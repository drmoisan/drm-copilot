"""Tests for the Python port of the Claude routing-document merge (issue #507)."""

from __future__ import annotations

import json
from pathlib import Path
from typing import cast

import pytest

from scripts.dev_tools.push_down_claude_destination_writes import (
    DestinationMergeFileSystem,
)
from scripts.dev_tools.push_down_claude_routing_merge import (
    RoutingMergeError,
    merge_routing_documents,
)
from tests.scripts.dev_tools.push_down_customizations_test_support import (
    RecordingFileSystem,
)

DEST_PATH = Path("/dest/config/orchestration-routing.json")
ERROR_PREFIX = (
    "Destination routing document is not valid JSON and was not written: "
    "/dest/config/orchestration-routing.json ("
)


def _doc(value: object) -> str:
    """Serialize a document in the canonical 2-space form."""

    return json.dumps(value, indent=2) + "\n"


def _merge(destination: object, source: object) -> dict[str, object]:
    """Merge two documents and parse the result for structural assertions."""

    merged = merge_routing_documents(_doc(destination), _doc(source), DEST_PATH)
    return json.loads(merged)


def _routes(merged: dict[str, object]) -> dict[str, object]:
    """Return the merged routes block, asserting it is a JSON object."""

    routes = merged["routes"]
    assert isinstance(routes, dict), f"routes is not an object: {routes!r}"
    return cast("dict[str, object]", routes)


def test_merge_preserves_destination_keys_and_values_in_destination_order() -> None:
    """Destination top-level keys keep destination order and values."""

    destination = {"zeta": 1, "routes": {}, "alpha": {"local": True}}
    source = {"alpha": {"local": False}, "zeta": 2, "routes": {}}

    merged = _merge(destination, source)

    assert list(merged) == ["zeta", "routes", "alpha"]
    assert merged["zeta"] == 1
    assert merged["alpha"] == {"local": True}


def test_merge_replaces_parallel_route_with_source_definition() -> None:
    """The source parallel route replaces the destination's in place."""

    destination = {"routes": {"parallel": {"agent": "old"}, "local": {"agent": "l"}}}
    source = {"routes": {"parallel": {"agent": "new"}}}

    merged = _merge(destination, source)

    assert merged["routes"] == {"parallel": {"agent": "new"}, "local": {"agent": "l"}}
    assert list(_routes(merged)) == ["parallel", "local"]


def test_merge_keeps_destination_parallel_when_source_lacks_parallel() -> None:
    """A destination parallel route survives when the source defines none."""

    destination = {"routes": {"parallel": {"agent": "local-parallel"}}}
    source = {"routes": {"feature": {"agent": "f"}}}

    merged = _merge(destination, source)

    assert merged["routes"] == {
        "parallel": {"agent": "local-parallel"},
        "feature": {"agent": "f"},
    }


def test_merge_appends_source_only_routes_in_source_order() -> None:
    """Source-only routes are appended after destination routes in source order."""

    destination = {"routes": {"local": {"agent": "l"}}}
    source = {"routes": {"b": {"agent": "b"}, "local": {"agent": "x"}, "a": {}}}

    merged = _merge(destination, source)

    assert list(_routes(merged)) == ["local", "b", "a"]
    assert _routes(merged)["local"] == {"agent": "l"}


def test_merge_appends_source_only_top_level_keys_in_source_order() -> None:
    """Source-only top-level keys are appended in source order."""

    destination = {"version": 1}
    source = {"defaults": {"t": 1}, "version": 2, "extra": [1, 2]}

    merged = _merge(destination, source)

    assert list(merged) == ["version", "defaults", "extra"]
    assert merged["version"] == 1


def test_merge_treats_non_object_destination_routes_as_absent() -> None:
    """A non-object destination routes value is replaced by the source routes."""

    destination = {"routes": [1, 2], "note": "n"}
    source = {"routes": {"parallel": {"agent": "p"}}}

    merged = _merge(destination, source)

    assert merged == {"routes": {"parallel": {"agent": "p"}}, "note": "n"}


def test_merge_appended_non_object_source_routes_becomes_empty_object() -> None:
    """An appended routes key whose source value is not an object becomes {}."""

    destination = {"version": 1}
    source = {"routes": "not-an-object"}

    merged = _merge(destination, source)

    assert merged == {"version": 1, "routes": {}}


