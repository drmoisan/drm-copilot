"""Check exact evidence-link projections and their unchanged claim/approval states."""

from __future__ import annotations

import json
from dataclasses import replace
from typing import TYPE_CHECKING, cast

import pytest
from drm_copilot_discovery import evidence_linking
from drm_copilot_discovery.evidence_linking import (
    EvidenceLink,
    evidence_changes,
    link_evidence,
    plan_evidence_link,
)
from drm_copilot_discovery.findings import Finding
from drm_copilot_discovery.models import JsonObject, canonical_json, to_plain_value
from drm_copilot_discovery.mutation_io import MutationArtifact, MutationResult
from drm_copilot_discovery.mutation_plan import MutationError

from tests.discovery_runtime.evidence_test_support import (
    CONTENT,
    add_record,
    memory_writer,
    request_for,
)
from tests.discovery_runtime.evidence_test_support import link_baseline as link_baseline
from tests.discovery_runtime.mutation_test_support import constant, grants_for
from tests.discovery_runtime.mutation_test_support import (
    mutation_catalog as mutation_catalog,
)
from tests.schemas.discovery.v2_schema_test_support import as_object, load_fixture

if TYPE_CHECKING:
    from drm_copilot_discovery.agent_output import InvocationContext
    from drm_copilot_discovery.mutation_plan import CapturedWorkspace, MutationPlan


@pytest.mark.parametrize(
    "kind",
    [
        "source",
        "test",
        "runtime",
        "observation",
        "decision",
        "documentation",
        "inventory",
    ],
)
def test_registration_projects_exact_provenance_and_preserves_every_other_field(
    link_baseline: CapturedWorkspace, kind: str
) -> None:
    """Every evidence type has a stable record/payload and no claim-state mutation."""
    request = request_for(link_baseline, kind=kind)
    before = link_baseline.snapshot.sha256
    changes = evidence_changes(link_baseline, request)
    original = next(
        item
        for item in link_baseline.snapshot.artifacts
        if item.path == changes[1].path
    )
    updated = as_object(json.loads(changes[1].content))
    expected = as_object(to_plain_value(original.document))
    field = (
        "runtime_evidence_refs"
        if kind in {"runtime", "observation"}
        else "source_evidence_refs"
    )
    links = cast("list[object]", updated.pop(field))
    assert expected.pop(field) == []
    assert updated == expected, "Evidence registration changed unrelated claims"
    assert links == [{"artifact_kind": "evidence-reference", "id": "proof"}]
    assert changes[0].content == canonical_json(request.record)
    assert changes[2].content == CONTENT and changes[2].expected_sha256 is None
    assert changes[1].expected_sha256 == request.expected_sha256
    assert evidence_changes(link_baseline, request) == changes
    assert link_baseline.snapshot.sha256 == before


@pytest.mark.parametrize("kind", ["unspecified-behavior", "product-decision"])
def test_collection_member_update_preserves_siblings_and_approval(
    link_baseline: CapturedWorkspace, kind: str
) -> None:
    """The containing file grant and digest bind a member-only evidence append."""
    member = load_fixture(kind)
    if kind == "unspecified-behavior":
        member.update(
            status="open",
            resolution_basis=None,
            resolution_evidence_refs=[],
            decision=None,
            approved_target_behavior=None,
        )
    collection = load_fixture(kind + "-collection")
    members = [member, dict(member, id="unrelated")]
    collection.update(id="collection", records=members)
    path = link_baseline.snapshot.profile.artifacts[
        "product_decisions" if kind == "product-decision" else "unspecified_behaviors"
    ]
    baseline = add_record(link_baseline, collection, path=path)
    request = replace(
        request_for(baseline),
        artifact_kind=kind,
        artifact_id=str(member["id"]),
        expected_sha256=baseline.snapshot.file(path).sha256,
    )
    changes = evidence_changes(baseline, request)
    value = as_object(json.loads(changes[1].content))
    records = cast("list[dict[str, object]]", value["records"])
    assert changes[1].artifact_kind == kind + "-collection"
    assert changes[1].artifact_id == "collection"
    assert records[1] == members[1]
    selected = records[0]
    assert selected["status"] == member["status"]
    if kind == "product-decision":
        approval = as_object(selected["approval"])
        original = as_object(member["approval"])
        assert (
            approval["owner"] == original["owner"]
            and approval["timestamp"] == original["timestamp"]
        )
        assert (
            cast("list[object]", approval["evidence_refs"])[:-1]
            == original["evidence_refs"]
        )
    else:
        assert selected["decision"] is selected["resolution_basis"] is None


