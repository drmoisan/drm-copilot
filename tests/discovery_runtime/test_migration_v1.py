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
    from drm_copilot_discovery.mutation_plan import CapturedWorkspace

ROOT = Path(__file__).resolve().parents[2]
ENVIRONMENT = draft_object(
    id="legacy-environment",
    platform="desktop",
    operating_mode="online",
    client_id=None,
    extensions=JsonObject(()),
)


def source_for(kind: str, **changes: object) -> MigrationSource:
    """Read immutable historical examples; callers receive detached source values."""
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
    """Supply explicit context without manufacturing observations or source pins."""
    selected = sources or tuple(source_for(kind) for kind in V1_KINDS)
    return MigrationRequest(
        initialization=replace(
            request_for("combined"), documentation_roots=("legacy",)
        ),
        sources=selected,
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
    """Compose one real immutable plan; mutable unit dependencies remain per test."""
    case = InitializationCase(initialization_catalog)
    request = migration_request()
    for source in request.sources:
        case.disk.store.put(source.path, source.content)
    return migration_v1.plan_migration(
        request, io=case.io, templates=initialization_templates
    )


def source_capture(
    plan: MigrationPlan, sources: tuple[MigrationSource, ...]
) -> CapturedWorkspace:
    """Substitute captured source bytes for direct pure boundary tests only."""
    baseline = plan.mutation.baseline
    files = tuple(
        item
        for item in baseline.snapshot.manifest.files
        if not item.path.startswith("legacy/")
    )
    manifest = replace(
        baseline.snapshot.manifest,
        files=files
        + tuple(
            SnapshotFile(path=item.path, content=item.content, category="documentation")
            for item in sources
        ),
    )
    return replace(baseline, snapshot=replace(baseline.snapshot, manifest=manifest))


def test_all_kinds_have_exact_mapping_and_honest_projected_graph(
    migration_plan: MigrationPlan,
) -> None:
    """Every frozen kind maps exact bytes without completion claims."""
    assert migration_plan.mutation.validation.ok
    report = migration_plan.report
    assert report["activation_switched"] is False and report["result"] == "pass"
    mappings = cast("tuple[JsonObject, ...]", report["mappings"])
    assert len(mappings) == len(V1_KINDS)
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
    """Request construction sorts inputs and detaches selectors deterministically."""
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
    """Captured input identity, exact schema and cross-kind uniqueness are mandatory."""
    source = source_for("feature-contract")
    captured = (source,)
    requested = source
    code = "MIGRATION_SOURCE"
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
    """Exercise public proposals while isolating previously proved graph rebuilding."""
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
    """YAML input preserves its checksum and explicit legacy ID translation."""
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
    """Isolate the commit coordinator from already-proved graph/native algorithms."""
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


def test_dry_run_never_bootstraps_or_revokes(
    monkeypatch: MonkeyPatch, migration_plan: MigrationPlan
) -> None:
    """Reconstruction completes but dry-run does not touch publication capabilities."""
    case = unit_commit_case(monkeypatch, migration_plan)

    def forbidden(*args: object, **kwargs: object) -> None:
        pytest.fail("dry-run bootstrap")

    monkeypatch.setattr(case.io, "bootstrap", forbidden)
    result = migration_v1.commit_migration(migration_plan, io=case.io, dry_run=True)
    assert result.ok and result.report["dry_run"] is True
    assert not case.disk.store.files and case.revocations == 0
    assert all(
        item["status"] == "planned"
        for item in cast("tuple[JsonObject, ...]", result.report["mappings"])
    )


@pytest.mark.parametrize("success", [True, False])
def test_returned_outcome_tracks_actual_partial_publication(
    monkeypatch: MonkeyPatch, migration_plan: MigrationPlan, success: bool
) -> None:
    """A persisted planned mapping never becomes a false completion claim on failure."""
    case = unit_commit_case(monkeypatch, migration_plan)
    mapping = cast("tuple[JsonObject, ...]", migration_plan.report["mappings"])[0]
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
    monkeypatch.setattr(migration_v1, "commit_mutation", constant(publication))
    result = migration_v1.commit_migration(migration_plan, io=case.io)
    assert result.ok is success and result.publication is publication
    assert result.bootstrap_created == ("new-root",)
    assert result.uncertain_paths == publication.uncertain_paths
    assert result.report["result"] == ("pass" if success else "fail")
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
    "failure", ["reconstruct", "bootstrap", "physical", "projection", "revocation"]
)
def test_commit_failures_preserve_truth_and_do_not_activate(
    monkeypatch: MonkeyPatch, migration_plan: MigrationPlan, failure: str
) -> None:
    """Each coordinator boundary returns failure without erasing prior effects."""
    case = unit_commit_case(monkeypatch, migration_plan)
    changed = replace(
        migration_plan.mutation, prospective=migration_plan.mutation.baseline.snapshot
    )
    if failure in {"reconstruct", "revocation"}:
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
            raise OSError("revocation blocked")

        monkeypatch.setattr(case.io, "invalidate_authority", broken)
    result = migration_v1.commit_migration(migration_plan, io=case.io)
    assert not result.ok and result.error
    assert result.report["activation_switched"] is False
    assert case.disk.store.files == {}
    if failure == "bootstrap":
        assert result.bootstrap_created == ("new-root",) and result.uncertain_paths == (
            "uncertain",
        )
    if failure == "revocation":
        assert "revocation blocked" in result.error
