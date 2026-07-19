"""The .NET/C# inventory analyzer (namespace, type, event, subscription).

Purpose:
    Implement a concrete stack-specific ``Analyzer`` (structural, no base class,
    no registry) that enumerates C# namespaces and types and detects event and
    delegate declarations and ``+=``/``-=`` handler subscriptions over C# source.
    Every match becomes one Evidence Reference v1 instance via the reused #363
    emitter.

Heuristic scope (normative):
    This analyzer is a heuristic textual evidence scanner, not a compiler. All C#
    patterns run over comment/string-stripped text (see ``source_text``) and are
    line-anchored so mid-expression text rarely matches. Detections record an
    observed textual pattern at a file/line anchor; no type resolution, scope
    resolution, or preprocessor evaluation is performed. Handler-subscription
    detection is the highest false-positive-risk pattern and is explicitly tagged
    ``confidence = "heuristic"``; the residual risk of a member-access right-hand
    side (for example ``x += y.Count``) is accepted and documented.

Invariants / Constraints:
    - ``parse`` performs the only I/O (walk + read via the seam); ``classify`` and
      ``map``'s detection logic are pure. No stack-specific consumer identifier is
      hardcoded; the stack literals (``class``, ``record``, and so on) are the
      generic subject matter of a C# analyzer.
    - ``classify`` isinstance-narrows to ``TextParseResult`` and ``map``
      isinstance-narrows to ``DetectionResult``, raising ``AnalyzerError`` on the
      plain base type (fail-fast).
    - Enumeration is deterministic (POSIX-sorted candidate order); ids are pure
      functions of ``(location, line, detection_kind, symbol)``.

Side Effects:
    Stage methods read and write only through the injected filesystem seam.
"""

from __future__ import annotations

import hashlib
import re
from typing import TYPE_CHECKING

from scripts.dev_tools.discovery.analyzer.emitter import serialize_record
from scripts.dev_tools.discovery.analyzer.inventory import AnalyzerError, filter_paths
from scripts.dev_tools.discovery.analyzer.pipeline import RealAnalyzerFileSystem
from scripts.dev_tools.discovery.analyzer.source_text import (
    Detection,
    DetectionResult,
    TextParseResult,
    build_evidence_record,
    numbered_lines,
    strip_comments_and_strings,
)

if TYPE_CHECKING:
    from pathlib import Path

    from scripts.dev_tools.discovery.analyzer.models import (
        AnalyzerContext,
        ClassifyResult,
        EvidenceRecord,
        ParseResult,
    )
    from scripts.dev_tools.discovery.analyzer.pipeline import AnalyzerFileSystem

_ANALYZER_NAME = "dotnet-inventory"
_ID_PREFIX = "dotnet"
_TOOL = "dev.discovery.dotnet"

# File-scoped namespace form (C# 10): ``namespace A.B;`` on its own line.
_NAMESPACE_FILE_SCOPED_RE = re.compile(r"^\s*namespace\s+(?P<name>[\w.]+)\s*;\s*$")

# Block namespace form: ``namespace A.B`` with the opening brace on the same or
# the next line (nested block namespaces appear as independent lines).
_NAMESPACE_BLOCK_RE = re.compile(r"^\s*namespace\s+(?P<name>[\w.]+)\s*\{?\s*$")

# Type declaration covering class/struct/interface/enum and the three record
# forms, tolerating same-line attribute groups, a modifier stack, and a single
# level of generic parameters. Attribute-only lines simply do not match.
_TYPE_RE = re.compile(
    r"^\s*(?:\[[^\]]*\]\s*)*"
    r"(?:(?:public|private|protected|internal|static|sealed|abstract|partial|"
    r"readonly|ref|unsafe|new|virtual|override|file|extern)\s+)*"
    r"(?P<kw>record\s+class|record\s+struct|record|class|struct|interface|enum)"
    r"\s+(?P<name>[A-Za-z_]\w*)\s*(?P<generic><[^<>]*>)?"
)

# Event declaration (field-like ``;``/``=`` and custom-accessor ``{`` forms).
_EVENT_RE = re.compile(
    r"^\s*(?:\[[^\]]*\]\s*)*"
    r"(?:(?:public|private|protected|internal|static|virtual|override|abstract|"
    r"sealed|new)\s+)*"
    r"event\s+(?P<type>[\w.<>,\[\]\s]+?)\s+(?P<name>[A-Za-z_]\w*)\s*(?:;|=|\{|$)"
)

