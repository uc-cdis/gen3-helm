#!/usr/bin/env python3
"""
Add or update S3 object metadata into vectis.s3_metadata with crash recovery.
"""
import hashlib
import json
import os
import sys
from datetime import datetime, timezone, timedelta

import boto3
import botocore.exceptions

import pika, ssl, traceback

PAGE_SIZE = 2000  # Limiting respone to 2000 records at a time
LOOKBACK_DAYS = 3


def load_config():
    """Read required configuration from the environment."""
    return {
        "REGION":       os.environ["REGION"],
        "RESOURCE_ARN": os.environ["RESOURCE_ARN"],
        "SECRET_ARN":   os.environ["SECRET_ARN"],
        "DB_NAME":      os.environ["DB_NAME"],
        "S3_BUCKET":    os.environ["S3_BUCKET"],
    }


def make_clients(region):
    """Create the boto3 clients used throughout the script."""
    s3_client  = boto3.client("s3", region_name=region)
    rds_client = boto3.client("rds-data", region_name=region)
    return s3_client, rds_client


def escape(val):
    return str(val).replace("'", "''")


def run_sql(rds_client, resource_arn, secret_arn, db_name, sql):
    try:
        return rds_client.execute_statement(
            resourceArn = resource_arn,
            secretArn   = secret_arn,
            database    = db_name,
            sql         = sql,
        )
    except botocore.exceptions.ClientError as e:
        print(f"  [SQL ERROR] {e}", file=sys.stderr)
        sys.exit(1)


def run_sql_pages(rds_client, resource_arn, secret_arn, db_name, build_sql, get_cursor, page_size=PAGE_SIZE):
    """
    Running SQL query
    """
    all_records = []
    cursor = None

    while True:
        result  = run_sql(rds_client, resource_arn, secret_arn, db_name, build_sql(cursor, page_size))
        records = result.get("records", []) if result else []

        if not records:
            break
        all_records.extend(records)
        cursor = get_cursor(records)
        if len(records) < page_size:
            break
    return all_records


def get_content_type(s3_client, bucket, key):
    try:
        resp = s3_client.head_object(Bucket=bucket, Key=key)
        return resp.get("ContentType")
    except botocore.exceptions.ClientError:
        return None


def get_md5(s3_client, bucket, key, etag):
    clean_etag = etag.strip('"') if etag else ""
    if clean_etag and "-" not in clean_etag and len(clean_etag) == 32:
        return clean_etag
    print(f"    [MD5] Multipart upload — streaming {key} to compute MD5...")
    try:
        resp   = s3_client.get_object(Bucket=bucket, Key=key)
        hasher = hashlib.md5()
        for chunk in resp["Body"].iter_chunks(chunk_size=8192):
            hasher.update(chunk)
        return hasher.hexdigest()
    except Exception as exc:
        print(f"    [MD5 ERROR] Could not compute MD5 for {key}: {exc!r}")
        return None


def ensure_column(rds_client, resource_arn, secret_arn, db_name, table, column, coldef):
    exists = run_sql(rds_client, resource_arn, secret_arn, db_name, f"""
        SELECT 1
        FROM information_schema.columns
        WHERE table_schema = 'vectis'
          AND table_name   = '{escape(table)}'
          AND column_name  = '{escape(column)}';
    """)
    if exists and exists.get("records"):
        print(f"  [SCHEMA] Column '{column}' already exists on {table} — skipping.")
        return
    print(f"  [SCHEMA] Column '{column}' missing on {table} — adding it now...")
    run_sql(rds_client, resource_arn, secret_arn, db_name,
            f"ALTER TABLE vectis.{table} ADD COLUMN IF NOT EXISTS {column} {coldef};")
    print(f"  [SCHEMA] Column '{column}' added.")



def scan_s3_objects(s3_client, bucket, lookback_days=LOOKBACK_DAYS):
    """List bucket contents and filter to objects modified within the lookback window."""
    cutoff = datetime.now(timezone.utc) - timedelta(days=lookback_days)

    paginator     = s3_client.get_paginator("list_objects_v2")
    objects       = []
    scanned_total = 0
    try:
        for page in paginator.paginate(Bucket=bucket):
            page_objects   = page.get("Contents", [])
            scanned_total += len(page_objects)
            objects.extend(obj for obj in page_objects if obj["LastModified"] >= cutoff)
    except botocore.exceptions.ClientError as e:
        print(f"[ERROR] Could not list S3 bucket: {e}", file=sys.stderr)
        sys.exit(1)

    print(f"  Scanned {scanned_total} object(s) in s3://{bucket}")
    print(f"  {len(objects)} object(s) created/modified in the last {lookback_days} day(s)\n")
    return objects


