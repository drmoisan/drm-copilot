"""Shared pure text-scanning helpers for the stack-specific analyzers.

Purpose:
    Provide the stdlib-only, I/O-free building blocks that both the .NET/C#
    inventory analyzer and the VSTO/Office analyzer use during their pure
    ``classify`` stage:

    - ``strip_comments_and_strings``: a line-number-preserving C# comment and
      string-literal stripper that blanks non-code spans so declaration-shaped
      text inside comments and strings cannot produce false detections while
      line and column offsets are preserved.
    - ``slugify`` and ``build_evidence_id``: pure identifier helpers producing
      deterministic Evidence Reference ids that match the shared discovery
      identifier grammar ``^[a-z0-9][a-z0-9._-]*$``.
    - ``numbered_lines``: a 1-based line-numbering utility for line-anchored
      pattern scanning.
    - ``TextParseResult``: a frozen ``ParseResult`` subtype carrying file text
      from the I/O ``parse`` stage into the pure ``classify`` stage.

Heuristic scope (normative):
    These helpers support heuristic textual evidence scanning, not compilation.
    The stripper handles the common C# comment and string forms; raw string
    literals (``\"\"\"``) and deeply nested string interpolation are handled on a
    best-effort basis only. Detections built on top of these helpers record an
    observed textual pattern at a file/line anchor, never a compiler-verified
    symbol table.

Invariants / Constraints:
    - Every function is pure: no filesystem, network, clock, or global state.
    - The stripper preserves the exact character length of its input (each
      non-code character becomes a single space, and newlines are preserved), so
      1-based line numbers and column offsets survive stripping.
    - Ids are pure functions of their inputs (no clock, no counter).

Side Effects:
    None.
"""

from __future__ import annotations

import hashlib
from dataclasses import dataclass

from scripts.dev_tools.discovery.analyzer.models import (
    ClassifyResult,
    EvidenceRecord,
    ParseResult,
)

# Characters permitted in a slug after normalization. The identifier grammar
# ``^[a-z0-9][a-z0-9._-]*$`` allows lowercase alphanumerics plus dot, underscore,
# and hyphen; every other character is normalized to a hyphen by ``slugify``.
_ALLOWED_SLUG_CHARS = frozenset("abcdefghijklmnopqrstuvwxyz0123456789._-")

# Number of leading hex characters of the SHA-256 disambiguation digest embedded
# in an evidence id. Eight hex characters give 32 bits of collision resistance,
# which is sufficient to disambiguate identical symbols at different locations.
_HASH_SUFFIX_LENGTH = 8


def _consume_char_literal(source: str, start: int, result: list[str]) -> int:
    """Blank a C# character literal starting at ``start`` (best-effort, pure).

    Args:
        source: The full source text being scanned.
        start: Index of the opening single quote.
        result: Mutable output buffer receiving one blanked character per input
            character consumed.

    Returns:
        The index immediately after the consumed character literal.

    Side Effects:
        Appends blanked characters to ``result``.
    """
    length = len(source)
    index = start
    # Blank the opening quote, then consume until the closing quote, honoring
    # backslash escapes so an escaped quote does not terminate the literal early.
    result.append(" ")
    index += 1
    while index < length:
        current = source[index]
        if current == "\\" and index + 1 < length:
            # A backslash escape consumes the following character as part of the
            # literal; blank both so neither is treated as code.
            result.append(" ")
            result.append("\n" if source[index + 1] == "\n" else " ")
            index += 2
            continue
        if current == "'":
            result.append(" ")
            index += 1
            break
        if current == "\n":
            # An unterminated char literal ends at the line break (best-effort).
            result.append("\n")
            index += 1
            break
        result.append(" ")
        index += 1
    return index


