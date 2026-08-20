"""Tests for new_active_feature_folder Python implementation."""

from __future__ import annotations

from datetime import datetime
from pathlib import Path
from typing import TYPE_CHECKING
from zoneinfo import ZoneInfo

import pytest

from scripts.dev_tools import new_active_feature_folder as mod
from scripts.dev_tools import new_active_feature_folder_io as io_mod

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


def test_format_checklist_matches_expected_rules() -> None:
    """Verify checklist normalization preserves expected bullet formatting rules."""
    raw = "Item one\n- [ ] existing\n- bullet\n   \nItem two"
    result = mod.format_checklist(raw)
    lines = result.splitlines()
    assert lines[0] == "- [ ] Item one"
    assert "- [ ] existing" in lines
    assert "- bullet" in lines
    assert lines[-1] == "- [ ] Item two"


def test_set_section_replaces_and_appends() -> None:
    """Verify section replacement and append behavior for markdown helpers."""
    content = "## Header\nold\n"
    updated = mod.set_section(content, "Header", "new")
    assert "new" in updated and "old" not in updated
    appended = mod.set_section(updated, "Another", "body")
    assert "## Another" in appended
    assert "body" in appended


def test_set_header_placeholder_replaces_placeholders() -> None:
    """Verify header placeholder tokens are replaced with runtime metadata."""
    content = "\n".join(
        [
            "- **Issue:** <issue>",
            "- **Parent (optional):** <parent-id>",
            "- **Owner:** <name>",
            "- **Last Updated:** <yyyy-MM-ddTHH-mm>",
            "- **Status:** <status>",
            "- **Version:** <version_number>",
            "<feature-name>",
        ]
    )
    result = mod.set_header_placeholder(
        content,
        "example",
        "#123",
        "owner",
        "2024-01-01T00-00",
        status_field="Draft",
        parent_field="none",
        version_field="0.1",
    )
    assert "example" in result
    assert "#123" in result
    assert "owner" in result
    assert "2024-01-01T00-00" in result
    assert "Draft" in result
    assert "none" in result
    assert "0.1" in result


def test_set_header_placeholder_does_not_prepend_plain_issue_line() -> None:
    """Ensure bold Issue headers do not trigger the fallback prepend."""
    content = "\n".join(
        [
            "# <bug-name> (Spec)",
            "",
            "- **Issue:** <issue>",
            "- **Owner:** <name>",
            "- **Last Updated:** <yyyy-MM-ddTHH-mm>",
            "<bug-name>",
        ]
    )

    result = mod.set_header_placeholder(
        content,
        "example-bug",
        "#95",
        "drmoisan",
        "2026-01-20T16-15",
        status_field="Draft",
        parent_field="none",
        version_field="0.1",
    )

    assert result.splitlines()[0] == "# example-bug (Spec)"
    assert "- Issue: #95" not in result


def test_build_folder_slug_uses_potential_and_issue_number() -> None:
    """Verify slug generation prefers potential stem and appends issue number."""
    potential = Path("/w/docs/features/potential/promoted/2025-12-23-json-quality.md")
    slug = mod.build_folder_slug("json-quality", potential, "63")
    assert slug == "2025-12-23-json-quality-63"


class FakeIssueFetcher:
    """Callable fake for deterministic issue metadata fetch behavior."""

    def __init__(self, meta: mod.IssueMeta | None = None) -> None:
        """Initialize fake fetcher with optional metadata payload."""
        self.meta = meta
        self.calls: list[str] = []

    def __call__(self, issue_number: str) -> mod.IssueMeta | None:
        """Fetch mock issue metadata for testing."""
        self.calls.append(issue_number)
        return self.meta


class FakeCodeLauncher:
    """Callable fake that records editor-launch file requests."""

    def __init__(self) -> None:
        """Initialize fake launcher call tracking."""
        self.calls: list[list[Path]] = []

    def __call__(self, files: Iterable[Path]) -> bool:
        """Launch mock code editor for testing."""
        file_list = list(files)
        self.calls.append(file_list)
        return True


