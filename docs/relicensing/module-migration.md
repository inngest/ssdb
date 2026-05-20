# Module Migration Tracker

This tracker records the licensing and provenance status of each major
KuebikoDB subsystem during the Apache-2.0 Rust rewrite.

The status here is intentionally conservative. A subsystem remains
AGPL-governed while it depends on inherited ScyllaDB-derived implementation
code. A subsystem should only be marked Apache-2.0 clean after its implementation
has been independently authored, reviewed, tested, and documented.

## Status Values

- `inherited`: current implementation is inherited AGPL-governed code.
- `candidate`: suitable rewrite target, but no clean implementation exists yet.
- `in-progress`: clean rewrite implementation has started.
- `mixed`: clean rewrite code is integrated with inherited AGPL code.
- `clean`: implementation is independently authored Apache-2.0 code.
- `blocked`: migration requires an unresolved design, licensing, or provenance
  decision.

## Subsystem Table

| Subsystem          | Current source                 | Target          | Status    | First clean milestone                    | Provenance notes                                                                                                               |
|--------------------|--------------------------------|-----------------|-----------|------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------|
| CQL protocol       | inherited C++                  | Rust Apache-2.0 | candidate | Native protocol frame parse/encode       | First Rust milestone. Base behavior on public Cassandra native protocol docs and black-box fixtures.                           |
| Storage engine     | inherited C++                  | Rust Apache-2.0 | inherited | None                                     | High-risk area. Requires independent storage format and compaction design docs before implementation.                          |
| Query execution    | inherited C++                  | Rust Apache-2.0 | inherited | None                                     | High-risk area. Use independently written semantics specs and black-box CQL tests.                                             |
| Cluster membership | inherited C++                  | Rust Apache-2.0 | inherited | None                                     | High-risk area. Avoid copying topology, gossip, or raft integration structure.                                                 |
| Admin/API server   | inherited C++/scripts          | Rust Apache-2.0 | candidate | Status and health endpoints              | Good early candidate after CQL framing. Public HTTP behavior can be specified independently.                                   |
| Packaging/install  | inherited scripts              | New packaging   | candidate | Package metadata names and service paths | Rebrand service names, install paths, metrics namespaces, and artifacts while preserving required notices.                     |
| Docs               | inherited docs                 | Rewritten docs  | candidate | Provenance and compatibility docs        | Preserve required attribution. Rewrite user-facing ScyllaDB branding and copied prose before Apache-2.0 claims.                |
| Tests              | inherited tests plus new tests | Mixed/new       | candidate | Black-box CQL protocol fixtures          | Copied inherited tests remain AGPL-derived unless independently rewritten. New black-box fixtures should record public inputs. |

## Required Entry For New Clean Modules

Add or update a row before merging a clean rewrite module. The row should answer:

- Which inherited component is being replaced?
- Where does the new implementation live?
- What license applies to the new files?
- Which public references, specs, tests, or observations were used?
- Did any implementer consult inherited implementation code for this component?
- Which tests establish compatibility?
- Is the module shipped standalone, mixed with AGPL code, or not shipped yet?

## First Milestone

The first Rust milestone is `rust-next/crates/cql-protocol` or an equivalent
path for CQL native protocol framing.

Initial scope:

- frame header parsing and encoding;
- protocol version handling;
- stream IDs, flags, opcodes, and body length validation;
- request and response envelope types;
- error frame representation;
- black-box fixtures from public Cassandra native protocol behavior.

Out of scope for the first milestone:

- query planning;
- CQL semantic validation;
- storage reads or writes;
- cluster topology;
- authentication implementation beyond frame shapes.

## Review Checklist

- [ ] SPDX headers are present on new clean rewrite source files.
- [ ] The module license is recorded as Apache-2.0.
- [ ] Contributor authority has been attested.
- [ ] Public references and test sources are recorded.
- [ ] No inherited implementation code, comments, or file structure were copied.
- [ ] Integration status is marked as standalone, mixed, or not shipped.
- [ ] If mixed with inherited code, release notes and license docs state that the
  combined artifact remains AGPL-governed.
