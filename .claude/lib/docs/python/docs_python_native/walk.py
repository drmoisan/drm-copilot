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
    """The blocks enclosing a node and whether it lies inside a comprehension.

    Produced by walk_with_context and read by every analyzer to apply the 1022 rules
    that depend on position: module-level imports, registrations inside loops, nested
    framework imports and conditional definitions. Immutable; a child context is a new
    instance.

    Attributes:
        blocks: The kinds of the enclosing compound statements, outermost first
            ("if", "for", "while", "with", "def", "class", "try").
        in_comprehension: True for nodes inside a list, set, dict or generator
            comprehension.
    """

    blocks: tuple[str, ...] = ()
    in_comprehension: bool = False

    @property
    def in_loop(self) -> bool:
        """Report whether the node lies in the body of a for or while statement.

        Returns:
            True when a "for" or "while" block encloses the node.
        """
        return "for" in self.blocks or "while" in self.blocks

    @property
    def nested(self) -> bool:
        """Report whether the node lies inside a def or class body.

        Returns:
            True when a "def" or "class" block encloses the node.
        """
        return "def" in self.blocks or "class" in self.blocks

    @property
    def top_level_only(self) -> bool:
        """Report whether every enclosing block is a top-level if or try.

        Returns:
            True at module level and inside if, else, try or except bodies only.
        """
        return all(kind in _TOP_LEVEL_BRANCHES for kind in self.blocks)


def _block_kind(node: ast.AST) -> str | None:
    """Return the block kind a compound statement opens for its child statements.

    try/except* (ast.TryStar, Python 3.11) is matched by class name so that the module
    names no node type the 3.11 floor might lack in a later refactor.

    Args:
        node: Any syntax-tree node.

    Returns:
        The block kind, or None for a node that opens no block.
    """
    kind = _BLOCK_KIND.get(type(node))
    if kind is None and type(node).__name__ == "TryStar":
        return "try"
    return kind


def walk_with_context(tree: ast.AST) -> Iterator[tuple[ast.AST, Context]]:
    """Yield every node with its enclosing-block context, in document order.

    A child statement (or except handler) of a compound statement lies in that block;
    its header expressions (test, iterator, decorators, defaults, bases) do not. The
    walk is iterative, so deep trees do not reach the recursion limit.

    Args:
        tree: The root node, usually an ast.Module.

    Yields:
        (node, context) pairs, parents before children, siblings in source order.
    """
    stack: list[tuple[ast.AST, Context]] = [(tree, Context())]
    # Depth-first walk over an explicit stack; children are pushed in reverse so they
    # pop in source order.
    while stack:
        node, context = stack.pop()
        yield node, context
        kind = _block_kind(node)
        children = list(ast.iter_child_nodes(node))
        # Derive each child's context: statements enter the block, and everything
        # under a comprehension is marked as comprehension-scoped.
        for child in reversed(children):
            child_context = context
            if kind is not None and isinstance(child, (ast.stmt, ast.ExceptHandler)):
                child_context = Context(
                    context.blocks + (kind,), context.in_comprehension
                )
            if isinstance(node, _COMPREHENSIONS):
                child_context = Context(child_context.blocks, True)
            stack.append((child, child_context))
