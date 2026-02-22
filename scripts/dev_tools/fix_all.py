"""Python implementation of the fix-all workflow."""

from __future__ import annotations

import argparse
import ctypes
import subprocess
import sys
from dataclasses import dataclass
from typing import TYPE_CHECKING, Protocol, TextIO, cast

from scripts.dev_tools.fix_all_runtime import run_fix_all as run_fix_all_runtime

if TYPE_CHECKING:
    import threading
    from collections.abc import Callable, Sequence

__all__ = [
    "BranchResult",
    "CommandResult",
    "CommandRunner",
    "StepLogger",
    "SubprocessCommandRunner",
    "format_status_transition_line",
    "render_status_board",
    "format_ansi_redraw",
    "should_use_interactive_board",
    "is_vt_enabled_for_stream",
    "shell_test_was_skipped",
    "run_fix_all",
    "parse_args",
    "main",
    "_shell_test_was_skipped",
]


@dataclass
class CommandResult:
    """Result of a command invocation."""

    returncode: int
    output: str


@dataclass
class BranchResult:
    """Outcome for a single toolchain branch."""

    name: str
    success: bool
    output: str
    failed_step: str | None = None


class CommandRunner(Protocol):
    """Protocol for running commands within the fix-all pipeline."""

    def run(self, command: Sequence[str], *, step_name: str) -> CommandResult:
        """Execute the provided command and return the result."""
        ...


class Kernel32Api(Protocol):
    """Typed protocol for the subset of Kernel32 APIs used for VT enablement."""

    def GetStdHandle(self, n_std_handle: int) -> int: ...

    def GetConsoleMode(self, handle: int, mode: object) -> int: ...

    def SetConsoleMode(self, handle: int, mode: int) -> int: ...


@dataclass
class StepLogger:
    """Simple logger for emitting step, success, and failure messages."""

    stream: TextIO = sys.stdout

    def step(self, message: str) -> None:
        print(f"\n==> {message}", file=self.stream)

    def success(self, message: str) -> None:
        print(f"[OK] {message}", file=self.stream)

    def failure(self, message: str) -> None:
        print(f"[FAIL] {message}", file=self.stream)

    def info(self, message: str) -> None:
        print(message, file=self.stream)

    def command_output(self, output: str) -> None:
        if output:
            end = "" if output.endswith("\n") else "\n"
            print(output, file=self.stream, end=end)

    def separator(self) -> None:
        print("", file=self.stream)


def format_status_transition_line(branch: str, status: str) -> str:
    """
    Format a non-interactive status transition line.

    Purpose:
        Provide a deterministic, line-oriented status update for CI or redirected
        output streams.

    Args:
        branch (str): Branch name to include in the output line.
        status (str): Status string to include in the output line.

    Returns:
        str: A formatted status line using the required STATUS|... template.

    Raises:
        ValueError: Raised if branch or status is empty.

    Side Effects:
        None. Pure formatting function.
    """
    if not branch:
        raise ValueError("branch cannot be empty.")
    if not status:
        raise ValueError("status cannot be empty.")
    return f"STATUS|branch={branch}|status={status}"


def render_status_board(lines: list[str], *, width: int) -> str:
    """
    Render a fixed-height status board for interactive terminals.

    Purpose:
        Produce deterministic board text with one line per branch for in-place
        redraws in interactive terminals.

    Args:
        lines (list[str]): Preformatted status lines to render.
        width (int): Target board width for padding or truncation decisions.

    Returns:
        str: Rendered board text with one newline per line and a trailing newline.

    Raises:
        ValueError: Raised when width is not positive.

    Side Effects:
        None. Pure rendering function.
    """
    if width <= 0:
        raise ValueError("width must be positive.")

    if not lines:
        # Return empty output to avoid trailing newline for empty boards.
        return ""

    rendered_lines: list[str] = []
    # Pad or trim each line to keep the board width stable between redraws.
    for line in lines:
        if len(line) > width:
            rendered_lines.append(line[:width])
        else:
            rendered_lines.append(line.ljust(width))
    return "\n".join(rendered_lines) + "\n"


