from __future__ import annotations

from io import StringIO
from typing import TYPE_CHECKING, TextIO, cast

from scripts.dev_tools import fix_all

if TYPE_CHECKING:
    from collections.abc import Iterable, Mapping, Sequence

    from pytest import MonkeyPatch


def make_result(code: int, output: str = "") -> fix_all.CommandResult:
    return fix_all.CommandResult(returncode=code, output=output)


class FakeRunner:
    def __init__(
        self, responses: Mapping[str, Iterable[fix_all.CommandResult]]
    ) -> None:
        self.responses = {name: list(values) for name, values in responses.items()}
        self.calls: list[tuple[str, list[str]]] = []
        self.branch_name: str | None = None

    def run(self, command: Sequence[str], *, step_name: str) -> fix_all.CommandResult:
        self.calls.append((step_name, list(command)))
        if step_name not in self.responses or not self.responses[step_name]:
            raise AssertionError(f"No response configured for {step_name}")
        return self.responses[step_name].pop(0)


class FakeRunnerFactory:
    def __init__(
        self,
        responses_by_branch: Mapping[
            str, Mapping[str, Iterable[fix_all.CommandResult]]
        ],
    ) -> None:
        self.responses_by_branch = responses_by_branch
        self.runners: dict[str, FakeRunner] = {}

    def __call__(
        self, branch_name: str, branch_logger: fix_all.StepLogger
    ) -> FakeRunner:
        runner = FakeRunner(self.responses_by_branch[branch_name])
        runner.branch_name = branch_name
        self.runners[branch_name] = runner
        return runner


def build_logger() -> fix_all.StepLogger:
    return fix_all.StepLogger(stream=StringIO())


def read_log(logger: fix_all.StepLogger) -> str:
    return cast("StringIO", logger.stream).getvalue()


def base_success_responses(
    *, include_coverage: bool = True
) -> dict[str, dict[str, list[fix_all.CommandResult]]]:
    pytest_key = "Pytest: test with coverage" if include_coverage else "Pytest: test"
    jest_key = "Jest: test with coverage" if include_coverage else "Jest: test"
    return {
        "json": {
            "JSON: format": [make_result(0)],
            "JSON: validate": [make_result(0)],
        },
        "shell": {
            "Shell: format": [make_result(0)],
            "Shell: check": [make_result(0)],
            "Shell: test": [make_result(0)],
        },
        "python": {
            "Black: format": [make_result(0)],
            "Ruff: lint": [make_result(0)],
            "Pyright: type-check": [make_result(0)],
            pytest_key: [make_result(0)],
        },
        "powershell": {
            "PoshQC: format": [make_result(0)],
            "PoshQC: analyze": [make_result(0)],
            "PoshQC: test": [make_result(0)],
        },
        "typescript": {
            "Prettier: format": [make_result(0)],
            "ESLint: lint": [make_result(0)],
            "TSC: type-check": [make_result(0)],
            jest_key: [make_result(0)],
        },
    }


def test_pipeline_stops_on_prettier_failure() -> None:
    """A failing Prettier step in the typescript branch fails the pipeline."""
    responses = base_success_responses()
    responses["typescript"]["Prettier: format"] = [make_result(1, "format errors")]
    factory = FakeRunnerFactory(responses)
    logger = build_logger()
    exit_code = fix_all.run_fix_all(
        max_ruff_retries=1,
        include_coverage=True,
        runner_factory=factory,
        logger=logger,
        complete_all=True,
    )
    assert exit_code == 1
    typescript_calls = [call[0] for call in factory.runners["typescript"].calls]
    assert typescript_calls == ["Prettier: format"]
    assert "Prettier formatting failed" in read_log(logger)


def test_pipeline_stops_on_eslint_failure() -> None:
    """A failing ESLint step in the typescript branch fails the pipeline."""
    responses = base_success_responses()
    responses["typescript"]["ESLint: lint"] = [make_result(1, "lint errors")]
    factory = FakeRunnerFactory(responses)
    logger = build_logger()
    exit_code = fix_all.run_fix_all(
        max_ruff_retries=1,
        include_coverage=True,
        runner_factory=factory,
        logger=logger,
        complete_all=True,
    )
    assert exit_code == 1
    typescript_calls = [call[0] for call in factory.runners["typescript"].calls]
    assert typescript_calls[-1] == "ESLint: lint"
    assert "TSC: type-check" not in typescript_calls
    assert "ESLint linting failed" in read_log(logger)


