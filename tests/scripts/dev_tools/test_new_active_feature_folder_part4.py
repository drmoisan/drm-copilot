"""Tests for new_active_feature_folder Python implementation."""

from __future__ import annotations

import sys
from pathlib import Path
from typing import TYPE_CHECKING

import pytest

from scripts.dev_tools import new_active_feature_folder as mod
from tests.scripts.dev_tools.test_new_active_feature_folder import FakeCodeLauncher

if TYPE_CHECKING:
    from collections.abc import Iterable


class FakeFileSystem(mod.FileSystem):
    """In-memory filesystem fake for active-folder workflow tests."""

    def __init__(self) -> None:
        """Initialize in-memory file and directory stores."""
        self.files: dict[Path, str] = {}
        self.dirs: set[Path] = set()

    def exists(self, path: Path) -> bool:
        """Return whether a file or directory exists in fake storage."""
        return path in self.files or path in self.dirs

    def ensure_dir(self, path: Path) -> None:
        """Record directory creation in fake storage."""
        self.dirs.add(path)

    def copy_file(self, src: Path, dest: Path) -> None:
        """Copy fake file content from source path to destination path."""
        if src not in self.files:
            raise FileNotFoundError(src)
        self.files[dest] = self.files[src]
        self.dirs.add(dest.parent)

    def copy_tree(self, src: Path, dest: Path) -> None:
        """Copy all fake files under source tree into destination tree."""
        for path, content in list(self.files.items()):
            try:
                relative = path.relative_to(src)
            except ValueError:
                continue
            self.files[dest / relative] = content
            self.dirs.add((dest / relative).parent)

    def list_files(self, path: Path) -> Iterable[Path]:
        """List immediate fake files in the provided directory path."""
        return [file_path for file_path in self.files if file_path.parent == path]

    def read_text(self, path: Path) -> str:
        """Read fake file content from memory."""
        return self.files[path]

    def write_text(self, path: Path, content: str) -> None:
        """Write fake file content into memory and track parent directory."""
        self.files[path] = content
        self.dirs.add(path.parent)

    def move(self, src: Path, dest: Path) -> None:
        """Move fake file content to a new path in memory."""
        if src not in self.files:
            raise FileNotFoundError(src)
        self.files[dest] = self.files.pop(src)
        self.dirs.add(dest.parent)


def _seed_feature_template(fs: mod.FileSystem, workspace: Path) -> None:
    """Seed feature templates required by tests in this split module."""
    template_dir = workspace / "docs" / "features" / "templates" / "feature"
    fs.write_text(
        template_dir / "user-story.md", "- **Issue:** <issue>\n<feature-name>"
    )
    fs.write_text(template_dir / "spec.md", "- **Issue:** <issue>\n<feature-name>")
    fs.write_text(
        template_dir / "plan.yyyy-MM-ddTHH-mm.md",
        "- **Issue:** <issue>\n<feature-name>",
    )


def _seed_bug_template(fs: mod.FileSystem, workspace: Path) -> None:
    """Seed bug templates required by tests in this split module."""
    template_dir = workspace / "docs" / "features" / "templates" / "bug"
    fs.write_text(template_dir / "spec.md", "- **Issue:** <issue>\n<feature-name>")
    fs.write_text(
        template_dir / "plan.yyyy-MM-ddTHH-mm.md", "- **Issue:** <issue>\n<bug-name>"
    )


def test_work_mode_marker_minor_audit_issue_md_even_when_heuristics_fail() -> None:
    """Verify explicit minor-audit keeps the minor marker above the first section."""
    fs = FakeFileSystem()
    workspace = Path("/workspace")
    _seed_feature_template(fs, workspace)
    potential_path = (
        workspace / "docs" / "features" / "potential" / "fallback-marker.md"
    )
    fs.write_text(
        potential_path,
        "\n".join(
            [
                "- Issue: #31",
                "- File: a.py",
                "- File: b.py",
                "- File: c.py",
                "- File: d.py",
                "## Problem / Why",
                "problem",
                "## Proposed Behavior",
                "behavior",
            ]
        ),
    )

    result = mod.create_active_folder(
        feature_name="fallback-marker",
        feature_type="feature",
        workspace=workspace,
        fs=fs,
        code_launcher=FakeCodeLauncher(),
        work_mode="minor-audit",
    )

    issue_md = fs.read_text(result.target / "issue.md")
    lines = issue_md.splitlines()
    first_section_index = lines.index("## Problem / Why")
    assert first_section_index > 0
    assert lines[first_section_index - 2] == "- Work Mode: minor-audit"
    assert lines[first_section_index - 1] == ""


