"""Unit tests for the inventory analyzer enumeration, filtering, and classify."""

from __future__ import annotations

from pathlib import Path

import pytest

from scripts.dev_tools.discovery.analyzer.inventory import (
    DEFAULT_MARKERS,
    AnalyzerError,
    InventoryAnalyzer,
    classify_paths,
    classify_unit,
    filter_paths,
)
from scripts.dev_tools.discovery.analyzer.models import (
    AnalyzerContext,
    ParseResult,
    UnitType,
)
from scripts.dev_tools.discovery.analyzer.pipeline import RealAnalyzerFileSystem
from scripts.dev_tools.discovery.domain_profile_models import DomainProfileError

_SCHEMA = Path("/schemas/discovery/v1/evidence-reference.schema.json")


def _write(root: Path, relative: str, content: str = "x") -> None:
    """Create an in-memory file at ``root/relative``, making parent dirs."""
    target = root / relative
    target.parent.mkdir(parents=True, exist_ok=True)
    target.write_text(content, encoding="utf-8")


def _context(
    root: Path, include: tuple[str, ...] = (), exclude: tuple[str, ...] = ()
) -> AnalyzerContext:
    """Return a context rooted at ``root`` with the given globs."""
    return AnalyzerContext(
        source_root=root,
        include=include,
        exclude=exclude,
        artifact_root=root / "out",
        schema_path=_SCHEMA,
        captured_at="2026-07-18T00:00:00Z",
    )


# Scenario 2 — enumeration and deterministic POSIX ordering.


def test_parse_enumerates_tree_in_deterministic_posix_order(mem_fs_path: Path) -> None:
    """parse returns every file as a consumer-relative POSIX path, POSIX-sorted."""
    # Arrange
    _write(mem_fs_path, "b.txt")
    _write(mem_fs_path, "a.txt")
    _write(mem_fs_path, "sub/z.txt")
    _write(mem_fs_path, "sub/deep/m.txt")
    analyzer = InventoryAnalyzer(fs=RealAnalyzerFileSystem())

    # Act
    result = analyzer.parse(_context(mem_fs_path))

    # Assert
    assert result.paths == ("a.txt", "b.txt", "sub/deep/m.txt", "sub/z.txt")


def test_parse_is_repeatable(mem_fs_path: Path) -> None:
    """Re-running parse on the same tree yields identical ordered output."""
    # Arrange
    _write(mem_fs_path, "one.txt")
    _write(mem_fs_path, "two.txt")
    analyzer = InventoryAnalyzer(fs=RealAnalyzerFileSystem())
    ctx = _context(mem_fs_path)

    # Act
    first = analyzer.parse(ctx)
    second = analyzer.parse(ctx)

    # Assert
    assert first.paths == second.paths


# Scenario 6 — unreachable / missing source root.


def test_parse_missing_root_raises_analyzer_error(mem_fs_path: Path) -> None:
    """A missing source root fails fast with AnalyzerError naming the path."""
    # Arrange
    missing = mem_fs_path / "does_not_exist"
    analyzer = InventoryAnalyzer(fs=RealAnalyzerFileSystem())

    # Act / Assert
    with pytest.raises(AnalyzerError) as exc_info:
        analyzer.parse(_context(missing))
    assert str(missing) in str(exc_info.value)


def test_parse_file_root_raises_analyzer_error(mem_fs_path: Path) -> None:
    """A source root that is a file (not a directory) fails fast."""
    # Arrange
    _write(mem_fs_path, "root_is_a_file.txt")
    file_root = mem_fs_path / "root_is_a_file.txt"
    analyzer = InventoryAnalyzer(fs=RealAnalyzerFileSystem())

    # Act / Assert
    with pytest.raises(AnalyzerError):
        analyzer.parse(_context(file_root))


def test_classify_before_parse_raises_analyzer_error() -> None:
    """Calling classify before parse fails fast because no context is stashed."""
    # Arrange
    analyzer = InventoryAnalyzer(fs=RealAnalyzerFileSystem())

    # Act / Assert
    with pytest.raises(AnalyzerError, match="parse must run first"):
        analyzer.classify(ParseResult(paths=("a.txt",)))


