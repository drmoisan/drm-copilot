"""Verify migration proposals and publication outcomes with isolated memory seams."""

from __future__ import annotations

import json
from dataclasses import replace
from hashlib import sha256
from pathlib import Path
from typing import TYPE_CHECKING, cast

import pytest
from drm_copilot_discovery import migration_v1
from drm_copilot_discovery.catalog import V1_KINDS, schema_path
from drm_copilot_discovery.draft_contracts import draft_object
from drm_copilot_discovery.findings import Finding
from drm_copilot_discovery.init_io import BootstrapResult
from drm_copilot_discovery.migration_models import (
    MIGRATION_EXTENSION,
    MigrationBinding,
    MigrationPlan,
    MigrationRequest,
    MigrationSource,
)
from drm_copilot_discovery.models import JsonObject, canonical_json
from drm_copilot_discovery.mutation_io import MutationArtifact, MutationResult
from drm_copilot_discovery.mutation_plan import MutationError
from drm_copilot_discovery.parsing import parse_document
from drm_copilot_discovery.schema_validation import validate_document
from drm_copilot_discovery.snapshot import SnapshotFile

from tests.discovery_runtime.initialization_test_support import (
    InitializationCase,
    request_for,
)
from tests.discovery_runtime.initialization_test_support import (
    initialization_catalog as initialization_catalog,
)
from tests.discovery_runtime.initialization_test_support import (
    initialization_templates as initialization_templates,
)
from tests.discovery_runtime.mutation_test_support import constant
from tests.discovery_runtime.test_references import immutable

if TYPE_CHECKING:
    from _pytest.monkeypatch import MonkeyPatch
    from drm_copilot_discovery.catalog import SchemaCatalog
    from drm_copilot_discovery.init_projection import InitializationTemplates
    from drm_copilot_discovery.mutation_io import MutationWriter
    from drm_copilot_discovery.mutation_plan import CapturedWorkspace, MutationPlan

ROOT = Path(__file__).resolve().parents[2]
ENVIRONMENT = draft_object(
    id="legacy-environment",
    platform="desktop",
    operating_mode="online",
    client_id=None,
    extensions=JsonObject(()),
)


def source_for(kind: str, **changes: object) -> MigrationSource:
    """Read kind (str)'s committed fixture with changes (object keyword fields).
    Return detached MigrationSource; fixture reads never write or mutate originals."""
    name = Path(schema_path(kind, "1.0.0")).name.replace(
        ".schema.json", ".example.json"
    )
    document = cast(
        "dict[str, object]",
        json.loads((ROOT / "examples/discovery/v1" / name).read_text("utf-8")),
    )
    document.update(changes)
    return MigrationSource(
        path="legacy/" + kind + ".json",
        kind=kind,
        content=json.dumps(document).encode(),
    )


def migration_request(*sources: MigrationSource) -> MigrationRequest:
    """Return MigrationRequest from sources (MigrationSource varargs) or fixtures.
    Read-only fixture inputs receive explicit context without verified claims."""
    # Select all frozen kinds only when the caller did not choose a smaller case.
    selected = sources or tuple(source_for(kind) for kind in V1_KINDS)
    return MigrationRequest(
        initialization=replace(
            request_for("combined"), documentation_roots=("legacy",)
        ),
        sources=selected,
        # Bind every source explicitly so individual tests can remove context.
        bindings=tuple(
            MigrationBinding(
                source_id=str(json.loads(source.content)["id"]),
                feature_ids=("feature-alpha",),
                environment=ENVIRONMENT,
            )
            for source in selected
        ),
    )


@pytest.fixture(scope="module")
def migration_plan(
    initialization_catalog: SchemaCatalog,
    initialization_templates: InitializationTemplates,
) -> MigrationPlan:
    """Return MigrationPlan from SchemaCatalog/InitializationTemplates fixtures.
    Only this fixture's memory store changes; its returned plan is immutable."""
    case = InitializationCase(initialization_catalog)
    request = migration_request()
    # Seed original captures before composing the real validated draft graph.
    for source in request.sources:
        case.disk.store.put(source.path, source.content)
    return migration_v1.plan_migration(
        request, io=case.io, templates=initialization_templates
    )


