"""Pack selection, variant routing, and memory-mode helpers for `.claude` push-down.

Purpose:
    Provide the pure logic that the Claude customization push-down entry point
    uses to decide which `.claude`-relative files to publish, which C# variant
    source to read for each canonical destination path, and how to treat
    agent-memory files for the selected memory mode. The entry point
    (`push_down_claude_customizations`) composes these helpers with a filesystem
    wrapper and delegates the actual copy to the shared publisher engine.

Responsibilities:
    - Load and validate pack-manifest JSON files via an injected filesystem
      adapter (no direct disk I/O here).
    - Compute the set of `.claude`-relative destination paths to publish for a
      given pack selection, always including `core`.
    - Resolve the source-relative path to read for a destination path given the
      selected C# variant (`modern` reads from `.claude`, `legacy` reads from
      the bundle-only `.claude-variants/csharp-legacy/` subtree).
    - Assert C# mutual exclusion so the four canonical C# destination paths are
      written at most once each and a single run never selects both variants.

Usage:
    These functions are stateless and are called by
    `scripts.dev_tools.push_down_claude_customizations`. They never touch the
    real filesystem directly; all reads go through the `PushDownFileSystem`
    adapter supplied by the caller.

Invariants / Constraints:
    - All manifest paths are `.claude`-relative POSIX strings.
    - `core` is always part of the published set when any explicit pack
      selection is provided.
    - The four canonical C# destination paths are fixed and shared by the
      modern and legacy packs; only one variant may be selected per run.

Side Effects:
    None beyond reads performed through the injected adapter.
"""

from __future__ import annotations

import json
from dataclasses import dataclass
from typing import TYPE_CHECKING, Literal, cast

if TYPE_CHECKING:
    from pathlib import Path

    from scripts.dev_tools.push_down_copilot_customizations_filesystem import (
        PushDownFileSystem,
    )

# Pack name reserved for the always-included non-language customization set.
CORE_PACK_NAME = "core"

# The four canonical `.claude`-relative C# destination paths shared by the
# modern and legacy C# packs. Exactly one variant's content may land at these
# destinations in a single push-down run.
CSHARP_CANONICAL_PATHS: tuple[str, ...] = (
    ".claude/rules/csharp.md",
    ".claude/agents/csharp-typed-engineer.md",
    ".claude/skills/csharp-qa-gate/SKILL.md",
    ".claude/skills/invoke-csharp-engineer/SKILL.md",
)

# Pack names whose paths are the canonical C# toolchain. Selecting either pack
# contributes the same destination paths; the variant flag chooses the source.
CSHARP_PACK_NAMES: frozenset[str] = frozenset({"csharp-modern", "csharp-legacy"})

# Bundle-only source prefix for the legacy C# variant subtree. A legacy
# destination path's `.claude/` head is replaced with this prefix to locate the
# source file that holds the legacy profile content.
LEGACY_VARIANT_SOURCE_PREFIX = ".claude-variants/csharp-legacy"

CSharpVariant = Literal["modern", "legacy"]
MemoryMode = Literal["overwrite", "merge", "skip"]


class ManifestError(ValueError):
    """Raised when a pack manifest is missing or structurally invalid.

    Purpose:
        Signal a fail-fast condition when the push-down cannot trust the pack
        manifest inputs (a missing manifest file or a manifest that lacks the
        required keys or uses the wrong types). Raising a specific subclass of
        ``ValueError`` lets callers and tests distinguish manifest problems from
        unrelated value errors.

    Usage:
        Raised by ``load_pack_manifests`` only; not caught internally.

    Side Effects:
        None.
    """


@dataclass(frozen=True, slots=True)
class PackManifest:
    """Describe one loaded pack manifest.

    Purpose:
        Hold the validated contents of a single pack-manifest JSON file in a
        typed, immutable structure so downstream selection logic does not work
        with raw dictionaries.

    Usage:
        Produced by ``load_pack_manifests`` and consumed by
        ``compute_published_paths``.

    Invariants / Constraints:
        - ``name`` and ``label`` are non-empty strings.
        - ``paths`` is a tuple of `.claude`-relative POSIX path strings.
        - ``source_prefix`` is ``None`` for packs that read from `.claude`, or a
          bundle-relative prefix string for variant packs that read elsewhere.

    Attributes:
        name (str): Stable pack identifier (for example ``"python"``).
        label (str): Human-readable label used by the command UI.
        paths (tuple[str, ...]): The `.claude`-relative destination paths this
            pack contributes.
        source_prefix (str | None): Optional bundle-relative source prefix used
            by variant packs; ``None`` for normal packs.
    """

    name: str
    label: str
    paths: tuple[str, ...]
    source_prefix: str | None


