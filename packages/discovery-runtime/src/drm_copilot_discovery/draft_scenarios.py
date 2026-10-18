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
    """Require feature links and caller-supplied environment and observation plans."""

    scenario_id: str
    feature_ids: tuple[str, ...]
    fields: JsonObject

    def __post_init__(self) -> None:
        """Detach IDs and reject empty, duplicate or unsafe request identities."""
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
        for identifier in self.feature_ids:
            WriteGrant(
                artifact_kind="feature-contract",
                artifact_id=identifier,
                path=identifier + ".json",
            )


def scenario_changes(
    baseline: CapturedWorkspace, request: ScenarioDraft
) -> tuple[MutationChange, ...]:
    """Preserve plans, generate no run, and link unknown expectations."""
    identifier = "unknown-scenario-" + request.scenario_id
    features = tuple(sorted(request.feature_ids))
    fields = draft_header("runtime-characterization-scenario", request.scenario_id)
    fields.update(
        scenario_id=request.scenario_id,
        feature_refs=tuple(
            draft_reference("feature-contract", name) for name in features
        ),
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
    for name in ("pre_state_capture", "post_state_capture"):
        value = fields[name]
        if isinstance(value, JsonObject) and (
            value.get("observed_state") is not None or value.get("evidence_refs")
        ):
            raise MutationError(
                "DRAFT_CLAIM", "A new observation plan cannot claim captured execution"
            )
    changes: list[MutationChange] = []
    if fields["expected_result"] is None:
        links = fields["unresolved_findings"]
        if not isinstance(links, tuple):
            raise ValueError("Unresolved findings must be an immutable array")
        fields["unresolved_findings"] = tuple(
            dict.fromkeys((*links, draft_reference("unspecified-behavior", identifier)))
        )
        plan = fields["observation_plan"]
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
    """Require resolvable feature links and accepted complete-graph validation."""
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
    """Commit or preview through the existing writer and exact freshness contract."""
    return commit_mutation(
        plan_scenario(baseline, request, grants=grants, invocation=invocation),
        writer=writer,
        dry_run=dry_run,
    )
