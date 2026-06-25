"""Tests for pack selection, variant routing, and memory modes in push-down.

These tests cover the pure pack-selection helpers
(`scripts.dev_tools.push_down_claude_pack_selection`) and the end-to-end
behavior of `scripts.dev_tools.push_down_claude_customizations` when the new
`--packs`, `--csharp-variant`, and `--memory-mode` options are supplied. They use
an in-memory filesystem double; no temporary files are created.
"""

from __future__ import annotations

import importlib
import json
from dataclasses import dataclass
from pathlib import Path

import pytest

# Manifest directory the entry point resolves relative to the source root.
MANIFEST_DIR_RELATIVE = (
    "extensions/drm-copilot/resources/claude-customizations/pack-manifests"
)
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


def _selection_module():
    """Import the pack-selection helper module under test."""
    return importlib.import_module("scripts.dev_tools.push_down_claude_pack_selection")


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


def _write_manifests(
    fs: RecordingFileSystem, source_root: Path, manifests: dict[str, str]
) -> None:
    """Write manifest payloads into the in-memory bundle manifest directory."""
    manifest_dir = source_root / MANIFEST_DIR_RELATIVE
    fs.directories.add(manifest_dir)
    # Persist each manifest payload as a `<name>.json` file in the bundle dir.
    for name, payload in manifests.items():
        fs.write_text(manifest_dir / f"{name}.json", payload)


# --- Manifest loader (P3-T1) ---------------------------------------------------


def test_load_pack_manifests_parses_valid_manifest() -> None:
    """Verify the loader returns a typed structure for a valid manifest."""
    # Arrange: a single core manifest in the in-memory bundle directory.
    module = _selection_module()
    source_root = Path("/repo")
    fs = RecordingFileSystem()
    _write_manifests(
        fs,
        source_root,
        {"core": _manifest_payload("core", "Core", [".claude/settings.json"])},
    )

    # Act
    manifests = module.load_pack_manifests(
        source_root / MANIFEST_DIR_RELATIVE, frozenset({"core"}), fs
    )

    # Assert
    assert "core" in manifests
    assert manifests["core"].name == "core"
    assert manifests["core"].paths == (".claude/settings.json",)
    assert manifests["core"].source_prefix is None


def test_load_pack_manifests_raises_for_missing_manifest() -> None:
    """Verify a specific error is raised when a selected manifest is absent."""
    # Arrange: bundle has core but not the requested python manifest.
    module = _selection_module()
    source_root = Path("/repo")
    fs = RecordingFileSystem()
    _write_manifests(
        fs,
        source_root,
        {"core": _manifest_payload("core", "Core", [".claude/settings.json"])},
    )

    # Act / Assert
    with pytest.raises(module.ManifestError):
        module.load_pack_manifests(
            source_root / MANIFEST_DIR_RELATIVE, frozenset({"python"}), fs
        )


def test_load_pack_manifests_raises_for_malformed_json() -> None:
    """Verify a specific error is raised when a manifest is not valid JSON."""
    # Arrange: a core manifest whose content is not valid JSON.
    module = _selection_module()
    source_root = Path("/repo")
    fs = RecordingFileSystem()
    manifest_dir = source_root / MANIFEST_DIR_RELATIVE
    fs.write_text(manifest_dir / "core.json", "{not json")

    # Act / Assert
    with pytest.raises(module.ManifestError):
        module.load_pack_manifests(manifest_dir, frozenset({"core"}), fs)


def test_load_pack_manifests_raises_for_missing_required_keys() -> None:
    """Verify a specific error is raised when a manifest lacks required keys."""
    # Arrange: a manifest object missing the 'paths' key.
    module = _selection_module()
    source_root = Path("/repo")
    fs = RecordingFileSystem()
    manifest_dir = source_root / MANIFEST_DIR_RELATIVE
    fs.write_text(manifest_dir / "core.json", json.dumps({"name": "core"}))

    # Act / Assert
    with pytest.raises(module.ManifestError):
        module.load_pack_manifests(manifest_dir, frozenset({"core"}), fs)


def test_load_pack_manifests_raises_for_non_string_path_entry() -> None:
    """Verify a specific error is raised when a paths entry is not a string."""
    module = _selection_module()
    source_root = Path("/repo")
    fs = RecordingFileSystem()
    manifest_dir = source_root / MANIFEST_DIR_RELATIVE
    fs.write_text(
        manifest_dir / "core.json",
        json.dumps({"name": "core", "label": "Core", "paths": [123]}),
    )

    with pytest.raises(module.ManifestError):
        module.load_pack_manifests(manifest_dir, frozenset({"core"}), fs)


# --- Pack filtering (P3-T2) ----------------------------------------------------


