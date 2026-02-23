"""Single-task execution helper for atomic executor CLI."""

from __future__ import annotations

import subprocess
import sys
from typing import TYPE_CHECKING

from scripts.dev_tools.atomic_executor.cli_copilot_runtime import log_msg, run_copilot
from scripts.dev_tools.atomic_executor.cli_preflight import resolve_plan_expectations
from scripts.dev_tools.atomic_executor.cli_task_runtime import execute_auto_qc_phase
from scripts.dev_tools.atomic_executor.copilot_throttling import (
    CallRateLimiter,
    ExponentialBackoff,
    FailureKind,
    classify_copilot_failure,
)
from scripts.dev_tools.atomic_executor.plan_parser import AutoQCPhase

if TYPE_CHECKING:
    from collections.abc import Callable
    from pathlib import Path

    from scripts.dev_tools.atomic_executor.cli_copilot_runtime import CopilotRunResult
    from scripts.dev_tools.atomic_executor.plan_parser import PlanParser, PlanTask
    from scripts.dev_tools.atomic_executor.prompt_builder import PromptBuilder
    from scripts.dev_tools.atomic_executor.qc_runner import QCRunner


def execute_one_task(
    workspace: Path,
    cur: PlanTask,
    parser: PlanParser,
    builder: PromptBuilder,
    qc_runner: QCRunner,
    log_file: Path,
    prompt_template_path: Path,
    max_fix_attempts: int,
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
    include_phase0_reads: bool,
    print_prompt: bool = False,
    copy_prompt: bool = False,
    is_first_task: bool = True,
    shutdown_requested: Callable[[], bool] | None = None,
    copy_to_clipboard_fn: Callable[[str], bool] | None = None,
    run_copilot_fn: Callable[..., CopilotRunResult] | None = None,
    log_msg_fn: Callable[[Path, str], None] | None = None,
) -> int:
    """Execute a single atomic task with retries."""
    is_shutdown_requested = shutdown_requested or (lambda: False)
    run_copilot_impl = run_copilot if run_copilot_fn is None else run_copilot_fn
    log_msg_impl = log_msg if log_msg_fn is None else log_msg_fn

    if print_prompt or copy_prompt:
        prompt_text = builder.build(
            feature_dir,
            cur,
            include_phase0_reads=include_phase0_reads,
        )
        if print_prompt:
            print(prompt_text)
            return 0

        if copy_prompt:
            if copy_to_clipboard_fn is None:
                from scripts.dev_tools.atomic_executor.cli_workspace import (
                    copy_to_clipboard as _copy_to_clipboard,
                )

                copy_to_clipboard_fn = _copy_to_clipboard

            ok = copy_to_clipboard_fn(prompt_text)
            if not ok:
                print(
                    "Clipboard copy not available; prompt printed below.",
                    file=sys.stderr,
                )
                print(prompt_text)
            else:
                print(
                    f"Prompt copied to clipboard for task {cur.task_id}.",
                    file=sys.stderr,
                )
            return 0

    auto_qc_phase: AutoQCPhase | None = None
    auto_qc_lookup = getattr(parser, "auto_qc_phase_for_task", None)
    if callable(auto_qc_lookup):
        candidate = auto_qc_lookup(cur)
        if isinstance(candidate, AutoQCPhase):
            auto_qc_phase = candidate
    if auto_qc_phase:
        return execute_auto_qc_phase(
            workspace=workspace,
            phase=auto_qc_phase,
            parser=parser,
            qc_runner=qc_runner,
            log_file=log_file,
            feature_dir=feature_dir,
            preferred_model=preferred_model,
            run_id=run_id,
            copilot_rate_limiter=copilot_rate_limiter,
            copilot_backoff=copilot_backoff,
            copilot_max_retries=copilot_max_retries,
            copilot_output_tail_bytes=copilot_output_tail_bytes,
            copilot_allow_shell=copilot_allow_shell,
            copilot_allow_all_paths=copilot_allow_all_paths,
            copilot_allow_all_urls=copilot_allow_all_urls,
            copilot_trust_workspace=copilot_trust_workspace,
            max_fix_attempts=max_fix_attempts,
            print_prompt=print_prompt,
            copy_prompt=copy_prompt,
            is_first_task=is_first_task,
        )

    attempt = 1
    retry_ctx = None

    while True:
        if is_shutdown_requested():
            print(f"[atomic_executor] Shutdown requested, exiting task {cur.task_id}.")
            return 130

        if max_fix_attempts > 0 and attempt > max_fix_attempts:
            msg = (
                f"Failed to complete task {cur.task_id} after "
                f"{max_fix_attempts} attempts."
            )
            print(msg, file=sys.stderr)
            log_msg_impl(log_file, f"ERROR: {msg}")
            print(f"See log: {log_file}", file=sys.stderr)
            return 5

        prompt_text = builder.build(
            feature_dir,
            cur,
            retry_context=retry_ctx,
            include_phase0_reads=include_phase0_reads,
        )

        limit_str = str(max_fix_attempts) if max_fix_attempts > 0 else "∞"
        msg = f"Executing task {cur.task_id} (attempt {attempt}/{limit_str})"
        print(msg)
        log_msg_impl(log_file, f"INFO: {msg}")

        copilot_invocation = 0
        throttle_retries = 0

        while True:
            if is_shutdown_requested():
                print(f"[atomic_executor] Shutdown at task {cur.task_id}.")
                return 130

            copilot_rate_limiter.acquire()

            copilot_result = run_copilot_impl(
                workspace=workspace,
                prompt_text=prompt_text,
                log_file=log_file,
                task_id=cur.task_id,
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
                    "Copilot CLI failed (non-throttle). "
                    f"exit_code={copilot_result.exit_code}. "
                    f"output_tail={copilot_result.output_tail!r}"
                )
                print(err_msg, file=sys.stderr)
                log_msg_impl(log_file, f"ERROR: {err_msg}")
                print(f"See log: {log_file}", file=sys.stderr)
                return 5

            effective_max_retries = copilot_max_retries
            if effective_max_retries < 0:
                effective_max_retries = 0

            if throttle_retries >= effective_max_retries:
                err_msg = (
                    f"Copilot CLI appears throttled, but max retries "
                    f"({effective_max_retries}) were exhausted for task {cur.task_id}."
                )
                print(err_msg, file=sys.stderr)
                log_msg_impl(log_file, f"ERROR: {err_msg}")
                print(f"See log: {log_file}", file=sys.stderr)
                return 5

            delay_seconds = copilot_backoff.on_throttle()
            throttle_retries += 1

            retry_msg = (
                f"Copilot throttled for task {cur.task_id}; retry "
                f"{throttle_retries}/{effective_max_retries} after "
                f"{delay_seconds:.2f}s backoff."
            )
            print(retry_msg)
            log_msg_impl(log_file, f"WARN: {retry_msg}")

            if delay_seconds > 0:
                copilot_rate_limiter.sleeper.sleep(delay_seconds)

        cur_after = parser.find_task_by_id(cur.task_id)

        try:
            scoped_expectations = resolve_plan_expectations(parser)
            qc_runner.run_scoped(expectations=scoped_expectations)
            if cur.expect_fail:
                changed_files = qc_runner.changed_files()
                ts_test_files = [
                    p
                    for p in changed_files
                    if (p.startswith("tests/") or "/tests/" in p)
                    and (p.endswith(".test.ts") or p.endswith(".spec.ts"))
                ]

                if ts_test_files:
                    jest_summary = qc_runner.check_jest_skipped_tests(
                        test_files=ts_test_files
                    )
                    if jest_summary.skipped_count > 0:
                        success_msg = (
                            f"Task {cur.task_id} has {jest_summary.skipped_count} "
                            f"skipped Jest tests (TDD Red). Verified."
                        )
                        print(success_msg)
                        log_msg_impl(log_file, f"SUCCESS: {success_msg}")

                        if cur_after and not cur_after.checked:
                            parser.flip_checkbox(cur_after)
                        return 0

                err_msg = (
                    f"Task {cur.task_id} expected failure (TDD Red) but QC passed."
                )
                print(err_msg, file=sys.stderr)
                log_msg_impl(log_file, f"WARN: {err_msg}")

                retry_ctx = (
                    f"Attempt {attempt}: Expected pytest failure but all QC passed.\n"
                    "The test should fail to verify the TDD Red condition."
                )
                attempt += 1
                continue
        except subprocess.CalledProcessError as e:
            cmd_str = (
                e.cmd if isinstance(e.cmd, str) else " ".join(str(arg) for arg in e.cmd)
            )
            is_pytest_failure = "pytest" in cmd_str
            is_npm_failure = "npm" in cmd_str and "test" in cmd_str

            if cur.expect_fail and (is_pytest_failure or is_npm_failure):
                success_msg = (
                    f"Task {cur.task_id} failed as expected (TDD Red). Verified."
                )
                print(success_msg)
                log_msg_impl(log_file, f"SUCCESS: {success_msg}")

                if cur_after and not cur_after.checked:
                    parser.flip_checkbox(cur_after)
                return 0

            err_msg = f"Scoped QC failed for task {cur.task_id}: {e}"
            print(err_msg, file=sys.stderr)
            log_msg_impl(log_file, f"WARN: {err_msg}")

            retry_ctx = (
                f"Attempt {attempt} failed verification.\n"
                f"Error: {e}\n"
                "Please fix code/test issues and try again."
            )
            attempt += 1
            continue

        if cur_after and not cur_after.checked:
            parser.flip_checkbox(cur_after)

        success_msg = f"Task {cur.task_id} complete and gated."
        print(success_msg)
        log_msg_impl(log_file, f"SUCCESS: {success_msg}")
        return 0
