"""Decode and bind the protected host records a host-principal request depends on.

Every decoder validates the record bytes through the offline catalog with the
exact kind and version before reading a field, then binds the record to the
trusted outer values the gateway supplies: the activation workspace selection,
the host identity, the installed runtime and the sibling records. A failed
binding raises ``OperationFailure("SERVICE_AUTHORITY", exit_code=3)`` with a
distinct reason; no decoder returns a partial authority value or writes.
"""

from __future__ import annotations

from dataclasses import dataclass
from datetime import datetime
from typing import TYPE_CHECKING

from drm_copilot_discovery.findings import Finding
from drm_copilot_discovery.models import JsonObject
from drm_copilot_discovery.operations import OperationFailure
from drm_copilot_discovery.schema_validation import validate_document

if TYPE_CHECKING:
    from drm_copilot_discovery.catalog import SchemaCatalog
    from drm_copilot_discovery.models import ParseLimits
    from drm_copilot_discovery.service_contracts import RuntimeIdentity


@dataclass(frozen=True, kw_only=True)
class WorkspaceBinding:
    """Carry the activation selection a protected record must be bound to.

    The gateway derives the three values from the protected activation and the
    registry location, never from request JSON or from the record itself.
    """

    workspace_sha256: str
    profile_path: str
    profile_sha256: str


@dataclass(frozen=True, kw_only=True)
class TrustedIdentity:
    """Carry the trusted outer identity of one host-principal request.

    The host passes these values as fixed gateway options after verifying them
    through its own native events; a record that names any other value is refused.
    """

    host: str
    session_id: str
    agent_id: str
    role: str
    invocation_id: str


def refusal(reason: str, *, pointer: str = "/") -> OperationFailure:
    """Return the exit-3 authority failure for reason (str); perform no I/O.

    pointer (str) names the record location the reason concerns. The finding
    keeps the fixed SERVICE_AUTHORITY code so callers classify it uniformly while
    the message distinguishes the refusal class for diagnostics.
    """
    return OperationFailure(
        "SERVICE_AUTHORITY",
        exit_code=3,
        findings=(
            Finding(
                code="SERVICE_AUTHORITY",
                pointer=pointer,
                message=reason,
                next_action="Restore the protected host records and retry the request.",
            ),
        ),
    )


def _decode(
    content: bytes,
    *,
    kind: str,
    record: str,
    catalog: SchemaCatalog,
    limits: ParseLimits,
) -> JsonObject:
    """Validate content (bytes) as kind through the catalog; return the document.

    record (str) names the protected record for the refusal message. Malformed
    bytes, another kind or any schema error refuse before a field is read.
    """
    checked = validate_document(
        content,
        expected_kind=kind,
        expected_version="2.0.0",
        catalog=catalog,
        limits=limits,
    )
    if checked.document is None or any(
        finding.severity == "error" for finding in checked.findings
    ):
        raise refusal(f"The protected {record} record is not a valid {kind} document.")
    return checked.document


def _object(document: JsonObject, key: str) -> JsonObject:
    """Return the object member key (str) of document; refuse any other shape."""
    value = document.get(key)
    if type(value) is not JsonObject:
        raise refusal(f"The protected record member {key} is not an object.")
    return value


def _same_workspace(record: JsonObject, binding: WorkspaceBinding) -> bool:
    """Compare a record's workspace member with the trusted binding; no I/O."""
    workspace = _object(record, "workspace")
    return (
        workspace.get("workspace_sha256") == binding.workspace_sha256
        and workspace.get("profile_path") == binding.profile_path
        and workspace.get("profile_sha256") == binding.profile_sha256
    )


def _same_runtime(record: JsonObject, runtime: RuntimeIdentity) -> bool:
    """Compare a record's runtime member with the installed identity; no I/O."""
    value = _object(record, "runtime")
    return (
        value.get("package_version") == runtime.package_version
        and value.get("schema_version") == runtime.schema_version
        and value.get("build_sha256") == runtime.build_sha256
        and value.get("policy_version") == runtime.policy_version
        and value.get("policy_sha256") == runtime.policy_sha256
    )


