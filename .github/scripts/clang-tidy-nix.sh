#!/usr/bin/env bash
set -euo pipefail

extra_args=()
if [[ -n "${NIX_CFLAGS_COMPILE:-}" ]]; then
  # Nix cc setup hooks expose system include paths through compiler flags.
  # clang-tidy needs those flags explicitly because it does not execute the
  # Nix compiler wrapper while parsing the compile database.
  nix_cflags=( ${NIX_CFLAGS_COMPILE} )
  for flag in "${nix_cflags[@]}"; do
    extra_args+=( "--extra-arg=$flag" )
  done
fi

exec clang-tidy "${extra_args[@]}" "$@"
