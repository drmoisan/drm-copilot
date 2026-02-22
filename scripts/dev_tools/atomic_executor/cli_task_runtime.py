"""Task execution helpers for atomic executor CLI."""

from __future__ import annotations

import re
import sys
from typing import TYPE_CHECKING

from scripts.dev_tools.atomic_executor.cli_copilot_runtime import log_msg, run_copilot
from scripts.dev_tools.atomic_executor.cli_preflight import (
    MISSING_EXECUTABLE_PREFIX,
    PreflightQCResult,
    build_preflight_qc_fix_prompt,
    run_preflight_qc_with_capture,
)
from scripts.dev_tools.atomic_executor.copilot_throttling import (
    CallRateLimiter,
    ExponentialBackoff,
    FailureKind,
    classify_copilot_failure,
)

if TYPE_CHECKING:
    from collections.abc import Callable
    from pathlib import Path

    from scripts.dev_tools.atomic_executor.plan_parser import (
        AutoQCPhase,
        PlanParser,
        PlanTask,
    )
    from scripts.dev_tools.atomic_executor.pytest_expectations import (
        ResolvedTestExpectations,
    )
    from scripts.dev_tools.atomic_executor.qc_runner import QCLoopResult, QCRunner
    from scripts.dev_tools.atomic_executor.qc_toolchain import QCToolchain

LOG_DIR = ".agent_logs"
READ_TASK_PATTERN = re.compile(r"^read\b", re.IGNORECASE)


def is_phase0_read_task(task: PlanTask) -> bool:
    """Determine whether a task is a Phase 0 "read" task."""
    return task.phase == 0 and bool(READ_TASK_PATTERN.match(task.title.strip()))


def phase0_read_tasks(parser: PlanParser) -> list[PlanTask]:
    """Collect unchecked Phase 0 read tasks in plan order."""
    plan = parser.parse()
    return [
        task
        for task in sorted(plan.tasks, key=lambda x: (x.phase, x.task_num))
        if (not task.checked) and is_phase0_read_task(task)
    ]


def first_non_read_task(parser: PlanParser) -> PlanTask | None:
    """Return the first unchecked task that is not a Phase 0 read task."""
    plan = parser.parse()
    for task in sorted(plan.tasks, key=lambda x: (x.phase, x.task_num)):
        if task.checked:
            continue
        if is_phase0_read_task(task):
            continue
        return task
    return None


def _build_qc_fix_prompt(
    *,
    feature_dir: Path,
    phase: AutoQCPhase,
    failure: QCLoopResult,
) -> str:
    """Build a focused prompt for fixing QC failures in an auto-QC phase."""
    failure_detail = failure.failure
    if failure_detail is None:
        return "Auto-QC failure: unknown failure detail."

    artifact_lines = [
        f"- {step}: {path.as_posix()}" for step, path in phase.artifact_paths.items()
    ]
    artifact_list = "\n".join(artifact_lines)
    return (
        "You are fixing an auto-executed QC phase in the atomic executor.\n\n"
        "Context:\n"
        f"- Feature folder: {feature_dir.as_posix()}\n"
        f"- QC phase: {phase.phase}\n\n"
        "Failure:\n"
        f"- Step: {failure_detail.step}\n"
        f"- Exit code: {failure_detail.returncode}\n\n"
        "Captured output:\n"
        f"{failure_detail.output}\n\n"
        "Artifacts (already written):\n"
        f"{artifact_list}\n\n"
        "Instructions:\n"
        "- Fix the reported issues in the codebase.\n"
        "- Do NOT run the toolchain yourself; the executor will rerun it.\n"
        "- Keep changes minimal and scoped to the failure.\n"
        "- When done, reply with a brief summary of what you changed.\n"
    )


