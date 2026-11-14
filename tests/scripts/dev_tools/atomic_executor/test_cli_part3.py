"""
Tests for atomic_executor.cli module.

Tests cover CLI argument parsing, workspace resolution, precondition checks,
clipboard operations, and main execution orchestration.
"""

# pyright: reportArgumentType=false, reportUnknownLambdaType=false, reportUnknownArgumentType=false, reportPrivateUsage=false

import subprocess
from pathlib import Path
from typing import TYPE_CHECKING
from unittest.mock import Mock

import pytest

from scripts.dev_tools.atomic_executor import cli_preflight
from scripts.dev_tools.atomic_executor.cli import (
    parse_args,
)
from scripts.dev_tools.atomic_executor.pytest_expectations import (
    JestFailureSummary,
    PytestFailureSummary,
    ResolvedTestExpectations,
)
from scripts.dev_tools.atomic_executor.qc_runner_expectations import (
    TEST_SUITE_LAUNCHER_ARGV,
)
from scripts.dev_tools.atomic_executor.qc_toolchain import QCToolchain

if TYPE_CHECKING:
    from _pytest.monkeypatch import MonkeyPatch


class TestPreflightQC:
    """Tests for pre-flight QC functionality."""

    def test_preflight_qc_result_dataclass(self) -> None:
        """PreflightQCResult stores success status and output."""
        from scripts.dev_tools.atomic_executor.cli import PreflightQCResult
        from scripts.dev_tools.atomic_executor.qc_toolchain import QCToolchain

        # Success case
        result = PreflightQCResult(success=True, output="All passed")
        assert result.success is True
        assert result.output == "All passed"
        assert result.failed_step is None
        assert result.toolchain == QCToolchain.PYTHON

        # Failure case
        result = PreflightQCResult(
            success=False, output="Ruff failed", failed_step="ruff"
        )
        assert result.success is False
        assert result.output == "Ruff failed"
        assert result.failed_step == "ruff"
        assert result.toolchain == QCToolchain.PYTHON

    def test_build_preflight_qc_fix_prompt_includes_workspace(
        self,
        mem_fs_path: Path,
    ) -> None:
        """_build_preflight_qc_fix_prompt includes workspace in prompt."""
        from scripts.dev_tools.atomic_executor.cli import _build_preflight_qc_fix_prompt
        from scripts.dev_tools.atomic_executor.qc_toolchain import QCToolchain

        prompt = _build_preflight_qc_fix_prompt(
            workspace=mem_fs_path,
            qc_output="Black failed: file.py",
            toolchain=QCToolchain.PYTHON,
        )

        # Check key elements are present
        assert "Pre-flight QC Fix Required" in prompt
        assert str(mem_fs_path.as_posix()) in prompt
        assert "poetry run pytest -n auto" in prompt
        assert "Black failed: file.py" in prompt
        assert "poetry run black" in prompt
        assert "poetry run ruff" in prompt
        assert "poetry run pyright" in prompt
        assert "poetry run pytest" in prompt
        assert "Do NOT end your turn until all QC steps pass" in prompt

    def test_build_preflight_qc_fix_prompt_typescript(self) -> None:
        """_build_preflight_qc_fix_prompt uses npm commands for TypeScript."""
        from scripts.dev_tools.atomic_executor.cli import _build_preflight_qc_fix_prompt
        from scripts.dev_tools.atomic_executor.qc_toolchain import QCToolchain

        prompt = _build_preflight_qc_fix_prompt(
            workspace=Path.cwd(),
            qc_output="npm run test:unit failed",
            toolchain=QCToolchain.TYPESCRIPT,
        )

        assert "npm run format" in prompt
        assert "npm run lint" in prompt
        assert "npm run typecheck" in prompt
        assert "npm run test:unit" in prompt

    def test_run_preflight_qc_with_capture_returns_success(
        self,
        mem_fs_path: Path,
        monkeypatch: "MonkeyPatch",
    ) -> None:
        """_run_preflight_qc_with_capture returns success when all steps pass."""
        from scripts.dev_tools.atomic_executor.cli import (
            _run_preflight_qc_with_capture,
        )

        # Mock subprocess.run to always succeed
        def mock_run(
            *args: object, **kwargs: object
        ) -> subprocess.CompletedProcess[str]:
            return subprocess.CompletedProcess(
                args=args,
                returncode=0,
                stdout="OK",
                stderr="",
            )

        monkeypatch.setattr("subprocess.run", mock_run)
        monkeypatch.setattr(cli_preflight.shutil, "which", lambda name: name)

        result = _run_preflight_qc_with_capture(mem_fs_path)

        assert result.success is True
        assert result.failed_step is None
        assert "=== BLACK ===" in result.output
        assert "=== RUFF ===" in result.output
        assert "=== PYRIGHT ===" in result.output
        assert "=== PYTEST ===" in result.output

    def test_run_preflight_qc_with_capture_returns_failure(
        self,
        mem_fs_path: Path,
        monkeypatch: "MonkeyPatch",
    ) -> None:
        """_run_preflight_qc_with_capture returns failure when a step fails."""
        from scripts.dev_tools.atomic_executor.cli import (
            _run_preflight_qc_with_capture,
        )

        call_count = 0

        # Mock subprocess.run to fail on second step (ruff)
        def mock_run(
            *args: object, **kwargs: object
        ) -> subprocess.CompletedProcess[str]:
            nonlocal call_count
            call_count += 1
            if call_count == 1:  # black
                return subprocess.CompletedProcess(
                    args=args, returncode=0, stdout="Black OK", stderr=""
                )
            # ruff fails
            return subprocess.CompletedProcess(
                args=args, returncode=1, stdout="Ruff error", stderr="E501"
            )

        monkeypatch.setattr("subprocess.run", mock_run)

        result = _run_preflight_qc_with_capture(mem_fs_path)

        assert result.success is False
        assert result.failed_step == "ruff"
        assert "=== BLACK ===" in result.output
        assert "=== RUFF ===" in result.output
        assert "Ruff error" in result.output
        # Should not have pyright/pytest since ruff failed
        assert "=== PYRIGHT ===" not in result.output

    def test_run_preflight_qc_with_capture_handles_missing_executable(
        self,
        monkeypatch: "MonkeyPatch",
    ) -> None:
        """_run_preflight_qc_with_capture fails fast when an executable is missing."""
        from scripts.dev_tools.atomic_executor.cli import (
            MISSING_EXECUTABLE_PREFIX,
            _run_preflight_qc_with_capture,
        )
        from scripts.dev_tools.atomic_executor.qc_toolchain import QCToolchain

        monkeypatch.setattr("shutil.which", lambda _cmd: None)

        def _should_not_run(*args: object, **kwargs: object) -> None:
            pytest.fail("subprocess.run should not be called when executable missing")

        monkeypatch.setattr("subprocess.run", _should_not_run)

        result = _run_preflight_qc_with_capture(
            Path.cwd(), toolchain=QCToolchain.TYPESCRIPT
        )

        assert result.success is False
        assert result.failed_step == "format"
        assert MISSING_EXECUTABLE_PREFIX in result.output

    def test_skip_preflight_qc_flag_parses(self) -> None:
        """parse_args() parses --skip-preflight-qc flag."""
        args = parse_args(["execute", "feature", "--skip-preflight-qc"])
        assert args.skip_preflight_qc is True

    def test_skip_preflight_qc_flag_defaults_false(self) -> None:
        """parse_args() defaults skip_preflight_qc to False."""
        args = parse_args(["execute", "feature"])
        assert args.skip_preflight_qc is False


