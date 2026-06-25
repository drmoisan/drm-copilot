"""Publish bundled `.claude` content into a destination workspace.

Purpose:
    Provide a dedicated public entry point for the Claude customization push-down
    workflow while reusing the shared publisher engine behind the existing
    `.github` customization flow. Settings-local configuration is excluded from
    push-down because it holds host-specific overrides that must not propagate.

    Agent-memory files under `.claude/agent-memory/` are filtered by a
    content-based scope check: only memories whose frontmatter declares
    `metadata.scope: general` are distributed to a destination workspace. A
    memory with an absent, malformed, or unrecognized scope is treated as
    `repo` and excluded (fail-safe default), so repository-specific memories do
    not leak into consumer workspaces. Files outside `.claude/agent-memory/`
    are copied verbatim and are never affected by the scope filter.
"""

from __future__ import annotations

import argparse
from pathlib import Path

try:
    from scripts.dev_tools.push_down_claude_filesystem import (
        AGENT_MEMORY_RELATIVE_ROOT,
        GENERAL_MEMORY_SCOPE,
        REPO_MEMORY_SCOPE,
        ExcludingFileSystem,
        is_general_memory_file,
        read_memory_scope,
    )
    from scripts.dev_tools.push_down_claude_pack_selection import (
        CSharpVariant,
        ManifestError,
        MemoryMode,
        PackManifest,
        assert_single_csharp_toolchain,
        compute_published_paths,
        load_pack_manifests,
    )
except ModuleNotFoundError as error:  # pragma: no cover - bundled import fallback
    if error.name is None or not error.name.startswith("scripts"):
        raise
    from dev_tools.push_down_claude_filesystem import (
        AGENT_MEMORY_RELATIVE_ROOT,
        GENERAL_MEMORY_SCOPE,
        REPO_MEMORY_SCOPE,
        ExcludingFileSystem,
        is_general_memory_file,
        read_memory_scope,
    )
    from dev_tools.push_down_claude_pack_selection import (
        CSharpVariant,
        ManifestError,
        MemoryMode,
        PackManifest,
        assert_single_csharp_toolchain,
        compute_published_paths,
        load_pack_manifests,
    )

# Repo-relative location of the bundle root that holds the pack manifests and
# the legacy variant subtree. In the repository CLI the source root is the repo
# root, so the manifests and variant live under this bundle path. The bundled
# template overrides ``bundle_root`` because its source root already is the
# bundle's ``claude-customizations`` directory.
BUNDLE_ROOT_RELATIVE_DIR = Path(
    "extensions/drm-copilot/resources/claude-customizations"
)
# Subdirectory under the bundle root that contains the pack-manifest JSON files.
PACK_MANIFEST_SUBDIR = "pack-manifests"
# Valid CLI choices for the C# variant and memory-mode arguments.
CSHARP_VARIANT_CHOICES: tuple[str, ...] = ("modern", "legacy")
MEMORY_MODE_CHOICES: tuple[str, ...] = ("overwrite", "merge", "skip")

try:
    from scripts.dev_tools.push_down_copilot_customizations import (
        PushDownFileSystem,
        PushDownSummary,
        RealPushDownFileSystem,
        resolve_cli_path,
    )
    from scripts.dev_tools.push_down_copilot_customizations import (
        push_down_customizations as push_down_scoped_customizations,
    )
except ModuleNotFoundError as error:
    if error.name is None or not error.name.startswith("scripts"):
        raise
    from dev_tools.push_down_copilot_customizations import (
        PushDownFileSystem,
        PushDownSummary,
        RealPushDownFileSystem,
        resolve_cli_path,
    )
    from dev_tools.push_down_copilot_customizations import (
        push_down_customizations as push_down_scoped_customizations,
    )

ARTIFACT_DIRECTORY = "artifacts/claude-customizations"
MODULE_ENTRY_POINT = "scripts.dev_tools.push_down_claude_customizations"
ROOT_FOLDERS: tuple[Path, ...] = (Path(".claude"),)
EXCLUDED_RELATIVE_PATHS: tuple[Path, ...] = (Path(".claude/settings.local.json"),)