def source_capture(
    plan: MigrationPlan, sources: tuple[MigrationSource, ...]
) -> CapturedWorkspace:
    """Return CapturedWorkspace for MigrationPlan and tuple[MigrationSource, ...].
    Substitute detached captures in memory; the fixture plan remains unchanged."""
    baseline = plan.mutation.baseline
    # Retain unrelated capture entries while selecting this test's source set.
    files = tuple(
        item
        for item in baseline.snapshot.manifest.files
        if not item.path.startswith("legacy/")
    )
    manifest = replace(
        baseline.snapshot.manifest,
        files=files
        # Project selected originals into the existing immutable capture contract.
        + tuple(
            SnapshotFile(path=item.path, content=item.content, category="documentation")
            for item in sources
        ),
    )
    return replace(baseline, snapshot=replace(baseline.snapshot, manifest=manifest))


def test_all_kinds_have_exact_mapping_and_honest_projected_graph(
    migration_plan: MigrationPlan,
) -> None:
    """Check MigrationPlan fixture mappings without writes; return None."""
    assert migration_plan.mutation.validation.ok
    report = migration_plan.report
    assert report["activation_switched"] is False and report["result"] == "pass"
    mappings = cast("tuple[JsonObject, ...]", report["mappings"])
    assert len(mappings) == len(V1_KINDS)
    # Check every frozen kind against original and exact prospective output bytes.
    for source, mapping in zip(migration_plan.request.sources, mappings, strict=True):
        assert mapping["old_path"] == source.path
        assert mapping["old_sha256"] == sha256(source.content).hexdigest()
        output = migration_plan.mutation.prospective.file(str(mapping["new_path"]))
        assert mapping["new_sha256"] == output.sha256
        assert mapping["status"] == "planned"
    extension = cast("JsonObject", report["extensions"])[MIGRATION_EXTENSION]
    assert cast("JsonObject", extension)["publication"] == "projection-only"
    assert len(cast("tuple[JsonObject, ...]", report["unresolved_behavior_refs"])) == 7


def test_planning_order_and_transient_input_do_not_change_report(
    migration_plan: MigrationPlan,
) -> None:
    """Check MigrationPlan fixture input-order independence; return None."""
    reordered = replace(
        migration_plan.request,
        sources=tuple(reversed(migration_plan.request.sources)),
        bindings=tuple(reversed(migration_plan.request.bindings)),
    )
    assert reordered == migration_plan.request
    assert migration_plan.report["source_manifest_sha256"]


@pytest.mark.parametrize(
    "change",
    ["missing", "different", "invalid", "version", "duplicate", "unknown-binding"],
)
def test_source_validation_fails_closed(
    monkeypatch: MonkeyPatch, migration_plan: MigrationPlan, change: str
) -> None:
    """Use MonkeyPatch/MigrationPlan fixtures and str change; return None.
    Scoped memory patches exercise exact input/schema/identity rejection."""
    source = source_for("feature-contract")
    captured = (source,)
    requested = source
    code = "MIGRATION_SOURCE"
    # Each case isolates capture, schema or cross-kind identity failure.
    if change == "missing":
        captured = ()
    elif change == "different":
        requested = replace(source, content=source.content + b" ")
    elif change in {"invalid", "version"}:
        requested = source_for(
            "feature-contract",
            **({"schema_version": "9.0.0"} if change == "version" else {"title": 8}),
        )
        captured, code = (requested,), "MIGRATION_INPUT"
    elif change == "duplicate":
        other = source_for("product-decision", id="feature-alpha")
        captured, code = (source, other), "MIGRATION_ID"
    # Duplicate IDs need both sources; other cases mutate a single source.
    if change == "duplicate":
        request = MigrationRequest(
            initialization=migration_plan.request.initialization, sources=captured
        )
    else:
        request = migration_request(requested)
    if change == "unknown-binding":
        request = replace(request, bindings=(MigrationBinding(source_id="absent"),))
        code = "MIGRATION_BINDING"
    with pytest.raises(MutationError, match=code):
        project_sources(monkeypatch, migration_plan, request, captured)


def project_sources(
    monkeypatch: MonkeyPatch,
    plan: MigrationPlan,
    request: MigrationRequest,
    sources: tuple[MigrationSource, ...],
) -> MigrationPlan:
    """Use MonkeyPatch, MigrationPlan, MigrationRequest and a MigrationSource tuple.
    Return MigrationPlan; scoped initializer/graph patches affect memory only."""
    capture = replace(
        plan.initialization.capture, proposal_base=source_capture(plan, sources)
    )
    monkeypatch.setattr(
        migration_v1,
        "plan_initialization",
        constant(replace(plan.initialization, capture=capture)),
    )
    monkeypatch.setattr(migration_v1, "plan_mutation", constant(plan.mutation))
    case = InitializationCase(plan.mutation.baseline.snapshot.catalog)
    return migration_v1.plan_migration(request, io=case.io)


