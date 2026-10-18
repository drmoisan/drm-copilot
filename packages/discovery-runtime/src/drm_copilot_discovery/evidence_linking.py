"""Register locally verifiable evidence without changing any observation or approval."""

from __future__ import annotations

from dataclasses import dataclass
from typing import TYPE_CHECKING, cast

from drm_copilot_discovery.catalog import V2_URN
from drm_copilot_discovery.evidence_rules import assess_evidence
from drm_copilot_discovery.findings import child_pointer
from drm_copilot_discovery.models import JsonObject, JsonValue, canonical_json
from drm_copilot_discovery.mutation_io import commit_mutation
from drm_copilot_discovery.mutation_plan import (
    MutationChange,
    MutationError,
    plan_mutation,
)
from drm_copilot_discovery.path_models import WriteGrant, relative_path
from drm_copilot_discovery.reference_links import schema_references
from drm_copilot_discovery.references import ArtifactRecord, index_references
from drm_copilot_discovery.revision_rules import RevisionInputs
from drm_copilot_discovery.schema_validation import validate_document

if TYPE_CHECKING:
    from drm_copilot_discovery.agent_output import InvocationContext
    from drm_copilot_discovery.mutation_io import MutationResult, MutationWriter
    from drm_copilot_discovery.mutation_plan import CapturedWorkspace, MutationPlan


@dataclass(frozen=True, kw_only=True)
class EvidencePayload:
    """Carry exact supplied bytes for exclusive creation under an allowed evidence root.

    The relative path must be named by the evidence record. Construction performs
    no I/O and grants no authority; the shared planner enforces roots and grants.
    """

    path: str
    content: bytes

    def __post_init__(self) -> None:
        """Reject unsafe names or mutable payloads with ValueError; return None."""
        relative_path(self.path)
        if not isinstance(cast("object", self.content), bytes):
            raise ValueError("Evidence payload content must be immutable bytes")


@dataclass(frozen=True, kw_only=True)
class EvidenceLink:
    """Select one local artifact/member, its original digest and supplied provenance.

    link_path optionally names an existing evidence-reference array relative to
    the selected record, using object keys and integer array positions. Defaults
    cover feature, scenario, question, decision approval and implementation links.
    Collection members require a grant for their containing file. These inputs
    convey no native authority and cannot set claim, run or approval state.
    """

    artifact_kind: str
    artifact_id: str
    expected_sha256: str
    record: JsonObject
    payloads: tuple[EvidencePayload, ...] = ()
    link_path: tuple[str | int, ...] = ()

    def __post_init__(self) -> None:
        """Detach sequences and check selectors; invalid inputs raise ValueError."""
        object.__setattr__(self, "payloads", tuple(self.payloads))
        object.__setattr__(self, "link_path", tuple(self.link_path))
        MutationChange(
            artifact_kind=self.artifact_kind,
            artifact_id=self.artifact_id,
            path="selected.json",
            content=b"",
            expected_sha256=self.expected_sha256,
        )
        if (
            cast("object", self.expected_sha256) is None
            or not isinstance(cast("object", self.record), JsonObject)
            or any(
                not isinstance(cast("object", item), EvidencePayload)
                for item in self.payloads
            )
            or any(
                type(item) not in (str, int) or isinstance(item, int) and item < 0
                for item in self.link_path
            )
        ):
            raise ValueError(
                "Evidence links require immutable provenance and selectors"
            )


def _default_path(kind: str, evidence_type: JsonValue) -> tuple[str | int, ...]:
    """Choose only existing core link fields; row-based artifacts need a selector."""
    # Runtime captures and manual observations belong to the feature's runtime links.
    if kind == "feature-contract":
        return (
            (
                "runtime_evidence_refs"
                if evidence_type in ("runtime", "observation")
                else "source_evidence_refs"
            ),
        )
    return {
        "runtime-characterization-scenario": ("evidence_refs",),
        "unspecified-behavior": ("evidence_refs",),
        "acceptance-specification": ("evidence_refs",),
        "implementation-record": ("verification_evidence_refs",),
        "product-decision": ("approval", "evidence_refs"),
    }.get(kind, ())


