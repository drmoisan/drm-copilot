"""Keep possible handler assignments distinct from compiler/runtime event proof."""

from __future__ import annotations

from typing import TYPE_CHECKING, cast

import pytest
from drm_copilot_discovery.analyzer.csharp_tokens import SourceScanError
from drm_copilot_discovery.analyzer.dotnet_inventory import (
    EventSubscriptionAnalyzer,
    classify_text,
)
from drm_copilot_discovery.analyzer.emitter import inventory_result
from drm_copilot_discovery.analyzer.event_subscriptions import subscription_candidates
from drm_copilot_discovery.analyzer.findings import row

from tests.discovery_runtime.analyzer.test_dotnet_projects import capture, properties
from tests.discovery_runtime.analyzer.test_dotnet_projects import catalog as catalog

if TYPE_CHECKING:
    from drm_copilot_discovery.catalog import SchemaCatalog
    from drm_copilot_discovery.models import JsonObject


@pytest.mark.parametrize(
    "rhs",
    [
        "this.Handle",
        "handler",
        "other.Count",
        "new Action(Handle)",
        "(x, y) => Handle(x)",
        "async x => await Handle(x)",
        "delegate(object x) { Handle(x); }",
        "(x) => { First(); Second(); }",
        "global::Handlers.OnChange",
    ],
)
def test_possible_handlers_are_explicitly_heuristic(rhs: str) -> None:
    """str rhs includes ambiguous arithmetic; candidates retain unresolved metadata.
    Returns None; assertions check isolated data without external effects."""
    result = subscription_candidates("a.cs", "publisher.Changed += " + rhs + ";")
    assert len(result) == 1 and result[0].symbol == "publisher.Changed"
    assert dict(result[0].extra)["confidence"] == "heuristic"
    assert dict(result[0].extra)["binding"] == "unresolved"


@pytest.mark.parametrize(
    "source",
    [
        "",
        "x += 3;",
        'x += "Handle";',
        "x += 'a';",
        "x += 1 + amount;",
        "x += amount * 2;",
        "x += call();",
        "x += ;",
        "x += (handler;",
        "x += handler)",
        "x += handler",
        "array[0] += handler;",
        "+= handler;",
        'var t = """x += handler;""";',
        "// x += handler;",
        "x += () => { work();",
        "x += [);",
        "x += value + other;",
    ],
)
def test_non_handler_or_incomplete_syntax_is_not_promoted(source: str) -> None:
    """str source is literal/arithmetic/incomplete; no candidate escapes.
    Returns None; assertions check isolated data without external effects."""
    assert subscription_candidates("a.cs", source) == ()


@pytest.mark.parametrize("newline", ["\n", "\r", "\r\n"])
def test_multiline_unicode_target_and_lambda_preserve_lines(newline: str) -> None:
    """str newline selects physical anchors across a multiline block lambda.
    Returns None; assertions check isolated data without external effects."""
    source = newline.join(
        ["Δ.", "Changed", "+=", "(x) => {", "First();", "Second();", "};"]
    )
    result = subscription_candidates("a.cs", source)
    assert len(result) == 1 and result[0].symbol == "Δ.Changed"
    assert result[0].line == 1 and dict(result[0].extra)["end_line"] == 7


def test_same_line_assignments_keep_order_and_operator() -> None:
    """Distinct offset metadata retains duplicate target sites in lexical order.
    Returns None; assertions check isolated data without external effects."""
    result = subscription_candidates(
        "a.cs", "x += Handler; x -= Handler; x += Handler;"
    )
    # Subscription and unsubscription operators retain lexical order.
    assert [dict(value.extra)["operator"] for value in result] == ["+=", "-=", "+="]
    # Offsets disambiguate repeated targets on one physical line.
    assert len({dict(value.extra)["offset"] for value in result}) == 3
    # The compatibility projection keeps its established heuristic metadata.
    assert all(
        dict(value.extra)["confidence"] == "heuristic"
        for value in classify_text("a.cs", "x += Handler;")
    )


def test_v2_event_rows_are_inferred_and_never_resolve_targets(
    catalog: SchemaCatalog,
) -> None:
    """SchemaCatalog validates unresolved arithmetic candidates without event proof.
    Returns None; assertions check isolated data without external effects."""
    inputs = capture(
        catalog, (("src/a.cs", b"total += other.Count; total -= other.Count;"),)
    )
    result = EventSubscriptionAnalyzer().analyze(inputs)
    assert len(result.findings) == len(result.relationships) == 2
    # Arithmetic-shaped identifiers never become verified event relationships.
    assert all(
        item["classification"] == "inferred" and item["confidence"] == "medium"
        for item in result.findings + result.relationships
    )
    # No compiler binding exists to justify a resolved target component.
    assert all(item["to_component_id"] is None for item in result.relationships)
    # Legacy heuristic metadata cannot override versioned confidence values.
    assert all("confidence" not in properties(item) for item in result.findings)
    # Relationships must retain source anchors just as their findings do.
    assert all(
        cast("JsonObject", item["source"])["line_range"] is not None
        for item in result.relationships
    )
    assert (
        inventory_result(
            inputs,
            (result,),
            analyzer_ids=("event-subscriptions",),
            timestamp="2026-10-19T00:00:00Z",
            author_or_agent=row(kind="tool", id="fixture"),
            catalog=catalog,
        ).document["relationships"]
        == result.relationships
    )
    assert result == EventSubscriptionAnalyzer().analyze(inputs)


def test_event_projection_accounts_for_relationship_budget(
    catalog: SchemaCatalog,
) -> None:
    """SchemaCatalog sets a bound that fits findings but excludes relationship rows.
    Returns None; assertions check isolated data without external effects."""
    result = EventSubscriptionAnalyzer().analyze(
        capture(catalog, (("src/a.cs", b"x += Handler;"),), records=3)
    )
    assert result.components == result.findings == result.relationships == ()
    # Aggregate overflow must replace partial results with an explicit blocker.
    assert [item["code"] for item in result.diagnostics] == ["analysis-limit"]


def test_missing_source_pin_downgrades_relationships(catalog: SchemaCatalog) -> None:
    """SchemaCatalog creates unpinned input; no relationship/finding verifies.
    Returns None; assertions check isolated data without external effects."""
    result = EventSubscriptionAnalyzer().analyze(
        capture(catalog, (("src/a.cs", b"x += Handler;"),), pinned=False)
    )
    assert (
        result.findings[0]["confidence"]
        == result.relationships[0]["confidence"]
        == "low"
    )
    # Unpinned evidence must retain an actionable provenance blocker.
    assert any(
        item["code"] == "source-revision-unverified" for item in result.diagnostics
    )


def test_repeated_incomplete_assignments_have_a_total_work_bound() -> None:
    """Adversarial unfinished assignments raise explicitly without quadratic scans.
    Returns None; assertions check isolated data without external effects."""
    with pytest.raises(SourceScanError) as error:
        subscription_candidates("a.cs", "x += " * 80 + "Handler")
    assert error.value.code == "source-work-limit"
