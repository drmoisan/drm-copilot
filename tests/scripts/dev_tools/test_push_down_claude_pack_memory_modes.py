"""Tests for the three agent-memory modes in the `.claude` push-down.

These tests verify the `overwrite`, `skip`, and `merge` memory modes of
`scripts.dev_tools.push_down_claude_customizations.push_down_customizations`
using an in-memory filesystem double. No temporary files are created.
"""

from __future__ import annotations

import importlib
from dataclasses import dataclass
from pathlib import Path

GENERAL_MEMORY = (
    "---\nname: shared\nmetadata:\n  scope: general\n---\n# Shared memory\n"
)


@dataclass
class MemoryFile:
    """Represent one in-memory text file for publisher tests."""

    content: str


class RecordingFileSystem:
    """Provide a deterministic in-memory filesystem for publisher tests."""

    def __init__(self, *, files: dict[Path, MemoryFile] | None = None) -> None:
        """Initialise with an optional pre-populated file mapping."""
        self.files: dict[Path, MemoryFile] = files or {}
        self.directories: set[Path] = set()

    def list_files(self, root: Path) -> list[Path]:
        """Return sorted file paths under the provided root."""
        files: list[Path] = []
        # Collect every tracked file that lives beneath the requested root.
        for path in self.files:
            try:
                path.relative_to(root)
            except ValueError:
                continue
            files.append(path)
        return sorted(files)

    def is_dir(self, path: Path) -> bool:
        """Return whether the path is tracked as a directory."""
        return path in self.directories

    def is_file(self, path: Path) -> bool:
        """Return whether the path is tracked as a file."""
        return path in self.files

    def read_text(self, path: Path) -> str:
        """Return file content from the in-memory store."""
        return self.files[path].content

    def write_text(self, path: Path, content: str) -> None:
        """Persist file content in the in-memory store."""
        self.files[path] = MemoryFile(content=content)
        self.directories.add(path.parent)

    def ensure_dir(self, path: Path) -> None:
        """Track created directories."""
        self.directories.add(path)


def _entry_module():
    """Import the Claude customization push-down entry point under test."""
    return importlib.import_module("scripts.dev_tools.push_down_claude_customizations")


def _seed_memory_tree(
    fs: RecordingFileSystem,
    source_root: Path,
    dest: Path,
    *,
    dest_memory_exists: bool,
) -> None:
    """Seed a tree with one general-scoped agent memory and core settings."""
    fs.write_text(source_root / ".claude/settings.json", '{"core": true}\n')
    fs.write_text(source_root / ".claude/agent-memory/shared/MEMORY.md", GENERAL_MEMORY)
    if dest_memory_exists:
        # Pre-existing destination memory used by the merge-mode assertion.
        fs.write_text(
            dest / ".claude/agent-memory/shared/MEMORY.md", "# Existing dest memory\n"
        )
    fs.directories.update({source_root, dest})


def test_memory_mode_overwrite_writes_general_memory() -> None:
    """Verify overwrite mode publishes general-scoped memories."""
    module = _entry_module()
    source_root = Path("/repo")
    dest = Path("/dest")
    fs = RecordingFileSystem()
    _seed_memory_tree(fs, source_root, dest, dest_memory_exists=True)

    module.push_down_customizations(
        repo_root=source_root,
        destination_root=dest,
        fs=fs,
        source_root=source_root,
        artifact_root=dest,
        memory_mode="overwrite",
    )

    # Overwrite replaces the pre-existing destination memory with source content.
    assert (
        fs.read_text(dest / ".claude/agent-memory/shared/MEMORY.md") == GENERAL_MEMORY
    )


def test_memory_mode_skip_excludes_all_agent_memory() -> None:
    """Verify skip mode publishes no agent-memory file."""
    module = _entry_module()
    source_root = Path("/repo")
    dest = Path("/dest")
    fs = RecordingFileSystem()
    _seed_memory_tree(fs, source_root, dest, dest_memory_exists=False)

    module.push_down_customizations(
        repo_root=source_root,
        destination_root=dest,
        fs=fs,
        source_root=source_root,
        artifact_root=dest,
        memory_mode="skip",
    )

    # No agent-memory file is written; the non-memory settings file still is.
    assert dest / ".claude/agent-memory/shared/MEMORY.md" not in fs.files
    assert dest / ".claude/settings.json" in fs.files


def test_memory_mode_merge_preserves_existing_destination_memory() -> None:
    """Verify merge mode keeps a pre-existing destination memory untouched."""
    module = _entry_module()
    source_root = Path("/repo")
    dest = Path("/dest")
    fs = RecordingFileSystem()
    _seed_memory_tree(fs, source_root, dest, dest_memory_exists=True)

    module.push_down_customizations(
        repo_root=source_root,
        destination_root=dest,
        fs=fs,
        source_root=source_root,
        artifact_root=dest,
        memory_mode="merge",
    )

    # Merge must not overwrite the pre-existing destination memory.
    assert (
        fs.read_text(dest / ".claude/agent-memory/shared/MEMORY.md")
        == "# Existing dest memory\n"
    )


def test_memory_mode_merge_writes_absent_destination_memory() -> None:
    """Verify merge mode publishes a memory absent at the destination."""
    module = _entry_module()
    source_root = Path("/repo")
    dest = Path("/dest")
    fs = RecordingFileSystem()
    _seed_memory_tree(fs, source_root, dest, dest_memory_exists=False)

    module.push_down_customizations(
        repo_root=source_root,
        destination_root=dest,
        fs=fs,
        source_root=source_root,
        artifact_root=dest,
        memory_mode="merge",
    )

    # The new memory is written because no destination file existed.
    assert (
        fs.read_text(dest / ".claude/agent-memory/shared/MEMORY.md") == GENERAL_MEMORY
    )
