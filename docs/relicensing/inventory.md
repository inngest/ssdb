# License Inventory

This inventory is generated from tracked files in the repository.
It is an audit starting point, not a legal conclusion.

- Source: tracked files in the current working tree
- Generator: `docs/relicensing/generate-inventory.py`
- Complete per-file inventory: `inventory.tsv`
- Tracked files scanned: `5951`

## License Classes

| Category | Files |
|---|---:|
| AGPL-only | 1695 |
| Apache-only | 35 |
| dual-licensed | 371 |
| unknown-license | 3850 |

## File Flags

| Category | Files |
|---|---:|
| generated | 72 |
| gitlink | 6 |
| vendored | 12 |

## Classification Rules

- `AGPL-only`: SPDX expression references AGPL and not Apache-2.0.
- `Apache-only`: SPDX expression is Apache-2.0 without compound operators.
- `dual-licensed`: SPDX expression references both AGPL and Apache-2.0.
- `Apache-plus`: SPDX expression references Apache-2.0 with additional operators.
- `other-license`: SPDX expression exists but is not AGPL or Apache-2.0.
- `unknown-license`: no SPDX identifier was found in the scanned file.
- `generated`: path or file contents indicate generated output.
- `vendored`: path is under a known third-party/vendor directory.
- `gitlink`: tracked path is a submodule/gitlink entry.

## Unknown-License Examples

- `.clang-format`
- `.dockerignore`
- `.envrc`
- `.gitattributes`
- `.github/CODEOWNERS`
- `.github/ISSUE_TEMPLATE.md`
- `.github/clang-include-cleaner.json`
- `.github/clang-matcher.json`
- `.github/mergify.yml`
- `.github/pull_request_template.md`
- `.github/scripts/auto-backport.py`
- `.github/scripts/label_promoted_commits.py`
- `.github/scripts/sync_labels.py`
- `.github/workflows/add-label-when-promoted.yaml`
- `.github/workflows/backport-pr-fixes-validation.yaml`
- `.github/workflows/build-scylla.yaml`
- `.github/workflows/clang-nightly.yaml`
- `.github/workflows/clang-tidy.yaml`
- `.github/workflows/codespell.yaml`
- `.github/workflows/docs-pages.yaml`
- `.github/workflows/docs-pr.yaml`
- `.github/workflows/iwyu.yaml`
- `.github/workflows/pr-require-backport-label.yaml`
- `.github/workflows/read-toolchain.yaml`
- `.github/workflows/reproducible-build.yaml`

## Generated Examples

- `Doxyfile`
- `alternator/expressions.g`
- `alternator/expressions_types.hh`
- `api/api-doc/authorization_cache.json`
- `api/api-doc/cache_service.json`
- `api/api-doc/collectd.json`
- `api/api-doc/column_family.json`
- `api/api-doc/commitlog.json`
- `api/api-doc/compaction_manager.json`
- `api/api-doc/config.json`
- `api/api-doc/cql_server_test.json`
- `api/api-doc/endpoint_snitch_info.json`
- `api/api-doc/error_injection.json`
- `api/api-doc/failure_detector.json`
- `api/api-doc/gossiper.json`
- `api/api-doc/hinted_handoff.json`
- `api/api-doc/lsa.json`
- `api/api-doc/messaging_service.json`
- `api/api-doc/metrics.def.json`
- `api/api-doc/metrics.json`
- `api/api-doc/raft.json`
- `api/api-doc/storage_proxy.json`
- `api/api-doc/storage_service.json`
- `api/api-doc/stream_manager.json`
- `api/api-doc/swagger20_header.json`

## Vendored Examples

- `abseil`
- `licenses/LICENSE-crc32-vpmsum.TXT`
- `licenses/README.md`
- `licenses/abseil-license.txt`
- `licenses/apache-license-2.0.txt`
- `licenses/boost-license-1.0.txt`
- `licenses/date-license.txt`
- `licenses/libdeflate-license.txt`
- `licenses/xxhash-license.txt`
- `licenses/zstd-license.txt`
- `seastar`
- `swagger-ui`

## Next Audit Steps

- Review `unknown-license` files and add SPDX headers where appropriate.
- Confirm whether generated files inherit license from their generator or input.
- Confirm vendored license obligations against upstream license files.
- Keep this inventory updated when files are added, removed, or relicensed.
