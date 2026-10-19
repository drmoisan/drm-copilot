"""Parse bounded XML bytes into immutable declarations without external access.

The fixed lxml dependency stays behind typed protocols. A parser-local target
rejects every DTD before its subset is processed, bounds elements/depth while
building, and preserves actual opening-tag line anchors. No path, network,
XInclude, schema, or build evaluation API is exposed.
"""

from __future__ import annotations

from dataclasses import dataclass
from importlib import import_module
from typing import TYPE_CHECKING, Protocol, cast

if TYPE_CHECKING:
    from collections.abc import Iterator, Mapping


class XmlInputError(ValueError):
    """Carry a stable XML rejection code without disclosing parser exception text.

    Callers translate code/message into source-bound diagnostics. Construction
    stores inert text only; no XML, files, or external resources are evaluated.
    """

    def __init__(self, code: str, message: str) -> None:
        """Retain code/message (str); return None without I/O or input mutation."""
        self.code = code
        super().__init__(message)


@dataclass(frozen=True, kw_only=True)
class XmlNode:
    """Retain one element's literal metadata and opening line after secure parsing.

    Nodes are returned in document order. parent indexes the same immutable node
    tuple; text contains only direct leading text, without synthesized child text.
    Names retain Clark namespaces. Consumers must not evaluate attribute values.
    """

    tag: str
    attributes: tuple[tuple[str, str], ...]
    text: str
    line: int
    parent: int | None

    def __post_init__(self) -> None:
        """Validate immutable metadata and anchors; return None, without I/O.

        Uses the declared constructor fields. Raises ValueError for mutable or
        malformed attributes, non-text values, or invalid line/parent indexes.
        """
        if not self.tag or type(self.tag) is not str or type(self.text) is not str:
            raise ValueError("XML names and text must be strings")
        if type(self.line) is not int or self.line < 1:
            raise ValueError("XML line anchors must be positive integers")
        if self.parent is not None and (
            type(self.parent) is not int or self.parent < 0
        ):
            raise ValueError("XML parent indexes must be nonnegative integers")
        if type(self.attributes) is not tuple:
            raise ValueError("XML attributes must be immutable name/value pairs")
        # Refuse mutable descendants so frozen node values remain deeply immutable.
        for pair in self.attributes:
            if (
                type(pair) is not tuple
                or len(pair) != 2
                or any(type(v) is not str for v in pair)
            ):
                raise ValueError("XML attributes must be immutable name/value pairs")
        if len(dict(self.attributes)) != len(self.attributes):
            raise ValueError("XML attribute names must be unique")

    def attribute(self, name: str) -> str | None:
        """Return a literal attribute by name (str), or None; no I/O or mutation."""
        return dict(self.attributes).get(name)


class _Element(Protocol):
    """Describe only immutable reads needed from the private third-party tree."""

    tag: str
    attrib: Mapping[str, str]
    text: str | None
    sourceline: int | None

    def __iter__(self) -> Iterator[_Element]:
        """Return child elements in document order; no arguments or external I/O."""
        ...


class _Builder(Protocol):
    """Hide lxml's untyped tree builder behind its narrow event contract."""

    def start(self, tag: str, attributes: Mapping[str, str]) -> _Element:
        """Build one element from tag/attributes; return it; mutate private tree."""
        ...

    def end(self, tag: str) -> _Element:
        """Close tag (str); return its element; mutate only private tree state."""
        ...

    def data(self, value: str) -> None:
        """Append value (str) to private text; return None without external I/O."""
        ...

    def close(self) -> _Element:
        """Return the root or raise parser error; takes no arguments or I/O."""
        ...


class _Library(Protocol):
    """Type the fixed XML library factories without exposing arbitrary execution."""

    XMLSyntaxError: type[Exception]

    def TreeBuilder(self) -> _Builder:
        """Return a fresh private tree builder; takes no arguments or I/O."""
        ...

    def XMLParser(self, **options: object) -> object:
        """Bind fixed parser options (object values); return opaque parser state."""
        ...

    def fromstring(self, content: bytes, parser: object) -> _Element:
        """Parse content bytes with parser; return root or raise syntax error."""
        ...


