"""Destination-side write decorators and extension seams for the Claude push-down.

Purpose:
    Align the Python Claude push-down with the TypeScript write path
    (``extensions/drm-copilot/src/lib/push-down/claude-customizations.ts``).
    Registered destination paths are merged into existing destination text,
    ``config/blast-radius.json`` is derived from the destination layout, and
    the published ``config/`` tree is read from the extension bundle.

Composition, outer to inner:
    ``BlastRadiusDeriveFileSystem`` -> ``DestinationMergeFileSystem`` -> inner
    adapter, assembled only by ``build_destination_write_stack()``. Because
    derive sits above merge, a merge registered for ``config/blast-radius.json``
    receives the derived document as its source text with no rewiring.

Extension seams (binding contract for downstream children):
    ``MERGED_RELATIVE_PATHS`` maps a destination-relative POSIX path to a
    ``MergeFunction`` taking ``(destination_text, source_text, path)``. Its keys
    are string literals so the parity test reads them statically.
    ``build_destination_write_stack()`` is the single assembly point for
    destination-side write decorators. Any child that changes either seam
    extends ``test_push_down_claude_parity.py`` in the same change.

#508 extends `MERGED_RELATIVE_PATHS` by registering `config/blast-radius.json`.
#621 inserts its destination exclusion filter in `build_destination_write_stack()`
as the outermost layer.
Downstream children extend these seams; they do not replace, bypass, or duplicate them.

Invariants / Constraints:
    A merge or derivation error propagates before the inner write, so the
    destination file bytes are unchanged. Path matching is string-wise and
    case-sensitive after backslash normalization, mirroring TypeScript
    ``relativeToPosix``.
"""

from __future__ import annotations

from collections.abc import Callable, Mapping
from typing import TYPE_CHECKING

try:
    from scripts.dev_tools.push_down_claude_blast_radius_derive import (
        DirectoryLister,
        collect_destination_observations,
    )
    from scripts.dev_tools.push_down_claude_blast_radius_derive_core import (
        BLAST_RADIUS_RELATIVE_PATH,
        derive_destination_module_map,
    )
    from scripts.dev_tools.push_down_claude_routing_merge import (
        merge_routing_documents,
    )
except ModuleNotFoundError as error:  # pragma: no cover - bundled import fallback
    if error.name is None or not error.name.startswith("scripts"):
        raise
    from dev_tools.push_down_claude_blast_radius_derive import (
        DirectoryLister,
        collect_destination_observations,
    )
    from dev_tools.push_down_claude_blast_radius_derive_core import (
        BLAST_RADIUS_RELATIVE_PATH,
        derive_destination_module_map,
    )
    from dev_tools.push_down_claude_routing_merge import merge_routing_documents

if TYPE_CHECKING:
    from pathlib import Path

    from scripts.dev_tools.push_down_copilot_customizations_filesystem import (
        PushDownFileSystem,
    )

__all__ = [
    "MERGED_RELATIVE_PATHS",
    "BlastRadiusDeriveFileSystem",
    "BundleConfigFileSystem",
    "DestinationMergeFileSystem",
    "DirectoryLister",
    "MergeFunction",
    "build_destination_write_stack",
]

# Merge seam signature: (destination_text, source_text, path) -> merged text.
MergeFunction = Callable[[str, str, "Path"], str]

MERGED_RELATIVE_PATHS: Mapping[str, MergeFunction] = {
    "config/orchestration-routing.json": merge_routing_documents,
}

# Name of the published configuration tree under both roots.
_CONFIG_DIR = "config"


def _normalize_posix(value: Path) -> str:
    """Return a forward-slash path string without trailing separators."""

    return str(value).replace("\\", "/").rstrip("/")


def _relative_posix(path: Path, root: Path) -> str | None:
    """Return the POSIX path of ``path`` relative to ``root``, or ``None``."""

    normalized_path = _normalize_posix(path)
    normalized_root = _normalize_posix(root)
    if normalized_path == normalized_root:
        return ""
    prefix = f"{normalized_root}/"
    if normalized_path.startswith(prefix):
        return normalized_path[len(prefix) :]
    return None


class _DelegatingFileSystem:
    """Delegate every ``PushDownFileSystem`` method to a wrapped adapter."""

    def __init__(self, inner: PushDownFileSystem) -> None:
        """Store the wrapped adapter."""

        self._inner = inner

    @property
    def inner(self) -> PushDownFileSystem:
        """Return the wrapped adapter, exposing the layer order read-only."""

        return self._inner

    def list_files(self, root: Path) -> list[Path]:
        """Delegate to the wrapped adapter."""

        return self._inner.list_files(root)

    def is_dir(self, path: Path) -> bool:
        """Delegate to the wrapped adapter."""

        return self._inner.is_dir(path)

    def is_file(self, path: Path) -> bool:
        """Delegate to the wrapped adapter."""

        return self._inner.is_file(path)

    def read_text(self, path: Path) -> str:
        """Delegate to the wrapped adapter."""

        return self._inner.read_text(path)

    def write_text(self, path: Path, content: str) -> None:
        """Delegate to the wrapped adapter."""

        self._inner.write_text(path, content)

    def ensure_dir(self, path: Path) -> None:
        """Delegate to the wrapped adapter."""

        self._inner.ensure_dir(path)


