"""Compose captured profile, inventory, source and graph validation operations."""

from __future__ import annotations

from typing import TYPE_CHECKING, Literal, cast

from drm_copilot_discovery.configuration import DEFAULT_PROFILE
from drm_copilot_discovery.models import JsonObject, canonical_json
from drm_copilot_discovery.operations import (
    OperationContext,
    OperationFailure,
    operation_problem,
)
from drm_copilot_discovery.profile_v2 import ProfileError

if TYPE_CHECKING:
    from drm_copilot_discovery.findings import Finding
    from drm_copilot_discovery.service_contracts import DiscoveryResult


def _profile(context: OperationContext) -> DiscoveryResult:
    """Validate or expose an exact selected profile; return DiscoveryResult.

    context (OperationContext) supplies bounded bootstrap reads and trusted
    catalog. Existing v1 and v2 parsers own semantics; no v2 graph is invented.
    Invalid schemas retain findings and exit 1; unsupported versions/selection
    raise OperationFailure. No activation or publication occurs.
    """
    from drm_copilot_discovery.domain_profile import parse_domain_profile_text
    from drm_copilot_discovery.domain_profile_models import DomainProfileError
    from drm_copilot_discovery.profile_v2 import ProfileV2

    explicit = context.text("input_path") or context.request.profile_path
    if explicit is None:
        selected = context.io.activation.select()
        path = selected.profile_path or DEFAULT_PROFILE
    else:
        path = explicit
    content = context.read(path)
    document = context.document(path)
    version = document.get("schema_version")
    legacy = version is None and document.get("profile_version") == 1
    if not legacy and version != "2.0.0":
        raise OperationFailure("SERVICE_VERSION")
    findings: tuple[Finding, ...] = ()
    try:
        if legacy:
            parse_domain_profile_text(content.decode("utf-8"), source=path)
        else:
            ProfileV2(
                content,
                format="yaml" if path.endswith((".yaml", ".yml")) else "json",
                catalog=context.io.initialization.catalog,
                limits=context.limits,
            )
    except ProfileError as error:
        findings = error.findings
    except DomainProfileError:
        findings = (operation_problem("SERVICE_PROFILE"),)
    artifacts = ()
    if context.request.operation == "profile":
        artifacts = context.projected(
            (context.change("domain-profile", "profile", path, content),)
        )
    return context.result(
        findings=findings,
        artifacts=artifacts,
        counts=(("legacy_compatibility_only", int(legacy)),),
    )


def _inventory(context: OperationContext) -> DiscoveryResult:
    """Analyze exact retained inputs and optionally publish canonical inventory.

    context (OperationContext) supplies a trusted selector and capture. Read-only
    injected results cannot replace canonical publication reconstruction. Return
    DiscoveryResult; selector, mutation and resource errors propagate. Only the
    accepted mutation writer may publish, and ledger rows remain proposals.
    """
    from drm_copilot_discovery.analyzer.input_capture import capture_snapshot
    from drm_copilot_discovery.analyzer.pipeline import plan_inventory, run_inventory
    from drm_copilot_discovery.analyzer.registry import normalized_analyzer_ids

    selectors = (
        context.strings("analyzer_ids") if "analyzer_ids" in context.inputs else None
    )
    try:
        selectors = normalized_analyzer_ids(
            context.snapshot.profile, analyzer_ids=selectors
        )
    except ProfileError:
        raise
    except ValueError as error:
        raise OperationFailure("SERVICE_SELECTION") from error
    result = run_inventory(
        capture_snapshot(context.snapshot),
        timestamp=context.timestamp,
        author_or_agent=context.author(),
        catalog=context.snapshot.catalog,
        analyzer_ids=selectors,
        analyzer_registry=context.analyzer_registry,
    )
    context.budget.check(result.document)
    identifier = cast("str", result.document["id"])
    change = context.change(
        "inventory-snapshot",
        identifier,
        context.snapshot.profile.artifacts["inventory"] + "/" + identifier + ".json",
        canonical_json(result.document),
    )
    if context.request.write:
        if context.baseline is None:
            raise OperationFailure("SERVICE_CAPTURE", exit_code=3)
        return context.publish(
            plan_inventory(
                context.baseline,
                result,
                grants=context.grants((change,)),
                analyzer_ids=selectors,
            )
        )
    diagnostics = cast("tuple[JsonObject, ...]", result.document["diagnostics"])
    context.budget.work(len(diagnostics))
    blocked = any(item["blocking"] for item in diagnostics)
    findings = (operation_problem("INVENTORY_BLOCKED"),) if blocked else ()
    return context.result(
        artifacts=context.projected((change,)),
        findings=findings,
        counts=(("proposed_ledger_components", len(result.ledger_components)),),
    )


