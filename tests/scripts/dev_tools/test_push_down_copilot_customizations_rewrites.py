"""Tests for push_down_copilot_customizations_rewrites.py rewrite catalog correctness.

Purpose:
    Verify that the rewrite engine substitutes script references with their
    canonical VS Code command equivalents, normalizes path variants, and
    reports unmatched references correctly — all without touching the real
    filesystem.
"""

from __future__ import annotations

import importlib
from dataclasses import dataclass
from pathlib import Path


@dataclass
class MemoryFile:
    """Represent a text file stored in the in-memory push-down filesystem."""

    content: str


class InMemoryPushDownFileSystem:
    """
    Provide a deterministic in-memory filesystem for rewrite catalog tests.

    Purpose:
        Let the push-down publisher enumerate, read, and write files without
        touching the real filesystem so the test suite stays policy-compliant.

    Usage:
        Seed the file map with source or destination content, then pass the
        filesystem into the push-down module.

    Flow:
        The test double stores files in a dictionary keyed by absolute `Path`
        objects and tracks which directories were created during a run.

    Invariants / Constraints:
        Only UTF-8 text content is modeled because the rewrite tests operate
        exclusively on repository text files.

    Side Effects:
        Mutates in-memory dictionaries only.

    Attributes:
        files (dict[Path, MemoryFile]): File content keyed by path.
        directories (set[Path]): Directories created by the publisher.
    """

    def __init__(self, files: dict[Path, MemoryFile] | None = None) -> None:
        """
        Initialize the in-memory filesystem.

        Purpose:
            Seed the test double with an optional file set for arrange steps.

        Args:
            files (dict[Path, MemoryFile] | None): Optional initial file map.

        Returns:
            None.

        Raises:
            None.

        Side Effects:
            Stores the provided file map in memory.
        """
        self.files: dict[Path, MemoryFile] = files or {}
        self.directories: set[Path] = set()

    def list_files(self, root: Path) -> list[Path]:
        """
        Return all files under a root path in sorted order.

        Purpose:
            Mirror the enumeration behavior the real publisher uses when it
            walks the scoped `.github` roots.

        Args:
            root (Path): Root path to scan.

        Returns:
            list[Path]: Sorted in-memory file paths under the provided root.

        Raises:
            None.

        Side Effects:
            None.
        """
        files: list[Path] = []
        # Keep enumeration deterministic so red/green tests remain stable.
        for path in self.files:
            if self._is_under(path, root):
                files.append(path)
        return sorted(files)

    def is_dir(self, path: Path) -> bool:
        """
        Return whether the path is treated as a directory.

        Purpose:
            Support destination-root validation without using the real
            filesystem.

        Args:
            path (Path): Path to inspect.

        Returns:
            bool: True when the path was declared as a directory.

        Raises:
            None.

        Side Effects:
            None.
        """
        return path in self.directories

    def is_file(self, path: Path) -> bool:
        """
        Return whether the path is treated as a file.

        Purpose:
            Let the publisher classify destination writes as created or
            overwritten without accessing the real filesystem.

        Args:
            path (Path): Path to inspect.

        Returns:
            bool: True when the path exists in the in-memory file map.

        Raises:
            None.

        Side Effects:
            None.
        """
        return path in self.files

    def read_text(self, path: Path) -> str:
        """
        Return file content from the in-memory store.

        Purpose:
            Support rewrite and copy assertions in publisher tests.

        Args:
            path (Path): File path to read.

        Returns:
            str: Stored file content.

        Raises:
            FileNotFoundError: When the path has not been seeded.

        Side Effects:
            None.
        """
        if path not in self.files:
            raise FileNotFoundError(path)
        return self.files[path].content

    def write_text(self, path: Path, content: str) -> None:
        """
        Store file content in memory.

        Purpose:
            Let publisher tests verify created versus overwritten output.

        Args:
            path (Path): File path to write.
            content (str): Content to persist.

        Returns:
            None.

        Raises:
            None.

        Side Effects:
            Updates the in-memory file map and directory tracking.
        """
        self.files[path] = MemoryFile(content=content)
        self.directories.add(path.parent)

    def ensure_dir(self, path: Path) -> None:
        """
        Mark a directory as created.

        Purpose:
            Allow tests to set up the destination structure that the publisher
            expects before writing files.

        Args:
            path (Path): Directory path to mark.

        Returns:
            None.

        Raises:
            None.

        Side Effects:
            Mutates the tracked directory set.
        """
        self.directories.add(path)

    def _is_under(self, path: Path, root: Path) -> bool:
        """
        Return whether a path is inside a root directory.

        Purpose:
            Mirror `Path.relative_to` containment logic for the in-memory store.

        Args:
            path (Path): Candidate child path.
            root (Path): Candidate parent root.

        Returns:
            bool: True when `path` is inside `root`.

        Raises:
            None.

        Side Effects:
            None.
        """
        try:
            path.relative_to(root)
        except ValueError:
            return False
        return True


