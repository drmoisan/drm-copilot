"""The VSTO/Office analyzer (Ribbon-XML and COM-interop detection).

Purpose:
    Implement a concrete stack-specific ``Analyzer`` (structural, no base class,
    no registry) that detects VSTO ribbon customization and COM-interop usage
    across C#, ribbon-XML, and project files, emitting one Evidence Reference v1
    instance per detection via the reused #363 emitter.

File routing:
    Within the include/exclude-filtered candidate set, ``.cs`` files are scanned
    over comment/string-stripped text, ``.xml`` files over unstripped text, and
    ``*proj`` files over unstripped XML. The pattern tables live in
    ``vsto_patterns`` so this module stays under the 500-line file-size limit.

Heuristic scope (normative):
    This analyzer is a heuristic textual evidence scanner, not a compiler.
    Detections record an observed textual pattern at a file/line anchor. The
    Office interop application name is captured as data into
    ``metadata.interop_target`` and never branched on, which keeps the analyzer
    consumer-neutral while remaining Office-stack-aware.

Invariants / Constraints:
    - ``parse`` performs the only I/O; ``classify`` is pure; ``map`` reads file
      bytes (cached per path) for integrity hashing via the seam.
    - ``classify`` isinstance-narrows to ``TextParseResult`` and ``map`` to
      ``DetectionResult``, raising ``AnalyzerError`` on the plain base type.
    - Enumeration is deterministic; ids are pure functions of the detection.

Side Effects:
    Stage methods read and write only through the injected filesystem seam.
"""

from __future__ import annotations

import hashlib
from typing import TYPE_CHECKING

from scripts.dev_tools.discovery.analyzer import vsto_patterns as patterns
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

_ANALYZER_NAME = "vsto-office"
_ID_PREFIX = "vsto"
_TOOL = "dev.discovery.vsto"


def _detect_ribbon_xml(path: str, lineno: int, line: str) -> list[Detection]:
    """Detect ribbon customUI patterns on one unstripped XML line (pure)."""
    detections: list[Detection] = []
    # Each customUI namespace URI is a distinct schema-generation signal; record
    # the matched URI so downstream consumers can tell the generations apart.
    for generation, uri in patterns.CUSTOMUI_URIS:
        if uri in line:
            detections.append(
                Detection(
                    path=path,
                    line=lineno,
                    detection_kind="ribbon_xml",
                    symbol=f"customui-{generation}",
                    symbol_kind="element",
                    extra=(("customui_schema", uri),),
                )
            )
    # The opening ``<customUI`` root element is the corroborating signal.
    if patterns.CUSTOMUI_ELEMENT_RE.search(line):
        detections.append(
            Detection(
                path=path,
                line=lineno,
                detection_kind="ribbon_xml",
                symbol="customUI",
                symbol_kind="element",
            )
        )
    return detections


def _detect_ribbon_cs(path: str, lineno: int, line: str) -> list[Detection]:
    """Detect ribbon-extensibility patterns on one stripped C# line (pure)."""
    detections: list[Detection] = []
    # IRibbonExtensibility (bare or namespace-qualified) is the interface signal.
    if patterns.IRIBBON_RE.search(line):
        detections.append(
            Detection(
                path=path,
                line=lineno,
                detection_kind="ribbon_extensibility",
                symbol="IRibbonExtensibility",
                symbol_kind="interface",
            )
        )
    # GetCustomUI is the single method of IRibbonExtensibility.
    if patterns.GETCUSTOMUI_RE.search(line):
        detections.append(
            Detection(
                path=path,
                line=lineno,
                detection_kind="ribbon_extensibility",
                symbol="GetCustomUI",
                symbol_kind="method",
            )
        )
    # The designer ribbon model bypasses GetCustomUI, so it is a required signal.
    if patterns.DESIGNER_RIBBON_LITERAL in line:
        detections.append(
            Detection(
                path=path,
                line=lineno,
                detection_kind="ribbon_extensibility",
                symbol=patterns.DESIGNER_RIBBON_LITERAL,
                symbol_kind="element",
            )
        )
    return detections


