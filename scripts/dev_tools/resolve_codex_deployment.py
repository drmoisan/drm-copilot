"""Resolve exact Codex deployment profiles from complexity and context.

This module owns only the model/deployment axis of the routing policy; topology
and file-count routing remain separate. It validates bands and context, enforces
forced epic/parallel personas, applies the deterministic C3 overlay, rejects
unavailable exact models, and returns a serializable receipt. Pure helpers do no
I/O or input mutation. ``main`` alone parses arguments and writes JSON stdout.
"""

from __future__ import annotations

import argparse
import json
from typing import TYPE_CHECKING, Literal, TypedDict, cast

from scripts.dev_tools.compute_complexity_floor import BAND_ORDER, ComplexityBand

if TYPE_CHECKING:
    from collections.abc import Collection

ExecutionContext = Literal[
    "standalone",
    "epic_preparation_child",
    "epic_execution_child",
    "parallel_planning",
    "parallel_execution",
]
ModelReasoningEffort = Literal["low", "medium", "high", "max", "ultra"]

VALID_EXECUTION_CONTEXTS: frozenset[str] = frozenset(
    {
        "standalone",
        "epic_preparation_child",
        "epic_execution_child",
        "parallel_planning",
        "parallel_execution",
    }
)
EPIC_EXECUTION_CONTEXTS: frozenset[str] = frozenset(
    {"epic_preparation_child", "epic_execution_child"}
)
C3_ELEVATED_EXECUTION_CONTEXTS: frozenset[str] = EPIC_EXECUTION_CONTEXTS
C3_ELEVATED_CEILING: ComplexityBand = "C4"
GENERATED_AGENT_FAMILIES: frozenset[str] = frozenset(
    {
        "orchestrator",
        "atomic-planner",
        "atomic-executor",
        "feature-reviewer",
        "task-researcher",
        "prd-feature",
        "pr-author",
        "python-typed-engineer",
        "powershell-typed-engineer",
        "csharp-typed-engineer",
        "typescript-engineer",
        "commit-steward",
    }
)
LOGICAL_AGENT_ALIASES: dict[str, str] = {"feature-review": "feature-reviewer"}


class DeploymentProfile(TypedDict):
    """Describe one immutable-by-convention generated deployment profile.

    Resolver constants provide these mappings; callers read them to construct a
    receipt and never mutate them. ``suffix`` names the generated agent variant,
    while ``model`` and ``model_reasoning_effort`` are the exact deployment
    identity. The shape performs no validation or I/O.
    """

    suffix: str
    model: str
    model_reasoning_effort: ModelReasoningEffort


class CodexDeploymentReceipt(TypedDict):
    """Describe the complete deployment decision persisted before delegation.

    ``resolve_codex_deployment`` constructs the mapping after all invariants pass;
    orchestration stores it as provenance. Fields retain requested identities,
    selected agent/model/effort, ceiling, and C3 overlay evidence. The shape has
    no behavior, mutation, or I/O.
    """

    logical_agent: str
    deployment_agent: str
    complexity_band: ComplexityBand
    execution_context: ExecutionContext
    orchestration_complexity_ceiling: ComplexityBand
    c3_overlay_applied: bool
    c3_overlay_reason: str | None
    model: str
    model_reasoning_effort: ModelReasoningEffort


