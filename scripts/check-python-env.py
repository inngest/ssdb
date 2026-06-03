#!/usr/bin/env python3
# SPDX-License-Identifier: Apache-2.0

import importlib
import py_compile
import sys
from pathlib import Path


IMPORTS = [
    "aiohttp",
    "boto3",
    "cassandra",
    "click",
    "colorama",
    "distro",
    "humanfriendly",
    "jinja2",
    "psutil",
    "elftools",
    "pyparsing",
    "pytest",
    "redis",
    "requests",
    "scylla_api_client",
    "setuptools",
    "six",
    "tabulate",
    "traceback_with_variables",
    "treelib",
    "unidiff",
    "urwid",
    "yaml",
]

LINUX_IMPORTS = [
    "magic",
    "pyudev",
]

ENTRY_POINTS = [
    "configure.py",
    "idl-compiler.py",
    "test.py",
    "docs/relicensing/generate-inventory.py",
    "docs/relicensing/relicensing-status.py",
    "scripts/create-relocatable-package.py",
    "scripts/get_description.py",
]


def main() -> int:
    missing = []
    for module in IMPORTS + (LINUX_IMPORTS if sys.platform.startswith("linux") else []):
        try:
            importlib.import_module(module)
        except Exception as exc:
            missing.append(f"{module}: {exc}")

    if missing:
        print("Missing or broken Python dependencies:", file=sys.stderr)
        for item in missing:
            print(f"  {item}", file=sys.stderr)
        return 1

    for filename in ENTRY_POINTS:
        py_compile.compile(str(Path(filename)), doraise=True)

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
