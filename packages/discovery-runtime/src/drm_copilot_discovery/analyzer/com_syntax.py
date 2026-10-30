"""Recognize bounded generic COM syntax without compiler binding or I/O."""

from __future__ import annotations

from drm_copilot_discovery.analyzer.csharp_tokens import (
    SourceScanError,
    Token,
    tokenize_csharp,
)
from drm_copilot_discovery.analyzer.source_text import (
    Detection,
    strip_comments_and_strings,
)

_ATTRIBUTES = frozenset(
    "ComImport ComVisible InterfaceType ClassInterface ComDefaultInterface "
    "ComSourceInterfaces CoClass ComEventInterface DispId TypeLibType "
    "TypeLibFunc TypeLibVar LCIDConversion ComConversionLoss".split()
)
_INTEROP = "System.Runtime.InteropServices"
_CALLS = {
    "Type.GetTypeFromProgID": ("System", "com_type_lookup"),
    "Type.GetTypeFromCLSID": ("System", "com_type_lookup"),
    "Activator.CreateComInstanceFrom": ("System", "com_activation"),
    "Marshal.BindToMoniker": (_INTEROP, "com_activation"),
    "Marshal.GetActiveObject": (_INTEROP, "com_object_lookup"),
    "Marshal.ReleaseComObject": (_INTEROP, "com_lifetime_call"),
    "Marshal.FinalReleaseComObject": (_INTEROP, "com_lifetime_call"),
    "Marshal.GetIUnknownForObject": (_INTEROP, "marshal_call"),
    "Marshal.GetIDispatchForObject": (_INTEROP, "marshal_call"),
    "Marshal.GetComInterfaceForObject": (_INTEROP, "marshal_call"),
    "Marshal.GetObjectForIUnknown": (_INTEROP, "marshal_call"),
    "Marshal.IsComObject": (_INTEROP, "marshal_call"),
    "Marshal.QueryInterface": (_INTEROP, "marshal_call"),
}


def _qualified(tokens: tuple[Token, ...], start: int) -> tuple[str, int]:
    """Return literal name and exclusive token end from tokens at int start; pure.

    The caller supplies an identifier token. Dot/alias separators are retained;
    no normalization or symbol binding occurs. Invalid indexes raise IndexError.
    """
    end = start + 1
    # Consume each qualified chain once; do not reinterpret its suffix as a type.
    while (
        end + 1 < len(tokens)
        and tokens[end].value in {".", "::"}
        and tokens[end + 1].identifier
    ):
        end += 2
    # Retain exact qualified spelling so aliases cannot become known framework types.
    return "".join(token.value for token in tokens[start:end]), end


def _kind(name: str, *, attribute: bool) -> str | None:
    """Return a fixed candidate kind for str name in the declared syntax context.

    attribute (bool) selects attributes versus calls. Only known short or framework
    qualified spellings match; aliases/Unicode escapes stay unresolved. No I/O.
    """
    name = name.removeprefix("global::")
    # Attribute presence is a candidate even when its argument disables exposure.
    if attribute:
        short = name.removeprefix(_INTEROP + ".")
        return (
            "com_attribute" if short.removesuffix("Attribute") in _ATTRIBUTES else None
        )
    # Exact known API owners prevent arbitrary Marshal/Activator members matching.
    for member, (namespace, kind) in _CALLS.items():
        if name in {member, namespace + "." + member}:
            return kind
    return None


def _delimiter_ends(tokens: tuple[Token, ...]) -> dict[int, int]:
    """Index each balanced opening delimiter in bounded tokens; return end indexes.

    tokens is the immutable Token tuple from the public tokenizer. SourceScanError
    rejects mismatched/unclosed delimiters before any candidate allocation. The
    local stack/map use at most token-count space; no input mutation or I/O occurs.
    """
    stack: list[tuple[str, int]] = []
    ends: dict[int, int] = {}
    closing = {")": "(", "]": "[", "}": "{"}
    # Pair each delimiter once, so later context checks never rescan nested suffixes.
    for index, token in enumerate(tokens):
        if token.value in {"(", "[", "{"}:
            stack.append((token.value, index))
        elif token.value in closing:
            if not stack or stack[-1][0] != closing[token.value]:
                raise SourceScanError(
                    "source-delimiter", "COM source has unmatched delimiters."
                )
            ends[stack.pop()[1]] = index
    if stack:
        raise SourceScanError("source-delimiter", "COM source has unclosed delimiters.")
    return ends


