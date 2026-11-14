"""
Launcher-outcome tests for run_preflight_qc_with_capture (issue #1158, D16, D28).

The pytest and test-unit steps run the test-execution launcher; a queue timeout
or policy refusal sets ``launcher_outcome`` and stops the run before any output
parser, with and without expectations. subprocess.run and the PATH lookup are
replaced through monkeypatch, so no process starts.
"""

from __future__ import annotations

from pathlib import Path
from typing import TYPE_CHECKING

import pytest

from scripts.dev_tools.atomic_executor import cli_preflight
from scripts.dev_tools.atomic_executor.pytest_expectations import (
    JestFailureSummary,
    PytestFailureSummary,
    ResolvedTestExpectations,
)
from scripts.dev_tools.atomic_executor.qc_runner_expectations import (
    TEST_SUITE_LAUNCHER_ARGV,
    LauncherOutcome,
)
from scripts.dev_tools.atomic_executor.qc_toolchain import QCToolchain

if TYPE_CHECKING:
    from _pytest.monkeypatch import MonkeyPatch

PYTEST_STEP = [
    *TEST_SUITE_LAUNCHER_ARGV,
    "pytest",
    "-n",
    "auto",
    "--color=no",
    "--cov=scripts/dev_tools",
    "--cov-report=term-missing",
]
JEST_STEP = [*TEST_SUITE_LAUNCHER_ARGV, "jest"]
RUFF_STEP = ["poetry", "run", "ruff", "check"]
EXPECTED_REF = "tests/bugs/2026/test_issue_98.py::test_expected_fail"
REFUSAL_LINE = "TEST_EXECUTION_POLICY_BLOCKED: worker token -p no:xdist"
PYTEST_SESSION = (
    "============================= test session starts =============================\n"
    "ERROR collecting tests/test_broken.py\n"
    "Interrupted: 1 error during collection\n"
)


def _expectations(*, jest: bool = False) -> ResolvedTestExpectations:
    """Return expectations with one pytest or one Jest expected-fail ref."""
    return ResolvedTestExpectations(
        expected_fail_refs=set() if jest else {EXPECTED_REF},
        expected_pass_refs=set(),
        expected_fail_jest_refs={"test/a.test.ts::case"} if jest else set(),
        expected_pass_jest_refs=set(),
        missing_test_refs=[],
    )


def _patch_steps(
    monkeypatch: MonkeyPatch, failing: list[str], returncode: int, stdout: str
) -> list[list[str]]:
    """
    Fake PATH lookup and subprocess.run with one failing step.

    Args:
        monkeypatch: Pytest monkeypatch fixture.
        failing: Argv of the step that fails.
        returncode: Exit code of the failing step.
        stdout: Captured output of the failing step.

    Returns:
        list[list[str]]: Each argv passed to subprocess.run, in order.
    """
    argvs: list[list[str]] = []

    def fake_run(
        argv: list[str], **kwargs: object
    ) -> cli_preflight.subprocess.CompletedProcess[str]:
        """Fail the selected step and pass every other step."""
        argvs.append(list(argv))
        code, output = (returncode, stdout) if argv == failing else (0, "OK")
        return cli_preflight.subprocess.CompletedProcess(argv, code, output, "")

    monkeypatch.setattr(cli_preflight.shutil, "which", _which_identity)
    monkeypatch.setattr(cli_preflight.subprocess, "run", fake_run)
    return argvs


def _which_identity(name: str) -> str:
    """Resolve an executable name to itself for argv assertions."""
    return name


def _forbid_parsers(monkeypatch: MonkeyPatch) -> None:
    """Replace both output parsers with functions that fail the test if called."""

    def no_pytest_parse(output: str) -> PytestFailureSummary:
        """Fail: a launcher report must not reach the pytest parser."""
        pytest.fail(f"parse_pytest_failure_output called with {output!r}")

    def no_jest_parse(output: str) -> JestFailureSummary:
        """Fail: a launcher report must not reach the Jest parser."""
        pytest.fail(f"parse_jest_failure_output called with {output!r}")

    monkeypatch.setattr(cli_preflight, "parse_pytest_failure_output", no_pytest_parse)
    monkeypatch.setattr(cli_preflight, "parse_jest_failure_output", no_jest_parse)