@pytest.mark.parametrize(
    "path",
    [
        ("trigger", "evidence_refs"),
        ("state_transitions", "entries", 0, "before", "evidence_refs"),
    ],
)
def test_nested_evidence_is_linked_without_promoting_observation(
    link_baseline: CapturedWorkspace, path: tuple[str | int, ...]
) -> None:
    """Nested selection changes one recognized array, including transition phases."""
    target = next(
        item
        for item in link_baseline.snapshot.artifacts
        if item.expected_kind == "feature-contract"
    )
    document = as_object(to_plain_value(target.document))
    transition = as_object(document["state_transitions"])
    phase = dict(as_object(document["trigger"]))
    transition["entries"] = [
        dict(id="step", before=phase, action=phase, after=phase, evidence_refs=[])
    ]
    baseline = add_record(link_baseline, document, path=target.path)
    request = replace(request_for(baseline), link_path=path)
    updated = as_object(json.loads(evidence_changes(baseline, request)[1].content))
    cursor: object = updated
    original: object = document
    # Follow the explicit selector so assertions remain independent of serialization.
    for token in path[:-1]:
        cursor = (
            cast("list[object]", cursor)[token]
            if isinstance(token, int)
            else as_object(cursor)[token]
        )
        original = (
            cast("list[object]", original)[token]
            if isinstance(token, int)
            else as_object(original)[token]
        )
    value = as_object(cursor)
    assert (
        value["observation_state"]
        == as_object(original)["observation_state"]
        == "unknown"
    )
    assert (
        value["statement"] is None
        and len(cast("list[object]", value["evidence_refs"])) == 1
    )


@pytest.mark.parametrize(
    "path",
    [
        ("extensions", "evidence_refs"),
        ("acceptance_criteria",),
        ("absent",),
        ("name",),
        ("state_transitions", "entries", 100, "evidence_refs"),
    ],
)
def test_only_core_existing_evidence_arrays_are_eligible(
    link_baseline: CapturedWorkspace, path: tuple[str | int, ...]
) -> None:
    """Arbitrary arrays, scalar state and missing fields cannot receive links."""
    request = replace(request_for(link_baseline), link_path=path)
    with pytest.raises(MutationError) as caught:
        evidence_changes(link_baseline, request)
    assert caught.value.code == "EVIDENCE_LINK_FIELD"


@pytest.mark.parametrize("invalid", ["missing", "duplicate", "imported"])
def test_target_must_resolve_to_one_local_record(
    link_baseline: CapturedWorkspace, invalid: str
) -> None:
    """Absence, ambiguity and imported identity cannot select a writable destination."""
    request = request_for(link_baseline)
    target = next(
        item
        for item in link_baseline.snapshot.artifacts
        if item.expected_kind == "feature-contract"
    )
    if invalid == "missing":
        request = replace(request, artifact_id="missing")
    else:
        with_extra = add_record(
            link_baseline,
            as_object(to_plain_value(target.document)),
            path="docs/duplicate.json",
        )
        extra = replace(
            target,
            path="docs/duplicate.json",
            origin_path="feature.json" if invalid == "imported" else None,
        )
        artifacts = tuple(
            item
            for item in link_baseline.snapshot.artifacts
            if invalid == "duplicate" or item != target
        )
        link_baseline = replace(
            with_extra,
            snapshot=replace(with_extra.snapshot, artifacts=(*artifacts, extra)),
        )
    with pytest.raises(MutationError) as caught:
        evidence_changes(link_baseline, request)
    assert caught.value.code == "EVIDENCE_TARGET"


