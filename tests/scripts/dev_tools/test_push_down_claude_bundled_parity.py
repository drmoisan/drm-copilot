"""Behavioral parity tests for the bundled `.claude` push-down engine copy.

These tests load the bundled engine copy under
``extensions/drm-copilot/resources/scripts/dev_tools`` using a bundled-only
``sys.path`` (with the repository root removed) and assert that it exposes the
same public surface and produces the same pack-filtered and legacy-variant
behavior as the repository source. They use an in-memory filesystem double; no
temporary files are created.
"""

from __future__ import annotations

import importlib
import json
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import TYPE_CHECKING

if TYPE_CHECKING:
    import pytest

BUNDLE_RELATIVE = "extensions/drm-copilot/resources/claude-customizations"
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


def _bundled_scripts_root() -> Path:
    """Resolve the bundled `resources/scripts` root used by the extension."""
    repo_root = Path(__file__).resolve().parents[3]
    return repo_root / "extensions" / "drm-copilot" / "resources" / "scripts"


def _bundled_only_sys_path(repo_root: Path, bundled_scripts_root: Path) -> list[str]:
    """Build a sys.path that exposes bundled `dev_tools` without repo-root scripts."""
    filtered_path: list[str] = []
    # Drop the implicit cwd entry and any entry that resolves to the repo root so
    # the repo-level `scripts` package cannot satisfy the import.
    for entry in sys.path:
        if entry == "":
            continue
        try:
            if Path(entry).resolve() == repo_root:
                continue
        except OSError:
            pass
        filtered_path.append(entry)
    return [str(bundled_scripts_root), *filtered_path]


def _manifest_payload(
    name: str, label: str, paths: list[str], source_prefix: str | None = None
) -> str:
    """Build a manifest JSON payload for the in-memory filesystem."""
    payload: dict[str, object] = {"name": name, "label": label, "paths": paths}
    if source_prefix is not None:
        payload["source_prefix"] = source_prefix
    return json.dumps(payload)


def _seed_bundled_tree(fs: RecordingFileSystem, source_root: Path, dest: Path) -> None:
    """Seed a `.claude` tree, bundle manifests, and the legacy variant subtree."""
    legacy_base = f"{BUNDLE_RELATIVE}/{LEGACY_PREFIX}"
    fs.write_text(source_root / ".claude/settings.json", '{"core": true}\n')
    fs.write_text(source_root / ".claude/agents/orchestrator.md", "# Orchestrator\n")
    fs.write_text(source_root / ".claude/rules/typescript.md", "# TS rules\n")
    fs.write_text(source_root / ".claude/rules/csharp.md", "# Modern C#\n")
    fs.write_text(
        source_root / ".claude/agents/csharp-typed-engineer.md", "# Modern engineer\n"
    )
    fs.write_text(
        source_root / ".claude/skills/csharp-qa-gate/SKILL.md", "# Modern qa\n"
    )
    fs.write_text(
        source_root / ".claude/skills/invoke-csharp-engineer/SKILL.md", "# Modern inv\n"
    )
    fs.write_text(source_root / f"{legacy_base}/rules/csharp.md", "# Legacy C#\n")
    fs.write_text(
        source_root / f"{legacy_base}/agents/csharp-typed-engineer.md",
        "# Legacy engineer\n",
    )
    fs.write_text(
        source_root / f"{legacy_base}/skills/csharp-qa-gate/SKILL.md", "# Legacy qa\n"
    )
    fs.write_text(
        source_root / f"{legacy_base}/skills/invoke-csharp-engineer/SKILL.md",
        "# Legacy inv\n",
    )

    csharp_paths = [
        ".claude/rules/csharp.md",
        ".claude/agents/csharp-typed-engineer.md",
        ".claude/skills/csharp-qa-gate/SKILL.md",
        ".claude/skills/invoke-csharp-engineer/SKILL.md",
    ]
    manifest_dir = source_root / BUNDLE_RELATIVE / "pack-manifests"
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
        "csharp-modern": _manifest_payload("csharp-modern", "C#", csharp_paths),
        "csharp-legacy": _manifest_payload(
            "csharp-legacy", "C# legacy", csharp_paths, LEGACY_PREFIX
        ),
    }
    # Persist each manifest payload as a `<name>.json` file in the bundle dir.
    for name, payload in manifests.items():
        fs.write_text(manifest_dir / f"{name}.json", payload)
    fs.directories.update({source_root, dest})


