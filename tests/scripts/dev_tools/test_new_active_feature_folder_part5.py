"""Tests for the promoted-record disposition rule in new_active_feature_folder.

A potential file resolved from ``docs/features/potential/promoted/`` is COPIED
into the active folder as ``issue.md`` so the promoted record is retained; a
source resolved from anywhere else is still MOVED. Both arms of the emitted-line
wording are covered here so the Python cluster stays in parity with the
TypeScript cluster.

Split into its own module because
``tests/scripts/dev_tools/test_new_active_feature_folder.py`` is already over the
500-line limit; the ``_partN`` split is the convention already in use in this
directory.
"""

from __future__ import annotations

from datetime import datetime
from pathlib import Path
from typing import TYPE_CHECKING
from zoneinfo import ZoneInfo

from scripts.dev_tools import new_active_feature_folder as mod
from tests.scripts.dev_tools.test_new_active_feature_folder import FakeCodeLauncher
from tests.scripts.dev_tools.test_new_active_feature_folder_part4 import FakeFileSystem

if TYPE_CHECKING:
    import pytest

FIXED_NOW = datetime(2024, 1, 2, 3, 4, tzinfo=ZoneInfo("America/New_York"))
POTENTIAL_BODY = "\n".join(
    [
        "## Problem / Why",
        "problem text",
        "## Proposed Behavior",
        "behavior text",
        "## Acceptance Criteria (early draft)",
        "first item",
        "## Constraints & Risks",
        "risk text",
        "## Test Conditions to Consider",
        "test A",
    ]
)


def _seed_feature_template(fs: mod.FileSystem, workspace: Path) -> None:
    """Seed the feature templates required by the tests in this module."""
    template_dir = workspace / "docs" / "features" / "templates" / "feature"
    fs.write_text(
        template_dir / "user-story.md", "- **Issue:** <issue>\n<feature-name>"
    )
    fs.write_text(template_dir / "spec.md", "- **Issue:** <issue>\n<feature-name>")
    fs.write_text(
        template_dir / "plan.yyyy-MM-ddTHH-mm.md",
        "- **Issue:** <issue>\n<feature-name>",
    )


def test_create_feature_folder_moves_unpromoted_potential(
    capsys: pytest.CaptureFixture[str],
) -> None:
    """Verify a source outside promoted/ is still moved and reports a move."""
    # Arrange: the potential file sits directly under docs/features/potential/.
    fs = FakeFileSystem()
    workspace = Path("/workspace")
    _seed_feature_template(fs, workspace)
    potential_path = workspace / "docs" / "features" / "potential" / "notes-feature.md"
    fs.write_text(potential_path, POTENTIAL_BODY)

    # Act
    result = mod.create_active_folder(
        feature_name="notes-feature",
        feature_type="feature",
        workspace=workspace,
        fs=fs,
        code_launcher=FakeCodeLauncher(),
        now_provider=lambda: FIXED_NOW,
    )

    # Assert: the unpromoted source is removed and the move wording is emitted.
    expected_issue = result.target / "issue.md"
    assert result.potential_issue_path == expected_issue
    assert expected_issue in fs.files
    assert potential_path not in fs.files
    assert f"Moved potential file to {expected_issue}" in capsys.readouterr().out


def test_create_feature_folder_copies_promoted_potential(
    capsys: pytest.CaptureFixture[str],
) -> None:
    """Verify a promoted source is retained and reports a copy."""
    # Arrange: the only matching potential file lives under promoted/.
    fs = FakeFileSystem()
    workspace = Path("/workspace")
    _seed_feature_template(fs, workspace)
    promoted_path = (
        workspace / "docs" / "features" / "potential" / "promoted" / "notes-feature.md"
    )
    fs.write_text(promoted_path, POTENTIAL_BODY)

    # Act
    result = mod.create_active_folder(
        feature_name="notes-feature",
        feature_type="feature",
        workspace=workspace,
        fs=fs,
        code_launcher=FakeCodeLauncher(),
        now_provider=lambda: FIXED_NOW,
    )

    # Assert: the promoted record survives with unchanged content.
    expected_issue = result.target / "issue.md"
    assert result.potential_issue_path == expected_issue
    assert expected_issue in fs.files
    assert promoted_path in fs.files
    assert fs.files[promoted_path] == POTENTIAL_BODY
    assert f"Copied potential file to {expected_issue}" in capsys.readouterr().out


def test_create_minor_audit_folder_copies_promoted_potential(
    capsys: pytest.CaptureFixture[str],
) -> None:
    """Verify the minor-audit placement site also retains a promoted source."""
    # Arrange: the only matching potential file lives under promoted/.
    fs = FakeFileSystem()
    workspace = Path("/workspace")
    _seed_feature_template(fs, workspace)
    promoted_path = (
        workspace / "docs" / "features" / "potential" / "promoted" / "notes-feature.md"
    )
    fs.write_text(promoted_path, POTENTIAL_BODY)

    # Act
    result = mod.create_active_folder(
        feature_name="notes-feature",
        feature_type="feature",
        workspace=workspace,
        fs=fs,
        code_launcher=FakeCodeLauncher(),
        now_provider=lambda: FIXED_NOW,
        work_mode="minor-audit",
    )

    # Assert: the promoted record survives and the minor-audit branch reports a
    # copy, covering the second placement site.
    expected_issue = result.target / "issue.md"
    assert result.potential_issue_path == expected_issue
    assert "- Work Mode: minor-audit" in fs.files[expected_issue]
    assert promoted_path in fs.files
    assert fs.files[promoted_path] == POTENTIAL_BODY
    assert f"Copied potential file to {expected_issue}" in capsys.readouterr().out
