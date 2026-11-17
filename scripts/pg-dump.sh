#!/usr/bin/env bash
# Dumps the Saleor database into the Floci bucket acdp-backups.
# The dump runs inside the Postgres pod, so client and server versions always match.
# Usage: scripts/pg-dump.sh [namespace]      (default: saleor-dev)
set -euo pipefail

export AWS_ACCESS_KEY_ID=test AWS_SECRET_ACCESS_KEY=test AWS_DEFAULT_REGION=us-east-1
export AWS_ENDPOINT_URL=http://127.0.0.1:4566 AWS_PAGER=""

ns="${1:-saleor-dev}"
pod="saleor-postgres-0"
bucket="acdp-backups"
key="postgres/${ns}/saleor-$(date -u +%Y%m%dT%H%M%SZ).dump"

# A dump holds user data, so the temp file is private and always removed.
umask 077
file=$(mktemp)
trap 'rm -f "$file"' EXIT

aws s3api head-bucket --bucket "$bucket"

# POSTGRES_USER, POSTGRES_DB and POSTGRES_PASSWORD already exist inside the pod.
kubectl -n "$ns" exec "$pod" -- sh -c \
  'PGPASSWORD="$POSTGRES_PASSWORD" pg_dump -h 127.0.0.1 -U "$POSTGRES_USER" -d "$POSTGRES_DB" --format=custom' \
  > "$file"

# A custom-format dump starts with the text PGDMP. Anything else means the dump failed.
[ "$(head -c 5 "$file")" = PGDMP ] || { echo "dump is not valid" >&2; exit 1; }

aws s3 cp "$file" "s3://${bucket}/${key}" --only-show-errors

local_size=$(stat -c %s "$file")
remote_size=$(aws s3api head-object --bucket "$bucket" --key "$key" --query ContentLength --output text)
[ "$local_size" = "$remote_size" ] || { echo "upload size mismatch" >&2; exit 1; }

echo "dump saved to s3://${bucket}/${key} (${remote_size} bytes)"
