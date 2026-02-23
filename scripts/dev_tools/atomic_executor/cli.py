"""
CLI entry point and orchestration for atomic executor.

Provides argument parsing, workspace validation, and main execution loop
that coordinates PlanParser, FeatureResolver, QCRunner, and PromptBuilder.
"""

from __future__ import annotations

import signal
import subprocess
import sys
from pathlib import Path
from typing import TYPE_CHECKING, Any, cast

from scripts.dev_tools.atomic_executor import cli_copilot_runtime as _copilot_runtime

# Compatibility alias for tests that patch cli._log_msg.
from scripts.dev_tools.atomic_executor.cli_copilot_runtime import log_msg as _log_msg
from scripts.dev_tools.atomic_executor.cli_execute_one_task import (
    execute_one_task as _execute_one_task_impl,
)
from scripts.dev_tools.atomic_executor.cli_preflight import (
    MISSING_EXECUTABLE_PREFIX,
    PreflightQCResult,
    build_preflight_qc_fix_prompt,
    resolve_plan_expectations,
    resolve_preflight_toolchains,
    run_preflight_qc_with_capture,
)
from scripts.dev_tools.atomic_executor.cli_task_runtime import (
    first_non_read_task,
    is_phase0_read_task,
    phase0_read_tasks,
    run_preflight_qc_fix_loop,
)
from scripts.dev_tools.atomic_executor.cli_workspace import (
    acquire_executor_lock,
    copy_to_clipboard,
    ensure_clean_tree,
    parse_args,
    refuse_protected_branch,
    release_executor_lock,
)
from scripts.dev_tools.atomic_executor.cli_workspace import (
    resolve_workspace as _resolve_workspace_impl,
)
from scripts.dev_tools.atomic_executor.copilot_throttling import (
    CallRateLimiter,
    ExponentialBackoff,
    SystemClock,
    SystemRandom,
    TimeSleeper,
)
from scripts.dev_tools.atomic_executor.feature_resolver import FeatureResolver
from scripts.dev_tools.atomic_executor.plan_discovery import resolve_feature_plan
from scripts.dev_tools.atomic_executor.plan_parser import (
    PlanParser,
)
from scripts.dev_tools.atomic_executor.prompt_builder import PromptBuilder
from scripts.dev_tools.atomic_executor.qc_runner import QCRunner

if TYPE_CHECKING:
    from scripts.dev_tools.atomic_executor.cli_copilot_runtime import CopilotRunResult

_STREAM_ATTR = "_stream_copilot_output"
_CLEAN_ATTR = "_clean_session_file"
_SUPPORTS_ATTR = "_supports_continue_sessions"

_ORIGINAL_STREAM_FN = getattr(_copilot_runtime, _STREAM_ATTR)
_ORIGINAL_CLEAN_FN = getattr(_copilot_runtime, _CLEAN_ATTR, None)
_ORIGINAL_SUPPORTS_FN = getattr(_copilot_runtime, _SUPPORTS_ATTR, None)


def _stream_copilot_output(**kwargs: object) -> tuple[int, str]:
    """Compatibility proxy for Copilot output streaming internals."""
    return _ORIGINAL_STREAM_FN(**kwargs)


def _clean_session_file(*args: object, **kwargs: object) -> None:
    """Compatibility proxy for optional session-file cleanup helper."""
    if callable(_ORIGINAL_CLEAN_FN):
        _ORIGINAL_CLEAN_FN(*args, **kwargs)


def _supports_continue_sessions() -> bool:
    """Compatibility proxy for session-continuation capability checks."""
    if callable(_ORIGINAL_SUPPORTS_FN):
        return bool(_ORIGINAL_SUPPORTS_FN())
    return False


__all__ = [
    "MISSING_EXECUTABLE_PREFIX",
    "PreflightQCResult",
    "copy_to_clipboard",
    "ensure_clean_tree",
    "_build_preflight_qc_fix_prompt",
    "_run_preflight_qc_fix_loop",
    "_run_preflight_qc_with_capture",
    "parse_args",
    "refuse_protected_branch",
    "run_copilot",
    "resolve_workspace",
]

DEFAULT_PROMPT_TEMPLATE = ".github/prompts/execute-plan-template.md"
LOG_DIR = ".agent_logs"