def _seed_feature_template(fs: FakeFileSystem, workspace: Path) -> None:
    """Seed in-memory feature templates used by active-folder tests."""
    template_dir = workspace / "docs" / "features" / "templates" / "feature"
    fs.write_text(
        template_dir / "user-story.md",
        "\n".join(
            [
                "- **Issue:** <issue>",
                "- **Parent (optional):** <parent-id>",
                "- **Owner:** <name>",
                "- **Last Updated:** <yyyy-MM-ddTHH-mm>",
                "- **Status:** <status>",
                "- **Version:** <version_number>",
                "<feature-name>",
                "## Problem / Why",
                "",
                "## Acceptance Criteria",
            ]
        ),
    )
    fs.write_text(
        template_dir / "spec.md",
        "\n".join(
            [
                "- **Issue:** <issue>",
                "- **Parent (optional):** <parent-id>",
                "- **Owner:** <name>",
                "- **Last Updated:** <yyyy-MM-ddTHH-mm>",
                "- **Status:** <status>",
                "- **Version:** <version_number>",
                "<feature-name>",
                "## Overview",
                "",
                "## Behavior",
                "",
                "## Constraints & Risks",
                "",
                "## Seeded Test Conditions (from potential)",
            ]
        ),
    )
    fs.write_text(
        template_dir / "plan.yyyy-MM-ddTHH-mm.md",
        "\n".join(
            [
                "- **Issue:** <issue>",
                "- **Parent (optional):** <parent-id>",
                "- **Owner:** <name>",
                "- **Last Updated:** <yyyy-MM-ddTHH-mm>",
                "- **Status:** <status>",
                "- **Version:** <version_number>",
                "<feature-name>",
            ]
        ),
    )


def _seed_bug_template(fs: FakeFileSystem, workspace: Path) -> None:
    """Seed in-memory bug templates used by bug-folder tests."""
    template_dir = workspace / "docs" / "features" / "templates" / "bug"
    fs.write_text(
        template_dir / "spec.md",
        "\n".join(
            [
                "- **Issue:** <issue>",
                "- **Parent (optional):** <parent-id>",
                "- **Owner:** <name>",
                "- **Last Updated:** <yyyy-MM-ddTHH-mm>",
                "- **Status:** <status>",
                "- **Version:** <version_number>",
                "<feature-name>",
                "## Context",
                "## Repro & Evidence",
                "## Root Cause Analysis",
                "## Proposed Fix",
                "## Test Strategy",
            ]
        ),
    )
    fs.write_text(
        template_dir / "plan.yyyy-MM-ddTHH-mm.md",
        "\n".join(
            [
                "- **Issue:** <issue>",
                "- **Parent (optional):** <parent-id>",
                "- **Owner:** <name>",
                "- **Last Updated:** <yyyy-MM-ddTHH-mm>",
                "- **Status:** <status>",
                "- **Version:** <version_number>",
                "<bug-name>",
            ]
        ),
    )


