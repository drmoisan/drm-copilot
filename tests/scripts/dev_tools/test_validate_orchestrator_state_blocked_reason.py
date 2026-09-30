"""Back-compat tests for the orchestrator-state ``blocked_reason`` vocabulary (#523).

The back-compat tests replay nine committed checkpoint fixtures (the key
absent, JSON ``null``, and each pre-existing ``blocked_reason`` member) through
``validate_orchestrator_state_text`` in four modes and assert the full ordered
error list equals the capture recorded against the unmodified validator in
``tests/fixtures/orchestrator_state_blocked_reason_backcompat_expected.json``.
Every test whose name contains ``backcompat`` belongs to that capture. Fixtures
are read in place; no temporary file is created.
"""

from __future__ import annotations

import json
from pathlib import Path
from typing import cast

import pytest

import scripts.dev_tools.validate_orchestrator_state as state_validator

_FIXTURES_ROOT = Path(__file__).resolve().parents[2] / "fixtures"
_BACKCOMPAT_DIR = _FIXTURES_ROOT / "orchestrator_state_blocked_reason_backcompat"
_BACKCOMPAT_EXPECTED = (
    _FIXTURES_ROOT / "orchestrator_state_blocked_reason_backcompat_expected.json"
)

_BACKCOMPAT_STEMS = (
    "absent",
    "null",
    "none",
    "spawn_agent_unavailable",
    "delegation_launch_failed",
    "delegate_no_receipt",
    "delegate_contract_incomplete",
    "validator_failed",
    "user_requested_stop",
)
_BACKCOMPAT_MODES = (
    "plain",
    "require_complete",
    "require_pr_creation_ready",
    "require_model_routing",
)


def _load_backcompat_python_expected() -> dict[str, dict[str, list[str]]]:
    """Return the ``python`` section of the committed back-compat capture."""

    payload = cast(
        "dict[str, object]",
        json.loads(_BACKCOMPAT_EXPECTED.read_text(encoding="utf-8")),
    )
    return cast("dict[str, dict[str, list[str]]]", payload["python"])


def _validate_in_mode(text: str, mode: str) -> list[str]:
    """Run the validator on ``text`` with only the flag named by ``mode`` set."""

    if mode == "plain":
        return state_validator.validate_orchestrator_state_text(text)
    if mode == "require_complete":
        return state_validator.validate_orchestrator_state_text(
            text, require_complete=True
        )
    if mode == "require_pr_creation_ready":
        return state_validator.validate_orchestrator_state_text(
            text, require_pr_creation_ready=True
        )
    if mode == "require_model_routing":
        return state_validator.validate_orchestrator_state_text(
            text, require_model_routing=True
        )
    raise ValueError(f"unknown back-compat mode: {mode}")


def test_backcompat_fixture_count_is_nine() -> None:
    """The back-compat fixture directory holds exactly the nine capture fixtures."""

    # Arrange
    expected_names = sorted(f"{stem}.json" for stem in _BACKCOMPAT_STEMS)

    # Act
    actual_names = sorted(path.name for path in _BACKCOMPAT_DIR.glob("*.json"))

    # Assert
    assert len(actual_names) == 9, f"expected 9 fixtures, found {actual_names}"
    assert actual_names == expected_names


@pytest.mark.parametrize("mode", _BACKCOMPAT_MODES)
@pytest.mark.parametrize("stem", _BACKCOMPAT_STEMS)
def test_backcompat_error_lists_are_unchanged(stem: str, mode: str) -> None:
    """Each fixture yields exactly the captured ordered error list in each mode."""

    # Arrange
    text = (_BACKCOMPAT_DIR / f"{stem}.json").read_text(encoding="utf-8")
    expected = _load_backcompat_python_expected()[stem][mode]

    # Act
    actual = _validate_in_mode(text, mode)

    # Assert
    assert actual == expected, f"{stem}/{mode}: {actual!r} != {expected!r}"
