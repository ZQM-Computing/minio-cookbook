#!/usr/bin/env bash
# Enable versioning and apply the sample lifecycle rule using an isolated mc config.
set -euo pipefail

: "${MINIO_ROOT_USER:?set MINIO_ROOT_USER}"
: "${MINIO_ROOT_PASSWORD:?set MINIO_ROOT_PASSWORD}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT
mkdir -p "$TMP_DIR/mc"
mc_local() { mc --config-dir "$TMP_DIR/mc" "$@"; }

mc_local alias set local http://127.0.0.1:9000 "$MINIO_ROOT_USER" "$MINIO_ROOT_PASSWORD"
python3 -m json.tool "$SCRIPT_DIR/lifecycle.json" > /dev/null

mc_local version enable local/rasters
mc_local version enable local/catalogs

mc_local ilm import local/catalogs < "$SCRIPT_DIR/lifecycle.json"

echo "--- versioning ---"
mc_local version info local/rasters
mc_local version info local/catalogs
echo "--- lifecycle rules on catalogs ---"
mc_local ilm rule ls local/catalogs
