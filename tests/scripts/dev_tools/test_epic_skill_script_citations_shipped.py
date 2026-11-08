"""Regression tests: epic skill and agent surfaces cite only shipped scripts.

Purpose:
    Issue #1129 found that the epic skills cited a script
    (`scripts/dev_tools/epic_wave_computation.py`) that the push-down never
    delivers to a destination repository. These tests fail whenever an epic
    surface cites a repository-relative script path that the owning pack
    manifest (`core.json`) does not ship, unless the path is allowlisted with a
    reason naming the route that replaces it.

Responsibilities:
    Provide two pure helpers (`find_unshipped_citations` and
    `find_stale_allowlist_entries`) and assert them against in-memory inputs and
    against the committed Claude and Codex epic surfaces.
"""

from __future__ import annotations

import json
import re
from pathlib import Path
from typing import TYPE_CHECKING

if TYPE_CHECKING:
    from collections.abc import Mapping, Sequence

REPO_ROOT = Path(__file__).resolve().parents[3]

CLAUDE_MANIFEST = (
    "extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json"
)
CODEX_MANIFEST = (
    "extensions/drm-copilot/resources/codex-and-agents-customizations/"
    "pack-manifests/core.json"
)

CLAUDE_SURFACES = (
    ".claude/skills/epic-plan/SKILL.md",
    ".claude/skills/epic-orchestrate/SKILL.md",
    ".claude/agents/epic-orchestrator.md",
    ".claude/agents/epic-planner.md",
)
CODEX_SURFACES = (
    ".agents/skills/epic-plan/SKILL.md",
    ".agents/skills/epic-orchestrate/SKILL.md",
    ".codex/agents/epic-orchestrator.toml",
    ".codex/agents/epic-planner.toml",
)

# Cited paths that are deliberately not shipped, each with the reason that names
# the route the citing sentence uses instead.
ALLOWLIST: Mapping[str, str] = {
    "scripts/dev_tools/validate_epic_orchestrator_state.py": (
        "Validated through the MCP tool validate_orchestration_artifacts, "
        "which the citing sentences already name."
    ),
}

_PATH_PATTERN = re.compile(
    r"(?<![A-Za-z0-9_./-])"
    r"((?:scripts|\.claude|\.codex|\.agents)/[A-Za-z0-9_./-]*?\.(?:py|ps1|psm1|sh))"
    r"(?![A-Za-z0-9_])"
)


def _cited_paths(surface_texts: Mapping[str, str]) -> set[str]:
    """Return every script path cited by any surface text.

    Args:
        surface_texts (Mapping[str, str]): Surface path to surface text.

    Returns:
        set[str]: Repository-relative script paths found in the texts.

    Raises:
        None.

    Side Effects:
        None.
    """

    cited: set[str] = set()
    # Collect each path token; the lookbehind keeps a nested `scripts/` segment of
    # a `.codex/scripts/...` path from being read as a separate path.
    for text in surface_texts.values():
        cited.update(match.group(1) for match in _PATH_PATTERN.finditer(text))
    return cited


def find_unshipped_citations(
    surface_texts: Mapping[str, str],
    manifest_paths: Sequence[str],
    allowlist: Mapping[str, str],
) -> list[str]:
    """Return cited script paths that are neither shipped nor allowlisted.

    Args:
        surface_texts (Mapping[str, str]): Surface path to surface text.
        manifest_paths (Sequence[str]): Paths listed in the owning `core.json`.
        allowlist (Mapping[str, str]): Allowlisted path to reason.

    Returns:
        list[str]: Sorted unshipped, unallowlisted cited paths.

    Raises:
        None.

    Side Effects:
        None.
    """

    shipped = set(manifest_paths)
    return sorted(
        path
        for path in _cited_paths(surface_texts)
        if path not in shipped and path not in allowlist
    )


def find_stale_allowlist_entries(
    surface_texts: Mapping[str, str],
    allowlist: Mapping[str, str],
) -> list[str]:
    """Return allowlisted paths that no surface cites.

    Args:
        surface_texts (Mapping[str, str]): Surface path to surface text.
        allowlist (Mapping[str, str]): Allowlisted path to reason.

    Returns:
        list[str]: Sorted allowlist paths cited nowhere.

    Raises:
        None.

    Side Effects:
        None.
    """

    cited = _cited_paths(surface_texts)
    return sorted(path for path in allowlist if path not in cited)


def _read_surfaces(paths: Sequence[str]) -> dict[str, str]:
    """Read committed surface files into a path-to-text mapping.

    Args:
        paths (Sequence[str]): Repository-relative surface paths.

    Returns:
        dict[str, str]: Path to file text.

    Raises:
        FileNotFoundError: If a surface file does not exist.

    Side Effects:
        Reads files from the repository tree.
    """

    return {
        path: (REPO_ROOT / path).read_text(encoding="utf-8").replace("\r\n", "\n")
        for path in paths
    }


def _read_manifest_paths(manifest: str) -> list[str]:
    """Read the `paths` list of a pack manifest.

    Args:
        manifest (str): Repository-relative manifest path.

    Returns:
        list[str]: The manifest `paths` entries.

    Raises:
        FileNotFoundError: If the manifest does not exist.

    Side Effects:
        Reads a file from the repository tree.
    """

    data = json.loads((REPO_ROOT / manifest).read_text(encoding="utf-8"))
    return [str(path) for path in data["paths"]]


def test_every_epic_surface_citation_is_shipped() -> None:
    """Fail when an epic surface cites a script its pack does not ship."""

    unshipped = find_unshipped_citations(
        _read_surfaces(CLAUDE_SURFACES),
        _read_manifest_paths(CLAUDE_MANIFEST),
        ALLOWLIST,
    ) + find_unshipped_citations(
        _read_surfaces(CODEX_SURFACES),
        _read_manifest_paths(CODEX_MANIFEST),
        ALLOWLIST,
    )

    assert unshipped == [], f"Epic surfaces cite unshipped scripts: {unshipped}"


def test_allowlist_reasons_name_the_mcp_route() -> None:
    """Require each allowlist reason to name the MCP validation route."""

    assert set(ALLOWLIST) == {"scripts/dev_tools/validate_epic_orchestrator_state.py"}
    for path, reason in ALLOWLIST.items():
        assert "validate_orchestration_artifacts" in reason, path


def test_allowlist_has_no_stale_entry() -> None:
    """Fail when an allowlisted path is cited by no epic surface."""

    surfaces = {**_read_surfaces(CLAUDE_SURFACES), **_read_surfaces(CODEX_SURFACES)}

    assert find_stale_allowlist_entries(surfaces, ALLOWLIST) == []


def test_find_unshipped_citations_reports_unlisted_path() -> None:
    """Report an unlisted path and keep a nested `.codex/scripts/` path whole."""

    texts = {
        "a.md": (
            "Run `scripts/tool.py` and .codex/scripts/launch.ps1 then "
            "`.claude/lib/x/Y.psm1`; allowed scripts/skip.py."
        )
    }

    result = find_unshipped_citations(
        texts, [".codex/scripts/launch.ps1"], {"scripts/skip.py": "reason"}
    )

    assert result == [".claude/lib/x/Y.psm1", "scripts/tool.py"]


def test_find_stale_allowlist_entries_reports_uncited_entry() -> None:
    """Report an allowlist entry that no surface text cites."""

    texts = {"a.md": "cites scripts/used.py only"}

    result = find_stale_allowlist_entries(
        texts, {"scripts/used.py": "r", "scripts/gone.py": "r"}
    )

    assert result == ["scripts/gone.py"]
