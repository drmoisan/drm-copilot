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

from scripts.dev_tools.atomic_executor.cli import (
    parse_args,
)

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
            """Return a failing npm test run for the expected-fail ref."""
            cmd = args[0]
            if isinstance(cmd, list) and cmd[:3] == ["npm", "run", "test:unit"]:
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

        result = _run_preflight_qc_with_capture(
            Path.cwd(), expectations=expectations, toolchain=QCToolchain.TYPESCRIPT
        )

        assert result.success is True
        assert result.failed_step is None

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
