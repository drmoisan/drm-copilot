"""Tests for the F6 mutation-protocol validator helper (spec FR9).

Covers FR9 invariants 1 and 2 of
``scripts/dev_tools/_parallel_orchestrator_state_mutations.py`` -- mutation-entry
shape completeness and monotonically non-decreasing ``recolor_generation`` in
append order -- plus the backward-compatibility guarantee that a checkpoint
carrying no ``mutations`` key produces no new error, and the no-mutation-of-input
guarantee. Invariant 3, the mode-dependent completion gate, is covered by
``test_validate_parallel_orchestrator_state_mutation_modes.py``, which reuses the
builders and accessors defined here. The two files are partitioned only to stay
under the repository's 500-line limit.

Every fixture is a literal dict with ``int`` item keys, matching F3's
``items[].issue_num`` primary-key type. Nothing here touches the filesystem, so
no temporary file is created. Each test drives the helper both directly and,
where the assertion is about the wired surface, through
``validate_parallel_orchestrator_state_text`` so the one additive call line is
exercised as well.
"""

from __future__ import annotations

import copy
import json
from typing import cast

import pytest

from scripts.dev_tools._parallel_orchestrator_state_mutations import (
    MUTATION_ENTRY_FIELDS,
    validate_mutation_protocol,
)
from scripts.dev_tools.validate_parallel_orchestrator_state import (
    CONTEXT,
    validate_parallel_orchestrator_state_text,
)

# One well-formed item-scoped entry and one well-formed run-close entry, used as
# the base of every fixture so a single overridden field explains any error.
REQUEUE_ENTRY: dict[str, object] = {
    "op": "requeue",
    "item_key": 444,
    "at": "2026-08-08T11-00",
    "prior_state": "in_flight",
    "new_state": "blocked",
    "disposition": None,
    "recolor_generation": 1,
}

CLOSE_ENTRY: dict[str, object] = {
    "op": "close",
    "item_key": None,
    "at": "2026-08-08T12-00",
    "prior_state": None,
    "new_state": None,
    "disposition": None,
    "recolor_generation": 1,
}

ADD_ENTRY: dict[str, object] = {
    "op": "add",
    "item_key": 445,
    "at": "2026-08-08T10-00",
    "prior_state": None,
    "new_state": "scheduled",
    "disposition": None,
    "recolor_generation": 0,
}


def build_blast_radius() -> dict[str, object]:
    """Return a minimally valid, planner-declared blast-radius block.

    Returns:
        dict[str, object]: The four collection fields, the confidence source,
        and ``computed_at``, in the shape F3 invariant 9 requires.
    """

    return {
        "paths": ["scripts/dev_tools/**"],
        "modules": ["scripts"],
        "shared_surfaces": [],
        "contracts": [],
        "source": "declared",
        "computed_at": "2026-08-08T09-00",
    }


def build_state(**overrides: object) -> dict[str, object]:
    """Return a valid parallel checkpoint with the supplied overrides applied.

    Two items sit in one current-generation cohort and the mutation log is
    empty, so a test can replace exactly one field and attribute any resulting
    error to that replacement.

    Args:
        **overrides (object): Top-level checkpoint keys to replace.

    Returns:
        dict[str, object]: The checkpoint payload as a fresh dict.
    """

    state: dict[str, object] = {
        "objective": "deliver parallel-mutation-protocol-442",
        "completed_steps": ["manifest_parsed"],
        "next_step": "cohort_0_launch",
        "last_updated": "2026-08-08T09-00",
        "route_id": "parallel",
        "parallel_slug": "wave-four",
        "parallel_manifest_path": "docs/features/parallel/wave-four/parallel.md",
        "parallel_status_doc_path": (
            "docs/features/parallel/wave-four/parallel-status.md"
        ),
        "mode": "closed",
        "max_concurrency": 4,
        "current_cohort": 0,
        "recolor_generation": 1,
        "cohorts": [{"index": 0, "generation": 1, "item_keys": [444, 445]}],
        "items": [
            {
                "issue_num": 444,
                "feature_folder": "2026-08-07-parallel-mutation-protocol-442",
                "state": "in_flight",
                "blast_radius": build_blast_radius(),
            },
            {
                "issue_num": 445,
                "feature_folder": "2026-08-07-parallel-drift-detection-446",
                "state": "scheduled",
                "blast_radius": build_blast_radius(),
            },
        ],
        "conflict_edges": [],
        "mutations": [],
        "drift_events": [],
    }
    state.update(overrides)
    return state


