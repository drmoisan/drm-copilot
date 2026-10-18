"""Verify truthful contract creation with isolated captured memory workspaces."""

from __future__ import annotations

import json
from dataclasses import replace
from typing import TYPE_CHECKING, cast

import pytest
from drm_copilot_discovery.draft_contracts import (
    ContractDraft,
    append_questions,
    contract_changes,
    create_contract,
    draft_object,
    draft_reference,
    open_question,
    plan_contract,
)
from drm_copilot_discovery.models import JsonObject, canonical_json
from drm_copilot_discovery.mutation_plan import MutationError
from drm_copilot_discovery.profile_models import FEATURE_DIMENSIONS
from drm_copilot_discovery.validation import validate_snapshot

from tests.discovery_runtime.draft_test_support import (
    add_feature,
    draft_case,
    transition_case,
)
from tests.discovery_runtime.mutation_test_support import capture, grants_for
from tests.discovery_runtime.mutation_test_support import (
    mutation_catalog as mutation_catalog,
)
from tests.discovery_runtime.test_mutation_commit import MemoryWriter
from tests.discovery_runtime.test_references import immutable
from tests.schemas.discovery.v2_schema_test_support import as_object

if TYPE_CHECKING:
    from drm_copilot_discovery.catalog import SchemaCatalog


@pytest.mark.parametrize("custom", [False, True])
def test_contract_projects_truthful_graph_with_inherited_dimensions(
    mutation_catalog: SchemaCatalog, custom: bool
) -> None:
    """Default/custom paths and required dimensions produce linked structural drafts."""
    store, baseline = draft_case(mutation_catalog, custom=custom)
    request = ContractDraft(feature_id="selected-feature", name="Selected feature")
    changes = contract_changes(baseline, request)
    original = dict(store.files)
    plan = plan_contract(baseline, request, grants=grants_for(*changes))
    assert plan.validation.ok and store.files == original
    assert contract_changes(baseline, request) == changes
    feature = next(
        item.document
        for item in plan.prospective.artifacts
        if item.expected_kind == "feature-contract"
    )
    assert feature is not None
    assert (
        changes[0].path
        == baseline.snapshot.profile.artifacts["feature_contracts"]
        + "/selected-feature.json"
    )
    assert feature["lifecycle"] == "draft" and feature["observation_state"] == "unknown"
    assert (
        feature["source_evidence_refs"]
        == feature["runtime_evidence_refs"]
        == feature["product_decision_refs"]
        == ()
    )
    assert set(baseline.snapshot.profile.required_feature_dimensions) <= set(
        cast("tuple[str, ...]", feature["required_dimensions"])
    )
    questions = next(
        item.document
        for item in plan.prospective.artifacts
        if item.expected_kind == "unspecified-behavior-collection"
    )
    assert questions is not None
    question = cast("tuple[JsonObject, ...]", questions["records"])[0]
    assert question["id"] == "unknown-feature-selected-feature"
    assert set(cast("tuple[str, ...]", question["dimensions"])) == FEATURE_DIMENSIONS
    assert question["status"] == "open" and question["resolution_basis"] is None
    assert question["approved_target_behavior"] is question["decision_owner"] is None
    for name in FEATURE_DIMENSIONS:
        value = cast("JsonObject", feature[name])
        if name == "state_transitions":
            value = cast("JsonObject", value["behavior"])
        assert (
            value["statement"] is None
            and value["unresolved_behavior_refs"] == feature["unresolved_behavior_refs"]
        )
    assert not validate_snapshot(plan.prospective, mode="discovery-complete").ok


@pytest.mark.parametrize("dry_run", [True, False])
def test_contract_creation_uses_shared_writer_without_changing_unrelated_content(
    mutation_catalog: SchemaCatalog, dry_run: bool
) -> None:
    """Shared commit writes the contract and question; dry-run writes nothing."""
    store, baseline = draft_case(mutation_catalog)
    request = ContractDraft(feature_id="create-feature", name="Create feature")
    changes = contract_changes(baseline, request)
    before = dict(store.files)
    writer = MemoryWriter(store, mutation_catalog)
    result = create_contract(
        baseline, request, grants=grants_for(*changes), writer=writer, dry_run=dry_run
    )
    assert result.ok
    assert all(store.files[path] == content for path, content in before.items())
    if dry_run:
        assert store.files == before and writer.invalidations == writer.attempts == 0
        assert {item.status for item in result.artifacts} == {"planned"}
    else:
        assert all(store.files[change.path] == change.content for change in changes)
        assert result.authority_invalidated and writer.invalidations == 1


