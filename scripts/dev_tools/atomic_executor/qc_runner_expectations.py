"""Expectation-aware QC helpers for pytest and Jest execution."""

from __future__ import annotations

import subprocess
from enum import Enum
from typing import TYPE_CHECKING

from scripts.dev_tools.atomic_executor.pytest_expectations import (
    ResolvedTestExpectations,
    parse_jest_failure_output,
    parse_pytest_failure_output,
    split_jest_expected_ref,
)

if TYPE_CHECKING:
    from collections.abc import Callable
    from pathlib import Path

# The test-execution launcher (issue #1158, spec D12, D16); the suite name follows
# these words.
TEST_SUITE_LAUNCHER_ARGV: list[str] = [
    "pwsh",
    "-NoProfile",
    "-NonInteractive",
    "-File",
    ".claude/skills/test-execution-policy/scripts/Invoke-TestSuite.ps1",
]

_QUEUE_TIMEOUT_EXIT_CODE = 75
_POLICY_REFUSAL_EXIT_CODE = 2
_QUEUE_TIMEOUT_PREFIX = "TEST_EXECUTION_QUEUE_TIMEOUT:"
_POLICY_REFUSAL_PREFIX = "TEST_EXECUTION_POLICY_BLOCKED:"


class LauncherOutcome(Enum):
    """
    A launcher exit that is not a test result (spec D12).

    Purpose:
        Name the two launcher exits that report on the machine test-suite lock or
        the test-execution policy rather than on the tests themselves, so callers
        stop instead of treating them as test failures.

    Attributes:
        QUEUE_TIMEOUT: The machine test-suite lock stayed busy for the whole wait.
        POLICY_REFUSAL: The launcher refused the suite command before starting it.
    """

    QUEUE_TIMEOUT = "queue-timeout"
    POLICY_REFUSAL = "policy-refusal"


def _first_nonblank_line(output: str) -> str:
    """
    Return the first line of output that is not blank.

    Args:
        output (str): Captured stdout and stderr text of a launcher run.

    Returns:
        str: The first non-blank line with surrounding whitespace removed, or an
        empty string when every line is blank.
    """
    # Skip leading blank lines: the launcher writes its prefix line first, but a
    # caller may join stdout before stderr, which can leave blank lines ahead of it.
    for line in output.splitlines():
        if line.strip():
            return line.strip()
    return ""


def classify_launcher_exit(
    returncode: int, output: str | None
) -> LauncherOutcome | None:
    """
    Classify a launcher exit as a queue timeout, a policy refusal, or neither.

    Exit 75, or a non-zero exit whose first non-blank output line starts with the
    queue prefix, is a queue timeout. Exit 2 is a policy refusal only when the first
    non-blank output line starts with the refusal prefix, because pytest also exits
    2 on an interrupted run or a collection error.

    Args:
        returncode (int): Exit code of the launcher process.
        output (str | None): Captured output, or None when it was not captured; with
            None only exit 75 classifies.

    Returns:
        LauncherOutcome | None: The outcome, or None for a test result (including
        every pytest or Jest exit that does not carry a launcher prefix line).
    """
    # Exit 75 is reserved for the queue timeout and no suite reports it (the
    # launcher remaps a child 75 to 1), so it classifies even without output.
    if returncode == _QUEUE_TIMEOUT_EXIT_CODE:
        return LauncherOutcome.QUEUE_TIMEOUT
    # A pass never classifies, and uncaptured output cannot prove a prefix line.
    if output is None or returncode == 0:
        return None
    first_line = _first_nonblank_line(output)
    # Only the first line counts: a prefix quoted later in test output is not a
    # launcher report, and exit 2 without the prefix stays a pytest result.
    if first_line.startswith(_QUEUE_TIMEOUT_PREFIX):
        return LauncherOutcome.QUEUE_TIMEOUT
    if returncode == _POLICY_REFUSAL_EXIT_CODE and first_line.startswith(
        _POLICY_REFUSAL_PREFIX
    ):
        return LauncherOutcome.POLICY_REFUSAL
    return None


