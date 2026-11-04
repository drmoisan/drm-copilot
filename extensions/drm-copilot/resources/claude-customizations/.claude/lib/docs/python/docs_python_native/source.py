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
    from collections.abc import Callable, Iterator

PARSE_OK = "ok"
PARSE_ERROR = "parse-error"

_BOM = chr(0xFEFF)
_OPENERS = frozenset({"(", "[", "{"})
_CLOSERS = frozenset({")", "]", "}"})
_PARSE_FAILURES = (SyntaxError, ValueError, RecursionError, MemoryError)
_TOKENIZE_FAILURES = (tokenize.TokenError, SyntaxError, ValueError, RecursionError)


def normalize_source(text: str) -> str:
    """Return the text with one leading U+FEFF removed and CRLF, then CR, as LF."""
    if text.startswith(_BOM):
        text = text[1:]
    return text.replace("\r\n", "\n").replace("\r", "\n")


def source_lines(text: str) -> list[str]:
    """Return the 1020 numbered lines of a normalized text (one trailing LF removed)."""
    if text.endswith("\n"):
        text = text[:-1]
    if text == "":
        return []
    return text.split("\n")


@dataclass(frozen=True)
class ParsedModule:
    """One parsed input: status, syntax tree, canonical lines and significant tokens."""

    status: str
    tree: ast.Module | None
    lines: tuple[str, ...]
    tokens: tuple[tokenize.TokenInfo, ...] = field(default=())


def _significant_tokens(text: str) -> tuple[tokenize.TokenInfo, ...]:
    skipped = {
        tokenize.COMMENT,
        tokenize.NL,
        tokenize.NEWLINE,
        tokenize.INDENT,
        tokenize.DEDENT,
        tokenize.ENDMARKER,
    }
    reader = io.StringIO(text).readline
    return tuple(t for t in tokenize.generate_tokens(reader) if t.type not in skipped)


def parse_module(
    text: str, *, parser: Callable[[str], ast.Module] = ast.parse
) -> ParsedModule:
    """Parse a normalized text; a parser failure gives status parse-error, no tree."""
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
    """Return the index of the first significant token at or after (line, column)."""
    for index, token in enumerate(parsed.tokens):
        if token.start >= (line, column):
            return index
    return len(parsed.tokens)


def statement_span(node: ast.stmt) -> tuple[int, int]:
    """Return the statement span: the first through the last line of the statement."""
    end = node.end_lineno if node.end_lineno is not None else node.lineno
    return (node.lineno, end)


def node_span(node: ast.expr | ast.stmt | ast.arg) -> tuple[int, int]:
    """Return the first and last line of an expression, statement or argument node."""
    end = node.end_lineno if node.end_lineno is not None else node.lineno
    return (node.lineno, end)


def decorator_line(parsed: ParsedModule, decorator: ast.expr) -> int:
    """Return the line of the '@' token that introduces a decorator expression."""
    index = _token_index_at(parsed, decorator.lineno, decorator.col_offset)
    for back in range(index - 1, -1, -1):
        token = parsed.tokens[back]
        if token.type == tokenize.OP and token.string == "@":
            return token.start[0]
    return decorator.lineno


def decorator_span(parsed: ParsedModule, decorator: ast.expr) -> tuple[int, int]:
    """Return the span from a decorator's '@' line to the line of its last token."""
    return (decorator_line(parsed, decorator), node_span(decorator)[1])


def header_end_line(
    parsed: ParsedModule, node: ast.FunctionDef | ast.AsyncFunctionDef | ast.ClassDef
) -> int:
    """Return the line of the ':' that ends a def or class header."""
    index = _token_index_at(parsed, node.lineno, node.col_offset)
    depth = 0
    for token in parsed.tokens[index:]:
        if token.type != tokenize.OP:
            continue
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
    """Return a header span: a decorator's '@' (default the topmost) to the ':'.

    An undecorated definition starts at its def or class line.
    """
    start_node = decorator
    if start_node is None and node.decorator_list:
        start_node = node.decorator_list[0]
    start = node.lineno if start_node is None else decorator_line(parsed, start_node)
    return (start, header_end_line(parsed, node))