def test_yaml_and_identifier_mapping_keep_original_bytes(
    monkeypatch: MonkeyPatch,
    migration_plan: MigrationPlan,
) -> None:
    """Use MonkeyPatch/MigrationPlan fixtures to check YAML mapping; return None."""
    source = replace(
        source_for("feature-contract", id="1feature"), path="legacy/one.yaml"
    )
    request = replace(migration_request(source), bindings=())
    plan = project_sources(monkeypatch, migration_plan, request, (source,))
    mapping = cast("tuple[JsonObject, ...]", plan.report["mappings"])[0]
    assert mapping["old_id"] == "1feature"
    assert mapping["new_id"] == "migrated-" + sha256(b"1feature").hexdigest()
    assert mapping["old_sha256"] == sha256(source.content).hexdigest()


def unit_commit_case(
    monkeypatch: MonkeyPatch, plan: MigrationPlan
) -> InitializationCase:
    """Use MonkeyPatch and MigrationPlan to return an isolated InitializationCase.
    Scoped graph/bootstrap patches affect memory only; no external I/O occurs."""
    case = InitializationCase(plan.mutation.baseline.snapshot.catalog)
    monkeypatch.setattr(migration_v1, "plan_migration", constant(plan))
    monkeypatch.setattr(
        case.io,
        "bootstrap",
        constant(
            BootstrapResult(
                ok=True,
                created=("new-root",),
                uncertain=(),
                authority_invalidated=True,
                physical=plan.mutation.baseline,
            )
        ),
    )
    monkeypatch.setattr(case.io, "physical_capture", constant(plan.mutation.baseline))
    monkeypatch.setattr(migration_v1, "plan_mutation", constant(plan.mutation))
    return case


@pytest.mark.parametrize("success", [True, False])
def test_returned_outcome_tracks_actual_partial_publication(
    monkeypatch: MonkeyPatch, migration_plan: MigrationPlan, success: bool
) -> None:
    """Use MonkeyPatch/MigrationPlan fixtures and bool success; return None.
    The scoped publication fake verifies projection/outcome separation in memory."""
    case = unit_commit_case(monkeypatch, migration_plan)
    mapping = cast("tuple[JsonObject, ...]", migration_plan.report["mappings"])[0]
    # One writer result varies success/conflict while preserving exact path identity.
    publication = MutationResult(
        ok=success,
        artifacts=(
            MutationArtifact(
                path=str(mapping["new_path"]),
                artifact_kind=str(mapping["new_kind"]),
                artifact_id=str(mapping["new_id"]),
                sha256=str(mapping["new_sha256"]),
                status="created" if success else "conflict",
            ),
        ),
        findings=(
            ()
            if success
            else (
                Finding(
                    code="MUTATION_FAILED",
                    message="write failed",
                    next_action="Inspect partial outputs",
                ),
            )
        ),
        validation=migration_plan.mutation.validation,
        authority_invalidated=True,
        uncertain_paths=() if success else (str(mapping["new_path"]),),
    )

    def publish(plan: MutationPlan, *, writer: MutationWriter) -> MutationResult:
        """Use MutationPlan/MutationWriter to check capture; return MutationResult."""
        assert writer.capture() == plan.baseline
        return publication

    monkeypatch.setattr(migration_v1, "commit_mutation", publish)
    result = migration_v1.commit_migration(migration_plan, io=case.io)
    assert result.ok is success and result.publication is publication
    assert result.bootstrap_created == ("new-root",)
    assert result.uncertain_paths == publication.uncertain_paths
    assert result.report["result"] == ("pass" if success else "fail")
    # An actual returned outcome must never mutate the persisted planned mappings.
    assert all(
        item["status"] == "planned"
        for item in cast("tuple[JsonObject, ...]", migration_plan.report["mappings"])
    )
    checked = validate_document(
        canonical_json(result.report),
        expected_kind="migration-report",
        expected_version="2.0.0",
        catalog=migration_plan.mutation.baseline.snapshot.catalog,
    )
    assert checked.ok, checked.findings


