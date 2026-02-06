"""Additional unit tests for `scripts.dev_tools.atomic_executor.qc_runner`.

Purpose:
    Drive coverage for branches that are hard to hit via the normal public
    entry points (expectation filtering, toolchain routing, and small helpers).

Constraints:
    - No external processes: subprocess calls are monkeypatched.
    - No filesystem I/O: artifact writing is bypassed by patching `_run_and_record`.
"""

from __future__ import annotations

import subprocess
from pathlib import Path
from typing import cast

import pytest  # noqa: TCH002 - pytest required at runtime for fixtures

from scripts.dev_tools.atomic_executor.pytest_expectations import (
    ResolvedTestExpectations,
)
from scripts.dev_tools.atomic_executor.qc_runner import (
    QCRunner,
    QCToolchain,
    QCToolResult,
)


def _cp(
    argv: list[str],
    *,
    returncode: int,
    stdout: str = "",
    stderr: str = "",
) -> subprocess.CompletedProcess[str]:
    """Create a simple CompletedProcess for subprocess.run monkeypatching."""
    return subprocess.CompletedProcess(
        args=argv, returncode=returncode, stdout=stdout, stderr=stderr
    )


def test_run_full_raises_for_unsupported_toolchain() -> None:
    """run_full should raise when toolchain is not a supported enum value."""
    runner = QCRunner(Path("/workspace"))

    with pytest.raises(RuntimeError, match="Unsupported QC toolchain"):
        runner.run_full(toolchain=cast(QCToolchain, object()))


def test_run_pytest_with_expectations_raises_on_missing_test_refs() -> None:
    """missing_test_refs should always fail fast with a clear RuntimeError."""
    runner = QCRunner(Path("/workspace"))

    expectations = ResolvedTestExpectations(
        expected_fail_refs=set(),
        expected_pass_refs=set(),
        expected_fail_jest_refs=set(),
        expected_pass_jest_refs=set(),
        missing_test_refs=["P1-T1"],
    )

    # Access the protected helper via a local to keep the Pyright ignore comment
    # attached to the protected attribute access.
    run_pytest_with_expectations = (
        runner._run_pytest_with_expectations  # pyright: ignore[reportPrivateUsage]
    )

    with pytest.raises(RuntimeError, match="Missing test reference"):
        run_pytest_with_expectations(expectations)


