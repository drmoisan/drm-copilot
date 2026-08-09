"""Single deterministic CLI entry point for the parallel abandon disposition.

Purpose:
    Give the ``abandon`` disposition of ``/parallel-remove`` exactly one
    invocation shape, so the abandon gate
    (``.claude/hooks/enforce-parallel-abandon-gate.ps1``) has a deterministic
    match target. Executing the abandon disposition through ad hoc ``gh`` or
    ``git`` commands is prohibited by the documented procedure precisely because
    those invocations are not matchable.

Responsibilities and boundaries:
    This module is the thinnest possible wiring. It parses arguments, refuses to
    act without the confirmation marker, and executes the two destructive side
    effects -- ``gh pr close`` and ``git worktree remove`` -- through an
    injectable runner seam. Every decision about whether a removal is legal
    already happened in ``scripts/dev_tools/parallel_mutation_protocol.py``; no
    decision logic lives here.

Token-source authority:
    This module is the single producer-side source of truth for the abandon
    token pair. ``ABANDON_DISPOSITION_TOKEN`` and ``CONFIRM_ABANDON_TOKEN`` are
    declared once here and the argparse surface is BUILT FROM THEM: the
    confirmation flag string is ``CONFIRM_ABANDON_TOKEN`` itself, and the
    ``--disposition`` option string plus its ``abandon`` choice compose
    ``ABANDON_DISPOSITION_TOKEN``. ``build_parser`` returns the live parser so a
    test can inspect that wiring without executing the CLI, which is how the
    cross-language seam test binds this module to the hook and the SKILL.

Key invariants and constraints:
    The item key is an ``int`` (F3's ``items[].issue_num``). The disposition
    choices come from F3's ``VALID_DISPOSITIONS`` rather than a local literal,
    so this CLI consumes that enum and never extends it. Without
    ``--confirm-abandon`` the CLI refuses and performs no side effect.

Raises and side effects:
    ``main`` returns a process exit code and never raises for an expected
    failure; it converts a refusal or a failed side effect into a non-zero exit
    with a specific message on stderr. The runner seam is the only place a
    subprocess is ever started, and every test injects its own runner, so no
    test invokes live ``gh`` or ``git``.
"""

from __future__ import annotations

import argparse
import shutil
import subprocess
import sys
from collections.abc import Callable
from typing import TYPE_CHECKING

from scripts.dev_tools._parallel_state_common import VALID_DISPOSITIONS

if TYPE_CHECKING:
    from collections.abc import Sequence

# The option prefix and the two option names argparse registers. Naming the
# parts separately lets the two exported tokens below be COMPOSED from them, so
# the parser and the tokens cannot disagree: there is only one spelling of each
# part in this module.
OPTION_PREFIX = "--"
DISPOSITION_OPTION = f"{OPTION_PREFIX}disposition"
CONFIRM_ABANDON_OPTION = f"{OPTION_PREFIX}confirm-abandon"

# The F3-owned ``mutations[].disposition`` member this CLI executes. The value is
# upstream-owned and is asserted to be a member of ``VALID_DISPOSITIONS`` by the
# unit tests, so this CLI consumes that enum rather than extending it.
ABANDON_DISPOSITION = "abandon"

# The two tokens the abandon gate matches on, composed from the parts above.
# This module is the single producer-side source of truth for both values.
ABANDON_DISPOSITION_TOKEN = f"{DISPOSITION_OPTION} {ABANDON_DISPOSITION}"
CONFIRM_ABANDON_TOKEN = CONFIRM_ABANDON_OPTION

# Exit codes. A refusal is distinguished from a failed side effect so a caller
# can tell "I did nothing" from "I did something and it broke".
EXIT_OK = 0
EXIT_SIDE_EFFECT_FAILED = 1
EXIT_REFUSED = 2

# Literal prefix on every message this CLI writes to stderr.
ERROR_PREFIX = "PARALLEL_ABANDON_ERROR:"

# A runner takes a command argument vector and returns its exit code.
CommandRunner = Callable[["Sequence[str]"], int]


