"""Validate the exact terminal checkpoint contract for epic preparation."""

from __future__ import annotations

from typing import Any

EXPECTED_NEXT_STEP = "S5_atomic_execution"
OUT_OF_SCOPE_STEP_KEYS = (
    "step5_status",
    "step6_status",
    "step7_status",
    "step8_status",
    "step9_status",
    "step10_status",
)


def validate_preparation_terminal_contract(state: dict[str, Any]) -> list[str]:
    """Require planning-only terminal values when route_id is preparation."""

    if state.get("route_id", state.get("path_selected")) != "preparation":
        return []

    errors: list[str] = []
    if state.get("next_step") != EXPECTED_NEXT_STEP:
        errors.append(
            "Preparation checkpoint next_step must be "
            f"{EXPECTED_NEXT_STEP!r}, found {state.get('next_step')!r}."
        )
    for key in OUT_OF_SCOPE_STEP_KEYS:
        if state.get(key) != "not-applicable":
            errors.append(
                f"Preparation checkpoint {key} must be 'not-applicable', "
                f"found {state.get(key)!r}."
            )
    return errors
