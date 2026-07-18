"""The repository/project inventory analyzer and its pure helpers.

Purpose:
    Implement the first concrete ``Analyzer``: a language-neutral inventory of a
    consumer repository's source tree. The four stages are:

    - ``parse``: fail fast on an unreachable source root, then walk the tree via
      the filesystem seam and return consumer-relative POSIX paths in
      deterministic order.
    - ``classify``: apply include/exclude glob filtering, then tag each surviving
      unit with a neutral ``UnitType`` from a marker pattern table.
    - ``map``: build one ``EvidenceRecord`` per inventoried unit.
    - ``emit``: write one Evidence Reference instance per record via the seam.

Invariants / Constraints:
    - Domain specificity is never hardcoded: classification markers are data
      (injectable, defaulting to a generic, extensible pattern table), and the
      source root and globs come from the run context. No stack-specific literal
      appears in this module.
    - ``AnalyzerError`` is a distinct ``ValueError`` subclass, separate from the
      profile loader's ``DomainProfileError``.
    - The filter and classification helpers are pure (no filesystem access).
    - Matching uses ``fnmatch.fnmatchcase`` so results are deterministic and
      platform-independent.

Side Effects:
    Stage methods read and write through the injected filesystem seam only.
"""

from __future__ import annotations

import hashlib
from fnmatch import fnmatchcase
from pathlib import PurePosixPath
from typing import TYPE_CHECKING

from scripts.dev_tools.discovery.analyzer.emitter import serialize_record
from scripts.dev_tools.discovery.analyzer.models import (
    ClassifiedUnit,
    ClassifyResult,
    EvidenceRecord,
    ParseResult,
    UnitType,
)
from scripts.dev_tools.discovery.analyzer.pipeline import RealAnalyzerFileSystem

if TYPE_CHECKING:
    from pathlib import Path

    from scripts.dev_tools.discovery.analyzer.models import AnalyzerContext
    from scripts.dev_tools.discovery.analyzer.pipeline import AnalyzerFileSystem

# Generic, extensible marker table mapping a filename glob to a neutral unit
# category. The tokens are the neutral structural category names themselves, not
# any specific technology stack. Consumers may supply their own table.
DEFAULT_MARKERS: tuple[tuple[str, UnitType], ...] = (
    ("*.solution", UnitType.SOLUTION),
    ("*.project", UnitType.PROJECT),
)

_DESCRIPTION = "Source file enumerated by the repository inventory analyzer."


class AnalyzerError(ValueError):
    """Raised when an analyzer cannot proceed (for example an unreachable root).

    A distinct ``ValueError`` subclass so callers can catch it separately from
    the profile loader's ``DomainProfileError``.
    """


def filter_paths(
    paths: tuple[str, ...],
    include: tuple[str, ...],
    exclude: tuple[str, ...],
) -> tuple[str, ...]:
    """Apply include/exclude globs to consumer-relative POSIX paths (pure).

    A path is retained when it matches at least one ``include`` pattern (or
    ``include`` is empty, meaning all) and matches no ``exclude`` pattern. Order
    is preserved.

    Args:
        paths: Ordered consumer-relative POSIX paths.
        include: Include glob patterns; empty selects all.
        exclude: Exclude glob patterns; empty excludes none.

    Returns:
        The filtered paths in their original order.
    """
    retained: list[str] = []
    for path in paths:
        included = not include or any(fnmatchcase(path, pat) for pat in include)
        excluded = any(fnmatchcase(path, pat) for pat in exclude)
        if included and not excluded:
            retained.append(path)
    return tuple(retained)


def classify_unit(
    relative_path: str, markers: tuple[tuple[str, UnitType], ...]
) -> UnitType:
    """Return the ``UnitType`` for one path from the marker table (pure).

    The first marker whose glob matches the path's filename wins; a path that
    matches no marker is a plain ``FILE``.

    Args:
        relative_path: Consumer-relative POSIX path.
        markers: Ordered ``(filename_glob, UnitType)`` pairs.

    Returns:
        The matched ``UnitType`` or ``UnitType.FILE`` when no marker matches.
    """
    name = PurePosixPath(relative_path).name
    for pattern, unit_type in markers:
        if fnmatchcase(name, pattern):
            return unit_type
    return UnitType.FILE


