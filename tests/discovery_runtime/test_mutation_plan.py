"""Prove prospective mutations use real complete loading and shared validation."""

from __future__ import annotations

import itertools
import json
from dataclasses import FrozenInstanceError, replace
from typing import TYPE_CHECKING, cast

import pytest
from drm_copilot_discovery.models import to_plain_value
from drm_copilot_discovery.mutation_io import capture_workspace
from drm_copilot_discovery.mutation_plan import (
    MutationChange,
    MutationError,
    plan_mutation,
    project_snapshot,
)
from drm_copilot_discovery.path_models import PathMetadata, PathPolicyError
from drm_copilot_discovery.validation import report_projection

from tests.discovery_runtime.test_references import immutable
from tests.discovery_runtime.test_snapshot_io import PROFILE_PATH, memory_workspace
from tests.discovery_runtime.test_snapshot_loading import MemoryRepository
from tests.schemas.discovery.v2_schema_test_support import as_object, load_fixture

if TYPE_CHECKING:
    from drm_copilot_discovery.catalog import SchemaCatalog


from tests.discovery_runtime.mutation_test_support import (
    capture,
    collection_change,
    grants_for,
    mutation_case,
    role_plan,
)
from tests.discovery_runtime.mutation_test_support import (
    mutation_catalog as mutation_catalog,
)


def test_planner_projects_complete_valid_graph_and_preserves_originals(
    mutation_catalog: SchemaCatalog,
) -> None:
    """Projection validates bytes in memory and retains unrelated inputs unchanged."""
    store, baseline = mutation_case(mutation_catalog)
    changes = (
        collection_change(baseline),
        collection_change(baseline, decisions=True, identifier="decisions"),
    )
    before = dict(store.files)
    plan = plan_mutation(baseline, changes, grants=grants_for(*changes))
    assert (
        plan.validation.ok and plan.validation.input_sha256 == plan.prospective.sha256
    )
    assert (
        store.files == before
        and baseline.snapshot.file(PROFILE_PATH).content == before[PROFILE_PATH]
    )
    assert plan.prospective.file(PROFILE_PATH) == baseline.snapshot.file(PROFILE_PATH)
    assert len(plan.prospective.artifacts) == 2


def test_plan_permutation_and_repeatability_property(
    mutation_catalog: SchemaCatalog,
) -> None:
    """Proposal/grant permutations preserve the canonical plan and prospective hash."""
    _, baseline = mutation_case(mutation_catalog)
    changes = (collection_change(baseline), collection_change(baseline, decisions=True))
    expected = plan_mutation(baseline, changes, grants=grants_for(*changes))
    # Enumerate the finite ordering domain without a shared RNG or mutable fixture.
    for permutation in itertools.permutations(changes):
        plan = plan_mutation(
            baseline, permutation, grants=grants_for(*reversed(permutation))
        )
        assert plan.writes == expected.writes
        assert plan.validation == expected.validation
        assert plan.prospective.sha256 == expected.prospective.sha256


@pytest.mark.parametrize(
    "error", ["content", "kind", "id", "digest", "grant", "duplicate", "missing"]
)
def test_invalid_proposals_never_change_valid_existing_bytes(
    error: str, mutation_catalog: SchemaCatalog
) -> None:
    """Invalid requests cannot substitute the valid old document for validation."""
    store, initial = mutation_case(mutation_catalog)
    first = collection_change(initial)
    store.put(first.path, first.content)
    baseline = capture(store, mutation_catalog)
    change = collection_change(baseline)
    grants = grants_for(change)
    expected = "MUTATION_"
    # Each case changes one independent precondition while retaining valid prior bytes.
    if error == "content":
        change = replace(change, content=b'{"schema_version":"2.0.0"}')
    elif error == "kind":
        change = replace(change, artifact_kind="coverage-ledger")
    elif error == "id":
        change = replace(change, artifact_id="other")
        grants = grants_for(change)
    elif error == "digest":
        change = replace(change, expected_sha256="0" * 64)
    elif error == "grant":
        grants = (replace(grants[0], path=grants[0].path + ".other"),)
    elif error == "missing":
        grants = ()
    else:
        expected = "PATH_COLLISION"
    before = dict(store.files)
    with pytest.raises((MutationError, PathPolicyError), match=expected):
        plan_mutation(
            baseline,
            (change, change) if error == "duplicate" else (change,),
            grants=grants,
        )
    assert store.files == before


