"""Tests for `scripts.dev_tools.discovery.coverage_report`.

Covers the positive parse->build_rows->render pipeline, determinism,
fail-fast validation, the empty-ledger edge case, and CLI exit codes, per
`spec.md` "Seeded Test Conditions" and `research.2026-07-17T15-10.md`
Section 9. Every test injects a fake `ArtifactValidator`; the real
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

import scripts.dev_tools.discovery.coverage_report as coverage_report


def _passing_validator(text: str) -> list[str]:
    """Fake `ArtifactValidator` that always reports no errors."""
    del text
    return []


def _failing_validator(text: str) -> list[str]:
    """Fake `ArtifactValidator` that always reports one fixed error."""
    del text
    return ["malformed field X"]


def test_build_and_render_coverage_report_sorts_and_counts_entries() -> None:
    """Given a conforming Coverage Ledger with out-of-order entries,
    build_coverage_rows then render_coverage_report should produce sorted
    entries and a correct total_entries count."""
    artifact = {
        "entries": [
            {"id": "c-003", "status": "covered"},
            {"id": "a-001", "status": "pending"},
            {"id": "b-002", "status": "covered"},
        ]
    }

    rows, summary = coverage_report.build_coverage_rows(artifact)
    report_text = coverage_report.render_coverage_report(rows, summary)

    rendered = json.loads(report_text)
    assert [entry["id"] for entry in rendered["entries"]] == [
        "a-001",
        "b-002",
        "c-003",
    ]
    assert rendered["summary"]["total_entries"] == 3


def test_render_coverage_report_is_deterministic() -> None:
    """Calling render_coverage_report twice on the same (rows, summary) pair
    must return byte-identical strings."""
    rows, summary = coverage_report.build_coverage_rows(
        {"entries": [{"id": "a-001"}, {"id": "b-002"}]}
    )

    first = coverage_report.render_coverage_report(rows, summary)
    second = coverage_report.render_coverage_report(rows, summary)

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

    monkeypatch.setattr(coverage_report, "read_artifact_text", fake_read_artifact_text)
    monkeypatch.setattr(coverage_report, "write_report", fake_write_report)

    stderr_capture = StringIO()
    monkeypatch.setattr(sys, "stderr", stderr_capture)

    exit_code = coverage_report.main(
        ["--input", "ledger.json"], validator=_failing_validator
    )

    assert exit_code == 1
    assert "malformed field X" in stderr_capture.getvalue()
    assert write_calls == []


def test_build_coverage_rows_handles_missing_entries_key() -> None:
    """An artifact dict with no 'entries' key should render a
    header/summary-only body without raising."""
    rows, summary = coverage_report.build_coverage_rows({})

    assert rows == []
    assert summary["total_entries"] == 0

    report_text = coverage_report.render_coverage_report(rows, summary)
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

    monkeypatch.setattr(coverage_report, "read_artifact_text", fake_read_artifact_text)
    monkeypatch.setattr(coverage_report, "write_report", fake_write_report)

    exit_code = coverage_report.main(
        ["--input", "ledger.json", "--output", "report.json"],
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

    monkeypatch.setattr(coverage_report, "read_artifact_text", fake_read_artifact_text)

    exit_code = coverage_report.main(
        ["--input", "ledger.json"], validator=_failing_validator
    )

    assert exit_code == 1


def test_main_writes_to_stdout_when_output_omitted(
    monkeypatch: MonkeyPatch, capsys: pytest.CaptureFixture[str]
) -> None:
    """main should print the rendered report to stdout when --output is
    omitted."""

    def fake_read_artifact_text(path: Path) -> str:
        del path
        return json.dumps({"entries": [{"id": "a-001"}]})

    monkeypatch.setattr(coverage_report, "read_artifact_text", fake_read_artifact_text)

    exit_code = coverage_report.main(
        ["--input", "ledger.json"], validator=_passing_validator
    )

    assert exit_code == 0
    captured = capsys.readouterr()
    assert '"id": "a-001"' in captured.out
