#!/usr/bin/env bash
# Copies the current Terraform state to a folder outside the repo.
# State can hold secrets, so the folder is mode 700 and each file is mode 600.
# It uses "terraform state pull", so it works with the local and the S3 backend.
set -euo pipefail

repo=$(cd "$(dirname "$0")/.." && pwd)
tf="$repo/infra/terraform/envs/local"
dest="$HOME/acdp-state-backups/terraform"
file="$dest/tfstate-$(date +%Y%m%d-%H%M%S).json"

mkdir -p "$dest"
chmod 700 "$dest"

# The copy must exist and be valid JSON, or the backup counts as failed.
if ! terraform -chdir="$tf" state pull > "$file" \
   || ! python3 -c 'import json,sys; json.load(open(sys.argv[1]))' "$file"; then
  rm -f "$file"
  echo "backup failed" >&2
  exit 1
fi

chmod 600 "$file"
echo "state saved to $file"
