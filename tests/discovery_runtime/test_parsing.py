"""Verify strict JSON/YAML normalization without filesystem or decoder fallbacks."""

from __future__ import annotations

import hashlib
import json
from dataclasses import FrozenInstanceError
from itertools import permutations
from typing import Literal, cast

import pytest
from drm_copilot_discovery.models import (
    JsonObject,
    JsonValue,
    ParsedDocument,
    canonical_json,
    to_plain_value,
)
from drm_copilot_discovery.parsing import parse_document


def test_json_and_yaml_normalize_to_identical_immutable_content() -> None:
    """Syntax and key ordering do not change the normalized structured values."""
    json_text = '{"z":[true,null,2.5],"a":{"title":"café","empty":{}}}'
    yaml_text = "a:\n  empty: {}\n  title: café\nz: [true, null, 2.5]\n"

    left = parse_document(json_text, format="json")
    right = parse_document(yaml_text, format="yaml")

    assert left.ok and right.ok
    assert left.value == right.value
    assert canonical_json(left.value) == canonical_json(right.value)
    assert left.source_sha256 == hashlib.sha256(json_text.encode()).hexdigest()
    assert left.source_sha256 != right.source_sha256
    assert left.findings == right.findings == ()


@pytest.mark.parametrize("format", ("json", "yaml"))
def test_nested_values_round_trip_without_aliasing(
    format: Literal["json", "yaml"],
) -> None:
    """Detached projections cannot mutate the stored object or its descendants."""
    result = parse_document('{"a":[{"b":2},3],"empty":{}}', format=format)

    plain = to_plain_value(result.value)
    assert isinstance(plain, dict)
    plain["a"] = "changed"
    round_trip = parse_document(canonical_json(result.value), format=format)

    assert result.ok and round_trip.value == result.value
    assert result.value is not None
    assert tuple(result.value) == ("a", "empty")
    assert len(result.value) == 2
    assert result.value["a"] == (JsonObject((("b", 2),)), 3)
    with pytest.raises(KeyError, match="missing"):
        result.value["missing"]
    with pytest.raises(FrozenInstanceError):
        field_name = "members"
        setattr(result.value, field_name, ())


@pytest.mark.parametrize("order", tuple(permutations(("a", "b", "c"))))
def test_mapping_order_is_not_part_of_canonical_content(order: tuple[str, ...]) -> None:
    """All property permutations produce the same sorted canonical JSON bytes."""
    source = json.dumps({key: key for key in order})

    result = parse_document(source, format="json")

    assert result.ok
    assert canonical_json(result.value) == b'{"a":"a","b":"b","c":"c"}\n'


@pytest.mark.parametrize(
    ("format", "text", "code", "pointer"),
    (
        ("json", '{"a":1,"a":2}', "DOCUMENT_DUPLICATE_KEY", "/a"),
        ("json", '{"a":1,"\\u0061":2}', "DOCUMENT_DUPLICATE_KEY", "/a"),
        ("json", '{"x":{"a/b~":1,"a/b~":2}}', "DOCUMENT_DUPLICATE_KEY", "/x/a~1b~0"),
        ("yaml", "a: 1\na: 2", "DOCUMENT_DUPLICATE_KEY", "/a"),
        ("yaml", "a: &key x\n*key: 1\nx: 2", "DOCUMENT_DUPLICATE_KEY", "/x"),
        ("yaml", "a: {<<: {b: 1}}", "DOCUMENT_MERGE", "/a"),
        ("yaml", "{1: a}", "DOCUMENT_KEY_TYPE", ""),
        ("yaml", "{true: a}", "DOCUMENT_KEY_TYPE", ""),
        ("yaml", "? [a, b]\n: value", "DOCUMENT_KEY_TYPE", ""),
        ("yaml", "a: &a [*a]", "DOCUMENT_CYCLE", "/a/0"),
        ("yaml", "&a {self: *a}", "DOCUMENT_CYCLE", "/self"),
        ("json", '{"a": NaN}', "DOCUMENT_NONFINITE", "/a"),
        ("json", '{"a": Infinity}', "DOCUMENT_NONFINITE", "/a"),
        ("json", '{"a": -Infinity}', "DOCUMENT_NONFINITE", "/a"),
        ("json", '{"a": 1e9999}', "DOCUMENT_NONFINITE", "/a"),
        ("yaml", "a: .nan", "DOCUMENT_NONFINITE", "/a"),
        ("yaml", "a: -.inf", "DOCUMENT_NONFINITE", "/a"),
        ("yaml", "a: 2024-01-01", "DOCUMENT_VALUE_TYPE", "/a"),
        ("yaml", "a: !!binary YQ==", "DOCUMENT_VALUE_TYPE", "/a"),
        ("yaml", "a: !!set {x: null}", "DOCUMENT_VALUE_TYPE", "/a"),
        ("yaml", "a: !!omap [{x: 1}]", "DOCUMENT_VALUE_TYPE", "/a"),
        ("yaml", "a: !custom value", "DOCUMENT_VALUE_TYPE", "/a"),
        ("yaml", "a: !!int invalid", "DOCUMENT_VALUE_TYPE", "/a"),
        ("yaml", "a: !!bool invalid", "DOCUMENT_VALUE_TYPE", "/a"),
        ("yaml", "a: !!python/object:module.Class {}", "DOCUMENT_VALUE_TYPE", "/a"),
        ("json", '{"a":"\\ud800"}', "DOCUMENT_ENCODING", "/a"),
        ("json", '{"\\ud800":1}', "DOCUMENT_ENCODING", ""),
        ("yaml", 'a: "\\ud800"', "DOCUMENT_ENCODING", "/a"),
    ),
)
def test_ambiguous_or_non_json_values_fail_with_pointer(
    format: Literal["json", "yaml"], text: str, code: str, pointer: str
) -> None:
    """Unsupported semantics are diagnosed without exposing a partial document."""
    result = parse_document(text, format=format, artifact_path="docs/Input.yaml")

    assert not result.ok and result.value is None
    assert any(f.code == code and f.pointer == pointer for f in result.findings)
    assert all(
        f.artifact_path == "docs/Input.yaml" and f.next_action for f in result.findings
    )


