"""Bound deterministic report values without granting completion or write authority."""

from __future__ import annotations

import math
import re
from dataclasses import dataclass
from typing import cast

from drm_copilot_discovery.models import (
    JsonObject,
    JsonValue,
    ParseLimits,
    canonical_json,
    to_plain_value,
)
from drm_copilot_discovery.parsing import parse_document
from drm_copilot_discovery.rendering import render_pretty_json, sort_rows


class ReportLimitError(ValueError):
    """Reject a complete report operation with a fixed resource diagnostic.

    Raised before an over-budget traversal, copy or encoding. It carries no
    partial report, external state or I/O authority; callers report the failure.
    """

    def __init__(self) -> None:
        """Initialize the fixed error; return None without exposing input values."""
        super().__init__("REPORT_LIMIT: report exceeds configured resource limits")


class ReportBudget:
    """Reserve one projection's independent work and canonical JSON capacities.

    Construct from ParseLimits, reserve work before aggregate scans, then measure
    existing values before copying or encoding. Bytes mean canonical UTF-8 JSON
    with ensure_ascii=False, including escaping and a trailing LF. Node visits,
    mapping records and nesting have independent limits. Counters decrease only;
    exhaustion aborts the whole operation. Only local counters mutate; no I/O or
    caller mutation occurs. Integer values are limited to signed 64-bit magnitude.
    """

    def __init__(self, limits: ParseLimits, *, pretty: bool = False) -> None:
        """Initialize from limits (ParseLimits); return None without I/O.

        pretty (bool) reserves indent=2, ensure_ascii=True compatibility JSON
        instead. Invalid policy raises ValueError. Copies capacities only.
        """
        if type(limits) is not ParseLimits or type(pretty) is not bool:
            raise ValueError("Report policy requires ParseLimits and a boolean style")
        self.limits = ParseLimits(
            document_bytes=limits.document_bytes,
            artifact_records=limits.artifact_records,
            nesting_depth=limits.nesting_depth,
        )
        self.bytes_left = self.limits.document_bytes - 1
        self.nodes_left = self.limits.expanded_nodes
        self.records_left = self.limits.artifact_records
        self.work_left = self.limits.expanded_nodes
        self.pretty = pretty

    def work(self, count: int) -> None:
        """Reserve count (nonnegative exact int) work units; return None.

        Raises ReportLimitError before performing excess work. Only the local
        work counter changes; units are explicitly named by each caller.
        """
        if type(count) is not int or not 0 <= count <= self.work_left:
            raise ReportLimitError()
        self.work_left -= count

    def spend(self, count: int) -> None:
        """Reserve count (nonnegative exact int) encoded bytes; return None.

        Raises ReportLimitError before allocation; only the byte counter changes.
        """
        if type(count) is not int or not 0 <= count <= self.bytes_left:
            raise ReportLimitError()
        self.bytes_left -= count

    def text(self, value: str) -> None:
        """Measure value (str) as a JSON string; return None without encoding.

        Raises ValueError for invalid Unicode or ReportLimitError on capacity.
        Only byte counters change; supplementary scalars use four UTF-8 bytes.
        """
        if len(value) + 2 > self.bytes_left:
            raise ReportLimitError()
        self.spend(2)
        # Account for JSON escapes before creating any encoded or escaped copy.
        for character in value:
            code = ord(character)
            if 0xD800 <= code <= 0xDFFF:
                raise ValueError("Report contains invalid Unicode")
            if character in '\\"\b\f\n\r\t':
                self.spend(2)
            elif code < 32:
                self.spend(6)
            elif self.pretty and code >= 128:
                self.spend(6 if code < 65536 else 12)
            else:
                self.spend(
                    1 if code < 128 else 2 if code < 2048 else 3 if code < 65536 else 4
                )

    def check(self, value: object, depth: int = 1) -> None:
        """Measure value (JSON-shaped object) at depth (int); return None.

        Supports exact dict/list/tuple scalars and immutable JsonObject. Rejects
        malformed values with ValueError and resource/cycle excess with
        ReportLimitError. Does not allocate collection copies or encode input.
        """
        if (
            type(depth) is not int
            or not 1 <= depth <= self.limits.nesting_depth
            or self.nodes_left < 1
        ):
            raise ReportLimitError()
        self.nodes_left -= 1
        # Reject unknown containers instead of executing arbitrary Mapping hooks.
        if type(value) in (dict, JsonObject):
            mapping = cast("dict[str, object] | JsonObject", value)
            if self.records_left < 1 or 2 * len(mapping) > self.nodes_left:
                raise ReportLimitError()
            self.records_left -= 1
            self.spend(2 + max(0, len(mapping) - 1) + len(mapping))
            if self.pretty and mapping:
                self.spend(
                    len(mapping)
                    + len(mapping)
                    + 1
                    + 2 * depth * len(mapping)
                    + 2 * (depth - 1)
                )
            members = (
                mapping.members if isinstance(mapping, JsonObject) else mapping.items()
            )
            # Direct immutable pairs avoid repeated linear Mapping key lookups.
            for key, child in members:
                if type(key) is not str:
                    raise ValueError("Report keys must be strings")
                self.check(key, depth + 1)
                self.check(child, depth + 1)
        elif type(value) in (list, tuple):
            sequence = cast("list[object] | tuple[object, ...]", value)
            if len(sequence) > self.nodes_left:
                raise ReportLimitError()
            self.spend(2 + max(0, len(sequence) - 1))
            if self.pretty and sequence:
                self.spend(
                    len(sequence) + 1 + 2 * depth * len(sequence) + 2 * (depth - 1)
                )
            # A cyclic caller container eventually fails the finite depth guard.
            for child in sequence:
                self.check(child, depth + 1)
        elif type(value) is str:
            self.text(value)
        elif type(value) is int:
            integer = value
            if integer.bit_length() > 63:
                raise ReportLimitError()
            self.spend(len(str(integer)))
        elif type(value) is float:
            number = value
            if not math.isfinite(number):
                raise ValueError("Report numbers must be finite")
            self.spend(len(str(number)))
        elif value is None or type(value) is bool:
            self.spend(4 if value is None or value is True else 5)
        else:
            raise ValueError("Report requires JSON-compatible values")


