"""Coordinate captured C# lexical inventory and the read-only legacy pipeline.

V2 adapters consume immutable captured inputs only. Legacy parsing reads source
once; classification and mapping use those same bytes and never publish.
"""

from __future__ import annotations

import hashlib
import re
from dataclasses import dataclass
from typing import TYPE_CHECKING

from drm_copilot_discovery.analyzer.csharp_declarations import declaration_candidates
from drm_copilot_discovery.analyzer.csharp_tokens import SourceScanError, decode_source
from drm_copilot_discovery.analyzer.event_subscriptions import subscription_candidates
from drm_copilot_discovery.analyzer.findings import (
    diagnostic,
    pinned_matches,
    row,
    source_reference,
    stable_id,
    tool,
)
from drm_copilot_discovery.analyzer.inventory import AnalyzerError, filter_paths
from drm_copilot_discovery.analyzer.models import Analysis
from drm_copilot_discovery.analyzer.pipeline import RealAnalyzerFileSystem
from drm_copilot_discovery.analyzer.source_text import (
    Detection,
    DetectionResult,
    TextParseResult,
    build_evidence_record,
    strip_comments_and_strings,
)
from drm_copilot_discovery.models import JsonObject

if TYPE_CHECKING:
    from pathlib import Path

    from drm_copilot_discovery.analyzer.models import (
        AnalyzerContext,
        ClassifyResult,
        EvidenceRecord,
        InventoryCapture,
        InventoryInput,
        ParseResult,
    )
    from drm_copilot_discovery.analyzer.pipeline import AnalyzerFileSystem


@dataclass(frozen=True, slots=True)
class _CapturedText(TextParseResult):
    """Retain exact parse payloads without changing shared carrier fields.

    file_bytes contains ordered path/bytes pairs read through the injected seam.
    Classification carries them forward unchanged; construction performs no I/O.
    """

    file_bytes: tuple[tuple[str, bytes], ...] = ()


@dataclass(frozen=True, slots=True)
class _CapturedDetections(DetectionResult):
    """Bind detections to parsed bytes for pure legacy evidence mapping.

    Ordered immutable file_bytes is private provenance. Shared carrier identity
    and defaults stay intact; constructing this subtype has no side effects.
    """

    file_bytes: tuple[tuple[str, bytes], ...] = ()


def classify_text(path: str, text: str) -> list[Detection]:
    """Return the legacy declaration/subscription catalog from str path/text.

    SourceScanError rejects malformed/bounded input. Member inference is reserved
    for v2; heuristic subscription metadata and legacy ID inputs remain intact.
    No I/O or mutation occurs.
    """
    values = (
        *declaration_candidates(path, text, include_members=False),
        *subscription_candidates(path, text),
    )
    return sorted(values, key=lambda value: (value.line, dict(value.extra)["offset"]))