def format_ansi_redraw(board: str, *, line_count: int) -> str:
    """
    Format an ANSI redraw payload using erase-line and cursor-up sequences.

    Purpose:
        Build a deterministic ANSI redraw string that rewrites a fixed-height
        status board without emitting unsupported control sequences.

    Args:
        board (str): Rendered board content to write.
        line_count (int): Number of lines in the board to move the cursor up.

    Returns:
        str: ANSI redraw payload using only erase-line and cursor-up sequences.

    Raises:
        ValueError: Raised when line_count is negative.

    Side Effects:
        None. Pure formatting function.
    """
    if line_count < 0:
        raise ValueError("line_count cannot be negative.")

    output_parts: list[str] = []
    if line_count:
        output_parts.append("\x1b[1A" * line_count)
    # Clear each line before writing to avoid leftover characters from prior redraws.
    for line in board.splitlines():
        output_parts.append(f"\x1b[2K\r{line}\n")
    return "".join(output_parts)


def should_use_interactive_board(*, isatty: bool, vt_enabled: bool) -> bool:
    """
    Decide whether interactive status rendering should be used.

    Purpose:
        Gate terminal redraw behavior on TTY availability and VT support.

    Args:
        isatty (bool): Whether the output stream is a TTY.
        vt_enabled (bool): Whether VT/ANSI sequences are supported.

    Returns:
        bool: True when interactive rendering should be enabled.

    Raises:
        None.

    Side Effects:
        None. Pure decision function.
    """
    return isatty and vt_enabled


def _stream_isatty(stream: TextIO) -> bool:
    """
    Safely determine whether a stream is attached to a TTY.

    Purpose:
        Provide a defensive check for interactive output when streams may not
        implement the isatty method (e.g., StringIO).

    Args:
        stream (TextIO): Stream to query for TTY capability.

    Returns:
        bool: True when the stream reports itself as a TTY.

    Raises:
        None.

    Side Effects:
        None. Pure detection helper.
    """
    isatty = getattr(stream, "isatty", None)
    if isatty is None:
        return False
    return bool(isatty())


def is_vt_enabled_for_stream(stream: TextIO) -> bool:
    """
    Determine whether VT/ANSI support is enabled for the provided stream.

    Purpose:
        Enable Windows VT processing when possible and report whether ANSI
        sequences should be used for interactive rendering.

    Args:
        stream (TextIO): Stream to evaluate for VT support.

    Returns:
        bool: True when VT/ANSI sequences are supported for the stream.

    Raises:
        None.

    Side Effects:
        On Windows, attempts to enable VT processing for the console handle.
    """
    if not sys.platform.startswith("win"):
        return True

    from ctypes import wintypes

    enable_virtual_terminal_processing = 0x0004
    enable_processed_output = 0x0001
    std_output_handle = -11

    windll = getattr(ctypes, "windll", None)
    if windll is None:
        return False

    kernel32 = cast(Kernel32Api, windll.kernel32)
    handle = kernel32.GetStdHandle(std_output_handle)
    if handle in (0, -1):
        return False

    mode = wintypes.DWORD()
    # On Windows, enable VT processing when a console mode is available.
    if kernel32.GetConsoleMode(handle, ctypes.byref(mode)) == 0:
        return False

    new_mode = mode.value | enable_virtual_terminal_processing | enable_processed_output
    if kernel32.SetConsoleMode(handle, new_mode) == 0:
        return False
    return True


def _combine_output(stdout: str | None, stderr: str | None) -> str:
    parts: list[str] = []
    if stdout:
        parts.append(stdout)
    if stderr:
        parts.append(stderr)
    return "".join(parts)


def shell_test_was_skipped(output: str) -> bool:
    """
    Detect whether shell tests were skipped based on output text.

    Purpose:
        Distinguish a successful shell test run from a skipped run so the status
        board can surface "SKIP tests" instead of a normal pass.

    Args:
        output (str): Combined stdout/stderr from the shell test step.

    Returns:
        bool: True when the output indicates shell tests were skipped.

    Raises:
        None.

    Side Effects:
        None. Pure detection helper.
    """
    skip_markers = (
        "No shell test directories found; skipping.",
        "bats not installed; skipping shell tests.",
    )
    # Check for any known skip marker emitted by the shell QC tooling.
    return any(marker in output for marker in skip_markers)


