#!/usr/bin/env bash
# Build MinIO from source at the fleet tag, then smoke-start it.
# Design-only example: credentials are placeholders from the environment,
# never committed values. Compare with README.md expected output.
set -euo pipefail

TAG="RELEASE.2025-10-15T17-29-55Z"

if [ ! -d minio-src ]; then
  git clone --depth 1 --branch "$TAG" https://github.com/minio/minio.git minio-src
fi
cd minio-src
go build -o ../minio .

cd ..
./minio --version

mkdir -p scratch-data
MINIO_ROOT_USER="${MINIO_ROOT_USER:-CHANGEME}" \
MINIO_ROOT_PASSWORD="${MINIO_ROOT_PASSWORD:-CHANGEME}" \
./minio server scratch-data --address :9000 --console-address :9001 &
SERVER_PID=$!
sleep 5
curl -fsS http://localhost:9000/minio/health/ready
kill "$SERVER_PID"
echo "smoke start OK"
