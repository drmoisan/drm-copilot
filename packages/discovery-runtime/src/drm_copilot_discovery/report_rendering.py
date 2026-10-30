"""Render captured report fields without assessing claims or performing I/O."""

from __future__ import annotations

from typing import TYPE_CHECKING

from drm_copilot_discovery.models import to_plain_value
from drm_copilot_discovery.rendering import render_pretty_json
from drm_copilot_discovery.report_models import ReportBudget

if TYPE_CHECKING:
    from drm_copilot_discovery.models import JsonObject, ParseLimits


def render_report_markdown(document: JsonObject, *, limits: ParseLimits) -> str:
    """Render document (JsonObject) under limits (ParseLimits) as fixed Markdown.

    Returns LF text containing a pretty JSON view of the same immutable fields.
    Only closed artifact kinds select headings; no authored text is interpolated
    outside JSON. Coverage/parity and the existing coverage fallback retain their
    bytes. ReportLimitError rejects excess before copying or encoding; ValueError
    rejects malformed policy/data. No validation, caller mutation or I/O occurs.
    """
    # Completion adds its own label without changing either predecessor heading.
    kind = document.get("artifact_kind")
    if kind == "completion-report":
        heading = "completion"
    elif kind == "parity-report":
        heading = "parity"
    else:
        heading = "coverage"
    prefix, suffix = f"# Discovery {heading} report\n\n```json\n", "```\n"
    budget = ReportBudget(limits, pretty=True)
    budget.spend(len(prefix) + len(suffix))
    budget.check(document)
    return prefix + render_pretty_json(to_plain_value(document)) + suffix
