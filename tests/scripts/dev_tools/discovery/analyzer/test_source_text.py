"""Unit tests for the shared pure text helpers in ``source_text``.

Covers the comment/string stripper (line/column preservation and false-positive
suppression), the slugifier and evidence-id builder (determinism, grammar
conformance, uniqueness), the line-numbering utility, and the ``TextParseResult``
frozen subtype. All inputs are inline strings; no filesystem is touched.
"""

from __future__ import annotations

import dataclasses
import re

import pytest

from scripts.dev_tools.discovery.analyzer.models import ParseResult
from scripts.dev_tools.discovery.analyzer.source_text import (
    TextParseResult,
    build_evidence_id,
    numbered_lines,
    slugify,
    strip_comments_and_strings,
)

# Shared discovery identifier grammar every evidence id must satisfy.
_ID_GRAMMAR = re.compile(r"^[a-z0-9][a-z0-9._-]*$")


class TestStripper:
    """Behavioral tests for ``strip_comments_and_strings``."""

    @pytest.mark.parametrize(
        ("source", "expected_visible"),
        [
            # Line comment: declaration-shaped text after ``//`` must be blanked.
            ("int x = 1; // namespace Fake", "int x = 1;"),
            # Block comment on a single line.
            ("a /* class Hidden */ b", "a"),
            # String literal containing a declaration look-alike.
            ('var s = "class InString";', "var s ="),
            # Verbatim string with an embedded quote look-alike.
            ('var p = @"C:\\ns namespace X";', "var p ="),
            # Interpolated string body is blanked.
            ('var m = $"value {count} class Y";', "var m ="),
            # Char literal is blanked.
            ("char c = 'x';", "char c ="),
        ],
    )
    def test_blanks_non_code_spans(self, source: str, expected_visible: str) -> None:
        """Non-code spans are blanked so only real code text remains visible."""
        # Arrange / Act
        stripped = strip_comments_and_strings(source)

        # Assert: the code prefix survives and no blanked keyword remains.
        assert stripped.startswith(expected_visible)
        assert "namespace" not in stripped or stripped.count("namespace") == 0
        assert "class Hidden" not in stripped
        assert "class InString" not in stripped

    def test_preserves_length_exactly(self) -> None:
        """The stripped text has the same character length as the input."""
        # Arrange
        source = 'namespace Real {} // comment\nvar s = "hidden";\n'

        # Act
        stripped = strip_comments_and_strings(source)

        # Assert
        assert len(stripped) == len(source)

    def test_preserves_line_count_multiline_block_comment(self) -> None:
        """A multi-line block comment keeps the surrounding line structure."""
        # Arrange: the block comment spans three physical lines.
        source = "line1\n/* comment\nstill comment\n*/ namespace After {\n"

        # Act
        stripped = strip_comments_and_strings(source)

        # Assert: line count is preserved and only real code remains.
        assert stripped.count("\n") == source.count("\n")
        assert "comment" not in stripped
        assert "namespace After {" in stripped

    def test_preserves_column_offset(self) -> None:
        """Code following a same-line block comment keeps its column offset."""
        # Arrange
        source = "/* c */ namespace Foo {"

        # Act
        stripped = strip_comments_and_strings(source)

        # Assert: the namespace keyword sits at the same column as in the source.
        assert stripped.index("namespace") == source.index("namespace")

    def test_verbatim_doubled_quote_stays_in_string(self) -> None:
        """A doubled quote inside a verbatim string does not end it early."""
        # Arrange: the ``""`` is an escaped quote; ``class Z`` must stay blanked.
        source = 'var s = @"a ""b"" class Z"; int y = 2;'

        # Act
        stripped = strip_comments_and_strings(source)

        # Assert
        assert "class Z" not in stripped
        assert "int y = 2;" in stripped

    def test_unterminated_block_comment_blanks_to_end(self) -> None:
        """An unterminated block comment blanks the remainder without error."""
        # Arrange
        source = "code /* open comment never closed"

        # Act
        stripped = strip_comments_and_strings(source)

        # Assert
        assert stripped.startswith("code")
        assert "comment" not in stripped
        assert len(stripped) == len(source)

    def test_code_outside_comments_is_untouched(self) -> None:
        """Plain code with no comments or strings is returned verbatim."""
        # Arrange
        source = "public class Widget { }"

        # Act / Assert
        assert strip_comments_and_strings(source) == source

    @pytest.mark.parametrize(
        ("source", "blanked", "kept"),
        [
            # Char literal with a backslash escape does not end early.
            (r"char c = '\n'; int keep = 1;", None, "int keep = 1;"),
            # Unterminated char literal ends at the line break.
            ("char c = 'a\nint keep = 2;", None, "int keep = 2;"),
            # Interpolated-verbatim ``@$"`` prefix blanks the whole literal.
            (
                'var a = @$"class Hidden {x}"; int keep = 3;',
                "class Hidden",
                "keep = 3;",
            ),
            # Interpolated-verbatim ``$@"`` prefix blanks the whole literal.
            (
                'var b = $@"class Buried {y}"; int keep = 4;',
                "class Buried",
                "keep = 4;",
            ),
            # Unterminated regular string ends at the line break.
            ('var s = "class Never\nint keep = 5;', "class Never", "int keep = 5;"),
        ],
    )
    def test_stripper_edge_cases(
        self, source: str, blanked: str | None, kept: str
    ) -> None:
        """Char-literal, interpolated-verbatim, and unterminated-string edges."""
        # Act
        stripped = strip_comments_and_strings(source)

        # Assert: length is preserved, code survives, and any blanked text is gone.
        assert len(stripped) == len(source)
        assert kept in stripped
        if blanked is not None:
            assert blanked not in stripped


