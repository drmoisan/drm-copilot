"""Tests for Codex-native converter source inventory behavior."""

from __future__ import annotations

from pathlib import Path

import pytest

from scripts.dev_tools.codex_native_converter.inventory import (
    discover_source_artifacts,
    normalize_selected_paths,
)
from scripts.dev_tools.codex_native_converter.models import SourceEcosystem


def _fixture_root(fixture_name: str) -> Path:
    """Resolve one committed converter fixture root.

    Purpose:
        Provide a stable path to the committed fixture tree used by the test
        suite.

    Args:
        fixture_name (str): Fixture folder name beneath
            ``tests/fixtures/codex_native_converter``.

    Returns:
        Path: Absolute path to the requested committed fixture root.

    Raises:
        None.

    Side Effects:
        None.
    """

    return (
        Path(__file__).resolve().parents[4]
        / "tests"
        / "fixtures"
        / "codex_native_converter"
        / fixture_name
    )


def test_discover_source_artifacts_returns_deterministic_relative_path_order() -> None:
    """Return supported GitHub fixture artifacts in normalized path order."""

    fixture_root = _fixture_root("github_copilot")

    discovered_paths = discover_source_artifacts(
        fixture_root,
        SourceEcosystem.GITHUB_COPILOT,
    )

    assert [path.as_posix() for path in discovered_paths] == [
        ".github/agents/beast-topology.agent.md",
        ".github/agents/orchestrator.agent.md",
        ".github/copilot-instructions.md",
        ".github/instructions/general-code-change.instructions.md",
        ".github/prompts/launch-review.prompt.md",
        ".github/prompts/mixed-runtime.prompt.md",
        ".github/skills/review-workflow/SKILL.md",
    ]


def test_normalize_selected_paths_rejects_paths_outside_source_root() -> None:
    """Reject caller-selected paths that escape the declared source root."""

    fixture_root = _fixture_root("github_copilot")

    with pytest.raises(ValueError, match="escapes the declared source root"):
        normalize_selected_paths(fixture_root, [Path("..") / "outside.md"])


def test_discover_source_artifacts_includes_published_github_hooks_only() -> None:
    """Discover `.github/hooks` resources without admitting unrelated paths."""

    fixture_root = _fixture_root("native_surfaces")

    discovered_paths = discover_source_artifacts(
        fixture_root,
        SourceEcosystem.GITHUB_COPILOT,
    )

    assert [path.as_posix() for path in discovered_paths] == [
        ".github/copilot-instructions.md",
        ".github/hooks/README.md",
        ".github/hooks/discovery-pre-tool.ps1",
        ".github/hooks/discovery.json",
    ]


def test_discover_source_artifacts_includes_claude_helper_library() -> None:
    """Discover `.claude/lib` helper resources for the Claude ecosystem."""

    fixture_root = _fixture_root("native_surfaces")

    discovered_paths = discover_source_artifacts(fixture_root, SourceEcosystem.CLAUDE)

    assert [path.as_posix() for path in discovered_paths] == [
        ".claude/lib/bash/parallel-common.sh",
        ".claude/lib/discovery-validation/DiscoveryValidation.psm1",
        "CLAUDE.md",
    ]
