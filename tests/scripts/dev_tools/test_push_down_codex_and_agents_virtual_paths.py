"""Virtual resource-pair tests for the `.codex` / `.agents` publisher (issue #697).

The publisher exposes resources stored once under `extensions/drm-copilot/
resources` at destination-relative paths. The codex-routing modules are stored
under `resources/lib/codex-routing` and published under
`.codex/lib/codex-routing`, so these tests prove rename support, the pair-map
boundary of each virtual root, and the byte identity of the shared mirror.
"""

from __future__ import annotations

from pathlib import Path

from tests.scripts.dev_tools.push_down_customizations_test_support import (
    MemoryFile,
    RecordingFileSystem,
    load_module,
    write_manifest,
)

REPO_ROOT = Path(__file__).resolve().parents[3]
RESOURCES_RELATIVE = Path("extensions/drm-copilot/resources")
CODEX_BUNDLE_RELATIVE = RESOURCES_RELATIVE / "codex-and-agents-customizations"
MODULE_NAMES: tuple[str, ...] = ("CodexTopology.psm1", "CodexDeployment.psm1")
MODULE_DESTINATION_DIR = Path(".codex/lib/codex-routing")


def _seed_module_resources(fs: RecordingFileSystem, repo_root: Path) -> dict[str, str]:
    """Seed distinct text for each shared codex-routing module resource.

    Args:
        fs: In-memory file system receiving the resources.
        repo_root: Source repository root of the in-memory tree.

    Returns:
        dict[str, str]: Module file name to the seeded text.
    """
    seeded: dict[str, str] = {}
    # Give each module unique content so a swapped mapping would be detected.
    for name in MODULE_NAMES:
        text = f"# shared module {name}\n"
        fs.files[repo_root / RESOURCES_RELATIVE / "lib" / "codex-routing" / name] = (
            MemoryFile(text)
        )
        seeded[name] = text
    return seeded


def _new_file_system(repo_root: Path, destination_root: Path) -> RecordingFileSystem:
    """Create an in-memory tree holding one `.codex` file and a destination.

    Args:
        repo_root: Source repository root of the in-memory tree.
        destination_root: Destination workspace root to register.

    Returns:
        RecordingFileSystem: File system with the minimum publishable tree.
    """
    fs = RecordingFileSystem(
        files={repo_root / ".codex" / "config.toml": MemoryFile("trusted = true\n")}
    )
    fs.directories.update({repo_root, repo_root / ".codex", destination_root})
    return fs


def test_module_pairs_publish_renamed_resources_in_full_tree_mode() -> None:
    """Full-tree mode publishes each module from its renamed resource path (AC-4.1)."""
    # Arrange
    module = load_module()
    repo_root = Path("C:/repo")
    destination_root = Path("C:/dest")
    fs = _new_file_system(repo_root, destination_root)
    seeded = _seed_module_resources(fs, repo_root)

    # Act
    module.push_down_customizations(
        repo_root=repo_root,
        destination_root=destination_root,
        fs=fs,
        source_root=repo_root,
        artifact_root=destination_root,
    )

    # Assert
    for name, text in seeded.items():
        assert fs.read_text(destination_root / MODULE_DESTINATION_DIR / name) == text


def test_module_pairs_publish_renamed_resources_in_pack_mode() -> None:
    """Pack mode publishes each module from its renamed resource path (AC-4.1)."""
    # Arrange
    module = load_module()
    repo_root = Path("C:/repo")
    destination_root = Path("C:/dest")
    fs = _new_file_system(repo_root, destination_root)
    seeded = _seed_module_resources(fs, repo_root)
    write_manifest(fs, repo_root, "core", [".codex/config.toml"])
    write_manifest(fs, repo_root, "python", [".codex/config.toml"])

    # Act
    module.push_down_customizations(
        repo_root=repo_root,
        destination_root=destination_root,
        fs=fs,
        source_root=repo_root,
        artifact_root=destination_root,
        packs=frozenset({"core", "python"}),
    )

    # Assert
    for name, text in seeded.items():
        assert fs.read_text(destination_root / MODULE_DESTINATION_DIR / name) == text


def test_unmapped_config_file_is_not_published() -> None:
    """A physical `config/` file outside the pair map is not published (AC-4.2)."""
    # Arrange
    module = load_module()
    repo_root = Path("C:/repo")
    destination_root = Path("C:/dest")
    fs = _new_file_system(repo_root, destination_root)
    fs.files[repo_root / "config" / "unrelated.json"] = MemoryFile("{}\n")
    fs.files[
        repo_root / RESOURCES_RELATIVE / "config" / "orchestration-routing.json"
    ] = MemoryFile('{"version": 1}\n')

    # Act
    summary = module.push_down_customizations(
        repo_root=repo_root,
        destination_root=destination_root,
        fs=fs,
        source_root=repo_root,
        artifact_root=destination_root,
    )

    # Assert
    published = [result.relative_path for result in summary.files]
    assert "config/unrelated.json" not in published
    assert "config/orchestration-routing.json" in published
    assert not fs.is_file(destination_root / "config" / "unrelated.json")


def test_codex_routing_lib_is_walked_as_published_root() -> None:
    """`.codex/lib/codex-routing` is a published root listing both modules (AC-4.2)."""
    # Arrange
    module = load_module()
    repo_root = Path("C:/repo")
    destination_root = Path("C:/dest")
    fs = _new_file_system(repo_root, destination_root)
    _seed_module_resources(fs, repo_root)

    # Act
    summary = module.push_down_customizations(
        repo_root=repo_root,
        destination_root=destination_root,
        fs=fs,
        source_root=repo_root,
        artifact_root=destination_root,
    )

    # Assert
    assert Path(".codex/lib/codex-routing") in module.PUBLISHED_ROOT_FOLDERS
    published = [result.relative_path for result in summary.files]
    # Each module destination must appear in the summary of published files.
    for name in MODULE_NAMES:
        assert (MODULE_DESTINATION_DIR / name).as_posix() in published


def test_shared_codex_routing_modules_match_claude_lib_sources() -> None:
    """The shared module mirror is byte-identical to `.claude/lib` (AC-4.4)."""
    # Arrange / Act / Assert: compare each module pair byte for byte.
    for name in MODULE_NAMES:
        shared = REPO_ROOT / RESOURCES_RELATIVE / "lib" / "codex-routing" / name
        canonical = REPO_ROOT / ".claude" / "lib" / "codex-routing" / name
        assert shared.read_bytes() == canonical.read_bytes(), name


def test_no_physical_codex_lib_directory_exists() -> None:
    """Neither the repository nor the bundle has a physical `.codex/lib` (AC-4.5)."""
    # Arrange
    repository_lib = REPO_ROOT / ".codex" / "lib"
    bundle_lib = REPO_ROOT / CODEX_BUNDLE_RELATIVE / ".codex" / "lib"

    # Act / Assert
    assert not repository_lib.exists()
    assert not bundle_lib.exists()
