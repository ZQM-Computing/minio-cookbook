#!/usr/bin/env bash
# Build the pinned MinIO source tag and smoke-start a disposable loopback instance.
# The source checkout, binary, data, and logs all live in one temporary directory.
set -euo pipefail

TAG="RELEASE.2025-10-15T17-29-55Z"
: "${MINIO_ROOT_USER:?set MINIO_ROOT_USER (at least 3 characters)}"
: "${MINIO_ROOT_PASSWORD:?set MINIO_ROOT_PASSWORD (at least 8 characters)}"
[[ "${#MINIO_ROOT_USER}" -ge 3 ]] || { echo "MINIO_ROOT_USER must be at least 3 characters" >&2; exit 2; }
[[ "${#MINIO_ROOT_PASSWORD}" -ge 8 ]] || { echo "MINIO_ROOT_PASSWORD must be at least 8 characters" >&2; exit 2; }

for tool in git go curl; do
  command -v "$tool" >/dev/null 2>&1 || { echo "ERROR: required command not found: $tool" >&2; exit 127; }
done

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

SOURCE_DIR="$TMP_DIR/minio-src"
BINARY="$TMP_DIR/minio"
git clone --depth 1 --branch "$TAG" https://github.com/minio/minio.git "$SOURCE_DIR"
ACTUAL_TAG="$(git -C "$SOURCE_DIR" describe --tags --exact-match HEAD)"
if [[ "$ACTUAL_TAG" != "$TAG" ]]; then
  echo "ERROR: expected source tag $TAG, got $ACTUAL_TAG" >&2
  exit 1
fi

(
  cd "$SOURCE_DIR"
  go build -o "$BINARY" .
)
"$BINARY" --version

mkdir -p "$TMP_DIR/data"
MINIO_ROOT_USER="$MINIO_ROOT_USER" MINIO_ROOT_PASSWORD="$MINIO_ROOT_PASSWORD" \
  "$BINARY" server "$TMP_DIR/data" \
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

echo "PASS: MinIO built from $TAG and is ready on loopback only."