@pytest.mark.parametrize("field", ["id", "evidence_id"])
def test_duplicate_evidence_identity_is_rejected_before_proposing_writes(
    link_baseline: CapturedWorkspace, field: str
) -> None:
    """Both artifact and domain identity namespaces reject existing local records."""
    request = request_for(link_baseline)
    record = as_object(to_plain_value(request.record))
    record["evidence_id" if field == "id" else "id"] = "other"
    baseline = add_record(
        link_baseline, record, path="docs/migration/discovery/evidence/other.json"
    )
    with pytest.raises(MutationError) as caught:
        evidence_changes(baseline, request)
    assert caught.value.code == "EVIDENCE_DUPLICATE"


@pytest.mark.parametrize(
    "change",
    [
        {"evidence_type": "manual"},
        {"revision": "HEAD", "evidence_type": "source"},
        {"checksum": None},
        {"timestamp": "invalid"},
    ],
)
def test_malformed_evidence_is_rejected_by_the_accepted_schema(
    link_baseline: CapturedWorkspace, change: dict[str, object]
) -> None:
    """Semantic types and provenance are never coerced or repaired by registration."""
    request = request_for(link_baseline, updates=change)
    with pytest.raises(MutationError) as caught:
        evidence_changes(link_baseline, request)
    assert caught.value.code == "EVIDENCE_RECORD" and caught.value.findings


def test_invalid_captured_input_remains_an_explicit_prewrite_error(
    link_baseline: CapturedWorkspace,
) -> None:
    """Invalid snapshots cannot supply target identities or cause effects."""
    baseline = replace(
        link_baseline,
        snapshot=replace(
            link_baseline.snapshot,
            findings=(
                Finding(
                    code="TEST_INVALID",
                    message="Invalid input",
                    next_action="Correct input",
                ),
            ),
        ),
    )
    with pytest.raises(MutationError) as caught:
        evidence_changes(baseline, request_for(baseline))
    assert (
        caught.value.code == "EVIDENCE_BASELINE"
        and caught.value.findings == baseline.snapshot.findings
    )


@pytest.mark.parametrize("already_linked", [False, True])
def test_existing_links_are_preserved_and_exact_repeat_is_not_duplicated(
    link_baseline: CapturedWorkspace, already_linked: bool
) -> None:
    """Adding provenance retains unrelated links and one copy of a selected link."""
    target = next(
        item
        for item in link_baseline.snapshot.artifacts
        if item.expected_kind == "feature-contract"
    )
    document = as_object(to_plain_value(target.document))
    existing = [{"artifact_kind": "evidence-reference", "id": "other"}]
    selected = {"artifact_kind": "evidence-reference", "id": "proof"}
    if already_linked:
        existing.append(selected)
    document["runtime_evidence_refs"] = existing
    baseline = add_record(link_baseline, document, path=target.path)
    result = evidence_changes(baseline, request_for(baseline))
    updated = as_object(json.loads(result[1].content))
    assert updated["runtime_evidence_refs"] == [existing[0], selected]


def test_evidence_link_cannot_create_a_product_approval(
    link_baseline: CapturedWorkspace,
) -> None:
    """An unapproved decision's null approval cannot become an object during linking."""
    document = load_fixture("product-decision-collection")
    member = load_fixture("product-decision")
    member.update(status="proposed", approval=None)
    document["records"] = [member]
    path = link_baseline.snapshot.profile.artifacts["product_decisions"]
    baseline = add_record(link_baseline, document, path=path)
    request = replace(
        request_for(baseline),
        artifact_kind="product-decision",
        artifact_id=str(member["id"]),
        expected_sha256=baseline.snapshot.file(path).sha256,
    )
    with pytest.raises(MutationError) as caught:
        evidence_changes(baseline, request)
    assert caught.value.code == "EVIDENCE_LINK_FIELD"
    assert member["approval"] is None and member["status"] == "proposed"


@pytest.fixture(scope="module")
def evidence_plan(link_baseline: CapturedWorkspace) -> MutationPlan:
    """Exercise the real complete planner once; reuse only its immutable result."""
    request = request_for(link_baseline)
    changes = evidence_changes(link_baseline, request)
    return plan_evidence_link(link_baseline, request, grants=grants_for(*changes))


