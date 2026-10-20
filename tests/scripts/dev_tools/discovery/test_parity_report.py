"""Verify v1/placeholder compatibility and fail-closed parity CLI routing in memory.

Schema validation and I/O use patched seams. Compatibility counts never prove
v2 parity, approval, verification or publication authority.
"""

from __future__ import annotations

import json
import sys
from io import StringIO
from pathlib import Path
from typing import TYPE_CHECKING

import pytest

if TYPE_CHECKING:
    from collections.abc import Callable

    from _pytest.monkeypatch import MonkeyPatch

import scripts.dev_tools.discovery.parity_report as parity_report


def _reader(text: str) -> Callable[[Path], str]:
    """Return a Path-to-str reader for text (str), with no filesystem access."""

    def read(path: Path) -> str:
        """Return captured text for path (Path); perform no I/O."""
        return text

    return read


def _writer(writes: list[tuple[Path, str]]) -> Callable[[Path, str], None]:
    """Return a writer recording path/content into writes; no filesystem access."""

    def write(path: Path, content: str) -> None:
        """Append path (Path)/content (str) to the local list; return None."""
        writes.append((path, content))

    return write


def _passing_validator(text: str) -> list[str]:
    """Fake `ArtifactValidator` that always reports no errors."""
    del text
    return []


def _failing_validator(text: str) -> list[str]:
    """Fake `ArtifactValidator` that always reports one fixed error."""
    del text
    return ["malformed parity field"]


