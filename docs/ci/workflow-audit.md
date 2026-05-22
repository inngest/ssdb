# SPDX-License-Identifier: Apache-2.0

# GitHub Actions Workflow Audit

This inventory categorizes the current GitHub Actions workflows for the
SSDB fork. It is intended as an audit starting point for deciding which
inherited workflows still make sense, which need rebranding or fork-specific
changes, and which should be removed.

## Categories

| Category                      | Meaning                                                                  |
|-------------------------------|--------------------------------------------------------------------------|
| Core PR CI                    | Should run on normal pull requests to protect this fork.                 |
| Reusable CI                   | Building block called by other workflows; should not run directly.       |
| Heavy or scheduled CI         | Useful, but too expensive or specialized for every pull request.         |
| External service automation   | GitHub-managed or dependency automation outside normal PR validation.    |

## Keep

| Workflow                          | File                                     | Category    | Current role                                                                                                                  | Audit note                                                                                     |
|-----------------------------------|------------------------------------------|-------------|-------------------------------------------------------------------------------------------------------------------------------|------------------------------------------------------------------------------------------------|
| SSDB Build and Test          | `.github/workflows/pr-builds.yml`        | Core PR CI  | Installs Nix, validates the flake, runs the C++ configure smoke through the C++ shell, runs the reusable inherited binary build, and runs Rust checks/tests through Makefile/Nix targets. | Keep as the fork's primary PR signal. Expand as Rust replacement modules become testable.      |
| SSDB PR                      | `.github/workflows/ssdb-pr.yaml`      | Core PR CI  | Runs relicensing Phase 1 checks and prints relicensing status.                                                                | Keep until provenance checks are merged into broader CI.                                       |
| PR Conventional Commit Validation | `.github/workflows/commits.yml`          | Core PR CI  | Validates conventional PR titles without adding labels.                                                                       | Keep for release-note hygiene.                                                                 |
| codespell                         | `.github/workflows/codespell.yaml`       | Core PR CI  | Warns on spelling issues.                                                                                                     | Keep, but consider making it fail once inherited false positives are cleaned up.               |
| Build SSDB                   | `.github/workflows/build-ssdb.yaml` | Reusable CI | Installs Nix, enters the C++ shell, and builds the inherited database executable for a requested mode.                         | Keep as reusable CI. Internal target paths still use `scylla` until the build tree is renamed. |

## Modify

| Workflow                      | File                                        | Category              | Current role                                                      | Recommended change                                                                                                                                     |
|-------------------------------|---------------------------------------------|-----------------------|-------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------|
| clang-tidy                    | `.github/workflows/clang-tidy.yaml`         | Core PR CI            | Runs clang-tidy on C++ changes through the Nix C++ shell.          | Keep path-filtered. Continue rebranding user-visible names only; CMake variables such as `Scylla_USE_LINKER` remain inherited build internals for now. |
| iwyu                          | `.github/workflows/iwyu.yaml`               | Core PR CI            | Runs include-cleaner on C++ paths through the Nix C++ shell.       | Keep path-filtered. It now validates submodule, flake, and workflow changes like clang-tidy.                                                          |
| Check Reproducible Build      | `.github/workflows/reproducible-build.yaml` | Heavy or scheduled CI | Builds twice through the reusable Nix-backed build and compares checksums. | Keep manual/scheduled. Consider reducing frequency until full binary rename and release process are settled.                                           |
| clang-nightly                 | `.github/workflows/clang-nightly.yaml`      | Heavy or scheduled CI | Builds with a nightly Clang snapshot.                             | Keep manual/scheduled if compiler-forward compatibility matters. Rename workflow once the inherited C++ build has SSDB naming.                    |
| Build with the latest Seastar | `.github/workflows/seastar.yaml`            | Heavy or scheduled CI | Builds against upstream Seastar through the Nix C++ shell.         | Keep manual/scheduled while Seastar remains a dependency. Confirm whether this should track ScyllaDB's Seastar fork or a SSDB fork.               |

## External Or Generated

| Workflow           | File             | Category                    | Current role                                     | Audit note                                  |
|--------------------|------------------|-----------------------------|--------------------------------------------------|---------------------------------------------|
| Dependabot Updates | GitHub-generated | External service automation | Dependency update automation surfaced by GitHub. | Keep if dependency update PRs are wanted.   |
| Dependency Graph   | GitHub-generated | External service automation | GitHub dependency graph analysis.                | Keep unless security policy says otherwise. |

## Rebranding Notes

- User-visible CI names should say SSDB rather than ScyllaDB or Scylla.
- Internal inherited C++ targets still use names such as `scylla`, and some CMake
  variables still contain `Scylla`. Rename those only as part of the broader
  source/build-system rebrand so CI does not diverge from the build tree.
- External dependency coordinates such as `scylladb/seastar` are intentionally
  left as dependency references until this fork provides replacements.

## Runner Notes

- Full inherited C++ builds and C++ source-analysis builds use
  `depot-ubuntu-24.04-8` so build parallelism has enough CPU.
- Normal PR build, configure, Rust, and relicensing jobs install Nix before
  running repository tooling so CI follows the same flake-backed shells used by
  local development.
- Heavy non-reproducibility builds use `ccache` with GitHub Actions cache.
  Reproducible builds disable compiler caching to preserve a clean comparison.
- Lightweight validation, relicensing, Rust, Nix, submodule, and reusable
  metadata jobs use `depot-ubuntu-24.04`.