def _append_link(
    value: JsonValue, path: tuple[str | int, ...], reference: JsonObject
) -> tuple[JsonValue, int]:
    """Copy one selected array while preserving every unrelated value and state."""
    # Only the selected leaf can grow; object members and array siblings stay exact.
    if not path:
        if not isinstance(value, tuple):
            raise MutationError("EVIDENCE_LINK_FIELD", "Select an existing link array")
        if reference in value:
            return value, value.index(reference)
        return (*value, reference), len(value)
    head, *tail = path
    if isinstance(value, JsonObject) and isinstance(head, str) and head in value:
        updated, position = _append_link(value[head], tuple(tail), reference)
        return JsonObject(tuple({**value, head: updated}.items())), position
    if isinstance(value, tuple) and isinstance(head, int) and 0 <= head < len(value):
        updated, position = _append_link(value[head], tuple(tail), reference)
        return (*value[:head], updated, *value[head + 1 :]), position
    raise MutationError("EVIDENCE_LINK_FIELD", "The selected link field does not exist")


def _linked_document(
    baseline: CapturedWorkspace,
    target: ArtifactRecord,
    request: EvidenceLink,
    reference: JsonObject,
) -> JsonObject:
    """Append only where the accepted schema identifies an evidence reference.

    Schema-directed traversal excludes extension payloads and arbitrary arrays.
    The containing artifact is preserved, including collection siblings and all
    observation/approval fields. Missing or non-evidence locations fail explicitly.
    """
    selected = request.link_path or _default_path(
        target.kind, request.record.get("evidence_type")
    )
    # Indexed member pointers are generated by the accepted collection index.
    prefix: tuple[str | int, ...] = tuple(
        int(part) if part.isdecimal() else part
        for part in target.pointer.split("/")[1:]
    )
    path = prefix + selected
    document, position = _append_link(target.artifact.document, path, reference)
    pointer = ""
    # Retain exact array position for the shared schema traversal's typed leaf.
    for part in (*path, position):
        pointer = child_pointer(pointer, part)
    schemas = dict(baseline.snapshot.catalog.documents)
    identifier = V2_URN + target.artifact.expected_kind
    if not any(
        location == pointer and expected == "evidence-reference"
        for location, _, expected, _ in schema_references(
            document, schemas[identifier], schemas, base=identifier, pointer=""
        )
    ):
        raise MutationError(
            "EVIDENCE_LINK_FIELD", "Select a core evidence-reference array"
        )
    return cast("JsonObject", document)