def _consume_string(source: str, start: int, result: list[str]) -> int | None:
    """Blank a C# string literal starting at ``start`` if one begins there.

    Handles the four common prefix forms: regular (``"``), verbatim (``@"``),
    interpolated (``$"``), and interpolated-verbatim (``$@"`` / ``@$"``). The
    entire literal, including its delimiters and any interpolation expressions,
    is blanked; this is intentionally conservative so declaration-shaped text
    inside a string cannot match a detection pattern.

    Args:
        source: The full source text being scanned.
        start: Candidate index of a string-literal prefix or opening quote.
        result: Mutable output buffer receiving blanked characters.

    Returns:
        The index immediately after the consumed string literal, or ``None`` when
        no string literal begins at ``start``.

    Side Effects:
        Appends blanked characters to ``result`` only when a string is consumed.
    """
    length = len(source)
    index = start
    verbatim = False
    prefix_length = 0

    # Decision table for the string-literal prefix. Order matters: the two-symbol
    # interpolated-verbatim prefixes must be tested before the single-symbol
    # verbatim and interpolated prefixes so the longer prefix wins.
    if (
        source[index] == "@"
        and index + 2 < length
        and source[index + 1] == "$"
        and source[index + 2] == '"'
    ):
        verbatim = True
        prefix_length = 2
    elif (
        source[index] == "$"
        and index + 2 < length
        and source[index + 1] == "@"
        and source[index + 2] == '"'
    ):
        verbatim = True
        prefix_length = 2
    elif source[index] == "@" and index + 1 < length and source[index + 1] == '"':
        verbatim = True
        prefix_length = 1
    elif source[index] == "$" and index + 1 < length and source[index + 1] == '"':
        prefix_length = 1
    elif source[index] == '"':
        prefix_length = 0
    else:
        return None

    # Blank the prefix symbols and the opening quote.
    for _ in range(prefix_length + 1):
        result.append(" ")
        index += 1

    # Consume the body. Verbatim strings treat a doubled quote as an escaped
    # quote and span newlines; non-verbatim strings honor backslash escapes and
    # terminate at a line break if unterminated (best-effort).
    while index < length:
        current = source[index]
        if verbatim:
            if current == '"':
                if index + 1 < length and source[index + 1] == '"':
                    result.append(" ")
                    result.append(" ")
                    index += 2
                    continue
                result.append(" ")
                index += 1
                break
            result.append("\n" if current == "\n" else " ")
            index += 1
            continue
        if current == "\\" and index + 1 < length:
            result.append(" ")
            result.append("\n" if source[index + 1] == "\n" else " ")
            index += 2
            continue
        if current == '"':
            result.append(" ")
            index += 1
            break
        if current == "\n":
            result.append("\n")
            index += 1
            break
        result.append(" ")
        index += 1
    return index


def strip_comments_and_strings(source: str) -> str:
    """Blank C# comment and string spans while preserving line/column offsets.

    Performs a single left-to-right character scan tracking code, ``//`` line
    comments, ``/* */`` block comments, and string/char literals. Non-code
    characters are replaced by spaces and newlines are preserved, so the returned
    text has the same length and line structure as the input; a 1-based line and
    column computed over the stripped text refers to the same position in the
    original source.

    Args:
        source: Raw C# source text.

    Returns:
        The source with every comment and string span blanked to spaces, line
        breaks preserved.

    Notes:
        Raw string literals (``\"\"\"``) and deeply nested interpolation are
        best-effort per the feature's stated regex-scanning limitations.
    """
    result: list[str] = []
    index = 0
    length = len(source)
    while index < length:
        current = source[index]
        # Line comment: blank from the ``//`` to the end of the line.
        if current == "/" and index + 1 < length and source[index + 1] == "/":
            while index < length and source[index] != "\n":
                result.append(" ")
                index += 1
            continue
        # Block comment: blank the ``/*`` and everything through the ``*/``.
        if current == "/" and index + 1 < length and source[index + 1] == "*":
            result.append(" ")
            result.append(" ")
            index += 2
            while index < length and not (
                source[index] == "*" and index + 1 < length and source[index + 1] == "/"
            ):
                result.append("\n" if source[index] == "\n" else " ")
                index += 1
            # Blank the closing ``*/`` when present (absent only if unterminated).
            if index < length:
                result.append(" ")
                index += 1
            if index < length:
                result.append(" ")
                index += 1
            continue
        # Character literal.
        if current == "'":
            index = _consume_char_literal(source, index, result)
            continue
        # String literal (any prefix form); ``None`` means no string starts here.
        consumed = _consume_string(source, index, result)
        if consumed is not None:
            index = consumed
            continue
        # Plain code character is preserved verbatim.
        result.append(current)
        index += 1
    return "".join(result)


