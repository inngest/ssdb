{
  description = "KuebikoDB";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
            permittedInsecurePackages = [
              "python-2.7.18.12"
            ];
          };
          overlays = [
            (final: prev: {
              # default.nix predates current nixpkgs and still references
              # package names that have been removed from unstable.
              llvmPackages_15 = prev.llvmPackages;
              boost175 = prev.boost181;
              libyamlcpp = prev.yaml-cpp;
            })
            (import ./dist/nix/overlay.nix nixpkgs)
          ];
        };

        lib = pkgs.lib;
        llvm = pkgs.llvmPackages;

        antlr3Cpp = pkgs.runCommand "antlr-3.5.2-kuebikodb" { } ''
          mkdir -p "$out"
          cp -a ${pkgs.antlr3}/. "$out/"
          chmod -R u+w "$out"
          sed -E \
            -e 's/const[[:space:]]+ANTLR_INT32([[:space:]]+)m_decisionNumber;/ANTLR_INT32\1m_decisionNumber;/' \
            -e 's/const[[:space:]]+ANTLR_INT32\*[[:space:]]+const([[:space:]]+)m_(eot|eof|min|max|accept|special);/const ANTLR_INT32*\1m_\2;/' \
            -e 's/const[[:space:]]+ANTLR_INT32\*[[:space:]]+const[[:space:]]+\*const([[:space:]]+)m_transition;/const ANTLR_INT32* const *\1m_transition;/' \
            "$out/include/antlr3cyclicdfa.hpp" > "$out/include/antlr3cyclicdfa.hpp.tmp"
          mv "$out/include/antlr3cyclicdfa.hpp.tmp" "$out/include/antlr3cyclicdfa.hpp"
          if grep -nE 'const[[:space:]]+ANTLR_INT32[[:space:]]+m_decisionNumber|const[[:space:]]+ANTLR_INT32\*[[:space:]]+const[[:space:]]+m_(eot|eof|min|max|accept|special)|const[[:space:]]+ANTLR_INT32\*[[:space:]]+const[[:space:]]+\*const[[:space:]]+m_transition' "$out/include/antlr3cyclicdfa.hpp"; then
            echo "failed to patch ANTLR3 cyclic DFA copy members" >&2
            exit 1
          fi
        '';

        pythonEnv = pkgs.python3.withPackages (
          ps: with ps; [
            aiohttp
            boto3
            colorama
            distro
            psutil
            pyparsing
            pytest
            pytest-asyncio
            pyyaml
            requests
            setuptools
            tabulate
            urwid
          ]
        );

        rustTools = with pkgs; [
          cargo
          clippy
          cxx-rs
          rust-analyzer
          rustc
          rustfmt
        ];

        cppTools = with pkgs; [
          ccache
          cmake
          doxygen
          gnumake
          llvm.bintools
          llvm.clang
          llvm.clang-tools
          ninja
          pkg-config
          ragel
        ];

        portableDevShell = pkgs.mkShell {
          packages =
            cppTools
            ++ rustTools
            ++ (with pkgs; [
              antlr3_4
              git
              jdk11_headless
              lz4
              protobuf
              pythonEnv
              wabt
              zstd
            ]);

          shellHook = lib.optionalString pkgs.stdenv.isDarwin ''
            echo "KuebikoDB portable macOS dev shell"
            echo "The inherited C++ database build is Linux-oriented; use a Linux Nix shell for the full C++ build."
          '';
        };

        scyllaDevShell =
          if pkgs.stdenv.isLinux then
            import ./default.nix {
              inherit pkgs;
              flake = true;
              shell = true;
              srcPath = self;
              antlr3Package = antlr3Cpp;
              fmtPackage = pkgs.fmt_10.overrideAttrs (old: {
                cmakeFlags = (old.cmakeFlags or [ ]) ++ [
                  "-DFMT_TEST=OFF"
                ];
                doCheck = false;
                doInstallCheck = false;
              });
              devInputs =
                { pkgs, llvm }:
                with pkgs;
                [
                  # for impure building
                  ccache
                  distcc

                  # for debugging
                  binutils
                  elfutils
                  llvm.llvm
                  lz4

                  # etc
                  diffutils
                  doxygen
                  rapidxml
                  colordiff
                  wabt
                ];
            }
          else
            portableDevShell;

        linuxCppShell =
          if pkgs.stdenv.isLinux then
            scyllaDevShell
          else
            pkgs.mkShell {
              packages = [ ];
              shellHook = ''
                echo "KuebikoDB full C++ build shell is Linux-only."
                echo "On macOS, use: nix develop .#portable or nix develop .#rust"
                return 1
              '';
            };

        macosShell =
          if pkgs.stdenv.isDarwin then
            portableDevShell
          else
            pkgs.mkShell {
              packages = [ ];
              shellHook = ''
                echo "KuebikoDB macOS shell is Darwin-only."
                echo "On Linux, use: nix develop .#default, nix develop .#cpp, or nix develop .#rust"
                return 1
              '';
            };

        rustDevShell = pkgs.mkShell {
          packages =
            rustTools
            ++ (with pkgs; [
              cmake
              ccache
              git
              llvm.clang
              ninja
              openssl
              pkg-config
              pythonEnv
            ]);

          shellHook = ''
            echo "KuebikoDB Rust dev shell"
            echo "Use this for rust/, rust-next/, cxxbridge, and Apache-2.0 rewrite work."
          '';
        };
      in
      {
        devShells.default = scyllaDevShell;
        devShells.cpp = linuxCppShell;
        devShells.linux-cpp = linuxCppShell;
        devShells.rust = rustDevShell;
        devShells.macos = macosShell;
        devShells.portable = portableDevShell;

        formatter = pkgs.nixfmt;
      }
    );
}
