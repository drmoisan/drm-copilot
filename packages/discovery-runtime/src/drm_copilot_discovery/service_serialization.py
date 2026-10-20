"""Bound service wire values before copying, encoding or core schema validation."""

from __future__ import annotations

import re
from typing import TYPE_CHECKING, cast

from drm_copilot_discovery.catalog import SchemaCatalog, load_catalog
from drm_copilot_discovery.findings import MAX_FINDINGS, Finding, ordered_findings
from drm_copilot_discovery.models import (
    JsonObject,
    JsonValue,
    ParseLimits,
    canonical_json,
)
from drm_copilot_discovery.path_models import relative_path
from drm_copilot_discovery.report_models import (
    ReportBudget,
    ReportLimitError,
    bounded_object,
)
from drm_copilot_discovery.schema_validation import validate_document
from drm_copilot_discovery.service_request_rules import check_combinations

if TYPE_CHECKING:
    from drm_copilot_discovery.service_contracts import (
        DiscoveryResult,
        ServiceArtifact,
        ServiceRequest,
    )
    from drm_copilot_discovery.snapshot import InputManifest

_OUTPUT_KINDS = frozenset(
    (
        "domain-profile",
        "scope",
        "feature-contract",
        "coverage-ledger",
        "runtime-characterization-scenario",
        "parity-matrix",
        "unspecified-behavior",
        "product-decision",
        "evidence-reference",
        "inventory-snapshot",
        "acceptance-specification",
        "source-snapshot-manifest",
        "implementation-record",
        "unspecified-behavior-collection",
        "product-decision-collection",
        "extension-result-manifest",
        "coverage-report",
        "parity-report",
        "completion-report",
        "validation-report",
        "migration-report",
        "acceptance-view",
        "evidence-payload",
        "activation",
        "required-output-manifest",
    )
)


def _reserve(value: object, budget: ReportBudget, depth: int = 1) -> None:
    """Reserve value traversal/sort work; return None or a fixed resource error.

    value is existing JSON-shaped data, budget is call-local ReportBudget, and
    depth is internal int. Work counts node visits and compared/copied characters.
    Bounds precede each scan; no containers or encoded strings are copied.
    """
    if depth > budget.limits.nesting_depth:
        raise ReportLimitError()
    budget.work(8)
    if type(value) is str:
        budget.work(8 * len(value))
    elif type(value) in (dict, JsonObject):
        mapping = cast("dict[str, object] | JsonObject", value)
        budget.work(4 * len(mapping))
        members = mapping.members if type(mapping) is JsonObject else mapping.items()
        # Charge worst-case key sorting comparisons before copying frozen members.
        for key, child in members:
            if type(key) is not str:
                raise ValueError("Service wire keys must be strings")
            budget.work(len(key) * (len(mapping).bit_length() + 8))
            _reserve(child, budget, depth + 1)
    elif type(value) in (tuple, list):
        sequence = cast("tuple[object, ...] | list[object]", value)
        budget.work(4 * len(sequence))
        # Reserve each retained child before recursively measuring its contents.
        for child in sequence:
            _reserve(child, budget, depth + 1)


def wire_object(value: object, *, limits: ParseLimits) -> JsonObject:
    """Freeze value (JSON object) under limits; return detached immutable fields.

    Raises ValueError/ReportLimitError before excessive copies or encoding.
    Independent work, node, record, depth and canonical UTF-8 byte budgets apply.
    Eight encoded-byte units cover the fixed measuring/freezing/encoding passes.
    No I/O or caller mutation occurs.
    """
    budget = ReportBudget(limits)
    _reserve(value, budget)
    budget.check(value)
    budget.work(8 * (limits.document_bytes - budget.bytes_left))
    return bounded_object(value, limits=limits)


def _finding_fields(finding: Finding) -> dict[str, object]:
    """Project Finding references to a fixed dict; no nested copy, I/O or errors."""
    return {
        "code": finding.code,
        "severity": finding.severity,
        "artifact_path": finding.artifact_path,
        "pointer": finding.pointer,
        "related_ids": finding.related_ids,
        "related_paths": finding.related_paths,
        "message": finding.message,
        "next_action": finding.next_action,
    }


def normalize_findings(
    findings: tuple[Finding, ...], *, limits: ParseLimits
) -> tuple[Finding, ...]:
    """Return ordered findings within typed limits, preserving blocking errors.

    Reject malformed tuples with ValueError or excess with ReportLimitError.
    Reserve record/text/sort work before ordering; no I/O or input mutation.
    """
    budget = ReportBudget(limits)
    if type(findings) is not tuple:
        raise ValueError("Service findings require an immutable tuple")
    if len(findings) > min(MAX_FINDINGS, limits.expanded_nodes):
        raise ReportLimitError()
    budget.work(16 * len(findings))
    # Ordering compares bounded finding text, not uncharged arbitrary payloads.
    for finding in findings:
        if type(finding) is not Finding:
            raise ValueError("Service findings require Finding records")
        fields = _finding_fields(finding)
        _reserve(fields, budget)
        before = budget.bytes_left
        budget.check(fields)
        budget.work((before - budget.bytes_left) * (len(findings).bit_length() + 2))
    return ordered_findings(findings, limit=MAX_FINDINGS)


