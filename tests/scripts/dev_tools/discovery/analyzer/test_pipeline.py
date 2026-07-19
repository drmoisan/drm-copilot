"""Unit tests for the analyzer pipeline runner and re-exports (scenario 1)."""

from __future__ import annotations

from pathlib import Path

import pytest

import scripts.dev_tools.discovery.analyzer as analyzer_pkg
from scripts.dev_tools.discovery.analyzer.models import (
    AnalyzerContext,
    ClassifiedUnit,
    ClassifyResult,
    EvidenceRecord,
    ParseResult,
    UnitType,
)
from scripts.dev_tools.discovery.analyzer.pipeline import (
    AnalyzerFileSystem,
    run_analyzer,
)

_DESCRIPTION = "Source file enumerated by the repository inventory analyzer."


class _RecordingAnalyzer:
    """Fake analyzer that records the order its stages are invoked in."""

    name = "recording"

    def __init__(self) -> None:
        self.calls: list[str] = []
        self.expected_records = (
            EvidenceRecord(
                id="inventory-file-0001",
                kind="file",
                location="a.txt",
                captured_at="2026-07-18T00:00:00Z",
                description=_DESCRIPTION,
            ),
        )
        self.expected_written = (Path("/out/inventory-file-0001.json"),)

    def parse(self, ctx: AnalyzerContext) -> ParseResult:
        """Record the parse call and return a fixed parse result."""
        assert isinstance(ctx, AnalyzerContext)
        self.calls.append("parse")
        return ParseResult(paths=("a.txt",))

    def classify(self, parsed: ParseResult) -> ClassifyResult:
        """Record the classify call and return a fixed classify result."""
        assert parsed.paths == ("a.txt",)
        self.calls.append("classify")
        return ClassifyResult(
            units=(ClassifiedUnit(relative_path="a.txt", unit_type=UnitType.FILE),)
        )

    def map(self, classified: ClassifyResult) -> tuple[EvidenceRecord, ...]:
        """Record the map call and return the fixed records."""
        assert classified.units[0].unit_type is UnitType.FILE
        self.calls.append("map")
        return self.expected_records

    def emit(
        self, records: tuple[EvidenceRecord, ...], fs: AnalyzerFileSystem
    ) -> tuple[Path, ...]:
        """Record the emit call; no filesystem access is performed."""
        assert records == self.expected_records
        assert fs is not None
        self.calls.append("emit")
        return self.expected_written


class _ExplodingFileSystem:
    """A seam whose every operation fails, proving the runner touches no disk."""

    def exists(self, path: Path) -> bool:
        """Fail if called."""
        raise AssertionError("filesystem must not be accessed by run_analyzer")

    def is_dir(self, path: Path) -> bool:
        """Fail if called."""
        raise AssertionError("filesystem must not be accessed by run_analyzer")

    def walk_files(self, root: Path) -> tuple[Path, ...]:
        """Fail if called."""
        raise AssertionError("filesystem must not be accessed by run_analyzer")

    def read_bytes(self, path: Path) -> bytes:
        """Fail if called."""
        raise AssertionError("filesystem must not be accessed by run_analyzer")

    def write_text(self, path: Path, content: str) -> None:
        """Fail if called."""
        raise AssertionError("filesystem must not be accessed by run_analyzer")


def _context() -> AnalyzerContext:
    """Return an arbitrary context; the fake analyzer ignores its fields."""
    return AnalyzerContext(
        source_root=Path("/src"),
        include=(),
        exclude=(),
        artifact_root=Path("/out"),
        schema_path=Path("/schemas/discovery/v1/evidence-reference.schema.json"),
        captured_at="2026-07-18T00:00:00Z",
    )


def test_run_analyzer_invokes_stages_in_fixed_order_and_threads_outputs() -> None:
    """run_analyzer calls parse -> classify -> map -> emit and returns their outputs."""
    # Arrange
    analyzer = _RecordingAnalyzer()
    fs = _ExplodingFileSystem()

    # Act
    result = run_analyzer(analyzer, _context(), fs)

    # Assert
    assert analyzer.calls == ["parse", "classify", "map", "emit"]
    assert result.records == analyzer.expected_records
    assert result.written_paths == analyzer.expected_written


def test_package_reexports_public_surface() -> None:
    """The package lazily re-exports Analyzer, run_analyzer, and main."""
    # Act
    exported_run = analyzer_pkg.run_analyzer
    exported_protocol = analyzer_pkg.Analyzer
    exported_main = analyzer_pkg.main

    # Assert
    assert exported_run is run_analyzer
    assert callable(exported_main)
    assert exported_protocol is not None
    assert set(analyzer_pkg.__all__) == {"Analyzer", "main", "run_analyzer"}


def test_package_unknown_attribute_raises_attribute_error() -> None:
    """Accessing an unknown package attribute raises AttributeError."""
    # Act / Assert
    with pytest.raises(AttributeError):
        _ = analyzer_pkg.does_not_exist
