"""Verify unexecuted scenario proposals and linked uncertainty entirely in memory."""

from __future__ import annotations

import json
from dataclasses import replace
from typing import TYPE_CHECKING, cast

import pytest
from drm_copilot_discovery.draft_scenarios import (
    ScenarioDraft,
    create_scenario,
    plan_scenario,
    scenario_changes,
)
from drm_copilot_discovery.models import JsonObject
from drm_copilot_discovery.mutation_plan import MutationError
from drm_copilot_discovery.schema_validation import validate_document

from tests.discovery_runtime.draft_test_support import add_feature, draft_case
from tests.discovery_runtime.mutation_test_support import capture, grants_for
from tests.discovery_runtime.mutation_test_support import (
    mutation_catalog as mutation_catalog,
)
from tests.discovery_runtime.test_mutation_commit import MemoryWriter
from tests.discovery_runtime.test_references import immutable
from tests.schemas.discovery.v2_schema_test_support import as_object

if TYPE_CHECKING:
    from drm_copilot_discovery.catalog import SchemaCatalog
    from drm_copilot_discovery.mutation_plan import CapturedWorkspace

    from tests.discovery_runtime.test_snapshot_io import MemoryStore


def scenario_fields(**changes: object) -> JsonObject:
    """Supply explicit planned context without implying any execution or evidence."""
    return immutable(
        {
            "environment": {
                "id": "observation-environment",
                "platform": "desktop",
                "operating_mode": "online",
                "client_id": None,
                "extensions": {},
            },
            "fixture": {
                "description": "Prepare an isolated sample.",
                "setup_steps": ["Prepare the sample."],
                "teardown_steps": ["Remove the sample."],
                "evidence_refs": [],
            },
            "preconditions": ["The selected environment is available."],
            "action": {"description": "Perform the selected action.", "inputs": []},
            "observation_plan": [
                {
                    "id": "observe-trigger",
                    "dimension": "trigger",
                    "description": "Record the trigger and resulting behavior.",
                }
            ],
            **changes,
        }
    )


def scenario_case(
    catalog: SchemaCatalog, *, custom: bool = False
) -> tuple[MemoryStore, CapturedWorkspace]:
    """Load two independent real schema-valid drafts as prospective scenario inputs."""
    store, _ = draft_case(catalog, custom=custom)
    add_feature(store, catalog, "first")
    return store, add_feature(store, catalog, "second")


@pytest.mark.parametrize("custom", [False, True])
def test_multifeature_scenario_preserves_unknown_expectation_and_linked_question(
    mutation_catalog: SchemaCatalog, custom: bool
) -> None:
    """The complete graph remains structurally valid with exact custom-root outputs."""
    store, baseline = scenario_case(mutation_catalog, custom=custom)
    request = ScenarioDraft(
        scenario_id="selected-scenario",
        feature_ids=("second", "first"),
        fields=scenario_fields(),
    )
    changes = scenario_changes(baseline, request)
    plan = plan_scenario(baseline, request, grants=grants_for(*changes))
    assert plan.validation.ok and scenario_changes(baseline, request) == changes
    assert (
        changes[0].path
        == baseline.snapshot.profile.artifacts["characterization"]
        + "/selected-scenario.json"
    )
    scenario = immutable(as_object(json.loads(changes[0].content)))
    assert (
        scenario["expected_result"] is None
        and scenario["expected_result_basis"] == "unknown"
    )
    assert (
        scenario["result_status"] == "not-run"
        and scenario["runs"] == scenario["evidence_refs"] == ()
    )
    assert scenario["repeatability"] == "not-assessed"
    features = cast("tuple[JsonObject, ...]", scenario["feature_refs"])
    assert tuple(feature["id"] for feature in features) == ("first", "second")
    question = cast(
        "tuple[JsonObject, ...]",
        immutable(as_object(json.loads(changes[1].content)))["records"],
    )[-1]
    assert (
        question["id"] == "unknown-scenario-selected-scenario"
        and question["feature_refs"] == features
    )
    assert question["dimensions"] == ("trigger",) and question["status"] == "open"
    assert question["resolution_basis"] is question["approved_target_behavior"] is None
    assert all(
        cast("JsonObject", scenario[name])["observed_state"] is None
        for name in ("pre_state_capture", "post_state_capture")
    )
    assert changes[0].path not in store.files


