"""Analyze explicitly selected optional syntax from immutable captured bytes.

No installed host, compiler, source traversal, callback execution or legacy write
pipeline is exposed. Public classifiers retain the old positional forms;
configured v2 consent and bounded capacities are mandatory at every entry point.
"""

from __future__ import annotations

from pathlib import PurePosixPath
from typing import TYPE_CHECKING, cast

from drm_copilot_discovery.analyzer.csharp_tokens import SourceScanError, decode_source
from drm_copilot_discovery.analyzer.findings import (
    diagnostic,
    pinned_matches,
    row,
    source_reference,
    stable_id,
    tool,
)
from drm_copilot_discovery.analyzer.models import Analysis, InventoryCapture
from drm_copilot_discovery.analyzer.optional import vsto_syntax as patterns
from drm_copilot_discovery.analyzer.source_text import Detection, build_evidence_id
from drm_copilot_discovery.analyzer.xml_input import XmlInputError
from drm_copilot_discovery.models import JsonObject
from drm_copilot_discovery.path_models import relative_path

if TYPE_CHECKING:
    from drm_copilot_discovery.analyzer.models import InventoryInput
    from drm_copilot_discovery.profile_v2 import ProfileV2
    from drm_copilot_discovery.repository_reader import RepositoryFile

_PROJECTS = frozenset(".csproj .vbproj .fsproj .proj .props .targets".split())


def classify_csharp(
    path: str,
    text: str,
    *,
    profile: ProfileV2 | None = None,
    max_tokens: int = 100000,
    max_candidates: int = 100000,
) -> list[Detection]:
    """Return consented C# Detection values for positional str path/text; pure.

    profile must be configured and explicitly select this adapter. Positive int
    max_tokens/max_candidates default to 100000. Tokens use the document_bytes
    numeric work ceiling; retained candidates use the separate artifact_records cap.
    SourceScanError rejects consent/input/resource violations; invalid capacities
    raise ValueError and draft profiles raise ProfileError. No source values run.
    """
    configured = patterns.require_consent(profile)
    tokens = patterns.capacity(
        max_tokens, min(100000, configured.limits.document_bytes)
    )
    candidates = patterns.capacity(
        max_candidates, min(100000, configured.limits.artifact_records)
    )
    relative_path(path)
    patterns.text_bytes(
        text,
        min(
            configured.analyzers.max_file_bytes,
            configured.limits.document_bytes,
            67108864,
        ),
    )
    return patterns.csharp_candidates(
        path, text, profile=configured, max_tokens=tokens, max_candidates=candidates
    )


def _xml(
    path: str,
    content: bytes,
    profile: ProfileV2 | None,
    project: bool,
    capacities: tuple[int, int, int, int],
) -> list[Detection]:
    """Return bounded XML candidates from path/bytes and configured profile; pure.

    project (bool) chooses the finite dialect. capacities is bytes/elements/depth/
    candidates. Consent, type and profile ceilings precede parser allocation;
    SourceScanError, XmlInputError, ProfileError or ValueError propagate.
    """
    configured = patterns.require_consent(profile)
    ceilings = (
        min(
            configured.analyzers.max_file_bytes,
            configured.limits.document_bytes,
            67108864,
        ),
        min(configured.limits.artifact_records, 100000),
        min(configured.limits.nesting_depth, 128),
        min(configured.limits.artifact_records, 100000),
    )
    # Each independent caller capacity can narrow, never enlarge, configured limits.
    byte_limit, elements, depth, candidates = tuple(
        patterns.capacity(value, ceiling)
        for value, ceiling in zip(capacities, ceilings, strict=True)
    )
    relative_path(path)
    return patterns.xml_candidates(
        path,
        content,
        profile=configured,
        project=project,
        max_bytes=byte_limit,
        max_elements=elements,
        max_depth=depth,
        max_candidates=candidates,
    )


def _xml_text(
    path: str,
    text: str,
    profile: ProfileV2 | None,
    project: bool,
    capacities: tuple[int, int, int, int],
) -> list[Detection]:
    """Encode str text only after consent/capacity checks; return Detection list.

    path/profile/project/capacities have _xml's contract. SourceScanError rejects
    unsafe text; public invalid capacities raise ValueError before encoding. Pure.
    """
    configured = patterns.require_consent(profile)
    # Validate all public values before allocating even the encoded text buffer.
    for value in capacities:
        patterns.capacity(value, 67108864)
    maximum = min(
        capacities[0],
        configured.analyzers.max_file_bytes,
        configured.limits.document_bytes,
        67108864,
    )
    return _xml(
        path, patterns.text_bytes(text, maximum), configured, project, capacities
    )


def classify_xml(
    path: str,
    text: str,
    *,
    profile: ProfileV2 | None = None,
    max_bytes: int = 67108864,
    max_elements: int = 100000,
    max_depth: int = 64,
    max_candidates: int = 100000,
) -> list[Detection]:
    """Return consented Ribbon declarations from positional str path/text; pure.

    profile selects configured consent; positive int byte/element/depth/candidate
    defaults are 64 MiB/100000/64/100000, capped by profile limits. Raises the fixed
    consent/encoding/XML/resource errors described by _xml_text; never executes.
    """
    return _xml_text(
        path, text, profile, False, (max_bytes, max_elements, max_depth, max_candidates)
    )


