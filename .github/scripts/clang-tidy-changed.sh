#!/usr/bin/env bash
# SPDX-License-Identifier: Apache-2.0

set -euo pipefail

base_ref="${GITHUB_BASE_REF:-main}"
build_dir="${BUILD_DIR:-build}"
checks="${CLANG_TIDY_CHECKS:--*,bugprone-use-after-move}"

if ! git rev-parse --verify --quiet "origin/$base_ref" >/dev/null; then
    git fetch --no-tags --depth=1 origin "$base_ref"
fi

mapfile -t sources < <(
    git diff --name-only --diff-filter=ACMR "origin/$base_ref"...HEAD -- \
        '*.c' '*.cc' '*.cpp' \
        | sort
)

if [[ "${#sources[@]}" -eq 0 ]]; then
    echo "No changed C/C++ translation units; skipping clang-tidy."
    exit 0
fi

printf 'Running clang-tidy for %d changed translation unit(s):\n' "${#sources[@]}"
printf '  %s\n' "${sources[@]}"

for source in "${sources[@]}"; do
    if [[ -f "$source" ]]; then
        .github/scripts/clang-tidy-nix.sh --checks="$checks" -p "$build_dir" "$source"
    fi
done
