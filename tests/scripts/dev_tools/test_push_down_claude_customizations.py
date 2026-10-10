"""Tests for the `.claude` customization push-down publisher."""

from __future__ import annotations

import importlib
import io
import json
from contextlib import redirect_stdout
from dataclasses import dataclass
from pathlib import Path
from typing import TYPE_CHECKING

import pytest

if TYPE_CHECKING:
    from collections.abc import Sequence
    from types import ModuleType

    from scripts.dev_tools.push_down_claude_blast_radius_derive import (
        DirectoryEntry,
    )
    from scripts.dev_tools.push_down_claude_exclusion_filter import (
        ClaudePushDownSummary,
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


def test_module_exposes_claude_root_folders_and_artifact_directory() -> None:
    """Verify the module-level constants match the Claude scope specification."""

    module = _load_module()

    assert module.ROOT_FOLDERS == (Path(".claude"), Path("config"))
    assert module.ARTIFACT_DIRECTORY == "artifacts/claude-customizations"
    assert (
        module.MODULE_ENTRY_POINT == "scripts.dev_tools.push_down_claude_customizations"
    )


def test_passthrough_rewrite_returns_text_unchanged() -> None:
    """Verify the passthrough rewrite helper returns original text with zero counts."""

    module = _load_module()

    result = module._passthrough_rewrite("anything")

    assert result == ("anything", 0, 0, [])


def test_push_down_customizations_copies_claude_tree_files() -> None:
    """Verify the publisher copies the full `.claude` tree byte-identically."""

    module = _load_module()
    repo_root = Path("/repo")
    destination_root = Path("/dest")
    # Populate a representative .claude tree matching the real layout.
    fs = RecordingFileSystem(
        files={
            repo_root
            / ".claude"
            / "agents"
            / "orchestrator.md": MemoryFile("# Orchestrator\n"),
            repo_root
            / ".claude"
            / "skills"
            / "sample"
            / "SKILL.md": MemoryFile("# Sample Skill\n"),
            repo_root
            / ".claude"
            / "rules"
            / "python.md": MemoryFile("# Python rules\n"),
            repo_root
            / ".claude"
            / "hooks"
            / "validate-bash.ps1": MemoryFile("# hook\n"),
            repo_root / ".claude" / "settings.json": MemoryFile('{"key": "value"}\n'),
            repo_root / ".claude" / "commands" / "sample.md": MemoryFile("# Command\n"),
        }
    )
    fs.directories.update(
        {
            repo_root,
            repo_root / ".claude",
            repo_root / ".claude" / "agents",
            repo_root / ".claude" / "skills",
            repo_root / ".claude" / "skills" / "sample",
            repo_root / ".claude" / "rules",
            repo_root / ".claude" / "hooks",
            repo_root / ".claude" / "commands",
            destination_root,
        }
    )

    summary = module.push_down_customizations(
        repo_root=repo_root,
        destination_root=destination_root,
        fs=fs,
        source_root=repo_root,
        artifact_root=destination_root,
    )

    # Every source file should appear in the destination with identical content.
    assert (
        fs.read_text(destination_root / ".claude" / "agents" / "orchestrator.md")
        == "# Orchestrator\n"
    )
    assert (
        fs.read_text(destination_root / ".claude" / "skills" / "sample" / "SKILL.md")
        == "# Sample Skill\n"
    )
    assert (
        fs.read_text(destination_root / ".claude" / "rules" / "python.md")
        == "# Python rules\n"
    )
    assert (
        fs.read_text(destination_root / ".claude" / "settings.json")
        == '{"key": "value"}\n'
    )
    assert len(summary.files) == 6


def test_push_down_customizations_excludes_settings_local_json() -> None:
    """Verify settings.local.json is excluded from destination and summary.files."""

    module = _load_module()
    repo_root = Path("/repo")
    destination_root = Path("/dest")
    fs = RecordingFileSystem(
        files={
            # settings.json should be copied; settings.local.json must not be.
            repo_root / ".claude" / "settings.json": MemoryFile('{"shared": true}\n'),
            repo_root
            / ".claude"
            / "settings.local.json": MemoryFile('{"local": true}\n'),
        }
    )
    fs.directories.update({repo_root, repo_root / ".claude", destination_root})

    summary = module.push_down_customizations(
        repo_root=repo_root,
        destination_root=destination_root,
        fs=fs,
        source_root=repo_root,
        artifact_root=destination_root,
    )

    # settings.json must appear in the destination.
    assert (
        fs.read_text(destination_root / ".claude" / "settings.json")
        == '{"shared": true}\n'
    )
    # settings.local.json must NOT have been written.
    assert (destination_root / ".claude" / "settings.local.json") not in fs.files
    # summary.files must not reference the excluded path.
    relative_paths = [result.relative_path for result in summary.files]
    assert ".claude/settings.local.json" not in relative_paths
    assert ".claude/settings.json" in relative_paths


def test_push_down_customizations_writes_claude_artifact() -> None:
    """Verify the artifact path uses the Claude artifact directory.

    Rewrite counts are expected to be zero per the passthrough contract.
    """

    module = _load_module()
    repo_root = Path("C:/repo")
    destination_root = Path("C:/dest")
    fs = RecordingFileSystem(
        files={
            repo_root / ".claude" / "settings.json": MemoryFile('{"v": 1}\n'),
        }
    )
    fs.directories.update({repo_root, repo_root / ".claude", destination_root})

    summary = module.push_down_customizations(
        repo_root=repo_root,
        destination_root=destination_root,
        fs=fs,
        source_root=repo_root,
        artifact_root=destination_root,
    )

    assert summary.rewritten_reference_count == 0
    assert summary.placeholder_rewrite_count == 0
    assert summary.unmatched_references == []
    assert "artifacts/claude-customizations/push-down-" in summary.artifact_path

    artifact_payload = json.loads(fs.read_text(Path(summary.artifact_path)))
    assert artifact_payload["destination_root"] == "C:/dest"
    assert artifact_payload["created_count"] == 1
    assert artifact_payload["rewritten_reference_count"] == 0
    assert artifact_payload["placeholder_rewrite_count"] == 0


def test_main_prints_summary_artifact_path_for_claude_scope() -> None:
    """Verify the CLI prints the Claude artifact directory in the summary path."""

    module = _load_module()
    repo_root = Path("C:/repo")
    destination_root = Path("C:/dest")
    fs = RecordingFileSystem(
        files={
            repo_root / ".claude" / "settings.json": MemoryFile('{"v": 1}\n'),
        }
    )
    fs.directories.update({repo_root, repo_root / ".claude", destination_root})

    output = io.StringIO()
    with redirect_stdout(output):
        exit_code = module.main(
            ["--destination", str(destination_root)],
            repo_root=repo_root,
            fs=fs,
        )

    assert exit_code == 0
    assert "artifacts/claude-customizations/push-down-" in output.getvalue()


def test_parse_args_requires_destination() -> None:
    """Verify parse_args raises SystemExit when --destination is not supplied."""

    module = _load_module()

    with pytest.raises(SystemExit):
        module.parse_args([])


def test_parse_args_returns_destination_value() -> None:
    """Verify parse_args captures the --destination argument value correctly."""

    module = _load_module()

    args = module.parse_args(["--destination", "C:/dest"])

    assert args.destination == "C:/dest"


def _load_filesystem_module() -> ModuleType:
    """Import the Claude push-down filesystem module under test."""

    return importlib.import_module("scripts.dev_tools.push_down_claude_filesystem")


def _empty_lister(_path: Path) -> Sequence[DirectoryEntry]:
    """Describe an empty destination layout."""

    return []


def _push_source_files(
    files: dict[str, str],
) -> tuple[ClaudePushDownSummary, RecordingFileSystem]:
    """Push ``/repo``-relative source files into ``/dest`` and return the result."""

    module = _load_module()
    repo_root = Path("/repo")
    destination_root = Path("/dest")
    fs = RecordingFileSystem(
        files={
            repo_root / relative: MemoryFile(text) for relative, text in files.items()
        }
    )
    fs.directories.update({repo_root, destination_root})
    summary: ClaudePushDownSummary = module.push_down_customizations(
        repo_root=repo_root,
        destination_root=destination_root,
        fs=fs,
        source_root=repo_root,
        artifact_root=destination_root,
        list_entries=_empty_lister,
    )
    return summary, fs


def _published(summary: ClaudePushDownSummary) -> list[str]:
    """Return the relative paths of the files a push-down published."""

    return [result.relative_path for result in summary.files]


def test_excluding_file_system_list_files_drops_local_runtime_directories() -> None:
    """F1: list_files drops .claude/state and .claude/worktrees paths."""

    module = _load_filesystem_module()
    inner = RecordingFileSystem(
        files={
            Path("/repo/.claude/state"): MemoryFile("x"),
            Path("/repo/.claude/state/batch-budget.json"): MemoryFile("{}"),
            Path("/repo/.claude/worktrees/wt/a.md"): MemoryFile("a"),
            Path("/repo/.claude/rules/python.md"): MemoryFile("py"),
        }
    )
    excluding = module.ExcludingFileSystem(
        inner, Path("/repo"), (), source_root=Path("/repo")
    )

    listed = excluding.list_files(Path("/repo/.claude"))

    assert listed == [Path("/repo/.claude/rules/python.md")]
    assert module.LOCAL_RUNTIME_RELATIVE_DIRECTORIES == (
        ".claude/state",
        ".claude/worktrees",
    )


def test_list_files_drops_runtime_paths_even_when_published() -> None:
    """F2: a runtime path listed in the published set is still dropped."""

    module = _load_filesystem_module()
    inner = RecordingFileSystem(
        files={
            Path("/repo/.claude/state/batch-budget.json"): MemoryFile("{}"),
            Path("/repo/.claude/worktrees/wt/a.md"): MemoryFile("a"),
            Path("/repo/.claude/rules/python.md"): MemoryFile("py"),
        }
    )
    excluding = module.ExcludingFileSystem(
        inner,
        Path("/repo"),
        (),
        source_root=Path("/repo"),
        published_paths=frozenset(
            {".claude/state/batch-budget.json", ".claude/rules/python.md"}
        ),
    )

    listed = excluding.list_files(Path("/repo/.claude"))

    assert listed == [Path("/repo/.claude/rules/python.md")]


def test_push_down_excludes_claude_state_and_worktrees_subtrees() -> None:
    """F3: a push-down publishes nothing below the runtime directories."""

    summary, fs = _push_source_files(
        {
            ".claude/rules/python.md": "py\n",
            ".claude/state/batch-budget.json": "{}\n",
            ".claude/state/current-session-id": "id\n",
            ".claude/worktrees/wt/.claude/settings.json": "{}\n",
            ".claude/worktrees/wt/README.md": "readme\n",
        }
    )

    assert _published(summary) == [".claude/rules/python.md"]
    runtime_roots = (Path("/dest/.claude/state"), Path("/dest/.claude/worktrees"))
    assert not [
        path
        for path in fs.files
        if any(path.is_relative_to(root) for root in runtime_roots)
    ]


def test_push_down_retains_lookalike_runtime_paths() -> None:
    """F4: paths that only resemble the runtime directories are published."""

    lookalikes = [
        ".claude/statement.md",
        ".claude/worktrees-notes.md",
        ".claude/hooks/state/x.ps1",
    ]

    summary, fs = _push_source_files({relative: "x\n" for relative in lookalikes})

    published = _published(summary)
    for relative in lookalikes:
        assert relative in published, relative
        assert Path("/dest") / relative in fs.files, relative


def test_push_down_still_publishes_general_agent_memory() -> None:
    """F5: a general-scoped agent memory is still published."""

    memory = ".claude/agent-memory/orchestrator/general.md"

    summary, fs = _push_source_files(
        {memory: "---\nname: g\nmetadata:\n  scope: general\n---\nbody\n"}
    )

    assert memory in _published(summary)
    assert Path("/dest") / memory in fs.files


def test_list_files_passes_paths_outside_source_root_through() -> None:
    """F6: a runtime-looking path outside the source root is not filtered."""

    module = _load_filesystem_module()
    inner = RecordingFileSystem(
        files={Path("/other/.claude/state/x.json"): MemoryFile("{}")}
    )
    excluding = module.ExcludingFileSystem(
        inner, Path("/repo"), (), source_root=Path("/repo")
    )

    listed = excluding.list_files(Path("/other/.claude"))

    assert listed == [Path("/other/.claude/state/x.json")]
