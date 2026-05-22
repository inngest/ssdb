# ssdb

ssdb is a fork of ScyllaDB OSS. This repository currently contains
inherited ScyllaDB-derived C++ code and documentation while the project builds a
path toward cleanly authored Apache-2.0 Rust components.

The inherited database remains API-compatible with Apache Cassandra and includes
the existing DynamoDB-compatible Alternator code path. During the transition,
internal build targets, binary names, service paths, docs, and package metadata
may still use Scylla or ScyllaDB names.

## Relicensing Status

ssdb uses a mixed dual-license model. Inherited ScyllaDB-derived code
remains AGPL-3.0-or-later. Cleanly authored ssdb rewrite code may be
Apache-2.0 when it follows the provenance rules in
[docs/relicensing/clean-room-guidelines.md](docs/relicensing/clean-room-guidelines.md).
The combined distributable remains AGPL-governed while inherited AGPL code is
part of the shipped work.

## Build Prerequisites

The inherited C++ database build is fairly fussy about its build environment,
requiring very recent versions of the C++23 compiler and of many libraries to
build. The document
[HACKING.md](HACKING.md) includes detailed information on building and
developing the inherited code. The
[frozen toolchain](tools/toolchain/README.md) provides a pre-configured Docker
image with recent compilers, libraries, and build tools.

## Building

The current inherited binary target is still named `scylla`:

```bash
$ git submodule update --init --force --recursive
$ ./tools/toolchain/dbuild ./configure.py
$ ./tools/toolchain/dbuild ninja build/release/scylla
```

For further information, please see:

* [Developer documentation] for more information on building the inherited code.
* [Build documentation] on how to build binaries, tests, and packages.
* [Docker image build documentation] for information on how to build Docker images.

[developer documentation]: HACKING.md
[build documentation]: docs/dev/building.md
[docker image build documentation]: dist/docker/debian/README.md

## Running

To start the inherited database server, run:

```bash
$ ./tools/toolchain/dbuild ./build/release/scylla --workdir tmp --smp 1 --developer-mode 1
```

This starts one node with one CPU core and stores data files in `tmp`. The
`--developer-mode` flag disables startup checks that are not relevant on
development workstations. Use `dbuild` to run binaries built with the frozen
toolchain.

For more run options, run:

```bash
$ ./tools/toolchain/dbuild ./build/release/scylla --help
```

## Testing

See [test.py manual](docs/dev/testing.md).

## APIs And Compatibility

The inherited database is compatible with Apache Cassandra and its CQL API.
There is also inherited support for a DynamoDB-compatible API, which must be
enabled and configured before use. See [Alternator](docs/alternator/alternator.md)
and [Getting started with Alternator](docs/alternator/getting-started.md).

## Documentation

Inherited developer documentation can be found [here](docs/dev/README.md).
Seastar documentation can be found [here](http://docs.seastar.io/master/index.html).
The restored documentation tree is retained as reference material until each
page is audited, rewritten, or removed.

## License

See [LICENSE](LICENSE), [LICENSE.AGPL](LICENSE.AGPL), and
[LICENSE.APACHE](LICENSE.APACHE).

## Contributing

Before contributing, read the [contribution guidelines]. For inherited C++
development details, read the [developer guidelines].

[contribution guidelines]: CONTRIBUTING.md
[developer guidelines]: HACKING.md