class TestNumberedLines:
    """Tests for the 1-based line-numbering utility."""

    def test_numbers_lines_from_one(self) -> None:
        """Lines are numbered starting at 1 in source order."""
        # Arrange
        text = "alpha\nbeta\ngamma"

        # Act
        numbered = numbered_lines(text)

        # Assert
        assert numbered == [(1, "alpha"), (2, "beta"), (3, "gamma")]

    def test_line_numbers_align_with_stripped_text(self) -> None:
        """Line numbers computed after stripping index the original lines."""
        # Arrange
        source = "// header\nnamespace Foo;\n"

        # Act
        stripped = strip_comments_and_strings(source)
        numbered = numbered_lines(stripped)

        # Assert: the namespace declaration is on line 2 in both texts.
        namespace_lines = [n for n, text in numbered if "namespace" in text]
        assert namespace_lines == [2]


class TestSlugify:
    """Edge-case coverage for the slugifier."""

    @pytest.mark.parametrize(
        ("value", "expected"),
        [
            ("MyClass", "myclass"),
            ("Foo Bar", "foo-bar"),
            ("A.B.C", "a.b.c"),
            ("___leading", "leading"),
            ("123abc", "123abc"),
            ("Café", "caf-"),
            ("--__..", ""),
            ("Microsoft.Office.Interop.Excel", "microsoft.office.interop.excel"),
        ],
    )
    def test_slugify_cases(self, value: str, expected: str) -> None:
        """Slugify lowercases, normalizes, and strips leading separators."""
        # Act / Assert
        assert slugify(value) == expected

    @pytest.mark.parametrize(
        "value",
        ["MyClass", "Foo Bar", "A.B.C", "___leading", "123abc"],
    )
    def test_non_empty_slug_conforms_to_grammar(self, value: str) -> None:
        """A non-empty slug is a valid identifier grammar body."""
        # Act
        slug = slugify(value)

        # Assert: a non-empty slug on its own satisfies the grammar.
        assert _ID_GRAMMAR.match(slug) is not None


