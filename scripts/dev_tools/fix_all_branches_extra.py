"""Python and TypeScript branch functions for the fix-all workflow.

Purpose:
    Hold the two largest per-language quality branches (python, typescript)
    that were previously nested closures inside
    ``fix_all_runtime.run_fix_all``. These two branches are split out of
    ``fix_all_branches.py`` so that both branch modules remain under the
    500-line file-size limit while preserving the exact behavior, branch
    ordering, and status-board emission of the originals.

Responsibilities:
    Run the python and typescript toolchains in their fixed step order via the
    supplied ``CommandRunner`` and emit status-board transitions through the
    injected ``emit_status_transition`` callable. This module does not own the
    threading loop, results aggregation, or final summary.

Usage:
    ``run_fix_all`` passes ``factory`` and ``emit_status_transition`` closures,
    the ``fix_all`` module reference (``api``), and config flags into these
    functions. ``api`` is the same module reference used by the runtime so test
    patch points (for example ``fix_all.subprocess_run``) remain valid.

Important side effects:
    Spawns subprocesses via the supplied runner, writes per-step output to an
    isolated in-memory branch stream, and emits status-board transitions.
"""

from __future__ import annotations

import shutil
from io import StringIO
from typing import TYPE_CHECKING

if TYPE_CHECKING:
    from collections.abc import Callable
    from types import ModuleType

    from .fix_all import BranchResult, CommandRunner, StepLogger


def run_python_branch(
    *,
    factory: Callable[[str, StepLogger], CommandRunner],
    emit_status_transition: Callable[[str, str], None],
    include_coverage: bool,
    max_black_retries: int,
    max_ruff_retries: int,
    api: ModuleType,
) -> BranchResult:
    """Run the Python Black/Ruff/Pyright/Pytest branch with auto-fix retry.

    Black runs with retry, Ruff runs with an auto-fix retry loop that
    re-verifies Black after any fix, then Pyright and Pytest run.

    Args:
        factory: Builds a ``CommandRunner`` for a named branch and logger.
        emit_status_transition: Records a status-board transition.
        include_coverage: When True, run Pytest with coverage flags/step name.
        max_black_retries: Maximum Black formatting attempts.
        max_ruff_retries: Maximum Ruff auto-fix attempts.
        api: ``fix_all`` module reference (step helpers, BranchResult).

    Returns:
        BranchResult: Success when all steps pass, else failure tagged with
            the first failing step.

    Side Effects:
        Spawns subprocesses, writes to an isolated branch stream, emits
        status-board transitions.
    """
    branch_stream: StringIO = StringIO()
    branch_logger = api.StepLogger(stream=branch_stream)
    branch_runner = factory("python", branch_logger)

    # Black/Ruff loop: a Ruff auto-fix can change formatting, so the loop
    # restarts Black and Ruff until Ruff passes without applying fixes.
    while True:
        emit_status_transition("python", "Black: format")
        if not api.run_black_with_retry(
            step_number=1,
            max_retries=max_black_retries,
            runner=branch_runner,
            logger=branch_logger,
        ):
            output = branch_stream.getvalue()
            emit_status_transition("python", "FAIL")
            return api.BranchResult(
                name="python",
                success=False,
                output=output,
                failed_step="Black: format",
            )

        emit_status_transition("python", "Ruff: lint")
        branch_logger.step("Step 2: Running Ruff linting...")
        ruff_result = branch_runner.run(
            ["poetry", "run", "ruff", "check"], step_name="Ruff: lint"
        )
        # Branch on Ruff result: clean lint exits the loop; reported issues
        # trigger an auto-fix attempt and another loop iteration.
        if ruff_result.returncode == 0:
            branch_logger.success("Ruff linting passed")
        else:
            if ruff_result.output:
                branch_logger.command_output(ruff_result.output)
            branch_logger.info("Ruff reported issues; attempting auto-fix...")
            emit_status_transition("python", "Ruff: fix")
            if not api.ruff_fix(
                max_retries=max_ruff_retries,
                runner=branch_runner,
                logger=branch_logger,
            ):
                output = branch_stream.getvalue()
                emit_status_transition("python", "FAIL")
                return api.BranchResult(
                    name="python",
                    success=False,
                    output=output,
                    failed_step="Ruff: lint",
                )
            branch_logger.info(
                "Ruff auto-fix applied; restarting Black to re-verify formatting."
            )
            branch_logger.info("Re-running Black and Ruff to confirm clean state.")
            continue

        break

    emit_status_transition("python", "Pyright: type-check")
    if not api.run_simple_step(
        step_number=3,
        description="Running Pyright type checking...",
        step_name="Pyright: type-check",
        success_message="Pyright type checking passed",
        failure_message="Pyright type checking failed. Please review errors above.",
        command=["poetry", "run", "pyright", "--project", "pyproject.toml"],
        runner=branch_runner,
        logger=branch_logger,
    ):
        output = branch_stream.getvalue()
        emit_status_transition("python", "FAIL")
        return api.BranchResult(
            name="python",
            success=False,
            output=output,
            failed_step="Pyright: type-check",
        )

    pytest_command: list[str] = ["poetry", "run", "pytest"]
    pytest_step_name = (
        "Pytest: test with coverage" if include_coverage else "Pytest: test"
    )
    # Coverage toggle: append coverage flags and switch the step name only
    # when coverage is requested.
    if include_coverage:
        pytest_command.extend(
            [
                "--cov=src/lexile_corpus_tuner",
                "--cov=scripts/dev_tools",
                "--cov-report=term-missing",
            ]
        )

    emit_status_transition("python", pytest_step_name)
    if not api.run_simple_step(
        step_number=4,
        description=(
            "Running Pytest with coverage..."
            if include_coverage
            else "Running Pytest..."
        ),
        step_name=pytest_step_name,
        success_message="Pytest passed",
        failure_message="Pytest failed. Please review errors above.",
        command=pytest_command,
        runner=branch_runner,
        logger=branch_logger,
    ):
        output = branch_stream.getvalue()
        emit_status_transition("python", "FAIL")
        return api.BranchResult(
            name="python",
            success=False,
            output=output,
            failed_step=pytest_step_name,
        )

    output = branch_stream.getvalue()
    emit_status_transition("python", "PASS")
    return api.BranchResult(name="python", success=True, output=output)