BASE_PROFILES: dict[ComplexityBand, DeploymentProfile] = {
    "C1": {
        "suffix": "c1",
        "model": "gpt-5.6-luna",
        "model_reasoning_effort": "low",
    },
    "C2": {
        "suffix": "c2",
        "model": "gpt-5.6-terra",
        "model_reasoning_effort": "medium",
    },
    "C3": {
        "suffix": "c3",
        "model": "gpt-5.6-terra",
        "model_reasoning_effort": "high",
    },
    "C4": {
        "suffix": "c4",
        "model": "gpt-5.6-sol",
        "model_reasoning_effort": "max",
    },
}
C3_ELEVATED_PROFILE: DeploymentProfile = {
    "suffix": "c3-elevated",
    "model": "gpt-5.6-sol",
    "model_reasoning_effort": "high",
}
FORCED_PERSONA_PROFILES: dict[str, DeploymentProfile] = {
    "epic-planner": {
        "suffix": "",
        "model": "gpt-5.6-sol",
        "model_reasoning_effort": "ultra",
    },
    "epic-orchestrator": {
        "suffix": "",
        "model": "gpt-5.6-sol",
        "model_reasoning_effort": "ultra",
    },
    "parallel-planner": {
        "suffix": "",
        "model": "gpt-5.6-sol",
        "model_reasoning_effort": "ultra",
    },
    "parallel-orchestrator": {
        "suffix": "",
        "model": "gpt-5.6-sol",
        "model_reasoning_effort": "ultra",
    },
}
PARALLEL_ROOT_CONTEXT_PERSONAS: dict[str, str] = {
    "parallel_planning": "parallel-planner",
    "parallel_execution": "parallel-orchestrator",
}


class ModelUnavailableError(RuntimeError):
    """Report unavailable exact-model routing where fallback is prohibited.

    Raised only after deterministic selection when an explicit availability set
    omits the chosen model. Callers may surface or persist it, but must not use it
    to select an alternate model. The class adds no state or side effects beyond
    the inherited exception message.
    """


def _validate_band(value: str, *, field_name: str) -> ComplexityBand:
    """Validate ``value`` for ``field_name`` and return its typed band.

    Raises:
        ValueError: The value is outside C1-C4.
    """

    if value not in BAND_ORDER:
        raise ValueError(f"{field_name} must be one of {BAND_ORDER}, found {value!r}.")
    return value


def _validate_context(value: str) -> ExecutionContext:
    """Validate ``value`` and return its typed execution context.

    Raises:
        ValueError: The value is outside the supported context set.
    """

    if value not in VALID_EXECUTION_CONTEXTS:
        raise ValueError(
            "execution_context must be one of "
            f"{tuple(sorted(VALID_EXECUTION_CONTEXTS))}, found {value!r}."
        )
    return cast("ExecutionContext", value)


def _select_c3_overlay_reason(
    execution_context: ExecutionContext,
    orchestration_complexity_ceiling: ComplexityBand,
) -> str | None:
    """Return the C3 elevation reason for ``execution_context`` and ceiling."""

    epic_context = execution_context in C3_ELEVATED_EXECUTION_CONTEXTS
    c4_ceiling = orchestration_complexity_ceiling == C3_ELEVATED_CEILING
    # Combined evidence is more specific and therefore precedes single triggers.
    if epic_context and c4_ceiling:
        return "epic_context_and_c4_ceiling"
    if epic_context:
        return "epic_context"
    if c4_ceiling:
        return "c4_orchestration_ceiling"
    return None


def _require_available_model(
    model: str, available_models: Collection[str] | None
) -> None:
    """Validate exact ``model`` availability and return None.

    Raises:
        ModelUnavailableError: A supplied availability set omits the model.
    """

    if available_models is not None and model not in available_models:
        raise ModelUnavailableError(
            f"model_unavailable: required Codex model {model!r} is unavailable; "
            "silent fallback is prohibited."
        )


def _parallel_persona_context(logical_agent: str) -> ExecutionContext | None:
    """Return the required parallel context for ``logical_agent``, if any."""

    # Search the two forced identities rather than duplicating reverse constants.
    return next(
        (
            cast("ExecutionContext", candidate)
            for candidate, persona in PARALLEL_ROOT_CONTEXT_PERSONAS.items()
            if persona == logical_agent
        ),
        None,
    )


