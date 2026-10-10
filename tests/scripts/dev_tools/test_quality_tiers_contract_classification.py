"""Unit tests for the quality-tiers classification and entry checks.

Only the two committed-tree tests read the committed quality-tiers.yml, read-only.
"""

from __future__ import annotations

from pathlib import Path

import pytest

from scripts.dev_tools.quality_tiers_contract import (
    find_classification_errors,
    find_entry_errors,
    parse_quality_tiers,
)
from tests.scripts.dev_tools.quality_tiers_contract_test_support import (
    make_manifest,
    qt_codes,
)

REPO_ROOT = Path(__file__).resolve().parents[3]


SPEC_TIER_ASSIGNMENTS: tuple[tuple[str, str], ...] = (
    (".", "T4"),
    ("extensions/drm-copilot", "T3"),
    ("packages/mcp-server", "T4"),
    ("scripts/powershell/PoshQC", "T3"),
    ("scripts/dev_tools", "T4"),
    ("scripts/dev-tools", "T4"),
    ("scripts/bash", "T4"),
    ("scripts/powershell", "T4"),
    (".claude/hooks", "T3"),
    (".codex/hooks", "T3"),
    (".claude/lib/bash", "T3"),
    (".claude/lib/blast-radius", "T3"),
    (".claude/lib/ci-gate", "T3"),
    (".claude/lib/cleanup-manifest", "T3"),
    (".claude/lib/codex-routing", "T3"),
    (".claude/lib/discovery-validation", "T3"),
    (".claude/lib/hook-payload", "T3"),
    (".claude/lib/mermaid", "T3"),
    (".claude/lib/model-routing", "T3"),
    (".claude/lib/orchestrator-state", "T3"),
    (".claude/lib/parallel-drift", "T3"),
    (".claude/lib/project-file-merge", "T3"),
    (".claude/lib/requirements", "T3"),
    (".claude/lib/worktree-resolution", "T3"),
)
"""The 24 rows of the spec "Tier assignments" table, in table order."""


def test_find_classification_errors_valid_manifest_returns_no_errors() -> None:
    """A manifest matching the discovered set reports no errors."""
    # Arrange
    manifest = make_manifest((".", "T4"), ("scripts/bash", "T4"))

    # Act
    errors = find_classification_errors(manifest, frozenset({".", "scripts/bash"}))

    # Assert
    assert errors == []


@pytest.mark.parametrize("tier", ["T5", "t3"])
def test_find_entry_errors_reports_qt004_for_invalid_tier(tier: str) -> None:
    """A tier outside T1-T4 (case-sensitive) yields QT004."""
    # Act
    errors = find_entry_errors(make_manifest(("scripts/bash", tier)))

    # Assert
    assert qt_codes(errors) == ["QT004"]
    assert errors[0].path == "scripts/bash"


def test_find_entry_errors_reports_qt005_for_duplicate_path() -> None:
    """Two entries with the same path yield QT005."""
    # Act
    errors = find_entry_errors(
        make_manifest(("scripts/bash", "T4"), ("scripts/bash", "T3"))
    )

    # Assert
    assert qt_codes(errors) == ["QT005"]
    assert "scripts/bash" in errors[0].message


@pytest.mark.parametrize(
    "path",
    [
        pytest.param("/scripts/bash", id="absolute"),
        pytest.param("C:/repo/scripts", id="drive-letter"),
        pytest.param("scripts\\bash", id="backslash"),
        pytest.param("scripts/bash/", id="trailing-slash"),
        pytest.param("scripts/../bash", id="dotdot-segment"),
        pytest.param("./scripts/bash", id="leading-dot-segment"),
    ],
)
def test_find_entry_errors_reports_qt006_for_malformed_path(path: str) -> None:
    """A path that is not repository-relative POSIX yields QT006."""
    # Act
    errors = find_entry_errors(make_manifest((path, "T4")))

    # Assert
    assert qt_codes(errors) == ["QT006"]
    assert errors[0].path == path


def test_find_classification_errors_reports_qt007_for_undiscovered_entry() -> None:
    """An entry whose path is not a discovered project yields QT007."""
    # Arrange
    manifest = make_manifest(("scripts/bash", "T4"), ("scripts/gone", "T4"))

    # Act
    errors = find_classification_errors(manifest, frozenset({"scripts/bash"}))

    # Assert
    assert qt_codes(errors) == ["QT007"]
    assert errors[0].path == "scripts/gone"


def test_find_classification_errors_reports_qt008_for_unclassified_project() -> None:
    """A discovered project without an entry yields QT008 naming the path."""
    # Arrange
    manifest = make_manifest(("scripts/bash", "T4"))

    # Act
    errors = find_classification_errors(
        manifest, frozenset({"scripts/bash", "scripts/new"})
    )

    # Assert
    assert qt_codes(errors) == ["QT008"]
    assert "scripts/new" in errors[0].render()


def test_find_classification_errors_empty_project_set_reports_qt007_for_every_entry():
    """An empty discovered set never passes silently: every entry yields QT007."""
    # Arrange
    manifest = make_manifest(("scripts/bash", "T4"), (".", "T4"))

    # Act
    errors = find_classification_errors(manifest, frozenset())

    # Assert
    assert qt_codes(errors) == ["QT007", "QT007"]


def test_find_classification_errors_accumulates_qt004_and_qt008() -> None:
    """An invalid tier and an unclassified project are both reported in one call."""
    # Arrange
    manifest = make_manifest(("scripts/bash", "T5"))

    # Act
    errors = find_classification_errors(
        manifest, frozenset({"scripts/bash", "scripts/new"})
    )

    # Assert
    assert sorted(qt_codes(errors)) == ["QT004", "QT008"]


def test_committed_quality_tiers_yml_matches_live_tree() -> None:
    """The committed manifest parses cleanly and every entry is an existing folder."""
    # Arrange
    text = (REPO_ROOT / "quality-tiers.yml").read_text(encoding="utf-8")

    # Act
    manifest, parse_errors = parse_quality_tiers(text)

    # Assert
    assert parse_errors == [], f"parse errors: {parse_errors}"
    assert manifest is not None
    assert find_entry_errors(manifest) == []
    missing = [
        entry.path
        for entry in manifest.entries
        if not (REPO_ROOT / entry.path).is_dir()
    ]
    assert missing == [], f"entries without a folder: {missing}"


def test_committed_quality_tiers_yml_assigns_spec_tiers() -> None:
    """Every spec tier-table row is present with its tier, and no entry is T1 or T2."""
    # Arrange
    text = (REPO_ROOT / "quality-tiers.yml").read_text(encoding="utf-8")

    # Act
    manifest, _ = parse_quality_tiers(text)

    # Assert
    assert manifest is not None
    assigned = {entry.path: entry.tier for entry in manifest.entries}
    assert len(SPEC_TIER_ASSIGNMENTS) == 24
    for path, tier in SPEC_TIER_ASSIGNMENTS:
        assert assigned.get(path) == tier, f"{path}: expected {tier}"
    elevated = sorted(path for path, tier in assigned.items() if tier in {"T1", "T2"})
    assert elevated == [], f"unexpected T1/T2 entries: {elevated}"
