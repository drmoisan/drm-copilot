"""Tests for the bare-module orchestrator-state validator CLI (issue #464).

Purpose:
    Verify the exit-code contract of `validate_orchestrator_state_cli.main`
    (0 pass, 1 validation errors, 2 unreadable path or usage error), the
    forwarding of the five `--require-*` flags, parity with the dispatcher
    `orchestrator-state` route, and the `__main__` guard in
    `validate_orchestrator_state`.

Invariants / Constraints:
    No temporary file, subprocess, or wall-clock access is used. The single
    I/O seam `read_checkpoint_text` is replaced with in-memory stubs.
"""

from __future__ import annotations

import json
import runpy
import sys
from typing import TYPE_CHECKING, cast

import pytest

import scripts.dev_tools.validate_orchestration_artifacts as dispatcher
import scripts.dev_tools.validate_orchestrator_state as state_validator
import scripts.dev_tools.validate_orchestrator_state_cli as cli
from tests.scripts.dev_tools.validate_orchestrator_state_test_support import (
    build_complete_small_state,
    build_valid_orchestrator_state,
)

if TYPE_CHECKING:
    from collections.abc import Callable, Sequence
    from pathlib import Path

READ_FAILURE_PREFIX = "orchestrator-state checkpoint could not be read: "
SUCCESS_PREFIX = "orchestrator-state validation passed: "
FLAG_TO_KEY = {
    "--require-complete": "require_complete",
    "--require-model-routing": "require_model_routing",
    "--require-pr-creation-ready": "require_pr_creation_ready",
    "--require-codex-model-routing": "require_codex_model_routing",
    "--require-codex-topology": "require_codex_topology",
}


def make_read_stub(text: str) -> Callable[[Path], str]:
    """Return a read stub that yields fixed checkpoint text."""

    def stub(_path: Path) -> str:
        return text

    return stub


def make_failing_read_stub(error: BaseException) -> Callable[[Path], str]:
    """Return a read stub that raises the given exception."""

    def stub(_path: Path) -> str:
        raise error

    return stub


class RecordingValidator:
    """Fake validator that records its call arguments and returns preset errors."""

    def __init__(self, errors: Sequence[str]) -> None:
        self.errors = list(errors)
        self.texts: list[str] = []
        self.calls: list[dict[str, object]] = []

    def __call__(self, text: str, **kwargs: object) -> list[str]:
        self.texts.append(text)
        self.calls.append(dict(kwargs))
        return list(self.errors)


def valid_state_text() -> str:
    """Return serialized text of a valid checkpoint."""

    return json.dumps(build_valid_orchestrator_state())


def test_main_returns_zero_and_writes_success_line_for_valid_checkpoint(
    monkeypatch: pytest.MonkeyPatch, capsys: pytest.CaptureFixture[str]
) -> None:
    """A valid checkpoint returns 0 with only the success line on stdout."""

    # Arrange
    monkeypatch.setattr(cli, "read_checkpoint_text", make_read_stub(valid_state_text()))

    # Act
    code = cli.main(
        ["checkpoint.json"], validate=state_validator.validate_orchestrator_state_text
    )

    # Assert
    captured = capsys.readouterr()
    assert code == 0, "valid checkpoint must exit 0"
    assert captured.out == f"{SUCCESS_PREFIX}checkpoint.json\n"
    assert captured.err == "", "success must not write to stderr"


def test_main_returns_zero_for_complete_small_state_with_require_complete(
    monkeypatch: pytest.MonkeyPatch, capsys: pytest.CaptureFixture[str]
) -> None:
    """A completion-safe small-route checkpoint passes --require-complete."""

    # Arrange
    state = build_complete_small_state()
    state["pr_gate"] = {
        "pr_number": 464,
        "pr_url": "https://github.com/drmoisan/drm-copilot/pull/464",
        "head_branch": "bug/example-464",
        "head_sha": "current-head-sha",
    }
    state["ci_gate"] = {
        "conclusion": "success",
        "head_sha": "current-head-sha",
        "verified_at": "2026-06-25T07:45:00Z",
    }
    text = json.dumps(state)
    monkeypatch.setattr(cli, "read_checkpoint_text", make_read_stub(text))

    # Act
    code = cli.main(
        ["checkpoint.json", "--require-complete"],
        validate=state_validator.validate_orchestrator_state_text,
    )

    # Assert
    captured = capsys.readouterr()
    assert code == 0, f"complete small state must exit 0; stderr={captured.err!r}"
    assert captured.err == ""