def test_rewrite_known_pr_context_reference_to_collect_pr_context_command() -> None:
    """Rewrite a verified PR-context script reference to the real extension command."""
    module = importlib.import_module(
        "scripts.dev_tools.push_down_copilot_customizations"
    )
    source_repo = Path("/source-repo")
    destination_repo = Path("/destination-repo")
    fs = InMemoryPushDownFileSystem()
    fs.ensure_dir(source_repo)
    fs.ensure_dir(destination_repo)
    prompt_path = source_repo / ".github/prompts/example.prompt.md"
    fs.ensure_dir(prompt_path.parent)
    fs.write_text(
        prompt_path,
        (
            "Run poetry run python -m "
            "scripts.dev_tools.pr_context.collector before review."
        ),
    )

    summary = module.push_down_customizations(
        repo_root=source_repo,
        destination_root=destination_repo,
        fs=fs,
    )

    rewritten_text = fs.read_text(
        destination_repo / ".github/prompts/example.prompt.md"
    )
    assert summary.rewritten_reference_count == 1
    assert "VS Code command: `drm-copilot: Collect PR Context`" in rewritten_text
    assert "command ID: `drmCopilotExtension.collectPrContext`" in rewritten_text
    assert "scripts.dev_tools.pr_context.collector" not in rewritten_text


def test_rewrite_new_active_feature_folder_reference_to_placeholder_command() -> None:
    """Rewrite uncovered feature-folder script references to the live command."""
    module = importlib.import_module(
        "scripts.dev_tools.push_down_copilot_customizations"
    )
    source_repo = Path("/source-repo")
    destination_repo = Path("/destination-repo")
    fs = InMemoryPushDownFileSystem()
    fs.ensure_dir(source_repo)
    fs.ensure_dir(destination_repo)
    instruction_path = source_repo / ".github/instructions/example.instructions.md"
    fs.ensure_dir(instruction_path.parent)
    fs.write_text(
        instruction_path,
        (
            "Use poetry run python -m "
            "scripts.dev_tools.new_active_feature_folder when creating the "
            "active feature folder."
        ),
    )

    summary = module.push_down_customizations(
        repo_root=source_repo,
        destination_root=destination_repo,
        fs=fs,
    )

    rewritten_text = fs.read_text(
        destination_repo / ".github/instructions/example.instructions.md"
    )
    assert summary.rewritten_reference_count == 1
    assert summary.placeholder_rewrite_count == 0
    assert "VS Code command: `drm-copilot: New Active Feature Folder`" in rewritten_text
    assert "command ID: `drmCopilotExtension.newActiveFeatureFolder`" in rewritten_text
    assert "scripts.dev_tools.new_active_feature_folder" not in rewritten_text


def test_rewrite_normalizes_dev_tools_slash_variants() -> None:
    """Normalize slash variants before rewriting to the live command catalog."""
    module = importlib.import_module(
        "scripts.dev_tools.push_down_copilot_customizations"
    )
    source_repo = Path("/source-repo")
    destination_repo = Path("/destination-repo")
    fs = InMemoryPushDownFileSystem()
    fs.ensure_dir(source_repo)
    fs.ensure_dir(destination_repo)
    prompt_path = source_repo / ".github/prompts/normalize.prompt.md"
    fs.ensure_dir(prompt_path.parent)
    fs.write_text(
        prompt_path,
        (
            "Run ${workspaceFolder}/scripts/dev_tools/new_potential_bug_entry.py "
            "and ${workspaceFolder}/scripts/dev-tools/new-potential-entry.ps1."
        ),
    )

    summary = module.push_down_customizations(
        repo_root=source_repo,
        destination_root=destination_repo,
        fs=fs,
    )

    rewritten_text = fs.read_text(
        destination_repo / ".github/prompts/normalize.prompt.md"
    )
    assert summary.rewritten_reference_count == 2
    assert summary.placeholder_rewrite_count == 0
    assert "command ID: `drmCopilotExtension.newPotentialBugEntry`" in rewritten_text
    assert "command ID: `drmCopilotExtension.newPotentialEntry`" in rewritten_text
    assert "scripts/dev_tools/new_potential_bug_entry.py" not in rewritten_text
    assert "scripts/dev-tools/new-potential-entry.ps1" not in rewritten_text