class TestPhaseEndQC:
    """Tests for phase-end QC behavior in the CLI."""

    def test_phase_end_expectations_passed_to_qc_runner(
        self, monkeypatch: "MonkeyPatch"
    ) -> None:
        """
        CLI should pass resolved expectations to phase-end QC.

        Purpose:
            Ensure phase completion forwards plan expectations into run_full().
        """
        from scripts.dev_tools.atomic_executor import cli
        from scripts.dev_tools.atomic_executor.plan_parser import PlanModel, PlanTask

        plan_task = PlanTask(
            task_id="P1-T1",
            phase=1,
            task_num=1,
            title="pytest tests/bugs/2026/test_issue_98.py::test_expected_fail",
            checked=True,
            line_index=0,
            expect_fail=True,
            test_ref="tests/bugs/2026/test_issue_98.py::test_expected_fail",
        )
        plan = PlanModel(tasks=[plan_task], phases=[1])

        parser = Mock()
        parser.next_unchecked_task.return_value = plan_task
        parser.find_task_by_id.return_value = plan_task
        parser.phase_complete.return_value = True
        parser.preflight_validate.return_value = None
        parser.parse.return_value = plan

        resolver = Mock()
        resolver.resolve.return_value = (Mock(), Path.cwd())
        qc_runner = Mock()

        monkeypatch.setattr(cli, "PlanParser", lambda _path: parser)
        monkeypatch.setattr(cli, "FeatureResolver", Mock(return_value=resolver))
        monkeypatch.setattr(cli, "QCRunner", Mock(return_value=qc_runner))
        monkeypatch.setattr(cli, "resolve_workspace", lambda _workspace: Path.cwd())
        monkeypatch.setattr(
            cli,
            "resolve_feature_plan",
            lambda _dir: Mock(path=Path("docs/features/active/README.md")),
        )
        monkeypatch.setattr(cli, "refuse_protected_branch", lambda _workspace: None)
        monkeypatch.setattr(cli, "execute_one_task", lambda **_kwargs: 0)

        exit_code = cli.main(["execute", "feature", "--skip-preflight-qc"])

        assert exit_code == 0
        qc_runner.run_full.assert_called_once()
        _, kwargs = qc_runner.run_full.call_args
        assert "expectations" in kwargs
        assert (
            "tests/bugs/2026/test_issue_98.py::test_expected_fail"
            in kwargs["expectations"].expected_fail_refs
        )

    def test_preflight_expected_fail_allows_known_failures(
        self,
        monkeypatch: "MonkeyPatch",
    ) -> None:
        """
        Preflight QC should allow failures covered by expected-fail refs.

        Purpose:
            Ensure expected-fail refs suppress baseline fix behavior for pytest.
        """
        from scripts.dev_tools.atomic_executor.cli import (
            _run_preflight_qc_with_capture,
        )
        from scripts.dev_tools.atomic_executor.pytest_expectations import (
            ResolvedTestExpectations,
        )

        expectations = ResolvedTestExpectations(
            expected_fail_refs={"tests/bugs/2026/test_issue_98.py::test_expected_fail"},
            expected_pass_refs=set(),
            expected_fail_jest_refs=set(),
            expected_pass_jest_refs=set(),
            missing_test_refs=[],
        )

        def mock_run(
            *args: object, **kwargs: object
        ) -> subprocess.CompletedProcess[str]:
            """Return a failing pytest run for the expected-fail nodeid."""
            cmd = args[0]
            if isinstance(cmd, list) and "pytest" in cmd and "--collect-only" in cmd:
                return subprocess.CompletedProcess(
                    args=cmd, returncode=0, stdout="collected", stderr=""
                )
            if isinstance(cmd, list) and "pytest" in cmd:
                output = (
                    "FAILED tests/bugs/2026/test_issue_98.py::"
                    "test_expected_fail - AssertionError"
                )
                return subprocess.CompletedProcess(
                    args=cmd, returncode=1, stdout=output, stderr=""
                )
            return subprocess.CompletedProcess(
                args=cmd, returncode=0, stdout="OK", stderr=""
            )

        monkeypatch.setattr("subprocess.run", mock_run)
        monkeypatch.setattr(cli_preflight.shutil, "which", lambda name: name)

        result = _run_preflight_qc_with_capture(Path.cwd(), expectations=expectations)

        assert result.success is True
        assert result.failed_step is None
        assert "expected pytest failures" in result.output.lower()

    def test_preflight_expected_fail_allows_known_jest_failures(
        self,
        monkeypatch: "MonkeyPatch",
    ) -> None:
        """
        Preflight QC should allow failures covered by expected Jest refs.

        Purpose:
            Ensure expected-fail refs suppress baseline fix behavior for Jest.
        """
        from scripts.dev_tools.atomic_executor.cli import (
            _run_preflight_qc_with_capture,
        )
        from scripts.dev_tools.atomic_executor.pytest_expectations import (
            ResolvedTestExpectations,
        )
        from scripts.dev_tools.atomic_executor.qc_toolchain import QCToolchain

        expectations = ResolvedTestExpectations(
            expected_fail_refs=set(),
            expected_pass_refs=set(),
            missing_test_refs=[],
            expected_fail_jest_refs={
                "tests/unit/task-execution-spec.test.ts::"
                "getTaskExecutionSpec returns QC black"
            },
            expected_pass_jest_refs=set(),
        )

        def mock_run(
            *args: object, **kwargs: object
        ) -> subprocess.CompletedProcess[str]:
            """Return a failing launcher jest run for the expected-fail ref."""
            cmd = args[0]
            if isinstance(cmd, list) and cmd == [*TEST_SUITE_LAUNCHER_ARGV, "jest"]:
                output = "\n".join(
                    [
                        "FAIL tests/unit/task-execution-spec.test.ts",
                        "  \u25cf getTaskExecutionSpec returns QC black",
                    ]
                )
                return subprocess.CompletedProcess(
                    args=cmd, returncode=1, stdout=output, stderr=""
                )
            return subprocess.CompletedProcess(
                args=cmd, returncode=0, stdout="OK", stderr=""
            )

        monkeypatch.setattr("subprocess.run", mock_run)
        # _resolve_executable rewrites argv[0] through shutil.which; returning the
        # argument keeps argv bare so the npm branch of mock_run is reached.
        monkeypatch.setattr(
            "scripts.dev_tools.atomic_executor.cli_preflight.shutil.which",
            lambda name: name,
        )

        result = _run_preflight_qc_with_capture(
            Path.cwd(), expectations=expectations, toolchain=QCToolchain.TYPESCRIPT
        )

        assert result.success is True
        assert result.failed_step is None
        assert "Expected Jest failures allowed" in result.output

    def test_preflight_expected_pass_wins(
        self,
        monkeypatch: "MonkeyPatch",
    ) -> None:
        """
        Expected-pass should override expected-fail for the same ref.

        Purpose:
            Ensure expected-pass entries cause the pytest gate to fail.
        """
        from scripts.dev_tools.atomic_executor.cli import (
            _run_preflight_qc_with_capture,
        )
        from scripts.dev_tools.atomic_executor.pytest_expectations import (
            ResolvedTestExpectations,
        )

        expectations = ResolvedTestExpectations(
            expected_fail_refs={"tests/bugs/2026/test_issue_98.py::test_expected_fail"},
            expected_pass_refs={"tests/bugs/2026/test_issue_98.py::test_expected_fail"},
            expected_fail_jest_refs=set(),
            expected_pass_jest_refs=set(),
            missing_test_refs=[],
        )

        def mock_run(
            *args: object, **kwargs: object
        ) -> subprocess.CompletedProcess[str]:
            """Return a failing pytest run for the expected-pass nodeid."""
            cmd = args[0]
            if isinstance(cmd, list) and "pytest" in cmd and "--collect-only" in cmd:
                return subprocess.CompletedProcess(
                    args=cmd, returncode=0, stdout="collected", stderr=""
                )
            if isinstance(cmd, list) and "pytest" in cmd:
                output = (
                    "FAILED tests/bugs/2026/test_issue_98.py::"
                    "test_expected_fail - AssertionError"
                )
                return subprocess.CompletedProcess(
                    args=cmd, returncode=1, stdout=output, stderr=""
                )
            return subprocess.CompletedProcess(
                args=cmd, returncode=0, stdout="OK", stderr=""
            )

        monkeypatch.setattr("subprocess.run", mock_run)
        monkeypatch.setattr(cli_preflight.shutil, "which", lambda name: name)

        result = _run_preflight_qc_with_capture(Path.cwd(), expectations=expectations)

        assert result.success is False
        assert result.failed_step == "pytest"
        assert "expected-pass" in result.output.lower()

    def test_preflight_missing_test_ref(
        self,
        monkeypatch: "MonkeyPatch",
    ) -> None:
        """
        Missing test refs should fail preflight before running pytest.

        Purpose:
            Provide actionable feedback when expectation tasks lack test refs.
        """
        from scripts.dev_tools.atomic_executor.cli import (
            _run_preflight_qc_with_capture,
        )
        from scripts.dev_tools.atomic_executor.pytest_expectations import (
            ResolvedTestExpectations,
        )

        expectations = ResolvedTestExpectations(
            expected_fail_refs=set(),
            expected_pass_refs=set(),
            expected_fail_jest_refs=set(),
            expected_pass_jest_refs=set(),
            missing_test_refs=["P1-T1"],
        )

        def mock_run(
            *args: object, **kwargs: object
        ) -> subprocess.CompletedProcess[str]:
            """Return success for non-pytest steps."""
            cmd = args[0]
            return subprocess.CompletedProcess(
                args=cmd, returncode=0, stdout="OK", stderr=""
            )

        monkeypatch.setattr("subprocess.run", mock_run)

        result = _run_preflight_qc_with_capture(Path.cwd(), expectations=expectations)

        assert result.success is False
        assert result.failed_step == "pytest-collect"
        assert "missing test reference" in result.output.lower()


