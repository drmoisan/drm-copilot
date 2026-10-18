"""Immutable, actionable diagnostics with deterministic bounded aggregation."""

from __future__ import annotations

import re
from dataclasses import dataclass
from typing import TYPE_CHECKING, Literal

if TYPE_CHECKING:
    from collections.abc import Iterable

Severity = Literal["error", "warning", "info"]
MAX_FINDINGS = 1000


def validate_finding_path(path: str) -> None:
    """Check only v2 wire spelling; filesystem authorization belongs to path policy."""
    pattern = (
        r"(?!/)(?!.*(?:^|/)\.{1,2}(?:/|$))"
        r"[^/\\:\x00-\x1f\u2028\u2029*?<>|]+"
        r"(?:/[^/\\:\x00-\x1f\u2028\u2029*?<>|]+)*"
    )
    if not re.fullmatch(pattern, path):
        raise ValueError("Finding paths must use workspace-relative POSIX spelling")
    path.encode("utf-8")


@dataclass(frozen=True, kw_only=True)
class Finding:
    """Carry one wire-compatible diagnostic without I/O or permission authority.

    Construction validates required text and freezes related references. The
    value can be sorted, hashed, or projected into a fresh wire dictionary.
    """

    code: str
    message: str
    next_action: str
    severity: Severity = "error"
    artifact_path: str | None = None
    pointer: str = ""
    related_ids: tuple[str, ...] = ()
    related_paths: tuple[str, ...] = ()

    def __post_init__(self) -> None:
        """Reject invalid wire fields and freeze references; perform no I/O."""
        if not re.fullmatch(r"[A-Z][A-Z0-9_]*", self.code):
            raise ValueError("Finding code must use uppercase letters and underscores")
        if self.severity not in ("error", "warning", "info"):
            raise ValueError("Finding severity must be error, warning, or info")
        if self.code == "FINDINGS_LIMIT" and self.severity != "error":
            raise ValueError("The reserved FINDINGS_LIMIT marker must be an error")
        if not self.message.strip() or not self.next_action.strip():
            raise ValueError("Finding message and next_action must be nonblank")
        if not re.fullmatch(r"(?:/(?:[^~/]|~[01])*)*", self.pointer):
            raise ValueError("Finding pointer must be an RFC 6901 JSON pointer")
        if self.artifact_path is not None:
            validate_finding_path(self.artifact_path)
        # Freeze and sort references so caller order cannot change diagnostics.
        for name in ("related_ids", "related_paths"):
            object.__setattr__(self, name, tuple(sorted(set(getattr(self, name)))))
        # Keep references compatible with the shared artifact identifier grammar.
        for identifier in self.related_ids:
            if not re.fullmatch(r"[a-z][a-z0-9]*(?:[._-][a-z0-9]+)*", identifier):
                raise ValueError("Finding related IDs must be stable identifiers")
        # Validate diagnostic spelling without granting filesystem access.
        for path in self.related_paths:
            validate_finding_path(path)

    def to_dict(self) -> dict[str, object]:
        """Return a fresh service-result finding dictionary without shared lists."""
        return {
            "code": self.code,
            "severity": self.severity,
            "artifact_path": self.artifact_path,
            "pointer": self.pointer,
            "related_ids": list(self.related_ids),
            "related_paths": list(self.related_paths),
            "message": self.message,
            "next_action": self.next_action,
        }


def finding_key(finding: Finding) -> tuple[object, ...]:
    """Order by path, pointer, code and IDs, with stable ties for all other fields."""
    return (
        finding.artifact_path or "",
        finding.pointer,
        finding.code,
        finding.related_ids,
        finding.related_paths,
        finding.severity,
        finding.message,
        finding.next_action,
    )


def child_pointer(pointer: str, part: str | int) -> str:
    """Append one escaped object key or array index to a valid JSON pointer."""
    return pointer + "/" + str(part).replace("~", "~0").replace("/", "~1")


class FindingCollector:
    """Retain the smallest bounded diagnostic set independently of arrival order.

    Each parser owns one collector. Additions mutate only this private buffer;
    snapshots are immutable and include a blocking truncation marker when needed.
    """

    def __init__(self, *, limit: int = 100) -> None:
        """Set a finite diagnostic budget; reject boolean or out-of-range limits."""
        if type(limit) is not int or not 1 <= limit <= MAX_FINDINGS:
            raise ValueError(f"Finding limit must be between 1 and {MAX_FINDINGS}")
        self._limit = limit
        self._items: list[Finding] = []
        self._truncated = False
        self._upstream_marker: Finding | None = None

    def add(self, finding: Finding) -> None:
        """Keep a bounded sorted unique finding set without retaining discarded data."""
        if finding.code == "FINDINGS_LIMIT":
            if self._upstream_marker is None or finding_key(finding) < finding_key(
                self._upstream_marker
            ):
                self._upstream_marker = finding
            return
        if finding in self._items:
            return
        self._items.append(finding)
        self._items.sort(key=finding_key)
        if len(self._items) > self._limit:
            self._items.pop()
            self._truncated = True

    @property
    def findings(self) -> tuple[Finding, ...]:
        """Return bounded findings with a blocker whenever diagnostics were omitted."""
        if not self._truncated and self._upstream_marker is None:
            return tuple(self._items)
        marker = self._upstream_marker or Finding(
            code="FINDINGS_LIMIT",
            message=f"Additional diagnostics exceed the {self._limit}-finding limit.",
            next_action="Correct the reported defects and validate the document again.",
        )
        return tuple(sorted((*self._items[: self._limit - 1], marker), key=finding_key))


def ordered_findings(
    findings: Iterable[Finding], *, limit: int = 100
) -> tuple[Finding, ...]:
    """Deduplicate and order an iterable while keeping memory bounded by limit."""
    collector = FindingCollector(limit=limit)
    # Streaming aggregation prevents a large error population becoming another limit.
    for finding in findings:
        collector.add(finding)
    return collector.findings
