"""Extract lexical C# declarations and explicitly inferred member candidates.

This bounded text scanner does not evaluate preprocessing, resolve namespaces,
bind types, or establish runtime behavior. Literal spellings are never normalized.
"""

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

_TYPE_WORDS = frozenset({"class", "struct", "interface", "enum", "record"})
_MODIFIERS = frozenset(
    (
        "public private protected internal static sealed abstract partial readonly "
        "ref unsafe new virtual override file extern async required "
        "const volatile fixed"
    ).split()
)


class _ScanWork:
    """Bound aggregate lookahead across one declaration scan without external I/O.

    Construct once from the token count and share with every prefix helper.
    remaining tracks deterministic token visits; consume rejects excessive work
    before another traversal or slice. Only this private counter is mutated.
    """

    def __init__(self, token_count: int) -> None:
        """Initialize a linear budget from nonnegative int token_count; return None."""
        self.remaining = max(32, token_count * 4)

    def consume(self, count: int = 1) -> None:
        """Charge nonnegative int count token visits; return None, mutate counter.

        Raises SourceScanError before exceeding the aggregate traversal budget.
        """
        if count > self.remaining:
            raise SourceScanError(
                "source-work-limit", "C# declaration scan limit exceeded."
            )
        self.remaining -= count


def _detection(
    path: str,
    anchor: Token,
    name: Token,
    kind: str,
    symbol_kind: str,
    extra: tuple[tuple[str, str | int], ...] = (),
) -> Detection:
    """Return immutable lexical Detection with actual offsets; no I/O or mutation.

    path (str), anchor/name (Token), kind/symbol_kind (str) and extra (metadata
    pairs) describe observed text. Offsets refer to decoded characters; the line
    span ends at the observed name, not the complete declaration body.
    """
    return Detection(
        path,
        anchor.line,
        kind,
        name.value,
        symbol_kind,
        (*extra, ("offset", anchor.start), ("end_line", name.line)),
    )


def _generic(
    tokens: tuple[Token, ...], position: int, work: _ScanWork
) -> tuple[int, int]:
    """Return (arity, end index) after optional generic parameters, without I/O.

    tokens (tuple[Token,...]) and position (int) identify the token after a name.
    work (_ScanWork) charges shared token visits. SourceScanError rejects an
    unterminated list or exhausted budget. Only the private counter is mutated;
    nested type/attribute syntax is counted without semantic evaluation.
    """
    if position >= len(tokens) or tokens[position].value != "<":
        return 0, position
    depth = 0
    arity = 1
    start = position
    # Only outer commas divide parameters; nested generic arguments do not.
    while position < len(tokens):
        work.consume()
        value = tokens[position].value
        if value == "<":
            depth += 1
        elif value == ">":
            depth -= 1
            if depth == 0:
                return (0 if position == start + 1 else arity), position + 1
        elif value == "," and depth == 1:
            arity += 1
        position += 1
    raise SourceScanError("source-declaration", "Unterminated generic declaration.")


def _namespace(
    path: str, tokens: tuple[Token, ...], index: int, work: _ScanWork
) -> Detection | None:
    """Read a literal dotted namespace after int index in immutable tokens.

    path (str) supplies provenance. Returns Detection or None for a nonmatching
    fragment; namespace scope/alias qualification remains unresolved. work
    (_ScanWork) is charged or raises SourceScanError; no caller data is mutated.
    """
    position = index + 1
    names: list[Token] = []
    # Alternate names and dots; whitespace and physical lines are already retained.
    while position < len(tokens) and tokens[position].identifier:
        work.consume()
        names.append(tokens[position])
        position += 1
        if position >= len(tokens) or tokens[position].value != ".":
            break
        position += 1
    if not names:
        return None
    form = (
        "file_scoped"
        if position < len(tokens) and tokens[position].value == ";"
        else "block"
    )
    result = _detection(
        path,
        tokens[index],
        names[-1],
        "namespace",
        "namespace",
        (("declaration_form", form),),
    )
    # Keep dotted namespace spelling without claiming resolved qualification.
    return Detection(
        result.path,
        result.line,
        result.detection_kind,
        ".".join(name.value for name in names),
        result.symbol_kind,
        result.extra,
    )


