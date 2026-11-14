"""Source normalization, parsing, spans and literal strings for the native analyzers.

Line numbers follow the 1020 declaration-lines digest (D5) steps 1 to 3: one leading
U+FEFF is removed, CRLF and then CR become LF, and the text is split on LF only, so
every reported line number is a line number of the canonical text that PowerShell
digests.
"""

from __future__ import annotations

import ast
import io
import tokenize
import warnings
from dataclasses import dataclass, field
from typing import TYPE_CHECKING

if TYPE_CHECKING:
    from collections.abc import Callable

PARSE_OK = "ok"
PARSE_ERROR = "parse-error"

_BOM = chr(0xFEFF)
_OPENERS = frozenset({"(", "[", "{"})
_CLOSERS = frozenset({")", "]", "}"})
_PARSE_FAILURES = (SyntaxError, ValueError, RecursionError, MemoryError)
_TOKENIZE_FAILURES = (tokenize.TokenError, SyntaxError, ValueError, RecursionError)


def normalize_source(text: str) -> str:
    """Return the canonical text of one request file.

    Args:
        text: The file text as sent by the PowerShell adapter.

    Returns:
        The text with one leading U+FEFF removed and CRLF, then CR, mapped to LF. No
        other character is treated as a line break.
    """
    if text.startswith(_BOM):
        text = text[1:]
    return text.replace("\r\n", "\n").replace("\r", "\n")


def source_lines(text: str) -> list[str]:
    """Return the 1020 numbered lines of a normalized text.

    Args:
        text: A text already passed through normalize_source.

    Returns:
        The lines split on LF after one trailing LF is removed; an empty text has no
        lines.
    """
    if text.endswith("\n"):
        text = text[:-1]
    if text == "":
        return []
    return text.split("\n")


@dataclass(frozen=True)
class ParsedModule:
    """One parsed request file: status, syntax tree, canonical lines and tokens.

    Built only by parse_module. A file that fails to parse or tokenize carries status
    PARSE_ERROR, no tree and no tokens, and the adapter uses the scanner for it.

    Attributes:
        status: PARSE_OK or PARSE_ERROR.
        tree: The ast.Module of the text, or None on a parse failure.
        lines: The canonical numbered lines (source_lines of the text).
        tokens: The significant tokens (no comments, newlines, indents or end marker),
            used to locate decorator '@' lines and header-ending colons.
    """

    status: str
    tree: ast.Module | None
    lines: tuple[str, ...]
    tokens: tuple[tokenize.TokenInfo, ...] = field(default=())


def _significant_tokens(text: str) -> tuple[tokenize.TokenInfo, ...]:
    """Return the tokens of a text that carry syntax.

    Args:
        text: A normalized source text.

    Returns:
        Every token except comments, newlines, indents, dedents and the end marker.

    Raises:
        tokenize.TokenError: The text cannot be tokenized (handled by parse_module).
    """
    skipped = {
        tokenize.COMMENT,
        tokenize.NL,
        tokenize.NEWLINE,
        tokenize.INDENT,
        tokenize.DEDENT,
        tokenize.ENDMARKER,
    }
    reader = io.StringIO(text).readline
    # Keep only tokens that carry syntax; layout tokens would shift index lookups.
    return tuple(t for t in tokenize.generate_tokens(reader) if t.type not in skipped)


def parse_module(
    text: str, *, parser: Callable[[str], ast.Module] = ast.parse
) -> ParsedModule:
    """Parse a normalized text without executing or compiling it to code.

    Warnings (for example invalid escape sequences) are suppressed so that standard
    error stays empty.

    Args:
        text: A normalized source text.
        parser: The parse function; tests inject failures through it. Production uses
            ast.parse, the helper's only parse entry.

    Returns:
        A ParsedModule with status PARSE_OK, or PARSE_ERROR with no tree when the
        parser raises SyntaxError, ValueError, RecursionError or MemoryError or the
        text cannot be tokenized.
    """
    lines = tuple(source_lines(text))
    with warnings.catch_warnings():
        warnings.simplefilter("ignore")
        try:
            tree = parser(text)
        except _PARSE_FAILURES:
            return ParsedModule(PARSE_ERROR, None, lines)
        try:
            tokens = _significant_tokens(text)
        except _TOKENIZE_FAILURES:
            return ParsedModule(PARSE_ERROR, None, lines)
    return ParsedModule(PARSE_OK, tree, lines, tokens)


def _token_index_at(parsed: ParsedModule, line: int, column: int) -> int:
    """Return the index of the first significant token at or after a position.

    Args:
        parsed: The parsed module whose tokens are searched.
        line: The one-based line of the position.
        column: The zero-based column of the position.

    Returns:
        The token index, or the token count when no token follows the position.
    """
    # Scan in document order; the first token at or past the position is the answer.
    for index, token in enumerate(parsed.tokens):
        if token.start >= (line, column):
            return index
    return len(parsed.tokens)


def statement_span(node: ast.stmt) -> tuple[int, int]:
    """Return the first and last line of a statement.

    Args:
        node: Any statement node.

    Returns:
        (first line, last line); the last line falls back to the first when absent.
    """
    end = node.end_lineno if node.end_lineno is not None else node.lineno
    return (node.lineno, end)


