"""Tests for docs_python_native.walk: enclosing-block contexts of a generic walk."""

import ast

from docs_python_native.walk import Context, walk_with_context


class TestWalkWithContext:
    def test_contexts_follow_blocks_and_comprehensions(self) -> None:
        text = (
            "if x:\n    a = 1\n"
            "for i in y:\n    b = 2\n"
            "def f():\n    c = 3\n"
            "z = [d for d in w]\n"
            "try:\n    e = 1\nexcept E:\n    g = 1\n"
        )
        found: dict[str, Context] = {}
        for node, context in walk_with_context(ast.parse(text)):
            if isinstance(node, ast.Name) and isinstance(node.ctx, ast.Store):
                found[node.id] = context
        assert found["a"].blocks == ("if",) and found["a"].top_level_only
        assert found["b"].in_loop and not found["b"].top_level_only
        assert found["c"].nested
        assert found["d"].in_comprehension
        assert found["e"].blocks == ("try",)
        assert found["g"].blocks == ("try",) and found["g"].top_level_only
        assert found["i"].blocks == ()
