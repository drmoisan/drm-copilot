"""Tests for the agent-memory scope parser and push-down scope filter."""

from __future__ import annotations

import importlib
from dataclasses import dataclass
from pathlib import Path


@dataclass
class MemoryFile:
    """Represent one in-memory text file for scope-filter tests."""

    content: str


class RecordingFileSystem:
    """Provide a deterministic in-memory filesystem for scope-filter tests."""

    def __init__(self, *, files: dict[Path, MemoryFile] | None = None) -> None:
        """Initialise with an optional pre-populated file mapping."""
        self.files: dict[Path, MemoryFile] = files or {}
        self.directories: set[Path] = set()

    def list_files(self, root: Path) -> list[Path]:
        """Return sorted file paths under the provided root."""

        # Collect every tracked file that lives under the requested root so the
        # publisher enumeration observes the same paths a real walk would yield.
        files: list[Path] = []
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


def _load_module():
    """Import the Claude customization push-down publisher under test."""

    return importlib.import_module("scripts.dev_tools.push_down_claude_customizations")


def test_read_memory_scope_returns_general_for_exact_general() -> None:
    """Return `general` only for an exact `metadata.scope: general` value."""

    module = _load_module()
    content = "---\nname: x\nmetadata:\n  type: feedback\n  scope: general\n---\nbody\n"

    assert module._read_memory_scope(content) == "general"


def test_read_memory_scope_returns_repo_for_exact_repo() -> None:
    """Return `repo` for an exact `metadata.scope: repo` value."""

    module = _load_module()
    content = "---\nname: x\nmetadata:\n  type: project\n  scope: repo\n---\nbody\n"

    assert module._read_memory_scope(content) == "repo"


def test_read_memory_scope_defaults_repo_when_scope_field_absent() -> None:
    """Return `repo` when frontmatter has a metadata block but no scope leaf."""

    module = _load_module()
    content = "---\nname: x\nmetadata:\n  type: feedback\n---\nbody\n"

    assert module._read_memory_scope(content) == "repo"


def test_read_memory_scope_defaults_repo_when_metadata_block_absent() -> None:
    """Return `repo` when frontmatter exists but carries no metadata block."""

    module = _load_module()
    content = "---\nname: x\ntype: feedback\n---\nbody\n"

    assert module._read_memory_scope(content) == "repo"


def test_read_memory_scope_defaults_repo_when_frontmatter_missing() -> None:
    """Return `repo` when the content has no leading frontmatter block."""

    module = _load_module()
    content = "# A plain markdown file\n\nNo frontmatter here.\n"

    assert module._read_memory_scope(content) == "repo"


def test_read_memory_scope_defaults_repo_for_malformed_frontmatter() -> None:
    """Return `repo` when the frontmatter has no closing `---` delimiter."""

    module = _load_module()
    content = "---\nname: x\nmetadata:\n  scope: general\nbody without close\n"

    assert module._read_memory_scope(content) == "repo"


def test_read_memory_scope_defaults_repo_for_unrecognized_value() -> None:
    """Return `repo` for any scope value other than exactly `general`."""

    module = _load_module()
    content = "---\nname: x\nmetadata:\n  scope: worldwide\n---\nbody\n"

    assert module._read_memory_scope(content) == "repo"


def _scope_filter_fs(scope_line: str | None, *, in_memory_subtree: bool = True):
    """Build a RecordingFileSystem holding one candidate memory-style file.

    Purpose:
        Provide a reusable in-memory tree for the push-down scope-filter tests
        so each scenario varies only the memory's scope frontmatter (or its
        location) without duplicating filesystem setup.

    Args:
        scope_line (str | None): The `scope:` value to embed in the file's
            metadata block, or None to omit the scope leaf entirely.
        in_memory_subtree (bool): When True the file is placed under
            `.claude/agent-memory/`; when False it is placed under
            `.claude/rules/` (outside the scope-filtered subtree).

    Returns:
        tuple: The module under test, the populated RecordingFileSystem, the
        repo root, the destination root, and the candidate file's path.

    Raises:
        None.

    Side Effects:
        None.
    """

    module = _load_module()
    repo_root = Path("C:/repo")
    destination_root = Path("C:/dest")
    # Compose frontmatter with or without the scope leaf to exercise each
    # include/exclude branch of the filter.
    if scope_line is None:
        body = "---\nname: m\nmetadata:\n  type: feedback\n---\nbody\n"
    else:
        body = (
            "---\nname: m\nmetadata:\n  type: feedback\n"
            f"  scope: {scope_line}\n---\nbody\n"
        )
    if in_memory_subtree:
        candidate = repo_root / ".claude" / "agent-memory" / "orchestrator" / "m.md"
    else:
        candidate = repo_root / ".claude" / "rules" / "m.md"
    fs = RecordingFileSystem(files={candidate: MemoryFile(body)})
    fs.directories.update(
        {repo_root, repo_root / ".claude", candidate.parent, destination_root}
    )
    return module, fs, repo_root, destination_root, candidate


