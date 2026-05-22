# SPDX-License-Identifier: Apache-2.0

.DEFAULT_GOAL := help

NIX ?= nix
PYTHON ?= python3
MAKEFLAGS += --no-builtin-rules

INVENTORY_GENERATOR := docs/relicensing/generate-inventory.py
INVENTORY_OUTPUTS := docs/relicensing/inventory.md docs/relicensing/inventory.tsv
RUST_MANIFEST ?= rust/Cargo.toml
CPP_TEST_MODE ?= dev
CPP_TEST_SMOKE ?= boost/UUID_test
CPP_TEST_SMOKE_ARTIFACTS ?= test/boost/UUID_test
CPP_TEST_SMOKE_TARGETS ?= build/$(CPP_TEST_MODE)/test/boost/UUID_test

.PHONY: help
help: ## Show available targets.
	@awk 'BEGIN {FS = ":.*## "; printf "Usage: make <target>\n\nTargets:\n"} /^[a-zA-Z0-9_.-]+:.*## / {printf "  %-28s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.PHONY: nix-default
nix-default: ## Enter the default Nix shell.
	$(NIX) develop

.PHONY: nix-rust
nix-rust: ## Enter the Rust/cxxbridge Nix shell.
	$(NIX) develop .#rust

.PHONY: nix-cpp
nix-cpp: ## Enter the Linux C++ Nix shell.
	$(NIX) develop .#cpp

.PHONY: nix-macos
nix-macos: ## Enter the macOS portable Nix shell.
	$(NIX) develop .#macos

.PHONY: nix-show
nix-show: ## Show flake outputs.
	$(NIX) flake show

.PHONY: rust-check
rust-check: ## Run cargo check for the current Rust workspace.
	$(NIX) develop .#rust -c cargo check --locked --manifest-path $(RUST_MANIFEST)

.PHONY: rust-test
rust-test: ## Run cargo test for the current Rust workspace.
	$(NIX) develop .#rust -c cargo test --locked --manifest-path $(RUST_MANIFEST)

.PHONY: rust-fmt
rust-fmt: ## Format Rust code in the current Rust workspace.
	$(NIX) develop .#rust -c cargo fmt --manifest-path $(RUST_MANIFEST)

.PHONY: rust-fmt-check
rust-fmt-check: ## Check Rust formatting in the current Rust workspace.
	$(NIX) develop .#rust -c cargo fmt --check --manifest-path $(RUST_MANIFEST)

.PHONY: cpp-configure
cpp-configure: ## Configure the inherited C++ build inside the Linux C++ shell.
	$(NIX) develop .#cpp -c ./configure.py --mode dev --with scylla --disable-dpdk

.PHONY: cpp-test-smoke
cpp-test-smoke: ## Build and run the focused inherited C++ smoke test binary.
	$(NIX) develop .#cpp -c ./configure.py --mode $(CPP_TEST_MODE) --with scylla $(addprefix --with ,$(CPP_TEST_SMOKE_ARTIFACTS)) --disable-dpdk --no-seastar-unused-result-error
	$(NIX) develop .#cpp -c ninja build/$(CPP_TEST_MODE)/scylla $(CPP_TEST_SMOKE_TARGETS)
	$(NIX) develop .#cpp -c env LD_LIBRARY_PATH="$$PWD/build/$(CPP_TEST_MODE)/seastar$${LD_LIBRARY_PATH:+:$$LD_LIBRARY_PATH}" build/$(CPP_TEST_MODE)/test/boost/UUID_test --report_level=no --catch_system_errors=no --color_output=false -- --overprovisioned --unsafe-bypass-fsync 1 --kernel-page-cache 1 --blocked-reactor-notify-ms 2000000 --collectd 0 --max-networking-io-control-blocks=100

.PHONY: inventory
inventory: ## Regenerate relicensing inventory files.
	@$(PYTHON) $(INVENTORY_GENERATOR)
	@echo "Relicensing inventory regenerated."

.PHONY: inventory-check
inventory-check: inventory ## Verify relicensing inventory files are up to date.
	@git diff --exit-code -- $(INVENTORY_GENERATOR) $(INVENTORY_OUTPUTS)

.PHONY: phase1-check
phase1-check: inventory-check ## Run focused Phase 1 provenance checks.
	@$(PYTHON) -m py_compile $(INVENTORY_GENERATOR) docs/relicensing/relicensing-status.py
	@awk '/\*\* Phase 1: Provenance baseline/{flag=1; next} /^\*\* Phase 2:/{flag=0} flag && /^- \[ \]/{found=1} END{exit found ? 1 : 0}' docs/plans/000-rust_rewrite_apache2_relicensing.org
	@echo "Phase 1 checks passed."

.PHONY: relicensing-status
relicensing-status: ## Show relicensing checklist, inventory, and module migration status.
	@$(PYTHON) docs/relicensing/relicensing-status.py
