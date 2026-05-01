"""Tests for resolve_execute_plan_prompt helper.

Purpose:
    Tests the script that resolves execute-plan prompt templates by
    substituting variables like ${file}, ${name}, ${spec}, ${research},
    and ${user-story}.

This module tests:
    - Variable extraction and replacement functions
    - Path resolution helpers
    - User story section removal when missing
    - CLI argument parsing
    - Main function with various scenarios
"""

from __future__ import annotations

import subprocess
import sys
from pathlib import Path
from typing import TYPE_CHECKING, cast
from unittest.mock import Mock, patch

import pytest

from scripts.dev_tools import resolve_execute_plan_prompt as module
from scripts.dev_tools.atomic_executor.plan_discovery import ResolvedPlan

if TYPE_CHECKING:
    from collections.abc import Callable

FIXTURE_ROOT = (
    Path(__file__).resolve().parent.parent.parent
    / "fixtures"
    / "resolve_execute_plan_prompt"
)


def make_plan_resolver(
    plan_filename: str = "plan.md",
) -> Callable[[Path], ResolvedPlan]:
    """Create a plan resolver that points to a plan file in the feature directory.

    Args:
        plan_filename (str): Name of the plan file to resolve.

    Returns:
        Callable[[Path], ResolvedPlan]: Resolver that maps feature directories
            to a ResolvedPlan pointing at the specified plan file.
    """

    def resolve(feature_dir: Path) -> ResolvedPlan:
        """Resolve a plan path within a feature directory.

        Args:
            feature_dir (Path): Feature directory containing the plan.

        Returns:
            ResolvedPlan: Resolved plan metadata for the feature directory.
        """
        return ResolvedPlan(
            path=feature_dir / plan_filename,
            display_label=plan_filename,
            update_filename=plan_filename,
        )

    return resolve


class InMemoryPromptBuilderFileSystem:
    """In-memory filesystem for PromptBuilder tests.

    Purpose:
        Enables prompt builder testing without touching disk, complying with
        the repository policy that forbids temporary files in tests.

    Attributes:
        files (dict[str, str]): Map of POSIX path strings to file content.
        dirs (set[str]): Set of POSIX path strings representing directories.
    """

    def __init__(
        self,
        files: dict[str, str] | None = None,
        dirs: set[str] | None = None,
    ) -> None:
        """Initialize the in-memory filesystem with files and directories.

        Args:
            files (dict[str, str] | None): Optional file content map.
            dirs (set[str] | None): Optional directory set.
        """
        self.files = files or {}
        self.dirs = dirs or set()

    def is_file(self, path: Path) -> bool:
        """Check if a path exists as a file.

        Args:
            path (Path): Path to check.

        Returns:
            bool: True when the path exists in the file map.
        """
        return path.as_posix() in self.files

    def is_dir(self, path: Path) -> bool:
        """Check if a path exists as a directory.

        Args:
            path (Path): Path to check.

        Returns:
            bool: True when the path exists in the directory set.
        """
        return path.as_posix() in self.dirs

    def read_text(self, path: Path) -> str:
        """Read a file from the in-memory store.

        Args:
            path (Path): File path to read.

        Returns:
            str: File contents.

        Raises:
            FileNotFoundError: If the path is missing from the file map.
        """
        key = path.as_posix()
        if key not in self.files:
            raise FileNotFoundError(f"File not found: {path}")
        return self.files[key]

    def glob(self, directory: Path, pattern: str) -> list[Path]:
        """Find files matching a glob pattern beneath a directory.

        Args:
            directory (Path): Base directory for the glob.
            pattern (str): Glob pattern to match.

        Returns:
            list[Path]: Matching paths sorted in discovery order.
        """
        import fnmatch

        base = directory.as_posix()
        matches: list[Path] = []
        for file_path in self.files:
            if file_path.startswith(base + "/"):
                relative = file_path[len(base) + 1 :]
                if fnmatch.fnmatch(relative, pattern):
                    matches.append(Path(file_path))
        return matches


# =============================================================================
# Tests for helper functions
# =============================================================================


def test_read_text() -> None:
    """Test read_text reads file content."""
    mock_path = Mock(spec=Path)
    mock_path.read_text.return_value = "file contents"

    result = module.read_text(mock_path)

    assert result == "file contents"
    mock_path.read_text.assert_called_once_with(encoding="utf-8")


def test_strip_front_matter_with_front_matter() -> None:
    """Test strip_front_matter removes YAML front matter."""
    content = "---\nkey: value\n---\n\nActual content"
    result = module.strip_front_matter(content)
    assert result == "Actual content"


def test_strip_front_matter_without_front_matter() -> None:
    """Test strip_front_matter returns content unchanged when no front matter."""
    content = "Just content"
    result = module.strip_front_matter(content)
    assert result == "Just content"


