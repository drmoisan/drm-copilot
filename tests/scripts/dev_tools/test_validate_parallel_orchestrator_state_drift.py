"""Tests for the Layer-2 parallel drift gate.

Covers `scripts/dev_tools/_parallel_orchestrator_state_drift.py` at the helper
level -- the key-gated absent-`drift_events` path, the four progressed
`merge_status` values, both reconciled resolution disjuncts, the non-progressed
statuses, and the fail-closed malformed-log paths -- and covers the dispatch
wiring end to end through the public entry point
`validate_parallel_orchestrator_state_text`. The public-validator tests are the
ones that would catch a missing or mis-ordered `errors.extend(...)` call; a helper
unit test alone is blind to that. Every checkpoint is an in-memory structure and
no temporary file is used.
"""

from __future__ import annotations

import copy
import json
from typing import TYPE_CHECKING, cast

import pytest

from scripts.dev_tools._parallel_orchestrator_state_drift import (
    GATE_VIOLATION_PREFIX,
    PROGRESSED_MERGE_STATUSES,
    validate_drift_gate,
)
from scripts.dev_tools._parallel_state_common import VALID_MERGE_STATUS
from scripts.dev_tools.validate_parallel_orchestrator_state import (
    CONTEXT,
    validate_parallel_orchestrator_state_text,
)
from tests.scripts.dev_tools.parallel_drift_test_support import event, item
from tests.scripts.dev_tools.test_validate_parallel_orchestrator_state import (
    build_valid_parallel_state,
    item_at,
)

if TYPE_CHECKING:
    from collections.abc import Sequence

EVENT_AT = "2026-08-08T10-00"

# The four merge statuses that count as progression toward merge, and the four
# that do not. The second group is what keeps the gate compatible with the
# `blocked_drift` state the halt path itself writes.
NON_PROGRESSED_STATUSES = (
    "not_started",
    "worktree_created",
    "blocked_drift",
    "blocked_ci_loop_limit",
)


def _item(
    issue_num: int,
    paths: Sequence[str],
    merge_status: str | None,
    *,
    source: str = "declared",
    computed_at: str = "2026-08-08T09-00",
) -> dict[str, object]:
    """Build an `items[]` record carrying a recorded `merge_status`.

    Args:
        issue_num (int): The item's primary key.
        paths (Sequence[str]): The item's currently recorded radius paths, which
            drive the first resolution disjunct.
        merge_status (str | None): The recorded status; `None` omits the field, as
            a checkpoint may.
        source (str): Radius confidence source, `observed` for the second
            resolution disjunct.
        computed_at (str): Radius timestamp, compared against the event's `at` by
            the second resolution disjunct.

    Returns:
        dict[str, object]: A new item mapping in the F3 shape.
    """
    record = item(issue_num, paths, source=source, computed_at=computed_at)
    if merge_status is not None:
        record["merge_status"] = merge_status
    return record


def _state(
    items: Sequence[object], events: Sequence[object] | None = None
) -> dict[str, object]:
    """Build the minimal in-memory checkpoint the drift gate reads.

    Args:
        items (Sequence[object]): The `items[]` records.
        events (Sequence[object] | None): The `drift_events[]` records; `None`
            omits the key entirely, which is the key-gated path.

    Returns:
        dict[str, object]: A mapping carrying only the collections the gate reads.
    """
    state: dict[str, object] = {"items": list(items)}
    if events is not None:
        state["drift_events"] = list(events)
    return state


def _gate_errors(errors: Sequence[str]) -> list[str]:
    """Keep the errors this feature's invariant owns.

    Args:
        errors (Sequence[str]): A validator's full error list.

    Returns:
        list[str]: The subset carrying the drift-gate token, so an assertion about
        this invariant is not disturbed by an unrelated schema error.
    """
    return [message for message in errors if GATE_VIOLATION_PREFIX in message]


def test_progressed_statuses_are_all_members_of_the_f3_merge_status_enum() -> None:
    """Bind the gate's status set to F3's enum so an upstream rename fails loudly."""

    assert set(PROGRESSED_MERGE_STATUSES) <= set(VALID_MERGE_STATUS)
    assert len(PROGRESSED_MERGE_STATUSES) == 4