def test_unchanged_bytes_are_explicit_skips(mutation_catalog: SchemaCatalog) -> None:
    """A valid same-byte update is idempotent and still requires the original digest."""
    store, initial = mutation_case(mutation_catalog)
    change = collection_change(initial)
    store.put(change.path, change.content)
    baseline = capture(store, mutation_catalog)
    change = collection_change(baseline)
    result = plan_mutation(baseline, (change,), grants=grants_for(change))
    assert result.writes[0].skipped
    assert result.prospective.sha256 == baseline.snapshot.sha256


@pytest.mark.parametrize(
    "role",
    [
        "legacy-parity-analyst",
        "runtime-characterization-analyst",
        "requirements-reconciler",
    ],
)
def test_role_output_uses_exact_accepted_validator(
    role: str, mutation_catalog: SchemaCatalog
) -> None:
    """Draft questions require an exact role output manifest."""
    _, baseline = mutation_case(mutation_catalog)
    changes, context = role_plan(baseline, role=role)
    result = plan_mutation(
        baseline, changes, grants=grants_for(*changes), invocation=context
    )
    assert (
        result.validation.mode == "agent-output"
        and result.validation.output_valid is True
    )
    assert result.validation.role == role


@pytest.mark.parametrize(
    "fault", ["role", "workspace", "baseline", "manifest", "unrequested"]
)
def test_role_mismatches_and_unrequested_changes_are_rejected(
    fault: str, mutation_catalog: SchemaCatalog
) -> None:
    """Caller context and required outputs cannot be substituted or widened by bytes."""
    _, baseline = mutation_case(mutation_catalog)
    changes, context = role_plan(baseline)
    # Vary one context binding to prove none can widen the authenticated manifest.
    if fault == "role":
        context = replace(context, role="migration-coverage-reviewer")
    elif fault == "workspace":
        value = as_object(to_plain_value(context.workspace))
        value["workspace_root"] = "/different"
        context = replace(context, workspace=immutable(value))
    elif fault == "baseline":
        context = replace(context, baseline=project_snapshot(baseline, changes[:1]))
    elif fault == "manifest":
        changes = changes[:1]
    else:
        changes += (collection_change(baseline, decisions=True),)
    with pytest.raises(MutationError, match="MUTATION_(CONTEXT|INVALID)"):
        plan_mutation(
            baseline, changes, grants=grants_for(*changes), invocation=context
        )


@pytest.mark.parametrize(
    "path",
    [
        "src/changed.py",
        "config/discovery.json",
        "../escape",
        "docs/migration/discovery/reports/arbitrary.json",
    ],
)
def test_unsafe_or_misclassified_paths_fail_before_write(
    path: str, mutation_catalog: SchemaCatalog
) -> None:
    """Path policy and real loader classification both constrain proposed locations."""
    _, baseline = mutation_case(mutation_catalog)
    with pytest.raises((MutationError, PathPolicyError)):
        change = replace(collection_change(baseline), path=path)
        plan_mutation(baseline, (change,), grants=grants_for(change))


def test_parser_findings_are_retained_in_graph_rejection(
    mutation_catalog: SchemaCatalog,
) -> None:
    """A schema-valid envelope with broken references returns actual graph findings."""
    _, baseline = mutation_case(mutation_catalog)
    value = load_fixture("unspecified-behavior-collection")
    value["records"] = [load_fixture("unspecified-behavior")]
    change = replace(
        collection_change(baseline),
        artifact_id=str(value["id"]),
        content=json.dumps(value).encode(),
    )
    with pytest.raises(MutationError, match="MUTATION_INVALID") as raised:
        plan_mutation(baseline, (change,), grants=grants_for(change))
    # Preserve the validator's concrete errors instead of replacing them with a generic
    # code.
    assert raised.value.findings and any(
        item.severity == "error" for item in raised.value.findings
    )


@pytest.mark.parametrize("digest", ["short", "A" * 64, "g" * 64])
def test_change_rejects_malformed_original_digests(digest: str) -> None:
    """Precondition syntax cannot be interpreted as an expression or mutable value."""
    with pytest.raises(ValueError, match="SHA-256"):
        MutationChange(
            artifact_kind="scope",
            artifact_id="scope",
            path="docs/scope.yaml",
            content=b"{}",
            expected_sha256=digest,
        )


