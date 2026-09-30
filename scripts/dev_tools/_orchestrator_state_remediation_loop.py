"""Validate the remediation-loop section of an orchestrator-state checkpoint.

Purpose:
    Hold the remediation-loop constants and validators that were extracted from
    `validate_orchestrator_state` so that module stays below the 500-line file
    limit and keeps headroom for later contract changes.

Usage:
    `validate_orchestrator_state` imports `REMEDIATION_LOOP_KEY` and
    `_validate_remediation_loop` from this module and calls the validator with
    the checkpoint's `remediation_loop` value.

Invariants / Constraints:
    The message text, ordering, and logic are identical to the pre-extraction
    implementation. The validators never modify their input.

Side Effects:
    None. Every function is pure and returns a list of error strings.
"""

from __future__ import annotations

from typing import Any, cast

# Declare the module's intended exported surface. Listing ``REMEDIATION_LOOP_KEY``
# and ``_validate_remediation_loop`` here marks them as deliberate re-exports
# consumed by ``validate_orchestrator_state``, so static analysis does not flag
# them as unused locally or as private-usage across the module boundary.
__all__ = [
    "REMEDIATION_LOOP_KEY",
    "_validate_remediation_loop",
]

REMEDIATION_LOOP_KEY = "remediation_loop"
REMEDIATION_CYCLES_KEY = "cycles"
EXECUTION_STATUSES_REQUIRING_CLEAR_PREFLIGHT = {
    "in_progress",
    "complete",
    "failed",
}
PREFLIGHT_CLEARED_STATUS = "clear"


def _validate_remediation_cycle(index: int, cycle: dict[str, Any]) -> list[str]:
    """Validate one remediation cycle without changing checkpoint state."""

    errors: list[str] = []

    plan_path = cycle.get("plan_path")
    if not isinstance(plan_path, str) or not plan_path.strip():
        errors.append(
            f"Checkpoint remediation cycle #{index} plan_path must be a "
            "non-empty string."
        )

    execution_status = cycle.get("execution_status")
    if execution_status in EXECUTION_STATUSES_REQUIRING_CLEAR_PREFLIGHT:
        preflight = cycle.get("preflight")
        preflight_status: object = (
            cast("dict[str, Any]", preflight).get("final_status")
            if isinstance(preflight, dict)
            else None
        )
        if preflight_status != PREFLIGHT_CLEARED_STATUS:
            errors.append(
                f"Checkpoint remediation cycle #{index} execution_status is "
                f"{execution_status} but preflight.final_status is not 'clear'."
            )

    if cycle.get("exit_condition_met") is True and cycle.get("blocking_count") != 0:
        errors.append(
            f"Checkpoint remediation cycle #{index} exit_condition_met is true "
            "but blocking_count is not 0."
        )

    return errors


def _validate_remediation_loop(remediation_loop: object) -> list[str]:
    errors: list[str] = []

    # A non-object remediation_loop carries no cycles to validate; treat it as
    # nothing to enforce rather than fabricating a structural error here.
    if not isinstance(remediation_loop, dict):
        return errors
    loop_map = cast("dict[str, Any]", remediation_loop)

    cycles = loop_map.get(REMEDIATION_CYCLES_KEY)
    if not isinstance(cycles, list):
        return errors
    cycle_list = cast("list[object]", cycles)

    # Validate each cycle independently so callers receive a complete error
    # list instead of stopping at the first malformed cycle.
    for index, cycle in enumerate(cycle_list):
        if not isinstance(cycle, dict):
            errors.append(f"Checkpoint remediation cycle #{index} must be an object.")
            continue
        errors.extend(_validate_remediation_cycle(index, cast("dict[str, Any]", cycle)))

    return errors
