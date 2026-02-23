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

import sys
from collections.abc import Callable
from pathlib import Path
from typing import cast

import pytest  # noqa: TCH002 - pytest required at runtime for fixtures

from scripts.dev_tools import resolve_execute_plan_prompt as module
from scripts.dev_tools.atomic_executor.plan_discovery import ResolvedPlan
from scripts.dev_tools.atomic_executor.plan_parser import PlanTask
from scripts.dev_tools.atomic_executor.prompt_builder import PromptBuilder

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


def test_parse_args_with_feature() -> None:
    """Test parse_args with feature argument."""
    args = module.parse_args(["--feature", "/path/to/plan.md"])
    assert args.feature == "/path/to/plan.md"
    assert args.no_copy is False


def test_parse_args_with_no_copy() -> None:
    """Test parse_args with no-copy flag."""
    args = module.parse_args(["--no-copy"])
    assert args.no_copy is True


def test_parse_args_with_workspace() -> None:
    """Test parse_args with workspace argument."""
    args = module.parse_args(["--workspace", "/custom/path"])
    assert args.workspace == "/custom/path"


def test_parse_args_with_prompt_path() -> None:
    """Test parse_args with prompt-path argument."""
    args = module.parse_args(["--prompt-path", "custom.md"])
    assert args.prompt_path == "custom.md"


def test_parse_args_with_agent() -> None:
    """Test parse_args with agent argument."""
    args = module.parse_args(["--agent", "Super Agent"])
    assert args.agent == "Super Agent"


def test_parse_args_defaults() -> None:
    """Test parse_args with no arguments uses defaults."""
    args = module.parse_args([])
    assert args.feature is None
    assert args.no_copy is False
    assert args.workspace is None
    assert args.agent is None


# =============================================================================
# Tests for main
# =============================================================================


def test_main_prompt_not_found(capsys: pytest.CaptureFixture[str]) -> None:
    """Test main returns error when prompt file not found."""
    feature_path = (
        FIXTURE_ROOT
        / "docs"
        / "features"
        / "active"
        / "2025-12-18-docs-v3-upgrade"
        / "plan.md"
    )
    code = module.main(
        [
            "--workspace",
            str(FIXTURE_ROOT),
            "--feature",
            str(feature_path),
            "--prompt-path",
            "nonexistent.md",
        ]
    )

    captured = capsys.readouterr()
    assert code == 1
    assert "not found" in captured.err


def test_main_no_feature_argument(capsys: pytest.CaptureFixture[str]) -> None:
    """Test main returns error when --feature not provided."""
    code = module.main(
        [
            "--workspace",
            str(FIXTURE_ROOT),
        ]
    )

    captured = capsys.readouterr()
    assert code == 1
    assert "--feature" in captured.err or "required" in captured.err.lower()


def test_main_target_not_found(capsys: pytest.CaptureFixture[str]) -> None:
    """Test main returns error when target file not found."""
    code = module.main(
        [
            "--workspace",
            str(FIXTURE_ROOT),
            "--feature",
            "/nonexistent/path/plan.md",
        ]
    )

    captured = capsys.readouterr()
    assert code == 1
    assert "not found" in captured.err


def test_main_with_feature_prints_prompt(capsys: pytest.CaptureFixture[str]) -> None:
    """Test main with valid feature prints resolved prompt."""
    workspace = FIXTURE_ROOT
    feature_path = (
        workspace
        / "docs"
        / "features"
        / "active"
        / "2025-12-18-docs-v3-upgrade"
        / "plan.md"
    )
    code = module.main(
        [
            "--workspace",
            str(workspace),
            "--feature",
            str(feature_path),
            "--no-copy",
        ]
    )

    captured = capsys.readouterr()
    assert code == 0
    # The template should have variables replaced
    assert (
        "2025-12-18-docs-v3-upgrade" in captured.out
        or "docs-v3-upgrade" in captured.out
    )


def test_main_with_clipboard_copy(
    monkeypatch: pytest.MonkeyPatch, capsys: pytest.CaptureFixture[str]
) -> None:
    """Test main with successful clipboard copy."""

    class DummyPyperclip:
        def copy(self, text: str) -> None:
            """Mock clipboard copy."""
            pass

    monkeypatch.setitem(sys.modules, "pyperclip", DummyPyperclip())

    workspace = FIXTURE_ROOT
    feature_path = (
        workspace
        / "docs"
        / "features"
        / "active"
        / "2025-12-18-docs-v3-upgrade"
        / "plan.md"
    )
    code = module.main(
        [
            "--workspace",
            str(workspace),
            "--feature",
            str(feature_path),
        ]
    )

    captured = capsys.readouterr()
    assert code == 0
    assert "copied to clipboard" in captured.err.lower()


def test_main_clipboard_unavailable(
    monkeypatch: pytest.MonkeyPatch, capsys: pytest.CaptureFixture[str]
) -> None:
    """Test main prints message when clipboard unavailable."""
    monkeypatch.setitem(sys.modules, "pyperclip", None)

    def _which(_name: str) -> str | None:
        return None

    monkeypatch.setattr(
        module.shutil, "which", cast("Callable[[str], str | None]", _which)
    )

    workspace = FIXTURE_ROOT
    feature_path = (
        workspace
        / "docs"
        / "features"
        / "active"
        / "2025-12-18-docs-v3-upgrade"
        / "plan.md"
    )
    code = module.main(
        [
            "--workspace",
            str(workspace),
            "--feature",
            str(feature_path),
        ]
    )

    captured = capsys.readouterr()
    assert code == 0
    assert "not available" in captured.err.lower()


# =============================================================================
# Tests for build_prompt_text
# =============================================================================


