"""Bundled template entry point for the `.claude` customization push-down.

Purpose:
    Provide the extension-invoked CLI that publishes the bundled `.claude`
    payload into a destination workspace. This template bootstraps the bundled
    ``resources/scripts`` directory onto ``sys.path`` and then delegates all
    pack-selection, C# variant-routing, and memory-mode logic to the bundled
    ``push_down_claude_customizations`` engine module so the template and the
    repository source stay behaviorally identical.

    Settings-local configuration is excluded from push-down because it holds
    host-specific overrides. Agent-memory files under `.claude/agent-memory/`
    are filtered by the engine's content-based scope check; only general-scoped
    memories are distributed.

Responsibilities:
    - Ensure the bundled scripts directory is importable when invoked directly
      from ``resources/templates/``.
    - Parse the CLI arguments (``--destination``, ``--packs``,
      ``--csharp-variant``, ``--memory-mode``).
    - Resolve the source root and bundle root to the sibling bundled
      ``claude-customizations`` directory so the template distributes the
      bundled payload rather than a destination workspace's own `.claude`.

Side Effects:
    Mutates ``sys.path`` at import time; reads bundled source files and writes
    destination files through the publisher engine.
"""

from __future__ import annotations

import argparse
import sys
from pathlib import Path


def _ensure_bundled_scripts_import_path() -> None:
    """Prepend bundled ``resources/scripts`` directory to ``sys.path``.

    Purpose:
        Make extension-bundled Python packages importable when this template is
        invoked directly from ``resources/templates/`` rather than from the
        repository root. Without this bootstrap, neither
        ``scripts.dev_tools.push_down_claude_customizations`` nor the fallback
        ``dev_tools.push_down_claude_customizations`` import resolves because
        ``resources/scripts`` is not on ``sys.path`` by default.

    Side Effects:
        Mutates ``sys.path`` by inserting the bundled scripts directory at
        index 0 when not already present.
    """
    scripts_dir = Path(__file__).resolve().parent.parent / "scripts"
    scripts_dir_str = str(scripts_dir)

    if scripts_dir_str not in sys.path:
        sys.path.insert(0, scripts_dir_str)


_ensure_bundled_scripts_import_path()

try:
    from scripts.dev_tools.push_down_claude_customizations import (
        CSHARP_VARIANT_CHOICES,
        MEMORY_MODE_CHOICES,
        PushDownSummary,
        push_down_customizations,
    )
    from scripts.dev_tools.push_down_copilot_customizations import (
        PushDownFileSystem,
        RealPushDownFileSystem,
        resolve_cli_path,
    )
except ModuleNotFoundError as error:
    if error.name is None or not error.name.startswith("scripts"):
        raise
    from dev_tools.push_down_claude_customizations import (
        CSHARP_VARIANT_CHOICES,
        MEMORY_MODE_CHOICES,
        PushDownSummary,
        push_down_customizations,
    )
    from dev_tools.push_down_copilot_customizations import (
        PushDownFileSystem,
        RealPushDownFileSystem,
        resolve_cli_path,
    )

MODULE_ENTRY_POINT = "scripts.dev_tools.push_down_claude_customizations"

__all__ = ["main", "parse_args"]


def parse_args(argv: list[str] | None = None) -> argparse.Namespace:
    """Parse CLI arguments for the bundled Claude customization push-down.

    Purpose:
        Mirror the repository entry point's CLI contract, including the optional
        ``--packs``, ``--csharp-variant``, and ``--memory-mode`` flags. With no
        optional flags the parsed namespace yields the backward-compatible
        defaults (``packs=None``, ``csharp_variant="modern"``,
        ``memory_mode="overwrite"``).

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
        help=("Agent-memory handling mode: 'overwrite' (default), 'merge', or 'skip'."),
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
    """Run the bundled Claude customization push-down publisher CLI.

    Purpose:
        Parse arguments, resolve the source and bundle roots to the sibling
        bundled ``claude-customizations`` directory, thread the pack selection,
        C# variant, and memory mode into the engine, and print the summary
        artifact path. With no optional flags this is byte-for-byte equivalent
        to the prior bundled publish-everything/overwrite behavior.

    Args:
        argv (list[str] | None): Optional CLI argument list.
        repo_root (Path | None): Optional explicit source root for tests; when
            absent, the bundled ``claude-customizations`` directory is used.
        fs (PushDownFileSystem | None): Optional filesystem adapter for tests.

    Returns:
        int: Process exit code (``0`` on success).

    Side Effects:
        Reads bundled source files and writes destination files and the summary
        artifact through the adapter.
    """
    args = parse_args(argv)
    # Resolve the source root to the bundled customizations directory so the
    # template distributes the bundled `.claude` payload rather than copying a
    # destination workspace's existing `.claude` back onto itself. The bundle
    # root that holds the pack manifests and legacy variant subtree is the same
    # customizations directory. The optional `repo_root` argument still allows
    # tests to inject an explicit root.
    customizations_root = (
        Path(__file__).resolve().parent.parent / "claude-customizations"
    )
    resolved_repo_root = resolve_cli_path(repo_root or customizations_root)
    resolved_destination = resolve_cli_path(args.destination)
    resolved_fs = fs or RealPushDownFileSystem()
    packs = _parse_packs_argument(args.packs)
    summary: PushDownSummary = push_down_customizations(
        repo_root=resolved_repo_root,
        destination_root=resolved_destination,
        fs=resolved_fs,
        source_root=resolved_repo_root,
        artifact_root=resolved_repo_root,
        packs=packs,
        csharp_variant=args.csharp_variant,
        memory_mode=args.memory_mode,
        bundle_root=resolved_repo_root,
    )
    print(f"Wrote push-down summary artifact to: {summary.artifact_path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
