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

PORTABLE_ASSET_RELATIVE_PATHS: tuple[str, ...] = (
    ".claude/lib/bash/compute-cohorts.sh",
    ".claude/lib/bash/compute-concurrency-batches.sh",
    ".claude/lib/bash/parallel-cohorts.sh",
    ".claude/lib/bash/parallel-common.sh",
    ".claude/lib/bash/parallel-items-validate.sh",
    ".claude/lib/bash/parallel-manifest-validate.sh",
    ".claude/lib/bash/parallel-yaml-emit.sh",
    ".claude/lib/bash/parallel-yaml-scan.sh",
    ".claude/lib/bash/validate-parallel-manifest.sh",
    ".claude/lib/blast-radius/BlastRadius.psm1",
    ".claude/lib/blast-radius/BlastRadiusConfig.psm1",
    ".claude/lib/blast-radius/BlastRadiusExtraction.psm1",
    ".claude/lib/blast-radius/BlastRadiusGlob.psm1",
    ".claude/lib/blast-radius/BlastRadiusValidation.psm1",
    "config/blast-radius.json",
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


class PortableAssetFileSystem:
    """Expose only the approved portable assets from the generic resource bundle."""

    def __init__(
        self,
        inner: PushDownFileSystem,
        *,
        source_root: Path,
        resource_root: Path,
        published_paths: frozenset[str] | None,
    ) -> None:
        self._inner = inner
        self._source_root = source_root
        self._resource_root = resource_root
        self._published_paths = published_paths

    def _source_relative(self, path: Path) -> str | None:
        """Return a source-relative POSIX path when the path is contained."""

        try:
            return path.relative_to(self._source_root).as_posix()
        except ValueError:
            return None

    def _is_selected(self, relative_path: str) -> bool:
        """Return whether a portable path belongs to the effective selection."""

        return relative_path in PORTABLE_ASSET_RELATIVE_PATHS and (
            self._published_paths is None or relative_path in self._published_paths
        )

    def _resource_path(self, path: Path) -> Path | None:
        """Map an approved selected virtual path to its resource source."""

        relative_path = self._source_relative(path)
        if relative_path is None or not self._is_selected(relative_path):
            return None
        return self._resource_root / relative_path

    def _selected_virtual_paths(self) -> list[Path]:
        """Return available selected paths in deterministic order."""

        paths: list[Path] = []
        for relative_path in PORTABLE_ASSET_RELATIVE_PATHS:
            if not self._is_selected(relative_path):
                continue
            resource_path = self._resource_root / relative_path
            if self._inner.is_file(resource_path):
                paths.append(self._source_root / relative_path)
        return paths

    def validate_destination_collisions(self, destination_root: Path) -> None:
        """Reject unequal portable destinations before the publisher writes."""

        collisions: list[str] = []
        for virtual_path in self._selected_virtual_paths():
            relative_path = virtual_path.relative_to(self._source_root)
            destination_path = destination_root / relative_path
            if not self._inner.is_file(destination_path):
                continue
            resource_path = self._resource_root / relative_path
            if self._inner.read_text(destination_path) != self._inner.read_text(
                resource_path
            ):
                collisions.append(relative_path.as_posix())
        if collisions:
            raise ValueError(
                "Portable asset collision(s) detected: " + ", ".join(collisions)
            )

    def list_files(self, root: Path) -> list[Path]:
        """Return exact portable virtual paths alongside delegated roots."""

        claude_root = self._source_root / ".claude"
        config_root = self._source_root / "config"
        selected_paths = self._selected_virtual_paths()
        if root == claude_root:
            return [path for path in selected_paths if path.is_relative_to(root)]

        delegated = self._inner.list_files(root)
        if root != config_root:
            return delegated

        blast_radius_path = self._source_root / "config/blast-radius.json"
        combined = {path for path in delegated if path != blast_radius_path}
        combined.update(path for path in selected_paths if path.is_relative_to(root))
        return sorted(combined)

    def is_dir(self, path: Path) -> bool:
        """Delegate directory checks."""

        return self._inner.is_dir(path)

    def is_file(self, path: Path) -> bool:
        """Resolve exact portable virtual paths to generic resources."""

        relative_path = self._source_relative(path)
        if relative_path in PORTABLE_ASSET_RELATIVE_PATHS:
            resource_path = self._resource_path(path)
            return resource_path is not None and self._inner.is_file(resource_path)
        return self._inner.is_file(path)

    def read_text(self, path: Path) -> str:
        """Read exact portable virtual paths from generic resources."""

        resource_path = self._resource_path(path)
        if resource_path is not None:
            return self._inner.read_text(resource_path)
        return self._inner.read_text(path)

    def write_text(self, path: Path, content: str) -> None:
        """Delegate writes."""

        self._inner.write_text(path, content)

    def ensure_dir(self, path: Path) -> None:
        """Delegate directory creation."""

        self._inner.ensure_dir(path)
