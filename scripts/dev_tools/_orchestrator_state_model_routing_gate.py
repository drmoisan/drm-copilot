"""Existence gate for model-routing receipts in orchestrator-state checkpoints.

Purpose:
    Host the ``require_model_routing`` existence gate for the primary validator
    module (`scripts.dev_tools.validate_orchestrator_state`) so that module can
    stay within the repository's 500-line file limit. The gate enforces the
    "required once delegated" invariant documented in
    `.claude/rules/orchestrator-state.md`: once a checkpoint records at least one
    delegation, every delegated agent must have a matching
    ``model_routing_receipts[]`` entry, each matched receipt's phase must have a
    ``complexity_assessments[]`` entry, and every present receipt/assessment must
    remain self-consistent with the reference formulas.

Usage:
    Import ``validate_model_routing_gate`` and call it with the parsed checkpoint
    map only when the caller opts into the ``require_model_routing`` mode. The
    gate returns an empty list for any delegation-free checkpoint, preserving
    backward compatibility for old checkpoints that predate model routing.

Invariants / Constraints:
    - The gate fires only when at least one delegating agent can be derived from
      the checkpoint (a well-formed ``delegation_receipts[]`` entry, or a
      ``next_step`` that names a recognized delegating agent). A delegation-free
      checkpoint contributes zero errors.
    - Per-entry correctness reuses ``_validate_model_routing_receipts`` and
      ``_validate_complexity_assessments``; this module never reimplements
      ``compute_complexity_floor`` or ``resolve_delegation_model``.
    - The validator never imports ``schemas/orchestrator-state.schema.json``;
      the invariants are expressed directly here per
      `.claude/rules/orchestrator-state.md`.

Side Effects:
    None. The gate reads only its in-memory argument and never mutates it.
"""

from __future__ import annotations

from typing import Any, cast

from scripts.dev_tools._orchestrator_state_complexity import (
    COMPLEXITY_ASSESSMENTS_KEY,
    _validate_complexity_assessments,
)
from scripts.dev_tools._orchestrator_state_model_routing import (
    MODEL_ROUTING_RECEIPTS_KEY,
    _validate_model_routing_receipts,
)

# Declare the module's intended exported surface. Listing the public entry point
# marks it as a deliberate re-export consumed by ``validate_orchestrator_state``
# so static analysis does not flag it as unused across the module boundary.
__all__ = [
    "MODEL_ROUTING_GATE",
    "validate_model_routing_gate",
]

# A stable label for this gate, used in log/context strings and as a marker that
# callers can reference when reporting which validation surface fired.
MODEL_ROUTING_GATE = "model_routing_gate"

# Checkpoint keys the gate reads to derive the delegated-agent set.
_DELEGATION_RECEIPTS_KEY = "delegation_receipts"
_NEXT_STEP_KEY = "next_step"
_AGENT_NAME_KEY = "agent_name"

# The subagent types that are delegated via the ``Agent`` tool and can therefore
# be named by a delegating ``next_step``. This mirrors the gated set enforced by
# the PreToolUse deterrent hook (`.claude/hooks/enforce-model-routing-receipt.ps1`)
# and is the union of ``required_agents`` across routes in
# ``config/orchestration-routing.json`` restricted to Agent-tool delegates. The
# ``orchestrator`` type is deliberately excluded: it is the calling agent, not a
# subagent delegated via the Agent tool, so it is never a routing-receipt target.
_DELEGATING_AGENTS: frozenset[str] = frozenset(
    {
        "atomic-planner",
        "atomic-executor",
        "feature-review",
        "task-researcher",
        "prd-feature",
        "pr-author",
    }
)


def _delegated_agents(state_map: dict[str, Any]) -> set[str]:
    """Derive the set of agents a checkpoint has delegated (or is about to).

    Purpose:
        Collect the authoritative set of delegating agents the model-routing
        gate must find a receipt for: every well-formed
        ``delegation_receipts[]`` entry's ``agent_name`` plus the agent implied
        by a ``next_step`` that names a recognized delegating agent.

    Args:
        state_map (dict[str, Any]): The parsed checkpoint object.

    Returns:
        set[str]: The delegated-agent names. An empty set means the checkpoint
        is delegation-free, in which case the gate imposes no requirement.

    Raises:
        None.

    Side Effects:
        None.
    """

    agents: set[str] = set()

    receipts = state_map.get(_DELEGATION_RECEIPTS_KEY)
    if isinstance(receipts, dict):
        receipts = cast("dict[str, object]", receipts).get("agents")
    if isinstance(receipts, list):
        receipt_list = cast("list[object]", receipts)
        for receipt in receipt_list:
            if not isinstance(receipt, dict):
                continue
            agent_name = cast("dict[str, Any]", receipt).get(_AGENT_NAME_KEY)
            if isinstance(agent_name, str) and agent_name.strip():
                agents.add(agent_name)

    # A delegating next_step names the upcoming delegation that may not yet have
    # a receipt; include it only when it matches a recognized delegating agent so
    # a non-delegating label (for example "done") never triggers the gate.
    next_step = state_map.get(_NEXT_STEP_KEY)
    if isinstance(next_step, str) and next_step in _DELEGATING_AGENTS:
        agents.add(next_step)

    return agents


