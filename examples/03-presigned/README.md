# 03 — Presigned URLs: Uploads and Downloads Without Credentials

**Design-only — gate 1 target. Not runtime-validated.** This pattern issues
presigned URLs with `mc share`: a time-limited download URL for a raster
asset and a time-limited upload URL for a drop folder, so a client needs no
MinIO credentials at all.

## Prerequisites

- A running MinIO server with the pattern 02 buckets (`rasters`, `catalogs`)
- `mc` installed
- Bash

## Files

- `presigned.sh` — object upload, presigned download, presigned upload

## Steps

```bash
export MINIO_ROOT_USER="your-admin-user"
export MINIO_ROOT_PASSWORD="your-admin-password"
bash presigned.sh
```

## Expected output

- A synthetic object `demo.tif` lands in `local/rasters/` (a small placeholder
  file, not a real raster).
- `mc share download` prints a URL containing an expiry parameter and a
  signature; fetching it with `curl` returns the object bytes.
- `mc share upload` prints a URL; uploading a second file to it with `curl`
  succeeds, and the object appears in the bucket.
- After expiry, the same URL fails with an expired-signature error (do not
  wait out a long expiry in the demo — use a short expiry and confirm the
  error form).

## Failure behavior

- Expired URL reused: signature-expired error. That is the feature working,
  not a failure — issue a fresh URL.
- Upload URL used with the wrong HTTP method: method-not-allowed error; the
  presigned upload URL expects PUT (to confirm at validation: exact method
  and header requirements on the fleet's MinIO version).
- Clock skew between client and server: signatures fail even inside the
  window. Sync clocks before debugging signatures.

## Versions note / to confirm at validation

- The exact `mc share` flag spellings (`--expire`, method handling) on the
  validation host's `mc` version.
- Whether presigned URLs work unchanged when the server sits behind a
  reverse proxy (host rewriting is a known presigned-URL trap; the fleet
  runs MinIO directly on :9000/:9001, so this is a deployment note, not a
  demo step).