# Delegate type declaration.
_DELEGATE_RE = re.compile(
    r"^\s*(?:\[[^\]]*\]\s*)*"
    r"(?:(?:public|private|protected|internal|static|new)\s+)*"
    r"delegate\s+[\w.<>,\[\]\s]+?\s+(?P<name>[A-Za-z_]\w*)\s*(?:<[^<>]*>)?\s*\("
)

# Handler subscription/unsubscription: ``target += handler;`` / ``target -= ...``.
_SUBSCRIPTION_RE = re.compile(
    r"(?P<lhs>[A-Za-z_][\w.]*)\s*(?P<op>\+=|-=)\s*(?P<rhs>[^;]*);"
)

# Normalization of the raw type keyword into the symbol-kind vocabulary.
_SYMBOL_KIND_BY_KEYWORD: dict[str, str] = {
    "class": "class",
    "struct": "struct",
    "interface": "interface",
    "enum": "enum",
    "record": "record",
    "record class": "record",
    "record struct": "record_struct",
}

# Static, generic, symbol-free descriptions keyed by detection kind. No consumer
# identifier and no detected symbol appears here; the symbol lives in metadata.
_DESCRIPTIONS: dict[str, str] = {
    "namespace": "Heuristic textual detection of a C# namespace declaration.",
    "type": "Heuristic textual detection of a C# type declaration.",
    "event_declaration": "Heuristic textual detection of a C# event declaration.",
    "delegate": "Heuristic textual detection of a C# delegate declaration.",
    "event_subscription": (
        "Heuristic textual detection of a C# event handler subscription."
    ),
}


def _generic_arity(generic_text: str | None) -> int:
    """Return the generic arity captured from a ``<...>`` fragment (pure).

    Args:
        generic_text: The matched generic fragment including angle brackets, or
            ``None`` when the declaration is non-generic.

    Returns:
        The number of comma-separated type parameters, or ``0`` when non-generic.
    """
    if not generic_text:
        return 0
    inner = generic_text.strip()[1:-1].strip()
    if not inner:
        return 0
    # Count comma-separated parameters at the single supported nesting level.
    return inner.count(",") + 1


def _is_probable_handler(rhs: str) -> bool:
    """Decide whether a ``+=``/``-=`` right-hand side is a handler (pure).

    Applies the documented literal-rejection filter: reject a right-hand side
    that is empty or begins with a numeric, string, or char literal; accept one
    that contains ``=>`` (lambda), ``new `` (delegate construction), ``delegate``
    (anonymous method), or is a bare dotted-identifier method group.

    Args:
        rhs: The right-hand side text (already comment/string-stripped).

    Returns:
        ``True`` when the right-hand side is a probable event handler.
    """
    candidate = rhs.strip()
    if not candidate:
        # On stripped text a string/char handler collapses to blanks; reject.
        return False
    first = candidate[0]
    # A leading numeric/string/char literal indicates arithmetic, not a handler.
    if first.isdigit() or first in {'"', "'"}:
        return False
    # Strong positive signals for a delegate/lambda/anonymous-method handler.
    if "=>" in candidate or "new " in candidate or "delegate" in candidate:
        return True
    # A bare dotted-identifier is treated as a method-group handler.
    return re.fullmatch(r"[A-Za-z_][\w.]*", candidate) is not None


def _detect_namespace(path: str, lineno: int, line: str) -> Detection | None:
    """Detect a namespace declaration on one stripped line (pure)."""
    # File-scoped form is tested first because it ends with ``;`` while the block
    # form permits a trailing brace or nothing.
    file_scoped = _NAMESPACE_FILE_SCOPED_RE.match(line)
    if file_scoped is not None:
        return Detection(
            path=path,
            line=lineno,
            detection_kind="namespace",
            symbol=file_scoped.group("name"),
            symbol_kind="namespace",
            extra=(("declaration_form", "file_scoped"),),
        )
    block = _NAMESPACE_BLOCK_RE.match(line)
    if block is not None:
        return Detection(
            path=path,
            line=lineno,
            detection_kind="namespace",
            symbol=block.group("name"),
            symbol_kind="namespace",
            extra=(("declaration_form", "block"),),
        )
    return None


