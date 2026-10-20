"""Tests for `scripts.dev_tools.discovery.coverage_report`.

Covers the positive parse->build_rows->render pipeline, determinism,
fail-fast validation, the empty-ledger edge case, and CLI exit codes, per
`spec.md` "Seeded Test Conditions" and `research.2026-07-17T15-10.md`
Section 9. Validation and I/O are replaced with in-memory seams, including
the lazily imported upstream validator's callable; no schema reads occur.
"""

from __future__ import annotations

import json
import sys
from io import StringIO
from pathlib import Path
from typing import TYPE_CHECKING

import pytest

if TYPE_CHECKING:
    from _pytest.monkeypatch import MonkeyPatch

import scripts.dev_tools.discovery.coverage_report as coverage_report


def _passing_validator(text: str) -> list[str]:
    """Ignore text (str); return no errors without I/O or exceptions."""
    del text
    return []


def _failing_validator(text: str) -> list[str]:
    """Ignore text (str); return one fixed error without I/O or exceptions."""
    del text
    return ["malformed field X"]


def _empty_read(path: Path) -> str:
    """Ignore path (Path); return an empty object without I/O or exceptions."""
    del path
    return "{}"


def _install_memory_io(
    monkeypatch: MonkeyPatch, *, text: str, writes: list[str]
) -> None:
    """Bind text (str) and writes (list[str]) using monkeypatch; return None.

    All operations stay in memory. Only the supplied write list mutates; no
    exceptions are expected. Each caller owns its independent input and list.
    """

    def read(path: Path) -> str:
        """Ignore path (Path); return captured text without I/O or exceptions."""
        del path
        return text

    def write(path: Path, value: str) -> None:
        """Record value (str), ignore path (Path); return None without file I/O."""
        del path
        writes.append(value)

    monkeypatch.setattr(coverage_report, "read_artifact_text", read)
    monkeypatch.setattr(coverage_report, "write_report", write)