def test_real_plan_validates_local_bytes_and_preserves_unknown_state(
    evidence_plan: MutationPlan,
) -> None:
    """A verifiable evidence link leaves the draft observation explicitly unknown."""
    assert evidence_plan.validation.ok
    assert (
        evidence_plan.prospective.file(
            "docs/migration/discovery/evidence/capture.txt"
        ).content
        == CONTENT
    )
    feature = next(
        item
        for item in evidence_plan.prospective.artifacts
        if item.expected_kind == "feature-contract"
    )
    assert isinstance(feature.document, JsonObject)
    trigger = cast("JsonObject", feature.document["trigger"])
    assert trigger["observation_state"] == "unknown" and trigger["statement"] is None


def test_wrapper_forwards_exact_context_grants_and_dry_run(
    link_baseline: CapturedWorkspace,
    evidence_plan: MutationPlan,
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """Thin orchestration forwards dry-run arguments and returns the exact result."""
    context = cast("InvocationContext", object())
    seen: list[object] = []

    def planned(
        baseline: CapturedWorkspace,
        request: EvidenceLink,
        *,
        grants: object,
        invocation: object,
    ) -> MutationPlan:
        """Observe untouched inputs while reusing a genuinely validated plan."""
        seen.extend((baseline, request, grants, invocation))
        return evidence_plan

    monkeypatch.setattr(evidence_linking, "plan_evidence_link", planned)
    request = request_for(link_baseline)
    writer = memory_writer(link_baseline)
    expected = MutationResult(
        ok=True,
        artifacts=(),
        findings=(),
        validation=evidence_plan.validation,
        authority_invalidated=False,
    )

    def committed(plan: MutationPlan, **options: object) -> MutationResult:
        """Observe the wrapper seam; actual publication is an integration concern."""
        seen.extend((plan, options))
        return expected

    monkeypatch.setattr(evidence_linking, "commit_mutation", committed)
    result = link_evidence(
        link_baseline,
        request,
        grants=evidence_plan.grants,
        writer=writer,
        dry_run=True,
        invocation=context,
    )
    assert seen == [
        link_baseline,
        request,
        evidence_plan.grants,
        context,
        evidence_plan,
        {"writer": writer, "dry_run": True},
    ]
    assert result is expected and writer.invalidations == writer.attempts == 0


@pytest.mark.parametrize("fail", [False, True])
def test_shared_writer_commits_or_reports_explicit_partial_failure(
    link_baseline: CapturedWorkspace,
    evidence_plan: MutationPlan,
    monkeypatch: pytest.MonkeyPatch,
    fail: bool,
) -> None:
    """The wrapper preserves the shared writer's complete or partial disposition."""
    monkeypatch.setattr(evidence_linking, "plan_evidence_link", constant(evidence_plan))
    writer = memory_writer(link_baseline)
    output = evidence_plan.writes[0].change
    artifact = MutationArtifact(
        path=output.path,
        artifact_kind=output.artifact_kind,
        artifact_id=output.artifact_id,
        sha256=evidence_plan.prospective.file(output.path).sha256,
        status="conflict" if fail else "created",
    )
    expected = MutationResult(
        ok=not fail,
        artifacts=(artifact,),
        findings=(
            (
                Finding(
                    code="MUTATION_IO", message="bounded failure", next_action="Reload"
                ),
            )
            if fail
            else ()
        ),
        validation=evidence_plan.validation,
        authority_invalidated=True,
        uncertain_paths=(output.path,) if fail else (),
    )
    seen: list[object] = []

    def committed(plan: MutationPlan, **options: object) -> MutationResult:
        """Return a distinct shared result without running unrelated graph logic."""
        seen.extend((plan, options))
        return expected

    monkeypatch.setattr(evidence_linking, "commit_mutation", committed)
    result = link_evidence(
        link_baseline,
        request_for(link_baseline),
        grants=evidence_plan.grants,
        writer=writer,
    )
    assert result is expected
    assert seen == [evidence_plan, {"writer": writer, "dry_run": False}]
    assert writer.invalidations == writer.attempts == 0
