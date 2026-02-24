from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path
from typing import TYPE_CHECKING

if TYPE_CHECKING:
    from collections.abc import Iterable, Sequence

from scripts.dev_tools.json_config import iter_governed_files


class FormatResult:
    """Aggregate result from a format_files run.

    Attributes:
        changed (bool): True when at least one file was (or would be) rewritten.
        failed (bool): True when at least one file could not be parsed.
        messages (list[str]): Per-file status strings collected during the run.
    """

    def __init__(self, changed: bool, failed: bool, messages: Iterable[str]):
        self.changed = changed
        self.failed = failed
        self.messages = list(messages)


def format_file(path: Path, check: bool) -> tuple[bool, bool, str]:
    """Format a single JSON file with sorted keys.

    Purpose:
        Parse the file as JSON, re-serialize with sort_keys=True and 2-space
        indentation (equivalent to ``jq --sort-keys .``), then write back
        unless check mode is active.

    Args:
        path (Path): The JSON file to format.
        check (bool): When True, report changes without writing.

    Returns:
        tuple[bool, bool, str]: (changed, failed, message).
            - changed: True when the on-disk content differs from the formatted form.
            - failed: True when the file cannot be parsed as valid JSON.
            - message: Human-readable status string.
    """
    original = path.read_text()
    try:
        parsed = json.loads(original)
    except json.JSONDecodeError as exc:
        return False, True, f"Failed to parse {path}: {exc}"

    # Append a trailing newline to match the default jq output convention.
    formatted = json.dumps(parsed, sort_keys=True, indent=2) + "\n"
    if original == formatted:
        return False, False, f"{path}: already formatted"
    if check:
        return True, False, f"{path}: would reformat"
    path.write_text(formatted)
    return True, False, f"{path}: reformatted"


def format_files(targets: Iterable[Path], check: bool, verbose: bool) -> FormatResult:
    """Format or check a collection of JSON files.

    Purpose:
        Iterate over the provided paths, skipping non-files, and apply
        format_file to each one.  Aggregate changed/failed status and collect
        per-file messages for the caller to print.

    Args:
        targets (Iterable[Path]): File paths to process.
        check (bool): When True, report but do not write changes.
        verbose (bool): When True, include messages for already-formatted files.

    Returns:
        FormatResult: Aggregate result with changed, failed flags and messages.
    """
    changed = False
    failed = False
    messages: list[str] = []

    for file_path in targets:
        if not file_path.is_file():
            continue
        c, f, msg = format_file(file_path, check)
        changed = changed or c
        failed = failed or f
        if verbose or f or c or check:
            messages.append(msg)
    return FormatResult(changed, failed, messages)


def parse_args(argv: Sequence[str] | None = None) -> argparse.Namespace:
    """Parse command-line arguments for the format_json CLI.

    Args:
        argv (Sequence[str] | None): Argument list; defaults to sys.argv[1:].

    Returns:
        argparse.Namespace: Parsed arguments with ``paths``, ``check``, and ``verbose``.
    """
    parser = argparse.ArgumentParser(
        description="Format governed JSON files with sorted keys"
    )
    parser.add_argument(
        "paths",
        nargs="*",
        help="Optional specific files/dirs; defaults to governed globs",
    )
    parser.add_argument(
        "--check",
        action="store_true",
        help="Only check; exit non-zero if changes needed",
    )
    parser.add_argument("--verbose", action="store_true", help="Print per-file status")
    return parser.parse_args(list(argv) if argv is not None else None)


def main(argv: Sequence[str] | None = None) -> int:
    """Entry point for the format_json CLI.

    Args:
        argv (Sequence[str] | None): Argument list; defaults to sys.argv[1:].

    Returns:
        int: 0 on success, 1 on failure or when check mode detects needed changes.
    """
    args = parse_args(argv or sys.argv[1:])
    root = Path(__file__).resolve().parents[2]

    # If explicit paths provided, override governed files
    if args.paths:

        def iter_paths() -> Iterable[Path]:
            for p in args.paths:
                path = Path(p)
                if path.is_dir():
                    yield from path.rglob("*.json")
                else:
                    yield path

        target_files = list(iter_paths())
    else:
        target_files = list(iter_governed_files(root))

    result = format_files(target_files, check=args.check, verbose=args.verbose)
    for msg in result.messages:
        print(msg)
    if result.failed:
        return 1
    if args.check and result.changed:
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
