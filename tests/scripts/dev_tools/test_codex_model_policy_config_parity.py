"""Static parity tests for Codex model policy and its Python resolver."""

from __future__ import annotations

import json
from pathlib import Path
from typing import Any, cast

from scripts.dev_tools.resolve_codex_deployment import (
    BASE_PROFILES,
    C3_ELEVATED_CEILING,
    C3_ELEVATED_EXECUTION_CONTEXTS,
    C3_ELEVATED_PROFILE,
    FORCED_PERSONA_PROFILES,
    GENERATED_AGENT_FAMILIES,
    LOGICAL_AGENT_ALIASES,
    VALID_EXECUTION_CONTEXTS,
)

REPO_ROOT = Path(__file__).resolve().parents[3]


def _load_policy() -> dict[str, Any]:
    """Load the canonical Codex model-policy object."""

    document = json.loads(
        (REPO_ROOT / "config" / "orchestration-routing.json").read_text(
            encoding="utf-8"
        )
    )
    return cast("dict[str, Any]", document["codex_model_policy"])


def test_base_profile_table_matches_routing_config() -> None:
    """Keep exact model slugs and reasoning levels aligned with central config."""

    policy = _load_policy()

    assert policy["complexity_to_profile"] == BASE_PROFILES


def test_elevated_and_forced_profiles_match_routing_config() -> None:
    """Keep the C3 overlay and epic master deployments aligned with config."""

    policy = _load_policy()
    configured_elevated = dict(policy["c3_elevated_profile"])
    activation = configured_elevated.pop("activation")

    assert configured_elevated == C3_ELEVATED_PROFILE
    assert activation == {
        "operator": "any",
        "execution_contexts": sorted(C3_ELEVATED_EXECUTION_CONTEXTS),
        "orchestration_complexity_ceiling": C3_ELEVATED_CEILING,
    }
    assert policy["forced_personas"] == FORCED_PERSONA_PROFILES


def test_agent_families_and_contexts_match_routing_config() -> None:
    """Keep deployment inventory and context vocabulary centralized."""

    policy = _load_policy()

    assert set(policy["generated_agent_families"]) == GENERATED_AGENT_FAMILIES
    assert set(policy["execution_contexts"]) == VALID_EXECUTION_CONTEXTS
    assert policy["logical_agent_aliases"] == LOGICAL_AGENT_ALIASES


def test_commit_steward_is_a_canonical_generated_family() -> None:
    """Require commit stewardship in both model-policy family authorities."""

    policy = _load_policy()

    assert "commit-steward" in GENERATED_AGENT_FAMILIES
    assert "commit-steward" in policy["generated_agent_families"]
