"""Pre-PR-creation readiness invariants for orchestrator-state checkpoints.

Purpose:
    Hold the ``validate_orchestrator_state_pr_creation_readiness`` helper and
    its two constants so the primary validator module
    (`scripts.dev_tools.validate_orchestrator_state`) can stay within the
    repository's 500-line file limit while preserving the existing validator
    contract.

Usage:
    Import ``PR_CREATION_READY_STEP_KEYS``,
    ``PR_CREATION_READY_EMPTY_LIST_KEYS``, and
    ``validate_orchestrator_state_pr_creation_readiness`` from this module. The
    primary validator re-exports all three symbols so existing callers and
    tests continue to resolve them from
    ``scripts.dev_tools.validate_orchestrator_state`` unchanged.

Invariants / Constraints:
    - The readiness check covers only steps 5-8 (`step5_status`-
      `step8_status`), `blocked_reason`, and the two override list fields.
    - The readiness check never calls `validate_completion_pr_gate`,
      `_validate_completion_ci_gate`, `validate_phase_completeness`, or
      `validate_routing_contract` — those remain exclusive to
      `--require-complete`.

Side Effects:
    None.
"""

from __future__ import annotations

from typing import Any

# Declare the module's intended exported surface. Listing
# ``validate_orchestrator_state_pr_creation_readiness`` here marks it as a
# deliberate re-export consumed by ``validate_orchestrator_state``, so static
# analysis does not flag the helper as unused locally or as private-usage when
# imported across the module boundary.
__all__ = [
    "PR_CREATION_READY_STEP_KEYS",
    "PR_CREATION_READY_EMPTY_LIST_KEYS",
    "validate_orchestrator_state_pr_creation_readiness",
]

# Upstream lifecycle steps that must not be pending/blocked before the first
# `gh pr create` of a branch. Deliberately narrower than the full completion
# step set (excludes step9_status/step10_status, which can only be populated
# after PR creation and CI have already run).
PR_CREATION_READY_STEP_KEYS = (
    "step5_status",
    "step6_status",
    "step7_status",
    "step8_status",
)
# Checkpoint list fields that must be empty (or absent) before the first PR
# creation of a branch, mirroring the completion-gate override checks without
# requiring the full routing-contract receipt set those checks also enforce.
PR_CREATION_READY_EMPTY_LIST_KEYS = ("local_execution_overrides", "delegation_bypasses")


def validate_orchestrator_state_pr_creation_readiness(
    state: dict[str, Any],
) -> list[str]:
    """Validate a checkpoint is ready for the first `gh pr create` of a branch.

    Purpose:
        Enforce a pre-PR-creation readiness contract that is deliberately
        narrower than `--require-complete`: it checks that upstream steps 5-8
        are not pending/blocked, `blocked_reason` is clear, and the override
        lists are empty, without requiring `ci_gate`, `pr_gate`, or routing-
        contract delegation receipts, none of which can exist before the first
        `gh pr create` of a branch has already succeeded.

    Args:
        state (dict[str, Any]): Parsed checkpoint state.

    Returns:
        list[str]: One error string per violated readiness condition; an
        empty list when the checkpoint is ready for PR creation.

    Raises:
        None.

    Side Effects:
        None. Does not call `validate_completion_pr_gate`,
        `_validate_completion_ci_gate`, `validate_phase_completeness`, or
        `validate_routing_contract`.
    """

    errors: list[str] = []

    # Reject a checkpoint that recorded an upstream step (promotion, planning,
    # execution, review) as pending or blocked; those steps must have finished
    # before the first PR of a branch is created.
    for key in PR_CREATION_READY_STEP_KEYS:
        value = state.get(key)
        if value in {"pending", "blocked"}:
            errors.append(
                f"Checkpoint PR-creation readiness validation failed: {key} is {value}."
            )

    if state.get("blocked_reason") not in {None, "none"}:
        errors.append(
            "Checkpoint PR-creation readiness validation failed: "
            "blocked_reason is not `none`."
        )

    # Reject a checkpoint carrying recorded local-execution overrides or
    # delegation bypasses; a legitimate pre-PR checkpoint has none.
    for key in PR_CREATION_READY_EMPTY_LIST_KEYS:
        value = state.get(key)
        if value is not None and (not isinstance(value, list) or value):
            errors.append(
                "Checkpoint PR-creation readiness validation failed: "
                f"{key} must be an empty list when present."
            )

    return errors
