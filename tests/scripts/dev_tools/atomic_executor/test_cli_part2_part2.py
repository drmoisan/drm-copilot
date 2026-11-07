"""
Tests for atomic_executor.cli module.

Tests cover CLI argument parsing, workspace resolution, precondition checks,
clipboard operations, and main execution orchestration.
"""

# pyright: reportArgumentType=false, reportUnknownLambdaType=false, reportUnknownArgumentType=false, reportPrivateUsage=false

import os
import subprocess
from pathlib import Path
from typing import TYPE_CHECKING
from unittest.mock import Mock

import pytest

if TYPE_CHECKING:
    from _pytest.monkeypatch import MonkeyPatch

    from scripts.dev_tools.atomic_executor.cli_preflight import PreflightQCResult
    from scripts.dev_tools.atomic_executor.pytest_expectations import (
        ResolvedTestExpectations,
    )


class TestMainEdgeCases:
    """Edge case tests for main execution flow."""

    def test_main_successful_execution_with_scoped_qc(
        self,
        mem_fs_path: Path,
        monkeypatch: "MonkeyPatch",
        capsys: pytest.CaptureFixture[str],
    ) -> None:
        """main() successfully executes task with scoped QC."""
        from scripts.dev_tools.atomic_executor.cli import main

        monkeypatch.setenv("XDG_CONFIG_HOME", str(mem_fs_path / "config-root"))

        # Setup feature folder
        feature_dir = mem_fs_path / "docs" / "features" / "active" / "my-feature"
        feature_dir.mkdir(parents=True)
        plan_file = feature_dir / "plan.md"
        plan_file.write_text(
            "# Phase 0\n- [ ] [P0-T1] Task 1\n\n"
            "# Phase 2 (QA/Toolchain)\n"
            "- [ ] [P2-T1] Black\n"
            "- [ ] [P2-T2] Ruff\n"
            "- [ ] [P2-T3] Pyright\n"
            "- [ ] [P2-T4] Pytest",
            encoding="utf-8",
        )
        (feature_dir / "spec.md").write_text("# Spec\n", encoding="utf-8")

        template_dir = mem_fs_path / ".github" / "prompts"
        template_dir.mkdir(parents=True)
        (template_dir / "execute-plan-template.md").write_text(
            "Task: {{task_id}}\n", encoding="utf-8"
        )

        # Setup fake copilot on PATH for run_copilot
        bin_dir = mem_fs_path / "bin"
        bin_dir.mkdir()
        copilot_exe = bin_dir / "copilot"
        copilot_exe.touch()
        copilot_exe.chmod(0o755)  # Make executable-ish
        path = os.environ.get("PATH", "")
        monkeypatch.setenv("PATH", f"{str(bin_dir)}{os.pathsep}{path}")

        # Track subprocess calls
        subprocess_calls: list[list[str]] = []

        def mock_run(
            argv: list[str], *args: object, **kwargs: object
        ) -> subprocess.CompletedProcess[str]:
            subprocess_calls.append(argv)
            result = Mock()
            result.stdout = ""
            result.returncode = 0
            return result  # type: ignore[return-value]

        class MockStdout:
            def read(self, size: int = -1) -> bytes:
                return b""

        class MockPopen:
            def __init__(
                self, argv: list[str], *args: object, **kwargs: object
            ) -> None:
                subprocess_calls.append(argv)
                self.stdout = MockStdout()
                self.returncode = 0

            def poll(self) -> int:
                return 0

            def wait(self) -> int:
                return 0

        monkeypatch.setattr("subprocess.run", mock_run)
        monkeypatch.setattr("subprocess.Popen", MockPopen)
        monkeypatch.setattr("shutil.which", lambda x: f"/usr/bin/{x}")

        # Mock QCRunner methods to succeed
        from scripts.dev_tools.atomic_executor.qc_runner import QCRunner

        monkeypatch.setattr(
            QCRunner,
            "run_scoped",
            lambda self, expectations=None: None,  # Accept expectations param
        )

        exit_code = main(
            [
                "execute",
                str(feature_dir),
                "--workspace",
                str(mem_fs_path),
                "--skip-preflight-qc",
            ]
        )

        assert exit_code == 0
        captured = capsys.readouterr()
        assert "complete and gated" in captured.out.lower()

        # Verify copilot was invoked
        copilot_calls = [c for c in subprocess_calls if "copilot" in c[0]]
        assert len(copilot_calls) == 1


