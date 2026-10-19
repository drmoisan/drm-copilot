"""Recognize fixed C# API spellings without resolving symbols or runtime values.

The scanner makes a fixed number of forward token passes and retains only bounded
known API names and numeric anchors. Output reservations count encoded bytes: 12
bytes per Unicode character cover compact UTF-8 JSON with either ensure_ascii
setting. No receiver, argument, error text or value-derived digest is emitted.
"""

from __future__ import annotations

from typing import TYPE_CHECKING

from drm_copilot_discovery.analyzer.api_syntax import (
    AccessSite,
    ApiSurface,
    access_sites,
)
from drm_copilot_discovery.analyzer.csharp_tokens import (
    SourceScanError,
    decode_source,
)
from drm_copilot_discovery.analyzer.findings import (
    diagnostic,
    row,
    source_reference,
    stable_id,
    tool,
)
from drm_copilot_discovery.analyzer.models import Analysis
from drm_copilot_discovery.models import JsonObject

if TYPE_CHECKING:
    from drm_copilot_discovery.analyzer.models import InventoryCapture, InventoryInput


def _failure(code: str, path: str | None, identifier: str) -> JsonObject:
    """Return a fixed redacted diagnostic for code/path/analyzer identifiers.

    All arguments are str except optional path; raw parser/read messages and
    exception contexts are never formatted. Returns JsonObject without effects.
    """
    return diagnostic(
        code,
        path,
        "Check captured C# syntax, immutable provenance and configured limits; "
        "runtime values and error details are withheld.",
        analyzer=identifier,
    )


def _row_cost(
    capture: InventoryCapture, item: InventoryInput, surface: ApiSurface
) -> int:
    """Return a prospective compact-JSON encoded-byte reservation per output row.

    capture/item provide retained provenance; surface has bounded fixed names.
    Twelve bytes per Unicode character cover both ensure_ascii settings, including
    astral surrogate pairs. 4096 bytes cover fixed fields/IDs/numeric anchors;
    repeated source/analyzer/name fields are conservatively reserved twice/four
    times. No row or source-derived string is allocated by this calculation.
    """
    source = (
        len(capture.profile.repository.id)
        + len(capture.profile.repository.revision or "")
        + len(item.path)
    )
    return 4096 + 12 * (
        2 * source
        + 4 * len(surface.identifier)
        + 2 * (64 * (len(surface.namespace) + 2) + 5)
    )


def _verified_paths(capture: InventoryCapture) -> frozenset[str]:
    """Match InventoryCapture inputs/pins once; return immutable verified paths.

    source_files bounds pin count before indexing; document_bytes separately bounds
    all retained pin bytes, including unused/foreign/duplicate objects.
    SourceScanError reports provenance overflow. Work is linear in input/pin count
    plus compared payload bytes; exact matching repository/revision/path/bytes
    preserves any-matching-pin semantics. No hashing, source reads or mutation.
    """
    if len(capture.repository_files) > capture.profile.limits.source_files:
        raise SourceScanError("analysis-work-limit", "Too many retained pins")
    # Index retained input references once instead of rescanning every Git object.
    selected = {
        item.path: item.file
        for item in capture.inputs
        if item.file is not None and item.path.lower().endswith(".cs")
    }
    matched: set[str] = set()
    remaining = capture.profile.limits.document_bytes
    # Every retained pin is visited once; already matched paths need no reread.
    for source in capture.repository_files:
        remaining -= len(source.content)
        if remaining < 0:
            raise SourceScanError("analysis-work-limit", "Retained pin byte limit")
        if (
            source.repository.id != capture.profile.repository.id
            or source.repository.revision != capture.profile.repository.revision
            or source.path in matched
        ):
            continue
        candidate = selected.get(source.path)
        if candidate is not None and source.content == candidate.content:
            matched.add(source.path)
    return frozenset(matched)


