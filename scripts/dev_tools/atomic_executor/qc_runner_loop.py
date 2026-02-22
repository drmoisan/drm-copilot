"""QC loop and artifact helpers for atomic executor QC runner."""

from __future__ import annotations

import subprocess
from dataclasses import dataclass
from typing import TYPE_CHECKING

from scripts.dev_tools.atomic_executor.qc_toolchain import QCToolchain

if TYPE_CHECKING:
    from collections.abc import Callable, Iterable
    from pathlib import Path


@dataclass(frozen=True)
class QCToolResult:
    """Captured output and exit status for one QC command."""

    step: str
    returncode: int
    output: str


@dataclass(frozen=True)
class QCLoopFailure:
    """Failure details captured when a QC loop step fails."""

    step: str
    returncode: int
    output: str


@dataclass(frozen=True)
class QCLoopResult:
    """Outcome of a full QC loop run with optional failure details."""

    success: bool
    failure: QCLoopFailure | None
    loop_count: int


def normalize_excluded_paths(
    workspace: Path, exclude_paths: Iterable[Path] | None
) -> set[str]:
    """Normalize excluded paths to repo-relative POSIX strings."""
    excluded: set[str] = set()
    if exclude_paths is None:
        return excluded

    for path in exclude_paths:
        try:
            rel_path = path.relative_to(workspace)
        except ValueError:
            rel_path = path
        excluded.add(rel_path.as_posix())

    return excluded


def diff_signature(
    *,
    workspace: Path,
    run_checked: Callable[..., subprocess.CompletedProcess[str]],
    exclude_paths: Iterable[Path] | None = None,
) -> tuple[tuple[str, str, str], ...]:
    """Build a stable diff fingerprint of working-tree changes."""
    result = run_checked(
        ["git", "diff", "--numstat"],
        capture_output=True,
        text=True,
        errors="replace",
    )
    excluded = normalize_excluded_paths(workspace, exclude_paths)

    signature: list[tuple[str, str, str]] = []
    for line in result.stdout.splitlines():
        parts = line.split("\t")
        if len(parts) < 3:
            continue
        additions, deletions, path = parts[0], parts[1], parts[2]
        if " => " in path:
            path = path.split(" => ")[-1].strip()
        if path in excluded:
            continue
        signature.append((path, additions, deletions))

    return tuple(sorted(signature))


def git_has_changes(
    *,
    workspace: Path,
    run_checked: Callable[..., subprocess.CompletedProcess[str]],
    exclude_paths: Iterable[Path] | None = None,
) -> bool:
    """Return whether git status reports changes outside excluded paths."""
    result = run_checked(
        ["git", "status", "--porcelain"],
        capture_output=True,
        text=True,
        errors="replace",
    )

    excluded = normalize_excluded_paths(workspace, exclude_paths)
    for line in result.stdout.splitlines():
        parts = line.strip().split(maxsplit=1)
        if len(parts) != 2:
            continue
        changed_path = parts[1]
        if changed_path in excluded:
            continue
        return True
    return False


def run_and_record(
    *,
    workspace: Path,
    resolve_executable: Callable[[list[str]], list[str]],
    argv: list[str],
    output_path: Path,
    env: dict[str, str] | None = None,
) -> QCToolResult:
    """Execute a command, write combined output to an artifact, and return result."""
    output_path.parent.mkdir(parents=True, exist_ok=True)
    resolved_argv = resolve_executable(argv)
    result = subprocess.run(  # noqa: S603 - argv constructed from trusted constants
        resolved_argv,
        cwd=workspace,
        check=False,
        capture_output=True,
        text=True,
        errors="replace",
        env=env,
    )

    output = (result.stdout or "") + (result.stderr or "")
    header = " ".join(argv)
    output_path.write_text(
        f"$ {header}\n(exit {result.returncode})\n\n{output}",
        encoding="utf-8",
    )

    return QCToolResult(
        step=argv[2] if len(argv) > 2 else "command",
        returncode=result.returncode,
        output=output,
    )


