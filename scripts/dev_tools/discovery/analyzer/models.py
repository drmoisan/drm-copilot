"""Frozen value objects and enums for the analyzer framework.

Purpose:
    Hold the immutable data carriers that flow between the four analyzer stages
    (``parse -> classify -> map -> emit``) and the ``UnitType`` enum. These value
    objects are host-neutral and carry no I/O behavior; the runner and the
    concrete analyzer thread them from stage to stage.

Invariants / Constraints:
    - Every value object is ``@dataclass(frozen=True, slots=True)`` so instances
      are immutable and cheap.
    - Domain specificity is never encoded here; classification markers, source
      roots, and globs are supplied at runtime.
    - Only type-only imports (``pathlib.Path``) live under ``TYPE_CHECKING``;
      annotations are strings under ``from __future__ import annotations``.

Side Effects:
    None.
"""

from __future__ import annotations

from dataclasses import dataclass, field
from enum import Enum
from typing import TYPE_CHECKING

if TYPE_CHECKING:
    from pathlib import Path

# Value permitted for the emitted ``schema_version`` field; matches ^1\.\d+\.\d+$.
SCHEMA_VERSION_V1 = "1.0.0"


class UnitType(str, Enum):
    """Neutral category of an enumerated inventory unit.

    A ``str`` enum so members compare and serialize as their plain string value.
    The three members are generic structural categories, not stack-specific
    identifiers.
    """

    FILE = "file"
    PROJECT = "project"
    SOLUTION = "solution"


@dataclass(frozen=True, slots=True)
class AnalyzerContext:
    """Resolved inputs for a single analyzer run.

    Args:
        source_root: Resolved consumer source root to enumerate.
        include: Glob patterns selecting files; empty means all files.
        exclude: Glob patterns excluding files; empty excludes none.
        artifact_root: Resolved output root where instances are written.
        schema_path: Path to the discovery v1 Evidence Reference schema file,
            used to compute each instance's scheme-less relative ``$schema``.
        captured_at: ISO-8601 timestamp supplied by an injected clock.
    """

    source_root: Path
    include: tuple[str, ...]
    exclude: tuple[str, ...]
    artifact_root: Path
    schema_path: Path
    captured_at: str


@dataclass(frozen=True, slots=True)
class ParseResult:
    """Ordered consumer-relative POSIX file paths produced by the walk.

    Args:
        paths: Deterministically ordered consumer-relative POSIX paths.
    """

    paths: tuple[str, ...]


@dataclass(frozen=True, slots=True)
class ClassifiedUnit:
    """A single enumerated unit tagged with its neutral ``UnitType``.

    Args:
        relative_path: Consumer-relative POSIX path of the unit.
        unit_type: Neutral structural category of the unit.
    """

    relative_path: str
    unit_type: UnitType


@dataclass(frozen=True, slots=True)
class ClassifyResult:
    """The filtered, classified units of one run.

    Args:
        units: Ordered classified units that survived include/exclude filtering.
    """

    units: tuple[ClassifiedUnit, ...]


@dataclass(frozen=True, slots=True)
class EvidenceRecord:
    """A typed carrier for one Evidence Reference instance.

    The ``$schema`` value is supplied at serialization time because it depends on
    the emitted instance's own location relative to the schema file.

    Args:
        id: Stable identifier matching ``^[a-z0-9][a-z0-9._-]*$``.
        kind: Evidence kind enum value (``"file"`` for enumerated source files).
        location: Consumer-relative POSIX path of the referenced artifact.
        captured_at: ISO-8601 timestamp supplied by an injected clock.
        description: Domain-neutral human-readable summary.
        schema_version: Instance schema version matching ``^1\\.\\d+\\.\\d+$``.
        content_hash: Optional ``(algorithm, value)`` integrity digest.
        tool: Optional label of the producing tool.
        metadata: Optional ordered free-form ``(key, value)`` extras.
    """

    id: str
    kind: str
    location: str
    captured_at: str
    description: str
    schema_version: str = SCHEMA_VERSION_V1
    content_hash: tuple[str, str] | None = None
    tool: str | None = None
    metadata: tuple[tuple[str, str | int], ...] = field(default_factory=tuple)

    def to_json_dict(self, schema_ref: str) -> dict[str, object]:
        """Serialize this record to the Evidence Reference v1 field set.

        Args:
            schema_ref: Scheme-less relative POSIX path from the emitted instance
                file to the schema file, computed by the emitter.

        Returns:
            A mapping with the required fields plus any present optional fields.
            No field is emitted outside the schema's declared set except the
            free-form ``metadata`` object.
        """
        document: dict[str, object] = {
            "$schema": schema_ref,
            "schema_version": self.schema_version,
            "id": self.id,
            "kind": self.kind,
            "location": self.location,
            "captured_at": self.captured_at,
            "description": self.description,
        }
        if self.content_hash is not None:
            algorithm, value = self.content_hash
            document["content_hash"] = {"algorithm": algorithm, "value": value}
        if self.tool is not None:
            document["tool"] = self.tool
        if self.metadata:
            document["metadata"] = {key: value for key, value in self.metadata}
        return document


@dataclass(frozen=True, slots=True)
class AnalyzerRunResult:
    """The outcome of one ``run_analyzer`` invocation.

    Args:
        records: The evidence records built by the ``map`` stage.
        written_paths: The instance paths written by the ``emit`` stage.
    """

    records: tuple[EvidenceRecord, ...]
    written_paths: tuple[Path, ...]
