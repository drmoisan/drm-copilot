"""Orchestrator-state ``blocked_reason`` vocabulary and partition.

Purpose:
    Publish the authoritative ``blocked_reason`` vocabulary for orchestrator-state
    checkpoints as the not-blocked member ``none`` plus two disjoint partitions,
    and classify a recorded value into one of those three classes. The
    TypeScript module ``orchestrator-state-blocked-reason.ts`` and the grouped
    arrays in ``OrchestratorState.psm1`` mirror this module.

Usage:
    ``validate_orchestrator_state`` imports ``VALID_BLOCKED_REASONS`` for its
    plain-validation membership check. Callers that need to tell a mechanical
    stop from a non-mechanical halt call ``classify_blocked_reason``.

Invariants / Constraints:
    - The mechanical partition holds the six validator-enforced members; the
      non-mechanical partition holds the five halt classes added by #523. The
      two partitions are disjoint and neither contains ``none``.
    - Membership is case-sensitive; a non-string value is never tested for set
      membership, so lists and dicts cannot raise ``TypeError``.
    - All constants are immutable ``frozenset`` values.

Side Effects:
    None. The module performs no I/O.
"""

from __future__ import annotations

from typing import Literal

MECHANICAL_BLOCKED_REASONS: frozenset[str] = frozenset(
    {
        "spawn_agent_unavailable",
        "delegation_launch_failed",
        "delegate_no_receipt",
        "delegate_contract_incomplete",
        "validator_failed",
        "user_requested_stop",
    }
)
NON_MECHANICAL_BLOCKED_REASONS: frozenset[str] = frozenset(
    {
        "premise_falsified",
        "external_dependency",
        "policy_hold",
        "awaiting_ci",
        "human_decision_required",
    }
)
VALID_BLOCKED_REASONS: frozenset[str] = (
    frozenset({"none"}) | MECHANICAL_BLOCKED_REASONS | NON_MECHANICAL_BLOCKED_REASONS
)

BlockedReasonClass = Literal["not_blocked", "mechanical", "non_mechanical"]


def classify_blocked_reason(value: object) -> BlockedReasonClass:
    """Classify a recorded ``blocked_reason`` value.

    Args:
        value (object): The checkpoint's ``blocked_reason`` value; JSON ``null``
            arrives as ``None``.

    Returns:
        BlockedReasonClass: ``"not_blocked"`` for ``None`` or ``"none"``,
        ``"mechanical"`` for a mechanical member, and ``"non_mechanical"`` for a
        non-mechanical member.

    Raises:
        ValueError: If the value is not a string member of the vocabulary. The
            message starts with ``invalid blocked_reason: ``.
    """
    if value is None or value == "none":
        return "not_blocked"
    if isinstance(value, str):
        if value in MECHANICAL_BLOCKED_REASONS:
            return "mechanical"
        if value in NON_MECHANICAL_BLOCKED_REASONS:
            return "non_mechanical"
    raise ValueError(f"invalid blocked_reason: {value!r}")