def _type(
    path: str, tokens: tuple[Token, ...], index: int, work: _ScanWork
) -> Detection | None:
    """Read type/record name and generic arity from typed tokens; no I/O.

    path (str) and index (int) anchor a known type keyword. Returns Detection or
    None; work (_ScanWork) charges lookahead. SourceScanError rejects an
    unterminated generic declaration or exhausted budget; only work is mutated.
    """
    kind = tokens[index].value
    position = index + 1
    # Contextual record can be an ordinary variable/type name in executable text.
    if kind == "record" and (
        index and tokens[index - 1].value not in {"{", "}", ";", "]", *_MODIFIERS}
    ):
        return None
    if (
        kind == "record"
        and position < len(tokens)
        and tokens[position].value in {"class", "struct"}
    ):
        kind = "record_struct" if tokens[position].value == "struct" else "record"
        position += 1
    if position >= len(tokens) or not tokens[position].identifier:
        return None
    arity, end = _generic(tokens, position + 1, work)
    # A contextual keyword needs an observed declaration header after its name.
    if kind in {"record", "record_struct"} and (
        end >= len(tokens) or tokens[end].value not in {"(", "{", ":", ";", "where"}
    ):
        return None
    extra: tuple[tuple[str, str | int], ...] = (("generic", arity),) if arity else ()
    return _detection(path, tokens[index], tokens[position], "type", kind, extra)


def _callable_name(
    tokens: tuple[Token, ...], start: int, end: int, work: _ScanWork
) -> Token | None:
    """Select the literal name before a signature boundary with bounded lookahead.

    tokens (tuple[Token,...]), start/end (int) bound a declaration prefix. Returns
    Token or None; skips generic parameters without resolving their types. work
    (_ScanWork) is charged; SourceScanError rejects excess aggregate lookahead.
    """
    position = end - 1
    depth = 0
    # Generic suffixes belong to the name before '<', not the final parameter.
    while position >= start:
        work.consume()
        value = tokens[position].value
        if value == ">":
            depth += 1
        elif value == "<" and depth:
            depth -= 1
        elif depth == 0:
            return tokens[position] if tokens[position].identifier else None
        position -= 1
    return None


def _event_or_delegate(
    path: str, tokens: tuple[Token, ...], index: int, work: _ScanWork
) -> Detection | None:
    """Extract an event/delegate declaration name from bounded lexical tokens.

    path (str), tokens (tuple[Token,...]) and index (int) identify its keyword.
    Returns Detection or None; anonymous delegates/function pointers are omitted.
    work (_ScanWork) is charged; SourceScanError rejects excessive traversal.
    No type binding, scope inference, I/O or caller-data mutation is performed.
    """
    keyword = tokens[index].value
    # Anonymous delegate bodies/signatures and pointers have no declared name.
    if keyword == "delegate" and (
        index + 1 >= len(tokens) or tokens[index + 1].value in {"*", "{", "("}
    ):
        return None
    stop = {";", "=", "{"} if keyword == "event" else {"("}
    position = index + 1
    depth = 0
    # Generic commas and type punctuation remain part of the declaration prefix.
    while position < len(tokens):
        work.consume()
        value = tokens[position].value
        if depth == 0 and (value in stop or value in {"{", "}", ";"}):
            break
        if value == "<":
            depth += 1
        elif value == ">":
            depth -= 1
        position += 1
    name = _callable_name(tokens, index + 1, position, work)
    if name is None or name.start == tokens[index + 1].start:
        return None
    kind = "event_declaration" if keyword == "event" else "delegate"
    return _detection(path, tokens[index], name, kind, keyword)