def test_push_down_reports_unmatched_script_references_without_rewrite() -> None:
    """Leave unknown script references untouched and report them in the summary."""
    module = importlib.import_module(
        "scripts.dev_tools.push_down_copilot_customizations"
    )
    source_repo = Path("/source-repo")
    destination_repo = Path("/destination-repo")
    fs = InMemoryPushDownFileSystem()
    fs.ensure_dir(source_repo)
    fs.ensure_dir(destination_repo)
    skill_path = source_repo / ".github/skills/example/SKILL.md"
    fs.ensure_dir(skill_path.parent)
    original_text = (
        "Run poetry run python -m "
        "scripts.dev_tools.unknown_future_tool before continuing."
    )
    fs.write_text(skill_path, original_text)

    summary = module.push_down_customizations(
        repo_root=source_repo,
        destination_root=destination_repo,
        fs=fs,
    )

    copied_text = fs.read_text(destination_repo / ".github/skills/example/SKILL.md")
    assert copied_text == original_text
    assert summary.unmatched_references == [
        "scripts.dev_tools.unknown_future_tool",
    ]


def test_rewrite_known_push_down_reference_to_real_command() -> None:
    """Rewrite the push-down publisher reference to the real extension command."""
    module = importlib.import_module(
        "scripts.dev_tools.push_down_copilot_customizations"
    )
    source_repo = Path("/source-repo")
    destination_repo = Path("/destination-repo")
    fs = InMemoryPushDownFileSystem()
    fs.ensure_dir(source_repo)
    fs.ensure_dir(destination_repo)
    prompt_path = source_repo / ".github/prompts/push-down.prompt.md"
    fs.ensure_dir(prompt_path.parent)
    fs.write_text(
        prompt_path,
        (
            "Run poetry run python -m "
            "scripts.dev_tools.push_down_copilot_customizations "
            "--destination <workspace-root> to push customizations."
        ),
    )

    summary = module.push_down_customizations(
        repo_root=source_repo,
        destination_root=destination_repo,
        fs=fs,
    )

    rewritten_text = fs.read_text(
        destination_repo / ".github/prompts/push-down.prompt.md"
    )
    assert summary.rewritten_reference_count >= 1
    assert (
        "VS Code command: `drm-copilot: Push Down Copilot Customizations`"
        in rewritten_text
    )
    assert (
        "command ID: `drmCopilotExtension.pushDownCopilotCustomizations`"
        in rewritten_text
    )
    assert "scripts.dev_tools.push_down_copilot_customizations" not in rewritten_text


def test_sync_agents_script_reference_rewrites_to_live_command() -> None:
    """Rewrite a sync-agents script reference to the live extension command."""
    module = importlib.import_module(
        "scripts.dev_tools.push_down_copilot_customizations"
    )
    source_repo = Path("/source-repo")
    destination_repo = Path("/destination-repo")
    fs = InMemoryPushDownFileSystem()
    fs.ensure_dir(source_repo)
    fs.ensure_dir(destination_repo)
    instruction_path = source_repo / ".github/instructions/agents.instructions.md"
    fs.ensure_dir(instruction_path.parent)
    fs.write_text(
        instruction_path,
        (
            "Run ${workspaceFolder}/scripts/dev-tools/"
            "sync-agents-from-instructions.ps1 "
            "to regenerate AGENTS.md."
        ),
    )

    summary = module.push_down_customizations(
        repo_root=source_repo,
        destination_root=destination_repo,
        fs=fs,
    )

    rewritten_text = fs.read_text(
        destination_repo / ".github/instructions/agents.instructions.md"
    )
    assert summary.rewritten_reference_count == 1
    assert summary.placeholder_rewrite_count == 0
    assert (
        "VS Code command: `drm-copilot: Sync AGENTS.md from Instructions`"
        in rewritten_text
    )
    assert (
        "command ID: `drmCopilotExtension.syncAgentsFromInstructions`" in rewritten_text
    )
    assert "sync-agents-from-instructions.ps1" not in rewritten_text
