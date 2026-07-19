"""Tests for `scripts.dev_tools.discovery.rendering`.

Covers `sort_rows` (id-field sort and case-insensitive fallback sort) and
`render_pretty_json` (exact literal output and determinism), per
`spec.md` "Data & State" and `research.2026-07-17T15-10.md` Section 5.
"""

from __future__ import annotations

from scripts.dev_tools.discovery.rendering import render_pretty_json, sort_rows


def test_sort_rows_sorts_ascending_by_id_field() -> None:
    """Rows supplied in reverse id order should sort into ascending id
    order."""
    rows = [{"id": "c"}, {"id": "a"}, {"id": "b"}]

    result = sort_rows(rows)

    assert [row["id"] for row in result] == ["a", "b", "c"]


def test_sort_rows_falls_back_to_joined_field_sort_when_id_absent() -> None:
    """Rows with no usable id_field should fall back to a case-insensitive
    joined-field sort, producing a stable order."""
    rows = [
        {"name": "Zeta", "status": "done"},
        {"name": "alpha", "status": "pending"},
        {"name": "Beta", "status": "active"},
    ]

    result = sort_rows(rows)

    # Fallback key joins sorted-by-field-name string values lowercased:
    # "name" and "status" -> "<name>|<status>". Expect alpha < beta < zeta.
    assert [row["name"] for row in result] == ["alpha", "Beta", "Zeta"]


def test_sort_rows_falls_back_when_id_field_partially_present() -> None:
    """A single row missing the id_field disqualifies id-based sorting for
    the whole collection, triggering the joined-field fallback."""
    rows = [
        {"id": "b", "label": "second"},
        {"label": "first"},
    ]

    result = sort_rows(rows)

    # Fallback key for the id-having row is "b|second" (id, label sorted by
    # field name); for the id-less row it is just "first" (label only).
    # "b|second" < "first" alphabetically, so the id-having row sorts first.
    assert result[0]["label"] == "second"
    assert result[1]["label"] == "first"


def test_render_pretty_json_exact_literal_output() -> None:
    """render_pretty_json on a fixed sample dict must produce the exact
    expected literal string, byte-for-byte."""
    data = {"summary": {"total_entries": 1}, "entries": [{"id": "a"}]}

    result = render_pretty_json(data)

    expected = (
        "{\n"
        '  "entries": [\n'
        "    {\n"
        '      "id": "a"\n'
        "    }\n"
        "  ],\n"
        '  "summary": {\n'
        '    "total_entries": 1\n'
        "  }\n"
        "}\n"
    )
    assert result == expected


def test_render_pretty_json_is_deterministic() -> None:
    """Calling render_pretty_json twice on the same input must return
    identical strings."""
    data = {"summary": {"total_entries": 2}, "entries": [{"id": "b"}, {"id": "a"}]}

    first = render_pretty_json(data)
    second = render_pretty_json(data)

    assert first == second
