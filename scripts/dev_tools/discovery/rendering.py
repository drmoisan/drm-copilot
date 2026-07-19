"""Shared deterministic-formatting helpers for discovery report renderers.

Purpose:
    Provide the sort and JSON-formatting primitives every report module
    (`coverage_report.py`, `parity_report.py`, `completion_report.py`) reuses
    so all three renderers share one fixed formatting discipline instead of
    each re-implementing ordering/formatting independently.

Constraints:
    No function in this module reads wall-clock time or randomness. Every
    ordering decision is made explicitly on the input data, per
    `.claude/rules/general-unit-test.md` "Determinism Infrastructure".
"""

from __future__ import annotations

import json
from typing import Any


def sort_rows(
    rows: list[dict[str, Any]], *, id_field: str = "id"
) -> list[dict[str, Any]]:
    """Sort report rows into a stable, deterministic order.

    Purpose:
        Provide the single sort primitive every report's row-building step
        uses, so output ordering never depends on dict/set iteration order
        or on the order artifact entries happened to be enumerated.

    Args:
        rows (list[dict]): Report rows to sort. Each row is an artifact
            entry dict of arbitrary shape.
        id_field (str): The field name to prefer as the sort key.

    Returns:
        list[dict]: A new list containing the same row dicts, sorted either
        by `row[id_field]` (when every row has a non-empty string value for
        `id_field`) or, as a fallback, by a case-insensitive join of every
        present string field's value in each row.

    Raises:
        None.

    Side Effects:
        None. The input list and its row dicts are not mutated.
    """
    # A stable per-entry sort key requires every row to actually carry a
    # usable, non-empty string id_field value; a single missing/empty/
    # non-string value disqualifies the whole collection from id-based
    # sorting, since a partial id-based sort would not be a total order.
    all_rows_have_id = all(
        isinstance(row.get(id_field), str) and row.get(id_field) for row in rows
    )
    if all_rows_have_id:
        return sorted(rows, key=lambda row: row[id_field])

    def _fallback_key(row: dict[str, Any]) -> str:
        """Build a case-insensitive fallback sort key for one row.

        Joins every present string-valued field's value (sorted by field
        name for determinism) so rows with no usable `id_field` still sort
        into a stable, reproducible order.
        """
        # Walk the row's fields in sorted-key order so the joined key does
        # not depend on dict insertion order.
        string_values = [
            str(row[field]).lower()
            for field in sorted(row)
            if isinstance(row[field], str)
        ]
        return "|".join(string_values)

    return sorted(rows, key=_fallback_key)


def render_pretty_json(data: object) -> str:
    """Render `data` as deterministic, human-readable JSON text.

    Purpose:
        Provide the single fixed formatting discipline every report module
        uses for its rendered output body, matching the repository's
        existing canonicalization precedent
        (`scripts/dev_tools/format_json.py` line 55).

    Args:
        data (object): JSON-serializable data to render (typically a dict
            containing a `"summary"` and `"entries"` or similar shape).

    Returns:
        str: `json.dumps(data, sort_keys=True, indent=2)` followed by a
        single trailing `"\\n"` (LF only, no CRLF).

    Raises:
        TypeError: Propagated unchanged when `data` is not JSON-serializable.

    Side Effects:
        None. This function reads no wall-clock time or randomness, so
        calling it twice on equal input always returns equal output.
    """
    return json.dumps(data, sort_keys=True, indent=2) + "\n"