def test_build_and_render_parity_report_sorts_and_counts_entries() -> None:
    """Given compatibility-only placeholder entries in arbitrary order,
    build_parity_rows then render_parity_report should produce sorted
    entries and a correct total_entries count."""
    artifact: dict[str, object] = {
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
        """Return inert text for path (Path); no filesystem access."""
        del path
        return "irrelevant text"

    def fake_write_report(path: Path, content: str) -> None:
        """Capture path/content in memory; return None without I/O."""
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
        """Return empty compatibility entries for path (Path), without I/O."""
        del path
        return json.dumps({"entries": []})

    def fake_write_report(path: Path, content: str) -> None:
        """Capture path/content in memory; return None without I/O."""
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
        """Return rejected text for path (Path); no filesystem access."""
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
        """Return a compatibility row for path (Path); no filesystem access."""
        del path
        return json.dumps({"entries": [{"id": "feature-a"}]})

    monkeypatch.setattr(parity_report, "read_artifact_text", fake_read_artifact_text)

    exit_code = parity_report.main(
        ["--input", "matrix.json"], validator=_passing_validator
    )

    assert exit_code == 0
    captured = capsys.readouterr()
    assert '"id": "feature-a"' in captured.out


@pytest.mark.parametrize("version", ["1.0.0", "1.12.34"])
def test_actual_v1_rows_keep_their_fields_and_feature_order(version: str) -> None:
    """Render version (str) using actual v1 rows without inferring v2 proof."""
    artifact: dict[str, object] = {
        "schema_version": version,
        "rows": [
            {"feature_id": "z", "parity_status": "deferred", "verification": "none"},
            {
                "feature_id": "a",
                "parity_status": "behavioral_parity",
                "verification": "manual",
                "notes": "A retained observation.",
            },
        ],
    }
    before = json.dumps(artifact, sort_keys=True)
    parsed = parity_report.parse_parity_matrix(json.dumps(artifact))
    rows, summary = parity_report.build_parity_rows(parsed)
    rendered = json.loads(parity_report.render_parity_report(rows, summary))
    assert [row["feature_id"] for row in rows] == ["a", "z"]
    assert rows[0]["parity_status"] == "behavioral_parity"
    assert rows[0]["verification"] == "manual"
    assert rows[0]["notes"] == "A retained observation."
    assert rendered == {"entries": rows, "summary": {"total_entries": 2}}
    assert json.dumps(artifact, sort_keys=True) == before


@pytest.mark.parametrize(
    "text",
    [
        "{",
        "[]",
        '{"entries":null}',
        '{"entries":[null]}',
        '{"entries":[],"entries":[]}',
        '{"entries":[{"score":NaN}]}',
        '{"schema_version":"2.0.0","entries":[]}',
        '{"schema_version":"1.bad","rows":[]}',
    ],
)
def test_injected_acceptance_cannot_bypass_safe_compatibility_boundary(
    monkeypatch: MonkeyPatch, capsys: pytest.CaptureFixture[str], text: str
) -> None:
    """Reject text (str) after injected acceptance without output or leaked text."""
    writes: list[tuple[Path, str]] = []
    monkeypatch.setattr(parity_report, "read_artifact_text", _reader(text))
    monkeypatch.setattr(parity_report, "write_report", _writer(writes))
    result = parity_report.main(
        ["--input", "matrix.json", "--output", "report.json"],
        validator=_passing_validator,
    )
    output = capsys.readouterr()
    assert result == 1 and writes == [] and output.out == ""
    assert output.err == "Parity matrix cannot be rendered as a legacy report\n"


def test_default_validator_uses_existing_lazy_upstream_seam(
    monkeypatch: MonkeyPatch,
) -> None:
    """Forward text through patched upstream validation, preserving diagnostics."""
    import scripts.dev_tools.validate_discovery_schema_artifacts as upstream

    seen: list[str] = []

    def validate(text: str) -> list[str]:
        """Record text (str) and return list[str] diagnostics without schema I/O."""
        seen.append(text)
        return ["upstream failure"]

    monkeypatch.setattr(upstream, "validate_parity_matrix_text", validate)
    monkeypatch.setattr(parity_report, "read_artifact_text", _reader("{}"))
    assert parity_report.main(["--input", "matrix.json"]) == 1
    assert seen == ["{}"]


@pytest.mark.parametrize("boundary", ["read", "write", "validator"])
def test_unexpected_boundary_failures_propagate(
    monkeypatch: MonkeyPatch, boundary: str
) -> None:
    """For boundary (str), preserve unexpected I/O/validator errors without fallback."""

    def fail(*args: object) -> str:
        """Raise OSError for inert args (object); never access external resources."""
        raise OSError("boundary unavailable")

    monkeypatch.setattr(parity_report, "read_artifact_text", _reader("{}"))
    monkeypatch.setattr(parity_report, "write_report", _writer([]))
    if boundary == "validator":

        def validator(text: str) -> list[str]:
            """Raise OSError for text (str) without external operations."""
            raise OSError("boundary unavailable")

    else:
        validator = _passing_validator
        monkeypatch.setattr(
            parity_report,
            f"{boundary}_report" if boundary == "write" else "read_artifact_text",
            fail,
        )
    with pytest.raises(OSError, match="boundary unavailable"):
        parity_report.main(
            ["--input", "matrix.json", "--output", "report.json"], validator=validator
        )


def test_missing_input_is_an_argument_error() -> None:
    """Reject missing --input before any artifact read."""
    with pytest.raises(SystemExit) as error:
        parity_report.parse_args([])
    assert error.value.code == 2


@pytest.mark.parametrize("phase", ["build", "render"])
def test_helper_rejection_never_writes_partial_report(
    monkeypatch: MonkeyPatch, capsys: pytest.CaptureFixture[str], phase: str
) -> None:
    """For phase (str), suppress partial publication and redact helper messages."""

    def fail(*args: object) -> str:
        """Reject args (object) with a diagnostic that the CLI must redact."""
        raise ValueError("secret input must not escape")

    writes: list[tuple[Path, str]] = []
    monkeypatch.setattr(parity_report, "read_artifact_text", _reader("{}"))
    monkeypatch.setattr(parity_report, "write_report", _writer(writes))
    monkeypatch.setattr(
        parity_report,
        "build_parity_rows" if phase == "build" else "render_parity_report",
        fail,
    )
    assert (
        parity_report.main(
            ["--input", "matrix.json", "--output", "report.json"],
            validator=_passing_validator,
        )
        == 1
    )
    output = capsys.readouterr()
    assert writes == [] and output.out == ""
    assert "secret" not in output.err
