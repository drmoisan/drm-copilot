"""Compatibility wrapper for extension-side PR context collection.

Purpose:
    Preserve the historical bundled-script entry point while delegating all
    collection/rendering behavior to the canonical package implementation.

Usage:
    python collect_pr_context.py --base <ref> --out <path> --appendix-out <path>

Flow:
    1. Parse stable CLI args consumed by the extension command.
    2. Execute `scripts.dev_tools.pr_context.collector` with forwarded args.

Invariants / Constraints:
    - No PR context rendering logic is implemented in this wrapper.
    - Output parity with repo-native collection is guaranteed by delegation.

Side Effects:
    Runs the canonical collector module in a subprocess and propagates exit code.
"""

from __future__ import annotations

import argparse
import shutil
import subprocess
import sys
from pathlib import Path


def main(argv: list[str] | None = None) -> int:
    """Forward CLI invocation to canonical PR-context collector module.

    Purpose:
        Keep the bundled extension script as a thin adapter and avoid duplicated
        PR-context business logic.

    Args:
        argv: Optional argument list for testability.

    Returns:
        Process exit code from delegated collector run.

    Side Effects:
        Executes a Python subprocess and streams stdout/stderr to caller.
    """
    parser = argparse.ArgumentParser(description="Collect PR context artifacts")
    parser.add_argument("--base", required=True, help="Base branch")
    parser.add_argument(
        "--out",
        type=Path,
        default=Path("artifacts/pr_context.summary.txt"),
        help="Summary output artifact path",
    )
    parser.add_argument(
        "--appendix-out",
        type=Path,
        default=Path("artifacts/pr_context.appendix.txt"),
        help="Appendix output artifact path",
    )
    args = parser.parse_args(argv)

    python_exe = shutil.which("python")
    if not python_exe:
        print("Error: python executable not found on PATH", file=sys.stderr)
        return 1

    command = [
        python_exe,
        "-m",
        "scripts.dev_tools.pr_context.collector",
        "--base",
        args.base,
        "--out",
        str(args.out),
        "--appendix-out",
        str(args.appendix_out),
    ]

    result = (
        subprocess.run(  # noqa: S603 - static analysis can't verify runtime validation
            command,
            check=False,
        )
    )
    return result.returncode


if __name__ == "__main__":
    raise SystemExit(main())
