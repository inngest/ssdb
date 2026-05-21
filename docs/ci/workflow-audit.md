# SPDX-License-Identifier: Apache-2.0

# GitHub Actions Workflow Audit

This inventory categorizes the current GitHub Actions workflows for the
KuebikoDB fork. It is intended as an audit starting point for deciding which
inherited workflows still make sense, which need rebranding or fork-specific
changes, and which should be removed.

## Categories

| Category                      | Meaning                                                                  |
|-------------------------------|--------------------------------------------------------------------------|
| Core PR CI                    | Should run on normal pull requests to protect this fork.                 |
| Reusable CI                   | Building block called by other workflows; should not run directly.       |
| Heavy or scheduled CI         | Useful, but too expensive or specialized for every pull request.         |
| Docs CI                       | Documentation build or publish automation.                               |
| Backport and label automation | Inherited release-management automation that needs audit before keeping. |
| External service automation   | GitHub-managed or dependency automation outside normal PR validation.    |

## Keep

| Workflow                          | File                                     | Category    | Current role                                                                                                                  | Audit note                                                                                     |
|-----------------------------------|------------------------------------------|-------------|-------------------------------------------------------------------------------------------------------------------------------|------------------------------------------------------------------------------------------------|
| KuebikoDB Build and Test          | `.github/workflows/pr-builds.yml`        | Core PR CI  | Runs submodule checkout, C++ configure smoke, full inherited binary build, Rust checks/tests, and Linux Nix flake validation. | Keep as the fork's primary PR signal. Expand as Rust replacement modules become testable.      |
| KuebikoDB PR                      | `.github/workflows/kuebiko-pr.yaml`      | Core PR CI  | Runs relicensing Phase 1 checks and prints relicensing status.                                                                | Keep until provenance checks are merged into broader CI.                                       |
| PR Conventional Commit Validation | `.github/workflows/commits.yml`          | Core PR CI  | Validates conventional PR titles without adding labels.                                                                       | Keep for release-note hygiene.                                                                 |
| codespell                         | `.github/workflows/codespell.yaml`       | Core PR CI  | Warns on spelling issues.                                                                                                     | Keep, but consider making it fail once inherited false positives are cleaned up.               |
| Build KuebikoDB                   | `.github/workflows/build-kuebikodb.yaml` | Reusable CI | Builds the inherited database executable for a requested mode.                                                                | Keep as reusable CI. Internal target paths still use `scylla` until the build tree is renamed. |
| Read Toolchain                    | `.github/workflows/read-toolchain.yaml`  | Reusable CI | Reads the container image from `tools/toolchain/image`.                                                                       | Keep while inherited C++ build uses the upstream toolchain container.                          |

## Modify

| Workflow                      | File                                        | Category              | Current role                                                      | Recommended change                                                                                                                                     |
|-------------------------------|---------------------------------------------|-----------------------|-------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------|
| clang-tidy                    | `.github/workflows/clang-tidy.yaml`         | Core PR CI            | Runs clang-tidy on C++ changes and relevant CI/toolchain changes. | Keep path-filtered. Continue rebranding user-visible names only; CMake variables such as `Scylla_USE_LINKER` remain inherited build internals for now. |
| iwyu                          | `.github/workflows/iwyu.yaml`               | Core PR CI            | Runs include-cleaner on C++ paths.                                | Keep path-filtered, but add `.gitmodules`, toolchain, and workflow paths if it should validate submodule/toolchain changes like clang-tidy.            |
| Docs / Build PR               | `.github/workflows/docs-pr.yaml`            | Docs CI               | Builds docs for docs/config changes.                              | Rebrand docs environment and remove enterprise-branch behavior if this fork will not publish Scylla-style multi-version docs.                          |
| Docs / Publish                | `.github/workflows/docs-pages.yaml`         | Docs CI               | Publishes docs on branch pushes.                                  | Audit before enabling for public pages. Rebrand paths, branch policy, and theme assumptions.                                                           |
| Check Reproducible Build      | `.github/workflows/reproducible-build.yaml` | Heavy or scheduled CI | Builds twice and compares checksums.                              | Keep manual/scheduled. Consider reducing frequency until full binary rename and release process are settled.                                           |
| clang-nightly                 | `.github/workflows/clang-nightly.yaml`      | Heavy or scheduled CI | Builds with a nightly Clang snapshot.                             | Keep manual/scheduled if compiler-forward compatibility matters. Rename workflow once the inherited C++ build has KuebikoDB naming.                    |
| Build with the latest Seastar | `.github/workflows/seastar.yaml`            | Heavy or scheduled CI | Builds against upstream Seastar.                                  | Keep manual/scheduled while Seastar remains a dependency. Confirm whether this should track ScyllaDB's Seastar fork or a KuebikoDB fork.               |

## Removed

| Workflow                         | Former file                                           | Category                      | Removal reason                                                               |
|----------------------------------|-------------------------------------------------------|-------------------------------|------------------------------------------------------------------------------|
| PR require backport label        | `.github/workflows/pr-require-backport-label.yaml`    | Backport and label automation | This fork does not currently use Scylla-style mandatory backport labels.     |
| Check if commits are promoted    | `.github/workflows/add-label-when-promoted.yaml`      | Backport and label automation | This fork does not currently use the inherited promotion/backport process.   |
| Sync labels                      | `.github/workflows/sync-labels.yaml`                  | Backport and label automation | The workflow was gated to `scylladb/scylladb` and inert in this repository.  |
| Fixes validation for backport PR | `.github/workflows/backport-pr-fixes-validation.yaml` | Backport and label automation | This fork does not currently define `branch-*` backport PR validation rules. |

## External Or Generated

| Workflow           | File             | Category                    | Current role                                     | Audit note                                  |
|--------------------|------------------|-----------------------------|--------------------------------------------------|---------------------------------------------|
| Dependabot Updates | GitHub-generated | External service automation | Dependency update automation surfaced by GitHub. | Keep if dependency update PRs are wanted.   |
| Dependency Graph   | GitHub-generated | External service automation | GitHub dependency graph analysis.                | Keep unless security policy says otherwise. |

## Rebranding Notes

- User-visible CI names should say KuebikoDB rather than ScyllaDB or Scylla.
- Internal inherited C++ targets still use names such as `scylla`, and some CMake
  variables still contain `Scylla`. Rename those only as part of the broader
  source/build-system rebrand so CI does not diverge from the build tree.
- External dependency coordinates such as `scylladb/scylla-toolchain` and
  `scylladb/seastar` are intentionally left as dependency references until this
  fork provides replacements.
