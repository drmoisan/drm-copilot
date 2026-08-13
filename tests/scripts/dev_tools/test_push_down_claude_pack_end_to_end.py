"""End-to-end tests for pack selection and C# variant routing in push-down.

These tests drive `scripts.dev_tools.push_down_claude_customizations` through a
seeded in-memory `.claude` tree, variant subtree, and pack manifests to verify
pack filtering, legacy-variant routing to canonical destination paths, C#
mutual exclusion, single-toolchain output, and the backward-compatible
no-argument run. No temporary files are created.
"""

from __future__ import annotations

import importlib
import json
from dataclasses import dataclass
from pathlib import Path

import pytest

# Bundle root (relative to the source root) that holds the pack manifests and
# the legacy variant subtree, mirroring the repository layout.
BUNDLE_RELATIVE = "extensions/drm-copilot/resources/claude-customizations"
MANIFEST_DIR_RELATIVE = f"{BUNDLE_RELATIVE}/pack-manifests"
LEGACY_PREFIX = ".claude-variants/csharp-legacy"


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


def _manifest_payload(
    name: str, label: str, paths: list[str], source_prefix: str | None = None
) -> str:
    """Build a manifest JSON payload for the in-memory filesystem."""
    payload: dict[str, object] = {"name": name, "label": label, "paths": paths}
    if source_prefix is not None:
        payload["source_prefix"] = source_prefix
    return json.dumps(payload)


def _seed_full_tree(fs: RecordingFileSystem, source_root: Path, dest: Path) -> None:
    """Seed a representative `.claude` tree, variant subtree, and manifests."""
    # The legacy variant subtree lives beneath the bundle root, mirroring the
    # repository layout (claude-customizations/.claude-variants/csharp-legacy).
    legacy_base = f"{BUNDLE_RELATIVE}/{LEGACY_PREFIX}"
    # Core, language, and C# source files mirrored on the in-memory filesystem.
    files = {
        source_root / ".claude/settings.json": '{"core": true}\n',
        source_root / ".claude/agents/orchestrator.md": "# Orchestrator\n",
        source_root / ".claude/rules/typescript.md": "# TS rules\n",
        source_root / ".claude/rules/python.md": "# Python rules\n",
        source_root / ".claude/rules/powershell.md": "# PS rules\n",
        source_root / ".claude/rules/csharp.md": "# Modern C#\n",
        source_root / ".claude/agents/csharp-typed-engineer.md": "# Modern engineer\n",
        source_root / ".claude/skills/csharp-qa-gate/SKILL.md": "# Modern qa\n",
        source_root
        / ".claude/skills/invoke-csharp-engineer/SKILL.md": "# Modern inv\n",
        source_root / f"{legacy_base}/rules/csharp.md": "# Legacy C#\n",
        source_root
        / f"{legacy_base}/agents/csharp-typed-engineer.md": "# Legacy engineer\n",
        source_root / f"{legacy_base}/skills/csharp-qa-gate/SKILL.md": "# Legacy qa\n",
        source_root
        / f"{legacy_base}/skills/invoke-csharp-engineer/SKILL.md": "# Legacy inv\n",
    }
    for path, content in files.items():
        fs.write_text(path, MemoryFile(content=content).content)

    csharp_paths = [
        ".claude/rules/csharp.md",
        ".claude/agents/csharp-typed-engineer.md",
        ".claude/skills/csharp-qa-gate/SKILL.md",
        ".claude/skills/invoke-csharp-engineer/SKILL.md",
    ]
    manifest_dir = source_root / MANIFEST_DIR_RELATIVE
    fs.directories.add(manifest_dir)
    manifests = {
        "core": _manifest_payload(
            "core",
            "Core",
            [".claude/settings.json", ".claude/agents/orchestrator.md"],
        ),
        "typescript": _manifest_payload(
            "typescript", "TypeScript", [".claude/rules/typescript.md"]
        ),
        "python": _manifest_payload("python", "Python", [".claude/rules/python.md"]),
        "powershell": _manifest_payload(
            "powershell", "PowerShell", [".claude/rules/powershell.md"]
        ),
        "csharp-modern": _manifest_payload("csharp-modern", "C#", csharp_paths),
        "csharp-legacy": _manifest_payload(
            "csharp-legacy", "C# legacy", csharp_paths, LEGACY_PREFIX
        ),
    }
    # Persist each manifest payload as a `<name>.json` file in the bundle dir.
    for name, payload in manifests.items():
        fs.write_text(manifest_dir / f"{name}.json", payload)
    # Register the source and destination roots as directories for validation.
    fs.directories.update({source_root, dest})


