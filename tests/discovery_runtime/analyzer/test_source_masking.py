"""Exercise offset-preserving C# masking with deterministic in-memory inputs."""

from __future__ import annotations

import re
from itertools import product

import pytest
from drm_copilot_discovery.analyzer.source_text import (
    Detection,
    build_evidence_id,
    build_evidence_record,
    numbered_lines,
    slugify,
    strip_comments_and_strings,
)


@pytest.mark.parametrize(
    "literal",
    (
        '"class Hidden \\" quoted"',
        '@"class Hidden "" quote\r\nmore"',
        '$"{{class Hidden}} { value }"',
        '$@"class Hidden { new { Name = "event Hidden" } }"',
        '@$"class Hidden { value }"',
        '"""class Hidden " double "" quotes"""',
        '""""\r\nclass Hidden """ shorter\r\n""""',
        '$"""class Hidden { "event Hidden" }"""',
        '$$"""{class Hidden} {{ new { Value = "event Hidden" } }}"""',
        '$$"""{{ """class Hidden""" }}"""',
        '$"{ new { Name = "class Hidden", More = $"{ "event Hidden" }" } }"',
        '$"{ value switch { 1 => "class Hidden", _ => "event Hidden" } }"',
        "$\"{ /* } hidden */ new { Value = '}' } }\"",
        '$"{\r\n // } hidden\r\n "class Hidden"\r\n}"',
        '$"{ value:000 } class Hidden"',
        '""',
        '$""',
        "'\\''",
        "'\\n'",
    ),
)
def test_complete_literal_masks_every_character_and_keeps_following_code(
    literal: str,
) -> None:
    """Mask supplied str literal wholly with exact offsets; return None, no I/O."""
    source = "var text = " + literal + "; public class Kept {}"
    # Derive the full masked span while retaining each original physical newline.
    expected_literal = "".join(char if char in "\r\n" else " " for char in literal)
    assert strip_comments_and_strings(source) == (
        "var text = " + expected_literal + "; public class Kept {}"
    )


@pytest.mark.parametrize("width", (3, 4, 5, 9))
@pytest.mark.parametrize("dollars", ("", "$", "$$", "$$$"))
def test_raw_delimiter_lengths_do_not_release_shorter_quote_runs(
    width: int,
    dollars: str,
) -> None:
    """Use int width/str prefix to contain shorter quotes; return None, no I/O."""
    delimiter = '"' * width
    literal = dollars + delimiter + "\r\n" + '"' * (width - 1)
    literal += " class Hidden\n" + delimiter
    source = literal + " public class Kept {}"
    result = strip_comments_and_strings(source)
    assert "Hidden" not in result and result.endswith(" public class Kept {}")
    assert result.index("Kept") == source.index("Kept")
    assert len(result) == len(source) and result.count("\r\n") == 1


@pytest.mark.parametrize(
    "source",
    (
        'var x = """\r\nclass Hidden',
        'var x = """"\n""" class Hidden',
        'var x = """\n"""" class Hidden',
        'var x = @"\r\nclass Hidden',
        'var x = $"{ new { Value = "x" } \nclass Hidden',
        'var x = $$"""{{ value } class Hidden',
        "var x = /*\r\nclass Hidden",
        'var x = "class Hidden\\',
        "var x = 'class Hidden\\",
    ),
)
def test_incomplete_multiline_or_interpolation_constructs_remain_masked(
    source: str,
) -> None:
    """Keep str source's unclosed spans conservative through EOF; return None."""
    result = strip_comments_and_strings(source)
    assert result.startswith("var x = ") and "Hidden" not in result
    assert len(result) == len(source)
    # Delimiter positions remain identical even for deliberately invalid syntax.
    assert tuple(index for index, char in enumerate(result) if char in "\r\n") == (
        tuple(index for index, char in enumerate(source) if char in "\r\n")
    )


