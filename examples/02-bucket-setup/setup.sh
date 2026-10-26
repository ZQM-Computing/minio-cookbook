#!/usr/bin/env bash
# Set up example buckets + policies with mc. Credentials come from the
# environment only; nothing secret is written to disk by this script.
# Design-only example: compare with README.md expected output.
set -euo pipefail

: "${MINIO_ROOT_USER:?set MINIO_ROOT_USER}"
: "${MINIO_ROOT_PASSWORD:?set MINIO_ROOT_PASSWORD}"

mc alias set local http://localhost:9000 "$MINIO_ROOT_USER" "$MINIO_ROOT_PASSWORD"
mc admin info local

mc mb --ignore-existing local/rasters
mc mb --ignore-existing local/catalogs

mc policy set download local/rasters
mc policy set private local/catalogs

echo "--- buckets ---"
mc ls local
echo "--- policies ---"
mc policy get local/rasters
mc policy get local/catalogs
