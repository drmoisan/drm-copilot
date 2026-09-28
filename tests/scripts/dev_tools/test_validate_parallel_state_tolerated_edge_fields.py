"""Validator tolerance for the scheduling layer's extra fields (issue #722).

The integration-cost scheduling layer records three tolerated-not-validated
fields on each conflict edge (``hard``, ``cost``, ``benefit``) and a
``tolerated_overlaps`` list on the planner and orchestrator checkpoints. No
validator reads them, so a checkpoint carrying them must validate with zero
errors, while the four-member edge reason enum stays enforced. The valid
checkpoint builders are shared with the existing validator test modules rather
than duplicated; orchestrator edges use the split-cohort builder, because an
edge between two items of one cohort is a cohort-barrier violation.
"""

from __future__ import annotations

from tests.scripts.dev_tools import (
    test_validate_parallel_orchestrator_state_structures as orchestrator_structures,
)
from tests.scripts.dev_tools.test_validate_parallel_orchestrator_state import (
    build_valid_parallel_state,
)
from tests.scripts.dev_tools.test_validate_parallel_orchestrator_state import (
    validate as validate_orchestrator,
)
from tests.scripts.dev_tools.test_validate_parallel_planner_state import (
    build_valid_planner_state,
)
from tests.scripts.dev_tools.test_validate_parallel_planner_state import (
    validate as validate_planner,
)

# An edge in the shape the scheduling layer records: the unchanged a, b, and
# reason, plus the three tolerated extra fields.
SCHEDULED_EDGE: dict[str, object] = {
    "a": 444,
    "b": 445,
    "reason": "path_overlap",
    "hard": False,
    "cost": 8,
    "benefit": 2,
}

# A tolerated overlap in the shape the scheduling layer records.
TOLERATED_OVERLAP: dict[str, object] = {
    "a": 444,
    "b": 445,
    "reasons": ["path_overlap", "module_overlap"],
    "cost": 1,
    "benefit": 2,
}


def test_orchestrator_state_accepts_tolerated_edge_fields() -> None:
    """An orchestrator edge carrying hard, cost, and benefit yields no errors."""
    state = orchestrator_structures.state_with_edges([dict(SCHEDULED_EDGE)])

    assert validate_orchestrator(state) == []


def test_planner_state_accepts_tolerated_edge_fields() -> None:
    """A planner edge carrying hard, cost, and benefit yields no errors."""
    state = build_valid_planner_state()
    state["conflict_edges"] = [dict(SCHEDULED_EDGE, hard=True)]

    assert validate_planner(state) == []
    assert validate_planner(state, ready=True) == []


def test_orchestrator_state_accepts_tolerated_overlaps_list() -> None:
    """An orchestrator checkpoint carrying tolerated_overlaps yields no errors."""
    state = build_valid_parallel_state()
    state["tolerated_overlaps"] = [dict(TOLERATED_OVERLAP)]

    assert validate_orchestrator(state) == []


def test_planner_state_accepts_tolerated_overlaps_list() -> None:
    """A planner checkpoint carrying tolerated_overlaps yields no errors."""
    state = build_valid_planner_state()
    state["tolerated_overlaps"] = [dict(TOLERATED_OVERLAP)]

    assert validate_planner(state) == []
    assert validate_planner(state, ready=True) == []


def test_out_of_enum_reason_is_still_rejected() -> None:
    """Extra fields do not relax the four-member reason enum."""
    state = orchestrator_structures.state_with_edges(
        [dict(SCHEDULED_EDGE, reason="same_file")]
    )
    state["tolerated_overlaps"] = [dict(TOLERATED_OVERLAP)]

    errors = validate_orchestrator(state)

    expected = (
        "Parallel checkpoint conflict_edges[0] reason must be one of "
        "path_overlap, module_overlap, shared_surface_overlap, "
        "contract_dependency; found: 'same_file'."
    )
    assert errors == [expected]
