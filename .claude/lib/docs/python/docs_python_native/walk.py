"""Enclosing-block contexts for a generic walk of a syntax tree.

walk_with_context yields every node with the blocks that enclose it, so analyzers can
tell module-level bindings from nested, looped or comprehension-scoped ones without
naming node types newer than Python 3.11.
"""

from __future__ import annotations

import ast
from dataclasses import dataclass
from typing import TYPE_CHECKING

if TYPE_CHECKING:
    from collections.abc import Iterator

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
