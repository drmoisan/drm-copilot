"""Failure-path tests for the fix-all branch and runtime aggregation logic.

These tests exercise the FAIL, cancel, and aggregation paths that the existing
suites do not cover: per-branch step failures (json, shell, powershell), the
Python Ruff command-output branch, and the runtime aggregation paths in
``fix_all_runtime`` (empty output and missing/None branch result). All tests use
the in-memory FakeRunner/FakeRunnerFactory seams; no temp files or external
processes are created.
"""

from __future__ import annotations

from io import StringIO
from typing import TYPE_CHECKING, cast

from scripts.dev_tools import fix_all
from scripts.dev_tools import fix_all_branches as branches
from tests.scripts.dev_tools.fix_all_thread_stubs import (
    SkipBranchThread as _SkipBranchThread,
)
from tests.scripts.dev_tools.fix_all_thread_stubs import make_ordered_thread_class

if TYPE_CHECKING:
    from collections.abc import Iterable, Mapping, Sequence

    from pytest import MonkeyPatch


def make_result(code: int, output: str = "") -> fix_all.CommandResult:
    """Build a CommandResult with the given return code and output."""
    return fix_all.CommandResult(returncode=code, output=output)


class FakeRunner:
    """In-memory CommandRunner returning queued responses per step name."""

    def __init__(
        self, responses: Mapping[str, Iterable[fix_all.CommandResult]]
    ) -> None:
        self.responses = {name: list(values) for name, values in responses.items()}
        self.calls: list[tuple[str, list[str]]] = []
        self.branch_name: str | None = None

    def run(self, command: Sequence[str], *, step_name: str) -> fix_all.CommandResult:
        """Record the call and pop the next queued response for ``step_name``."""
        self.calls.append((step_name, list(command)))
        if step_name not in self.responses or not self.responses[step_name]:
            raise AssertionError(f"No response configured for {step_name}")
        return self.responses[step_name].pop(0)


class FakeRunnerFactory:
    """Factory producing one FakeRunner per branch from queued responses."""

    def __init__(
        self,
        responses_by_branch: Mapping[
            str, Mapping[str, Iterable[fix_all.CommandResult]]
        ],
    ) -> None:
        self.responses_by_branch = responses_by_branch
        self.runners: dict[str, FakeRunner] = {}

    def __call__(
        self, branch_name: str, branch_logger: fix_all.StepLogger
    ) -> FakeRunner:
        """Create and remember a FakeRunner for ``branch_name``."""
        runner = FakeRunner(self.responses_by_branch[branch_name])
        runner.branch_name = branch_name
        self.runners[branch_name] = runner
        return runner


def build_logger() -> fix_all.StepLogger:
    """Build a StepLogger backed by an in-memory stream."""
    return fix_all.StepLogger(stream=StringIO())


def read_log(logger: fix_all.StepLogger) -> str:
    """Return the accumulated text written to ``logger``'s stream."""
    return cast("StringIO", logger.stream).getvalue()


def base_success_responses(
    *, include_coverage: bool = True
) -> dict[str, dict[str, list[fix_all.CommandResult]]]:
    """Return a response map where every branch step succeeds."""
    pytest_key = "Pytest: test with coverage" if include_coverage else "Pytest: test"
    jest_key = "Jest: test with coverage" if include_coverage else "Jest: test"
    return {
        "json": {
            "JSON: format": [make_result(0)],
            "JSON: validate": [make_result(0)],
        },
        "shell": {
            "Shell: format": [make_result(0)],
            "Shell: check": [make_result(0)],
            "Shell: test": [make_result(0)],
        },
        "python": {
            "Black: format": [make_result(0)],
            "Ruff: lint": [make_result(0)],
            "Pyright: type-check": [make_result(0)],
            pytest_key: [make_result(0)],
        },
        "powershell": {
            "PoshQC: format": [make_result(0)],
            "PoshQC: analyze": [make_result(0)],
            "PoshQC: test": [make_result(0)],
        },
        "typescript": {
            "Prettier: format": [make_result(0)],
            "ESLint: lint": [make_result(0)],
            "TSC: type-check": [make_result(0)],
            jest_key: [make_result(0)],
        },
    }


