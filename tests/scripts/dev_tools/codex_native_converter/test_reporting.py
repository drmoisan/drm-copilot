"""Tests for Codex-native converter report rendering."""

from __future__ import annotations

from pathlib import Path
from typing import Any, cast

from scripts.dev_tools.codex_native_converter import reporting
from scripts.dev_tools.codex_native_converter.models import (
    ConversionClass,
    MappingRecord,
    RunOptions,
    SectionIntentKind,
    SourceEcosystem,
    SourceKind,
    TargetRole,
    TopologyEdge,
    TranslationTrace,
)

REPORTING_HELPERS = cast("Any", reporting)


def test_render_conversion_report_includes_three_mermaid_topology_charts() -> None:
    """Render three Mermaid topology charts before the mapping table."""

    report_text = REPORTING_HELPERS._render_conversion_report(
        RunOptions(
            mode="review",
            source_root=Path("fixtures/source"),
            source_ecosystem=SourceEcosystem.GITHUB_COPILOT,
            selected_paths=(),
            destination_root=None,
            artifact_root=Path("fixtures/artifacts"),
        ),
        (
            MappingRecord(
                source_path=".github/copilot-instructions.md",
                source_ecosystem=SourceEcosystem.GITHUB_COPILOT,
                source_kind=SourceKind.STANDING_INSTRUCTION,
                conversion_class=ConversionClass.DIRECT,
                target_role=TargetRole.STANDING_GUIDANCE,
                target_path="AGENTS.md",
            ),
            MappingRecord(
                source_path=".github/agents/5.1-Beast-adjusted.agent.md",
                source_ecosystem=SourceEcosystem.GITHUB_COPILOT,
                source_kind=SourceKind.AGENT_MANIFEST,
                conversion_class=ConversionClass.DECOMPOSED,
                target_role=TargetRole.SUBAGENT,
                target_path=".codex/agents/5.1-Beast-adjusted.toml",
            ),
            MappingRecord(
                source_path=".github/instructions/python-code-change.instructions.md",
                source_ecosystem=SourceEcosystem.GITHUB_COPILOT,
                source_kind=SourceKind.PATH_SCOPED_INSTRUCTION,
                conversion_class=ConversionClass.DECOMPOSED,
                target_role=TargetRole.SHARED_SKILL,
                target_path=".agents/skills/python-code-change/SKILL.md",
            ),
        ),
        (
            TopologyEdge(
                source_path=".github/copilot-instructions.md",
                destination_path="AGENTS.md",
            ),
            TopologyEdge(
                source_path=".github/agents/5.1-Beast-adjusted.agent.md",
                destination_path=".codex/agents/5.1-Beast-adjusted.toml",
            ),
            TopologyEdge(
                source_path=".github/agents/5.1-Beast-adjusted.agent.md",
                destination_path="AGENTS.md",
            ),
            TopologyEdge(
                source_path=".github/agents/5.1-Beast-adjusted.agent.md",
                destination_path=".agents/skills/python-code-change/SKILL.md",
            ),
            TopologyEdge(
                source_path=".github/instructions/python-code-change.instructions.md",
                destination_path=".agents/skills/python-code-change/SKILL.md",
            ),
        ),
        (
            TranslationTrace(
                source_path=".github/agents/5.1-Beast-adjusted.agent.md",
                section_id=".github/agents/5.1-Beast-adjusted.agent.md#workflow",
                heading="Workflow",
                intent_kind=SectionIntentKind.SHARED_WORKFLOW,
                target_role=TargetRole.SHARED_SKILL,
                target_path=".agents/skills/python-code-change/SKILL.md",
            ),
        ),
        (),
    )

    assert "## Mapping Topology" in report_text
    assert "### Shared Destination Nodes" in report_text
    assert "### Repeated Destination Nodes" in report_text
    assert "### Repeated Source Nodes" in report_text
    assert "## Section Mappings" in report_text
    assert report_text.count("```mermaid") == 3
    assert ".github/agents/5.1-Beast-adjusted.agent.md" in report_text
    assert ".codex/agents/5.1-Beast-adjusted.toml" in report_text
