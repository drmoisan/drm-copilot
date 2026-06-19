"""JSON, shell, and PowerShell branch functions for the fix-all workflow.

Purpose:
    Hold three per-language quality branches (json, shell, powershell) that
    were previously nested closures inside ``fix_all_runtime.run_fix_all``. The
    two larger branches (python, typescript) live in
    ``fix_all_branches_extra.py`` so every branch module stays under the
    500-line file-size limit. Extraction preserves the exact behavior, branch
    ordering, cancel semantics, and status-board emission of the originals.

Responsibilities:
    Run each language toolchain in its fixed step order via the supplied
    ``CommandRunner``, emit status-board transitions through the injected
    ``emit_status_transition`` callable, and return a ``BranchResult``. This
    module does not own the threading loop, results aggregation, cancel
    coordination, or final summary; those remain in ``fix_all_runtime``.

Usage:
    ``run_fix_all`` passes ``factory`` and ``emit_status_transition`` closures,
    the ``fix_all`` module reference (``api``), and config flags into these
    functions. ``api`` is the same module reference used by the runtime so
    test patch points (for example ``fix_all.subprocess_run``) remain valid.

Key invariants/constraints:
    The json branch is the only branch that reads ``cancel_event`` and
    ``complete_all`` and must still call
    ``cancel_event.wait(api.CANCEL_CHECK_DELAY_S)``.

Important side effects:
    Spawns subprocesses via the supplied runner, writes per-step output to an
    isolated in-memory branch stream, and emits status-board transitions.
"""

from __future__ import annotations

from io import StringIO
from typing import TYPE_CHECKING

if TYPE_CHECKING:
    import threading
    from collections.abc import Callable
    from types import ModuleType

    from .fix_all import BranchResult, CommandRunner, StepLogger


def run_json_branch(
    *,
    factory: Callable[[str, StepLogger], CommandRunner],
    emit_status_transition: Callable[[str, str], None],
    cancel_event: threading.Event,
    complete_all: bool,
    api: ModuleType,
) -> BranchResult:
    """Run the JSON format then validate branch with cooperative cancel.

    Args:
        factory: Builds a ``CommandRunner`` for a named branch and logger.
        emit_status_transition: Records a status-board transition.
        cancel_event: Shared cancel signal; checked only when not complete_all.
        complete_all: When True, ignore cancellation and run every step.
        api: ``fix_all`` module reference (StepLogger, BranchResult,
            run_simple_step, CANCEL_CHECK_DELAY_S).

    Returns:
        BranchResult: Success when both steps pass, else failure tagged with
            the first failing or canceled step.

    Side Effects:
        Spawns subprocesses, writes to an isolated branch stream, emits
        status-board transitions.
    """
    branch_stream: StringIO = StringIO()
    branch_logger = api.StepLogger(stream=branch_stream)
    branch_runner = factory("json", branch_logger)

    emit_status_transition("json", "JSON: format")
    if not api.run_simple_step(
        step_number=1,
        description="Running JSON formatting...",
        step_name="JSON: format",
        success_message="JSON formatting completed",
        failure_message="JSON formatting failed. Please review errors above.",
        command=[
            "poetry",
            "run",
            "python",
            "-m",
            "scripts.dev_tools.format_json",
        ],
        runner=branch_runner,
        logger=branch_logger,
    ):
        output = branch_stream.getvalue()
        emit_status_transition("json", "FAIL")
        return api.BranchResult(
            name="json", success=False, output=output, failed_step="JSON: format"
        )

    # Cancel check: another branch may have failed during JSON formatting;
    # abort before validation unless complete_all overrides cancellation.
    if cancel_event.is_set() and not complete_all:
        output = branch_stream.getvalue()
        emit_status_transition("json", "FAIL")
        return api.BranchResult(
            name="json", success=False, output=output, failed_step="Canceled"
        )

    # Brief cooperative wait so a sibling failure has a chance to set the
    # cancel event before JSON validation starts.
    if not complete_all:
        cancel_event.wait(api.CANCEL_CHECK_DELAY_S)
    if cancel_event.is_set() and not complete_all:
        output = branch_stream.getvalue()
        emit_status_transition("json", "FAIL")
        return api.BranchResult(
            name="json", success=False, output=output, failed_step="Canceled"
        )

    emit_status_transition("json", "JSON: validate")
    if not api.run_simple_step(
        step_number=2,
        description="Running JSON validation...",
        step_name="JSON: validate",
        success_message="JSON validation passed",
        failure_message="JSON validation failed. Please review errors above.",
        command=[
            "poetry",
            "run",
            "python",
            "-m",
            "scripts.dev_tools.validate_json",
        ],
        runner=branch_runner,
        logger=branch_logger,
    ):
        output = branch_stream.getvalue()
        emit_status_transition("json", "FAIL")
        return api.BranchResult(
            name="json", success=False, output=output, failed_step="JSON: validate"
        )

    output = branch_stream.getvalue()
    emit_status_transition("json", "PASS")
    return api.BranchResult(name="json", success=True, output=output)


