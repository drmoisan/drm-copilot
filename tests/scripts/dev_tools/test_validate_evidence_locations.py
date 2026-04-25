"""Tests for scripts.dev_tools.validate_evidence_locations.

Covers:
    - find_forbidden_paths yields no results on a tree with no forbidden paths.
    - find_forbidden_paths yields a violation when a forbidden path is present.
    - Non-file entries (directories) are skipped.
    - Entries where relative_to raises ValueError are skipped.
    - main() exits 0 with no output for a clean tree.
    - main() prints violations and exits 1 for a dirty tree.

No temporary filesystem access is used in these tests; rglob is patched via
monkeypatch to return controlled path objects.
"""

from __future__ import annotations

import sys
from pathlib import Path
from unittest.mock import MagicMock, patch

import pytest

from scripts.dev_tools.validate_evidence_locations import find_forbidden_paths


def test_clean_tree_exits_zero(monkeypatch: MagicMock) -> None:
    """find_forbidden_paths yields no results when no forbidden paths exist.

    Scenario: rglob returns only allowed paths (source code and canonical evidence).
    Expected: the generator yields an empty sequence.
    """
    root = Path("/fake/repo")

    # Construct mock file objects that live under allowed paths.
    allowed_paths = [
        Path("/fake/repo/src/hello.ts"),
        Path("/fake/repo/docs/features/active/feat/evidence/baseline/result.md"),
        Path("/fake/repo/artifacts/orchestration/orchestrator-state.json"),
        Path("/fake/repo/artifacts/research/notes.md"),
    ]

    # Each mock path must respond to is_file() → True and relative_to(root)
    # so the generator can compute the relative POSIX form.
    def make_mock_path(absolute: Path) -> MagicMock:
        """Create a minimal mock for a file path used by find_forbidden_paths."""
        mock = MagicMock(spec=Path)
        mock.is_file.return_value = True
        mock.relative_to.return_value = absolute.relative_to(root)
        return mock

    mocked_files = [make_mock_path(p) for p in allowed_paths]

    # Patch rglob on the root instance so no real filesystem is accessed.
    root_mock = MagicMock(spec=Path)
    root_mock.rglob.return_value = iter(mocked_files)

    results = list(find_forbidden_paths(root_mock))

    # Assert: no violations found in a clean tree.
    assert results == [], f"Expected no violations but got: {results}"


def test_seeded_violation_exits_one(monkeypatch: MagicMock) -> None:
    """find_forbidden_paths yields exactly one result for a seeded forbidden path.

    Scenario: rglob returns one file under artifacts/baselines/ (forbidden prefix).
    Expected: exactly one (path, canonical_suggestion) tuple is yielded, where the
    canonical suggestion contains 'evidence/baseline/'.
    """
    root = Path("/fake/repo")
    forbidden_abs = Path("/fake/repo/artifacts/baselines/seeded.md")

    # Build a mock that represents the forbidden file.
    forbidden_mock = MagicMock(spec=Path)
    forbidden_mock.is_file.return_value = True
    forbidden_mock.relative_to.return_value = forbidden_abs.relative_to(root)

    # Patch rglob to return only the one forbidden file.
    root_mock = MagicMock(spec=Path)
    root_mock.rglob.return_value = iter([forbidden_mock])

    results = list(find_forbidden_paths(root_mock))

    # Assert: exactly one violation is reported.
    assert len(results) == 1, f"Expected 1 violation but got {len(results)}: {results}"

    reported_path, canonical_suggestion = results[0]
    assert (
        reported_path is forbidden_mock
    ), "Expected the forbidden mock path to be returned"
    assert "evidence/baseline/" in canonical_suggestion, (
        f"Expected canonical_suggestion to contain 'evidence/baseline/', "
        f"got: {canonical_suggestion!r}"
    )