def _shell_test_was_skipped(output: str) -> bool:
    """
    Backward-compatible wrapper for shell skip detection.

    Purpose:
        Preserve the private helper name while delegating to the public
        shell skip detection implementation.

    Args:
        output (str): Combined stdout/stderr from the shell test step.

    Returns:
        bool: True when the output indicates shell tests were skipped.

    Raises:
        None.

    Side Effects:
        None. Pure detection helper.
    """
    return shell_test_was_skipped(output)


subprocess_run = subprocess.run

# Brief delay to allow fail-fast cancellation signals between step boundaries.
CANCEL_CHECK_DELAY_S: float = 0.01

# Poll interval for checking subprocess completion and cancellation signals.
SUBPROCESS_POLL_INTERVAL_S: float = 0.1


@dataclass
class SubprocessCommandRunner:
    """
    Real command runner that invokes subprocesses with cancellation support.

    Purpose:
        Execute shell commands while respecting a cancellation signal for fail-fast
        behavior in parallel branch execution.

    Attributes:
        logger (StepLogger): Logger for emitting command output.
        cancel_event (threading.Event | None): Optional event that signals cancellation.
            When set, running subprocesses are terminated and new commands return
            immediately with a cancellation code.
    """

    logger: StepLogger
    cancel_event: threading.Event | None = None

    def run(self, command: Sequence[str], *, step_name: str) -> CommandResult:
        """
        Execute a command with support for cancellation.

        Purpose:
            Run a subprocess while periodically checking for cancellation signals,
            enabling fail-fast termination when another branch fails.

        Args:
            command (Sequence[str]): Command and arguments to execute.
            step_name (str): Descriptive name for logging (currently unused but
                reserved for future diagnostics).

        Returns:
            CommandResult: Result containing returncode and combined output.
                Returns returncode=-1 with "Canceled" output when cancelled.

        Raises:
            ValueError: Raised when command is empty.

        Side Effects:
            Spawns a subprocess, logs output, may terminate the subprocess early
            if cancellation is signaled.
        """
        if not command:
            raise ValueError("command cannot be empty.")

        # Fast-path: return immediately if already cancelled before starting.
        if self.cancel_event is not None and self.cancel_event.is_set():
            return CommandResult(returncode=-1, output="Canceled")

        # Always use simple blocking subprocess.run - it handles pipe buffers
        # correctly and the cancel_event is checked between steps, not during.
        # The fail-fast behavior works by preventing the *next* step from
        # starting when cancel_event is set.
        result = subprocess_run(  # noqa: S603
            list(command),
            check=False,
            capture_output=True,
            text=True,
        )
        output = _combine_output(result.stdout, result.stderr)
        if output:
            self.logger.command_output(output)
        return CommandResult(returncode=result.returncode, output=output)


def _log_failure(logger: StepLogger, message: str, result: CommandResult) -> None:
    logger.failure(f"{message} (exit code {result.returncode})")
    if result.output:
        logger.failure("Command output:")
        logger.command_output(result.output)


def _run_simple_step(
    *,
    step_number: int,
    description: str,
    step_name: str,
    success_message: str,
    failure_message: str,
    command: Sequence[str],
    runner: CommandRunner,
    logger: StepLogger,
) -> bool:
    logger.step(f"Step {step_number}: {description}")
    result = runner.run(command, step_name=step_name)
    if result.returncode == 0:
        logger.success(success_message)
        return True

    _log_failure(logger, failure_message, result)
    return False


def _ruff_fix(
    *,
    max_retries: int,
    runner: CommandRunner,
    logger: StepLogger,
) -> bool:
    attempt = 0
    last_result: CommandResult | None = None
    # Retry Ruff --fix so lint errors have multiple chances to be auto-corrected.
    while attempt < max_retries:
        attempt += 1
        logger.info(f"Ruff --fix attempt {attempt} of {max_retries}...")
        result = runner.run(
            ["poetry", "run", "ruff", "check", "--fix"], step_name="Ruff: fix"
        )
        last_result = result
        if result.returncode == 0:
            logger.success("Ruff auto-fix completed")
            return True

        if attempt < max_retries:
            logger.info("Ruff found issues. Retrying...")
    _log_failure(
        logger,
        (
            f"Ruff linting failed after {max_retries} attempts. "
            "Please review errors above."
        ),
        last_result or CommandResult(returncode=1, output=""),
    )
    return False