def test_create_active_folder_full_mode_alias_remains_backward_compatible() -> None:
    """Verify legacy full alias still creates full-feature document outputs."""
    fs = FakeFileSystem()
    workspace = Path("/workspace")
    _seed_feature_template(fs, workspace)
    result = mod.create_active_folder(
        feature_name="full-compatible",
        feature_type="feature",
        workspace=workspace,
        fs=fs,
        code_launcher=FakeCodeLauncher(),
        work_mode="full",
    )
    assert fs.exists(result.target / "user-story.md")


def test_create_active_folder_minor_audit_has_no_fallback_reason(
    capsys: pytest.CaptureFixture[str],
) -> None:
    """Verify explicit minor-audit does not emit fallback output."""
    fs = FakeFileSystem()
    workspace = Path("/workspace")
    _seed_feature_template(fs, workspace)
    result = mod.create_active_folder(
        feature_name="no-potential",
        feature_type="feature",
        workspace=workspace,
        fs=fs,
        code_launcher=FakeCodeLauncher(),
        work_mode="minor-audit",
    )
    assert result.target
    out = capsys.readouterr().out
    assert "Fallback reason:" not in out
    assert "Selected mode: minor-audit" in out


def test_parse_args_includes_work_mode(monkeypatch: pytest.MonkeyPatch) -> None:
    """Verify parser includes and accepts the `--work-mode` argument."""
    monkeypatch.setattr(
        sys,
        "argv",
        [
            "prog",
            "--feature-name",
            "sample",
            "--type",
            "feature",
            "--work-mode",
            "minor-audit",
        ],
    )
    parsed = mod.parse_args()
    assert parsed.work_mode == "minor-audit"


def test_create_active_folder_auto_resolve_feature_name_from_promoted_active_file() -> (
    None
):
    """Verify active-file auto-resolve derives feature name from markdown stem."""
    fs = FakeFileSystem()
    workspace = Path("/workspace")
    _seed_bug_template(fs, workspace)
    active_file = (
        workspace
        / "docs"
        / "features"
        / "potential"
        / "promoted"
        / "2026-02-22-testing-missing-mock-injections.md"
    )
    fs.write_text(
        active_file,
        "\n".join(
            [
                "- Issue: #42",
                "## Summary",
                "auto resolve bug",
                "## Expected Behavior",
                "expected",
                "## Actual Behavior",
                "actual",
            ]
        ),
    )

    code_launcher = FakeCodeLauncher()
    result = mod.create_active_folder(
        feature_name="manual-name",
        feature_type="bug",
        issue_number="auto",
        workspace=workspace,
        fs=fs,
        code_launcher=code_launcher,
        active_file_for_feature_name=str(active_file),  # type: ignore[call-arg]
    )

    expected_folder = (
        workspace
        / "docs"
        / "features"
        / "active"
        / "2026-02-22-testing-missing-mock-injections-42"
    )
    assert result.target == expected_folder
    assert result.potential_issue_path == expected_folder / "issue.md"
    assert active_file not in fs.files


def _auto_resolve_rejects_non_promoted_or_non_markdown_active_file() -> None:
    """Verify invalid active-file auto-resolve inputs raise guidance error."""
    fs = FakeFileSystem()
    workspace = Path("/workspace")
    _seed_bug_template(fs, workspace)
    bad_path = workspace / "docs" / "features" / "potential" / "not-promoted.md"
    fs.write_text(bad_path, "- Issue: #42\n## Summary\ninvalid")

    expected_error = (
        "Select a promoted issue markdown file under "
        "docs/features/potential/promoted or supply --feature-name directly."
    )

    with pytest.raises(ValueError) as outside_error:
        mod.create_active_folder(
            feature_name="manual-name",
            feature_type="bug",
            issue_number="auto",
            workspace=workspace,
            fs=fs,
            active_file_for_feature_name=str(bad_path),  # type: ignore[call-arg]
        )
    assert str(outside_error.value) == expected_error

    wrong_ext = (
        workspace
        / "docs"
        / "features"
        / "potential"
        / "promoted"
        / "2026-02-22-testing-missing-mock-injections.txt"
    )
    fs.write_text(wrong_ext, "- Issue: #42")
    with pytest.raises(ValueError) as extension_error:
        mod.create_active_folder(
            feature_name="manual-name",
            feature_type="bug",
            issue_number="auto",
            workspace=workspace,
            fs=fs,
            active_file_for_feature_name=str(wrong_ext),  # type: ignore[call-arg]
        )
    assert str(extension_error.value) == expected_error


