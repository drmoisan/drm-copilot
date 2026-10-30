"""Finalize a verified host invocation's exact outputs without writing or minting."""

from __future__ import annotations

from typing import TYPE_CHECKING, Literal

from drm_copilot_discovery.coverage_scope_rules import object_rows
from drm_copilot_discovery.operations import OperationContext, OperationFailure
from drm_copilot_discovery.path_models import WriteGrant
from drm_copilot_discovery.service_contracts import ServiceArtifact
from drm_copilot_discovery.validation import validate_snapshot

if TYPE_CHECKING:
    from drm_copilot_discovery.models import JsonObject
    from drm_copilot_discovery.service_contracts import DiscoveryResult


def _refuse() -> OperationFailure:
    """Return the fixed exit-3 authority failure; perform no I/O."""
    return OperationFailure("SERVICE_AUTHORITY", exit_code=3)


def _output_row(
    context: OperationContext, granted: frozenset[WriteGrant], row: JsonObject
) -> ServiceArtifact | None:
    """Report one required output from the current capture; never write.

    context (OperationContext) owns the captured files; granted
    (frozenset[WriteGrant]) is the verified authority's grant set; row
    (JsonObject) is one schema-validated required-output row. Returns a
    ServiceArtifact with status ``created`` (no prior digest), ``updated`` (prior
    digest) or ``conflict`` (prior digest but the path is absent), or None when
    the path is absent and no prior digest exists, because a row needs a real
    digest and that case has none; the OUTPUT_MISSING finding reports it.
    Raises OperationFailure("SERVICE_AUTHORITY", exit_code=3) for a row that is
    not a grant of the authority: the host cannot finalize an ungranted output.
    """
    kind, identifier, path, expected = (
        row.get("artifact_kind"),
        row.get("id"),
        row.get("path"),
        row.get("expected_sha256"),
    )
    # A row outside the verified grants is an authority mismatch, not an output defect.
    if (
        type(kind) is not str
        or type(identifier) is not str
        or type(path) is not str
        or (expected is not None and type(expected) is not str)
        or WriteGrant(artifact_kind=kind, artifact_id=identifier, path=path)
        not in granted
    ):
        raise _refuse()
    captured = context.files.get(path)
    # Presence and the pinned prior digest decide the status; an absent output with
    # no prior bytes has no digest to report and is left to the validation finding.
    if captured is None:
        if expected is None:
            return None
        return ServiceArtifact(path=path, kind=kind, status="conflict", sha256=expected)
    status: Literal["created", "updated"] = "created" if expected is None else "updated"
    return ServiceArtifact(path=path, kind=kind, status=status, sha256=captured.sha256)


def finalize_agent(context: OperationContext) -> DiscoveryResult:
    """Return the finalize-agent result for a verified host invocation.

    context (OperationContext) carries a host authority whose invocation the
    service admitted (P12-T7 rules) and the current configured capture. The
    route refuses a non-host or invocation-less authority and a non-agent-output
    mode, requires every required-output row to be a grant of the authority,
    reports one artifact row per required output from the current capture, runs
    validate_snapshot in agent-output mode against the verified invocation, and
    returns exit 0 only when the output set is valid and the result is ``pass``;
    otherwise exit 1 with the error findings. The summary carries the invocation
    id and a null receipt reference: the Python runtime never mints a receipt and
    this route performs no write. Raises OperationFailure for refusals.
    """
    authority = context.authority
    invocation = authority.invocation
    # Only a verified host invocation can be finalized; local-user has no invocation.
    if authority.principal != "host" or invocation is None:
        raise _refuse()
    if context.request.mode != "agent-output":
        raise OperationFailure("SERVICE_MODE")
    snapshot = context.snapshot
    rows = object_rows(invocation.required_outputs.get("outputs"))
    context.budget.work(4 * len(rows))
    granted = frozenset(authority.grants)
    artifacts: list[ServiceArtifact] = []
    missing = 0
    # Report every required output so the gate sees the complete delivered set.
    for _, row in rows:
        artifact = _output_row(context, granted, row)
        if artifact is None:
            missing += 1
            continue
        if artifact.status == "conflict":
            missing += 1
        artifacts.append(artifact)
    assessment = validate_snapshot(snapshot, mode="agent-output", invocation=invocation)
    passed = assessment.output_valid is True and assessment.validation_result == "pass"
    return context.result(
        findings=assessment.findings,
        artifacts=tuple(artifacts),
        validation=assessment.validation_result,
        exit_code=0 if passed else 1,
        counts=(("required_outputs", len(rows)), ("missing_outputs", missing)),
        invocation_ref=invocation.invocation_id,
    )
