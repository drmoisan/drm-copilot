"""Focused receipt-bound cohort and deterministic drift-requeue tests."""

from __future__ import annotations

import copy
from typing import cast

from scripts.dev_tools._parallel_orchestrator_state_receipt_cohort import (
    RECEIPT_COHORT_VIOLATION_PREFIX,
    validate_receipt_bound_cohort_admission,
)

CONTEXT = "Parallel checkpoint"
UNRESOLVED_ERROR = (
    "Parallel checkpoint unresolved drift for items [101] blocks admission "
    "and completion."
)
REQUEUE_ORDER_ERROR = (
    "Parallel checkpoint requeue mutation item order must be ascending; "
    "found: [203, 202]."
)


def _radius(path: str, *, resolved: bool = False) -> dict[str, object]:
    """Build one declared or later-observed blast-radius record."""

    return {
        "paths": [path],
        "modules": [],
        "shared_surfaces": [],
        "contracts": [],
        "source": "observed" if resolved else "declared",
        "computed_at": "2026-08-10T22-00" if resolved else "2026-08-10T20-00",
    }


def _item(
    key: int,
    *,
    state: str,
    merge_status: str,
    path: str,
) -> dict[str, object]:
    """Build one checkpoint item with deterministic receipt references."""

    return {
        "issue_num": key,
        "feature_folder": f"2026-08-10-parallel-item-{key}",
        "state": state,
        "merge_status": merge_status,
        "blast_radius": _radius(path),
        "launch_receipt_path": f"artifacts/orchestration/item-{key}.launch.json",
        "launch_status_path": f"artifacts/orchestration/item-{key}.status.json",
    }


def _state(items: list[dict[str, object]]) -> dict[str, object]:
    """Build the minimal collections consumed by the focused pure helper."""

    return {
        "parallel_slug": "receipt-bound-runtime",
        "current_cohort": 1,
        "recolor_generation": 0,
        "items": items,
        "cohorts": [
            {"index": 0, "generation": 0, "item_keys": [101]},
            {"index": 1, "generation": 0, "item_keys": [202]},
        ],
        "conflict_edges": [{"a": 101, "b": 202, "reason": "path_overlap"}],
        "mutations": [],
        "drift_events": [],
    }


def _receipt_bound_state(*, predecessor_status: str) -> dict[str, object]:
    """Build a started later cohort and its conflicting predecessor."""

    predecessor = _item(
        101,
        state="merged",
        merge_status=predecessor_status,
        path="scripts/**",
    )
    predecessor["merge_receipt_path"] = "artifacts/orchestration/item-101.merge.json"
    if predecessor_status == "worktree_removed":
        predecessor["worktree_removal_receipt_path"] = (
            "artifacts/orchestration/item-101.worktree-removal.json"
        )
    later = _item(
        202,
        state="in_flight",
        merge_status="worktree_created",
        path="scripts/**",
    )
    later["worktree_created_at"] = "2026-08-10T21-00"
    return _state([predecessor, later])


def _resolved_halt_state(*, peer_keys: tuple[int, ...] = (202,)) -> dict[str, object]:
    """Build persisted halt, requeue, and unstarted recolor state."""

    drifting = _item(
        101,
        state="in_flight",
        merge_status="pr_open",
        path="packages/**",
    )
    drifting["blast_radius"] = _radius("packages/**", resolved=True)
    peers = [
        _item(
            key,
            state="blocked",
            merge_status="blocked_drift",
            path="packages/**",
        )
        for key in peer_keys
    ]
    unstarted = [
        _item(301, state="scheduled", merge_status="not_started", path="docs/**"),
        _item(302, state="scheduled", merge_status="not_started", path="docs/**"),
    ]
    state = _state([drifting, *peers, *unstarted])
    state["current_cohort"] = 0
    state["recolor_generation"] = 1
    state["cohorts"] = [
        {"index": 1, "generation": 1, "item_keys": [301]},
        {"index": 2, "generation": 1, "item_keys": [302]},
    ]
    state["conflict_edges"] = [
        {"a": 101, "b": 301, "reason": "path_overlap"},
        {"a": 301, "b": 302, "reason": "path_overlap"},
    ]
    state["drift_events"] = [
        {
            "item_key": 101,
            "declared": ["scripts/**"],
            "observed": ["packages/service.ts"],
            "escaped_paths": ["packages/service.ts"],
            "at": "2026-08-10T21-00",
            "action": "halted_later_started_item",
        }
    ]
    state["mutations"] = [
        {
            "sequence": index + 1,
            "op": "requeue",
            "item_key": key,
            "at": "2026-08-10T21-00",
            "prior_state": "in_flight",
            "new_state": "blocked",
            "disposition": None,
            "recolor_generation": 1,
        }
        for index, key in enumerate(peer_keys)
    ]
    return state


