"""Immutable JSON-compatible values and finite structured-input policy."""

from __future__ import annotations

import json
import math
from collections.abc import Mapping
from dataclasses import dataclass
from typing import TYPE_CHECKING, Literal, TypeAlias

from drm_copilot_discovery.findings import MAX_FINDINGS, Finding, ordered_findings

if TYPE_CHECKING:
    from collections.abc import Iterator

JsonScalar: TypeAlias = str | int | float | bool | None
JsonValue: TypeAlias = "JsonScalar | JsonObject | tuple[JsonValue, ...]"
EXPANDED_NODE_MULTIPLIER = 64


def _validate_value(value: JsonValue) -> None:
    """Reject mutable/non-JSON descendants before an immutable value is published."""
    if isinstance(value, tuple):
        # Arrays must be deeply immutable, including direct constructor callers.
        for child in value:
            _validate_value(child)
    elif isinstance(value, str):
        value.encode("utf-8")
    elif type(value) is float and not math.isfinite(value):
        raise ValueError("JSON numbers must be finite")
    elif value is not None and type(value) not in (str, int, float, bool, JsonObject):
        raise ValueError("JSON values must contain immutable JSON-compatible types")


@dataclass(frozen=True)
class JsonObject(Mapping[str, JsonValue]):
    """Store sorted unique JSON members without retaining mutable input containers.

    Parsers construct this value only after resource checks. It exposes read-only
    mapping operations; to_plain_value supplies detached dictionaries for validators.
    """

    members: tuple[tuple[str, JsonValue], ...]

    def __post_init__(self) -> None:
        """Normalize member order and enforce unique string keys and frozen children."""
        # Copy the outer membership sequence before publishing the frozen object.
        members = tuple((key, value) for key, value in self.members)
        if any(type(key) is not str for key, _ in members):
            raise ValueError("JSON object keys must be strings")
        if len({key for key, _ in members}) != len(members):
            raise ValueError("JSON object keys must be unique")
        # Validate only frozen descendants; no caller-owned list or dict is retained.
        for key, value in members:
            key.encode("utf-8")
            _validate_value(value)
        object.__setattr__(self, "members", tuple(sorted(members)))

    def __getitem__(self, key: str) -> JsonValue:
        """Find a member by exact case-sensitive key, raising KeyError if absent."""
        # Read only exact keys; case folding would change artifact identity.
        for name, value in self.members:
            if key == name:
                return value
        raise KeyError(key)

    def __iter__(self) -> Iterator[str]:
        """Iterate sorted keys without exposing a mutable view."""
        return (key for key, _ in self.members)

    def __len__(self) -> int:
        """Return the number of unique object members."""
        return len(self.members)


def to_plain_value(value: JsonValue) -> object:
    """Create detached JSON-native containers from a previously validated snapshot."""
    if isinstance(value, JsonObject):
        # Return detached child containers so validators cannot mutate the snapshot.
        return {key: to_plain_value(child) for key, child in value.members}
    if isinstance(value, tuple):
        # JSON arrays retain order while their mutable projection remains separate.
        return [to_plain_value(child) for child in value]
    return value


def canonical_json(value: JsonValue) -> bytes:
    """Render sorted UTF-8 JSON with LF, without inventing a raw-evidence digest."""
    return (
        json.dumps(
            to_plain_value(value),
            ensure_ascii=False,
            allow_nan=False,
            sort_keys=True,
            separators=(",", ":"),
        )
        + "\n"
    ).encode("utf-8")


@dataclass(frozen=True, kw_only=True)
class ParseLimits:
    """Root-supplied finite parser policy; artifact payloads cannot override it.

    Each expanded mapping, including an envelope, counts as one structural record.
    Every expanded value node counts against a separate derived traversal budget.
    Source enumeration is outside this parser and retains its own profile limit.
    """

    document_bytes: int = 16 * 1024 * 1024
    nesting_depth: int = 64
    artifact_records: int = 100_000
    findings: int = 100

    def __post_init__(self) -> None:
        """Enforce positive bounded limits matching the profile's hard ceilings."""
        ceilings = (
            ("document_bytes", 64 * 1024 * 1024),
            ("nesting_depth", 128),
            ("artifact_records", 1_000_000),
            ("findings", MAX_FINDINGS),
        )
        # Reject every unbounded or ambiguous policy override at construction.
        for name, ceiling in ceilings:
            value = getattr(self, name)
            if type(value) is not int or not 1 <= value <= ceiling:
                raise ValueError(f"{name} must be an integer between 1 and {ceiling}")

    @property
    def expanded_nodes(self) -> int:
        """Bound alias expansion even when arrays contain no mapping records."""
        return self.artifact_records * EXPANDED_NODE_MULTIPLIER


@dataclass(frozen=True, kw_only=True)
class ParsedDocument:
    """Represent either an immutable object or actionable parsing failures.

    A failed parse never exposes a partial graph. The raw input digest, when
    available, is separate from canonical rendering. No filesystem work occurs.
    """

    value: JsonObject | None
    findings: tuple[Finding, ...]
    source_sha256: str | None
    format: Literal["json", "yaml"]

    def __post_init__(self) -> None:
        """Freeze diagnostics and reject contradictory success/failure states."""
        object.__setattr__(
            self, "findings", ordered_findings(self.findings, limit=1000)
        )
        if self.format not in ("json", "yaml"):
            raise ValueError("Parsed document format must be json or yaml")
        if (self.value is None) != any(f.severity == "error" for f in self.findings):
            raise ValueError(
                "Failed documents require errors and cannot expose a value"
            )
        if self.value is not None and type(self.value) is not JsonObject:
            raise ValueError("Parsed document root must be an immutable JSON object")
        if self.source_sha256 is not None and (
            len(self.source_sha256) != 64
            or any(char not in "0123456789abcdef" for char in self.source_sha256)
        ):
            raise ValueError("Source digest must be a lowercase SHA-256 hex string")

    @property
    def ok(self) -> bool:
        """Report parsing success only, without conferring schema or gate validity."""
        return self.value is not None