def test_existing_question_records_and_extensions_are_preserved(
    mutation_catalog: SchemaCatalog,
) -> None:
    """Appending unknowns preserves another feature's structured records."""
    store, _ = draft_case(mutation_catalog)
    baseline = add_feature(store, mutation_catalog, "existing")
    path = baseline.snapshot.profile.artifacts["unspecified_behaviors"]
    prior = baseline.snapshot.file(path)
    old_document = next(
        item.document for item in baseline.snapshot.artifacts if item.path == path
    )
    assert old_document is not None
    change = contract_changes(
        baseline, ContractDraft(feature_id="second", name="Second")
    )[1]
    changed = immutable(as_object(json.loads(change.content)))
    assert change.expected_sha256 == prior.sha256
    assert (
        cast("tuple[JsonObject, ...]", changed["records"])[:-1]
        == old_document["records"]
    )
    assert (
        changed["id"] == old_document["id"]
        and changed["extensions"] == old_document["extensions"]
    )
    assert store.files[path] == prior.content


@pytest.mark.parametrize(
    "field",
    [
        "id",
        "lifecycle",
        "observation_state",
        "source_evidence_refs",
        "product_decision_status",
        "acceptance_criteria",
    ],
)
def test_creation_rejects_supplied_identity_or_completed_claims(
    mutation_catalog: SchemaCatalog, field: str
) -> None:
    """Caller fields cannot assert verification, approval or a different identity."""
    _, baseline = draft_case(mutation_catalog)
    request = ContractDraft(
        feature_id="feature", name="Feature", fields=immutable({field: "forged"})
    )
    with pytest.raises(MutationError, match="DRAFT_CLAIM"):
        contract_changes(baseline, request)


@pytest.mark.parametrize("state", ["verified", "intentionally-unspecified"])
def test_draft_dimensions_cannot_upgrade_observation_states(
    mutation_catalog: SchemaCatalog, state: str
) -> None:
    """A supplied dimension cannot claim verification or an approved decision."""
    _, baseline = draft_case(mutation_catalog)
    request = ContractDraft(
        feature_id="feature",
        name="Feature",
        fields=immutable({"trigger": {"observation_state": state}}),
    )
    with pytest.raises(MutationError, match="DRAFT_CLAIM"):
        contract_changes(baseline, request)


def test_supplied_inference_and_unknown_transition_remain_explicit(
    mutation_catalog: SchemaCatalog,
) -> None:
    """Inference stays inference; unknown transitions receive an open question."""
    _, baseline = draft_case(mutation_catalog)
    request = ContractDraft(
        feature_id="feature",
        name="Feature",
        fields=immutable(
            {
                "trigger": {
                    "observation_state": "inferred",
                    "statement": "A caller may invoke the action.",
                    "evidence_refs": [],
                    "unresolved_behavior_refs": [],
                    "confidence": "low",
                },
                "state_transitions": {
                    "disposition": "unknown",
                    "behavior": {
                        "observation_state": "contradictory",
                        "statement": None,
                        "evidence_refs": [],
                        "unresolved_behavior_refs": [],
                        "confidence": "unknown",
                    },
                    "entries": [],
                    "rationale": None,
                },
                "required_dimensions": ["security_permissions"],
            }
        ),
    )
    changes = contract_changes(baseline, request)
    plan = plan_contract(baseline, request, grants=grants_for(*changes))
    assert plan.validation.ok
    feature = immutable(as_object(json.loads(changes[0].content)))
    assert cast("JsonObject", feature["trigger"])["observation_state"] == "inferred"
    question = cast(
        "tuple[JsonObject, ...]",
        immutable(as_object(json.loads(changes[1].content)))["records"],
    )[0]
    assert "trigger" not in cast("tuple[str, ...]", question["dimensions"])


@pytest.mark.parametrize(
    "case", ["missing-grant", "wrong-id", "wrong-kind", "existing-path", "duplicate-id"]
)
def test_exact_grants_and_existing_id_collisions_fail_before_effects(
    mutation_catalog: SchemaCatalog, case: str
) -> None:
    """Creation rejects existing files and grants for other kinds, IDs or paths."""
    store, baseline = draft_case(mutation_catalog)
    request = ContractDraft(feature_id="feature", name="Feature")
    changes = contract_changes(baseline, request)
    if case in {"existing-path", "duplicate-id"}:
        for change in changes:
            path = change.path
            if case == "duplicate-id" and change.artifact_kind == "feature-contract":
                path = path.replace("feature.json", "other.json")
            store.put(path, change.content)
        baseline = capture(store, mutation_catalog)
        changes = contract_changes(baseline, request)
    grants = grants_for(*changes)
    if case == "missing-grant":
        grants = grants[:1]
    elif case in {"wrong-id", "wrong-kind"}:
        grants = (
            replace(
                grants[0],
                **(
                    {"artifact_id": "different"}
                    if case == "wrong-id"
                    else {"artifact_kind": "evidence-reference"}
                ),
            ),
            *grants[1:],
        )
    before = dict(store.files)
    with pytest.raises(MutationError):
        plan_contract(baseline, request, grants=grants)
    assert store.files == before


