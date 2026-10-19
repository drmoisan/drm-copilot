"""Infer possible C# handler subscriptions from bounded lexical assignments.

The assignment operator is detected syntax; event binding and handler identity
remain unresolved. Arithmetic with identifier operands remains an explicit risk.
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


def _left(tokens: tuple[Token, ...], index: int) -> tuple[Token, ...]:
    """Return a literal qualified assignment target before int index; pure.

    tokens (tuple[Token,...]) are masked source tokens. Returns a token tuple or
    empty for unsupported indexer/expression targets; no symbol binding occurs.
    """
    start = index - 1
    if start < 0 or not tokens[start].identifier:
        return ()
    # Walk only dotted or alias-qualified names, never arbitrary expressions.
    while (
        start >= 2
        and tokens[start - 1].value in {".", "?.", "::"}
        and tokens[start - 2].identifier
    ):
        start -= 2
    return tokens[start:index]


def _right(
    tokens: tuple[Token, ...], index: int, budget: int
) -> tuple[tuple[Token, ...], int]:
    """Return RHS tokens through the top-level semicolon after int index; pure.

    tokens (tuple[Token,...]) are immutable; budget (int) bounds remaining work.
    Returns (RHS tuple, visited count), with an empty RHS
    for incomplete/unbalanced expressions; nested lambda bodies may contain
    semicolons. SourceScanError rejects budget exhaustion. No evaluation occurs.
    """
    start = index + 1
    closing: list[str] = []
    # Delimiter matching retains block lambdas without consuming later statements.
    for position in range(start, len(tokens)):
        if position - start >= budget:
            raise SourceScanError(
                "source-work-limit", "C# assignment scan limit exceeded."
            )
        value = tokens[position].value
        if value == ";" and not closing:
            return tokens[start:position], position - start + 1
        if value in {"(", "[", "{"}:
            closing.append({"(": ")", "[": "]", "{": "}"}[value])
        elif value in {")", "]", "}"}:
            if not closing or closing.pop() != value:
                return (), position - start + 1
    return (), len(tokens) - start


def _handler(tokens: tuple[Token, ...]) -> bool:
    """Classify a possible handler expression without resolving its type; pure.

    tokens (tuple[Token,...]) is a complete RHS. Returns bool; identifier/member
    operands remain ambiguous arithmetic. Literals and arithmetic expressions are
    omitted; lambdas, construction and anonymous delegates remain inferred.
    """
    if not tokens:
        return False
    # Lambda and construction syntax is only candidate evidence, never event proof.
    if any(token.value == "=>" for token in tokens) or tokens[0].value in {
        "new",
        "delegate",
    }:
        return True
    if not tokens[0].identifier or not tokens[-1].identifier:
        return False
    # An alternating name/separator sequence remains an ambiguous method group.
    return all(
        token.identifier if index % 2 == 0 else token.value in {".", "?.", "::"}
        for index, token in enumerate(tokens)
    )


def subscription_candidates(
    path: str, text: str, *, max_tokens: int = 100000
) -> tuple[Detection, ...]:
    """Return ordered inferred subscription/unsubscription Detection values.

    path/text (str) identify retained source; max_tokens (int) bounds allocation.
    Raises ValueError/SourceScanError for malformed text or limits. Legacy metadata
    keeps confidence='heuristic'; v2 projection must use its schema confidence and
    classification='inferred'. No I/O, runtime claims or type binding occurs.
    """
    tokens = tokenize_csharp(strip_comments_and_strings(text), max_tokens=max_tokens)
    result: list[Detection] = []
    budget = max(32, len(tokens) * 4)
    # Each assignment receives its own offset so identical same-line sites survive.
    for index, token in enumerate(tokens):
        if token.value not in {"+=", "-="}:
            continue
        left = _left(tokens, index)
        right, visited = _right(tokens, index, budget)
        budget -= visited
        if not left or not _handler(right):
            continue
        # Retain literal target/RHS spelling and offsets for unresolved relationships.
        result.append(
            Detection(
                path,
                left[0].line,
                "event_subscription",
                "".join(part.value for part in left),
                "event",
                (
                    ("operator", token.value),
                    ("confidence", "heuristic"),
                    ("offset", left[0].start),
                    ("end_line", right[-1].line),
                    ("handler", " ".join(part.value for part in right)),
                    ("binding", "unresolved"),
                ),
            )
        )
    return tuple(result)
