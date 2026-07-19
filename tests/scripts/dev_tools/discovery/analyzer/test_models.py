"""Unit tests for the analyzer value objects and ``UnitType`` enum."""

from __future__ import annotations

import dataclasses
from pathlib import Path

import pytest

from scripts.dev_tools.discovery.analyzer.models import (
    SCHEMA_VERSION_V1,
    AnalyzerContext,
    AnalyzerRunResult,
    ClassifiedUnit,
    ClassifyResult,
    EvidenceRecord,
    ParseResult,
    UnitType,
)


def test_unit_type_members_are_the_three_neutral_categories() -> None:
    """UnitType exposes exactly file, project, and solution members."""
    # Arrange / Act
    values = {member.value for member in UnitType}

    # Assert
    assert values == {"file", "project", "solution"}
    assert UnitType.FILE == "file"
    assert UnitType.PROJECT.value == "project"
    assert UnitType.SOLUTION.value == "solution"


def test_analyzer_context_is_frozen() -> None:
    """AnalyzerContext rejects attribute mutation."""
    # Arrange
    ctx = AnalyzerContext(
        source_root=Path("/src"),
        include=("*.txt",),
        exclude=(),
        artifact_root=Path("/out"),
        schema_path=Path("/schemas/discovery/v1/evidence-reference.schema.json"),
        captured_at="2026-07-18T00:00:00Z",
    )

    # Act / Assert
    with pytest.raises(dataclasses.FrozenInstanceError):
        ctx.captured_at = "changed"  # type: ignore[misc]


def test_parse_result_and_classify_result_are_frozen() -> None:
    """ParseResult and ClassifyResult reject mutation."""
    # Arrange
    parsed = ParseResult(paths=("a.txt", "b.txt"))
    unit = ClassifiedUnit(relative_path="a.txt", unit_type=UnitType.FILE)
    classified = ClassifyResult(units=(unit,))

    # Act / Assert
    with pytest.raises(dataclasses.FrozenInstanceError):
        parsed.paths = ()  # type: ignore[misc]
    with pytest.raises(dataclasses.FrozenInstanceError):
        classified.units = ()  # type: ignore[misc]
    with pytest.raises(dataclasses.FrozenInstanceError):
        unit.unit_type = UnitType.PROJECT  # type: ignore[misc]


def test_evidence_record_is_frozen() -> None:
    """EvidenceRecord rejects mutation."""
    # Arrange
    record = _minimal_record()

    # Act / Assert
    with pytest.raises(dataclasses.FrozenInstanceError):
        record.id = "other"  # type: ignore[misc]


def test_analyzer_run_result_is_frozen() -> None:
    """AnalyzerRunResult rejects mutation."""
    # Arrange
    result = AnalyzerRunResult(records=(), written_paths=())

    # Act / Assert
    with pytest.raises(dataclasses.FrozenInstanceError):
        result.records = ()  # type: ignore[misc]


def test_to_json_dict_required_only_has_exact_field_set() -> None:
    """A record without optionals serializes to exactly the required fields."""
    # Arrange
    record = _minimal_record()

    # Act
    document = record.to_json_dict(
        "../../schemas/discovery/v1/evidence-reference.schema.json"
    )

    # Assert
    assert set(document) == {
        "$schema",
        "schema_version",
        "id",
        "kind",
        "location",
        "captured_at",
        "description",
    }
    assert document["$schema"] == (
        "../../schemas/discovery/v1/evidence-reference.schema.json"
    )
    assert document["schema_version"] == SCHEMA_VERSION_V1


def test_to_json_dict_includes_present_optional_fields() -> None:
    """Optional fields appear only when set, with metadata rendered as a mapping."""
    # Arrange
    record = EvidenceRecord(
        id="inventory-file-abc123",
        kind="file",
        location="src/main.txt",
        captured_at="2026-07-18T00:00:00Z",
        description="Source file enumerated by the repository inventory analyzer.",
        content_hash=("sha256", "deadbeef"),
        tool="dev.discovery.inventory",
        metadata=(("unit_type", "file"), ("size_bytes", 42)),
    )

    # Act
    document = record.to_json_dict("./evidence-reference.schema.json")

    # Assert
    assert document["content_hash"] == {"algorithm": "sha256", "value": "deadbeef"}
    assert document["tool"] == "dev.discovery.inventory"
    assert document["metadata"] == {"unit_type": "file", "size_bytes": 42}


def _minimal_record() -> EvidenceRecord:
    """Return an EvidenceRecord with only the required fields populated."""
    return EvidenceRecord(
        id="inventory-file-0001",
        kind="file",
        location="src/main.txt",
        captured_at="2026-07-18T00:00:00Z",
        description="Source file enumerated by the repository inventory analyzer.",
    )