def resolve_codex_deployment(
    logical_agent: str,
    complexity_band: str,
    execution_context: str,
    orchestration_complexity_ceiling: str,
    *,
    available_models: Collection[str] | None = None,
) -> CodexDeploymentReceipt:
    """Resolve an exact deployment receipt from agent, band, context, and ceiling.

    C3 defaults to Terra/high. It elevates to Sol/high only for an epic child
    or when the orchestration ceiling is C4. Epic planner and orchestrator
    personas and their context-bound parallel counterparts are always forced
    to Sol/ultra. No model alias or fallback is accepted.

    Args:
        logical_agent: Requested logical routing family or forced persona.
        complexity_band: C1-C4 work complexity.
        execution_context: Standalone, epic-child, or parallel-root context.
        orchestration_complexity_ceiling: Monotonic C1-C4 orchestration ceiling.
        available_models: Optional exact-model availability set.

    Returns:
        CodexDeploymentReceipt: Deterministic deployment and model identity.

    Raises:
        ValueError: Any routing identity or invariant is invalid.
        ModelUnavailableError: The selected exact model is unavailable.
    """

    band = _validate_band(complexity_band, field_name="complexity_band")
    ceiling = _validate_band(
        orchestration_complexity_ceiling,
        field_name="orchestration_complexity_ceiling",
    )
    context = _validate_context(execution_context)
    # A child decision cannot exceed its monotonic orchestration ceiling.
    if BAND_ORDER.index(band) > BAND_ORDER.index(ceiling):
        raise ValueError(
            "orchestration_complexity_ceiling must be greater than or equal to "
            f"complexity_band, found {ceiling} below {band}."
        )

    # Parallel root contexts and personas must agree in both directions.
    parallel_persona = PARALLEL_ROOT_CONTEXT_PERSONAS.get(context)
    if parallel_persona is not None and logical_agent != parallel_persona:
        raise ValueError(
            f"Parallel context {context!r} requires its forced root persona "
            f"{parallel_persona!r}."
        )
    parallel_context = _parallel_persona_context(logical_agent)
    if parallel_context is not None and context != parallel_context:
        raise ValueError(
            f"Parallel persona {logical_agent!r} requires "
            f"{parallel_context!r} context."
        )

    # Forced personas bypass generated-family selection and C3 overlays.
    forced_profile = FORCED_PERSONA_PROFILES.get(logical_agent)
    if forced_profile is not None:
        profile = forced_profile
        deployment_agent = logical_agent
        overlay_reason = None
    else:
        # Resolve aliases first, then choose the base or elevated generated profile.
        deployment_family = LOGICAL_AGENT_ALIASES.get(logical_agent, logical_agent)
        if deployment_family not in GENERATED_AGENT_FAMILIES:
            raise ValueError(f"Unsupported Codex logical agent: {logical_agent!r}.")
        overlay_reason = (
            _select_c3_overlay_reason(context, ceiling) if band == "C3" else None
        )
        profile = C3_ELEVATED_PROFILE if overlay_reason else BASE_PROFILES[band]
        deployment_agent = f"{deployment_family}-{profile['suffix']}"

    _require_available_model(profile["model"], available_models)
    return {
        "logical_agent": logical_agent,
        "deployment_agent": deployment_agent,
        "complexity_band": band,
        "execution_context": context,
        "orchestration_complexity_ceiling": ceiling,
        "c3_overlay_applied": overlay_reason is not None,
        "c3_overlay_reason": overlay_reason,
        "model": profile["model"],
        "model_reasoning_effort": profile["model_reasoning_effort"],
    }


def build_parser() -> argparse.ArgumentParser:
    """Build and return the side-effect-free deployment CLI parser."""

    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--logical-agent", required=True)
    parser.add_argument("--complexity-band", choices=BAND_ORDER, required=True)
    parser.add_argument(
        "--execution-context",
        choices=tuple(sorted(VALID_EXECUTION_CONTEXTS)),
        required=True,
    )
    parser.add_argument(
        "--orchestration-complexity-ceiling", choices=BAND_ORDER, required=True
    )
    return parser


def main(argv: list[str] | None = None) -> int:
    """Parse ``argv``, emit one stable JSON receipt, and return zero.

    Side Effects:
        Writes the resolved receipt to stdout.
    """

    args = build_parser().parse_args(argv)
    receipt = resolve_codex_deployment(
        args.logical_agent,
        args.complexity_band,
        args.execution_context,
        args.orchestration_complexity_ceiling,
    )
    # Stable formatting makes the CLI receipt suitable for durable evidence.
    print(json.dumps(receipt, indent=2, sort_keys=True))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