def test_gate_returns_no_error_when_the_checkpoint_has_no_drift_events_key() -> None:
    """Stay inert on a checkpoint that predates the drift-event log."""

    state = _state([_item(446, ["docs/**"], "merged")])

    assert validate_drift_gate(state, CONTEXT) == []


@pytest.mark.parametrize("merge_status", PROGRESSED_MERGE_STATUSES)
def test_gate_reports_one_error_per_progressed_item_with_unresolved_drift(
    merge_status: str,
) -> None:
    """Report the violation for each of the four progressed merge statuses."""

    state = _state(
        [_item(446, ["scripts/dev_tools/**"], merge_status)],
        [event(446, ["docs/escaped.md"], EVENT_AT)],
    )

    errors = validate_drift_gate(state, CONTEXT)

    assert len(errors) == 1
    assert errors[0].startswith(GATE_VIOLATION_PREFIX)
    assert "issue_num 446" in errors[0]
    assert repr(merge_status) in errors[0]


def test_gate_reports_one_error_per_violating_item_in_ascending_key_order() -> None:
    """Report every violating item, not just the first, in a deterministic order."""

    state = _state(
        [
            _item(447, ["scripts/dev_tools/**"], "ci_green"),
            _item(446, ["scripts/dev_tools/**"], "pr_open"),
        ],
        [
            event(447, ["docs/escaped.md"], EVENT_AT),
            event(446, ["docs/escaped.md"], EVENT_AT),
        ],
    )

    errors = validate_drift_gate(state, CONTEXT)

    assert len(errors) == 2
    assert "issue_num 446" in errors[0]
    assert "issue_num 447" in errors[1]


def test_gate_reports_nothing_when_the_radius_widened_to_cover_the_escape() -> None:
    """Accept the first resolution disjunct: the recorded radius now covers it."""

    state = _state(
        [_item(446, ["docs/**"], "merged")],
        [event(446, ["docs/escaped.md"], EVENT_AT)],
    )

    assert validate_drift_gate(state, CONTEXT) == []


def test_gate_reports_nothing_when_the_radius_was_rerecorded_from_a_later_diff() -> (
    None
):
    """Accept the second resolution disjunct: an observed radius taken later."""

    state = _state(
        [
            _item(
                446,
                ["scripts/dev_tools/**"],
                "merged",
                source="observed",
                computed_at="2026-08-08T11-00",
            )
        ],
        [event(446, ["docs/escaped.md"], EVENT_AT)],
    )

    assert validate_drift_gate(state, CONTEXT) == []


@pytest.mark.parametrize("merge_status", [*NON_PROGRESSED_STATUSES, None])
def test_gate_reports_nothing_for_an_item_that_has_not_progressed(
    merge_status: str | None,
) -> None:
    """Leave an unresolved item alone until its merge status actually progresses."""

    state = _state(
        [_item(446, ["scripts/dev_tools/**"], merge_status)],
        [event(446, ["docs/escaped.md"], EVENT_AT)],
    )

    assert validate_drift_gate(state, CONTEXT) == []


def test_gate_skips_an_item_whose_primary_key_is_malformed() -> None:
    """Attribute no verdict to an item F3 already rejects for its key."""

    state = _state(
        [
            _item(446, ["scripts/dev_tools/**"], "pr_open"),
            {"issue_num": None, "merge_status": "merged"},
        ],
        [event(446, ["docs/escaped.md"], EVENT_AT)],
    )

    errors = validate_drift_gate(state, CONTEXT)

    assert len(errors) == 1
    assert "issue_num 446" in errors[0]


def test_gate_records_that_a_non_object_event_entry_left_it_unevaluable() -> None:
    """Fail closed and say so when an event entry cannot be read at all."""

    state = _state(
        [_item(446, ["scripts/dev_tools/**"], "pr_open")],
        [None, event(446, ["docs/escaped.md"], EVENT_AT)],
    )

    errors = validate_drift_gate(state, CONTEXT)

    assert len(errors) == 2
    assert "is not an object" in errors[0]
    assert "issue_num 446" in errors[1]


