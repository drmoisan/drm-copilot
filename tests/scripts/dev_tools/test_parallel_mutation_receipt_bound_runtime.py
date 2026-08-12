"""Receipt-bound mutation and mode-transition tests for the public validator."""

from __future__ import annotations

import copy
import json
from typing import cast

import pytest

from scripts.dev_tools.validate_parallel_orchestrator_state import (
    validate_parallel_orchestrator_state_text,
)

CONTEXT = "Parallel checkpoint"
WORKTREE = "C:/worktrees/parallel-item-444"


def _radius() -> dict[str, object]:
    """Build one valid declared blast-radius record."""

    return {
        "paths": ["scripts/dev_tools/**"],
        "modules": ["scripts"],
        "shared_surfaces": [],
        "contracts": [],
        "source": "declared",
        "computed_at": "2026-08-10T20-25",
    }


def _item(
    key: int, *, state: str, merge_status: str, worktree: str | None = None
) -> dict[str, object]:
    """Build one checkpoint item with an optional durable worktree identity."""

    result: dict[str, object] = {
        "issue_num": key,
        "feature_folder": f"2026-08-10-parallel-item-{key}",
        "state": state,
        "merge_status": merge_status,
        "blast_radius": _radius(),
    }
    if worktree is not None:
        result["worktree_identity"] = worktree
    return result


def _state() -> dict[str, object]:
    """Build a valid in-progress checkpoint for mutation tests."""

    return {
        "objective": "validate receipt-bound parallel mutation state",
        "completed_steps": ["manifest_parsed"],
        "next_step": "cohort_0_launch",
        "last_updated": "2026-08-10T20-25",
        "route_id": "parallel",
        "parallel_slug": "receipt-bound-mutations",
        "parallel_manifest_path": (
            "docs/features/parallel/receipt-bound-mutations/parallel.md"
        ),
        "parallel_status_doc_path": (
            "docs/features/parallel/receipt-bound-mutations/parallel-status.md"
        ),
        "mode": "closed",
        "max_concurrency": 2,
        "current_cohort": 0,
        "recolor_generation": 0,
        "cohorts": [{"index": 0, "generation": 0, "item_keys": [444, 445]}],
        "items": [
            _item(444, state="in_flight", merge_status="pr_open", worktree=WORKTREE),
            _item(445, state="scheduled", merge_status="not_started"),
        ],
        "conflict_edges": [],
        "mutations": [],
        "drift_events": [],
    }


def _remove_mutation(
    *, disposition: str | None, generation: int = 0, prior_state: str = "in_flight"
) -> dict[str, object]:
    """Build one complete seven-field remove record."""

    return {
        "op": "remove",
        "item_key": 444,
        "at": "2026-08-10T20-34",
        "prior_state": prior_state,
        "new_state": "withdrawn",
        "disposition": disposition,
        "recolor_generation": generation,
    }


def _receipt(operation: str) -> dict[str, object]:
    """Build one exact item/worktree-bound confirmation receipt reference."""

    return {
        "mutation_index": 0,
        "receipt_path": (
            f"artifacts/orchestration/mutations/item-444-{operation}.json"
        ),
        "operation": operation,
        "item_key": 444,
        "worktree_identity": WORKTREE,
        "confirmation_token": f"confirm:{operation}:444:{WORKTREE}",
    }


def _receipt_bound_removal(operation: str) -> dict[str, object]:
    """Build post-removal state with its exact durable confirmation receipt."""

    state = _state()
    items = cast("list[dict[str, object]]", state["items"])
    items[0]["state"] = "withdrawn"
    state["cohorts"] = [{"index": 0, "generation": 0, "item_keys": [445]}]
    state["mutations"] = [_remove_mutation(disposition=operation)]
    state["mutation_receipts"] = [_receipt(operation)]
    return state


def _validate(state: dict[str, object], *, require_complete: bool = False) -> list[str]:
    """Serialize a checkpoint and return public-validator diagnostics."""

    return validate_parallel_orchestrator_state_text(
        json.dumps(state), require_complete=require_complete
    )


def test_legacy_checkpoint_without_mutation_receipts_remains_compatible() -> None:
    """Receipt validation is additive and presence-gated."""

    assert _validate(_state()) == []


