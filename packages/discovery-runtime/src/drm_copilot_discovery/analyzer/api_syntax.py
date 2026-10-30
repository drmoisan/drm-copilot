"""Recognize bounded fixed C# API spellings without symbol or runtime resolution."""

from __future__ import annotations

from dataclasses import dataclass
from typing import Literal, cast

from drm_copilot_discovery.analyzer.csharp_tokens import (
    SourceScanError,
    Token,
    tokenize_csharp,
)
from drm_copilot_discovery.analyzer.source_text import strip_comments_and_strings


@dataclass(frozen=True, kw_only=True)
class ApiSurface:
    """Hold a small immutable allowlist owned by a specific API adapter.

    identifier is a fixed analyzer ID; namespace contains qualified name parts.
    calls/properties contain (type, member) pairs; constructors contain types.
    Construction rejects oversized or nonidentifier definitions with ValueError.
    """

    identifier: str
    namespace: tuple[str, ...]
    calls: frozenset[tuple[str, str]] = frozenset()
    properties: frozenset[tuple[str, str]] = frozenset()
    constructors: frozenset[str] = frozenset()

    def __post_init__(self) -> None:
        """Validate fixed definition sizes/spellings; return None, without I/O.

        Uses declared immutable fields. ValueError rejects invalid definitions;
        no mutable collection or source-derived configuration is retained.
        """
        # Reject mutable rule collections before retaining any configured names.
        if not isinstance(cast("object", self.namespace), tuple) or any(
            not isinstance(cast("object", value), frozenset)
            for value in (self.calls, self.properties, self.constructors)
        ):
            raise ValueError("API definitions require immutable collections")
        if not 1 <= len(self.namespace) <= 4 or (
            len(self.calls) + len(self.properties) + len(self.constructors) > 128
        ):
            raise ValueError("API definitions exceed fixed bounds")
        names = self.namespace + tuple(self.constructors)
        # Bound configuration before flattening the fixed method/property pairs.
        for pair in self.calls | self.properties:
            if len(pair) != 2:
                raise ValueError("API members require type and member names")
            names += pair
        # Every emitted name must be a short literal identifier, never source data.
        if (
            any(
                not 1 <= len(name) <= 64
                or not name.isascii()
                or not name.isidentifier()
                for name in names + (self.identifier.replace("-", "_"),)
            )
            or self.calls & self.properties
        ):
            raise ValueError("API definitions require distinct literal identifiers")


@dataclass(frozen=True, kw_only=True)
class AccessSite:
    """Retain a fixed API name/form and physical decoded-character source anchor.

    api is canonical allowlisted spelling; operation is lexical syntax only.
    start/end are zero-based, end-exclusive offsets; line/end_line are one-based.
    Instances are created only after scanner record and token bounds pass.
    """

    api: str
    operation: Literal["invocation", "constructor", "property"]
    start: int
    end: int
    line: int
    end_line: int


def _balanced(tokens: tuple[Token, ...]) -> dict[int, int]:
    """Check delimiters once and return opening-to-closing parenthesis positions.

    tokens is the already bounded immutable lexical stream. No source text is
    retained or evaluated; incomplete syntax fails before any candidate is built.
    SourceScanError rejects mismatches; returned int indexes avoid suffix rescans.
    """
    stack: list[tuple[str, int]] = []
    parentheses: dict[int, int] = {}
    closing = {")": "(", "]": "[", "}": "{"}
    # Each delimiter is pushed/popped at most once, with no suffix rescans.
    for index, token in enumerate(tokens):
        # Validate nesting before retaining a pair for declaration discrimination.
        if token.value in {"(", "[", "{"}:
            stack.append((token.value, index))
        elif token.value in closing:
            if not stack or stack[-1][0] != closing[token.value]:
                raise SourceScanError("source-delimiter", "Source delimiters mismatch")
            opening, start = stack.pop()
            if opening == "(":
                parentheses[start] = index
    if stack:
        raise SourceScanError("source-delimiter", "Source delimiters are incomplete")
    return parentheses