class DestinationMergeFileSystem(_DelegatingFileSystem):
    """Merge registered destination paths instead of overwriting them."""

    def __init__(
        self,
        inner: PushDownFileSystem,
        *,
        destination_root: Path,
        merges: Mapping[str, MergeFunction] = MERGED_RELATIVE_PATHS,
    ) -> None:
        """Wrap ``inner`` with the merge registry for ``destination_root``.

        Args:
            inner (PushDownFileSystem): Wrapped adapter performing real I/O.
            destination_root (Path): Destination workspace root.
            merges (Mapping[str, MergeFunction]): Destination-relative POSIX
                paths mapped to their merge functions.
        """

        super().__init__(inner)
        self._destination_root = destination_root
        self._merges = merges

    def write_text(self, path: Path, content: str) -> None:
        """Write ``content``, merging it when the path is registered and exists.

        Raises:
            ValueError: Propagated from the merge function (for example
                ``RoutingMergeError``) before the inner write occurs.
        """

        relative = _relative_posix(path, self._destination_root)
        merge = self._merges.get(relative) if relative is not None else None
        # An absent destination file has nothing to preserve, so the source
        # text is written unchanged and the next push merges against it.
        if merge is not None and self._inner.is_file(path):
            content = merge(self._inner.read_text(path), content, path)
        self._inner.write_text(path, content)


class BlastRadiusDeriveFileSystem(_DelegatingFileSystem):
    """Replace the bundled blast-radius bytes with a destination-derived map."""

    def __init__(
        self,
        inner: PushDownFileSystem,
        *,
        destination_root: Path,
        lister: DirectoryLister,
    ) -> None:
        """Wrap ``inner`` so ``config/blast-radius.json`` is derived.

        Args:
            inner (PushDownFileSystem): Wrapped adapter.
            destination_root (Path): Destination workspace root to scan.
            lister (DirectoryLister): Shallow directory lister for the scan.
        """

        super().__init__(inner)
        self._destination_root = destination_root
        self._lister = lister

    def write_text(self, path: Path, content: str) -> None:
        """Write ``content``, deriving it for the blast-radius target path.

        Raises:
            BlastRadiusDeriveError: When the bundled document is not parseable.
            BlastRadiusGuardError: When a forbidden glob would be emitted. Both
                are raised before the inner write.
        """

        if _relative_posix(path, self._destination_root) == BLAST_RADIUS_RELATIVE_PATH:
            observations = collect_destination_observations(
                self._destination_root, self._lister
            )
            content = derive_destination_module_map(observations, content)
        self._inner.write_text(path, content)


class BundleConfigFileSystem(_DelegatingFileSystem):
    """Answer ``<source_root>/config`` reads from ``<bundle_root>/config``."""

    def __init__(
        self, inner: PushDownFileSystem, *, source_root: Path, bundle_root: Path
    ) -> None:
        """Redirect the source ``config`` tree to the bundle ``config`` tree.

        Args:
            inner (PushDownFileSystem): Wrapped adapter.
            source_root (Path): Root the engine enumerates ``config`` under.
            bundle_root (Path): Extension bundle root holding ``config``.
        """

        super().__init__(inner)
        self._source_config = source_root / _CONFIG_DIR
        self._bundle_config = bundle_root / _CONFIG_DIR
        self._identity = self._source_config == self._bundle_config

    def _redirect(self, path: Path) -> Path:
        """Map a path under the source ``config`` tree into the bundle tree."""

        if self._identity:
            return path
        try:
            relative = path.relative_to(self._source_config)
        except ValueError:
            return path
        return self._bundle_config / relative

    def list_files(self, root: Path) -> list[Path]:
        """List the bundle ``config`` files under source-rooted paths."""

        if self._identity or root != self._source_config:
            return self._inner.list_files(root)
        return [
            self._source_config / bundle_path.relative_to(self._bundle_config)
            for bundle_path in self._inner.list_files(self._bundle_config)
        ]

    def is_file(self, path: Path) -> bool:
        """Answer existence for source ``config`` paths from the bundle."""

        return self._inner.is_file(self._redirect(path))

    def read_text(self, path: Path) -> str:
        """Read source ``config`` paths from the bundle."""

        return self._inner.read_text(self._redirect(path))


def build_destination_write_stack(
    inner: PushDownFileSystem,
    *,
    destination_root: Path,
    lister: DirectoryLister,
    merges: Mapping[str, MergeFunction] = MERGED_RELATIVE_PATHS,
) -> PushDownFileSystem:
    """Assemble the destination-side write decorators around ``inner``.

    Args:
        inner (PushDownFileSystem): Adapter performing real I/O.
        destination_root (Path): Destination workspace root.
        lister (DirectoryLister): Shallow directory lister for the derivation.
        merges (Mapping[str, MergeFunction]): Merge registry; replaces the
            default ``MERGED_RELATIVE_PATHS`` when supplied.

    Returns:
        PushDownFileSystem: ``BlastRadiusDeriveFileSystem`` wrapping
        ``DestinationMergeFileSystem`` wrapping ``inner``.
    """

    merging = DestinationMergeFileSystem(
        inner, destination_root=destination_root, merges=merges
    )
    return BlastRadiusDeriveFileSystem(
        merging, destination_root=destination_root, lister=lister
    )