def test_build_and_render_coverage_report_sorts_and_counts_entries() -> None:
    """Given safe placeholder coverage rows with out-of-order entries,
    build_coverage_rows then render_coverage_report should produce sorted
    entries and a correct total_entries count."""
    artifact: dict[str, object] = {
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
        """Ignore path (Path); return invalid text without I/O or exceptions."""
        del path
        return "irrelevant text"

    def fake_write_report(path: Path, content: str) -> None:
        """Record path (Path) and content (str); return None without file I/O."""
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
        """Ignore path (Path); return an empty ledger without I/O or exceptions."""
        del path
        return json.dumps({"entries": []})

    def fake_write_report(path: Path, content: str) -> None:
        """Record path (Path) and content (str); return None without file I/O."""
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
        """Ignore path (Path); return invalid text without I/O or exceptions."""
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
        """Ignore path (Path); return a placeholder ledger without file I/O."""
        del path
        return json.dumps({"entries": [{"id": "a-001"}]})

    monkeypatch.setattr(coverage_report, "read_artifact_text", fake_read_artifact_text)

    exit_code = coverage_report.main(
        ["--input", "ledger.json"], validator=_passing_validator
    )

    assert exit_code == 0
    captured = capsys.readouterr()
    assert '"id": "a-001"' in captured.out


@pytest.mark.parametrize("version", ["1.0.0", "1.2.3"])
def test_true_v1_preserves_unit_fields_without_completion_claims(version: str) -> None:
    """For version (str), preserve v1 fields and count entries without I/O."""
    entries: list[dict[str, object]] = [
        {"unit_id": "z", "unit_kind": "file", "status": "characterized"},
        {
            "unit_id": "a",
            "unit_kind": "component",
            "status": "excluded",
            "feature_ids": ["feature"],
            "evidence_refs": ["proof"],
            "notes": "Retained characterization",
        },
    ]
    artifact: dict[str, object] = {
        "schema_version": version,
        "entries": entries,
        "summary": {"total_units": 99, "covered_units": 99},
    }
    original = json.dumps(artifact, sort_keys=True)

    parsed = coverage_report.parse_coverage_ledger(original)
    rows, summary = coverage_report.build_coverage_rows(parsed)
    rendered = json.loads(coverage_report.render_coverage_report(rows, summary))

    assert rendered == {
        "entries": list(reversed(entries)),
        "summary": {"total_entries": 2},
    }
    assert json.dumps(artifact, sort_keys=True) == original


@pytest.mark.parametrize(
    "text",
    [
        "secret malformed text",
        "null",
        "[]",
        '{"entries": null}',
        '{"entries": {}}',
        '{"entries": ["secret"]}',
        '{"entries": [], "entries": []}',
        '{"entries": [{"secret": NaN}]}',
        '{"schema_version": "2.0.0", "entries": []}',
        '{"schema_version": "2.99.0", "entries": []}',
        '{"schema_version": "unknown", "entries": []}',
    ],
)
def test_accepted_invalid_text_never_reaches_output(
    text: str, monkeypatch: MonkeyPatch, capsys: pytest.CaptureFixture[str]
) -> None:
    """Reject unsafe text (str) despite injected validation; emit fixed stderr only."""
    writes: list[str] = []
    _install_memory_io(monkeypatch, text=text, writes=writes)

    result = coverage_report.main(
        ["--input", "ledger.json", "--output", "report.json"],
        validator=_passing_validator,
    )

    captured = capsys.readouterr()
    assert result == 1
    assert writes == []
    assert captured.out == ""
    assert captured.err == "Coverage ledger cannot be rendered as a legacy report\n"


@pytest.mark.parametrize(
    "helper", ["parse_coverage_ledger", "build_coverage_rows", "render_coverage_report"]
)
def test_helper_value_errors_are_redacted_before_any_output(
    helper: str, monkeypatch: MonkeyPatch, capsys: pytest.CaptureFixture[str]
) -> None:
    """For helper (str), catch ValueError without exposing source-bearing text."""
    writes: list[str] = []

    def reject(*values: object) -> object:
        """Ignore values (object tuple); raise input-bearing ValueError without I/O."""
        del values
        raise ValueError("secret-content")

    _install_memory_io(monkeypatch, text="{}", writes=writes)
    monkeypatch.setattr(coverage_report, helper, reject)

    result = coverage_report.main(
        ["--input", "ledger.json", "--output", "report.json"],
        validator=_passing_validator,
    )

    captured = capsys.readouterr()
    assert result == 1 and writes == [] and captured.out == ""
    assert captured.err == "Coverage ledger cannot be rendered as a legacy report\n"


def test_path_and_validator_seams_preserve_call_order(monkeypatch: MonkeyPatch) -> None:
    """Use monkeypatch (MonkeyPatch) to record ordered I/O without touching files."""
    calls: list[tuple[str, object]] = []
    text = '{"entries": [{"id": "item", "status": "pending"}]}'

    def read(path: Path) -> str:
        """Record path (Path); return fixture str without I/O or exceptions."""
        calls.append(("read", path))
        return text

    def validate(text: str) -> list[str]:
        """Record text (str); return no errors without I/O or exceptions."""
        calls.append(("validate", text))
        return []

    def write(path: Path, value: str) -> None:
        """Record path (Path) and value (str); return None without file I/O."""
        calls.append(("write", (path, json.loads(value))))

    monkeypatch.setattr(coverage_report, "read_artifact_text", read)
    monkeypatch.setattr(coverage_report, "write_report", write)

    result = coverage_report.main(
        ["--input", "folder with spaces/é.json", "--output", "../reports/result.json"],
        validator=validate,
    )

    assert result == 0
    assert calls == [
        ("read", Path("folder with spaces/é.json")),
        ("validate", text),
        (
            "write",
            (
                Path("../reports/result.json"),
                {
                    "entries": [{"id": "item", "status": "pending"}],
                    "summary": {"total_entries": 1},
                },
            ),
        ),
    ]


def test_default_validator_and_sys_argv_remain_injectable(
    monkeypatch: MonkeyPatch, capsys: pytest.CaptureFixture[str]
) -> None:
    """Patch schema validation and argv with monkeypatch; assert stdout via capsys."""
    import scripts.dev_tools.validate_discovery_schema_artifacts as validators

    seen: list[str] = []

    def validate(text: str) -> list[str]:
        """Record text (str); return no errors without schema reads or exceptions."""
        seen.append(text)
        return []

    monkeypatch.setattr(validators, "validate_coverage_ledger_text", validate)
    monkeypatch.setattr(coverage_report, "read_artifact_text", _empty_read)
    monkeypatch.setattr(sys, "argv", ["coverage-report", "--input", "ledger.json"])

    result = coverage_report.main()

    captured = capsys.readouterr()
    assert result == 0 and seen == ["{}"]
    assert json.loads(captured.out) == {"entries": [], "summary": {"total_entries": 0}}
    assert captured.err == ""


@pytest.mark.parametrize("arguments", [[], ["--output", "out.json"], ["--input"]])
def test_missing_input_arguments_fail_before_read(
    arguments: list[str], monkeypatch: MonkeyPatch, capsys: pytest.CaptureFixture[str]
) -> None:
    """Reject arguments (list[str]) using argparse before any injected read seam."""
    reads: list[Path] = []

    def read(path: Path) -> str:
        """Record path (Path); return an empty object without file I/O."""
        reads.append(path)
        return "{}"

    monkeypatch.setattr(coverage_report, "read_artifact_text", read)

    with pytest.raises(SystemExit) as failure:
        coverage_report.main(arguments, validator=_passing_validator)

    assert failure.value.code == 2 and reads == []
    assert "error:" in capsys.readouterr().err


@pytest.mark.parametrize("operation", ["read_artifact_text", "write_report"])
def test_io_errors_propagate_without_a_success_report(
    operation: str, monkeypatch: MonkeyPatch, capsys: pytest.CaptureFixture[str]
) -> None:
    """For operation (str), retain the existing I/O exception contract in memory."""
    error = OSError("unavailable path")

    def fail(*values: object) -> str:
        """Ignore values (object tuple); raise the captured OSError without I/O."""
        del values
        raise error

    monkeypatch.setattr(coverage_report, "read_artifact_text", _empty_read)
    monkeypatch.setattr(coverage_report, operation, fail)

    with pytest.raises(OSError) as failure:
        coverage_report.main(
            ["--input", "ledger.json", "--output", "report.json"],
            validator=_passing_validator,
        )

    assert failure.value is error
    captured = capsys.readouterr()
    assert captured.out == "" and captured.err == ""