class TestBuildEvidenceId:
    """Determinism, grammar conformance, and uniqueness of evidence ids."""

    def test_id_is_deterministic_across_calls(self) -> None:
        """Identical inputs yield the identical id on repeated calls."""
        # Arrange
        args = ("dotnet", "namespace", "Foo.Bar", "src/A.cs", 3)

        # Act
        first = build_evidence_id(*args)
        second = build_evidence_id(*args)

        # Assert
        assert first == second

    @pytest.mark.parametrize(
        ("prefix", "kind", "symbol", "location", "line"),
        [
            ("dotnet", "namespace", "Foo.Bar", "src/A.cs", 1),
            ("dotnet", "type", "Widget", "src/deep/path/Widget.cs", 42),
            ("vsto", "interop_using", "Microsoft.Office.Interop.Excel", "x.cs", 7),
            ("vsto", "marshal_call", "ReleaseComObject", "y.cs", 100),
            ("dotnet", "event_subscription", "", "z.cs", 5),
        ],
    )
    def test_id_conforms_to_grammar(
        self, prefix: str, kind: str, symbol: str, location: str, line: int
    ) -> None:
        """Every built id matches the shared identifier grammar."""
        # Act
        evidence_id = build_evidence_id(prefix, kind, symbol, location, line)

        # Assert
        assert _ID_GRAMMAR.match(evidence_id) is not None

    def test_same_symbol_different_location_is_unique(self) -> None:
        """The same symbol at different locations yields distinct ids."""
        # Arrange / Act
        first = build_evidence_id("dotnet", "type", "Widget", "src/A.cs", 3)
        second = build_evidence_id("dotnet", "type", "Widget", "src/B.cs", 3)

        # Assert
        assert first != second

    def test_same_symbol_different_line_is_unique(self) -> None:
        """The same symbol at different lines yields distinct ids."""
        # Arrange / Act
        first = build_evidence_id("dotnet", "type", "Widget", "src/A.cs", 3)
        second = build_evidence_id("dotnet", "type", "Widget", "src/A.cs", 9)

        # Assert
        assert first != second

    def test_empty_symbol_falls_back_to_location_slug(self) -> None:
        """An empty symbol still produces a grammar-conforming id via location."""
        # Act
        evidence_id = build_evidence_id("dotnet", "event_subscription", "", "p/q.cs", 2)

        # Assert: the location slug appears and the id is valid.
        assert "p-q.cs" in evidence_id
        assert _ID_GRAMMAR.match(evidence_id) is not None


class TestTextParseResult:
    """Tests for the frozen ``TextParseResult`` subtype."""

    def test_is_parse_result_subtype(self) -> None:
        """``TextParseResult`` is an instance of the #363 ``ParseResult``."""
        # Arrange / Act
        result = TextParseResult(paths=("a.cs",), file_texts=(("a.cs", "code"),))

        # Assert
        assert isinstance(result, ParseResult)

    def test_field_ordering_paths_then_file_texts(self) -> None:
        """Positional construction binds ``paths`` first, then ``file_texts``."""
        # Arrange / Act: positional order proves the inherited field comes first.
        result = TextParseResult(("a.cs", "b.cs"), (("a.cs", "x"), ("b.cs", "y")))

        # Assert
        assert result.paths == ("a.cs", "b.cs")
        assert result.file_texts == (("a.cs", "x"), ("b.cs", "y"))

    def test_is_frozen(self) -> None:
        """Assigning to a field raises because the dataclass is frozen."""
        # Arrange
        result = TextParseResult(paths=("a.cs",), file_texts=(("a.cs", "code"),))

        # Act / Assert
        with pytest.raises(dataclasses.FrozenInstanceError):
            result.file_texts = ()  # type: ignore[misc]

    def test_default_file_texts_is_empty(self) -> None:
        """``file_texts`` defaults to an empty tuple when omitted."""
        # Arrange / Act
        result = TextParseResult(paths=("a.cs",))

        # Assert
        assert result.file_texts == ()
