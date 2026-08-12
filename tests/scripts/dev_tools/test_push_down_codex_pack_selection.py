"""Tests for Codex pack selection and C# variant routing."""

from __future__ import annotations

import importlib
import json
from dataclasses import dataclass
from pathlib import Path

import pytest

MANIFEST_DIR_RELATIVE = (
    "extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests"
)
REPO_ROOT = Path(__file__).resolve().parents[3]
REAL_MANIFEST_DIR = REPO_ROOT / MANIFEST_DIR_RELATIVE
PORTABLE_CLAUDE_PATHS = frozenset(
    {
        ".claude/lib/bash/compute-cohorts.sh",
        ".claude/lib/bash/compute-concurrency-batches.sh",
        ".claude/lib/bash/parallel-cohorts.sh",
        ".claude/lib/bash/parallel-common.sh",
        ".claude/lib/bash/parallel-items-validate.sh",
        ".claude/lib/bash/parallel-manifest-validate.sh",
        ".claude/lib/bash/parallel-yaml-emit.sh",
        ".claude/lib/bash/parallel-yaml-scan.sh",
        ".claude/lib/bash/validate-parallel-manifest.sh",
        ".claude/lib/blast-radius/BlastRadius.psm1",
        ".claude/lib/blast-radius/BlastRadiusConfig.psm1",
        ".claude/lib/blast-radius/BlastRadiusExtraction.psm1",
        ".claude/lib/blast-radius/BlastRadiusGlob.psm1",
        ".claude/lib/blast-radius/BlastRadiusValidation.psm1",
    }
)
COMMIT_STEWARD_PROFILE_PATHS = frozenset(
    f".codex/agents/commit-steward{suffix}.toml"
    for suffix in ("", "-c1", "-c2", "-c3", "-c3-elevated", "-c4")
)
SELECTED_PARALLEL_CORE_PATHS = frozenset(
    {
        ".agents/skills/parallel-add/SKILL.md",
        ".agents/skills/parallel-close/SKILL.md",
        ".agents/skills/parallel-orchestrate/SKILL.md",
        ".agents/skills/parallel-plan/SKILL.md",
        ".agents/skills/parallel-remove/SKILL.md",
        ".agents/skills/parallel-run/SKILL.md",
        ".codex/agents/parallel-orchestrator.toml",
        ".codex/agents/parallel-planner.toml",
        ".codex/hooks/authorize-root-parallel-invocation.ps1",
        ".codex/hooks/codex-authority-store.ps1",
        ".codex/hooks/enforce-codex-model-routing.ps1",
        ".codex/hooks/enforce-completion-consistency.ps1",
        ".codex/hooks/enforce-parallel-abandon-gate.ps1",
        ".codex/hooks/enforce-parallel-child-worktree-binding.ps1",
        ".codex/hooks/enforce-parallel-cohort-barrier.ps1",
        ".codex/hooks/enforce-parallel-drift-gate.ps1",
        ".codex/hooks/enforce-parallel-root-invocation.ps1",
        ".codex/hooks/enforce-parallel-worktree-removal-gate.ps1",
        ".codex/hooks/parallel-hook-common.ps1",
        ".codex/hooks/record-subagent-routing-attestation.ps1",
        ".codex/hooks/validate-codex-subagent-routing.ps1",
        ".codex/hooks/validate-parallel-agent-output.ps1",
        ".codex/scripts/codex-child-launch-contract-core.ps1",
        ".codex/scripts/codex-child-launch-persistence.ps1",
        ".codex/scripts/codex-child-launch-resume.ps1",
        ".codex/scripts/codex-child-launch-runtime.ps1",
        ".codex/scripts/launch-parallel-child-batch.ps1",
        ".codex/scripts/parallel-child-launch-contract.ps1",
        ".codex/scripts/parallel-child-post-session.ps1",
        ".codex/scripts/resume-parallel-child.ps1",
        ".codex/config.toml",
        "AGENTS.md",
        "config/blast-radius.json",
        "config/orchestration-routing.json",
        *PORTABLE_CLAUDE_PATHS,
        *COMMIT_STEWARD_PROFILE_PATHS,
    }
)


@dataclass
class MemoryFile:
    """Represent one in-memory text file."""

    content: str


class RecordingFileSystem:
    """Provide the filesystem methods used by the pack-selection helpers."""

    def __init__(self) -> None:
        self.files: dict[Path, MemoryFile] = {}

    def is_file(self, path: Path) -> bool:
        """Return whether the file exists."""

        return path in self.files

    def read_text(self, path: Path) -> str:
        """Return file content."""

        return self.files[path].content

    def write_text(self, path: Path, content: str) -> None:
        """Write file content."""

        self.files[path] = MemoryFile(content=content)


def _selection_module():
    """Import the Codex pack-selection helper module."""

    return importlib.import_module("scripts.dev_tools.push_down_codex_pack_selection")


