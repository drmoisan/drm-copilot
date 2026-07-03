"""CLI-level tests for the `orchestrator-state --require-pr-creation-ready` flag.

These tests exercise the `validate_orchestration_artifacts` CLI dispatcher's new
`--require-pr-creation-ready` flag end-to-end (argument parsing through
`main()`'s exit code), monkeypatching `_read_text` so no real file or
subprocess is required. Kept in a sibling module (not an extension of
`test_validate_orchestration_artifacts.py`) to respect the repository's
500-line file-size cap on the existing, already-over-cap test file.
"""

from __future__ import annotations

import json
from typing import TYPE_CHECKING

import scripts.dev_tools.validate_orchestration_artifacts as validator
from tests.scripts.dev_tools import (
    test_validate_orchestrator_state_pr_creation_readiness as state_fixtures,
)

if TYPE_CHECKING:
    from collections.abc import Callable
    from pathlib import Path

    from pytest import MonkeyPatch


def _build_read_text_stub(text: str) -> Callable[[Path], str]:
    """Return a typed `_read_text` replacement for monkeypatched CLI tests."""

    def _stub(_path: Path) -> str:
        return text

    return _stub


def test_main_orchestrator_state_require_pr_creation_ready_returns_0_for_valid(
    monkeypatch: MonkeyPatch,
) -> None:
    """Return success for a ready pre-PR checkpoint via the CLI flag.

    Purpose:
        Confirm the `orchestrator-state <path> --require-pr-creation-ready`
        CLI subcommand returns exit code 0 for a checkpoint that satisfies the
        narrower pre-PR-creation readiness contract, independent of
        `--require-complete`.

    Args:
        monkeypatch (MonkeyPatch): Pytest fixture used to inject checkpoint
            text in memory so no real subprocess or temporary file is
            required.

    Returns:
        None: Assertions verify the CLI returns exit code 0.

    Raises:
        None.

    Side Effects:
        None.
    """

    state = state_fixtures.build_pr_creation_ready_state()
    monkeypatch.setattr(
        validator, "_read_text", _build_read_text_stub(json.dumps(state))
    )

    result = validator.main(
        ["orchestrator-state", "ignored.json", "--require-pr-creation-ready"]
    )

    assert result == 0


def test_main_orchestrator_state_require_pr_creation_ready_returns_1_for_invalid(
    monkeypatch: MonkeyPatch,
) -> None:
    """Return failure for a not-ready checkpoint via the CLI flag.

    Purpose:
        Exercise the `orchestrator-state <path> --require-pr-creation-ready`
        CLI subcommand contract, asserting the validator returns a non-zero
        exit code when an upstream step is pending.

    Args:
        monkeypatch (MonkeyPatch): Pytest fixture used to inject checkpoint
            text in memory so no real subprocess or temporary file is
            required.

    Returns:
        None: Assertions verify the CLI returns exit code 1.

    Raises:
        None.

    Side Effects:
        None.
    """

    state = state_fixtures.build_pr_creation_ready_state()
    state["step7_status"] = "pending"
    monkeypatch.setattr(
        validator, "_read_text", _build_read_text_stub(json.dumps(state))
    )

    result = validator.main(
        ["orchestrator-state", "ignored.json", "--require-pr-creation-ready"]
    )

    assert result == 1
