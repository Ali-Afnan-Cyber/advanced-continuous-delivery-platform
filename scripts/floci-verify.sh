#!/usr/bin/env bash
# Smoke test for the Floci AWS emulator: S3, SSM and KMS round trips.
# Exit 0 means every check passed. Uses the IP, not localhost, so S3 stays path-style.
set -u
export AWS_ACCESS_KEY_ID=test AWS_SECRET_ACCESS_KEY=test AWS_DEFAULT_REGION=us-east-1
export AWS_ENDPOINT_URL=http://127.0.0.1:4566 AWS_PAGER=""

fail=0
check() { if "${@:2}" >/dev/null 2>&1; then echo "PASS $1"; else echo "FAIL $1"; fail=1; fi; }

bucket="floci-verify-$$"
param="/acdp/verify-$$"
file=$(mktemp)
echo hello > "$file"

# S3: make bucket, upload, download and compare, remove bucket
check "s3 make bucket"       aws s3 mb "s3://$bucket"
check "s3 upload"            aws s3 cp "$file" "s3://$bucket/hello.txt"
check "s3 download matches"  test "$(aws s3 cp "s3://$bucket/hello.txt" -)" = hello
check "s3 remove bucket"     aws s3 rb "s3://$bucket" --force
rm -f "$file"

# SSM: put, get, delete
check "ssm put"              aws ssm put-parameter --name "$param" --value v1 --type String
check "ssm get"              test "$(aws ssm get-parameter --name "$param" --query Parameter.Value --output text)" = v1
check "ssm delete"           aws ssm delete-parameter --name "$param"

# KMS: create key, encrypt, decrypt and compare
key=$(aws kms create-key --query KeyMetadata.KeyId --output text 2>/dev/null)
check "kms create key"       test -n "$key"
cipher=$(aws kms encrypt --key-id "$key" --plaintext "$(echo -n hello | base64)" \
  --query CiphertextBlob --output text 2>/dev/null)
check "kms encrypt/decrypt"  test "$(aws kms decrypt --ciphertext-blob "$cipher" \
  --query Plaintext --output text 2>/dev/null | base64 -d)" = hello
# Best-effort cleanup. Not counted as a check.
aws kms schedule-key-deletion --key-id "$key" --pending-window-in-days 7 >/dev/null 2>&1

[ $fail = 0 ] && echo "ALL PASS" || { echo "SOME FAILED"; exit 1; }