def load_pack_manifests(
    manifest_dir: Path,
    selected_pack_names: frozenset[str],
    fs: PushDownFileSystem,
) -> dict[str, PackManifest]:
    """Load and validate the selected pack manifests from the bundle.

    Purpose:
        Read each selected manifest JSON through the injected filesystem
        adapter, validate its required structure, and return a mapping from pack
        name to its typed :class:`PackManifest`.

    Args:
        manifest_dir (Path): Directory holding ``<pack>.json`` manifest files,
            typically ``resources/claude-customizations/pack-manifests``.
        selected_pack_names (frozenset[str]): Pack names to load. ``core`` is
            loaded automatically even when it is not present in this set so the
            always-included contract holds.
        fs (PushDownFileSystem): Filesystem adapter used for existence checks
            and text reads. No direct disk I/O is performed here.

    Returns:
        dict[str, PackManifest]: Mapping of pack name to its validated manifest,
        including the ``core`` manifest.

    Raises:
        ManifestError: When a required manifest file is missing, is not valid
            JSON, is not a JSON object, or lacks valid ``name``/``label``/
            ``paths`` values.

    Side Effects:
        Reads manifest files through the injected adapter.
    """

    # Always load core in addition to the explicitly selected packs so the
    # always-included contract is satisfied at the loading stage.
    names_to_load = set(selected_pack_names) | {CORE_PACK_NAME}

    manifests: dict[str, PackManifest] = {}
    # Load each selected manifest deterministically (sorted) so any error order
    # is stable and reproducible across runs.
    for name in sorted(names_to_load):
        manifest_path = manifest_dir / f"{name}.json"
        if not fs.is_file(manifest_path):
            raise ManifestError(
                f"Pack manifest is missing for pack '{name}': {manifest_path}"
            )
        raw_text = fs.read_text(manifest_path)
        manifests[name] = _parse_manifest(name, manifest_path, raw_text)
    return manifests


def _parse_manifest(name: str, manifest_path: Path, raw_text: str) -> PackManifest:
    """Parse and validate one manifest's JSON text into a :class:`PackManifest`.

    Purpose:
        Centralize the structural validation of a single manifest so the loader
        stays focused on filesystem access and iteration.

    Args:
        name (str): The pack name expected for this manifest (the file stem).
        manifest_path (Path): The manifest path, used only for error messages.
        raw_text (str): The raw JSON text read from the manifest file.

    Returns:
        PackManifest: The validated, immutable manifest structure.

    Raises:
        ManifestError: When the text is not valid JSON, is not an object, or has
            missing or wrongly typed ``name``/``label``/``paths``/
            ``source_prefix`` values.

    Side Effects:
        None.
    """

    try:
        loaded: object = json.loads(raw_text)
    except json.JSONDecodeError as error:
        raise ManifestError(
            f"Pack manifest is not valid JSON for pack '{name}': {manifest_path}"
        ) from error

    if not isinstance(loaded, dict):
        raise ManifestError(
            f"Pack manifest must be a JSON object for pack '{name}': {manifest_path}"
        )

    # Treat the decoded mapping as untyped JSON values; each leaf is narrowed
    # explicitly below so the constructed PackManifest is fully typed.
    parsed = cast("dict[str, object]", loaded)
    manifest_name = parsed.get("name")
    manifest_label = parsed.get("label")
    manifest_paths = parsed.get("paths")
    source_prefix = parsed.get("source_prefix")

    # Validate the required string keys; both must be non-empty so the command
    # UI and selection logic always have a usable identifier and label.
    if not isinstance(manifest_name, str) or not manifest_name:
        raise ManifestError(
            f"Pack manifest 'name' must be a non-empty string: {manifest_path}"
        )
    if not isinstance(manifest_label, str) or not manifest_label:
        raise ManifestError(
            f"Pack manifest 'label' must be a non-empty string: {manifest_path}"
        )

    # Validate the paths array is a list of strings, building a typed list so the
    # PackManifest 'paths' tuple is str-typed for downstream consumers.
    if not isinstance(manifest_paths, list):
        raise ManifestError(
            f"Pack manifest 'paths' must be a list of strings: {manifest_path}"
        )
    raw_paths = cast("list[object]", manifest_paths)
    typed_paths: list[str] = []
    # Narrow each entry to str so a non-string element is rejected explicitly.
    for entry in raw_paths:
        if not isinstance(entry, str):
            raise ManifestError(
                f"Pack manifest 'paths' must be a list of strings: {manifest_path}"
            )
        typed_paths.append(entry)

    # source_prefix is optional; when present it must be a string so variant
    # source resolution can join it with the destination tail.
    if source_prefix is not None and not isinstance(source_prefix, str):
        raise ManifestError(
            f"Pack manifest 'source_prefix' must be a string when present: "
            f"{manifest_path}"
        )

    return PackManifest(
        name=manifest_name,
        label=manifest_label,
        paths=tuple(typed_paths),
        source_prefix=source_prefix,
    )