def test_push_down_packs_core_typescript_excludes_other_languages() -> None:
    """Verify --packs core,typescript writes only core + TypeScript files."""
    # Arrange
    module = _entry_module()
    source_root = Path("/repo")
    dest = Path("/dest")
    fs = RecordingFileSystem()
    _seed_full_tree(fs, source_root, dest)

    # Act
    module.push_down_customizations(
        repo_root=source_root,
        destination_root=dest,
        fs=fs,
        source_root=source_root,
        artifact_root=dest,
        packs=frozenset({"core", "typescript"}),
    )

    # Assert: core + TypeScript present; other language packs absent.
    assert dest / ".claude/settings.json" in fs.files
    assert dest / ".claude/agents/orchestrator.md" in fs.files
    assert dest / ".claude/rules/typescript.md" in fs.files
    assert dest / ".claude/rules/python.md" not in fs.files
    assert dest / ".claude/rules/powershell.md" not in fs.files
    assert dest / ".claude/rules/csharp.md" not in fs.files


def test_push_down_legacy_variant_writes_legacy_content_to_canonical_paths() -> None:
    """Verify legacy variant routes legacy content to canonical C# paths."""
    # Arrange
    module = _entry_module()
    source_root = Path("/repo")
    dest = Path("/dest")
    fs = RecordingFileSystem()
    _seed_full_tree(fs, source_root, dest)

    # Act: select core + csharp with the legacy variant.
    module.push_down_customizations(
        repo_root=source_root,
        destination_root=dest,
        fs=fs,
        source_root=source_root,
        artifact_root=dest,
        packs=frozenset({"core", "csharp-legacy"}),
        csharp_variant="legacy",
    )

    # Assert: canonical destination holds legacy content; no variant path written.
    assert fs.read_text(dest / ".claude/rules/csharp.md") == "# Legacy C#\n"
    assert (
        fs.read_text(dest / ".claude/agents/csharp-typed-engineer.md")
        == "# Legacy engineer\n"
    )
    # The modern content must not be written to the canonical destination path.
    assert fs.read_text(dest / ".claude/rules/csharp.md") != "# Modern C#\n"
    # No `.claude-variants/` path is ever written at the destination.
    assert not any(
        LEGACY_PREFIX in path.as_posix() for path in fs.files if dest in path.parents
    )


def test_push_down_both_csharp_variants_raises() -> None:
    """Verify selecting both C# variants raises the mutual-exclusion error."""
    module = _entry_module()
    source_root = Path("/repo")
    dest = Path("/dest")
    fs = RecordingFileSystem()
    _seed_full_tree(fs, source_root, dest)

    with pytest.raises(module.ManifestError):
        module.push_down_customizations(
            repo_root=source_root,
            destination_root=dest,
            fs=fs,
            source_root=source_root,
            artifact_root=dest,
            packs=frozenset({"core", "csharp-modern", "csharp-legacy"}),
        )


def test_push_down_single_csharp_toolchain_written_once() -> None:
    """Verify legacy C# selection yields exactly one C# toolchain at destination.

    Each of the four canonical C# destination paths is written exactly once,
    holds legacy content, and no modern C# content is written to any destination
    path (single-C#-toolchain invariant).
    """
    module = _entry_module()
    source_root = Path("/repo")
    dest = Path("/dest")
    fs = RecordingFileSystem()
    _seed_full_tree(fs, source_root, dest)

    summary = module.push_down_customizations(
        repo_root=source_root,
        destination_root=dest,
        fs=fs,
        source_root=source_root,
        artifact_root=dest,
        packs=frozenset({"core", "csharp-legacy"}),
        csharp_variant="legacy",
    )

    # Each canonical C# path must appear exactly once in the summary file list.
    csharp_relpaths = [
        ".claude/rules/csharp.md",
        ".claude/agents/csharp-typed-engineer.md",
        ".claude/skills/csharp-qa-gate/SKILL.md",
        ".claude/skills/invoke-csharp-engineer/SKILL.md",
    ]
    written = [result.relative_path for result in summary.files]
    for relpath in csharp_relpaths:
        assert written.count(relpath) == 1

    # Each canonical destination path holds legacy content, and no modern C#
    # content (e.g. "# Modern C#") was written to any destination path.
    legacy_contents = {
        ".claude/rules/csharp.md": "# Legacy C#\n",
        ".claude/agents/csharp-typed-engineer.md": "# Legacy engineer\n",
        ".claude/skills/csharp-qa-gate/SKILL.md": "# Legacy qa\n",
        ".claude/skills/invoke-csharp-engineer/SKILL.md": "# Legacy inv\n",
    }
    for relpath, content in legacy_contents.items():
        assert fs.read_text(dest / relpath) == content
    modern_markers = {
        "# Modern C#\n",
        "# Modern engineer\n",
        "# Modern qa\n",
        "# Modern inv\n",
    }
    written_destination_contents = {
        memory.content for path, memory in fs.files.items() if dest in path.parents
    }
    assert not (modern_markers & written_destination_contents)


