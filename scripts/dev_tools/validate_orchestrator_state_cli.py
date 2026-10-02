"""Command-line entry point for the orchestrator-state checkpoint validator.

Purpose:
    Provide the argument parsing, file reading, and exit-code handling behind
    `python -m scripts.dev_tools.validate_orchestrator_state`. The validator
    function is injected by the caller, so this module never imports
    `scripts.dev_tools.validate_orchestrator_state` and introduces no import
    cycle with the module that hosts the `__main__` guard.

Usage:
    python -m scripts.dev_tools.validate_orchestrator_state <path> [flags]

    Flags: --require-complete, --require-model-routing,
    --require-pr-creation-ready, --require-codex-model-routing,
    --require-codex-topology.

Invariants / Constraints:
    - Exit code 0: the checkpoint passed; the success line goes to stdout.
    - Exit code 1: the validator reported errors; one error per stderr line.
    - Exit code 2: the path could not be read (missing, unreadable, or not
      UTF-8) or argparse rejected the arguments.
    - `strict_route_membership` is never forwarded to the validator.

Side Effects:
    Reads one file from disk through `read_checkpoint_text` and writes the
    result to stdout or stderr.
"""

from __future__ import annotations

import argparse
import sys
from pathlib import Path
from typing import TYPE_CHECKING, cast

if TYPE_CHECKING:
    from collections.abc import Callable, Sequence

READ_FAILURE_PREFIX = "orchestrator-state checkpoint could not be read: "
SUCCESS_PREFIX = "orchestrator-state validation passed: "


def build_parser() -> argparse.ArgumentParser:
    """Build the argument parser for the bare-module validator CLI.

    Purpose:
        Declare the positional checkpoint path and the five optional
        `--require-*` flags accepted by the dispatcher `orchestrator-state`
        route, so both entry points share one flag vocabulary.

    Args:
        None.

    Returns:
        argparse.ArgumentParser: Parser with one positional `path` and five
        `store_true` flags.

    Raises:
        None.

    Side Effects:
        None.
    """

    parser = argparse.ArgumentParser(
        prog="python -m scripts.dev_tools.validate_orchestrator_state",
        description="Validate an orchestrator-state checkpoint file.",
    )
    parser.add_argument("path", help="Path to the orchestrator-state checkpoint.")
    parser.add_argument(
        "--require-complete",
        action="store_true",
        help="Require all tracked statuses to be complete-state safe.",
    )
    parser.add_argument(
        "--require-model-routing",
        action="store_true",
        help="Require model-routing fields on delegation receipts.",
    )
    parser.add_argument(
        "--require-pr-creation-ready",
        action="store_true",
        help="Validate the checkpoint is ready for the first `gh pr create`.",
    )
    parser.add_argument(
        "--require-codex-model-routing",
        action="store_true",
        help="Require Codex model-routing fields on delegation receipts.",
    )
    parser.add_argument(
        "--require-codex-topology",
        action="store_true",
        help="Require Codex topology fields on the checkpoint.",
    )
    return parser


def read_checkpoint_text(path: Path) -> str:
    """Return the UTF-8 text of the checkpoint file.

    Purpose:
        Serve as the only I/O seam of this module so tests can replace it.

    Args:
        path (Path): Checkpoint file location.

    Returns:
        str: Decoded file content.

    Raises:
        OSError: When the file is missing or unreadable.
        UnicodeDecodeError: When the file is not valid UTF-8.

    Side Effects:
        Reads the file from disk.
    """

    return path.read_text(encoding="utf-8")


def main(
    argv: Sequence[str] | None = None,
    *,
    validate: Callable[..., list[str]],
) -> int:
    """Run the validator CLI and return its process exit code.

    Purpose:
        Parse arguments, read the checkpoint, call the injected validator with
        the five requirement flags, and report the result.

    Args:
        argv (Sequence[str] | None): Command-line arguments; `sys.argv[1:]`
            when omitted.
        validate (Callable[..., list[str]]): Validator that takes the checkpoint
            text plus the five flags as keyword arguments and returns errors.

    Returns:
        int: `0` when validation passes, `1` when the validator reports errors,
        `2` when the checkpoint path cannot be read or decoded. Argparse usage
        errors raise `SystemExit(2)`.

    Raises:
        SystemExit: When argparse rejects the arguments (code 2).

    Side Effects:
        Reads the checkpoint file and writes to stdout or stderr.
    """

    args = build_parser().parse_args(argv)
    path_argument = cast("str", args.path)
    try:
        text = read_checkpoint_text(Path(path_argument))
    except (OSError, UnicodeDecodeError) as error:
        print(
            f"{READ_FAILURE_PREFIX}{path_argument}: {type(error).__name__}: {error}",
            file=sys.stderr,
        )
        return 2
    errors = validate(
        text,
        require_complete=cast("bool", args.require_complete),
        require_model_routing=cast("bool", args.require_model_routing),
        require_pr_creation_ready=cast("bool", args.require_pr_creation_ready),
        require_codex_model_routing=cast("bool", args.require_codex_model_routing),
        require_codex_topology=cast("bool", args.require_codex_topology),
    )
    if errors:
        for error_line in errors:
            print(error_line, file=sys.stderr)
        return 1
    print(f"{SUCCESS_PREFIX}{path_argument}")
    return 0