@pytest.mark.parametrize("format", ("json", "yaml"))
@pytest.mark.parametrize("text", ("null", "[]", "true", "23", '"text"'))
def test_non_object_roots_are_rejected(
    format: Literal["json", "yaml"], text: str
) -> None:
    """Artifact parsing accepts only object roots, even when scalar syntax is valid."""
    result = parse_document(text, format=format)

    assert not result.ok
    assert result.findings[0].code == "DOCUMENT_ROOT"


@pytest.mark.parametrize(
    ("format", "text"),
    (
        ("json", ""),
        ("json", "{x: 1}"),
        ("json", '{"a": 1,}'),
        ("json", "{} {}"),
        ("json", '{"x":'),
        ("yaml", "a: [1"),
        ("yaml", "{}\n---\n{}"),
        ("yaml", "a: *missing"),
        ("yaml", "a: &a 1\nb: &a 2"),
        ("yaml", "\tkey: value"),
    ),
)
def test_invalid_grammar_is_not_reparsed_with_a_weaker_syntax(
    format: Literal["json", "yaml"], text: str
) -> None:
    """Malformed input returns one actionable syntax finding without a fallback."""
    result = parse_document(text, format=format)

    assert not result.ok
    assert result.findings[0].code == "DOCUMENT_SYNTAX"


@pytest.mark.parametrize("content", (b"\xff", b"\xff\xfe{\x00}\x00", "\ud800"))
def test_invalid_utf8_input_fails_before_decoding(content: bytes | str) -> None:
    """Wrong encodings and unpaired Unicode surrogates are never normalized away."""
    result = parse_document(content, format="yaml")

    assert not result.ok
    assert result.findings[0].code == "DOCUMENT_ENCODING"


@pytest.mark.parametrize("format", ("json", "yaml"))
def test_utf8_bom_and_line_endings_preserve_raw_identity(
    format: Literal["json", "yaml"],
) -> None:
    """An optional UTF-8 BOM is accepted while source hashes remain byte-specific."""
    raw = b'\xef\xbb\xbf{\r\n"a":1\r\n}\r\n'

    result = parse_document(raw, format=format)

    assert result.ok and canonical_json(result.value) == b'{"a":1}\n'
    assert result.source_sha256 == hashlib.sha256(raw).hexdigest()


def test_yaml_acyclic_aliases_and_quoted_merge_spelling_are_data() -> None:
    """Finite alias reuse and literal string keys retain ordinary JSON semantics."""
    result = parse_document('a: &a [1, 2]\nb: *a\n"<<": literal', format="yaml")

    assert result.ok
    assert to_plain_value(result.value) == {"a": [1, 2], "b": [1, 2], "<<": "literal"}


def test_empty_yaml_document_and_unsupported_format_are_explicit() -> None:
    """Empty YAML has a wrong root; an invalid trusted format is an invocation error."""
    result = parse_document("", format="yaml")

    assert result.findings[0].code == "DOCUMENT_ROOT"
    with pytest.raises(ValueError, match="format"):
        parse_document("{}", format=cast('Literal["json"]', "toml"))


@pytest.mark.parametrize("path", ("../escape.json", "/absolute.json"))
@pytest.mark.parametrize("content", ("{}", "invalid"))
def test_invalid_diagnostic_path_is_an_invocation_error(
    path: str, content: str
) -> None:
    """Caller path validation must not depend on whether document parsing succeeds."""
    with pytest.raises(ValueError, match="workspace-relative"):
        parse_document(content, format="json", artifact_path=path)


@pytest.mark.parametrize("value", (float("nan"), float("inf"), [1], {"a": 1}, b"x"))
def test_direct_immutable_values_reject_non_json_descendants(value: object) -> None:
    """Public value constructors cannot retain mutable or nonfinite data."""
    with pytest.raises(ValueError):
        JsonObject((("a", cast("JsonValue", value)),))


def test_value_constructors_enforce_keys_and_parsed_result_consistency() -> None:
    """Direct calls retain the same immutable root and error-state invariants."""
    with pytest.raises(ValueError, match="unique"):
        JsonObject((("a", 1), ("a", 2)))
    with pytest.raises(ValueError, match="strings"):
        JsonObject(((cast("str", 1), 1),))
    with pytest.raises(ValueError, match="Failed documents"):
        ParsedDocument(value=None, findings=(), source_sha256=None, format="json")
    with pytest.raises(ValueError, match="digest"):
        ParsedDocument(
            value=JsonObject(()), findings=(), source_sha256="bad", format="json"
        )
    with pytest.raises(ValueError, match="format"):
        ParsedDocument(
            value=JsonObject(()),
            findings=(),
            source_sha256=None,
            format=cast('Literal["json"]', "bad"),
        )
    with pytest.raises(ValueError, match="immutable JSON object"):
        ParsedDocument(
            value=cast("JsonObject", {}), findings=(), source_sha256=None, format="json"
        )