def _expectations(
    *,
    fail: set[str] | None = None,
    passing: set[str] | None = None,
    jest_fail: set[str] | None = None,
    jest_pass: set[str] | None = None,
) -> ResolvedTestExpectations:
    """
    Build a ResolvedTestExpectations value with empty defaults.

    Args:
        fail: Pytest refs allowed to fail.
        passing: Pytest refs required to pass.
        jest_fail: Jest refs allowed to fail.
        jest_pass: Jest refs required to pass.

    Returns:
        ResolvedTestExpectations: The expectation sets with no missing refs.
    """
    return ResolvedTestExpectations(
        expected_fail_refs=fail or set(),
        expected_pass_refs=passing or set(),
        expected_fail_jest_refs=jest_fail or set(),
        expected_pass_jest_refs=jest_pass or set(),
        missing_test_refs=[],
    )


def _patch_qc_run(
    monkeypatch: "MonkeyPatch", *, failing_step: list[str], collect_code: int = 0
) -> None:
    """
    Replace PATH lookup and subprocess.run for the preflight QC steps.

    Args:
        monkeypatch: The pytest monkeypatch fixture.
        failing_step: The argv of the test step, which exits 1.
        collect_code: The exit code of the pytest collect-only step.

    Returns:
        None. Side effect: shutil.which returns its argument and subprocess.run
        returns a completed process without starting one.
    """
    monkeypatch.setattr("shutil.which", lambda cmd: cmd)

    def fake_run(*args: object, **kwargs: object) -> subprocess.CompletedProcess[str]:
        """Return exit 1 for the test step, collect_code for collection, else 0."""
        cmd = args[0]
        # Route by argv: collection, the test step under test, then every other step.
        if isinstance(cmd, list) and "--collect-only" in cmd:
            return subprocess.CompletedProcess(cmd, collect_code, "collected", "")
        if cmd == failing_step:
            return subprocess.CompletedProcess(cmd, 1, "failed", "")
        return subprocess.CompletedProcess(cmd, 0, "OK", "")

    monkeypatch.setattr("subprocess.run", fake_run)


