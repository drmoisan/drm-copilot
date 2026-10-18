"""Exercise finite byte, depth, record, alias-expansion and diagnostic budgets."""

from __future__ import annotations

import json
from typing import Literal

import pytest
from drm_copilot_discovery.models import EXPANDED_NODE_MULTIPLIER, ParseLimits
from drm_copilot_discovery.parsing import parse_document


@pytest.mark.parametrize("format", ("json", "yaml"))
def test_document_byte_limit_accepts_exact_size_and_rejects_one_more(
    format: Literal["json", "yaml"],
) -> None:
    """Limits measure encoded UTF-8 bytes rather than character counts."""
    content = '{"a":"é"}'
    exact = len(content.encode())

    accepted = parse_document(
        content, format=format, limits=ParseLimits(document_bytes=exact)
    )
    denied = parse_document(
        content, format=format, limits=ParseLimits(document_bytes=exact - 1)
    )

    assert accepted.ok
    assert denied.value is None
    assert denied.findings[0].code == "DOCUMENT_BYTES"
    assert denied.source_sha256 is None


def test_default_sixteen_mib_boundary_is_enforced() -> None:
    """Accept exactly 16 MiB and reject larger input before decoding."""
    size = 16 * 1024 * 1024
    content = b'{"a":"' + b"x" * (size - 8) + b'"}'

    accepted = parse_document(content, format="json")
    denied = parse_document(content + b" ", format="json")

    assert len(content) == size and accepted.ok
    assert denied.findings[0].code == "DOCUMENT_BYTES"


@pytest.mark.parametrize("format", ("json", "yaml"))
@pytest.mark.parametrize("depth", (1, 4, 64, 128))
def test_container_depth_boundary_is_exact(
    format: Literal["json", "yaml"], depth: int
) -> None:
    """Root is depth one; scalar leaves do not consume an extra container level."""
    source = '{"a":' * depth + "1" + "}" * depth
    too_deep = '{"a":' + source + "}"
    limits = ParseLimits(nesting_depth=depth)

    accepted = parse_document(source, format=format, limits=limits)
    denied = parse_document(too_deep, format=format, limits=limits)

    assert accepted.ok
    assert denied.findings[0].code == "DOCUMENT_DEPTH"


def test_default_depth_and_very_deep_input_fail_before_recursive_loading() -> None:
    """Depth 65 and hostile depth 10,000 cannot enter the recursive decoder."""
    # Exercise both the immediate boundary and hostile nesting without recursion.
    for depth in (65, 10_000):
        source = '{"a":' * depth + "0" + "}" * depth

        result = parse_document(source, format="json")

        assert result.findings[0].code == "DOCUMENT_DEPTH"


def test_json_delimiters_and_escaped_quotes_inside_strings_do_not_increase_depth() -> (
    None
):
    """Preflight respects string escaping rather than counting literal punctuation."""
    source = json.dumps({"a": '\\"{[[]]}"\\'})

    result = parse_document(source, format="json", limits=ParseLimits(nesting_depth=1))

    assert result.ok


@pytest.mark.parametrize("format", ("json", "yaml"))
def test_structural_mapping_records_count_the_envelope(
    format: Literal["json", "yaml"],
) -> None:
    """The structural-record budget is distinct from semantic feature cardinality."""
    source = '{"a":{},"b":{}}'

    exact = parse_document(
        source, format=format, limits=ParseLimits(artifact_records=3)
    )
    over = parse_document(source, format=format, limits=ParseLimits(artifact_records=2))

    assert exact.ok
    assert over.findings[0].code == "DOCUMENT_RECORDS"


def test_alias_occurrences_consume_records_independently() -> None:
    """Reusing a mapping anchor cannot bypass the expanded structural-record limit."""
    source = "a: &a {value: 1}\nb: *a\nc: *a"

    exact = parse_document(
        source, format="yaml", limits=ParseLimits(artifact_records=4)
    )
    over = parse_document(source, format="yaml", limits=ParseLimits(artifact_records=3))

    assert exact.ok
    assert over.findings[0].code == "DOCUMENT_RECORDS"
    assert over.findings[0].pointer == "/c"


