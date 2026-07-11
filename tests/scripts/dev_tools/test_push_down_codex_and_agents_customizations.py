"""Tests for the `.codex` / `.agents` push-down publisher."""

from __future__ import annotations

import importlib
import io
import json
from contextlib import redirect_stdout
from dataclasses import dataclass
from pathlib import Path

ROUTING_CONFIG_RESOURCE = Path(
    "extensions/drm-copilot/resources/config/orchestration-routing.json"
)


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


def _load_module():
    """Import the Codex/agents push-down publisher under test."""

    return importlib.import_module(
        "scripts.dev_tools.push_down_codex_and_agents_customizations"
    )


def _manifest_payload(name: str, paths: list[str]) -> str:
    """Build a Codex pack manifest JSON payload."""

    return json.dumps({"name": name, "label": name.title(), "paths": paths})


def _write_manifest(
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


def test_push_down_customizations_copies_codex_and_agents_paths() -> None:
    """Verify the new publisher copies `.codex` and `.agents` paths unchanged."""

    module = _load_module()
    repo_root = Path("C:/repo")
    destination_root = Path("C:/dest")
    fs = RecordingFileSystem(
        files={
            repo_root / ROUTING_CONFIG_RESOURCE: MemoryFile('{"version": 1}\n'),
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
    assert (
        fs.read_text(destination_root / "config" / "orchestration-routing.json")
        == '{"version": 1}\n'
    )
    assert [result.relative_path for result in summary.files] == [
        ".codex/agents/orchestrator.toml",
        ".codex/config.toml",
        ".agents/skills/policy-compliance-order/SKILL.md",
        "config/orchestration-routing.json",
    ]


def test_no_argument_push_down_publishes_full_tree_and_artifact_path() -> None:
    """Verify omitted packs keeps full `.codex` and `.agents` behavior."""

    module = _load_module()
    repo_root = Path("/repo")
    destination_root = Path("/dest")
    fs = RecordingFileSystem(
        files={
            repo_root / ".codex" / "config.toml": MemoryFile("config\n"),
            repo_root / ".codex" / "agents" / "python.toml": MemoryFile("py\n"),
            repo_root
            / ".agents"
            / "skills"
            / "python"
            / "SKILL.md": MemoryFile("python\n"),
            repo_root
            / ".agents"
            / "skills"
            / "csharp"
            / "SKILL.md": MemoryFile("csharp\n"),
        }
    )
    fs.directories.update({repo_root, destination_root})

    summary = module.push_down_customizations(
        repo_root=repo_root,
        destination_root=destination_root,
        fs=fs,
        source_root=repo_root,
        artifact_root=destination_root,
    )

    assert fs.read_text(destination_root / ".codex" / "config.toml") == "config\n"
    assert (
        fs.read_text(destination_root / ".agents" / "skills" / "python" / "SKILL.md")
        == "python\n"
    )
    assert (
        fs.read_text(destination_root / ".agents" / "skills" / "csharp" / "SKILL.md")
        == "csharp\n"
    )
    assert (
        "artifacts/codex-and-agents-customizations/push-down-" in summary.artifact_path
    )


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
    assert artifact_payload["codex_selection"] == {
        "csharp_variant": "modern",
        "effective_packs": None,
        "full_tree": True,
        "memory_mode": "overwrite",
    }


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


def test_selected_typescript_pack_writes_only_core_and_typescript_paths() -> None:
    """Verify explicit TypeScript selection excludes other language packs."""

    module = _load_module()
    repo_root = Path("/repo")
    destination_root = Path("/dest")
    fs = RecordingFileSystem(
        files={
            repo_root / ".codex" / "config.toml": MemoryFile("core\n"),
            repo_root
            / ".agents"
            / "skills"
            / "typescript"
            / "SKILL.md": MemoryFile("ts\n"),
            repo_root
            / ".agents"
            / "skills"
            / "python"
            / "SKILL.md": MemoryFile("py\n"),
            repo_root
            / ".agents"
            / "skills"
            / "powershell"
            / "SKILL.md": MemoryFile("ps\n"),
            repo_root
            / ".agents"
            / "skills"
            / "csharp"
            / "SKILL.md": MemoryFile("cs\n"),
        }
    )
    fs.directories.update({repo_root, destination_root})
    _write_manifest(fs, repo_root, "core", [".codex/config.toml"])
    _write_manifest(
        fs,
        repo_root,
        "typescript",
        [".agents/skills/typescript/SKILL.md"],
    )

    module.push_down_customizations(
        repo_root=repo_root,
        destination_root=destination_root,
        fs=fs,
        source_root=repo_root,
        artifact_root=destination_root,
        packs=frozenset({"core", "typescript"}),
    )

    assert fs.is_file(destination_root / ".codex" / "config.toml")
    assert fs.is_file(
        destination_root / ".agents" / "skills" / "typescript" / "SKILL.md"
    )
    assert not fs.is_file(
        destination_root / ".agents" / "skills" / "python" / "SKILL.md"
    )
    assert not fs.is_file(
        destination_root / ".agents" / "skills" / "powershell" / "SKILL.md"
    )
    assert not fs.is_file(
        destination_root / ".agents" / "skills" / "csharp" / "SKILL.md"
    )


def test_selected_legacy_csharp_writes_variant_content_to_canonical_paths() -> None:
    """Verify public C# selector writes legacy content to canonical paths."""

    module = _load_module()
    repo_root = Path("C:/repo")
    destination_root = Path("C:/dest")
    fs = RecordingFileSystem(
        files={
            repo_root / ".codex" / "config.toml": MemoryFile("core\n"),
            repo_root
            / ".agents"
            / "skills"
            / "csharp"
            / "SKILL.md": MemoryFile("modern csharp\n"),
            repo_root
            / ".agents"
            / "skills"
            / "csharp-qa-gate"
            / "SKILL.md": MemoryFile("modern qa\n"),
            repo_root
            / ".agents"
            / "skills"
            / "invoke-csharp-engineer"
            / "SKILL.md": MemoryFile("modern invoke\n"),
            repo_root
            / ".codex"
            / "agents"
            / "csharp-typed-engineer.toml": MemoryFile("modern agent\n"),
            repo_root
            / "extensions"
            / "drm-copilot"
            / "resources"
            / "codex-and-agents-customizations"
            / ".agents-variants"
            / "csharp-legacy"
            / "skills"
            / "csharp"
            / "SKILL.md": MemoryFile("legacy csharp\n"),
            repo_root
            / "extensions"
            / "drm-copilot"
            / "resources"
            / "codex-and-agents-customizations"
            / ".agents-variants"
            / "csharp-legacy"
            / "skills"
            / "csharp-qa-gate"
            / "SKILL.md": MemoryFile("legacy qa\n"),
            repo_root
            / "extensions"
            / "drm-copilot"
            / "resources"
            / "codex-and-agents-customizations"
            / ".agents-variants"
            / "csharp-legacy"
            / "skills"
            / "invoke-csharp-engineer"
            / "SKILL.md": MemoryFile("legacy invoke\n"),
            repo_root
            / "extensions"
            / "drm-copilot"
            / "resources"
            / "codex-and-agents-customizations"
            / ".codex-variants"
            / "csharp-legacy"
            / "agents"
            / "csharp-typed-engineer.toml": MemoryFile("legacy agent\n"),
        }
    )
    fs.directories.update({repo_root, destination_root})
    csharp_paths = [
        ".agents/skills/csharp/SKILL.md",
        ".agents/skills/csharp-qa-gate/SKILL.md",
        ".agents/skills/invoke-csharp-engineer/SKILL.md",
        ".codex/agents/csharp-typed-engineer.toml",
    ]
    _write_manifest(fs, repo_root, "core", [".codex/config.toml"])
    _write_manifest(fs, repo_root, "csharp-legacy", csharp_paths)

    exit_code = module.main(
        [
            "--destination",
            str(destination_root),
            "--packs",
            "core,csharp",
            "--csharp-variant",
            "legacy",
        ],
        repo_root=repo_root,
        fs=fs,
    )

    assert exit_code == 0
    assert (
        fs.read_text(destination_root / ".agents" / "skills" / "csharp" / "SKILL.md")
        == "legacy csharp\n"
    )
    assert (
        fs.read_text(
            destination_root / ".codex" / "agents" / "csharp-typed-engineer.toml"
        )
        == "legacy agent\n"
    )
    assert not fs.is_file(
        destination_root
        / ".agents-variants"
        / "csharp-legacy"
        / "skills"
        / "csharp"
        / "SKILL.md"
    )
    assert not fs.is_file(
        destination_root
        / ".codex-variants"
        / "csharp-legacy"
        / "agents"
        / "csharp-typed-engineer.toml"
    )


def test_invalid_csharp_variant_pack_combination_fails_before_writes() -> None:
    """Verify variant-specific public input is rejected before destination writes."""

    module = _load_module()
    repo_root = Path("/repo")
    destination_root = Path("/dest")
    fs = RecordingFileSystem(
        files={
            repo_root / ".codex" / "config.toml": MemoryFile("core\n"),
        }
    )
    fs.directories.update({repo_root, destination_root})

    try:
        module.push_down_customizations(
            repo_root=repo_root,
            destination_root=destination_root,
            fs=fs,
            source_root=repo_root,
            artifact_root=destination_root,
            packs=frozenset({"csharp", "csharp-legacy"}),
            csharp_variant="legacy",
        )
    except module.ManifestError as error:
        assert "public Codex pack 'csharp'" in str(error)
    else:
        raise AssertionError("Expected ManifestError for invalid C# pack combination.")

    assert not fs.is_file(destination_root / ".codex" / "config.toml")