class DotnetInventoryAnalyzer:
    """Preserve legacy parse/classify/map contracts with captured source bytes.

    Construct with an optional filesystem seam, then parse before mapping. Parse
    reads; later stages are pure and emit rejects unguarded writes. Shared public
    carrier constructors and identity remain unchanged.
    """

    name = "dotnet-inventory"

    def __init__(self, fs: AnalyzerFileSystem | None = None) -> None:
        """Store fs (AnalyzerFileSystem | None); return None without I/O."""
        self._fs = fs if fs is not None else RealAnalyzerFileSystem()
        self._ctx: AnalyzerContext | None = None

    def _require_ctx(self) -> AnalyzerContext:
        """Return captured context or raise AnalyzerError; no I/O."""
        if self._ctx is None:
            raise AnalyzerError("analyzer context is unavailable; parse must run first")
        return self._ctx

    def parse(self, ctx: AnalyzerContext) -> ParseResult:
        """Read selected .cs paths once through the filesystem seam.

        ctx (AnalyzerContext) supplies roots/globs/time. Returns TextParseResult
        subtype with bytes; AnalyzerError rejects roots/encoding and read failures
        propagate. Clears prior context before reading; never writes files.
        """
        self._ctx = None
        root = ctx.source_root
        if not self._fs.exists(root) or not self._fs.is_dir(root):
            raise AnalyzerError(f"source root is not reachable: {root}")
        # Preserve POSIX order and legacy case-sensitive .cs/include/exclude rules.
        ordered = tuple(
            sorted(
                path.relative_to(root).as_posix() for path in self._fs.walk_files(root)
            )
        )
        # Apply consumer globs before capturing only legacy lowercase .cs inputs.
        paths = tuple(
            path
            for path in filter_paths(ordered, ctx.include, ctx.exclude)
            if path.endswith(".cs")
        )
        payloads: list[tuple[str, bytes]] = []
        texts: list[tuple[str, str]] = []
        # One payload backs decoded text and all later hashes, with no rereads.
        for path in paths:
            payload = self._fs.read_bytes(root / path)
            try:
                text = decode_source(payload)
            except SourceScanError as exc:
                raise AnalyzerError(f"{path}: {exc}") from exc
            payloads.append((path, payload))
            texts.append((path, text))
        self._ctx = ctx
        return _CapturedText(paths, tuple(texts), tuple(payloads))

    def classify(self, parsed: ParseResult) -> ClassifyResult:
        """Classify ParseResult after narrowing; return DetectionResult, without I/O.

        AnalyzerError rejects wrong carriers; SourceScanError rejects malformed
        text. Uncaptured public TextParseResult remains classifiable but cannot
        support evidence hashes. Private parsed bytes are carried forward intact.
        """
        if not isinstance(parsed, TextParseResult):
            raise AnalyzerError("dotnet-inventory classify requires a TextParseResult")
        # Preserve text-only classification without inventing its source bytes.
        detections = tuple(
            value
            for path, text in parsed.file_texts
            for value in classify_text(path, text)
        )
        if isinstance(parsed, _CapturedText):
            return _CapturedDetections((), detections, parsed.file_bytes)
        return DetectionResult((), detections)

    def map(self, classified: ClassifyResult) -> tuple[EvidenceRecord, ...]:
        """Return legacy evidence for captured ClassifyResult without rereads.

        AnalyzerError rejects wrong/uncaptured carriers, missing paths or absent
        context. Hashes retained bytes; filesystem changes cannot alter findings.
        """
        if not isinstance(classified, DetectionResult):
            raise AnalyzerError("dotnet-inventory map requires a DetectionResult")
        ctx = self._require_ctx()
        if not isinstance(classified, _CapturedDetections):
            raise AnalyzerError("Mapping requires exact bytes from the parse stage")
        # Compute one digest per file for every detection from that payload.
        digests = {
            path: hashlib.sha256(content).hexdigest()
            for path, content in classified.file_bytes
        }
        records: list[EvidenceRecord] = []
        # Reject unmatched provenance instead of inventing a digest for a detection.
        for detection in classified.detections:
            if detection.path not in digests:
                raise AnalyzerError("Detection has no captured source bytes")
            records.append(
                build_evidence_record(
                    analyzer_name=self.name,
                    id_prefix="dotnet",
                    tool="dev.discovery.dotnet",
                    description="Heuristic C# declaration or handler syntax detection.",
                    detection=detection,
                    captured_at=ctx.captured_at,
                    digest=digests[detection.path],
                )
            )
        return tuple(records)

    def emit(
        self, records: tuple[EvidenceRecord, ...], fs: AnalyzerFileSystem
    ) -> tuple[Path, ...]:
        """Always raise AnalyzerError; records/fs preserve the unused protocol.

        records (tuple[EvidenceRecord,...]) and fs (AnalyzerFileSystem) are never
        consumed. No I/O occurs; guarded v2 mutation owns publication.
        """
        raise AnalyzerError(
            "Legacy emission is disabled; use guarded v2 inventory publication"
        )


def _project(
    capture: InventoryCapture,
    item: InventoryInput,
    identifier: str,
    candidates: tuple[Detection, ...],
    preprocessor: bool,
) -> Analysis:
    """Project C# candidates into exact-byte inventory rows; pure.

    capture/item supply immutable input/pins; identifier (str), candidates (tuple
    of Detection) and preprocessor (bool) retain lexical semantics. Returns Analysis
    with honest anchors/confidence/diagnostics. Missing bytes raise ValueError.
    """
    source = source_reference(capture, item)
    pinned = pinned_matches(capture, item)
    component_id = stable_id(
        "component",
        row(repository=source["repository"], path=item.path, analyzer=identifier),
    )
    component = row(
        component_id=component_id,
        component_type="csharp-source-file",
        source=source,
        analyzer=tool(identifier),
        classification="detected",
        confidence="high" if pinned else "low",
        properties=(),
        extensions=row(),
    )
    findings: list[JsonObject] = []
    relationships: list[JsonObject] = []
    # Syntax observations and inferred member/event interpretations stay separate.
    for candidate in candidates:
        extra = dict(candidate.extra)
        inferred = candidate.detection_kind in {"member", "event_subscription"}
        confidence = "low" if not pinned else "medium" if inferred else "high"
        anchor = JsonObject(
            source.members
            + (
                ("line_range", row(start=candidate.line, end=extra["end_line"])),
                ("symbol", candidate.symbol),
            )
        )
        identity = row(
            component=component_id,
            kind=candidate.detection_kind,
            symbol=candidate.symbol,
            offset=extra["offset"],
        )
        extension = row(
            **{
                "drm.csharp": row(
                    binding="unresolved",
                    preprocessing="not-evaluated",
                    offset=extra["offset"],
                    anchor="physical-text",
                    interpretation="candidate" if inferred else "syntax",
                )
            }
        )
        # Legacy 'heuristic' is neither a v2 confidence value nor an evidence claim.
        properties = (
            row(name="symbol", value=candidate.symbol),
            row(name="symbol_kind", value=candidate.symbol_kind),
            *(
                row(name=name, value=value)
                for name, value in candidate.extra
                if name not in {"confidence", "offset", "end_line"}
            ),
        )
        findings.append(
            row(
                finding_id=stable_id("finding", identity),
                component_id=component_id,
                kind=candidate.detection_kind,
                source=anchor,
                analyzer=tool(identifier),
                classification="inferred" if inferred else "detected",
                confidence=confidence,
                properties=properties,
                extensions=extension,
            )
        )
        if candidate.detection_kind == "event_subscription":
            relationships.append(
                row(
                    relationship_id=stable_id("relationship", identity),
                    from_component_id=component_id,
                    to_component_id=None,
                    target_description=extra["handler"],
                    kind="possible-handler-assignment",
                    source=anchor,
                    analyzer=tool(identifier),
                    classification="inferred",
                    confidence=confidence,
                    extensions=extension,
                )
            )
    diagnostics = [
        diagnostic(
            "compiler-binding-not-performed",
            item.path,
            "Lexical names, members and assignment operands are not compiler-bound.",
            analyzer=identifier,
            blocking=False,
        )
    ]
    if preprocessor:
        diagnostics.append(
            diagnostic(
                "preprocessing-not-evaluated",
                item.path,
                "All textual branches are inspected; active branches and #line "
                "mappings remain unresolved.",
                analyzer=identifier,
                blocking=False,
            )
        )
    if not pinned:
        diagnostics.append(
            diagnostic(
                "source-revision-unverified",
                item.path,
                "Capture matching immutable bytes before publishing C# observations.",
                analyzer=identifier,
            )
        )
    return Analysis(
        components=(component,),
        findings=tuple(findings),
        relationships=tuple(relationships),
        diagnostics=tuple(diagnostics),
    )


