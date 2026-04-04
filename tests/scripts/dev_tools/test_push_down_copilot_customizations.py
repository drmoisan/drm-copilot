"""
Tests for the push-down Copilot customization publisher.

Purpose:
    Lock down the one-way publishing behavior for copied `.github` customization
    content without using temporary files or external processes.
"""

from __future__ import annotations

import importlib
from dataclasses import dataclass
from pathlib import Path

import pytest  # noqa: TCH002 - pytest required at runtime for test assertions


@dataclass
class MemoryFile:
    """Represent a text file stored in the in-memory push-down filesystem."""

    content: str


class InMemoryPushDownFileSystem:
    """
    Provide a deterministic in-memory filesystem for push-down tests.

    Purpose:
        Let the push-down publisher enumerate, read, and write files without
        touching the real filesystem so the test suite stays policy-compliant.

    Usage:
        Seed the file map with source or destination content, then pass the
        filesystem into the push-down module once it exists.

    Flow:
        The test double stores files in a dictionary keyed by absolute `Path`
        objects and tracks which directories were created during a run.

    Invariants / Constraints:
        Only UTF-8 text content is modeled because the first release tests focus
        on copied customization text.

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
            Mirror the enumeration behavior the real publisher will need when it
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
            Support rewrite and copy assertions in future publisher tests.

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
            Let future publisher tests verify created versus overwritten output.

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
            Allow tests to assert that the publisher created missing output
            directories before writing files.

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


def test_main_rejects_invalid_destination_before_copy() -> None:
    """Reject an unusable destination before any copy work begins."""
    module = importlib.import_module(
        "scripts.dev_tools.push_down_copilot_customizations"
    )
    source_repo = Path("/source-repo")
    fs = InMemoryPushDownFileSystem()
    fs.ensure_dir(source_repo)

    with pytest.raises(ValueError, match="destination"):
        module.main(
            ["--destination", str(source_repo)],
            repo_root=source_repo,
            fs=fs,
        )

    assert fs.files == {}


def _seed_scoped_source_files(
    fs: InMemoryPushDownFileSystem,
    *,
    repo_root: Path,
) -> None:
    """
    Seed one text file under each scoped `.github` root.

    Purpose:
        Give the copy scenarios a compact but representative source tree that
        exercises the deterministic root ordering required by the feature.

    Args:
        fs (InMemoryPushDownFileSystem): In-memory filesystem to populate.
        repo_root (Path): Source repository root.

    Returns:
        None.

    Raises:
        None.

    Side Effects:
        Adds source directories and files to the in-memory filesystem.
    """
    roots_to_files = {
        Path(".github/agents/example.agent.md"): "agent content",
        Path(".github/instructions/example.instructions.md"): "instruction content",
        Path(".github/prompts/example.prompt.md"): "prompt content",
        Path(".github/skills/example/SKILL.md"): "skill content",
    }

    # Seed each scoped root so copy tests cover the full push-down surface.
    for relative_path, content in roots_to_files.items():
        file_path = repo_root / relative_path
        fs.ensure_dir(file_path.parent)
        fs.write_text(file_path, content)


def test_push_down_copies_scoped_github_trees_to_empty_destination() -> None:
    """Copy every scoped `.github` tree into an empty destination workspace."""
    module = importlib.import_module(
        "scripts.dev_tools.push_down_copilot_customizations"
    )
    source_repo = Path("/source-repo")
    destination_repo = Path("/destination-repo")
    fs = InMemoryPushDownFileSystem()
    fs.ensure_dir(source_repo)
    fs.ensure_dir(destination_repo)
    _seed_scoped_source_files(fs, repo_root=source_repo)

    summary = module.push_down_customizations(
        repo_root=source_repo,
        destination_root=destination_repo,
        fs=fs,
    )

    assert summary.created_count == 4
    assert fs.read_text(destination_repo / ".github/agents/example.agent.md") == (
        "agent content"
    )
    assert (
        fs.read_text(destination_repo / ".github/instructions/example.instructions.md")
        == "instruction content"
    )
    assert fs.read_text(destination_repo / ".github/prompts/example.prompt.md") == (
        "prompt content"
    )
    assert fs.read_text(destination_repo / ".github/skills/example/SKILL.md") == (
        "skill content"
    )


def test_push_down_overwrites_existing_destination_file() -> None:
    """Overwrite a same-path destination file with the source-repo version."""
    module = importlib.import_module(
        "scripts.dev_tools.push_down_copilot_customizations"
    )
    source_repo = Path("/source-repo")
    destination_repo = Path("/destination-repo")
    fs = InMemoryPushDownFileSystem()
    fs.ensure_dir(source_repo)
    fs.ensure_dir(destination_repo)
    _seed_scoped_source_files(fs, repo_root=source_repo)
    fs.ensure_dir(destination_repo / ".github/agents")
    fs.write_text(
        destination_repo / ".github/agents/example.agent.md",
        "stale destination content",
    )

    summary = module.push_down_customizations(
        repo_root=source_repo,
        destination_root=destination_repo,
        fs=fs,
    )

    assert summary.overwritten_count == 1
    assert fs.read_text(destination_repo / ".github/agents/example.agent.md") == (
        "agent content"
    )