@pytest.mark.parametrize(
    "malformed",
    [
        {
            "item_key": 446,
            "declared": [],
            "observed": [],
            "escaped_paths": [],
            "at": EVENT_AT,
            "action": "raised_blocking_finding",
        },
        {
            "item_key": 0,
            "declared": [],
            "observed": [],
            "escaped_paths": ["docs/escaped.md"],
            "at": EVENT_AT,
            "action": "raised_blocking_finding",
        },
        {
            "item_key": 446,
            "declared": [],
            "observed": [],
            "escaped_paths": ["docs/escaped.md"],
            "at": "",
            "action": "raised_blocking_finding",
        },
    ],
)
def test_gate_fails_closed_on_an_event_the_pure_module_refuses(
    malformed: dict[str, object],
) -> None:
    """Report exactly one fail-closed error carrying the imported refusal message."""

    state = _state([_item(446, ["scripts/dev_tools/**"], "merged")], [malformed])

    errors = validate_drift_gate(state, CONTEXT)

    assert len(errors) == 1
    assert errors[0].startswith(GATE_VIOLATION_PREFIX)
    assert "fails closed" in errors[0]


@pytest.mark.parametrize(
    "state",
    [
        {"items": [], "drift_events": {}},
        {"items": "not-a-list", "drift_events": []},
    ],
)
def test_gate_stays_silent_when_a_collection_is_not_a_list(
    state: dict[str, object],
) -> None:
    """Leave the list-ness error to F3 rather than reporting it twice."""

    assert validate_drift_gate(state, CONTEXT) == []


def test_gate_does_not_mutate_the_checkpoint() -> None:
    """Read both collections without altering either."""

    state = _state(
        [_item(446, ["scripts/dev_tools/**"], "pr_open")],
        [event(446, ["docs/escaped.md"], EVENT_AT)],
    )
    snapshot = copy.deepcopy(state)

    validate_drift_gate(state, CONTEXT)

    assert state == snapshot


def _drifted_checkpoint() -> dict[str, object]:
    """Build an otherwise-valid checkpoint whose only defect is the drift gate.

    Returns:
        dict[str, object]: The builder's valid payload with item 444 progressed to
        `pr_open` and one unresolved drift event recorded for it. The escaped path
        is outside that item's declared radius and the radius source is
        `declared`, so neither resolution disjunct holds.
    """
    state = build_valid_parallel_state()
    item_at(state, 0)["merge_status"] = "pr_open"
    state["drift_events"] = [event(444, ["docs/escaped.md"], EVENT_AT)]
    return state


def test_public_validator_dispatches_the_drift_gate_and_reports_the_violation() -> None:
    """Bind the dispatch wiring: the gate must fire through the public entry point.

    This is the seam test. A checkpoint whose only defect is an unresolved drift
    event on a `pr_open` item must produce the gate error from
    `validate_parallel_orchestrator_state_text`, which a helper-only unit test
    cannot demonstrate.
    """

    errors = validate_parallel_orchestrator_state_text(
        json.dumps(_drifted_checkpoint())
    )

    assert len(errors) == 1
    assert errors[0].startswith(GATE_VIOLATION_PREFIX)
    assert "issue_num 444" in errors[0]


def test_public_validator_still_accepts_a_checkpoint_with_an_empty_drift_log() -> None:
    """Keep a valid checkpoint valid: an empty event log violates no gate."""

    errors = validate_parallel_orchestrator_state_text(
        json.dumps(build_valid_parallel_state())
    )

    assert errors == []


def test_public_validator_reports_no_drift_error_without_the_drift_events_key() -> None:
    """Bind backward compatibility at run time: an absent key means no gate error."""

    state = build_valid_parallel_state()
    del state["drift_events"]

    errors = validate_parallel_orchestrator_state_text(json.dumps(state))

    assert _gate_errors(errors) == []
    assert errors == [f"{CONTEXT} missing required key: drift_events."]


def test_public_validator_reports_the_gate_violation_under_the_completion_gate() -> (
    None
):
    """Keep the gate active alongside the completion gate rather than replacing it."""

    state = _drifted_checkpoint()

    errors = validate_parallel_orchestrator_state_text(
        json.dumps(state), require_complete=True
    )
    gate_errors = _gate_errors(errors)

    assert len(gate_errors) == 1
    assert len(errors) > len(gate_errors)


def test_public_validator_leaves_the_caller_payload_untouched() -> None:
    """Confirm the added dispatch introduced no mutation of the parsed checkpoint."""

    state = _drifted_checkpoint()
    text = json.dumps(state)

    validate_parallel_orchestrator_state_text(text)
    reparsed = cast("dict[str, object]", json.loads(text))

    assert reparsed == state
