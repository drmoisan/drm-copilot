"""Per-item PR, exact-head CI, merge, and worktree-removal receipt tests."""

from __future__ import annotations

import copy
import json
from typing import cast

import pytest

from scripts.dev_tools.validate_parallel_orchestrator_state import (
    validate_parallel_orchestrator_state_text,
)
from tests.scripts.dev_tools.test_validate_parallel_orchestrator_state import (
    build_valid_parallel_state,
)

CONTEXT = "Parallel checkpoint"
HEAD_A = "a" * 40
HEAD_B = "b" * 40
MERGE_A = "c" * 40
MERGE_B = "d" * 40


def _items(state: dict[str, object]) -> list[dict[str, object]]:
    """Return mutable object-shaped checkpoint items from a test fixture."""

    value = state["items"]
    if not isinstance(value, list):
        raise TypeError("fixture items must be a list")
    return cast("list[dict[str, object]]", value)


def _completed_state() -> dict[str, object]:
    """Build one legacy-compatible completed checkpoint."""

    state = build_valid_parallel_state()
    state["cohorts"] = []
    for item in _items(state):
        item["state"] = "merged"
        item["merge_status"] = "worktree_removed"
    return state


def _bind_completion(item: dict[str, object], *, head_sha: str, merge_sha: str) -> None:
    """Bind one item to a versioned main-only terminal completion receipt."""

    key = cast("int", item["issue_num"])
    branch = f"feature/parallel-item-{key}"
    worktree = f"C:/worktrees/parallel-item-{key}"
    receipt = f"artifacts/orchestration/parallel/item-{key}-completion.json"
    item.update(
        {
            "branch_name": branch,
            "base_branch": "main",
            "worktree_path": worktree,
            "checked_head": head_sha,
            "pr_number": key,
            "pr_url": f"https://github.example/pull/{key}",
            "pr_base_branch": "main",
            "pr_head_branch": branch,
            "pr_head_sha": head_sha,
            "pr_state": "MERGED",
            "checks_head_sha": head_sha,
            "checks_conclusion": "success",
            "merged_at": "2026-08-10T21:30:00Z",
            "merge_commit_sha": merge_sha,
            "merge_receipt_path": receipt,
            "worktree_removed_at": "2026-08-10T21:31:00Z",
            "worktree_removal_receipt_path": receipt,
            "completion_receipt_path": receipt,
        }
    )


def _receipt_state() -> dict[str, object]:
    """Build a completed checkpoint with two distinct per-item receipts."""

    state = _completed_state()
    first, second = _items(state)
    _bind_completion(first, head_sha=HEAD_A, merge_sha=MERGE_A)
    _bind_completion(second, head_sha=HEAD_B, merge_sha=MERGE_B)
    return state


def _validate(state: dict[str, object], *, complete: bool = True) -> list[str]:
    """Serialize a state and invoke the public checkpoint validator."""

    return validate_parallel_orchestrator_state_text(
        json.dumps(state), require_complete=complete
    )


def _new_errors(state: dict[str, object]) -> list[str]:
    """Remove the unrelated external Codex evidence diagnostic."""

    return [
        error
        for error in _validate(state)
        if error != f"{CONTEXT} Codex readiness evidence is required."
    ]


def test_legacy_completed_checkpoint_without_receipt_fields_remains_compatible() -> (
    None
):
    """The additive receipt validator does not invalidate legacy checkpoints."""

    assert _new_errors(_completed_state()) == []


def test_distinct_main_only_item_receipts_complete_successfully() -> None:
    """Each item may complete through one distinct main-targeted PR."""

    assert _new_errors(_receipt_state()) == []


def test_duplicate_pr_number_is_rejected_across_items() -> None:
    """Two items cannot share a PR or form a fan-in completion path."""

    state = _receipt_state()
    first, second = _items(state)
    second["pr_number"] = first["pr_number"]

    assert _new_errors(state) == [
        f"{CONTEXT} completion receipts assign PR {first['pr_number']} "
        "to multiple items."
    ]


@pytest.mark.parametrize(
    ("field", "value", "expected"),
    [
        ("pr_base_branch", "epic/integration", "PR base branch must be 'main'"),
        ("pr_head_branch", "feature/wrong", "PR head branch must match branch_name"),
        ("pr_head_sha", HEAD_B, "PR head SHA must match checked_head"),
        ("checks_head_sha", HEAD_B, "checks head SHA must match pr_head_sha"),
        (
            "checks_conclusion",
            "failure",
            "required checks conclusion must be 'success'",
        ),
        ("pr_state", "OPEN", "PR state must be 'MERGED'"),
    ],
)
def test_exact_pr_and_check_binding_rejects_each_mismatch(
    field: str, value: object, expected: str
) -> None:
    """Base, branch, head, checks, and merged state fail closed independently."""

    state = _receipt_state()
    _items(state)[0][field] = value

    assert expected in "\n".join(_new_errors(state))


@pytest.mark.parametrize(
    ("field", "expected"),
    [
        ("merge_commit_sha", "merge_commit_sha must be a 40-character SHA"),
        ("merge_receipt_path", "merge_receipt_path must be repository-relative"),
        ("worktree_removed_at", "worktree_removed_at must be a non-empty string"),
        (
            "worktree_removal_receipt_path",
            "worktree_removal_receipt_path must be repository-relative",
        ),
        (
            "completion_receipt_path",
            "completion_receipt_path must be repository-relative",
        ),
    ],
)
def test_terminal_receipt_rejects_each_missing_merge_or_removal_field(
    field: str, expected: str
) -> None:
    """A partial merge or worktree-removal receipt cannot complete an item."""

    state = _receipt_state()
    del _items(state)[0][field]

    assert expected in "\n".join(_new_errors(state))


def test_terminal_completion_rejects_a_residual_worktree_status() -> None:
    """Merged alone is not terminal while the item worktree remains present."""

    state = _receipt_state()
    _items(state)[0]["merge_status"] = "merged"

    assert "merge_status must be 'worktree_removed'" in "\n".join(_new_errors(state))


def test_receipt_paths_reject_absolute_traversal_and_backslash_forms() -> None:
    """Receipt references remain normalized and repository-relative."""

    for path in ("C:/outside.json", "../outside.json", "artifacts\\outside.json"):
        state = _receipt_state()
        _items(state)[0]["completion_receipt_path"] = path

        assert "completion_receipt_path must be repository-relative" in "\n".join(
            _new_errors(state)
        )


def test_receipt_validation_preserves_error_order_and_input() -> None:
    """Diagnostics are deterministic and validation does not mutate its input."""

    state = _receipt_state()
    first = _items(state)[0]
    first.update(
        {
            "pr_base_branch": "epic/integration",
            "checks_head_sha": HEAD_B,
            "checks_conclusion": "failure",
            "pr_state": "OPEN",
        }
    )
    snapshot = copy.deepcopy(state)

    first_run = _new_errors(state)
    assert first_run == _new_errors(state)
    assert state == snapshot
    assert [
        "PR base branch",
        "checks head SHA",
        "required checks conclusion",
        "PR state",
    ] == [
        next(
            label
            for label in (
                "PR base branch",
                "checks head SHA",
                "required checks conclusion",
                "PR state",
            )
            if label in error
        )
        for error in first_run
    ]