def test_later_cohort_requires_merged_and_worktree_removed_predecessor_receipts() -> (
    None
):
    """A merge receipt alone does not release the later-cohort barrier."""

    errors = validate_receipt_bound_cohort_admission(
        _receipt_bound_state(predecessor_status="merged"), CONTEXT
    )

    assert errors == [
        "PARALLEL_COHORT_BARRIER_VIOLATION: 101 ran concurrently with conflicting 202",
        (
            f"{RECEIPT_COHORT_VIOLATION_PREFIX} later-cohort item 202 started "
            "before conflicting predecessor 101 was both merged and worktree-removed."
        ),
        (
            f"{RECEIPT_COHORT_VIOLATION_PREFIX} predecessor 101 must bind "
            "merge_receipt_path and worktree_removal_receipt_path before "
            "later-cohort item 202 admission."
        ),
    ]


def test_removed_predecessor_with_both_receipts_releases_admission() -> None:
    """Merged and removed predecessor evidence permits the bound later launch."""

    assert (
        validate_receipt_bound_cohort_admission(
            _receipt_bound_state(predecessor_status="worktree_removed"), CONTEXT
        )
        == []
    )


def test_started_later_item_requires_launch_receipt_and_status_paths() -> None:
    """A started item without both external launch references fails closed."""

    state = _receipt_bound_state(predecessor_status="worktree_removed")
    later = cast("list[dict[str, object]]", state["items"])[1]
    del later["launch_status_path"]

    assert validate_receipt_bound_cohort_admission(state, CONTEXT) == [
        (
            f"{RECEIPT_COHORT_VIOLATION_PREFIX} later-cohort item 202 must bind "
            "launch_receipt_path and launch_status_path before admission."
        )
    ]


def test_unresolved_drift_quiesces_admission_and_completion() -> None:
    """One unresolved event produces the shared admission/completion block."""

    state = _resolved_halt_state()
    drifting = cast("list[dict[str, object]]", state["items"])[0]
    drifting["blast_radius"] = _radius("scripts/**")

    assert UNRESOLVED_ERROR in validate_receipt_bound_cohort_admission(state, CONTEXT)


def test_recolor_pins_every_running_item() -> None:
    """A recolor reports pinned assignment and clears its highest cohort."""

    state = _resolved_halt_state()
    cohorts = cast("list[dict[str, object]]", state["cohorts"])
    cohorts.append({"index": 3, "generation": 1, "item_keys": [101]})

    errors = validate_receipt_bound_cohort_admission(state, CONTEXT)

    assert "Parallel checkpoint drift recolor must pin running items [101]." in errors
    assert (
        "Parallel checkpoint recomputed cohort assignments do not match "
        "deterministic unstarted recoloring." in errors
    )


def test_halt_requires_only_later_started_conflicting_peers() -> None:
    """A halt event without its later-started peer requeue is rejected."""

    state = _resolved_halt_state()
    peer = cast("list[dict[str, object]]", state["items"])[1]
    peer["state"] = "in_flight"
    peer["merge_status"] = "pr_open"
    state["mutations"] = []

    assert (
        "Parallel checkpoint drift_events[0] halted_later_started_item action "
        "requires a persisted requeue mutation."
        in validate_receipt_bound_cohort_admission(state, CONTEXT)
    )


def test_recolor_changes_only_the_unstarted_subgraph() -> None:
    """A stale unstarted assignment is rejected against the shared authority."""

    state = _resolved_halt_state()
    state["cohorts"] = [{"index": 1, "generation": 1, "item_keys": [301, 302]}]

    assert (
        "Parallel checkpoint recomputed cohort assignments do not match "
        "deterministic unstarted recoloring."
        in validate_receipt_bound_cohort_admission(state, CONTEXT)
    )


def test_persisted_requeue_order_is_ascending() -> None:
    """Multiple halted peers must be persisted in ascending item order."""

    state = _resolved_halt_state(peer_keys=(202, 203))
    mutations = cast("list[dict[str, object]]", state["mutations"])
    state["mutations"] = list(reversed(mutations))

    assert REQUEUE_ORDER_ERROR in validate_receipt_bound_cohort_admission(
        state, CONTEXT
    )


def test_errors_are_deterministic_and_input_is_immutable() -> None:
    """Repeated validation preserves both diagnostic order and checkpoint data."""

    state = _resolved_halt_state(peer_keys=(202, 203))
    mutations = cast("list[dict[str, object]]", state["mutations"])
    state["mutations"] = list(reversed(mutations))
    drifting = cast("list[dict[str, object]]", state["items"])[0]
    drifting["blast_radius"] = _radius("scripts/**")
    snapshot = copy.deepcopy(state)

    first = validate_receipt_bound_cohort_admission(state, CONTEXT)
    second = validate_receipt_bound_cohort_admission(state, CONTEXT)

    assert first == second
    assert first.index(UNRESOLVED_ERROR) < first.index(REQUEUE_ORDER_ERROR)
    assert state == snapshot
