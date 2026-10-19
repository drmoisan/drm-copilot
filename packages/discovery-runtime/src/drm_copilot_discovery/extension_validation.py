"""Validate inert extension bytes against captured local inputs, without I/O."""

from __future__ import annotations

import hashlib
import math
from dataclasses import dataclass
from typing import TYPE_CHECKING, cast

from drm_copilot_discovery.analyzer.input_capture import capture_snapshot
from drm_copilot_discovery.analyzer.models import Analysis
from drm_copilot_discovery.extension_inputs import extension_input_projection
from drm_copilot_discovery.models import JsonObject, JsonValue, canonical_json
from drm_copilot_discovery.path_models import relative_path
from drm_copilot_discovery.schema_validation import validate_document
from drm_copilot_discovery.snapshot import DiscoverySnapshot, SnapshotFile

if TYPE_CHECKING:
    from drm_copilot_discovery.profile_models import ProfileLimits


class ExtensionResultError(ValueError):
    """Carry a fixed code/message for one rejected operation, without I/O.

    Construct at the failing boundary; callers inspect code rather than raw input.
    The exception grants no partial result or mutation authority.
    """

    def __init__(self, code: str) -> None:
        """Store code (str); return None with a fixed, non-publishing failure."""
        self.code = code
        super().__init__(
            f"{code}: extension data does not satisfy the captured contract"
        )


@dataclass(frozen=True, kw_only=True)
class ValidatedExtension:
    """Describe validated bytes; construction grants no merge or write authority.

    Fields bind manifest path/hash, pre-output input hash, adapter, result files
    and inert Analysis. All values are immutable. Consumers must revalidate the
    original DiscoverySnapshot rather than trust a caller-created instance.
    """

    manifest_path: str
    manifest_sha256: str
    input_manifest_sha256: str
    adapter: JsonObject
    result_files: tuple[SnapshotFile, ...]
    analysis: Analysis

    def __post_init__(self) -> None:
        """Check initialized fields; return None without authority or I/O.

        Invalid paths raise ValueError; other malformed fields raise
        ExtensionResultError with EXTENSION_CARRIER. No field is changed.
        """
        relative_path(self.manifest_path)
        # Structural carrier checks do not substitute for source/member validation.
        for value in (self.manifest_sha256, self.input_manifest_sha256):
            if (
                type(value) is not str
                or len(value) != 64
                or any(char not in "0123456789abcdef" for char in value)
            ):
                raise ExtensionResultError("EXTENSION_CARRIER")
        if (
            type(self.adapter) is not JsonObject
            or type(self.result_files) is not tuple
            or any(type(item) is not SnapshotFile for item in self.result_files)
            or type(self.analysis) is not Analysis
        ):
            raise ExtensionResultError("EXTENSION_CARRIER")