def _detect_com_attributes(
    path: str, lineno: int, stripped: str, original: str
) -> list[Detection]:
    """Detect COM interop attributes on one line (pure).

    Attribute presence is confirmed on the stripped line so a commented or
    stringized attribute cannot match; the GUID value, which lives inside a
    string literal blanked by the stripper, is captured from the original line
    only after that confirmation.
    """
    detections: list[Detection] = []
    # Walk the attribute table; each entry confirms one interop attribute name.
    for attribute_name, pattern in patterns.COM_ATTRIBUTE_RES:
        if pattern.search(stripped) is None:
            continue
        extra: tuple[tuple[str, str | int], ...] = ()
        # The GUID value is only available in the unstripped original line.
        if attribute_name == "Guid":
            guid_match = patterns.GUID_CAPTURE_RE.search(original)
            if guid_match is not None:
                extra = (("com_guid", guid_match.group(1)),)
        detections.append(
            Detection(
                path=path,
                line=lineno,
                detection_kind="com_attribute",
                symbol=attribute_name,
                symbol_kind="element",
                extra=extra,
            )
        )
    return detections


def _detect_com_usage(path: str, lineno: int, line: str) -> list[Detection]:
    """Detect Marshal/ProgID/interop-using patterns on one stripped line (pure)."""
    detections: list[Detection] = []
    # Marshal member calls: capture the member with no fixed allow-list.
    for marshal_match in patterns.MARSHAL_RE.finditer(line):
        detections.append(
            Detection(
                path=path,
                line=lineno,
                detection_kind="marshal_call",
                symbol=marshal_match.group("member"),
                symbol_kind="method",
            )
        )
    # ProgID activation via Type.GetTypeFromProgID(.
    if patterns.PROGID_RE.search(line):
        detections.append(
            Detection(
                path=path,
                line=lineno,
                detection_kind="progid_activation",
                symbol="GetTypeFromProgID",
                symbol_kind="method",
            )
        )
    # Office interop using: capture the application name as data, never branch it.
    using_match = patterns.INTEROP_USING_RE.match(line)
    if using_match is not None:
        detections.append(
            Detection(
                path=path,
                line=lineno,
                detection_kind="interop_using",
                symbol=using_match.group("full"),
                symbol_kind="namespace",
                extra=(("interop_target", using_match.group("app")),),
            )
        )
    return detections


def _detect_project(path: str, lineno: int, line: str) -> list[Detection]:
    """Detect project-file COM references on one unstripped line (pure)."""
    detections: list[Detection] = []
    # ``<COMReference Include="...">`` captures the Include value as the symbol.
    com_match = patterns.COMREFERENCE_RE.search(line)
    if com_match is not None:
        detections.append(
            Detection(
                path=path,
                line=lineno,
                detection_kind="com_reference",
                symbol=com_match.group("include"),
                symbol_kind="assembly",
            )
        )
    # ``<EmbedInteropTypes>`` marks an embedded interop type.
    if patterns.EMBEDINTEROP_RE.search(line):
        detections.append(
            Detection(
                path=path,
                line=lineno,
                detection_kind="com_reference",
                symbol="EmbedInteropTypes",
                symbol_kind="element",
            )
        )
    # An interop assembly ``<Reference Include="Microsoft.Office.Interop.*">``.
    assembly_match = patterns.INTEROP_ASSEMBLY_RE.search(line)
    if assembly_match is not None:
        detections.append(
            Detection(
                path=path,
                line=lineno,
                detection_kind="com_reference",
                symbol=assembly_match.group("include"),
                symbol_kind="assembly",
            )
        )
    return detections


def classify_csharp(path: str, text: str) -> list[Detection]:
    """Detect ribbon and COM C# patterns in one file's text (pure; strips first).

    Args:
        path: Consumer-relative POSIX path used as the detection anchor.
        text: Raw C# source text.

    Returns:
        Ordered detections for the file.
    """
    stripped = strip_comments_and_strings(text)
    detections: list[Detection] = []
    # Scan each line over both the stripped text (for pattern presence) and the
    # original text (for GUID value capture), which share line numbering.
    for (lineno, stripped_line), (_, original_line) in zip(
        numbered_lines(stripped), numbered_lines(text), strict=True
    ):
        detections.extend(_detect_ribbon_cs(path, lineno, stripped_line))
        detections.extend(
            _detect_com_attributes(path, lineno, stripped_line, original_line)
        )
        detections.extend(_detect_com_usage(path, lineno, stripped_line))
    return detections


