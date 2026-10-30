"""Prove strict retained-byte decoding and bounded literal C# token anchors."""

from __future__ import annotations

import codecs
from dataclasses import FrozenInstanceError

import pytest
from drm_copilot_discovery.analyzer.csharp_tokens import (
    SourceScanError,
    Token,
    decode_source,
    tokenize_csharp,
)


@pytest.mark.parametrize("encoding", ["utf-8", "utf-8-sig", "utf-16", "utf-32"])
def test_decoding_retains_physical_text(encoding: str) -> None:
    """str encoding selects valid byte fixtures; decode returns exact str, no I/O.
    Returns None; assertions check isolated data without external effects."""
    text = "class Café\r\n{\r\n}\rnamespace Δ;\n"
    assert decode_source(text.encode(encoding)) == text


@pytest.mark.parametrize(
    ("bom", "encoding"),
    [(codecs.BOM_UTF16_BE, "utf-16-be"), (codecs.BOM_UTF32_BE, "utf-32-be")],
)
def test_big_endian_bom_is_authoritative(bom: bytes, encoding: str) -> None:
    """bytes bom and str encoding produce exact text; assertions are pure.
    Returns None; assertions check isolated data without external effects."""
    assert decode_source(bom + "class Ω {}".encode(encoding)) == "class Ω {}"


@pytest.mark.parametrize(
    "payload", [b"\xff", b"\xff\xfe\x00", b"a\x00b", b"\xed\xa0\x80"]
)
def test_invalid_encoding_never_uses_replacement(payload: bytes) -> None:
    """bytes payload is rejected with source-encoding instead of invented text.
    Returns None; assertions check isolated data without external effects."""
    with pytest.raises(SourceScanError, match="C# input") as error:
        decode_source(payload)
    assert error.value.code == "source-encoding"


@pytest.mark.parametrize("limit", [0, -1, 67108865, True])
def test_invalid_byte_bound_is_explicit(limit: int) -> None:
    """int limit outside supported bounds raises ValueError without I/O.
    Returns None; assertions check isolated data without external effects."""
    with pytest.raises(ValueError, match="byte limit"):
        decode_source(b"a", max_bytes=limit)


def test_byte_limit_is_inclusive() -> None:
    """Exact byte limit succeeds and one extra byte fails before decoding.
    Returns None; assertions check isolated data without external effects."""
    assert decode_source(b"ab", max_bytes=2) == "ab"
    with pytest.raises(SourceScanError) as error:
        decode_source(b"abc", max_bytes=2)
    assert error.value.code == "source-limit"


@pytest.mark.parametrize(
    "name",
    [
        "Name",
        "_x",
        "Δelta",
        "Café",
        "e\u0301",
        "Ⅻ",
        "@class",
        r"\u0394",
        r"a\u0301",
        r"\U00010400",
        "a\u200c",
    ],
)
def test_identifier_literal_spelling_and_offsets(name: str) -> None:
    """str name keeps literal spelling, offset and identifier classification.
    Returns None; assertions check isolated data without external effects."""
    tokens = tokenize_csharp("  " + name + ";")
    assert tokens[0] == Token(
        value=name, start=2, end=2 + len(name), line=1, identifier=True
    )
    assert tokens[1].value == ";" and not tokens[1].identifier


@pytest.mark.parametrize("separator", ["\r\n", "\r", "\n"])
def test_physical_lines_and_literal_offsets(separator: str) -> None:
    """str separator is one physical boundary; token offsets use original text.
    Returns None; assertions check isolated data without external effects."""
    text = "A" + separator + "  B" + separator
    tokens = tokenize_csharp(text)
    # Assert physical anchors and offsets together, independently of token kinds.
    assert [(item.value, item.line, item.start) for item in tokens] == [
        ("A", 1, 0),
        ("B", 2, len(separator) + 3),
    ]


@pytest.mark.parametrize("separator", ["\u2028", "\u2029", "\x85", "\v", "\f"])
def test_unicode_whitespace_does_not_fabricate_physical_lines(separator: str) -> None:
    """Nonphysical str separator does not change the reported source line.
    Returns None; assertions check isolated data without external effects."""
    # Only physical line separators may change line numbers.
    assert [item.line for item in tokenize_csharp("A" + separator + "B")] == [1, 1]