def item_at(state: dict[str, object], index: int) -> dict[str, object]:
    """Return one ``items[]`` entry of a builder-produced checkpoint.

    Args:
        state (dict[str, object]): A checkpoint payload from a builder here.
        index (int): Zero-based position within ``items``.

    Returns:
        dict[str, object]: The mutable item record at that position.
    """

    return cast("list[dict[str, object]]", state["items"])[index]


def build_completed_state(**overrides: object) -> dict[str, object]:
    """Return a checkpoint recording both completion signals.

    Every item is merged with a terminal merge status and no current-generation
    cohort holds a key, so the closed-mode completion gate applies.

    Args:
        **overrides (object): Top-level checkpoint keys to replace, applied
            after the completion shape is built.

    Returns:
        dict[str, object]: The completed checkpoint payload.
    """

    state = build_state(cohorts=[], mutations=[dict(CLOSE_ENTRY)])
    # Both items reach a terminal outcome; the gate's subject is the per-item
    # merge status, so both are set explicitly rather than defaulted.
    for index in (0, 1):
        item_at(state, index)["state"] = "merged"
        item_at(state, index)["merge_status"] = "worktree_removed"
    state.update(overrides)
    return state


def check(state: dict[str, object]) -> list[str]:
    """Run the FR9 helper directly against a checkpoint payload.

    Args:
        state (dict[str, object]): The checkpoint payload.

    Returns:
        list[str]: The helper's error list, using the wired surface's own
        literal context prefix so assertions read as the user sees them.
    """

    return validate_mutation_protocol(state, CONTEXT)


def validate_wired(state: dict[str, object]) -> list[str]:
    """Run the full F3 validator, exercising F6's single additive call line.

    Args:
        state (dict[str, object]): The checkpoint payload.

    Returns:
        list[str]: Every error the wired validator reports.
    """

    return validate_parallel_orchestrator_state_text(json.dumps(state))


def test_valid_checkpoint_yields_no_helper_errors() -> None:
    """A checkpoint whose mutation log is well formed produces no error."""

    state = build_state(mutations=[dict(ADD_ENTRY), dict(REQUEUE_ENTRY)])

    assert check(state) == []


def test_wired_validator_accepts_the_valid_checkpoint() -> None:
    """The additive call line adds no error to an otherwise valid checkpoint."""

    state = build_state(mutations=[dict(ADD_ENTRY), dict(REQUEUE_ENTRY)])

    assert validate_wired(state) == []


@pytest.mark.parametrize("field", MUTATION_ENTRY_FIELDS)
def test_invariant_1_reports_each_missing_field(field: str) -> None:
    """Omitting any of the seven fields produces exactly one shape error."""

    entry = dict(REQUEUE_ENTRY)
    del entry[field]

    assert check(build_state(mutations=[entry])) == [
        f"{CONTEXT} mutations[0] is missing required field: {field}."
    ]


def test_invariant_1_reports_an_unexpected_field() -> None:
    """An eighth field would widen the F3-owned entry shape and is rejected."""

    entry = dict(REQUEUE_ENTRY)
    entry["reason"] = "drift"

    errors = check(build_state(mutations=[entry]))

    assert len(errors) == 1
    assert errors[0].startswith(
        f"{CONTEXT} mutations[0] carries unexpected field: reason;"
    )


def test_invariant_1_names_the_entry_by_position() -> None:
    """A shape error names the offending entry's index, not its item key."""

    entry = dict(REQUEUE_ENTRY)
    del entry["at"]

    assert check(build_state(mutations=[dict(ADD_ENTRY), entry])) == [
        f"{CONTEXT} mutations[1] is missing required field: at."
    ]