def load_known_files(rds_client, resource_arn, secret_arn, db_name, bucket):
    """Load the current known file sizes for this bucket from the DB, paginated."""
    print("  Loading known files from DB (paginated)")
    known_files = {}

    def _known_files_page_sql(cursor, page_size):
        cursor_clause = f"AND file_key > '{escape(cursor)}'" if cursor else ""
        return f"""
            SELECT file_key, current_size_bytes FROM (
                SELECT DISTINCT ON (file_key)
                       file_key,
                       current_size_bytes
                FROM   vectis.s3_metadata
                WHERE  bucket_name = '{escape(bucket)}'
                  AND  s3_last_modified >= NOW() - INTERVAL '7 days'
                ORDER  BY file_key, detected_at DESC
            ) latest
            WHERE 1=1 {cursor_clause}
            ORDER BY file_key
            LIMIT {page_size}
        """

    known_records = run_sql_pages(
        rds_client, resource_arn, secret_arn, db_name,
        _known_files_page_sql,
        get_cursor=lambda records: records[-1][0]["stringValue"],
    )
    for record in known_records:
        fkey  = record[0]["stringValue"]
        fsize = record[1].get("longValue", 0)
        known_files[fkey] = fsize
    print(f"  DB has {len(known_files)} known file(s) for this bucket\n")
    return known_files


def sync_objects(s3_client, rds_client, resource_arn, secret_arn, db_name, bucket, objects, known_files):
    """Insert new objects and update changed ones in vectis.s3_metadata."""
    inserted = 0
    updated  = 0
    skipped  = 0

    for obj in objects:
        key           = obj["Key"]
        size          = obj["Size"]
        last_modified = obj["LastModified"].isoformat()
        etag          = obj.get("ETag", "").strip('"')
        storage_class = obj.get("StorageClass", "STANDARD")

        if key not in known_files:
            content_type = get_content_type(s3_client, bucket, key)
            ct_col = ", content_type" if content_type else ""
            ct_val = f", '{escape(content_type)}'" if content_type else ""
            md5_val = get_md5(s3_client, bucket, key, etag)
            md5_col = ", md5_checksum" if md5_val else ""
            md5_sql_val = f", '{escape(md5_val)}'" if md5_val else ""

            run_sql(rds_client, resource_arn, secret_arn, db_name, f"""
                INSERT INTO vectis.s3_metadata
                  (bucket_name, file_key, current_size_bytes,
                   etag, storage_class, event_type, s3_last_modified, published_to_mq{ct_col}{md5_col})
                VALUES
                  ('{escape(bucket)}', '{escape(key)}', {size},
                   '{escape(etag)}', '{escape(storage_class)}',
                   'CREATED', '{escape(last_modified)}', FALSE{ct_val}{md5_sql_val})
            """)
            print(f"  [CREATED]  {key}  ({size} bytes)  md5: {md5_val or 'unavailable'}  saved to DB.")
            inserted += 1

        else:
            prev_size = known_files[key]

            if prev_size == size:
                skipped += 1
            else:
                delta        = size - prev_size
                direction    = "increased" if delta > 0 else "decreased"
                content_type = get_content_type(s3_client, bucket, key)
                ct_col       = ", content_type" if content_type else ""
                ct_val = f", '{escape(content_type)}'" if content_type else ""
                md5_val = get_md5(s3_client, bucket, key, etag)
                md5_col = ", md5_checksum" if md5_val else ""
                md5_sql_val = f", '{escape(md5_val)}'" if md5_val else ""

                run_sql(rds_client, resource_arn, secret_arn, db_name, f"""
                    INSERT INTO vectis.s3_metadata
                      (bucket_name, file_key, current_size_bytes, previous_size_bytes,
                       etag, storage_class, event_type, s3_last_modified, published_to_mq{ct_col}{md5_col})
                    VALUES
                      ('{escape(bucket)}', '{escape(key)}', {size}, {prev_size},
                       '{escape(etag)}', '{escape(storage_class)}',
                       'UPDATED', '{escape(last_modified)}', FALSE{ct_val}{md5_sql_val})
                """)
                print(f"  [UPDATED]  {key}  size {direction}: {prev_size} -> {size} bytes  md5: {md5_val or 'unavailable'}  saved to DB.")
                updated += 1

    print(f"\n{'='*60}")
    print(f"  Summary: {inserted} inserted | {updated} updated | {skipped} skipped")
    print(f"{'='*60}\n")

    return inserted, updated, skipped


