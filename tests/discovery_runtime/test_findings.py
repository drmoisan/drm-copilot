"""Verify immutable wire diagnostics and deterministic bounded aggregation."""

from __future__ import annotations

from dataclasses import FrozenInstanceError
from itertools import permutations
from typing import cast

import pytest
from drm_copilot_discovery.findings import (
    Finding,
    FindingCollector,
    Severity,
    child_pointer,
    ordered_findings,
)


def _finding(
    *, code: str = "INVALID_VALUE", path: str | None = None, pointer: str = ""
) -> Finding:
    """Create one fresh actionable diagnostic for ordering and mutation tests."""
    return Finding(
        code=code,
        message="Value is invalid.",
        next_action="Correct the value.",
        artifact_path=path,
        pointer=pointer,
    )


def test_finding_wire_projection_does_not_share_mutable_references() -> None:
    """Construction freezes references and serialization allocates fresh wire lists."""
    finding = Finding(
        code="INVALID_VALUE",
        message="Invalid.",
        next_action="Correct.",
        related_ids=("b", "a", "a"),
        related_paths=("docs/B", "docs/A"),
    )

    wire = finding.to_dict()
    related = wire["related_ids"]
    assert isinstance(related, list)
    related.clear()

    assert finding.related_ids == ("a", "b")
    assert finding.related_paths == ("docs/A", "docs/B")
    assert finding.to_dict()["related_ids"] == ["a", "b"]
    assert set(wire) == {
        "code",
        "severity",
        "artifact_path",
        "pointer",
        "related_ids",
        "related_paths",
        "message",
        "next_action",
    }
    assert hash(finding)
    with pytest.raises(FrozenInstanceError):
        field_name = "code"
        setattr(finding, field_name, "CHANGED")


@pytest.mark.parametrize(
    "path",
    ("docs/Feature Contract.yaml", "docs/évidence.json", ".migration/Record.json"),
)
def test_wire_paths_preserve_supported_consumer_spelling(path: str) -> None:
    """Capitals, spaces, Unicode and dot directories remain valid diagnostic paths."""
    finding = Finding(
        code="INVALID_VALUE",
        message="Invalid.",
        next_action="Correct.",
        artifact_path=path,
        related_paths=(path,),
    )

    assert finding.to_dict()["artifact_path"] == path
    assert finding.related_paths == (path,)


@pytest.mark.parametrize(
    "path",
    (
        "",
        "../a",
        "a/../b",
        "./a",
        "a/./b",
        "/root/a",
        "C:/a",
        "C:a",
        "a\\b",
        "//server/a",
        "a//b",
        "a/",
        "a:stream",
        "a\n",
        "a\u2028b",
        "a?b",
        "a*b",
        "a|b",
        "a<b",
    ),
)
def test_unsafe_wire_paths_are_rejected(path: str) -> None:
    """Wire-level path spelling rejects traversal and nonrelative or ambiguous forms."""
    with pytest.raises(ValueError, match="workspace-relative"):
        _finding(path=path)
    with pytest.raises(ValueError, match="workspace-relative"):
        Finding(
            code="INVALID_VALUE",
            message="Invalid.",
            next_action="Correct.",
            related_paths=(path,),
        )


@pytest.mark.parametrize("code", ("", "lower", "A-B", "A\n", "1A"))
def test_finding_code_has_one_stable_machine_readable_spelling(code: str) -> None:
    """Codes reject lowercase, punctuation and trailing-newline aliases."""
    with pytest.raises(ValueError, match="code"):
        _finding(code=code)


@pytest.mark.parametrize("pointer", ("a", "/a~", "/a~2", "/a~x"))
def test_invalid_json_pointers_cannot_enter_diagnostics(pointer: str) -> None:
    """Pointers preserve RFC 6901 escaping and the explicit empty root pointer."""
    with pytest.raises(ValueError, match="pointer"):
        _finding(pointer=pointer)


def test_child_pointer_escapes_keys_and_preserves_indices() -> None:
    """Slash and tilde spelling is stable for nested source and schema errors."""
    pointer = child_pointer(child_pointer("", "a/b~"), 0)

    assert pointer == "/a~1b~0/0"
    assert _finding(pointer=pointer).pointer == pointer
    assert child_pointer("", "") == "/"