def test_main_returns_one_and_writes_each_error_in_order(
    monkeypatch: pytest.MonkeyPatch, capsys: pytest.CaptureFixture[str]
) -> None:
    """Validation errors are written one per stderr line in returned order."""

    # Arrange
    validator = RecordingValidator(["first error", "second error"])
    monkeypatch.setattr(cli, "read_checkpoint_text", make_read_stub("{}"))

    # Act
    code = cli.main(["checkpoint.json"], validate=validator)

    # Assert
    captured = capsys.readouterr()
    assert code == 1, "validation errors must exit 1"
    assert captured.out == "", "failure must not write to stdout"
    assert captured.err == "first error\nsecond error\n"


@pytest.mark.parametrize("flag", list(FLAG_TO_KEY))
def test_main_forwards_flag_true_when_present(
    flag: str, monkeypatch: pytest.MonkeyPatch
) -> None:
    """Each flag forwards True for its own key and False for the other four."""

    # Arrange
    validator = RecordingValidator([])
    monkeypatch.setattr(cli, "read_checkpoint_text", make_read_stub("{}"))

    # Act
    code = cli.main(["checkpoint.json", flag], validate=validator)

    # Assert
    expected = {key: key == FLAG_TO_KEY[flag] for key in FLAG_TO_KEY.values()}
    assert code == 0
    assert cast("dict[str, bool]", validator.calls[0]) == expected


