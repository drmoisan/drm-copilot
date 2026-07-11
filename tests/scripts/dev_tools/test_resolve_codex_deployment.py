"""Tests for deterministic Codex deployment-profile resolution."""

from __future__ import annotations

import pytest

from scripts.dev_tools.resolve_codex_deployment import (
    ModelUnavailableError,
    main,
    resolve_codex_deployment,
)


@pytest.mark.parametrize(
    ("band", "expected_agent", "expected_model", "expected_reasoning"),
    [
        ("C1", "atomic-executor-c1", "gpt-5.6-luna", "low"),
        ("C2", "atomic-executor-c2", "gpt-5.6-terra", "medium"),
        ("C3", "atomic-executor-c3", "gpt-5.6-terra", "high"),
        ("C4", "atomic-executor-c4", "gpt-5.6-sol", "max"),
    ],
)
def test_resolves_standalone_base_profiles(
    band: str,
    expected_agent: str,
    expected_model: str,
    expected_reasoning: str,
) -> None:
    """Map standalone work to the exact base model and reasoning profile."""

    receipt = resolve_codex_deployment("atomic-executor", band, "standalone", band)

    assert receipt["deployment_agent"] == expected_agent
    assert receipt["model"] == expected_model
    assert receipt["model_reasoning_effort"] == expected_reasoning
    assert receipt["c3_overlay_applied"] is False
    assert receipt["c3_overlay_reason"] is None


@pytest.mark.parametrize("context", ["epic_preparation_child", "epic_execution_child"])
def test_elevates_c3_for_epic_children(context: str) -> None:
    """Route C3 epic children to the Sol/high elevated agent profile."""

    receipt = resolve_codex_deployment("orchestrator", "C3", context, "C3")

    assert receipt["deployment_agent"] == "orchestrator-c3-elevated"
    assert receipt["model"] == "gpt-5.6-sol"
    assert receipt["model_reasoning_effort"] == "high"
    assert receipt["c3_overlay_applied"] is True
    assert receipt["c3_overlay_reason"] == "epic_context"


def test_elevates_standalone_c3_when_orchestration_ceiling_is_c4() -> None:
    """Route standalone C3 to Sol/high when sibling scope establishes C4."""

    receipt = resolve_codex_deployment("task-researcher", "C3", "standalone", "C4")

    assert receipt["deployment_agent"] == "task-researcher-c3-elevated"
    assert receipt["c3_overlay_reason"] == "c4_orchestration_ceiling"


def test_records_combined_c3_overlay_reason() -> None:
    """Record both deterministic triggers when epic context also has C4 scope."""

    receipt = resolve_codex_deployment(
        "prd-feature", "C3", "epic_execution_child", "C4"
    )

    assert receipt["c3_overlay_reason"] == "epic_context_and_c4_ceiling"


@pytest.mark.parametrize("persona", ["epic-planner", "epic-orchestrator"])
def test_forces_epic_personas_to_sol_ultra(persona: str) -> None:
    """Keep both epic master personas on the forced highest deployment."""

    receipt = resolve_codex_deployment(persona, "C1", "standalone", "C1")

    assert receipt["deployment_agent"] == persona
    assert receipt["model"] == "gpt-5.6-sol"
    assert receipt["model_reasoning_effort"] == "ultra"
    assert receipt["c3_overlay_applied"] is False


def test_does_not_overlay_non_c3_epic_work() -> None:
    """Keep C2 epic-child work on its C2 profile because overlays are C3-only."""

    receipt = resolve_codex_deployment(
        "atomic-planner", "C2", "epic_preparation_child", "C4"
    )

    assert receipt["deployment_agent"] == "atomic-planner-c2"
    assert receipt["model"] == "gpt-5.6-terra"
    assert receipt["model_reasoning_effort"] == "medium"
    assert receipt["c3_overlay_applied"] is False


def test_maps_route_feature_review_name_to_codex_reviewer_family() -> None:
    """Preserve the route receipt name while selecting the native reviewer."""

    receipt = resolve_codex_deployment("feature-review", "C2", "standalone", "C2")

    assert receipt["logical_agent"] == "feature-review"
    assert receipt["deployment_agent"] == "feature-reviewer-c2"


@pytest.mark.parametrize(
    ("agent", "band", "context", "ceiling", "message"),
    [
        ("unknown", "C1", "standalone", "C1", "Unsupported Codex logical agent"),
        ("orchestrator", "C5", "standalone", "C4", "complexity_band"),
        ("orchestrator", "C1", "other", "C1", "execution_context"),
        (
            "orchestrator",
            "C4",
            "standalone",
            "C3",
            "orchestration_complexity_ceiling",
        ),
    ],
)
def test_rejects_invalid_routing_inputs(
    agent: str, band: str, context: str, ceiling: str, message: str
) -> None:
    """Fail explicitly for unsupported agents, bands, contexts, or ceilings."""

    with pytest.raises(ValueError, match=message):
        resolve_codex_deployment(agent, band, context, ceiling)


def test_fails_without_model_fallback_when_exact_model_is_unavailable() -> None:
    """Report model_unavailable instead of substituting another deployment."""

    with pytest.raises(ModelUnavailableError, match="model_unavailable"):
        resolve_codex_deployment(
            "atomic-executor",
            "C4",
            "standalone",
            "C4",
            available_models={"gpt-5.6-terra", "gpt-5.6-luna"},
        )


def test_accepts_exact_routed_model_when_available() -> None:
    """Return the routed receipt when the availability set contains the slug."""

    receipt = resolve_codex_deployment(
        "atomic-executor",
        "C4",
        "standalone",
        "C4",
        available_models={"gpt-5.6-sol"},
    )

    assert receipt["model"] == "gpt-5.6-sol"


def test_cli_emits_stable_deployment_receipt(
    capsys: pytest.CaptureFixture[str],
) -> None:
    """Expose the pure resolver through a scriptable JSON command surface."""

    result = main(
        [
            "--logical-agent",
            "orchestrator",
            "--complexity-band",
            "C3",
            "--execution-context",
            "standalone",
            "--orchestration-complexity-ceiling",
            "C3",
        ]
    )

    output = capsys.readouterr().out
    assert result == 0
    assert '"deployment_agent": "orchestrator-c3"' in output
    assert '"model": "gpt-5.6-terra"' in output