def _detect_type(path: str, lineno: int, line: str) -> Detection | None:
    """Detect a type declaration on one stripped line (pure)."""
    match = _TYPE_RE.match(line)
    if match is None:
        return None
    keyword = re.sub(r"\s+", " ", match.group("kw").strip())
    symbol_kind = _SYMBOL_KIND_BY_KEYWORD[keyword]
    arity = _generic_arity(match.group("generic"))
    # Record generic arity only when the type is generic to keep metadata lean.
    extra: tuple[tuple[str, str | int], ...] = (
        (("generic", arity),) if arity > 0 else ()
    )
    return Detection(
        path=path,
        line=lineno,
        detection_kind="type",
        symbol=match.group("name"),
        symbol_kind=symbol_kind,
        extra=extra,
    )


def _detect_event_or_delegate(path: str, lineno: int, line: str) -> Detection | None:
    """Detect an event or delegate declaration on one stripped line (pure)."""
    event = _EVENT_RE.match(line)
    if event is not None:
        return Detection(
            path=path,
            line=lineno,
            detection_kind="event_declaration",
            symbol=event.group("name"),
            symbol_kind="event",
        )
    delegate = _DELEGATE_RE.match(line)
    if delegate is not None:
        return Detection(
            path=path,
            line=lineno,
            detection_kind="delegate",
            symbol=delegate.group("name"),
            symbol_kind="delegate",
        )
    return None


def _detect_subscriptions(path: str, lineno: int, line: str) -> list[Detection]:
    """Detect ``+=``/``-=`` handler subscriptions on one stripped line (pure)."""
    detections: list[Detection] = []
    # A line may contain more than one subscription; scan every match and keep
    # only those whose right-hand side survives the literal-rejection filter.
    for match in _SUBSCRIPTION_RE.finditer(line):
        if not _is_probable_handler(match.group("rhs")):
            continue
        detections.append(
            Detection(
                path=path,
                line=lineno,
                detection_kind="event_subscription",
                symbol=match.group("lhs"),
                symbol_kind="event",
                extra=(
                    ("operator", match.group("op")),
                    ("confidence", "heuristic"),
                ),
            )
        )
    return detections


def classify_text(path: str, text: str) -> list[Detection]:
    """Detect all C# patterns in one file's text (pure; strips first).

    Args:
        path: Consumer-relative POSIX path used as the detection anchor.
        text: Raw C# source text for the file.

    Returns:
        Ordered detections for the file, top-to-bottom by line.
    """
    stripped = strip_comments_and_strings(text)
    detections: list[Detection] = []
    # Walk every line once, applying the anchored declaration catalog (at most one
    # declaration per line) and then the mid-line subscription scan.
    for lineno, line in numbered_lines(stripped):
        declaration = (
            _detect_namespace(path, lineno, line)
            or _detect_type(path, lineno, line)
            or _detect_event_or_delegate(path, lineno, line)
        )
        if declaration is not None:
            detections.append(declaration)
        detections.extend(_detect_subscriptions(path, lineno, line))
    return detections


