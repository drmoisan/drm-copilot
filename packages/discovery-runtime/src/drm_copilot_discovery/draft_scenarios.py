"""Create unexecuted observation plans with explicit unknown expectations."""

from __future__ import annotations

from dataclasses import dataclass
from typing import TYPE_CHECKING, cast

from drm_copilot_discovery.draft_contracts import (
    append_questions,
    draft_header,
    draft_object,
    draft_reference,
    merge_draft_fields,
    open_question,
)
from drm_copilot_discovery.models import JsonObject, canonical_json
from drm_copilot_discovery.mutation_io import commit_mutation
from drm_copilot_discovery.mutation_plan import (
    MutationChange,
    MutationError,
    plan_mutation,
)
from drm_copilot_discovery.path_models import WriteGrant

if TYPE_CHECKING:
    from drm_copilot_discovery.agent_output import InvocationContext
    from drm_copilot_discovery.mutation_io import MutationResult, MutationWriter
    from drm_copilot_discovery.mutation_plan import CapturedWorkspace, MutationPlan


@dataclass(frozen=True, kw_only=True)
class ScenarioDraft:
    """Carry selected feature links and an immutable caller-supplied observation plan.

    Construct with unique feature IDs and explicit structured planning fields, then
    use plan_scenario/create_scenario with separate grants. The value validates ID
    shape but grants no authority, performs no I/O and never describes an executed
    run. Complete graph validation remains the shared planner's responsibility.
    """

    scenario_id: str
    feature_ids: tuple[str, ...]
    fields: JsonObject

    def __post_init__(self) -> None:
        """Return None after detaching IDs; invalid identity/fields raise ValueError."""
        object.__setattr__(self, "feature_ids", tuple(self.feature_ids))
        WriteGrant(
            artifact_kind="runtime-characterization-scenario",
            artifact_id=self.scenario_id,
            path=self.scenario_id + ".json",
        )
        if (
            not self.feature_ids
            or len(set(self.feature_ids)) != len(self.feature_ids)
            or not isinstance(cast("object", self.fields), JsonObject)
        ):
            raise ValueError(
                "A scenario requires unique feature IDs and immutable structured fields"
            )
        # Validate each selected identity without treating it as an output grant.
        for identifier in self.feature_ids:
            WriteGrant(
                artifact_kind="feature-contract",
                artifact_id=identifier,
                path=identifier + ".json",
            )


def scenario_changes(
    baseline: CapturedWorkspace, request: ScenarioDraft
) -> tuple[MutationChange, ...]:
    """Return scenario and any necessary question proposals from captured inputs.

    The request supplies environment, fixture, action and observation plans. Unknown
    expectations remain null and gain an open question covering selected features;
    known text retains its supplied basis for shared graph validation. Invalid
    inputs/claims raise MutationError/ValueError. No I/O or input mutation occurs.
    """
    identifier = "unknown-scenario-" + request.scenario_id
    features = tuple(sorted(request.feature_ids))
    fields = draft_header("runtime-characterization-scenario", request.scenario_id)
    # Stable feature order makes equivalent selections produce identical bytes.
    feature_refs = tuple(draft_reference("feature-contract", name) for name in features)
    fields.update(
        scenario_id=request.scenario_id,
        feature_refs=feature_refs,
        pre_state_capture=draft_object(
            plan="Capture state before the planned action.",
            observed_state=None,
            evidence_refs=(),
        ),
        post_state_capture=draft_object(
            plan="Capture state after the planned action.",
            observed_state=None,
            evidence_refs=(),
        ),
        expected_result=None,
        expected_result_basis="unknown",
        result_status="not-run",
        deviations=(),
        evidence_refs=(),
        repeatability="not-assessed",
        confidence="unknown",
        unresolved_findings=(),
        runs=(),
    )
    fields = merge_draft_fields(
        fields,
        request.fields,
        fixed=(
            "$schema",
            "schema_version",
            "artifact_kind",
            "id",
            "scenario_id",
            "feature_refs",
            "result_status",
            "deviations",
            "evidence_refs",
            "repeatability",
            "confidence",
            "runs",
        ),
    )
    # No environment, fixture, action or observation steps are guessed from the profile.
    required = {"environment", "fixture", "preconditions", "action", "observation_plan"}
    if missing := required - fields.keys():
        raise MutationError(
            "DRAFT_INPUT", "Supply planning fields: " + ", ".join(sorted(missing))
        )
    # Capture instructions are plans; observed states must come from later execution.
    for name in ("pre_state_capture", "post_state_capture"):
        value = fields[name]
        if isinstance(value, JsonObject) and (
            value.get("observed_state") is not None or value.get("evidence_refs")
        ):
            raise MutationError(
                "DRAFT_CLAIM", "A new observation plan cannot claim captured execution"
            )
    changes: list[MutationChange] = []
    # Only unknown expectations need generated questions; known claims need real proof.
    if fields["expected_result"] is None:
        links = fields["unresolved_findings"]
        if not isinstance(links, tuple):
            raise ValueError("Unresolved findings must be an immutable array")
        fields["unresolved_findings"] = tuple(
            dict.fromkeys((*links, draft_reference("unspecified-behavior", identifier)))
        )
        plan = fields["observation_plan"]
        # Include every planned dimension; malformed plan rows remain schema errors.
        dimensions = (
            tuple(
                sorted(
                    {
                        cast("str", value["dimension"])
                        for value in plan
                        if isinstance(value, JsonObject)
                        and isinstance(value.get("dimension"), str)
                    }
                )
            )
            if isinstance(plan, tuple)
            else ()
        )
        question = open_question(
            identifier,
            features=features,
            dimensions=dimensions,
            question="What outcome should characterize the planned scenario "
            + request.scenario_id
            + "?",
        )
        changes.append(append_questions(baseline, (question,)))
    changes.insert(
        0,
        MutationChange(
            artifact_kind="runtime-characterization-scenario",
            artifact_id=request.scenario_id,
            path=baseline.snapshot.profile.artifacts["characterization"]
            + "/"
            + request.scenario_id
            + ".json",
            content=canonical_json(JsonObject(tuple(fields.items()))),
            expected_sha256=None,
        ),
    )
    return tuple(changes)


def plan_scenario(
    baseline: CapturedWorkspace,
    request: ScenarioDraft,
    *,
    grants: tuple[WriteGrant, ...],
    invocation: InvocationContext | None = None,
) -> MutationPlan:
    """Return a shared validated plan with resolvable feature links and exact grants.

    Baseline/request determine proposed bytes. Caller-authenticated grants and
    optional invocation are forwarded unchanged. Shared planning exceptions
    propagate; this thin composition does not perform I/O or manufacture authority.
    """
    return plan_mutation(
        baseline,
        scenario_changes(baseline, request),
        grants=grants,
        invocation=invocation,
    )


def create_scenario(
    baseline: CapturedWorkspace,
    request: ScenarioDraft,
    *,
    grants: tuple[WriteGrant, ...],
    writer: MutationWriter,
    dry_run: bool = False,
    invocation: InvocationContext | None = None,
) -> MutationResult:
    """Plan and publish through the injected writer, returning its MutationResult.

    Inputs have the same meaning as plan_scenario; planning errors propagate. The
    shared writer owns freshness, invalidation and explicit partial results. A real
    commit writes only planned files; dry-run leaves all external state unchanged.
    """
    return commit_mutation(
        plan_scenario(baseline, request, grants=grants, invocation=invocation),
        writer=writer,
        dry_run=dry_run,
    )
