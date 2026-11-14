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
    ``cancel_event.wait(api.CANCEL_CHECK_DELAY_S)``. Every test step runs the
    test-execution launcher (issue #1158) inside the optional ``suite_lock``, so
    the four test suites of one run never overlap, and classifies the launcher
    exit through ``classify_launcher_exit`` before any other failure handling.

Important side effects:
    Spawns subprocesses via the supplied runner, writes per-step output to an
    isolated in-memory branch stream, and emits status-board transitions.
"""

from __future__ import annotations

from io import StringIO
from typing import TYPE_CHECKING

from .atomic_executor.qc_runner_expectations import (
    TEST_SUITE_LAUNCHER_ARGV,
    classify_launcher_exit,
    launcher_refusal_message,
)

if TYPE_CHECKING:
    import threading
    from collections.abc import Callable, Sequence
    from contextlib import AbstractContextManager
    from types import ModuleType

    from .fix_all import BranchResult, CommandResult, CommandRunner, StepLogger


def run_suite_command(
    *,
    suite: str,
    extras: Sequence[str],
    step_name: str,
    runner: CommandRunner,
    suite_lock: AbstractContextManager[object] | None,
) -> CommandResult:
    """Run one launcher suite, inside the suite lock when one is supplied.

    Args:
        suite: Launcher suite name, the first script argument (spec D18).
        extras: Arguments passed after the suite name.
        step_name: Runner step name used for the status board and logs.
        runner: Command runner of the calling branch.
        suite_lock: Context manager held for the whole run; ``None`` runs the
            suite without serialization (direct branch callers).

    Returns:
        CommandResult: The runner's result, with the launcher output captured.

    Side Effects:
        Starts the launcher process through ``runner``.
    """
    command = [*TEST_SUITE_LAUNCHER_ARGV, suite, *extras]
    # Direct callers pass no lock; run_fix_all passes one lock to all four test
    # steps so only one suite runs at a time within a fix_all run.
    if suite_lock is None:
        return runner.run(command, step_name=step_name)
    with suite_lock:
        return runner.run(command, step_name=step_name)


def report_suite_failure(
    *,
    result: CommandResult,
    failure_message: str,
    logger: StepLogger,
    api: ModuleType,
) -> None:
    """Log a failed launcher run as a launcher outcome or as a test failure.

    Args:
        result: Non-zero result of a launcher run.
        failure_message: The step's existing failure message.
        logger: Branch logger.
        api: ``fix_all`` module reference (``log_failure``).

    Returns:
        None.

    Side Effects:
        Writes failure lines to the branch logger.
    """
    outcome = classify_launcher_exit(result.returncode, result.output)
    # A queue timeout or a policy refusal is reported by its prefix line, not as
    # a test failure; every other code keeps the step's existing message.
    if outcome is None:
        api.log_failure(logger, failure_message, result)
        return
    logger.failure(launcher_refusal_message(outcome))
    if result.output:
        logger.failure("Command output:")
        logger.command_output(result.output)


def run_launcher_test_step(
    *,
    step_number: int,
    description: str,
    step_name: str,
    success_message: str,
    failure_message: str,
    suite: str,
    extras: Sequence[str],
    runner: CommandRunner,
    logger: StepLogger,
    suite_lock: AbstractContextManager[object] | None,
    api: ModuleType,
) -> bool:
    """Run a test step through the launcher with the log lines of run_simple_step.

    ``run_simple_step`` returns only a boolean and discards the result, so test
    steps use this helper to classify the captured launcher exit (spec D28).

    Args:
        step_number: Number shown in the ``Step N:`` log line.
        description: Text of the ``Step N:`` log line.
        step_name: Runner step name.
        success_message: Message logged on exit 0.
        failure_message: Message logged for a test failure.
        suite: Launcher suite name.
        extras: Arguments passed after the suite name.
        runner: Command runner of the calling branch.
        logger: Branch logger.
        suite_lock: Optional suite lock (see ``run_suite_command``).
        api: ``fix_all`` module reference.

    Returns:
        bool: True when the suite passed.

    Side Effects:
        Starts the launcher process and writes log lines.
    """
    logger.step(f"Step {step_number}: {description}")
    result = run_suite_command(
        suite=suite,
        extras=extras,
        step_name=step_name,
        runner=runner,
        suite_lock=suite_lock,
    )
    if result.returncode == 0:
        logger.success(success_message)
        return True
    report_suite_failure(
        result=result, failure_message=failure_message, logger=logger, api=api
    )
    return False


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
    suite_lock: AbstractContextManager[object] | None = None,
) -> BranchResult:
    """Run the shell format, lint, and test branch; skipped tests count as pass.

    Args:
        factory: Builds a ``CommandRunner`` for a named branch and logger.
        emit_status_transition: Records a status-board transition.
        api: ``fix_all`` module reference (StepLogger, BranchResult,
            run_simple_step, shell_test_was_skipped, log_failure).
        suite_lock: Optional lock held while the launcher ``bats`` suite runs.

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
            "bash",
            "scripts/bash/shell-qc.sh",
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
            "bash",
            "scripts/bash/shell-qc.sh",
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
    test_result = run_suite_command(
        suite="bats",
        extras=[],
        step_name="Shell: test",
        runner=branch_runner,
        suite_lock=suite_lock,
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

    report_suite_failure(
        result=test_result,
        failure_message="Shell tests failed. Please review errors above.",
        logger=branch_logger,
        api=api,
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
    suite_lock: AbstractContextManager[object] | None = None,
) -> BranchResult:
    """Run the PowerShell PoshQC format, analyze, leak-scan, and test branch via pwsh.

    The four steps run in order and the branch stops at the first failure.

    Args:
        factory: Builds a ``CommandRunner`` for a named branch and logger.
        emit_status_transition: Records a status-board transition.
        api: ``fix_all`` module reference (StepLogger, BranchResult,
            run_simple_step).
        suite_lock: Optional lock held while the launcher ``pester`` suite runs.

    Returns:
        BranchResult: Success when all four steps pass, else failure tagged
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

    # The static leak scan (issue #1096) runs no test, so it gates the branch
    # before the Pester step and stops the branch on any unallowlisted finding.
    emit_status_transition("powershell", "PoshQC: leak scan")
    if not api.run_simple_step(
        step_number=3,
        description="Scanning Pester tests for leaked state (Invoke-PoshQCLeakScan)...",
        step_name="PoshQC: leak scan",
        success_message="PowerShell leak scan passed",
        failure_message="PowerShell leak scan failed. Please review findings above.",
        command=[
            "pwsh",
            "-NoLogo",
            "-NoProfile",
            "-ExecutionPolicy",
            "Bypass",
            "-Command",
            "Import-Module './scripts/powershell/PoshQC'; "
            "Invoke-PoshQCLeakScan -Root '.'",
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
            failed_step="PoshQC: leak scan",
        )

    emit_status_transition("powershell", "PoshQC: test")
    # The gate is one launcher ``pester`` suite run: Invoke-PoshQCParallelTest
    # under the machine test-suite lock, exiting with its ExitCode (#1096, #1158).
    if not run_launcher_test_step(
        step_number=4,
        description="Running PowerShell tests (Pester, parallel shards)...",
        step_name="PoshQC: test",
        success_message="PowerShell tests passed",
        failure_message="PowerShell tests failed. Please review errors above.",
        suite="pester",
        extras=[],
        runner=branch_runner,
        logger=branch_logger,
        suite_lock=suite_lock,
        api=api,
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
