"""Tests for the `.codex` / `.agents` push-down publisher."""

from __future__ import annotations

import io
import json
from contextlib import redirect_stdout
from pathlib import Path

from tests.scripts.dev_tools.push_down_customizations_test_support import (
    ROUTING_CONFIG_RESOURCE,
    MemoryFile,
    RecordingFileSystem,
)
from tests.scripts.dev_tools.push_down_customizations_test_support import (
    load_module as _load_module,
)
from tests.scripts.dev_tools.push_down_customizations_test_support import (
    write_manifest as _write_manifest,
)

REPO_ROOT = Path(__file__).resolve().parents[3]
CODEX_BUNDLE_ROOT = (
    REPO_ROOT
    / "extensions"
    / "drm-copilot"
    / "resources"
    / "codex-and-agents-customizations"
)
SHARED_CONFIG_ROOT = REPO_ROOT / "extensions" / "drm-copilot" / "resources"
HANDOFF_RUNTIME_PATHS = (
    Path(".agents/skills/orchestrate/SKILL.md"),
    Path(".agents/skills/orchestrator-state/SKILL.md"),
    Path(".codex/hooks/enforce-epic-planning-only.ps1"),
    Path("config/orchestration-handoff-registry.json"),
    Path("config/orchestration-handoff.schema.json"),
)
HANDOFF_SEMANTIC_TOOLS = {
    "drm-copilot.validate_orchestration_artifacts",
    "drm-copilot.resolve_orchestration_topology",
    "drm-copilot.resolve_provider_routing",
    "drm-copilot.transition_prepared_orchestration",
}


def _normalized_text(path: Path) -> str:
    """Read text with line endings and terminal newlines normalized."""

    return path.read_text(encoding="utf-8").replace("\r\n", "\n").rstrip("\n")


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