def _artifact_fields(artifact: ServiceArtifact) -> dict[str, object]:
    """Return fixed artifact fields referencing existing strings, without I/O."""
    fields: dict[str, object] = {
        "path": artifact.path,
        "kind": artifact.kind,
        "status": artifact.status,
        "sha256": artifact.sha256,
    }
    if artifact.content is not None:
        fields["content"] = artifact.content
    return fields


def artifact_document(artifact: ServiceArtifact, *, limits: ParseLimits) -> JsonObject:
    """Validate immutable artifact fields; return bounded wire object without I/O.

    Raises ValueError/ReportLimitError for invalid kinds, paths, status, text or
    SHA-256. This consistency check does not establish an actual file effect.
    """
    document = wire_object(_artifact_fields(artifact), limits=limits)
    if (
        type(artifact.path) is not str
        or type(artifact.kind) is not str
        or artifact.kind not in _OUTPUT_KINDS
        or artifact.status
        not in ("planned", "created", "updated", "skipped", "conflict")
        or type(artifact.sha256) is not str
        or re.fullmatch("[0-9a-f]{64}", artifact.sha256) is None
        or (artifact.content is not None and type(artifact.content) is not str)
    ):
        raise ValueError("Service artifact fields are invalid")
    relative_path(artifact.path)
    return document


def _request_fields(request: ServiceRequest) -> dict[str, object]:
    """Return fixed request/header references; no I/O, traversal or input mutation."""
    return {
        "$schema": "urn:drm-copilot:discovery:2.0.0:service-request",
        "schema_version": "2.0.0",
        "artifact_kind": "service-request",
        "id": request.id,
        "request_id": request.request_id,
        "operation": request.operation,
        "mode": request.mode,
        "workspace_root": request.workspace_root,
        "profile_path": request.profile_path,
        "dry_run": request.dry_run,
        "write": request.write,
        "format": request.format,
        "inputs": request.inputs,
        "invocation_ref": request.invocation_ref,
        "authorization_ref": request.authorization_ref,
    }


def check_request(request: ServiceRequest) -> None:
    """Check request typed fields/combinations; return None without schema I/O.

    Raises ValueError/ReportLimitError for malformed or excessive direct values.
    Exact wire schema validation is performed by the public parser separately.
    """
    fields = _request_fields(request)
    wire_object(fields, limits=ParseLimits())
    if (
        type(request.inputs) is not JsonObject
        or type(request.dry_run) is not bool
        or type(request.write) is not bool
        or request.format not in ("json", "markdown", "both")
        or any(
            type(fields[name]) is not str
            for name in ("id", "request_id", "operation", "mode", "workspace_root")
        )
        or any(
            fields[name] is not None and type(fields[name]) is not str
            for name in ("profile_path", "invocation_ref", "authorization_ref")
        )
    ):
        raise ValueError("Service request fields have invalid types")
    check_combinations(fields)


def checked_request_document(
    value: JsonValue, *, catalog: SchemaCatalog, limits: ParseLimits
) -> tuple[JsonObject | None, tuple[Finding, ...]]:
    """Return validated immutable request or fixed actionable invocation errors.

    value is immutable JSON; catalog/limits are trusted typed caller policy.
    Resource/shape errors are redacted, not arbitrary downstream failures.
    No I/O, request authority or operation execution occurs.
    """
    try:
        document = wire_object(value, limits=limits)
        checked = validate_document(
            canonical_json(document),
            expected_kind="service-request",
            expected_version="2.0.0",
            catalog=catalog,
            limits=limits,
        )
        if not checked.ok:
            raise ValueError("Service request schema is invalid")
        check_combinations(dict(document.members))
    except (ValueError, UnicodeError):
        return None, (
            Finding(
                code="SERVICE_REQUEST",
                pointer="/",
                message="Request shape, operation or resource bounds are invalid.",
                next_action="Use the service request schema and applicable inputs.",
            ),
        )
    return document, ()


def _manifest(manifest: InputManifest, budget: ReportBudget) -> dict[str, object]:
    """Reserve manifest serialization/hashing, then return its accepted projection.

    manifest retains immutable captured bytes; budget is the enclosing result's
    local policy. Raises ReportLimitError before traversal/copy/hash exhaustion.
    Counts include both accepted to_dict content hash scans. Text is prepaid
    before measuring; sixteen measured-byte units cover the two input copies,
    canonical serialization, sorting and digest scan. No source I/O occurs.
    """
    count = len(manifest.files) + len(manifest.missing_paths)
    count += len(manifest.source_repositories) + len(manifest.target_repositories)
    budget.work(256 + 128 * count)
    before = budget.bytes_left
    budget.spend(200 * count + 256)
    # Captured file contents are hashed twice by the accepted manifest projection.
    for file in manifest.files:
        budget.work(2 * len(file.content))
        _reserve((file.path, file.category), budget)
        budget.check((file.path, file.category))
    # Pins and missing paths contribute text even when there are no file rows.
    for path in manifest.missing_paths:
        _reserve(path, budget)
        budget.check(path)
    # Complete both independent role populations before projecting or hashing.
    for identities in (manifest.source_repositories, manifest.target_repositories):
        # Role pins remain distinct; a combined repository appears in both lists.
        for identity in identities:
            _reserve((identity.id, identity.revision), budget)
            budget.check((identity.id, identity.revision))
    budget.work(16 * (before - budget.bytes_left))
    return manifest.to_dict()


