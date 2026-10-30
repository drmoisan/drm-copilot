"""Mask non-code C# text and preserve shared lexical evidence contracts.

Masking preserves Python character offsets and every CR/LF. It hides complete
interpolation expressions, including nested literals/comments, without compiling
or evaluating them. Unterminated ordinary literals recover at a physical newline;
unterminated multiline literals or interpolation holes remain masked to EOF.
All public helpers are pure; carrier constructors retain their legacy contracts.
"""

from __future__ import annotations

import hashlib
import re
from dataclasses import dataclass
from typing import Literal

from drm_copilot_discovery.analyzer.models import (
    ClassifyResult,
    EvidenceRecord,
    ParseResult,
)

_ALLOWED_SLUG_CHARS = frozenset("abcdefghijklmnopqrstuvwxyz0123456789._-")
_HASH_SUFFIX_LENGTH = 8
_NEWLINE = re.compile(r"\r\n|\r|\n")
_STRING_START = re.compile(r'(?P<prefix>\$@|@\$|\$+|@)?(?P<quotes>"+)')
_Mode = Literal["char", "regular", "verbatim", "raw", "hole"]


@dataclass(slots=True)
class _Frame:
    """Track one active literal or interpolation hole during a single scan.

    The private scanner creates/pops frames and updates hole brace depth. kind
    selects lexical rules; delimiter is a quote/brace count, interpolation is
    the required opening-brace count. State never escapes or performs I/O.
    """

    kind: _Mode
    delimiter: int = 1
    interpolation: int = 0
    braces: int = 0


class _Masker:
    """Scan one str with an iterative literal stack and offset-preserving buffer.

    Construct then run once. Nested interpolation code is masked, not analyzed;
    comments and nested literals still determine its boundaries. The index only
    advances, output length remains fixed, and only private state is mutated.
    No filesystem, network, clock, recursion or evaluation is used.
    """

    def __init__(self, source: str) -> None:
        """Retain str source and initialize private buffers; return None, no I/O."""
        self.source = source
        self.result = list(source)
        self.index = 0
        self.stack: list[_Frame] = []

    def _blank(self, end: int) -> None:
        """Mask through exclusive int end, clamped to EOF; return None.
        Mutate only the private output/index, preserving every CR and LF.
        """
        end = min(end, len(self.source))
        # Retain physical line delimiters and one output character per input.
        for position in range(self.index, end):
            if self.source[position] not in "\r\n":
                self.result[position] = " "
        self.index = end

    def _run_end(self, character: str) -> int:
        """Return the exclusive end of the current str-character run; pure."""
        end = self.index
        # Count the whole delimiter run so shorter/longer raw quotes stay masked.
        while end < len(self.source) and self.source[end] == character:
            end += 1
        return end

    def _comment(self) -> bool:
        """Consume a comment at the current index; return bool matched.
        Mutate only the scan buffer/index; absent terminators conservatively use EOF.
        """
        # Line comments stop at any physical newline; block comments need */.
        if self.source.startswith("//", self.index):
            newline = _NEWLINE.search(self.source, self.index + 2)
            end = newline.start() if newline else len(self.source)
        elif self.source.startswith("/*", self.index):
            closing = self.source.find("*/", self.index + 2)
            end = closing + 2 if closing >= 0 else len(self.source)
        else:
            return False
        self._blank(end)
        return True

    def _open_string(self) -> bool:
        """Push a recognized string prefix; return bool matched, no external effects.
        Raw delimiters use their entire opening quote count; verbatim uses one.
        """
        match = _STRING_START.match(self.source, self.index)
        if match is None:
            return False
        prefix, quotes = match.group("prefix") or "", match.group("quotes")
        # @ takes precedence over raw quote runs; otherwise three quotes are raw.
        kind: _Mode = (
            "verbatim" if "@" in prefix else "raw" if len(quotes) >= 3 else "regular"
        )
        delimiter = len(quotes) if kind == "raw" else 1
        self.stack.append(_Frame(kind, delimiter, prefix.count("$")))
        self._blank(self.index + len(prefix) + delimiter)
        return True

    def _code(self, hole: _Frame | None) -> None:
        """Advance code or a supplied interpolation _Frame; return None.
        Ordinary code is preserved; hole code is masked and braces are balanced.
        Only scanner state changes; no interpretation or semantic claims occur.
        """
        if self._comment():
            return
        current = self.source[self.index]
        if current == "'":
            self.stack.append(_Frame("char"))
            self._blank(self.index + 1)
            return
        if self._open_string():
            return
        if hole is None:
            self.index += 1
            return
        # Nested code braces must close before the interpolation delimiter can.
        if current == "{":
            hole.braces += 1
        elif current == "}":
            if hole.braces:
                hole.braces -= 1
            elif self.source.startswith("}" * hole.delimiter, self.index):
                self.stack.pop()
                self._blank(self.index + hole.delimiter)
                return
        self._blank(self.index + 1)

    def _literal(self, frame: _Frame) -> None:
        """Advance a supplied literal _Frame; return None, mutating scan state only.
        Respect escapes, exact raw delimiters and nested interpolation boundaries.
        """
        current = self.source[self.index]
        quote = "'" if frame.kind == "char" else '"'
        # Raw strings close only on the same complete quote-run length.
        if frame.kind == "raw" and current == '"':
            end = self._run_end('"')
            if end - self.index == frame.delimiter:
                self.stack.pop()
            self._blank(end)
            return
        if frame.kind != "raw" and current == quote:
            # A doubled verbatim quote is content; other matching quotes close.
            if frame.kind == "verbatim" and self.source.startswith('""', self.index):
                self._blank(self.index + 2)
            else:
                self.stack.pop()
                self._blank(self.index + 1)
            return
        if frame.kind in {"regular", "char"} and current == "\\":
            self._blank(self.index + 2)
            return
        if frame.kind in {"regular", "char"} and current in "\r\n":
            self.stack.pop()
            self._blank(self.index + 1)
            return
        if frame.interpolation and current == "{":
            # Ordinary doubled braces escape; raw brace width follows dollar count.
            if frame.kind != "raw" and self.source.startswith("{{", self.index):
                self._blank(self.index + 2)
                return
            end = self._run_end("{") if frame.kind == "raw" else self.index + 1
            if end - self.index >= frame.interpolation:
                self.stack.append(_Frame("hole", frame.interpolation))
            self._blank(end)
            return
        self._blank(self.index + 1)

    def run(self) -> str:
        """Return the masked str from the retained input; mutate only this scanner.
        An iterative stack supports deep interpolation without recursive calls.
        """
        # Every step advances or consumes a delimiter while preserving offsets.
        while self.index < len(self.source):
            frame = self.stack[-1] if self.stack else None
            if frame is not None and frame.kind != "hole":
                self._literal(frame)
            else:
                self._code(frame)
        return "".join(self.result)