def get_pending_rows(s3_client, rds_client, resource_arn, secret_arn, db_name, bucket):
    """
    Handling the cases which were missed earlier to be published to RabbiMQ. This is to ensure atleast one successfull message to MQ
    """
    print("Checking database for un-published events (including recovery from past crashes, paginated)")

    def _pending_page_sql(cursor, page_size):
        cursor_clause = f"AND id > {cursor}" if cursor else ""
        return f"""
            SELECT id, event_type, bucket_name, file_key, current_size_bytes,
                   previous_size_bytes, size_delta_bytes, etag, storage_class,
                   content_type, s3_last_modified, md5_checksum
            FROM vectis.s3_metadata
            WHERE published_to_mq = FALSE
              AND bucket_name = '{escape(bucket)}'
              {cursor_clause}
            ORDER BY id
            LIMIT {page_size}
        """

    pending_rows = run_sql_pages(
        rds_client, resource_arn, secret_arn, db_name,
        _pending_page_sql,
        get_cursor=lambda records: records[-1][0]["longValue"],
    )

    processed_rows = []
    for r in pending_rows:
        db_id = r[0]["longValue"]
        f_key = r[3]["stringValue"]
        e_tag = r[7]["stringValue"]

        md5_val = r[11].get("stringValue")
        if not md5_val:
            md5_val = get_md5(s3_client, bucket, f_key, e_tag)
            if md5_val:
                run_sql(rds_client, resource_arn, secret_arn, db_name, f"""
                    UPDATE vectis.s3_metadata
                    SET md5_checksum = '{escape(md5_val)}'
                    WHERE id = {db_id};
                """)

        processed_rows.append({
            "db_id":               db_id,
            "event_type":          r[1]["stringValue"],
            "bucket_name":         r[2]["stringValue"],
            "file_key":            f_key,
            "current_size_bytes":  r[4]["longValue"],
            "previous_size_bytes": r[5].get("longValue"),
            "size_delta_bytes":    r[6].get("longValue"),
            "etag":                e_tag,
            "md5_checksum":        md5_val,
            "storage_class":       r[8]["stringValue"],
            "content_type":        r[9].get("stringValue"),
            "s3_last_modified":    r[10]["stringValue"]
        })

    return processed_rows


def resolve_rabbitmq_host(rabbitmq_url, rabbitmq_port):
    """Resolve the RabbitMQ hostname to an IPv4 address."""
    print(f"\nResolving {rabbitmq_url}")
    try:
        import socket
        addr_info  = socket.getaddrinfo(rabbitmq_url, rabbitmq_port, socket.AF_UNSPEC)
        ipv4_addrs = [sa[0] for fam, _, _, _, sa in addr_info if fam == socket.AF_INET]
        if not ipv4_addrs:
            print("No IPv4 address found — aborting RabbitMQ publish")
            sys.exit(1)
        mq_ip = ipv4_addrs[0]
        print(f"  Using IPv4: {mq_ip}")
        return mq_ip
    except Exception as e:
        print(f"  DNS resolution failed: {e!r}")
        sys.exit(1)


def fetch_queue_name(rabbitmq_url, mq_user, mq_pass):
    """Look up an existing queue via the RabbitMQ Management API, falling back to a default."""
    print("\nFetching queues from RabbitMQ Management API")
    try:
        import urllib.request, base64
        mgmt_url    = f"https://{rabbitmq_url}:443/api/queues"
        req         = urllib.request.Request(mgmt_url)
        credentials_b64 = base64.b64encode(f"{mq_user}:{mq_pass}".encode()).decode()
        req.add_header("Authorization", f"Basic {credentials_b64}")
        with urllib.request.urlopen(req, timeout=15) as resp:
            queues = json.loads(resp.read().decode())
        queue_name = queues[0]["name"] if queues else "s3-monitor-queue"
        print(f"  Found {len(queues)} queue(s) — using: '{queue_name}'")
        return queue_name
    except Exception as e:
        print(f"  Could not fetch queues ({e!r}) — using default: 's3-monitor-queue'")
        return "s3-monitor-queue"