def _freeze(value: object) -> JsonValue:
    """Detach prechecked value (JSON object); return deeply immutable JsonValue.

    Called only after ReportBudget.check. No I/O, input mutation or validation
    authority is created; malformed input has already raised ValueError.
    """
    if type(value) in (dict, JsonObject):
        mapping = cast("dict[str, object] | JsonObject", value)
        members = (
            mapping.members if isinstance(mapping, JsonObject) else mapping.items()
        )
        # The prospective pass reserved direct pairs before this linear copy.
        return JsonObject(tuple((key, _freeze(child)) for key, child in members))
    if type(value) in (list, tuple):
        # Preserve authored array order while detaching mutable caller containers.
        return tuple(
            _freeze(child) for child in cast("list[object] | tuple[object, ...]", value)
        )
    return cast("JsonValue", value)


def bounded_object(value: object, *, limits: ParseLimits) -> JsonObject:
    """Detach value (dict/JsonObject) within limits (ParseLimits); return JsonObject.

    Raises ValueError for malformed JSON/root or ReportLimitError for excess.
    No I/O or caller mutation occurs; the result provides no validation authority.
    """
    if type(value) not in (dict, JsonObject):
        raise ValueError("Report requires an object root")
    ReportBudget(limits).check(value)
    return cast("JsonObject", _freeze(value))


def ratio(numerator: int, denominator: int, *, unit: str) -> JsonObject:
    """Return an explicit ratio for nonnegative exact integer counts and str unit.

    Zero denominator has percentage None. Invalid or inverted counts raise
    ValueError; no I/O, caller mutation or readiness inference occurs.
    """
    if (
        type(numerator) is not int
        or type(denominator) is not int
        or not 0 <= numerator <= denominator
        or denominator.bit_length() > 63
        or type(unit) is not str
        or not unit
    ):
        raise ValueError("Report ratios require an explicit unit and valid counts")
    return JsonObject(
        (
            ("numerator", numerator),
            ("denominator", denominator),
            (
                "percentage",
                round(100 * numerator / denominator, 6) if denominator else None,
            ),
            ("unit", unit),
        )
    )


