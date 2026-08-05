#!/usr/bin/env python3
"""
Add or update S3 object metadata into vectis.s3_metadata with crash recovery.
"""
import hashlib
import json
import os
import sys
import boto3
import botocore.exceptions
from datetime import datetime, timezone, timedelta

REGION       = os.environ["REGION"]
RESOURCE_ARN = os.environ["RESOURCE_ARN"]
SECRET_ARN   = os.environ["SECRET_ARN"]
DB_NAME      = os.environ["DB_NAME"]
S3_BUCKET    = os.environ["S3_BUCKET"]

s3_client  = boto3.client("s3",       region_name=REGION)
rds_client = boto3.client("rds-data", region_name=REGION)

def run_sql(sql):
    try:
        return rds_client.execute_statement(
            resourceArn = RESOURCE_ARN,
            secretArn   = SECRET_ARN,
            database    = DB_NAME,
            sql         = sql,
        )
    except botocore.exceptions.ClientError as e:
        print(f"  [SQL ERROR] {e}", file=sys.stderr)
        sys.exit(1)

def escape(val):
    return str(val).replace("'", "''")

PAGE_SIZE = 2000  # keep each execute_statement response comfortably under the Data API's 1MB cap

def run_sql_pages(build_sql, get_cursor, page_size=PAGE_SIZE):
    """
   Running SQL query 
    """
    all_records = []
    cursor = None

    
    while True:
        result  = run_sql(build_sql(cursor, page_size))
        records = result.get("records", []) if result else []

    
        if not records:
            break
        all_records.extend(records)
        cursor = get_cursor(records)
        if len(records) < page_size:
            break
    return all_records

def get_content_type(key):
    try:
        resp = s3_client.head_object(Bucket=S3_BUCKET, Key=key)
        return resp.get("ContentType")
    except botocore.exceptions.ClientError:
        return None

def get_md5(key, etag):
    clean_etag = etag.strip('"') if etag else ""
    if clean_etag and "-" not in clean_etag and len(clean_etag) == 32:
        return clean_etag
    print(f"    [MD5] Multipart upload — streaming {key} to compute MD5...")
    try:
        resp   = s3_client.get_object(Bucket=S3_BUCKET, Key=key)
        hasher = hashlib.md5()
        for chunk in resp["Body"].iter_chunks(chunk_size=8192):
            hasher.update(chunk)
        return hasher.hexdigest()
    except Exception as exc:
        print(f"    [MD5 ERROR] Could not compute MD5 for {key}: {exc!r}")
        return None

