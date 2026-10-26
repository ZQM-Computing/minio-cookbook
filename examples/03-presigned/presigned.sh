#!/usr/bin/env bash
# Exercise presigned download and upload URLs using a text fixture (not a fake GeoTIFF).
set -euo pipefail

: "${MINIO_ROOT_USER:?set MINIO_ROOT_USER}"
: "${MINIO_ROOT_PASSWORD:?set MINIO_ROOT_PASSWORD}"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT
MC_CONFIG_DIR="$TMP_DIR/mc"
mkdir -p "$MC_CONFIG_DIR"
mc_local() { mc --config-dir "$MC_CONFIG_DIR" "$@"; }

mc_local alias set local http://127.0.0.1:9000 "$MINIO_ROOT_USER" "$MINIO_ROOT_PASSWORD"

printf 'synthetic MinIO cookbook fixture; not geospatial raster data\n' > "$TMP_DIR/demo.txt"
mc_local cp "$TMP_DIR/demo.txt" local/catalogs/demo.txt

echo "--- presigned download URL ---"
DOWNLOAD_URL="$(mc_local share download --expire 1h local/catalogs/demo.txt)"
printf '%s\n' "$DOWNLOAD_URL"
curl --fail-with-body --silent --show-error --output "$TMP_DIR/downloaded.txt" "$DOWNLOAD_URL"
cmp "$TMP_DIR/demo.txt" "$TMP_DIR/downloaded.txt"
echo "PASS: downloaded bytes match the source fixture."

echo "--- presigned upload URL ---"
UPLOAD_URL="$(mc_local share upload --expire 1h local/catalogs/uploaded.txt)"
printf '%s\n' "$UPLOAD_URL"
printf 'uploaded through a presigned URL\n' > "$TMP_DIR/uploaded.txt"
curl --fail-with-body --silent --show-error --request PUT \
  --upload-file "$TMP_DIR/uploaded.txt" "$UPLOAD_URL"
mc_local stat local/catalogs/uploaded.txt
echo "PASS: uploaded object is visible through mc."