def _source(context: OperationContext) -> DiscoveryResult:
    """Return one bounded authorized source page with explicit truncation counters.

    context (OperationContext) contains an authenticated ReadSelection. Existing
    SourceReader owns scope, line and freshness rules. Reads are supplied only
    from retained captured bytes. Invalid selection/resource/path errors propagate;
    no write, continuation claim or source execution occurs.
    """
    from dataclasses import replace

    from drm_copilot_discovery.service_serialization import wire_object
    from drm_copilot_discovery.source_read_models import (
        SourceReadLimits,
        SourceReadRequest,
    )
    from drm_copilot_discovery.source_reads import SourceReader

    selection = context.authority.read_selection
    if selection is None:
        raise OperationFailure("SERVICE_AUTHORITY", exit_code=3)
    limits = SourceReadLimits()
    maximum = cast("int", context.inputs.get("max_bytes", limits.output_bytes))
    limits = replace(limits, output_bytes=min(maximum, limits.output_bytes))

    def read(path: str, *, limit: int) -> bytes:
        """Return unchanged captured path bytes under int limit; raise OSError.

        Compare the trusted reader's current bytes before returning the retained
        value, preserving SourceReader freshness checks and capture attribution.
        """
        value = context.read(path)
        if (
            len(value) > limit
            or context.io.initialization.read_bytes(path, limit=limit) != value
        ):
            raise OSError("Captured source is excessive or changed")
        return value

    reader = SourceReader(
        context.snapshot.profile,
        catalog=context.snapshot.catalog,
        workspace_root=context.io.initialization.workspace_root,
        metadata=context.io.initialization.metadata,
        read_bytes=read,
        selection=selection,
        limits=limits,
    )
    try:
        request = SourceReadRequest(
            operation=cast(
                "Literal['list', 'read', 'search']", context.text("read_operation")
            ),
            paths=context.strings("paths"),
            query=context.text("query") or None,
            regex=cast("bool", context.inputs.get("regex", False)),
            line_start=cast("int", context.inputs.get("line_start", 1)),
            line_end=cast("int | None", context.inputs.get("line_end")),
        )
    except ValueError as error:
        raise OperationFailure("SERVICE_SOURCE") from error
    try:
        page = reader.inspect(request)
    except ValueError as error:
        raise OperationFailure("SERVICE_SOURCE") from error
    context.budget.work(len(page.items))
    rows: list[JsonObject] = []
    # Preserve every returned page row and its exact observed source digest.
    for item in page.items:
        line = item.span.line if item.span else None
        row = {
            "path": item.evidence.workspace_path,
            "revision": item.evidence.repository.revision,
            "sha256": item.evidence.sha256,
            "line_range": {"start": line, "end": line} if line is not None else None,
            "text": item.text,
            "matches": (
                ({"line": line, "text": item.text},)
                if page.operation == "search"
                else ()
            ),
        }
        context.budget.check(row)
        rows.append(wire_object(row, limits=context.limits))
    return context.result(
        source_reads=tuple(rows),
        counts=(
            ("total_rows", page.total),
            ("returned_rows", len(page.items)),
            ("truncated", int(page.next_cursor is not None)),
        ),
    )


def inspect_request(context: OperationContext) -> DiscoveryResult:
    """Compose fixed inspection routes for context; return DiscoveryResult.

    Existing validators retain graph-wide findings after the requested kind/path
    check. This service never filters truncated findings into target-only success.
    Captured reads, domain failures and guarded inventory publication are delegated.
    """
    from drm_copilot_discovery.schema_validation import validate_document
    from drm_copilot_discovery.validation import validate_snapshot

    operation = context.request.operation
    if operation in ("profile", "validate-profile"):
        return _profile(context)
    if operation == "inventory":
        return _inventory(context)
    if operation == "read-source":
        return _source(context)
    if operation == "doctor":
        from drm_copilot_discovery.doctor import inspect_doctor

        return inspect_doctor(
            io=context.io, request=context.request, runtime=context.runtime
        )
    kinds = {
        "validate-feature-contract": "feature-contract",
        "validate-coverage-ledger": "coverage-ledger",
        "validate-runtime-scenario": "runtime-characterization-scenario",
        "validate-parity-matrix": "parity-matrix",
        "validate-unspecified-behavior": "unspecified-behavior",
        "validate-product-decision": "product-decision",
        "validate-evidence-reference": "evidence-reference",
    }
    findings: tuple[Finding, ...] = ()
    if operation in kinds:
        path = context.text("artifact_path")
        checked = validate_document(
            context.read(path),
            expected_kind=kinds[operation],
            expected_version="2.0.0",
            format="yaml" if path.endswith((".yaml", ".yml")) else "json",
            artifact_path=path,
            catalog=context.snapshot.catalog,
            limits=context.limits,
        )
        findings = checked.findings
    elif operation != "validate-decisions":
        raise OperationFailure("SERVICE_OPERATION")
    assessment = validate_snapshot(context.snapshot, mode="structural")
    return context.result(
        findings=findings + assessment.findings,
        validation=assessment.validation_result,
        counts=(("graph_wide_assessment", 1),),
    )