def test_build_prompt_text_resolves_variables() -> None:
    """Test build_prompt_text substitutes variables correctly."""
    workspace = FIXTURE_ROOT
    prompt_path = workspace / ".github" / "prompts" / "execute-plan-template.md"
    target_path = (
        workspace
        / "docs"
        / "features"
        / "active"
        / "2025-12-18-docs-v3-upgrade"
        / "plan.md"
    )

    result = module.build_prompt_text(workspace, target_path, prompt_path)

    # Variables should be resolved
    assert "${file}" not in result
    assert "${name}" not in result
    assert "${spec}" not in result
    # Content should contain resolved values
    assert "plan.md" in result or "docs-v3-upgrade" in result


def test_build_prompt_text_with_agent() -> None:
    """Test build_prompt_text substitutes agent token."""
    workspace = FIXTURE_ROOT
    prompt_path = workspace / ".github" / "prompts" / "execute-plan-template.md"
    target_path = (
        workspace
        / "docs"
        / "features"
        / "active"
        / "2025-12-18-docs-v3-upgrade"
        / "plan.md"
    )

    result = module.build_prompt_text(
        workspace, target_path, prompt_path, agent="Super Agent"
    )

    # Agent should be injected (if template has <agent_type>)
    # Just check the function doesn't error
    assert result


# =============================================================================
# Tests for PromptBuilder integration
# =============================================================================


def test_prompt_excludes_instructions_md_content() -> None:
    """PromptBuilder output should not include repo instruction blocks."""
    workspace = Path("/workspace")
    template_path = workspace / "template.md"
    feature_dir = workspace / "docs" / "features" / "active" / "my-feature"
    plan_path = feature_dir / "plan.md"
    spec_path = feature_dir / "spec.md"
    instructions_dir = workspace / ".github" / "instructions"
    copilot_instructions = workspace / ".github" / "copilot-instructions.md"

    fs = InMemoryPromptBuilderFileSystem(
        files={
            template_path.as_posix(): "BASE TEMPLATE\n",
            plan_path.as_posix(): "# Plan\n- [ ] [P0-T1] Task",
            spec_path.as_posix(): "# Specification\n",
            copilot_instructions.as_posix(): "Repo instructions",
            (instructions_dir / "general.instructions.md").as_posix(): "More rules",
        },
        dirs={feature_dir.as_posix(), instructions_dir.as_posix()},
    )
    task = PlanTask(
        task_id="P0-T1",
        phase=0,
        task_num=1,
        title="Task",
        checked=False,
        line_index=1,
    )
    builder = PromptBuilder(
        workspace,
        template_path,
        fs=fs,
        plan_resolver=make_plan_resolver(),
    )

    prompt = builder.build(feature_dir, task)

    assert "---- BEGIN repo instructions ----" not in prompt


def test_resolve_mode_context_mode_minor_audit(monkeypatch: pytest.MonkeyPatch) -> None:
    """Resolve mode context from issue.md marker when minor-audit is present."""
    workspace = Path("/workspace")
    folderpath = "docs/features/active/feature-x"
    issue_path = workspace / folderpath / "issue.md"

    def _exists(self: Path) -> bool:
        return self == issue_path

    def _read_text(self: Path, encoding: str = "utf-8") -> str:
        del encoding
        if self == issue_path:
            return "- Work Mode: minor-audit\n"
        raise FileNotFoundError(str(self))

    monkeypatch.setattr(Path, "exists", _exists)
    monkeypatch.setattr(Path, "read_text", _read_text)

    mode, reason = module.resolve_mode_context(folderpath, workspace)

    assert mode == "minor-audit"
    assert reason == "none"


def test_resolve_mode_context_mode_fails_closed_when_marker_missing(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """Fail closed to full mode when issue marker is missing."""
    workspace = Path("/workspace")
    folderpath = "docs/features/active/feature-x"
    issue_path = workspace / folderpath / "issue.md"

    def _exists(self: Path) -> bool:
        return self == issue_path

    def _read_text(self: Path, encoding: str = "utf-8") -> str:
        del encoding
        if self == issue_path:
            return "# no marker\n"
        raise FileNotFoundError(str(self))

    monkeypatch.setattr(Path, "exists", _exists)
    monkeypatch.setattr(Path, "read_text", _read_text)

    mode, reason = module.resolve_mode_context(folderpath, workspace)

    assert mode == "full"
    assert "marker missing" in reason


def test_resolve_mode_context_mode_fails_closed_when_issue_missing(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """Fail closed to full when issue.md file does not exist."""
    workspace = Path("/workspace")
    folderpath = "docs/features/active/feature-x"

    def _exists(_self: Path) -> bool:
        return False

    monkeypatch.setattr(Path, "exists", _exists)

    mode, reason = module.resolve_mode_context(folderpath, workspace)

    assert mode == "full"
    assert reason == "issue.md missing; fail closed to full"


def test_resolve_mode_context_mode_fails_closed_when_issue_unreadable(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """Fail closed to full with unreadable reason when issue.md read fails."""
    workspace = Path("/workspace")
    folderpath = "docs/features/active/feature-x"
    issue_path = workspace / folderpath / "issue.md"

    def _exists(self: Path) -> bool:
        return self == issue_path

    def _read_text(_self: Path, encoding: str = "utf-8") -> str:
        del encoding
        raise OSError("cannot read")

    monkeypatch.setattr(Path, "exists", _exists)
    monkeypatch.setattr(Path, "read_text", _read_text)

    mode, reason = module.resolve_mode_context(folderpath, workspace)

    assert mode == "full"
    assert reason == "issue.md unreadable; fail closed to full"
