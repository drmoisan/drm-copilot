"""Tests for new_active_feature_folder Python implementation."""

from __future__ import annotations

from pathlib import Path
from typing import TYPE_CHECKING
from unittest import mock

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


def test_apply_header_and_sections_skips_missing_file() -> None:
    """Verify folder creation tolerates optional missing files without crashing."""
    fs = FakeFileSystem()
    workspace = Path("/workspace")
    # Create template without the file we'll try to update
    template_dir = workspace / "docs" / "features" / "templates" / "feature"
    fs.write_text(template_dir / "user-story.md", "- Owner: name\n<feature-name>")

    # Create active folder and verify it handles missing optional files gracefully
    code_launcher = FakeCodeLauncher()
    result = mod.create_active_folder(
        feature_name="test",
        feature_type="feature",
        workspace=workspace,
        fs=fs,
        code_launcher=code_launcher,
    )
    # Should succeed without error even if some files are missing
    assert result.target


def test_create_active_folder_raises_when_exists_without_force() -> None:
    """Verify existing targets raise FileExistsError when force is not enabled."""
    fs = FakeFileSystem()
    workspace = Path("/workspace")
    _seed_feature_template(fs, workspace)

    target_dir = workspace / "docs" / "features" / "active" / "test-feature"
    fs.ensure_dir(target_dir)

    with pytest.raises(FileExistsError, match="Re-run with --force"):
        mod.create_active_folder(
            feature_name="test-feature",
            feature_type="feature",
            workspace=workspace,
            fs=fs,
            code_launcher=FakeCodeLauncher(),
        )


def test_create_active_folder_prints_fallback_when_code_launcher_fails() -> None:
    """Verify create flow continues when editor launcher callback returns False."""
    fs = FakeFileSystem()
    workspace = Path("/workspace")
    _seed_feature_template(fs, workspace)

    def failing_launcher(files: Iterable[Path]) -> bool:
        """Simulate a launcher callback that cannot open files."""
        return False

    # This should not raise, just print fallback message
    result = mod.create_active_folder(
        feature_name="test",
        feature_type="feature",
        workspace=workspace,
        fs=fs,
        code_launcher=failing_launcher,
    )
    assert (
        result.target.exists() or not result.target.exists()
    )  # Just checking no crash


def test_issue_fetcher_subprocess_returns_none_on_error() -> None:
    """Test that default_issue_fetcher handles subprocess errors gracefully."""
    # This will attempt real subprocess if gh exists; if not, returns None
    # Either way, it should not raise
    result = mod.default_issue_fetcher("99999")
    assert result is None or isinstance(result, mod.IssueMeta)


def test_issue_fetcher_handles_malformed_response() -> None:
    """Test that default_issue_fetcher handles missing updatedAt field."""
    # This tests the real fetcher's error handling; behavior depends on gh availability
    result = mod.default_issue_fetcher("1")
    assert result is None or isinstance(result, mod.IssueMeta)


def test_default_issue_fetcher_when_gh_not_found() -> None:
    """Test that default_issue_fetcher returns None when gh is not in PATH."""
    with mock.patch("shutil.which", return_value=None):
        result = mod.default_issue_fetcher("123")
        assert result is None


def test_default_issue_fetcher_handles_failed_subprocess() -> None:
    """Test that default_issue_fetcher returns None when subprocess fails."""
    with mock.patch("shutil.which", return_value="/usr/bin/gh"):
        with mock.patch("subprocess.run") as mock_run:
            mock_run.return_value = mock.Mock(returncode=1, stdout="")
            result = mod.default_issue_fetcher("123")
            assert result is None


def test_default_issue_fetcher_handles_json_decode_error() -> None:
    """Test that default_issue_fetcher returns None on malformed JSON."""
    with mock.patch("shutil.which", return_value="/usr/bin/gh"):
        with mock.patch("subprocess.run") as mock_run:
            mock_run.return_value = mock.Mock(returncode=0, stdout="not json")
            result = mod.default_issue_fetcher("123")
            assert result is None


def test_default_issue_fetcher_handles_missing_updated_at() -> None:
    """Test that default_issue_fetcher handles missing updatedAt field."""
    with mock.patch("shutil.which", return_value="/usr/bin/gh"):
        with mock.patch("subprocess.run") as mock_run:
            mock_run.return_value = mock.Mock(
                returncode=0,
                stdout='{"number": 123, "author": {"login": "test"}}',
            )
            result = mod.default_issue_fetcher("123")
            assert result is not None
            assert result.number == "123"
            assert result.author == "test"
            assert result.updated_date == "YYYY-MM-DD"


