"""Verify detached parity compatibility reports without granting graph authority."""

from __future__ import annotations

import json
import math
from typing import TYPE_CHECKING, cast

import pytest
from drm_copilot_discovery import parity_report
from drm_copilot_discovery.models import ParseLimits
from drm_copilot_discovery.rendering import render_pretty_json
from drm_copilot_discovery.report_models import ReportLimitError

if TYPE_CHECKING:
    from pytest import MonkeyPatch


def test_parsed_and_projected_rows_have_independent_nested_values() -> None:
    """Detach nested row values through both public helpers; return None, no I/O."""
    text = '{"schema_version":"1.2.3","rows":[{"feature_id":"a","notes":["é"]}]}'
    artifact = parity_report.parse_parity_matrix(text)
    rows, summary = parity_report.build_parity_rows(artifact)
    rendered = parity_report.render_parity_report(rows, summary)

    # A returned row must not retain any caller-owned nested mutable container.
    authored_rows = cast("list[dict[str, object]]", artifact["rows"])
    authored_notes = cast("list[str]", authored_rows[0]["notes"])
    authored_notes.append("later change")

    assert rows == [{"feature_id": "a", "notes": ["é"]}]
    assert json.loads(rendered) == {"entries": rows, "summary": {"total_entries": 1}}
    assert "\r" not in rendered and rendered.endswith("\n")
    assert parity_report.parse_parity_matrix(text) != artifact


@pytest.mark.parametrize("version", [True, 1, "2.0.0", "1.bad"])
def test_explicit_non_v1_versions_cannot_establish_compatibility(
    version: object,
) -> None:
    """Reject version (object) in parsed and supplied data; return None, no I/O."""
    artifact: dict[str, object] = {"schema_version": version, "rows": []}
    message = "^Use a captured v2 snapshot for discovery parity$"

    with pytest.raises(ValueError, match=message):
        parity_report.parse_parity_matrix(json.dumps(artifact))
    with pytest.raises(ValueError, match=message):
        parity_report.build_parity_rows(artifact)


@pytest.mark.parametrize(
    "text",
    [
        '{"SECRET":',
        '{"SECRET":1,"SECRET":2}',
        '{"SECRET":NaN}',
        '["SECRET"]',
    ],
)
def test_parsing_failures_use_a_fixed_redacted_message(text: str) -> None:
    """Reject malformed text (str) without exposing its values; return None."""
    with pytest.raises(
        ValueError, match="^Parity compatibility input requires valid bounded JSON$"
    ) as error:
        parity_report.parse_parity_matrix(text)
    assert "SECRET" not in str(error.value)


@pytest.mark.parametrize(
    "artifact",
    [
        {"schema_version": "1.0.0"},
        {"schema_version": "1.0.0", "rows": {}},
        {"schema_version": "1.0.0", "rows": [None]},
        {"entries": None},
    ],
)
def test_row_shape_is_checked_before_returning_any_projection(
    artifact: dict[str, object],
) -> None:
    """Reject malformed artifact rows (dict); return None without partial data."""
    with pytest.raises(ValueError, match="^Parity rows must be JSON objects$"):
        parity_report.build_parity_rows(artifact)


@pytest.mark.parametrize(
    "value, message",
    [
        (object(), "JSON-compatible"),
        (math.nan, "finite"),
        ("\ud800", "invalid Unicode"),
    ],
)
def test_rendering_rejects_non_json_values_before_encoding(
    value: object, message: str
) -> None:
    """Reject value (object) with fixed message (str); return None without I/O."""
    with pytest.raises(ValueError, match=message):
        parity_report.render_parity_report([{"id": "a", "value": value}], {})


def test_build_rejects_excess_before_detaching_any_rows(
    monkeypatch: MonkeyPatch,
) -> None:
    """Use monkeypatch to intercept forbidden copying; return None without I/O."""
    limits = ParseLimits(document_bytes=64)

    def configured_limits() -> ParseLimits:
        """Return the fixed small ParseLimits policy; perform no external effects."""
        return limits

    def forbidden(value: object) -> object:
        """Reject a copy of value (object); raise AssertionError without I/O."""
        raise AssertionError("Over-budget rows must not be copied")

    monkeypatch.setattr(parity_report, "ParseLimits", configured_limits)
    monkeypatch.setattr(parity_report, "to_plain_value", forbidden)
    with pytest.raises(ReportLimitError, match="^REPORT_LIMIT:"):
        parity_report.build_parity_rows({"entries": [{"id": "😀" * 40}]})


@pytest.mark.parametrize("text", ["é", "😀", "\x01"])
def test_pretty_render_budget_accounts_for_unicode_and_escape_expansion(
    monkeypatch: MonkeyPatch, text: str
) -> None:
    """Bound encoded text (str) with monkeypatch; return None without external I/O.

    The exact pretty-JSON byte capacity succeeds. One fewer byte must reject
    before rendering, including supplementary Unicode surrogate-pair escapes.
    """
    rows: list[dict[str, object]] = [{"id": text}]
    summary: dict[str, object] = {"total_entries": 1}
    expected = (
        json.dumps({"entries": rows, "summary": summary}, sort_keys=True, indent=2)
        + "\n"
    )
    capacity = len(expected.encode("utf-8"))
    calls: list[object] = []

    def configured_limits() -> ParseLimits:
        """Return ParseLimits using current capacity (bytes); perform no I/O."""
        return ParseLimits(document_bytes=capacity)

    def observed(value: object) -> str:
        """Record value (object), then return pretty JSON; mutate only local calls."""
        calls.append(value)
        return render_pretty_json(value)

    monkeypatch.setattr(parity_report, "ParseLimits", configured_limits)
    monkeypatch.setattr(parity_report, "render_pretty_json", observed)
    assert parity_report.render_parity_report(rows, summary) == expected
    capacity -= 1
    with pytest.raises(ReportLimitError, match="^REPORT_LIMIT:"):
        parity_report.render_parity_report(rows, summary)
    assert len(calls) == 1
