"""Pack selection and C# variant routing for Codex push-down."""

from __future__ import annotations

import json
from dataclasses import dataclass
from typing import TYPE_CHECKING, Literal, cast

if TYPE_CHECKING:
    from pathlib import Path

    from scripts.dev_tools.push_down_copilot_customizations_filesystem import (
        PushDownFileSystem,
    )

CORE_PACK_NAME = "core"
SUPPORTED_PACK_NAMES: frozenset[str] = frozenset(
    {"core", "python", "powershell", "typescript", "csharp-modern", "csharp-legacy"}
)
CSHARP_CANONICAL_PATHS: tuple[str, ...] = (
    ".agents/skills/csharp/SKILL.md",
    ".agents/skills/csharp-qa-gate/SKILL.md",
    ".agents/skills/invoke-csharp-engineer/SKILL.md",
    ".codex/agents/csharp-typed-engineer.toml",
)
CSHARP_PACK_NAMES: frozenset[str] = frozenset({"csharp-modern", "csharp-legacy"})
AGENTS_LEGACY_VARIANT_SOURCE_PREFIX = ".agents-variants/csharp-legacy"
CODEX_LEGACY_VARIANT_SOURCE_PREFIX = ".codex-variants/csharp-legacy"

CSharpVariant = Literal["modern", "legacy"]
MemoryMode = Literal["overwrite", "merge", "skip"]


class ManifestError(ValueError):
    """Raised when a Codex pack selection or manifest is invalid."""


@dataclass(frozen=True, slots=True)
class PackManifest:
    """Represent one validated Codex pack manifest."""

    name: str
    label: str
    paths: tuple[str, ...]
    source_prefix: str | None


def load_pack_manifests(
    manifest_dir: Path,
    selected_pack_names: frozenset[str],
    fs: PushDownFileSystem,
) -> dict[str, PackManifest]:
    """Load selected Codex pack manifests, always including core."""

    unknown = selected_pack_names - SUPPORTED_PACK_NAMES
    if unknown:
        raise ManifestError(f"Unknown Codex pack name(s): {sorted(unknown)}")

    names_to_load = set(selected_pack_names) | {CORE_PACK_NAME}
    manifests: dict[str, PackManifest] = {}
    for name in sorted(names_to_load):
        manifest_path = manifest_dir / f"{name}.json"
        if not fs.is_file(manifest_path):
            raise ManifestError(
                f"Codex pack manifest is missing for pack '{name}': {manifest_path}"
            )
        raw_text = fs.read_text(manifest_path)
        manifests[name] = _parse_manifest(name, manifest_path, raw_text)
    return manifests


def _parse_manifest(name: str, manifest_path: Path, raw_text: str) -> PackManifest:
    """Parse one manifest and validate its required fields."""

    try:
        loaded: object = json.loads(raw_text)
    except json.JSONDecodeError as error:
        raise ManifestError(
            f"Codex pack manifest is not valid JSON for pack '{name}': {manifest_path}"
        ) from error

    if not isinstance(loaded, dict):
        raise ManifestError(
            f"Codex pack manifest must be a JSON object for pack '{name}': "
            f"{manifest_path}"
        )
    parsed = cast("dict[str, object]", loaded)
    manifest_name = parsed.get("name")
    manifest_label = parsed.get("label", manifest_name)
    manifest_paths = parsed.get("paths")
    source_prefix = parsed.get("source_prefix")

    if not isinstance(manifest_name, str) or not manifest_name:
        raise ManifestError(
            f"Codex pack manifest 'name' must be a non-empty string: {manifest_path}"
        )
    if not isinstance(manifest_label, str) or not manifest_label:
        raise ManifestError(
            f"Codex pack manifest 'label' must be a non-empty string: {manifest_path}"
        )
    if not isinstance(manifest_paths, list) or not manifest_paths:
        raise ManifestError(
            f"Codex pack manifest 'paths' must be a non-empty list of strings: "
            f"{manifest_path}"
        )
    paths: list[str] = []
    for entry in cast("list[object]", manifest_paths):
        if not isinstance(entry, str) or not entry:
            raise ManifestError(
                f"Codex pack manifest 'paths' must be a non-empty list of strings: "
                f"{manifest_path}"
            )
        paths.append(entry)
    if source_prefix is not None and not isinstance(source_prefix, str):
        raise ManifestError(
            f"Codex pack manifest 'source_prefix' must be a string when present: "
            f"{manifest_path}"
        )
    return PackManifest(
        name=manifest_name,
        label=manifest_label,
        paths=tuple(paths),
        source_prefix=source_prefix,
    )


def compute_published_paths(
    selected_pack_names: frozenset[str] | None,
    manifests: dict[str, PackManifest],
) -> frozenset[str] | None:
    """Return selected `.codex`/`.agents` destination paths or None for full tree."""

    if not selected_pack_names:
        return None

    effective_names = set(selected_pack_names) | {CORE_PACK_NAME}
    published: set[str] = set()
    for name in effective_names:
        manifest = manifests.get(name)
        if manifest is None:
            raise ManifestError(f"No loaded Codex manifest for selected pack '{name}'.")
        published.update(manifest.paths)
    return frozenset(published)


def resolve_variant_source_path(
    destination_relative_path: str,
    csharp_variant: CSharpVariant,
) -> str:
    """Return the source path for a canonical destination path."""

    if (
        csharp_variant == "legacy"
        and destination_relative_path in CSHARP_CANONICAL_PATHS
    ):
        if destination_relative_path.startswith(".agents/"):
            tail = destination_relative_path[len(".agents/") :]
            return f"{AGENTS_LEGACY_VARIANT_SOURCE_PREFIX}/{tail}"
        if destination_relative_path.startswith(".codex/"):
            tail = destination_relative_path[len(".codex/") :]
            return f"{CODEX_LEGACY_VARIANT_SOURCE_PREFIX}/{tail}"
    return destination_relative_path


def assert_single_csharp_toolchain(
    published_paths: frozenset[str],
    selected_pack_names: frozenset[str],
) -> None:
    """Reject a selection that includes both Codex C# variants."""

    selected_csharp = selected_pack_names & CSHARP_PACK_NAMES
    if len(selected_csharp) > 1:
        raise ManifestError(
            "C# mutual exclusion violated: both modern and legacy Codex C# packs "
            f"were selected ({sorted(selected_csharp)}); select exactly one C# "
            "variant."
        )
    _ = published_paths