def _manifest_payload(
    name: str, paths: list[str], source_prefix: str | None = None
) -> str:
    """Build a manifest JSON payload."""

    payload: dict[str, object] = {
        "name": name,
        "label": name.title(),
        "paths": paths,
    }
    if source_prefix is not None:
        payload["source_prefix"] = source_prefix
    return json.dumps(payload)


def _write_manifest(
    fs: RecordingFileSystem, source_root: Path, name: str, payload: str
) -> None:
    """Write one manifest into the in-memory bundle."""

    fs.write_text(source_root / MANIFEST_DIR_RELATIVE / f"{name}.json", payload)


def test_load_pack_manifests_parses_valid_manifest_and_core() -> None:
    """Verify selected manifest loading also loads core."""

    module = _selection_module()
    source_root = Path("/repo")
    fs = RecordingFileSystem()
    _write_manifest(
        fs,
        source_root,
        "core",
        _manifest_payload("core", [".codex/config.toml"]),
    )
    _write_manifest(
        fs,
        source_root,
        "typescript",
        _manifest_payload("typescript", [".agents/skills/typescript/SKILL.md"]),
    )

    manifests = module.load_pack_manifests(
        source_root / MANIFEST_DIR_RELATIVE, frozenset({"typescript"}), fs
    )

    assert sorted(manifests) == ["core", "typescript"]
    assert manifests["typescript"].paths == (".agents/skills/typescript/SKILL.md",)


def test_load_pack_manifests_raises_for_missing_manifest() -> None:
    """Verify missing selected manifests fail with a specific error."""

    module = _selection_module()
    source_root = Path("/repo")
    fs = RecordingFileSystem()
    _write_manifest(
        fs,
        source_root,
        "core",
        _manifest_payload("core", [".codex/config.toml"]),
    )

    with pytest.raises(module.ManifestError, match="python"):
        module.load_pack_manifests(
            source_root / MANIFEST_DIR_RELATIVE, frozenset({"python"}), fs
        )


def test_load_pack_manifests_raises_for_malformed_manifest() -> None:
    """Verify malformed JSON fails with a manifest error."""

    module = _selection_module()
    source_root = Path("/repo")
    fs = RecordingFileSystem()
    _write_manifest(fs, source_root, "core", "{not json")

    with pytest.raises(module.ManifestError, match="not valid JSON"):
        module.load_pack_manifests(
            source_root / MANIFEST_DIR_RELATIVE, frozenset({"core"}), fs
        )


@pytest.mark.parametrize(
    ("payload", "message"),
    [
        ("[]", "must be a JSON object"),
        (json.dumps({"paths": [".codex/config.toml"]}), "name"),
        (
            json.dumps({"name": "core", "label": "", "paths": [".codex/config.toml"]}),
            "label",
        ),
        (json.dumps({"name": "core", "paths": []}), "paths"),
        (json.dumps({"name": "core", "paths": [7]}), "paths"),
        (
            json.dumps(
                {
                    "name": "core",
                    "paths": [".codex/config.toml"],
                    "source_prefix": 7,
                }
            ),
            "source_prefix",
        ),
    ],
)
def test_load_pack_manifests_raises_for_invalid_manifest_shapes(
    payload: str, message: str
) -> None:
    """Verify every manifest structural validation branch is covered."""

    module = _selection_module()
    source_root = Path("/repo")
    fs = RecordingFileSystem()
    _write_manifest(fs, source_root, "core", payload)

    with pytest.raises(module.ManifestError, match=message):
        module.load_pack_manifests(
            source_root / MANIFEST_DIR_RELATIVE, frozenset({"core"}), fs
        )


def test_load_pack_manifests_raises_for_unknown_pack() -> None:
    """Verify unknown pack names fail before manifest reads."""

    module = _selection_module()

    with pytest.raises(module.ManifestError, match="Unknown Codex pack"):
        module.load_pack_manifests(
            Path("/bundle/pack-manifests"), frozenset({"ruby"}), RecordingFileSystem()
        )


def test_resolve_manifest_pack_names_maps_public_csharp_to_variant_manifest() -> None:
    """Verify public C# selection maps to the selected variant manifest."""

    module = _selection_module()

    assert module.resolve_manifest_pack_names(
        frozenset({"core", "csharp"}), "legacy"
    ) == frozenset({"core", "csharp-legacy"})
    assert module.resolve_manifest_pack_names(
        frozenset({"csharp"}), "modern"
    ) == frozenset({"csharp-modern"})


def test_resolve_manifest_pack_names_rejects_variant_specific_public_input() -> None:
    """Verify variant-specific pack names are not accepted as public input."""

    module = _selection_module()

    with pytest.raises(module.ManifestError, match="public Codex pack 'csharp'"):
        module.resolve_manifest_pack_names(
            frozenset({"csharp", "csharp-legacy"}), "legacy"
        )