def _run_black_with_retry(
    *,
    step_number: int,
    max_retries: int,
    runner: CommandRunner,
    logger: StepLogger,
) -> bool:
    attempt = 0
    # Black is retried to allow it to reformat files after upstream tools apply fixes.
    while attempt < max_retries:
        attempt += 1
        logger.step(
            f"Step {step_number}: Running Black formatting... "
            f"(attempt {attempt} of {max_retries})"
        )
        result = runner.run(["poetry", "run", "black", "."], step_name="Black: format")
        if result.returncode == 0:
            logger.success("Black formatting completed successfully")
            return True

        if attempt < max_retries:
            logger.info("Black found issues. Retrying...")
        else:
            _log_failure(
                logger,
                f"Black formatting failed after {max_retries} attempts.",
                result,
            )
    return False


# Public aliases for runtime-module access without private-member usage.
stream_isatty = _stream_isatty
run_simple_step = _run_simple_step
ruff_fix = _ruff_fix
run_black_with_retry = _run_black_with_retry
log_failure = _log_failure


def run_fix_all(
    *,
    max_ruff_retries: int = 3,
    max_black_retries: int = 3,
    include_coverage: bool = True,
    runner_factory: Callable[[str, StepLogger], CommandRunner] | None = None,
    logger: StepLogger | None = None,
    complete_all: bool = False,
) -> int:
    """Run the fix-all pipeline in parallel branches."""
    return run_fix_all_runtime(
        max_ruff_retries=max_ruff_retries,
        max_black_retries=max_black_retries,
        include_coverage=include_coverage,
        runner_factory=runner_factory,
        logger=logger,
        complete_all=complete_all,
    )


def parse_args(argv: Sequence[str] | None = None) -> argparse.Namespace:
    """
    Parse command-line arguments for the fix-all workflow.

    Purpose:
        Define and parse CLI options for the fix-all execution entry point.

    Args:
        argv (Sequence[str] | None): Optional argument list for testing or CLI use.

    Returns:
        argparse.Namespace: Parsed arguments with configured defaults.

    Raises:
        SystemExit: Raised by argparse when parsing fails or help is requested.

    Side Effects:
        Writes help or error text to stdout/stderr via argparse when applicable.
    """
    parser = argparse.ArgumentParser(
        description="Run all code quality steps with auto-fix and retries."
    )
    parser.add_argument(
        "--complete-all",
        action="store_true",
        help="Run all branches to completion even if another branch fails.",
    )
    parser.add_argument(
        "--max-ruff-retries",
        type=int,
        default=3,
        help="Maximum number of Ruff --fix retries (default: 3).",
    )
    parser.add_argument(
        "--max-black-retries",
        type=int,
        default=3,
        help="Maximum number of Black retries (default: 3).",
    )
    parser.add_argument(
        "--no-coverage",
        action="store_true",
        help="Skip coverage flags when running pytest.",
    )
    return parser.parse_args(argv)


def main(argv: Sequence[str] | None = None) -> int:
    """
    Run the fix-all workflow using CLI arguments.

    Purpose:
        Provide the command-line entry point for running fix-all.

    Args:
        argv (Sequence[str] | None): Optional CLI arguments for testing or CLI use.

    Returns:
        int: Process exit code (0 for success, 1 for failure).

    Raises:
        SystemExit: Raised by argparse if parsing fails or help is requested.

    Side Effects:
        Executes the fix-all pipeline and writes output to stdout.
    """
    args = parse_args(argv)
    return run_fix_all(
        max_ruff_retries=args.max_ruff_retries,
        max_black_retries=args.max_black_retries,
        include_coverage=not args.no_coverage,
        complete_all=args.complete_all,
    )


if __name__ == "__main__":
    raise SystemExit(main())
