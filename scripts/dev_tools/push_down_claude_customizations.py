"""Publish bundled `.claude` content into a destination workspace.

Purpose:
    Provide a dedicated public entry point for the Claude customization push-down
    workflow while reusing the shared publisher engine behind the existing
    `.github` customization flow. Settings-local configuration is excluded from
    push-down because it holds host-specific overrides that must not propagate.
"""

from __future__ import annotations

import argparse
from pathlib import Path

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
    "ARTIFACT_DIRECTORY",
    "EXCLUDED_RELATIVE_PATHS",
    "PushDownSummary",
    "ROOT_FOLDERS",
    "main",
    "parse_args",
    "push_down_customizations",
]


class _ExcludingFileSystem:
    """Wrap a PushDownFileSystem and filter specified paths from list_files.

    Purpose:
        Prevent host-specific files (e.g. `settings.local.json`) from being
        included when the publisher enumerates source files. Chosen over a
        post-enumeration filter so the exclusion travels with the filesystem
        contract and is transparent to the shared engine.

    Usage:
        Instantiate with the inner adapter and exclusion paths relative to
        the repo root; pass the result as the `fs` argument to the engine.

    Invariants / Constraints:
        Excluded paths are resolved once at construction time for O(1) checks.

    Side Effects:
        Delegates all I/O to the inner adapter.
    """

    def __init__(
        self, inner: PushDownFileSystem, repo_root: Path, excluded: tuple[Path, ...]
    ) -> None:
        """Set up the adapter; resolve exclusion paths relative to repo_root."""
        self._inner = inner
        # Resolve once at init so list_files per-path checks are O(1).
        self._excluded: frozenset[Path] = frozenset(
            (repo_root / p).resolve() for p in excluded
        )

    def list_files(self, root: Path) -> list[Path]:
        """Return inner list_files output with excluded paths removed."""
        return [
            p for p in self._inner.list_files(root) if p.resolve() not in self._excluded
        ]

    def is_dir(self, path: Path) -> bool:
        """Delegate to inner adapter."""
        return self._inner.is_dir(path)

    def is_file(self, path: Path) -> bool:
        """Delegate to inner adapter."""
        return self._inner.is_file(path)

    def read_text(self, path: Path) -> str:
        """Delegate to inner adapter."""
        return self._inner.read_text(path)

    def write_text(self, path: Path, content: str) -> None:
        """Delegate to inner adapter."""
        self._inner.write_text(path, content)

    def ensure_dir(self, path: Path) -> None:
        """Delegate to inner adapter."""
        self._inner.ensure_dir(path)


def _passthrough_rewrite(
    text: str,
) -> tuple[str, int, int, list[str]]:
    """Return unmodified text for payloads that do not need command rewrites."""

    return text, 0, 0, []


def push_down_customizations(
    *,
    repo_root: Path,
    destination_root: Path,
    fs: PushDownFileSystem,
    source_root: Path | None = None,
    artifact_root: Path | None = None,
) -> PushDownSummary:
    """Copy the `.claude` tree into the destination workspace.

    Excludes paths in `EXCLUDED_RELATIVE_PATHS` by wrapping `fs` in
    `_ExcludingFileSystem` before delegating to the shared engine.
    """

    # Wrap the caller-supplied adapter so enumeration omits excluded paths.
    excluding_fs = _ExcludingFileSystem(fs, repo_root, EXCLUDED_RELATIVE_PATHS)
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
    """Parse CLI arguments for the Claude customization push-down publisher."""

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
    return parser.parse_args(argv)


def main(
    argv: list[str] | None = None,
    *,
    repo_root: Path | None = None,
    fs: PushDownFileSystem | None = None,
) -> int:
    """Run the Claude customization push-down publisher CLI."""

    args = parse_args(argv)
    resolved_repo_root = resolve_cli_path(repo_root or Path.cwd())
    resolved_destination = resolve_cli_path(args.destination)
    resolved_fs = fs or RealPushDownFileSystem()
    summary = push_down_customizations(
        repo_root=resolved_repo_root,
        destination_root=resolved_destination,
        fs=resolved_fs,
        source_root=resolved_repo_root,
        artifact_root=resolved_repo_root,
    )
    print(f"Wrote push-down summary artifact to: {summary.artifact_path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
