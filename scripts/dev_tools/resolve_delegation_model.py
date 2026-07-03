"""Resolve the delegation model tier for an agent, band, and fable policy.

Purpose:
    Provide the canonical, tested reference implementation of the
    delegation-model selection formula documented in
    `.claude/skills/orchestrate/SKILL.md` (`## Model Selection`) and
    `config/orchestration-routing.json` (`model_policy`). The formula maps a
    ``(agent, complexity_band, fable_policy)`` triple to a model tier by
    applying the base ``complexity_to_model`` table, the agent-scoped
    ``preferred_overlay`` (only under ``fable_policy == "preferred"``), and the
    ``disabled``-mode clamp that removes ``fable`` from the consideration set.

Responsibilities:
    Compute the pre-clamp ``table_model`` (including any preferred overlay) and
    the post-clamp ``model``, reporting the clamp provenance
    (``clamped_from`` / ``clamp_reason``). This module does not read the
    routing config or any other file; it encodes the base table, overlay set,
    overlay band/model, and clamp rule as module constants that mirror the
    ``model_policy`` block.

Usage:
    Callers (for example the orchestrator at delegation time) pass the target
    agent, the assessed ``complexity_band``, and the session
    ``model_budget.fable_policy``. The returned mapping is recorded as a
    ``model_routing_receipts[]`` entry; the model-routing validator
    (`scripts.dev_tools._orchestrator_state_model_routing`) recomputes this
    resolution to check checkpoint receipts.

Invariants / Constraints:
    - ``route`` is never an input to model selection; only ``agent``,
      ``band``, and ``fable_policy`` participate.
    - The preferred overlay changes only the ``C3`` cell to ``fable`` and only
      for the four overlay agents; ``atomic-executor`` and ``pr-author`` C3
      cells stay ``opus`` under every policy.
    - Under ``fable_policy == "disabled"`` a ``fable`` table cell clamps to
      ``opus`` with ``clamped_from == "fable"`` and
      ``clamp_reason == "fable_disabled"``.
    - The function is pure and deterministic: identical inputs yield identical
      output.

Side Effects:
    None.
"""

from __future__ import annotations

from typing import Literal

# The three session-level fable policies (`model_budget.fable_policy`).
FablePolicy = Literal["disabled", "available", "preferred"]
DISABLED_POLICY: FablePolicy = "disabled"
PREFERRED_POLICY: FablePolicy = "preferred"

# The model tier that is removed from consideration under the disabled policy.
FABLE_MODEL = "fable"
# The tier a disabled-mode fable cell clamps down to.
DISABLED_CLAMP_MODEL = "opus"
# The reason string recorded on a disabled-mode clamp.
DISABLED_CLAMP_REASON = "fable_disabled"

# The base complexity-to-model table applied uniformly across delegated agents.
BASE_COMPLEXITY_TO_MODEL: dict[str, str] = {
    "C1": "haiku",
    "C2": "sonnet",
    "C3": "opus",
    "C4": "fable",
}

# The agents whose C3 cell the preferred overlay redirects to ``fable``. No
# other agent and no other band is affected by the overlay.
PREFERRED_OVERLAY_AGENTS: frozenset[str] = frozenset(
    {"atomic-planner", "prd-feature", "feature-review", "task-researcher"}
)
# The single band and target model the preferred overlay applies.
PREFERRED_OVERLAY_BAND = "C3"
PREFERRED_OVERLAY_MODEL = "fable"


def resolve_delegation_model(
    agent: str, band: str, fable_policy: str
) -> dict[str, str | None]:
    """Resolve the delegation model tier for an agent under a fable policy.

    Purpose:
        Apply the ``model_policy`` selection formula to a single delegation:
        compute the pre-clamp ``table_model`` (base table plus any preferred
        overlay) and the post-clamp ``model``, recording clamp provenance.

    Args:
        agent (str): The target delegate agent name (for example
            ``atomic-planner``). Only participates in overlay eligibility.
        band (str): The assessed complexity band, one of ``C1``..``C4``. Used
            as the key into the base ``complexity_to_model`` table.
        fable_policy (str): The session fable policy, one of ``disabled``,
            ``available``, or ``preferred``.

    Returns:
        dict[str, str | None]: A mapping with keys ``table_model`` (the
        pre-clamp table lookup, including any overlay), ``model`` (the
        post-clamp result), ``clamped_from`` (``"fable"`` when a clamp
        occurred, else ``None``), and ``clamp_reason``
        (``"fable_disabled"`` when a clamp occurred, else ``None``).

    Raises:
        KeyError: If ``band`` is not a key in the base
            ``complexity_to_model`` table. Band-enum validity is otherwise the
            complexity validator's responsibility.

    Side Effects:
        None. This function is pure: it reads no file and mutates no input.
    """

    # The preferred overlay redirects only the C3 cell to fable, and only for
    # the overlay agents; every other case reads the base table unchanged.
    if (
        fable_policy == PREFERRED_POLICY
        and agent in PREFERRED_OVERLAY_AGENTS
        and band == PREFERRED_OVERLAY_BAND
    ):
        table_model = PREFERRED_OVERLAY_MODEL
    else:
        table_model = BASE_COMPLEXITY_TO_MODEL[band]

    # Under the disabled policy, fable is removed from consideration: a fable
    # table cell clamps down to opus and records the clamp provenance.
    if fable_policy == DISABLED_POLICY and table_model == FABLE_MODEL:
        return {
            "table_model": table_model,
            "model": DISABLED_CLAMP_MODEL,
            "clamped_from": FABLE_MODEL,
            "clamp_reason": DISABLED_CLAMP_REASON,
        }

    # No clamp applies: the resolved model is the table model verbatim.
    return {
        "table_model": table_model,
        "model": table_model,
        "clamped_from": None,
        "clamp_reason": None,
    }