_PYTEST_STEP = [
    *TEST_SUITE_LAUNCHER_ARGV,
    "pytest",
    "-n",
    "auto",
    "--color=no",
    "--cov=scripts/dev_tools",
    "--cov-report=term-missing",
]
_JEST_STEP = [*TEST_SUITE_LAUNCHER_ARGV, "jest"]


class TestPreflightQCBranches:
    """Tests for the preflight toolchain resolution and failure-gating branches."""

    @pytest.mark.parametrize(
        ("detected", "expected"),
        [
            ("not callable", [QCToolchain.PYTHON]),
            (lambda: ["python"], [QCToolchain.PYTHON]),
            (set, [QCToolchain.PYTHON]),
            (
                lambda: {QCToolchain.TYPESCRIPT, QCToolchain.PYTHON},
                [QCToolchain.PYTHON, QCToolchain.TYPESCRIPT],
            ),
        ],
    )
    def test_resolve_preflight_toolchains_defaults_and_orders(
        self, detected: object, expected: list[QCToolchain]
    ) -> None:
        """A non-callable, non-set, or empty detection gives Python; sets sort."""
        parser = Mock(detected_qc_toolchains=detected)

        assert cli_preflight.resolve_preflight_toolchains(parser) == expected

    def test_resolve_executable_rejects_empty_argv(self) -> None:
        """An empty argv raises ValueError before any PATH lookup."""
        with pytest.raises(ValueError, match="must not be empty"):
            cli_preflight._resolve_executable([])

    def test_unsupported_toolchain_raises(self) -> None:
        """Both the QC run and the fix prompt reject an unknown toolchain."""
        with pytest.raises(RuntimeError, match="Unsupported QC toolchain"):
            cli_preflight.run_preflight_qc_with_capture(Path.cwd(), toolchain="x")
        with pytest.raises(RuntimeError, match="Unsupported QC toolchain"):
            cli_preflight.build_preflight_qc_fix_prompt(Path.cwd(), "", toolchain="x")

    def test_collect_step_missing_executable_fails(
        self, monkeypatch: "MonkeyPatch"
    ) -> None:
        """A missing executable for the collect-only step fails pytest-collect."""
        _patch_qc_run(monkeypatch, failing_step=_PYTEST_STEP)
        lookups: list[str] = []

        def which(cmd: str) -> str | None:
            """Resolve the three static steps, then report the collector missing."""
            lookups.append(cmd)
            return cmd if len(lookups) <= 3 else None

        monkeypatch.setattr("shutil.which", which)

        result = cli_preflight.run_preflight_qc_with_capture(
            Path.cwd(), expectations=_expectations(fail={"tests/a.py::t"})
        )

        assert (result.success, result.failed_step) == (False, "pytest-collect")
        assert cli_preflight.MISSING_EXECUTABLE_PREFIX in result.output

    def test_collect_step_nonzero_exit_fails(self, monkeypatch: "MonkeyPatch") -> None:
        """A failing collect-only step stops QC before the pytest step runs."""
        _patch_qc_run(monkeypatch, failing_step=_PYTEST_STEP, collect_code=4)

        result = cli_preflight.run_preflight_qc_with_capture(
            Path.cwd(), expectations=_expectations(fail={"tests/a.py::t"})
        )

        assert (result.success, result.failed_step) == (False, "pytest-collect")

    @pytest.mark.parametrize(
        ("summary", "message"),
        [
            (PytestFailureSummary(set(), True), "collection/import errors"),
            (
                PytestFailureSummary({"tests/b.py::t"}, False),
                "Unexpected pytest failures",
            ),
        ],
    )
    def test_pytest_failures_outside_expectations_fail(
        self,
        monkeypatch: "MonkeyPatch",
        summary: PytestFailureSummary,
        message: str,
    ) -> None:
        """Collection errors and unlisted failing nodeids fail the pytest step."""
        _patch_qc_run(monkeypatch, failing_step=_PYTEST_STEP)
        monkeypatch.setattr(
            cli_preflight, "parse_pytest_failure_output", lambda _out: summary
        )

        result = cli_preflight.run_preflight_qc_with_capture(
            Path.cwd(), expectations=_expectations(fail={"tests/a.py::t"})
        )

        assert (result.success, result.failed_step) == (False, "pytest")
        assert message in result.output
        assert "Expected-pass override" not in result.output

    @pytest.mark.parametrize(
        ("tests", "files", "runtime", "success", "message"),
        [
            (set[str](), set[str](), True, False, "Jest runtime errors"),
            (set[str](), set[str](), False, False, "could not be parsed"),
            ({"alpha", "beta", "gamma"}, set[str](), False, False, "override"),
            ({"beta"}, set[str](), False, True, "Expected Jest failures allowed"),
            (set[str](), {"a.ts", "b.ts", "c.ts"}, False, False, "override"),
            (set[str](), {"b.ts"}, False, True, "Expected Jest failures allowed"),
            (set[str](), {"c.ts"}, False, False, "Unexpected Jest failures"),
        ],
    )
    def test_jest_failures_are_gated_by_expectations(
        self,
        monkeypatch: "MonkeyPatch",
        tests: set[str],
        files: set[str],
        runtime: bool,
        success: bool,
        message: str,
    ) -> None:
        """Jest failures pass only when every failing test or file is expected."""
        _patch_qc_run(monkeypatch, failing_step=_JEST_STEP)
        summary = JestFailureSummary(files, tests, runtime, 0, "")
        monkeypatch.setattr(
            cli_preflight, "parse_jest_failure_output", lambda _out: summary
        )
        expectations = _expectations(
            jest_fail={"b.ts::beta"}, jest_pass={"a.ts::alpha"}
        )

        result = cli_preflight.run_preflight_qc_with_capture(
            Path.cwd(), expectations=expectations, toolchain=QCToolchain.TYPESCRIPT
        )

        assert result.success is success
        assert message in result.output
