"""Verify prospective Node input, traversal and redaction capacities in memory."""

from __future__ import annotations

from dataclasses import replace
from typing import cast

import pytest
from drm_copilot_discovery.analyzer import dependency_node as implementation
from drm_copilot_discovery.analyzer.dependency_inputs import (
    DependencyInputError,
    DependencyLimits,
)
from drm_copilot_discovery.analyzer.dependency_node import parse_node_dependencies

from tests.discovery_runtime.analyzer.test_dependency_node import (
    FORMATS,
    parse,
    rendered,
)


@pytest.mark.parametrize(
    "argument,invalid",
    [
        ("format", "yarn"),
        ("format", []),
        ("content", "VALUE_SENTINEL"),
        ("content", bytearray()),
        ("limits", None),
    ],
)
def test_public_contract_misuse_has_fixed_errors(
    argument: str, invalid: object
) -> None:
    """Str argument/object invalid exercise only public boundary misuse.

    Returns None; deliberately wrong types are isolated through explicit casts.
    """
    with pytest.raises(ValueError) as caught:
        parse_node_dependencies(
            cast("bytes", invalid) if argument == "content" else b"{}",
            format=cast("FORMATS", invalid) if argument == "format" else "package-json",
            limits=(
                cast("DependencyLimits", invalid)
                if argument == "limits"
                else DependencyLimits()
            ),
        )
    assert "VALUE_SENTINEL" not in str(caught.value)


@pytest.mark.parametrize(
    "limit,amount,content",
    [
        ("max_bytes", 1, b"{}"),
        ("max_nodes", 63, b"{}"),
        ("max_lines", 1, b'{\r\n"x":1\r}'),
    ],
)
def test_input_limits_precede_json_parser_allocation(
    limit: str, amount: int, content: bytes, monkeypatch: pytest.MonkeyPatch
) -> None:
    """Str limit/int amount/bytes content exercise prospective input bounds.

    pytest.MonkeyPatch monkeypatch isolates the allocation guard and proves the
    accepted parser is never called. Returns None; expected errors are caught.
    """

    def forbidden(*args: object, **kwargs: object) -> object:
        """Reject object args/kwargs; raise AssertionError without effects or return."""
        raise AssertionError("Parser allocation must not occur")

    monkeypatch.setattr(implementation, "parse_document", forbidden)
    with pytest.raises(DependencyInputError) as caught:
        parse_node_dependencies(
            content,
            format="package-json",
            limits=replace(DependencyLimits(), **{limit: amount}),
        )
    assert caught.value.code == "dependency-limit"


@pytest.mark.parametrize(
    "value,limits",
    [
        ({"dependencies": {"a": "1", "b": "2"}}, {"max_candidates": 1}),
        ({"dependencies": {"a": "1"}}, {"max_text_bytes": 1}),
        ({"nested": {"deeper": {}}}, {"max_depth": 1}),
        ({"dependencies": {}}, {"max_nodes": 64}),
        (
            {
                "lockfileVersion": 3,
                "packages": {"node_modules/a/" * 140 + "node_modules/b": {}},
            },
            {"max_nodes": 256},
        ),
    ],
)
def test_aggregate_allocation_and_normalization_bounds_discard_complete_result(
    value: object, limits: dict[str, int]
) -> None:
    """Object value/int limits exhaust independent count, text and depth budgets.

    Returns None; neither earlier candidates nor private source strings escape.
    """
    format: FORMATS = (
        "package-lock"
        if isinstance(value, dict) and "lockfileVersion" in value
        else "package-json"
    )
    with pytest.raises(DependencyInputError) as caught:
        parse(cast("object", value), format=format, **limits)
    assert caught.value.code == "dependency-limit"


@pytest.mark.parametrize("count", [1, 5, 20])
def test_lock_extraction_reserves_linear_work_across_records(count: int) -> None:
    """Int count scales a small captured map; returns None without timing gates.

    Independent normalized-node allocation and extraction work stay bounded.
    """
    # Distinct locations require one index and one bounded segment scan each.
    packages = {f"node_modules/pkg{index}": {"version": "1"} for index in range(count)}
    result = parse({"lockfileVersion": 3, "packages": packages}, format="package-lock")
    assert len(result.candidates) == count
    assert result.consumed_nodes <= 8 * count + 8


@pytest.mark.parametrize(
    "key",
    ["éVALUE_SENTINEL", "😀VALUE_SENTINEL", 'bad/"VALUE_SENTINEL', "~VALUE_SENTINEL"],
)
def test_unicode_and_escaped_identifiers_remain_redacted_and_budgeted(key: str) -> None:
    """Str key covers UTF-8 and JSON escaping expansion; returns None.

    Prospective selected-string bytes include the full raw spelling before redaction.
    """
    result = parse({"dependencies": {key: "1"}})
    assert result.candidates[0].name is None and "VALUE_SENTINEL" not in rendered(
        result
    )
    assert result.consumed_text_bytes >= len(key.encode())
    with pytest.raises(DependencyInputError, match="limit"):
        parse({"dependencies": {key: "1"}}, max_text_bytes=len(key.encode()) - 1)
