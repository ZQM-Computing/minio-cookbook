#!/usr/bin/env bash
# Build the pinned MinIO source tag, then smoke-start a disposable local instance.
# This example requires explicit credentials and binds only to loopback.
set -euo pipefail

TAG="RELEASE.2025-10-15T17-29-55Z"
: "${MINIO_ROOT_USER:?set MINIO_ROOT_USER (at least 3 characters)}"
: "${MINIO_ROOT_PASSWORD:?set MINIO_ROOT_PASSWORD (at least 8 characters)}"
[[ "${#MINIO_ROOT_USER}" -ge 3 ]] || { echo "MINIO_ROOT_USER must be at least 3 characters" >&2; exit 2; }
[[ "${#MINIO_ROOT_PASSWORD}" -ge 8 ]] || { echo "MINIO_ROOT_PASSWORD must be at least 8 characters" >&2; exit 2; }

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"
if [ ! -d minio-src ]; then
  git clone --depth 1 --branch "$TAG" https://github.com/minio/minio.git minio-src
fi
cd minio-src
go build -o ../minio .
cd "$ROOT_DIR"
./minio --version

TMP_DIR="$(mktemp -d)"
SERVER_PID=""
cleanup() {
  if [[ -n "$SERVER_PID" ]]; then
    kill "$SERVER_PID" 2>/dev/null || true
    wait "$SERVER_PID" 2>/dev/null || true
  fi
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT

mkdir -p "$TMP_DIR/data"
MINIO_ROOT_USER="$MINIO_ROOT_USER" MINIO_ROOT_PASSWORD="$MINIO_ROOT_PASSWORD" \
  ./minio server "$TMP_DIR/data" \
  --address 127.0.0.1:9000 --console-address 127.0.0.1:9001 \
  >"$TMP_DIR/server.log" 2>&1 &
SERVER_PID=$!

echo "Waiting for loopback readiness (up to 30 seconds)..."
ready=0
for _ in $(seq 1 30); do
  if curl --fail --silent --show-error --max-time 2 \
      --output /dev/null http://127.0.0.1:9000/minio/health/ready; then
    ready=1
    break
  fi
  sleep 1
done
if [[ "$ready" != 1 ]]; then
  echo "MinIO did not become ready. Server log follows:" >&2
  cat "$TMP_DIR/server.log" >&2
  exit 1
fi

echo "PASS: MinIO is ready on loopback only; cleanup will stop the process."
