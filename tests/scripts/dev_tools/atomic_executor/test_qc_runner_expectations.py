"""
Tests for the launcher contract in atomic_executor.qc_runner_expectations.

Covers the exit classification of the test-execution launcher (issue #1158, spec
D12 and D28): the pure classifier, the report line, the error type, and the
classification order inside run_pytest_with_expectations and
run_jest_with_expectations. subprocess.run is replaced through monkeypatch, so no
process starts.
"""

from __future__ import annotations

from collections.abc import Callable
from pathlib import Path
from typing import TYPE_CHECKING

import pytest

import scripts.dev_tools.atomic_executor.qc_runner_expectations as qre
from scripts.dev_tools.atomic_executor.pytest_expectations import (
    JestFailureSummary,
    PytestFailureSummary,
    ResolvedTestExpectations,
)

if TYPE_CHECKING:
    from _pytest.monkeypatch import MonkeyPatch

QUEUE_LINE = "TEST_EXECUTION_QUEUE_TIMEOUT: lock held by pytest (pid 42); retry later"
REFUSAL_LINE = (
    "TEST_EXECUTION_POLICY_BLOCKED: local integration lane is CI-only evidence"
)
PYTEST_SESSION = (
    "============================= test session starts =============================\n"
    "collected 0 items / 1 error\n"
    "ERROR collecting tests/test_broken.py\n"
    "Interrupted: 1 error during collection\n"
)
JEST_RUNTIME_ERROR = "FAIL test/a.test.ts\n  Test suite failed to run\n"
LAUNCHER_CMD = [*qre.TEST_SUITE_LAUNCHER_ARGV, "pytest", "-n", "auto"]


def _expectations() -> ResolvedTestExpectations:
    """Return empty expectations so the captured-output path runs."""
    return ResolvedTestExpectations(
        expected_fail_refs=set(),
        expected_pass_refs=set(),
        expected_fail_jest_refs=set(),
        expected_pass_jest_refs=set(),
        missing_test_refs=[],
    )


def _identity(argv: list[str]) -> list[str]:
    """Resolve executables to themselves for argv assertions."""
    return argv


def _patch_run(
    monkeypatch: MonkeyPatch, returncode: int, stdout: str
) -> list[dict[str, object]]:
    """
    Replace subprocess.run with a fake that reports one fixed result.

    Args:
        monkeypatch (MonkeyPatch): Pytest monkeypatch fixture.
        returncode (int): Exit code the fake reports.
        stdout (str): Captured stdout the fake reports.

    Returns:
        list[dict[str, object]]: The keyword arguments of each call, in order.

    Side Effects:
        A check=True call with a non-zero code raises CalledProcessError, as the
        real function does.
    """
    calls: list[dict[str, object]] = []

    def fake_run(
        argv: list[str], **kwargs: object
    ) -> qre.subprocess.CompletedProcess[str]:
        """Record the call and report the fixed result."""
        calls.append(kwargs)
        if kwargs.get("check") and returncode != 0:
            raise qre.subprocess.CalledProcessError(returncode, argv)
        return qre.subprocess.CompletedProcess(
            args=argv, returncode=returncode, stdout=stdout, stderr=""
        )

    monkeypatch.setattr(qre.subprocess, "run", fake_run)
    return calls


def _forbid_parsers(monkeypatch: MonkeyPatch) -> None:
    """Replace both output parsers with functions that fail the test if called."""

    def no_pytest_parse(output: str) -> PytestFailureSummary:
        """Fail: a launcher report must not reach the pytest parser."""
        pytest.fail(f"parse_pytest_failure_output called with {output!r}")

    def no_jest_parse(output: str) -> JestFailureSummary:
        """Fail: a launcher report must not reach the Jest parser."""
        pytest.fail(f"parse_jest_failure_output called with {output!r}")

    monkeypatch.setattr(qre, "parse_pytest_failure_output", no_pytest_parse)
    monkeypatch.setattr(qre, "parse_jest_failure_output", no_jest_parse)


RunFunction = Callable[..., None]


def _run_pytest(expectations: ResolvedTestExpectations | None) -> None:
    """Call run_pytest_with_expectations with the launcher argv."""
    qre.run_pytest_with_expectations(
        cmd=LAUNCHER_CMD,
        workspace=Path("repo"),
        resolve_executable=_identity,
        expectations=expectations,
    )


def _run_jest(expectations: ResolvedTestExpectations | None) -> None:
    """Call run_jest_with_expectations with the launcher jest argv."""
    qre.run_jest_with_expectations(
        cmd=[*qre.TEST_SUITE_LAUNCHER_ARGV, "jest"],
        workspace=Path("repo"),
        resolve_executable=_identity,
        expectations=expectations,
    )