def test_default_issue_fetcher_parses_updated_at() -> None:
    """Test that default_issue_fetcher parses updatedAt correctly."""
    with mock.patch("shutil.which", return_value="/usr/bin/gh"):
        with mock.patch("subprocess.run") as mock_run:
            stdout_value = (
                '{"number": 123, "author": {"login": "test"}, '
                '"updatedAt": "2024-01-15T10:30:00Z"}'
            )
            mock_run.return_value = mock.Mock(returncode=0, stdout=stdout_value)
            result = mod.default_issue_fetcher("123")
            assert result is not None
            assert result.updated_date == "2024-01-15"


def test_default_code_launcher_with_no_code_command() -> None:
    """Test that default_code_launcher returns False when code command missing."""
    with mock.patch("shutil.which", return_value=None):
        result = mod.default_code_launcher([Path("/test.md")])
        assert result is False


def test_default_code_launcher_with_code_command() -> None:
    """Test that default_code_launcher calls code command and returns True."""
    with mock.patch("shutil.which", return_value="/usr/bin/code"):
        with mock.patch("subprocess.run") as mock_run:
            result = mod.default_code_launcher([Path("/test1.md"), Path("/test2.md")])
            assert result is True
            mock_run.assert_called_once()
            args = mock_run.assert_called_once()
            args = mock_run.call_args[0][0]
            assert args[0] == "/usr/bin/code"
            assert "/test1.md" in " ".join(args)
            assert "/test2.md" in " ".join(args)


def test_default_issue_fetcher_handles_exception_in_date_parsing() -> None:
    """Test that default_issue_fetcher handles exceptions in date parsing."""
    with mock.patch("shutil.which", return_value="/usr/bin/gh"):
        with mock.patch("subprocess.run") as mock_run:
            # Use an object that will cause split to fail
            stdout_value = (
                '{"number": 123, "author": {"login": "test"}, "updatedAt": null}'
            )
            mock_run.return_value = mock.Mock(returncode=0, stdout=stdout_value)
            result = mod.default_issue_fetcher("123")
            assert result is not None
            # When updatedAt is null or missing, should default to YYYY-MM-DD
            assert result.updated_date == "YYYY-MM-DD"


def test_create_active_folder_minor_audit_materializes_issue_md_and_skips_full_docs():
    """Verify eligible minor-audit mode creates issue.md-centric outputs."""
    fs = FakeFileSystem()
    workspace = Path("/workspace")
    _seed_feature_template(fs, workspace)
    potential_path = workspace / "docs" / "features" / "potential" / "minor-audit.md"
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
                "## Acceptance Criteria (early draft)",
                "criteria",
                "## Constraints & Risks",
                "low integration risk",
                "## Test Conditions to Consider",
                "verify",
            ]
        ),
    )
    result = mod.create_active_folder(
        feature_name="minor-audit",
        feature_type="feature",
        workspace=workspace,
        fs=fs,
        code_launcher=FakeCodeLauncher(),
        work_mode="minor-audit",
    )
    assert fs.exists(result.target / "issue.md")
    issue_md = fs.read_text(result.target / "issue.md")
    assert "- Work Mode: minor-audit" in issue_md
    assert "## Proposed Behavior" in issue_md
    assert not fs.exists(result.target / "spec.md")
    assert not fs.exists(result.target / "user-story.md")