globals()[
    "test_create_active_folder_auto_resolve_rejects_non_promoted_or_"
    "non_markdown_active_file"
] = _auto_resolve_rejects_non_promoted_or_non_markdown_active_file


def test_create_active_folder_full_mode_persists_full_marker_in_issue_md() -> None:
    """Verify legacy full alias persists canonical full-feature marker in issue.md."""
    fs = FakeFileSystem()
    workspace = Path("/workspace")
    _seed_feature_template(fs, workspace)
    potential_path = (
        workspace
        / "docs"
        / "features"
        / "potential"
        / "promoted"
        / "2026-02-22-testing-missing-mock-injections.md"
    )
    fs.write_text(
        potential_path,
        "\n".join(
            [
                "- Issue: #42",
                "## Problem / Why",
                "problem",
                "## Proposed Behavior",
                "behavior",
            ]
        ),
    )

    result = mod.create_active_folder(
        feature_name="testing-missing-mock-injections",
        feature_type="feature",
        issue_number="auto",
        workspace=workspace,
        fs=fs,
        code_launcher=FakeCodeLauncher(),
        work_mode="full",
    )

    issue_md = fs.read_text(result.target / "issue.md")
    lines = issue_md.splitlines()
    marker_lines = [line for line in lines if line.startswith("- Work Mode:")]
    assert marker_lines == ["- Work Mode: full-feature"]
    first_section_index = lines.index("## Problem / Why")
    marker_index = lines.index("- Work Mode: full-feature")
    assert marker_index == first_section_index - 2
    assert lines[first_section_index - 1] == ""


def test_create_active_folder_bug_full_alias_persists_full_bug_marker() -> None:
    """Verify legacy full alias normalizes to full-bug for bug folder creation."""
    fs = FakeFileSystem()
    workspace = Path("/workspace")
    _seed_bug_template(fs, workspace)
    potential_path = (
        workspace
        / "docs"
        / "features"
        / "potential"
        / "promoted"
        / "2026-02-22-bug-mode-test.md"
    )
    fs.write_text(
        potential_path,
        "\n".join(
            [
                "- Issue: #52",
                "## Summary",
                "summary",
                "## Expected Behavior",
                "expected",
                "## Actual Behavior",
                "actual",
            ]
        ),
    )

    result = mod.create_active_folder(
        feature_name="bug-mode-test",
        feature_type="bug",
        issue_number="auto",
        workspace=workspace,
        fs=fs,
        code_launcher=FakeCodeLauncher(),
        work_mode="full",
    )

    issue_md = fs.read_text(result.target / "issue.md")
    assert "- Work Mode: full-bug" in issue_md
    assert fs.exists(result.target / "spec.md")
    assert not fs.exists(result.target / "user-story.md")


def _minor_audit_behavior_unchanged_with_auto_resolve_option_absent() -> None:
    """Verify minor-audit behavior is unchanged without auto-resolve input."""
    fs = FakeFileSystem()
    workspace = Path("/workspace")
    _seed_feature_template(fs, workspace)
    potential_path = (
        workspace / "docs" / "features" / "potential" / "minor-unchanged.md"
    )
    fs.write_text(
        potential_path,
        "\n".join(
            [
                "- Issue: #28",
                "- File: scripts/dev_tools/new_active_feature_folder.py",
                "- Risk: low",
                "## Problem / Why",
                "problem",
                "## Proposed Behavior",
                "intent",
                "## Constraints & Risks",
                "low integration risk",
            ]
        ),
    )

    result = mod.create_active_folder(
        feature_name="minor-unchanged",
        feature_type="feature",
        workspace=workspace,
        fs=fs,
        code_launcher=FakeCodeLauncher(),
        work_mode="minor-audit",
        active_file_for_feature_name=None,  # type: ignore[call-arg]
    )

    issue_md = fs.read_text(result.target / "issue.md")
    assert "- Work Mode: minor-audit" in issue_md
    assert not fs.exists(result.target / "spec.md")
    assert not fs.exists(result.target / "user-story.md")


globals()[
    "test_create_active_folder_minor_audit_behavior_unchanged_with_auto_"
    "resolve_option_absent"
] = _minor_audit_behavior_unchanged_with_auto_resolve_option_absent
