"""Freeze legacy compatibility records and versioned analyzer input/result values.

Legacy carriers preserve import and serialization contracts. V2 inputs retain
exact bytes and truthful unavailable-input accounting; outputs keep inventory
separate from uninspected ledger proposals. Construction performs no I/O.
"""

from __future__ import annotations

from dataclasses import dataclass, field
from enum import Enum
from typing import TYPE_CHECKING, Literal, cast

from drm_copilot_discovery.models import JsonObject
from drm_copilot_discovery.path_models import check_path_collisions, relative_path
from drm_copilot_discovery.snapshot import SnapshotFile

if TYPE_CHECKING:
    from pathlib import Path

    from drm_copilot_discovery.profile_v2 import ProfileV2
    from drm_copilot_discovery.repository_reader import RepositoryFile

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
        written_paths: Empty for read-only legacy runs; publication moved to v2.
    """

    records: tuple[EvidenceRecord, ...]
    written_paths: tuple[Path, ...]


@dataclass(frozen=True, kw_only=True)
class InventoryInput:
    """Account for one selected input without inventing bytes for failed reads.

    Construct after bounded capture. Only inspected inputs carry SnapshotFile;
    excluded/unreadable inputs require a rationale. The cached digest describes
    the exact bytes later analyzed. Construction performs no I/O or writes.
    """

    path: str
    status: Literal["inspected", "excluded", "unreadable"]
    file: SnapshotFile | None = None
    rationale: str | None = None
    sha256: str | None = field(init=False, default=None)

    def __post_init__(self) -> None:
        """Validate input state; raise ValueError for dishonest accounting; pure.

        Uses the declared path (str), status (literal), file (SnapshotFile | None)
        and rationale (str | None) fields. Returns None; raises ValueError for
        contradictory state or unsafe paths. Initializes only the cached digest;
        performs no I/O.
        """
        relative_path(self.path)
        if self.status not in {"inspected", "excluded", "unreadable"}:
            raise ValueError("Unknown inventory input status")
        # Captured bytes and failed/excluded observations are mutually exclusive.
        if self.status == "inspected":
            if (
                not isinstance(self.file, SnapshotFile)
                or self.file.path != self.path
                or self.rationale is not None
            ):
                raise ValueError("Inspected inputs require exact captured bytes")
            object.__setattr__(self, "sha256", self.file.sha256)
        elif (
            self.file is not None
            or not isinstance(self.rationale, str)
            or not self.rationale.strip()
        ):
            raise ValueError("Unavailable inputs require rationale and no bytes")


@dataclass(frozen=True, kw_only=True)
class InventoryCapture:
    """Freeze configured scan inputs, explicit omissions and pinned Git bytes.

    Feed this value to registered analyzers. It describes reading, not feature
    inspection or completion. Repository objects are retained only when already
    captured; their absence never becomes a fabricated revision verification.
    Construction sorts/detaches collections and has no external side effects.
    """

    profile: ProfileV2
    inputs: tuple[InventoryInput, ...]
    exclusions: tuple[JsonObject, ...] = ()
    repository_files: tuple[RepositoryFile, ...] = ()

    def __post_init__(self) -> None:
        """Require configured profile and typed unique inputs; return None or fail.

        Uses profile (ProfileV2), inputs (tuple[InventoryInput, ...]), exclusions
        and repository_files from construction. Returns None; raises ValueError or
        ProfileError for invalid scope, types, collisions or limits. Freezes only
        this instance and performs no I/O.
        """
        from drm_copilot_discovery.profile_v2 import ProfileV2

        if not isinstance(cast("object", self.profile), ProfileV2):
            raise ValueError("Inventory requires a validated profile")
        self.profile.require_configured()
        inputs = tuple(self.inputs)
        if any(not isinstance(cast("object", item), InventoryInput) for item in inputs):
            raise ValueError("Inventory requires typed captured inputs")
        check_path_collisions(item.path for item in inputs)
        if len(inputs) > self.profile.limits.source_files:
            raise ValueError("Inventory input count exceeds the configured limit")
        object.__setattr__(
            self, "inputs", tuple(sorted(inputs, key=lambda item: item.path))
        )
        object.__setattr__(self, "exclusions", tuple(self.exclusions))
        object.__setattr__(self, "repository_files", tuple(self.repository_files))


@dataclass(frozen=True, kw_only=True)
class Analysis:
    """Carry inert, schema-shaped adapter findings before aggregate validation.

    Registered adapters return immutable rows; the runner validates their complete
    inventory. No row changes coverage dispositions or authorizes publication.
    """

    components: tuple[JsonObject, ...] = ()
    findings: tuple[JsonObject, ...] = ()
    relationships: tuple[JsonObject, ...] = ()
    diagnostics: tuple[JsonObject, ...] = ()

    def __post_init__(self) -> None:
        """Detach and type-check each row family; raise ValueError without I/O.

        Uses the four tuple[JsonObject, ...] result fields. Returns None and freezes
        their containers. Raises ValueError for untyped rows; performs no I/O and
        never mutates caller containers.
        """
        # Adapters cannot retain mutable arrays inside a supposedly frozen result.
        for name in ("components", "findings", "relationships", "diagnostics"):
            rows = tuple(cast("tuple[JsonObject, ...]", getattr(self, name)))
            if any(not isinstance(cast("object", row), JsonObject) for row in rows):
                raise ValueError("Analyzer rows must be immutable JSON objects")
            object.__setattr__(self, name, rows)


@dataclass(frozen=True, kw_only=True)
class InventoryResult:
    """Keep validated inventory bytes and separate, unpublished coverage proposals.

    Semantic identity excludes capture metadata, so repeated observations retain
    identity. Neither this value nor its ledger rows grant mutation permission.
    """

    document: JsonObject
    ledger_components: tuple[JsonObject, ...]
    semantic_sha256: str
