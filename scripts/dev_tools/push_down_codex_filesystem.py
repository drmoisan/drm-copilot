"""Filtering filesystem wrapper for Codex and agents push-down."""

from __future__ import annotations

from typing import TYPE_CHECKING

try:
    from scripts.dev_tools.push_down_codex_pack_selection import (
        CSHARP_CANONICAL_PATHS,
        CSharpVariant,
        resolve_variant_source_path,
    )
except ModuleNotFoundError as error:  # pragma: no cover - bundled import fallback
    if error.name is None or not error.name.startswith("scripts"):
        raise
    from dev_tools.push_down_codex_pack_selection import (
        CSHARP_CANONICAL_PATHS,
        CSharpVariant,
        resolve_variant_source_path,
    )

if TYPE_CHECKING:
    from pathlib import Path

    from scripts.dev_tools.push_down_copilot_customizations_filesystem import (
        PushDownFileSystem,
    )


class ExcludingFileSystem:
    """Filter selected Codex files and redirect legacy C# reads."""

    def __init__(
        self,
        inner: PushDownFileSystem,
        *,
        source_root: Path,
        published_paths: frozenset[str] | None = None,
        csharp_variant: CSharpVariant = "modern",
        variant_root: Path | None = None,
    ) -> None:
        self._inner = inner
        self._source_root_raw = source_root
        self._source_root = source_root.resolve()
        self._published_paths = published_paths
        self._csharp_variant: CSharpVariant = csharp_variant
        self._variant_root_raw = variant_root or source_root

    def _source_relative_posix(self, path: Path) -> str | None:
        """Return the path relative to source root as POSIX, if possible."""

        try:
            return path.resolve().relative_to(self._source_root).as_posix()
        except ValueError:
            return None

    def _is_pack_included(self, path: Path) -> bool:
        """Return whether a candidate source path is selected for publish."""

        if self._published_paths is None:
            return True
        relative = self._source_relative_posix(path)
        if relative is None:
            return True
        return relative in self._published_paths

    def _resolve_read_source(self, path: Path) -> Path:
        """Return the actual path to read for variant-routed files."""

        if self._csharp_variant != "legacy":
            return path
        relative = self._source_relative_posix(path)
        if relative is None or relative not in CSHARP_CANONICAL_PATHS:
            return path
        return self._variant_root_raw / resolve_variant_source_path(relative, "legacy")

    def list_files(self, root: Path) -> list[Path]:
        """Return filtered source files."""

        return [p for p in self._inner.list_files(root) if self._is_pack_included(p)]

    def is_dir(self, path: Path) -> bool:
        """Delegate directory checks."""

        return self._inner.is_dir(path)

    def is_file(self, path: Path) -> bool:
        """Delegate file checks."""

        return self._inner.is_file(path)

    def read_text(self, path: Path) -> str:
        """Read text, redirecting legacy C# canonical paths when selected."""

        return self._inner.read_text(self._resolve_read_source(path))

    def write_text(self, path: Path, content: str) -> None:
        """Delegate writes."""

        self._inner.write_text(path, content)

    def ensure_dir(self, path: Path) -> None:
        """Delegate directory creation."""

        self._inner.ensure_dir(path)