@pytest.mark.parametrize(
    "text",
    [
        r"\x10",
        r"\u0",
        r"\uZZZZ",
        r"\U00110000",
        r"\uD800",
        r"\u0031name",
        r"a\u0020",
        "@",
        "@1",
    ],
)
def test_malformed_identifier_is_not_partially_accepted(text: str) -> None:
    """str text raises source-identifier rather than emitting a truncated name.
    Returns None; assertions check isolated data without external effects."""
    with pytest.raises(SourceScanError) as error:
        tokenize_csharp(text)
    assert error.value.code == "source-identifier"


@pytest.mark.parametrize("text", ["\x00", "a \ud800"])
def test_direct_text_rejects_invalid_scalars(text: str) -> None:
    """Invalid direct str text raises source-encoding; no partial tokens escape.
    Returns None; assertions check isolated data without external effects."""
    with pytest.raises(SourceScanError) as error:
        tokenize_csharp(text)
    assert error.value.code == "source-encoding"


@pytest.mark.parametrize("limit", [0, -1, 100001, True])
def test_invalid_token_bound_is_explicit(limit: int) -> None:
    """int limit outside supported bounds raises ValueError without I/O.
    Returns None; assertions check isolated data without external effects."""
    with pytest.raises(ValueError, match="Token limit"):
        tokenize_csharp("", max_tokens=limit)


def test_token_limit_bounds_allocation() -> None:
    """The inclusive token budget rejects additional nonwhitespace input.
    Returns None; assertions check isolated data without external effects."""
    assert len(tokenize_csharp("a ;\n", max_tokens=2)) == 2
    with pytest.raises(SourceScanError) as error:
        tokenize_csharp("a ; b", max_tokens=2)
    assert error.value.code == "source-token-limit"
    assert tokenize_csharp(" \r\n") == ()


def test_directives_are_omitted_without_evaluating_branches() -> None:
    """Directive text creates no token while both textual branches remain.
    Returns None; assertions check isolated data without external effects."""
    tokens = tokenize_csharp("#if class Fake\rclass A {}\r#else\rclass B {}\r#endif")
    # Both textual branches remain visible while directive text is omitted.
    assert [item.value for item in tokens] == [
        "class",
        "A",
        "{",
        "}",
        "class",
        "B",
        "{",
        "}",
    ]
    assert tokens[0].line == 2 and tokens[4].line == 4


def test_compound_operators_and_numeric_tokens() -> None:
    """Compound punctuation remains atomic and numbers cannot become names.
    Returns None; assertions check isolated data without external effects."""
    tokens = tokenize_csharp("x += 3; y -= z; a?.b => q::r")
    # Verify operator boundaries without treating numeric operands as names.
    assert [item.value for item in tokens] == [
        "x",
        "+=",
        "3",
        ";",
        "y",
        "-=",
        "z",
        ";",
        "a",
        "?.",
        "b",
        "=>",
        "q",
        "::",
        "r",
    ]
    assert not tokens[2].identifier


@pytest.mark.parametrize(
    ("value", "start", "end", "line"),
    [("", 0, 1, 1), ("a", -1, 0, 1), ("a", 0, 0, 1), ("a", 0, 1, 0), ("ab", 0, 1, 1)],
)
def test_token_construction_enforces_literal_span(
    value: str, start: int, end: int, line: int
) -> None:
    """str value and int coordinates must form one honest immutable token.
    Returns None; assertions check isolated data without external effects."""
    with pytest.raises(ValueError, match="Token"):
        Token(value=value, start=start, end=end, line=line, identifier=True)


def test_tokens_are_immutable() -> None:
    """Frozen tokens reject mutation through the standard attribute API.
    Returns None; assertions check isolated data without external effects."""
    token = tokenize_csharp("Name")[0]
    attribute = "line"
    with pytest.raises(FrozenInstanceError):
        setattr(token, attribute, 2)