def test_merge_serializes_two_space_indent_with_trailing_newline() -> None:
    """Output uses 2-space indentation and exactly one trailing newline."""

    destination = '{"version": 1, "routes": {"a": {"agent": "x"}}}'
    source = '{"routes": {}}'

    merged = merge_routing_documents(destination, source, DEST_PATH)

    expected = (
        '{\n  "version": 1,\n  "routes": {\n    "a": {\n      "agent": "x"\n'
        "    }\n  }\n}\n"
    )
    assert merged == expected


def test_merge_is_idempotent_on_second_application() -> None:
    """Merging the same source into the merged output is byte-stable."""

    destination = _doc({"local": True, "routes": {"parallel": {"a": 1}, "x": {}}})
    source = _doc({"version": 2, "routes": {"parallel": {"a": 2}, "y": {"b": [1]}}})

    first = merge_routing_documents(destination, source, DEST_PATH)
    second = merge_routing_documents(first, source, DEST_PATH)

    assert second == first


def test_merge_emits_non_ascii_verbatim() -> None:
    """Non-ASCII characters are emitted verbatim rather than escaped."""

    destination = _doc({"label": "café"})
    source = _doc({"routes": {"r": {"note": "über"}}})

    merged = merge_routing_documents(destination, source, DEST_PATH)

    assert "café" in merged
    assert "über" in merged
    assert "\\u00" not in merged


def _assert_routing_error(error: RoutingMergeError) -> None:
    """Assert the shared error contract: type, path, and message prefix."""

    assert isinstance(error, ValueError)
    assert error.path == DEST_PATH
    assert str(error).startswith(ERROR_PREFIX)


def test_merge_raises_for_invalid_destination_json() -> None:
    """Invalid destination JSON raises RoutingMergeError."""

    with pytest.raises(RoutingMergeError) as caught:
        merge_routing_documents("{not json", _doc({}), DEST_PATH)

    _assert_routing_error(caught.value)


def test_merge_raises_for_invalid_source_json() -> None:
    """Invalid source JSON raises RoutingMergeError."""

    with pytest.raises(RoutingMergeError) as caught:
        merge_routing_documents(_doc({}), '{"routes": ', DEST_PATH)

    _assert_routing_error(caught.value)


@pytest.mark.parametrize("constant", ["NaN", "Infinity", "-Infinity"])
@pytest.mark.parametrize("side", ["destination", "source"])
def test_merge_raises_for_non_finite_constants(constant: str, side: str) -> None:
    """NaN and the infinities are rejected in either document."""

    bad = f'{{"version": {constant}}}'
    destination, source = (bad, _doc({})) if side == "destination" else (_doc({}), bad)

    with pytest.raises(RoutingMergeError) as caught:
        merge_routing_documents(destination, source, DEST_PATH)

    _assert_routing_error(caught.value)


@pytest.mark.parametrize("root", ["[]", "null", "1", '"s"'])
def test_merge_raises_for_non_object_destination_root(root: str) -> None:
    """A non-object destination root raises RoutingMergeError."""

    with pytest.raises(RoutingMergeError) as caught:
        merge_routing_documents(root, _doc({}), DEST_PATH)

    _assert_routing_error(caught.value)
    assert str(caught.value).endswith("(document root is not a JSON object)")


@pytest.mark.parametrize("root", ["[]", "null", "1", '"s"'])
def test_merge_raises_for_non_object_source_root(root: str) -> None:
    """A non-object source root raises RoutingMergeError."""

    with pytest.raises(RoutingMergeError) as caught:
        merge_routing_documents(_doc({}), root, DEST_PATH)

    _assert_routing_error(caught.value)
    assert str(caught.value).endswith("(document root is not a JSON object)")


def test_routing_merge_error_is_value_error_with_path_and_message() -> None:
    """The error stores the path as passed and renders it in POSIX form."""

    error = RoutingMergeError(DEST_PATH, "detail text")

    assert isinstance(error, ValueError)
    assert error.path == DEST_PATH
    assert str(error) == ERROR_PREFIX + "detail text)"


def test_destination_absent_writes_source_bytes_unchanged() -> None:
    """With no destination file the source text is written byte-for-byte."""

    source = (
        '{\n    "routes": {\n        "parallel": {\n'
        '            "agent": "p"\n        }\n    }\n}\n'
    )
    fs = RecordingFileSystem()
    merging = DestinationMergeFileSystem(fs, destination_root=Path("/dest"))

    merging.write_text(DEST_PATH, source)

    assert fs.read_text(DEST_PATH) == source
