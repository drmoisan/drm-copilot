"""Tests for docs_python_native.source: normalization, parsing, spans, literals."""

import ast
import warnings

import pytest
from docs_python_native.source import (
    PARSE_ERROR,
    PARSE_OK,
    ParsedModule,
    decorator_line,
    decorator_span,
    dotted_name,
    header_end_line,
    header_span,
    literal_string,
    node_span,
    normalize_source,
    parameter_span,
    parse_module,
    source_lines,
    statement_span,
)

BOM = chr(0xFEFF)
LINE_SEPARATOR = chr(0x2028)
PARAGRAPH_SEPARATOR = chr(0x2029)
NEXT_LINE = chr(0x85)


def _first_def(
    text: str,
) -> tuple[ParsedModule, ast.FunctionDef | ast.AsyncFunctionDef | ast.ClassDef]:
    parsed = parse_module(text)
    assert parsed.tree is not None
    node = parsed.tree.body[0]
    assert isinstance(node, (ast.FunctionDef, ast.AsyncFunctionDef, ast.ClassDef))
    return parsed, node


def _expression(text: str) -> ast.expr:
    tree = ast.parse(text, mode="eval")
    return tree.body


class TestNormalizeSource:
    def test_removes_one_leading_bom_only(self) -> None:
        # Arrange / Act / Assert: exactly one U+FEFF is stripped.
        assert normalize_source(BOM + BOM + "x") == BOM + "x"

    def test_maps_crlf_then_cr_to_lf(self) -> None:
        assert normalize_source("a\r\nb\rc\n") == "a\nb\nc\n"

    @pytest.mark.parametrize(
        "separator", ["\f", LINE_SEPARATOR, PARAGRAPH_SEPARATOR, NEXT_LINE]
    )
    def test_other_separators_are_not_line_breaks(self, separator: str) -> None:
        text = normalize_source("a" + separator + "b\nc")
        assert source_lines(text) == ["a" + separator + "b", "c"]


class TestSourceLines:
    def test_empty_text_has_no_lines(self) -> None:
        assert source_lines("") == []

    def test_one_trailing_lf_is_removed(self) -> None:
        assert source_lines("a\n\n") == ["a", ""]


class TestParseModule:
    def test_valid_module_parses_with_tokens(self) -> None:
        parsed = parse_module("x = 1\n")
        assert parsed.status == PARSE_OK
        assert parsed.tree is not None
        assert parsed.lines == ("x = 1",)
        assert parsed.tokens

    def test_syntax_error_is_parse_error(self) -> None:
        parsed = parse_module("x = $y\n")
        assert parsed.status == PARSE_ERROR
        assert parsed.tree is None

    def test_null_byte_value_error_is_parse_error(self) -> None:
        assert parse_module("x = 1" + chr(0) + "\n").status == PARSE_ERROR

    @pytest.mark.parametrize("failure", [RecursionError, MemoryError, ValueError])
    def test_injected_parser_failure_is_parse_error(
        self, failure: type[BaseException]
    ) -> None:
        def parser(_text: str) -> ast.Module:
            raise failure("injected")

        assert parse_module("x = 1\n", parser=parser).status == PARSE_ERROR

    def test_invalid_escape_emits_no_warning(self) -> None:
        with warnings.catch_warnings(record=True) as caught:
            warnings.simplefilter("always")
            parsed = parse_module('x = "' + chr(92) + 'd"\n')
        assert parsed.status == PARSE_OK
        assert caught == []

    def test_tokenize_failure_is_parse_error(self) -> None:
        def parser(_text: str) -> ast.Module:
            return ast.Module(body=[], type_ignores=[])

        assert parse_module("x = (\n", parser=parser).status == PARSE_ERROR

    def test_form_feed_and_line_separator_keep_numbering(self) -> None:
        parsed = parse_module('\fx = "a' + LINE_SEPARATOR + 'b"\ny = 2\n')
        assert parsed.status == PARSE_OK
        assert parsed.tree is not None
        assert [s.lineno for s in parsed.tree.body] == [1, 2]


class TestSpans:
    def test_statement_span_covers_continuations(self) -> None:
        tree = ast.parse("x = f(\n    1,\n)\n")
        assert statement_span(tree.body[0]) == (1, 3)

    def test_header_span_single_line(self) -> None:
        parsed, node = _first_def("def f(a, b):\n    pass\n")
        assert header_span(parsed, node) == (1, 1)

    def test_header_span_multi_line_with_annotations(self) -> None:
        text = "def f(\n    a: dict[str, int] = {'k': 1},\n) -> int:\n    return 1\n"
        parsed, node = _first_def(text)
        assert header_span(parsed, node) == (1, 3)

    def test_header_span_starts_at_topmost_decorator(self) -> None:
        text = "@a\n@b(\n  1)\nclass K(object):\n    pass\n"
        parsed, node = _first_def(text)
        assert header_span(parsed, node) == (1, 4)
        assert header_span(parsed, node, decorator=node.decorator_list[1]) == (2, 4)
        assert decorator_span(parsed, node.decorator_list[1]) == (2, 3)

    def test_decorator_line_on_parenthesized_decorator(self) -> None:
        parsed, node = _first_def("@(\n  a)\nasync def f(): pass\n")
        assert decorator_line(parsed, node.decorator_list[0]) == 1
        assert header_end_line(parsed, node) == 3

    def test_parameter_span_uses_annotation_and_default(self) -> None:
        tree = ast.parse("def f(a: int = (\n 1)): pass\n")
        function = tree.body[0]
        assert isinstance(function, ast.FunctionDef)
        argument = function.args.args[0]
        assert parameter_span(
            argument, argument.annotation, function.args.defaults[0]
        ) == (1, 2)
        assert parameter_span(argument, None, None) == (1, 1)

    def test_node_span_of_expression(self) -> None:
        assert node_span(_expression("[\n1]")) == (1, 2)


ESCAPE = chr(92)


class TestLiteralString:
    @pytest.mark.parametrize(
        ("text", "expected"),
        [
            ('"--name"', "--name"),
            ('"--na" "me"', "--name"),
            ('"--na' + ESCAPE + 'x6de"', "--name"),
            ("r'/a'", "/a"),
        ],
    )
    def test_accepts_literal_forms(self, text: str, expected: str) -> None:
        assert literal_string(_expression(text)) == expected

    @pytest.mark.parametrize(
        "text",
        [
            '""',
            '" x"',
            '"x "',
            '"a' + ESCAPE + 'tb"',
            'b"x"',
            'f"x{y}"',
            "1",
            "name",
            '"' + ESCAPE + 'ud800"',
        ],
    )
    def test_rejects_non_literal_forms(self, text: str) -> None:
        assert literal_string(_expression(text)) is None

    def test_none_gives_none(self) -> None:
        assert literal_string(None) is None


class TestDottedName:
    def test_chain(self) -> None:
        assert dotted_name(_expression("a.b.c")) == "a.b.c"

    def test_non_chain(self) -> None:
        assert dotted_name(_expression("a().b")) is None
