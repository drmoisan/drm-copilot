"""Unit tests for Evidence Reference emission (scenario 5)."""

from __future__ import annotations

import json
import re
from pathlib import Path
from typing import TYPE_CHECKING

import pytest

from scripts.dev_tools.discovery.analyzer.emitter import (
    compute_schema_ref,
    serialize_record,
)
from scripts.dev_tools.discovery.analyzer.inventory import InventoryAnalyzer
from scripts.dev_tools.discovery.analyzer.models import (
    AnalyzerContext,
    EvidenceRecord,
    UnitType,
)
from scripts.dev_tools.discovery.analyzer.pipeline import RealAnalyzerFileSystem

if TYPE_CHECKING:
    from collections.abc import Callable

_REPO_ROOT = Path(__file__).resolve().parents[5]
_SCHEMA_FILE = (
    _REPO_ROOT / "schemas" / "discovery" / "v1" / "evidence-reference.schema.json"
)

_SCHEMA_VERSION_RE = re.compile(r"^1\.\d+\.\d+$")
_ID_RE = re.compile(r"^[a-z0-9][a-z0-9._-]*$")

_REQUIRED_FIELDS = {
    "$schema",
    "schema_version",
    "id",
    "kind",
    "location",
    "captured_at",
    "description",
}
_OPTIONAL_FIELDS = {"content_hash", "tool", "metadata"}


def _fixed_clock() -> Callable[[], str]:
    """Return an injected clock producing a fixed ISO-8601 timestamp."""
    return lambda: "2026-07-18T12:34:56Z"


def _record(captured_at: str) -> EvidenceRecord:
    """Return a fully-populated evidence record for serialization tests."""
    return EvidenceRecord(
        id="inventory-file-0badc0de",
        kind="file",
        location="src/main.txt",
        captured_at=captured_at,
        description="Source file enumerated by the repository inventory analyzer.",
        content_hash=("sha256", "0" * 64),
        tool="dev.discovery.inventory",
        metadata=(("unit_type", "file"), ("size_bytes", 3)),
    )


def test_document_has_exact_field_set_and_valid_patterns() -> None:
    """The emitted document has only the schema field set with valid patterns."""
    # Arrange
    clock = _fixed_clock()
    record = _record(clock())
    instance_path = Path("/consumer/out/inventory-file-0badc0de.json")
    schema_path = Path("/consumer/schemas/discovery/v1/evidence-reference.schema.json")

    # Act
    document = json.loads(serialize_record(record, instance_path, schema_path))

    # Assert: no unexpected top-level keys.
    assert set(document) <= _REQUIRED_FIELDS | _OPTIONAL_FIELDS
    assert _REQUIRED_FIELDS <= set(document)
    assert _SCHEMA_VERSION_RE.match(document["schema_version"])
    assert _ID_RE.match(document["id"])
    assert document["captured_at"] == "2026-07-18T12:34:56Z"


def test_schema_ref_is_scheme_less_relative_posix() -> None:
    """$schema is a relative POSIX path with no drive letter and no leading slash."""
    # Arrange
    instance_path = Path("/consumer/out/inst.json")
    schema_path = Path("/consumer/schemas/discovery/v1/evidence-reference.schema.json")

    # Act
    schema_ref = compute_schema_ref(instance_path, schema_path)

    # Assert
    assert not schema_ref.startswith("/")
    assert ":" not in schema_ref.split("/", 1)[0]
    assert schema_ref == "../schemas/discovery/v1/evidence-reference.schema.json"


def test_compute_schema_ref_wraps_relpath_value_error(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """A relpath ValueError (for example different drives) is re-raised clearly."""

    # Arrange
    def _raise(_target: str, start: str) -> str:
        del start
        raise ValueError("paths are on different drives")

    monkeypatch.setattr("os.path.relpath", _raise)

    # Act / Assert
    with pytest.raises(ValueError, match="cannot compute a relative"):
        compute_schema_ref(Path("/a/inst.json"), Path("/b/schema.json"))


def test_compute_schema_ref_rejects_absolute_result(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """A relpath result that is absolute is rejected as not scheme-less relative."""

    # Arrange
    def _absolute(_target: str, start: str) -> str:
        del start
        return "/absolute/schema.json"

    monkeypatch.setattr("os.path.relpath", _absolute)

    # Act / Assert
    with pytest.raises(ValueError, match="not scheme-less relative"):
        compute_schema_ref(Path("/a/inst.json"), Path("/b/schema.json"))


def test_compute_schema_ref_handles_sibling_directories() -> None:
    """A schema in a sibling directory resolves to a relative POSIX path."""
    # Arrange
    instance_path = Path("/a/b/inst.json")
    schema_path = Path("/a/c/schema.json")

    # Act
    schema_ref = compute_schema_ref(instance_path, schema_path)

    # Assert
    assert schema_ref == "../c/schema.json"


def test_captured_at_derives_from_injected_clock() -> None:
    """captured_at in the emitted document comes from the injected clock value."""
    # Arrange
    clock = _fixed_clock()
    record = _record(clock())
    instance_path = Path("/out/x.json")
    schema_path = Path("/schemas/discovery/v1/evidence-reference.schema.json")

    # Act
    document = json.loads(serialize_record(record, instance_path, schema_path))

    # Assert
    assert document["captured_at"] == clock()


def test_emit_writes_instances_through_seam(mem_fs_path: Path) -> None:
    """emit writes one JSON instance per record via the filesystem seam."""
    # Arrange
    (mem_fs_path / "src").mkdir(parents=True, exist_ok=True)
    (mem_fs_path / "src" / "main.txt").write_text("abc", encoding="utf-8")
    fs = RealAnalyzerFileSystem()
    analyzer = InventoryAnalyzer(fs=fs)
    ctx = AnalyzerContext(
        source_root=mem_fs_path,
        include=(),
        exclude=(),
        artifact_root=mem_fs_path / "out",
        schema_path=mem_fs_path / "schemas" / "evidence-reference.schema.json",
        captured_at="2026-07-18T12:34:56Z",
    )

    # Act
    records = analyzer.map(analyzer.classify(analyzer.parse(ctx)))
    written = analyzer.emit(records, fs)

    # Assert
    assert len(written) == 1
    document = json.loads(written[0].read_text(encoding="utf-8"))
    assert document["kind"] == "file"
    assert document["location"] == "src/main.txt"
    assert document["metadata"]["unit_type"] == UnitType.FILE.value


@pytest.mark.skipif(
    not _SCHEMA_FILE.exists(),
    reason="discovery v1 evidence-reference schema not present (pre-merge)",
)
def test_emitted_instance_validates_against_v1_schema() -> None:
    """The emitted instance validates against the discovery v1 schema."""
    # Arrange
    jsonschema = pytest.importorskip("jsonschema")
    record = _record("2026-07-18T12:34:56Z")
    instance_path = Path("/consumer/out/inst.json")
    schema_path = Path("/consumer/schemas/discovery/v1/evidence-reference.schema.json")
    document = json.loads(serialize_record(record, instance_path, schema_path))
    schema = json.loads(_SCHEMA_FILE.read_text(encoding="utf-8"))

    # Act / Assert (raises on invalid)
    jsonschema.validate(instance=document, schema=schema)
