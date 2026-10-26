# 02 — Bucket Setup: Buckets, Policies, Console Access

**Design-only — gate 1 target. Not runtime-validated.** This pattern sets up
buckets with the MinIO client (`mc`): alias the server, make buckets, attach
a policy, and confirm console access. Credentials live in the environment
only — this pattern never commits a credential, and neither should you.

## Prerequisites

- A running MinIO server (pattern 01), API on :9000, console on :9001
- `mc` (MinIO Client) installed
- Bash

## Files

- `setup.sh` — alias, buckets, policies, and checks

## Steps

```bash
export MINIO_ROOT_USER="your-admin-user"
export MINIO_ROOT_PASSWORD="your-admin-password"
bash setup.sh
```

## Expected output

- `mc alias set` succeeds and `mc admin info` shows the server.
- Buckets `rasters` and `catalogs` exist after the run (`mc ls` lists them).
- `rasters` carries a download (public-read) policy and `catalogs` carries a
  private policy, as `mc policy get` reports.
- The console at :9001 accepts the admin credentials.

## Failure behavior

- Wrong credentials: `mc alias set` succeeds (it does not authenticate) but
  the first real call fails with an access-denied error. Fix the environment
  values, not the script.
- Bucket already exists: `mc mb` reports it and exits non-zero under
  `set -e`; re-running setup is idempotent only if the existence check is
  added first — to confirm at validation whether `mc mb --ignore-existing`
  is the right spelling on the fleet's `mc` version.
- Policy names: `mc policy set` accepts named policies (`public`,
  `private`, `download`, `upload`); a misspelled policy fails with an
  unknown-policy error.

## Versions note / to confirm at validation

- The `mc` version on the validation host and the exact `mc policy` spellings
  (named policies vs JSON policy files).
- Whether the fleet's bucket names differ from the synthetic `rasters` /
  `catalogs` used here (these are examples, not fleet names).
