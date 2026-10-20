"""Verify pure report budgets, deterministic views and v1 compatibility boundaries."""

from __future__ import annotations

import json
import math
from dataclasses import FrozenInstanceError
from typing import TYPE_CHECKING, cast

import pytest
from drm_copilot_discovery import report_models
from drm_copilot_discovery.models import (
    JsonObject,
    JsonValue,
    ParseLimits,
    canonical_json,
)
from drm_copilot_discovery.report_models import (
    DiscoveryReport,
    ReportBudget,
    ReportLimitError,
    bounded_object,
    build_coverage_rows,
    parse_coverage_ledger,
    ratio,
    render_coverage_report,
)

if TYPE_CHECKING:
    from pytest import MonkeyPatch


@pytest.mark.parametrize(
    "value",
    [
        {},
        {"array": []},
        {"a": [None, True, False, 0, -12, 1.25]},
        {"é": '漢字😀\x01\b\f\n\r\t\\"'},
        {"nested": {"array": [{"x": "value"}, {}]}},
    ],
)
@pytest.mark.parametrize("pretty", [False, True])
def test_encoded_budget_matches_exact_serializer_cost(
    value: dict[str, object], pretty: bool
) -> None:
    """Measure value (dict) in pretty/canonical style (bool); return None.

    Exact UTF-8 capacity passes, one fewer byte fails, and no I/O occurs.
    """
    rendered = (
        json.dumps(value, sort_keys=True, indent=2)
        if pretty
        else json.dumps(
            value, ensure_ascii=False, sort_keys=True, separators=(",", ":")
        )
    ) + "\n"
    size = len(rendered.encode("utf-8"))
    budget = ReportBudget(ParseLimits(document_bytes=size), pretty=pretty)

    budget.check(value)

    assert budget.bytes_left == 0
    with pytest.raises(ReportLimitError, match="^REPORT_LIMIT:"):
        ReportBudget(ParseLimits(document_bytes=size - 1), pretty=pretty).check(value)


def test_detached_report_views_preserve_exact_fields_and_order() -> None:
    """Round-trip immutable report views without changing caller data; return None."""
    source: dict[str, object] = {"z": ["```", "line\nnext"], "a": {"count": 2}}
    frozen = bounded_object(source, limits=ParseLimits())
    report = DiscoveryReport(document=frozen)
    original = report.to_json()

    source["a"] = "changed"
    plain = report.to_dict()
    plain["z"] = "changed"
    markdown = report.to_markdown()
    markdown_json = markdown.split("```json\n", 1)[1].rsplit("```", 1)[0]

    assert report.to_json() == original == canonical_json(frozen).decode("utf-8")
    assert json.loads(markdown_json) == json.loads(original) == report.to_dict()
    assert markdown.startswith("# Discovery coverage report\n\n```json\n")
    assert markdown.count("\n```\n") == 1
    assert report.to_markdown() == markdown
    with pytest.raises(FrozenInstanceError):
        report.__setattr__("document", JsonObject(()))


def test_markdown_has_independent_prospective_render_budget(
    monkeypatch: MonkeyPatch,
) -> None:
    """Reject oversized Markdown before monkeypatched rendering; return None."""
    document = JsonObject((("key", "😀"),))
    report = DiscoveryReport(
        document=document,
        limits=ParseLimits(document_bytes=len(canonical_json(document))),
    )

    def forbidden(data: object) -> str:
        """Reject any attempted render of data (object); never return or perform I/O."""
        raise AssertionError("Oversized rendering must be rejected before encoding")

    monkeypatch.setattr(report_models, "render_pretty_json", forbidden)

    with pytest.raises(ReportLimitError, match="^REPORT_LIMIT:"):
        report.to_markdown()
    assert report.to_json() == canonical_json(document).decode("utf-8")


@pytest.mark.parametrize("value", [[], (), "text", None, 1])
def test_report_requires_an_object_root(value: object) -> None:
    """Reject non-object value (object) without creating a report; return None."""
    with pytest.raises(ValueError, match="object root"):
        bounded_object(value, limits=ParseLimits())


@pytest.mark.parametrize(
    "value, message",
    [
        ({1: "value"}, "keys must be strings"),
        ({"x": object()}, "JSON-compatible"),
        ({"x": math.nan}, "finite"),
        ({"x": math.inf}, "finite"),
        ({"x": "\ud800"}, "invalid Unicode"),
    ],
)
def test_malformed_values_fail_with_fixed_diagnostics(
    value: object, message: str
) -> None:
    """Reject value (object) with message (str) before copying; return None, no I/O."""
    with pytest.raises(ValueError, match=message):
        bounded_object(value, limits=ParseLimits())


@pytest.mark.parametrize("value", [2**63, -(2**63), 2**1000])
def test_oversized_integer_is_rejected_before_decimal_render(value: int) -> None:
    """Reject value (int) beyond the finite integer range; return None without I/O."""
    with pytest.raises(ReportLimitError, match="^REPORT_LIMIT:"):
        bounded_object({"integer": value}, limits=ParseLimits())