def classify_xml(path: str, text: str) -> list[Detection]:
    """Detect ribbon customUI patterns in one XML file's text (pure; unstripped)."""
    detections: list[Detection] = []
    # Ribbon XML is scanned unstripped; XML has no C# comment/string semantics.
    for lineno, line in numbered_lines(text):
        detections.extend(_detect_ribbon_xml(path, lineno, line))
    return detections


def classify_project(path: str, text: str) -> list[Detection]:
    """Detect project-file COM references in one file's text (pure; unstripped)."""
    detections: list[Detection] = []
    # Project XML is scanned unstripped for COM-reference elements.
    for lineno, line in numbered_lines(text):
        detections.extend(_detect_project(path, lineno, line))
    return detections


def _classify_one(path: str, text: str) -> list[Detection]:
    """Route one file to the detector matching its kind (pure)."""
    # Routing table: extension decides which unstripped/stripped scan applies.
    if path.endswith(".cs"):
        return classify_csharp(path, text)
    if path.endswith(".xml"):
        return classify_xml(path, text)
    if path.endswith("proj"):
        return classify_project(path, text)
    return []


class VstoOfficeAnalyzer:
    """VSTO/Office analyzer implementing the #363 ``Analyzer`` protocol.

    Purpose:
        Detect VSTO ribbon customization and COM-interop usage across C#,
        ribbon-XML, and project files, emitting one Evidence Reference instance
        per detection.

    Usage:
        Constructed by the CLI and handed to ``run_analyzer(analyzer, ctx, fs)``.

    Invariants:
        ``parse`` is the only I/O stage; ``classify`` is pure; ``map`` reads file
        bytes (cached per path) via the seam.

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
        """Walk the tree, select routed candidates, and read their text.

        Args:
            ctx: The resolved run context.

        Returns:
            A ``TextParseResult`` of ordered ``.cs``/``.xml``/``*proj`` paths and
            their text.

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
        # Select the three routed file kinds; other files are ignored.
        candidates = tuple(
            path
            for path in filtered
            if path.endswith(".cs") or path.endswith(".xml") or path.endswith("proj")
        )
        file_texts = tuple(
            (path, self._fs.read_bytes(root / path).decode("utf-8", errors="replace"))
            for path in candidates
        )
        return TextParseResult(paths=candidates, file_texts=file_texts)

    def classify(self, parsed: ParseResult) -> ClassifyResult:
        """Route and scan each file's text into typed detections (pure).

        Args:
            parsed: The parse result; must be a ``TextParseResult``.

        Returns:
            A ``DetectionResult`` carrying every detection.

        Raises:
            AnalyzerError: When ``parsed`` is a plain ``ParseResult``.
        """
        if not isinstance(parsed, TextParseResult):
            raise AnalyzerError(
                "vsto-office classify requires a TextParseResult carrying file "
                "text; received a plain ParseResult"
            )
        detections: list[Detection] = []
        # Route each candidate file by kind and accumulate its detections.
        for path, text in parsed.file_texts:
            detections.extend(_classify_one(path, text))
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
                "vsto-office map requires a DetectionResult; received a plain "
                "ClassifyResult"
            )
        ctx = self._require_ctx()
        # Cache per-file content hashes so repeated detections in one file do not
        # trigger repeated reads.
        hash_cache: dict[str, str] = {}
        records: list[EvidenceRecord] = []
        for detection in classified.detections:
            if detection.path not in hash_cache:
                content = self._fs.read_bytes(ctx.source_root / detection.path)
                hash_cache[detection.path] = hashlib.sha256(content).hexdigest()
            records.append(
                build_evidence_record(
                    analyzer_name=_ANALYZER_NAME,
                    id_prefix=_ID_PREFIX,
                    tool=_TOOL,
                    description=patterns.DESCRIPTIONS[detection.detection_kind],
                    detection=detection,
                    captured_at=ctx.captured_at,
                    digest=hash_cache[detection.path],
                )
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
