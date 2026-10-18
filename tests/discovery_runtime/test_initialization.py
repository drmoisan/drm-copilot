"""Verify caller-owned drafts and complete guarded initialization in memory."""

from __future__ import annotations

from dataclasses import replace
from typing import TYPE_CHECKING, cast

import pytest
from drm_copilot_discovery.init_flow import (
    commit_initialization,
    initialize_workspace,
    plan_initialization,
)
from drm_copilot_discovery.init_projection import (
    InitializationRequest,
    InitializationTemplates,
    profile_proposal,
    require_compatible,
)
from drm_copilot_discovery.models import JsonObject
from drm_copilot_discovery.profile_v2 import ProfileV2
from drm_copilot_discovery.snapshot import repository_pins
from drm_copilot_discovery.validation import validate_snapshot

from tests.discovery_runtime.initialization_test_support import (
    InitializationCase,
    MemoryRepository,
    request_for,
)
from tests.discovery_runtime.initialization_test_support import (
    initialization_catalog as initialization_catalog,
)
from tests.discovery_runtime.initialization_test_support import (
    initialization_templates as initialization_templates,
)

if TYPE_CHECKING:
    from drm_copilot_discovery.catalog import SchemaCatalog
    from drm_copilot_discovery.profile_models import ArtifactKey, SystemRole


@pytest.mark.parametrize("role", ["legacy-source", "modernization-target", "combined"])
def test_each_role_projects_a_complete_honest_structural_draft(
    initialization_catalog: SchemaCatalog,
    initialization_templates: InitializationTemplates,
    role: SystemRole,
) -> None:
    """
    Validate exact role-specific file sets and pins without fabricated completion.
    """
    case = InitializationCase(initialization_catalog)
    request = request_for(role)

    plan = plan_initialization(request, io=case.io, templates=initialization_templates)
    snapshot = plan.mutation.prospective
    paths = request.artifact_paths()
    expected = {
        str(paths[key])
        for key in (
            "profile",
            "scope",
            "coverage_ledger",
            "unspecified_behaviors",
            "product_decisions",
        )
    }
    if role != "legacy-source":
        expected.add(str(paths["parity_matrix"]))
    assert {item.path for item in snapshot.manifest.files} == expected
    assert len(expected) == (5 if role == "legacy-source" else 6)
    assert snapshot.profile.repository.revision is None
    assert snapshot.profile.profile_state == "draft"
    assert validate_snapshot(snapshot, mode="structural").ok
    assert not validate_snapshot(snapshot, mode="discovery-complete").ok
    assert snapshot.profile.system.role == role
    source, target = repository_pins(snapshot.profile)
    assert tuple(pin.id for pin in source) == (
        () if role == "modernization-target" else (request.repository_id,)
    )
    assert tuple(pin.id for pin in target) == (
        () if role == "legacy-source" else (request.repository_id,)
    )
    assert all(pin.revision is None for pin in (*source, *target))
    assert len(plan.directories) == 9
    assert all(
        plan.capture.proposal_base.inspect(path).kind == "directory"
        for path in plan.directories
    )
    assert case.disk.store.files == {} and case.revocations == 0


def test_first_combined_initialization_publishes_parity_through_real_writer(
    initialization_catalog: SchemaCatalog,
    initialization_templates: InitializationTemplates,
) -> None:
    """Publish the complete combined draft and release every native memory handle."""
    case = InitializationCase(initialization_catalog)
    request = request_for("combined")
    result = initialize_workspace(
        request, io=case.io, templates=initialization_templates
    )
    assert result.ok, result.error
    assert all(item.status in {"created", "skipped"} for item in result.outputs)
    assert (
        len(case.disk.store.files) == 6
        and str(request.artifact_paths()["parity_matrix"]) in case.disk.store.files
    )
    assert case.disk.held == 0 and not case.disk.locked
    assert all(
        case.disk.store.metadata(item.path).kind == "directory"
        for item in result.outputs
        if item.kind == "directory"
    )
    assert not any(
        "activation" in path or "receipt" in path for path in case.disk.store.files
    )


def test_dry_run_is_repeatable_and_retains_exact_physical_absence(
    initialization_catalog: SchemaCatalog,
    initialization_templates: InitializationTemplates,
) -> None:
    """
    A virtual profile validates a proposal but cannot become a physical observation.
    """
    case = InitializationCase(initialization_catalog)
    before = dict(case.disk.store.metadata.entries)
    plan = plan_initialization(
        request_for(), io=case.io, templates=initialization_templates
    )

    first = commit_initialization(plan, io=case.io, dry_run=True)
    second = commit_initialization(plan, io=case.io, dry_run=True)

    assert first == second and first.ok
    assert case.disk.store.files == {} and case.revocations == 0
    assert case.disk.store.metadata.entries == before
    assert plan.capture.profile_missing and plan.capture.physical_files == ()
    profile_path = plan.capture.proposal_base.snapshot.profile.artifacts["profile"]
    assert dict(plan.capture.physical_metadata)[profile_path].kind == "missing"
    assert plan.capture.proposal_base.inspect(profile_path).kind == "file"