class ExtensionBudget:
    """Reserve aggregate JSON bytes, value traversal and result rows prospectively.

    max_bytes counts canonical UTF-8 JSON bytes, including escaping. max_records
    counts semantic rows; max_nodes bounds JSON value/key visits independently.
    No encoded copy is allocated while reserving. Exhaustion raises a fixed error
    and callers discard their entire partial result.
    """

    def __init__(
        self, *, max_bytes: int, max_records: int, max_nodes: int, max_depth: int
    ) -> None:
        """Initialize independent capacities and zero counters; return None.

        max_bytes (int) caps canonical UTF-8 bytes, max_records (int) semantic
        rows, max_nodes (int) value/key visits and max_depth (int) nesting.
        Nonpositive or nonexact integers raise EXTENSION_LIMIT. No I/O occurs.
        """
        # Reject bool/float/unbounded user overrides before traversal or allocation.
        for value in (max_bytes, max_records, max_nodes, max_depth):
            if type(value) is not int or value < 1:
                raise ExtensionResultError("EXTENSION_LIMIT")
        self.max_bytes, self.max_records = max_bytes, max_records
        self.max_nodes, self.max_depth = max_nodes, max_depth
        self.bytes = self.records = self.nodes = 0

    def reserve(self, value: JsonValue, *, records: int = 0) -> None:
        """Charge value (JsonValue) and records (nonnegative int); return None.

        Raises EXTENSION_LIMIT for byte, row, depth, node or numeric overflow.
        Mutates byte/node/row counters only; performs no encoding or I/O.
        """
        if type(records) is not int or records < 0:
            raise ExtensionResultError("EXTENSION_LIMIT")
        self.records += records
        if self.records > self.max_records:
            raise ExtensionResultError("EXTENSION_LIMIT")
        self._visit(value, 1)
        self._bytes(1)  # Reserve a separator/newline conservatively for every value.

    def _bytes(self, count: int) -> None:
        """Charge count (int) before allocation; return None or raise the fixed
        limit.
        """
        self.bytes += count
        if self.bytes > self.max_bytes:
            raise ExtensionResultError("EXTENSION_LIMIT")

    def _integer(self, value: int) -> None:
        """Charge exact decimal width of value (int); return None without rendering.

        Sign and separator consume capacity before bounded power comparisons.
        EXTENSION_LIMIT rejects overflow; only byte counters change. No str call,
        global digit-limit dependency, input copy or I/O is used.
        """
        sign = int(value < 0)
        available = self.max_bytes - self.bytes - sign - 1
        bits = value.bit_length()
        # 0.3 < log10(2) < 1/3 gives integer-only width bounds, including zero.
        low = max(1, (bits - 1) * 3 // 10 + 1)
        high = min(max(1, (bits + 2) // 3), available)
        if low > high:
            raise ExtensionResultError("EXTENSION_LIMIT")
        # Locate exact width without decimal text; powers never exceed capacity.
        while low < high:
            middle = (low + high) // 2
            threshold = 10**middle
            if -threshold < value < threshold:
                high = middle
            else:
                low = middle + 1
        threshold = 10**low
        if not -threshold < value < threshold:
            raise ExtensionResultError("EXTENSION_LIMIT")
        self._bytes(low + sign)

    def _visit(self, value: JsonValue, depth: int) -> None:
        """Measure value (JsonValue) at depth (int); return None, updating counters.

        Raises EXTENSION_LIMIT before exceeding a byte/node/depth ceiling or
        accepting a non-JSON scalar. Does not copy, encode or mutate input values.
        """
        self.nodes += 1
        if depth > self.max_depth or self.nodes > self.max_nodes:
            raise ExtensionResultError("EXTENSION_LIMIT")
        if isinstance(value, JsonObject):
            self._bytes(2 + max(0, len(value) - 1) + len(value))
            # Keys and children consume independent visits and escaped byte costs.
            for key, child in value.members:
                self._visit(key, depth + 1)
                self._visit(child, depth + 1)
        elif isinstance(value, tuple):
            self._bytes(2 + max(0, len(value) - 1))
            # Array order is retained; measurement allocates no copied collection.
            for child in value:
                self._visit(child, depth + 1)
        elif isinstance(value, str):
            self._bytes(2)
            # Count canonical JSON escaping and UTF-8 width before any encode call.
            for char in value:
                code = ord(char)
                self._bytes(
                    2
                    if char in '"\\\b\f\n\r\t'
                    else (
                        6
                        if code < 32
                        else (
                            1
                            if code < 128
                            else 2 if code < 2048 else 3 if code < 65536 else 4
                        )
                    )
                )
        elif type(value) is int:
            self._integer(value)
        elif value is None or type(value) in (bool, float):
            if type(value) is float and not math.isfinite(value):
                raise ExtensionResultError("EXTENSION_LIMIT")
            self._bytes(len(str(value)) if value is not None else 4)
        else:
            raise ExtensionResultError("EXTENSION_LIMIT")


def budget(limits: ProfileLimits) -> ExtensionBudget:
    """Map limits (ProfileLimits) to a fresh ExtensionBudget; no external effects.

    Invalid capacities raise EXTENSION_LIMIT; the profile object is unchanged.
    """
    return ExtensionBudget(
        max_bytes=limits.document_bytes,
        max_records=limits.artifact_records,
        max_nodes=limits.parse_limits().expanded_nodes,
        max_depth=limits.nesting_depth,
    )


def object_rows(document: JsonObject, key: str) -> tuple[JsonObject, ...]:
    """Return tuple[JsonObject, ...] at key (str) in document (JsonObject).

    Caller supplies a schema-validated array; a missing key raises KeyError.
    This typed narrowing changes no values and performs no I/O.
    """
    return cast("tuple[JsonObject, ...]", document[key])


def check_link_work(inputs: int, diagnostics: int, max_operations: int) -> None:
    """Bound file-to-diagnostic comparisons before emission; return None or fail.

    inputs/diagnostics are nonnegative retained collection lengths (int).
    max_operations is the validated profile node-work ceiling (int). Each possible
    comparison counts as one operation; exhaustion raises EXTENSION_LIMIT. Pure.
    """
    if inputs * diagnostics > max_operations:
        raise ExtensionResultError("EXTENSION_LIMIT")


class ExtensionValidation:
    """Share captured input, path, schema and provenance checks across one import.

    Constructor accepts only a configured, load-valid DiscoverySnapshot. Derived
    indexes are bounded once before allocation. No parsed artifact claim is trusted
    in place of its retained raw bytes; no repository reader or process is used.
    """

    def __init__(self, snapshot: DiscoverySnapshot) -> None:
        """Index snapshot (DiscoverySnapshot); return None after bounded setup.

        Invalid capture/profile/input raises ValueError or ExtensionResultError.
        Stores immutable input references and fresh counters; performs no I/O.
        """
        if type(snapshot) is not DiscoverySnapshot or not snapshot.ok:
            raise ExtensionResultError("EXTENSION_SNAPSHOT")
        snapshot.profile.require_configured()
        self.snapshot = snapshot
        self.limits = snapshot.profile.limits
        if (
            len(snapshot.manifest.files)
            > self.limits.source_files + self.limits.artifact_records
        ):
            raise ExtensionResultError("EXTENSION_LIMIT")
        self.capture = capture_snapshot(snapshot)
        self.projection = extension_input_projection(self.capture)
        self.input_sha256 = hashlib.sha256(canonical_json(self.projection)).hexdigest()
        # Raw lookup is independent of caller-supplied ArtifactSnapshot documents.
        self.files = {item.path: item for item in snapshot.manifest.files}
        self.inputs = object_rows(self.projection, "inputs")
        # File accounting includes excluded frontiers omitted from the input digest.
        self.input_index = {item.path: item for item in self.capture.inputs}
        # Only source/test or exact project inputs can satisfy the current loader
        # contract.
        self.sources = {
            cast("str", item["path"]): item
            for item in self.inputs
            if item["status"] == "inspected"
            and (item["category"] in {"source", "test"} or item["entry_point"] is True)
        }
        # Pinned descriptors were derived from retained Git bytes by the shared
        # projection.
        self.pins = {
            cast("str", item["path"]): item
            for item in object_rows(self.projection, "repository_files")
        }
        self.raw_bytes = 0
        self.line_counts: dict[str, int] = {}
        self.rows = budget(self.limits)
        self.used_paths: set[str] = set()
        self.identifiers: set[tuple[str, str]] = set()

    def inventory_path(self, path: str) -> str:
        """Return contained path (str), or raise EXTENSION_PATH; pure validation."""
        try:
            clean = relative_path(path)
        except (TypeError, ValueError) as error:
            raise ExtensionResultError("EXTENSION_PATH") from error
        if not clean.startswith(self.snapshot.profile.artifacts["inventory"] + "/"):
            raise ExtensionResultError("EXTENSION_PATH")
        return clean

    def read(self, path: str, kind: str) -> tuple[SnapshotFile, JsonObject]:
        """Validate path (str) for kind (str); return (SnapshotFile, JsonObject).

        Rejects reuse, missing files and unsupported schemas with fixed diagnostics.
        Updates raw-byte counters and used paths. Reads only immutable capture
        bytes; ExtensionResultError prevents any partial document return.
        """
        self.inventory_path(path)
        if path in self.used_paths:
            raise ExtensionResultError("EXTENSION_COLLISION")
        file = self.files.get(path)
        # Match loader-specific labels while retaining generic captured artifacts.
        categories = {
            "extension-result-manifest": "extension-result",
            "inventory-snapshot": "inventory",
        }
        if (
            kind not in categories
            or file is None
            or file.category not in {"artifact", categories[kind]}
        ):
            raise ExtensionResultError("EXTENSION_MEMBER")
        self.raw_bytes += len(file.content)
        if self.raw_bytes > self.limits.document_bytes:
            raise ExtensionResultError("EXTENSION_LIMIT")
        checked = validate_document(
            file.content,
            expected_kind=kind,
            expected_version="2.0.0",
            format="json",
            catalog=self.snapshot.catalog,
            limits=self.limits.parse_limits(),
        )
        if not checked.ok or checked.document is None:
            raise ExtensionResultError("EXTENSION_SCHEMA")
        self.used_paths.add(path)
        return file, checked.document

    def source_inputs(self, manifest: JsonObject) -> None:
        """Check manifest (JsonObject) source descriptors against retained pins.

        Returns None or raises EXTENSION_SOURCE for incomplete/mismatched claims.
        Uses bounded indexes without input mutation or I/O.
        """
        inputs = object_rows(manifest, "source_inputs")
        if len(inputs) != len(self.sources):
            raise ExtensionResultError("EXTENSION_SOURCE")
        seen: set[str] = set()
        # Every source claim must match independently captured, immutable local bytes.
        for item in inputs:
            path = cast("str", item["path"])
            expected, pin = self.sources.get(path), self.pins.get(path)
            if path in seen or expected is None or pin is None:
                raise ExtensionResultError("EXTENSION_SOURCE")
            if any(
                item[key] != expected[key] or item[key] != pin[key]
                for key in ("sha256", "size")
            ):
                raise ExtensionResultError("EXTENSION_SOURCE")
            seen.add(path)

    def source(self, value: JsonObject) -> None:
        """Check value (JsonObject) against pinned source bytes; return None.

        Raises EXTENSION_SOURCE for identity/hash/span disagreement. Caches physical
        line counts for retained bytes without changing source content or doing I/O.
        """
        path = cast("str", value["path"])
        expected = self.sources.get(path)
        profile = self.snapshot.profile
        if (
            expected is None
            or value["repository"] != profile.repository.id
            or value["revision"] != profile.repository.revision
            or value["sha256"] != expected["sha256"]
        ):
            raise ExtensionResultError("EXTENSION_SOURCE")
        span = value.get("line_range")
        if isinstance(span, JsonObject):
            if path not in self.line_counts:
                content = self.files[path].content
                count = (
                    content.count(b"\n") + content.count(b"\r") - content.count(b"\r\n")
                )
                count += int(bool(content) and not content.endswith((b"\r", b"\n")))
                self.line_counts[path] = count
            if (
                not cast("int", span["start"])
                <= cast("int", span["end"])
                <= self.line_counts[path]
            ):
                raise ExtensionResultError("EXTENSION_SOURCE")

    def unique(self, family: str, identifier: str) -> None:
        """Reserve family (str) and identifier (str); return None without I/O.

        Mutates the operation-local identity set; duplicates raise
        ExtensionResultError with EXTENSION_COLLISION.
        """
        key = (family, identifier)
        if key in self.identifiers:
            raise ExtensionResultError("EXTENSION_COLLISION")
        self.identifiers.add(key)

    def diagnostics(self, values: tuple[JsonObject, ...], adapter: JsonObject) -> None:
        """Check values (tuple[JsonObject, ...]) for adapter (JsonObject); return None.

        Reserves output/identity counters; invalid ownership, paths or severity
        raises ExtensionResultError. Preserves incomplete results without I/O.
        """
        # Diagnostic paths may describe any accounted input, never arbitrary siblings.
        for item in values:
            self.rows.reserve(item, records=1)
            self.unique("diagnostic", cast("str", item["id"]))
            if item["analyzer_id"] != adapter["id"]:
                raise ExtensionResultError("EXTENSION_IDENTITY")
            if item["path"] is not None and item["path"] not in self.input_index:
                raise ExtensionResultError("EXTENSION_SOURCE")
            if item["severity"] == "error" and item["blocking"] is not True:
                raise ExtensionResultError("EXTENSION_ACCOUNTING")

    def accounting(
        self, document: JsonObject, diagnostics: tuple[JsonObject, ...]
    ) -> None:
        """Check document (JsonObject) with diagnostics (tuple[JsonObject, ...]).

        Returns None; raises EXTENSION_ACCOUNTING for omitted/changed inputs or links.
        Creates bounded local indexes without mutation or external effects.
        """
        files = object_rows(document, "files")
        if (
            len(files) != len(self.capture.inputs)
            or document["exclusions"] != self.capture.exclusions
        ):
            raise ExtensionResultError("EXTENSION_ACCOUNTING")
        # Build one per-path diagnostic index, avoiding repeated file-by-row scans.
        by_path: dict[JsonValue, set[JsonValue]] = {}
        blocking: set[JsonValue] = set()
        # Diagnostic references retain exact path ownership, including blocked files.
        for item in diagnostics:
            by_path.setdefault(item["path"], set()).add(item["id"])
            if item["blocking"] is True:
                blocking.add(item["id"])
        seen: set[str] = set()
        # Raw members must describe the same complete pre-output input selection.
        for item in files:
            path = cast("str", item["path"])
            expected = self.input_index.get(path)
            if path in seen or expected is None:
                raise ExtensionResultError("EXTENSION_ACCOUNTING")
            if (
                item["status"] != expected.status
                or item["sha256"] != expected.sha256
                or item["size"]
                != (len(expected.file.content) if expected.file else None)
                or item["rationale"] != expected.rationale
            ):
                raise ExtensionResultError("EXTENSION_ACCOUNTING")
            ids = set(cast("tuple[JsonValue, ...]", item["diagnostic_ids"]))
            if ids != by_path.get(path, set()):
                raise ExtensionResultError("EXTENSION_ACCOUNTING")
            if item["status"] == "unreadable" and not ids.intersection(blocking):
                raise ExtensionResultError("EXTENSION_ACCOUNTING")
            seen.add(path)