def classify_paths(
    paths: tuple[str, ...], markers: tuple[tuple[str, UnitType], ...]
) -> tuple[ClassifiedUnit, ...]:
    """Tag each path with its ``UnitType`` (pure)."""
    return tuple(
        ClassifiedUnit(relative_path=path, unit_type=classify_unit(path, markers))
        for path in paths
    )


def _slug(relative_path: str) -> str:
    """Return a stable identifier slug matching ``^[a-z0-9][a-z0-9._-]*$``."""
    digest = hashlib.sha256(relative_path.encode("utf-8")).hexdigest()
    return digest[:16]


class InventoryAnalyzer:
    """Language-neutral inventory analyzer implementing the ``Analyzer`` contract.

    Args:
        fs: Filesystem seam used by ``parse`` and ``map``; defaults to the real
            filesystem implementation.
        markers: Marker pattern table for classification; defaults to a generic,
            extensible table.
    """

    name = "inventory"

    def __init__(
        self,
        fs: AnalyzerFileSystem | None = None,
        markers: tuple[tuple[str, UnitType], ...] | None = None,
    ) -> None:
        self._fs: AnalyzerFileSystem = (
            fs if fs is not None else RealAnalyzerFileSystem()
        )
        self._markers = markers if markers is not None else DEFAULT_MARKERS
        self._ctx: AnalyzerContext | None = None

    def _require_ctx(self) -> AnalyzerContext:
        """Return the stashed run context, failing if ``parse`` did not run."""
        if self._ctx is None:
            raise AnalyzerError("analyzer context is unavailable; parse must run first")
        return self._ctx

    def parse(self, ctx: AnalyzerContext) -> ParseResult:
        """Fail fast on an unreachable root, then walk and order the tree.

        Args:
            ctx: The resolved run context.

        Returns:
            Consumer-relative POSIX paths in deterministic POSIX-sorted order.

        Raises:
            AnalyzerError: When the source root does not exist or is not a
                directory.
        """
        self._ctx = ctx
        root = ctx.source_root
        if not self._fs.exists(root) or not self._fs.is_dir(root):
            raise AnalyzerError(f"source root is not reachable: {root}")
        relative_paths = [
            file_path.relative_to(root).as_posix()
            for file_path in self._fs.walk_files(root)
        ]
        return ParseResult(paths=tuple(sorted(relative_paths)))

    def classify(self, parsed: ParseResult) -> ClassifyResult:
        """Filter by include/exclude globs, then tag each surviving unit."""
        ctx = self._require_ctx()
        retained = filter_paths(parsed.paths, ctx.include, ctx.exclude)
        return ClassifyResult(units=classify_paths(retained, self._markers))

    def map(self, classified: ClassifyResult) -> tuple[EvidenceRecord, ...]:
        """Build one ``EvidenceRecord`` per inventoried unit."""
        ctx = self._require_ctx()
        records: list[EvidenceRecord] = []
        for unit in classified.units:
            content = self._fs.read_bytes(ctx.source_root / unit.relative_path)
            digest = hashlib.sha256(content).hexdigest()
            records.append(
                EvidenceRecord(
                    id=f"inventory-{unit.unit_type.value}-{_slug(unit.relative_path)}",
                    kind="file",
                    location=unit.relative_path,
                    captured_at=ctx.captured_at,
                    description=_DESCRIPTION,
                    content_hash=("sha256", digest),
                    tool="dev.discovery.inventory",
                    metadata=(
                        ("unit_type", unit.unit_type.value),
                        ("size_bytes", len(content)),
                    ),
                )
            )
        return tuple(records)

    def emit(
        self, records: tuple[EvidenceRecord, ...], fs: AnalyzerFileSystem
    ) -> tuple[Path, ...]:
        """Write one Evidence Reference instance per record via the seam."""
        ctx = self._require_ctx()
        written: list[Path] = []
        for record in records:
            instance_path = ctx.artifact_root / f"{record.id}.json"
            text = serialize_record(record, instance_path, ctx.schema_path)
            fs.write_text(instance_path, text)
            written.append(instance_path)
        return tuple(written)