class _GuardedTarget:
    """Bound parser events before tree allocation and reject DTD processing.

    A new instance belongs to one parse. It delegates accepted events to the
    private builder, retaining the first policy error so close cannot replace it
    with a secondary incomplete-tree error. It performs no external I/O.
    """

    def __init__(self, builder: _Builder, depth: int, elements: int) -> None:
        """Bind builder and positive depth/elements (int); return None; no I/O."""
        self.builder = builder
        self.max_depth, self.max_elements = depth, elements
        self.depth = self.count = 0
        self.failure: XmlInputError | None = None

    def reject(self, code: str, message: str) -> None:
        """Store then raise XmlInputError from code/message (str); never return."""
        self.failure = XmlInputError(code, message)
        raise self.failure

    def start(self, tag: str, attributes: Mapping[str, str]) -> _Element:
        """Bound tag/attributes before allocation; return element or raise limit error.

        tag (str) and attributes (Mapping[str, str]) are parser events. Only private
        counters/tree mutate; XmlInputError prevents over-budget allocation.
        """
        if self.depth >= self.max_depth or self.count >= self.max_elements:
            self.reject("xml-limit", "XML depth or element count exceeds its limit.")
        if tag.startswith("{http://www.w3.org/2001/XInclude}"):
            self.reject("xml-external", "XInclude declarations are not supported.")
        self.depth += 1
        self.count += 1
        return self.builder.start(tag, attributes)

    def end(self, tag: str) -> _Element:
        """Close tag (str); return element and reduce depth; parser errors pass."""
        element = self.builder.end(tag)
        self.depth -= 1
        return element

    def data(self, value: str) -> None:
        """Forward literal value (str) to the private tree; return None, no I/O."""
        self.builder.data(value)

    def doctype(self, name: str, public_id: str | None, system_id: str | None) -> None:
        """Reject any DTD before processing it, irrespective of encoding or URI.

        name (str), public_id/system_id (str | None) are untrusted parser metadata.
        Always raises XmlInputError; stores only the fixed error, never reads URIs.
        """
        self.reject("xml-dtd", "DTD and custom entity declarations are prohibited.")

    def close(self) -> _Element:
        """Return root or preserve the first XmlInputError; no arguments or I/O."""
        if self.failure is not None:
            raise self.failure
        return self.builder.close()


def parse_xml(
    content: bytes, *, max_bytes: int, max_elements: int, max_depth: int = 64
) -> tuple[XmlNode, ...]:
    """Return bounded immutable XML nodes with actual opening-line anchors.

    content (bytes) is already captured source. max_bytes/max_elements/max_depth
    (int) are positive limits, with hard ceilings of 64 MiB/100000/128. Rejects
    malformed XML, DTD/custom entities, XInclude, and exceeded limits with
    XmlInputError. Invalid parameter types/ranges raise ValueError. Only supplied
    memory is parsed; no decompression, path parsing, I/O, or input mutation occurs.
    """
    # Bound configuration itself so a caller cannot disable parser resource guards.
    for value, ceiling in (
        (max_bytes, 67108864),
        (max_elements, 100000),
        (max_depth, 128),
    ):
        if type(value) is not int or not 1 <= value <= ceiling:
            raise ValueError("XML limits must be positive bounded integers")
    if not isinstance(cast("object", content), bytes):
        raise ValueError("XML input must be retained bytes")
    if len(content) > max_bytes:
        raise XmlInputError("xml-limit", "XML bytes exceed the configured limit.")
    library = cast("_Library", import_module("lxml.etree"))
    target = _GuardedTarget(library.TreeBuilder(), max_depth, max_elements)
    parser = library.XMLParser(
        target=target,
        resolve_entities=False,
        load_dtd=False,
        no_network=True,
        dtd_validation=False,
        attribute_defaults=False,
        recover=False,
        huge_tree=False,
        remove_comments=True,
        remove_pis=True,
    )
    try:
        root = library.fromstring(content, parser)
    except library.XMLSyntaxError as exc:
        raise XmlInputError(
            "xml-malformed", "XML is malformed or unsupported."
        ) from exc
    result: list[XmlNode] = []
    pending: list[tuple[_Element, int | None]] = [(root, None)]
    # Preserve document order and genuine anchors without inventing closing spans.
    while pending:
        element, parent = pending.pop()
        if element.sourceline is None:
            raise XmlInputError("xml-anchor", "XML declaration has no source anchor.")
        index = len(result)
        result.append(
            XmlNode(
                tag=element.tag,
                attributes=tuple(sorted(element.attrib.items())),
                text=element.text or "",
                line=element.sourceline,
                parent=parent,
            )
        )
        # Reverse the stack insertion so the next element follows source order.
        pending.extend((child, index) for child in reversed(tuple(element)))
    return tuple(result)