def test_compute_published_paths_includes_core() -> None:
    """Verify explicit selections always include core."""

    module = _selection_module()
    manifests = {
        "core": module.PackManifest(
            name="core",
            label="Core",
            paths=(".codex/config.toml",),
            source_prefix=None,
        ),
        "typescript": module.PackManifest(
            name="typescript",
            label="TypeScript",
            paths=(".agents/skills/typescript/SKILL.md",),
            source_prefix=None,
        ),
    }

    published = module.compute_published_paths(frozenset({"typescript"}), manifests)

    assert published == frozenset(
        {".codex/config.toml", ".agents/skills/typescript/SKILL.md"}
    )


def test_selected_language_pack_inherits_the_complete_parallel_core() -> None:
    """Require explicit language selection to retain the exact core closure."""

    module = _selection_module()
    source_root = Path("/repo")
    fs = RecordingFileSystem()
    for name in ("core", "typescript"):
        _write_manifest(
            fs,
            source_root,
            name,
            (REAL_MANIFEST_DIR / f"{name}.json").read_text(encoding="utf-8"),
        )

    manifests = module.load_pack_manifests(
        source_root / MANIFEST_DIR_RELATIVE,
        frozenset({"typescript"}),
        fs,
    )
    published = module.compute_published_paths(
        frozenset({"core", "typescript"}), manifests
    )

    assert published is not None
    core_paths = manifests["core"].paths
    assert len(SELECTED_PARALLEL_CORE_PATHS) == 54
    assert SELECTED_PARALLEL_CORE_PATHS <= published
    assert {
        path for path in published if path.startswith(".codex/agents/commit-steward")
    } == COMMIT_STEWARD_PROFILE_PATHS
    for profile_path in COMMIT_STEWARD_PROFILE_PATHS:
        assert core_paths.count(profile_path) == 1
        assert profile_path not in manifests["typescript"].paths
    assert {path for path in published if path.startswith(".claude/")} == (
        PORTABLE_CLAUDE_PATHS
    )


def test_compute_published_paths_returns_none_for_empty_selection() -> None:
    """Verify omitted or empty packs mean full-tree mode."""

    module = _selection_module()

    assert module.compute_published_paths(None, {}) is None
    assert module.compute_published_paths(frozenset(), {}) is None


def test_compute_published_paths_raises_for_unloaded_manifest() -> None:
    """Verify selected packs must have loaded manifests."""

    module = _selection_module()

    with pytest.raises(module.ManifestError, match="No loaded Codex manifest"):
        module.compute_published_paths(frozenset({"python"}), {})


def test_codex_csharp_canonical_paths_are_declared() -> None:
    """Verify the C# pack targets the canonical Codex destination paths."""

    module = _selection_module()

    assert module.CSHARP_CANONICAL_PATHS == (
        ".agents/skills/csharp/SKILL.md",
        ".agents/skills/csharp-qa-gate/SKILL.md",
        ".agents/skills/invoke-csharp-engineer/SKILL.md",
        ".codex/agents/csharp-typed-engineer.toml",
    )


def test_resolve_variant_source_path_routes_agents_legacy_csharp() -> None:
    """Verify legacy `.agents` C# reads come from the variant root."""

    module = _selection_module()

    assert (
        module.resolve_variant_source_path(".agents/skills/csharp/SKILL.md", "legacy")
        == ".agents-variants/csharp-legacy/skills/csharp/SKILL.md"
    )


def test_resolve_variant_source_path_routes_codex_legacy_csharp() -> None:
    """Verify legacy `.codex` C# reads come from the variant root."""

    module = _selection_module()

    assert (
        module.resolve_variant_source_path(
            ".codex/agents/csharp-typed-engineer.toml", "legacy"
        )
        == ".codex-variants/csharp-legacy/agents/csharp-typed-engineer.toml"
    )


def test_resolve_variant_source_path_modern_and_non_csharp_are_identity() -> None:
    """Verify non-legacy or non-C# paths are not redirected."""

    module = _selection_module()

    assert (
        module.resolve_variant_source_path(".agents/skills/csharp/SKILL.md", "modern")
        == ".agents/skills/csharp/SKILL.md"
    )
    assert (
        module.resolve_variant_source_path(".agents/skills/python/SKILL.md", "legacy")
        == ".agents/skills/python/SKILL.md"
    )


def test_assert_single_csharp_toolchain_rejects_both_variants() -> None:
    """Verify selecting both C# variants fails before writes."""

    module = _selection_module()

    with pytest.raises(module.ManifestError, match="both modern and legacy"):
        module.assert_single_csharp_toolchain(
            frozenset(module.CSHARP_CANONICAL_PATHS),
            frozenset({"csharp-modern", "csharp-legacy"}),
        )
