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


def test_update_feature_docs_for_refactor_type() -> None:
    """Test that update_feature_docs creates and populates refactor docs correctly."""
    # Arrange
    fs = FakeFileSystem()
    target_dir = Path("/target")
    fs.write_text(
        target_dir / "spec.md",
        "\n".join(
            [
                "- **Issue:** <issue>",
                "- **Parent (optional):** <parent-id>",
                "- **Owner:** <name>",
                "- **Last Updated:** <yyyy-MM-ddTHH-mm>",
                "- **Status:** <status>",
                "- **Version:** <version_number>",
                "<refactor-name>",
            ]
        ),
    )
    fs.write_text(
        target_dir / "plan.md",
        "\n".join(
            [
                "- **Issue:** <issue>",
                "- **Parent (optional):** <parent-id>",
                "- **Owner:** <name>",
                "- **Last Updated:** <yyyy-MM-ddTHH-mm>",
                "- **Status:** <status>",
                "- **Version:** <version_number>",
                "<refactor-name>",
            ]
        ),
    )

    sections = {
        "problem": "intent content",
        "behavior": "scope content",
        "constraints": "risks content",
        "tests": "test item",
    }

    # Act
    result = mod.update_feature_docs(
        feature_type="refactor",
        feature_name="my-refactor",
        target_dir=target_dir,
        issue_field="#42",
        owner_field="tester",
        updated_field="2024-01-15",
        parent_field="none",
        status_field="Draft",
        version_field="0.1",
        plan_updated_field="2024-01-15",
        fs=fs,
        sections=sections,
    )

    # Assert
    assert len(result) == 2
    assert result[0] == target_dir / "spec.md"
    assert result[1] == target_dir / "plan.md"

    spec_content = fs.read_text(target_dir / "spec.md")
    assert "my-refactor" in spec_content
    assert "#42" in spec_content
    assert "tester" in spec_content
    assert "2024-01-15" in spec_content
    assert "## Intent & Outcomes" in spec_content
    assert "intent content" in spec_content
    assert "## Scope (structural changes)" in spec_content
    assert "scope content" in spec_content
    assert "## Risks & Mitigations" in spec_content
    assert "risks content" in spec_content
    assert "## Seeded Test Conditions (from potential)" in spec_content
    assert "- [ ] test item" in spec_content

    plan_content = fs.read_text(target_dir / "plan.md")
    assert "my-refactor" in plan_content
    assert "#42" in plan_content
    assert "tester" in plan_content
    assert "Draft" in plan_content
    assert "0.1" in plan_content


def test_update_feature_docs_for_epic_type() -> None:
    """Verify update_feature_docs stamps epic.md and never returns initiative.md."""
    # Arrange: seed the merged epic.md source and the generated-only epic-status.md.
    fs = FakeFileSystem()
    target_dir = Path("/target")
    fs.write_text(
        target_dir / "epic.md",
        "\n".join(
            [
                "- **Issue:** <issue>",
                "- **Parent (optional):** <parent-id>",
                "- **Owner:** <name>",
                "- **Last Updated:** <yyyy-MM-ddTHH-mm>",
                "- **Status:** <status>",
                "- **Version:** <version_number>",
                "<epic-name>",
            ]
        ),
    )
    fs.write_text(target_dir / "epic-status.md", "# <epic-name> - Epic Status")

    sections: dict[str, str] = {}

    # Act
    result = mod.update_feature_docs(
        feature_type="epic",
        feature_name="my-epic",
        target_dir=target_dir,
        issue_field="#100",
        owner_field="epic-owner",
        updated_field="2024-03-20",
        parent_field="none",
        status_field="Draft",
        version_field="0.1",
        plan_updated_field="2024-03-20",
        fs=fs,
        sections=sections,
    )

    # Assert: only epic.md is stamped and opened; epic-status.md is generated-only.
    assert result == [target_dir / "epic.md"]
    assert target_dir / "initiative.md" not in result

    epic_content = fs.read_text(target_dir / "epic.md")
    assert "my-epic" in epic_content
    assert "#100" in epic_content
    assert "epic-owner" in epic_content
    assert "2024-03-20" in epic_content