class TestLauncherArgv:
    """Tests for the TEST_SUITE_LAUNCHER_ARGV constant."""

    def test_launcher_argv_is_pwsh_file_form(self) -> None:
        """The launcher words start pwsh with -File and the launcher script."""
        assert qre.TEST_SUITE_LAUNCHER_ARGV == [
            "pwsh",
            "-NoProfile",
            "-NonInteractive",
            "-File",
            ".claude/skills/test-execution-policy/scripts/Invoke-TestSuite.ps1",
        ]


class TestClassifyLauncherExit:
    """Tests for classify_launcher_exit."""

    @pytest.mark.parametrize(
        ("returncode", "output", "expected"),
        [
            (75, None, qre.LauncherOutcome.QUEUE_TIMEOUT),
            (75, "any text", qre.LauncherOutcome.QUEUE_TIMEOUT),
            (1, QUEUE_LINE, qre.LauncherOutcome.QUEUE_TIMEOUT),
            (0, QUEUE_LINE, None),
            (2, REFUSAL_LINE, qre.LauncherOutcome.POLICY_REFUSAL),
            (2, "\n  \n" + REFUSAL_LINE, qre.LauncherOutcome.POLICY_REFUSAL),
            (2, PYTEST_SESSION, None),
            (2, PYTEST_SESSION + REFUSAL_LINE + "\n", None),
            (2, None, None),
            (1, REFUSAL_LINE, None),
            (0, None, None),
            (3, None, None),
            (4, None, None),
            (5, None, None),
            (-1, None, None),
            (137, None, None),
        ],
    )
    def test_classifies_exit(
        self,
        returncode: int,
        output: str | None,
        expected: qre.LauncherOutcome | None,
    ) -> None:
        """Each exit code and first output line maps to its outcome."""
        assert qre.classify_launcher_exit(returncode, output) is expected


class TestLauncherRefusal:
    """Tests for launcher_refusal_message and LauncherRefusedError."""

    @pytest.mark.parametrize(
        ("outcome", "prefix"),
        [
            (qre.LauncherOutcome.QUEUE_TIMEOUT, "TEST_EXECUTION_QUEUE_TIMEOUT:"),
            (qre.LauncherOutcome.POLICY_REFUSAL, "TEST_EXECUTION_POLICY_BLOCKED:"),
        ],
    )
    def test_message_starts_with_prefix(
        self, outcome: qre.LauncherOutcome, prefix: str
    ) -> None:
        """The report line starts with the outcome's prefix and is one line."""
        message = qre.launcher_refusal_message(outcome)
        assert message.startswith(prefix)
        assert "\n" not in message

    def test_queue_message_states_rerun_rule(self) -> None:
        """The queue-timeout line names the lock and the re-run rule."""
        message = qre.launcher_refusal_message(qre.LauncherOutcome.QUEUE_TIMEOUT)
        assert "machine test-suite lock" in message
        assert "re-run" in message

    def test_error_is_called_process_error_with_message(self) -> None:
        """LauncherRefusedError subclasses CalledProcessError; str is the report."""
        error = qre.LauncherRefusedError(
            qre.LauncherOutcome.POLICY_REFUSAL, 2, LAUNCHER_CMD, output="x"
        )
        assert isinstance(error, qre.subprocess.CalledProcessError)
        assert error.outcome is qre.LauncherOutcome.POLICY_REFUSAL
        assert error.returncode == 2
        assert str(error).startswith("TEST_EXECUTION_POLICY_BLOCKED:")