def _preflight_expectations(
    *,
    expected_fail: set[str] | None = None,
    expected_pass: set[str] | None = None,
    expected_fail_jest: set[str] | None = None,
    expected_pass_jest: set[str] | None = None,
) -> "ResolvedTestExpectations":
    """Build a ResolvedTestExpectations with empty defaults for unnamed sets."""
    from scripts.dev_tools.atomic_executor.pytest_expectations import (
        ResolvedTestExpectations,
    )

    return ResolvedTestExpectations(
        expected_fail_refs=expected_fail or set(),
        expected_pass_refs=expected_pass or set(),
        expected_fail_jest_refs=expected_fail_jest or set(),
        expected_pass_jest_refs=expected_pass_jest or set(),
        missing_test_refs=[],
    )


def _install_preflight_stubs(
    monkeypatch: "MonkeyPatch",
    *,
    collect: tuple[int, str] = (0, "collected"),
    test: tuple[int, str] = (0, "OK"),
) -> list[list[str]]:
    """Stub PATH lookup and subprocess.run for cli_preflight; return recorded argv.

    ``shutil.which`` returns its argument, so argv stays bare and no case depends
    on the runner's PATH. The ``subprocess.run`` stub routes on ``--collect-only``
    and on the unit-test step of either toolchain.
    """
    calls: list[list[str]] = []

    def fake_run(argv: list[str], **kwargs: object) -> subprocess.CompletedProcess[str]:
        """Record the argv and return the configured result for its step."""
        calls.append(list(argv))
        # Route the collect step, the unit-test step of either toolchain, and
        # every static step to their configured results.
        if "--collect-only" in argv:
            code, out = collect
        elif "test:unit" in argv or ("pytest" in argv and "-n" in argv):
            code, out = test
        else:
            code, out = 0, "OK"
        return subprocess.CompletedProcess(
            args=argv, returncode=code, stdout=out, stderr=""
        )

    monkeypatch.setattr(
        "scripts.dev_tools.atomic_executor.cli_preflight.shutil.which",
        lambda name: name,
    )
    monkeypatch.setattr(
        "scripts.dev_tools.atomic_executor.cli_preflight.subprocess.run", fake_run
    )
    return calls


def _run_jest_preflight(
    monkeypatch: "MonkeyPatch", output: str, **expectations: set[str]
) -> "PreflightQCResult":
    """Run the TypeScript preflight with a failing unit-test step."""
    from scripts.dev_tools.atomic_executor.cli_preflight import (
        run_preflight_qc_with_capture,
    )
    from scripts.dev_tools.atomic_executor.qc_toolchain import QCToolchain

    _install_preflight_stubs(monkeypatch, test=(1, output))
    return run_preflight_qc_with_capture(
        Path("/workspace"),
        expectations=_preflight_expectations(**expectations),
        toolchain=QCToolchain.TYPESCRIPT,
    )