def test_bundled_engine_exposes_new_surface_and_pack_and_variant_behavior(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """Verify the bundled engine copy honors packs and legacy-variant routing."""
    # Arrange: import the bundled engine with a bundled-only sys.path so the
    # bundled package (not the repo source) satisfies every import.
    repo_root = Path(__file__).resolve().parents[3]
    bundled_scripts_root = _bundled_scripts_root()
    import_state = [
        "scripts",
        "scripts.dev_tools",
        "scripts.dev_tools.agentic_sync",
        "scripts.dev_tools.push_down_copilot_customizations",
        "scripts.dev_tools.push_down_copilot_customizations_filesystem",
        "scripts.dev_tools.push_down_copilot_customizations_rewrites",
        "scripts.dev_tools.push_down_claude_customizations",
        "scripts.dev_tools.push_down_claude_pack_selection",
        "scripts.dev_tools.push_down_claude_filesystem",
        "dev_tools",
        "dev_tools.agentic_sync",
        "dev_tools.push_down_copilot_customizations",
        "dev_tools.push_down_copilot_customizations_filesystem",
        "dev_tools.push_down_copilot_customizations_rewrites",
        "dev_tools.push_down_claude_customizations",
        "dev_tools.push_down_claude_pack_selection",
        "dev_tools.push_down_claude_filesystem",
    ]
    saved_modules = {name: sys.modules.get(name) for name in import_state}
    for module_name in import_state:
        sys.modules.pop(module_name, None)

    monkeypatch.setattr(
        sys, "path", _bundled_only_sys_path(repo_root, bundled_scripts_root)
    )
    importlib.invalidate_caches()

    try:
        module = importlib.import_module("dev_tools.push_down_claude_customizations")

        # Assert the new public surface exists on the bundled copy.
        assert callable(module.push_down_customizations)
        assert module.CSHARP_VARIANT_CHOICES == ("modern", "legacy")
        assert module.MEMORY_MODE_CHOICES == ("overwrite", "merge", "skip")
        args = module.parse_args(
            [
                "--destination",
                "C:/dest",
                "--packs",
                "core,csharp-legacy",
                "--csharp-variant",
                "legacy",
                "--memory-mode",
                "skip",
            ]
        )
        assert args.packs == "core,csharp-legacy"
        assert args.csharp_variant == "legacy"
        assert args.memory_mode == "skip"

        # Act: a representative pack-filtered + legacy-variant run.
        source_root = Path("C:/repo")
        dest = Path("C:/dest")
        fs = RecordingFileSystem()
        _seed_bundled_tree(fs, source_root, dest)
        module.push_down_customizations(
            repo_root=source_root,
            destination_root=dest,
            fs=fs,
            source_root=source_root,
            artifact_root=dest,
            packs=frozenset({"core", "csharp-legacy"}),
            csharp_variant="legacy",
        )

        # Assert: canonical destination holds legacy content; non-selected
        # language packs are absent; no variant path is written at destination.
        assert fs.read_text(dest / ".claude/rules/csharp.md") == "# Legacy C#\n"
        assert dest / ".claude/rules/typescript.md" not in fs.files
        assert not any(
            LEGACY_PREFIX in path.as_posix()
            for path in fs.files
            if dest in path.parents
        )
    finally:
        # Restore the original module table so other tests import the repo copy.
        for module_name in import_state:
            sys.modules.pop(module_name, None)
        for module_name, saved in saved_modules.items():
            if saved is not None:
                sys.modules[module_name] = saved