class AbandonSideEffectError(RuntimeError):
    """Raised when one of the abandon side effects fails.

    Purpose:
        Carry which command failed and how, so ``main`` can report a specific
        error rather than a generic failure. It is caught inside this module and
        never crosses the process boundary.

    Attributes:
        argv (tuple[str, ...]): The failed command's argument vector.
        exit_code (int): The exit code the runner reported, or -1 when the
            executable could not be resolved at all.
    """

    def __init__(self, argv: Sequence[str], exit_code: int) -> None:
        """Store the failed command and build the literal message.

        Args:
            argv (Sequence[str]): The failed command's argument vector.
            exit_code (int): The reported exit code, or -1 for an unresolvable
                executable.

        Returns:
            None.

        Side Effects:
            None.
        """

        self.argv = tuple(argv)
        self.exit_code = exit_code
        super().__init__(
            f"abandon side effect failed with exit code {exit_code}: "
            f"{' '.join(self.argv)}"
        )


def run_with_subprocess(argv: Sequence[str]) -> int:
    """Execute a command vector as a subprocess and return its exit code.

    This is the production runner and the ONLY place this module starts a
    process. It is a named module-level function rather than an inline default
    so tests can substitute their own runner without patching ``subprocess``.

    Args:
        argv (Sequence[str]): The command vector, executable name first. The
            name is resolved through ``PATH`` so the caller need not know where
            ``gh`` or ``git`` is installed.

    Returns:
        int: The completed process's exit code.

    Raises:
        AbandonSideEffectError: If the executable cannot be resolved on ``PATH``,
            which is reported as exit code -1 because no process ever ran.

    Side Effects:
        Starts a subprocess that closes a pull request or removes a worktree.
    """

    executable = shutil.which(argv[0])
    if executable is None:
        raise AbandonSideEffectError(argv, -1)
    command = [executable, *argv[1:]]
    # S603 rationale: static analysis can't verify runtime validation. The
    # executable is resolved through shutil.which above before the call.
    completed = subprocess.run(  # noqa: S603
        command,
        check=False,
    )
    return completed.returncode


def close_pull_request_argv(pr_number: int) -> list[str]:
    """Build the ``gh pr close`` argument vector.

    Args:
        pr_number (int): The pull request to close.

    Returns:
        list[str]: The command vector, built here rather than inline so a test
        can assert the exact vector the runner receives.

    Raises:
        None.

    Side Effects:
        None.
    """

    return ["gh", "pr", "close", str(pr_number)]


def remove_worktree_argv(worktree_path: str) -> list[str]:
    """Build the ``git worktree remove`` argument vector.

    Args:
        worktree_path (str): The worktree to remove.

    Returns:
        list[str]: The command vector, built here rather than inline so a test
        can assert the exact vector the runner receives.

    Raises:
        None.

    Side Effects:
        None.
    """

    return ["git", "worktree", "remove", worktree_path]


def build_parser() -> argparse.ArgumentParser:
    """Build the CLI's argparse surface from the declared abandon tokens.

    The parser is constructed in this named function, separately from ``main``,
    so the seam test can inspect the live actions -- their ``option_strings`` and
    ``choices`` -- and confirm the token constants are actually wired in, rather
    than merely declared. A constant that the parser does not honor would
    otherwise ship a silently dead gate.

    Returns:
        argparse.ArgumentParser: The parser, whose ``--disposition`` option
        string and ``abandon`` choice compose ``ABANDON_DISPOSITION_TOKEN`` and
        whose confirmation flag is ``CONFIRM_ABANDON_TOKEN``.

    Raises:
        None.

    Side Effects:
        None.
    """

    parser = argparse.ArgumentParser(
        prog="parallel_mutation_abandon_cli",
        description=(
            "Execute the abandon disposition of a parallel item removal: close "
            "the pull request and remove the worktree. Requires the explicit "
            f"{CONFIRM_ABANDON_TOKEN} confirmation marker."
        ),
    )
    parser.add_argument(
        "--item",
        type=int,
        required=True,
        help="The item's items[].issue_num (a positive integer).",
    )
    parser.add_argument(
        DISPOSITION_OPTION,
        choices=VALID_DISPOSITIONS,
        required=True,
        help=(
            f"The removal disposition. This CLI executes "
            f"{ABANDON_DISPOSITION_TOKEN!r} only."
        ),
    )
    parser.add_argument(
        CONFIRM_ABANDON_TOKEN,
        action="store_true",
        help="Explicit confirmation required for the destructive abandon path.",
    )
    parser.add_argument(
        "--pr",
        type=int,
        required=True,
        help="The pull request number to close.",
    )
    parser.add_argument(
        "--worktree",
        required=True,
        help="The worktree path to remove.",
    )
    return parser


