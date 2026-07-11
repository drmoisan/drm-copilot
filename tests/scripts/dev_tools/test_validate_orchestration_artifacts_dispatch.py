"""CLI-dispatch tests for the orchestration artifact validator.

Split out of `test_validate_orchestration_artifacts.py` (issue #275 remediation
cycle 1, fix #4) because that file exceeded the repository's 500-line hard cap.
This module contains the CLI-dispatch integration tests and the
`epic-orchestrator-state` dispatch tests; the shared builder helpers are
imported from the sibling module rather than duplicated, following the
sibling-module convention already used by `test_validate_epic_orchestrator_state.py`.
"""

from __future__ import annotations

import argparse
import json
from typing import TYPE_CHECKING, cast

import scripts.dev_tools.validate_orchestration_artifacts as validator
from tests.scripts.dev_tools.test_validate_orchestration_artifacts import (
    build_complete_large_orchestrator_state,
    build_read_text_stub,
    build_valid_orchestrator_state,
    build_valid_policy_audit_text,
)

# `get_first_receipt` is not imported: none of the 10 functions moved into this module
# call it (it is only used by receipt-shape tests that remain in the sibling module).
# Ruff's unused-import check (F401) would otherwise fail the mandatory toolchain loop.

if TYPE_CHECKING:
    from collections.abc import Callable

    from pytest import MonkeyPatch


def test_validate_from_args_returns_unsupported_artifact_type(
    monkeypatch: MonkeyPatch,
) -> None:
    """Return an unsupported-artifact error for unknown dispatch values."""

    monkeypatch.setattr(validator, "_read_text", build_read_text_stub("ignored"))
    # Access the private dispatch function via vars() to avoid Pyright
    # reportPrivateUsage and Ruff B009 (getattr with constant) conflicts.
    validate_from_args = cast(
        "Callable[[argparse.Namespace], list[str]]",
        vars(validator)["_validate_from_args"],
    )

    errors = validate_from_args(
        argparse.Namespace(path="ignored.md", artifact_type="unsupported")
    )

    assert errors == ["Unsupported artifact type: unsupported"]


def test_main_returns_exit_code_1_for_an_invalid_plan_artifact(
    monkeypatch: MonkeyPatch,
) -> None:
    """Return failure for an invalid plan artifact using in-memory text."""

    monkeypatch.setattr(
        validator,
        "_read_text",
        build_read_text_stub("### Phase 0: Baseline\n- [ ] [P0-T1] Capture baseline"),
    )

    result = validator.main(["plan", "ignored.md"])

    assert result == 1


def test_main_returns_zero_for_valid_policy_audit(monkeypatch: MonkeyPatch) -> None:
    """Return success for a template-shaped policy audit using in-memory text."""

    monkeypatch.setattr(
        validator,
        "_read_text",
        build_read_text_stub(build_valid_policy_audit_text()),
    )

    result = validator.main(["policy-audit", "ignored.md"])

    assert result == 0


def test_main_orchestrator_state_require_complete_returns_1_for_invalid(
    monkeypatch: MonkeyPatch,
) -> None:
    """Return failure for an invalid require-complete checkpoint via the CLI.

    Purpose:
        Exercise the `orchestrator-state <path> --require-complete` CLI
        subcommand contract used by the SubagentStop subprocess seam, asserting
        the validator returns a non-zero exit code for an invalid checkpoint.

    Args:
        monkeypatch (MonkeyPatch): Pytest fixture used to inject checkpoint text
            in memory so no real subprocess or temporary file is required.

    Returns:
        None: Assertions verify the CLI returns exit code 1.

    Raises:
        None.

    Side Effects:
        None.
    """

    # A blocked lifecycle status is invalid under require_complete.
    state = build_valid_orchestrator_state()
    state["step8_status"] = "blocked"
    monkeypatch.setattr(
        validator, "_read_text", build_read_text_stub(json.dumps(state))
    )

    result = validator.main(
        ["orchestrator-state", "ignored.json", "--require-complete"]
    )

    assert result == 1