def launcher_refusal_message(outcome: LauncherOutcome) -> str:
    """
    Return the one-line report for a launcher outcome.

    Args:
        outcome (LauncherOutcome): The classified launcher outcome.

    Returns:
        str: A line that starts with the outcome's prefix; the queue-timeout line
        states the re-run rule.
    """
    # Each outcome keeps its own prefix so a reader can tell a busy lock (re-run
    # later) from a refused command (correct the command).
    if outcome is LauncherOutcome.QUEUE_TIMEOUT:
        return (
            f"{_QUEUE_TIMEOUT_PREFIX} the machine test-suite lock was busy; re-run the "
            "gate after the holder finishes and record it as a queue timeout, not a "
            "failure (test-execution policy)."
        )
    return (
        f"{_POLICY_REFUSAL_PREFIX} the test-execution launcher refused the suite "
        "command; correct the command and re-run (test-execution policy)."
    )


class LauncherRefusedError(subprocess.CalledProcessError):
    """
    A launcher exit classified as a queue timeout or a policy refusal.

    Purpose:
        Stop a full-suite run with a message that names the launcher outcome,
        while existing ``except subprocess.CalledProcessError`` handlers still
        catch it.

    Attributes:
        outcome (LauncherOutcome): The classified outcome; ``str()`` of the error
            is ``launcher_refusal_message(outcome)``.
    """

    def __init__(
        self,
        outcome: LauncherOutcome,
        returncode: int,
        cmd: list[str],
        output: str | None = None,
    ) -> None:
        """
        Store the outcome alongside the CalledProcessError fields.

        Args:
            outcome (LauncherOutcome): The classified launcher outcome.
            returncode (int): Exit code of the launcher process.
            cmd (list[str]): The launcher argv.
            output (str | None): Captured output, when available.
        """
        super().__init__(returncode, cmd, output=output)
        self.outcome = outcome

    def __str__(self) -> str:
        """
        Return the launcher report line for the stored outcome.

        Returns:
            str: ``launcher_refusal_message(self.outcome)``.
        """
        return launcher_refusal_message(self.outcome)


def _raise_if_launcher_refused(
    returncode: int, cmd: list[str], output: str | None
) -> None:
    """
    Raise LauncherRefusedError when the exit classifies as a launcher outcome.

    Args:
        returncode (int): Exit code of the launcher process.
        cmd (list[str]): The launcher argv, carried on the error.
        output (str | None): Captured output, or None when not captured.

    Returns:
        None: Returns normally when the exit is a test result.

    Raises:
        LauncherRefusedError: When ``classify_launcher_exit`` classifies the exit.
    """
    outcome = classify_launcher_exit(returncode, output)
    if outcome is not None:
        raise LauncherRefusedError(outcome, returncode, cmd, output=output)


def matches_expected_ref(nodeid: str, expected_refs: set[str]) -> bool:
    """Return whether a pytest nodeid matches any expected reference prefix."""
    for expected_ref in expected_refs:
        if nodeid.startswith(expected_ref):
            return True
    return False


def jest_test_matches_expected(test_name: str, expected_refs: set[str]) -> bool:
    """Return whether a Jest test name matches any expected test pattern."""
    for expected_ref in expected_refs:
        _, test_pattern = split_jest_expected_ref(expected_ref)
        if test_pattern and test_pattern in test_name:
            return True
    return False


def jest_file_matches_expected(file_path: str, expected_refs: set[str]) -> bool:
    """Return whether a Jest file path matches any expected file reference."""
    for expected_ref in expected_refs:
        expected_file, _ = split_jest_expected_ref(expected_ref)
        if expected_file and expected_file == file_path:
            return True
    return False


