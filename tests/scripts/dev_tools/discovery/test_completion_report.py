"""Verify legacy counts and adapter boundaries using only in-memory collaborators."""

from __future__ import annotations

import json
import sys
from io import StringIO
from pathlib import Path
from typing import TYPE_CHECKING

import pytest

if TYPE_CHECKING:
    from _pytest.monkeypatch import MonkeyPatch

import scripts.dev_tools.discovery.completion_report as completion_report


def _passing_validator(text: str) -> list[str]:
    """Ignore text (str), return an empty list[str]; no errors or side effects."""
    del text
    return []


def _failing_validator(text: str) -> list[str]:
    """Ignore text (str), return one list[str] error; no exception or side effects."""
    del text
    return ["malformed completion input"]


def test_build_completion_summary_reports_entry_counts_and_compatibility() -> None:
    """Retain historical counts without claiming readiness; return None, no I/O."""
    coverage_artifact: dict[str, object] = {"entries": [{"id": "a"}, {"id": "b"}]}
    parity_artifact: dict[str, object] = {
        "entries": [{"id": "x"}, {"id": "y"}, {"id": "z"}]
    }

    summary = completion_report.build_completion_summary(
        coverage_artifact, parity_artifact
    )

    assert summary["coverage_ledger"] == {"present": True, "entry_count": 2}
    assert summary["parity_matrix"] == {"present": True, "entry_count": 3}
    assert summary["validation_scope"] == "legacy-artifact-compatibility-only"
    assert "readiness" not in summary


def test_render_completion_report_is_deterministic() -> None:
    """Render the same summary identically; return None without external effects."""
    summary = completion_report.build_completion_summary(
        {"entries": [{"id": "a"}]}, {"entries": [{"id": "x"}]}
    )

    first = completion_report.render_completion_report(summary)
    second = completion_report.render_completion_report(summary)

    assert first == second


def test_main_returns_1_on_coverage_validation_failure_and_skips_build(
    monkeypatch: MonkeyPatch,
) -> None:
    """Use monkeypatch (MonkeyPatch) to observe rejection; return None, no file I/O.

    Coverage errors prevent build/write and are retained on captured stderr.
    """
    build_calls: list[object] = []
    write_calls: list[tuple[Path, str]] = []

    def fake_read_artifact_text(path: Path) -> str:
        """Ignore path (Path), return str; no file access or exceptions."""
        del path
        return "irrelevant text"

    def fake_build_completion_summary(
        coverage_artifact: dict[str, object], parity_artifact: dict[str, object]
    ) -> dict[str, object]:
        """Record two dict inputs, return empty dict; only build_calls mutates."""
        build_calls.append((coverage_artifact, parity_artifact))
        return {}

    def fake_write_report(path: Path, content: str) -> None:
        """Record path (Path) and content (str), return None; only local log mutates."""
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
    """Retain zero counts for empty placeholders; return None without I/O."""
    summary = completion_report.build_completion_summary({}, {})

    assert summary["coverage_ledger"] == {"present": True, "entry_count": 0}
    assert summary["parity_matrix"] == {"present": True, "entry_count": 0}
    assert summary["validation_scope"] == "legacy-artifact-compatibility-only"
    assert "readiness" not in summary


def test_main_returns_0_when_both_validators_pass(monkeypatch: MonkeyPatch) -> None:
    """Use monkeypatch (MonkeyPatch) to capture output; return None without disk I/O."""
    write_calls: list[tuple[Path, str]] = []

    def fake_read_artifact_text(path: Path) -> str:
        """Ignore path (Path), return empty legacy JSON str; no external effects."""
        del path
        return json.dumps({"entries": []})

    def fake_write_report(path: Path, content: str) -> None:
        """Record path (Path) and content (str), return None; only local log mutates."""
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
    """Use monkeypatch (MonkeyPatch) to reject parity; return None without file I/O."""

    def fake_read_artifact_text(path: Path) -> str:
        """Ignore path (Path), return str; no file access or exceptions."""
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
    """Capture stdout using monkeypatch and capsys; return None without file I/O.

    monkeypatch (MonkeyPatch) replaces reads; capsys (CaptureFixture[str]) observes
    the explicit compatibility label, with no readiness or v2 claims.
    """

    def fake_read_artifact_text(path: Path) -> str:
        """Ignore path (Path), return placeholder JSON str; no file access."""
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
    assert '"validation_scope": "legacy-artifact-compatibility-only"' in captured.out
    assert "readiness" not in captured.out