def classify_project(
    path: str,
    text: str,
    *,
    profile: ProfileV2 | None = None,
    max_bytes: int = 67108864,
    max_elements: int = 100000,
    max_depth: int = 64,
    max_candidates: int = 100000,
) -> list[Detection]:
    """Return consented project declarations from positional str path/text; pure.

    profile and positive int capacities use classify_xml's defaults/ceilings.
    SourceScanError/XmlInputError reject invalid data, ValueError rejects limits
    and ProfileError rejects drafts. Reference/condition values are not evaluated.
    """
    return _xml_text(
        path, text, profile, True, (max_bytes, max_elements, max_depth, max_candidates)
    )


def _failure(code: str, path: str | None, *, blocking: bool = True) -> JsonObject:
    """Return a fixed diagnostic from str code/path and bool blocking; pure.

    No parser exception text, arguments, GUID values or runtime paths are retained.
    """
    return diagnostic(
        code,
        path,
        "Inspect retained optional declarations and configured limits; binding, "
        "conditions and execution remain unresolved. Source values are withheld.",
        analyzer="office-vsto",
        blocking=blocking,
    )


class _Run:
    """Own one consented run's bounded indexes, candidates and immutable output.

    Construction reserves fallback output and independently caps pin count/bytes.
    inspect reserves aggregate input/scan work and every output row before parsing
    or projection. Failure discards the instance; no external side effects occur.
    """

    def __init__(self, capture: InventoryCapture) -> None:
        """Bind InventoryCapture and reserve bounded private state; return None.

        SourceScanError rejects exhausted count/byte/work budgets before allocation.
        Pins retain exact repository/revision/path/bytes, independently of input data.
        """
        self.capture = capture
        self.rows_left = min(capture.profile.limits.artifact_records, 100000) - 1
        self.input_left = self.work_left = capture.profile.limits.document_bytes
        self.output_left = self.input_left - 1024
        self.components: list[JsonObject] = []
        self.findings: list[JsonObject] = []
        self.relationships: list[JsonObject] = []
        self.diagnostics: list[JsonObject] = []
        self.pins: dict[str, list[RepositoryFile]] = {}
        if len(capture.repository_files) > capture.profile.limits.source_files:
            raise SourceScanError(
                "analysis-work-limit", "Optional pin count exceeds its limit."
            )
        pin_left = capture.profile.limits.document_bytes
        # Index retained pins once; duplicate comparisons share the aggregate byte cap.
        for source in capture.repository_files:
            pin_left -= len(source.content)
            if pin_left < 0:
                raise SourceScanError(
                    "analysis-work-limit", "Optional pin bytes exceed their limit."
                )
            self.pins.setdefault(source.path, []).append(source)

    def reserve(self, count: int, cost: int) -> None:
        """Charge int count/cost before allocation; return None, private mutation.

        SourceScanError distinguishes exhausted row and conservative encoded-byte
        budgets. cost includes JSON escaping and every repeated source/name field.
        """
        if count > self.rows_left:
            raise SourceScanError("analysis-limit", "Optional rows exceed their limit.")
        if count * cost > self.output_left:
            raise SourceScanError(
                "analysis-text-limit", "Optional output exceeds its limit."
            )
        self.rows_left -= count
        self.output_left -= count * cost

    def inspect(self, item: InventoryInput) -> None:
        """Inspect one selected immutable item; append reserved rows and return None.

        Per-file parse/read failures become fixed diagnostics. Aggregate work or
        candidate exhaustion raises SourceScanError so analyze discards all rows.
        Original XML bytes are parsed directly, including their encoding declaration.
        """
        cost = 16384 + 12 * (
            len(item.path)
            + len(self.capture.profile.repository.id)
            + len(self.capture.profile.repository.revision or "")
        )
        self.reserve(3, cost)
        if item.file is None:
            self.diagnostics.append(_failure("input-unreadable", item.path))
            return
        content = item.file.content
        work = max(1, len(content)) * 8
        if len(content) > self.input_left or work > self.work_left:
            raise SourceScanError(
                "analysis-work-limit", "Optional captured work exceeds its limit."
            )
        self.input_left -= len(content)
        self.work_left -= work
        count_capacity = self.rows_left // 2
        text_capacity = self.output_left // (2 * cost)
        capacity = min(count_capacity, text_capacity, 100000)
        exhausted = (
            "analysis-limit"
            if count_capacity <= text_capacity
            else "analysis-text-limit"
        )
        if capacity < 1:
            raise SourceScanError(exhausted, "Optional candidate budget is exhausted.")
        configured = self.capture.profile
        maximum = min(configured.analyzers.max_file_bytes, 67108864)
        suffix = PurePosixPath(item.path).suffix.lower()
        try:
            # C# strict decoding and XML original-byte parsing use separate seams.
            candidates = (
                classify_csharp(
                    item.path,
                    decode_source(content, max_bytes=maximum),
                    profile=configured,
                    max_candidates=capacity,
                )
                if suffix == ".cs"
                else _xml(
                    item.path,
                    content,
                    configured,
                    suffix in _PROJECTS,
                    (maximum, 100000, 64, capacity),
                )
            )
        except (SourceScanError, XmlInputError) as error:
            if error.code in {"office-candidate-limit", "com-candidate-limit"}:
                raise SourceScanError(
                    exhausted, "Optional candidate budget is exhausted."
                ) from error
            self.diagnostics.append(_failure(error.code, item.path))
            return
        self.reserve(2 * len(candidates), cost)
        local = InventoryCapture(
            profile=configured,
            inputs=(item,),
            repository_files=tuple(self.pins.get(item.path, ())),
        )
        source, pinned = source_reference(local, item), pinned_matches(local, item)
        component_id = stable_id(
            "component",
            row(
                repository=source["repository"], path=item.path, analyzer="office-vsto"
            ),
        )
        self.components.append(
            row(
                component_id=component_id,
                component_type="optional-source-file",
                source=source,
                analyzer=tool("office-vsto"),
                classification="detected",
                confidence="high" if pinned else "low",
                properties=(),
                extensions=row(),
            )
        )
        self.diagnostics.append(
            _failure("optional-binding-unresolved", item.path, blocking=False)
        )
        if not pinned:
            self.diagnostics.append(_failure("source-revision-unverified", item.path))
        # Keep distinct lexical sites, preserving historical IDs as provenance metadata.
        for candidate in candidates:
            metadata = dict(candidate.extra)
            anchor = JsonObject(
                source.members
                + (("line_range", row(start=candidate.line, end=candidate.line)),)
            )
            identity = row(
                component=component_id,
                kind=candidate.detection_kind,
                symbol=candidate.symbol,
                site=metadata.get("offset", metadata.get("ordinal")),
                attribute=metadata.get("attribute"),
            )
            legacy_id = build_evidence_id(
                "vsto",
                candidate.detection_kind,
                candidate.symbol,
                candidate.path,
                candidate.line,
            )
            extension = row(
                **{
                    "drm.office-vsto": row(
                        **metadata,
                        legacy_evidence_id=legacy_id,
                        legacy_analyzer="vsto-office",
                        execution="unverified",
                    )
                }
            )
            declared = suffix != ".cs"
            self.findings.append(
                row(
                    finding_id=stable_id("finding", identity),
                    component_id=component_id,
                    kind=candidate.detection_kind,
                    source=anchor,
                    analyzer=tool("office-vsto"),
                    classification="detected" if declared else "inferred",
                    confidence=("high" if declared else "medium") if pinned else "low",
                    properties=(
                        row(name="symbol", value=candidate.symbol),
                        row(name="symbol_kind", value=candidate.symbol_kind),
                    ),
                    extensions=extension,
                )
            )
            if candidate.detection_kind == "ribbon_callback":
                self.relationships.append(
                    row(
                        relationship_id=stable_id("relationship", identity),
                        from_component_id=component_id,
                        to_component_id=None,
                        target_description=candidate.symbol,
                        kind="possible-callback-method",
                        source=anchor,
                        analyzer=tool("office-vsto"),
                        classification="inferred",
                        confidence="low",
                        extensions=row(
                            **{
                                "drm.office-vsto": row(
                                    binding="unresolved", execution="unverified"
                                )
                            }
                        ),
                    )
                )