@pytest.mark.parametrize("operation", ["detach", "abandon"])
def test_exact_detach_or_abandon_receipt_is_accepted(operation: str) -> None:
    """Exact operation, item, worktree, path, and token binding validates."""

    assert _validate(_receipt_bound_removal(operation)) == []


@pytest.mark.parametrize(
    ("field", "value", "expected"),
    [
        ("operation", "abandon", "operation must match disposition 'detach'"),
        ("item_key", 445, "item_key must match mutation item 444"),
        ("worktree_identity", "C:/wrong", "worktree_identity must match item 444"),
        ("confirmation_token", "confirm:detach:444:C:/wrong", "token must equal"),
    ],
)
def test_detach_receipt_rejects_each_mismatched_binding(
    field: str, value: object, expected: str
) -> None:
    """Every confirmation tuple member is independently fail-closed."""

    state = _receipt_bound_removal("detach")
    receipt = cast("list[dict[str, object]]", state["mutation_receipts"])[0]
    receipt[field] = value

    assert expected in "\n".join(_validate(state))


def test_receipt_bound_in_flight_removal_requires_a_confirmation() -> None:
    """A receipt-mode in-flight removal cannot omit its confirmation record."""

    state = _receipt_bound_removal("detach")
    state["mutation_receipts"] = []

    assert "requires one matching mutation_receipts[] entry" in "\n".join(
        _validate(state)
    )


def test_merged_removal_is_rejected_through_the_public_validator() -> None:
    """The shared removal authority rejects an already merged prior state."""

    state = _state()
    items = cast("list[dict[str, object]]", state["items"])
    items[0].update({"state": "merged", "merge_status": "merged"})
    state["mutations"] = [_remove_mutation(disposition=None, prior_state="merged")]

    assert "cannot remove item 444 from prior_state 'merged'" in "\n".join(
        _validate(state)
    )


def test_in_flight_removal_cannot_move_the_recolor_generation() -> None:
    """A detach leaves pinned-generation state unchanged."""

    state = _receipt_bound_removal("detach")
    state["recolor_generation"] = 1
    cast("list[dict[str, object]]", state["cohorts"])[0]["generation"] = 1
    cast("list[dict[str, object]]", state["mutations"])[0]["recolor_generation"] = 1

    assert "in-flight remove must preserve recolor_generation 0; found: 1" in (
        "\n".join(_validate(state))
    )


def test_close_with_in_flight_work_is_rejected_atomically() -> None:
    """A recorded close cannot coexist with any in-flight item."""

    state = _state()
    state["mutations"] = [
        {
            "op": "close",
            "item_key": None,
            "at": "2026-08-10T20-35",
            "prior_state": None,
            "new_state": None,
            "disposition": None,
            "recolor_generation": 0,
        }
    ]

    assert "close requires no item in flight; still in flight: [444]" in "\n".join(
        _validate(state)
    )


def test_incomplete_and_out_of_order_records_remain_rejected() -> None:
    """Receipt additions do not weaken complete ordered seven-field records."""

    incomplete = _receipt_bound_removal("detach")
    del cast("list[dict[str, object]]", incomplete["mutations"])[0]["at"]
    assert "is missing required field: at" in "\n".join(_validate(incomplete))

    out_of_order = _state()
    out_of_order["recolor_generation"] = 1
    out_of_order["mutations"] = [
        {**_remove_mutation(disposition=None), "recolor_generation": 1},
        {**_remove_mutation(disposition=None), "recolor_generation": 0},
    ]
    assert "mutation log must be monotonically non-decreasing" in "\n".join(
        _validate(out_of_order)
    )


def test_open_mode_cannot_complete_without_a_close_record() -> None:
    """Explicit completion rejects an open run whose admissions remain open."""

    state = _state()
    state["mode"] = "open"
    state["cohorts"] = []
    for item in cast("list[dict[str, object]]", state["items"]):
        item.update({"state": "merged", "merge_status": "worktree_removed"})

    assert "open mode requires a mutations[] entry with op 'close'" in "\n".join(
        _validate(state, require_complete=True)
    )


def test_receipt_validation_does_not_mutate_checkpoint_input() -> None:
    """Repeated receipt validation is deterministic and input-immutable."""

    state = _receipt_bound_removal("detach")
    snapshot = copy.deepcopy(state)

    assert _validate(state) == _validate(state)
    assert state == snapshot
