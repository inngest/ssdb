# Contributing to Scylla

## KuebikoDB clean rewrite contributions

KuebikoDB is migrating inherited AGPL-covered ScyllaDB code toward cleanly
authored Apache-2.0 Rust components. This migration does not relicense inherited
code. New clean rewrite contributions must preserve clear provenance.

For any contribution intended to be Apache-2.0 clean rewrite code, contributors
must attest that they have authority to license the contribution under
Apache-2.0. If the contribution may be owned by an employer, the contributor
must have employer authorization, a corporate CLA, or equivalent written
approval before the project treats that contribution as Apache-2.0 clean code.

Clean rewrite code must be based on public protocols, public documentation,
behavioral specifications, black-box tests, benchmarks, and observed behavior.
Do not copy inherited AGPL implementation code, comments, file structure, or
distinctive implementation expression into new Apache-2.0 modules.

See `docs/relicensing/clean-room-guidelines.md` for the detailed rewrite rules.

## Asking questions or requesting help

Use the [ScyllaDB Community Forum](https://forum.scylladb.com) or the [Slack workspace](http://slack.scylladb.com) for general questions and help.

Join the [Scylla Developers mailing list](https://groups.google.com/g/scylladb-dev) for deeper technical discussions and to discuss your ideas for contributions.

## Reporting an issue

Please use the [issue tracker](https://github.com/scylladb/scylla/issues/) to report issues or to suggest features. Fill in as much information as you can in the issue template, especially for performance problems.

## Contributing code to Scylla

Before you can contribute code to Scylla for the first time, you should sign the [Contributor License Agreement](https://www.scylladb.com/open-source/contributor-agreement/) and send the signed form cla@scylladb.com. You can then submit your changes as patches to the to the [scylladb-dev mailing list](https://groups.google.com/forum/#!forum/scylladb-dev) or as a pull request to the [Scylla project on github](https://github.com/scylladb/scylla).
If you need help formatting or sending patches, [check out these instructions](https://github.com/scylladb/scylla/wiki/Formatting-and-sending-patches).

The Scylla C++ source code uses the [Seastar coding style](https://github.com/scylladb/seastar/blob/master/coding-style.md) so please adhere to that in your patches. Note that Scylla code is written with `using namespace seastar`, so should not explicitly add the `seastar::` prefix to Seastar symbols. You will usually not need to add `using namespace seastar` to new source files, because most Scylla header files have `#include "seastarx.hh"`, which does this.

Header files in Scylla must be self-contained, i.e., each can be included without having to include specific other headers first. To verify that your change did not break this property, run `ninja dev-headers`. If you added or removed header files, you must `touch configure.py` first - this will cause `configure.py` to be automatically re-run to generate a fresh list of header files.

For more criteria on what reviewers consider good code, see the [review checklist](https://github.com/scylladb/scylla/blob/master/docs/dev/review-checklist.md).
