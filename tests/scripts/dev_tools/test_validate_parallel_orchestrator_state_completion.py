"""Tests for the parallel checkpoint record logs and completion gate.

Covers the full ``mutations[]`` shape including every schema S5 null rule and
the in-flight-removal disposition rule (invariants 16 and 17), the full
``drift_events[]`` shape (invariant 18), the non-list receipt-array rejection
that completes invariant 19, and the mode-dependent completion gate
(invariants 20 and 21): closed-mode pass and fail, the open-mode close-mutation
requirement, the withdrawn-item exemption, and the gate-off default.

The mutation and drift logs live here rather than in
``test_validate_parallel_orchestrator_state_structures.py`` so each of the
three Phase 1 test files stays under the repository's 500-line limit; the two
record collections are the inputs the completion gate reads, so they sit
naturally beside it.
"""

from __future__ import annotations

import pytest

from scripts.dev_tools._parallel_state_common import (
    VALID_DISPOSITIONS,
    VALID_DRIFT_ACTIONS,
    VALID_MUTATION_OPS,
)
from tests.scripts.dev_tools.test_validate_parallel_orchestrator_state import (
    build_valid_parallel_state,
    item_at,
    validate,
)

CLOSE_MUTATION: dict[str, object] = {
    "op": "close",
    "item_key": None,
    "at": "2026-08-07T12-00",
    "prior_state": None,
    "new_state": None,
    "disposition": None,
    "recolor_generation": 0,
}


def build_mutation(**overrides: object) -> dict[str, object]:
    """Return a valid requeue mutation with the supplied overrides applied."""

    base: dict[str, object] = {
        "op": "requeue",
        "item_key": 444,
        "at": "2026-08-07T11-00",
        "prior_state": "scheduled",
        "new_state": "admitted",
        "disposition": None,
        "recolor_generation": 0,
    }
    base.update(overrides)
    return base


def build_drift_event(**overrides: object) -> dict[str, object]:
    """Return a valid drift event with the supplied overrides applied."""

    base: dict[str, object] = {
        "item_key": 444,
        "declared": ["scripts/dev_tools/**"],
        "observed": ["scripts/dev_tools/a.py", "extensions/b.ts"],
        "escaped_paths": ["extensions/b.ts"],
        "at": "2026-08-07T11-30",
        "action": "raised_blocking_finding",
    }
    base.update(overrides)
    return base


def state_with_mutation(entry: dict[str, object]) -> dict[str, object]:
    """Return a valid checkpoint whose mutation log holds one supplied entry."""

    state = build_valid_parallel_state()
    state["mutations"] = [entry]
    return state


def state_with_drift(events: object) -> dict[str, object]:
    """Return a valid checkpoint whose drift log is replaced."""

    state = build_valid_parallel_state()
    state["drift_events"] = events
    return state


def build_completed_state() -> dict[str, object]:
    """Return a closed-mode checkpoint in which every item merged and closed."""

    state = build_valid_parallel_state()
    for index in (0, 1):
        item_at(state, index)["state"] = "merged"
        item_at(state, index)["merge_status"] = "worktree_removed"
    state["cohorts"] = []
    return state


def test_invariant_16_accepts_a_valid_requeue_mutation() -> None:
    """A fully populated item-scoped mutation validates."""

    assert validate(state_with_mutation(build_mutation())) == []


def test_invariant_16_accepts_a_valid_close_mutation() -> None:
    """The run-level close record carries a null key and null states."""

    assert validate(state_with_mutation(dict(CLOSE_MUTATION))) == []


def test_invariant_16_rejects_non_list_mutations() -> None:
    """A non-list mutations value yields one collection-level error."""

    state = build_valid_parallel_state()
    state["mutations"] = {}

    assert "Parallel checkpoint mutations must be a list." in validate(state)


def test_invariant_16_rejects_non_object_mutation() -> None:
    """A non-object mutation entry is named by its positional index."""

    state = build_valid_parallel_state()
    state["mutations"] = ["close"]

    assert "Parallel checkpoint mutations[0] must be an object." in validate(state)


