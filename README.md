# MinIO Cookbook

<!-- ZQM-START -->
<!-- markdownlint-disable MD033 -->
<p align="center">
  <strong>ZQM Computing — Geospatial Engineering & Scientific Computing</strong><br>
  <a href="https://github.com/ZQM-Computing">ZQM Computing</a>
</p>
<!-- markdownlint-enable MD033 -->
<!-- ZQM-END -->

![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)

A **MinIO cookbook** for S3-compatible object storage from a source build. Patterns are drawn from the ZQM fleet's MinIO installs on all three Windows nodes, built from source tag RELEASE.2025-10-15T17-29-55Z after every download path returned 410 — the source-build route is the pattern. It is intended for Platform engineers who need S3-compatible storage without a cloud account. Validate each pattern against your own data, software versions, and operating environment before adopting it.

## Repository role and status

**Status:** Active, public — first pattern pass written (design-only, gate 1 target; runtime validation pending). The table below lists what is written; no pattern has been runtime-validated yet.

**What this repository is:** MinIO patterns — see the table below.

**What it contributes:** Part of the ZQM Computing geospatial portfolio. The umbrella index for the series is [geospatial-cookbooks](https://github.com/ZQM-Computing/geospatial-cookbooks).

**Standing:** This repository is maintained independently. Automated checks cover only the paths and environments configured in its workflows; they do not establish production readiness or operational certification.

## Who this is for

Platform engineers who need S3-compatible storage without a cloud account.

## Prerequisites

- MinIO source build (tag RELEASE.2025-10-15T17-29-55Z) or a release binary
- Go toolchain for the build pass
- Bash or PowerShell

## Patterns

| # | Example | Status | What it demonstrates |
|---|---------|--------|----------------------|
| 01 | [01-source-build](examples/01-source-build/README.md) | Written (design-only) | Building MinIO from source when release downloads are unavailable |
| 02 | [02-bucket-setup](examples/02-bucket-setup/README.md) | Written (design-only) | Buckets, policies, and console access (credentials in service env only, never in repos) |
| 03 | [03-presigned](examples/03-presigned/README.md) | Written (design-only) | Presigned URLs for uploads and downloads |
| 04 | [04-versioning-lifecycle](examples/04-versioning-lifecycle/README.md) | Written (design-only) | Versioning and lifecycle rules for raster and catalog assets |

## Repository layout

```text
minio-cookbook/
├── examples/          # pattern passes, landing in follow-up work
├── README.md
└── LICENSE
```

## Roadmap

- First pattern pass: the first two table rows
- Second pass: the remaining rows, from fleet-verified setups

## Contributing

A contributing guide lands with the first pattern pass. Report security issues to <zqmcomputing@gmail.com> — please do not open a public issue for those.

## More from this series

- [cog-cookbook](https://github.com/ZQM-Computing/cog-cookbook) — Cloud Optimized GeoTIFF creation, validation, TiTiler serving
- [titiler-cookbook](https://github.com/ZQM-Computing/titiler-cookbook) — Dynamic map tiles, STAC endpoints, cloud-native raster serving
- [geoserver-cookbook](https://github.com/ZQM-Computing/geoserver-cookbook) — Publishing, styling, federation, and securing OGC services