@pytest.mark.parametrize("run", [_run_pytest, _run_jest], ids=["pytest", "jest"])
class TestRunWithExpectationsLauncherOutcomes:
    """Launcher outcomes in run_pytest_with_expectations and the Jest twin."""

    def test_queue_timeout_raises_before_parsing(
        self, run: RunFunction, monkeypatch: MonkeyPatch
    ) -> None:
        """With expectations, exit 75 raises LauncherRefusedError unparsed."""
        _patch_run(monkeypatch, 75, QUEUE_LINE)
        _forbid_parsers(monkeypatch)

        with pytest.raises(qre.LauncherRefusedError) as info:
            run(_expectations())

        assert "TEST_EXECUTION_QUEUE_TIMEOUT" in str(info.value)
        assert isinstance(info.value, qre.subprocess.CalledProcessError)
        assert info.value.outcome is qre.LauncherOutcome.QUEUE_TIMEOUT

    def test_policy_refusal_raises_before_parsing(
        self, run: RunFunction, monkeypatch: MonkeyPatch
    ) -> None:
        """With expectations, exit 2 with the refusal line first raises unparsed."""
        _patch_run(monkeypatch, 2, REFUSAL_LINE + "\n")
        _forbid_parsers(monkeypatch)

        with pytest.raises(qre.LauncherRefusedError) as info:
            run(_expectations())

        assert "TEST_EXECUTION_POLICY_BLOCKED" in str(info.value)
        assert info.value.outcome is qre.LauncherOutcome.POLICY_REFUSAL

    def test_without_expectations_exit_75_raises_launcher_error(
        self, run: RunFunction, monkeypatch: MonkeyPatch
    ) -> None:
        """Without expectations (no capture), exit 75 still converts."""
        calls = _patch_run(monkeypatch, 75, "")

        with pytest.raises(qre.LauncherRefusedError) as info:
            run(None)

        assert info.value.outcome is qre.LauncherOutcome.QUEUE_TIMEOUT
        assert calls[0]["check"] is True
        assert calls[0]["capture_output"] is False

    def test_without_expectations_exit_2_stays_plain(
        self, run: RunFunction, monkeypatch: MonkeyPatch
    ) -> None:
        """Without expectations, exit 2 cannot be proven a refusal and re-raises."""
        _patch_run(monkeypatch, 2, "")

        with pytest.raises(qre.subprocess.CalledProcessError) as info:
            run(None)

        assert not isinstance(info.value, qre.LauncherRefusedError)
        assert info.value.returncode == 2


class TestPytestExpectationsKeepTodaysHandling:
    """Exits without a launcher outcome keep the existing pytest handling."""

    def test_exit_2_collection_error_reaches_parser(
        self, monkeypatch: MonkeyPatch
    ) -> None:
        """A pytest exit 2 with session output is parsed and raises plainly."""
        _patch_run(monkeypatch, 2, PYTEST_SESSION)
        parsed: list[str] = []
        real_parse = qre.parse_pytest_failure_output

        def spy_parse(output: str) -> PytestFailureSummary:
            """Record the parsed output and delegate to the real parser."""
            parsed.append(output)
            return real_parse(output)

        monkeypatch.setattr(qre, "parse_pytest_failure_output", spy_parse)

        with pytest.raises(qre.subprocess.CalledProcessError) as info:
            _run_pytest(_expectations())

        assert parsed == [PYTEST_SESSION]
        assert not isinstance(info.value, qre.LauncherRefusedError)

    def test_exit_1_unexpected_failure_raises_plain(
        self, monkeypatch: MonkeyPatch
    ) -> None:
        """An unexpected pytest failure keeps raising the plain error."""
        _patch_run(monkeypatch, 1, "FAILED tests/test_a.py::test_x - AssertionError")

        with pytest.raises(qre.subprocess.CalledProcessError) as info:
            _run_pytest(_expectations())

        assert not isinstance(info.value, qre.LauncherRefusedError)

    def test_exit_1_expected_failure_is_tolerated(
        self, monkeypatch: MonkeyPatch
    ) -> None:
        """An expected-fail pytest failure is still tolerated."""
        _patch_run(monkeypatch, 1, "FAILED tests/test_a.py::test_x - AssertionError")
        expectations = ResolvedTestExpectations(
            expected_fail_refs={"tests/test_a.py::test_x"},
            expected_pass_refs=set(),
            expected_fail_jest_refs=set(),
            expected_pass_jest_refs=set(),
            missing_test_refs=[],
        )

        _run_pytest(expectations)


class TestJestExpectationsKeepTodaysHandling:
    """Exits without a launcher outcome keep the existing Jest handling."""

    def test_refusal_line_precedes_runtime_error_raise(
        self, monkeypatch: MonkeyPatch
    ) -> None:
        """A refusal line first wins over output the parser reads as a crash."""
        _patch_run(monkeypatch, 2, REFUSAL_LINE + "\n" + JEST_RUNTIME_ERROR)

        with pytest.raises(qre.LauncherRefusedError) as info:
            _run_jest(_expectations())

        assert info.value.outcome is qre.LauncherOutcome.POLICY_REFUSAL

    def test_exit_2_runtime_error_raises_plain(self, monkeypatch: MonkeyPatch) -> None:
        """A Jest exit 2 without the prefix line keeps the runtime-error raise."""
        _patch_run(monkeypatch, 2, JEST_RUNTIME_ERROR)

        with pytest.raises(qre.subprocess.CalledProcessError) as info:
            _run_jest(_expectations())

        assert not isinstance(info.value, qre.LauncherRefusedError)

    def test_exit_1_unexpected_failure_raises_plain(
        self, monkeypatch: MonkeyPatch
    ) -> None:
        """An unexpected Jest failure keeps raising the plain error."""
        _patch_run(monkeypatch, 1, "FAIL test/a.test.ts\n● suite > case\n")

        with pytest.raises(qre.subprocess.CalledProcessError) as info:
            _run_jest(_expectations())

        assert not isinstance(info.value, qre.LauncherRefusedError)


