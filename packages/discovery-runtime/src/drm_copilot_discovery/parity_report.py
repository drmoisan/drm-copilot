"""Project parity from captured assessments while retaining bounded v1 helpers."""

from __future__ import annotations

import re
from typing import cast

from drm_copilot_discovery.models import JsonObject, ParseLimits, to_plain_value
from drm_copilot_discovery.parsing import parse_document
from drm_copilot_discovery.rendering import render_pretty_json, sort_rows
from drm_copilot_discovery.report_models import ReportBudget, bounded_object


def _legacy_version(value: object) -> bool:
    """Check optional version (object); return whether it explicitly names v1.

    Raises ValueError for non-v1 text or non-string values. Absence supports the
    historical unversioned placeholder only; no graph assurance or I/O occurs.
    """
    if value is None:
        return False
    if not isinstance(value, str) or re.fullmatch(r"1\.\d+\.\d+", value) is None:
        raise ValueError("Use a captured v2 snapshot for discovery parity")
    return True


def parse_parity_matrix(text: str) -> dict[str, object]:
    """Parse compatibility text (str) into a detached bounded dict without I/O.

    Raises ValueError for malformed, duplicate, nonfinite or explicit non-v1
    input. Parsing grants no schema validation or source-to-target assurance.
    """
    parsed = parse_document(text, format="json")
    if not parsed.ok or parsed.value is None:
        raise ValueError("Parity compatibility input requires valid bounded JSON")
    _legacy_version(parsed.value.get("schema_version"))
    return cast("dict[str, object]", to_plain_value(parsed.value))


def build_parity_rows(
    artifact: dict[str, object],
) -> tuple[list[dict[str, object]], dict[str, object]]:
    """Project artifact (dict) into detached sorted rows and total_entries.

    Returns (list[dict], dict). Explicit v1 uses rows and feature_id; the old
    unversioned entries/id shape remains compatibility-only. Raises ValueError
    for invalid shape/version and ReportLimitError for excess. No completion,
    proof, validation, publication, input mutation or external effects occur.
    """
    value = bounded_object(artifact, limits=ParseLimits())
    versioned = _legacy_version(value.get("schema_version"))
    entries = value.get("rows" if versioned else "entries", None if versioned else ())
    if not isinstance(entries, tuple) or any(
        not isinstance(row, JsonObject) for row in entries
    ):
        raise ValueError("Parity rows must be JSON objects")
    # Preserve true v1 row fields while detaching every caller-owned container.
    rows = [cast("dict[str, object]", to_plain_value(row)) for row in entries]
    return sort_rows(rows, id_field="feature_id" if versioned else "id"), {
        "total_entries": len(rows)
    }


def render_parity_report(
    rows: list[dict[str, object]], summary: dict[str, object]
) -> str:
    """Render compatibility rows (list[dict]) and summary (dict) as pretty JSON.

    Returns deterministic LF text. Raises ValueError/ReportLimitError before
    encoding malformed/excess data. No graph authority or external effects.
    """
    value = bounded_object({"entries": rows, "summary": summary}, limits=ParseLimits())
    # Reserve formatting expansion before rendering the unchanged legacy envelope.
    ReportBudget(ParseLimits(), pretty=True).check(value)
    return render_pretty_json(to_plain_value(value))
