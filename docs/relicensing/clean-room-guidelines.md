# Clean Rewrite Guidelines

This document defines what contributors may and may not reference when writing
Apache-2.0 clean rewrite code for KuebikoDB.

It is an engineering provenance guide, not legal advice. When in doubt, keep the
work separate, document the source of behavior, and ask for review before
committing code that is intended to be Apache-2.0 clean.

## Allowed References

Contributors may use these sources when implementing clean rewrite modules:

- Public Cassandra and CQL protocol documentation.
- Public API documentation and published compatibility notes.
- Publicly observable behavior from black-box tests.
- Independently written behavior specifications.
- Test fixtures created from public inputs or black-box observations.
- Benchmarks that describe expected behavior without copying implementation.
- Original design documents written for KuebikoDB clean rewrite modules.
- Third-party dependencies whose licenses are compatible with the intended
  module license.

## Restricted References

Contributors must not use these sources as implementation inputs for
Apache-2.0 clean rewrite code:

- Inherited AGPL implementation code from this repository.
- Comments, helper names, file layout, control flow, or distinctive expression
  copied from inherited AGPL code.
- Mechanical translations from inherited C++ into Rust.
- Private ScyllaDB materials unless the project has written permission to use
  them for Apache-2.0 work.
- Tests copied from inherited AGPL sources unless they are explicitly tracked as
  AGPL-derived and excluded from Apache-2.0 provenance claims.

## Clean Rewrite Workflow

For low-risk modules, contributors should record the public references used and
add a provenance note to `docs/relicensing/module-migration.md`.

For high-risk modules, use a split workflow:

1. A spec author writes behavior specs and black-box tests from public
   documentation and observed behavior.
2. An implementer writes the Rust module from those specs without consulting the
   inherited implementation for that component.
3. A reviewer checks that the module has SPDX headers, license documentation,
   test coverage, and a provenance note.

High-risk modules include storage, compaction, query planning, query execution,
replication, topology, membership, and CQL semantics beyond frame encoding.

## Required Provenance Note

Every clean rewrite module should record:

- module name and path;
- intended license;
- implementation authors;
- public references used;
- whether the author consulted inherited implementation code;
- test sources;
- review status.

If a module cannot meet the clean rewrite standard, keep it AGPL-governed until
it is rewritten or relicensed.