def _member(
    path: str,
    tokens: tuple[Token, ...],
    start: int,
    end: int,
    declaring_type: str,
    boundary: str,
    work: _ScanWork,
) -> Detection | None:
    """Infer a directly enclosed member from a bounded declaration prefix.

    path/type/boundary (str), tokens (tuple[Token,...]) and start/end (int) retain
    lexical placement. Returns Detection or None. Attributes/modifiers are
    omitted; complex operators/indexers and initializers are not bound. work
    (_ScanWork) charges name lookahead or raises SourceScanError; no external I/O.
    """
    # Remove attribute brackets before interpreting punctuation in a member prefix.
    depth = 0
    prefix: list[Token] = []
    # Discard attribute payloads so their arguments cannot become member names.
    for token in tokens[start:end]:
        if token.value == "[":
            depth += 1
        elif token.value == "]":
            depth = max(0, depth - 1)
        elif depth == 0:
            prefix.append(token)
    # Reject executable/unsupported prefixes before inferring declaration syntax.
    if not prefix or any(
        token.value in {"=", "=>", "(", "event", "delegate", "operator", *_TYPE_WORDS}
        for token in prefix
    ):
        return None
    name = _callable_name(tuple(prefix), 0, len(prefix), work)
    if name is None:
        return None
    # A return/type prefix must precede the member name, except for constructors.
    has_type = any(
        token.identifier and token.value not in _MODIFIERS and token.start < name.start
        for token in prefix
    )
    constructor = boundary == "(" and name.value == declaring_type
    if not constructor and not has_type:
        return None
    form = (
        "constructor"
        if constructor
        else {"(": "method", "{": "property", "=>": "property"}.get(boundary, "field")
    )
    return _detection(
        path,
        prefix[0],
        name,
        "member",
        form,
        (("declaring_type", declaring_type), ("binding", "unresolved")),
    )


def _members(
    path: str, tokens: tuple[Token, ...], types: dict[int, str], work: _ScanWork
) -> list[Detection]:
    """Infer member candidates only inside directly enclosing lexical type braces.

    path (str), immutable tokens and types (keyword-offset/name mapping) originate
    from one masked text. Returns list[Detection]. Does not resolve conditional
    compilation or malformed grammar; every result stays inferred and unbound.
    work (_ScanWork) bounds prefix allocation or raises SourceScanError; no I/O.
    """
    scopes: list[str | None] = []
    pending: str | None = None
    start = 0
    square = 0
    result: list[Detection] = []
    # Brace placement prevents ordinary method-local declarations becoming members.
    for index, token in enumerate(tokens):
        value = token.value
        if token.start in types:
            pending = types[token.start]
        if value == "[":
            square += 1
        elif value == "]":
            square = max(0, square - 1)
        if (
            scopes
            and scopes[-1] is not None
            and pending is None
            and square == 0
            and value in {"(", "{", ";", "=", "=>"}
        ):
            work.consume(index - start)
            member = _member(path, tokens, start, index, scopes[-1], value, work)
            if member is not None:
                result.append(member)
        # New type bodies consume their pending declaration; other blocks hide locals.
        if value == "{":
            scopes.append(pending)
            pending = None
            start = index + 1
        elif value == "}":
            if scopes:
                scopes.pop()
            start = index + 1
        elif value == ";":
            pending = None
            start = index + 1
    return result


def declaration_candidates(
    path: str, text: str, *, include_members: bool = True, max_tokens: int = 100000
) -> tuple[Detection, ...]:
    """Return ordered lexical declarations and optional inferred member candidates.

    path/text (str) are captured source identity/text; include_members (bool) keeps
    the legacy catalog stable when false. max_tokens (int) bounds tokenization.
    Raises ValueError/SourceScanError for invalid limits/text. No I/O, namespace
    binding, preprocessor evaluation or runtime/behavior claims are performed.
    """
    tokens = tokenize_csharp(strip_comments_and_strings(text), max_tokens=max_tokens)
    work = _ScanWork(len(tokens))
    result: list[Detection] = []
    types: dict[int, str] = {}
    # Inspect every textual declaration, including multiline and same-line forms.
    for index, token in enumerate(tokens):
        previous = tokens[index - 1].value if index else ""
        if previous in {".", "?.", "::", ":", "record"}:
            continue
        if token.value == "namespace":
            candidate = _namespace(path, tokens, index, work)
        elif token.value in _TYPE_WORDS:
            candidate = _type(path, tokens, index, work)
        elif token.value in {"event", "delegate"}:
            candidate = _event_or_delegate(path, tokens, index, work)
        else:
            continue
        if candidate is not None:
            result.append(candidate)
            if candidate.detection_kind == "type":
                types[token.start] = candidate.symbol
    if include_members:
        result.extend(_members(path, tokens, types, work))
    return tuple(
        sorted(
            result,
            key=lambda candidate: (
                candidate.line,
                dict(candidate.extra)["offset"],
                candidate.detection_kind,
            ),
        )
    )
