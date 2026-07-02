"""Publish bundled `.codex` and `.agents` content into a destination workspace.

Purpose:
    Provide a dedicated public entry point for the Codex/agents push-down
    workflow while reusing the shared publisher engine behind the existing
    `.github` customization flow.
"""

from __future__ import annotations

import argparse
import json
from pathlib import Path

try:
    from scripts.dev_tools.push_down_codex_filesystem import ExcludingFileSystem
    from scripts.dev_tools.push_down_codex_pack_selection import (
        CSharpVariant,
        ManifestError,
        MemoryMode,
        PackManifest,
        assert_single_csharp_toolchain,
        compute_published_paths,
        load_pack_manifests,
    )
    from scripts.dev_tools.push_down_copilot_customizations import (
        PushDownFileSystem,
        PushDownSummary,
        RealPushDownFileSystem,
        resolve_cli_path,
    )
    from scripts.dev_tools.push_down_copilot_customizations import (
        push_down_customizations as push_down_scoped_customizations,
    )
except ModuleNotFoundError as error:  # pragma: no cover - bundled import fallback
    if error.name is None or not error.name.startswith("scripts"):
        raise
    from dev_tools.push_down_codex_filesystem import ExcludingFileSystem
    from dev_tools.push_down_codex_pack_selection import (
        CSharpVariant,
        ManifestError,
        MemoryMode,
        PackManifest,
        assert_single_csharp_toolchain,
        compute_published_paths,
        load_pack_manifests,
    )
    from dev_tools.push_down_copilot_customizations import (
        PushDownFileSystem,
        PushDownSummary,
        RealPushDownFileSystem,
        resolve_cli_path,
    )
    from dev_tools.push_down_copilot_customizations import (
        push_down_customizations as push_down_scoped_customizations,
    )

ARTIFACT_DIRECTORY = "artifacts/codex-and-agents-customizations"
BUNDLE_ROOT_RELATIVE_DIR = Path(
    "extensions/drm-copilot/resources/codex-and-agents-customizations"
)
PACK_MANIFEST_SUBDIR = "pack-manifests"
MODULE_ENTRY_POINT = "scripts.dev_tools.push_down_codex_and_agents_customizations"
ROOT_FOLDERS: tuple[Path, ...] = (Path(".codex"), Path(".agents"))
CSHARP_VARIANT_CHOICES: tuple[str, ...] = ("modern", "legacy")
MEMORY_MODE_CHOICES: tuple[str, ...] = ("overwrite", "merge", "skip")

__all__ = [
    "ARTIFACT_DIRECTORY",
    "BUNDLE_ROOT_RELATIVE_DIR",
    "CSHARP_VARIANT_CHOICES",
    "MEMORY_MODE_CHOICES",
    "PACK_MANIFEST_SUBDIR",
    "ManifestError",
    "PushDownSummary",
    "main",
    "parse_args",
    "push_down_customizations",
]


def _passthrough_rewrite(
    text: str,
) -> tuple[str, int, int, list[str]]:
    """Return unmodified text for payloads that do not need command rewrites."""

    return text, 0, 0, []


def _resolve_published_paths(
    *,
    packs: frozenset[str] | None,
    bundle_root: Path,
    fs: PushDownFileSystem,
) -> frozenset[str] | None:
    """Compute selected Codex destination paths, or None for full-tree mode."""

    if not packs:
        return None
    manifest_dir = bundle_root / PACK_MANIFEST_SUBDIR
    manifests: dict[str, PackManifest] = load_pack_manifests(manifest_dir, packs, fs)
    published = compute_published_paths(packs, manifests)
    empty: frozenset[str] = frozenset()
    effective_published = published if published is not None else empty
    assert_single_csharp_toolchain(effective_published, packs)
    return effective_published


def _effective_pack_names(packs: frozenset[str] | None) -> list[str] | None:
    """Return sorted effective pack names, or None for full-tree mode."""

    if not packs:
        return None
    return sorted(set(packs) | {"core"})


def _record_selection_metadata(
    *,
    fs: PushDownFileSystem,
    summary: PushDownSummary,
    packs: frozenset[str] | None,
    csharp_variant: CSharpVariant,
    memory_mode: MemoryMode,
) -> None:
    """Add Codex selection metadata to the existing summary artifact."""

    artifact_path = Path(summary.artifact_path)
    payload = json.loads(fs.read_text(artifact_path))
    payload["codex_selection"] = {
        "effective_packs": _effective_pack_names(packs),
        "csharp_variant": csharp_variant,
        "memory_mode": memory_mode,
        "full_tree": not packs,
    }
    fs.write_text(artifact_path, json.dumps(payload, indent=2, sort_keys=True))