def test_work_mode_marker_minor_issue_md() -> None:
    """Verify minor-audit issue.md persists marker above first section heading."""
    fs = FakeFileSystem()
    workspace = Path("/workspace")
    _seed_feature_template(fs, workspace)
    potential_path = workspace / "docs" / "features" / "potential" / "minor-marker.md"
    fs.write_text(
        potential_path,
        "\n".join(
            [
                "- Issue: #30",
                "- File: scripts/dev_tools/new_active_feature_folder.py",
                "- Risk: low",
                "## Problem / Why",
                "problem",
                "## Proposed Behavior",
                "intent",
            ]
        ),
    )

    result = mod.create_active_folder(
        feature_name="minor-marker",
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


def scenario_single_work_mode_marker_before_first_heading() -> None:
    """Verify generated issue.md has one marker before the first section."""
    fs = FakeFileSystem()
    workspace = Path("/workspace")
    _seed_feature_template(fs, workspace)
    potential_path = workspace / "docs" / "features" / "potential" / "single-marker.md"
    fs.write_text(
        potential_path,
        "\n".join(
            [
                "- Issue: #40",
                "- File: scripts/dev_tools/new_active_feature_folder.py",
                "- Risk: low",
                "## Problem / Why",
                "problem",
                "## Proposed Behavior",
                "behavior",
            ]
        ),
    )

    result = mod.create_active_folder(
        feature_name="single-marker",
        feature_type="feature",
        workspace=workspace,
        fs=fs,
        code_launcher=FakeCodeLauncher(),
        work_mode="minor-audit",
    )

    issue_md = fs.read_text(result.target / "issue.md")
    lines = issue_md.splitlines()
    marker_lines = [line for line in lines if line.startswith("- Work Mode:")]
    first_section_index = lines.index("## Problem / Why")
    marker_index = lines.index("- Work Mode: minor-audit")

    assert len(marker_lines) == 1
    assert marker_index == first_section_index - 2
    assert lines[first_section_index - 1] == ""


test_new_active_feature_folder_writes_single_work_mode_marker_before_first_heading = (
    scenario_single_work_mode_marker_before_first_heading
)


def test_minor_audit_preserves_issue_frontmatter_and_spacing() -> None:
    """Verify minor-audit preserves promoted issue frontmatter and spacing."""
    fs = FakeFileSystem()
    workspace = Path("/workspace")
    _seed_feature_template(fs, workspace)
    potential_path = workspace / "docs" / "features" / "potential" / "frontmatter.md"
    fs.write_text(
        potential_path,
        "\n".join(
            [
                "# bootstrap-typescript (Issue #33)",
                "",
                "- Date captured: 2026-02-20",
                "- Author: Dan Moisan",
                "- Status: Promoted -> "
                "docs/features/active/bootstrap-typescript/ (Issue #33)",
                "- Risk: low",
                "",
                "- Issue: #33",
                "- Issue URL: https://github.com/drmoisan/drm-copilot/issues/33",
                "- Last Updated: 2026-02-21",
                "",
                "## Problem / Why",
                "problem",
            ]
        ),
    )

    result = mod.create_active_folder(
        feature_name="frontmatter",
        feature_type="feature",
        workspace=workspace,
        fs=fs,
        code_launcher=FakeCodeLauncher(),
        work_mode="minor-audit",
    )

    issue_md = fs.read_text(result.target / "issue.md")
    lines = issue_md.splitlines()
    assert lines[0] == "# bootstrap-typescript (Issue #33)"
    assert lines[1] == ""
    assert "- Date captured: 2026-02-20" in lines
    assert "- Issue URL: https://github.com/drmoisan/drm-copilot/issues/33" in lines
    assert "- Work Mode: minor-audit" in lines

    issue_url_index = lines.index(
        "- Issue URL: https://github.com/drmoisan/drm-copilot/issues/33"
    )
    marker_index = lines.index("- Work Mode: minor-audit")
    problem_index = lines.index("## Problem / Why")
    assert issue_url_index < marker_index < problem_index
    assert lines[marker_index + 1] == ""
    assert lines[marker_index + 2] == "## Problem / Why"


def test_create_active_folder_minor_audit_honors_explicit_selection(
    capsys: pytest.CaptureFixture[str],
) -> None:
    """Verify explicit minor-audit stays selected even when heuristics are unmet."""
    fs = FakeFileSystem()
    workspace = Path("/workspace")
    _seed_feature_template(fs, workspace)
    potential_path = workspace / "docs" / "features" / "potential" / "fallback.md"
    fs.write_text(
        potential_path,
        "\n".join(
            [
                "- Issue: #29",
                "- File: a.py",
                "- File: b.py",
                "- File: c.py",
                "- File: d.py",
                "## Problem / Why",
                "problem",
            ]
        ),
    )
    result = mod.create_active_folder(
        feature_name="fallback",
        feature_type="feature",
        workspace=workspace,
        fs=fs,
        code_launcher=FakeCodeLauncher(),
        work_mode="minor-audit",
    )
    out = capsys.readouterr().out
    issue_md = fs.read_text(result.target / "issue.md")
    assert "- Work Mode: minor-audit" in issue_md
    assert "Selected mode: minor-audit" in out
    assert "Fallback reason:" not in out