class TestPreflightBranches:
    """Branch tests for cli_preflight with stubbed subprocess and PATH lookup."""

    @pytest.mark.parametrize(
        "parser",
        [
            object(),
            Mock(detected_qc_toolchains=lambda: ["python"]),
            Mock(detected_qc_toolchains=lambda: set()),
        ],
        ids=["no-detector", "non-set-result", "empty-set"],
    )
    def test_toolchains_default_to_python_without_a_detector(
        self, parser: object
    ) -> None:
        """resolve_preflight_toolchains falls back to Python without a detector."""
        from scripts.dev_tools.atomic_executor.cli_preflight import (
            resolve_preflight_toolchains,
        )
        from scripts.dev_tools.atomic_executor.qc_toolchain import QCToolchain

        assert resolve_preflight_toolchains(parser) == [QCToolchain.PYTHON]

    def test_detected_toolchains_order_python_first(self) -> None:
        """Detected toolchains are returned with Python before TypeScript."""
        from scripts.dev_tools.atomic_executor.cli_preflight import (
            resolve_preflight_toolchains,
        )
        from scripts.dev_tools.atomic_executor.qc_toolchain import QCToolchain

        parser = Mock(
            detected_qc_toolchains=lambda: {QCToolchain.TYPESCRIPT, QCToolchain.PYTHON}
        )

        assert resolve_preflight_toolchains(parser) == [
            QCToolchain.PYTHON,
            QCToolchain.TYPESCRIPT,
        ]

    def test_resolve_executable_rejects_empty_argv(self) -> None:
        """_resolve_executable raises ValueError for an empty argv."""
        from scripts.dev_tools.atomic_executor.cli_preflight import _resolve_executable

        with pytest.raises(ValueError, match="must not be empty"):
            _resolve_executable([])

    def test_capture_rejects_unsupported_toolchain(self) -> None:
        """run_preflight_qc_with_capture raises for a toolchain it does not know."""
        from scripts.dev_tools.atomic_executor.cli_preflight import (
            run_preflight_qc_with_capture,
        )

        with pytest.raises(RuntimeError, match="Unsupported QC toolchain"):
            run_preflight_qc_with_capture(Path("/workspace"), toolchain="bogus")

    def test_pytest_collect_missing_executable_fails_collect_step(
        self, monkeypatch: "MonkeyPatch"
    ) -> None:
        """A missing executable for the collect command fails pytest-collect."""
        from scripts.dev_tools.atomic_executor import cli_preflight

        def fake_resolve(argv: list[str]) -> list[str]:
            """Fail PATH resolution for the collect command only."""
            if "--collect-only" in argv:
                raise FileNotFoundError("Required executable not found on PATH: x")
            return argv

        _install_preflight_stubs(monkeypatch)
        monkeypatch.setattr(cli_preflight, "_resolve_executable", fake_resolve)

        result = cli_preflight.run_preflight_qc_with_capture(
            Path("/workspace"),
            expectations=_preflight_expectations(expected_fail={"tests/a.py::t"}),
        )

        assert result.success is False
        assert result.failed_step == "pytest-collect"
        assert "Required executable not found" in result.output

    def test_pytest_collect_failure_stops_before_pytest(
        self, monkeypatch: "MonkeyPatch"
    ) -> None:
        """A failing collect run stops before the pytest step runs."""
        from scripts.dev_tools.atomic_executor.cli_preflight import (
            run_preflight_qc_with_capture,
        )

        calls = _install_preflight_stubs(monkeypatch, collect=(4, "no tests ran"))

        result = run_preflight_qc_with_capture(
            Path("/workspace"),
            expectations=_preflight_expectations(expected_fail={"tests/a.py::t"}),
        )

        assert result.failed_step == "pytest-collect"
        # Only the pytest step carries -n, so no recorded argv may hold it.
        assert not any("-n" in argv for argv in calls)

    def test_pytest_collection_error_fails_step(
        self, monkeypatch: "MonkeyPatch"
    ) -> None:
        """A collection error in the pytest output fails the pytest step."""
        from scripts.dev_tools.atomic_executor.cli_preflight import (
            run_preflight_qc_with_capture,
        )

        _install_preflight_stubs(monkeypatch, test=(2, "ERROR collecting tests/a.py"))

        result = run_preflight_qc_with_capture(
            Path("/workspace"),
            expectations=_preflight_expectations(expected_fail={"tests/a.py::t"}),
        )

        assert result.failed_step == "pytest"
        assert "collection/import errors detected" in result.output

    def test_pytest_unmatched_failure_fails_without_override_note(
        self, monkeypatch: "MonkeyPatch"
    ) -> None:
        """An unexpected pytest failure fails the step with no override note."""
        from scripts.dev_tools.atomic_executor.cli_preflight import (
            run_preflight_qc_with_capture,
        )

        _install_preflight_stubs(monkeypatch, test=(1, "FAILED tests/b.py::other - x"))

        result = run_preflight_qc_with_capture(
            Path("/workspace"),
            expectations=_preflight_expectations(expected_fail={"tests/a.py::t"}),
        )

        assert result.failed_step == "pytest"
        assert "Unexpected pytest failures detected." in result.output
        assert "Expected-pass override" not in result.output

    def test_jest_runtime_error_fails_step(self, monkeypatch: "MonkeyPatch") -> None:
        """A Jest suite that failed to run fails the unit-test step."""
        result = _run_jest_preflight(
            monkeypatch, "Test suite failed to run", expected_fail_jest={"a.ts::x"}
        )

        assert result.failed_step == "test-unit"
        assert "Jest runtime errors detected" in result.output

    def test_jest_unparsed_failure_fails_step(self, monkeypatch: "MonkeyPatch") -> None:
        """A Jest failure with no parsable test or file fails the step."""
        result = _run_jest_preflight(
            monkeypatch, "exit code 1", expected_fail_jest={"a.ts::x"}
        )

        assert result.failed_step == "test-unit"
        assert "could not be parsed" in result.output

    def test_jest_expected_pass_test_name_fails_step(
        self, monkeypatch: "MonkeyPatch"
    ) -> None:
        """A failing test named by an expected-pass ref fails with the override note."""
        result = _run_jest_preflight(
            monkeypatch,
            "● suite renders the title",
            expected_pass_jest={"a.ts::renders the title"},
        )

        assert result.failed_step == "test-unit"
        assert "override applied to: suite renders the title" in result.output

    def test_jest_unmatched_test_name_fails_step(
        self, monkeypatch: "MonkeyPatch"
    ) -> None:
        """A failing test that no ref names fails without the override note."""
        result = _run_jest_preflight(
            monkeypatch,
            "● suite renders the footer",
            expected_fail_jest={"a.ts::renders the title"},
        )

        assert result.failed_step == "test-unit"
        assert "Unexpected Jest failures detected." in result.output
        assert "Expected-pass override" not in result.output

    def test_jest_expected_fail_file_is_allowed(
        self, monkeypatch: "MonkeyPatch"
    ) -> None:
        """A failing file named by an expected-fail ref is allowed."""
        result = _run_jest_preflight(
            monkeypatch,
            "FAIL tests/unit/a.test.ts",
            expected_fail_jest={"tests/unit/a.test.ts::anything"},
        )

        assert result.success is True
        assert "Expected Jest failures allowed: tests/unit/a.test.ts" in result.output

    def test_jest_expected_pass_file_fails_step(
        self, monkeypatch: "MonkeyPatch"
    ) -> None:
        """A failing file named by an expected-pass ref fails with the override note."""
        result = _run_jest_preflight(
            monkeypatch,
            "FAIL tests/unit/a.test.ts",
            expected_pass_jest={"tests/unit/a.test.ts::anything"},
        )

        assert result.failed_step == "test-unit"
        assert "override applied to: tests/unit/a.test.ts" in result.output

    def test_jest_unmatched_file_fails_step(self, monkeypatch: "MonkeyPatch") -> None:
        """A failing file that no ref names fails the step."""
        result = _run_jest_preflight(
            monkeypatch,
            "FAIL tests/unit/b.test.ts",
            expected_fail_jest={"tests/unit/a.test.ts::anything"},
        )

        assert result.failed_step == "test-unit"
        assert "Unexpected Jest failures detected." in result.output

    def test_fix_prompt_rejects_unsupported_toolchain(self) -> None:
        """build_preflight_qc_fix_prompt raises for a toolchain it does not know."""
        from scripts.dev_tools.atomic_executor.cli_preflight import (
            build_preflight_qc_fix_prompt,
        )

        with pytest.raises(RuntimeError, match="Unsupported QC toolchain"):
            build_preflight_qc_fix_prompt(Path("/workspace"), "out", toolchain="bogus")
