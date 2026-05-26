#!/usr/bin/env bash
# SPDX-License-Identifier: Apache-2.0

set -euo pipefail

if [[ "${GITHUB_EVENT_NAME:-}" == "workflow_dispatch" ]]; then
    cpp=true
    rust=true
    regression=true
else
    base_ref="${GITHUB_BASE_REF:-main}"
    if ! git rev-parse --verify --quiet "origin/$base_ref" >/dev/null; then
        git fetch --no-tags --depth=1 origin "$base_ref"
    fi

    cpp=false
    rust=false
    regression=false
    while IFS= read -r file; do
        case "$file" in
            *.c|*.cc|*.cpp|*.cxx|*.h|*.hh|*.hpp|*.hxx|*.ipp|*.tcc|CMakeLists.txt|*/CMakeLists.txt|cmake/*|configure.py|.gitmodules|flake.nix|flake.lock|Makefile|.github/workflows/pr-builds.yml|.github/workflows/build-ssdb.yaml|.github/scripts/ci-changes.sh)
                cpp=true
                ;;
        esac

        case "$file" in
            rust/*|Cargo.toml|Cargo.lock|flake.nix|flake.lock|Makefile|.github/workflows/pr-builds.yml|.github/scripts/ci-changes.sh)
                rust=true
                ;;
        esac

        case "$file" in
            *.c|*.cc|*.cpp|*.cxx|*.h|*.hh|*.hpp|*.hxx|*.ipp|*.tcc|CMakeLists.txt|*/CMakeLists.txt|cmake/*|configure.py|.gitmodules|flake.nix|flake.lock|Makefile|pyproject.toml|uv.lock|test/*|.github/workflows/pr-builds.yml|.github/workflows/build-ssdb.yaml|.github/scripts/ci-changes.sh)
                regression=true
                ;;
        esac
    done < <(git diff --name-only --diff-filter=ACMR "origin/$base_ref"...HEAD)
fi

{
    echo "cpp=$cpp"
    echo "rust=$rust"
    echo "regression=$regression"
} >> "$GITHUB_OUTPUT"