def run_pytest_with_expectations(
    *,
    cmd: list[str],
    workspace: Path,
    resolve_executable: Callable[[list[str]], list[str]],
    expectations: ResolvedTestExpectations | None,
    env: dict[str, str] | None = None,
) -> None:
    """Run pytest and tolerate failures only when they match expected-fail refs."""
    if expectations is None:
        resolved_cmd = resolve_executable(cmd)
        try:
            subprocess.run(  # noqa: S603 - argv constructed from trusted constants
                resolved_cmd,
                cwd=workspace,
                check=True,
                capture_output=False,
                text=True,
                errors="replace",
                env=env,
            )
        except subprocess.CalledProcessError as error:
            # Output is not captured here, so only exit 75 converts; any other code,
            # including a pytest or Jest exit 2, re-raises the plain error.
            _raise_if_launcher_refused(error.returncode, cmd, None)
            raise
        return

    if expectations.missing_test_refs:
        missing_refs = ", ".join(expectations.missing_test_refs)
        raise RuntimeError(
            "Missing test reference for expectation-tagged tasks: " f"{missing_refs}"
        )

    resolved_cmd = resolve_executable(cmd)
    result = subprocess.run(  # noqa: S603 - argv constructed from trusted constants
        resolved_cmd,
        cwd=workspace,
        check=False,
        capture_output=True,
        text=True,
        errors="replace",
        env=env,
    )
    combined = (result.stdout or "") + (result.stderr or "")
    if result.returncode == 0:
        return
    # Classify before parsing (spec D28): a launcher report is not runner output, so
    # no parser or expectation filter may read it as test failures.
    _raise_if_launcher_refused(result.returncode, cmd, combined)

    summary = parse_pytest_failure_output(combined)
    if summary.has_collection_error:
        raise subprocess.CalledProcessError(result.returncode, cmd, output=combined)

    unexpected_failures: list[str] = []
    expected_pass_hits: list[str] = []

    for nodeid in summary.failed_nodeids:
        if matches_expected_ref(nodeid, expectations.expected_pass_refs):
            expected_pass_hits.append(nodeid)
            unexpected_failures.append(nodeid)
        elif matches_expected_ref(nodeid, expectations.expected_fail_refs):
            continue
        else:
            unexpected_failures.append(nodeid)

    if unexpected_failures or expected_pass_hits:
        raise subprocess.CalledProcessError(result.returncode, cmd, output=combined)


def run_jest_with_expectations(
    *,
    cmd: list[str],
    workspace: Path,
    resolve_executable: Callable[[list[str]], list[str]],
    expectations: ResolvedTestExpectations | None,
) -> None:
    """Run Jest and tolerate failures only when they match expected-fail refs."""
    if expectations is None:
        resolved_cmd = resolve_executable(cmd)
        try:
            subprocess.run(  # noqa: S603 - argv constructed from trusted constants
                resolved_cmd,
                cwd=workspace,
                check=True,
                capture_output=False,
                text=True,
                errors="replace",
            )
        except subprocess.CalledProcessError as error:
            # Output is not captured here, so only exit 75 converts; any other code,
            # including a pytest or Jest exit 2, re-raises the plain error.
            _raise_if_launcher_refused(error.returncode, cmd, None)
            raise
        return

    if expectations.missing_test_refs:
        missing_refs = ", ".join(expectations.missing_test_refs)
        raise RuntimeError(
            "Missing test reference for expectation-tagged tasks: " f"{missing_refs}"
        )

    resolved_cmd = resolve_executable(cmd)
    result = subprocess.run(  # noqa: S603 - argv constructed from trusted constants
        resolved_cmd,
        cwd=workspace,
        check=False,
        capture_output=True,
        text=True,
        errors="replace",
    )
    combined = (result.stdout or "") + (result.stderr or "")
    if result.returncode == 0:
        return
    # Classify before parsing (spec D28): a launcher report is not runner output, so
    # no parser or expectation filter may read it as test failures.
    _raise_if_launcher_refused(result.returncode, cmd, combined)

    summary = parse_jest_failure_output(combined)
    if summary.has_runtime_error:
        raise subprocess.CalledProcessError(result.returncode, cmd, output=combined)
    if not summary.failed_tests and not summary.failed_files:
        raise subprocess.CalledProcessError(result.returncode, cmd, output=combined)

    unexpected_failures: list[str] = []
    expected_pass_hits: list[str] = []

    if summary.failed_tests:
        for test_name in summary.failed_tests:
            if jest_test_matches_expected(
                test_name, expectations.expected_pass_jest_refs
            ):
                expected_pass_hits.append(test_name)
                unexpected_failures.append(test_name)
            elif jest_test_matches_expected(
                test_name, expectations.expected_fail_jest_refs
            ):
                continue
            else:
                unexpected_failures.append(test_name)
    else:
        for file_path in summary.failed_files:
            if jest_file_matches_expected(
                file_path, expectations.expected_pass_jest_refs
            ):
                expected_pass_hits.append(file_path)
                unexpected_failures.append(file_path)
            elif jest_file_matches_expected(
                file_path, expectations.expected_fail_jest_refs
            ):
                continue
            else:
                unexpected_failures.append(file_path)

    if unexpected_failures or expected_pass_hits:
        raise subprocess.CalledProcessError(result.returncode, cmd, output=combined)