def test_finding_requires_severity_text_and_stable_related_ids() -> None:
    """Invalid direct constructors fail before a malformed diagnostic can be emitted."""
    with pytest.raises(ValueError, match="severity"):
        Finding(
            code="INVALID",
            message="Invalid",
            next_action="Correct",
            severity=cast("Severity", "fatal"),
        )
    with pytest.raises(ValueError, match="nonblank"):
        Finding(code="INVALID", message=" ", next_action="Correct")
    with pytest.raises(ValueError, match="nonblank"):
        Finding(code="INVALID", message="Invalid", next_action=" ")
    with pytest.raises(ValueError, match="identifiers"):
        Finding(
            code="INVALID", message="Invalid", next_action="Correct", related_ids=("A",)
        )


@pytest.mark.parametrize("order", tuple(permutations((0, 1, 2))))
def test_findings_are_ordered_independently_of_arrival(order: tuple[int, ...]) -> None:
    """Order diagnostics by path, pointer, code and references."""
    values = (
        _finding(path="b.json"),
        _finding(path="a.json", pointer="/z"),
        _finding(path="a.json", pointer="/a"),
    )

    actual = ordered_findings(values[index] for index in order)

    assert actual == (values[2], values[1], values[0])


@pytest.mark.parametrize("order", tuple(permutations((0, 1, 2, 3))))
def test_truncated_findings_keep_the_same_bounded_subset(
    order: tuple[int, ...],
) -> None:
    """Excess findings retain the smallest ordered subset and an explicit blocker."""
    values = tuple(_finding(pointer=f"/{index}") for index in range(4))

    actual = ordered_findings((values[index] for index in order), limit=3)

    assert len(actual) == 3
    assert actual[0].code == "FINDINGS_LIMIT"
    assert actual[1:] == values[:2]


def test_collectors_are_independent_and_snapshots_are_immutable() -> None:
    """Duplicates and independent collectors cannot mutate prior snapshots."""
    first = FindingCollector(limit=1)
    second = FindingCollector(limit=1)
    finding = _finding()
    first.add(finding)
    snapshot = first.findings

    first.add(finding)
    second.add(_finding(code="OTHER"))

    assert first.findings == snapshot == (finding,)
    first.add(_finding(code="ANOTHER"))
    assert first.findings[0].code == "FINDINGS_LIMIT"
    assert snapshot == (finding,)
    assert second.findings[0].code == "OTHER"


def test_composed_truncation_is_unique_and_idempotent() -> None:
    """Reaggregating bounded results preserves a field finding and one marker."""
    values = tuple(_finding(pointer=f"/{index}") for index in range(4))
    bounded = ordered_findings(values, limit=2)

    combined = ordered_findings((*bounded, values[3]), limit=2)
    repeated = ordered_findings(combined, limit=2)

    assert combined == repeated == bounded
    assert len(combined) == len(set(combined)) == 2
    assert combined[1] == values[0]
    assert ordered_findings(combined, limit=1000) == combined


@pytest.mark.parametrize("severity", ("warning", "info"))
def test_truncation_marker_cannot_use_nonblocking_severity(severity: Severity) -> None:
    """A reserved marker must not hide errors when a downstream limit is one."""
    with pytest.raises(ValueError, match="must be an error"):
        Finding(
            code="FINDINGS_LIMIT",
            severity=severity,
            message="Diagnostics were omitted.",
            next_action="Correct and retry.",
        )


@pytest.mark.parametrize("reverse", (False, True))
def test_composed_marker_remains_blocking_in_either_order(reverse: bool) -> None:
    """A one-finding budget preserves failure through repeated aggregation."""
    marker = _finding(code="FINDINGS_LIMIT")
    error = _finding(code="REAL_ERROR", pointer="/value")
    inputs = (error, marker) if reverse else (marker, error)

    result = ordered_findings(inputs, limit=1)

    assert result == (marker,)
    assert result[0].severity == "error"
    assert ordered_findings(result, limit=1) == result


@pytest.mark.parametrize("limit", (0, -1, True, 1001))
def test_finding_limits_are_always_positive_and_finite(limit: int) -> None:
    """Direct consumers cannot remove the bounded error population."""
    with pytest.raises(ValueError, match="limit"):
        FindingCollector(limit=limit)