def run_full_loop_with_artifacts(
    *,
    workspace: Path,
    resolve_executable: Callable[[list[str]], list[str]],
    run_checked: Callable[..., subprocess.CompletedProcess[str]],
    artifact_paths: dict[str, Path],
    lock_bypass_env: Callable[[], dict[str, str]],
    merge_env: Callable[[dict[str, str] | None], dict[str, str] | None],
    full_fmt: list[str],
    full_lint: list[str],
    full_type: list[str],
    full_test: list[str],
    full_ts_fmt: list[str],
    full_ts_lint: list[str],
    full_ts_type: list[str],
    full_ts_test: list[str],
    diff_signature_fn: Callable[..., tuple[tuple[str, str, str], ...]] = diff_signature,
    run_and_record_fn: Callable[..., QCToolResult] = run_and_record,
    max_loops: int | None = 10,
    toolchain: QCToolchain = QCToolchain.PYTHON,
) -> QCLoopResult:
    """Run repeated full QC loops until one pass succeeds without formatter diffs."""
    loop_count = 0

    if toolchain is QCToolchain.PYTHON:
        format_step = "black"
        lint_step = "ruff"
        type_step = "pyright"
        test_step = "pytest"
        format_cmd = full_fmt
        lint_cmd = full_lint
        type_cmd = full_type
        test_cmd = full_test
        test_env = merge_env(lock_bypass_env())
    elif toolchain is QCToolchain.TYPESCRIPT:
        format_step = "format"
        lint_step = "lint"
        type_step = "typecheck"
        test_step = "test-unit"
        format_cmd = full_ts_fmt
        lint_cmd = full_ts_lint
        type_cmd = full_ts_type
        test_cmd = full_ts_test
        test_env = None
    else:
        raise RuntimeError(f"Unsupported QC toolchain: {toolchain}")

    while True:
        loop_count += 1
        if max_loops is not None and loop_count > max_loops:
            raise RuntimeError(f"QC loop exceeded maximum iterations ({max_loops}).")

        before_black = diff_signature_fn(
            workspace=workspace,
            run_checked=run_checked,
            exclude_paths=artifact_paths.values(),
        )

        format_result = run_and_record_fn(
            workspace=workspace,
            resolve_executable=resolve_executable,
            argv=format_cmd,
            output_path=artifact_paths[format_step],
        )
        if format_result.returncode != 0:
            return QCLoopResult(
                success=False,
                failure=QCLoopFailure(
                    step=format_step,
                    returncode=format_result.returncode,
                    output=format_result.output,
                ),
                loop_count=loop_count,
            )

        after_black = diff_signature_fn(
            workspace=workspace,
            run_checked=run_checked,
            exclude_paths=artifact_paths.values(),
        )
        if after_black != before_black:
            continue

        lint_result = run_and_record_fn(
            workspace=workspace,
            resolve_executable=resolve_executable,
            argv=lint_cmd,
            output_path=artifact_paths[lint_step],
        )
        if lint_result.returncode != 0:
            return QCLoopResult(
                success=False,
                failure=QCLoopFailure(
                    step=lint_step,
                    returncode=lint_result.returncode,
                    output=lint_result.output,
                ),
                loop_count=loop_count,
            )

        type_result = run_and_record_fn(
            workspace=workspace,
            resolve_executable=resolve_executable,
            argv=type_cmd,
            output_path=artifact_paths[type_step],
        )
        if type_result.returncode != 0:
            return QCLoopResult(
                success=False,
                failure=QCLoopFailure(
                    step=type_step,
                    returncode=type_result.returncode,
                    output=type_result.output,
                ),
                loop_count=loop_count,
            )

        test_result = run_and_record_fn(
            workspace=workspace,
            resolve_executable=resolve_executable,
            argv=test_cmd,
            output_path=artifact_paths[test_step],
            env=test_env,
        )
        if test_result.returncode != 0:
            return QCLoopResult(
                success=False,
                failure=QCLoopFailure(
                    step=test_step,
                    returncode=test_result.returncode,
                    output=test_result.output,
                ),
                loop_count=loop_count,
            )

        return QCLoopResult(success=True, failure=None, loop_count=loop_count)