def strip_comments_and_strings(source: str) -> str:
    """Return str source with non-code replaced by spaces, preserving CR/LF.

    Recognize comments, chars, regular/verbatim/interpolated/raw strings and mask
    all interpolation code. No I/O, evaluation or compiler validity is claimed.
    Ordinary unterminated literals recover at physical newlines; incomplete raw,
    verbatim or interpolation constructs remain masked through EOF. Malformed raw
    quote runs are treated conservatively as content rather than false code.
    """
    return _Masker(source).run()


def numbered_lines(text: str) -> list[tuple[int, str]]:
    """Return 1-based (int, str) physical lines for str text; pure.

    Split CRLF, lone CR and LF only. Keep empty input/final lines as before;
    Unicode separators remain source characters rather than extra physical lines.
    """
    return list(enumerate(_NEWLINE.split(text), start=1))


def slugify(value: str) -> str:
    """Return an identifier fragment from str value using the legacy algorithm.
    Lowercase and replace unsupported characters, then trim leading separators;
    the result may be empty. Pure, deterministic, with no I/O or mutation.
    """
    # Normalize each character without changing the established slug grammar.
    normalized = "".join(
        char if char in _ALLOWED_SLUG_CHARS else "-" for char in value.lower()
    )
    return normalized.lstrip("._-")


def build_evidence_id(
    analyzer_prefix: str,
    detection_kind: str,
    symbol: str,
    location: str,
    line: int,
) -> str:
    """Return the legacy deterministic str ID from prefix/kind/symbol/path/line.
    String inputs keep their established meaning; line:int is a 1-based anchor.
    Use symbol or path slug and eight SHA-256 hex digits. Pure; no I/O or counters.
    """
    hash_source = f"{location}:{line}:{detection_kind}:{symbol}"
    hash_suffix = hashlib.sha256(hash_source.encode("utf-8")).hexdigest()[
        :_HASH_SUFFIX_LENGTH
    ]
    slug = slugify(symbol) or slugify(location)
    return f"{analyzer_prefix}-{detection_kind}-{slug}-{hash_suffix}"


@dataclass(frozen=True, slots=True)
class TextParseResult(ParseResult):
    """Carry ordered file text from parsing into pure classification.

    Construct with inherited paths followed by optional file_texts; both are
    tuples, and file_texts contains (path:str, text:str) pairs. Consumers narrow
    ParseResult to this immutable subtype. No I/O or validation is introduced.
    """

    file_texts: tuple[tuple[str, str], ...] = ()


def build_evidence_record(
    *,
    analyzer_name: str,
    id_prefix: str,
    tool: str,
    description: str,
    detection: Detection,
    captured_at: str,
    digest: str,
) -> EvidenceRecord:
    """Return the legacy EvidenceRecord for a typed Detection; pure.

    String arguments supply analyzer/id prefix, tool, generic description,
    externally captured timestamp and original-byte SHA-256 digest. Preserve
    metadata ordering and the detection's extras without I/O or mutation.
    """
    # Keep canonical metadata first and append supplied extras in their original order.
    metadata: tuple[tuple[str, str | int], ...] = (
        ("analyzer", analyzer_name),
        ("detection_kind", detection.detection_kind),
        ("symbol", detection.symbol),
        ("symbol_kind", detection.symbol_kind),
        ("line", detection.line),
        *detection.extra,
    )
    return EvidenceRecord(
        id=build_evidence_id(
            id_prefix,
            detection.detection_kind,
            detection.symbol,
            detection.path,
            detection.line,
        ),
        kind="file",
        location=detection.path,
        captured_at=captured_at,
        description=description,
        content_hash=("sha256", digest),
        tool=tool,
        metadata=metadata,
    )


@dataclass(frozen=True, slots=True)
class Detection:
    """Carry one lexical observation into evidence projection without I/O.

    Construct with path:str, line:int, detection_kind:str, symbol:str and
    symbol_kind:str, followed by optional extra metadata pairs. The ordered,
    immutable fields preserve legacy positional/default contracts and describe
    a textual candidate, never a compiler-verified or runtime fact.
    """

    path: str
    line: int
    detection_kind: str
    symbol: str
    symbol_kind: str
    extra: tuple[tuple[str, str | int], ...] = ()


@dataclass(frozen=True, slots=True)
class DetectionResult(ClassifyResult):
    """Carry ordered Detection values from classification into mapping.

    Construct with inherited units then optional detections:tuple[Detection,...].
    Consumers narrow ClassifyResult to this frozen subtype; neither the existing
    constructor/defaults nor the neutral base carrier change. No I/O or mutation.
    """

    detections: tuple[Detection, ...] = ()