def test_budget_checks_records_nodes_depth_and_cycles() -> None:
    """Reject independent traversal excess without partial output; return None."""
    cycle: list[object] = []
    cycle.append(cycle)

    with pytest.raises(ReportLimitError):
        bounded_object({"nested": {}}, limits=ParseLimits(artifact_records=1))
    with pytest.raises(ReportLimitError):
        bounded_object({"array": [0] * 64}, limits=ParseLimits(artifact_records=1))
    with pytest.raises(ReportLimitError):
        bounded_object({"nested": {"value": 1}}, limits=ParseLimits(nesting_depth=2))
    with pytest.raises(ReportLimitError):
        ReportBudget(ParseLimits(nesting_depth=3)).check(cycle)
    assert (
        bounded_object({"value": 1}, limits=ParseLimits(nesting_depth=2))["value"] == 1
    )


@pytest.mark.parametrize("count", [True, False, 1.5, -1, 65])
@pytest.mark.parametrize("method", ["work", "spend"])
def test_reservations_require_exact_bounded_integers(
    count: object, method: str
) -> None:
    """Reject invalid count (object) for method (str); return None without effects."""
    budget = ReportBudget(ParseLimits(document_bytes=65, artifact_records=1))
    reserve = budget.work if method == "work" else budget.spend

    with pytest.raises(ReportLimitError, match="^REPORT_LIMIT:"):
        reserve(cast("int", count))
    assert budget.work_left == 64 and budget.bytes_left == 64


def test_work_capacity_is_independent_and_reserved_before_execution() -> None:
    """Consume exact work units, then fail the next unit; return None without I/O."""
    budget = ReportBudget(ParseLimits(document_bytes=65, artifact_records=1))

    budget.work(0)
    budget.work(64)
    budget.spend(64)

    assert budget.work_left == budget.bytes_left == 0
    with pytest.raises(ReportLimitError):
        budget.work(1)
    with pytest.raises(ReportLimitError):
        budget.spend(1)


@pytest.mark.parametrize("depth", [True, 0, -1, 129, 1.5])
def test_depth_guard_rejects_ambiguous_or_excessive_values(depth: object) -> None:
    """Reject depth (object) before inspecting data; return None without I/O."""
    with pytest.raises(ReportLimitError):
        ReportBudget(ParseLimits()).check(None, cast("int", depth))


def test_exact_node_exhaustion_rejects_the_next_scalar() -> None:
    """Observe the public node counter's finite lifetime; return None without I/O."""
    budget = ReportBudget(ParseLimits(artifact_records=1))
    budget.check([0] * 63)

    with pytest.raises(ReportLimitError):
        budget.check(None)
    assert budget.nodes_left == 0


@pytest.mark.parametrize("limits, pretty", [(None, False), (ParseLimits(), 1)])
def test_constructor_rejects_ambiguous_policy(limits: object, pretty: object) -> None:
    """Reject limits/style (objects) with fixed error; return None without I/O."""
    with pytest.raises(ValueError, match="ParseLimits and a boolean"):
        ReportBudget(cast("ParseLimits", limits), pretty=cast("bool", pretty))


@pytest.mark.parametrize("numerator, denominator", [(0, 0), (0, 1), (1, 3), (3, 3)])
def test_ratio_keeps_count_units_and_null_empty_denominators(
    numerator: int, denominator: int
) -> None:
    """Project counts (int) without inferring completeness; return None."""
    value = ratio(numerator, denominator, unit="source feature identities")

    assert value["numerator"] == numerator and value["denominator"] == denominator
    assert value["unit"] == "source feature identities"
    assert value["percentage"] == (
        round(100 * numerator / denominator, 6) if denominator else None
    )


@pytest.mark.parametrize(
    "numerator, denominator, unit",
    [
        (True, 1, "x"),
        (1, False, "x"),
        (-1, 1, "x"),
        (2, 1, "x"),
        (0, 2**63, "x"),
        (0, 0, ""),
        (0, 0, None),
    ],
)
def test_ratio_rejects_unsupported_or_misleading_counts(
    numerator: object, denominator: object, unit: object
) -> None:
    """Reject invalid counts/unit (objects); return None and no report authority."""
    with pytest.raises(ValueError, match="explicit unit and valid counts"):
        ratio(cast("int", numerator), cast("int", denominator), unit=cast("str", unit))