# Safe, bounded defaults for Copilot CLI throttling controls (issue #80).
DEFAULT_COPILOT_CLI_MAX_CALLS_PER_WINDOW = 6
DEFAULT_COPILOT_CLI_WINDOW_SECONDS = 60.0
DEFAULT_COPILOT_CLI_BACKOFF_BASE_SECONDS = 2.0
DEFAULT_COPILOT_CLI_BACKOFF_MAX_SECONDS = 60.0
DEFAULT_COPILOT_CLI_OUTPUT_TAIL_BYTES = 4096
DEFAULT_COPILOT_CLI_MAX_RETRIES = 8
DEFAULT_COPILOT_AGENT = "atomic_executor"
DEFAULT_COPILOT_ALLOW_SHELL = True
DEFAULT_COPILOT_ALLOW_ALL_PATHS = True
DEFAULT_COPILOT_ALLOW_ALL_URLS = False
DEFAULT_COPILOT_TRUST_WORKSPACE = True

_shutdown_requested = False
_active_lock_path: Path | None = None


def _handle_shutdown_signal(signum: int, frame: object) -> None:
    """Handle shutdown signals and release any active executor lock."""
    global _shutdown_requested
    _shutdown_requested = True
    sig_name = signal.Signals(signum).name if hasattr(signal, "Signals") else signum
    print(f"\n[atomic_executor] Received {sig_name}, shutting down gracefully...")
    # Release lock immediately to avoid stale locks on forced termination
    if _active_lock_path is not None:
        release_executor_lock(_active_lock_path)


def is_shutdown_requested() -> bool:
    """Check if graceful shutdown has been requested via signal."""
    return _shutdown_requested


def resolve_workspace(workspace_arg: str | None) -> Path:
    """Resolve workspace root using cli module path semantics."""
    if workspace_arg:
        return _resolve_workspace_impl(workspace_arg)
    return Path(__file__).resolve().parents[3]


_build_preflight_qc_fix_prompt = build_preflight_qc_fix_prompt
_run_preflight_qc_with_capture = run_preflight_qc_with_capture


def run_copilot(
    *,
    workspace: Path,
    prompt_text: str,
    log_file: Path,
    task_id: str,
    preferred_model: str | None,
    run_id: str,
    resume_session: bool = False,
    is_first_task: bool = True,
    allow_all_paths: bool = True,
    allow_all_urls: bool = False,
    allow_shell: bool = True,
    trust_workspace: bool = True,
    _idle_timeout_seconds: float | None = None,
    _output_tail_bytes: int | None = None,
) -> CopilotRunResult:
    """Forward Copilot invocations through patchable compatibility hooks."""
    _copilot_runtime.Path = Path
    _copilot_runtime.subprocess = subprocess
    setattr(_copilot_runtime, _STREAM_ATTR, _stream_copilot_output)
    setattr(_copilot_runtime, _CLEAN_ATTR, _clean_session_file)
    setattr(_copilot_runtime, _SUPPORTS_ATTR, _supports_continue_sessions)
    return _copilot_runtime.run_copilot(
        workspace=workspace,
        prompt_text=prompt_text,
        log_file=log_file,
        task_id=task_id,
        preferred_model=preferred_model,
        run_id=run_id,
        resume_session=resume_session,
        is_first_task=is_first_task,
        allow_all_paths=allow_all_paths,
        allow_all_urls=allow_all_urls,
        allow_shell=allow_shell,
        trust_workspace=trust_workspace,
        _idle_timeout_seconds=_idle_timeout_seconds,
        _output_tail_bytes=_output_tail_bytes,
    )


def execute_one_task(*args: object, **kwargs: object) -> int:
    """Call execute_one_task with patch-aware Copilot/log hooks."""
    forwarded_kwargs = dict(kwargs)
    forwarded_kwargs.setdefault("run_copilot_fn", run_copilot)
    forwarded_kwargs.setdefault("log_msg_fn", _log_msg)
    executor = cast(Any, _execute_one_task_impl)
    return cast(int, executor(*args, **forwarded_kwargs))


_run_preflight_qc_fix_loop = run_preflight_qc_fix_loop


