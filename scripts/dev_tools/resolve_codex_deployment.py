"""Resolve Codex agent deployment profiles from complexity and context.

The file-count route and the judgment-based complexity band are independent.
This module implements only the Codex deployment axis recorded in
``config/orchestration-routing.json`` under ``codex_model_policy``.
"""

from __future__ import annotations

import argparse
import json
from typing import TYPE_CHECKING, Literal, TypedDict, cast

from scripts.dev_tools.compute_complexity_floor import BAND_ORDER, ComplexityBand

if TYPE_CHECKING:
    from collections.abc import Collection

ExecutionContext = Literal[
    "standalone", "epic_preparation_child", "epic_execution_child"
]
ModelReasoningEffort = Literal["low", "medium", "high", "max", "ultra"]

VALID_EXECUTION_CONTEXTS: frozenset[str] = frozenset(
    {"standalone", "epic_preparation_child", "epic_execution_child"}
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
        "commit-steward",
        "python-typed-engineer",
        "powershell-typed-engineer",
        "csharp-typed-engineer",
        "typescript-engineer",
    }
)
LOGICAL_AGENT_ALIASES: dict[str, str] = {"feature-review": "feature-reviewer"}


class DeploymentProfile(TypedDict):
    """Model, reasoning, and generated-agent suffix for one profile."""

    suffix: str
    model: str
    model_reasoning_effort: ModelReasoningEffort


class CodexDeploymentReceipt(TypedDict):
    """Deterministic receipt persisted before a Codex agent delegation."""

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
}


class ModelUnavailableError(RuntimeError):
    """Report that the exact routed model is unavailable without falling back."""


def _validate_band(value: str, *, field_name: str) -> ComplexityBand:
    """Return a valid complexity band or raise a field-specific error."""

    if value not in BAND_ORDER:
        raise ValueError(f"{field_name} must be one of {BAND_ORDER}, found {value!r}.")
    return value


def _validate_context(value: str) -> ExecutionContext:
    """Return a valid execution context or raise a field-specific error."""

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
    """Return the deterministic C3 elevation reason, if one applies."""

    epic_context = execution_context in C3_ELEVATED_EXECUTION_CONTEXTS
    c4_ceiling = orchestration_complexity_ceiling == C3_ELEVATED_CEILING
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
    """Fail explicitly when an availability set omits the exact routed model."""

    if available_models is not None and model not in available_models:
        raise ModelUnavailableError(
            f"model_unavailable: required Codex model {model!r} is unavailable; "
            "silent fallback is prohibited."
        )


def resolve_codex_deployment(
    logical_agent: str,
    complexity_band: str,
    execution_context: str,
    orchestration_complexity_ceiling: str,
    *,
    available_models: Collection[str] | None = None,
) -> CodexDeploymentReceipt:
    """Resolve the exact Codex agent, model, and reasoning deployment.

    C3 defaults to Terra/high. It elevates to Sol/high only for an epic child
    or when the orchestration ceiling is C4. Epic planner and orchestrator
    personas are always forced to Sol/ultra. No model alias or fallback is
    accepted.
    """

    band = _validate_band(complexity_band, field_name="complexity_band")
    ceiling = _validate_band(
        orchestration_complexity_ceiling,
        field_name="orchestration_complexity_ceiling",
    )
    context = _validate_context(execution_context)
    if BAND_ORDER.index(band) > BAND_ORDER.index(ceiling):
        raise ValueError(
            "orchestration_complexity_ceiling must be greater than or equal to "
            f"complexity_band, found {ceiling} below {band}."
        )

    forced_profile = FORCED_PERSONA_PROFILES.get(logical_agent)
    if forced_profile is not None:
        profile = forced_profile
        deployment_agent = logical_agent
        overlay_reason = None
    else:
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
    """Build the deterministic deployment resolver CLI parser."""

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
    """Resolve one deployment and emit its receipt as stable JSON."""

    args = build_parser().parse_args(argv)
    receipt = resolve_codex_deployment(
        args.logical_agent,
        args.complexity_band,
        args.execution_context,
        args.orchestration_complexity_ceiling,
    )
    print(json.dumps(receipt, indent=2, sort_keys=True))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