@pytest.mark.parametrize("version", [None, "1.0.0", "1.2.3"])
def test_legacy_helpers_preserve_true_v1_rows_without_completion(
    version: str | None,
) -> None:
    """Render optional v1 version (str/None); return None without schema authority."""
    source: dict[str, object] = {
        "entries": [
            {"id": "b", "unit_id": "b", "status": "contracted"},
            {"id": "a", "unit_id": "a", "status": "excluded"},
        ]
    }
    if version is not None:
        source["schema_version"] = version
    parsed = parse_coverage_ledger(json.dumps(source))

    rows, summary = build_coverage_rows(parsed)
    rendered = render_coverage_report(rows, summary)

    # Row order follows stable v1 identity rather than caller insertion order.
    assert [row["unit_id"] for row in rows] == ["a", "b"]
    assert summary == {"total_entries": 2}
    assert json.loads(rendered) == {"entries": rows, "summary": summary}
    assert "validation_result" not in rendered
    rows[0]["status"] = "changed"
    assert parsed == source


@pytest.mark.parametrize("version", ["2.0.0", "1", "1.0.0suffix", 1, True])
def test_explicit_non_v1_version_cannot_enter_compatibility_projection(
    version: object,
) -> None:
    """Reject version (object) through both entrypoints; return None without I/O."""
    value: dict[str, object] = {"schema_version": version, "entries": []}

    with pytest.raises(ValueError, match="captured v2 snapshot"):
        parse_coverage_ledger(json.dumps(value))
    with pytest.raises(ValueError, match="captured v2 snapshot"):
        build_coverage_rows(value)


@pytest.mark.parametrize("text", ["{} {}", "[]", '{"a":1,"a":2}', '{"a":NaN}'])
def test_legacy_parser_rejects_malformed_duplicate_or_nonfinite_text(text: str) -> None:
    """Reject text (str) with a fixed safe error; return None without I/O."""
    with pytest.raises(ValueError, match="valid bounded JSON"):
        parse_coverage_ledger(text)


@pytest.mark.parametrize("entries", [None, {}, [1], ["value"]])
def test_legacy_rows_reject_invalid_entry_shapes(entries: object) -> None:
    """Reject entries (object) without placeholder counts; return None without I/O."""
    with pytest.raises(ValueError, match="entries must be JSON objects"):
        build_coverage_rows({"entries": entries})


def test_legacy_missing_entries_remains_an_empty_per_artifact_result() -> None:
    """Keep the safe empty helper contract without completeness; return None."""
    assert build_coverage_rows({}) == ([], {"total_entries": 0})


def test_oversized_input_fails_before_detached_copy(monkeypatch: MonkeyPatch) -> None:
    """Reject excess before monkeypatched copying; return None without I/O."""

    def forbidden(value: object) -> None:
        """Reject any copy attempt for value (object); never return or perform I/O."""
        raise AssertionError("Over-budget input reached the detached-copy boundary")

    monkeypatch.setattr(report_models, "_freeze", forbidden)

    with pytest.raises(ReportLimitError):
        bounded_object({"value": "secret"}, limits=ParseLimits(document_bytes=8))


@pytest.mark.parametrize("count", [1, 16, 64])
def test_immutable_budget_and_copy_traverse_members_without_key_search(
    monkeypatch: MonkeyPatch, count: int
) -> None:
    """Count key searches using monkeypatch and count (int); return None without I/O.

    Budgeting and detached copying each traverse direct immutable pairs, so
    wider objects never invoke the Mapping's linear lookup implementation.
    """
    # Preserve the review's 64-member shape and two smaller deterministic controls.
    value = JsonObject(tuple((f"key-{index:03}", index) for index in range(count)))
    original = JsonObject.__getitem__
    calls: list[str] = []

    def counted(self: JsonObject, key: str) -> JsonValue:
        """Record a lookup of key (str) on self (JsonObject); return JsonValue.

        Mutates only the test-local counter and propagates the original KeyError.
        """
        calls.append(key)
        return original(self, key)

    monkeypatch.setattr(JsonObject, "__getitem__", counted)

    budget = ReportBudget(ParseLimits())
    budget.check(value)
    copied = bounded_object(value, limits=ParseLimits())

    assert calls == []
    assert copied.members == value.members and copied is not value
    assert budget.nodes_left == budget.limits.expanded_nodes - (2 * count + 1)


@pytest.mark.parametrize(
    "kind,heading",
    [
        ("parity-report", "parity"),
        ("coverage-report", "coverage"),
        ("authored\n# misleading", "coverage"),
    ],
)
def test_heading_uses_only_closed_artifact_kind(kind: str, heading: str) -> None:
    """Render kind (str) with fixed heading (str); return None without I/O.

    Unknown authored values cannot enter the heading. JSON and Markdown retain
    identical fields, and the historical coverage heading remains unchanged.
    """
    report = DiscoveryReport(
        document=bounded_object({"artifact_kind": kind}, limits=ParseLimits())
    )
    value = report.to_markdown()
    assert value.startswith(f"# Discovery {heading} report\n\n```json\n")
    assert (
        json.loads(value.split("```json\n", 1)[1].rsplit("```", 1)[0])
        == report.to_dict()
    )
