"""Pack and legacy-variant tests for the Codex customization publisher."""

from __future__ import annotations

from pathlib import Path

from tests.scripts.dev_tools.push_down_customizations_test_support import (
    AGENTS_VARIANT_RELATIVE,
    CODEX_VARIANT_RELATIVE,
    CSHARP_CANONICAL_PATHS,
    MemoryFile,
    RecordingFileSystem,
)
from tests.scripts.dev_tools.push_down_customizations_test_support import (
    load_module as _load_module,
)
from tests.scripts.dev_tools.push_down_customizations_test_support import (
    write_manifest as _write_manifest,
)


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


def _seed_legacy_variant_tree(fs: RecordingFileSystem, repo_root: Path) -> None:
    """Seed the modern C# slot and legacy variant subtrees under ``repo_root``."""

    agents_variant_skills = f"{AGENTS_VARIANT_RELATIVE}/skills"
    codex_variant_agents = f"{CODEX_VARIANT_RELATIVE}/agents"
    seeded = {
        ".codex/config.toml": "core\n",
        ".agents/skills/csharp/SKILL.md": "modern csharp\n",
        ".agents/skills/csharp-qa-gate/SKILL.md": "modern qa\n",
        ".agents/skills/invoke-csharp-engineer/SKILL.md": "modern invoke\n",
        ".codex/agents/csharp-typed-engineer.toml": "modern agent\n",
        f"{agents_variant_skills}/csharp/SKILL.md": "legacy csharp\n",
        f"{agents_variant_skills}/csharp-qa-gate/SKILL.md": "legacy qa\n",
        f"{agents_variant_skills}/invoke-csharp-engineer/SKILL.md": "legacy invoke\n",
        f"{codex_variant_agents}/csharp-typed-engineer.toml": "legacy agent\n",
    }
    for relative_path, content in seeded.items():
        fs.write_text(repo_root / relative_path, content)
    fs.directories.add(repo_root)


def test_selected_legacy_csharp_writes_variant_content_to_canonical_paths() -> None:
    """Verify public C# selector writes legacy content to canonical paths."""

    module = _load_module()
    repo_root = Path("C:/repo")
    destination_root = Path("C:/dest")
    fs = RecordingFileSystem()
    _seed_legacy_variant_tree(fs, repo_root)
    fs.directories.add(destination_root)
    _write_manifest(fs, repo_root, "core", [".codex/config.toml"])
    _write_manifest(fs, repo_root, "csharp-legacy", CSHARP_CANONICAL_PATHS)

    cli_args = ["--destination", str(destination_root), "--packs", "core,csharp"]
    exit_code = module.main(
        [*cli_args, "--csharp-variant", "legacy"], repo_root=repo_root, fs=fs
    )

    assert exit_code == 0
    for canonical_relative, expected in (
        (".agents/skills/csharp/SKILL.md", "legacy csharp\n"),
        (".codex/agents/csharp-typed-engineer.toml", "legacy agent\n"),
    ):
        assert fs.read_text(destination_root / canonical_relative) == expected
    for variant_relative in (
        ".agents-variants/csharp-legacy/skills/csharp/SKILL.md",
        ".codex-variants/csharp-legacy/agents/csharp-typed-engineer.toml",
    ):
        assert not fs.is_file(destination_root / variant_relative)


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


def test_push_down_codex_repeated_generation_is_deterministic() -> None:
    """Verify two legacy-variant generations produce identical Codex output."""

    module = _load_module()
    repo_root = Path("C:/repo")
    destinations = (Path("C:/dest"), Path("C:/dest2"))
    artifact_root = Path("C:/artifacts")
    fs = RecordingFileSystem()
    _seed_legacy_variant_tree(fs, repo_root)
    fs.directories.update({*destinations, artifact_root})
    _write_manifest(fs, repo_root, "core", [".codex/config.toml"])
    _write_manifest(fs, repo_root, "csharp-legacy", CSHARP_CANONICAL_PATHS)

    for destination in destinations:
        module.push_down_customizations(
            repo_root=repo_root,
            destination_root=destination,
            fs=fs,
            source_root=repo_root,
            artifact_root=artifact_root,
            packs=frozenset({"core", "csharp"}),
            csharp_variant="legacy",
        )

    generations = [
        {
            path.relative_to(root).as_posix(): fs.read_text(path)
            for path in fs.list_files(root)
        }
        for root in destinations
    ]
    assert generations[0], "First generation must publish at least one file."
    assert generations[0] == generations[1]