def run_preflight_qc_fix_loop(
    *,
    workspace: Path,
    log_file: Path,
    run_id: str,
    preferred_model: str | None,
    copilot_rate_limiter: CallRateLimiter,
    copilot_backoff: ExponentialBackoff,
    copilot_max_retries: int,
    copilot_output_tail_bytes: int,
    copilot_allow_shell: bool,
    copilot_allow_all_paths: bool,
    copilot_allow_all_urls: bool,
    copilot_trust_workspace: bool,
    max_fix_attempts: int,
    expectations: ResolvedTestExpectations | None,
    toolchains: list[QCToolchain],
    shutdown_requested: Callable[[], bool] | None = None,
) -> int:
    """Run the pre-flight QC fix loop until baseline passes."""
    is_shutdown_requested = shutdown_requested or (lambda: False)
    attempt = 1
    copilot_invocation_count = 0

    while True:
        if is_shutdown_requested():
            print("[atomic_executor] Shutdown requested during pre-flight QC.")
            return 130

        if max_fix_attempts > 0 and attempt > max_fix_attempts:
            msg = f"Pre-flight QC fix failed after {max_fix_attempts} attempts."
            print(msg, file=sys.stderr)
            log_msg(log_file, f"ERROR: {msg}")
            return 6

        print("Running pre-flight QC check...")
        log_msg(log_file, "INFO: Running pre-flight QC check")

        preflight_check: PreflightQCResult | None = None
        for toolchain in toolchains:
            preflight_check = run_preflight_qc_with_capture(
                workspace,
                expectations=expectations,
                toolchain=toolchain,
            )
            if not preflight_check.success:
                break
        if preflight_check is None or preflight_check.success:
            print("Pre-flight QC passed.")
            log_msg(log_file, "INFO: Pre-flight QC passed")
            return 0

        qc_output = preflight_check.output
        failed_toolchain = preflight_check.toolchain

        if MISSING_EXECUTABLE_PREFIX in qc_output:
            missing_line = next(
                (
                    line
                    for line in qc_output.splitlines()
                    if MISSING_EXECUTABLE_PREFIX in line
                ),
                qc_output,
            )
            err_msg = (
                "Pre-flight QC cannot run because a required executable "
                f"is missing. {missing_line}"
            )
            print(err_msg, file=sys.stderr)
            log_msg(log_file, f"ERROR: {err_msg}")
            return 6

        limit_str = str(max_fix_attempts) if max_fix_attempts > 0 else "∞"
        msg = (
            f"Pre-flight QC failed (attempt {attempt}/{limit_str}), "
            "invoking Copilot to fix..."
        )
        print(msg)
        log_msg(log_file, f"WARN: {msg}")

        prompt_text = build_preflight_qc_fix_prompt(
            workspace,
            qc_output,
            toolchain=failed_toolchain,
        )

        prompt_dir = workspace / LOG_DIR / "prompts"
        prompt_dir.mkdir(parents=True, exist_ok=True)
        prompt_file = prompt_dir / f"prompt_{run_id}_preflight_{attempt}.md"
        prompt_file.write_text(prompt_text, encoding="utf-8")

        throttle_retries = 0
        while True:
            if is_shutdown_requested():
                print("[atomic_executor] Shutdown requested during pre-flight QC.")
                return 130

            copilot_rate_limiter.acquire()
            copilot_result = run_copilot(
                workspace=workspace,
                prompt_text=prompt_text,
                log_file=log_file,
                task_id=f"preflight-{attempt}",
                preferred_model=preferred_model,
                run_id=run_id,
                resume_session=(copilot_invocation_count > 0),
                is_first_task=(copilot_invocation_count == 0),
                allow_all_paths=copilot_allow_all_paths,
                allow_all_urls=copilot_allow_all_urls,
                allow_shell=copilot_allow_shell,
                trust_workspace=copilot_trust_workspace,
                _output_tail_bytes=copilot_output_tail_bytes,
            )
            copilot_invocation_count += 1

            if copilot_result.exit_code == 0:
                copilot_backoff.on_success()
                break

            failure_kind = classify_copilot_failure(
                exit_code=copilot_result.exit_code,
                output_tail=copilot_result.output_tail,
            )
            if failure_kind is FailureKind.NON_THROTTLE:
                err_msg = (
                    "Copilot CLI failed (non-throttle) during pre-flight fix. "
                    f"exit_code={copilot_result.exit_code}. "
                    f"output_tail={copilot_result.output_tail!r}"
                )
                print(err_msg, file=sys.stderr)
                log_msg(log_file, f"ERROR: {err_msg}")
                return 6

            effective_max_retries = (
                0 if copilot_max_retries < 0 else copilot_max_retries
            )
            if throttle_retries >= effective_max_retries:
                err_msg = (
                    "Copilot CLI throttled during pre-flight fix, "
                    f"max retries ({effective_max_retries}) exhausted."
                )
                print(err_msg, file=sys.stderr)
                log_msg(log_file, f"ERROR: {err_msg}")
                return 6

            delay_seconds = copilot_backoff.on_throttle()
            throttle_retries += 1
            retry_msg = (
                f"Copilot throttled during pre-flight fix; retry "
                f"{throttle_retries}/{effective_max_retries} after "
                f"{delay_seconds:.2f}s backoff."
            )
            print(retry_msg)
            log_msg(log_file, f"WARN: {retry_msg}")
            if delay_seconds > 0:
                copilot_rate_limiter.sleeper.sleep(delay_seconds)

        print("Copilot completed, verifying QC...")
        log_msg(log_file, "INFO: Verifying QC after Copilot pre-flight fix")
        attempt += 1


