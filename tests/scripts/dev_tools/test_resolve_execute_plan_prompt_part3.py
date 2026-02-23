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

from pathlib import Path
from typing import TYPE_CHECKING

from scripts.dev_tools.atomic_executor.plan_discovery import ResolvedPlan
from scripts.dev_tools.atomic_executor.plan_parser import PlanTask
from scripts.dev_tools.atomic_executor.prompt_builder import PromptBuilder

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


def test_prompt_excludes_copilot_instructions_content() -> None:
    """PromptBuilder output should not inline copilot instruction labels."""
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

    assert "copilot-instructions.md" not in prompt


def test_prompt_size_under_threshold() -> None:
    """PromptBuilder output should stay within the 15KB threshold."""
    workspace = Path("/workspace")
    template_path = workspace / "template.md"
    feature_dir = workspace / "docs" / "features" / "active" / "my-feature"
    plan_path = feature_dir / "plan.md"
    spec_path = feature_dir / "spec.md"
    instructions_dir = workspace / ".github" / "instructions"
    copilot_instructions = workspace / ".github" / "copilot-instructions.md"

    large_instructions = "A" * 16000
    fs = InMemoryPromptBuilderFileSystem(
        files={
            template_path.as_posix(): "BASE TEMPLATE\n",
            plan_path.as_posix(): "# Plan\n- [ ] [P0-T1] Task",
            spec_path.as_posix(): "# Specification\n",
            copilot_instructions.as_posix(): large_instructions,
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

    assert len(prompt.encode("utf-8")) < 15_000
