"""Tests for `scripts.dev_tools.discovery.completion_report`.

Covers the positive aggregation, determinism, fail-fast dual-validation,
the empty-artifacts edge case, and CLI exit codes for the v1-scoped
Coverage Ledger + Parity Matrix aggregation, per `spec.md`
"Completion-report scope risk". Every test injects fake `ArtifactValidator`
callables for both inputs; the real lazily-imported upstream validators are
never exercised here.
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

import scripts.dev_tools.discovery.completion_report as completion_report


def _passing_validator(text: str) -> list[str]:
    """Fake `ArtifactValidator` that always reports no errors."""
    del text
    return []


def _failing_validator(text: str) -> list[str]:
    """Fake `ArtifactValidator` that always reports one fixed error."""
    del text
    return ["malformed completion input"]


def test_build_completion_summary_reports_entry_counts_and_readiness() -> None:
    """A conforming Coverage Ledger (2 entries) and Parity Matrix (3
    entries) should produce entry_count 2 and 3 respectively, with
    readiness == 'ready'."""
    coverage_artifact = {"entries": [{"id": "a"}, {"id": "b"}]}
    parity_artifact = {"entries": [{"id": "x"}, {"id": "y"}, {"id": "z"}]}

    summary = completion_report.build_completion_summary(
        coverage_artifact, parity_artifact
    )

    assert summary["coverage_ledger"] == {"present": True, "entry_count": 2}
    assert summary["parity_matrix"] == {"present": True, "entry_count": 3}
    assert summary["readiness"] == "ready"


def test_render_completion_report_is_deterministic() -> None:
    """Calling render_completion_report twice on the same summary dict must
    return byte-identical strings."""
    summary = completion_report.build_completion_summary(
        {"entries": [{"id": "a"}]}, {"entries": [{"id": "x"}]}
    )

    first = completion_report.render_completion_report(summary)
    second = completion_report.render_completion_report(summary)

    assert first == second


def test_main_returns_1_on_coverage_validation_failure_and_skips_build(
    monkeypatch: MonkeyPatch,
) -> None:
    """A failing coverage validator (with a passing parity validator) should
    cause main to return 1, print the coverage errors, and never call
    build_completion_summary or write_report."""
    build_calls: list[object] = []
    write_calls: list[tuple[Path, str]] = []

    def fake_read_artifact_text(path: Path) -> str:
        del path
        return "irrelevant text"

    def fake_build_completion_summary(
        coverage_artifact: dict[str, object], parity_artifact: dict[str, object]
    ) -> dict[str, object]:
        build_calls.append((coverage_artifact, parity_artifact))
        return {}

    def fake_write_report(path: Path, content: str) -> None:
        write_calls.append((path, content))

    monkeypatch.setattr(
        completion_report, "read_artifact_text", fake_read_artifact_text
    )
    monkeypatch.setattr(
        completion_report, "build_completion_summary", fake_build_completion_summary
    )
    monkeypatch.setattr(completion_report, "write_report", fake_write_report)

    stderr_capture = StringIO()
    monkeypatch.setattr(sys, "stderr", stderr_capture)

    exit_code = completion_report.main(
        ["--coverage-input", "a.json", "--parity-input", "b.json"],
        coverage_validator=_failing_validator,
        parity_validator=_passing_validator,
    )

    assert exit_code == 1
    assert "malformed completion input" in stderr_capture.getvalue()
    assert build_calls == []
    assert write_calls == []


def test_build_completion_summary_handles_missing_entries_key() -> None:
    """Both artifacts lacking an 'entries' key should still yield
    entry_count 0 for both categories and readiness == 'ready', without
    raising."""
    summary = completion_report.build_completion_summary({}, {})

    assert summary["coverage_ledger"] == {"present": True, "entry_count": 0}
    assert summary["parity_matrix"] == {"present": True, "entry_count": 0}
    assert summary["readiness"] == "ready"


def test_main_returns_0_when_both_validators_pass(monkeypatch: MonkeyPatch) -> None:
    """main should return 0 when both injected validators pass."""
    write_calls: list[tuple[Path, str]] = []

    def fake_read_artifact_text(path: Path) -> str:
        if "coverage" in str(path):
            return json.dumps({"entries": []})
        return json.dumps({"entries": []})

    def fake_write_report(path: Path, content: str) -> None:
        write_calls.append((path, content))

    monkeypatch.setattr(
        completion_report, "read_artifact_text", fake_read_artifact_text
    )
    monkeypatch.setattr(completion_report, "write_report", fake_write_report)

    exit_code = completion_report.main(
        [
            "--coverage-input",
            "coverage.json",
            "--parity-input",
            "parity.json",
            "--output",
            "report.json",
        ],
        coverage_validator=_passing_validator,
        parity_validator=_passing_validator,
    )

    assert exit_code == 0
    assert len(write_calls) == 1
    assert write_calls[0][0] == Path("report.json")


def test_main_returns_1_when_either_validator_fails(monkeypatch: MonkeyPatch) -> None:
    """main should return 1 when either injected validator fails."""

    def fake_read_artifact_text(path: Path) -> str:
        del path
        return "irrelevant text"

    monkeypatch.setattr(
        completion_report, "read_artifact_text", fake_read_artifact_text
    )

    exit_code = completion_report.main(
        ["--coverage-input", "coverage.json", "--parity-input", "parity.json"],
        coverage_validator=_passing_validator,
        parity_validator=_failing_validator,
    )

    assert exit_code == 1


def test_main_writes_to_stdout_when_output_omitted(
    monkeypatch: MonkeyPatch, capsys: pytest.CaptureFixture[str]
) -> None:
    """main should print the rendered report to stdout when --output is
    omitted."""

    def fake_read_artifact_text(path: Path) -> str:
        del path
        return json.dumps({"entries": [{"id": "a"}]})

    monkeypatch.setattr(
        completion_report, "read_artifact_text", fake_read_artifact_text
    )

    exit_code = completion_report.main(
        ["--coverage-input", "coverage.json", "--parity-input", "parity.json"],
        coverage_validator=_passing_validator,
        parity_validator=_passing_validator,
    )

    assert exit_code == 0
    captured = capsys.readouterr()
    assert '"readiness": "ready"' in captured.out