def test_invariant_16_rejects_unknown_op() -> None:
    """An op outside the four-value enum is rejected."""

    assert (
        "Parallel checkpoint mutations[0] op must be one of add, remove, "
        "close, requeue; found: 'rename'."
        in validate(state_with_mutation(build_mutation(op="rename")))
    )


def test_invariant_16_enum_carries_exactly_four_ops() -> None:
    """The mutation-op vocabulary matches spec S4 exactly."""

    assert len(VALID_MUTATION_OPS) == 4


def test_invariant_16_rejects_item_key_on_close() -> None:
    """Close is a run-level operation and must carry no item key."""

    close = dict(CLOSE_MUTATION)
    close["item_key"] = 444

    assert (
        "Parallel checkpoint mutations[0] item_key must be null for op "
        "'close'; found: 444." in validate(state_with_mutation(close))
    )


@pytest.mark.parametrize("op", ["add", "remove", "requeue"])
def test_invariant_16_rejects_unresolved_item_key(op: str) -> None:
    """Every item-scoped op must name a declared items[].issue_num."""

    entry = build_mutation(op=op, item_key=999, prior_state=None)

    assert (
        "Parallel checkpoint mutations[0] item_key 999 does not resolve to an "
        "items[].issue_num." in validate(state_with_mutation(entry))
    )


def test_invariant_16_rejects_blank_at_timestamp() -> None:
    """A mutation must record when it happened."""

    assert (
        "Parallel checkpoint mutations[0] at must be a non-empty string."
        in validate(state_with_mutation(build_mutation(at="")))
    )


@pytest.mark.parametrize("op", ["add", "close"])
def test_invariant_16_requires_null_prior_state(op: str) -> None:
    """Add introduces an item and close is run-level, so neither has a prior."""

    entry = build_mutation(op=op, item_key=None if op == "close" else 444)

    assert (
        f"Parallel checkpoint mutations[0] prior_state must be null for op "
        f"{op!r}; found: 'scheduled'." in validate(state_with_mutation(entry))
    )


def test_invariant_16_requires_null_new_state_for_close() -> None:
    """The run-level close record carries no new state."""

    entry = build_mutation(op="close", item_key=None, prior_state=None)

    assert (
        "Parallel checkpoint mutations[0] new_state must be null for op "
        "'close'; found: 'admitted'." in validate(state_with_mutation(entry))
    )


@pytest.mark.parametrize("field", ["prior_state", "new_state"])
def test_invariant_16_rejects_out_of_enum_state_field(field: str) -> None:
    """A non-null state field must be an item-state enum member."""

    entry = build_mutation(**{field: "parked"})

    assert any(
        error.startswith(
            f"Parallel checkpoint mutations[0] {field} must be null or one of "
        )
        and error.endswith("found: 'parked'.")
        for error in validate(state_with_mutation(entry))
    )


@pytest.mark.parametrize("generation", [-1, True, "0", None])
def test_invariant_16_rejects_non_integer_mutation_generation(
    generation: object,
) -> None:
    """A mutation's recolor_generation must be a non-negative integer."""

    entry = build_mutation(recolor_generation=generation)

    assert (
        f"Parallel checkpoint mutations[0] recolor_generation must be a "
        f"non-negative integer; found: {generation!r}."
        in validate(state_with_mutation(entry))
    )


def test_invariant_16_rejects_mutation_generation_above_top_level() -> None:
    """A mutation cannot claim a generation the run has not reached."""

    assert (
        "Parallel checkpoint mutations[0] recolor_generation 4 must not exceed "
        "recolor_generation 0."
        in validate(state_with_mutation(build_mutation(recolor_generation=4)))
    )