@dataclass(frozen=True, kw_only=True)
class DiscoveryReport:
    """Render one detached bounded report without authenticating its claims.

    Generation supplies the canonical recomputed document. Construction freezes
    it and checks limits; it never validates a graph or authorizes publication.
    JSON and Markdown render the same document. Each instance is immutable and
    has no I/O, mutation or ambient state. Limits bound canonical JSON; Markdown
    includes a fixed heading and a bounded pretty JSON rendering of those fields.
    """

    document: JsonObject
    limits: ParseLimits = ParseLimits()

    def __post_init__(self) -> None:
        """Freeze document (JsonObject) under limits; return None without I/O.

        Raises ValueError/ReportLimitError for malformed or oversized data.
        """
        object.__setattr__(
            self, "document", bounded_object(self.document, limits=self.limits)
        )

    def to_dict(self) -> dict[str, object]:
        """Return detached dict fields; no I/O, readiness decision or input mutation."""
        return cast("dict[str, object]", to_plain_value(self.document))

    def to_json(self) -> str:
        """Return canonical LF-terminated UTF-8 JSON text; no external effects."""
        return canonical_json(self.document).decode("utf-8")

    def to_markdown(self) -> str:
        """Return an exact JSON-backed Markdown view; no I/O or independent counts.

        The fixed fence encloses pretty JSON, so embedded Markdown and escaped
        newlines cannot close it. Raises ReportLimitError before rendering if
        whitespace or ASCII escaping would exceed the independent output budget.
        """
        prefix, suffix = "# Discovery coverage report\n\n```json\n", "```\n"
        budget = ReportBudget(self.limits, pretty=True)
        budget.spend(len(prefix) + len(suffix))
        budget.check(self.document)
        return prefix + render_pretty_json(self.to_dict()) + suffix


def _legacy_version(value: object) -> None:
    """Check value (optional version scalar); return None for absent or v1 family.

    Raises ValueError for other versions. No I/O, mutation or schema assurance.
    """
    if value is not None and (
        not isinstance(value, str) or re.fullmatch(r"1\.\d+\.\d+", value) is None
    ):
        raise ValueError("Use a captured v2 snapshot for discovery coverage")


def parse_coverage_ledger(text: str) -> dict[str, object]:
    """Parse compatibility text (str) to a detached bounded dict, without I/O.

    Rejects malformed/duplicate/nonfinite JSON and explicit v2 with ValueError.
    This reader grants no schema, evidence or graph-completion assurance.
    """
    parsed = parse_document(text, format="json")
    if not parsed.ok or parsed.value is None:
        raise ValueError("Coverage compatibility input requires valid bounded JSON")
    value = cast("dict[str, object]", to_plain_value(parsed.value))
    _legacy_version(value.get("schema_version"))
    return value


def build_coverage_rows(
    artifact: dict[str, object],
) -> tuple[list[dict[str, object]], dict[str, object]]:
    """Project compatibility artifact (dict) into detached sorted rows and counts.

    Returns (list[dict], dict) with total_entries only; never claims completion.
    Raises ValueError for unsafe shape/version or ReportLimitError on excess.
    Preserves v1 fields and old id-based sorting; no I/O or caller mutation.
    """
    value = bounded_object(artifact, limits=ParseLimits())
    _legacy_version(value.get("schema_version"))
    entries = value.get("entries", ())
    if not isinstance(entries, tuple) or any(
        not isinstance(row, JsonObject) for row in entries
    ):
        raise ValueError("Coverage entries must be JSON objects")
    # Detached row dictionaries preserve the safe legacy helper return contract.
    rows = [cast("dict[str, object]", to_plain_value(row)) for row in entries]
    return sort_rows(
        rows, id_field="unit_id" if value.get("schema_version") else "id"
    ), {"total_entries": len(rows)}


def render_coverage_report(
    rows: list[dict[str, object]], summary: dict[str, object]
) -> str:
    """Render compatibility rows (list[dict]) and summary (dict) as pretty JSON.

    Returns deterministic LF text; raises ValueError/ReportLimitError on unsafe
    input. It supplies no v2 validation, publication, I/O or mutation authority.
    """
    value = bounded_object({"entries": rows, "summary": summary}, limits=ParseLimits())
    # Retain the established pretty JSON bytes for safe compatibility callers.
    ReportBudget(ParseLimits(), pretty=True).check(value)
    return render_pretty_json(to_plain_value(value))
