"""Select explicit lexical type contexts and inert MSBuild reference declarations.

Accepted token/XML parsers provide immutable source anchors. This module performs
no symbol resolution, build evaluation, execution, source reads or publication.
"""

from __future__ import annotations

from typing import TYPE_CHECKING

from drm_copilot_discovery.analyzer.csharp_tokens import SourceScanError
from drm_copilot_discovery.analyzer.xml_input import parse_xml

if TYPE_CHECKING:
    from collections.abc import Iterator

    from drm_copilot_discovery.analyzer.csharp_tokens import Token

_MSBUILD = "{http://schemas.microsoft.com/developer/msbuild/2003}"


def type_mentions(tokens: tuple[Token, ...], names: dict[str, int]) -> Iterator[Token]:
    """Yield literal terminal type tokens from explicit bounded C# contexts.

    tokens are already masked/bounded; names maps production spellings to counts.
    Returns an iterator without resolving aliases, generics or namespaces.
    SourceScanError rejects excessive tokens or aggregate lookahead; the adapter
    discards partial results. No caller mutation or raw expression capture occurs.
    """
    if len(tokens) > 100000 or len(names) > 100000:
        raise SourceScanError("analysis-work-limit", "Mention input limit")
    remaining = 4 * len(tokens)
    # A fixed context allowlist avoids variable names and arithmetic coincidences.
    for index, token in enumerate(tokens):
        if token.value not in {"new", "typeof", "default", "sizeof"} or (
            index and tokens[index - 1].value in {".", "::", "?."}
        ):
            continue
        position = index + 1
        if token.value != "new":
            if position >= len(tokens) or tokens[position].value != "(":
                continue
            position += 1
        if (
            position + 1 < len(tokens)
            and tokens[position].value == "global"
            and tokens[position + 1].value == "::"
        ):
            position += 2
        candidate: Token | None = None
        # Qualification is lexical only; every overlapping visit consumes work.
        while position < len(tokens) and tokens[position].identifier:
            remaining -= 1
            if remaining < 0:
                raise SourceScanError("analysis-work-limit", "Mention work limit")
            candidate = tokens[position]
            position += 1
            if position >= len(tokens) or tokens[position].value != ".":
                break
            candidate = None
            position += 1
        endings = {"(", "<", "["} if token.value == "new" else {")", "<", "[", "?"}
        if (
            candidate is not None
            and candidate.value in names
            and position < len(tokens)
            and tokens[position].value in endings
        ):
            yield candidate


def project_reference_sites(
    content: bytes, *, max_bytes: int, limit: int
) -> Iterator[tuple[str, int, int, str, str, bool]]:
    """Yield finite MSBuild declarations using the accepted secure XML parser.

    content (bytes), max_bytes (int,1..64MiB) and limit (int,1..100000) bound parsing.
    Tuples contain (safe target, parser line, ordinal, operation, target kind,
    condition). Raw expressions/conditions are withheld. ValueError rejects limits;
    XmlInputError/SourceScanError reject malformed selected input. No effects,
    import expansion, build evaluation or binding occurs.
    """
    if type(max_bytes) is not int or not 1 <= max_bytes <= 67108864:
        raise ValueError("Project byte limit must be an integer in 1..67108864")
    if type(limit) is not int or not 1 <= limit <= 100000:
        raise ValueError("Project node limit must be an integer in 1..100000")
    nodes = parse_xml(content, max_bytes=max_bytes, max_elements=limit)
    namespace = _MSBUILD if nodes[0].tag == _MSBUILD + "Project" else ""
    if nodes[0].tag != namespace + "Project":
        raise SourceScanError("project-reference-root", "Unsupported project root")
    conditional: list[bool] = []
    # Parent indexes make inherited condition presence linear without raw values.
    for ordinal, node in enumerate(nodes):
        condition = node.attribute("Condition") is not None or (
            node.parent is not None and conditional[node.parent]
        )
        conditional.append(condition)
        if node.tag != namespace + "ProjectReference" or node.parent is None:
            continue
        parent = nodes[node.parent]
        if parent.tag != namespace + "ItemGroup" or parent.parent != 0:
            continue
        # Include, Update and Remove describe operations; none establishes activation.
        operations = [
            (key.lower(), value)
            for key in ("Include", "Update", "Remove")
            if (value := node.attribute(key)) is not None
        ]
        if len(operations) != 1 or not operations[0][1].strip():
            raise SourceScanError("project-reference-declaration", "Invalid operation")
        operation, target = operations[0]
        # Expressions and wildcard activation are unknown; never emit their values.
        if any(char in target for char in "$@%;"):
            target_kind = "expression"
        # Wildcard declarations also withhold the unevaluated target expression.
        elif any(char in target for char in "*?"):
            target_kind = "wildcard"
        else:
            target_kind = "literal"
        safe = target if target_kind == "literal" else "unresolved-project-target"
        yield safe, node.line, ordinal, operation, target_kind, condition