def _resolve_npm() -> str | None:
    """Resolve the ``npm`` executable to a full filesystem path.

    Purpose:
        Locate ``npm`` on PATH and return its absolute path. The TypeScript
        branch must launch ``npm`` through the no-shell subprocess runner, and
        on Windows ``npm`` is a ``.cmd`` shim rather than a PE executable.
        ``subprocess`` cannot launch the bare name ``npm`` there (it raises
        ``FileNotFoundError``), so the command must use the full path that
        PATHEXT resolution yields (for example ``npm.CMD``). ``shutil.which``
        performs that PATHEXT-aware lookup on every platform.

    Returns:
        str | None: The absolute path to ``npm`` (``npm.cmd`` on Windows, the
            ``npm`` binary on POSIX), or ``None`` when ``npm`` is not installed
            or not resolvable on PATH.

    Side Effects:
        None. Performs a read-only PATH lookup.
    """
    return shutil.which("npm")


def run_typescript_branch(
    *,
    factory: Callable[[str, StepLogger], CommandRunner],
    emit_status_transition: Callable[[str, str], None],
    include_coverage: bool,
    api: ModuleType,
) -> BranchResult:
    """Run the TypeScript format -> lint -> type-check -> test branch via npm.

    Mirrors the linear PowerShell-branch structure (no auto-fix retry loop).

    Args:
        factory: Builds a ``CommandRunner`` for a named branch and logger.
        emit_status_transition: Records a status-board transition.
        include_coverage: When True, run Jest with coverage and coverage step
            name.
        api: ``fix_all`` module reference (StepLogger, BranchResult,
            run_simple_step).

    Returns:
        BranchResult: Success when all steps pass, else failure tagged with
            the first failing step name.

    Side Effects:
        Spawns npm subprocesses, writes to an isolated branch stream, emits
        status-board transitions.
    """
    branch_stream: StringIO = StringIO()
    branch_logger = api.StepLogger(stream=branch_stream)
    branch_runner = factory("typescript", branch_logger)

    # Resolve npm to a full path before any step. The no-shell subprocess runner
    # cannot launch the bare name "npm" on Windows (it is a .cmd shim), so a
    # missing or unresolvable npm must fail this branch cleanly rather than raise
    # FileNotFoundError inside the worker thread.
    npm = _resolve_npm()
    if npm is None:
        branch_logger.failure(
            "npm executable not found on PATH; cannot run the TypeScript "
            "toolchain branch. Install Node.js/npm or remove it from scope."
        )
        output = branch_stream.getvalue()
        emit_status_transition("typescript", "FAIL")
        return api.BranchResult(
            name="typescript",
            success=False,
            output=output,
            failed_step="Prettier: format",
        )

    # Prettier auto-fixes formatting in place; there is no separate fix step.
    emit_status_transition("typescript", "Prettier: format")
    if not api.run_simple_step(
        step_number=1,
        description="Running Prettier formatting (npm run format)...",
        step_name="Prettier: format",
        success_message="Prettier formatting completed",
        failure_message="Prettier formatting failed. Please review errors above.",
        command=[npm, "run", "format"],
        runner=branch_runner,
        logger=branch_logger,
    ):
        output = branch_stream.getvalue()
        emit_status_transition("typescript", "FAIL")
        return api.BranchResult(
            name="typescript",
            success=False,
            output=output,
            failed_step="Prettier: format",
        )

    emit_status_transition("typescript", "ESLint: lint")
    if not api.run_simple_step(
        step_number=2,
        description="Running ESLint linting (npm run lint)...",
        step_name="ESLint: lint",
        success_message="ESLint linting passed",
        failure_message="ESLint linting failed. Please review errors above.",
        command=[npm, "run", "lint"],
        runner=branch_runner,
        logger=branch_logger,
    ):
        output = branch_stream.getvalue()
        emit_status_transition("typescript", "FAIL")
        return api.BranchResult(
            name="typescript",
            success=False,
            output=output,
            failed_step="ESLint: lint",
        )

    emit_status_transition("typescript", "TSC: type-check")
    if not api.run_simple_step(
        step_number=3,
        description="Running TSC type checking (npm run typecheck)...",
        step_name="TSC: type-check",
        success_message="TSC type checking passed",
        failure_message="TSC type checking failed. Please review errors above.",
        command=[npm, "run", "typecheck"],
        runner=branch_runner,
        logger=branch_logger,
    ):
        output = branch_stream.getvalue()
        emit_status_transition("typescript", "FAIL")
        return api.BranchResult(
            name="typescript",
            success=False,
            output=output,
            failed_step="TSC: type-check",
        )

    # Switch Jest step name and command on coverage, mirroring the python branch.
    jest_command = (
        [npm, "run", "test:unit:coverage"]
        if include_coverage
        else [npm, "run", "test:unit"]
    )
    jest_step_name = "Jest: test with coverage" if include_coverage else "Jest: test"

    emit_status_transition("typescript", jest_step_name)
    if not api.run_simple_step(
        step_number=4,
        description=(
            "Running Jest with coverage..." if include_coverage else "Running Jest..."
        ),
        step_name=jest_step_name,
        success_message="Jest passed",
        failure_message="Jest failed. Please review errors above.",
        command=jest_command,
        runner=branch_runner,
        logger=branch_logger,
    ):
        output = branch_stream.getvalue()
        emit_status_transition("typescript", "FAIL")
        return api.BranchResult(
            name="typescript",
            success=False,
            output=output,
            failed_step=jest_step_name,
        )

    output = branch_stream.getvalue()
    emit_status_transition("typescript", "PASS")
    return api.BranchResult(name="typescript", success=True, output=output)
