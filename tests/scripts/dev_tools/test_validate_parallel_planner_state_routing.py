"""Tests for parallel-planner ready-gate invariant P10, the routing record.

Under ``require_ready_for_execution`` every planner item must carry a valid
``complexity_band``, a ``complexity_assessment``, and a
``model_routing_receipt`` (issue #532). Checkpoints are built with the shared
builders module and serialized with ``json.dumps``; no temporary file is
created.
"""

from __future__ import annotations

import json
from typing import cast

from scripts.dev_tools.validate_parallel_planner_state import (
    validate_parallel_planner_state_text,
)
from tests.scripts.dev_tools.parallel_planner_state_builders import (
    build_valid_planner_state,
)

BAND_ABSENT = (
    "Parallel planner checkpoint items[0] complexity_band must be one of "
    "C1, C2, C3, C4; found: None."
)
ASSESSMENT_NOT_OBJECT = (
    "Parallel planner checkpoint items[0] complexity_assessment must be an object."
)
RECEIPT_NOT_OBJECT = (
    "Parallel planner checkpoint items[0] model_routing_receipt must be an object."
)


def validate(state: dict[str, object], *, ready: bool) -> list[str]:
    """Serialize a checkpoint dict and return the validator's error list."""

    return validate_parallel_planner_state_text(
        json.dumps(state), require_ready_for_execution=ready
    )


def test_ready_gate_rejects_item_without_band_assessment_or_receipt() -> None:
    """The ready gate reports an item missing all three routing fields."""

    # Arrange
    state = build_valid_planner_state()
    item = cast("list[dict[str, object]]", state["items"])[0]
    del item["complexity_band"]
    del item["complexity_assessment"]
    del item["model_routing_receipt"]

    # Act
    errors = validate(state, ready=True)

    # Assert
    assert BAND_ABSENT in errors, errors
    assert ASSESSMENT_NOT_OBJECT in errors, errors
    assert RECEIPT_NOT_OBJECT in errors, errors