__all__ = [
    "AGENT_MEMORY_RELATIVE_ROOT",
    "ARTIFACT_DIRECTORY",
    "CSHARP_VARIANT_CHOICES",
    "EXCLUDED_RELATIVE_PATHS",
    "GENERAL_MEMORY_SCOPE",
    "BUNDLE_ROOT_RELATIVE_DIR",
    "MEMORY_MODE_CHOICES",
    "PACK_MANIFEST_SUBDIR",
    "ManifestError",
    "PushDownSummary",
    "REPO_MEMORY_SCOPE",
    "ROOT_FOLDERS",
    "main",
    "parse_args",
    "push_down_customizations",
]

# Backward-compatible private aliases. The memory-scope helpers moved to
# ``push_down_claude_filesystem``; these aliases keep the prior import location
# stable for existing callers and tests that referenced the private names here.
_read_memory_scope = read_memory_scope
_is_general_memory_file = is_general_memory_file


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
    """Compute the published `.claude`-relative path set for a pack selection.

    Purpose:
        Load the selected pack manifests from the bundle, compute the union of
        their destination paths (always including ``core``), and assert C#
        mutual exclusion. Returns ``None`` when no pack selection was supplied so
        the publisher falls back to the backward-compatible publish-everything
        path with no manifest read.

    Args:
        packs (frozenset[str] | None): Selected pack names, or ``None``/empty for
            the publish-everything default.
        bundle_root (Path): Bundle root that contains the ``pack-manifests``
            subdirectory and the legacy variant subtree.
        fs (PushDownFileSystem): Adapter used to read the manifest files.

    Returns:
        frozenset[str] | None: The union of selected packs' paths plus ``core``,
        or ``None`` to signal the publish-everything default.

    Raises:
        ManifestError: When a manifest is missing/malformed or both C# variants
            are selected in the same run.

    Side Effects:
        Reads manifest files through the adapter when a selection is present.
    """

    # No explicit selection means the backward-compatible default: publish the
    # full tree without reading any manifest.
    if not packs:
        return None

    manifest_dir = bundle_root / PACK_MANIFEST_SUBDIR
    manifests: dict[str, PackManifest] = load_pack_manifests(manifest_dir, packs, fs)
    published = compute_published_paths(packs, manifests)
    # compute_published_paths returns None only for an empty selection, which the
    # early return above already excluded; treat a None here as an empty set so
    # the C# exclusion check still runs on a concrete value.
    empty: frozenset[str] = frozenset()
    effective_published = published if published is not None else empty
    assert_single_csharp_toolchain(effective_published, packs)
    return effective_published


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
    """Copy the `.claude` tree into the destination workspace.

    Purpose:
        Publish the bundled `.claude` customizations into a destination
        workspace, optionally filtered to a set of language packs, optionally
        sourcing the C# toolchain from the legacy variant, and applying the
        selected agent-memory mode.

    Args:
        repo_root (Path): Source repository root.
        destination_root (Path): Destination workspace root.
        fs (PushDownFileSystem): Filesystem adapter.
        source_root (Path | None): Explicit source root for packaged content;
            defaults to ``repo_root``.
        artifact_root (Path | None): Explicit artifact root; defaults to
            ``repo_root``.
        packs (frozenset[str] | None): Selected pack names. ``None``/empty
            publishes the full tree (backward-compatible default) with no
            manifest read and no variant routing.
        csharp_variant (CSharpVariant): ``"modern"`` (default) reads C# files
            from `.claude`; ``"legacy"`` reads them from the bundle-only legacy
            variant subtree while still writing the canonical destination paths.
        memory_mode (MemoryMode): ``overwrite`` (default), ``merge``, or
            ``skip`` for agent-memory handling.
        bundle_root (Path | None): Root that holds the ``pack-manifests``
            subdirectory and the legacy variant subtree. Defaults to
            ``source_root / BUNDLE_ROOT_RELATIVE_DIR`` (the repository CLI
            layout). The bundled template passes its ``claude-customizations``
            directory directly because its source root already is that bundle.

    Returns:
        PushDownSummary: The shared engine's run summary.

    Raises:
        ManifestError: When a selected manifest is missing/malformed or both C#
            variants are selected.

    Side Effects:
        Reads source files and writes destination files and the summary artifact
        through the adapter.
    """

    effective_source = source_root if source_root is not None else repo_root
    # Resolve the bundle root that holds manifests and the variant subtree. The
    # repository CLI nests the bundle under the source root; the template passes
    # its own bundle directory directly.
    effective_bundle = (
        bundle_root
        if bundle_root is not None
        else effective_source / BUNDLE_ROOT_RELATIVE_DIR
    )
    # Resolve the published-path set only when a pack selection is supplied so
    # the no-argument path performs no manifest I/O and stays byte-equivalent.
    published_paths = _resolve_published_paths(
        packs=packs,
        bundle_root=effective_bundle,
        fs=fs,
    )

    # Wrap the caller-supplied adapter so enumeration omits excluded paths and
    # honors the pack, variant, and memory-mode selections.
    excluding_fs = ExcludingFileSystem(
        fs,
        repo_root,
        EXCLUDED_RELATIVE_PATHS,
        source_root=effective_source,
        destination_root=destination_root,
        published_paths=published_paths,
        csharp_variant=csharp_variant,
        memory_mode=memory_mode,
        variant_root=effective_bundle,
    )
    return push_down_scoped_customizations(
        repo_root=repo_root,
        destination_root=destination_root,
        fs=excluding_fs,
        source_root=source_root,
        artifact_root=artifact_root,
        root_folders=ROOT_FOLDERS,
        artifact_directory=ARTIFACT_DIRECTORY,
        rewrite_references=_passthrough_rewrite,
    )


