"""In-range concurrency-bound tests for the parallel-planner checkpoint (P2).

This module exists as a sibling of
``tests/scripts/dev_tools/test_validate_parallel_planner_state.py`` for a purely
mechanical reason: that parent module stands at 499 of the repository's 500-line
ceiling and has no recoverable headroom. Its three multi-line ``parametrize``
blocks and three multi-line strings cannot be condensed under Black's 88-column
limit without deleting content, so a new accept test cannot land there. The same
rationale governs ``test_parallel_manifest_contract_m8.py``.

Scope is deliberately narrow: planner invariant P2 delegates the concurrency
bound to orchestrator invariant 4, and the parent module carries only the
REJECT parametrization plus a builder fixture. The ACCEPT direction of the
bound had no test at all before this module, so a widened ceiling could not have
been detected by the planner suite. The cases below pin the lower bound, an
interior value, and the upper bound.

Checkpoints are built as dictionaries and serialized with ``json.dumps``; no
temporary file is created and no external process is started.
"""

from __future__ import annotations

import pytest

from tests.scripts.dev_tools.test_validate_parallel_planner_state import (
    build_valid_planner_state,
    validate,
)


@pytest.mark.parametrize("concurrency", [1, 4, 32])
def test_invariant_p2_accepts_in_range_concurrency(concurrency: int) -> None:
    """Concurrency at both bounds and in the middle validates cleanly.

    Scenario: a valid planner checkpoint carries a ``max_concurrency`` inside
    the 1..32 bound. Expected outcome: the validator reports no error at all,
    so the bound admits the value and nothing else in the payload regressed.
    """

    # Arrange
    state = build_valid_planner_state()
    state["max_concurrency"] = concurrency

    # Act / Assert
    assert validate(state) == []


@pytest.mark.parametrize("concurrency", [1, 4, 32])
def test_invariant_p2_accepts_in_range_concurrency_under_the_ready_gate(
    concurrency: int,
) -> None:
    """The in-range bound is unchanged when the readiness gate is enabled.

    Scenario: the same in-range values validated with
    ``require_ready_for_execution=True``. Expected outcome: no error, proving
    the ready gate adds no separate concurrency constraint.
    """

    # Arrange
    state = build_valid_planner_state()
    state["max_concurrency"] = concurrency

    # Act / Assert
    assert validate(state, ready=True) == []
