"""Public publisher contracts for the fixed Codex portable asset allowlist."""

from __future__ import annotations

import importlib
import json
from dataclasses import dataclass
from pathlib import Path

import pytest

CODEX_BUNDLE_RELATIVE = Path(
    "extensions/drm-copilot/resources/codex-and-agents-customizations"
)
CLAUDE_BUNDLE_RELATIVE = Path("extensions/drm-copilot/resources/claude-customizations")
PORTABLE_CLAUDE_PATHS = (
    Path(".claude/lib/bash/compute-cohorts.sh"),
    Path(".claude/lib/bash/compute-concurrency-batches.sh"),
    Path(".claude/lib/bash/parallel-cohorts.sh"),
    Path(".claude/lib/bash/parallel-common.sh"),
    Path(".claude/lib/bash/parallel-items-validate.sh"),
    Path(".claude/lib/bash/parallel-manifest-validate.sh"),
    Path(".claude/lib/bash/parallel-yaml-emit.sh"),
    Path(".claude/lib/bash/parallel-yaml-scan.sh"),
    Path(".claude/lib/bash/validate-parallel-manifest.sh"),
    Path(".claude/lib/blast-radius/BlastRadius.psm1"),
    Path(".claude/lib/blast-radius/BlastRadiusConfig.psm1"),
    Path(".claude/lib/blast-radius/BlastRadiusExtraction.psm1"),
    Path(".claude/lib/blast-radius/BlastRadiusGlob.psm1"),
    Path(".claude/lib/blast-radius/BlastRadiusValidation.psm1"),
)
BLAST_RADIUS_CONFIG = Path("config/blast-radius.json")
UNRELATED_CLAUDE_PATH = Path(".claude/rules/parallel-orchestration.md")


@dataclass
class MemoryFile:
    """Represent one in-memory publisher file."""

    content: str


class RecordingFileSystem:
    """Provide the publisher filesystem protocol without disk I/O."""

    def __init__(self, files: dict[Path, MemoryFile]) -> None:
        self.files = files
        self.directories: set[Path] = set()

    def list_files(self, root: Path) -> list[Path]:
        """Return deterministic in-memory descendants of root."""

        return sorted(path for path in self.files if path.is_relative_to(root))

    def is_dir(self, path: Path) -> bool:
        """Return whether a directory is tracked."""

        return path in self.directories

    def is_file(self, path: Path) -> bool:
        """Return whether a file is tracked."""

        return path in self.files

    def read_text(self, path: Path) -> str:
        """Read one in-memory file."""

        return self.files[path].content

    def write_text(self, path: Path, content: str) -> None:
        """Write one in-memory file."""

        self.files[path] = MemoryFile(content)
        self.directories.add(path.parent)

    def ensure_dir(self, path: Path) -> None:
        """Track a created directory."""

        self.directories.add(path)


def _publisher_module():
    """Import the public Codex publisher."""

    return importlib.import_module(
        "scripts.dev_tools.push_down_codex_and_agents_customizations"
    )


def _build_filesystem(repo_root: Path, destination_root: Path) -> RecordingFileSystem:
    """Build a repository and generic bundle with portable source fixtures."""

    codex_bundle = repo_root / CODEX_BUNDLE_RELATIVE
    claude_bundle = repo_root / CLAUDE_BUNDLE_RELATIVE
    portable_paths = [path.as_posix() for path in PORTABLE_CLAUDE_PATHS]
    files = {
        repo_root / ".codex/config.toml": MemoryFile("codex-config\n"),
        repo_root / BLAST_RADIUS_CONFIG: MemoryFile("repo-specific\n"),
        claude_bundle / BLAST_RADIUS_CONFIG: MemoryFile("generic-default\n"),
        repo_root / UNRELATED_CLAUDE_PATH: MemoryFile("unrelated\n"),
        codex_bundle
        / "pack-manifests/core.json": MemoryFile(
            json.dumps(
                {
                    "name": "core",
                    "paths": [
                        ".codex/config.toml",
                        *portable_paths,
                        BLAST_RADIUS_CONFIG.as_posix(),
                    ],
                }
            )
        ),
    }
    for relative_path in PORTABLE_CLAUDE_PATHS:
        content = f"portable:{relative_path.as_posix()}\n"
        files[repo_root / relative_path] = MemoryFile(content)
        files[claude_bundle / relative_path] = MemoryFile(content)
    fs = RecordingFileSystem(files)
    fs.directories.update({repo_root, destination_root})
    return fs


def test_public_publisher_emits_exact_portable_allowlist_and_generic_config() -> None:
    """Require the exact 15 assets and exclude unrelated Claude content."""

    module = _publisher_module()
    repo_root = Path("/repo")
    destination_root = Path("/dest")
    fs = _build_filesystem(repo_root, destination_root)

    module.push_down_customizations(
        repo_root=repo_root,
        destination_root=destination_root,
        source_root=repo_root,
        artifact_root=destination_root,
        bundle_root=repo_root / CODEX_BUNDLE_RELATIVE,
        packs=frozenset({"core"}),
        fs=fs,
    )

    expected_paths = {*PORTABLE_CLAUDE_PATHS, BLAST_RADIUS_CONFIG}
    published_paths = {
        path.relative_to(destination_root)
        for path in fs.files
        if path.is_relative_to(destination_root)
        and path.relative_to(destination_root) in expected_paths
    }
    assert len(PORTABLE_CLAUDE_PATHS) == 14
    assert published_paths == expected_paths
    assert fs.read_text(destination_root / BLAST_RADIUS_CONFIG) == "generic-default\n"
    assert not fs.is_file(destination_root / UNRELATED_CLAUDE_PATH)


def test_public_publisher_rejects_unequal_portable_destination_collision() -> None:
    """Require an unequal existing portable asset to fail before replacement."""

    module = _publisher_module()
    repo_root = Path("/repo")
    destination_root = Path("/dest")
    fs = _build_filesystem(repo_root, destination_root)
    collision_path = PORTABLE_CLAUDE_PATHS[0]
    fs.write_text(destination_root / collision_path, "destination-owned\n")

    with pytest.raises(ValueError, match=r"(?i)portable.*collision"):
        module.push_down_customizations(
            repo_root=repo_root,
            destination_root=destination_root,
            source_root=repo_root,
            artifact_root=destination_root,
            bundle_root=repo_root / CODEX_BUNDLE_RELATIVE,
            packs=frozenset({"core"}),
            fs=fs,
        )

    assert fs.read_text(destination_root / collision_path) == "destination-owned\n"