def evidence_changes(
    baseline: CapturedWorkspace, request: EvidenceLink
) -> tuple[MutationChange, ...]:
    """Project create-only evidence/payloads and one exact-byte artifact update.

    Uses the accepted schema and reference index; no local or remote I/O occurs.
    Invalid metadata, duplicate identities, absent/imported targets and unrelated
    payloads raise MutationError. This projection is not a validated write plan;
    roots, grants, freshness and the complete graph are checked by plan_evidence_link.
    """
    snapshot = baseline.snapshot
    if not snapshot.ok:
        raise MutationError(
            "EVIDENCE_BASELINE",
            "Captured inputs are invalid",
            findings=snapshot.findings,
        )
    content = canonical_json(request.record)
    validation = validate_document(
        content,
        expected_kind="evidence-reference",
        expected_version="2.0.0",
        catalog=snapshot.catalog,
        limits=snapshot.profile.limits.parse_limits(),
    )
    if not validation.ok:
        raise MutationError(
            "EVIDENCE_RECORD",
            "Evidence metadata is invalid",
            findings=validation.findings,
        )
    identifier = cast("str", request.record["id"])
    path = snapshot.profile.artifacts["evidence"] + "/" + identifier + ".json"
    index = index_references(snapshot)
    # IDs remain repository-scoped; imported evidence is never overwritten locally.
    for field in ("id", "evidence_id"):
        if index.candidates(
            "evidence-reference",
            cast("str", request.record[field]),
            repository=snapshot.profile.repository.id,
            identity_field=field,
        ):
            raise MutationError(
                "EVIDENCE_DUPLICATE", "Evidence identity already exists"
            )
    targets = index.candidates(
        request.artifact_kind,
        request.artifact_id,
        repository=snapshot.profile.repository.id,
    )
    if len(targets) != 1 or targets[0].artifact.origin_path is not None:
        raise MutationError("EVIDENCE_TARGET", "Select one captured local artifact")
    target = targets[0]
    # Local links use the accepted ID form; transport paths require full pinned refs.
    reference = JsonObject(
        (("artifact_kind", "evidence-reference"), ("id", identifier))
    )
    updated = _linked_document(baseline, target, request, reference)
    changes = [
        MutationChange(
            artifact_kind="evidence-reference",
            artifact_id=identifier,
            path=path,
            content=content,
            expected_sha256=None,
        ),
        MutationChange(
            artifact_kind=target.artifact.expected_kind,
            artifact_id=cast("str", cast("JsonObject", target.artifact.document)["id"]),
            path=target.artifact.path,
            content=canonical_json(updated),
            expected_sha256=request.expected_sha256,
        ),
    ]
    runtime = request.record.get("runtime_artifact")
    payload_paths = {request.record.get("path")}
    if isinstance(runtime, JsonObject):
        payload_paths.add(runtime.get("path"))
    # Supplied bytes cannot smuggle unrelated files into the authorized operation.
    for payload in request.payloads:
        if payload.path not in payload_paths:
            raise MutationError(
                "EVIDENCE_PAYLOAD", "Payload is not named by the record"
            )
        changes.append(
            MutationChange(
                artifact_kind="evidence-payload",
                artifact_id=identifier,
                path=payload.path,
                content=payload.content,
                expected_sha256=None,
            )
        )
    return tuple(changes)


def plan_evidence_link(
    baseline: CapturedWorkspace,
    request: EvidenceLink,
    *,
    grants: tuple[WriteGrant, ...],
    invocation: InvocationContext | None = None,
) -> MutationPlan:
    """Validate a complete prospective graph and require exact local evidence bytes.

    Grants/invocation are forwarded unchanged, never generated here. Source/test
    proof requires objects already captured at full pins in baseline; working-tree
    bytes are not substituted. URI-only descriptions cannot satisfy this operation.
    Shared planning errors or EVIDENCE_UNVERIFIED propagate before any writes.
    """
    plan = plan_mutation(
        baseline,
        evidence_changes(baseline, request),
        grants=grants,
        invocation=invocation,
    )
    index = index_references(plan.prospective)
    record = index.candidates(
        "evidence-reference",
        cast("str", request.record["id"]),
        repository=plan.prospective.profile.repository.id,
    )[0]
    assessment = assess_evidence(RevisionInputs(plan.prospective), record)
    if not assessment.locally_verified:
        raise MutationError(
            "EVIDENCE_UNVERIFIED",
            "Evidence must identify locally verified bytes",
            findings=assessment.findings,
        )
    return plan


def link_evidence(
    baseline: CapturedWorkspace,
    request: EvidenceLink,
    *,
    grants: tuple[WriteGrant, ...],
    writer: MutationWriter,
    dry_run: bool = False,
    invocation: InvocationContext | None = None,
) -> MutationResult:
    """Register and link through the shared writer, returning its explicit outcome.

    Planning exceptions propagate without writes. The injected trusted writer owns
    freshness, invalidation and per-file publication; partial failures remain in its
    MutationResult. Dry-run performs validation without writes or invalidation.
    Neither a link nor a successful result promotes a claim or product approval.
    """
    return commit_mutation(
        plan_evidence_link(baseline, request, grants=grants, invocation=invocation),
        writer=writer,
        dry_run=dry_run,
    )