def _recognize(
    parts: list[Token], surface: ApiSurface, *, constructor: bool, follows: str
) -> tuple[Literal["invocation", "constructor", "property"], int] | None:
    """Match a bounded literal chain against surface; return form/leaf index.

    parts has at most eight Token values; constructor marks a preceding new token;
    follows is the next token spelling or empty. Returns None for unsupported
    spellings/qualification. No alias, receiver or compiler binding is performed.
    """
    # Verbatim identifiers have ordinary spelling; Unicode escapes stay unresolved.
    names = tuple(part.value.removeprefix("@") for part in parts)
    offset = 1 if parts[0].value == "global" else 0
    if names[offset : offset + len(surface.namespace)] == surface.namespace:
        offset += len(surface.namespace)
    elif offset:
        return None
    remaining = names[offset:]
    if constructor:
        if (
            len(remaining) == 1
            and remaining[0] in surface.constructors
            and follows == "("
        ):
            return "constructor", offset
        return None
    if len(remaining) < 2:
        return None
    pair = remaining[0], remaining[1]
    if len(remaining) == 2 and pair in surface.calls and follows == "(":
        return "invocation", offset + 1
    # A known property may be the root of a longer, unresolved member chain.
    if pair in surface.properties and (
        len(remaining) > 2
        or follows
        in {
            "",
            ";",
            ",",
            ")",
            "]",
            "}",
            ".",
            "?.",
            "[",
            "=",
            "==",
            "!=",
            "??",
            "?",
            ":",
        }
    ):
        return "property", offset + 1
    return None


def access_sites(
    text: str, surface: ApiSurface, *, max_tokens: int = 100000, max_sites: int = 100000
) -> tuple[AccessSite, ...]:
    """Return bounded fixed-name candidates from C# text and immutable surface.

    max_tokens (int, 1..100000) and max_sites (int, 0..100000) bound tokens/records.
    Both capacities require exact int values; bool and fractional values fail.
    Text has at most 67108864 decoded characters, checked before allocating masks.
    Comments, string/interpolation contents and directives cannot create evidence.
    SourceScanError reports size/token/delimiter/record limits without partial
    success. Explicit member bodies are declarations, not invocation candidates.
    Traversal is linear in token count; at most eight names are retained per chain.
    No I/O, source evaluation or argument collection occurs.
    """
    if type(cast("object", max_sites)) is not int or not 0 <= max_sites <= 100000:
        raise SourceScanError("source-record-limit", "Invalid candidate record limit")
    if type(cast("object", max_tokens)) is not int or not 1 <= max_tokens <= 100000:
        raise SourceScanError("source-token-limit", "Invalid token limit")
    if len(text) > 67108864:
        raise SourceScanError("source-limit", "C# text exceeds its character limit")
    tokens = tokenize_csharp(strip_comments_and_strings(text), max_tokens=max_tokens)
    parentheses = _balanced(tokens)
    sites: list[AccessSite] = []
    index = 0
    # Consume every maximal dotted chain once, including overlong rejected chains.
    while index < len(tokens):
        start = index
        token = tokens[index]
        index += 1
        if not token.identifier:
            continue
        if token.value == "namespace" or (
            token.value == "using"
            and index < len(tokens)
            and (
                tokens[index].value == "static"
                or (index + 1 < len(tokens) and tokens[index + 1].value == "=")
            )
        ):
            # Skip declaration-only names without repeatedly scanning their suffix.
            while index < len(tokens) and tokens[index].value not in {";", "{"}:
                index += 1
            continue
        parts = [token]
        valid = start == 0 or tokens[start - 1].value not in {".", "?.", "::"}
        # Retain at most eight fixed prefix names, regardless of chain length.
        while (
            index + 1 < len(tokens)
            and tokens[index].value in {".", "::", "?."}
            and tokens[index + 1].identifier
        ):
            separator = tokens[index].value
            valid &= separator == (
                "::" if len(parts) == 1 and token.value == "global" else "."
            )
            if len(parts) < 8:
                parts.append(tokens[index + 1])
            else:
                valid = False
            index += 2
        if not valid:
            continue
        constructor = start > 0 and tokens[start - 1].value == "new"
        matched = _recognize(
            parts,
            surface,
            constructor=constructor,
            follows=tokens[index].value if index < len(tokens) else "",
        )
        if matched is None:
            continue
        operation, leaf = matched
        # Paired delimiters distinguish method bodies without rescanning arguments.
        if operation == "invocation":
            after = parentheses[index] + 1
            if after < len(tokens) and tokens[after].value in {"{", "=>"}:
                continue
        if len(sites) >= max_sites:
            raise SourceScanError(
                "source-record-limit", "Candidate record limit exceeded"
            )
        first = tokens[start - 1] if constructor else token
        # All emitted name parts originate in the finite adapter allowlist.
        api = ".".join(
            (
                *surface.namespace,
                *tuple(
                    part.value.removeprefix("@")
                    for part in parts[leaf - (operation != "constructor") : leaf + 1]
                ),
            )
        )
        sites.append(
            AccessSite(
                api=api,
                operation=operation,
                start=first.start,
                end=parts[leaf].end,
                line=first.line,
                end_line=parts[leaf].line,
            )
        )
    return tuple(sites)