class TestWithExpectations:
    """Launcher outcomes when the plan carries expectations."""

    def test_pytest_queue_timeout_stops_before_parsing(
        self, monkeypatch: MonkeyPatch
    ) -> None:
        """Exit 75 sets QUEUE_TIMEOUT and never reaches the pytest parser."""
        _patch_steps(monkeypatch, PYTEST_STEP, 75, "")
        _forbid_parsers(monkeypatch)

        result = cli_preflight.run_preflight_qc_with_capture(
            Path("repo"), expectations=_expectations()
        )

        assert result.success is False
        assert result.failed_step == "pytest"
        assert result.launcher_outcome is LauncherOutcome.QUEUE_TIMEOUT
        assert "TEST_EXECUTION_QUEUE_TIMEOUT" in result.output

    def test_jest_policy_refusal_stops_before_parsing(
        self, monkeypatch: MonkeyPatch
    ) -> None:
        """Exit 2 with the refusal line first sets POLICY_REFUSAL for test-unit."""
        _patch_steps(monkeypatch, JEST_STEP, 2, REFUSAL_LINE + "\n")
        _forbid_parsers(monkeypatch)

        result = cli_preflight.run_preflight_qc_with_capture(
            Path("repo"),
            expectations=_expectations(jest=True),
            toolchain=QCToolchain.TYPESCRIPT,
        )

        assert result.success is False
        assert result.failed_step == "test-unit"
        assert result.launcher_outcome is LauncherOutcome.POLICY_REFUSAL

    def test_pytest_exit_2_session_output_reaches_parser(
        self, monkeypatch: MonkeyPatch
    ) -> None:
        """A pytest exit 2 with session output keeps today's parsing."""
        _patch_steps(monkeypatch, PYTEST_STEP, 2, PYTEST_SESSION)
        parsed: list[str] = []
        real_parse = cli_preflight.parse_pytest_failure_output

        def spy_parse(output: str) -> PytestFailureSummary:
            """Record the parsed output and delegate to the real parser."""
            parsed.append(output)
            return real_parse(output)

        monkeypatch.setattr(cli_preflight, "parse_pytest_failure_output", spy_parse)

        result = cli_preflight.run_preflight_qc_with_capture(
            Path("repo"), expectations=_expectations()
        )

        assert result.success is False
        assert result.launcher_outcome is None
        assert parsed == [PYTEST_SESSION]

    def test_collect_step_stays_direct(self, monkeypatch: MonkeyPatch) -> None:
        """The --collect-only step keeps its direct poetry argv (spec D24)."""
        argvs = _patch_steps(monkeypatch, PYTEST_STEP, 0, "")

        cli_preflight.run_preflight_qc_with_capture(
            Path("repo"), expectations=_expectations()
        )

        collect = next(argv for argv in argvs if "--collect-only" in argv)
        assert collect == [
            "poetry",
            "run",
            "pytest",
            "--collect-only",
            "--color=no",
            EXPECTED_REF,
        ]
        assert PYTEST_STEP in argvs


class TestWithoutExpectations:
    """Launcher outcomes classify ahead of the expectations-is-None return."""

    def test_pytest_queue_timeout(self, monkeypatch: MonkeyPatch) -> None:
        """Exit 75 sets QUEUE_TIMEOUT without expectations."""
        _patch_steps(monkeypatch, PYTEST_STEP, 75, "")

        result = cli_preflight.run_preflight_qc_with_capture(Path("repo"))

        assert result.success is False
        assert result.failed_step == "pytest"
        assert result.launcher_outcome is LauncherOutcome.QUEUE_TIMEOUT

    def test_jest_policy_refusal(self, monkeypatch: MonkeyPatch) -> None:
        """Exit 2 with the refusal line first sets POLICY_REFUSAL."""
        _patch_steps(monkeypatch, JEST_STEP, 2, REFUSAL_LINE)

        result = cli_preflight.run_preflight_qc_with_capture(
            Path("repo"), toolchain=QCToolchain.TYPESCRIPT
        )

        assert result.launcher_outcome is LauncherOutcome.POLICY_REFUSAL

    def test_pytest_exit_2_session_output_is_a_test_failure(
        self, monkeypatch: MonkeyPatch
    ) -> None:
        """A pytest exit 2 with session output carries no launcher outcome."""
        _patch_steps(monkeypatch, PYTEST_STEP, 2, PYTEST_SESSION)

        result = cli_preflight.run_preflight_qc_with_capture(Path("repo"))

        assert result.success is False
        assert result.failed_step == "pytest"
        assert result.launcher_outcome is None

    def test_ruff_step_never_classifies(self, monkeypatch: MonkeyPatch) -> None:
        """Only test steps classify, even when another step prints the prefix."""
        _patch_steps(monkeypatch, RUFF_STEP, 2, REFUSAL_LINE)

        result = cli_preflight.run_preflight_qc_with_capture(Path("repo"))

        assert result.failed_step == "ruff"
        assert result.launcher_outcome is None