def _same_principal(record: JsonObject, identity: TrustedIdentity) -> bool:
    """Compare host, session and role members of record with identity; no I/O."""
    return (
        record.get("host") == identity.host
        and record.get("session_id") == identity.session_id
        and record.get("role") == identity.role
    )


def decode_invocation(
    content: bytes,
    *,
    binding: WorkspaceBinding,
    identity: TrustedIdentity,
    runtime: RuntimeIdentity,
    catalog: SchemaCatalog,
    limits: ParseLimits,
) -> JsonObject:
    """Validate and bind the protected `discovery-invocation` record.

    content (bytes) is the stored record. The record must be bound to the
    activation workspace, name the trusted host, session, role and invocation,
    be in state `started` for the trusted agent, and be prepared for the
    installed runtime. Returns the validated JsonObject or raises the refusal.
    """
    document = _decode(
        content,
        kind="discovery-invocation",
        record="invocation",
        catalog=catalog,
        limits=limits,
    )
    # Each binding is checked in order so the first failing one names the reason.
    if not _same_workspace(document, binding):
        raise refusal("The invocation is bound to another workspace or profile.")
    if (
        not _same_principal(document, identity)
        or document.get("invocation_id") != identity.invocation_id
    ):
        raise refusal("The invocation is bound to another host identity.")
    if document.get("state") != "started":
        raise refusal("The invocation has not been started by the native host.")
    if document.get("agent_id") != identity.agent_id:
        raise refusal("The invocation was started for another agent.")
    if not _same_runtime(document, runtime):
        raise refusal("The invocation was prepared for another runtime.")
    return document


def decode_start_attestation(
    content: bytes,
    *,
    invocation: JsonObject,
    identity: TrustedIdentity,
    catalog: SchemaCatalog,
    limits: ParseLimits,
) -> JsonObject:
    """Validate and bind the native `start-attestation` record to the invocation.

    The attestation must carry the invocation's `start_attestation_ref`, name
    the invocation id, the trusted host, session, agent and role, the same
    workspace, capability reference and runtime as the started invocation.
    Returns the validated JsonObject or raises the refusal.
    """
    document = _decode(
        content,
        kind="start-attestation",
        record="start attestation",
        catalog=catalog,
        limits=limits,
    )
    if document.get("start_attestation_ref") != invocation.get(
        "start_attestation_ref"
    ) or document.get("invocation_ref") != invocation.get("invocation_id"):
        raise refusal("The start attestation is not the one the invocation names.")
    if (
        not _same_principal(document, identity)
        or document.get("agent_id") != identity.agent_id
    ):
        raise refusal("The start attestation names another host identity.")
    if (
        _object(document, "workspace") != _object(invocation, "workspace")
        or document.get("capability_ref") != invocation.get("capability_ref")
        or _object(document, "runtime") != _object(invocation, "runtime")
    ):
        raise refusal("The start attestation differs from the invocation bindings.")
    return document


def decode_capability_attestation(
    content: bytes,
    *,
    invocation: JsonObject,
    binding: WorkspaceBinding,
    identity: TrustedIdentity,
    runtime: RuntimeIdentity,
    catalog: SchemaCatalog,
    limits: ParseLimits,
) -> JsonObject:
    """Validate and bind the session `capability-attestation` record.

    The attestation must be the one the invocation's `capability_ref` names,
    report `supported`, and be bound to the activation workspace, the trusted
    host and session, and the installed runtime. Returns the validated
    JsonObject or raises the refusal.
    """
    document = _decode(
        content,
        kind="capability-attestation",
        record="capability attestation",
        catalog=catalog,
        limits=limits,
    )
    if document.get("attestation_ref") != invocation.get("capability_ref"):
        raise refusal("The capability attestation is not the one the invocation names.")
    if document.get("status") != "supported":
        raise refusal("The session capability attestation does not report support.")
    if not _same_workspace(document, binding):
        raise refusal("The capability attestation is bound to another workspace.")
    if (
        document.get("host") != identity.host
        or document.get("session_id") != identity.session_id
    ):
        raise refusal("The capability attestation names another host session.")
    if not _same_runtime(document, runtime):
        raise refusal("The capability attestation was observed for another runtime.")
    return document