def execute_auto_qc_phase(
    *,
    workspace: Path,
    phase: AutoQCPhase,
    parser: PlanParser,
    qc_runner: QCRunner,
    log_file: Path,
    feature_dir: Path,
    preferred_model: str | None,
    run_id: str,
    copilot_rate_limiter: CallRateLimiter,
    copilot_backoff: ExponentialBackoff,
    copilot_max_retries: int,
    copilot_output_tail_bytes: int,
    copilot_allow_shell: bool,
    copilot_allow_all_paths: bool,
    copilot_allow_all_urls: bool,
    copilot_trust_workspace: bool,
    max_fix_attempts: int,
    print_prompt: bool = False,
    copy_prompt: bool = False,
    is_first_task: bool = True,
) -> int:
    """Execute an auto-detected QC phase without per-task LLM calls."""
    if print_prompt or copy_prompt:
        print(
            "Auto-QC phase detected; no prompt is generated for this task.",
            file=sys.stderr,
        )
        return 0

    attempt = 1
    while True:
        if max_fix_attempts > 0 and attempt > max_fix_attempts:
            msg = (
                f"Failed to complete auto-QC phase {phase.phase} after "
                f"{max_fix_attempts} attempts."
            )
            print(msg, file=sys.stderr)
            log_msg(log_file, f"ERROR: {msg}")
            print(f"See log: {log_file}", file=sys.stderr)
            return 5

        try:
            result = qc_runner.run_full_loop_with_artifacts(
                artifact_paths=phase.artifact_paths,
                toolchain=phase.toolchain,
            )
        except RuntimeError as exc:
            err_msg = f"Auto-QC phase {phase.phase} failed: {exc}"
            print(err_msg, file=sys.stderr)
            log_msg(log_file, f"ERROR: {err_msg}")
            return 5

        if result.success:
            for task_id in phase.task_ids:
                current_task = parser.find_task_by_id(task_id)
                if not current_task.checked:
                    parser.flip_checkbox(current_task)
            success_msg = f"Auto-QC phase {phase.phase} complete and gated."
            print(success_msg)
            log_msg(log_file, f"SUCCESS: {success_msg}")
            return 0

        if result.failure is None:
            err_msg = f"Auto-QC phase {phase.phase} failed without error details."
            print(err_msg, file=sys.stderr)
            log_msg(log_file, f"ERROR: {err_msg}")
            return 5

        prompt_text = _build_qc_fix_prompt(
            feature_dir=feature_dir,
            phase=phase,
            failure=result,
        )

        copilot_invocation = 0
        throttle_retries = 0
        while True:
            copilot_rate_limiter.acquire()
            copilot_result = run_copilot(
                workspace=workspace,
                prompt_text=prompt_text,
                log_file=log_file,
                task_id=f"AUTO-QC-P{phase.phase}",
                preferred_model=preferred_model,
                run_id=run_id,
                resume_session=(attempt > 1 or copilot_invocation > 0),
                is_first_task=is_first_task,
                allow_all_paths=copilot_allow_all_paths,
                allow_all_urls=copilot_allow_all_urls,
                allow_shell=copilot_allow_shell,
                trust_workspace=copilot_trust_workspace,
                _output_tail_bytes=copilot_output_tail_bytes,
            )
            copilot_invocation += 1

            if copilot_result.exit_code == 0:
                copilot_backoff.on_success()
                break

            failure_kind = classify_copilot_failure(
                exit_code=copilot_result.exit_code,
                output_tail=copilot_result.output_tail,
            )
            if failure_kind is FailureKind.NON_THROTTLE:
                err_msg = (
                    "Copilot CLI failed (non-throttle) while fixing auto-QC. "
                    f"exit_code={copilot_result.exit_code}. "
                    f"output_tail={copilot_result.output_tail!r}"
                )
                print(err_msg, file=sys.stderr)
                log_msg(log_file, f"ERROR: {err_msg}")
                print(f"See log: {log_file}", file=sys.stderr)
                return 5

            effective_max_retries = (
                0 if copilot_max_retries < 0 else copilot_max_retries
            )
            if throttle_retries >= effective_max_retries:
                err_msg = (
                    "Copilot CLI appears throttled during auto-QC fixes, "
                    f"max retries ({effective_max_retries}) exhausted."
                )
                print(err_msg, file=sys.stderr)
                log_msg(log_file, f"ERROR: {err_msg}")
                print(f"See log: {log_file}", file=sys.stderr)
                return 5

            delay_seconds = copilot_backoff.on_throttle()
            throttle_retries += 1
            retry_msg = (
                "Copilot throttled during auto-QC fixes; retry "
                f"{throttle_retries}/{effective_max_retries} after "
                f"{delay_seconds:.2f}s backoff."
            )
            print(retry_msg)
            log_msg(log_file, f"WARN: {retry_msg}")
            if delay_seconds > 0:
                copilot_rate_limiter.sleeper.sleep(delay_seconds)

        attempt += 1