def _project(
    capture: InventoryCapture,
    item: InventoryInput,
    surface: ApiSurface,
    sites: tuple[AccessSite, ...],
    pinned: bool,
) -> Analysis:
    """Build reserved rows from captured provenance and fixed AccessSite values.

    capture/item/surface identify source and adapter; sites are bounded; pinned
    records exact immutable-byte agreement. Return Analysis with inferred API
    candidates and detected file presence. ValueError rejects unavailable bytes;
    no I/O, argument values or source mutation occurs.
    """
    source = source_reference(capture, item)
    component_id = stable_id(
        "component",
        row(
            repository=source["repository"], path=item.path, analyzer=surface.identifier
        ),
    )
    component = row(
        component_id=component_id,
        component_type="csharp-source",
        source=source,
        analyzer=tool(surface.identifier),
        classification="detected",
        confidence="high" if pinned else "low",
        properties=(),
        extensions=row(),
    )
    findings: list[JsonObject] = []
    # Offset identity separates repeated sites without hashing runtime arguments.
    for site in sites:
        anchor = JsonObject(
            source.members
            + (
                ("line_range", row(start=site.line, end=site.end_line)),
                ("symbol", site.api),
            )
        )
        findings.append(
            row(
                finding_id=stable_id(
                    "finding",
                    row(
                        component=component_id,
                        api=site.api,
                        offset=site.start,
                        operation=site.operation,
                    ),
                ),
                component_id=component_id,
                kind=surface.identifier + "-candidate",
                source=anchor,
                analyzer=tool(surface.identifier),
                classification="inferred",
                confidence="medium" if pinned else "low",
                properties=(
                    row(name="api", value=site.api),
                    row(name="operation", value=site.operation),
                ),
                extensions=row(
                    **{
                        "drm.api-access": row(
                            binding="unresolved",
                            aliases="not-resolved",
                            preprocessing="not-evaluated",
                            platform_applicability="unresolved",
                            arguments="not-collected",
                            offset=site.start,
                            end_offset=site.end,
                            anchor="physical-text",
                        )
                    }
                ),
            )
        )
    diagnostics = [
        diagnostic(
            "api-binding-unresolved",
            item.path,
            "API spellings are candidates only; custom types, aliases, conditional "
            "compilation, runtime targets and platform applicability stay unresolved.",
            analyzer=surface.identifier,
            blocking=False,
        )
    ]
    if not pinned:
        diagnostics.append(
            _failure("source-revision-unverified", item.path, surface.identifier)
        )
    return Analysis(
        components=(component,),
        findings=tuple(findings),
        diagnostics=tuple(diagnostics),
    )


def analyze_access(capture: InventoryCapture, surface: ApiSurface) -> Analysis:
    """Return inferred API Analysis from immutable captured bytes and fixed surface.

    capture supplies validated profile limits; surface supplies known syntax.
    Record and encoded-text reservations precede candidate/row construction.
    Independent document_bytes budgets cap retained pins and selected source bytes.
    Whole-aggregate overflow returns one blocker and no partial claims. Per-file
    decode/syntax/read failures are redacted blockers. No file reads or writes.
    """
    components: list[JsonObject] = []
    findings: list[JsonObject] = []
    diagnostics: list[JsonObject] = []
    limit = min(capture.profile.limits.artifact_records, 100000)
    remaining = capture.profile.limits.document_bytes
    input_bytes = capture.profile.limits.document_bytes
    overflow = "analysis-limit"
    try:
        verified = _verified_paths(capture)
    except SourceScanError as error:
        return Analysis(diagnostics=(_failure(error.code, None, surface.identifier),))
    # Captured ordering and selection are deterministic and never reread sources.
    for item in capture.inputs:
        if not item.path.lower().endswith(".cs") or item.status == "excluded":
            continue
        # Bound aggregate decoding work independently from projected text size.
        if item.file is not None:
            input_bytes -= len(item.file.content)
            if input_bytes < 0:
                overflow = "analysis-work-limit"
                break
        used = len(components) + len(findings) + len(diagnostics)
        cost = _row_cost(capture, item, surface)
        pinned = item.path in verified
        base = 1 if item.file is None else 2 + int(not pinned)
        if used + base > limit:
            break
        if cost * base > remaining:
            overflow = "analysis-text-limit"
            break
        remaining -= cost * base
        if item.file is None:
            diagnostics.append(
                _failure("input-unreadable", item.path, surface.identifier)
            )
            continue
        records = limit - used - base
        text_records = remaining // cost
        try:
            text = decode_source(
                item.file.content,
                max_bytes=min(capture.profile.analyzers.max_file_bytes, 67108864),
            )
            sites = access_sites(text, surface, max_sites=min(records, text_records))
        except SourceScanError as error:
            # Candidate exhaustion invalidates the aggregate, never a partial file.
            if error.code == "source-record-limit":
                overflow = (
                    "analysis-text-limit"
                    if text_records < records
                    else "analysis-limit"
                )
                break
            diagnostics.append(_failure(error.code, item.path, surface.identifier))
            continue
        remaining -= cost * len(sites)
        projected = _project(capture, item, surface, sites, pinned)
        components.extend(projected.components)
        findings.extend(projected.findings)
        diagnostics.extend(projected.diagnostics)
    else:
        return Analysis(
            components=tuple(components),
            findings=tuple(findings),
            diagnostics=tuple(diagnostics),
        )
    return Analysis(diagnostics=(_failure(overflow, None, surface.identifier),))
