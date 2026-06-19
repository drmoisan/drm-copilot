"""Runtime orchestration for the fix-all workflow."""

from __future__ import annotations

import threading
from typing import TYPE_CHECKING, cast

from . import fix_all_branches as branches
from . import fix_all_branches_extra as branches_extra

if TYPE_CHECKING:
    from collections.abc import Callable

    from .fix_all import BranchResult, CommandRunner, StepLogger


def run_fix_all(
    *,
    max_ruff_retries: int = 3,
    max_black_retries: int = 3,
    include_coverage: bool = True,
    runner_factory: Callable[[str, StepLogger], CommandRunner] | None = None,
    logger: StepLogger | None = None,
    complete_all: bool = False,
) -> int:
    """Run the fix-all pipeline in parallel branches."""
    from . import fix_all as api

    step_logger = logger or api.StepLogger()
    cancel_event = threading.Event()
    stream_isatty = api.stream_isatty(step_logger.stream)
    use_interactive_board = api.should_use_interactive_board(
        isatty=stream_isatty,
        vt_enabled=api.is_vt_enabled_for_stream(step_logger.stream),
    )
    status_lock = threading.Lock()
    status_by_branch = {
        "json": "pending",
        "shell": "pending",
        "python": "pending",
        "powershell": "pending",
        "typescript": "pending",
    }
    has_rendered_board = False

    def emit_status_transition(branch: str, status: str) -> None:
        nonlocal has_rendered_board

        if use_interactive_board:
            with status_lock:
                status_by_branch[branch] = status
                lines = [
                    f"{name}: {status_by_branch[name]}"
                    for name in (
                        "json",
                        "shell",
                        "python",
                        "powershell",
                        "typescript",
                    )
                ]
                width = max(len(line) for line in lines) if lines else 1
                board = api.render_status_board(lines, width=width)
                line_count = len(lines) if has_rendered_board else 0
                redraw = api.format_ansi_redraw(board, line_count=line_count)
                step_logger.stream.write(redraw)
                step_logger.stream.flush()
                has_rendered_board = True
            return

        line = api.format_status_transition_line(branch, status)
        print(line, file=step_logger.stream)

    def factory(branch_name: str, branch_logger: StepLogger) -> CommandRunner:
        if runner_factory is not None:
            return runner_factory(branch_name, branch_logger)
        return cast(
            "CommandRunner",
            api.SubprocessCommandRunner(
                branch_logger, cancel_event=None if complete_all else cancel_event
            ),
        )

    # Bind the extracted module-level branch functions with this call's
    # captured locals. Each adapter forwards to the matching function in
    # fix_all_branches / fix_all_branches_extra, preserving status-board,
    # cancel, and coverage behavior. The json branch is the only one that
    # reads cancel_event / complete_all.
    def run_json_branch() -> BranchResult:
        return branches.run_json_branch(
            factory=factory,
            emit_status_transition=emit_status_transition,
            cancel_event=cancel_event,
            complete_all=complete_all,
            api=api,
        )

    def run_shell_branch() -> BranchResult:
        return branches.run_shell_branch(
            factory=factory,
            emit_status_transition=emit_status_transition,
            api=api,
        )

    def run_python_branch() -> BranchResult:
        return branches_extra.run_python_branch(
            factory=factory,
            emit_status_transition=emit_status_transition,
            include_coverage=include_coverage,
            max_black_retries=max_black_retries,
            max_ruff_retries=max_ruff_retries,
            api=api,
        )

    def run_powershell_branch() -> BranchResult:
        return branches.run_powershell_branch(
            factory=factory,
            emit_status_transition=emit_status_transition,
            api=api,
        )

    def run_typescript_branch() -> BranchResult:
        return branches_extra.run_typescript_branch(
            factory=factory,
            emit_status_transition=emit_status_transition,
            include_coverage=include_coverage,
            api=api,
        )

    branch_functions = [
        ("json", run_json_branch),
        ("shell", run_shell_branch),
        ("python", run_python_branch),
        ("powershell", run_powershell_branch),
        ("typescript", run_typescript_branch),
    ]

    results: dict[str, BranchResult] = {}
    threads: list[threading.Thread] = []

    def _runner(name: str, func: Callable[[], BranchResult]) -> None:
        result = func()
        results[name] = result
        if not result.success and not complete_all:
            cancel_event.set()

    for name, func in branch_functions:
        thread = threading.Thread(target=_runner, args=(name, func), daemon=True)
        threads.append(thread)
        thread.start()

    for thread in threads:
        thread.join()

    for name, _ in branch_functions:
        branch_result = results.get(name)
        if branch_result is None:
            continue
        step_logger.separator()
        step_logger.info(f"--- {name} branch log ---")
        if branch_result.output:
            step_logger.info(branch_result.output)
        else:
            step_logger.info("(no output)")

    step_logger.separator()
    step_logger.info("========== Branch Results ==========")
    for name, _ in branch_functions:
        branch_result = results.get(name)
        if branch_result is None:
            step_logger.failure(f"Branch {name} did not produce a result.")
            continue

        status = "PASS" if branch_result.success else "FAIL"
        if branch_result.failed_step:
            step_logger.info(
                f"Branch {name}: {status} (failed at {branch_result.failed_step})"
            )
        else:
            step_logger.info(f"Branch {name}: {status}")
    step_logger.info("====================================")

    return 0 if all(res.success for res in results.values()) else 1