def _routing_receipt_agents_and_matched_phases(
    state_map: dict[str, Any], delegated: set[str]
) -> tuple[set[str], set[Any]]:
    """Collect routing-receipt agents and the phases matched to delegations.

    Purpose:
        Read the checkpoint's ``model_routing_receipts[]`` array once and return
        both the set of agents that carry a receipt and the set of phases named
        by receipts whose agent is in the delegated set (the "matched" receipts
        whose phase must have a complexity assessment).

    Args:
        state_map (dict[str, Any]): The parsed checkpoint object.
        delegated (set[str]): The delegated-agent set from ``_delegated_agents``.

    Returns:
        tuple[set[str], set[Any]]: A pair ``(receipt_agents, matched_phases)``.
        ``receipt_agents`` is the set of ``agent`` values present on well-formed
        receipt objects; ``matched_phases`` is the set of ``phase`` values on
        receipts whose ``agent`` is in ``delegated``.

    Raises:
        None.

    Side Effects:
        None.
    """

    receipt_agents: set[str] = set()
    matched_phases: set[Any] = set()

    receipts = state_map.get(MODEL_ROUTING_RECEIPTS_KEY)
    # A non-list value is a malformed block handled by the reused per-entry
    # validator; here we only harvest agents/phases from a well-formed list.
    if not isinstance(receipts, list):
        return receipt_agents, matched_phases
    receipt_list = cast("list[object]", receipts)

    # Walk every receipt to record which agents have a receipt and, for receipts
    # that match a delegated agent, which phase they reference so the paired
    # complexity assessment can be required.
    for receipt in receipt_list:
        if not isinstance(receipt, dict):
            continue
        receipt_map = cast("dict[str, Any]", receipt)
        agent = receipt_map.get("agent")
        if isinstance(agent, str) and agent.strip():
            receipt_agents.add(agent)
            if agent in delegated:
                matched_phases.add(receipt_map.get("phase"))

    return receipt_agents, matched_phases


def _assessed_phases(state_map: dict[str, Any]) -> set[Any]:
    """Collect the phases that carry a complexity-assessment entry.

    Purpose:
        Read the checkpoint's ``complexity_assessments[]`` array and return the
        set of ``phase`` values present on well-formed assessment objects, so
        the gate can require an assessment for each matched routing-receipt
        phase.

    Args:
        state_map (dict[str, Any]): The parsed checkpoint object.

    Returns:
        set[Any]: The set of ``phase`` values found on assessment objects.

    Raises:
        None.

    Side Effects:
        None.
    """

    phases: set[Any] = set()
    assessments = state_map.get(COMPLEXITY_ASSESSMENTS_KEY)
    if not isinstance(assessments, list):
        return phases
    assessment_list = cast("list[object]", assessments)

    # Harvest each well-formed assessment's phase so matched receipt phases can
    # be checked for a paired assessment entry.
    for assessment in assessment_list:
        if isinstance(assessment, dict):
            phases.add(cast("dict[str, Any]", assessment).get("phase"))

    return phases


def validate_model_routing_gate(state_map: dict[str, Any]) -> list[str]:
    """Enforce the "required once delegated" model-routing existence invariant.

    Purpose:
        When a checkpoint records at least one delegation, require that every
        delegated agent has a matching ``model_routing_receipts[]`` entry, that
        each matched receipt's phase has a ``complexity_assessments[]`` entry,
        and that every present receipt and assessment is self-consistent with
        the reference formulas. A delegation-free checkpoint contributes zero
        errors, preserving backward compatibility.

    Args:
        state_map (dict[str, Any]): The parsed checkpoint object.

    Returns:
        list[str]: One checkpoint-context-prefixed error string per violated
        invariant; an empty list when the gate is satisfied or does not fire.

    Raises:
        None.

    Side Effects:
        None. Reuses ``_validate_model_routing_receipts`` and
        ``_validate_complexity_assessments`` for per-entry correctness and never
        reimplements ``compute_complexity_floor`` or ``resolve_delegation_model``.
    """

    errors: list[str] = []

    # Backward-compat gate: fire only when the checkpoint has delegated (or is
    # about to delegate to) at least one agent. A delegation-free checkpoint
    # imposes no routing-receipt requirement.
    delegated = _delegated_agents(state_map)
    if not delegated:
        return errors

    receipt_agents, matched_phases = _routing_receipt_agents_and_matched_phases(
        state_map, delegated
    )

    # Existence invariant (superset): the set of routing-receipt agents must be a
    # superset of the delegated-agent set. Report each delegated agent that has
    # no receipt, sorted for deterministic error ordering.
    for agent in sorted(delegated - receipt_agents):
        errors.append(
            "Checkpoint model_routing_receipts is missing a receipt for "
            f"delegated agent: {agent}."
        )

    # Phase-pairing invariant: every phase named by a matched routing receipt
    # must carry a complexity assessment. Only phases of receipts that matched a
    # delegated agent are required, so an unrelated receipt cannot force an
    # assessment. Sort by string form for deterministic ordering across types.
    assessed = _assessed_phases(state_map)
    for phase in sorted(matched_phases - assessed, key=repr):
        errors.append(
            "Checkpoint complexity_assessments is missing an entry for phase "
            f"{phase} referenced by a model_routing_receipts entry."
        )

    # Per-entry correctness: reuse the existing validators so a present receipt
    # whose model diverges from resolve_delegation_model, or an assessment whose
    # floor diverges from compute_complexity_floor, is caught under the flag.
    # Guard on key presence so an absent key does not emit a spurious
    # "must be a list when present" error (the existence checks above already
    # report the missing receipts/assessments).
    if MODEL_ROUTING_RECEIPTS_KEY in state_map:
        errors.extend(
            _validate_model_routing_receipts(state_map.get(MODEL_ROUTING_RECEIPTS_KEY))
        )
    if COMPLEXITY_ASSESSMENTS_KEY in state_map:
        errors.extend(
            _validate_complexity_assessments(state_map.get(COMPLEXITY_ASSESSMENTS_KEY))
        )

    return errors
