# Agent Guide

This file provides guidance to AI coding agents working in this repository.

## Repository Context

This repository is the KuebikoDB fork of ScyllaDB OSS. It uses a mixed
dual-license model: inherited ScyllaDB-derived code remains AGPL-governed, and
cleanly authored KuebikoDB rewrite components may be Apache-2.0.

Do not describe the whole repository or final binary as Apache-2.0 while
inherited AGPL code remains part of the distributed work. New clean rewrite
modules may be Apache-2.0 at the file/crate level when they follow the
provenance rules in `docs/relicensing/clean-room-guidelines.md`.

## Commit Titles

Use short, imperative commit titles. Prefer conventional commit types when they
fit, especially for new KuebikoDB work:

- `feat`
- `fix`
- `docs`
- `refactor`
- `test`
- `chore`
- `ci`
- `build`
- `revert`

Examples:

- `docs: add module migration tracker`
- `build: add Rust dev shell`
- `chore: refresh relicensing inventory`

## Development Commands

### Nix Shells

- `make nix-rust` enters the Rust/cxxbridge shell.
- `make nix-cpp` enters the Linux C++ build shell.
- `make nix-macos` enters the macOS portable shell.
- `make nix-show` shows flake outputs.

The inherited C++ database build is Linux-oriented. On macOS, use the portable
or Rust shell for rewrite and tooling work unless explicitly testing a Linux
build environment.

### Rust

- `make rust-check` runs `cargo check` for the current Rust workspace.
- `make rust-test` runs Rust tests for the current Rust workspace.
- `make rust-fmt` formats Rust code.
- `make rust-fmt-check` checks Rust formatting.

The current Rust workspace is under `rust/`. Future Apache-2.0 rewrite work is
expected under `rust-next/` or another clearly separated path.

### C++

- `make cpp-configure` runs the inherited C++ configure step inside the Linux
  C++ Nix shell.

For broader C++ build and test commands, follow the existing ScyllaDB build
documentation in `docs/dev/building.md` and prefer the repository's current
Ninja/configure flow.

### Relicensing

- `make relicensing-status` shows phase progress, inventory counts, and module
  migration status.
- `make inventory` regenerates `docs/relicensing/inventory.md` and
  `docs/relicensing/inventory.tsv`.
- `make inventory-check` verifies the generated inventory is up to date.
- `make phase1-check` verifies Phase 1 provenance artifacts.

Run `make inventory` whenever tracked files are added, removed, or relicensed.

## Project Architecture

This codebase is still primarily ScyllaDB-derived C++ with an existing Rust
workspace used through Cargo and cxxbridge.

Important areas:

- `configure.py` and top-level `CMakeLists.txt` define the inherited C++ build.
- `rust/` contains the current Rust static library and cxxbridge bindings.
- `docs/plans/000-rust_rewrite_apache2_relicensing.org` is the active
  relicensing plan.
- `docs/relicensing/` contains provenance, inventory, clean-room, and module
  migration documentation.
- `docs/relicensing/module-migration.md` tracks rewrite status by subsystem.

The first clean Rust milestone is CQL native protocol framing, intended for a
future `rust-next/crates/cql-protocol` or equivalent path.

## Working Style

- Prefer minimal, targeted changes that preserve existing code style.
- Run relevant checks for the area you touch when practical.
- Commit in small logical chunks. Each commit should be self-reviewable and
  contain one coherent change plus its relevant tests/docs.
- Do not mix generated inventory refreshes with unrelated behavior changes
  unless the inventory refresh is caused by that same change.
- If working with a plan, update the plan checklist incrementally as part of
  implementation, not only at the end.
- Add comments for non-obvious logic, production constraints, safety guardrails,
  or provenance-sensitive decisions. Keep comments succinct.

## Working From Plans

When implementing a plan in `docs/plans/`:

- Treat the plan checklist as the source of truth for progress.
- Before code changes, identify the phase/checklist items being worked.
- Update checklist items incrementally in the plan file as work completes.
- Do not mark an item complete unless the named code/test/docs work is actually
  done.
- If implementation differs from the checklist wording, update the wording
  instead of marking an inaccurate item complete.
- In the final response, summarize which checklist items changed and which
  remain open.

## Clean Rewrite Rules

For Apache-2.0 clean rewrite modules:

- Use public protocols, public docs, independently written specs, black-box
  tests, benchmarks, and observed behavior.
- Do not copy inherited AGPL implementation code, comments, file structure,
  helper names, or distinctive implementation expression.
- Record provenance in `docs/relicensing/module-migration.md`.
- Require contributor authority attestation for Apache-2.0 contributions.
- If work may be employer-owned, require employer authorization, a corporate
  CLA, or equivalent written approval before treating it as clean Apache-2.0
  code.

High-risk modules such as storage, compaction, query execution, topology, and
CQL semantics beyond frame encoding should use a split spec/implementation
workflow as described in `docs/relicensing/clean-room-guidelines.md`.
