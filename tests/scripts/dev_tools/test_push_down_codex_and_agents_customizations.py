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