class DotnetInventoryAnalyzer:
    """.NET/C# inventory analyzer implementing the #363 ``Analyzer`` protocol.

    Purpose:
        Enumerate C# namespaces and types and detect event/delegate declarations
        and handler subscriptions, emitting one Evidence Reference instance per
        detection.

    Usage:
        Constructed by the CLI and handed to ``run_analyzer(analyzer, ctx, fs)``,
        which drives ``parse -> classify -> map -> emit`` in order.

    Invariants:
        ``parse`` is the only I/O stage; ``classify`` is pure; ``map`` reads file
        bytes (cached per path) for integrity hashing via the seam.

    Args:
        fs: Filesystem seam used by ``parse`` and ``map``; defaults to the real
            filesystem implementation.
    """

    name = _ANALYZER_NAME

    def __init__(self, fs: AnalyzerFileSystem | None = None) -> None:
        self._fs: AnalyzerFileSystem = (
            fs if fs is not None else RealAnalyzerFileSystem()
        )
        self._ctx: AnalyzerContext | None = None

    def _require_ctx(self) -> AnalyzerContext:
        """Return the stashed run context, failing if ``parse`` did not run."""
        if self._ctx is None:
            raise AnalyzerError("analyzer context is unavailable; parse must run first")
        return self._ctx

    def parse(self, ctx: AnalyzerContext) -> ParseResult:
        """Walk the tree, select ``.cs`` candidates, and read their text.

        Args:
            ctx: The resolved run context.

        Returns:
            A ``TextParseResult`` of ordered ``.cs`` paths and their text.

        Raises:
            AnalyzerError: When the source root is unreachable or not a directory.
        """
        self._ctx = ctx
        root = ctx.source_root
        if not self._fs.exists(root) or not self._fs.is_dir(root):
            raise AnalyzerError(f"source root is not reachable: {root}")
        ordered = tuple(
            sorted(
                file_path.relative_to(root).as_posix()
                for file_path in self._fs.walk_files(root)
            )
        )
        filtered = filter_paths(ordered, ctx.include, ctx.exclude)
        # Only C# source participates in the .NET inventory analyzer.
        candidates = tuple(path for path in filtered if path.endswith(".cs"))
        file_texts = tuple(
            (path, self._fs.read_bytes(root / path).decode("utf-8", errors="replace"))
            for path in candidates
        )
        return TextParseResult(paths=candidates, file_texts=file_texts)

    def classify(self, parsed: ParseResult) -> ClassifyResult:
        """Strip and scan each file's text into typed detections (pure).

        Args:
            parsed: The parse result; must be a ``TextParseResult``.

        Returns:
            A ``DetectionResult`` carrying every detection.

        Raises:
            AnalyzerError: When ``parsed`` is a plain ``ParseResult`` (narrowing
                failure).
        """
        if not isinstance(parsed, TextParseResult):
            raise AnalyzerError(
                "dotnet-inventory classify requires a TextParseResult carrying "
                "file text; received a plain ParseResult"
            )
        detections: list[Detection] = []
        # Accumulate detections across all candidate files in deterministic order.
        for path, text in parsed.file_texts:
            detections.extend(classify_text(path, text))
        return DetectionResult(units=(), detections=tuple(detections))

    def map(self, classified: ClassifyResult) -> tuple[EvidenceRecord, ...]:
        """Build one Evidence Reference record per detection (reads bytes).

        Args:
            classified: The classify result; must be a ``DetectionResult``.

        Returns:
            One ``EvidenceRecord`` per detection.

        Raises:
            AnalyzerError: When ``classified`` is a plain ``ClassifyResult``.
        """
        if not isinstance(classified, DetectionResult):
            raise AnalyzerError(
                "dotnet-inventory map requires a DetectionResult; received a "
                "plain ClassifyResult"
            )
        ctx = self._require_ctx()
        # Cache the per-file content hash so repeated detections in one file do
        # not trigger repeated reads.
        hash_cache: dict[str, str] = {}
        records: list[EvidenceRecord] = []
        for detection in classified.detections:
            if detection.path not in hash_cache:
                content = self._fs.read_bytes(ctx.source_root / detection.path)
                hash_cache[detection.path] = hashlib.sha256(content).hexdigest()
            records.append(
                _build_record(detection, ctx.captured_at, hash_cache[detection.path])
            )
        return tuple(records)

    def emit(
        self, records: tuple[EvidenceRecord, ...], fs: AnalyzerFileSystem
    ) -> tuple[Path, ...]:
        """Write one Evidence Reference instance per record via the seam."""
        ctx = self._require_ctx()
        written: list[Path] = []
        for record in records:
            instance_path = ctx.artifact_root / f"{record.id}.json"
            text = serialize_record(record, instance_path, ctx.schema_path)
            fs.write_text(instance_path, text)
            written.append(instance_path)
        return tuple(written)


def _build_record(
    detection: Detection, captured_at: str, digest: str
) -> EvidenceRecord:
    """Assemble one Evidence Reference record from a detection (pure).

    Args:
        detection: The detection to serialize.
        captured_at: ISO-8601 timestamp from the injected clock.
        digest: Hex SHA-256 of the source file bytes for the integrity digest.

    Returns:
        The assembled ``EvidenceRecord``; all detection specifics live in
        ``metadata`` and nothing detection-specific appears in a top-level field.
    """
    return build_evidence_record(
        analyzer_name=_ANALYZER_NAME,
        id_prefix=_ID_PREFIX,
        tool=_TOOL,
        description=_DESCRIPTIONS[detection.detection_kind],
        detection=detection,
        captured_at=captured_at,
        digest=digest,
    )
