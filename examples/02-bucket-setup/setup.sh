#!/usr/bin/env bash
# Set up example buckets and policies without writing credentials to the user's mc config.
set -euo pipefail

: "${MINIO_ROOT_USER:?set MINIO_ROOT_USER}"
: "${MINIO_ROOT_PASSWORD:?set MINIO_ROOT_PASSWORD}"
: "${MC_CONFIG_DIR:=$(mktemp -d)}"
CLEAN_CONFIG=0
if [[ -z "${MC_CONFIG_DIR:-}" ]]; then
  MC_CONFIG_DIR="$(mktemp -d)"
  CLEAN_CONFIG=1
fi
# Keep this example's alias/credentials isolated from the user's normal mc config.
if [[ -z "${MC_CONFIG_DIR:-}" ]]; then
  echo "Could not establish an isolated mc config directory" >&2
  exit 2
fi
mc_local() { mc --config-dir "$MC_CONFIG_DIR" "$@"; }

cleanup() {
  if [[ "$CLEAN_CONFIG" == 1 ]]; then rm -rf "$MC_CONFIG_DIR"; fi
}
trap cleanup EXIT

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
