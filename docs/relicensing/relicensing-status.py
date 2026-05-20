#!/usr/bin/env python3
#
# SPDX-License-Identifier: Apache-2.0

from __future__ import annotations

import re
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
PLAN = ROOT / "docs/plans/000-rust_rewrite_apache2_relicensing.org"
INVENTORY = ROOT / "docs/relicensing/inventory.md"
MODULES = ROOT / "docs/relicensing/module-migration.md"

PHASE_RE = re.compile(r"^\*\* (Phase \d+: .+)$")
CHECK_RE = re.compile(r"^- \[( |X)\] ")


def phase_progress() -> list[tuple[str, int, int]]:
    phases: list[tuple[str, int, int]] = []
    current: str | None = None
    done = 0
    total = 0

    for line in PLAN.read_text().splitlines():
        phase_match = PHASE_RE.match(line)
        if phase_match:
            if current is not None:
                phases.append((current, done, total))
            current = phase_match.group(1)
            done = 0
            total = 0
            continue

        if current is None:
            continue

        if line.startswith("*"):
            phases.append((current, done, total))
            current = None
            continue

        check_match = CHECK_RE.match(line)
        if check_match:
            total += 1
            if check_match.group(1) == "X":
                done += 1

    if current is not None:
        phases.append((current, done, total))

    return phases


def inventory_counts() -> list[tuple[str, str]]:
    counts: list[tuple[str, str]] = []
    in_table = False
    for line in INVENTORY.read_text().splitlines():
        if line == "## License Classes":
            in_table = True
            continue
        if in_table and line.startswith("## "):
            break
        if not in_table or not line.startswith("|"):
            continue
        if "Category" in line or set(line.replace("|", "").strip()) == {"-"}:
            continue
        cells = [cell.strip() for cell in line.strip("|").split("|")]
        if len(cells) == 2:
            counts.append((cells[0], cells[1]))
    return counts


def module_statuses() -> list[tuple[str, str]]:
    statuses: list[tuple[str, str]] = []
    for line in MODULES.read_text().splitlines():
        if not line.startswith("| ") or "---" in line or "Subsystem" in line:
            continue
        cells = [cell.strip() for cell in line.strip("|").split("|")]
        if len(cells) >= 4:
            statuses.append((cells[0], cells[3]))
    return statuses


def main() -> None:
    print("Relicensing Progress")
    print()

    for phase, done, total in phase_progress():
        pct = 100 if total == 0 else round(done * 100 / total)
        print(f"{phase}: {done}/{total} complete ({pct}%)")

    print()
    print("License Inventory")
    for category, count in inventory_counts():
        print(f"{category}: {count}")

    print()
    print("Module Migration")
    for module, status in module_statuses():
        print(f"{module}: {status}")


if __name__ == "__main__":
    main()