def publish_to_rabbitmq(rds_client, resource_arn, secret_arn, db_name, processed_rows):
    """Connect to RabbitMQ and publish each pending row, acking it in the DB as it goes."""
    
    rabbitmq_url  = os.environ.get("RABBITMQ_URL", "b-60a6d3ee-83ab-4602-b0e6-d89bd97315be.mq.us-east-1.on.aws")
    rabbitmq_port = int(os.environ.get("RABBITMQ_PORT", "5671"))
    mq_user       = os.environ.get("MQ_USER", "vectis")
    mq_pass       = os.environ.get("MQ_PASS", "")

    print(f"{'='*60}")
    print(f"  RabbitMQ Publish  |  {len(processed_rows)} message(s) to send")
    print(f"{'='*60}")

    mq_ip = resolve_rabbitmq_host(rabbitmq_url, rabbitmq_port)
    queue_name = fetch_queue_name(rabbitmq_url, mq_user, mq_pass)

    print(f"\nConnecting to RabbitMQ at {rabbitmq_url}:{rabbitmq_port}")
    try:
        ssl_context                = ssl.SSLContext(ssl.PROTOCOL_TLS_CLIENT)
        ssl_context.check_hostname = False
        ssl_context.verify_mode    = ssl.CERT_NONE

        parameters = pika.ConnectionParameters(
            host=mq_ip,
            port=rabbitmq_port,
            virtual_host="/",
            credentials=pika.PlainCredentials(mq_user, mq_pass),
            ssl_options=pika.SSLOptions(ssl_context, server_hostname=rabbitmq_url),
            connection_attempts=3,
            retry_delay=5,
            socket_timeout=30,
            heartbeat=60,
            blocked_connection_timeout=30,
        )

        mq_conn    = pika.BlockingConnection(parameters)
        mq_channel = mq_conn.channel()
        mq_channel.queue_declare(queue=queue_name, durable=True, arguments={"x-queue-type": "quorum"})
        print(f"  Connected! Publishing {len(processed_rows)} message(s) to '{queue_name}'...")

        for row in processed_rows:
            current_id = row.pop("db_id")  # Remove ID tracking from MQ message payload
            msg = json.dumps(row, default=str)

            mq_channel.basic_publish(
                exchange="",
                routing_key=queue_name,
                body=msg.encode("utf-8"),
                properties=pika.BasicProperties(
                    delivery_mode=2,
                    content_type="application/json",
                ),
            )

            run_sql(rds_client, resource_arn, secret_arn, db_name,
                    f"UPDATE vectis.s3_metadata SET published_to_mq = TRUE WHERE id = {current_id};")
            print(f"  [PUBLISHED & ACKED] {row['event_type']} — {row['file_key']}")

        mq_conn.close()
        print(f"\n  Successfully processed and acknowledged all messages.")

    except Exception as e:
        print(f"  [MQ ERROR] Failed to publish: {type(e).__name__}: {e!r}")
        traceback.print_exc()
        sys.exit(1)

    print(f"{'='*60}\n")


def main():
    config = load_config()
    region        = config["REGION"]
    resource_arn  = config["RESOURCE_ARN"]
    secret_arn    = config["SECRET_ARN"]
    db_name       = config["DB_NAME"]
    bucket        = config["S3_BUCKET"]

    s3_client, rds_client = make_clients(region)

    # 1. Scan S3 for recently created/modified objects.
    objects = scan_s3_objects(s3_client, bucket)

    # 2. Load what the DB currently knows about this bucket's files.
    known_files = load_known_files(rds_client, resource_arn, secret_arn, db_name, bucket)

    # 3. Insert/update rows in the DB for anything new or changed.
    sync_objects(s3_client, rds_client, resource_arn, secret_arn, db_name, bucket, objects, known_files)

    # 4. Gather anything still un-published (including recovery from a past crash).
    processed_rows = get_pending_rows(s3_client, rds_client, resource_arn, secret_arn, db_name, bucket)

    if not processed_rows:
        print("No rows to publish to RabbitMQ (all caught up).")
        sys.exit(0)

    # 5. Publish pending rows to RabbitMQ, acknowledging each in the DB as it's sent.
    publish_to_rabbitmq(rds_client, resource_arn, secret_arn, db_name, processed_rows)


if __name__ == "__main__":
    main()