def test_non_file_entry_is_skipped() -> None:
    """find_forbidden_paths skips entries where is_file() returns False.

    Scenario: rglob returns a directory mock at a forbidden prefix path.
    Expected: the generator yields no results (directories are not violations).
    This covers the 'if not candidate.is_file(): continue' branch.
    """
    # Simulate a directory entry at a forbidden prefix location.
    dir_mock = MagicMock(spec=Path)
    dir_mock.is_file.return_value = False
    dir_mock.relative_to.return_value = Path("artifacts/baselines")

    root_mock = MagicMock(spec=Path)
    root_mock.rglob.return_value = iter([dir_mock])

    results = list(find_forbidden_paths(root_mock))

    # Assert: directory entries are not reported as violations.
    assert (
        results == []
    ), f"Expected no violations for a directory entry but got: {results}"


def test_relative_to_value_error_is_skipped() -> None:
    """find_forbidden_paths skips entries where relative_to raises ValueError.

    Scenario: rglob returns a file whose relative_to call raises ValueError.
    Expected: the generator yields no results (the entry is silently skipped).
    This covers the ValueError except branch.
    """
    root_mock = MagicMock(spec=Path)

    # Build a file mock that raises ValueError when relative_to is called.
    bad_mock = MagicMock(spec=Path)
    bad_mock.is_file.return_value = True
    bad_mock.relative_to.side_effect = ValueError("not relative")

    root_mock.rglob.return_value = iter([bad_mock])

    results = list(find_forbidden_paths(root_mock))

    # Assert: entries with ValueError in relative_to are skipped cleanly.
    assert (
        results == []
    ), f"Expected no violations when relative_to raises but got: {results}"


def test_main_exits_zero_when_clean(
    monkeypatch: MagicMock, capsys: pytest.CaptureFixture[str]
) -> None:
    """main() exits 0 and produces no output when the tree has no violations.

    Scenario: find_forbidden_paths returns an empty iterator.
    Expected: no output to stdout, sys.exit not called (or called with 0).
    """
    # Provide a --root pointing to a real directory that has no forbidden paths
    # by patching find_forbidden_paths to return an empty list.
    with patch(
        "scripts.dev_tools.validate_evidence_locations.find_forbidden_paths",
        return_value=iter([]),
    ):
        monkeypatch.setattr(
            sys, "argv", ["validate_evidence_locations", "--root", "/fake"]
        )
        # main() exits cleanly (no sys.exit(1) call); verify no output.
        from scripts.dev_tools import validate_evidence_locations

        validate_evidence_locations.main()

    captured = capsys.readouterr()
    assert captured.out == "", f"Expected no stdout output but got: {captured.out!r}"


def test_main_exits_one_when_violations_found(
    monkeypatch: MagicMock, capsys: pytest.CaptureFixture[str]
) -> None:
    """main() prints violations and calls sys.exit(1) when violations are found.

    Scenario: find_forbidden_paths returns one violation tuple.
    Expected: stdout contains 'VIOLATION:', sys.exit(1) is raised.
    """
    fake_path = Path("/fake/repo/artifacts/baselines/result.md")
    fake_suggestion = "<FEATURE>/evidence/baseline/"

    with patch(
        "scripts.dev_tools.validate_evidence_locations.find_forbidden_paths",
        return_value=iter([(fake_path, fake_suggestion)]),
    ):
        monkeypatch.setattr(
            sys, "argv", ["validate_evidence_locations", "--root", "/fake"]
        )
        from scripts.dev_tools import validate_evidence_locations

        with pytest.raises(SystemExit) as exc_info:
            validate_evidence_locations.main()

    assert (
        exc_info.value.code == 1
    ), f"Expected exit code 1 but got {exc_info.value.code}"
    captured = capsys.readouterr()
    assert (
        "VIOLATION:" in captured.out
    ), f"Expected 'VIOLATION:' in stdout but got: {captured.out!r}"
    assert (
        str(fake_path) in captured.out
    ), f"Expected path in stdout but got: {captured.out!r}"
