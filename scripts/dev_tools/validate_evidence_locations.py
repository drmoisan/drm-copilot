"""Scan a repository tree for files written to non-canonical evidence locations.

Purpose:
    Enforce the canonical evidence-path scheme defined in
    ``.claude/skills/evidence-and-timestamp-conventions/SKILL.md``. Evidence
    MUST reside under ``<FEATURE>/evidence/<kind>/``; any file found under a
    forbidden ``artifacts/`` sub-path is reported as a violation.

CLI usage::

    poetry run python scripts/dev_tools/validate_evidence_locations.py [--root PATH]

Exits 0 when no violations are found, 1 when at least one violation exists.
"""

from __future__ import annotations

import argparse
import sys
from pathlib import Path
from typing import TYPE_CHECKING

if TYPE_CHECKING:
    from collections.abc import Iterator

# Map from forbidden relative-path prefix to the canonical replacement hint.
# Keys must NOT start with a leading slash; they are matched against the
# POSIX-normalized path relative to the repository root.
_FORBIDDEN_PREFIX_TO_CANONICAL: dict[str, str] = {
    "artifacts/baselines/": "<FEATURE>/evidence/baseline/",
    "artifacts/baseline/": "<FEATURE>/evidence/baseline/",
    "artifacts/qa/": "<FEATURE>/evidence/qa-gates/",
    "artifacts/qa-gates/": "<FEATURE>/evidence/qa-gates/",
    "artifacts/coverage/": "<FEATURE>/evidence/qa-gates/",
    "artifacts/evidence/": "<FEATURE>/evidence/<kind>/",
    "artifacts/regression-testing/": "<FEATURE>/evidence/qa-gates/",
    "artifacts/post-change/": "<FEATURE>/evidence/qa-gates/",
    "artifacts/research/": "docs/features/active/<feature>/research/ or docs/research/",
}


def find_forbidden_paths(root: Path) -> Iterator[tuple[Path, str]]:
    """Walk ``root`` and yield every file that lives under a forbidden evidence prefix.

    Args:
        root: Repository root (or any directory) to scan recursively.

    Yields:
        Tuples of (absolute_path, canonical_suggestion) for each violation found.
        ``canonical_suggestion`` is a human-readable hint of the form
        ``<FEATURE>/evidence/<kind>/``.
    """
    # Iterate over all files reachable from root and check each against the
    # forbidden-prefix table.  Converting to POSIX form ensures consistent
    # forward-slash separators on Windows.
    for candidate in root.rglob("*"):
        if not candidate.is_file():
            continue

        # Compute the POSIX-normalized path relative to root for prefix matching.
        try:
            relative_posix = candidate.relative_to(root).as_posix()
        except ValueError:
            # relative_to raises ValueError if candidate is not under root;
            # this should not occur during rglob but guard defensively.
            continue

        # Check whether the relative path starts with any forbidden prefix.
        for (
            forbidden_prefix,
            canonical_suggestion,
        ) in _FORBIDDEN_PREFIX_TO_CANONICAL.items():
            if relative_posix.startswith(forbidden_prefix):
                yield candidate, canonical_suggestion
                break


def main() -> None:
    """Entry point: parse arguments, scan the tree, and report violations.

    Exits with code 1 if any forbidden evidence paths are found, 0 if clean.
    """
    parser = argparse.ArgumentParser(
        description=(
            "Scan a repository for files written to non-canonical evidence locations. "
            "Exits 0 if clean, 1 if violations are found."
        )
    )
    parser.add_argument(
        "--root",
        type=Path,
        default=Path(__file__).resolve().parents[2],
        help="Repository root to scan (default: two directories above this script).",
    )
    args = parser.parse_args()
    root: Path = args.root

    violations: list[tuple[Path, str]] = list(find_forbidden_paths(root))

    # Report each violation on its own line so callers can parse or display them.
    for forbidden_path, canonical_suggestion in violations:
        print(f"VIOLATION: {forbidden_path} — use {canonical_suggestion} instead")

    if violations:
        sys.exit(1)


if __name__ == "__main__":
    main()