def parse_args(argv: list[str] | None = None) -> argparse.Namespace:
    """Parse CLI arguments for the Claude customization push-down publisher.

    Purpose:
        Define the CLI contract, including the optional pack selection, C#
        variant, and memory-mode flags. When the optional flags are omitted the
        parsed namespace yields the backward-compatible defaults
        (``packs=None``, ``csharp_variant="modern"``, ``memory_mode="overwrite"``).

    Args:
        argv (list[str] | None): Optional argument list for tests or embedding.

    Returns:
        argparse.Namespace: Parsed arguments with attributes ``destination``,
        ``packs``, ``csharp_variant``, and ``memory_mode``.

    Raises:
        SystemExit: Raised by ``argparse`` when arguments are invalid.

    Side Effects:
        Emits usage/help text through ``argparse`` when parsing fails.
    """

    parser = argparse.ArgumentParser(
        description=(
            "Publish bundled Claude customizations with "
            f"python -m {MODULE_ENTRY_POINT}."
        )
    )
    parser.add_argument(
        "--destination",
        required=True,
        help=("Destination workspace root that will receive the copied .claude tree."),
    )
    parser.add_argument(
        "--packs",
        default=None,
        help=(
            "Comma-separated language pack names to publish (for example "
            "'core,typescript'). When omitted, the full tree is published. "
            "'core' is always included."
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
            "Agent-memory handling mode: 'overwrite' (default), 'merge', or " "'skip'."
        ),
    )
    return parser.parse_args(argv)


def _parse_packs_argument(packs_value: str | None) -> frozenset[str] | None:
    """Parse the raw ``--packs`` CLI value into a normalized pack-name set.

    Args:
        packs_value (str | None): The raw comma-separated value, or ``None`` when
            the flag was omitted.

    Returns:
        frozenset[str] | None: The set of non-empty, stripped pack names, or
        ``None`` when the flag was omitted or contained only empty entries (the
        publish-everything default).
    """

    if packs_value is None:
        return None
    # Strip whitespace and drop empty entries so trailing commas or stray spaces
    # do not produce empty pack names.
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
    """Run the Claude customization push-down publisher CLI.

    Parses arguments, resolves defaults, threads the pack selection, C# variant,
    and memory mode into ``push_down_customizations``, and prints the summary
    artifact path. With no optional flags this is byte-for-byte equivalent to
    the prior publish-everything/overwrite behavior.
    """

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


if __name__ == "__main__":
    raise SystemExit(main())
