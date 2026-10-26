# 01 — Source Build: MinIO When Downloads 410

**Design-only — gate 1 target. Not runtime-validated.** This pattern builds
MinIO from source at the fleet's tag, the route the fleet took after release-download paths returned 410. The runner
clones the exact tag, builds the server binary, and starts it against a scratch
data directory. The checkout, binary, data, and logs are all temporary and are
removed on exit.

## Prerequisites

- Go toolchain (version to confirm at validation — see below)
- Git
- Bash (or PowerShell with the equivalent commands; the script below is Bash)

## Files

- `build.sh` — clone, build, and smoke-start the server

## Steps

```bash
bash build.sh
```

## Expected output

- `minio` binary built from tag `RELEASE.2025-10-15T17-29-55Z`.
- `minio --version` reports that tag (or a version string derived from it).
- A scratch server started with `minio server` answers on its API port
  (:9000) and console port (:9001) — fleet ports — and then stops cleanly.
- The source checkout, built binary, scratch data, and logs are all confined to the temporary directory and removed on exit; no build artifacts are left in the repository checkout.

## Failure behavior

- A Go version too old for the tag's `go.mod` fails at build with a
  go-version error; the fix is the toolchain, not a source edit.
- A network interruption during clone/build fails the run; the cleanup trap removes the temporary checkout and binary, so retry from a clean start.
- Port conflict on :9000/:9001: the smoke start fails to bind. Stop the
  existing server first — never run the smoke test against a production data
  dir.

## Versions note / to confirm at validation

- The Go version the fleet used for the source build (the seed records the
  tag and the 410 story, not the Go version).
- Whether the built binary's `--version` output names the tag verbatim.
- The fleet's binary size reference: Node-3/Node-4 builds are byte-identical
  at 151,329,792 bytes — a useful sanity check for a fresh build, not an
  assertion (build environments differ).