def numbered_lines(text: str) -> list[tuple[int, str]]:
    """Return ``(line_number, line_text)`` pairs with 1-based line numbers.

    Splitting on ``"\\n"`` (rather than ``str.splitlines``) keeps the line count
    aligned with the newline-preserving output of ``strip_comments_and_strings``,
    so a line number computed here indexes the same line in the original source.

    Args:
        text: Text to enumerate (typically stripped C# source).

    Returns:
        A list of ``(line_number, line_text)`` pairs, line numbers starting at 1.
    """
    return list(enumerate(text.split("\n"), start=1))


def slugify(value: str) -> str:
    """Normalize ``value`` into an identifier slug fragment (pure).

    Lowercases the input, replaces every character outside ``[a-z0-9._-]`` with a
    hyphen, and strips leading ``.``/``_``/``-`` so the result begins with an
    alphanumeric character (or is empty). The output is safe to embed inside an
    id that must match ``^[a-z0-9][a-z0-9._-]*$`` provided the surrounding id
    starts with an alphanumeric prefix.

    Args:
        value: Arbitrary symbol or path text.

    Returns:
        The normalized slug fragment; may be empty when ``value`` contains no
        alphanumeric characters.
    """
    # Normalize each character to the allowed set, mapping anything else to '-'.
    normalized = "".join(
        char if char in _ALLOWED_SLUG_CHARS else "-" for char in value.lower()
    )
    # The grammar requires an alphanumeric first character; drop leading
    # separators that would otherwise violate it.
    return normalized.lstrip("._-")


def build_evidence_id(
    analyzer_prefix: str,
    detection_kind: str,
    symbol: str,
    location: str,
    line: int,
) -> str:
    """Build a deterministic Evidence Reference id (pure).

    The id has the shape ``<analyzer-prefix>-<detection_kind>-<slug>-<hash8>``,
    where ``slug`` is the slugified symbol (falling back to the slugified
    location when the symbol is empty) and ``hash8`` is the first eight hex
    characters of ``sha256(location + ":" + line + ":" + detection_kind + ":" +
    symbol)``. The hash disambiguates identical symbols at different locations or
    lines; the function reads no clock and keeps no counter, so repeated calls
    with the same inputs return the same id.

    Args:
        analyzer_prefix: Stable analyzer id prefix (for example ``"dotnet"``);
            must start with an alphanumeric so the overall id satisfies the
            identifier grammar.
        detection_kind: Normative detection-kind token (lowercase, underscore).
        symbol: The detected symbol text; may be empty for symbol-less matches.
        location: Consumer-relative POSIX path of the source file.
        line: 1-based line number of the detection.

    Returns:
        An id string matching ``^[a-z0-9][a-z0-9._-]*$``.
    """
    hash_source = f"{location}:{line}:{detection_kind}:{symbol}"
    hash_suffix = hashlib.sha256(hash_source.encode("utf-8")).hexdigest()[
        :_HASH_SUFFIX_LENGTH
    ]
    slug = slugify(symbol) or slugify(location)
    return f"{analyzer_prefix}-{detection_kind}-{slug}-{hash_suffix}"


