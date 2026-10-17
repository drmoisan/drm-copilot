"""Tests for epic launch-binding edge cases."""

from __future__ import annotations

import pytest

from scripts.dev_tools._epic_orchestrator_state_launch_binding import (
    validate_epic_child_launch_bindings,
    validate_epic_planner_child_launch_bindings,
)
from tests.scripts.dev_tools.typescript_twin_test_support import (
    literals_missing_from_twin,
)

DEPLOYMENT_AGENT_ERROR = (
    "Epic planner checkpoint features[0] launch binding."
    "model_routing_receipt.deployment_agent "
    "must be a non-empty string."
)
WORKTREE_PATH_ERROR = (
    "Epic planner checkpoint features[0] launch binding.worktree_path "
    "must be a non-empty canonical absolute path."
)
ASSERTED_MESSAGES = (DEPLOYMENT_AGENT_ERROR, WORKTREE_PATH_ERROR)


def test_planner_model_receipt_requires_deployment_agent() -> None:
    """Require a deployment agent on the planner model receipt."""

    features: list[object] = [{"model_routing_receipt": {}}]

    errors = validate_epic_planner_child_launch_bindings(features)

    assert DEPLOYMENT_AGENT_ERROR in errors


@pytest.mark.parametrize(
    ("path", "rejected"),
    [
        ("/", False),
        ("/repo\\worktree", True),
        ("\\\\server\\share\\worktree", False),
        ("worktree", True),
    ],
    ids=["root", "posix-backslash", "unc", "bare-name"],
)
def test_worktree_path_canonical_forms(path: str, rejected: bool) -> None:
    """Classify root, backslash, UNC, and bare-name worktree paths."""

    features: list[object] = [{"worktree_path": path}]

    errors = validate_epic_planner_child_launch_bindings(features)

    assert (WORKTREE_PATH_ERROR in errors) is rejected


def test_child_launch_bindings_skip_non_list_features() -> None:
    """Skip child launch bindings when features is not a list."""

    state: dict[str, object] = {"features": "not-a-list"}

    errors = validate_epic_child_launch_bindings(state, require_complete=True)

    assert errors == []


def test_asserted_messages_match_typescript_twin() -> None:
    """Keep every asserted message identical to its TypeScript twin literal."""

    missing = literals_missing_from_twin(
        ASSERTED_MESSAGES,
        "lib/validate/epic-orchestrator-state-launch-binding-edges.test.ts",
    )

    assert missing == []
