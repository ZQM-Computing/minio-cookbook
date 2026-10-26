# 04 — Versioning and Lifecycle: Raster and Catalog Assets

**Design-only — gate 1 target. Not runtime-validated.** This pattern turns on
bucket versioning and applies a lifecycle rule: keep raster assets versioned,
expire old catalog staging objects. Versioning is the safety net; lifecycle is
the janitor.

## Prerequisites

- A running MinIO server with the pattern 02 buckets
- `mc` installed
- Bash

## Files

- `lifecycle.json` — lifecycle rule for the `catalogs` staging prefix
- `apply.sh` — enable versioning, apply lifecycle, verify

## Steps

```bash
export MINIO_ROOT_USER="your-admin-user"
export MINIO_ROOT_PASSWORD="your-admin-password"
bash apply.sh
```

## Expected output

- `mc version info` reports versioning Enabled on both buckets after the run.
- `mc ilm rule ls` (or the lifecycle list command on the validation host's
  `mc` version) shows the staging-expiry rule on `catalogs`.
- Uploading the same object twice to a versioned bucket creates two versions
  (`mc version` listing shows both); the older version remains retrievable.

## Failure behavior

- Versioning on a bucket with existing unversioned objects: existing objects
  become version "null" — they are not retroactively versioned. State this
  before enabling versioning on a populated bucket.
- Lifecycle rule syntax errors fail at apply time with a rule-parse error;
  validate the JSON first (`python3 -m json.tool`).
- Expiry is eventual, not instant: an expired object may still list briefly
  after its expiry date. The check is that it disappears, not when exactly.

## Versions note / to confirm at validation

- The exact `mc ilm` subcommand spellings on the validation host's `mc`
  version (the `mc ilm rule` family has changed across `mc` releases).
- The lifecycle rule JSON fields MinIO accepts for prefix-scoped expiry
  (the file below uses the S3 lifecycle shape; MinIO deviations are a
  validation finding).
- Whether the fleet enables versioning on its real buckets (the seed lists
  versioning/lifecycle as planned, not as fleet-verified state).