@pytest.mark.parametrize("side", ["coverage", "parity"])
@pytest.mark.parametrize(
    "text",
    [
        '{"schema_version":2,"entries":[]}',
        '{"entries":[],"entries":[{"id":"secret-token"}]}',
        '{"entries":NaN}',
        '{"entries":"secret-token"}',
        '["secret-token"]',
        "secret-token is not JSON",
    ],
)
def test_injected_acceptance_cannot_bypass_strict_runtime_checks(
    monkeypatch: MonkeyPatch,
    capsys: pytest.CaptureFixture[str],
    side: str,
    text: str,
) -> None:
    """Reject text (str) on side (str) despite injected acceptance.

    monkeypatch (MonkeyPatch) replaces all file boundaries and capsys
    (CaptureFixture[str]) captures diagnostics. Returns None; only local logs
    mutate, with no source text leaked and no report written.
    """
    writes: list[tuple[Path, str]] = []

    def read(path: Path) -> str:
        """Return selected bad or empty JSON for path (Path); no I/O or mutation."""
        return text if path.stem == side else '{"entries":[]}'

    def write(path: Path, content: str) -> None:
        """Record path (Path) and content (str); return None, no file I/O."""
        writes.append((path, content))

    monkeypatch.setattr(completion_report, "read_artifact_text", read)
    monkeypatch.setattr(completion_report, "write_report", write)

    result = completion_report.main(
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

    captured = capsys.readouterr()
    assert result == 1 and writes == [] and captured.out == ""
    assert (
        captured.err == "Artifacts cannot be rendered as a legacy completion report\n"
    )
    assert "secret-token" not in captured.err


def test_default_validator_bindings_preserve_both_diagnostics(
    monkeypatch: MonkeyPatch, capsys: pytest.CaptureFixture[str]
) -> None:
    """Patch real lazy bindings using monkeypatch (MonkeyPatch); return None.

    capsys (CaptureFixture[str]) observes ordered diagnostics. No schema/file
    access occurs; both default functions receive exactly their own input.
    """
    from scripts.dev_tools import validate_discovery_schema_artifacts as schema

    seen: list[tuple[str, str]] = []

    def read(path: Path) -> str:
        """Return path stem (Path) as text; no I/O, exceptions or mutation."""
        return path.stem

    def coverage(text: str) -> list[str]:
        """Record text (str), return two errors; only local seen log mutates."""
        seen.append(("coverage", text))
        return ["coverage first", "coverage second"]

    def parity(text: str) -> list[str]:
        """Record text (str), return one error; only local seen log mutates."""
        seen.append(("parity", text))
        return ["parity last"]

    monkeypatch.setattr(schema, "validate_coverage_ledger_text", coverage)
    monkeypatch.setattr(schema, "validate_parity_matrix_text", parity)
    monkeypatch.setattr(completion_report, "read_artifact_text", read)

    result = completion_report.main(
        ["--coverage-input", "coverage.json", "--parity-input", "parity.json"]
    )

    captured = capsys.readouterr()
    assert result == 1
    assert seen == [("coverage", "coverage"), ("parity", "parity")]
    assert captured.out == ""
    assert captured.err == "coverage first\ncoverage second\nparity last\n"


def test_none_arguments_use_process_argument_seam(monkeypatch: MonkeyPatch) -> None:
    """Patch sys.argv with monkeypatch (MonkeyPatch); return None, no process launch."""
    monkeypatch.setattr(
        sys,
        "argv",
        ["completion", "--coverage-input", "c.json", "--parity-input", "p.json"],
    )

    args = completion_report.parse_args(None)

    assert (args.coverage_input, args.parity_input, args.output) == (
        "c.json",
        "p.json",
        None,
    )


@pytest.mark.parametrize(
    "arguments", [[], ["--coverage-input", "c.json"], ["--parity-input", "p.json"]]
)
def test_missing_required_arguments_fail_before_io(arguments: list[str]) -> None:
    """Reject arguments (list[str]) via SystemExit(2); return None, no file I/O."""
    with pytest.raises(SystemExit) as error:
        completion_report.parse_args(arguments)

    assert error.value.code == 2


@pytest.mark.parametrize("stage", ["read", "validator", "write"])
def test_unexpected_boundary_errors_propagate_without_conversion(
    monkeypatch: MonkeyPatch, stage: str
) -> None:
    """Inject failure at stage (str) with monkeypatch (MonkeyPatch); return None.

    OSError at I/O seams and RuntimeError at the validator remain original error
    objects; in-memory replacements never access files or external services.
    """
    failure = (
        RuntimeError("validator failed") if stage == "validator" else OSError("I/O")
    )

    def read(path: Path) -> str:
        """Ignore path (Path); raise selected OSError or return JSON without I/O."""
        del path
        if stage == "read":
            raise failure
        return '{"entries":[]}'

    def validator(text: str) -> list[str]:
        """Ignore text (str); raise selected RuntimeError or return empty errors."""
        del text
        if stage == "validator":
            raise failure
        return []

    def write(path: Path, content: str) -> None:
        """Ignore path (Path)/content (str), raise selected OSError; no I/O."""
        del path, content
        raise failure

    monkeypatch.setattr(completion_report, "read_artifact_text", read)
    monkeypatch.setattr(completion_report, "write_report", write)

    with pytest.raises(type(failure)) as error:
        completion_report.main(
            [
                "--coverage-input",
                "coverage.json",
                "--parity-input",
                "parity.json",
                "--output",
                "report.json",
            ],
            coverage_validator=validator,
            parity_validator=_passing_validator,
        )

    assert error.value is failure