@pytest.mark.parametrize("disposition", VALID_DISPOSITIONS)
def test_invariant_17_accepts_both_in_flight_dispositions(disposition: str) -> None:
    """Detaching and abandoning are the two recorded in-flight outcomes."""

    entry = build_mutation(
        op="remove",
        prior_state="in_flight",
        new_state="withdrawn",
        disposition=disposition,
    )

    assert validate(state_with_mutation(entry)) == []


def test_invariant_17_requires_disposition_on_in_flight_removal() -> None:
    """Removing running work must record how that work was disposed of."""

    entry = build_mutation(op="remove", prior_state="in_flight", new_state="withdrawn")

    assert (
        "Parallel checkpoint mutations[0] disposition must be one of detach, "
        "abandon for an in-flight removal; found: None."
        in validate(state_with_mutation(entry))
    )


@pytest.mark.parametrize("op", ["add", "requeue", "remove"])
def test_invariant_17_rejects_disposition_outside_in_flight_removal(op: str) -> None:
    """A disposition anywhere else would imply a decision never taken."""

    entry = build_mutation(op=op, prior_state="scheduled", disposition="detach")

    assert (
        "Parallel checkpoint mutations[0] disposition must be null unless op "
        "is 'remove' with prior_state 'in_flight'; found: 'detach'."
        in validate(state_with_mutation(entry))
    )


def test_invariant_18_accepts_a_valid_drift_event() -> None:
    """A fully populated drift event validates."""

    assert validate(state_with_drift([build_drift_event()])) == []


def test_invariant_18_rejects_non_list_drift_events() -> None:
    """A non-list drift_events value yields one collection-level error."""

    assert "Parallel checkpoint drift_events must be a list." in validate(
        state_with_drift({})
    )


def test_invariant_18_rejects_non_object_drift_event() -> None:
    """A non-object drift entry is named by its positional index."""

    assert "Parallel checkpoint drift_events[0] must be an object." in validate(
        state_with_drift(["drift"])
    )


@pytest.mark.parametrize("item_key", [999, "444", True, None])
def test_invariant_18_rejects_unresolved_item_key(item_key: object) -> None:
    """A drift event must name a declared items[].issue_num."""

    assert (
        f"Parallel checkpoint drift_events[0] item_key {item_key!r} does not "
        f"resolve to an items[].issue_num."
        in validate(state_with_drift([build_drift_event(item_key=item_key)]))
    )


@pytest.mark.parametrize("field", ["declared", "observed"])
def test_invariant_18_rejects_malformed_path_set(field: str) -> None:
    """Both compared path sets must be lists of non-empty strings."""

    assert (
        f"Parallel checkpoint drift_events[0] {field} must be a list of "
        f"non-empty strings."
        in validate(state_with_drift([build_drift_event(**{field: [""]})]))
    )


@pytest.mark.parametrize("field", ["declared", "observed"])
def test_invariant_18_accepts_empty_path_set(field: str) -> None:
    """An empty declared or observed set is legitimate, unlike escaped_paths."""

    empty: list[str] = []

    assert validate(state_with_drift([build_drift_event(**{field: empty})])) == []


@pytest.mark.parametrize("escaped", [[], "extensions/b.ts", [""], None])
def test_invariant_18_rejects_empty_or_malformed_escaped_paths(
    escaped: object,
) -> None:
    """An event with no escaped path is not a drift event at all."""

    assert (
        "Parallel checkpoint drift_events[0] escaped_paths must be a non-empty "
        "list of non-empty strings."
        in validate(state_with_drift([build_drift_event(escaped_paths=escaped)]))
    )


def test_invariant_18_rejects_blank_at_timestamp() -> None:
    """A drift event must record when detection happened."""

    assert (
        "Parallel checkpoint drift_events[0] at must be a non-empty string."
        in validate(state_with_drift([build_drift_event(at="  ")]))
    )


@pytest.mark.parametrize("action", VALID_DRIFT_ACTIONS)
def test_invariant_18_accepts_both_drift_actions(action: str) -> None:
    """Both recorded drift responses are accepted."""

    assert validate(state_with_drift([build_drift_event(action=action)])) == []


