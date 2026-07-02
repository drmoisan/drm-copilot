"""Contract tests for bundled `.codex` / `.agents` customization resources."""

from __future__ import annotations

from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[3]
BUNDLED_ROOT = (
    REPO_ROOT
    / "extensions"
    / "drm-copilot"
    / "resources"
    / "codex-and-agents-customizations"
)
SCOPED_ROOTS: tuple[Path, ...] = (Path(".codex"), Path(".agents"))
PACK_MANIFEST_ROOT = Path("pack-manifests")
VARIANT_ROOTS: tuple[Path, ...] = (
    Path(".agents-variants"),
    Path(".codex-variants"),
)
REQUIRED_PACK_MANIFESTS = (
    Path("pack-manifests/core.json"),
    Path("pack-manifests/python.json"),
    Path("pack-manifests/powershell.json"),
    Path("pack-manifests/typescript.json"),
    Path("pack-manifests/csharp-modern.json"),
    Path("pack-manifests/csharp-legacy.json"),
)
REQUIRED_VARIANT_FILES = (
    Path(".agents-variants/csharp-legacy/skills/csharp/SKILL.md"),
    Path(".agents-variants/csharp-legacy/skills/csharp-qa-gate/SKILL.md"),
    Path(".agents-variants/csharp-legacy/skills/invoke-csharp-engineer/SKILL.md"),
    Path(".codex-variants/csharp-legacy/agents/csharp-typed-engineer.toml"),
)
REQUIRED_BUNDLED_FILES = (
    Path(".agents/README.md"),
    Path(".agents/skills/README.md"),
    Path(".agents/skills/atomic-executor/SKILL.md"),
    Path(".agents/skills/atomic-planner/SKILL.md"),
    Path(".agents/skills/orchestrator-workflow/SKILL.md"),
    Path(".agents/skills/repo-automation-adapter/agents/openai.yaml"),
    Path(".codex/config.toml"),
    Path(".codex/agents/atomic-executor.toml"),
    Path(".codex/agents/atomic-planner.toml"),
    Path(".codex/agents/orchestrator.toml"),
    Path(".codex/prompts/generate-pr.md"),
    Path(".codex/prompts/orchestrate-work.md"),
)


def list_scoped_files(root: Path) -> list[Path]:
    """Return scoped files in deterministic relative-path order."""

    files: list[Path] = []
    for scoped_root in SCOPED_ROOTS:
        scoped_path = root / scoped_root
        for path in scoped_path.rglob("*"):
            if path.is_file():
                files.append(path.relative_to(root))
    return sorted(files)


def list_bundle_only_files(root: Path) -> list[Path]:
    """Return bundle-only manifest and variant files."""

    files: list[Path] = []
    for scoped_root in (PACK_MANIFEST_ROOT, *VARIANT_ROOTS):
        scoped_path = root / scoped_root
        for path in scoped_path.rglob("*"):
            if path.is_file():
                files.append(path.relative_to(root))
    return sorted(files)


def read_text(root: Path, relative_path: Path) -> str:
    """Return UTF-8 text for a bundled or source payload file."""

    return (root / relative_path).read_text(encoding="utf-8")


def test_bundled_codex_and_agents_payload_contains_required_runtime_files() -> None:
    """Require the bundled payload to include the expected runtime support files."""

    bundled_files = list_scoped_files(BUNDLED_ROOT)

    assert bundled_files
    for relative_path in REQUIRED_BUNDLED_FILES:
        assert relative_path in bundled_files


def test_bundled_codex_pack_manifests_and_variants_exist() -> None:
    """Require Codex manifests and bundle-only C# variant resources."""

    bundled_files = list_bundle_only_files(BUNDLED_ROOT)

    for relative_path in REQUIRED_PACK_MANIFESTS:
        assert relative_path in bundled_files
    for relative_path in REQUIRED_VARIANT_FILES:
        assert relative_path in bundled_files


def test_bundled_codex_and_agents_payload_contains_all_repo_runtime_contracts() -> None:
    """Require the bundled payload to include all repo `.agents` and `.codex` files."""

    bundled_files = list_scoped_files(BUNDLED_ROOT)
    repo_runtime_files = list_scoped_files(REPO_ROOT)
    bundle_only_files = list_bundle_only_files(BUNDLED_ROOT)

    for relative_path in repo_runtime_files:
        assert relative_path not in bundle_only_files
        assert relative_path in bundled_files
        assert read_text(BUNDLED_ROOT, relative_path) == read_text(
            REPO_ROOT,
            relative_path,
        )