@pytest.mark.parametrize("newline", ("\r\n", "\r", "\n"))
@pytest.mark.parametrize("opening", ('"', "'", "//"))
def test_ordinary_unterminated_forms_recover_at_physical_newlines(
    newline: str,
    opening: str,
) -> None:
    """Recover supplied str ordinary opening at str newline; return None, pure."""
    hidden = opening + "class Hidden"
    source = hidden + newline + "class Kept {}"
    assert (
        strip_comments_and_strings(source)
        == " " * len(hidden) + newline + "class Kept {}"
    )


def test_deep_nested_interpolation_uses_no_python_recursion() -> None:
    """Mask 1,200 nested expressions then resume code; return None, no I/O."""
    source = '$"{' * 1200 + '"class Hidden"' + '}"' * 1200 + "; class Kept {}"
    result = strip_comments_and_strings(source)
    assert result.endswith("; class Kept {}") and "Hidden" not in result
    assert len(result) == len(source)


@pytest.mark.parametrize(
    "text", ("", "a\r\nb\rc\n", "\r\n\r\n", "α\u0085β\u2028γ\u2029δ")
)
def test_numbered_lines_uses_only_physical_crlf_cr_lf_boundaries(text: str) -> None:
    """Count str text's physical boundaries, keeping Unicode content; return None."""
    lines = numbered_lines(text)
    expected_count = text.count("\r") + text.count("\n") - text.count("\r\n") + 1
    assert len(lines) == expected_count
    assert [number for number, _ in lines] == list(range(1, expected_count + 1))
    assert "\n".join(line for _, line in lines) == text.replace("\r\n", "\n").replace(
        "\r", "\n"
    )


def test_masking_metamorphic_properties_hold_for_generated_unicode_fragments() -> None:
    """Check length, offsets, idempotence and line alignment over generated text.
    Return None; deterministic Cartesian inputs require no RNG, files or services.
    """
    fragments = (
        "α😀",
        "e\u0301",
        "\r\n",
        "\r",
        "\n",
        '"',
        "'",
        "\\",
        "//",
        "/*",
        "$",
        "{",
        "}",
    )
    # Cross lexical boundaries exhaustively while retaining reproducible inputs.
    for parts in product(fragments, repeat=3):
        source = "".join(parts)
        masked = strip_comments_and_strings(source)
        assert len(masked) == len(source), repr(source)
        assert strip_comments_and_strings(masked) == masked, repr(source)
        assert len(numbered_lines(masked)) == len(numbered_lines(source)), repr(source)
        # Every replacement is local; original physical newline bytes stay visible.
        for original, actual in zip(source, masked, strict=True):
            assert actual == original or (original not in "\r\n" and actual == " ")


def test_identifiers_and_evidence_projection_are_deterministic_under_repetition() -> (
    None
):
    """Exercise pure identifier/projection invariants over a fixed generated set.
    Return None; preserve ordered extras and inputs without I/O or randomness.
    """
    fragments = ("A", "é", "_", ".", "/", "", "7")
    # Repetition checks the existing pure contracts without a mutable global counter.
    for parts in product(fragments, repeat=2):
        symbol = "".join(parts)
        slug = slugify(symbol)
        assert slugify(slug) == slug
        assert not slug or re.fullmatch(r"[a-z0-9][a-z0-9._-]*", slug)
        detection = Detection(
            "src/input.cs", 2, "type", symbol, "class", (("rank", 1),)
        )
        first = build_evidence_record(
            analyzer_name="synthetic",
            id_prefix="synthetic",
            tool="inventory",
            description="Lexical candidate",
            detection=detection,
            captured_at="2026-01-01T00:00:00Z",
            digest="a" * 64,
        )
        second = build_evidence_record(
            analyzer_name="synthetic",
            id_prefix="synthetic",
            tool="inventory",
            description="Lexical candidate",
            detection=detection,
            captured_at="2026-01-01T00:00:00Z",
            digest="a" * 64,
        )
        assert first == second
        assert first.id == build_evidence_id(
            "synthetic", "type", symbol, "src/input.cs", 2
        )
        assert first.metadata[-1] == ("rank", 1) and detection.symbol == symbol