def test_pipeline_stops_on_tsc_failure() -> None:
    """A failing TSC step in the typescript branch fails the pipeline."""
    responses = base_success_responses()
    responses["typescript"]["TSC: type-check"] = [make_result(1, "type errors")]
    factory = FakeRunnerFactory(responses)
    logger = build_logger()
    exit_code = fix_all.run_fix_all(
        max_ruff_retries=1,
        include_coverage=True,
        runner_factory=factory,
        logger=logger,
        complete_all=True,
    )
    assert exit_code == 1
    typescript_calls = [call[0] for call in factory.runners["typescript"].calls]
    assert typescript_calls[-1] == "TSC: type-check"
    assert "Jest: test with coverage" not in typescript_calls
    assert "TSC type checking failed" in read_log(logger)


def test_pipeline_stops_on_jest_failure() -> None:
    """A failing Jest step in the typescript branch fails the pipeline."""
    responses = base_success_responses()
    responses["typescript"]["Jest: test with coverage"] = [
        make_result(1, "tests failed")
    ]
    factory = FakeRunnerFactory(responses)
    logger = build_logger()
    exit_code = fix_all.run_fix_all(
        max_ruff_retries=1,
        include_coverage=True,
        runner_factory=factory,
        logger=logger,
        complete_all=True,
    )
    assert exit_code == 1
    typescript_calls = [call[0] for call in factory.runners["typescript"].calls]
    assert typescript_calls[-1] == "Jest: test with coverage"
    assert "Jest failed" in read_log(logger)


def test_typescript_jest_step_name_switches_with_coverage() -> None:
    """The typescript Jest step name and command switch on include_coverage."""
    factory = FakeRunnerFactory(base_success_responses(include_coverage=False))
    logger = build_logger()
    exit_code = fix_all.run_fix_all(
        max_ruff_retries=1,
        include_coverage=False,
        runner_factory=factory,
        logger=logger,
    )
    assert exit_code == 0
    typescript_calls = factory.runners["typescript"].calls
    step_names = [call[0] for call in typescript_calls]
    assert "Jest: test" in step_names
    assert "Jest: test with coverage" not in step_names
    jest_call = next(call for call in typescript_calls if call[0] == "Jest: test")
    assert jest_call[1] == ["npm", "run", "test:unit"]


def test_format_status_transition_line_exact_format() -> None:
    """Ensure status transition formatting matches the required template."""
    assert (
        fix_all.format_status_transition_line("python", "Pyright: type-check")
        == "STATUS|branch=python|status=Pyright: type-check"
    )


def test_render_status_board_line_count_and_trailing_newline() -> None:
    """Ensure rendered boards have one newline per line and a trailing newline."""
    lines = ["json: format", "python: lint"]
    board = fix_all.render_status_board(lines, width=40)
    assert board.count("\n") == len(lines)
    assert board.endswith("\n")


def test_should_use_interactive_board_requires_isatty_and_vt() -> None:
    """Verify interactive mode requires both TTY and VT support."""
    assert fix_all.should_use_interactive_board(isatty=True, vt_enabled=True) is True
    assert fix_all.should_use_interactive_board(isatty=True, vt_enabled=False) is False
    assert fix_all.should_use_interactive_board(isatty=False, vt_enabled=True) is False
    assert fix_all.should_use_interactive_board(isatty=False, vt_enabled=False) is False


def test_non_interactive_emits_status_transitions_without_ansi() -> None:
    """Confirm non-interactive mode emits status lines without ANSI control codes."""
    factory = FakeRunnerFactory(base_success_responses())
    logger = build_logger()
    exit_code = fix_all.run_fix_all(
        max_ruff_retries=1,
        include_coverage=True,
        runner_factory=factory,
        logger=logger,
    )
    assert exit_code == 0
    output = read_log(logger)
    assert "STATUS|branch=" in output
    assert "\x1b[" not in output


def test_format_ansi_redraw_contains_only_erase_and_cursor_up() -> None:
    """Ensure ANSI redraw uses only erase-line and cursor-up sequences."""
    board = "json\npython\n"
    rendered = fix_all.format_ansi_redraw(board, line_count=2)
    assert "\x1b[2K" in rendered
    assert "\x1b[1A" in rendered
    assert "\x1b[" in rendered
    assert rendered.replace("\x1b[2K", "").replace("\x1b[1A", "").find("\x1b[") == -1


def test_is_vt_enabled_for_stream_true_on_non_windows(
    monkeypatch: MonkeyPatch,
) -> None:
    """Ensure non-Windows platforms default to VT-enabled."""
    monkeypatch.setattr(fix_all.sys, "platform", "linux")
    logger = build_logger()
    assert fix_all.is_vt_enabled_for_stream(logger.stream) is True