def compute_published_paths(
    selected_pack_names: frozenset[str] | None,
    manifests: dict[str, PackManifest],
) -> frozenset[str] | None:
    """Compute the `.claude`-relative destination paths to publish.

    Purpose:
        Translate a pack selection into the concrete set of destination paths
        the push-down should write, always unioning ``core`` into the result so
        the non-language customization set is never dropped.

    Args:
        selected_pack_names (frozenset[str] | None): The explicitly selected
            pack names, or ``None``/empty to signal the backward-compatible
            "publish everything" default.
        manifests (dict[str, PackManifest]): Loaded manifests for at least the
            selected packs plus ``core``.

    Returns:
        frozenset[str] | None: The union of the selected packs' paths plus
        ``core`` paths, or ``None`` when no explicit selection was made (the
        caller then publishes the full tree without manifest filtering).

    Raises:
        ManifestError: When a selected pack has no loaded manifest.

    Side Effects:
        None.
    """

    # An empty or None selection means the caller did not pass --packs, so the
    # backward-compatible default is to publish the full tree (signalled by
    # returning None rather than an empty set).
    if not selected_pack_names:
        return None

    # Always include core so the non-language baseline is published regardless
    # of whether the caller named it explicitly.
    effective_names = set(selected_pack_names) | {CORE_PACK_NAME}

    published: set[str] = set()
    # Union every selected pack's destination paths into the published set.
    for name in effective_names:
        manifest = manifests.get(name)
        if manifest is None:
            raise ManifestError(f"No loaded manifest for selected pack '{name}'.")
        published.update(manifest.paths)
    return frozenset(published)


def resolve_variant_source_path(
    destination_relative_path: str,
    csharp_variant: CSharpVariant,
) -> str:
    """Resolve the source-relative path to read for a destination path.

    Purpose:
        Route C# canonical destination paths to the correct source: the modern
        variant reads from `.claude`, while the legacy variant reads from the
        bundle-only `.claude-variants/csharp-legacy/` subtree. Non-C# paths and
        the modern variant always resolve to the destination path unchanged.

    Args:
        destination_relative_path (str): A `.claude`-relative destination path
            (for example ``.claude/rules/csharp.md``).
        csharp_variant (CSharpVariant): ``"modern"`` to read from `.claude`, or
            ``"legacy"`` to read the legacy variant source.

    Returns:
        str: The source-relative path to read. For ``modern`` or any non-C#
        path this equals ``destination_relative_path``. For ``legacy`` and a C#
        canonical path it is the path under
        ``.claude-variants/csharp-legacy/`` (the leading ``.claude/`` is
        replaced with the legacy prefix).

    Raises:
        None.

    Side Effects:
        None.
    """

    # Only the four canonical C# destinations are variant-routed; everything
    # else (and the modern variant) reads from its own destination path.
    if (
        csharp_variant == "legacy"
        and destination_relative_path in CSHARP_CANONICAL_PATHS
    ):
        # Replace the leading `.claude/` with the legacy variant prefix so the
        # source read targets the bundle-only legacy profile.
        tail = destination_relative_path[len(".claude/") :]
        return f"{LEGACY_VARIANT_SOURCE_PREFIX}/{tail}"
    return destination_relative_path


def assert_single_csharp_toolchain(
    published_paths: frozenset[str],
    selected_pack_names: frozenset[str],
) -> None:
    """Assert the C# selection yields exactly one toolchain at the destination.

    Purpose:
        Enforce C# mutual exclusion: the four canonical C# destination paths may
        be written at most once each, and a single run must not select both the
        modern and legacy C# packs (which would attempt to write two profiles to
        the same destination paths).

    Args:
        published_paths (frozenset[str]): The computed destination paths for the
            run. A set already deduplicates, so this is checked for the presence
            of the canonical paths rather than for literal duplicates.
        selected_pack_names (frozenset[str]): The selected pack names, used to
            detect selection of both C# variants in one run.

    Returns:
        None.

    Raises:
        ManifestError: When both ``csharp-modern`` and ``csharp-legacy`` are
            selected in the same run.

    Side Effects:
        None.
    """

    # Selecting both C# packs would route two different sources to the same four
    # canonical destinations; reject it so only one toolchain is ever written.
    selected_csharp = selected_pack_names & CSHARP_PACK_NAMES
    if len(selected_csharp) > 1:
        raise ManifestError(
            "C# mutual exclusion violated: both modern and legacy C# packs were "
            f"selected ({sorted(selected_csharp)}); select exactly one C# variant."
        )