def _two_pack_manifests(module: object) -> dict[str, object]:
    """Build a core + python manifest mapping for filter tests."""
    return {
        "core": module.PackManifest(  # type: ignore[attr-defined]
            name="core",
            label="Core",
            paths=(".claude/settings.json", ".claude/agents/orchestrator.md"),
            source_prefix=None,
        ),
        "python": module.PackManifest(  # type: ignore[attr-defined]
            name="python",
            label="Python",
            paths=(".claude/rules/python.md",),
            source_prefix=None,
        ),
    }


def test_compute_published_paths_always_includes_core() -> None:
    """Verify selecting python alone still publishes all core paths."""
    # Arrange
    module = _selection_module()
    manifests = _two_pack_manifests(module)

    # Act: select only python (without core).
    published = module.compute_published_paths(frozenset({"python"}), manifests)

    # Assert: core paths are present alongside python paths.
    assert published is not None
    assert ".claude/settings.json" in published
    assert ".claude/agents/orchestrator.md" in published
    assert ".claude/rules/python.md" in published


def test_compute_published_paths_returns_none_for_empty_selection() -> None:
    """Verify an empty selection signals the publish-everything default."""
    module = _selection_module()
    manifests = _two_pack_manifests(module)

    assert module.compute_published_paths(None, manifests) is None
    assert module.compute_published_paths(frozenset(), manifests) is None


# --- Variant resolver (P3-T5 groundwork) --------------------------------------


def test_resolve_variant_source_path_legacy_maps_canonical_csharp() -> None:
    """Verify legacy variant maps a canonical C# path to the legacy source."""
    module = _selection_module()

    resolved = module.resolve_variant_source_path(".claude/rules/csharp.md", "legacy")

    assert resolved == f"{LEGACY_PREFIX}/rules/csharp.md"


def test_resolve_variant_source_path_modern_is_identity() -> None:
    """Verify modern variant returns the canonical C# path unchanged."""
    module = _selection_module()

    resolved = module.resolve_variant_source_path(".claude/rules/csharp.md", "modern")

    assert resolved == ".claude/rules/csharp.md"


def test_resolve_variant_source_path_non_csharp_is_identity() -> None:
    """Verify non-C# paths resolve to themselves under either variant."""
    module = _selection_module()

    assert (
        module.resolve_variant_source_path(".claude/rules/python.md", "legacy")
        == ".claude/rules/python.md"
    )


# --- Collision assertion (P3-T5 groundwork) -----------------------------------


def test_assert_single_csharp_toolchain_rejects_both_variants() -> None:
    """Verify selecting both C# packs raises the mutual-exclusion error."""
    module = _selection_module()
    published = frozenset({".claude/rules/csharp.md"})

    with pytest.raises(module.ManifestError):
        module.assert_single_csharp_toolchain(
            published, frozenset({"csharp-modern", "csharp-legacy"})
        )


def test_assert_single_csharp_toolchain_accepts_single_variant() -> None:
    """Verify selecting exactly one C# pack passes the assertion."""
    module = _selection_module()
    published = frozenset({".claude/rules/csharp.md"})

    # Act / Assert: no exception is raised for a single C# variant.
    module.assert_single_csharp_toolchain(published, frozenset({"csharp-legacy"}))


# --- parse_args defaults and explicit values (P2-T6) --------------------------


def test_parse_args_defaults() -> None:
    """Verify parse_args yields backward-compatible defaults."""
    module = _entry_module()

    args = module.parse_args(["--destination", "/dest"])

    assert args.destination == "/dest"
    assert args.packs is None
    assert args.csharp_variant == "modern"
    assert args.memory_mode == "overwrite"


def test_parse_packs_argument_empty_entries_returns_none() -> None:
    """Verify a packs value of only separators resolves to the everything default."""
    module = _entry_module()

    # A value of only commas/whitespace must collapse to None (publish all).
    assert module._parse_packs_argument(",") is None
    assert module._parse_packs_argument("  ") is None
    assert module._parse_packs_argument(None) is None


def test_parse_packs_argument_strips_and_dedupes() -> None:
    """Verify the packs parser strips whitespace and drops empty entries."""
    module = _entry_module()

    assert module._parse_packs_argument(" core , typescript ,") == frozenset(
        {"core", "typescript"}
    )


def test_parse_args_explicit_values() -> None:
    """Verify parse_args captures explicit pack/variant/memory values."""
    module = _entry_module()

    args = module.parse_args(
        [
            "--destination",
            "/dest",
            "--packs",
            "core,typescript",
            "--csharp-variant",
            "legacy",
            "--memory-mode",
            "merge",
        ]
    )

    assert args.packs == "core,typescript"
    assert args.csharp_variant == "legacy"
    assert args.memory_mode == "merge"
