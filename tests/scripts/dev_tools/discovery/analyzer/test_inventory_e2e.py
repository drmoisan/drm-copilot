"""End-to-end integration test for the inventory analyzer.

Exercises a profile-driven ``AnalyzerContext`` through ``run_analyzer`` to a
collection of schema-conforming Evidence Reference instances on the in-memory
filesystem seam, asserting one instance per unit and byte-identical re-runs for
a fixed injected clock.
"""

from __future__ import annotations

import json
from pathlib import Path

import pytest

from scripts.dev_tools.discovery.analyzer.emitter import serialize_record
from scripts.dev_tools.discovery.analyzer.inventory import InventoryAnalyzer
from scripts.dev_tools.discovery.analyzer.models import AnalyzerContext
from scripts.dev_tools.discovery.analyzer.pipeline import (
    RealAnalyzerFileSystem,
    run_analyzer,
)

_REPO_ROOT = Path(__file__).resolve().parents[5]
_SCHEMA_FILE = (
    _REPO_ROOT / "schemas" / "discovery" / "v1" / "evidence-reference.schema.json"
)


def _build_tree(source_root: Path) -> None:
    """Populate an in-memory consumer source tree."""
    source_root.mkdir(parents=True, exist_ok=True)
    (source_root / "a.txt").write_text("alpha", encoding="utf-8")
    (source_root / "app.sln").write_text("sln", encoding="utf-8")
    sub = source_root / "sub"
    sub.mkdir(parents=True, exist_ok=True)
    (sub / "b.csproj").write_text("proj", encoding="utf-8")


def _context(source_root: Path, out_root: Path) -> AnalyzerContext:
    """Return a profile-driven context (fixed clock) for the e2e run."""
    return AnalyzerContext(
        source_root=source_root,
        include=(),
        exclude=(),
        artifact_root=out_root,
        schema_path=source_root.parent / "schemas" / "evidence-reference.schema.json",
        captured_at="2026-07-18T12:34:56Z",
    )


def test_end_to_end_emits_one_instance_per_unit(mem_fs_path: Path) -> None:
    """run_analyzer emits one schema-conforming instance per inventoried unit."""
    # Arrange
    source_root = mem_fs_path / "consumer"
    _build_tree(source_root)
    fs = RealAnalyzerFileSystem()
    analyzer = InventoryAnalyzer(fs=fs)
    ctx = _context(source_root, mem_fs_path / "out")

    # Act
    result = run_analyzer(analyzer, ctx, fs)

    # Assert
    assert len(result.records) == 3
    assert result.written_paths == ()
    assert not ctx.artifact_root.exists()
    kinds = {record.kind for record in result.records}
    assert kinds == {"file"}
    unit_types = {dict(record.metadata)["unit_type"] for record in result.records}
    assert unit_types == {"file", "solution", "project"}


def test_end_to_end_is_byte_identical_on_rerun(mem_fs_path: Path) -> None:
    """Re-running with a fixed clock produces byte-identical instance content."""
    # Arrange
    source_root = mem_fs_path / "consumer"
    _build_tree(source_root)
    fs = RealAnalyzerFileSystem()
    analyzer = InventoryAnalyzer(fs=fs)
    ctx = _context(source_root, mem_fs_path / "out")

    # Act
    first = run_analyzer(analyzer, ctx, fs)
    first_content = {
        record.id: serialize_record(
            record, ctx.artifact_root / f"{record.id}.json", ctx.schema_path
        )
        for record in first.records
    }
    second = run_analyzer(analyzer, ctx, fs)
    second_content = {
        record.id: serialize_record(
            record, ctx.artifact_root / f"{record.id}.json", ctx.schema_path
        )
        for record in second.records
    }

    # Assert
    assert first_content and first_content == second_content


@pytest.mark.skipif(
    not _SCHEMA_FILE.exists(),
    reason="discovery v1 evidence-reference schema not present (pre-merge)",
)
def test_end_to_end_instances_validate_against_schema(mem_fs_path: Path) -> None:
    """Every emitted instance validates against the discovery v1 schema."""
    # Arrange
    jsonschema = pytest.importorskip("jsonschema")
    schema = json.loads(_SCHEMA_FILE.read_text(encoding="utf-8"))
    source_root = mem_fs_path / "consumer"
    _build_tree(source_root)
    fs = RealAnalyzerFileSystem()
    analyzer = InventoryAnalyzer(fs=fs)
    ctx = _context(source_root, mem_fs_path / "out")

    # Act
    result = run_analyzer(analyzer, ctx, fs)

    # Assert
    assert len(result.records) == 3 and not result.written_paths
    for record in result.records:
        document = json.loads(
            serialize_record(
                record, ctx.artifact_root / f"{record.id}.json", ctx.schema_path
            )
        )
        jsonschema.validate(instance=document, schema=schema)
