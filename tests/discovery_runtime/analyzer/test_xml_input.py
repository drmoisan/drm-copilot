"""Exercise secure XML byte parsing with immutable, isolated in-memory inputs."""

from __future__ import annotations

from dataclasses import FrozenInstanceError, replace
from types import SimpleNamespace
from typing import cast

import pytest
from drm_copilot_discovery.analyzer import xml_input
from drm_copilot_discovery.analyzer.xml_input import XmlInputError, XmlNode, parse_xml


def parse(content: bytes, **limits: int) -> tuple[XmlNode, ...]:
    """Parse test content (bytes) with explicit small limits and int overrides.

    Returns tuple[XmlNode, ...]; propagates parser rejection. No I/O or shared state.
    """
    options = {"max_bytes": 8192, "max_elements": 100, "max_depth": 16}
    options.update(limits)
    return parse_xml(content, **options)


@pytest.mark.parametrize("encoding", ["utf-8", "utf-8-sig", "utf-16", "utf-32"])
def test_literal_nodes_preserve_unicode_namespace_parents_and_anchors(
    encoding: str,
) -> None:
    """Given encoding (str), retain literal Unicode XML metadata and actual lines.

    Returns None; assertions fail on changes. Only in-memory byte parsing occurs.
    """
    content = (
        '<Project xmlns="urn:synthetic" Z="2" A="1">\r\n'
        " <Name>État &amp; Ω</Name>\r\n <Empty/>\r\n</Project>"
    ).encode(encoding)
    nodes = parse(content)
    assert [node.tag for node in nodes] == [
        "{urn:synthetic}Project",
        "{urn:synthetic}Name",
        "{urn:synthetic}Empty",
    ]
    assert [node.parent for node in nodes] == [None, 0, 0]
    assert [node.line for node in nodes] == [1, 2, 3]
    assert nodes[0].attributes == (("A", "1"), ("Z", "2"))
    assert nodes[1].text == "État & Ω"
    assert nodes[0].attribute("A") == "1" and nodes[0].attribute("Missing") is None
    assert nodes[2].text == ""
    assert parse(content) == nodes


def test_comments_processing_instructions_and_multiline_tags_remain_literal() -> None:
    """Ignore inert comments/PI and retain parser anchors without fabricated spans.

    Returns None; AssertionError signals a mismatch. No arguments, I/O or mutation.
    """
    content = (
        b"<?synthetic instruction?>\n<Project>\n<!-- comment -->\n"
        b' <Reference\n Include="A"\n />\n</Project>'
    )
    nodes = parse(content)
    assert len(nodes) == 2 and nodes[1].tag == "Reference"
    assert nodes[1].line in (4, 6)
    assert nodes[1].attribute("Include") == "A"


@pytest.mark.parametrize("encoding", ["utf-8", "utf-16", "utf-32"])
@pytest.mark.parametrize(
    "declaration",
    [
        "<!DOCTYPE Project>",
        '<!DOCTYPE Project [<!ENTITY x "expanded">]>',
        '<!DOCTYPE Project SYSTEM "file:///never-read.dtd">',
        '<!DOCTYPE Project SYSTEM "https://invalid.invalid/never-fetch.dtd">',
        '<!DOCTYPE Project [<!ENTITY % remote SYSTEM "https://invalid.invalid/never-fetch.dtd">%remote;]>',
        '<!DOCTYPE Project [<!ENTITY x SYSTEM "file:///never-read.txt">]>',
    ],
)
def test_all_dtd_forms_are_rejected_before_processing(
    encoding: str, declaration: str
) -> None:
    """Reject encoding/declaration (str) security cases before any subset is processed.

    Returns None; expected XmlInputError proves rejection. No external resource is
    required or accessed because the doctype event rejects the entire declaration.
    """
    content = (declaration + "<Project/>").encode(encoding)
    with pytest.raises(XmlInputError, match="DTD and custom entity") as caught:
        parse(content)
    assert caught.value.code == "xml-dtd"


@pytest.mark.parametrize(
    "content, code",
    [
        (
            b'<Project xmlns:xi="http://www.w3.org/2001/XInclude"><xi:include href="file:///never-read"/></Project>',
            "xml-external",
        ),
        (b"<Project>&undefined;</Project>", "xml-malformed"),
        (b"<Project><Unclosed></Project>", "xml-malformed"),
        (b"<Project/><Project/>", "xml-malformed"),
        (b"", "xml-malformed"),
        (b"\x1f\x8bcompressed", "xml-malformed"),
        (
            b'<?xml version="1.0" encoding="unknown-encoding"?><Project/>',
            "xml-malformed",
        ),
    ],
)
def test_unsupported_or_malformed_input_fails_closed(content: bytes, code: str) -> None:
    """Given content (bytes), require fixed code (str) without raw exception leaks.

    Returns None; asserts a specific XmlInputError. No I/O or external state.
    """
    with pytest.raises(XmlInputError) as caught:
        parse(content)
    assert caught.value.code == code
    assert "never-read" not in str(caught.value)