@dataclass(frozen=True, slots=True)
class TextParseResult(ParseResult):
    """A ``ParseResult`` carrying file text from ``parse`` into ``classify``.

    The #363 ``ParseResult`` contract is paths-only. Both stack-specific
    analyzers need file text to flow from the I/O ``parse`` stage into the pure
    ``classify`` stage without ``classify`` performing I/O. This frozen subtype
    adds ``file_texts`` alongside the inherited ``paths`` field. ``parse`` returns
    this subtype (a covariant return that satisfies the ``Analyzer`` protocol);
    ``classify`` accepts ``ParseResult`` and isinstance-narrows to this type,
    raising ``AnalyzerError`` on a plain ``ParseResult``.

    Coordination note (recorded, not a blocker):
        This subtype is the adopted no-#363-change approach. The preferred
        long-term resolution is for #363 to genericize ``ParseResult`` with an
        optional payload field before its contract freezes; that
        ParseResult-payload genericization is an open coordination item to raise
        with #363 at integration-branch time. See
        ``docs/features/active/2026-07-17-legacy-discovery-dotnet-vsto-analyzers-369/coordination/text-parse-result-reconciliation.md``.

    Args:
        paths: Inherited ordered consumer-relative POSIX paths.
        file_texts: Ordered ``(consumer-relative POSIX path, text)`` pairs for the
            selected candidate files, in the same order as ``paths``.
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
    """Assemble one Evidence Reference record from a detection (pure).

    Shared by both stack-specific analyzers. All detection specifics are placed
    only inside ``metadata``; no detection-specific value appears in a top-level
    field. The ``analyzer``, ``detection_kind``, ``symbol``, ``symbol_kind``, and
    ``line`` metadata keys precede the detection's own ``extra`` pairs.

    Args:
        analyzer_name: The producing analyzer's ``name`` (``metadata.analyzer``).
        id_prefix: Stable id prefix for ``build_evidence_id``.
        tool: The invoking console-script name (top-level ``tool``).
        description: Static, generic, symbol-free detection description.
        detection: The detection to serialize.
        captured_at: ISO-8601 timestamp from the injected clock.
        digest: Hex SHA-256 of the source file bytes for the integrity digest.

    Returns:
        The assembled ``EvidenceRecord``.
    """
    # Serialization sorts keys, so tuple order here is not significant; base keys
    # precede the detection's own specifics for readability.
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
    """One heuristic textual detection produced by a stack-specific analyzer.

    A pure value object shared by both the .NET/C# and VSTO/Office analyzers. It
    records an observed textual pattern anchored to a file and 1-based line; it is
    never a compiler-verified symbol. The ``map`` stage turns each ``Detection``
    into one Evidence Reference instance.

    Args:
        path: Consumer-relative POSIX path of the source file.
        line: 1-based line number where the pattern was observed.
        detection_kind: Normative detection-kind vocabulary token.
        symbol: The detected symbol text; may be empty for symbol-less matches.
        symbol_kind: Normalized symbol-kind vocabulary token.
        extra: Ordered detection-specific ``(key, value)`` metadata pairs (for
            example ``declaration_form``, ``generic``, ``confidence``,
            ``customui_schema``, ``com_guid``, ``interop_target``).
    """

    path: str
    line: int
    detection_kind: str
    symbol: str
    symbol_kind: str
    extra: tuple[tuple[str, str | int], ...] = ()


@dataclass(frozen=True, slots=True)
class DetectionResult(ClassifyResult):
    """A ``ClassifyResult`` carrying rich detections into the ``map`` stage.

    The #363 ``ClassifyResult`` carries neutral ``ClassifiedUnit`` values only.
    The stack-specific analyzers need to thread typed ``Detection`` objects from
    ``classify`` into ``map`` without reading I/O in ``map``. This frozen subtype
    adds ``detections`` alongside the inherited ``units`` field. ``classify``
    returns this subtype (a covariant return satisfying the ``Analyzer``
    protocol); ``map`` accepts ``ClassifyResult`` and isinstance-narrows to this
    type, raising ``AnalyzerError`` on a plain ``ClassifyResult``.

    Args:
        units: Inherited neutral classified units (unused by these analyzers,
            defaulting to empty).
        detections: Ordered heuristic detections produced by ``classify``.
    """

    detections: tuple[Detection, ...] = ()