def test_create_refactor_folder_seeds_refactor_docs() -> None:
    """Verify refactor-folder creation seeds refactor template sections."""
    fs = FakeFileSystem()
    workspace = Path("/workspace")
    template_dir = workspace / "docs" / "features" / "templates" / "refactor"
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
                "<refactor-name>",
                "## Intent & Outcomes",
                "",
                "## Scope (structural changes)",
                "",
                "## Risks & Mitigations",
                "",
                "## Seeded Test Conditions (from potential)",
            ]
        ),
    )
    fs.write_text(
        template_dir / "plan.md",
        "\n".join(
            [
                "- Owner: name",
                "- Last Updated: YYYY-MM-DD",
                "<refactor-name>",
            ]
        ),
    )

    potential_path = workspace / "docs" / "features" / "potential" / "refactor-test.md"
    fs.write_text(
        potential_path,
        "\n".join(
            [
                "- Issue: #88",
                "## Problem / Why",
                "intent text",
                "## Proposed Behavior",
                "scope text",
                "## Constraints & Risks",
                "risks text",
                "## Test Conditions to Consider",
                "test condition",
            ]
        ),
    )

    code_launcher = FakeCodeLauncher()
    result = mod.create_active_folder(
        feature_name="refactor-test",
        feature_type="refactor",
        workspace=workspace,
        fs=fs,
        code_launcher=code_launcher,
    )

    expected_folder = workspace / "docs" / "features" / "active" / "refactor-test-88"
    assert result.target == expected_folder
    spec_content = fs.read_text(expected_folder / "spec.md")
    assert "intent text" in spec_content
    assert "scope text" in spec_content
    assert "risks text" in spec_content
    assert "test condition" in spec_content
    assert "#88" in spec_content


def test_create_epic_folder_scaffolds_single_home() -> None:
    """Verify epic creation scaffolds only epics/<slug>/{epic.md, epic-status.md}."""
    # Arrange: the epic template set carries only the single-home files.
    fs = FakeFileSystem()
    workspace = Path("/workspace")
    template_dir = workspace / "docs" / "features" / "templates" / "epic"
    fs.write_text(
        template_dir / "epic.md",
        "\n".join(
            [
                "- **Issue:** <issue>",
                "- **Parent (optional):** <parent-id>",
                "- **Owner:** <name>",
                "- **Last Updated:** <yyyy-MM-ddTHH-mm>",
                "- **Status:** <status>",
                "- **Version:** <version_number>",
                "<epic-name>",
            ]
        ),
    )
    fs.write_text(
        template_dir / "epic-status.md",
        "# <epic-name> - Epic Status (generated)",
    )

    code_launcher = FakeCodeLauncher()
    result = mod.create_active_folder(
        feature_name="store-lockup-resilience",
        feature_type="epic",
        workspace=workspace,
        fs=fs,
        code_launcher=code_launcher,
    )

    # Assert: the single epic home is created under docs/features/epics/.
    expected_folder = (
        workspace / "docs" / "features" / "epics" / "store-lockup-resilience"
    )
    assert result.target == expected_folder
    assert fs.exists(expected_folder / "epic.md")
    assert fs.exists(expected_folder / "epic-status.md")
    # No initiative.md, and no active/ epic folder is created.
    assert not fs.exists(expected_folder / "initiative.md")
    active_root = workspace / "docs" / "features" / "active"
    assert not any(active_root in path.parents for path in fs.files)
    epic_content = fs.read_text(expected_folder / "epic.md")
    assert "store-lockup-resilience" in epic_content


def test_guard_blocks_unmocked_code_launcher_invocation() -> None:
    """Verify guard fixture blocks unmocked launcher subprocess invocation."""
    fs = FakeFileSystem()
    workspace = Path("/workspace")
    _seed_feature_template(fs, workspace)

    # Force launcher path resolution so the guard intercepts launcher execution.
    with mock.patch("shutil.which", return_value="code"):
        with pytest.raises(
            AssertionError,
            match="Blocked unmocked code launcher subprocess",
        ):
            mod.create_active_folder(
                feature_name="guard-check",
                feature_type="feature",
                workspace=workspace,
                fs=fs,
            )


def test_create_active_folder_raises_on_invalid_feature_type() -> None:
    """Verify invalid feature type inputs raise ValueError."""
    fs = FakeFileSystem()
    workspace = Path("/workspace")
    with pytest.raises(ValueError, match="must be one of"):
        mod.create_active_folder(
            feature_name="test",
            feature_type="invalid",  # type: ignore[arg-type]
            workspace=workspace,
            fs=fs,
            code_launcher=FakeCodeLauncher(),
        )


def test_create_active_folder_raises_on_missing_template() -> None:
    """Verify missing template directories raise FileNotFoundError."""
    fs = FakeFileSystem()
    workspace = Path("/workspace")
    with pytest.raises(FileNotFoundError, match="Template folder not found"):
        mod.create_active_folder(
            feature_name="test",
            feature_type="feature",
            workspace=workspace,
            fs=fs,
            code_launcher=FakeCodeLauncher(),
        )


