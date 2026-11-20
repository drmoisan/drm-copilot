# P3-T4 exact staged review patch

Timestamp: 2026-10-18T16-42
Baseline: c114f98583599ebd5ee02281ece3524b2909fa51
Representation: full-blob identities, zero context, UTF-8; exact five owned paths.

```diff
diff --git a/packages/discovery-runtime/src/drm_copilot_discovery/draft_contracts.py b/packages/discovery-runtime/src/drm_copilot_discovery/draft_contracts.py
new file mode 100644
index 0000000000000000000000000000000000000000..9914ebe3fe91eb286c3a9db3626dd866bfcb8b43
--- /dev/null
+++ b/packages/discovery-runtime/src/drm_copilot_discovery/draft_contracts.py
@@ -0,0 +1,396 @@
+"""Create truthful contract proposals through the accepted graph mutation boundary.
+
+Draft identities and grants are distinct inputs. This module performs no native
+I/O; callers supply authenticated grants and the existing mutation writer.
+"""
+
+from __future__ import annotations
+
+from dataclasses import dataclass
+from typing import TYPE_CHECKING, cast
+
+from drm_copilot_discovery.models import JsonObject, JsonValue, canonical_json
+from drm_copilot_discovery.mutation_io import commit_mutation
+from drm_copilot_discovery.mutation_plan import (
+    MutationChange,
+    MutationError,
+    plan_mutation,
+)
+from drm_copilot_discovery.path_models import WriteGrant
+from drm_copilot_discovery.profile_models import FEATURE_DIMENSIONS, ProfileRequirements
+
+if TYPE_CHECKING:
+    from collections.abc import Mapping
+
+    from drm_copilot_discovery.agent_output import InvocationContext
+    from drm_copilot_discovery.mutation_io import MutationResult, MutationWriter
+    from drm_copilot_discovery.mutation_plan import CapturedWorkspace, MutationPlan
+
+
+def draft_object(**fields: JsonValue) -> JsonObject:
+    """Return immutable JSON from typed keyword members without external effects.
+
+    JsonObject rejects mutable descendants with TypeError/ValueError; callers
+    retain their input objects and receive a detached member tuple.
+    """
+    return JsonObject(tuple(fields.items()))
+
+
+def draft_header(kind: str, identifier: str) -> dict[str, JsonValue]:
+    """Return fixed v2 header members for the given kind and stable identifier.
+
+    This pure projection leaves schema/path validation to the shared planner;
+    it does not interpret these strings as native authority.
+    """
+    return {
+        "$schema": "urn:drm-copilot:discovery:2.0.0:" + kind,
+        "schema_version": "2.0.0",
+        "artifact_kind": kind,
+        "id": identifier,
+        "extensions": JsonObject(()),
+    }
+
+
+def draft_reference(kind: str, identifier: str) -> JsonObject:
+    """Return an immutable kind/identifier link without resolving or granting it."""
+    return draft_object(artifact_kind=kind, id=identifier)
+
+
+def merge_draft_fields(
+    defaults: Mapping[str, JsonValue], supplied: JsonObject, *, fixed: tuple[str, ...]
+) -> dict[str, JsonValue]:
+    """Return detached defaults overlaid with immutable caller planning members.
+
+    Fixed names must retain their default values or MutationError is raised.
+    Unknown fields remain visible to the accepted schema validator. No input or
+    external state is changed.
+    """
+    result = dict(defaults)
+    # Preserve planning detail while preventing changes to creation invariants.
+    for name, value in supplied.items():
+        if name in fixed and value != defaults[name]:
+            raise MutationError("DRAFT_CLAIM", f"Creation cannot change {name}")
+        result[name] = value
+    return result
+
+
+def open_question(
+    identifier: str,
+    *,
+    features: tuple[str, ...],
+    dimensions: tuple[str, ...],
+    question: str,
+) -> JsonObject:
+    """Return an open question for selected feature IDs and dimension names.
+
+    The supplied text describes uncertainty; owner, resolution and evidence stay
+    unset. This pure projection delegates shape/link validation to the planner.
+    """
+    fields = draft_header("unspecified-behavior", identifier)
+    # Every selected feature must remain explicit in the unresolved record.
+    feature_refs = tuple(draft_reference("feature-contract", name) for name in features)
+    fields.update(
+        behavior_id=identifier,
+        feature_refs=feature_refs,
+        dimensions=dimensions,
+        question=question,
+        evidence_refs=(),
+        competing_interpretations=(),
+        impact="Characterization and acceptance expectations remain unresolved.",
+        status="open",
+        decision_owner=None,
+        decision_ref=None,
+        decision=None,
+        rationale=None,
+        approved_target_behavior=None,
+        acceptance_test_implications=(),
+        resolution_basis=None,
+        resolution_evidence_refs=(),
+    )
+    return JsonObject(tuple(fields.items()))
+
+
+def append_questions(
+    baseline: CapturedWorkspace, questions: tuple[JsonObject, ...]
+) -> MutationChange:
+    """Return a collection change that appends immutable questions to captured data.
+
+    The CapturedWorkspace supplies configured paths and original-byte CAS. Invalid
+    baseline/collection data raises MutationError with available findings. Existing
+    records and extension values are preserved; this function performs no I/O.
+    """
+    snapshot = baseline.snapshot
+    if not snapshot.ok:
+        raise MutationError(
+            "DRAFT_BASELINE",
+            "Correct invalid captured inputs first",
+            findings=snapshot.findings,
+        )
+    path = snapshot.profile.artifacts["unspecified_behaviors"]
+    # Resolve only the configured collection, never an arbitrary matching kind.
+    original = next((item for item in snapshot.artifacts if item.path == path), None)
+    # Absence authorizes only a create proposal; existing bytes remain a CAS input.
+    if original is None:
+        document = draft_header(
+            "unspecified-behavior-collection",
+            "unresolved-" + snapshot.profile.system.id,
+        )
+        document["records"] = ()
+        expected = None
+    else:
+        if (
+            original.expected_kind != "unspecified-behavior-collection"
+            or original.document is None
+        ):
+            raise MutationError(
+                "DRAFT_COLLECTION", "The configured unresolved collection is invalid"
+            )
+        document = dict(original.document)
+        expected = snapshot.file(path).sha256
+    # The accepted loader validates existing required fields before extraction.
+    records = cast("tuple[JsonValue, ...]", document["records"])
+    document["records"] = records + questions
+    return MutationChange(
+        artifact_kind="unspecified-behavior-collection",
+        artifact_id=cast("str", document["id"]),
+        path=path,
+        content=canonical_json(JsonObject(tuple(document.items()))),
+        expected_sha256=expected,
+    )
+
+
+@dataclass(frozen=True, kw_only=True)
+class ContractDraft:
+    """Carry selected feature identity and immutable optional planning fields.
+
+    Construct with an explicit ID/name, then pass to plan_contract/create_contract
+    with separately authenticated grants. Construction checks ID syntax and input
+    immutability; graph validation remains the planner's responsibility. This value
+    performs no I/O and cannot supply native authority.
+    """
+
+    feature_id: str
+    name: str
+    capability_group: str = "unclassified"
+    fields: JsonObject = JsonObject(())
+
+    def __post_init__(self) -> None:
+        """Return None after checking stored inputs; invalid values raise ValueError."""
+        WriteGrant(
+            artifact_kind="feature-contract",
+            artifact_id=self.feature_id,
+            path=self.feature_id + ".json",
+        )
+        if (
+            not isinstance(cast("object", self.name), str)
+            or not self.name.strip()
+            or not isinstance(cast("object", self.fields), JsonObject)
+        ):
+            raise ValueError(
+                "A contract draft requires a name and immutable structured fields"
+            )
+
+
+def _link_observation(value: JsonValue, link: JsonObject) -> tuple[JsonValue, bool]:
+    """Return a draft observation and whether its question must cover this dimension.
+
+    Immutable JSON remains untouched unless an unknown needs the supplied link.
+    Completed observation states raise MutationError; malformed shapes remain for
+    the shared schema validator. This pure helper has no I/O or input mutation.
+    """
+    if not isinstance(value, JsonObject):
+        return value, False
+    state = value.get("observation_state")
+    if state not in ("unknown", "contradictory", "inferred"):
+        raise MutationError("DRAFT_CLAIM", "Creation cannot assert verified behavior")
+    if state == "inferred":
+        return value, False
+    links = value.get("unresolved_behavior_refs", ())
+    if not isinstance(links, tuple):
+        raise ValueError("Unresolved links must be an immutable array")
+    updated = dict(value)
+    updated["unresolved_behavior_refs"] = tuple(dict.fromkeys((*links, link)))
+    return JsonObject(tuple(updated.items())), True
+
+
+def _link_transitions(value: JsonObject, link: JsonObject) -> tuple[JsonObject, bool]:
+    """Apply draft claims to the summary and each nested before/action/after phase.
+
+    The immutable transition object and question link produce a detached object
+    plus an uncertainty flag. Schema-invalid shapes are preserved for validation;
+    completed phases raise MutationError. No input or external state is changed.
+    """
+    fields = dict(value)
+    fields["behavior"], uncertain = _link_observation(value.get("behavior"), link)
+    entries = value.get("entries")
+    # Nested phases carry independent observation claims, even with an inferred summary.
+    if isinstance(entries, tuple):
+        updated: list[JsonValue] = []
+        # Preserve malformed rows for schema errors, and normalize valid objects.
+        for entry in entries:
+            if not isinstance(entry, JsonObject):
+                updated.append(entry)
+                continue
+            phases = dict(entry)
+            # Treat each phase independently so a summary cannot conceal uncertainty.
+            for name in ("before", "action", "after"):
+                phases[name], unknown = _link_observation(entry.get(name), link)
+                uncertain = uncertain or unknown
+            updated.append(JsonObject(tuple(phases.items())))
+        fields["entries"] = tuple(updated)
+    return JsonObject(tuple(fields.items())), uncertain
+
+
+def contract_changes(
+    baseline: CapturedWorkspace, request: ContractDraft
+) -> tuple[MutationChange, ...]:
+    """Return exact contract/question proposals for a captured workspace and request.
+
+    Configured requirements are inherited without guessing legacy behavior. Only
+    inferred, unknown or contradictory supplied observations are allowed; unknowns
+    gain linked questions. Invalid claims/inputs raise MutationError/ValueError.
+    The immutable byte proposals do not modify the captured or physical workspace.
+    """
+    profile = baseline.snapshot.profile
+    identifier = "unknown-feature-" + request.feature_id
+    link = draft_reference("unspecified-behavior", identifier)
+    unknown = draft_object(
+        observation_state="unknown",
+        statement=None,
+        evidence_refs=(),
+        unresolved_behavior_refs=(link,),
+        confidence="unknown",
+        applicability="unspecified",
+    )
+    fields = draft_header("feature-contract", request.feature_id)
+    fields.update(
+        feature_id=request.feature_id,
+        name=request.name,
+        capability_group=request.capability_group,
+        summary="Legacy behavior has not yet been characterized.",
+        lifecycle="draft",
+        observation_state="unknown",
+        source_evidence_refs=(),
+        runtime_evidence_refs=(),
+        confidence="unknown",
+        unresolved_behavior_refs=(link,),
+        product_decision_status="not-required",
+        product_decision_refs=(),
+        target_relevance="undecided",
+        required_dimensions=(),
+        acceptance_criteria=(),
+    )
+    # Every supported dimension starts honestly unknown, including optional modes.
+    fields.update({name: unknown for name in FEATURE_DIMENSIONS})
+    fields["state_transitions"] = draft_object(
+        disposition="unknown", behavior=unknown, entries=(), rationale=None
+    )
+    fields = merge_draft_fields(
+        fields,
+        request.fields,
+        fixed=(
+            "$schema",
+            "schema_version",
+            "artifact_kind",
+            "id",
+            "feature_id",
+            "name",
+            "capability_group",
+            "lifecycle",
+            "observation_state",
+            "source_evidence_refs",
+            "runtime_evidence_refs",
+            "confidence",
+            "product_decision_status",
+            "product_decision_refs",
+            "unresolved_behavior_refs",
+            "acceptance_criteria",
+        ),
+    )
+    dimensions = fields["required_dimensions"]
+    if not isinstance(dimensions, tuple):
+        raise ValueError("Required dimensions must be an immutable array")
+    local = ProfileRequirements(
+        platforms=(), modes=(), dimensions=cast("tuple[str, ...]", dimensions)
+    )
+    inherited = set(local.dimensions)
+    # Include global and client requirements so selection cannot hide required work.
+    for client in (None, *(item.id for item in profile.clients)):
+        required = profile.requirements(client_id=client, feature=local)
+        inherited.update(required.dimensions)
+        inherited.update(set(required.modes) & FEATURE_DIMENSIONS)
+        inherited.update(set(required.platforms) & {"mobile"})
+    fields["required_dimensions"] = tuple(sorted(inherited))
+    unresolved: list[str] = []
+    # All observations, including nested phases, obey the same creation contract.
+    for name in sorted(FEATURE_DIMENSIONS):
+        value = fields[name]
+        if name == "state_transitions" and isinstance(value, JsonObject):
+            fields[name], uncertain = _link_transitions(value, link)
+        else:
+            fields[name], uncertain = _link_observation(value, link)
+        if uncertain:
+            unresolved.append(name)
+    question = open_question(
+        identifier,
+        features=(request.feature_id,),
+        dimensions=tuple(unresolved),
+        question="What legacy behavior applies to the unresolved dimensions of "
+        + request.feature_id
+        + "?",
+    )
+    change = MutationChange(
+        artifact_kind="feature-contract",
+        artifact_id=request.feature_id,
+        path=profile.artifacts["feature_contracts"]
+        + "/"
+        + request.feature_id
+        + ".json",
+        content=canonical_json(JsonObject(tuple(fields.items()))),
+        expected_sha256=None,
+    )
+    return change, append_questions(baseline, (question,))
+
+
+def plan_contract(
+    baseline: CapturedWorkspace,
+    request: ContractDraft,
+    *,
+    grants: tuple[WriteGrant, ...],
+    invocation: InvocationContext | None = None,
+) -> MutationPlan:
+    """Return the shared validated plan for the captured workspace and draft request.
+
+    Grants and optional invocation are caller-authenticated values, forwarded
+    unchanged. The shared planner raises MutationError/ValueError/OSError for
+    invalid proposals, paths or graph claims. This thin wrapper performs no I/O.
+    """
+    return plan_mutation(
+        baseline,
+        contract_changes(baseline, request),
+        grants=grants,
+        invocation=invocation,
+    )
+
+
+def create_contract(
+    baseline: CapturedWorkspace,
+    request: ContractDraft,
+    *,
+    grants: tuple[WriteGrant, ...],
+    writer: MutationWriter,
+    dry_run: bool = False,
+    invocation: InvocationContext | None = None,
+) -> MutationResult:
+    """Plan then commit the selected draft through the injected MutationWriter.
+
+    The baseline, request, exact grants and optional invocation retain the same
+    contract as plan_contract. Planning errors propagate; publication returns the
+    shared MutationResult, including explicit partial failures and invalidation.
+    Dry-run performs no writes; real commits may create/replace only planned files.
+    """
+    return commit_mutation(
+        plan_contract(baseline, request, grants=grants, invocation=invocation),
+        writer=writer,
+        dry_run=dry_run,
+    )
diff --git a/packages/discovery-runtime/src/drm_copilot_discovery/draft_scenarios.py b/packages/discovery-runtime/src/drm_copilot_discovery/draft_scenarios.py
new file mode 100644
index 0000000000000000000000000000000000000000..2655c4d999cc79933cf9e72af2e2f0ebe5e114b1
--- /dev/null
+++ b/packages/discovery-runtime/src/drm_copilot_discovery/draft_scenarios.py
@@ -0,0 +1,231 @@
+"""Create unexecuted observation plans with explicit unknown expectations."""
+
+from __future__ import annotations
+
+from dataclasses import dataclass
+from typing import TYPE_CHECKING, cast
+
+from drm_copilot_discovery.draft_contracts import (
+    append_questions,
+    draft_header,
+    draft_object,
+    draft_reference,
+    merge_draft_fields,
+    open_question,
+)
+from drm_copilot_discovery.models import JsonObject, canonical_json
+from drm_copilot_discovery.mutation_io import commit_mutation
+from drm_copilot_discovery.mutation_plan import (
+    MutationChange,
+    MutationError,
+    plan_mutation,
+)
+from drm_copilot_discovery.path_models import WriteGrant
+
+if TYPE_CHECKING:
+    from drm_copilot_discovery.agent_output import InvocationContext
+    from drm_copilot_discovery.mutation_io import MutationResult, MutationWriter
+    from drm_copilot_discovery.mutation_plan import CapturedWorkspace, MutationPlan
+
+
+@dataclass(frozen=True, kw_only=True)
+class ScenarioDraft:
+    """Carry selected feature links and an immutable caller-supplied observation plan.
+
+    Construct with unique feature IDs and explicit structured planning fields, then
+    use plan_scenario/create_scenario with separate grants. The value validates ID
+    shape but grants no authority, performs no I/O and never describes an executed
+    run. Complete graph validation remains the shared planner's responsibility.
+    """
+
+    scenario_id: str
+    feature_ids: tuple[str, ...]
+    fields: JsonObject
+
+    def __post_init__(self) -> None:
+        """Return None after detaching IDs; invalid identity/fields raise ValueError."""
+        object.__setattr__(self, "feature_ids", tuple(self.feature_ids))
+        WriteGrant(
+            artifact_kind="runtime-characterization-scenario",
+            artifact_id=self.scenario_id,
+            path=self.scenario_id + ".json",
+        )
+        if (
+            not self.feature_ids
+            or len(set(self.feature_ids)) != len(self.feature_ids)
+            or not isinstance(cast("object", self.fields), JsonObject)
+        ):
+            raise ValueError(
+                "A scenario requires unique feature IDs and immutable structured fields"
+            )
+        # Validate each selected identity without treating it as an output grant.
+        for identifier in self.feature_ids:
+            WriteGrant(
+                artifact_kind="feature-contract",
+                artifact_id=identifier,
+                path=identifier + ".json",
+            )
+
+
+def scenario_changes(
+    baseline: CapturedWorkspace, request: ScenarioDraft
+) -> tuple[MutationChange, ...]:
+    """Return scenario and any necessary question proposals from captured inputs.
+
+    The request supplies environment, fixture, action and observation plans. Unknown
+    expectations remain null and gain an open question covering selected features;
+    known text retains its supplied basis for shared graph validation. Invalid
+    inputs/claims raise MutationError/ValueError. No I/O or input mutation occurs.
+    """
+    identifier = "unknown-scenario-" + request.scenario_id
+    features = tuple(sorted(request.feature_ids))
+    fields = draft_header("runtime-characterization-scenario", request.scenario_id)
+    # Stable feature order makes equivalent selections produce identical bytes.
+    feature_refs = tuple(draft_reference("feature-contract", name) for name in features)
+    fields.update(
+        scenario_id=request.scenario_id,
+        feature_refs=feature_refs,
+        pre_state_capture=draft_object(
+            plan="Capture state before the planned action.",
+            observed_state=None,
+            evidence_refs=(),
+        ),
+        post_state_capture=draft_object(
+            plan="Capture state after the planned action.",
+            observed_state=None,
+            evidence_refs=(),
+        ),
+        expected_result=None,
+        expected_result_basis="unknown",
+        result_status="not-run",
+        deviations=(),
+        evidence_refs=(),
+        repeatability="not-assessed",
+        confidence="unknown",
+        unresolved_findings=(),
+        runs=(),
+    )
+    fields = merge_draft_fields(
+        fields,
+        request.fields,
+        fixed=(
+            "$schema",
+            "schema_version",
+            "artifact_kind",
+            "id",
+            "scenario_id",
+            "feature_refs",
+            "result_status",
+            "deviations",
+            "evidence_refs",
+            "repeatability",
+            "confidence",
+            "runs",
+        ),
+    )
+    # No environment, fixture, action or observation steps are guessed from the profile.
+    required = {"environment", "fixture", "preconditions", "action", "observation_plan"}
+    if missing := required - fields.keys():
+        raise MutationError(
+            "DRAFT_INPUT", "Supply planning fields: " + ", ".join(sorted(missing))
+        )
+    # Capture instructions are plans; observed states must come from later execution.
+    for name in ("pre_state_capture", "post_state_capture"):
+        value = fields[name]
+        if isinstance(value, JsonObject) and (
+            value.get("observed_state") is not None or value.get("evidence_refs")
+        ):
+            raise MutationError(
+                "DRAFT_CLAIM", "A new observation plan cannot claim captured execution"
+            )
+    changes: list[MutationChange] = []
+    # Only unknown expectations need generated questions; known claims need real proof.
+    if fields["expected_result"] is None:
+        links = fields["unresolved_findings"]
+        if not isinstance(links, tuple):
+            raise ValueError("Unresolved findings must be an immutable array")
+        fields["unresolved_findings"] = tuple(
+            dict.fromkeys((*links, draft_reference("unspecified-behavior", identifier)))
+        )
+        plan = fields["observation_plan"]
+        # Include every planned dimension; malformed plan rows remain schema errors.
+        dimensions = (
+            tuple(
+                sorted(
+                    {
+                        cast("str", value["dimension"])
+                        for value in plan
+                        if isinstance(value, JsonObject)
+                        and isinstance(value.get("dimension"), str)
+                    }
+                )
+            )
+            if isinstance(plan, tuple)
+            else ()
+        )
+        question = open_question(
+            identifier,
+            features=features,
+            dimensions=dimensions,
+            question="What outcome should characterize the planned scenario "
+            + request.scenario_id
+            + "?",
+        )
+        changes.append(append_questions(baseline, (question,)))
+    changes.insert(
+        0,
+        MutationChange(
+            artifact_kind="runtime-characterization-scenario",
+            artifact_id=request.scenario_id,
+            path=baseline.snapshot.profile.artifacts["characterization"]
+            + "/"
+            + request.scenario_id
+            + ".json",
+            content=canonical_json(JsonObject(tuple(fields.items()))),
+            expected_sha256=None,
+        ),
+    )
+    return tuple(changes)
+
+
+def plan_scenario(
+    baseline: CapturedWorkspace,
+    request: ScenarioDraft,
+    *,
+    grants: tuple[WriteGrant, ...],
+    invocation: InvocationContext | None = None,
+) -> MutationPlan:
+    """Return a shared validated plan with resolvable feature links and exact grants.
+
+    Baseline/request determine proposed bytes. Caller-authenticated grants and
+    optional invocation are forwarded unchanged. Shared planning exceptions
+    propagate; this thin composition does not perform I/O or manufacture authority.
+    """
+    return plan_mutation(
+        baseline,
+        scenario_changes(baseline, request),
+        grants=grants,
+        invocation=invocation,
+    )
+
+
+def create_scenario(
+    baseline: CapturedWorkspace,
+    request: ScenarioDraft,
+    *,
+    grants: tuple[WriteGrant, ...],
+    writer: MutationWriter,
+    dry_run: bool = False,
+    invocation: InvocationContext | None = None,
+) -> MutationResult:
+    """Plan and publish through the injected writer, returning its MutationResult.
+
+    Inputs have the same meaning as plan_scenario; planning errors propagate. The
+    shared writer owns freshness, invalidation and explicit partial results. A real
+    commit writes only planned files; dry-run leaves all external state unchanged.
+    """
+    return commit_mutation(
+        plan_scenario(baseline, request, grants=grants, invocation=invocation),
+        writer=writer,
+        dry_run=dry_run,
+    )
diff --git a/tests/discovery_runtime/draft_test_support.py b/tests/discovery_runtime/draft_test_support.py
new file mode 100644
index 0000000000000000000000000000000000000000..ffba64c7b5752ee733012d7f2ce5847342d5c0b7
--- /dev/null
+++ b/tests/discovery_runtime/draft_test_support.py
@@ -0,0 +1,126 @@
+"""Build fresh memory workspaces and explicit transition evidence for draft tests."""
+
+from __future__ import annotations
+
+import json
+from hashlib import sha256
+from typing import TYPE_CHECKING
+
+from drm_copilot_discovery.draft_contracts import ContractDraft, contract_changes
+
+from tests.discovery_runtime.mutation_test_support import capture, mutation_case
+from tests.discovery_runtime.test_references import immutable
+from tests.discovery_runtime.test_snapshot_io import PROFILE_PATH
+from tests.schemas.discovery.v2_schema_test_support import as_object, load_fixture
+
+if TYPE_CHECKING:
+    from drm_copilot_discovery.catalog import SchemaCatalog
+    from drm_copilot_discovery.mutation_plan import CapturedWorkspace
+
+    from tests.discovery_runtime.test_snapshot_io import MemoryStore
+
+
+def draft_case(
+    catalog: SchemaCatalog, *, custom: bool = False
+) -> tuple[MemoryStore, CapturedWorkspace]:
+    """Provide fresh state with optional configured artifact roots and requirements."""
+    store, baseline = mutation_case(catalog)
+    if custom:
+        document = as_object(json.loads(store.files[PROFILE_PATH]))
+        roots = as_object(document["artifacts"])
+        roots.update(
+            feature_contracts="work/contracts",
+            characterization="work/scenarios",
+            unspecified_behaviors="work/questions.yaml",
+        )
+        document["required_feature_dimensions"] = [
+            "trigger",
+            "timing",
+            "offline",
+            "mobile",
+        ]
+        store.put(PROFILE_PATH, json.dumps(document).encode())
+        baseline = capture(store, catalog)
+    return store, baseline
+
+
+def add_feature(
+    store: MemoryStore, catalog: SchemaCatalog, identifier: str
+) -> CapturedWorkspace:
+    """Set up real schema-valid draft inputs without repeating publication tests."""
+    baseline = capture(store, catalog)
+    # Seed only fixture bytes; publication behavior has separate shared-writer tests.
+    for change in contract_changes(
+        baseline, ContractDraft(feature_id=identifier, name=identifier)
+    ):
+        store.put(change.path, change.content)
+    return capture(store, catalog)
+
+
+def transition_case(
+    catalog: SchemaCatalog, *, phase: str, state: str, linked: bool
+) -> tuple[CapturedWorkspace, ContractDraft]:
+    """Bind one requested phase to real local evidence in a fresh captured store."""
+    store, _ = draft_case(catalog)
+    profile = as_object(json.loads(store.files[PROFILE_PATH]))
+    repository = as_object(profile["repository"])
+    repository["revision"] = "a" * 40
+    store.put(PROFILE_PATH, json.dumps(profile).encode())
+    payload = b"recorded observation\n"
+    evidence = load_fixture("evidence-reference")
+    evidence.update(
+        id="proof",
+        evidence_id="proof",
+        repository=repository["id"],
+        path="docs/migration/discovery/evidence/capture.txt",
+    )
+    as_object(evidence["runtime_artifact"])["path"] = evidence["path"]
+    as_object(evidence["environment"])["client_id"] = None
+    as_object(evidence["checksum"])["value"] = sha256(payload).hexdigest()
+    store.put(str(evidence["path"]), payload)
+    store.put(
+        "docs/migration/discovery/evidence/proof.json", json.dumps(evidence).encode()
+    )
+    baseline = capture(store, catalog)
+    proof = {"artifact_kind": "evidence-reference", "id": "proof"}
+    inferred: dict[str, object] = dict(
+        observation_state="inferred",
+        statement="A transition may occur.",
+        evidence_refs=[],
+        unresolved_behavior_refs=[],
+        confidence="low",
+    )
+    question = {
+        "artifact_kind": "unspecified-behavior",
+        "id": "unknown-feature-feature",
+    }
+    selected = dict(
+        inferred,
+        observation_state=state,
+        statement=None if state == "unknown" else inferred["statement"],
+        evidence_refs=[proof] if state == "verified" else [],
+        unresolved_behavior_refs=[question] if linked else [],
+    )
+    entry: dict[str, object] = dict(
+        id="step",
+        before=inferred,
+        action=inferred,
+        after=inferred,
+        evidence_refs=[proof],
+    )
+    entry[phase] = selected
+    request = ContractDraft(
+        feature_id="feature",
+        name="Feature",
+        fields=immutable(
+            {
+                "state_transitions": dict(
+                    disposition="present",
+                    behavior=inferred,
+                    entries=[entry],
+                    rationale=None,
+                )
+            }
+        ),
+    )
+    return baseline, request
diff --git a/tests/discovery_runtime/test_draft_contracts.py b/tests/discovery_runtime/test_draft_contracts.py
new file mode 100644
index 0000000000000000000000000000000000000000..30c14e3859692f9169dcb606ec7167939bc5dfb0
--- /dev/null
+++ b/tests/discovery_runtime/test_draft_contracts.py
@@ -0,0 +1,431 @@
+"""Verify truthful contract creation with isolated captured memory workspaces."""
+
+from __future__ import annotations
+
+import json
+from dataclasses import replace
+from typing import TYPE_CHECKING, cast
+
+import pytest
+from drm_copilot_discovery.draft_contracts import (
+    ContractDraft,
+    append_questions,
+    contract_changes,
+    create_contract,
+    draft_object,
+    draft_reference,
+    open_question,
+    plan_contract,
+)
+from drm_copilot_discovery.models import JsonObject, canonical_json
+from drm_copilot_discovery.mutation_plan import MutationError
+from drm_copilot_discovery.profile_models import FEATURE_DIMENSIONS
+from drm_copilot_discovery.validation import validate_snapshot
+
+from tests.discovery_runtime.draft_test_support import (
+    add_feature,
+    draft_case,
+    transition_case,
+)
+from tests.discovery_runtime.mutation_test_support import capture, grants_for
+from tests.discovery_runtime.mutation_test_support import (
+    mutation_catalog as mutation_catalog,
+)
+from tests.discovery_runtime.test_mutation_commit import MemoryWriter
+from tests.discovery_runtime.test_references import immutable
+from tests.schemas.discovery.v2_schema_test_support import as_object
+
+if TYPE_CHECKING:
+    from drm_copilot_discovery.catalog import SchemaCatalog
+
+
+@pytest.mark.parametrize("custom", [False, True])
+def test_contract_projects_truthful_graph_with_inherited_dimensions(
+    mutation_catalog: SchemaCatalog, custom: bool
+) -> None:
+    """Default/custom paths and required dimensions produce linked structural drafts."""
+    store, baseline = draft_case(mutation_catalog, custom=custom)
+    request = ContractDraft(feature_id="selected-feature", name="Selected feature")
+    changes = contract_changes(baseline, request)
+    original = dict(store.files)
+    plan = plan_contract(baseline, request, grants=grants_for(*changes))
+    assert plan.validation.ok and store.files == original
+    assert contract_changes(baseline, request) == changes
+    feature = next(
+        item.document
+        for item in plan.prospective.artifacts
+        if item.expected_kind == "feature-contract"
+    )
+    assert feature is not None
+    assert (
+        changes[0].path
+        == baseline.snapshot.profile.artifacts["feature_contracts"]
+        + "/selected-feature.json"
+    )
+    assert feature["lifecycle"] == "draft" and feature["observation_state"] == "unknown"
+    assert (
+        feature["source_evidence_refs"]
+        == feature["runtime_evidence_refs"]
+        == feature["product_decision_refs"]
+        == ()
+    )
+    assert set(baseline.snapshot.profile.required_feature_dimensions) <= set(
+        cast("tuple[str, ...]", feature["required_dimensions"])
+    )
+    questions = next(
+        item.document
+        for item in plan.prospective.artifacts
+        if item.expected_kind == "unspecified-behavior-collection"
+    )
+    assert questions is not None
+    question = cast("tuple[JsonObject, ...]", questions["records"])[0]
+    assert question["id"] == "unknown-feature-selected-feature"
+    assert set(cast("tuple[str, ...]", question["dimensions"])) == FEATURE_DIMENSIONS
+    assert question["status"] == "open" and question["resolution_basis"] is None
+    assert question["approved_target_behavior"] is question["decision_owner"] is None
+    for name in FEATURE_DIMENSIONS:
+        value = cast("JsonObject", feature[name])
+        if name == "state_transitions":
+            value = cast("JsonObject", value["behavior"])
+        assert (
+            value["statement"] is None
+            and value["unresolved_behavior_refs"] == feature["unresolved_behavior_refs"]
+        )
+    assert not validate_snapshot(plan.prospective, mode="discovery-complete").ok
+
+
+@pytest.mark.parametrize("dry_run", [True, False])
+def test_contract_creation_uses_shared_writer_without_changing_unrelated_content(
+    mutation_catalog: SchemaCatalog, dry_run: bool
+) -> None:
+    """Shared commit writes the contract and question; dry-run writes nothing."""
+    store, baseline = draft_case(mutation_catalog)
+    request = ContractDraft(feature_id="create-feature", name="Create feature")
+    changes = contract_changes(baseline, request)
+    before = dict(store.files)
+    writer = MemoryWriter(store, mutation_catalog)
+    result = create_contract(
+        baseline, request, grants=grants_for(*changes), writer=writer, dry_run=dry_run
+    )
+    assert result.ok
+    assert all(store.files[path] == content for path, content in before.items())
+    if dry_run:
+        assert store.files == before and writer.invalidations == writer.attempts == 0
+        assert {item.status for item in result.artifacts} == {"planned"}
+    else:
+        assert all(store.files[change.path] == change.content for change in changes)
+        assert result.authority_invalidated and writer.invalidations == 1
+
+
+def test_existing_question_records_and_extensions_are_preserved(
+    mutation_catalog: SchemaCatalog,
+) -> None:
+    """Appending unknowns preserves another feature's structured records."""
+    store, _ = draft_case(mutation_catalog)
+    baseline = add_feature(store, mutation_catalog, "existing")
+    path = baseline.snapshot.profile.artifacts["unspecified_behaviors"]
+    prior = baseline.snapshot.file(path)
+    old_document = next(
+        item.document for item in baseline.snapshot.artifacts if item.path == path
+    )
+    assert old_document is not None
+    change = contract_changes(
+        baseline, ContractDraft(feature_id="second", name="Second")
+    )[1]
+    changed = immutable(as_object(json.loads(change.content)))
+    assert change.expected_sha256 == prior.sha256
+    assert (
+        cast("tuple[JsonObject, ...]", changed["records"])[:-1]
+        == old_document["records"]
+    )
+    assert (
+        changed["id"] == old_document["id"]
+        and changed["extensions"] == old_document["extensions"]
+    )
+    assert store.files[path] == prior.content
+
+
+@pytest.mark.parametrize(
+    "field",
+    [
+        "id",
+        "lifecycle",
+        "observation_state",
+        "source_evidence_refs",
+        "product_decision_status",
+        "acceptance_criteria",
+    ],
+)
+def test_creation_rejects_supplied_identity_or_completed_claims(
+    mutation_catalog: SchemaCatalog, field: str
+) -> None:
+    """Caller fields cannot assert verification, approval or a different identity."""
+    _, baseline = draft_case(mutation_catalog)
+    request = ContractDraft(
+        feature_id="feature", name="Feature", fields=immutable({field: "forged"})
+    )
+    with pytest.raises(MutationError, match="DRAFT_CLAIM"):
+        contract_changes(baseline, request)
+
+
+@pytest.mark.parametrize("state", ["verified", "intentionally-unspecified"])
+def test_draft_dimensions_cannot_upgrade_observation_states(
+    mutation_catalog: SchemaCatalog, state: str
+) -> None:
+    """A supplied dimension cannot claim verification or an approved decision."""
+    _, baseline = draft_case(mutation_catalog)
+    request = ContractDraft(
+        feature_id="feature",
+        name="Feature",
+        fields=immutable({"trigger": {"observation_state": state}}),
+    )
+    with pytest.raises(MutationError, match="DRAFT_CLAIM"):
+        contract_changes(baseline, request)
+
+
+def test_supplied_inference_and_unknown_transition_remain_explicit(
+    mutation_catalog: SchemaCatalog,
+) -> None:
+    """Inference stays inference; unknown transitions receive an open question."""
+    _, baseline = draft_case(mutation_catalog)
+    request = ContractDraft(
+        feature_id="feature",
+        name="Feature",
+        fields=immutable(
+            {
+                "trigger": {
+                    "observation_state": "inferred",
+                    "statement": "A caller may invoke the action.",
+                    "evidence_refs": [],
+                    "unresolved_behavior_refs": [],
+                    "confidence": "low",
+                },
+                "state_transitions": {
+                    "disposition": "unknown",
+                    "behavior": {
+                        "observation_state": "contradictory",
+                        "statement": None,
+                        "evidence_refs": [],
+                        "unresolved_behavior_refs": [],
+                        "confidence": "unknown",
+                    },
+                    "entries": [],
+                    "rationale": None,
+                },
+                "required_dimensions": ["security_permissions"],
+            }
+        ),
+    )
+    changes = contract_changes(baseline, request)
+    plan = plan_contract(baseline, request, grants=grants_for(*changes))
+    assert plan.validation.ok
+    feature = immutable(as_object(json.loads(changes[0].content)))
+    assert cast("JsonObject", feature["trigger"])["observation_state"] == "inferred"
+    question = cast(
+        "tuple[JsonObject, ...]",
+        immutable(as_object(json.loads(changes[1].content)))["records"],
+    )[0]
+    assert "trigger" not in cast("tuple[str, ...]", question["dimensions"])
+
+
+@pytest.mark.parametrize(
+    "case", ["missing-grant", "wrong-id", "wrong-kind", "existing-path", "duplicate-id"]
+)
+def test_exact_grants_and_existing_id_collisions_fail_before_effects(
+    mutation_catalog: SchemaCatalog, case: str
+) -> None:
+    """Creation rejects existing files and grants for other kinds, IDs or paths."""
+    store, baseline = draft_case(mutation_catalog)
+    request = ContractDraft(feature_id="feature", name="Feature")
+    changes = contract_changes(baseline, request)
+    if case in {"existing-path", "duplicate-id"}:
+        for change in changes:
+            path = change.path
+            if case == "duplicate-id" and change.artifact_kind == "feature-contract":
+                path = path.replace("feature.json", "other.json")
+            store.put(path, change.content)
+        baseline = capture(store, mutation_catalog)
+        changes = contract_changes(baseline, request)
+    grants = grants_for(*changes)
+    if case == "missing-grant":
+        grants = grants[:1]
+    elif case in {"wrong-id", "wrong-kind"}:
+        grants = (
+            replace(
+                grants[0],
+                **(
+                    {"artifact_id": "different"}
+                    if case == "wrong-id"
+                    else {"artifact_kind": "evidence-reference"}
+                ),
+            ),
+            *grants[1:],
+        )
+    before = dict(store.files)
+    with pytest.raises(MutationError):
+        plan_contract(baseline, request, grants=grants)
+    assert store.files == before
+
+
+@pytest.mark.parametrize(
+    "fields",
+    [
+        {"trigger": None},
+        {"extra": "unsupported"},
+        {
+            "state_transitions": {
+                "behavior": {"observation_state": "unknown"},
+                "entries": None,
+            }
+        },
+        {
+            "state_transitions": {
+                "behavior": {"observation_state": "unknown"},
+                "entries": [None],
+            }
+        },
+        {
+            "trigger": {
+                "observation_state": "unknown",
+                "statement": "Invented.",
+                "evidence_refs": [],
+                "unresolved_behavior_refs": [],
+                "confidence": "unknown",
+            }
+        },
+    ],
+)
+def test_invalid_proposed_fields_reach_accepted_complete_graph_validation(
+    mutation_catalog: SchemaCatalog, fields: dict[str, object]
+) -> None:
+    """Valid prior bytes cannot conceal malformed or untruthful proposed content."""
+    _, baseline = draft_case(mutation_catalog)
+    request = ContractDraft(
+        feature_id="feature", name="Feature", fields=immutable(fields)
+    )
+    changes = contract_changes(baseline, request)
+    with pytest.raises(MutationError, match="MUTATION_INVALID") as error:
+        plan_contract(baseline, request, grants=grants_for(*changes))
+    assert error.value.findings
+
+
+@pytest.mark.parametrize(
+    "case",
+    [
+        "unsafe-id",
+        "empty-name",
+        "mutable-fields",
+        "dimensions",
+        "unknown-dimension",
+        "unresolved-links",
+    ],
+)
+def test_invalid_request_boundaries_are_explicit(
+    mutation_catalog: SchemaCatalog, case: str
+) -> None:
+    """Invalid identity and collection-shaped inputs fail without native effects."""
+    _, baseline = draft_case(mutation_catalog)
+    with pytest.raises(ValueError):
+        request = ContractDraft(
+            feature_id="../escape" if case == "unsafe-id" else "feature",
+            name=" " if case == "empty-name" else "Feature",
+            fields=(
+                cast("JsonObject", {})
+                if case == "mutable-fields"
+                else immutable(
+                    {"required_dimensions": None}
+                    if case == "dimensions"
+                    else (
+                        {"required_dimensions": ["not-a-dimension"]}
+                        if case == "unknown-dimension"
+                        else (
+                            {
+                                "trigger": {
+                                    "observation_state": "unknown",
+                                    "unresolved_behavior_refs": None,
+                                }
+                            }
+                            if case == "unresolved-links"
+                            else {}
+                        )
+                    )
+                )
+            ),
+        )
+        contract_changes(baseline, request)
+
+
+def test_invalid_existing_collection_preserves_typed_loader_findings(
+    mutation_catalog: SchemaCatalog,
+) -> None:
+    """Malformed prior collection data cannot reach required-field extraction."""
+    store, baseline = draft_case(mutation_catalog)
+    store.put(
+        baseline.snapshot.profile.artifacts["unspecified_behaviors"], b'{"records":[]}'
+    )
+    invalid = capture(store, mutation_catalog)
+    with pytest.raises(MutationError, match="DRAFT_BASELINE") as error:
+        append_questions(
+            invalid,
+            (
+                open_question(
+                    "question",
+                    features=("feature",),
+                    dimensions=(),
+                    question="Unknown?",
+                ),
+            ),
+        )
+    assert error.value.findings
+
+
+def test_shared_json_values_do_not_mint_native_authority() -> None:
+    """Generated references remain immutable structural values."""
+    value = draft_object(reference=draft_reference("feature-contract", "feature"))
+    assert (
+        canonical_json(value)
+        == b'{"reference":{"artifact_kind":"feature-contract","id":"feature"}}\n'
+    )
+
+
+@pytest.mark.parametrize("phase", ["before", "action", "after"])
+@pytest.mark.parametrize(
+    "state,linked",
+    [
+        ("inferred", False),
+        ("verified", False),
+        ("intentionally-unspecified", False),
+        ("unknown", False),
+        ("unknown", True),
+    ],
+)
+def test_nested_transition_phases_keep_draft_claims_and_question_links(
+    mutation_catalog: SchemaCatalog, phase: str, state: str, linked: bool
+) -> None:
+    """Each phase rejects promotion and links unknowns despite an inferred summary."""
+    baseline, request = transition_case(
+        mutation_catalog, phase=phase, state=state, linked=linked
+    )
+    question = {
+        "artifact_kind": "unspecified-behavior",
+        "id": "unknown-feature-feature",
+    }
+    if state in {"verified", "intentionally-unspecified"}:
+        with pytest.raises(MutationError, match="DRAFT_CLAIM"):
+            contract_changes(baseline, request)
+        return
+    changes = contract_changes(baseline, request)
+    assert plan_contract(baseline, request, grants=grants_for(*changes)).validation.ok
+    feature = as_object(json.loads(changes[0].content))
+    transition = as_object(feature["state_transitions"])
+    phases = cast("list[dict[str, object]]", transition["entries"])[0]
+    observation = as_object(phases[phase])
+    records = cast(
+        "list[dict[str, object]]", as_object(json.loads(changes[1].content))["records"]
+    )
+    assert ("state_transitions" in cast("list[str]", records[-1]["dimensions"])) == (
+        state == "unknown"
+    )
+    assert observation["unresolved_behavior_refs"] == (
+        [question] if state == "unknown" else []
+    )
diff --git a/tests/discovery_runtime/test_draft_scenarios.py b/tests/discovery_runtime/test_draft_scenarios.py
new file mode 100644
index 0000000000000000000000000000000000000000..d84dc26a53d2bb3bf4add5a528ed7149c42d92a3
--- /dev/null
+++ b/tests/discovery_runtime/test_draft_scenarios.py
@@ -0,0 +1,378 @@
+"""Verify unexecuted scenario proposals and linked uncertainty entirely in memory."""
+
+from __future__ import annotations
+
+import json
+from dataclasses import replace
+from typing import TYPE_CHECKING, cast
+
+import pytest
+from drm_copilot_discovery.draft_scenarios import (
+    ScenarioDraft,
+    create_scenario,
+    plan_scenario,
+    scenario_changes,
+)
+from drm_copilot_discovery.models import JsonObject
+from drm_copilot_discovery.mutation_plan import MutationError
+from drm_copilot_discovery.schema_validation import validate_document
+
+from tests.discovery_runtime.draft_test_support import add_feature, draft_case
+from tests.discovery_runtime.mutation_test_support import capture, grants_for
+from tests.discovery_runtime.mutation_test_support import (
+    mutation_catalog as mutation_catalog,
+)
+from tests.discovery_runtime.test_mutation_commit import MemoryWriter
+from tests.discovery_runtime.test_references import immutable
+from tests.schemas.discovery.v2_schema_test_support import as_object
+
+if TYPE_CHECKING:
+    from drm_copilot_discovery.catalog import SchemaCatalog
+    from drm_copilot_discovery.mutation_plan import CapturedWorkspace
+
+    from tests.discovery_runtime.test_snapshot_io import MemoryStore
+
+
+def scenario_fields(**changes: object) -> JsonObject:
+    """Supply explicit planned context without implying any execution or evidence."""
+    return immutable(
+        {
+            "environment": {
+                "id": "observation-environment",
+                "platform": "desktop",
+                "operating_mode": "online",
+                "client_id": None,
+                "extensions": {},
+            },
+            "fixture": {
+                "description": "Prepare an isolated sample.",
+                "setup_steps": ["Prepare the sample."],
+                "teardown_steps": ["Remove the sample."],
+                "evidence_refs": [],
+            },
+            "preconditions": ["The selected environment is available."],
+            "action": {"description": "Perform the selected action.", "inputs": []},
+            "observation_plan": [
+                {
+                    "id": "observe-trigger",
+                    "dimension": "trigger",
+                    "description": "Record the trigger and resulting behavior.",
+                }
+            ],
+            **changes,
+        }
+    )
+
+
+def scenario_case(
+    catalog: SchemaCatalog, *, custom: bool = False
+) -> tuple[MemoryStore, CapturedWorkspace]:
+    """Load two independent real schema-valid drafts as prospective scenario inputs."""
+    store, _ = draft_case(catalog, custom=custom)
+    add_feature(store, catalog, "first")
+    return store, add_feature(store, catalog, "second")
+
+
+@pytest.mark.parametrize("custom", [False, True])
+def test_multifeature_scenario_preserves_unknown_expectation_and_linked_question(
+    mutation_catalog: SchemaCatalog, custom: bool
+) -> None:
+    """The complete graph remains structurally valid with exact custom-root outputs."""
+    store, baseline = scenario_case(mutation_catalog, custom=custom)
+    request = ScenarioDraft(
+        scenario_id="selected-scenario",
+        feature_ids=("second", "first"),
+        fields=scenario_fields(),
+    )
+    changes = scenario_changes(baseline, request)
+    plan = plan_scenario(baseline, request, grants=grants_for(*changes))
+    assert plan.validation.ok and scenario_changes(baseline, request) == changes
+    assert (
+        changes[0].path
+        == baseline.snapshot.profile.artifacts["characterization"]
+        + "/selected-scenario.json"
+    )
+    scenario = immutable(as_object(json.loads(changes[0].content)))
+    assert (
+        scenario["expected_result"] is None
+        and scenario["expected_result_basis"] == "unknown"
+    )
+    assert (
+        scenario["result_status"] == "not-run"
+        and scenario["runs"] == scenario["evidence_refs"] == ()
+    )
+    assert scenario["repeatability"] == "not-assessed"
+    features = cast("tuple[JsonObject, ...]", scenario["feature_refs"])
+    assert tuple(feature["id"] for feature in features) == ("first", "second")
+    question = cast(
+        "tuple[JsonObject, ...]",
+        immutable(as_object(json.loads(changes[1].content)))["records"],
+    )[-1]
+    assert (
+        question["id"] == "unknown-scenario-selected-scenario"
+        and question["feature_refs"] == features
+    )
+    assert question["dimensions"] == ("trigger",) and question["status"] == "open"
+    assert question["resolution_basis"] is question["approved_target_behavior"] is None
+    assert all(
+        cast("JsonObject", scenario[name])["observed_state"] is None
+        for name in ("pre_state_capture", "post_state_capture")
+    )
+    assert changes[0].path not in store.files
+
+
+@pytest.mark.parametrize("dry_run", [True, False])
+def test_scenario_shared_commit_and_repeatable_dry_run_have_honest_effects(
+    mutation_catalog: SchemaCatalog, dry_run: bool
+) -> None:
+    """Shared publication writes planned bytes; preview retains all state."""
+    store, baseline = scenario_case(mutation_catalog)
+    request = ScenarioDraft(
+        scenario_id="scenario",
+        feature_ids=("first", "second"),
+        fields=scenario_fields(),
+    )
+    changes = scenario_changes(baseline, request)
+    writer = MemoryWriter(store, mutation_catalog)
+    before = dict(store.files)
+    result = create_scenario(
+        baseline, request, grants=grants_for(*changes), writer=writer, dry_run=dry_run
+    )
+    assert result.ok
+    if dry_run:
+        repeated = create_scenario(
+            baseline, request, grants=grants_for(*changes), writer=writer, dry_run=True
+        )
+        assert (
+            repeated == result
+            and store.files == before
+            and writer.attempts == writer.invalidations == 0
+        )
+    else:
+        assert all(store.files[change.path] == change.content for change in changes)
+        assert result.authority_invalidated and writer.invalidations == 1
+        question_path = baseline.snapshot.profile.artifacts["unspecified_behaviors"]
+        assert all(
+            store.files[path] == content
+            for path, content in before.items()
+            if path != question_path
+        )
+
+
+@pytest.mark.parametrize(
+    "case",
+    [
+        "missing-feature",
+        "one-missing",
+        "missing-grant",
+        "existing-scenario",
+        "question-collision",
+    ],
+)
+def test_missing_links_exact_grants_and_collisions_cannot_publish(
+    mutation_catalog: SchemaCatalog, case: str
+) -> None:
+    """Invalid selection and colliding IDs fail before changing memory bytes."""
+    store, baseline = scenario_case(mutation_catalog)
+    features = (
+        ("missing",)
+        if case == "missing-feature"
+        else ("first", "missing") if case == "one-missing" else ("first",)
+    )
+    request = ScenarioDraft(
+        scenario_id="scenario", feature_ids=features, fields=scenario_fields()
+    )
+    changes = scenario_changes(baseline, request)
+    if case == "existing-scenario":
+        for change in changes:
+            store.put(change.path, change.content)
+        baseline = capture(store, mutation_catalog)
+        changes = scenario_changes(baseline, request)
+    elif case == "question-collision":
+        store.put(changes[1].path, changes[1].content)
+        baseline = capture(store, mutation_catalog)
+        changes = scenario_changes(baseline, request)
+    grants = grants_for(*changes)
+    if case == "missing-grant":
+        grants = grants[:1]
+    before = dict(store.files)
+    with pytest.raises(MutationError):
+        plan_scenario(baseline, request, grants=grants)
+    assert store.files == before
+
+
+@pytest.mark.parametrize(
+    "field,value",
+    [
+        ("result_status", "passed"),
+        ("runs", [{"id": "invented"}]),
+        ("repeatability", "repeatable"),
+        ("evidence_refs", [{"artifact_kind": "evidence-reference", "id": "invented"}]),
+        ("scenario_id", "other"),
+        ("feature_refs", []),
+    ],
+)
+def test_creation_rejects_execution_and_identity_overrides(
+    mutation_catalog: SchemaCatalog, field: str, value: object
+) -> None:
+    """A create request cannot claim execution, repetition or fabricated proof."""
+    _, baseline = draft_case(mutation_catalog)
+    request = ScenarioDraft(
+        scenario_id="scenario",
+        feature_ids=("feature",),
+        fields=scenario_fields(**{field: value}),
+    )
+    with pytest.raises(MutationError, match="DRAFT_CLAIM"):
+        scenario_changes(baseline, request)
+
+
+@pytest.mark.parametrize("name", ["pre_state_capture", "post_state_capture"])
+def test_planned_captures_do_not_accept_observed_state(
+    mutation_catalog: SchemaCatalog, name: str
+) -> None:
+    """Unknown expectations are not evidence of recorded pre/post state."""
+    _, baseline = draft_case(mutation_catalog)
+    captured: dict[str, object] = {
+        "plan": "Capture state.",
+        "observed_state": "already observed",
+        "evidence_refs": [],
+    }
+    request = ScenarioDraft(
+        scenario_id="scenario",
+        feature_ids=("feature",),
+        fields=scenario_fields(**{name: captured}),
+    )
+    with pytest.raises(MutationError, match="DRAFT_CLAIM"):
+        scenario_changes(baseline, request)
+
+
+def test_supplied_known_expectation_needs_actual_source_support(
+    mutation_catalog: SchemaCatalog,
+) -> None:
+    """A known expectation stays supplied text and cannot promote an unknown source."""
+    _, baseline = scenario_case(mutation_catalog)
+    request = ScenarioDraft(
+        scenario_id="known-plan",
+        feature_ids=("first",),
+        fields=scenario_fields(
+            expected_result="Supplied known expectation.",
+            expected_result_basis="source-contract",
+        ),
+    )
+    changes = scenario_changes(baseline, request)
+    assert len(changes) == 1
+    assert validate_document(
+        changes[0].content,
+        expected_kind="runtime-characterization-scenario",
+        expected_version="2.0.0",
+        catalog=mutation_catalog,
+    ).ok
+    with pytest.raises(MutationError, match="MUTATION_INVALID") as error:
+        plan_scenario(baseline, request, grants=grants_for(*changes))
+    assert any(
+        finding.code == "RUNTIME_EXPECTATION" for finding in error.value.findings
+    )
+
+
+@pytest.mark.parametrize(
+    "case",
+    [
+        "empty-features",
+        "duplicate-features",
+        "unsafe-scenario",
+        "unsafe-feature",
+        "mutable-fields",
+        "missing-input",
+        "bad-links",
+    ],
+)
+def test_invalid_scenario_request_boundaries_are_explicit(
+    mutation_catalog: SchemaCatalog, case: str
+) -> None:
+    """Invalid IDs and missing context are rejected without invented defaults."""
+    _, baseline = draft_case(mutation_catalog)
+    with pytest.raises(ValueError):
+        request = ScenarioDraft(
+            scenario_id="../escape" if case == "unsafe-scenario" else "scenario",
+            feature_ids=(
+                ()
+                if case == "empty-features"
+                else (
+                    ("feature", "feature")
+                    if case == "duplicate-features"
+                    else ("../escape",) if case == "unsafe-feature" else ("feature",)
+                )
+            ),
+            fields=(
+                cast("JsonObject", {})
+                if case == "mutable-fields"
+                else (
+                    JsonObject(())
+                    if case == "missing-input"
+                    else (
+                        scenario_fields(unresolved_findings=None)
+                        if case == "bad-links"
+                        else scenario_fields()
+                    )
+                )
+            ),
+        )
+        scenario_changes(baseline, request)
+
+
+@pytest.mark.parametrize(
+    "fields",
+    [
+        {"observation_plan": None},
+        {"observation_plan": [{"id": "plan", "description": "No dimension."}]},
+        {"pre_state_capture": None},
+        {"expected_result": "Invented with unknown basis."},
+    ],
+)
+def test_malformed_plans_are_rejected_by_the_existing_graph_validator(
+    mutation_catalog: SchemaCatalog, fields: dict[str, object]
+) -> None:
+    """The creation layer never masks schema errors or manufactures known provenance."""
+    _, baseline = scenario_case(mutation_catalog)
+    request = ScenarioDraft(
+        scenario_id="scenario", feature_ids=("first",), fields=scenario_fields(**fields)
+    )
+    changes = scenario_changes(baseline, request)
+    with pytest.raises(MutationError, match="MUTATION_INVALID") as error:
+        plan_scenario(baseline, request, grants=grants_for(*changes))
+    assert error.value.findings
+
+
+def test_stale_selected_inputs_fail_shared_commit_without_publication(
+    mutation_catalog: SchemaCatalog,
+) -> None:
+    """Caller preparation cannot authorize creation after a source artifact changes."""
+    store, baseline = scenario_case(mutation_catalog)
+    request = ScenarioDraft(
+        scenario_id="scenario", feature_ids=("first",), fields=scenario_fields()
+    )
+    changes = scenario_changes(baseline, request)
+    existing = baseline.snapshot.profile.artifacts["feature_contracts"] + "/first.json"
+    store.put(existing, store.files[existing] + b"\n")
+    writer = MemoryWriter(store, mutation_catalog)
+    before = dict(store.files)
+    result = create_scenario(
+        baseline, request, grants=grants_for(*changes), writer=writer
+    )
+    assert not result.ok and result.findings and writer.attempts == 0
+    assert store.files == before
+
+
+def test_feature_order_is_normalized_without_changing_selection(
+    mutation_catalog: SchemaCatalog,
+) -> None:
+    """Equivalent feature sets produce identical projected bytes and question IDs."""
+    _, baseline = scenario_case(mutation_catalog)
+    request = ScenarioDraft(
+        scenario_id="scenario",
+        feature_ids=("second", "first"),
+        fields=scenario_fields(),
+    )
+    assert scenario_changes(baseline, request) == scenario_changes(
+        baseline, replace(request, feature_ids=("first", "second"))
+    )
```