@pytest.mark.parametrize(
    ("op", "field"),
    [
        ("add", "new_state"),
        ("remove", "prior_state"),
        ("remove", "new_state"),
        ("requeue", "prior_state"),
        ("requeue", "new_state"),
    ],
)
def test_invariant_1_rejects_a_null_where_a_value_is_required(
    op: str, field: str
) -> None:
    """A field F3's null rule leaves non-null must actually carry a value."""

    entry = dict(REQUEUE_ENTRY)
    entry["op"] = op
    entry["prior_state"] = "in_flight"
    entry["new_state"] = "withdrawn" if op == "remove" else "blocked"
    entry["disposition"] = "detach" if op == "remove" else None
    entry[field] = None

    assert f"{CONTEXT} mutations[0] {field} must not be null for op {op!r}." in check(
        build_state(mutations=[entry])
    )


def test_invariant_1_accepts_the_nulls_f3_requires() -> None:
    """The null side of the rule stays F3's; add and close report nothing."""

    state = build_state(mutations=[dict(ADD_ENTRY), dict(CLOSE_ENTRY)])

    assert check(state) == []


def test_invariant_1_ignores_an_out_of_enum_op() -> None:
    """A non-existent op has no null rule, so only F3 reports the enum error."""

    entry = dict(REQUEUE_ENTRY)
    entry["op"] = "rename"
    entry["prior_state"] = None

    assert check(build_state(mutations=[entry])) == []


def test_invariant_1_skips_a_non_object_entry() -> None:
    """A non-object entry is F3's error; the helper adds nothing for it."""

    assert check(build_state(mutations=["close"])) == []


def test_invariant_2_rejects_a_decreasing_generation() -> None:
    """A later entry stamped with an earlier generation is a lost update."""

    first = dict(REQUEUE_ENTRY)
    first["recolor_generation"] = 2
    second = dict(REQUEUE_ENTRY)
    second["recolor_generation"] = 1

    assert check(build_state(recolor_generation=2, mutations=[first, second])) == [
        f"{CONTEXT} mutations[1] recolor_generation 1 is below the preceding "
        f"maximum 2; the mutation log must be monotonically non-decreasing."
    ]


def test_invariant_2_accepts_a_repeated_generation() -> None:
    """Non-recompute operations stamp the current generation unchanged."""

    first = dict(REQUEUE_ENTRY)
    second = dict(REQUEUE_ENTRY)

    assert check(build_state(mutations=[first, second])) == []


def test_invariant_2_reports_every_out_of_order_entry() -> None:
    """Each regression is reported, so one defect does not mask a later one."""

    entries: list[dict[str, object]] = []
    # Build the sequence 2, 1, 1: both trailing entries sit below the running
    # maximum, so both must be reported rather than only the first.
    for generation in (2, 1, 1):
        entry = dict(REQUEUE_ENTRY)
        entry["recolor_generation"] = generation
        entries.append(entry)

    errors = check(build_state(recolor_generation=2, mutations=entries))

    assert len(errors) == 2
    assert "mutations[1] recolor_generation 1" in errors[0]
    assert "mutations[2] recolor_generation 1" in errors[1]


def test_invariant_2_skips_a_malformed_generation() -> None:
    """A non-integer generation is F3's error and is not compared here."""

    entry = dict(REQUEUE_ENTRY)
    entry["recolor_generation"] = "one"

    assert check(build_state(mutations=[dict(REQUEUE_ENTRY), entry])) == []


def test_backward_compatibility_absent_mutations_key() -> None:
    """A checkpoint without the mutations key produces no new error."""

    state = build_state()
    del state["mutations"]

    assert check(state) == []


def test_backward_compatibility_non_list_mutations() -> None:
    """A non-list mutations value is F3's error and adds nothing here."""

    assert check(build_state(mutations={})) == []


def test_helper_does_not_mutate_its_input() -> None:
    """Validation leaves the caller's checkpoint payload untouched."""

    state = build_completed_state()
    snapshot = copy.deepcopy(state)

    check(state)

    assert state == snapshot


def test_wired_validator_reports_the_helper_error() -> None:
    """The single additive call line surfaces an FR9 error to the caller."""

    first = dict(REQUEUE_ENTRY)
    first["recolor_generation"] = 2
    second = dict(REQUEUE_ENTRY)
    second["recolor_generation"] = 1
    state = build_state(recolor_generation=2, mutations=[first, second])

    assert any(
        "recolor_generation 1 is below the preceding maximum 2" in error
        for error in validate_wired(state)
    )