def test_push_down_customizations_excludes_ephemeral_codex_state() -> None:
    """Exclude runtime-only Codex state while retaining source customizations."""

    module = _load_module()
    repo_root = Path("C:/repo")
    destination_root = Path("C:/dest")
    state_path = (
        repo_root / ".codex" / "state" / "powershell-batch-budget.ephemeral.json"
    )
    fs = RecordingFileSystem(
        files={
            repo_root / ".codex" / "config.toml": MemoryFile("trusted = true\n"),
            repo_root
            / ".agents"
            / "skills"
            / "policy-compliance-order"
            / "SKILL.md": MemoryFile("# Policy\n"),
            state_path: MemoryFile('{"runtime": true}\n'),
        }
    )
    fs.directories.update(
        {
            repo_root,
            repo_root / ".codex",
            repo_root / ".codex" / "state",
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

    published_paths = [result.relative_path for result in summary.files]
    assert ".codex/config.toml" in published_paths
    assert ".agents/skills/policy-compliance-order/SKILL.md" in published_paths
    assert ".codex/state/powershell-batch-budget.ephemeral.json" not in published_paths


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


def test_handoff_runtime_has_root_bundle_resource_and_effective_pack_parity() -> None:
    """Every Codex handoff file is identical and present in each effective pack."""

    manifest_root = CODEX_BUNDLE_ROOT / "pack-manifests"
    core = json.loads((manifest_root / "core.json").read_text(encoding="utf-8"))
    core_paths = set(core["paths"])
    expected_paths = {path.as_posix() for path in HANDOFF_RUNTIME_PATHS}

    for relative_path in HANDOFF_RUNTIME_PATHS:
        canonical = REPO_ROOT / relative_path
        bundled = (
            SHARED_CONFIG_ROOT / relative_path
            if relative_path.parts[0] == "config"
            else CODEX_BUNDLE_ROOT / relative_path
        )
        assert _normalized_text(canonical) == _normalized_text(bundled), relative_path
    assert expected_paths <= core_paths

    for manifest_path in sorted(manifest_root.glob("*.json")):
        if manifest_path.name == "core.json":
            continue
        variant = json.loads(manifest_path.read_text(encoding="utf-8"))
        assert expected_paths <= core_paths.union(variant["paths"]), manifest_path.name


def test_every_selected_pack_generates_identical_handoff_runtime_files() -> None:
    """Core inclusion installs identical handoff files for every public variant."""

    module = _load_module()
    repo_root = Path("C:/repo")
    artifact_root = Path("C:/artifacts")
    fs = RecordingFileSystem()
    fs.directories.update({repo_root, artifact_root})
    expected: dict[Path, str] = {}
    for relative_path in HANDOFF_RUNTIME_PATHS:
        content = (REPO_ROOT / relative_path).read_text(encoding="utf-8")
        source_path = repo_root / relative_path
        if relative_path.parts[0] == "config":
            content = (SHARED_CONFIG_ROOT / relative_path).read_text(encoding="utf-8")
            source_path = (
                repo_root / "extensions" / "drm-copilot" / "resources" / relative_path
            )
        expected[relative_path] = content
        fs.write_text(source_path, content)
    _write_manifest(
        fs,
        repo_root,
        "core",
        [path.as_posix() for path in HANDOFF_RUNTIME_PATHS],
    )

    variants = (
        ("python", "python", "modern"),
        ("powershell", "powershell", "modern"),
        ("typescript", "typescript", "modern"),
        ("csharp", "csharp-modern", "modern"),
        ("csharp", "csharp-legacy", "legacy"),
    )
    marker = ".agents/skills/variant-marker/SKILL.md"
    fs.write_text(repo_root / marker, "variant marker\n")
    for index, (public_pack, manifest_name, csharp_variant) in enumerate(variants):
        destination = Path(f"C:/dest-{index}")
        fs.directories.add(destination)
        _write_manifest(fs, repo_root, manifest_name, [marker])

        module.push_down_customizations(
            repo_root=repo_root,
            destination_root=destination,
            fs=fs,
            source_root=repo_root,
            artifact_root=artifact_root,
            packs=frozenset({"core", public_pack}),
            csharp_variant=csharp_variant,
        )

        for relative_path, content in expected.items():
            assert fs.read_text(destination / relative_path) == content
        installed_registry = json.loads(
            fs.read_text(destination / "config/orchestration-handoff-registry.json")
        )
        assert HANDOFF_SEMANTIC_TOOLS <= set(installed_registry["semantic_tools"])


def test_consumer_authority_is_typescript_only_and_scope_owners_are_unchanged() -> None:
    """Installed authority avoids Python and leaves #467/#543 behavior unchanged."""

    authority_paths = (
        "repo-automation-tool-names.ts",
        "mcp-repo-automation-tool-definitions-handoff.ts",
        "mcp-handlers/orchestration-handoff-handlers.ts",
        "lib/validate/orchestration-handoff-authority-service.ts",
        "lib/validate/orchestration-handoff-contract.ts",
        "lib/validate/orchestration-handoff-provider-adapters.ts",
        "lib/validate/orchestration-handoff-materializer.ts",
    )
    source_root = REPO_ROOT / "extensions" / "drm-copilot" / "src"
    authority = "\n".join(
        (source_root / relative_path).read_text(encoding="utf-8")
        for relative_path in authority_paths
    )
    assert "scripts.dev_tools" not in authority
    assert "scripts/dev_tools" not in authority
    assert all(tool.partition(".")[2] in authority for tool in HANDOFF_SEMANTIC_TOOLS)

    codex_parallel_paths = (
        ".agents/skills/parallel-plan/SKILL.md",
        ".agents/skills/parallel-orchestrate/SKILL.md",
        ".agents/skills/parallel-run/SKILL.md",
        ".codex/agents/parallel-planner.toml",
        ".codex/agents/parallel-orchestrator.toml",
    )
    assert not any((REPO_ROOT / path).exists() for path in codex_parallel_paths)
    epic_validator = (
        REPO_ROOT / "scripts/dev_tools/validate_epic_planner_state.py"
    ).read_text(encoding="utf-8")
    ready_gate = epic_validator[
        epic_validator.index("if require_ready_for_execution:") :
    ]
    assert "validate_epic_planner_child_launch_bindings(features)" in ready_gate