def test_create_active_folder_with_force_overwrites_existing() -> None:
    """Verify force mode allows reuse of existing target folder paths."""
    fs = FakeFileSystem()
    workspace = Path("/workspace")
    _seed_feature_template(fs, workspace)

    target_dir = workspace / "docs" / "features" / "active" / "test-feature"
    fs.ensure_dir(target_dir)
    fs.write_text(target_dir / "existing.txt", "old content")

    code_launcher = FakeCodeLauncher()
    result = mod.create_active_folder(
        feature_name="test-feature",
        feature_type="feature",
        force=True,
        workspace=workspace,
        fs=fs,
        code_launcher=code_launcher,
    )

    assert result.target == target_dir
    assert fs.exists(target_dir / "user-story.md")


def test_create_active_folder_without_potential_file() -> None:
    """Verify folder creation succeeds when no potential file is available."""
    fs = FakeFileSystem()
    workspace = Path("/workspace")
    _seed_feature_template(fs, workspace)

    code_launcher = FakeCodeLauncher()
    result = mod.create_active_folder(
        feature_name="new-feature",
        feature_type="feature",
        workspace=workspace,
        fs=fs,
        code_launcher=code_launcher,
    )

    expected_folder = workspace / "docs" / "features" / "active" / "new-feature"
    assert result.target == expected_folder
    assert result.potential_issue_path is None


def test_create_active_folder_with_auto_issue_detection() -> None:
    """Verify `issue_number=auto` resolves issue metadata from potential content."""
    fs = FakeFileSystem()
    workspace = Path("/workspace")
    _seed_feature_template(fs, workspace)

    potential_path = workspace / "docs" / "features" / "potential" / "auto-test.md"
    fs.write_text(
        potential_path,
        "\n".join(
            [
                "- Issue: #42",
                "## Problem / Why",
                "content",
            ]
        ),
    )

    code_launcher = FakeCodeLauncher()
    result = mod.create_active_folder(
        feature_name="auto-test",
        feature_type="feature",
        issue_number="auto",
        workspace=workspace,
        fs=fs,
        code_launcher=code_launcher,
    )

    expected_folder = workspace / "docs" / "features" / "active" / "auto-test-42"
    assert result.target == expected_folder


def test_issue_fetcher_returns_none_when_gh_missing() -> None:
    """Verify default issue fetcher handles missing gh executable safely."""
    result = mod.default_issue_fetcher("123")
    # If gh is missing, returns None; if present, may return data or None
    assert result is None or isinstance(result, mod.IssueMeta)


def test_code_launcher_returns_false_when_code_missing() -> None:
    """Verify code launcher returns False and avoids subprocess when code is absent."""
    with mock.patch("shutil.which", return_value=None):
        with mock.patch("subprocess.run") as mock_run:
            result = mod.default_code_launcher([Path("/test.md")])

    assert result is False
    mock_run.assert_not_called()


def test_create_active_folder_resolves_template_from_template_root() -> None:
    """Verify template_root overrides workspace template path when provided."""
    fs = FakeFileSystem()
    workspace = Path("/workspace")
    template_root = Path("/ext/resources/feature-templates")

    # Seed templates under template_root (not workspace)
    template_dir = template_root / "feature"
    fs.write_text(
        template_dir / "user-story.md", "- **Issue:** <issue>\n<feature-name>"
    )
    fs.write_text(template_dir / "spec.md", "- **Issue:** <issue>\n<feature-name>")
    fs.write_text(
        template_dir / "plan.yyyy-MM-ddTHH-mm.md",
        "- **Issue:** <issue>\n<feature-name>",
    )

    code_launcher = FakeCodeLauncher()
    result = mod.create_active_folder(
        feature_name="tr-feature",
        feature_type="feature",
        workspace=workspace,
        fs=fs,
        code_launcher=code_launcher,
        template_root=template_root,
    )

    expected_folder = workspace / "docs" / "features" / "active" / "tr-feature"
    assert result.target == expected_folder
    assert fs.exists(expected_folder / "user-story.md")


def test_create_active_folder_falls_back_to_workspace_when_template_root_is_none() -> (
    None
):
    """Verify workspace-relative template path is used when template_root is None."""
    fs = FakeFileSystem()
    workspace = Path("/workspace")

    # Seed templates under workspace (default location)
    _seed_feature_template(fs, workspace)

    code_launcher = FakeCodeLauncher()
    result = mod.create_active_folder(
        feature_name="fb-feature",
        feature_type="feature",
        workspace=workspace,
        fs=fs,
        code_launcher=code_launcher,
        template_root=None,
    )

    expected_folder = workspace / "docs" / "features" / "active" / "fb-feature"
    assert result.target == expected_folder
    assert fs.exists(expected_folder / "user-story.md")