def test_push_down_no_arguments_publishes_full_tree() -> None:
    """Verify a no-argument run publishes the full tree and overwrites memory."""
    # Arrange: a general memory plus several language files and core settings.
    # Use C:/ style absolute paths so resolve_cli_path is a no-op on Windows and
    # the in-memory key space matches the engine's resolved paths.
    module = _entry_module()
    source_root = Path("C:/repo")
    dest = Path("C:/dest")
    fs = RecordingFileSystem()
    _seed_full_tree(fs, source_root, dest)
    general_memory = (
        "---\nname: shared\nmetadata:\n  scope: general\n---\n# Shared memory\n"
    )
    fs.write_text(source_root / ".claude/agent-memory/shared/MEMORY.md", general_memory)

    # Act: invoke via main with only --destination (no pack/variant/memory args).
    exit_code = module.main(
        ["--destination", str(dest)],
        repo_root=source_root,
        fs=fs,
    )

    # Assert: full tree present including all language files and the memory.
    assert exit_code == 0
    assert dest / ".claude/settings.json" in fs.files
    assert dest / ".claude/rules/typescript.md" in fs.files
    assert dest / ".claude/rules/python.md" in fs.files
    assert dest / ".claude/rules/powershell.md" in fs.files
    assert dest / ".claude/rules/csharp.md" in fs.files
    assert dest / ".claude/agent-memory/shared/MEMORY.md" in fs.files
    # The default run reads modern C# content (no variant routing).
    assert fs.read_text(dest / ".claude/rules/csharp.md") == "# Modern C#\n"


def _destination_map(fs: RecordingFileSystem, destination_root: Path) -> dict[str, str]:
    """Return a `{relative_path: content}` map for one destination root.

    Purpose:
        Reduce a push-down result to a root-independent value so two generations
        written to different destination roots can be compared directly.

    Args:
        fs (RecordingFileSystem): The in-memory filesystem holding both runs.
        destination_root (Path): The destination root whose files are collected.

    Returns:
        dict[str, str]: POSIX-style relative path to file content for every file
        written beneath the destination root.

    Raises:
        None.

    Side Effects:
        None.
    """

    # Key by POSIX relative path so the two maps are comparable across roots.
    return {
        path.relative_to(destination_root).as_posix(): fs.read_text(path)
        for path in fs.list_files(destination_root)
    }


def test_push_down_claude_repeated_generation_is_deterministic() -> None:
    """Verify two legacy-variant generations produce identical output.

    Both generations run against one seeded source tree and write to separate
    destination roots. `artifact_root` points outside both destinations so the
    timestamped push-down artifacts are excluded from the comparison, leaving
    only the published payload. Equal maps establish that repeated generation is
    deterministic.
    """

    # Arrange: one seeded source tree plus two destination roots and an artifact
    # root outside both. `_seed_full_tree` registers only the first destination,
    # so the second destination and the artifact root are registered explicitly.
    module = _entry_module()
    source_root = Path("/repo")
    first_dest = Path("/dest")
    second_dest = Path("/dest2")
    artifact_root = Path("/artifacts")
    fs = RecordingFileSystem()
    _seed_full_tree(fs, source_root, first_dest)
    fs.directories.update({second_dest, artifact_root})

    # Act: publish the same pack selection twice, once into each destination.
    for destination in (first_dest, second_dest):
        module.push_down_customizations(
            repo_root=source_root,
            destination_root=destination,
            fs=fs,
            source_root=source_root,
            artifact_root=artifact_root,
            packs=frozenset({"core", "csharp-legacy"}),
            csharp_variant="legacy",
        )

    # Assert: both generations wrote the same relative paths and contents.
    first_map = _destination_map(fs, first_dest)
    second_map = _destination_map(fs, second_dest)
    assert first_map, "First generation must publish at least one file."
    assert (
        first_map == second_map
    ), "Repeated generation must produce identical destination content."