def test_create_feature_folder_retains_promoted_potential_and_updates_files() -> None:
    """Verify feature-folder creation moves potential file and updates docs."""
    fs = FakeFileSystem()
    workspace = Path("/workspace")
    _seed_feature_template(fs, workspace)

    potential_path = (
        workspace
        / "docs"
        / "features"
        / "potential"
        / "promoted"
        / "2025-12-23-json-quality.md"
    )
    fs.write_text(
        potential_path,
        "\n".join(
            [
                "- Issue: #63",
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
        ),
    )

    code_launcher = FakeCodeLauncher()
    fixed_now = datetime(2024, 1, 2, 3, 4, tzinfo=ZoneInfo("America/New_York"))
    result = mod.create_active_folder(
        feature_name="json-quality",
        feature_type="feature",
        workspace=workspace,
        fs=fs,
        code_launcher=code_launcher,
        now_provider=lambda: fixed_now,
    )

    expected_folder = (
        workspace / "docs" / "features" / "active" / "2025-12-23-json-quality-63"
    )
    assert result.target == expected_folder
    assert result.potential_issue_path == expected_folder / "issue.md"
    assert potential_path in fs.files
    assert fs.exists(expected_folder / "user-story.md")
    user_story = fs.read_text(expected_folder / "user-story.md")
    assert "problem text" in user_story
    assert "first item" in user_story
    assert "#63" in user_story

    plan_path = expected_folder / "plan.2024-01-02T03-04.md"
    assert fs.exists(plan_path)
    plan_content = fs.read_text(plan_path)
    assert "- **Issue:** #63" in plan_content
    assert "- **Parent (optional):** none" in plan_content
    assert "- **Status:** Draft" in plan_content
    assert "- **Version:** 0.1" in plan_content
    assert "- **Last Updated:** 2024-01-02T03-04" in plan_content
    assert code_launcher.calls, "code launcher should be invoked"


def test_create_bug_folder_uses_issue_metadata_and_sections() -> None:
    """Verify bug-folder creation uses fetched metadata and seeded sections."""
    fs = FakeFileSystem()
    workspace = Path("/workspace")
    _seed_bug_template(fs, workspace)

    potential_path = workspace / "docs" / "features" / "potential" / "bug-case.md"
    fs.write_text(
        potential_path,
        "\n".join(
            [
                "## Summary",
                "bug summary",
                "## Environment",
                "env",
                "## Steps to Reproduce",
                "step 1",
                "## Expected Behavior",
                "should work",
                "## Actual Behavior",
                "fails",
                "## Logs / Screenshots",
                "trace",
                "## Impact / Severity",
                "high",
                "## Suspected Cause / Notes",
                "root cause",
                "## Proposed Fix / Validation Ideas",
                "validate",
            ]
        ),
    )

    issue_meta = mod.IssueMeta(number="77", author="octocat", updated_date="2024-02-02")
    fetcher = FakeIssueFetcher(issue_meta)
    code_launcher = FakeCodeLauncher()
    fixed_now = datetime(2024, 2, 3, 4, 5, tzinfo=ZoneInfo("America/New_York"))

    result = mod.create_active_folder(
        feature_name="bug-case",
        feature_type="bug",
        issue_number="77",
        workspace=workspace,
        fs=fs,
        issue_fetcher=fetcher,
        code_launcher=code_launcher,
        now_provider=lambda: fixed_now,
    )

    expected_folder = workspace / "docs" / "features" / "active" / "bug-case-77"
    assert result.target == expected_folder
    spec_content = fs.read_text(expected_folder / "spec.md")
    assert "bug summary" in spec_content
    assert "step 1" in spec_content
    assert "Expected:\nshould work" in spec_content
    assert "Actual:\nfails" in spec_content
    assert "Logs / Screenshots:\ntrace" in spec_content
    assert "Root Cause Analysis" in spec_content
    assert "Proposed Fix" in spec_content
    assert "#77" in spec_content
    assert "octocat" in spec_content
    assert "2024-02-03T04-05" in spec_content
    assert fetcher.calls == ["77"]

    plan_path = expected_folder / "plan.2024-02-03T04-05.md"
    assert fs.exists(plan_path)
    plan_content = fs.read_text(plan_path)
    assert "- **Issue:** #77" in plan_content
    assert "- **Parent (optional):** none" in plan_content
    assert "- **Owner:** octocat" in plan_content
    assert "- **Last Updated:** 2024-02-03T04-05" in plan_content
    assert "- **Status:** Draft" in plan_content
    assert "- **Version:** 0.1" in plan_content
    assert code_launcher.calls, "code launcher should be invoked"


def test_validate_feature_name_rejects_invalid() -> None:
    """Verify invalid feature names raise ValueError."""
    with pytest.raises(ValueError):
        mod.validate_feature_name("INVALID")


def test_set_section_handles_empty_body() -> None:
    """Verify empty section bodies leave original markdown content unchanged."""
    content = "## Header\nold\n"
    result = mod.set_section(content, "Header", "")
    assert result == content


def test_find_potential_file_returns_none_when_no_match() -> None:
    """Verify no potential file is returned when no candidate matches."""
    fs = FakeFileSystem()
    workspace = Path("/workspace")
    result = mod.find_potential_file("nonexistent", workspace, fs)
    assert result is None


def test_parse_issue_number_returns_none_when_no_match() -> None:
    """Verify issue parsing returns None when no issue metadata line exists."""
    content = "Some content without issue"
    result = mod.parse_issue_number(content)
    assert result is None


def test_build_folder_slug_raises_on_invalid_slug() -> None:
    """Verify invalid derived slugs raise ValueError."""
    with pytest.raises(ValueError, match="invalid"):
        mod.build_folder_slug("name", Path("/some/INVALID-FILE.md"), None)


def test_default_code_launcher_uses_code_with_reuse_window(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """Use the standard VS Code CLI and reuse the current window when available."""
    launched: list[list[str]] = []

    def fake_run(cmd: list[str], check: bool) -> None:  # noqa: ARG001
        launched.append(cmd)

    def fake_which(name: str) -> str | None:
        if name == "code":
            return "/usr/bin/code"
        return None

    monkeypatch.setattr(io_mod.shutil, "which", fake_which)
    monkeypatch.setattr(io_mod.subprocess, "run", fake_run)
    monkeypatch.delenv("TERM_PROGRAM_VERSION", raising=False)
    monkeypatch.delenv("VSCODE_GIT_ASKPASS_MAIN", raising=False)
    monkeypatch.delenv("TERM_PROGRAM", raising=False)
    monkeypatch.delenv("VSCODE_IPC_HOOK_CLI", raising=False)

    assert mod.default_code_launcher([Path("file.md")]) is True
    assert launched == [["/usr/bin/code", "--reuse-window", "file.md"]]


def test_default_code_launcher_prefers_code_insiders_for_insiders_session(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """Prefer the Insiders CLI and reuse the current window when session signals it."""
    launched: list[list[str]] = []
    looked_up: list[str] = []

    def fake_run(cmd: list[str], check: bool) -> None:  # noqa: ARG001
        launched.append(cmd)

    def fake_which(name: str) -> str | None:
        looked_up.append(name)
        if name == "code-insiders":
            return "/usr/bin/code-insiders"
        if name == "code":
            return "/usr/bin/code"
        return None

    monkeypatch.setattr(io_mod.shutil, "which", fake_which)
    monkeypatch.setattr(io_mod.subprocess, "run", fake_run)
    monkeypatch.setenv("TERM_PROGRAM_VERSION", "1.110.0-insider")
    monkeypatch.delenv("VSCODE_GIT_ASKPASS_MAIN", raising=False)
    monkeypatch.delenv("TERM_PROGRAM", raising=False)
    monkeypatch.delenv("VSCODE_IPC_HOOK_CLI", raising=False)

    assert mod.default_code_launcher([Path("file.md")]) is True
    assert looked_up[0] == "code-insiders"
    assert launched == [["/usr/bin/code-insiders", "--reuse-window", "file.md"]]


def test_default_code_launcher_returns_false_when_no_cli_is_available(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """Return False after checking both standard CLI names when none are installed."""
    looked_up: list[str] = []

    def fake_which(name: str) -> None:
        looked_up.append(name)
        return None

    monkeypatch.setattr(io_mod.shutil, "which", fake_which)
    monkeypatch.delenv("TERM_PROGRAM_VERSION", raising=False)
    monkeypatch.delenv("VSCODE_GIT_ASKPASS_MAIN", raising=False)
    monkeypatch.delenv("TERM_PROGRAM", raising=False)
    monkeypatch.delenv("VSCODE_IPC_HOOK_CLI", raising=False)

    assert mod.default_code_launcher([Path("file.md")]) is False
    assert looked_up == ["code", "code-insiders"]
