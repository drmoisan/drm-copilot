"""Tests for docs_python_native.call_sites: keyword, span, binding and chain helpers."""

import ast

import pytest
from docs_python_native.call_sites import (
    binding_name,
    decorator_call,
    function_header_nodes,
    has_keyword,
    has_star,
    keyword,
    leading_chain,
    literal_bool,
    site_span,
    statement_index,
)
from docs_python_native.imports import build_tables
from docs_python_native.source import parse_module


def _call(text: str) -> ast.Call:
    """Parse a text as one call expression and return it."""
    node = ast.parse(text, mode="eval").body
    assert isinstance(node, ast.Call)
    return node


def _expression(text: str) -> ast.expr:
    """Parse a text as one expression and return the expression node."""
    return ast.parse(text, mode="eval").body


class TestKeywords:
    """Scenarios for keywords in docs_python_native.call_sites."""

    def test_keyword_returns_the_named_value(self) -> None:
        """Scenario: keyword returns the value of a named keyword."""
        value = keyword(_call("f(a=1, b='x')"), "b")
        assert isinstance(value, ast.Constant) and value.value == "x"

    def test_keyword_is_none_when_absent(self) -> None:
        """Scenario: keyword returns None when the keyword is absent."""
        assert keyword(_call("f(a=1)"), "b") is None

    def test_has_keyword_reports_presence_and_absence(self) -> None:
        """Scenario: has keyword reports presence and absence."""
        call = _call("f(a=1)")
        assert has_keyword(call, "a")
        assert not has_keyword(call, "b")

    @pytest.mark.parametrize(
        ("text", "expected"),
        [("f(*args)", True), ("f(**kwargs)", True), ("f(1, a=2)", False)],
    )
    def test_has_star_detects_unpacked_arguments(
        self, text: str, expected: bool
    ) -> None:
        """Scenario: has star detects unpacked arguments."""
        assert has_star(_call(text)) is expected


class TestLiteralBool:
    """Scenarios for literal bool in docs_python_native.call_sites."""

    @pytest.mark.parametrize(
        ("text", "expected"),
        [("True", True), ("False", False), ("1", None), ("flag", None)],
    )
    def test_literal_bool_accepts_only_boolean_constants(
        self, text: str, expected: bool | None
    ) -> None:
        """Scenario: literal bool accepts only boolean constants."""
        assert literal_bool(_expression(text)) is expected

    def test_literal_bool_of_none_is_none(self) -> None:
        """Scenario: literal_bool of None returns None."""
        assert literal_bool(None) is None


class TestStatementOwnershipAndSpans:
    """Scenarios for statement ownership and spans in docs_python_native.call_sites."""

    def test_statement_index_maps_a_call_to_its_innermost_statement(self) -> None:
        """Scenario: statement index maps a call to its innermost statement."""
        tree = ast.parse("if x:\n    y = f(1)\n")
        owner = statement_index(tree)
        call = next(n for n in ast.walk(tree) if isinstance(n, ast.Call))
        statement = owner[call]
        assert isinstance(statement, ast.Assign) and statement.lineno == 2

    def test_site_span_of_a_single_line_statement(self) -> None:
        """Scenario: site span of a single line statement."""
        tree = ast.parse("y = f(1)\n")
        call = next(n for n in ast.walk(tree) if isinstance(n, ast.Call))
        assert site_span(call, statement_index(tree)[call]) == (1, 1)

    def test_site_span_of_a_multi_line_statement(self) -> None:
        """Scenario: site span of a multi line statement."""
        tree = ast.parse("y = f(\n    1,\n)\n")
        call = next(n for n in ast.walk(tree) if isinstance(n, ast.Call))
        assert site_span(call, statement_index(tree)[call]) == (1, 3)

    def test_site_span_of_a_call_in_a_compound_header_uses_the_call(self) -> None:
        """Scenario: site span of a call in a compound header uses the call."""
        tree = ast.parse("for i in f(\n    1):\n    pass\n")
        call = next(n for n in ast.walk(tree) if isinstance(n, ast.Call))
        assert site_span(call, statement_index(tree)[call]) == (1, 2)

    def test_site_span_without_a_statement_uses_the_call(self) -> None:
        """Scenario: site span without a statement uses the call."""
        assert site_span(_call("f(\n1)"), None) == (1, 2)


class TestBindingName:
    """Scenarios for binding name in docs_python_native.call_sites."""

    def test_bound_receiver_statement_gives_its_name(self) -> None:
        """Scenario: bound receiver statement gives its name."""
        parsed = parse_module("import argparse\nparser = argparse.ArgumentParser()\n")
        assert parsed.tree is not None
        tables = build_tables(parsed)
        assert binding_name(tables, parsed.tree.body[1]) == "parser"

    @pytest.mark.parametrize(
        "text",
        ["f()\n", "a.b = g()\n", "x = 1\n"],
    )
    def test_unbound_statement_gives_none(self, text: str) -> None:
        """Scenario: a statement binding no tracked receiver gives None."""
        parsed = parse_module(text)
        assert parsed.tree is not None
        assert binding_name(build_tables(parsed), parsed.tree.body[0]) is None

    def test_none_statement_gives_none(self) -> None:
        """Scenario: a None statement gives None."""
        assert binding_name(build_tables(parse_module("x = 1\n")), None) is None


class TestChains:
    """Scenarios for chains in docs_python_native.call_sites."""

    @pytest.mark.parametrize(
        ("text", "expected"),
        [
            ("app.get", "app.get"),
            ("app.get('/x')", "app.get"),
            ("app.get('/x')(y)", "app.get"),
            ("items[0].route", "items"),
            ("(lambda: 1)()", None),
        ],
    )
    def test_leading_chain_of_attribute_and_call_forms(
        self, text: str, expected: str | None
    ) -> None:
        """Scenario: leading chain of attribute and call forms."""
        assert leading_chain(_expression(text)) == expected

    def test_decorator_call_of_a_called_decorator(self) -> None:
        """Scenario: decorator call of a called decorator."""
        call = decorator_call(_expression("click.command('x')"))
        assert call is not None and isinstance(call.func, ast.Attribute)

    def test_decorator_call_of_a_bare_decorator_is_none(self) -> None:
        """Scenario: decorator call of a bare decorator is none."""
        assert decorator_call(_expression("click.command")) is None

    def test_decorator_call_skips_an_outer_call_of_a_call(self) -> None:
        """Scenario: decorator call skips an outer call of a call."""
        call = decorator_call(_expression("factory('a')('b')"))
        assert call is not None and isinstance(call.func, ast.Name)


class TestFunctionHeaderNodes:
    """Scenarios for function header nodes in docs_python_native.call_sites."""

    def test_header_nodes_hold_decorators_parameters_and_returns_only(self) -> None:
        """Scenario: header nodes hold decorators parameters and returns only."""
        tree = ast.parse("@deco(1)\ndef f(a: int = g()) -> R:\n    body()\n")
        nodes = function_header_nodes(tree)
        calls = {
            n.func.id: n
            for n in ast.walk(tree)
            if isinstance(n, ast.Call) and isinstance(n.func, ast.Name)
        }
        assert calls["deco"] in nodes
        assert calls["g"] in nodes
        assert calls["body"] not in nodes