def run_shell_branch(
    *,
    factory: Callable[[str, StepLogger], CommandRunner],
    emit_status_transition: Callable[[str, str], None],
    api: ModuleType,
) -> BranchResult:
    """Run the shell format, lint, and test branch; skipped tests count as pass.

    Args:
        factory: Builds a ``CommandRunner`` for a named branch and logger.
        emit_status_transition: Records a status-board transition.
        api: ``fix_all`` module reference (StepLogger, BranchResult,
            run_simple_step, shell_test_was_skipped, log_failure).

    Returns:
        BranchResult: Success when format/check pass and tests pass or skip,
            else failure tagged with the first failing step.

    Side Effects:
        Spawns subprocesses, writes to an isolated branch stream, emits
        status-board transitions.
    """
    branch_stream: StringIO = StringIO()
    branch_logger = api.StepLogger(stream=branch_stream)
    branch_runner = factory("shell", branch_logger)

    emit_status_transition("shell", "Shell: format")
    if not api.run_simple_step(
        step_number=1,
        description="Running shell script formatting (shfmt)...",
        step_name="Shell: format",
        success_message="Shell formatting completed",
        failure_message="Shell formatting failed. Please review errors above.",
        command=[
            "poetry",
            "run",
            "python",
            "-m",
            "scripts.dev_tools.shell_qc",
            "format",
        ],
        runner=branch_runner,
        logger=branch_logger,
    ):
        output = branch_stream.getvalue()
        emit_status_transition("shell", "FAIL")
        return api.BranchResult(
            name="shell", success=False, output=output, failed_step="Shell: format"
        )

    emit_status_transition("shell", "Shell: check")
    if not api.run_simple_step(
        step_number=2,
        description="Running shell linting (shfmt -d + shellcheck)...",
        step_name="Shell: check",
        success_message="Shell linting passed",
        failure_message="Shell linting failed. Please review errors above.",
        command=[
            "poetry",
            "run",
            "python",
            "-m",
            "scripts.dev_tools.shell_qc",
            "check",
        ],
        runner=branch_runner,
        logger=branch_logger,
    ):
        output = branch_stream.getvalue()
        emit_status_transition("shell", "FAIL")
        return api.BranchResult(
            name="shell", success=False, output=output, failed_step="Shell: check"
        )

    emit_status_transition("shell", "Shell: test")
    branch_logger.step("Step 3: Running shell tests (bats)...")
    test_result = branch_runner.run(
        [
            "poetry",
            "run",
            "python",
            "-m",
            "scripts.dev_tools.shell_qc",
            "test",
        ],
        step_name="Shell: test",
    )
    # Success path: distinguish a genuine pass from an environment skip so the
    # status board reflects whether tests actually ran.
    if test_result.returncode == 0:
        if api.shell_test_was_skipped(test_result.output):
            branch_logger.success("Shell tests skipped")
            test_status = "SKIP tests"
        else:
            branch_logger.success("Shell tests passed")
            test_status = "PASS"
        output = branch_stream.getvalue()
        emit_status_transition("shell", test_status)
        return api.BranchResult(name="shell", success=True, output=output)

    api.log_failure(
        branch_logger,
        "Shell tests failed. Please review errors above.",
        test_result,
    )
    output = branch_stream.getvalue()
    emit_status_transition("shell", "FAIL")
    return api.BranchResult(
        name="shell", success=False, output=output, failed_step="Shell: test"
    )