def node_span(node: ast.expr | ast.stmt | ast.arg) -> tuple[int, int]:
    """Return the first and last line of an expression, statement or argument.

    Args:
        node: The node to measure.

    Returns:
        (first line, last line); the last line falls back to the first when absent.
    """
    end = node.end_lineno if node.end_lineno is not None else node.lineno
    return (node.lineno, end)


def decorator_line(parsed: ParsedModule, decorator: ast.expr) -> int:
    """Return the line of the '@' token that introduces a decorator expression.

    The expression can start on a later line than its '@' (a parenthesized decorator),
    so the token stream is searched backwards from the expression start.

    Args:
        parsed: The parsed module that holds the decorator.
        decorator: One element of a decorator_list.

    Returns:
        The '@' line, or the expression line when no '@' precedes it.
    """
    index = _token_index_at(parsed, decorator.lineno, decorator.col_offset)
    # Walk back from the expression to the nearest '@' operator.
    for back in range(index - 1, -1, -1):
        token = parsed.tokens[back]
        if token.type == tokenize.OP and token.string == "@":
            return token.start[0]
    return decorator.lineno


def decorator_span(parsed: ParsedModule, decorator: ast.expr) -> tuple[int, int]:
    """Return the span from a decorator's '@' line to the line of its last token.

    Args:
        parsed: The parsed module that holds the decorator.
        decorator: One element of a decorator_list.

    Returns:
        (the '@' line, the last line of the decorator expression).
    """
    return (decorator_line(parsed, decorator), node_span(decorator)[1])


def header_end_line(
    parsed: ParsedModule, node: ast.FunctionDef | ast.AsyncFunctionDef | ast.ClassDef
) -> int:
    """Return the line of the ':' that ends a def or class header.

    Args:
        parsed: The parsed module that holds the definition.
        node: The function or class definition.

    Returns:
        The line of the first ':' at bracket depth zero after the definition start
        (colons inside annotations, defaults or bases are skipped), or the definition
        line when none is found.
    """
    index = _token_index_at(parsed, node.lineno, node.col_offset)
    depth = 0
    # Track bracket depth so only the colon that closes the header is accepted.
    for token in parsed.tokens[index:]:
        if token.type != tokenize.OP:
            continue
        # Openers and closers adjust the depth; a colon counts only at depth zero.
        if token.string in _OPENERS:
            depth += 1
        elif token.string in _CLOSERS:
            depth -= 1
        elif token.string == ":" and depth == 0:
            return token.start[0]
    return node.lineno


def header_span(
    parsed: ParsedModule,
    node: ast.FunctionDef | ast.AsyncFunctionDef | ast.ClassDef,
    *,
    decorator: ast.expr | None = None,
) -> tuple[int, int]:
    """Return a definition header span from a decorator's '@' line to the ':'.

    Args:
        parsed: The parsed module that holds the definition.
        node: The function or class definition.
        decorator: The decorator whose '@' starts the span; defaults to the topmost
            decorator. An undecorated definition starts at its def or class line.

    Returns:
        (start line, line of the header-ending ':').
    """
    start_node = decorator
    if start_node is None and node.decorator_list:
        start_node = node.decorator_list[0]
    start = node.lineno if start_node is None else decorator_line(parsed, start_node)
    return (start, header_end_line(parsed, node))


def parameter_span(
    argument: ast.arg, annotation: ast.expr | None, default: ast.expr | None
) -> tuple[int, int]:
    """Return a parameter span from the name line to its last annotation or default.

    Args:
        argument: The parameter node.
        annotation: The parameter annotation, or None.
        default: The parameter default, or None.

    Returns:
        (name line, the last line of the name, annotation or default).
    """
    end = node_span(argument)[1]
    # Extend the end over whichever of the annotation and default reaches furthest.
    for part in (annotation, default):
        if part is not None:
            end = max(end, node_span(part)[1])
    return (argument.lineno, end)


def literal_string(node: ast.expr | None) -> str | None:
    """Return a declaration-forming literal string, or None.

    A string constant (implicit concatenation and escapes already processed by the
    parser) is accepted when it is non-empty, has no leading or trailing whitespace, no
    C0 control character and no surrogate code point.

    Args:
        node: Any expression, or None.

    Returns:
        The accepted string, or None for bytes, f-strings, non-strings and rejected
        strings.
    """
    if not isinstance(node, ast.Constant):
        return None
    value: object = node.value
    if not isinstance(value, str) or value == "" or value.strip() != value:
        return None
    # Reject the whole string on the first control character or surrogate.
    for character in value:
        code = ord(character)
        if code < 0x20 or 0xD800 <= code <= 0xDFFF:
            return None
    return value


def dotted_name(node: ast.expr) -> str | None:
    """Return NAME(.NAME)* for a Name or an Attribute chain over a Name.

    Args:
        node: Any expression.

    Returns:
        The dotted text, or None when the chain does not end in a plain Name (for
        example a call or subscript in the chain).
    """
    parts: list[str] = []
    current: ast.expr = node
    # Peel attributes from the outside in, collecting names right to left.
    while isinstance(current, ast.Attribute):
        parts.append(current.attr)
        current = current.value
    if not isinstance(current, ast.Name):
        return None
    parts.append(current.id)
    return ".".join(reversed(parts))