def _jest_expectations(
    *, fail: set[str] | None = None, passing: set[str] | None = None
) -> ResolvedTestExpectations:
    """Return expectations carrying only Jest refs."""
    return ResolvedTestExpectations(
        expected_fail_refs=set(),
        expected_pass_refs=set(),
        expected_fail_jest_refs=fail or set(),
        expected_pass_jest_refs=passing or set(),
        missing_test_refs=[],
    )


class TestExpectationPathsUnchanged:
    """Existing expectation handling around the launcher classification."""

    def test_blank_output_does_not_classify(self) -> None:
        """Output with only blank lines has no prefix line."""
        assert qre.classify_launcher_exit(2, "  \n\n") is None

    @pytest.mark.parametrize("run", [_run_pytest, _run_jest], ids=["pytest", "jest"])
    def test_exit_0_returns(self, run: RunFunction, monkeypatch: MonkeyPatch) -> None:
        """A passing captured run returns without raising."""
        _patch_run(monkeypatch, 0, "")

        run(_expectations())

    @pytest.mark.parametrize("run", [_run_pytest, _run_jest], ids=["pytest", "jest"])
    def test_missing_refs_raise_runtime_error(
        self, run: RunFunction, monkeypatch: MonkeyPatch
    ) -> None:
        """Missing expectation refs stop the run before it starts."""
        calls = _patch_run(monkeypatch, 0, "")
        expectations = ResolvedTestExpectations(
            expected_fail_refs=set(),
            expected_pass_refs=set(),
            expected_fail_jest_refs=set(),
            expected_pass_jest_refs=set(),
            missing_test_refs=["P1-T1"],
        )

        with pytest.raises(RuntimeError, match="P1-T1"):
            run(expectations)
        assert calls == []

    def test_pytest_expected_pass_hit_raises(self, monkeypatch: MonkeyPatch) -> None:
        """A failure of an expected-pass ref raises even when also expected-fail."""
        _patch_run(monkeypatch, 1, "FAILED tests/test_a.py::test_x - AssertionError")
        expectations = ResolvedTestExpectations(
            expected_fail_refs={"tests/test_a.py::test_x"},
            expected_pass_refs={"tests/test_a.py::test_x"},
            expected_fail_jest_refs=set(),
            expected_pass_jest_refs=set(),
            missing_test_refs=[],
        )

        with pytest.raises(qre.subprocess.CalledProcessError):
            _run_pytest(expectations)

    def test_jest_unparsed_failure_raises(self, monkeypatch: MonkeyPatch) -> None:
        """A Jest failure with no parsable test or file raises."""
        _patch_run(monkeypatch, 1, "something went wrong\n")

        with pytest.raises(qre.subprocess.CalledProcessError):
            _run_jest(_expectations())

    @pytest.mark.parametrize(
        ("stdout", "expectations", "raises"),
        [
            (
                "FAIL test/a.test.ts\n\u25cf suite > case\n",
                _jest_expectations(fail={"test/a.test.ts::case"}),
                False,
            ),
            (
                "FAIL test/a.test.ts\n\u25cf suite > case\n",
                _jest_expectations(passing={"test/a.test.ts::case"}),
                True,
            ),
            (
                "FAIL test/a.test.ts\n",
                _jest_expectations(fail={"test/a.test.ts"}),
                False,
            ),
            (
                "FAIL test/a.test.ts\n",
                _jest_expectations(passing={"test/a.test.ts"}),
                True,
            ),
            (
                "FAIL test/b.test.ts\n",
                _jest_expectations(fail={"test/a.test.ts"}),
                True,
            ),
        ],
        ids=[
            "test-expected-fail",
            "test-expected-pass",
            "file-expected-fail",
            "file-expected-pass",
            "file-unexpected",
        ],
    )
    def test_jest_expectation_matching(
        self,
        monkeypatch: MonkeyPatch,
        stdout: str,
        expectations: ResolvedTestExpectations,
        raises: bool,
    ) -> None:
        """Jest failures by test name or file honor the expectation refs."""
        _patch_run(monkeypatch, 1, stdout)

        # Route by the expected outcome: unexpected or expected-pass hits raise.
        if raises:
            with pytest.raises(qre.subprocess.CalledProcessError):
                _run_jest(expectations)
        else:
            _run_jest(expectations)