def push_down_customizations(
    *,
    repo_root: Path,
    destination_root: Path,
    fs: PushDownFileSystem,
    source_root: Path | None = None,
    artifact_root: Path | None = None,
    packs: frozenset[str] | None = None,
    csharp_variant: CSharpVariant = "modern",
    memory_mode: MemoryMode = "overwrite",
    bundle_root: Path | None = None,
) -> PushDownSummary:
    """Copy bundled `.codex` and `.agents` trees into the destination workspace."""

    effective_source = source_root if source_root is not None else repo_root
    effective_bundle = (
        bundle_root
        if bundle_root is not None
        else effective_source / BUNDLE_ROOT_RELATIVE_DIR
    )
    published_paths = _resolve_published_paths(
        packs=packs,
        bundle_root=effective_bundle,
        fs=fs,
    )
    excluding_fs = ExcludingFileSystem(
        fs,
        source_root=effective_source,
        published_paths=published_paths,
        csharp_variant=csharp_variant,
        variant_root=effective_bundle,
    )
    summary = push_down_scoped_customizations(
        repo_root=repo_root,
        destination_root=destination_root,
        fs=excluding_fs,
        source_root=source_root,
        artifact_root=artifact_root,
        root_folders=ROOT_FOLDERS,
        artifact_directory=ARTIFACT_DIRECTORY,
        rewrite_references=_passthrough_rewrite,
    )
    _record_selection_metadata(
        fs=fs,
        summary=summary,
        packs=packs,
        csharp_variant=csharp_variant,
        memory_mode=memory_mode,
    )
    return summary


def parse_args(argv: list[str] | None = None) -> argparse.Namespace:
    """Parse CLI arguments for the Codex/agents push-down publisher."""

    parser = argparse.ArgumentParser(
        description=(
            "Publish bundled Codex and agents customizations with "
            f"python -m {MODULE_ENTRY_POINT}."
        )
    )
    parser.add_argument(
        "--destination",
        required=True,
        help=(
            "Destination workspace root that will receive the copied .codex "
            "and .agents trees."
        ),
    )
    parser.add_argument(
        "--packs",
        default=None,
        help=(
            "Comma-separated Codex pack names to publish. When omitted or empty, "
            "the full .codex and .agents trees are published. 'core' is always "
            "included for explicit selections."
        ),
    )
    parser.add_argument(
        "--csharp-variant",
        dest="csharp_variant",
        choices=CSHARP_VARIANT_CHOICES,
        default="modern",
        help="C# toolchain variant to source ('modern' default or 'legacy').",
    )
    parser.add_argument(
        "--memory-mode",
        dest="memory_mode",
        choices=MEMORY_MODE_CHOICES,
        default="overwrite",
        help=(
            "Codex memory parity field: 'overwrite' (default), 'merge', or "
            "'skip'. It is inert unless Codex memory files are introduced."
        ),
    )
    return parser.parse_args(argv)


def _parse_packs_argument(packs_value: str | None) -> frozenset[str] | None:
    """Parse a comma-separated packs value into a normalized set."""

    if packs_value is None:
        return None
    names = {entry.strip() for entry in packs_value.split(",") if entry.strip()}
    if not names:
        return None
    return frozenset(names)


def main(
    argv: list[str] | None = None,
    *,
    repo_root: Path | None = None,
    fs: PushDownFileSystem | None = None,
) -> int:
    """Run the Codex/agents push-down publisher CLI."""

    args = parse_args(argv)
    resolved_repo_root = resolve_cli_path(repo_root or Path.cwd())
    resolved_destination = resolve_cli_path(args.destination)
    resolved_fs = fs or RealPushDownFileSystem()
    packs = _parse_packs_argument(args.packs)
    summary = push_down_customizations(
        repo_root=resolved_repo_root,
        destination_root=resolved_destination,
        fs=resolved_fs,
        source_root=resolved_repo_root,
        artifact_root=resolved_repo_root,
        packs=packs,
        csharp_variant=args.csharp_variant,
        memory_mode=args.memory_mode,
    )
    print(f"Wrote push-down summary artifact to: {summary.artifact_path}")
    return 0


if __name__ == "__main__":  # pragma: no cover - module entry point
    raise SystemExit(main())
