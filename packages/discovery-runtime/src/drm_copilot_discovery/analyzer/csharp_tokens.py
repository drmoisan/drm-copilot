"""Tokenize bounded masked C# text without evaluating or binding source code.

Literal identifier spellings and decoded-character offsets remain unchanged.
Physical CRLF/CR/LF anchors describe inspected text, not compiler source maps.
"""

from __future__ import annotations

import codecs
import unicodedata
from dataclasses import dataclass

_INITIAL = frozenset({"Lu", "Ll", "Lt", "Lm", "Lo", "Nl"})
_CONTINUATION = _INITIAL | {"Mn", "Mc", "Nd", "Pc", "Cf"}
_PAIRS = frozenset({"+=", "-=", "=>", "::", "?.", "??", "==", "!=", "&&", "||"})


class SourceScanError(ValueError):
    """Reject unsupported encoding, malformed identifiers or bounded lexical input.

    Construct with a stable code and actionable message. Callers may convert the
    error into a diagnostic; no partial token stream, I/O or mutation is exposed.
    """

    def __init__(self, code: str, message: str) -> None:
        """Store code/message (str); return None and initialize this error only."""
        super().__init__(message)
        self.code = code


@dataclass(frozen=True, kw_only=True)
class Token:
    """Retain one literal token and its physical source anchor, without I/O.

    value is the original spelling; start/end are decoded-character offsets with
    an exclusive end; line is one-based. identifier distinguishes identifier-like
    syntax from punctuation/numbers, without resolving keywords or symbols.
    """

    value: str
    start: int
    end: int
    line: int
    identifier: bool

    def __post_init__(self) -> None:
        """Validate str/int/bool fields; return None or raise ValueError; pure."""
        if not self.value or self.start < 0 or self.end <= self.start or self.line < 1:
            raise ValueError("Tokens require a spelling, positive span and line")
        if self.end - self.start != len(self.value):
            raise ValueError("Token span must retain the original spelling")


def decode_source(content: bytes, *, max_bytes: int = 67108864) -> str:
    """Decode retained bytes strictly as UTF-8 or BOM-declared UTF-16/32; pure.

    content (bytes) is the payload later hashed; max_bytes (int) is a positive
    allocation bound up to 64 MiB. Returns str with every physical newline intact.
    Raises ValueError for invalid limits and SourceScanError for size/encoding
    failures. No replacement characters, file reads or encoding guesses occur.
    """
    if isinstance(max_bytes, bool) or not 1 <= max_bytes <= 67108864:
        raise ValueError("Source byte limit must be between 1 and 67108864")
    if len(content) > max_bytes:
        raise SourceScanError("source-limit", "C# input exceeds its byte limit.")
    # UTF-32 BOMs must precede their UTF-16 prefixes to avoid ambiguous decoding.
    if content.startswith((codecs.BOM_UTF32_LE, codecs.BOM_UTF32_BE)):
        encoding = "utf-32"
    elif content.startswith((codecs.BOM_UTF16_LE, codecs.BOM_UTF16_BE)):
        encoding = "utf-16"
    else:
        encoding = "utf-8-sig"
    try:
        text = content.decode(encoding, errors="strict")
    except UnicodeError as exc:
        raise SourceScanError(
            "source-encoding", "C# input must be valid UTF-8 or BOM-declared UTF-16/32."
        ) from exc
    if "\x00" in text:
        raise SourceScanError("source-encoding", "C# input contains a NUL character.")
    return text


def _character(text: str, index: int) -> tuple[str, int]:
    """Decode one identifier character while preserving its literal span; pure.

    text (str) and index (int) address a nonempty suffix. Returns (character:str,
    exclusive_end:int). SourceScanError rejects malformed Unicode escapes; invalid
    internal indexes raise IndexError. No normalization or binding occurs.
    """
    if text[index] != "\\":
        return text[index], index + 1
    width = {"u": 4, "U": 8}.get(text[index + 1 : index + 2])
    digits = text[index + 2 : index + 2 + (width or 0)]
    if (
        width is None
        or len(digits) != width
        or any(char not in "0123456789abcdefABCDEF" for char in digits)
    ):
        raise SourceScanError(
            "source-identifier", "Malformed Unicode identifier escape."
        )
    value = int(digits, 16)
    if value > 0x10FFFF or 0xD800 <= value <= 0xDFFF:
        raise SourceScanError("source-identifier", "Identifier escape is not a scalar.")
    return chr(value), index + 2 + width


def _identifier_end(text: str, start: int) -> int:
    """Consume literal or escaped identifier syntax from str text at int start.

    Returns exclusive int end, or start when the first character cannot begin an
    identifier. SourceScanError rejects invalid escaped characters/verbatim names.
    No normalization, keyword classification, I/O or input mutation occurs.
    """
    position = start + int(text[start] == "@")
    first = True
    # Unicode categories implement lexical spelling rules, not symbol identity.
    while position < len(text):
        character, end = _character(text, position)
        permitted = character == "_" or unicodedata.category(character) in (
            _INITIAL if first else _CONTINUATION
        )
        if not permitted:
            if text[position] == "\\":
                raise SourceScanError(
                    "source-identifier",
                    "Escaped character is invalid in an identifier.",
                )
            break
        first = False
        position = end
    if first and text[start] == "@":
        raise SourceScanError("source-identifier", "Verbatim identifier has no name.")
    return start if first else position


def tokenize_csharp(text: str, *, max_tokens: int = 100000) -> tuple[Token, ...]:
    """Return bounded immutable tokens from already masked str text; pure.

    max_tokens (int) is in [1,100000]. Spelling, offsets and CRLF/CR/LF physical
    lines are retained; directive lines are omitted without evaluating branches.
    Raises ValueError for invalid limits; SourceScanError for invalid identifier,
    NUL/surrogate or over-budget text/tokens. Caller must mask strings/comments.
    """
    if isinstance(max_tokens, bool) or not 1 <= max_tokens <= 100000:
        raise ValueError("Token limit must be between 1 and 100000")
    if len(text) > 67108864:
        raise SourceScanError("source-limit", "C# text exceeds its character limit.")
    tokens: list[Token] = []
    index = 0
    line = 1
    # Consume each character once, preserving physical offsets and bounding storage.
    while index < len(text):
        character = text[index]
        if character == "\x00" or 0xD800 <= ord(character) <= 0xDFFF:
            raise SourceScanError(
                "source-encoding", "C# text contains invalid scalars."
            )
        # CRLF is one boundary; other Unicode whitespace never increments anchors.
        if character in "\r\n":
            index += 2 if text.startswith("\r\n", index) else 1
            line += 1
            continue
        if character.isspace():
            index += 1
            continue
        if character == "#":
            # Directive syntax cannot become false declarations in the token stream.
            while index < len(text) and text[index] not in "\r\n":
                index += 1
            continue
        if len(tokens) >= max_tokens:
            raise SourceScanError("source-token-limit", "C# token limit exceeded.")
        end = _identifier_end(text, index)
        identifier = end > index
        if not identifier:
            end = index + (2 if text[index : index + 2] in _PAIRS else 1)
        tokens.append(
            Token(
                value=text[index:end],
                start=index,
                end=end,
                line=line,
                identifier=identifier,
            )
        )
        index = end
    return tuple(tokens)