def _attribute_sections(
    tokens: tuple[Token, ...], ends: dict[int, int]
) -> dict[int, bool]:
    """Classify bracket continuations in bounded tokens using prevalidated ends.

    Return opening-index/bool entries for brackets. Consecutive attribute sections
    reuse the next section's result; declaration names and explicit assembly/module
    targets qualify, while expression operators and argument terminators do not.
    KeyError indicates an invalid internal delimiter index. No I/O/input mutation.
    """
    sections: dict[int, bool] = {}
    # Right-to-left propagation resolves attribute chains in linear total work.
    for index in range(len(tokens) - 1, -1, -1):
        if tokens[index].value != "[":
            continue
        after = ends[index] + 1
        following = tokens[after].value if after < len(tokens) else ""
        target = (
            index + 2 < len(tokens)
            and tokens[index + 1].value in {"assembly", "module"}
            and tokens[index + 2].value == ":"
        )
        # Adjacent sections inherit declaration context; parentheses need a lambda.
        if following == "[":
            continuation = sections[after]
        elif following == "(":
            end = ends[after] + 1
            continuation = end < len(tokens) and tokens[end].value == "=>"
        else:
            continuation = (
                after < len(tokens)
                and tokens[after].identifier
                and following not in {"is", "as", "switch", "with", "and", "or"}
            )
        sections[index] = target or continuation
    return sections


def _method_declaration(
    tokens: tuple[Token, ...], opening: int, ends: dict[int, int]
) -> bool:
    """Reject a body/arrow after a known parenthesized name; return bool, pure.

    tokens/ends are the bounded validated stream/index, and opening is its int
    parameter-list opening. KeyError denotes an invalid internal index. Only the
    immediate continuation is examined; nested invocation arguments are untouched.
    """
    after = ends[opening] + 1
    return after < len(tokens) and tokens[after].value in {"{", "=>"}


def com_source_candidates(
    path: str, text: str, *, max_tokens: int = 100000, max_candidates: int = 100000
) -> tuple[Detection, ...]:
    """Return ordered COM syntax candidates from str path/text without I/O.

    max_tokens/max_candidates (int, default 100000) bound token and result counts.
    Zero candidate capacity is permitted for proving that no findings exist. Invalid
    limits raise ValueError; SourceScanError rejects input, delimiters or limits.
    Attributes require a declaration continuation; calls exclude method bodies.
    Binding, aliases, preprocessing and generic calls remain unresolved. Delimiter
    indexing and attribute-chain propagation each visit the bounded tokens once.
    Every candidate is inferred; GUID/argument text is neither searched nor copied.
    """
    if type(max_candidates) is not int or not 0 <= max_candidates <= 100000:
        raise ValueError("COM candidate limit must be between 0 and 100000")
    if len(text) > 67108864:
        raise SourceScanError("source-limit", "COM source exceeds its text limit.")
    tokens = tokenize_csharp(strip_comments_and_strings(text), max_tokens=max_tokens)
    ends = _delimiter_ends(tokens)
    sections = _attribute_sections(tokens, ends)
    results: list[Detection] = []
    nesting: list[tuple[str, bool]] = []
    index = 0
    # Advance over tokens/chains once; bracket context excludes ordinary indexers.
    while index < len(tokens):
        token = tokens[index]
        previous = tokens[index - 1].value if index else ""
        # Only delimiter state changes here; source expressions are never evaluated.
        if token.value in {"[", "(", "{"}:
            attribute = sections.get(index, False) and previous in {
                "",
                "]",
                "{",
                "}",
                ";",
                "(",
                ",",
            }
            nesting.append(({"[": "]", "(": ")", "{": "}"}[token.value], attribute))
        elif token.value in {"]", ")", "}"}:
            nesting.pop()
        # Match a complete name only after establishing attribute or call context.
        elif token.identifier and previous not in {".", "::", "?."}:
            name, end = _qualified(tokens, index)
            following = tokens[end].value if end < len(tokens) else ""
            attribute = bool(
                nesting and nesting[-1] == ("]", True) and previous in {"[", ",", ":"}
            )
            kind = (
                _kind(name, attribute=attribute)
                if following in ({"(", ",", "]"} if attribute else {"("})
                and (attribute or not _method_declaration(tokens, end, ends))
                else None
            )
            if kind is not None:
                if len(results) >= max_candidates:
                    raise SourceScanError(
                        "com-candidate-limit", "COM candidates exceed their limit."
                    )
                results.append(
                    Detection(
                        path,
                        token.line,
                        kind,
                        name,
                        "attribute" if attribute else "call",
                        (
                            ("offset", token.start),
                            ("end_offset", tokens[end - 1].end),
                            ("end_line", tokens[end - 1].line),
                            ("binding", "unresolved"),
                        ),
                    )
                )
            index = end
            continue
        index += 1
    return tuple(results)
