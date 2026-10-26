#!/usr/bin/env bash
# Presigned download + upload URLs with mc share.
# Design-only example: credentials from the environment only.
# Compare with README.md expected output.
set -euo pipefail

: "${MINIO_ROOT_USER:?set MINIO_ROOT_USER}"
: "${MINIO_ROOT_PASSWORD:?set MINIO_ROOT_PASSWORD}"

mc alias set local http://localhost:9000 "$MINIO_ROOT_USER" "$MINIO_ROOT_PASSWORD"

printf 'synthetic raster placeholder, not a real GeoTIFF\n' > demo.tif
mc cp demo.tif local/rasters/demo.tif

echo "--- presigned download URL ---"
DOWNLOAD_URL=$(mc share download --expire 1h local/rasters/demo.tif)
echo "$DOWNLOAD_URL"
curl -fsS "$DOWNLOAD_URL" | head -c 200; echo

echo "--- presigned upload URL ---"
UPLOAD_URL=$(mc share upload --expire 1h local/rasters/uploaded.txt)
echo "$UPLOAD_URL"
printf 'uploaded via presigned URL\n' > uploaded.txt
curl -fsS -X PUT --upload-file uploaded.txt "$UPLOAD_URL"
mc ls local/rasters/