def result_document(result: DiscoveryResult, *, limits: ParseLimits) -> JsonObject:
    """Project a consistent result under limits; return bounded immutable JSON.

    Raises ValueError/ReportLimitError before excessive row retention, hashing or
    encoding. Null pre-execution context cannot claim artifacts, counts or a
    validation outcome. Captured empty manifests remain real non-null values.
    One cumulative work budget covers each preflight and later projection.
    A separate exact final wire measurement checks canonical bytes/nodes; it
    never resets work. No schema I/O, writes or execution authority occurs.
    """
    budget = ReportBudget(limits)
    budget.work(64 * (len(result.findings) + len(result.artifacts)))
    runtime = result.runtime
    fields: dict[str, object] = {
        "result_version": "2.0.0",
        "operation": result.operation,
        "mode": result.mode,
        "ok": result.ok,
        "exit_code": result.exit_code,
        "findings": (),
        "artifacts": (),
        "summary": None,
        "input_manifest": None,
        "runtime": (
            {
                "package_version": runtime.package_version,
                "schema_version": runtime.schema_version,
                "build_sha256": runtime.build_sha256,
                "policy_version": runtime.policy_version,
                "policy_sha256": runtime.policy_sha256,
            }
            if runtime
            else None
        ),
    }
    _reserve(fields, budget)
    budget.check(fields)
    _reserve(result.summary, budget)
    budget.check(result.summary)
    summary = dict(result.summary.members)
    required = {
        "message",
        "counts",
        "validation_result",
        "receipt_ref",
        "invocation_ref",
    }
    if not required <= summary.keys() or summary.keys() - required - {
        "deployment",
        "source_reads",
    }:
        raise ValueError("Service summary has invalid fields")
    errors = any(finding.severity == "error" for finding in result.findings)
    if result.ok != (result.exit_code == 0) or result.ok == errors:
        raise ValueError("Service result success and diagnostics disagree")
    unknown = result.operation is None or result.mode is None
    missing = unknown or result.runtime is None or result.input_manifest is None
    if (unknown and result.exit_code != 2) or (
        missing and result.exit_code not in (2, 3)
    ):
        raise ValueError("Service result context is unavailable for this outcome")
    if missing and (
        result.artifacts
        or summary["counts"] != ()
        or any(
            summary[key] is not None
            for key in ("validation_result", "receipt_ref", "invocation_ref")
        )
        or not any(f.pointer for f in result.findings if f.severity == "error")
    ):
        raise ValueError("Pre-execution failure cannot claim evaluated output")
    findings: list[dict[str, object]] = []
    artifacts: list[dict[str, object]] = []
    # Measure each row before retention; no full unbounded intermediate is built.
    for finding in result.findings:
        row = _finding_fields(finding)
        _reserve(row, budget)
        budget.check(row)
        findings.append(row)
    # Artifact content receives the same aggregate reservation as finding text.
    for artifact in result.artifacts:
        row = _artifact_fields(artifact)
        _reserve(row, budget)
        budget.check(row)
        if result.ok and artifact.status == "conflict":
            raise ValueError("Successful results cannot contain conflicts")
        artifacts.append(row)
    fields.update(findings=findings, artifacts=artifacts, summary=result.summary)
    if result.input_manifest is not None:
        fields["input_manifest"] = _manifest(result.input_manifest, budget)
    # Reserve final measurement/freezing/encoding against the same remaining work.
    _reserve(fields, budget)
    output = ReportBudget(limits)
    output.check(fields)
    budget.work(8 * (limits.document_bytes - output.bytes_left))
    return bounded_object(fields, limits=limits)


def checked_result_document(
    result: DiscoveryResult, *, catalog: SchemaCatalog | None, limits: ParseLimits
) -> JsonObject:
    """Return result JSON after trusted core validation under explicit limits.

    None catalog invokes the accepted installed reader; supplied SchemaCatalog
    stays pure. Raises fixed ValueError/ReportLimitError; installed catalog
    failures propagate. No workspace selection, execution or publication occurs.
    """
    document = result_document(result, limits=limits)
    trusted = load_catalog() if catalog is None else catalog
    checked = validate_document(
        canonical_json(document),
        expected_kind="service-result",
        expected_version="2.0.0",
        catalog=trusted,
        limits=limits,
    )
    if not checked.ok:
        raise ValueError("Service result violates the trusted core schema")
    return document