def test_invariant_18_rejects_unknown_drift_action() -> None:
    """An action outside the two-value enum is rejected."""

    assert (
        "Parallel checkpoint drift_events[0] action must be one of "
        "raised_blocking_finding, halted_later_started_item; found: 'ignored'."
        in validate(state_with_drift([build_drift_event(action="ignored")]))
    )


@pytest.mark.parametrize(
    "key", ["delegation_receipts", "skill_receipts", "mcp_call_receipts"]
)
def test_invariant_19_rejects_non_list_receipt_value(key: str) -> None:
    """A present receipt array that is not a list yields one error."""

    state = build_valid_parallel_state()
    state[key] = {"agent_name": "atomic-executor"}

    assert f"Parallel checkpoint {key} must be a list when present." in validate(state)


def test_invariants_20_and_21_gate_is_inactive_by_default() -> None:
    """Without require_complete an unfinished run validates cleanly."""

    assert validate(build_valid_parallel_state()) == []


def test_invariant_20_closed_mode_rejects_unmerged_item() -> None:
    """Under the gate, a non-withdrawn item must reach a terminal merge."""

    assert (
        "Parallel checkpoint items[0] completion validation failed: "
        "merge_status is not merged or worktree_removed; found: None."
        in validate(build_valid_parallel_state(), require_complete=True)
    )


@pytest.mark.parametrize("merge_status", ["merged", "worktree_removed"])
def test_invariant_20_closed_mode_accepts_terminal_merge_status(
    merge_status: str,
) -> None:
    """Both terminal merge statuses satisfy the closed-mode gate."""

    state = build_completed_state()
    for index in (0, 1):
        item_at(state, index)["merge_status"] = merge_status

    assert validate(state, require_complete=True) == [
        "Parallel checkpoint Codex readiness evidence is required."
    ]


def test_invariant_20_closed_mode_rejects_a_blocked_item() -> None:
    """A blocked item is not withdrawn, so the gate still requires a merge."""

    state = build_completed_state()
    item_at(state, 1)["state"] = "blocked"
    item_at(state, 1)["merge_status"] = "blocked_drift"

    assert (
        "Parallel checkpoint items[1] completion validation failed: "
        "merge_status is not merged or worktree_removed; found: 'blocked_drift'."
        in validate(state, require_complete=True)
    )


def test_invariant_20_exempts_a_withdrawn_item() -> None:
    """A withdrawn item left the run and never reaches a merge outcome."""

    state = build_completed_state()
    item_at(state, 1)["state"] = "withdrawn"
    del item_at(state, 1)["merge_status"]

    assert validate(state, require_complete=True) == [
        "Parallel checkpoint Codex readiness evidence is required."
    ]


def test_invariant_21_open_mode_requires_a_close_mutation() -> None:
    """An open run has no other signal that admissions have stopped."""

    state = build_completed_state()
    state["mode"] = "open"

    assert validate(state, require_complete=True) == [
        "Parallel checkpoint Codex readiness evidence is required.",
        "Parallel checkpoint completion validation failed: open mode requires "
        "a mutations[] entry with op 'close'.",
    ]


def test_invariant_21_open_mode_accepts_a_recorded_close() -> None:
    """A recorded close mutation satisfies the open-mode gate."""

    state = build_completed_state()
    state["mode"] = "open"
    state["mutations"] = [dict(CLOSE_MUTATION)]

    assert validate(state, require_complete=True) == [
        "Parallel checkpoint Codex readiness evidence is required."
    ]


def test_invariant_21_open_mode_still_applies_the_per_item_condition() -> None:
    """Recording the close does not waive invariant 20's per-item rule."""

    state = build_valid_parallel_state()
    state["mode"] = "open"
    state["mutations"] = [dict(CLOSE_MUTATION)]
    errors = validate(state, require_complete=True)

    assert any("completion validation failed: merge_status" in e for e in errors)
