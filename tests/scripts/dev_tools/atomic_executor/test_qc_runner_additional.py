"""Additional unit tests for `scripts.dev_tools.atomic_executor.qc_runner`.

This module increases coverage without expanding existing large test files.
All subprocess and filesystem behavior is mocked/monkeypatched.
"""

from __future__ import annotations

import subprocess
from pathlib import Path

import pytest

from scripts.dev_tools.atomic_executor import qc_runner as qc_runner_module
from scripts.dev_tools.atomic_executor.pytest_expectations import (
    JestFailureSummary,
    ResolvedTestExpectations,
)
from scripts.dev_tools.atomic_executor.qc_runner import QCRunner, QCToolResult


def _which_passthrough(cmd: str) -> str:
    """Return cmd unchanged so argv assertions stay stable across platforms."""
    return cmd


def test_resolve_executable_raises_for_empty_argv() -> None:
    """resolve_executable should reject empty argv lists."""
    runner = QCRunner(Path("/workspace"))
    with pytest.raises(ValueError, match="must not be empty"):
        runner.resolve_executable([])


def test_resolve_executable_raises_when_exe_missing(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """resolve_executable should raise when PATH lookup fails."""
    runner = QCRunner(Path("/workspace"))

    def fake_which(_cmd: str) -> str | None:
        return None

    monkeypatch.setattr(
        "scripts.dev_tools.atomic_executor.qc_runner.shutil.which", fake_which
    )
    with pytest.raises(FileNotFoundError, match="Required executable not found"):
        runner.resolve_executable(["definitely-not-a-command"])


def test_merge_env_returns_none_when_no_overrides() -> None:
    """_merge_env should return None when extra_env is empty or None."""
    runner = QCRunner(Path("/workspace"))
    assert runner._merge_env(None) is None  # pyright: ignore[reportPrivateUsage]
    assert runner._merge_env({}) is None  # pyright: ignore[reportPrivateUsage]


def test_merge_env_includes_overrides(monkeypatch: pytest.MonkeyPatch) -> None:
    """_merge_env should merge overrides into the environment."""
    runner = QCRunner(Path("/workspace"))
    monkeypatch.setenv("BASE", "1")

    env = runner._merge_env({"EXTRA": "2"})  # pyright: ignore[reportPrivateUsage]

    assert env is not None
    assert env["BASE"] == "1"
    assert env["EXTRA"] == "2"


def test_run_passes_errors_none_when_text_false(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """_run should pass errors=None when text=False to subprocess.run."""
    runner = QCRunner(Path("/workspace"))

    captured: dict[str, object] = {}

    def fake_run(
        argv: list[str],
        *,
        cwd: Path,
        check: bool,
        capture_output: bool,
        text: bool,
        errors: str | None,
        env: dict[str, str] | None,
    ) -> subprocess.CompletedProcess[str]:
        captured["errors"] = errors
        return subprocess.CompletedProcess(argv, 0, "", "")

    monkeypatch.setattr(
        "scripts.dev_tools.atomic_executor.qc_runner.shutil.which", _which_passthrough
    )
    monkeypatch.setattr(
        "scripts.dev_tools.atomic_executor.qc_runner.subprocess.run", fake_run
    )

    _ = runner._run(["echo", "hi"], text=False)  # pyright: ignore[reportPrivateUsage]

    assert captured["errors"] is None


def test_run_and_record_writes_header_and_output_without_touching_disk(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """_run_and_record should format output content and return QCToolResult."""
    runner = QCRunner(Path("/workspace"))

    written: dict[str, str] = {}

    def fake_mkdir(self: Path, *args: object, **kwargs: object) -> None:
        return None

    def fake_write_text(self: Path, text: str, *, encoding: str) -> int:
        written[self.as_posix()] = text
        return len(text)

    def fake_run(
        argv: list[str],
        *,
        cwd: Path,
        check: bool,
        capture_output: bool,
        text: bool,
        errors: str,
        env: dict[str, str] | None,
    ) -> subprocess.CompletedProcess[str]:
        return subprocess.CompletedProcess(argv, 2, "stdout", "stderr")

    monkeypatch.setattr(Path, "mkdir", fake_mkdir)
    monkeypatch.setattr(Path, "write_text", fake_write_text)
    monkeypatch.setattr(
        "scripts.dev_tools.atomic_executor.qc_runner.shutil.which", _which_passthrough
    )
    monkeypatch.setattr(
        "scripts.dev_tools.atomic_executor.qc_runner.subprocess.run", fake_run
    )

    out_path = Path("/workspace/artifacts/step.txt")
    result = runner._run_and_record(  # pyright: ignore[reportPrivateUsage]
        argv=["poetry", "run", "ruff", "check"],
        output_path=out_path,
    )

    assert isinstance(result, QCToolResult)
    assert result.returncode == 2
    assert "stdout" in result.output
    assert "stderr" in result.output
    assert out_path.as_posix() in written
    assert written[out_path.as_posix()].startswith("$ poetry run ruff check")


def test_diff_signature_normalizes_renamed_paths(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """_diff_signature should reduce rename paths to the final file path."""
    runner = QCRunner(Path("/workspace"))

    def fake_run(
        argv: list[str],
        *,
        capture_output: bool,
        text: bool,
        errors: str | None,
    ) -> subprocess.CompletedProcess[str]:
        return subprocess.CompletedProcess(
            argv,
            0,
            "1\t0\tfoo => bar\n2\t3\tsrc/x.py\n",
            "",
        )

    monkeypatch.setattr(runner, "_run", fake_run)

    sig = runner._diff_signature()  # pyright: ignore[reportPrivateUsage]

    assert ("bar", "1", "0") in sig
    assert ("src/x.py", "2", "3") in sig


def test_normalize_excluded_paths_keeps_unrelated_paths(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """_normalize_excluded_paths should retain paths outside the workspace."""
    runner = QCRunner(Path("/workspace"))

    excluded = runner._normalize_excluded_paths(  # pyright: ignore[reportPrivateUsage]
        [Path("/other/outside.txt")]
    )

    assert "/other/outside.txt" in excluded


def test_run_scoped_invokes_jest_when_only_ts_tests_changed(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """run_scoped should route TypeScript test changes to Jest."""
    runner = QCRunner(Path("/workspace"))

    monkeypatch.setattr(runner, "changed_files", lambda: ["tests/unit/a.test.ts"])

    called: dict[str, object] = {}

    def fake_jest_scoped(*, test_files: list[str], expectations: object) -> None:
        called["test_files"] = test_files

    monkeypatch.setattr(runner, "_run_jest_scoped_with_expectations", fake_jest_scoped)

    runner.run_scoped()

    assert called["test_files"] == ["tests/unit/a.test.ts"]


def test_run_pytest_with_expectations_raises_on_collection_error(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """Collection errors should always raise, even if expectations exist."""
    runner = QCRunner(Path("/workspace"))

    expectations = ResolvedTestExpectations(
        expected_fail_refs={"tests/x.py::test_a"},
        expected_pass_refs=set(),
        expected_fail_jest_refs=set(),
        expected_pass_jest_refs=set(),
        missing_test_refs=[],
    )

    def fake_run(
        argv: list[str],
        *,
        cwd: Path,
        check: bool,
        capture_output: bool,
        text: bool,
        errors: str,
        env: dict[str, str] | None,
    ) -> subprocess.CompletedProcess[str]:
        return subprocess.CompletedProcess(
            argv,
            2,
            "ERROR collecting tests/x.py\n",
            "",
        )

    monkeypatch.setattr(
        "scripts.dev_tools.atomic_executor.qc_runner.subprocess.run", fake_run
    )

    with pytest.raises(subprocess.CalledProcessError):
        runner._run_pytest_with_expectations(  # pyright: ignore[reportPrivateUsage]
            expectations
        )


def test_run_pytest_with_expectations_raises_when_expected_pass_fails(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """If an expected-pass ref fails, the QC gate must fail."""
    runner = QCRunner(Path("/workspace"))

    expectations = ResolvedTestExpectations(
        expected_fail_refs=set(),
        expected_pass_refs={"tests/x.py::test_a"},
        expected_fail_jest_refs=set(),
        expected_pass_jest_refs=set(),
        missing_test_refs=[],
    )

    def fake_run(
        argv: list[str],
        *,
        cwd: Path,
        check: bool,
        capture_output: bool,
        text: bool,
        errors: str,
        env: dict[str, str] | None,
    ) -> subprocess.CompletedProcess[str]:
        return subprocess.CompletedProcess(
            argv,
            1,
            "FAILED tests/x.py::test_a - AssertionError\n",
            "",
        )

    monkeypatch.setattr(
        "scripts.dev_tools.atomic_executor.qc_runner.subprocess.run", fake_run
    )

    with pytest.raises(subprocess.CalledProcessError):
        runner._run_pytest_with_expectations(  # pyright: ignore[reportPrivateUsage]
            expectations
        )


def test_check_jest_skipped_tests_parses_skipped_count(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """check_jest_skipped_tests should parse skipped count from summary."""
    runner = QCRunner(Path("/workspace"))

    def fake_which(_cmd: str) -> str | None:
        return "/usr/bin/npm"

    monkeypatch.setattr(
        "scripts.dev_tools.atomic_executor.qc_runner.shutil.which", fake_which
    )

    def fake_run(
        argv: list[str],
        *,
        cwd: Path,
        check: bool,
        capture_output: bool,
        text: bool,
        errors: str,
    ) -> subprocess.CompletedProcess[str]:
        output = "Tests: 2 skipped, 4 passed, 6 total\n"
        return subprocess.CompletedProcess(argv, 1, output, "")

    monkeypatch.setattr(
        "scripts.dev_tools.atomic_executor.qc_runner.subprocess.run", fake_run
    )

    summary = runner.check_jest_skipped_tests(test_files=["tests/unit/a.test.ts"])

    assert isinstance(summary, JestFailureSummary)
    assert summary.skipped_count == 2


def test_check_jest_skipped_tests_raises_when_executable_missing(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """Executable lookup should raise a clear error when npm is missing."""
    runner = QCRunner(Path("/workspace"))

    def fake_which(_cmd: str) -> str | None:
        return None

    monkeypatch.setattr(
        "scripts.dev_tools.atomic_executor.qc_runner.shutil.which", fake_which
    )

    with pytest.raises(FileNotFoundError, match="Required executable not found"):
        runner.check_jest_skipped_tests()


def test_run_jest_with_expectations_allows_expected_fail_by_test_name(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """Expected Jest test-name failures should be allowed."""
    runner = QCRunner(Path("/workspace"))

    expectations = ResolvedTestExpectations(
        expected_fail_refs=set(),
        expected_pass_refs=set(),
        expected_fail_jest_refs={"tests/unit/a.test.ts::my test"},
        expected_pass_jest_refs=set(),
        missing_test_refs=[],
    )

    output = "\n".join(
        [
            "FAIL tests/unit/a.test.ts",
            "  \u25cf my test should fail",
        ]
    )

    def fake_run(*args: object, **kwargs: object) -> None:
        raise subprocess.CalledProcessError(
            1, ["npm", "run", "test:unit"], output=output, stderr=""
        )

    monkeypatch.setattr(runner, "_run", fake_run)

    # Should not raise because the failure matches expected_fail_jest_refs.
    runner._run_jest_with_expectations(  # pyright: ignore[reportPrivateUsage]
        cmd=["npm", "run", "test:unit"],
        expectations=expectations,
    )


def test_run_jest_with_expectations_raises_on_runtime_error(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """Runtime errors should always fail the QC gate."""
    runner = QCRunner(Path("/workspace"))

    expectations = ResolvedTestExpectations(
        expected_fail_refs=set(),
        expected_pass_refs=set(),
        expected_fail_jest_refs={"tests/unit/a.test.ts::my test"},
        expected_pass_jest_refs=set(),
        missing_test_refs=[],
    )

    output = "\n".join(
        [
            "FAIL tests/unit/a.test.ts",
            "Test suite failed to run",
        ]
    )

    def fake_run(*args: object, **kwargs: object) -> None:
        raise subprocess.CalledProcessError(
            1, ["npm", "run", "test:unit"], output=output, stderr=""
        )

    monkeypatch.setattr(runner, "_run", fake_run)

    with pytest.raises(subprocess.CalledProcessError):
        runner._run_jest_with_expectations(  # pyright: ignore[reportPrivateUsage]
            cmd=["npm", "run", "test:unit"],
            expectations=expectations,
        )


def test_expected_ref_match_helpers() -> None:
    """Helper matchers should perform prefix/substr/file matching."""
    assert (
        qc_runner_module._matches_expected_ref(  # pyright: ignore[reportPrivateUsage]
            "tests/x.py::test_a[param]",
            {"tests/x.py::test_a"},
        )
    )

    assert qc_runner_module._jest_test_matches_expected(  # pyright: ignore[reportPrivateUsage]
        "my test should fail",
        {"tests/unit/a.test.ts::my test"},
    )

    assert qc_runner_module._jest_file_matches_expected(  # pyright: ignore[reportPrivateUsage]
        "tests/unit/a.test.ts",
        {"tests/unit/a.test.ts::my test"},
    )
