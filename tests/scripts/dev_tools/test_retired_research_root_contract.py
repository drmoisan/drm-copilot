"""Reject retired research output roots across active customization surfaces."""

from __future__ import annotations

from pathlib import Path

import pytest

from scripts.dev_tools import synchronize_customization_bundles as bundles

PROFILE_SUFFIXES = ("", "-c1", "-c2", "-c3", "-c3-elevated", "-c4")
ORCHESTRATOR_ROOT_PATHS = (
    *(Path(f".codex/agents/orchestrator{suffix}.toml") for suffix in PROFILE_SUFFIXES),
    Path(".agents/skills/orchestrate/SKILL.md"),
    Path(".github/agents/orchestrator.agent.md"),
    Path(".github/prompts/orchestrate-work.prompt.md"),
    Path(".github/prompts/orchestrate-python-work.prompt.md"),
    Path(".github/prompts/orchestrate-powershell-work.prompt.md"),
    Path(".github/prompts/orchestrate-csharp-work.prompt.md"),
    Path(".claude/agents/orchestrator.md"),
    Path(".claude/skills/orchestrate/SKILL.md"),
    Path(".claude/rules/orchestrator-state.md"),
)
RESEARCHER_ROOT_PATHS = (
    *(
        Path(f".codex/agents/task-researcher{suffix}.toml")
        for suffix in PROFILE_SUFFIXES
    ),
    Path(".agents/skills/research-issue/SKILL.md"),
    Path(".github/agents/task-researcher.agent.md"),
    Path(".github/prompts/research-issue.prompt.md"),
    Path(".claude/agents/task-researcher.md"),
    Path(".claude/skills/research-issue/SKILL.md"),
)
ROOT_RESEARCH_PATHS = (*ORCHESTRATOR_ROOT_PATHS, *RESEARCHER_ROOT_PATHS)


def _packaged_path(source: Path) -> Path:
    """Resolve one active source to its exact P5-T8 packaged destination."""

    destinations = {mapping.source: mapping.destination for mapping in bundles.MAPPINGS}
    try:
        return destinations[source]
    except KeyError as error:
        raise AssertionError(
            f"Active research profile is not packaged: {source}"
        ) from error


PACKAGED_RESEARCH_PATHS = tuple(_packaged_path(path) for path in ROOT_RESEARCH_PATHS)
ACTIVE_RESEARCH_PATHS = (*ROOT_RESEARCH_PATHS, *PACKAGED_RESEARCH_PATHS)


def test_research_root_inventory_covers_canonical_generated_and_packaged_profiles() -> (
    None
):
    """Keep all 26 active sources and their 26 packaged mirrors in scope."""

    assert len(ORCHESTRATOR_ROOT_PATHS) == 15
    assert len(RESEARCHER_ROOT_PATHS) == 11
    assert len(ROOT_RESEARCH_PATHS) == 26
    assert len(ACTIVE_RESEARCH_PATHS) == 52
    assert len(set(ACTIVE_RESEARCH_PATHS)) == 52
    assert all((bundles.REPO_ROOT / path).is_file() for path in ACTIVE_RESEARCH_PATHS)


@pytest.mark.parametrize(
    "path",
    ACTIVE_RESEARCH_PATHS,
    ids=lambda path: path.as_posix(),
)
def test_active_profile_rejects_retired_research_root(path: Path) -> None:
    """Exclude the untracked artifacts/research destination from every profile."""

    text = (bundles.REPO_ROOT / path).read_text(encoding="utf-8")

    assert "artifacts/research/" not in text


@pytest.mark.parametrize(
    "path",
    ACTIVE_RESEARCH_PATHS,
    ids=lambda path: path.as_posix(),
)
def test_active_profile_accepts_only_tracked_research_destinations(path: Path) -> None:
    """Require a feature-local root and the tracked one-off docs root."""

    text = (bundles.REPO_ROOT / path).read_text(encoding="utf-8")

    assert (
        "<feature-folder>/research/" in text
        or "docs/features/<feature>/research/" in text
    )
    assert "docs/research/" in text
