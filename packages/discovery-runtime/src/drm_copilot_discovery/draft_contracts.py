"""Create truthful contract proposals through the accepted graph mutation boundary.

Draft identities and grants are distinct inputs. This module performs no native
I/O; callers supply authenticated grants and the existing mutation writer.
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import TYPE_CHECKING, cast

from drm_copilot_discovery.models import JsonObject, JsonValue, canonical_json
from drm_copilot_discovery.mutation_io import commit_mutation
from drm_copilot_discovery.mutation_plan import (
    MutationChange,
    MutationError,
    plan_mutation,
)
from drm_copilot_discovery.path_models import WriteGrant
from drm_copilot_discovery.profile_models import FEATURE_DIMENSIONS, ProfileRequirements

if TYPE_CHECKING:
    from collections.abc import Mapping

    from drm_copilot_discovery.agent_output import InvocationContext
    from drm_copilot_discovery.mutation_io import MutationResult, MutationWriter
    from drm_copilot_discovery.mutation_plan import CapturedWorkspace, MutationPlan


def draft_object(**fields: JsonValue) -> JsonObject:
    """Return immutable JSON from typed keyword members without external effects.

    JsonObject rejects mutable descendants with TypeError/ValueError; callers
    retain their input objects and receive a detached member tuple.
    """
    return JsonObject(tuple(fields.items()))


def draft_header(kind: str, identifier: str) -> dict[str, JsonValue]:
    """Return fixed v2 header members for the given kind and stable identifier.

    This pure projection leaves schema/path validation to the shared planner;
    it does not interpret these strings as native authority.
    """
    return {
        "$schema": "urn:drm-copilot:discovery:2.0.0:" + kind,
        "schema_version": "2.0.0",
        "artifact_kind": kind,
        "id": identifier,
        "extensions": JsonObject(()),
    }


def draft_reference(kind: str, identifier: str) -> JsonObject:
    """Return an immutable kind/identifier link without resolving or granting it."""
    return draft_object(artifact_kind=kind, id=identifier)


def merge_draft_fields(
    defaults: Mapping[str, JsonValue], supplied: JsonObject, *, fixed: tuple[str, ...]
) -> dict[str, JsonValue]:
    """Return detached defaults overlaid with immutable caller planning members.

    Fixed names must retain their default values or MutationError is raised.
    Unknown fields remain visible to the accepted schema validator. No input or
    external state is changed.
    """
    result = dict(defaults)
    # Preserve planning detail while preventing changes to creation invariants.
    for name, value in supplied.items():
        if name in fixed and value != defaults[name]:
            raise MutationError("DRAFT_CLAIM", f"Creation cannot change {name}")
        result[name] = value
    return result


def open_question(
    identifier: str,
    *,
    features: tuple[str, ...],
    dimensions: tuple[str, ...],
    question: str,
) -> JsonObject:
    """Return an open question for selected feature IDs and dimension names.

    The supplied text describes uncertainty; owner, resolution and evidence stay
    unset. This pure projection delegates shape/link validation to the planner.
    """
    fields = draft_header("unspecified-behavior", identifier)
    # Every selected feature must remain explicit in the unresolved record.
    feature_refs = tuple(draft_reference("feature-contract", name) for name in features)
    fields.update(
        behavior_id=identifier,
        feature_refs=feature_refs,
        dimensions=dimensions,
        question=question,
        evidence_refs=(),
        competing_interpretations=(),
        impact="Characterization and acceptance expectations remain unresolved.",
        status="open",
        decision_owner=None,
        decision_ref=None,
        decision=None,
        rationale=None,
        approved_target_behavior=None,
        acceptance_test_implications=(),
        resolution_basis=None,
        resolution_evidence_refs=(),
    )
    return JsonObject(tuple(fields.items()))


def append_questions(
    baseline: CapturedWorkspace, questions: tuple[JsonObject, ...]
) -> MutationChange:
    """Return a collection change that appends immutable questions to captured data.

    The CapturedWorkspace supplies configured paths and original-byte CAS. Invalid
    baseline/collection data raises MutationError with available findings. Existing
    records and extension values are preserved; this function performs no I/O.
    """
    snapshot = baseline.snapshot
    if not snapshot.ok:
        raise MutationError(
            "DRAFT_BASELINE",
            "Correct invalid captured inputs first",
            findings=snapshot.findings,
        )
    path = snapshot.profile.artifacts["unspecified_behaviors"]
    # Resolve only the configured collection, never an arbitrary matching kind.
    original = next((item for item in snapshot.artifacts if item.path == path), None)
    # Absence authorizes only a create proposal; existing bytes remain a CAS input.
    if original is None:
        document = draft_header(
            "unspecified-behavior-collection",
            "unresolved-" + snapshot.profile.system.id,
        )
        document["records"] = ()
        expected = None
    else:
        if (
            original.expected_kind != "unspecified-behavior-collection"
            or original.document is None
        ):
            raise MutationError(
                "DRAFT_COLLECTION", "The configured unresolved collection is invalid"
            )
        document = dict(original.document)
        expected = snapshot.file(path).sha256
    # The accepted loader validates existing required fields before extraction.
    records = cast("tuple[JsonValue, ...]", document["records"])
    document["records"] = records + questions
    return MutationChange(
        artifact_kind="unspecified-behavior-collection",
        artifact_id=cast("str", document["id"]),
        path=path,
        content=canonical_json(JsonObject(tuple(document.items()))),
        expected_sha256=expected,
    )


@dataclass(frozen=True, kw_only=True)
class ContractDraft:
    """Carry selected feature identity and immutable optional planning fields.

    Construct with an explicit ID/name, then pass to plan_contract/create_contract
    with separately authenticated grants. Construction checks ID syntax and input
    immutability; graph validation remains the planner's responsibility. This value
    performs no I/O and cannot supply native authority.
    """

    feature_id: str
    name: str
    capability_group: str = "unclassified"
    fields: JsonObject = JsonObject(())

    def __post_init__(self) -> None:
        """Return None after checking stored inputs; invalid values raise ValueError."""
        WriteGrant(
            artifact_kind="feature-contract",
            artifact_id=self.feature_id,
            path=self.feature_id + ".json",
        )
        if (
            not isinstance(cast("object", self.name), str)
            or not self.name.strip()
            or not isinstance(cast("object", self.fields), JsonObject)
        ):
            raise ValueError(
                "A contract draft requires a name and immutable structured fields"
            )


def _link_observation(value: JsonValue, link: JsonObject) -> tuple[JsonValue, bool]:
    """Return a draft observation and whether its question must cover this dimension.

    Immutable JSON remains untouched unless an unknown needs the supplied link.
    Completed observation states raise MutationError; malformed shapes remain for
    the shared schema validator. This pure helper has no I/O or input mutation.
    """
    if not isinstance(value, JsonObject):
        return value, False
    state = value.get("observation_state")
    if state not in ("unknown", "contradictory", "inferred"):
        raise MutationError("DRAFT_CLAIM", "Creation cannot assert verified behavior")
    if state == "inferred":
        return value, False
    links = value.get("unresolved_behavior_refs", ())
    if not isinstance(links, tuple):
        raise ValueError("Unresolved links must be an immutable array")
    updated = dict(value)
    updated["unresolved_behavior_refs"] = tuple(dict.fromkeys((*links, link)))
    return JsonObject(tuple(updated.items())), True


def _link_transitions(value: JsonObject, link: JsonObject) -> tuple[JsonObject, bool]:
    """Apply draft claims to the summary and each nested before/action/after phase.

    The immutable transition object and question link produce a detached object
    plus an uncertainty flag. Schema-invalid shapes are preserved for validation;
    completed phases raise MutationError. No input or external state is changed.
    """
    fields = dict(value)
    fields["behavior"], uncertain = _link_observation(value.get("behavior"), link)
    entries = value.get("entries")
    # Nested phases carry independent observation claims, even with an inferred summary.
    if isinstance(entries, tuple):
        updated: list[JsonValue] = []
        # Preserve malformed rows for schema errors, and normalize valid objects.
        for entry in entries:
            if not isinstance(entry, JsonObject):
                updated.append(entry)
                continue
            phases = dict(entry)
            # Treat each phase independently so a summary cannot conceal uncertainty.
            for name in ("before", "action", "after"):
                phases[name], unknown = _link_observation(entry.get(name), link)
                uncertain = uncertain or unknown
            updated.append(JsonObject(tuple(phases.items())))
        fields["entries"] = tuple(updated)
    return JsonObject(tuple(fields.items())), uncertain


def contract_changes(
    baseline: CapturedWorkspace, request: ContractDraft
) -> tuple[MutationChange, ...]:
    """Return exact contract/question proposals for a captured workspace and request.

    Configured requirements are inherited without guessing legacy behavior. Only
    inferred, unknown or contradictory supplied observations are allowed; unknowns
    gain linked questions. Invalid claims/inputs raise MutationError/ValueError.
    The immutable byte proposals do not modify the captured or physical workspace.
    """
    profile = baseline.snapshot.profile
    identifier = "unknown-feature-" + request.feature_id
    link = draft_reference("unspecified-behavior", identifier)
    unknown = draft_object(
        observation_state="unknown",
        statement=None,
        evidence_refs=(),
        unresolved_behavior_refs=(link,),
        confidence="unknown",
        applicability="unspecified",
    )
    fields = draft_header("feature-contract", request.feature_id)
    fields.update(
        feature_id=request.feature_id,
        name=request.name,
        capability_group=request.capability_group,
        summary="Legacy behavior has not yet been characterized.",
        lifecycle="draft",
        observation_state="unknown",
        source_evidence_refs=(),
        runtime_evidence_refs=(),
        confidence="unknown",
        unresolved_behavior_refs=(link,),
        product_decision_status="not-required",
        product_decision_refs=(),
        target_relevance="undecided",
        required_dimensions=(),
        acceptance_criteria=(),
    )
    # Every supported dimension starts honestly unknown, including optional modes.
    fields.update({name: unknown for name in FEATURE_DIMENSIONS})
    fields["state_transitions"] = draft_object(
        disposition="unknown", behavior=unknown, entries=(), rationale=None
    )
    fields = merge_draft_fields(
        fields,
        request.fields,
        fixed=(
            "$schema",
            "schema_version",
            "artifact_kind",
            "id",
            "feature_id",
            "name",
            "capability_group",
            "lifecycle",
            "observation_state",
            "source_evidence_refs",
            "runtime_evidence_refs",
            "confidence",
            "product_decision_status",
            "product_decision_refs",
            "unresolved_behavior_refs",
            "acceptance_criteria",
        ),
    )
    dimensions = fields["required_dimensions"]
    if not isinstance(dimensions, tuple):
        raise ValueError("Required dimensions must be an immutable array")
    local = ProfileRequirements(
        platforms=(), modes=(), dimensions=cast("tuple[str, ...]", dimensions)
    )
    inherited = set(local.dimensions)
    # Include global and client requirements so selection cannot hide required work.
    for client in (None, *(item.id for item in profile.clients)):
        required = profile.requirements(client_id=client, feature=local)
        inherited.update(required.dimensions)
        inherited.update(set(required.modes) & FEATURE_DIMENSIONS)
        inherited.update(set(required.platforms) & {"mobile"})
    fields["required_dimensions"] = tuple(sorted(inherited))
    unresolved: list[str] = []
    # All observations, including nested phases, obey the same creation contract.
    for name in sorted(FEATURE_DIMENSIONS):
        value = fields[name]
        if name == "state_transitions" and isinstance(value, JsonObject):
            fields[name], uncertain = _link_transitions(value, link)
        else:
            fields[name], uncertain = _link_observation(value, link)
        if uncertain:
            unresolved.append(name)
    question = open_question(
        identifier,
        features=(request.feature_id,),
        dimensions=tuple(unresolved),
        question="What legacy behavior applies to the unresolved dimensions of "
        + request.feature_id
        + "?",
    )
    change = MutationChange(
        artifact_kind="feature-contract",
        artifact_id=request.feature_id,
        path=profile.artifacts["feature_contracts"]
        + "/"
        + request.feature_id
        + ".json",
        content=canonical_json(JsonObject(tuple(fields.items()))),
        expected_sha256=None,
    )
    return change, append_questions(baseline, (question,))


def plan_contract(
    baseline: CapturedWorkspace,
    request: ContractDraft,
    *,
    grants: tuple[WriteGrant, ...],
    invocation: InvocationContext | None = None,
) -> MutationPlan:
    """Return the shared validated plan for the captured workspace and draft request.

    Grants and optional invocation are caller-authenticated values, forwarded
    unchanged. The shared planner raises MutationError/ValueError/OSError for
    invalid proposals, paths or graph claims. This thin wrapper performs no I/O.
    """
    return plan_mutation(
        baseline,
        contract_changes(baseline, request),
        grants=grants,
        invocation=invocation,
    )


def create_contract(
    baseline: CapturedWorkspace,
    request: ContractDraft,
    *,
    grants: tuple[WriteGrant, ...],
    writer: MutationWriter,
    dry_run: bool = False,
    invocation: InvocationContext | None = None,
) -> MutationResult:
    """Plan then commit the selected draft through the injected MutationWriter.

    The baseline, request, exact grants and optional invocation retain the same
    contract as plan_contract. Planning errors propagate; publication returns the
    shared MutationResult, including explicit partial failures and invalidation.
    Dry-run performs no writes; real commits may create/replace only planned files.
    """
    return commit_mutation(
        plan_contract(baseline, request, grants=grants, invocation=invocation),
        writer=writer,
        dry_run=dry_run,
    )