def parameter_span(
    argument: ast.arg, annotation: ast.expr | None, default: ast.expr | None
) -> tuple[int, int]:
    """Return a parameter span: the name line to the last annotation or default line."""
    end = node_span(argument)[1]
    for part in (annotation, default):
        if part is not None:
            end = max(end, node_span(part)[1])
    return (argument.lineno, end)


def literal_string(node: ast.expr | None) -> str | None:
    """Return a declaration-forming literal string, or None.

    A string constant (implicit concatenation and escapes already processed by the
    parser) is accepted when it is non-empty, has no leading or trailing whitespace, no
    C0 control character and no surrogate code point. Bytes, f-strings and non-strings
    give None.
    """
    if not isinstance(node, ast.Constant):
        return None
    value: object = node.value
    if not isinstance(value, str) or value == "" or value.strip() != value:
        return None
    for character in value:
        code = ord(character)
        if code < 0x20 or 0xD800 <= code <= 0xDFFF:
            return None
    return value


def dotted_name(node: ast.expr) -> str | None:
    """Return NAME(.NAME)* for a Name or an Attribute chain over a Name, else None."""
    parts: list[str] = []
    current: ast.expr = node
    while isinstance(current, ast.Attribute):
        parts.append(current.attr)
        current = current.value
    if not isinstance(current, ast.Name):
        return None
    parts.append(current.id)
    return ".".join(reversed(parts))


_BLOCK_KIND: dict[type[ast.AST], str] = {
    ast.If: "if",
    ast.For: "for",
    ast.AsyncFor: "for",
    ast.While: "while",
    ast.With: "with",
    ast.AsyncWith: "with",
    ast.FunctionDef: "def",
    ast.AsyncFunctionDef: "def",
    ast.ClassDef: "class",
    ast.Try: "try",
}
_TOP_LEVEL_BRANCHES = frozenset({"if", "try"})
_COMPREHENSIONS = (ast.ListComp, ast.SetComp, ast.DictComp, ast.GeneratorExp)


@dataclass(frozen=True)
class Context:
    """The blocks enclosing a node (outermost first) and the comprehension flag."""

    blocks: tuple[str, ...] = ()
    in_comprehension: bool = False

    @property
    def in_loop(self) -> bool:
        """True inside the body of a for or while statement."""
        return "for" in self.blocks or "while" in self.blocks

    @property
    def nested(self) -> bool:
        """True inside a def or class body."""
        return "def" in self.blocks or "class" in self.blocks

    @property
    def top_level_only(self) -> bool:
        """True when every enclosing block is a top-level if, else, try or except."""
        return all(kind in _TOP_LEVEL_BRANCHES for kind in self.blocks)


def _block_kind(node: ast.AST) -> str | None:
    kind = _BLOCK_KIND.get(type(node))
    if kind is None and type(node).__name__ == "TryStar":
        return "try"
    return kind


def walk_with_context(tree: ast.AST) -> Iterator[tuple[ast.AST, Context]]:
    """Yield every node with its enclosing-block context, in document order.

    A child statement (or except handler) of a compound statement lies in that block;
    its header expressions (test, iterator, decorators, defaults, bases) do not.
    """
    stack: list[tuple[ast.AST, Context]] = [(tree, Context())]
    while stack:
        node, context = stack.pop()
        yield node, context
        kind = _block_kind(node)
        children = list(ast.iter_child_nodes(node))
        for child in reversed(children):
            child_context = context
            if kind is not None and isinstance(child, (ast.stmt, ast.ExceptHandler)):
                child_context = Context(
                    context.blocks + (kind,), context.in_comprehension
                )
            if isinstance(node, _COMPREHENSIONS):
                child_context = Context(child_context.blocks, True)
            stack.append((child, child_context))