def _analyze(
    capture: InventoryCapture, *, identifier: str, subscriptions: bool
) -> Analysis:
    """Return one fixed adapter's Analysis from bounded immutable captured inputs.

    capture (InventoryCapture), identifier (str) and subscriptions (bool) select
    the scanner. Lexical errors become diagnostics; aggregate overflow discards
    partial results. No I/O, input mutation, optional imports or publication occurs.
    """
    components: list[JsonObject] = []
    findings: list[JsonObject] = []
    relationships: list[JsonObject] = []
    diagnostics: list[JsonObject] = []
    limit = min(capture.profile.limits.artifact_records, 100000)
    # Capture already sorts inputs; unavailable/excluded state stays authoritative.
    for item in capture.inputs:
        if not item.path.lower().endswith(".cs") or item.status == "excluded":
            continue
        used = sum(map(len, (components, findings, relationships, diagnostics)))
        if used >= limit:
            break
        if item.file is None:
            diagnostics.append(
                diagnostic(
                    "input-unreadable",
                    item.path,
                    item.rationale or "C# input unavailable.",
                    analyzer=identifier,
                )
            )
            continue
        try:
            text = decode_source(
                item.file.content,
                max_bytes=min(capture.profile.analyzers.max_file_bytes, 67108864),
            )
            preprocessor = (
                re.search(r"(?:^|[\r\n])[ \t]*#", strip_comments_and_strings(text))
                is not None
            )
            candidates = (
                subscription_candidates(item.path, text)
                if subscriptions
                else declaration_candidates(item.path, text)
            )
            required = (
                2
                + int(preprocessor)
                + int(not pinned_matches(capture, item))
                + len(candidates)
            )
            required += len(candidates) if subscriptions else 0
            if used + required > limit:
                break
            parsed = _project(capture, item, identifier, candidates, preprocessor)
        except SourceScanError as exc:
            diagnostics.append(
                diagnostic(exc.code, item.path, str(exc), analyzer=identifier)
            )
        else:
            components.extend(parsed.components)
            findings.extend(parsed.findings)
            relationships.extend(parsed.relationships)
            diagnostics.extend(parsed.diagnostics)
    else:
        return Analysis(
            components=tuple(components),
            findings=tuple(findings),
            relationships=tuple(relationships),
            diagnostics=tuple(diagnostics),
        )
    return Analysis(
        diagnostics=(
            diagnostic(
                "analysis-limit",
                None,
                "C# analysis exceeds its record limit; increase it or narrow scope.",
                analyzer=identifier,
            ),
        )
    )


class CSharpDeclarationAnalyzer:
    """Project declared syntax and inferred members from immutable C# inputs.

    Stateless direct adapter; registration is a separate task. Every result keeps
    exact source bytes, physical anchors and unresolved compiler binding.
    """

    identifier = "csharp-symbols"

    def analyze(self, capture: InventoryCapture) -> Analysis:
        """Return Analysis for capture (InventoryCapture); pure, no publication.

        Bounded errors become diagnostics through the shared C# analysis routine.
        """
        return _analyze(capture, identifier=self.identifier, subscriptions=False)


class EventSubscriptionAnalyzer:
    """Project inferred handler assignments without resolving events.

    Stateless direct adapter. Runtime subscription and arithmetic type resolution
    remain unknown; registration and guarded publication are external.
    """

    identifier = "event-subscriptions"

    def analyze(self, capture: InventoryCapture) -> Analysis:
        """Return Analysis for capture (InventoryCapture); pure, no publication.

        Bounded errors become diagnostics; assignment interpretations stay inferred.
        """
        return _analyze(capture, identifier=self.identifier, subscriptions=True)