# --- P2-T1: JSON branch FAIL and cancel paths ---


def test_json_format_failure_returns_fail_result() -> None:
    """A failing JSON format step fails the pipeline and tags JSON: format."""
    # Arrange: JSON format fails; complete_all keeps other branches running.
    responses = base_success_responses()
    responses["json"] = {"JSON: format": [make_result(1, "json format error")]}
    factory = FakeRunnerFactory(responses)
    logger = build_logger()

    # Act
    exit_code = fix_all.run_fix_all(
        max_ruff_retries=1,
        include_coverage=True,
        runner_factory=factory,
        logger=logger,
        complete_all=True,
    )

    # Assert
    assert exit_code == 1
    json_calls = [call[0] for call in factory.runners["json"].calls]
    assert json_calls == ["JSON: format"]
    assert "JSON: validate" not in json_calls
    assert "STATUS|branch=json|status=FAIL" in read_log(logger)


def test_json_cancel_before_validate_returns_canceled_result(
    monkeypatch: MonkeyPatch,
) -> None:
    """JSON cancels before validate when a sibling fails and complete_all is off."""
    # Arrange: Python fails (sets cancel); JSON has only a format response so
    # validate must never run. complete_all defaults to False.
    #
    # Ordering: run the python branch to completion before the json branch, so
    # the cancel event is already set when json reaches its first cancel check.
    # Without this the assertion below depends on whether python's failure beats
    # a 10 ms wall-clock grace period in fix_all_branches, which is a scheduler
    # race rather than a property of the inputs (issue #505).
    import scripts.dev_tools.fix_all_runtime as runtime

    monkeypatch.setattr(
        runtime.threading,
        "Thread",
        make_ordered_thread_class(order=("python", "json")),
    )
    responses = base_success_responses()
    responses["python"]["Black: format"] = [
        make_result(1, "err"),
        make_result(1, "err"),
        make_result(1, "err"),
    ]
    responses["json"] = {"JSON: format": [make_result(0)]}
    factory = FakeRunnerFactory(responses)
    logger = build_logger()

    # Act
    exit_code = fix_all.run_fix_all(
        max_black_retries=3,
        max_ruff_retries=1,
        include_coverage=True,
        runner_factory=factory,
        logger=logger,
    )

    # Assert: JSON did not run validate; pipeline failed.
    assert exit_code == 1
    json_calls = [call[0] for call in factory.runners["json"].calls]
    assert "JSON: validate" not in json_calls


def test_json_validate_failure_returns_fail_result() -> None:
    """A failing JSON validate step fails the pipeline and tags JSON: validate."""
    # Arrange: JSON format passes, validate fails; complete_all isolates JSON.
    responses = base_success_responses()
    responses["json"] = {
        "JSON: format": [make_result(0)],
        "JSON: validate": [make_result(1, "invalid json")],
    }
    factory = FakeRunnerFactory(responses)
    logger = build_logger()

    # Act
    exit_code = fix_all.run_fix_all(
        max_ruff_retries=1,
        include_coverage=True,
        runner_factory=factory,
        logger=logger,
        complete_all=True,
    )

    # Assert
    assert exit_code == 1
    json_calls = [call[0] for call in factory.runners["json"].calls]
    assert json_calls == ["JSON: format", "JSON: validate"]
    assert "JSON validation failed" in read_log(logger)


# --- P2-T2: shell branch FAIL paths ---


def test_shell_format_failure_returns_fail_result() -> None:
    """A failing shell format step stops the shell branch at Shell: format."""
    # Arrange
    responses = base_success_responses()
    responses["shell"] = {"Shell: format": [make_result(1, "shfmt error")]}
    factory = FakeRunnerFactory(responses)
    logger = build_logger()

    # Act
    exit_code = fix_all.run_fix_all(
        max_ruff_retries=1,
        include_coverage=True,
        runner_factory=factory,
        logger=logger,
        complete_all=True,
    )

    # Assert
    assert exit_code == 1
    shell_calls = [call[0] for call in factory.runners["shell"].calls]
    assert shell_calls == ["Shell: format"]
    assert "Shell formatting failed" in read_log(logger)


