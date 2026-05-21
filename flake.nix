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
              antlr3Package = pkgs.antlr3_4;
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
