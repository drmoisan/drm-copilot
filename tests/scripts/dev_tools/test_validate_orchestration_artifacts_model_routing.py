"""CLI-level tests for the `orchestrator-state --require-model-routing` flag.

These tests exercise the `validate_orchestration_artifacts` CLI dispatcher's new
`--require-model-routing` flag end-to-end, spying on
`validate_orchestrator_state_text` so the exact keyword forwarding and
flag-independence can be asserted without a real checkpoint. Kept in a sibling
module to respect the repository's 500-line file-size cap on the existing CLI
test file.
"""

from __future__ import annotations

from typing import TYPE_CHECKING, Any

import scripts.dev_tools.validate_orchestration_artifacts as validator

if TYPE_CHECKING:
    from pathlib import Path

    from pytest import MonkeyPatch


def _install_spy(monkeypatch: MonkeyPatch) -> dict[str, Any]:
    """Replace the state validator with a spy and stub file reading.

    Purpose:
        Capture the keyword arguments forwarded to
        `validate_orchestrator_state_text` and avoid real file/subprocess I/O.

    Args:
        monkeypatch (MonkeyPatch): Pytest fixture used to patch module
            attributes.

    Returns:
        dict[str, Any]: A mutable record populated with the captured kwargs.

    Raises:
        None.

    Side Effects:
        Patches `validator._read_text` and
        `validator.validate_orchestrator_state_text`.
    """

    captured: dict[str, Any] = {}

    def _spy(_text: str, **kwargs: Any) -> list[str]:
        captured.update(kwargs)
        return []

    def _read_text_stub(_path: Path) -> str:
        return "{}"

    monkeypatch.setattr(validator, "_read_text", _read_text_stub)
    monkeypatch.setattr(validator, "validate_orchestrator_state_text", _spy)
    return captured


def test_require_model_routing_flag_forwards_true(monkeypatch: MonkeyPatch) -> None:
    """`--require-model-routing` forwards `require_model_routing=True`.

    Purpose:
        Confirm the CLI flag reaches
        `validate_orchestrator_state_text(require_model_routing=True)`.

    Args:
        monkeypatch (MonkeyPatch): Pytest patching fixture.

    Returns:
        None: Assertions verify the forwarded keyword and exit code.

    Raises:
        None.

    Side Effects:
        None.
    """

    captured = _install_spy(monkeypatch)

    result = validator.main(
        ["orchestrator-state", "ignored.json", "--require-model-routing"]
    )

    assert result == 0
    assert captured["require_model_routing"] is True


def test_require_model_routing_absent_forwards_false(monkeypatch: MonkeyPatch) -> None:
    """Omitting the flag forwards `require_model_routing=False`.

    Purpose:
        Confirm the default-off contract is preserved at the CLI boundary.

    Args:
        monkeypatch (MonkeyPatch): Pytest patching fixture.

    Returns:
        None: Assertions verify the forwarded keyword.

    Raises:
        None.

    Side Effects:
        None.
    """

    captured = _install_spy(monkeypatch)

    result = validator.main(["orchestrator-state", "ignored.json"])

    assert result == 0
    assert captured["require_model_routing"] is False


def test_flag_independence_model_routing_only(monkeypatch: MonkeyPatch) -> None:
    """`--require-model-routing` alone does not enable the other gates.

    Purpose:
        Confirm passing only `--require-model-routing` leaves
        `require_complete` and `require_pr_creation_ready` False.

    Args:
        monkeypatch (MonkeyPatch): Pytest patching fixture.

    Returns:
        None: Assertions verify flag independence.

    Raises:
        None.

    Side Effects:
        None.
    """

    captured = _install_spy(monkeypatch)

    validator.main(["orchestrator-state", "ignored.json", "--require-model-routing"])

    assert captured["require_model_routing"] is True
    assert captured["require_complete"] is False
    assert captured["require_pr_creation_ready"] is False


def test_flag_independence_complete_only(monkeypatch: MonkeyPatch) -> None:
    """`--require-complete` alone does not enable model routing.

    Purpose:
        Confirm passing only `--require-complete` leaves
        `require_model_routing` False.

    Args:
        monkeypatch (MonkeyPatch): Pytest patching fixture.

    Returns:
        None: Assertions verify flag independence.

    Raises:
        None.

    Side Effects:
        None.
    """

    captured = _install_spy(monkeypatch)

    validator.main(["orchestrator-state", "ignored.json", "--require-complete"])

    assert captured["require_complete"] is True
    assert captured["require_model_routing"] is False