def test_analyzer_error_is_distinct_from_domain_profile_error() -> None:
    """AnalyzerError and DomainProfileError are distinct ValueError subclasses."""
    # Assert
    assert issubclass(AnalyzerError, ValueError)
    assert issubclass(DomainProfileError, ValueError)
    assert not issubclass(AnalyzerError, DomainProfileError)
    assert not issubclass(DomainProfileError, AnalyzerError)


# Scenario 3 — include/exclude glob handling (pure function).

_PATHS = ("a.txt", "b.log", "dir/c.txt", "dir/d.md")


@pytest.mark.parametrize(
    ("include", "exclude", "expected"),
    [
        pytest.param(("*.txt",), (), ("a.txt", "dir/c.txt"), id="include-only"),
        pytest.param(
            (), ("*.log",), ("a.txt", "dir/c.txt", "dir/d.md"), id="exclude-only"
        ),
        pytest.param(("*.txt",), ("dir/*",), ("a.txt",), id="include-and-exclude"),
        pytest.param((), (), _PATHS, id="empty-include-selects-all"),
    ],
)
def test_filter_paths_glob_matrix(
    include: tuple[str, ...], exclude: tuple[str, ...], expected: tuple[str, ...]
) -> None:
    """filter_paths honors include-only, exclude-only, both, and empty-include."""
    # Act
    result = filter_paths(_PATHS, include, exclude)

    # Assert
    assert result == expected


def test_filter_paths_preserves_input_order() -> None:
    """filter_paths preserves the input ordering of retained paths."""
    # Act
    result = filter_paths(("z.txt", "a.txt"), ("*.txt",), ())

    # Assert
    assert result == ("z.txt", "a.txt")


# Scenario 4 — marker classification (pure function).


@pytest.mark.parametrize(
    ("relative_path", "expected"),
    [
        pytest.param("app.solution", UnitType.SOLUTION, id="solution-marker"),
        pytest.param("lib.project", UnitType.PROJECT, id="project-marker"),
        pytest.param("src/main.txt", UnitType.FILE, id="plain-file"),
        pytest.param("nested/dir/notes.md", UnitType.FILE, id="non-matching"),
        pytest.param("sub/core.solution", UnitType.SOLUTION, id="solution-in-subdir"),
    ],
)
def test_classify_unit_uses_default_markers(
    relative_path: str, expected: UnitType
) -> None:
    """classify_unit tags a path via the default marker table."""
    # Act
    result = classify_unit(relative_path, DEFAULT_MARKERS)

    # Assert
    assert result is expected


def test_classify_unit_honors_custom_marker_table() -> None:
    """Markers are data: a custom table changes classification."""
    # Arrange
    custom = (("*.pkg", UnitType.PROJECT),)

    # Act / Assert
    assert classify_unit("thing.pkg", custom) is UnitType.PROJECT
    assert classify_unit("app.solution", custom) is UnitType.FILE


def test_classify_paths_tags_every_unit() -> None:
    """classify_paths returns one classified unit per input path, in order."""
    # Act
    units = classify_paths(("a.solution", "b.txt"), DEFAULT_MARKERS)

    # Assert
    assert tuple(u.relative_path for u in units) == ("a.solution", "b.txt")
    assert units[0].unit_type is UnitType.SOLUTION
    assert units[1].unit_type is UnitType.FILE


def test_classify_stage_filters_then_tags(mem_fs_path: Path) -> None:
    """The classify stage applies include/exclude before tagging."""
    # Arrange
    _write(mem_fs_path, "a.solution")
    _write(mem_fs_path, "b.txt")
    _write(mem_fs_path, "skip/c.txt")
    _write(mem_fs_path, "d.log")
    analyzer = InventoryAnalyzer(fs=RealAnalyzerFileSystem())
    ctx = _context(mem_fs_path, include=("*.solution", "*.txt"), exclude=("skip/*",))

    # Act
    classified = analyzer.classify(analyzer.parse(ctx))

    # Assert
    tags = {u.relative_path: u.unit_type for u in classified.units}
    assert tags == {"a.solution": UnitType.SOLUTION, "b.txt": UnitType.FILE}