@pytest.mark.parametrize(
    "failure",
    [
        "reconstruct",
        "bootstrap",
        "physical",
        "projection",
        "revocation",
        "dry-reconstruct",
    ],
)
def test_commit_failures_preserve_truth_and_do_not_activate(
    monkeypatch: MonkeyPatch, migration_plan: MigrationPlan, failure: str
) -> None:
    """Use MonkeyPatch/MigrationPlan fixtures and str failure; return None.
    Isolated memory faults verify retained effects and authority handling."""
    case = unit_commit_case(monkeypatch, migration_plan)
    changed = replace(
        migration_plan.mutation, prospective=migration_plan.mutation.baseline.snapshot
    )
    # Route the selected fault to reconstruction, bootstrap, capture or projection.
    if failure in {"reconstruct", "revocation", "dry-reconstruct"}:
        monkeypatch.setattr(
            migration_v1,
            "plan_migration",
            constant(replace(migration_plan, report=immutable({"changed": True}))),
        )
    elif failure == "bootstrap":
        monkeypatch.setattr(
            case.io,
            "bootstrap",
            constant(
                BootstrapResult(
                    ok=False,
                    created=("new-root",),
                    uncertain=("uncertain",),
                    authority_invalidated=True,
                    error="blocked",
                )
            ),
        )
    elif failure == "physical":
        monkeypatch.setattr(
            case.io,
            "bootstrap",
            constant(
                BootstrapResult(
                    ok=True,
                    created=(),
                    uncertain=(),
                    authority_invalidated=True,
                    physical=None,
                )
            ),
        )
    else:
        monkeypatch.setattr(migration_v1, "plan_mutation", constant(changed))
    if failure == "revocation":

        def broken() -> None:
            """Raise OSError for the scoped revocation fake; never return None."""
            raise OSError("revocation blocked")

        monkeypatch.setattr(case.io, "invalidate_authority", broken)
    result = migration_v1.commit_migration(
        migration_plan, io=case.io, dry_run=failure == "dry-reconstruct"
    )
    assert not result.ok and result.error
    assert result.report["activation_switched"] is False
    assert case.disk.store.files == {}
    if failure == "bootstrap":
        assert result.bootstrap_created == ("new-root",) and result.uncertain_paths == (
            "uncertain",
        )
    if failure == "revocation":
        assert "revocation blocked" in result.error
    if failure == "dry-reconstruct":
        assert case.revocations == 0


@pytest.mark.parametrize(
    "case", ["malformed-template", "record-conflict", "same-output", "different-output"]
)
def test_proposal_preserves_existing_bytes_or_reports_explicit_conflicts(
    monkeypatch: MonkeyPatch,
    migration_plan: MigrationPlan,
    case: str,
) -> None:
    """Use MonkeyPatch/MigrationPlan fixtures and str case; return None.
    Scoped memory substitutions distinguish template faults from output conflicts."""
    plan, source = migration_plan, source_for("feature-contract")
    # Existing-file cases alter captured outputs; template cases alter draft inputs.
    if case.endswith("output"):
        baseline = plan.mutation.baseline
        path = (
            baseline.snapshot.profile.artifacts["feature_contracts"]
            + "/feature-alpha.json"
        )
        original = plan.mutation.prospective.file(path)
        if case == "different-output":
            original = replace(original, content=original.content + b" ")
        manifest = replace(
            baseline.snapshot.manifest,
            files=baseline.snapshot.manifest.files + (original,),
        )
        plan = replace(
            plan,
            mutation=replace(
                plan.mutation,
                baseline=replace(
                    baseline, snapshot=replace(baseline.snapshot, manifest=manifest)
                ),
            ),
        )
    else:
        writes = list(plan.initialization.mutation.writes)
        # Locate the unresolved collection whose ID merge must remain fail-closed.
        index = next(
            i
            for i, item in enumerate(writes)
            if item.change.artifact_kind == "unspecified-behavior-collection"
        )
        content = b"{"
        if case == "record-conflict":
            document = parse_document(writes[index].change.content, format="json").value
            assert document is not None
            fields = dict(document)
            fields["records"] = (draft_object(id="unknown-feature-feature-alpha"),)
            content = canonical_json(JsonObject(tuple(fields.items())))
        writes[index] = replace(
            writes[index], change=replace(writes[index].change, content=content)
        )
        initialization = replace(
            plan.initialization,
            mutation=replace(plan.initialization.mutation, writes=tuple(writes)),
        )
        plan = replace(plan, initialization=initialization)
    # Exact bytes are reusable; malformed or conflicting inputs must raise.
    if case == "same-output":
        result = project_sources(
            monkeypatch, plan, migration_request(source), (source,)
        )
        mapping = cast("tuple[JsonObject, ...]", result.report["mappings"])[0]
        assert (
            mapping["new_sha256"]
            == migration_plan.mutation.prospective.file(str(mapping["new_path"])).sha256
        )
    else:
        with pytest.raises(
            MutationError,
            match=(
                "MIGRATION_TEMPLATE"
                if case == "malformed-template"
                else "MIGRATION_COLLISION"
            ),
        ):
            project_sources(monkeypatch, plan, migration_request(source), (source,))
