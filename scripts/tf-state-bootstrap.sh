#!/usr/bin/env bash
# Creates the Floci S3 bucket that holds Terraform state.
# Terraform cannot create its own state bucket, so this uses the AWS CLI.
# Safe to re-run: it does nothing when the bucket already exists.
set -euo pipefail

export AWS_ACCESS_KEY_ID=test AWS_SECRET_ACCESS_KEY=test AWS_DEFAULT_REGION=us-east-1
export AWS_ENDPOINT_URL=http://127.0.0.1:4566 AWS_PAGER=""

bucket="acdp-tfstate"

if aws s3api head-bucket --bucket "$bucket" 2>/dev/null; then
  echo "bucket $bucket already exists"
else
  aws s3api create-bucket --bucket "$bucket" >/dev/null
  echo "bucket $bucket created"
fi
