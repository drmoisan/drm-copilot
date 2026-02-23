"""Runtime orchestration for the fix-all workflow."""

from __future__ import annotations

import threading
from io import StringIO
from typing import TYPE_CHECKING, cast

if TYPE_CHECKING:
    from collections.abc import Callable

    from scripts.dev_tools.fix_all import BranchResult, CommandRunner, StepLogger


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
    from scripts.dev_tools import fix_all as api

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
    }
    has_rendered_board = False

    def emit_status_transition(branch: str, status: str) -> None:
        nonlocal has_rendered_board

        if use_interactive_board:
            with status_lock:
                status_by_branch[branch] = status
                lines = [
                    f"{name}: {status_by_branch[name]}"
                    for name in ("json", "shell", "python", "powershell")
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

    def run_json_branch() -> BranchResult:
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

        if cancel_event.is_set() and not complete_all:
            output = branch_stream.getvalue()
            emit_status_transition("json", "FAIL")
            return api.BranchResult(
                name="json", success=False, output=output, failed_step="Canceled"
            )

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

    def run_shell_branch() -> BranchResult:
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

    def run_python_branch() -> BranchResult:
        branch_stream: StringIO = StringIO()
        branch_logger = api.StepLogger(stream=branch_stream)
        branch_runner = factory("python", branch_logger)

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

    def run_powershell_branch() -> BranchResult:
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

    branch_functions = [
        ("json", run_json_branch),
        ("shell", run_shell_branch),
        ("python", run_python_branch),
        ("powershell", run_powershell_branch),
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
