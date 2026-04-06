"""Tests for the `.codex` / `.agents` push-down publisher."""

from __future__ import annotations

import importlib
import io
import json
import sys
from contextlib import redirect_stdout
from dataclasses import dataclass
from pathlib import Path
from typing import TYPE_CHECKING

if TYPE_CHECKING:
    import pytest


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


def _bundled_scripts_root() -> Path:
    """Resolve the bundled `resources/scripts` root used by the extension."""

    repo_root = Path(__file__).resolve().parents[3]
    return repo_root / "extensions" / "drm-copilot" / "resources" / "scripts"


def _bundled_only_sys_path(repo_root: Path, bundled_scripts_root: Path) -> list[str]:
    """Build a sys.path that exposes bundled `dev_tools` without repo-root `scripts`."""

    filtered_path: list[str] = []
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


def _load_module():
    """Import the Codex/agents push-down publisher under test."""

    return importlib.import_module(
        "scripts.dev_tools.push_down_codex_and_agents_customizations"
    )


def test_bundled_module_imports_without_repo_root_scripts_package(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """Verify bundled import and CLI execution work with only packaged sources."""

    repo_root = Path(__file__).resolve().parents[3]
    bundled_scripts_root = _bundled_scripts_root()
    import_state = [
        "scripts",
        "scripts.dev_tools",
        "scripts.dev_tools.agentic_sync",
        "scripts.dev_tools.push_down_copilot_customizations",
        "scripts.dev_tools.push_down_copilot_customizations_filesystem",
        "scripts.dev_tools.push_down_copilot_customizations_rewrites",
        "scripts.dev_tools.push_down_codex_and_agents_customizations",
        "dev_tools",
        "dev_tools.agentic_sync",
        "dev_tools.push_down_copilot_customizations",
        "dev_tools.push_down_copilot_customizations_filesystem",
        "dev_tools.push_down_copilot_customizations_rewrites",
        "dev_tools.push_down_codex_and_agents_customizations",
    ]
    saved_modules = {name: sys.modules.get(name) for name in import_state}

    for module_name in import_state:
        sys.modules.pop(module_name, None)

    monkeypatch.setattr(
        sys,
        "path",
        _bundled_only_sys_path(repo_root, bundled_scripts_root),
    )
    importlib.invalidate_caches()

    try:
        module = importlib.import_module(
            "dev_tools.push_down_codex_and_agents_customizations"
        )
        assert callable(module.push_down_customizations)
        assert module.MODULE_ENTRY_POINT.endswith(
            "push_down_codex_and_agents_customizations"
        )
        source_root = Path("C:/repo")
        destination_root = Path("C:/dest")
        fs = RecordingFileSystem(
            files={
                source_root / ".codex" / "config.toml": MemoryFile("trusted = true\n"),
            }
        )
        fs.directories.update({source_root, source_root / ".codex", destination_root})

        exit_code = module.main(
            ["--destination", str(destination_root)],
            repo_root=source_root,
            fs=fs,
        )

        assert exit_code == 0
        assert (
            fs.read_text(destination_root / ".codex" / "config.toml")
            == "trusted = true\n"
        )
    finally:
        for module_name in import_state:
            sys.modules.pop(module_name, None)
        for module_name, module in saved_modules.items():
            if module is not None:
                sys.modules[module_name] = module


def test_push_down_customizations_copies_codex_and_agents_paths() -> None:
    """Verify the new publisher copies `.codex` and `.agents` paths unchanged."""

    module = _load_module()
    repo_root = Path("/repo")
    destination_root = Path("/dest")
    fs = RecordingFileSystem(
        files={
            repo_root / ".codex" / "config.toml": MemoryFile("trusted = true\n"),
            repo_root
            / ".codex"
            / "agents"
            / "orchestrator.toml": MemoryFile('name = "orchestrator"\n'),
            repo_root
            / ".agents"
            / "skills"
            / "policy-compliance-order"
            / "SKILL.md": MemoryFile("# Policy\n"),
        }
    )
    fs.directories.update(
        {
            repo_root,
            repo_root / ".codex",
            repo_root / ".codex" / "agents",
            repo_root / ".agents",
            repo_root / ".agents" / "skills",
            repo_root / ".agents" / "skills" / "policy-compliance-order",
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

    assert (
        fs.read_text(destination_root / ".codex" / "config.toml") == "trusted = true\n"
    )
    assert (
        fs.read_text(destination_root / ".codex" / "agents" / "orchestrator.toml")
        == 'name = "orchestrator"\n'
    )
    assert (
        fs.read_text(
            destination_root
            / ".agents"
            / "skills"
            / "policy-compliance-order"
            / "SKILL.md"
        )
        == "# Policy\n"
    )
    assert [result.relative_path for result in summary.files] == [
        ".codex/agents/orchestrator.toml",
        ".codex/config.toml",
        ".agents/skills/policy-compliance-order/SKILL.md",
    ]


def test_push_down_customizations_writes_codex_and_agents_artifact() -> None:
    """Verify the new publisher uses its own artifact directory and rewrite counts."""

    module = _load_module()
    repo_root = Path("C:/repo")
    destination_root = Path("C:/dest")
    fs = RecordingFileSystem(
        files={
            repo_root
            / ".agents"
            / "README.md": MemoryFile("Use the repo automation adapter.\n"),
        }
    )
    fs.directories.update({repo_root, repo_root / ".agents", destination_root})

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
    assert (
        "artifacts/codex-and-agents-customizations/push-down-" in summary.artifact_path
    )

    artifact_payload = json.loads(fs.read_text(Path(summary.artifact_path)))
    assert artifact_payload["destination_root"] == "C:/dest"
    assert artifact_payload["created_count"] == 1
    assert artifact_payload["rewritten_reference_count"] == 0
    assert artifact_payload["placeholder_rewrite_count"] == 0


def test_main_prints_summary_artifact_path_for_codex_and_agents_scope() -> None:
    """Verify the CLI prints the new artifact directory for the Codex/agents scope."""

    module = _load_module()
    repo_root = Path("C:/repo")
    destination_root = Path("C:/dest")
    fs = RecordingFileSystem(
        files={
            repo_root / ".codex" / "config.toml": MemoryFile("trusted = true\n"),
        }
    )
    fs.directories.update({repo_root, repo_root / ".codex", destination_root})

    output = io.StringIO()
    with redirect_stdout(output):
        exit_code = module.main(
            ["--destination", str(destination_root)],
            repo_root=repo_root,
            fs=fs,
        )

    assert exit_code == 0
    assert "artifacts/codex-and-agents-customizations/push-down-" in output.getvalue()