class VstoOfficeAnalyzer:
    """Project explicitly consented optional markers without source reads or writes.

    Stateless callers supply InventoryCapture; every run rechecks configured
    selection before traversal. Aggregate exhaustion discards all partial rows;
    syntax and immutable provenance never imply execution or legacy behavior.
    """

    identifier = "office-vsto"
    name = "vsto-office"

    def analyze(self, capture: InventoryCapture) -> Analysis:
        """Return bounded Analysis from InventoryCapture; no external side effects.

        ValueError rejects untyped capture, SourceScanError rejects consent and an
        insufficient fallback budget; ProfileError rejects draft configuration.
        Other aggregate exhaustion returns one reserved blocking diagnostic.
        """
        if not isinstance(cast("object", capture), InventoryCapture):
            raise ValueError("Optional analysis requires an immutable capture")
        patterns.require_consent(capture.profile)
        if capture.profile.limits.document_bytes < 1024:
            raise SourceScanError(
                "analysis-text-limit", "Optional diagnostic budget is insufficient."
            )
        try:
            run = _Run(capture)
            # Captured exclusions and unsupported suffixes never reach classifiers.
            for item in capture.inputs:
                if item.status == "excluded" or PurePosixPath(
                    item.path
                ).suffix.lower() not in {".cs", ".xml", *_PROJECTS}:
                    continue
                run.inspect(item)
        except SourceScanError as error:
            return Analysis(diagnostics=(_failure(error.code, None),))
        return Analysis(
            components=tuple(run.components),
            findings=tuple(run.findings),
            relationships=tuple(run.relationships),
            diagnostics=tuple(run.diagnostics),
        )