def test_values_reject_mutability_and_metadata_ambiguity(
    mutation_catalog: SchemaCatalog,
) -> None:
    """Frozen captures and requests cannot be changed through mutable caller data."""
    _, baseline = mutation_case(mutation_catalog)
    change = collection_change(baseline)
    with pytest.raises(ValueError, match="immutable bytes"):
        replace(change, content=cast("bytes", bytearray()))
    attribute = "path"
    with pytest.raises(FrozenInstanceError):
        setattr(change, attribute, "other")
    with pytest.raises(ValueError, match="unique"):
        replace(baseline, metadata=baseline.metadata + (baseline.metadata[0],))
    with pytest.raises(ValueError, match="workspace root"):
        replace(baseline, metadata=())
    assert baseline.inspect("new/deep/file").kind == "missing"
    entries = dict(baseline.metadata)
    entries["new"] = PathMetadata(kind="missing")
    entries["."] = replace(entries["."], children=(*entries["."].children, "new"))
    assert (
        replace(baseline, metadata=tuple(entries.items())).inspect("new/file").kind
        == "missing"
    )
    entries["."] = replace(
        entries["."], children=(*entries["."].children, "uncaptured")
    )
    incomplete = replace(baseline, metadata=tuple(entries.items()))
    with pytest.raises(OSError, match="not captured"):
        incomplete.inspect("uncaptured/file")
    entries["uncaptured"] = PathMetadata(
        kind="file", identity="f", resolved_path="/workspace/uncaptured"
    )
    with pytest.raises(OSError, match="not a directory"):
        replace(baseline, metadata=tuple(entries.items())).inspect("uncaptured/file")


def test_bounded_empty_and_oversized_changes_fail(
    mutation_catalog: SchemaCatalog,
) -> None:
    """Empty mutations and oversized proposed documents cannot start a write plan."""
    _, baseline = mutation_case(mutation_catalog)
    with pytest.raises(MutationError, match="MUTATION_LIMIT"):
        plan_mutation(baseline, (), grants=())
    change = replace(
        collection_change(baseline),
        content=b"x" * (baseline.snapshot.profile.limits.document_bytes + 1),
    )
    with pytest.raises(MutationError, match="MUTATION_LIMIT"):
        plan_mutation(baseline, (change,), grants=grants_for(change))


def test_directory_enumeration_permutations_preserve_capture(
    mutation_catalog: SchemaCatalog,
) -> None:
    """Changing only directory enumeration order never reports changed inputs."""
    store, baseline = mutation_case(mutation_catalog)
    calls = 0

    def reordered(path: str) -> PathMetadata:
        """Return alternating namespace order over the same test-owned metadata."""
        nonlocal calls
        calls += 1
        entry = store.metadata(path)
        return replace(entry, children=entry.children[:: (-1 if calls % 2 else 1)])

    result = capture_workspace(
        workspace_root=baseline.workspace_root,
        profile_path=PROFILE_PATH,
        metadata=reordered,
        read_bytes=store.read,
        catalog=mutation_catalog,
    )
    assert (
        result.metadata == baseline.metadata
        and result.snapshot.sha256 == baseline.snapshot.sha256
    )


@pytest.mark.parametrize("kind", ["evidence-payload", "acceptance-view"])
def test_opaque_grants_cannot_create_structured_records(
    kind: str, mutation_catalog: SchemaCatalog
) -> None:
    """Opaque kinds cannot suppress authoritative parsed kind/ID comparisons."""
    store, baseline = mutation_case(mutation_catalog)
    key, structured = (
        ("evidence", "evidence-reference")
        if kind == "evidence-payload"
        else ("acceptance", "acceptance-specification")
    )
    # Supply the referenced payload so this case reaches authoritative identity checks.
    if kind == "evidence-payload":
        store.put("docs/migration/discovery/evidence/capture-alpha.json", b"{}")
        baseline = capture(store, mutation_catalog)
    change = MutationChange(
        artifact_kind=kind,
        artifact_id="granted",
        path=baseline.snapshot.profile.artifacts[key] + "/record.yaml",
        content=json.dumps(load_fixture(structured)).encode(),
        expected_sha256=None,
    )
    with pytest.raises(MutationError, match="MUTATION_IDENTITY"):
        plan_mutation(baseline, (change,), grants=grants_for(change))