@pytest.mark.parametrize(
    "field,value",
    [
        ("system_id", "Invalid ID"),
        ("system_name", " "),
        ("role", "invalid"),
        ("repository_id", "../invalid"),
        ("production_roots", ()),
        ("artifact_root", "../invalid"),
        ("artifact_overrides", (("scope", "docs/a"), ("scope", "docs/b"))),
    ],
)
def test_request_rejects_ambiguous_configuration(field: str, value: object) -> None:
    """Malformed consumer configuration fails before any workspace I/O."""
    arguments = {field: value}
    with pytest.raises(ValueError):
        replace(request_for(), **arguments)


@pytest.mark.parametrize("key", ["root", "unknown"])
def test_only_named_artifact_paths_may_be_overridden(key: str) -> None:
    """Root selection has one explicit field and unknown output categories fail."""
    request = replace(
        request_for(), artifact_overrides=((cast("ArtifactKey", key), "docs/new"),)
    )
    with pytest.raises(ValueError, match="Override only named"):
        request.artifact_paths()


def test_explicit_draft_and_custom_paths_preserve_caller_values(
    initialization_catalog: SchemaCatalog,
    initialization_templates: InitializationTemplates,
) -> None:
    """Empty source roots require explicit draft mode; typed slots escape user text."""
    request = InitializationRequest(
        system_id="draft-system",
        system_name='Quoted "name"\nnext',
        role="combined",
        repository_id="draft-repository",
        draft_configuration=True,
        artifact_root="notes/discovery",
        artifact_overrides=(("scope", "notes/custom/scope.yaml"),),
    )
    raw = profile_proposal(
        request,
        templates=initialization_templates,
        catalog=initialization_catalog,
        revision=None,
    )
    profile = ProfileV2(raw, catalog=initialization_catalog)
    require_compatible(request, profile)
    assert profile.system.name == request.system_name
    assert profile.production_roots == () and profile.repository.revision is None
    assert profile.documentation_roots == ("notes/discovery",)
    assert profile.artifacts["scope"] == "notes/custom/scope.yaml"
    assert profile.required_modes == ("online",)
    assert raw == profile_proposal(
        request,
        templates=initialization_templates,
        catalog=initialization_catalog,
        revision=None,
    )


@pytest.mark.parametrize(
    "field,value",
    [
        ("system_name", "different"),
        ("production_roots", ("different",)),
        ("test_roots", ("different",)),
        ("documentation_roots", ("different",)),
        ("artifact_overrides", (("scope", "docs/different.yaml"),)),
    ],
)
def test_existing_profile_conflicts_are_explicit(
    initialization_catalog: SchemaCatalog,
    initialization_templates: InitializationTemplates,
    field: str,
    value: object,
) -> None:
    """Compatibility never silently rewrites requested identity or root bindings."""
    request = request_for()
    raw = profile_proposal(
        request,
        templates=initialization_templates,
        catalog=initialization_catalog,
        revision=None,
    )
    profile = ProfileV2(raw, catalog=initialization_catalog)
    with pytest.raises(ValueError, match="conflicts"):
        require_compatible(replace(request, **{field: value}), profile)


def test_template_loader_requires_complete_valid_structures(
    initialization_templates: InitializationTemplates,
) -> None:
    """Malformed or missing templates and unresolved slots remain actionable errors."""
    with pytest.raises(ValueError, match="all six distinct"):
        InitializationTemplates(documents=initialization_templates.documents[:-1])
    with pytest.raises(ValueError, match="Invalid initialization template"):
        InitializationTemplates.load(read=lambda path: b"[invalid")
    with pytest.raises(ValueError, match="Missing initialization template value"):
        initialization_templates.render("scope.yaml", {})


def test_template_cannot_claim_a_configured_profile(
    initialization_catalog: SchemaCatalog,
    initialization_templates: InitializationTemplates,
) -> None:
    """
    Even schema-valid configured profile templates cannot bypass draft initialization.
    """
    documents = dict(initialization_templates.documents)
    value = dict(documents["domain-profile.yaml"])
    value["profile_state"] = "configured"
    documents["domain-profile.yaml"] = JsonObject(tuple(value.items()))
    templates = InitializationTemplates(documents=tuple(documents.items()))
    with pytest.raises(ValueError, match="honest draft"):
        profile_proposal(
            request_for(),
            templates=templates,
            catalog=initialization_catalog,
            revision="a" * 40,
        )


@pytest.mark.parametrize("available", [False, True])
def test_local_repository_identity_is_observed_or_left_null(
    initialization_catalog: SchemaCatalog,
    initialization_templates: InitializationTemplates,
    available: bool,
) -> None:
    """An unavailable local Git adapter never produces a fabricated revision."""
    case = InitializationCase(initialization_catalog)
    repository = MemoryRepository(available=available)
    case.io.repository = repository
    plan = plan_initialization(
        request_for(), io=case.io, templates=initialization_templates
    )
    profile = plan.capture.proposal_base.snapshot.profile
    assert profile.repository.revision == ("a" * 40 if available else None)
    assert profile.profile_state == "draft" and case.disk.store.files == {}


def test_wrong_local_git_repository_identity_is_rejected(
    initialization_catalog: SchemaCatalog,
    initialization_templates: InitializationTemplates,
) -> None:
    """A local adapter cannot silently bind the request to a different repository."""
    case = InitializationCase(initialization_catalog)
    repository = MemoryRepository()
    repository.checkout = replace(repository.checkout, id="other")
    case.io.repository = repository
    with pytest.raises(ValueError, match="Local Git identity differs"):
        plan_initialization(
            request_for(), io=case.io, templates=initialization_templates
        )
    assert case.disk.store.files == {}
