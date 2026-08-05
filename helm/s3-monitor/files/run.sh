#!/usr/bin/env bash
set -euo pipefail

echo "Installing dependencies (awscli + boto3 + pika)..."
pip install --quiet awscli boto3 pika
echo "Dependencies installed."

REGION="${REGION:-us-east-1}"
CLUSTER_ID="${CLUSTER_ID:-gen3-qa-vectis-rdscluster7e964c7d-lqk85dtnbh5j}"
SECRET_NAME="${SECRET_NAME:-RdsSecretB4544A18-GrJ4o16zGYiT}"
DB_NAME="${DB_NAME:-postgres}"
S3_BUCKET="${S3_BUCKET:-gen3-qa-vectis-config}"
APPLY="${APPLY:-false}"
SCRIPTS_DIR="${SCRIPTS_DIR:-/scripts}"

echo "Step 1: Resolve ARNs"
RESOURCE_ARN="$(aws rds describe-db-clusters \
  --region "$REGION" \
  --db-cluster-identifier "$CLUSTER_ID" \
  --query 'DBClusters[0].DBClusterArn' \
  --output text)"

HTTP_ENDPOINT_ENABLED="$(aws rds describe-db-clusters \
  --region "$REGION" \
  --db-cluster-identifier "$CLUSTER_ID" \
  --query 'DBClusters[0].HttpEndpointEnabled' \
  --output text)"

SECRET_ARN="$(aws secretsmanager describe-secret \
  --region "$REGION" \
  --secret-id "$SECRET_NAME" \
  --query 'ARN' \
  --output text)"

echo "Cluster ARN : $RESOURCE_ARN"
echo "Secret ARN  : $SECRET_ARN"
echo "Data API    : $HTTP_ENDPOINT_ENABLED"
echo "S3 Bucket   : $S3_BUCKET"

if [[ "$HTTP_ENDPOINT_ENABLED" != "True" ]]; then
  echo "Enabling Data API..."
  aws rds modify-db-cluster \
    --region "$REGION" \
    --db-cluster-identifier "$CLUSTER_ID" \
    --enable-http-endpoint \
    --apply-immediately
fi

run_sql_file() {
  local sql_file="$1"
  echo "Running: $sql_file"
  aws rds-data execute-statement \
    --region "$REGION" \
    --resource-arn "$RESOURCE_ARN" \
    --secret-arn "$SECRET_ARN" \
    --database "$DB_NAME" \
    --sql "$(cat "$sql_file")"
}

if [[ "$APPLY" != "true" ]]; then
  echo "DRY RUN - no DDL or S3 sync executed."
  exit 0
fi

# echo "Step 2: Applying DDL"
# run_sql_file "$SCRIPTS_DIR/schema.sql"
# run_sql_file "$SCRIPTS_DIR/table.sql"
# run_sql_file "$SCRIPTS_DIR/index.sql"
# echo "-------------------------------------------"
# echo "Step 3: Checking table"
# TABLE_CHECK=$(aws rds-data execute-statement \
#   --region "$REGION" \
#   --resource-arn "$RESOURCE_ARN" \
#   --secret-arn "$SECRET_ARN" \
#   --database "$DB_NAME" \
#   --sql "SELECT table_schema, table_name FROM information_schema.tables WHERE table_schema='vectis' AND table_name='s3_metadata';" \
#   --query 'records' --output text)

# if [[ -z "$TABLE_CHECK" ]]; then
#   echo "TABLE STATUS: NOT FOUND - aborting sync"
#   exit 1
# fi
# echo "TABLE STATUS: EXISTS (vectis.s3_metadata)"

echo "-------------------------------------------"
echo "Step 2: Syncing S3 metadata + publishing to RabbitMQ"
export RESOURCE_ARN SECRET_ARN
python3 -u "$SCRIPTS_DIR/sync_s3.py"

echo "Done."