@pytest.mark.parametrize("wrong_id", [False, True])
def test_report_view_requires_exact_structured_peer(
    wrong_id: bool, mutation_catalog: SchemaCatalog
) -> None:
    """Markdown views require the same report kind/ID as their structured peer."""
    _, baseline = mutation_case(mutation_catalog)
    document = report_projection(
        baseline.snapshot,
        kind="coverage-report",
        identifier="coverage",
        mode="structural",
    )
    report = MutationChange(
        artifact_kind="coverage-report",
        artifact_id="coverage",
        path=baseline.snapshot.profile.artifacts["reports"] + "/coverage-report.json",
        content=json.dumps(document).encode(),
        expected_sha256=None,
    )
    view = replace(
        report,
        artifact_id="wrong" if wrong_id else "coverage",
        path=report.path[:-5] + ".md",
        content=b"# Coverage\n",
    )
    # A matching view shares the structured report identity; mismatches must fail early.
    if wrong_id:
        with pytest.raises(MutationError, match="MUTATION_IDENTITY"):
            plan_mutation(baseline, (report, view), grants=grants_for(report, view))
    else:
        assert plan_mutation(
            baseline, (report, view), grants=grants_for(report, view)
        ).validation.ok


@pytest.mark.parametrize("failure", ["none", "missing", "oversized"])
def test_projection_replays_only_captured_git_objects(
    failure: str, mutation_catalog: SchemaCatalog
) -> None:
    """Projections reuse pinned byte values and cannot read new Git objects."""
    store, _ = memory_workspace()
    store.put("src/a.py", b"source")
    repository = MemoryRepository({("a" * 40, "src/a.py"): b"source"})
    baseline = capture_workspace(
        workspace_root="/workspace",
        profile_path=PROFILE_PATH,
        metadata=store.metadata,
        read_bytes=store.read,
        catalog=mutation_catalog,
        repository=repository,
    )
    # Missing and oversized pins are loader errors, never substituted live reads.
    if failure == "missing":
        baseline = replace(
            baseline, snapshot=replace(baseline.snapshot, repository_files=())
        )
    elif failure == "oversized":
        pinned = replace(baseline.snapshot.repository_files[0], content=b"x" * 16777217)
        baseline = replace(
            baseline, snapshot=replace(baseline.snapshot, repository_files=(pinned,))
        )
    change = collection_change(baseline)
    # Successful replay is pure; absent or oversized captured objects abort the load.
    if failure == "none":
        assert not project_snapshot(baseline, (change,)).findings
    else:
        with pytest.raises(OSError, match="not captured|read limit"):
            project_snapshot(baseline, (change,))
    assert repository.requests == [("a" * 40, "src/a.py")]


def test_projection_refuses_uncaptured_profile_bytes(
    mutation_catalog: SchemaCatalog,
) -> None:
    """Metadata alone cannot supply bytes missing from a complete captured graph."""
    _, baseline = mutation_case(mutation_catalog)
    baseline = replace(
        baseline,
        snapshot=replace(
            baseline.snapshot, manifest=replace(baseline.snapshot.manifest, files=())
        ),
    )
    with pytest.raises(OSError, match="uncaptured"):
        project_snapshot(baseline, ())


def test_capture_rejects_metadata_changes_during_loading(
    mutation_catalog: SchemaCatalog,
) -> None:
    """
    A namespace identity change during one capture cannot yield an immutable input.
    """
    store, baseline = mutation_case(mutation_catalog)
    seen: set[str] = set()

    def changing(path: str) -> PathMetadata:
        """Replace the root identity only after its first recorded observation."""
        value = store.metadata(path)
        if path == "." and path in seen:
            return replace(value, identity="changed")
        seen.add(path)
        return value

    with pytest.raises(OSError, match="Metadata changed"):
        capture_workspace(
            workspace_root=baseline.workspace_root,
            profile_path=PROFILE_PATH,
            metadata=changing,
            read_bytes=store.read,
            catalog=mutation_catalog,
        )