@pytest.mark.parametrize(
    "fields",
    [
        {"trigger": None},
        {"extra": "unsupported"},
        {
            "state_transitions": {
                "behavior": {"observation_state": "unknown"},
                "entries": None,
            }
        },
        {
            "state_transitions": {
                "behavior": {"observation_state": "unknown"},
                "entries": [None],
            }
        },
        {
            "trigger": {
                "observation_state": "unknown",
                "statement": "Invented.",
                "evidence_refs": [],
                "unresolved_behavior_refs": [],
                "confidence": "unknown",
            }
        },
    ],
)
def test_invalid_proposed_fields_reach_accepted_complete_graph_validation(
    mutation_catalog: SchemaCatalog, fields: dict[str, object]
) -> None:
    """Valid prior bytes cannot conceal malformed or untruthful proposed content."""
    _, baseline = draft_case(mutation_catalog)
    request = ContractDraft(
        feature_id="feature", name="Feature", fields=immutable(fields)
    )
    changes = contract_changes(baseline, request)
    with pytest.raises(MutationError, match="MUTATION_INVALID") as error:
        plan_contract(baseline, request, grants=grants_for(*changes))
    assert error.value.findings


@pytest.mark.parametrize(
    "case",
    [
        "unsafe-id",
        "empty-name",
        "mutable-fields",
        "dimensions",
        "unknown-dimension",
        "unresolved-links",
    ],
)
def test_invalid_request_boundaries_are_explicit(
    mutation_catalog: SchemaCatalog, case: str
) -> None:
    """Invalid identity and collection-shaped inputs fail without native effects."""
    _, baseline = draft_case(mutation_catalog)
    with pytest.raises(ValueError):
        request = ContractDraft(
            feature_id="../escape" if case == "unsafe-id" else "feature",
            name=" " if case == "empty-name" else "Feature",
            fields=(
                cast("JsonObject", {})
                if case == "mutable-fields"
                else immutable(
                    {"required_dimensions": None}
                    if case == "dimensions"
                    else (
                        {"required_dimensions": ["not-a-dimension"]}
                        if case == "unknown-dimension"
                        else (
                            {
                                "trigger": {
                                    "observation_state": "unknown",
                                    "unresolved_behavior_refs": None,
                                }
                            }
                            if case == "unresolved-links"
                            else {}
                        )
                    )
                )
            ),
        )
        contract_changes(baseline, request)


def test_invalid_existing_collection_preserves_typed_loader_findings(
    mutation_catalog: SchemaCatalog,
) -> None:
    """Malformed prior collection data cannot reach required-field extraction."""
    store, baseline = draft_case(mutation_catalog)
    store.put(
        baseline.snapshot.profile.artifacts["unspecified_behaviors"], b'{"records":[]}'
    )
    invalid = capture(store, mutation_catalog)
    with pytest.raises(MutationError, match="DRAFT_BASELINE") as error:
        append_questions(
            invalid,
            (
                open_question(
                    "question",
                    features=("feature",),
                    dimensions=(),
                    question="Unknown?",
                ),
            ),
        )
    assert error.value.findings


def test_shared_json_values_do_not_mint_native_authority() -> None:
    """Generated references remain immutable structural values."""
    value = draft_object(reference=draft_reference("feature-contract", "feature"))
    assert (
        canonical_json(value)
        == b'{"reference":{"artifact_kind":"feature-contract","id":"feature"}}\n'
    )


@pytest.mark.parametrize("phase", ["before", "action", "after"])
@pytest.mark.parametrize(
    "state,linked",
    [
        ("inferred", False),
        ("verified", False),
        ("intentionally-unspecified", False),
        ("unknown", False),
        ("unknown", True),
    ],
)
def test_nested_transition_phases_keep_draft_claims_and_question_links(
    mutation_catalog: SchemaCatalog, phase: str, state: str, linked: bool
) -> None:
    """Each phase rejects promotion and links unknowns despite an inferred summary."""
    baseline, request = transition_case(
        mutation_catalog, phase=phase, state=state, linked=linked
    )
    question = {
        "artifact_kind": "unspecified-behavior",
        "id": "unknown-feature-feature",
    }
    if state in {"verified", "intentionally-unspecified"}:
        with pytest.raises(MutationError, match="DRAFT_CLAIM"):
            contract_changes(baseline, request)
        return
    changes = contract_changes(baseline, request)
    assert plan_contract(baseline, request, grants=grants_for(*changes)).validation.ok
    feature = as_object(json.loads(changes[0].content))
    transition = as_object(feature["state_transitions"])
    phases = cast("list[dict[str, object]]", transition["entries"])[0]
    observation = as_object(phases[phase])
    records = cast(
        "list[dict[str, object]]", as_object(json.loads(changes[1].content))["records"]
    )
    assert ("state_transitions" in cast("list[str]", records[-1]["dimensions"])) == (
        state == "unknown"
    )
    assert observation["unresolved_behavior_refs"] == (
        [question] if state == "unknown" else []
    )