def test_interactive_mode_emits_ansi_redraw_not_status_lines(
    monkeypatch: MonkeyPatch,
) -> None:
    """Verify interactive mode emits ANSI redraws instead of STATUS lines."""

    class FakeTty(StringIO):
        def isatty(self) -> bool:
            return True

    def always_vt_enabled(stream: TextIO) -> bool:
        """Return True to force interactive mode in tests."""
        return True

    monkeypatch.setattr(fix_all, "is_vt_enabled_for_stream", always_vt_enabled)
    factory = FakeRunnerFactory(base_success_responses())
    logger = fix_all.StepLogger(stream=FakeTty())
    exit_code = fix_all.run_fix_all(
        max_ruff_retries=1,
        include_coverage=True,
        runner_factory=factory,
        logger=logger,
    )
    assert exit_code == 0
    output = read_log(logger)
    assert "\x1b[2K" in output
    assert "STATUS|branch=" not in output


def test_shell_test_was_skipped_no_test_dirs_message() -> None:
    """Ensure skip detection handles missing shell test directories."""
    output = "No shell test directories found; skipping."
    assert fix_all.shell_test_was_skipped(output) is True


def test_shell_test_was_skipped_bats_missing_message() -> None:
    """Ensure skip detection handles missing bats installations."""
    output = "bats not installed; skipping shell tests."
    assert fix_all.shell_test_was_skipped(output) is True


def test_shell_branch_emits_skip_tests_status_on_skip_output() -> None:
    """Ensure skipped shell tests emit a SKIP tests status transition."""
    responses = base_success_responses()
    responses["shell"]["Shell: test"] = [
        make_result(0, "No shell test directories found; skipping.")
    ]
    factory = FakeRunnerFactory(responses)
    logger = build_logger()
    exit_code = fix_all.run_fix_all(
        max_ruff_retries=1,
        include_coverage=True,
        runner_factory=factory,
        logger=logger,
    )
    assert exit_code == 0
    output = read_log(logger)
    assert "STATUS|branch=shell|status=SKIP tests" in output


def test_final_summary_framing_lines_present() -> None:
    """Ensure final summary framing lines remain present."""
    factory = FakeRunnerFactory(base_success_responses())
    logger = build_logger()
    exit_code = fix_all.run_fix_all(
        max_ruff_retries=1,
        include_coverage=True,
        runner_factory=factory,
        logger=logger,
    )
    assert exit_code == 0
    output = read_log(logger)
    assert "========== Branch Results ==========" in output
    assert "====================================" in output


def test_subprocess_runner_returns_immediately_when_already_cancelled(
    monkeypatch: MonkeyPatch,
) -> None:
    """Verify runner returns immediately if cancel_event already set."""
    import threading

    captured = StringIO()
    logger = fix_all.StepLogger(stream=captured)
    cancel_event = threading.Event()
    cancel_event.set()  # Already cancelled.

    # Track whether subprocess_run was called (it shouldn't be).
    run_called = False

    def fake_run(
        command: Sequence[str], check: bool, capture_output: bool, text: bool
    ) -> object:
        nonlocal run_called
        run_called = True

        class Result:
            stdout = ""
            stderr = ""
            returncode = 0

        return Result()

    monkeypatch.setattr(fix_all, "subprocess_run", fake_run)

    runner = fix_all.SubprocessCommandRunner(logger, cancel_event=cancel_event)
    result = runner.run(["should-not-run"], step_name="Test: pre-cancel")

    assert result.returncode == -1
    assert result.output == "Canceled"
    assert not run_called, "subprocess_run should not be called when already cancelled"


def test_subprocess_runner_runs_normally_with_cancel_event_not_set(
    monkeypatch: MonkeyPatch,
) -> None:
    """Verify runner executes normally when cancel_event exists but is not set."""
    import threading

    captured = StringIO()
    logger = fix_all.StepLogger(stream=captured)
    cancel_event = threading.Event()  # Not set.

    def fake_run(
        command: Sequence[str], check: bool, capture_output: bool, text: bool
    ) -> object:
        class Result:
            stdout = "success output\n"
            stderr = ""
            returncode = 0

        return Result()

    monkeypatch.setattr(fix_all, "subprocess_run", fake_run)

    runner = fix_all.SubprocessCommandRunner(logger, cancel_event=cancel_event)
    result = runner.run(["some-command"], step_name="Test: normal")

    assert result.returncode == 0
    assert "success output" in result.output