def test_main_orchestrator_state_require_complete_returns_0_for_valid(
    monkeypatch: MonkeyPatch,
) -> None:
    """Return success for a valid require-complete checkpoint via the CLI.

    Purpose:
        Confirm the `orchestrator-state <path> --require-complete` CLI
        subcommand returns exit code 0 for a checkpoint that satisfies the full
        completion contract, including route-driven PR-gate evidence.

    Args:
        monkeypatch (MonkeyPatch): Pytest fixture used to inject checkpoint text
            in memory so no real subprocess or temporary file is required.

    Returns:
        None: Assertions verify the CLI returns exit code 0.

    Raises:
        None.

    Side Effects:
        None.
    """

    state = build_complete_large_orchestrator_state()
    monkeypatch.setattr(
        validator, "_read_text", build_read_text_stub(json.dumps(state))
    )

    result = validator.main(
        ["orchestrator-state", "ignored.json", "--require-complete"]
    )

    assert result == 0


def build_valid_epic_orchestrator_state() -> dict[str, object]:
    """Return a minimally valid epic-orchestrator checkpoint payload."""

    return {
        "objective": "deliver epic-orchestrate-275",
        "route_id": "epic",
        "epic_feature_folder": "epic-orchestrate-275",
        "integration_branch": "epic/epic-orchestrate-275-integration",
        "max_parallel_features": 4,
        "completed_steps": ["epic_manifest_parsed"],
        "next_step": "wave_1_launch",
        "last_updated": "2026-07-02T20-00",
        "waves": [{"wave_number": 0, "feature_folders": ["child-a"]}],
        "features": [
            {
                "issue_num": 101,
                "feature_folder": "child-a",
                "depends_on": [],
                "wave_number": 0,
                "merge_status": "merged",
                "branch_name": "feature/child-a",
                "worktree_path": r"C:\worktrees\child-a",
                "delegation_receipt": {
                    "delegation_id": "delegate-child-a",
                    "feature_folder": "child-a",
                    "issue_num": 101,
                    "agent_name": "orchestrator-c3-elevated",
                },
                "model_routing_receipt": {
                    "delegation_id": "delegate-child-a",
                    "deployment_agent": "orchestrator-c3-elevated",
                    "execution_context": "epic_execution_child",
                },
                "launch_receipt_path": (
                    "artifacts/orchestration/epic-child-launches/"
                    "child-a.receipt.json"
                ),
                "launch_status_path": (
                    "artifacts/orchestration/epic-child-launches/" "child-a.status.json"
                ),
            }
        ],
    }


def test_build_parser_epic_orchestrator_state_accepts_require_complete() -> None:
    """Confirm the epic-orchestrator-state subparser accepts --require-complete."""

    parser = validator.build_parser()

    args = parser.parse_args(
        ["epic-orchestrator-state", "ignored.json", "--require-complete"]
    )

    assert args.artifact_type == "epic-orchestrator-state"
    assert args.path == "ignored.json"
    assert args.require_complete is True


def test_validate_from_args_dispatches_epic_orchestrator_state(
    monkeypatch: MonkeyPatch,
) -> None:
    """Confirm the epic-orchestrator-state branch routes to the epic validator."""

    monkeypatch.setattr(
        validator,
        "_read_text",
        build_read_text_stub(json.dumps(build_valid_epic_orchestrator_state())),
    )
    validate_from_args = cast(
        "Callable[[argparse.Namespace], list[str]]",
        vars(validator)["_validate_from_args"],
    )

    errors = validate_from_args(
        argparse.Namespace(
            path="ignored.json",
            artifact_type="epic-orchestrator-state",
            require_complete=False,
        )
    )

    assert errors == []


def test_main_epic_orchestrator_state_require_complete_returns_0_for_valid(
    monkeypatch: MonkeyPatch,
) -> None:
    """Return success for a valid require-complete epic checkpoint via the CLI."""

    state = build_valid_epic_orchestrator_state()
    state["epic_merge_pr"] = {"merge_commit_sha": "abc123"}
    monkeypatch.setattr(
        validator, "_read_text", build_read_text_stub(json.dumps(state))
    )

    result = validator.main(
        ["epic-orchestrator-state", "ignored.json", "--require-complete"]
    )

    assert result == 0


def test_main_epic_orchestrator_state_require_complete_returns_1_for_invalid(
    monkeypatch: MonkeyPatch,
) -> None:
    """Return failure for an invalid require-complete epic checkpoint via the CLI."""

    state = build_valid_epic_orchestrator_state()
    state["features"][0]["merge_status"] = "pr_open"  # type: ignore[index]
    monkeypatch.setattr(
        validator, "_read_text", build_read_text_stub(json.dumps(state))
    )

    result = validator.main(
        ["epic-orchestrator-state", "ignored.json", "--require-complete"]
    )

    assert result == 1