@pytest.mark.parametrize(
    "limits, content",
    [
        ({"max_bytes": 9}, b"<Project/>"),
        ({"max_elements": 1}, b"<Project><Child/></Project>"),
        ({"max_depth": 1}, b"<Project><Child/></Project>"),
    ],
)
def test_resource_limits_reject_before_allocating_excess_nodes(
    limits: dict[str, int], content: bytes
) -> None:
    """Require limit failure for content (bytes) and positive limits (dict[str,int]).

    Returns None; XmlInputError is required. All inputs and parse state are local.
    """
    with pytest.raises(XmlInputError) as caught:
        parse(content, **limits)
    assert caught.value.code == "xml-limit"


@pytest.mark.parametrize(
    "name,value",
    [
        ("max_bytes", 0),
        ("max_bytes", 67108865),
        ("max_elements", 100001),
        ("max_depth", 129),
        ("max_depth", True),
    ],
)
def test_invalid_parser_limits_are_not_silently_coerced(name: str, value: int) -> None:
    """Reject invalid name/value (str/int) limits; bool is not an integer budget.

    Returns None; requires ValueError. No I/O, source reads, or shared mutation.
    """
    with pytest.raises(ValueError, match="positive bounded integers"):
        parse(b"<Project/>", **{name: value})


def test_text_input_cannot_cross_the_retained_bytes_boundary() -> None:
    """Reject text despite a statically typed caller contract; no implicit encoding.

    Returns None; requires ValueError. Takes no arguments and performs no I/O.
    """
    with pytest.raises(ValueError, match="retained bytes"):
        parse(cast("bytes", cast("object", "<Project/>")))


def test_missing_parser_line_is_not_invented(monkeypatch: pytest.MonkeyPatch) -> None:
    """Given monkeypatch, simulate a dependency missing an actual source anchor.

    Returns None; requires XmlInputError. The local fake performs no parsing or I/O.
    """

    def library(name: str) -> object:
        """For fixed name (str), return local parser factories; no I/O or mutation."""
        assert name == "lxml.etree"

        def parser(**options: object) -> object:
            """Accept options (object kwargs); return an inert parser without I/O."""
            return options

        def root(content: bytes, parser: object) -> object:
            """Accept content/parser; return anchorless tree stub, without I/O."""
            return SimpleNamespace(sourceline=None)

        return SimpleNamespace(
            TreeBuilder=object,
            XMLParser=parser,
            fromstring=root,
            XMLSyntaxError=ValueError,
        )

    monkeypatch.setattr(xml_input, "import_module", library)
    with pytest.raises(XmlInputError) as caught:
        parse(b"<Project/>")
    assert caught.value.code == "xml-anchor"


@pytest.mark.parametrize(
    "changes",
    [
        {"tag": ""},
        {"text": None},
        {"line": 0},
        {"line": True},
        {"parent": -1},
        {"parent": True},
        {"attributes": []},
        {"attributes": (["A", "B"],)},
        {"attributes": (("A",),)},
        {"attributes": (("A", 2),)},
        {"attributes": (("A", "1"), ("A", "2"))},
    ],
)
def test_node_construction_rejects_mutable_or_invalid_values(
    changes: dict[str, object],
) -> None:
    """Reject changes (dict[str,object]) violating immutable XML metadata invariants.

    Returns None; requires ValueError. Only local dataclass construction occurs.
    """
    node = XmlNode(tag="Project", attributes=(), text="", line=1, parent=None)
    with pytest.raises(ValueError):
        replace(node, **changes)


@pytest.mark.parametrize("field", ["line", "parent"])
def test_nodes_are_frozen_and_parent_zero_is_valid(field: str) -> None:
    """Retain valid zero parent indexes and reject mutation of the resulting value.

    field (str) selects an immutable integer field. Returns None;
    FrozenInstanceError is required. No I/O or shared mutation.
    """
    node = XmlNode(tag="Child", attributes=(), text="", line=2, parent=0)
    with pytest.raises(FrozenInstanceError):
        setattr(node, field, 9)
    assert node.line == 2 and node.parent == 0


@pytest.mark.parametrize("text", ["", "abc", " Ωé ", "A012" * 10])
@pytest.mark.parametrize("count", [1, 2, 8, 12])
def test_text_and_exact_element_budget_are_preserved(text: str, count: int) -> None:
    """For generated text/count, preserve literal values at the exact node boundary.

    text (str) excludes XML delimiters; count (int) bounds child count. Returns None;
    assertion failures expose parser drift. No I/O or mutable shared state.
    """
    content = (
        "<Project>"
        + "<Value>"
        + text
        + "</Value>"
        + "<Empty/>" * (count - 1)
        + "</Project>"
    ).encode()
    nodes = parse(content, max_elements=count + 1)
    assert len(nodes) == count + 1 and nodes[1].text == text
    assert parse(content, max_elements=count + 1) == nodes