def _instant(value: object) -> datetime | None:
    """Return the aware instant of a schema timestamp (str), or None when unreadable."""
    if not isinstance(value, str):
        return None
    try:
        parsed = datetime.fromisoformat(value.replace("Z", "+00:00"))
    except ValueError:
        return None
    # A timestamp without an offset is not a schema timestamp and binds nothing.
    return parsed if parsed.tzinfo is not None else None


def decode_authorization(
    content: bytes,
    *,
    latch_present: bool,
    now: datetime,
    used_latch_present: bool,
    invocation: JsonObject,
    identity: TrustedIdentity,
    operation: str,
    authorization_ref: str,
    catalog: SchemaCatalog,
    limits: ParseLimits,
) -> JsonObject:
    """Validate and bind one consumed `tool-authorization` record to the request.

    latch_present (bool) reports whether the exclusive `.consumed` latch exists;
    now (datetime) is the injected aware instant the grant is compared with;
    used_latch_present (bool) reports whether the runtime's exclusive `.used`
    latch already exists. The record must carry authorization_ref, be `consumed`
    with a stamp and a latch, be unexpired at now, not yet dispatched, authorize
    operation (str) for the invocation, bind the trusted identity and the
    invocation's workspace, start attestation and capability. Returns the
    validated JsonObject or raises the refusal.
    """
    document = _decode(
        content,
        kind="tool-authorization",
        record="authorization",
        catalog=catalog,
        limits=limits,
    )
    if document.get("authorization_ref") != authorization_ref:
        raise refusal("The authorization record is not the referenced grant.")
    if (
        document.get("state") != "consumed"
        or document.get("consumed_at") is None
        or not latch_present
    ):
        raise refusal("The authorization has not been consumed by the host gate.")
    # A grant is dispatched once and only inside its validity window.
    expires = _instant(document.get("expires_at"))
    if expires is None or expires <= now:
        raise refusal("The authorization expired before dispatch.")
    if used_latch_present:
        raise refusal("The authorization was already dispatched by the runtime.")
    if document.get("operation") != operation:
        raise refusal("The authorization was issued for another operation.")
    if document.get("invocation_ref") != invocation.get("invocation_id"):
        raise refusal("The authorization was issued for another invocation.")
    bound = _object(document, "identity")
    if (
        bound.get("host") != identity.host
        or bound.get("session_id") != identity.session_id
        or bound.get("agent_id") != identity.agent_id
        or bound.get("role") != identity.role
        or bound.get("invocation_id") != identity.invocation_id
    ):
        raise refusal("The authorization is bound to another native identity.")
    if (
        _object(document, "workspace") != _object(invocation, "workspace")
        or document.get("start_attestation_ref")
        != invocation.get("start_attestation_ref")
        or document.get("capability_ref") != invocation.get("capability_ref")
    ):
        raise refusal("The authorization differs from the invocation bindings.")
    return document


def decode_baseline_result(
    content: bytes,
    *,
    runtime: RuntimeIdentity,
    catalog: SchemaCatalog,
    limits: ParseLimits,
) -> JsonObject:
    """Validate the persisted `prepare-agent` baseline `service-result` document.

    The result must be the ok prepare-agent result of the installed runtime;
    its artifact rows and input manifest supply the pre-invocation baseline.
    Returns the validated JsonObject or raises the refusal.
    """
    document = _decode(
        content,
        kind="service-result",
        record="baseline",
        catalog=catalog,
        limits=limits,
    )
    if (
        document.get("operation") != "prepare-agent"
        or document.get("ok") is not True
        or document.get("exit_code") != 0
    ):
        raise refusal("The baseline is not an ok prepare-agent result.")
    if type(document.get("runtime")) is not JsonObject or not _same_runtime(
        document, runtime
    ):
        raise refusal("The baseline was pinned by another runtime.")
    return document
