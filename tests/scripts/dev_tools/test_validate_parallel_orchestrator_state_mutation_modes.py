"""Tests for the FR9 mode-dependent completion invariant (spec FR7).

Covers the ``open``-mode termination rule and the ``closed``-mode completion
predicate enforced by
``scripts/dev_tools/_parallel_orchestrator_state_mode_completion.py``, reached
through the entry point ``validate_mutation_protocol``. Invariants 1 and 2 (entry
shape and generation monotonicity), the backward-compatibility gates, and the
no-mutation-of-input guarantee live in
``test_validate_parallel_orchestrator_state_mutations.py``, whose builders and
accessors this file reuses. The two files are partitioned only to stay under the
repository's 500-line limit.

Every fixture is a literal dict with ``int`` item keys. Nothing here touches the
filesystem, so no temporary file is created.
"""

from __future__ import annotations

import pytest

from scripts.dev_tools.validate_parallel_orchestrator_state import CONTEXT
from tests.scripts.dev_tools import (
    test_validate_parallel_orchestrator_state_mutations as base,
)


def test_invariant_3_open_mode_rejects_a_mutation_after_the_close() -> None:
    """An open run terminates at the close record and must not continue."""

    trailing = dict(base.ADD_ENTRY)
    trailing["recolor_generation"] = 1
    state = base.build_state(mode="open", mutations=[dict(base.CLOSE_ENTRY), trailing])

    assert base.check(state) == [
        f"{CONTEXT} mutations[1] records op 'add' after the run-close entry at "
        f"mutations[0]; an open-mode run terminates at the close record and "
        f"must not auto-complete.",
        f"{CONTEXT} mutations[0] close requires no item in flight; "
        "still in flight: [444].",
    ]


def test_invariant_3_open_mode_rejects_close_while_work_remains() -> None:
    """A terminal close still rejects a checkpoint with in-flight work."""

    state = base.build_state(
        mode="open", mutations=[dict(base.ADD_ENTRY), dict(base.CLOSE_ENTRY)]
    )

    assert base.check(state) == [
        f"{CONTEXT} mutations[1] close requires no item in flight; "
        "still in flight: [444]."
    ]


def test_invariant_3_open_mode_ignores_an_idle_run_without_a_close() -> None:
    """An open run whose items all merged is idle, not auto-completed."""

    state = base.build_completed_state(mode="open", mutations=[])

    assert base.check(state) == []


def test_invariant_3_closed_mode_rejects_completion_without_the_predicate() -> None:
    """A completed closed run whose item never merged fails the predicate."""

    state = base.build_completed_state()
    first = base.item_at(state, 0)
    first["merge_status"] = "pr_open"

    assert base.check(state) == [
        f"{CONTEXT} items[0] completion invariant failed: closed mode records "
        f"a mutations[] op 'close' entry but merge_status is not merged or "
        f"worktree_removed; found: 'pr_open'."
    ]


def test_invariant_3_closed_mode_accepts_a_satisfied_predicate() -> None:
    """Every non-withdrawn item terminal satisfies the completion gate."""

    assert base.check(base.build_completed_state()) == []


def test_invariant_3_closed_mode_exempts_a_withdrawn_item() -> None:
    """A withdrawn item left the run and never reaches a merge outcome."""

    state = base.build_completed_state()
    first = base.item_at(state, 0)
    first["state"] = "withdrawn"
    del first["merge_status"]

    assert base.check(state) == []


def test_invariant_3_closed_mode_rejects_a_close_while_work_remains() -> None:
    """A close with schedulable work is rejected atomically."""

    state = base.build_state(mutations=[dict(base.CLOSE_ENTRY)])

    assert base.check(state) == [
        f"{CONTEXT} mutations[0] close requires no item in flight; "
        "still in flight: [444]."
    ]


def test_invariant_3_ignores_a_checkpoint_recording_no_close() -> None:
    """Without the run-close record neither mode has recorded completion."""

    state = base.build_completed_state(mutations=[dict(base.REQUEUE_ENTRY)])
    first = base.item_at(state, 0)
    first["merge_status"] = "pr_open"

    assert base.check(state) == []


@pytest.mark.parametrize("mode", ["fast", None])
def test_invariant_3_ignores_a_malformed_mode(mode: object) -> None:
    """An out-of-enum mode is F3's error and disables the mode-dependent gate."""

    state = base.build_completed_state(mode=mode)
    first = base.item_at(state, 0)
    first["merge_status"] = "pr_open"

    assert base.check(state) == []


def test_invariant_3_ignores_non_list_items() -> None:
    """A malformed items collection disables the mode-dependent gate."""

    state = base.build_completed_state(items={})

    assert base.check(state) == []


def test_invariant_3_ignores_a_malformed_cohorts_collection() -> None:
    """A non-list cohorts value cannot prove work is finished."""

    state = base.build_completed_state(cohorts={})
    first = base.item_at(state, 0)
    first["merge_status"] = "pr_open"

    assert base.check(state) == []


def test_invariant_3_ignores_a_non_object_cohort_entry() -> None:
    """A non-object cohort entry is skipped without proving work remains."""

    state = base.build_completed_state(cohorts=["cohort-0"])
    first = base.item_at(state, 0)
    first["merge_status"] = "pr_open"

    assert any("completion invariant failed" in error for error in base.check(state))


def test_invariant_3_treats_a_superseded_cohort_as_no_work() -> None:
    """Only current-generation cohorts carry schedulable work."""

    state = base.build_completed_state(
        cohorts=[{"index": 0, "generation": 0, "item_keys": [444]}]
    )
    first = base.item_at(state, 0)
    first["merge_status"] = "pr_open"

    assert any("completion invariant failed" in error for error in base.check(state))


def test_invariant_3_treats_an_empty_cohort_as_no_work() -> None:
    """A current-generation cohort holding no key schedules nothing."""

    empty_cohort: dict[str, object] = {"index": 0, "generation": 1, "item_keys": []}
    state = base.build_completed_state(cohorts=[empty_cohort])
    first = base.item_at(state, 0)
    first["merge_status"] = "pr_open"

    assert any("completion invariant failed" in error for error in base.check(state))


def test_invariant_3_skips_a_non_object_item() -> None:
    """A non-object item is F3's error; the gate reads no field from it."""

    state = base.build_completed_state(items=["item-444"])

    assert base.check(state) == []