def main(argv: list[str] | None = None) -> int:
    """
    Main entry point for atomic executor CLI.

    Purpose:
        Orchestrates feature folder resolution, plan parsing, QC execution,
        and Copilot invocation for one task at a time.

    Args:
        argv (list[str]): Command-line arguments.

    Returns:
        int: Exit code (0 for success, non-zero for error).

    Side Effects:
        - Validates workspace state (git clean, not on protected branch)
        - Parses and modifies plan.md
        - Runs QC toolchains
        - Invokes Copilot CLI
        - Writes log files
    """
    if argv is None:
        argv = sys.argv[1:]
    args = parse_args(argv)
    workspace = resolve_workspace(args.workspace)

    # Preconditions: not on protected branch
    # ensure_clean_tree(workspace) - Disabled to allow mid-execution restarts
    refuse_protected_branch(workspace)

    # Resolve feature folder
    active_dir = workspace / "docs" / "features" / "active"
    resolver = FeatureResolver(workspace, active_dir)
    _, feature_dir = resolver.resolve(args.path, args.feature)

    try:
        resolved_plan = resolve_feature_plan(feature_dir)
    except FileNotFoundError as exc:
        print(str(exc), file=sys.stderr)
        return 2

    plan_path = resolved_plan.path
    prompt_template_path = (workspace / args.prompt_template).resolve()

    if not prompt_template_path.is_file():
        print(
            f"Prompt template not found: {prompt_template_path}",
            file=sys.stderr,
        )
        return 2

    # Setup logging
    log_dir = workspace / LOG_DIR
    log_dir.mkdir(exist_ok=True)
    import datetime

    run_id = datetime.datetime.now().strftime("%Y-%m-%d_%H%M%S")
    log_file = log_dir / f"atomic_executor_{run_id}.log"

    lock_path: Path | None = None
    # Declare global for signal handler to access; set below if execute-all
    global _active_lock_path
    if args.cmd == "execute-all":
        lock_path = acquire_executor_lock(workspace)
        _active_lock_path = lock_path

    # Register signal handlers for graceful shutdown (Ctrl+C, kill)
    signal.signal(signal.SIGINT, _handle_shutdown_signal)
    signal.signal(signal.SIGTERM, _handle_shutdown_signal)

    try:
        # Parse plan and preflight validate
        parser = PlanParser(plan_path)
        parser.preflight_validate()

        # Determine current task
        if args.cmd == "resume" or args.cmd == "execute-all":
            cur = parser.next_unchecked_task()
            if cur is None:
                print("Plan already complete: no unchecked tasks found.")
                return 0
        else:
            if args.start:
                cur = parser.find_task_by_id(args.start)
            else:
                cur = parser.next_unchecked_task()
                if cur is None:
                    print("Plan already complete: no unchecked tasks found.")
                    return 0

        include_phase0_reads = False
        phase0_reads = phase0_read_tasks(parser)
        if phase0_reads:
            include_phase0_reads = True

        # Bundle Phase 0 read tasks with the first non-read task on session start.
        if include_phase0_reads and is_phase0_read_task(cur):
            non_read_task = first_non_read_task(parser)
            if non_read_task is not None:
                cur = non_read_task

        builder = PromptBuilder(
            workspace,
            prompt_template_path,
            preferred_model=args.preferred_model,
        )
        qc_runner = QCRunner(workspace)
        preflight_expectations = resolve_plan_expectations(parser)
        preflight_toolchains = resolve_preflight_toolchains(parser)

        # Per-run throttling controls. The limiter must persist across tasks to
        # regulate overall call cadence.
        copilot_rate_limiter = CallRateLimiter(
            max_calls=args.copilot_cli_max_calls_per_window,
            window_seconds=args.copilot_cli_window_seconds,
            clock=SystemClock(),
            sleeper=TimeSleeper(),
        )

        # Pre-flight QC: run full toolchain before task execution
        # If baseline fails, enter fix loop with Copilot
        if not args.skip_preflight_qc:
            # Backoff state for pre-flight Copilot invocations
            preflight_backoff = ExponentialBackoff(
                base_seconds=args.copilot_cli_backoff_base_seconds,
                max_seconds=args.copilot_cli_backoff_max_seconds,
                random_source=SystemRandom(),
            )
            preflight_result = _run_preflight_qc_fix_loop(
                workspace=workspace,
                log_file=log_file,
                run_id=run_id,
                preferred_model=args.preferred_model,
                copilot_rate_limiter=copilot_rate_limiter,
                copilot_backoff=preflight_backoff,
                copilot_max_retries=args.copilot_cli_max_retries,
                copilot_output_tail_bytes=args.copilot_cli_output_tail_bytes,
                copilot_allow_shell=args.copilot_allow_shell,
                copilot_allow_all_paths=args.copilot_allow_all_paths,
                copilot_allow_all_urls=args.copilot_allow_all_urls,
                copilot_trust_workspace=args.copilot_trust_workspace,
                max_fix_attempts=args.max_fix_attempts,
                expectations=preflight_expectations,
                toolchains=preflight_toolchains,
                shutdown_requested=is_shutdown_requested,
            )
            if preflight_result != 0:
                return preflight_result

        is_first_task = True

        while True:
            # Check for graceful shutdown request (Ctrl+C or SIGTERM)
            if is_shutdown_requested():
                print("[atomic_executor] Shutdown requested, exiting after cleanup.")
                return 130  # Standard exit code for SIGINT

            # Backoff state is per-task; it resets after successful Copilot invocations.
            copilot_backoff = ExponentialBackoff(
                base_seconds=args.copilot_cli_backoff_base_seconds,
                max_seconds=args.copilot_cli_backoff_max_seconds,
                random_source=SystemRandom(),
            )

            # Build prompt and execute
            result = execute_one_task(
                workspace=workspace,
                cur=cur,
                parser=parser,
                builder=builder,
                qc_runner=qc_runner,
                log_file=log_file,
                prompt_template_path=prompt_template_path,
                max_fix_attempts=args.max_fix_attempts,
                feature_dir=feature_dir,
                preferred_model=args.preferred_model,
                run_id=run_id,
                copilot_rate_limiter=copilot_rate_limiter,
                copilot_backoff=copilot_backoff,
                copilot_max_retries=args.copilot_cli_max_retries,
                copilot_output_tail_bytes=args.copilot_cli_output_tail_bytes,
                copilot_allow_shell=args.copilot_allow_shell,
                copilot_allow_all_paths=args.copilot_allow_all_paths,
                copilot_allow_all_urls=args.copilot_allow_all_urls,
                copilot_trust_workspace=args.copilot_trust_workspace,
                include_phase0_reads=include_phase0_reads and is_first_task,
                print_prompt=args.print_prompt,
                copy_prompt=args.copy_prompt,
                is_first_task=is_first_task,
                shutdown_requested=is_shutdown_requested,
                copy_to_clipboard_fn=copy_to_clipboard,
                run_copilot_fn=run_copilot,
                log_msg_fn=_log_msg,
            )

            if result != 0:
                return result

            # Stop here if interactive command (print/copy)
            if args.print_prompt or args.copy_prompt:
                return 0

            # Check phase completion after task success
            if parser.phase_complete(cur.phase):
                is_auto_qc = False
                # Avoid MagicMock truthiness by explicitly calling the checker.
                auto_qc_phase_check = getattr(parser, "is_auto_qc_phase", None)
                if callable(auto_qc_phase_check):
                    phase_candidate = auto_qc_phase_check(cur.phase)
                    if isinstance(phase_candidate, bool):
                        is_auto_qc = phase_candidate

                if is_auto_qc:
                    print(f"Phase {cur.phase} complete (auto-QC handled by executor).")
                else:
                    print(f"Phase {cur.phase} complete -> running full toolchain...")
                    try:
                        phase_expectations = resolve_plan_expectations(parser)
                        for toolchain in preflight_toolchains:
                            qc_runner.run_full(
                                expectations=phase_expectations,
                                toolchain=toolchain,
                            )
                    except subprocess.CalledProcessError as e:
                        print(
                            f"Full QC failed after completing Phase {cur.phase}: {e}",
                            file=sys.stderr,
                        )
                        return 5

            # If not execute-all, we are done after one task
            if args.cmd != "execute-all":
                print("Next: run 'resume' for the next task.")
                return 0

            # If execute-all, find next task
            next_task = parser.next_unchecked_task()
            if next_task is None:
                print("All tasks complete.")
                return 0
            cur = next_task
            is_first_task = False
            include_phase0_reads = False
            print(f"Proceeding to next task: {cur.task_id}...")
    finally:
        # Clear global and release lock
        _active_lock_path = None
        if lock_path is not None:
            release_executor_lock(lock_path)


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