def test_split_path_platform_agnostic_forward_slash() -> None:
    """Test _split_path_platform_agnostic with forward slashes."""
    # Test private helper
    result = module._split_path_platform_agnostic(  # type: ignore[reportPrivateUsage]
        "docs/features/active/my-feature"
    )
    assert result == ["docs", "features", "active", "my-feature"]


def test_split_path_platform_agnostic_backslash() -> None:
    """Test _split_path_platform_agnostic with backslashes."""
    # Test private helper
    result = module._split_path_platform_agnostic(  # type: ignore[reportPrivateUsage]
        r"docs\features\active\my-feature"
    )
    assert result == ["docs", "features", "active", "my-feature"]


def test_split_path_platform_agnostic_mixed() -> None:
    """Test _split_path_platform_agnostic with mixed separators."""
    # Test private helper
    result = module._split_path_platform_agnostic(  # type: ignore[reportPrivateUsage]
        r"docs/features\active/my-feature"
    )
    assert result == ["docs", "features", "active", "my-feature"]


def test_resolve_folderpath() -> None:
    """Test _resolve_folderpath extracts parent folder."""
    workspace = Path("/workspace")
    target = Path("/workspace/docs/features/active/my-feature/plan.md")
    # Test private helper
    result = module._resolve_folderpath(  # type: ignore[reportPrivateUsage]
        target, workspace
    )
    assert result == "docs/features/active/my-feature"


def test_resolve_feature_foldername_standard() -> None:
    """Test _resolve_feature_foldername with standard path."""
    # Test private helper
    result = module._resolve_feature_foldername(  # type: ignore[reportPrivateUsage]
        "docs/features/active/my-feature"
    )
    assert result == "my-feature"


def test_resolve_feature_foldername_versioned() -> None:
    """Test _resolve_feature_foldername with versioned plan folder."""
    # Test private helper
    result = module._resolve_feature_foldername(  # type: ignore[reportPrivateUsage]
        "docs/features/active/my-feature/v2"
    )
    assert result == "my-feature"


def test_resolve_feature_foldername_empty_raises() -> None:
    """Test _resolve_feature_foldername raises on empty path."""
    with pytest.raises(ValueError, match="empty"):
        # Test private helper
        module._resolve_feature_foldername("")  # type: ignore[reportPrivateUsage]


def test_resolve_name_from_feature_foldername_dated() -> None:
    """Test _resolve_name_from_feature_foldername with dated convention."""
    # Test private helper
    result = module._resolve_name_from_feature_foldername(  # type: ignore[reportPrivateUsage]
        "2025-12-18-docs-v3-upgrade-42"
    )
    assert result == "docs-v3-upgrade"


def test_resolve_name_from_feature_foldername_no_date() -> None:
    """Test _resolve_name_from_feature_foldername without date convention."""
    # Test private helper
    result = module._resolve_name_from_feature_foldername(  # type: ignore[reportPrivateUsage]
        "my-feature"
    )
    assert result == "my-feature"


def test_resolve_name_from_feature_foldername_short() -> None:
    """Test _resolve_name_from_feature_foldername with too few parts."""
    # Test private helper
    result = module._resolve_name_from_feature_foldername(  # type: ignore[reportPrivateUsage]
        "2025-12-18"
    )
    assert result == "2025-12-18"


def test_resolve_spec_path() -> None:
    """Test _resolve_spec_path builds correct path."""
    # Test private helper
    result = module._resolve_spec_path(  # type: ignore[reportPrivateUsage]
        "docs/features/active/my-feature"
    )
    assert result == "docs/features/active/my-feature/spec.md"


def test_resolve_research_value_missing() -> None:
    """Test _resolve_research_value when file does not exist."""
    workspace = FIXTURE_ROOT
    # Use a non-existent folder to test missing research.md
    folderpath = "docs/features/active/nonexistent-feature"
    # Test private helper
    result = module._resolve_research_value(  # type: ignore[reportPrivateUsage]
        folderpath, workspace
    )
    assert "(missing)" in result


def test_resolve_user_story_value_missing() -> None:
    """Test _resolve_user_story_value when file does not exist."""
    workspace = FIXTURE_ROOT
    # Use the -alt folder which does NOT have user-story.md
    folderpath = "docs/features/active/2025-12-18-docs-v3-upgrade-alt"
    # Test private helper
    result = module._resolve_user_story_value(  # type: ignore[reportPrivateUsage]
        folderpath, workspace
    )
    assert "(missing)" in result


def test_remove_user_story_section_when_missing() -> None:
    """Test _remove_user_story_section_when_missing removes the section.

    Verifies that when the user story section is removed, a blank line
    is preserved to maintain proper spacing before the next section.
    """
    template = """3. **Research** (Implementation research):
   `${research}`
4. **User Story** (Requirements & Acceptance Criteria):
   `${user-story}`

## Task Execution
"""
    # Test private helper
    result = module._remove_user_story_section_when_missing(  # type: ignore[reportPrivateUsage]
        template
    )
    assert "4. **User Story**" not in result
    assert "${user-story}" not in result
    assert "3. **Research**" in result
    assert "## Task Execution" in result
    # Verify blank line is preserved between Research and Task Execution
    assert "`${research}`\n\n## Task Execution" in result