def test_run_pytest_with_expectations_returns_when_tests_pass(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """When pytest succeeds, expectation filtering should return without raising."""
    runner = QCRunner(Path("/workspace"))

    expectations = ResolvedTestExpectations(
        expected_fail_refs={"tests/x.py::test_a"},
        expected_pass_refs=set(),
        expected_fail_jest_refs=set(),
        expected_pass_jest_refs=set(),
        missing_test_refs=[],
    )

    def fake_run(*args: object, **kwargs: object) -> subprocess.CompletedProcess[str]:
        _ = args
        _ = kwargs
        return _cp(["poetry", "run", "pytest"], returncode=0, stdout="", stderr="")

    monkeypatch.setattr(
        "scripts.dev_tools.atomic_executor.qc_runner.subprocess.run", fake_run
    )

    run_pytest_with_expectations = (
        runner._run_pytest_with_expectations  # pyright: ignore[reportPrivateUsage]
    )

    run_pytest_with_expectations(expectations)


def test_run_pytest_scoped_raises_on_missing_test_refs() -> None:
    """Fail fast when the plan has expect-fail tags but no test refs.

    This is a guardrail: expectation filtering can only work when the plan
    provides a reference to the test that is expected to fail.
    """
    runner = QCRunner(Path("/workspace"))

    expectations = ResolvedTestExpectations(
        expected_fail_refs=set(),
        expected_pass_refs=set(),
        expected_fail_jest_refs=set(),
        expected_pass_jest_refs=set(),
        missing_test_refs=["P1-T2"],
    )

    with pytest.raises(RuntimeError, match="Missing test reference"):
        runner._run_pytest_scoped_with_expectations(  # pyright: ignore[reportPrivateUsage]
            test_files=["tests/x.py"],
            expectations=expectations,
        )


def test_run_pytest_scoped_returns_when_tests_pass(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """Scoped pytest should return without raising when subprocess succeeds."""
    runner = QCRunner(Path("/workspace"))

    expectations = ResolvedTestExpectations(
        expected_fail_refs=set(),
        expected_pass_refs=set(),
        expected_fail_jest_refs=set(),
        expected_pass_jest_refs=set(),
        missing_test_refs=[],
    )

    def fake_run(*args: object, **kwargs: object) -> subprocess.CompletedProcess[str]:
        _ = args
        _ = kwargs
        return _cp(["poetry", "run", "pytest"], returncode=0)

    monkeypatch.setattr(
        "scripts.dev_tools.atomic_executor.qc_runner.subprocess.run", fake_run
    )

    runner._run_pytest_scoped_with_expectations(  # pyright: ignore[reportPrivateUsage]
        test_files=["tests/x.py"],
        expectations=expectations,
    )


def test_run_jest_with_expectations_raises_on_missing_test_refs() -> None:
    """missing_test_refs should fail fast for Jest as well."""
    runner = QCRunner(Path("/workspace"))

    expectations = ResolvedTestExpectations(
        expected_fail_refs=set(),
        expected_pass_refs=set(),
        expected_fail_jest_refs=set(),
        expected_pass_jest_refs=set(),
        missing_test_refs=["P2-T1"],
    )

    with pytest.raises(RuntimeError, match="Missing test reference"):
        runner._run_jest_with_expectations(  # pyright: ignore[reportPrivateUsage]
            cmd=["npm", "run", "test:unit"],
            expectations=expectations,
        )


def test_run_jest_with_expectations_returns_on_success(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """When Jest succeeds, the expectation wrapper should return cleanly."""
    runner = QCRunner(Path("/workspace"))

    expectations = ResolvedTestExpectations(
        expected_fail_refs=set(),
        expected_pass_refs=set(),
        expected_fail_jest_refs=set(),
        expected_pass_jest_refs=set(),
        missing_test_refs=[],
    )

    called: dict[str, object] = {}

    def fake_run(cmd: list[str], *, capture_output: bool = False, **_: object) -> None:
        called["cmd"] = cmd
        called["capture_output"] = capture_output
        return None

    monkeypatch.setattr(runner, "_run", fake_run)

    runner._run_jest_with_expectations(  # pyright: ignore[reportPrivateUsage]
        cmd=["npm", "run", "test:unit"],
        expectations=expectations,
    )

    assert called["capture_output"] is True


def test_run_jest_with_expectations_raises_when_output_has_no_fail_markers(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """If Jest output cannot be parsed, failures should not be silently allowed."""
    runner = QCRunner(Path("/workspace"))

    expectations = ResolvedTestExpectations(
        expected_fail_refs=set(),
        expected_pass_refs=set(),
        expected_fail_jest_refs=set(),
        expected_pass_jest_refs=set(),
        missing_test_refs=[],
    )

    def fake_run(*_: object, **__: object) -> None:
        raise subprocess.CalledProcessError(1, ["npm"], output="some error", stderr="")

    monkeypatch.setattr(runner, "_run", fake_run)

    with pytest.raises(subprocess.CalledProcessError):
        runner._run_jest_with_expectations(  # pyright: ignore[reportPrivateUsage]
            cmd=["npm", "run", "test:unit"],
            expectations=expectations,
        )


def test_run_jest_with_expectations_fails_when_expected_pass_test_fails(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """Expected-pass Jest refs should cause the QC gate to fail if hit."""
    runner = QCRunner(Path("/workspace"))

    expectations = ResolvedTestExpectations(
        expected_fail_refs=set(),
        expected_pass_refs=set(),
        expected_fail_jest_refs=set(),
        expected_pass_jest_refs={"tests/unit/a.test.ts::my test"},
        missing_test_refs=[],
    )

    output = "\n".join(
        [
            "FAIL tests/unit/a.test.ts",
            "  \u25cf my test should fail",
        ]
    )

    def fake_run(*_: object, **__: object) -> None:
        raise subprocess.CalledProcessError(1, ["npm"], output=output, stderr="")

    monkeypatch.setattr(runner, "_run", fake_run)

    with pytest.raises(subprocess.CalledProcessError):
        runner._run_jest_with_expectations(  # pyright: ignore[reportPrivateUsage]
            cmd=["npm", "run", "test:unit"],
            expectations=expectations,
        )


def test_run_jest_with_expectations_allows_expected_fail_by_file_path(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """File-level expected-fail refs should be allowed when Jest lacks test names."""
    runner = QCRunner(Path("/workspace"))

    expectations = ResolvedTestExpectations(
        expected_fail_refs=set(),
        expected_pass_refs=set(),
        expected_fail_jest_refs={"tests/unit/a.test.ts"},
        expected_pass_jest_refs=set(),
        missing_test_refs=[],
    )

    output = "FAIL tests/unit/a.test.ts\n"

    def fake_run(*_: object, **__: object) -> None:
        raise subprocess.CalledProcessError(1, ["npm"], output=output, stderr="")

    monkeypatch.setattr(runner, "_run", fake_run)

    # Should not raise because the file failure is expected.
    runner._run_jest_with_expectations(  # pyright: ignore[reportPrivateUsage]
        cmd=["npm", "run", "test:unit"],
        expectations=expectations,
    )


def test_run_jest_scoped_wraps_test_files(monkeypatch: pytest.MonkeyPatch) -> None:
    """_run_jest_scoped_with_expectations should build a Jest command for the files."""
    runner = QCRunner(Path("/workspace"))

    captured: dict[str, object] = {}

    def fake_run_jest(*, cmd: list[str], expectations: object) -> None:
        captured["cmd"] = cmd
        captured["expectations"] = expectations

    monkeypatch.setattr(runner, "_run_jest_with_expectations", fake_run_jest)

    runner._run_jest_scoped_with_expectations(  # pyright: ignore[reportPrivateUsage]
        test_files=["tests/unit/a.test.ts"],
        expectations=None,
    )

    assert captured["cmd"] == ["npm", "run", "test:unit", "--", "tests/unit/a.test.ts"]


def test_run_full_loop_with_artifacts_supports_typescript_toolchain(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """The loop should support the TypeScript toolchain routing branch."""
    runner = QCRunner(Path("/workspace"))

    artifact_paths = {
        "format": Path("/workspace/artifacts/format.txt"),
        "lint": Path("/workspace/artifacts/lint.txt"),
        "typecheck": Path("/workspace/artifacts/typecheck.txt"),
        "test-unit": Path("/workspace/artifacts/test-unit.txt"),
    }

    def fake_diff_signature(
        *, exclude_paths: object | None = None
    ) -> tuple[tuple[str, str, str], ...]:
        _ = exclude_paths
        return (("a", "0", "0"),)

    results = iter(
        [
            QCToolResult(step="format", returncode=0, output="fmt"),
            QCToolResult(step="lint", returncode=0, output="lint"),
            QCToolResult(step="typecheck", returncode=0, output="type"),
            QCToolResult(step="test-unit", returncode=0, output="test"),
        ]
    )

    def fake_run_and_record(
        *, argv: list[str], output_path: Path, env: dict[str, str] | None = None
    ) -> QCToolResult:
        _ = argv
        _ = output_path
        _ = env
        return next(results)

    monkeypatch.setattr(runner, "_diff_signature", fake_diff_signature)
    monkeypatch.setattr(runner, "_run_and_record", fake_run_and_record)

    result = runner.run_full_loop_with_artifacts(
        artifact_paths=artifact_paths,
        max_loops=10,
        toolchain=QCToolchain.TYPESCRIPT,
    )

    assert result.success is True
    assert result.loop_count == 1


@pytest.mark.parametrize(
    ("failing_step", "returncode"),
    [
        ("black", 2),
        ("pyright", 3),
        ("pytest", 4),
    ],
)
def test_run_full_loop_with_artifacts_returns_failure_on_nonzero_step(
    failing_step: str,
    returncode: int,
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """Non-zero exit codes should produce a QCLoopResult failure for that step."""
    runner = QCRunner(Path("/workspace"))

    artifact_paths = {
        "black": Path("/workspace/artifacts/black.txt"),
        "ruff": Path("/workspace/artifacts/ruff.txt"),
        "pyright": Path("/workspace/artifacts/pyright.txt"),
        "pytest": Path("/workspace/artifacts/pytest.txt"),
    }

    def fake_diff_signature(
        *, exclude_paths: object | None = None
    ) -> tuple[tuple[str, str, str], ...]:
        _ = exclude_paths
        return (("a", "0", "0"),)

    # The loop runs: black, ruff, pyright, pytest (stopping on the first failure).
    ordered_steps = ["black", "ruff", "pyright", "pytest"]
    tool_results: list[QCToolResult] = []

    for step in ordered_steps:
        rc = returncode if step == failing_step else 0
        tool_results.append(
            QCToolResult(step=step, returncode=rc, output=f"{step} out")
        )

    results = iter(tool_results)

    def fake_run_and_record(
        *, argv: list[str], output_path: Path, env: dict[str, str] | None = None
    ) -> QCToolResult:
        _ = argv
        _ = output_path
        _ = env
        return next(results)

    monkeypatch.setattr(runner, "_diff_signature", fake_diff_signature)
    monkeypatch.setattr(runner, "_run_and_record", fake_run_and_record)

    result = runner.run_full_loop_with_artifacts(
        artifact_paths=artifact_paths,
        max_loops=10,
        toolchain=QCToolchain.PYTHON,
    )

    assert result.success is False
    assert result.failure is not None
    assert result.failure.step == failing_step
    assert result.failure.returncode == returncode


def test_run_full_loop_with_artifacts_raises_for_unsupported_toolchain() -> None:
    """The full-loop entry point should reject unsupported toolchain values."""
    runner = QCRunner(Path("/workspace"))

    with pytest.raises(RuntimeError, match="Unsupported QC toolchain"):
        runner.run_full_loop_with_artifacts(
            artifact_paths={},
            toolchain=cast(QCToolchain, object()),
        )


def test_git_has_changes_skips_malformed_status_lines(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """_git_has_changes should ignore status lines that don't include a path."""
    runner = QCRunner(Path("/workspace"))

    def fake_run(*args: object, **kwargs: object) -> subprocess.CompletedProcess[str]:
        _ = args
        _ = kwargs
        return _cp(["git"], returncode=0, stdout="M\n")

    monkeypatch.setattr(runner, "_run", fake_run)

    assert runner._git_has_changes() is False  # pyright: ignore[reportPrivateUsage]


def test_diff_signature_skips_malformed_numstat_lines(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """_diff_signature should skip lines without <add>\t<del>\t<path>."""
    runner = QCRunner(Path("/workspace"))

    def fake_run(*args: object, **kwargs: object) -> subprocess.CompletedProcess[str]:
        _ = args
        _ = kwargs
        return _cp(
            ["git"],
            returncode=0,
            stdout="1\t2\n3\t4\tsrc/x.py\n",
        )

    monkeypatch.setattr(runner, "_run", fake_run)

    sig = runner._diff_signature()  # pyright: ignore[reportPrivateUsage]

    assert sig == (("src/x.py", "3", "4"),)


def test_run_jest_with_expectations_raises_when_expected_fail_file_does_not_match(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """File-level expect-fail refs should not match unrelated failing files."""
    runner = QCRunner(Path("/workspace"))

    expectations = ResolvedTestExpectations(
        expected_fail_refs=set(),
        expected_pass_refs=set(),
        expected_fail_jest_refs={"tests/unit/other.test.ts"},
        expected_pass_jest_refs=set(),
        missing_test_refs=[],
    )

    output = "FAIL tests/unit/a.test.ts\n"

    def fake_run(*_: object, **__: object) -> None:
        raise subprocess.CalledProcessError(1, ["npm"], output=output, stderr="")

    monkeypatch.setattr(runner, "_run", fake_run)

    with pytest.raises(subprocess.CalledProcessError):
        runner._run_jest_with_expectations(  # pyright: ignore[reportPrivateUsage]
            cmd=["npm", "run", "test:unit"],
            expectations=expectations,
        )