def ensure_column(table, column, coldef):
   
    exists = run_sql(f"""
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
    run_sql(f"ALTER TABLE vectis.{table} ADD COLUMN IF NOT EXISTS {column} {coldef};")
    print(f"  [SCHEMA] Column '{column}' added.")

ensure_column("s3_metadata", "published_to_mq", "BOOLEAN NOT NULL DEFAULT FALSE")
ensure_column("s3_metadata", "md5_checksum", "TEXT")

print(f"\n{'='*60}")
print(f"  S3 Sync  |  bucket: {S3_BUCKET}")
print(f"{'='*60}")

LOOKBACK_DAYS = 3
cutoff = datetime.now(timezone.utc) - timedelta(days=LOOKBACK_DAYS)

paginator     = s3_client.get_paginator("list_objects_v2")
objects       = []
scanned_total = 0
try:
    for page in paginator.paginate(Bucket=S3_BUCKET):
        page_objects   = page.get("Contents", [])
        scanned_total += len(page_objects)
        objects.extend(obj for obj in page_objects if obj["LastModified"] >= cutoff)
except botocore.exceptions.ClientError as e:
    print(f"[ERROR] Could not list S3 bucket: {e}", file=sys.stderr)
    sys.exit(1)

print(f"  Scanned {scanned_total} object(s) in s3://{S3_BUCKET}")
print(f"  {len(objects)} object(s) created/modified in the last {LOOKBACK_DAYS} day(s)\n")

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
            WHERE  bucket_name = '{escape(S3_BUCKET)}'
              AND  s3_last_modified >= NOW() - INTERVAL '7 days'
            ORDER  BY file_key, detected_at DESC
        ) latest
        WHERE 1=1 {cursor_clause}
        ORDER BY file_key
        LIMIT {page_size}
    """

known_records = run_sql_pages(
    _known_files_page_sql,
    get_cursor=lambda records: records[-1][0]["stringValue"],
)
for record in known_records:
    fkey  = record[0]["stringValue"]
    fsize = record[1].get("longValue", 0)
    known_files[fkey] = fsize
print(f"  DB has {len(known_files)} known file(s) for this bucket\n")

inserted       = 0
updated        = 0
skipped        = 0

for obj in objects:
    key           = obj["Key"]
    size          = obj["Size"]
    last_modified = obj["LastModified"].isoformat()
    etag          = obj.get("ETag", "").strip('"')
    storage_class = obj.get("StorageClass", "STANDARD")

    if key not in known_files:
        content_type = get_content_type(key)
        ct_col = ", content_type" if content_type else ""
        ct_val = f", '{escape(content_type)}'" if content_type else ""
        md5_val = get_md5(key, etag)
        md5_col = ", md5_checksum" if md5_val else ""
        md5_sql_val = f", '{escape(md5_val)}'" if md5_val else ""

        run_sql(f"""
            INSERT INTO vectis.s3_metadata
              (bucket_name, file_key, current_size_bytes,
               etag, storage_class, event_type, s3_last_modified, published_to_mq{ct_col}{md5_col})
            VALUES
              ('{escape(S3_BUCKET)}', '{escape(key)}', {size},
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
            content_type = get_content_type(key)
            ct_col       = ", content_type" if content_type else ""
            ct_val = f", '{escape(content_type)}'" if content_type else ""
            md5_val = get_md5(key, etag)
            md5_col = ", md5_checksum" if md5_val else ""
            md5_sql_val = f", '{escape(md5_val)}'" if md5_val else ""

            run_sql(f"""
                INSERT INTO vectis.s3_metadata
                  (bucket_name, file_key, current_size_bytes, previous_size_bytes,
                   etag, storage_class, event_type, s3_last_modified, published_to_mq{ct_col}{md5_col})
                VALUES
                  ('{escape(S3_BUCKET)}', '{escape(key)}', {size}, {prev_size},
                   '{escape(etag)}', '{escape(storage_class)}',
                   'UPDATED', '{escape(last_modified)}', FALSE{ct_val}{md5_sql_val})
            """)
            print(f"  [UPDATED]  {key}  size {direction}: {prev_size} -> {size} bytes  md5: {md5_val or 'unavailable'}  saved to DB.")
            updated += 1

print(f"\n{'='*60}")
print(f"  Summary: {inserted} inserted | {updated} updated | {skipped} skipped")
print(f"{'='*60}\n")

print("Checking database for un-published events (including recovery from past crashes, paginated)")

def _pending_page_sql(cursor, page_size):
    cursor_clause = f"AND id > {cursor}" if cursor else ""
    return f"""
        SELECT id, event_type, bucket_name, file_key, current_size_bytes,
               previous_size_bytes, size_delta_bytes, etag, storage_class,
               content_type, s3_last_modified, md5_checksum
        FROM vectis.s3_metadata
        WHERE published_to_mq = FALSE
          AND bucket_name = '{escape(S3_BUCKET)}'
          {cursor_clause}
        ORDER BY id
        LIMIT {page_size}
    """

pending_rows = run_sql_pages(
    _pending_page_sql,
    get_cursor=lambda records: records[-1][0]["longValue"],
)


processed_rows = []
if pending_rows:
    for r in pending_rows:
        db_id = r[0]["longValue"]
        f_key = r[3]["stringValue"]
        e_tag = r[7]["stringValue"]

        md5_val = r[11].get("stringValue")
        if not md5_val:
            md5_val = get_md5(f_key, e_tag)
            if md5_val:
                run_sql(f"""
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

if not processed_rows:
    print("No rows to publish to RabbitMQ (all caught up).")
    sys.exit(0)

import pika, ssl, socket, traceback

RABBITMQ_URL  = os.environ.get("RABBITMQ_URL", "b-60a6d3ee-83ab-4602-b0e6-d89bd97315be.mq.us-east-1.on.aws")
RABBITMQ_PORT = int(os.environ.get("RABBITMQ_PORT", "5671"))
MQ_USER       = os.environ.get("MQ_USER", "vectis")
MQ_PASS       = os.environ.get("MQ_PASS", "")

print(f"{'='*60}")
print(f"  RabbitMQ Publish  |  {len(processed_rows)} message(s) to send")
print(f"{'='*60}")

print(f"\nResolving {RABBITMQ_URL}")
try:
    addr_info    = socket.getaddrinfo(RABBITMQ_URL, RABBITMQ_PORT, socket.AF_UNSPEC)
    ipv4_addrs   = [sa[0] for fam, _, _, _, sa in addr_info if fam == socket.AF_INET]
    if not ipv4_addrs:
        print("No IPv4 address found — aborting RabbitMQ publish")
        sys.exit(1)
    mq_ip = ipv4_addrs[0]
    print(f"  Using IPv4: {mq_ip}")
except Exception as e:
    print(f"  DNS resolution failed: {e!r}")
    sys.exit(1)

print("\nFetching queues from RabbitMQ Management API")
try:
    import urllib.request, base64
    mgmt_url    = f"https://{RABBITMQ_URL}:443/api/queues"
    req         = urllib.request.Request(mgmt_url)
    credentials_b64 = base64.b64encode(f"{MQ_USER}:{MQ_PASS}".encode()).decode()
    req.add_header("Authorization", f"Basic {credentials_b64}")
    with urllib.request.urlopen(req, timeout=15) as resp:
        queues = json.loads(resp.read().decode())
    QUEUE_NAME = queues[0]["name"] if queues else "s3-monitor-queue"
    print(f"  Found {len(queues)} queue(s) — using: '{QUEUE_NAME}'")
except Exception as e:
    QUEUE_NAME = "s3-monitor-queue"
    print(f"  Could not fetch queues ({e!r}) — using default: '{QUEUE_NAME}'")

print(f"\nConnecting to RabbitMQ at {RABBITMQ_URL}:{RABBITMQ_PORT}")
try:
    ssl_context             = ssl.SSLContext(ssl.PROTOCOL_TLS_CLIENT)
    ssl_context.check_hostname = False
    ssl_context.verify_mode = ssl.CERT_NONE

    parameters = pika.ConnectionParameters(
        host=mq_ip,
        port=RABBITMQ_PORT,
        virtual_host="/",
        credentials=pika.PlainCredentials(MQ_USER, MQ_PASS),
        ssl_options=pika.SSLOptions(ssl_context, server_hostname=RABBITMQ_URL),
        connection_attempts=3,
        retry_delay=5,
        socket_timeout=30,
        heartbeat=60,
        blocked_connection_timeout=30,
    )

    mq_conn    = pika.BlockingConnection(parameters)
    mq_channel = mq_conn.channel()
    mq_channel.queue_declare(queue=QUEUE_NAME, durable=True, arguments={"x-queue-type": "quorum"})
    print(f"  Connected! Publishing {len(processed_rows)} message(s) to '{QUEUE_NAME}'...")

    for row in processed_rows:
        current_id = row.pop("db_id") # Remove ID tracking from MQ message payload
        msg = json.dumps(row, default=str)

        mq_channel.basic_publish(
            exchange="",
            routing_key=QUEUE_NAME,
            body=msg.encode("utf-8"),
            properties=pika.BasicProperties(
                delivery_mode=2,
                content_type="application/json",
            ),
        )

        run_sql(f"UPDATE vectis.s3_metadata SET published_to_mq = TRUE WHERE id = {current_id};")
        print(f"  [PUBLISHED & ACKED] {row['event_type']} — {row['file_key']}")

    mq_conn.close()
    print(f"\n  Successfully processed and acknowledged all messages.")

except Exception as e:
    print(f"  [MQ ERROR] Failed to publish: {type(e).__name__}: {e!r}")
    traceback.print_exc()
    sys.exit(1)

print(f"{'='*60}\n")