@pytest.mark.parametrize("format", ("json", "yaml"))
def test_scalar_array_nodes_have_a_separate_exact_budget(
    format: Literal["json", "yaml"],
) -> None:
    """Scalar-only arrays cannot evade the derived node budget by omitting mappings."""
    limits = ParseLimits(artifact_records=1)
    assert limits.expanded_nodes == EXPANDED_NODE_MULTIPLIER == 64
    exact_source = json.dumps({"values": [0] * 62})
    over_source = json.dumps({"values": [0] * 63})

    exact = parse_document(exact_source, format=format, limits=limits)
    over = parse_document(over_source, format=format, limits=limits)

    assert exact.ok
    assert over.findings[0].code == "DOCUMENT_NODES"
    assert over.findings[0].pointer == "/values/62"


def test_scalar_alias_expansion_is_bounded_before_result_freezing() -> None:
    """Charge each alias occurrence even when node identities repeat."""
    sequence = ", ".join("0" for _ in range(30))
    source = f"a: &a [{sequence}]\nb: *a\nc: 0"
    limits = ParseLimits(artifact_records=1)

    exact = parse_document(source, format="yaml", limits=limits)
    over = parse_document(source + "\nd: 0", format="yaml", limits=limits)

    assert exact.ok
    assert over.findings[0].code == "DOCUMENT_NODES"
    assert over.findings[0].pointer == "/d"


def test_expanded_alias_depth_is_checked_separately_from_source_nesting() -> None:
    """Shallow alias declarations can still exceed permitted expanded depth."""
    source = "a: &a [0]\nb: &b [*a]\nc: [*b]"

    result = parse_document(source, format="yaml", limits=ParseLimits(nesting_depth=3))

    assert result.findings[0].code == "DOCUMENT_DEPTH"
    assert result.findings[0].pointer == "/c/0/0"


@pytest.mark.parametrize("format", ("json", "yaml"))
def test_large_flat_sources_are_stopped_before_decoder_allocation(
    format: Literal["json", "yaml"],
) -> None:
    """Physical tokens remain bounded even before expanded graph traversal begins."""
    source = json.dumps({"items": [0] * 200})

    result = parse_document(
        source, format=format, limits=ParseLimits(artifact_records=1)
    )

    assert result.findings[0].code == "DOCUMENT_NODES"
    assert result.findings[0].pointer == ""


def test_alias_expansion_is_bounded_with_no_cycles_or_extra_mappings() -> None:
    """Exponential scalar aliases cannot cause unbounded normalized output."""
    source = "a: &a [0, 0]\nb: &b [*a, *a]\nc: &c [*b, *b]\nd: [*c, *c, *c]"

    result = parse_document(
        source, format="yaml", limits=ParseLimits(artifact_records=1)
    )

    assert result.value is None
    assert result.findings[0].code == "DOCUMENT_NODES"


def test_error_aggregation_is_bounded_actionable_and_repeatable() -> None:
    """Multiple defects produce stable pointers and a truncation marker."""
    source = '{"c":NaN,"a":NaN,"b":NaN,"d":NaN}'
    limits = ParseLimits(findings=3)

    first = parse_document(source, format="json", limits=limits)
    second = parse_document(
        '{"d":NaN,"b":NaN,"a":NaN,"c":NaN}', format="json", limits=limits
    )

    assert first.findings == second.findings
    assert len(first.findings) == 3
    assert first.findings[0].code == "FINDINGS_LIMIT"
    assert tuple(f.pointer for f in first.findings[1:]) == ("/a", "/b")
    assert all(f.severity == "error" and f.next_action for f in first.findings)


@pytest.mark.parametrize(
    "name,ceiling",
    (
        ("document_bytes", 67108864),
        ("nesting_depth", 128),
        ("artifact_records", 1000000),
        ("findings", 1000),
    ),
)
@pytest.mark.parametrize("bad", (0, -1, True, 1.5))
def test_parser_limits_cannot_be_disabled(name: str, ceiling: int, bad: int) -> None:
    """Zero, negative, boolean and noninteger limits never disable a boundary."""
    with pytest.raises(ValueError, match=name):
        ParseLimits(**{name: bad})
    with pytest.raises(ValueError, match=name):
        ParseLimits(**{name: ceiling + 1})


def test_document_cannot_override_root_owned_limits() -> None:
    """A payload field resembling configuration remains ordinary untrusted data."""
    source = '{"limits":{"artifact_records":1000000},"value":{}}'

    result = parse_document(
        source, format="json", limits=ParseLimits(artifact_records=2)
    )

    assert result.findings[0].code == "DOCUMENT_RECORDS"
