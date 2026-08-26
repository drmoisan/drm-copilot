"""In-memory filesystem support for Codex customization publisher tests."""

from __future__ import annotations

import importlib
import json
from dataclasses import dataclass
from pathlib import Path

ROUTING_CONFIG_RESOURCE = Path(
    "extensions/drm-copilot/resources/config/orchestration-routing.json"
)
CODEX_BUNDLE_ROOT = "extensions/drm-copilot/resources/codex-and-agents-customizations"
AGENTS_VARIANT_RELATIVE = f"{CODEX_BUNDLE_ROOT}/.agents-variants/csharp-legacy"
CODEX_VARIANT_RELATIVE = f"{CODEX_BUNDLE_ROOT}/.codex-variants/csharp-legacy"
CSHARP_CANONICAL_PATHS = [
    ".agents/skills/csharp/SKILL.md",
    ".agents/skills/csharp-qa-gate/SKILL.md",
    ".agents/skills/invoke-csharp-engineer/SKILL.md",
    ".codex/agents/csharp-typed-engineer.toml",
]


@dataclass
class MemoryFile:
    """Represent one in-memory text file for publisher tests."""

    content: str


class RecordingFileSystem:
    """Provide a deterministic in-memory filesystem for publisher tests."""

    def __init__(self, *, files: dict[Path, MemoryFile] | None = None) -> None:
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


def load_module():
    """Import the Codex/agents push-down publisher under test."""

    return importlib.import_module(
        "scripts.dev_tools.push_down_codex_and_agents_customizations"
    )


def _manifest_payload(name: str, paths: list[str]) -> str:
    """Build a Codex pack manifest JSON payload."""

    return json.dumps({"name": name, "label": name.title(), "paths": paths})


def write_manifest(
    fs: RecordingFileSystem, repo_root: Path, name: str, paths: list[str]
) -> None:
    """Write one Codex manifest into the in-memory bundle."""

    fs.write_text(
        repo_root
        / "extensions"
        / "drm-copilot"
        / "resources"
        / "codex-and-agents-customizations"
        / "pack-manifests"
        / f"{name}.json",
        _manifest_payload(name, paths),
    )


_load_module = load_module
_write_manifest = write_manifest
