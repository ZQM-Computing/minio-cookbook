#!/usr/bin/env bash
# Enable versioning on both buckets, apply the lifecycle rule, verify.
# Design-only example: credentials from the environment only.
# Compare with README.md expected output.
set -euo pipefail

: "${MINIO_ROOT_USER:?set MINIO_ROOT_USER}"
: "${MINIO_ROOT_PASSWORD:?set MINIO_ROOT_PASSWORD}"

mc alias set local http://localhost:9000 "$MINIO_ROOT_USER" "$MINIO_ROOT_PASSWORD"

python3 -m json.tool lifecycle.json > /dev/null

mc version enable local/rasters
mc version enable local/catalogs

mc ilm import local/catalogs < lifecycle.json

echo "--- versioning ---"
mc version info local/rasters
mc version info local/catalogs
echo "--- lifecycle rules on catalogs ---"
mc ilm rule ls local/catalogs