@pytest.mark.parametrize("dry_run", [True, False])
def test_scenario_shared_commit_and_repeatable_dry_run_have_honest_effects(
    mutation_catalog: SchemaCatalog, dry_run: bool
) -> None:
    """Shared publication writes planned bytes; preview retains all state."""
    store, baseline = scenario_case(mutation_catalog)
    request = ScenarioDraft(
        scenario_id="scenario",
        feature_ids=("first", "second"),
        fields=scenario_fields(),
    )
    changes = scenario_changes(baseline, request)
    writer = MemoryWriter(store, mutation_catalog)
    before = dict(store.files)
    result = create_scenario(
        baseline, request, grants=grants_for(*changes), writer=writer, dry_run=dry_run
    )
    assert result.ok
    if dry_run:
        repeated = create_scenario(
            baseline, request, grants=grants_for(*changes), writer=writer, dry_run=True
        )
        assert (
            repeated == result
            and store.files == before
            and writer.attempts == writer.invalidations == 0
        )
    else:
        assert all(store.files[change.path] == change.content for change in changes)
        assert result.authority_invalidated and writer.invalidations == 1
        question_path = baseline.snapshot.profile.artifacts["unspecified_behaviors"]
        assert all(
            store.files[path] == content
            for path, content in before.items()
            if path != question_path
        )


@pytest.mark.parametrize(
    "case",
    [
        "missing-feature",
        "one-missing",
        "missing-grant",
        "existing-scenario",
        "question-collision",
    ],
)
def test_missing_links_exact_grants_and_collisions_cannot_publish(
    mutation_catalog: SchemaCatalog, case: str
) -> None:
    """Invalid selection and colliding IDs fail before changing memory bytes."""
    store, baseline = scenario_case(mutation_catalog)
    features = (
        ("missing",)
        if case == "missing-feature"
        else ("first", "missing") if case == "one-missing" else ("first",)
    )
    request = ScenarioDraft(
        scenario_id="scenario", feature_ids=features, fields=scenario_fields()
    )
    changes = scenario_changes(baseline, request)
    if case == "existing-scenario":
        for change in changes:
            store.put(change.path, change.content)
        baseline = capture(store, mutation_catalog)
        changes = scenario_changes(baseline, request)
    elif case == "question-collision":
        store.put(changes[1].path, changes[1].content)
        baseline = capture(store, mutation_catalog)
        changes = scenario_changes(baseline, request)
    grants = grants_for(*changes)
    if case == "missing-grant":
        grants = grants[:1]
    before = dict(store.files)
    with pytest.raises(MutationError):
        plan_scenario(baseline, request, grants=grants)
    assert store.files == before


@pytest.mark.parametrize(
    "field,value",
    [
        ("result_status", "passed"),
        ("runs", [{"id": "invented"}]),
        ("repeatability", "repeatable"),
        ("evidence_refs", [{"artifact_kind": "evidence-reference", "id": "invented"}]),
        ("scenario_id", "other"),
        ("feature_refs", []),
    ],
)
def test_creation_rejects_execution_and_identity_overrides(
    mutation_catalog: SchemaCatalog, field: str, value: object
) -> None:
    """A create request cannot claim execution, repetition or fabricated proof."""
    _, baseline = draft_case(mutation_catalog)
    request = ScenarioDraft(
        scenario_id="scenario",
        feature_ids=("feature",),
        fields=scenario_fields(**{field: value}),
    )
    with pytest.raises(MutationError, match="DRAFT_CLAIM"):
        scenario_changes(baseline, request)


@pytest.mark.parametrize("name", ["pre_state_capture", "post_state_capture"])
def test_planned_captures_do_not_accept_observed_state(
    mutation_catalog: SchemaCatalog, name: str
) -> None:
    """Unknown expectations are not evidence of recorded pre/post state."""
    _, baseline = draft_case(mutation_catalog)
    captured: dict[str, object] = {
        "plan": "Capture state.",
        "observed_state": "already observed",
        "evidence_refs": [],
    }
    request = ScenarioDraft(
        scenario_id="scenario",
        feature_ids=("feature",),
        fields=scenario_fields(**{name: captured}),
    )
    with pytest.raises(MutationError, match="DRAFT_CLAIM"):
        scenario_changes(baseline, request)