def execute_abandon(
    pr_number: int,
    worktree_path: str,
    runner: CommandRunner,
) -> None:
    """Execute both abandon side effects in order through the runner seam.

    The pull request is closed before the worktree is removed, because removing
    the worktree first would leave an open pull request whose branch checkout is
    gone. The sequence stops at the first failure so a partially applied abandon
    is reported rather than compounded.

    Args:
        pr_number (int): The pull request to close.
        worktree_path (str): The worktree to remove.
        runner (CommandRunner): The injected command runner.

    Returns:
        None.

    Raises:
        AbandonSideEffectError: If either command reports a non-zero exit code.

    Side Effects:
        Whatever the injected runner does; the production runner closes a pull
        request and removes a worktree.
    """

    # Run both side effects in dependency order, stopping at the first failure.
    for argv in (
        close_pull_request_argv(pr_number),
        remove_worktree_argv(worktree_path),
    ):
        exit_code = runner(argv)
        if exit_code != 0:
            raise AbandonSideEffectError(argv, exit_code)


def main(
    argv: Sequence[str] | None = None,
    runner: CommandRunner = run_with_subprocess,
) -> int:
    """Parse arguments, enforce the confirmation marker, and abandon the item.

    The two refusal branches come before any side effect: a missing confirmation
    marker and a disposition other than ``abandon`` both mean this CLI must do
    nothing, because it exists only to execute the confirmed abandon path.

    Args:
        argv (Sequence[str] | None): Argument vector excluding the program name.
            None reads ``sys.argv``, which only the production entry point does.
        runner (CommandRunner): The injected command runner. Defaults to the
            subprocess runner; every test passes its own.

    Returns:
        int: ``EXIT_OK`` on success, ``EXIT_REFUSED`` when the CLI refused to
        act, and ``EXIT_SIDE_EFFECT_FAILED`` when a side effect failed.

    Raises:
        None. Every expected failure becomes an exit code and a stderr message.
        ``SystemExit`` from argparse on a malformed argument vector is argparse's
        own contract and is deliberately not intercepted.

    Side Effects:
        Writes to stderr on refusal or failure, and runs the injected runner on
        the success path.
    """

    args = build_parser().parse_args(argv)

    if args.disposition != ABANDON_DISPOSITION:
        print(
            f"{ERROR_PREFIX} this CLI executes the "
            f"{ABANDON_DISPOSITION!r} disposition only; got "
            f"{args.disposition!r}.",
            file=sys.stderr,
        )
        return EXIT_REFUSED

    if not args.confirm_abandon:
        print(
            f"{ERROR_PREFIX} refusing to abandon item {args.item!r} without "
            f"the explicit {CONFIRM_ABANDON_TOKEN} confirmation marker; no "
            f"side effect was performed.",
            file=sys.stderr,
        )
        return EXIT_REFUSED

    try:
        execute_abandon(args.pr, args.worktree, runner)
    except AbandonSideEffectError as exc:
        print(f"{ERROR_PREFIX} {exc}", file=sys.stderr)
        return EXIT_SIDE_EFFECT_FAILED

    return EXIT_OK


if __name__ == "__main__":  # pragma: no cover - process entry point only
    raise SystemExit(main())