def run_powershell_branch(
    *,
    factory: Callable[[str, StepLogger], CommandRunner],
    emit_status_transition: Callable[[str, str], None],
    api: ModuleType,
) -> BranchResult:
    """Run the PowerShell PoshQC format, analyze, and test branch via pwsh.

    Args:
        factory: Builds a ``CommandRunner`` for a named branch and logger.
        emit_status_transition: Records a status-board transition.
        api: ``fix_all`` module reference (StepLogger, BranchResult,
            run_simple_step).

    Returns:
        BranchResult: Success when all three steps pass, else failure tagged
            with the first failing step.

    Side Effects:
        Spawns subprocesses, writes to an isolated branch stream, emits
        status-board transitions.
    """
    branch_stream: StringIO = StringIO()
    branch_logger = api.StepLogger(stream=branch_stream)
    branch_runner = factory("powershell", branch_logger)

    emit_status_transition("powershell", "PoshQC: format")
    if not api.run_simple_step(
        step_number=1,
        description="Running PowerShell formatting (Invoke-PoshQCFormat)...",
        step_name="PoshQC: format",
        success_message="PowerShell formatting completed",
        failure_message="PowerShell formatting failed. Please review errors above.",
        command=[
            "pwsh",
            "-NoLogo",
            "-NoProfile",
            "-ExecutionPolicy",
            "Bypass",
            "-Command",
            "Import-Module './scripts/powershell/PoshQC'; "
            "Invoke-PoshQCFormat -Root '.'",
        ],
        runner=branch_runner,
        logger=branch_logger,
    ):
        output = branch_stream.getvalue()
        emit_status_transition("powershell", "FAIL")
        return api.BranchResult(
            name="powershell",
            success=False,
            output=output,
            failed_step="PoshQC: format",
        )

    emit_status_transition("powershell", "PoshQC: analyze")
    if not api.run_simple_step(
        step_number=2,
        description="Running PowerShell linting (PSScriptAnalyzer)...",
        step_name="PoshQC: analyze",
        success_message="PowerShell analysis passed",
        failure_message="PowerShell analysis failed. Please review errors above.",
        command=[
            "pwsh",
            "-NoLogo",
            "-NoProfile",
            "-ExecutionPolicy",
            "Bypass",
            "-Command",
            "Import-Module './scripts/powershell/PoshQC'; "
            "Invoke-PoshQCAnalyze -Root '.'",
        ],
        runner=branch_runner,
        logger=branch_logger,
    ):
        output = branch_stream.getvalue()
        emit_status_transition("powershell", "FAIL")
        return api.BranchResult(
            name="powershell",
            success=False,
            output=output,
            failed_step="PoshQC: analyze",
        )

    emit_status_transition("powershell", "PoshQC: test")
    if not api.run_simple_step(
        step_number=3,
        description="Running PowerShell tests (Pester)...",
        step_name="PoshQC: test",
        success_message="PowerShell tests passed",
        failure_message="PowerShell tests failed. Please review errors above.",
        command=[
            "pwsh",
            "-NoLogo",
            "-NoProfile",
            "-ExecutionPolicy",
            "Bypass",
            "-Command",
            "Import-Module './scripts/powershell/PoshQC'; "
            "Invoke-PoshQCTest -Root '.'",
        ],
        runner=branch_runner,
        logger=branch_logger,
    ):
        output = branch_stream.getvalue()
        emit_status_transition("powershell", "FAIL")
        return api.BranchResult(
            name="powershell",
            success=False,
            output=output,
            failed_step="PoshQC: test",
        )

    output = branch_stream.getvalue()
    emit_status_transition("powershell", "PASS")
    return api.BranchResult(name="powershell", success=True, output=output)
