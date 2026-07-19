"""Tests for `scripts.dev_tools.discovery.parity_report`.

Covers the positive parse->build_rows->render pipeline, determinism,
fail-fast validation, the empty-matrix edge case, and CLI exit codes,
mirroring `test_coverage_report.py`'s coverage for the analogous Parity
Matrix pipeline. Every test injects a fake `ArtifactValidator`; the real
lazily-imported upstream validator is never exercised here.
"""

from __future__ import annotations

import json
import sys
from io import StringIO
from pathlib import Path
from typing import TYPE_CHECKING

if TYPE_CHECKING:
    import pytest
    from _pytest.monkeypatch import MonkeyPatch

import scripts.dev_tools.discovery.parity_report as parity_report


def _passing_validator(text: str) -> list[str]:
    """Fake `ArtifactValidator` that always reports no errors."""
    del text
    return []


def _failing_validator(text: str) -> list[str]:
    """Fake `ArtifactValidator` that always reports one fixed error."""
    del text
    return ["malformed parity field"]


def test_build_and_render_parity_report_sorts_and_counts_entries() -> None:
    """Given a conforming Parity Matrix with out-of-order entries,
    build_parity_rows then render_parity_report should produce sorted
    entries and a correct total_entries count."""
    artifact = {
        "entries": [
            {"id": "feature-c", "parity": "matched"},
            {"id": "feature-a", "parity": "gap"},
            {"id": "feature-b", "parity": "matched"},
        ]
    }

    rows, summary = parity_report.build_parity_rows(artifact)
    report_text = parity_report.render_parity_report(rows, summary)

    rendered = json.loads(report_text)
    assert [entry["id"] for entry in rendered["entries"]] == [
        "feature-a",
        "feature-b",
        "feature-c",
    ]
    assert rendered["summary"]["total_entries"] == 3


def test_render_parity_report_is_deterministic() -> None:
    """Calling render_parity_report twice on the same (rows, summary) pair
    must return byte-identical strings."""
    rows, summary = parity_report.build_parity_rows(
        {"entries": [{"id": "feature-a"}, {"id": "feature-b"}]}
    )

    first = parity_report.render_parity_report(rows, summary)
    second = parity_report.render_parity_report(rows, summary)

    assert first == second


def test_main_returns_1_and_prints_errors_on_validation_failure(
    monkeypatch: MonkeyPatch,
) -> None:
    """A failing injected validator should cause main to return 1, print the
    errors to stderr, and never write a report."""
    write_calls: list[tuple[Path, str]] = []

    def fake_read_artifact_text(path: Path) -> str:
        del path
        return "irrelevant text"

    def fake_write_report(path: Path, content: str) -> None:
        write_calls.append((path, content))

    monkeypatch.setattr(parity_report, "read_artifact_text", fake_read_artifact_text)
    monkeypatch.setattr(parity_report, "write_report", fake_write_report)

    stderr_capture = StringIO()
    monkeypatch.setattr(sys, "stderr", stderr_capture)

    exit_code = parity_report.main(
        ["--input", "matrix.json"], validator=_failing_validator
    )

    assert exit_code == 1
    assert "malformed parity field" in stderr_capture.getvalue()
    assert write_calls == []


def test_build_parity_rows_handles_missing_entries_key() -> None:
    """An artifact dict with no 'entries' key should render a
    header/summary-only body without raising."""
    rows, summary = parity_report.build_parity_rows({})

    assert rows == []
    assert summary["total_entries"] == 0

    report_text = parity_report.render_parity_report(rows, summary)
    rendered = json.loads(report_text)
    assert rendered["entries"] == []
    assert rendered["summary"]["total_entries"] == 0


def test_main_returns_0_on_success(monkeypatch: MonkeyPatch) -> None:
    """main should return 0 when the injected validator passes."""
    write_calls: list[tuple[Path, str]] = []

    def fake_read_artifact_text(path: Path) -> str:
        del path
        return json.dumps({"entries": []})

    def fake_write_report(path: Path, content: str) -> None:
        write_calls.append((path, content))

    monkeypatch.setattr(parity_report, "read_artifact_text", fake_read_artifact_text)
    monkeypatch.setattr(parity_report, "write_report", fake_write_report)

    exit_code = parity_report.main(
        ["--input", "matrix.json", "--output", "report.json"],
        validator=_passing_validator,
    )

    assert exit_code == 0
    assert len(write_calls) == 1
    assert write_calls[0][0] == Path("report.json")


def test_main_returns_1_on_failure(monkeypatch: MonkeyPatch) -> None:
    """main should return 1 when the injected validator fails."""

    def fake_read_artifact_text(path: Path) -> str:
        del path
        return "irrelevant text"

    monkeypatch.setattr(parity_report, "read_artifact_text", fake_read_artifact_text)

    exit_code = parity_report.main(
        ["--input", "matrix.json"], validator=_failing_validator
    )

    assert exit_code == 1


def test_main_writes_to_stdout_when_output_omitted(
    monkeypatch: MonkeyPatch, capsys: pytest.CaptureFixture[str]
) -> None:
    """main should print the rendered report to stdout when --output is
    omitted."""

    def fake_read_artifact_text(path: Path) -> str:
        del path
        return json.dumps({"entries": [{"id": "feature-a"}]})

    monkeypatch.setattr(parity_report, "read_artifact_text", fake_read_artifact_text)

    exit_code = parity_report.main(
        ["--input", "matrix.json"], validator=_passing_validator
    )

    assert exit_code == 0
    captured = capsys.readouterr()
    assert '"id": "feature-a"' in captured.out