def test_scope_filter_copies_general_memory() -> None:
    """A general-scoped agent memory is copied to the destination."""

    module, fs, repo_root, destination_root, candidate = _scope_filter_fs("general")

    summary = module.push_down_customizations(
        repo_root=repo_root,
        destination_root=destination_root,
        fs=fs,
        source_root=repo_root,
        artifact_root=destination_root,
    )

    relative = candidate.relative_to(repo_root).as_posix()
    relative_paths = [result.relative_path for result in summary.files]
    assert relative in relative_paths
    assert (destination_root / candidate.relative_to(repo_root)) in fs.files


def test_scope_filter_excludes_repo_memory() -> None:
    """A repo-scoped agent memory is excluded from the destination."""

    module, fs, repo_root, destination_root, candidate = _scope_filter_fs("repo")

    summary = module.push_down_customizations(
        repo_root=repo_root,
        destination_root=destination_root,
        fs=fs,
        source_root=repo_root,
        artifact_root=destination_root,
    )

    relative = candidate.relative_to(repo_root).as_posix()
    relative_paths = [result.relative_path for result in summary.files]
    assert relative not in relative_paths
    assert (destination_root / candidate.relative_to(repo_root)) not in fs.files


def test_scope_filter_excludes_unmarked_memory() -> None:
    """An unmarked agent memory is excluded via the fail-safe default."""

    module, fs, repo_root, destination_root, candidate = _scope_filter_fs(None)

    summary = module.push_down_customizations(
        repo_root=repo_root,
        destination_root=destination_root,
        fs=fs,
        source_root=repo_root,
        artifact_root=destination_root,
    )

    relative = candidate.relative_to(repo_root).as_posix()
    relative_paths = [result.relative_path for result in summary.files]
    assert relative not in relative_paths


def test_scope_filter_excludes_malformed_frontmatter_memory() -> None:
    """A malformed-frontmatter agent memory is excluded (fail-safe default)."""

    module = _load_module()
    repo_root = Path("C:/repo")
    destination_root = Path("C:/dest")
    # Frontmatter opens but never closes; the parser must fail safe to repo.
    candidate = repo_root / ".claude" / "agent-memory" / "orchestrator" / "m.md"
    fs = RecordingFileSystem(
        files={candidate: MemoryFile("---\nmetadata:\n  scope: general\nno close\n")}
    )
    fs.directories.update(
        {repo_root, repo_root / ".claude", candidate.parent, destination_root}
    )

    summary = module.push_down_customizations(
        repo_root=repo_root,
        destination_root=destination_root,
        fs=fs,
        source_root=repo_root,
        artifact_root=destination_root,
    )

    relative = candidate.relative_to(repo_root).as_posix()
    relative_paths = [result.relative_path for result in summary.files]
    assert relative not in relative_paths


def test_scope_filter_copies_non_memory_file_verbatim() -> None:
    """A file outside `.claude/agent-memory/` is copied and unaffected."""

    # The file carries `scope: repo`, but because it is outside the agent-memory
    # subtree the scope filter must not exclude it.
    module, fs, repo_root, destination_root, candidate = _scope_filter_fs(
        "repo", in_memory_subtree=False
    )

    summary = module.push_down_customizations(
        repo_root=repo_root,
        destination_root=destination_root,
        fs=fs,
        source_root=repo_root,
        artifact_root=destination_root,
    )

    relative = candidate.relative_to(repo_root).as_posix()
    relative_paths = [result.relative_path for result in summary.files]
    assert relative in relative_paths
    assert (destination_root / candidate.relative_to(repo_root)) in fs.files