def test_remove_user_story_clause_when_missing() -> None:
    """Test _remove_user_story_clause_when_missing removes prose references."""
    template = "Review the Spec and User Story before starting."
    # Test private helper
    result = module._remove_user_story_clause_when_missing(  # type: ignore[reportPrivateUsage]
        template
    )
    assert "and User Story" not in result


def test_extract_template_variables() -> None:
    """Test _extract_template_variables finds all placeholders."""
    template = "File: ${file}\nName: ${name}\nSpec: ${spec}"
    # Test private helper
    result = module._extract_template_variables(  # type: ignore[reportPrivateUsage]
        template
    )
    assert result == {"file", "name", "spec"}


def test_replace_all_variables_success() -> None:
    """Test _replace_all_variables replaces all placeholders."""
    template = "File: ${file}, Name: ${name}"
    variables = {"file": "plan.md", "name": "my-feature"}
    # Test private helper
    result = module._replace_all_variables(  # type: ignore[reportPrivateUsage]
        template, variables
    )
    assert result == "File: plan.md, Name: my-feature"


def test_replace_all_variables_missing_raises() -> None:
    """Test _replace_all_variables raises on missing variables."""
    template = "File: ${file}, Name: ${name}"
    variables = {"file": "plan.md"}
    with pytest.raises(ValueError, match="Unresolved.*name"):
        # Test private helper
        module._replace_all_variables(  # type: ignore[reportPrivateUsage]
            template, variables
        )


# =============================================================================
# Tests for copy_to_clipboard
# =============================================================================


def test_copy_to_clipboard_with_pyperclip(monkeypatch: pytest.MonkeyPatch) -> None:
    """Test copy_to_clipboard uses pyperclip when available."""

    class DummyPyperclip:
        def __init__(self) -> None:
            self.copied: str | None = None

        def copy(self, text: str) -> None:
            """Copy text to mock clipboard."""
            self.copied = text

    dummy = DummyPyperclip()
    monkeypatch.setitem(sys.modules, "pyperclip", dummy)

    assert module.copy_to_clipboard("hello") is True


def test_copy_to_clipboard_without_clipboard(monkeypatch: pytest.MonkeyPatch) -> None:
    """Test copy_to_clipboard returns False when no mechanism available."""
    monkeypatch.setitem(sys.modules, "pyperclip", None)

    def _which(_name: str) -> str | None:
        return None

    monkeypatch.setattr(
        module.shutil, "which", cast("Callable[[str], str | None]", _which)
    )

    assert module.copy_to_clipboard("hello") is False


def test_copy_to_clipboard_pyperclip_error(monkeypatch: pytest.MonkeyPatch) -> None:
    """Test copy_to_clipboard falls back when pyperclip raises error."""

    class BrokenPyperclip:
        def copy(self, text: str) -> None:
            """Simulate clipboard failure."""
            raise RuntimeError("Clipboard unavailable")

    monkeypatch.setitem(sys.modules, "pyperclip", BrokenPyperclip())

    def _which(_name: str) -> str | None:
        return None

    monkeypatch.setattr(
        module.shutil, "which", cast("Callable[[str], str | None]", _which)
    )

    result = module.copy_to_clipboard("hello")
    assert result is False


def test_copy_to_clipboard_command_success(monkeypatch: pytest.MonkeyPatch) -> None:
    """Test copy_to_clipboard uses command when available."""
    monkeypatch.setitem(sys.modules, "pyperclip", None)

    def _which(name: str) -> str | None:
        return "/usr/bin/pbcopy" if name == "pbcopy" else None

    monkeypatch.setattr(
        module.shutil, "which", cast("Callable[[str], str | None]", _which)
    )

    with patch.object(
        module.subprocess,
        "run",
        return_value=Mock(returncode=0),
    ):
        result = module.copy_to_clipboard("hello")
        assert result is True


def test_copy_to_clipboard_command_failure(monkeypatch: pytest.MonkeyPatch) -> None:
    """Test copy_to_clipboard continues when command fails."""
    monkeypatch.setitem(sys.modules, "pyperclip", None)

    def _which(name: str) -> str | None:
        return "/usr/bin/pbcopy" if name == "pbcopy" else None

    monkeypatch.setattr(
        module.shutil, "which", cast("Callable[[str], str | None]", _which)
    )

    with patch.object(
        module.subprocess,
        "run",
        side_effect=subprocess.CalledProcessError(1, "pbcopy"),
    ):
        result = module.copy_to_clipboard("hello")
        assert result is False


# =============================================================================
# Tests for parse_args
# =============================================================================