def test_shell_check_failure_returns_fail_result() -> None:
    """A failing shell check step stops the shell branch at Shell: check."""
    # Arrange
    responses = base_success_responses()
    responses["shell"] = {
        "Shell: format": [make_result(0)],
        "Shell: check": [make_result(1, "shellcheck error")],
    }
    factory = FakeRunnerFactory(responses)
    logger = build_logger()

    # Act
    exit_code = fix_all.run_fix_all(
        max_ruff_retries=1,
        include_coverage=True,
        runner_factory=factory,
        logger=logger,
        complete_all=True,
    )

    # Assert
    assert exit_code == 1
    shell_calls = [call[0] for call in factory.runners["shell"].calls]
    assert shell_calls == ["Shell: format", "Shell: check"]
    assert "Shell: test" not in shell_calls
    assert "Shell linting failed" in read_log(logger)


def test_shell_test_failure_returns_fail_result() -> None:
    """A failing shell test step reaches the failure aggregation path."""
    # Arrange: format and check pass, tests fail with a non-zero return code.
    responses = base_success_responses()
    responses["shell"] = {
        "Shell: format": [make_result(0)],
        "Shell: check": [make_result(0)],
        "Shell: test": [make_result(1, "bats failure")],
    }
    factory = FakeRunnerFactory(responses)
    logger = build_logger()

    # Act
    exit_code = fix_all.run_fix_all(
        max_ruff_retries=1,
        include_coverage=True,
        runner_factory=factory,
        logger=logger,
        complete_all=True,
    )

    # Assert
    assert exit_code == 1
    shell_calls = [call[0] for call in factory.runners["shell"].calls]
    assert shell_calls == ["Shell: format", "Shell: check", "Shell: test"]
    assert "STATUS|branch=shell|status=FAIL" in read_log(logger)


# --- P2-T3: python Ruff command-output branch and powershell FAIL paths ---


def test_python_ruff_logs_command_output_when_present() -> None:
    """A non-empty Ruff output is forwarded to the command-output log path."""
    # Arrange: Ruff lint fails once with output, then auto-fix succeeds and a
    # clean re-lint follows, exercising the `if ruff_result.output` branch.
    responses = base_success_responses()
    responses["python"]["Black: format"] = [make_result(0), make_result(0)]
    responses["python"]["Ruff: lint"] = [
        make_result(1, "RUFF-OUTPUT-MARKER"),
        make_result(0),
    ]
    responses["python"]["Ruff: fix"] = [make_result(0)]
    factory = FakeRunnerFactory(responses)
    logger = build_logger()

    # Act
    exit_code = fix_all.run_fix_all(
        max_ruff_retries=2,
        include_coverage=True,
        runner_factory=factory,
        logger=logger,
    )

    # Assert: pipeline succeeds and the Ruff output reached the branch log.
    assert exit_code == 0
    output = read_log(logger)
    assert "RUFF-OUTPUT-MARKER" in output


def test_powershell_format_failure_returns_fail_result() -> None:
    """A failing PoshQC format step stops the powershell branch at format."""
    # Arrange
    responses = base_success_responses()
    responses["powershell"] = {"PoshQC: format": [make_result(1, "format error")]}
    factory = FakeRunnerFactory(responses)
    logger = build_logger()

    # Act
    exit_code = fix_all.run_fix_all(
        max_ruff_retries=1,
        include_coverage=True,
        runner_factory=factory,
        logger=logger,
        complete_all=True,
    )

    # Assert
    assert exit_code == 1
    powershell_calls = [call[0] for call in factory.runners["powershell"].calls]
    assert powershell_calls == ["PoshQC: format"]
    assert "PowerShell formatting failed" in read_log(logger)


