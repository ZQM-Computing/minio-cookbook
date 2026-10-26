#!/usr/bin/env bash
# Set up example buckets and policies without writing credentials to the user's mc config.
set -euo pipefail

: "${MINIO_ROOT_USER:?set MINIO_ROOT_USER}"
: "${MINIO_ROOT_PASSWORD:?set MINIO_ROOT_PASSWORD}"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT
MC_CONFIG_DIR="$TMP_DIR/mc"
mkdir -p "$MC_CONFIG_DIR"
# Keep this example's alias/credentials isolated from the user's normal mc config.
mc_local() { mc --config-dir "$MC_CONFIG_DIR" "$@"; }

mc_local alias set local http://127.0.0.1:9000 "$MINIO_ROOT_USER" "$MINIO_ROOT_PASSWORD"
mc_local admin info local

mc_local mb --ignore-existing local/rasters
mc_local mb --ignore-existing local/catalogs

mc_local policy set download local/rasters
mc_local policy set private local/catalogs

echo "--- buckets ---"
mc_local ls local
echo "--- policies ---"
mc_local policy get local/rasters
mc_local policy get local/catalogs
