"""Verify bounded report views without filesystem, gate evaluation or mutation."""

from __future__ import annotations

import json
from typing import TYPE_CHECKING

import pytest
from drm_copilot_discovery import report_rendering
from drm_copilot_discovery.models import JsonObject, ParseLimits, canonical_json
from drm_copilot_discovery.rendering import render_pretty_json
from drm_copilot_discovery.report_models import DiscoveryReport, ReportLimitError

if TYPE_CHECKING:
    from pytest import MonkeyPatch


@pytest.mark.parametrize(
    "kind,heading",
    [
        ("coverage-report", "coverage"),
        ("parity-report", "parity"),
        ("completion-report", "completion"),
        ("validation-report", "coverage"),
        ("untrusted\n```", "coverage"),
    ],
)
def test_closed_headings_preserve_exact_existing_view_bytes(
    kind: str, heading: str
) -> None:
    """Render kind (str) with expected heading (str); return None without I/O."""
    document = JsonObject(
        (("artifact_kind", kind), ("validation_result", "fail"), ("counts", None))
    )
    expected = (
        f"# Discovery {heading} report\n\n```json\n"
        + json.dumps(
            {"artifact_kind": kind, "validation_result": "fail", "counts": None},
            sort_keys=True,
            indent=2,
        )
        + "\n```\n"
    )

    report = DiscoveryReport(document=document)
    rendered = report_rendering.render_report_markdown(document, limits=ParseLimits())

    assert rendered == expected == report.to_markdown()
    assert report.to_json() == canonical_json(document).decode("utf-8")
    assert json.loads(rendered.split("```json\n", 1)[1].rsplit("```", 1)[0]) == (
        report.to_dict()
    )


@pytest.mark.parametrize("text", ["é", "😀", "\x01", "```json\n</script>\r\n"])
def test_exact_capacity_passes_and_short_capacity_rejects_before_encoding(
    monkeypatch: MonkeyPatch, text: str
) -> None:
    """Bound text (str) with monkeypatch observer; return None, no external I/O.

    Exact rendered UTF-8 capacity passes; one byte less raises ReportLimitError
    before the formatting seam, including escaping and Markdown wrapper costs.
    """
    document = JsonObject((("artifact_kind", "completion-report"), ("value", text)))
    expected = DiscoveryReport(document=document).to_markdown()
    capacity = len(expected.encode("utf-8"))
    encoded: list[object] = []

    def observed(value: object) -> str:
        """Record value (object) and return original JSON; only local list mutates."""
        encoded.append(value)
        return render_pretty_json(value)

    monkeypatch.setattr(report_rendering, "render_pretty_json", observed)

    assert (
        report_rendering.render_report_markdown(
            document, limits=ParseLimits(document_bytes=capacity)
        )
        == expected
    )
    with pytest.raises(ReportLimitError, match="^REPORT_LIMIT:"):
        report_rendering.render_report_markdown(
            document, limits=ParseLimits(document_bytes=capacity - 1)
        )
    assert len(encoded) == 1


@pytest.mark.parametrize(
    "text",
    ["", "plain", "é", "😀", "\x00\t\r\n", '\\"', "```json\n</script>", "\u2028\u2029"],
)
def test_rendered_view_round_trips_unicode_without_changing_fields(
    text: str,
) -> None:
    """Round-trip text (str); return None without I/O or caller mutation."""
    document = JsonObject((("artifact_kind", "completion-report"), ("message", text)))
    before = canonical_json(document)
    report = DiscoveryReport(document=document)

    rendered = report_rendering.render_report_markdown(document, limits=ParseLimits())
    restored = json.loads(rendered.split("```json\n", 1)[1].rsplit("```", 1)[0])

    assert restored == {"artifact_kind": "completion-report", "message": text}
    assert canonical_json(document) == before
    assert report.to_markdown() == rendered
    assert rendered.count("\n```\n") == 1 and "\r" not in rendered


def test_missing_kind_retains_coverage_fallback_and_empty_fields() -> None:
    """Render an empty JsonObject without adding status; return None without I/O."""
    document = JsonObject(())

    result = report_rendering.render_report_markdown(document, limits=ParseLimits())

    assert result == "# Discovery coverage report\n\n```json\n{}\n```\n"
    assert DiscoveryReport(document=document).to_dict() == {}