def test_powershell_analyze_failure_returns_fail_result() -> None:
    """A failing PoshQC analyze step stops the powershell branch at analyze."""
    # Arrange
    responses = base_success_responses()
    responses["powershell"] = {
        "PoshQC: format": [make_result(0)],
        "PoshQC: analyze": [make_result(1, "analyze error")],
    }
    factory = FakeRunnerFactory(responses)
    logger = build_logger()

    # Act
    exit_code = fix_all.run_fix_all(
        max_ruff_retries=1,
        include_coverage=True,
        runner_factory=factory,
        logger=logger,
        complete_all=True,
    )

    # Assert
    assert exit_code == 1
    powershell_calls = [call[0] for call in factory.runners["powershell"].calls]
    assert powershell_calls == ["PoshQC: format", "PoshQC: analyze"]
    assert "PoshQC: test" not in powershell_calls
    assert "PowerShell analysis failed" in read_log(logger)


def test_powershell_test_failure_returns_fail_result() -> None:
    """A failing PoshQC test step stops the powershell branch at test."""
    # Arrange
    responses = base_success_responses()
    responses["powershell"] = {
        "PoshQC: format": [make_result(0)],
        "PoshQC: analyze": [make_result(0)],
        "PoshQC: test": [make_result(1, "pester error")],
    }
    factory = FakeRunnerFactory(responses)
    logger = build_logger()

    # Act
    exit_code = fix_all.run_fix_all(
        max_ruff_retries=1,
        include_coverage=True,
        runner_factory=factory,
        logger=logger,
        complete_all=True,
    )

    # Assert
    assert exit_code == 1
    powershell_calls = [call[0] for call in factory.runners["powershell"].calls]
    assert powershell_calls == ["PoshQC: format", "PoshQC: analyze", "PoshQC: test"]
    assert "PowerShell tests failed" in read_log(logger)


# --- P2-T4: runtime aggregation paths (empty output / missing result) ---


def test_runtime_emits_no_output_for_empty_branch_output(
    monkeypatch: MonkeyPatch,
) -> None:
    """A branch returning empty output triggers the runtime '(no output)' path."""

    # Arrange: replace the json branch with one returning an empty-output
    # success result so the runtime per-branch log loop hits the else branch.
    def empty_output_json_branch(**_kwargs: object) -> fix_all.BranchResult:
        """Return a successful json result with no captured output."""
        return fix_all.BranchResult(name="json", success=True, output="")

    monkeypatch.setattr(branches, "run_json_branch", empty_output_json_branch)
    factory = FakeRunnerFactory(base_success_responses())
    logger = build_logger()

    # Act
    exit_code = fix_all.run_fix_all(
        max_ruff_retries=1,
        include_coverage=True,
        runner_factory=factory,
        logger=logger,
    )

    # Assert
    assert exit_code == 0
    assert "(no output)" in read_log(logger)


def test_runtime_reports_missing_result_when_branch_absent(
    monkeypatch: MonkeyPatch,
) -> None:
    """A branch with no recorded result triggers the missing-result path."""
    # Arrange: replace the runtime Thread with one that never runs the json
    # branch target, so results["json"] stays unset without any exception.
    import scripts.dev_tools.fix_all_runtime as runtime

    monkeypatch.setattr(runtime.threading, "Thread", _SkipBranchThread)
    factory = FakeRunnerFactory(base_success_responses())
    logger = build_logger()

    # Act
    exit_code = fix_all.run_fix_all(
        max_ruff_retries=1,
        include_coverage=True,
        runner_factory=factory,
        logger=logger,
        complete_all=True,
    )

    # Assert: the json result is missing, so the summary records the
    # missing-result message and the per-branch log loop skips the None entry.
    # The exit code reflects only recorded results (the four others succeed),
    # so it remains 0; the assertion targets the aggregation messages.
    assert exit_code == 0
    output = read_log(logger)
    assert "Branch json did not produce a result." in output
    assert "--- json branch log ---" not in output