def test_main_forwards_all_flags_false_when_absent(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """No flags forward False for all five keys and never pass strict membership."""

    # Arrange
    validator = RecordingValidator([])
    monkeypatch.setattr(cli, "read_checkpoint_text", make_read_stub("{}"))

    # Act
    code = cli.main(["checkpoint.json"], validate=validator)

    # Assert
    assert code == 0
    assert validator.calls[0] == {key: False for key in FLAG_TO_KEY.values()}
    assert "strict_route_membership" not in validator.calls[0]


def test_main_returns_two_when_checkpoint_path_is_missing(
    monkeypatch: pytest.MonkeyPatch, capsys: pytest.CaptureFixture[str]
) -> None:
    """A missing path exits 2 with one diagnostic line and no traceback."""

    # Arrange
    monkeypatch.setattr(
        cli, "read_checkpoint_text", make_failing_read_stub(FileNotFoundError("gone"))
    )

    # Act
    code = cli.main(
        ["artifacts/nonexistent.json"],
        validate=state_validator.validate_orchestrator_state_text,
    )

    # Assert
    captured = capsys.readouterr()
    expected = f"{READ_FAILURE_PREFIX}artifacts/nonexistent.json: "
    assert code == 2, "missing path must exit 2"
    assert captured.out == ""
    assert captured.err.startswith(expected)
    assert captured.err == f"{expected}FileNotFoundError: gone\n"
    assert "Traceback" not in captured.err


@pytest.mark.parametrize("error_type", [PermissionError, IsADirectoryError])
def test_main_returns_two_for_unreadable_checkpoint(
    error_type: type[OSError],
    monkeypatch: pytest.MonkeyPatch,
    capsys: pytest.CaptureFixture[str],
) -> None:
    """Permission and directory read failures exit 2 with one diagnostic line."""

    # Arrange
    monkeypatch.setattr(
        cli, "read_checkpoint_text", make_failing_read_stub(error_type("denied"))
    )

    # Act
    code = cli.main(
        ["checkpoint.json"], validate=state_validator.validate_orchestrator_state_text
    )

    # Assert
    captured = capsys.readouterr()
    assert code == 2
    assert captured.err.startswith(f"{READ_FAILURE_PREFIX}checkpoint.json: ")
    assert error_type.__name__ in captured.err


def test_main_returns_two_for_non_utf8_checkpoint(
    monkeypatch: pytest.MonkeyPatch, capsys: pytest.CaptureFixture[str]
) -> None:
    """A non-UTF-8 checkpoint exits 2 with a decode diagnostic."""

    # Arrange
    decode_error = UnicodeDecodeError("utf-8", b"\xff", 0, 1, "invalid start byte")
    monkeypatch.setattr(
        cli, "read_checkpoint_text", make_failing_read_stub(decode_error)
    )

    # Act
    code = cli.main(
        ["checkpoint.json"], validate=state_validator.validate_orchestrator_state_text
    )

    # Assert
    captured = capsys.readouterr()
    assert code == 2
    assert captured.err.startswith(f"{READ_FAILURE_PREFIX}checkpoint.json: ")
    assert "UnicodeDecodeError" in captured.err


def test_main_does_not_swallow_unexpected_read_errors(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """Exceptions other than OSError and UnicodeDecodeError propagate."""

    # Arrange
    monkeypatch.setattr(
        cli, "read_checkpoint_text", make_failing_read_stub(RuntimeError("boom"))
    )

    # Act / Assert
    with pytest.raises(RuntimeError):
        cli.main(
            ["checkpoint.json"],
            validate=state_validator.validate_orchestrator_state_text,
        )


def test_main_rejects_unknown_flag_with_exit_two() -> None:
    """An unknown flag is an argparse usage error with exit code 2."""

    # Act / Assert
    with pytest.raises(SystemExit) as exit_info:
        cli.main(
            ["checkpoint.json", "--no-such-flag"],
            validate=state_validator.validate_orchestrator_state_text,
        )
    assert exit_info.value.code == 2


def test_main_rejects_missing_positional_with_exit_two() -> None:
    """A missing path argument is an argparse usage error with exit code 2."""

    # Act / Assert
    with pytest.raises(SystemExit) as exit_info:
        cli.main([], validate=state_validator.validate_orchestrator_state_text)
    assert exit_info.value.code == 2


@pytest.mark.parametrize("text", ["", "not json at all"], ids=["empty", "non-json"])
def test_main_returns_one_for_empty_and_non_json_text(
    text: str, monkeypatch: pytest.MonkeyPatch, capsys: pytest.CaptureFixture[str]
) -> None:
    """Empty and non-JSON text fail validation with the validator's own errors."""

    # Arrange
    monkeypatch.setattr(cli, "read_checkpoint_text", make_read_stub(text))
    expected_errors = state_validator.validate_orchestrator_state_text(text)

    # Act
    code = cli.main(
        ["checkpoint.json"], validate=state_validator.validate_orchestrator_state_text
    )

    # Assert
    captured = capsys.readouterr()
    assert expected_errors, "validator must report at least one error"
    assert code == 1
    assert captured.out == ""
    assert captured.err == "".join(f"{error}\n" for error in expected_errors)


@pytest.mark.parametrize(
    "text", [valid_state_text(), "{}"], ids=["valid-text", "invalid-text"]
)
def test_cli_and_dispatcher_agree_on_exit_code_for_valid_and_invalid_text(
    text: str, monkeypatch: pytest.MonkeyPatch
) -> None:
    """The bare-module CLI and the dispatcher route return the same exit code."""

    # Arrange
    monkeypatch.setattr(cli, "read_checkpoint_text", make_read_stub(text))
    monkeypatch.setattr(dispatcher, "_read_text", make_read_stub(text))

    # Act
    cli_code = cli.main(
        ["checkpoint.json"], validate=state_validator.validate_orchestrator_state_text
    )
    dispatcher_code = dispatcher.main(["orchestrator-state", "checkpoint.json"])

    # Assert
    assert cli_code == dispatcher_code, "CLI and dispatcher exit codes must agree"


@pytest.mark.filterwarnings("ignore:.*found in sys.modules.*:RuntimeWarning")
def test_validator_module_main_guard_reaches_cli_main(
    monkeypatch: pytest.MonkeyPatch, capsys: pytest.CaptureFixture[str]
) -> None:
    """Running the validator module as __main__ dispatches to the CLI main."""

    # Arrange
    monkeypatch.setattr(sys, "argv", ["validate_orchestrator_state", "checkpoint.json"])
    monkeypatch.setattr(cli, "read_checkpoint_text", make_read_stub(valid_state_text()))

    # Act
    with pytest.raises(SystemExit) as exit_info:
        runpy.run_module(
            "scripts.dev_tools.validate_orchestrator_state", run_name="__main__"
        )

    # Assert
    captured = capsys.readouterr()
    assert exit_info.value.code == 0
    assert captured.out == f"{SUCCESS_PREFIX}checkpoint.json\n"