def test_supplied_known_expectation_needs_actual_source_support(
    mutation_catalog: SchemaCatalog,
) -> None:
    """A known expectation stays supplied text and cannot promote an unknown source."""
    _, baseline = scenario_case(mutation_catalog)
    request = ScenarioDraft(
        scenario_id="known-plan",
        feature_ids=("first",),
        fields=scenario_fields(
            expected_result="Supplied known expectation.",
            expected_result_basis="source-contract",
        ),
    )
    changes = scenario_changes(baseline, request)
    assert len(changes) == 1
    assert validate_document(
        changes[0].content,
        expected_kind="runtime-characterization-scenario",
        expected_version="2.0.0",
        catalog=mutation_catalog,
    ).ok
    with pytest.raises(MutationError, match="MUTATION_INVALID") as error:
        plan_scenario(baseline, request, grants=grants_for(*changes))
    assert any(
        finding.code == "RUNTIME_EXPECTATION" for finding in error.value.findings
    )


@pytest.mark.parametrize(
    "case",
    [
        "empty-features",
        "duplicate-features",
        "unsafe-scenario",
        "unsafe-feature",
        "mutable-fields",
        "missing-input",
        "bad-links",
    ],
)
def test_invalid_scenario_request_boundaries_are_explicit(
    mutation_catalog: SchemaCatalog, case: str
) -> None:
    """Invalid IDs and missing context are rejected without invented defaults."""
    _, baseline = draft_case(mutation_catalog)
    with pytest.raises(ValueError):
        request = ScenarioDraft(
            scenario_id="../escape" if case == "unsafe-scenario" else "scenario",
            feature_ids=(
                ()
                if case == "empty-features"
                else (
                    ("feature", "feature")
                    if case == "duplicate-features"
                    else ("../escape",) if case == "unsafe-feature" else ("feature",)
                )
            ),
            fields=(
                cast("JsonObject", {})
                if case == "mutable-fields"
                else (
                    JsonObject(())
                    if case == "missing-input"
                    else (
                        scenario_fields(unresolved_findings=None)
                        if case == "bad-links"
                        else scenario_fields()
                    )
                )
            ),
        )
        scenario_changes(baseline, request)


@pytest.mark.parametrize(
    "fields",
    [
        {"observation_plan": None},
        {"observation_plan": [{"id": "plan", "description": "No dimension."}]},
        {"pre_state_capture": None},
        {"expected_result": "Invented with unknown basis."},
    ],
)
def test_malformed_plans_are_rejected_by_the_existing_graph_validator(
    mutation_catalog: SchemaCatalog, fields: dict[str, object]
) -> None:
    """The creation layer never masks schema errors or manufactures known provenance."""
    _, baseline = scenario_case(mutation_catalog)
    request = ScenarioDraft(
        scenario_id="scenario", feature_ids=("first",), fields=scenario_fields(**fields)
    )
    changes = scenario_changes(baseline, request)
    with pytest.raises(MutationError, match="MUTATION_INVALID") as error:
        plan_scenario(baseline, request, grants=grants_for(*changes))
    assert error.value.findings


def test_stale_selected_inputs_fail_shared_commit_without_publication(
    mutation_catalog: SchemaCatalog,
) -> None:
    """Caller preparation cannot authorize creation after a source artifact changes."""
    store, baseline = scenario_case(mutation_catalog)
    request = ScenarioDraft(
        scenario_id="scenario", feature_ids=("first",), fields=scenario_fields()
    )
    changes = scenario_changes(baseline, request)
    existing = baseline.snapshot.profile.artifacts["feature_contracts"] + "/first.json"
    store.put(existing, store.files[existing] + b"\n")
    writer = MemoryWriter(store, mutation_catalog)
    before = dict(store.files)
    result = create_scenario(
        baseline, request, grants=grants_for(*changes), writer=writer
    )
    assert not result.ok and result.findings and writer.attempts == 0
    assert store.files == before


def test_feature_order_is_normalized_without_changing_selection(
    mutation_catalog: SchemaCatalog,
) -> None:
    """Equivalent feature sets produce identical projected bytes and question IDs."""
    _, baseline = scenario_case(mutation_catalog)
    request = ScenarioDraft(
        scenario_id="scenario",
        feature_ids=("second", "first"),
        fields=scenario_fields(),
    )
    assert scenario_changes(baseline, request) == scenario_changes(
        baseline, replace(request, feature_ids=("first", "second"))
    )
