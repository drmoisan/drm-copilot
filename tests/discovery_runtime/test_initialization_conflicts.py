"""Exercise prewrite conflicts, bootstrap races and bounded failures with memory I/O."""

from __future__ import annotations

from dataclasses import replace
from typing import TYPE_CHECKING, cast

import pytest
from drm_copilot_discovery.init_flow import (
    commit_initialization,
    initialize_workspace,
)
from drm_copilot_discovery.init_io import BootstrapResult
from drm_copilot_discovery.init_projection import (
    InitializationConflict,
    ProposalInputs,
)

from tests.discovery_runtime.initialization_test_support import (
    InitializationCase,
    bootstrap_capture,
    request_for,
    seed_proposal,
)
from tests.discovery_runtime.initialization_test_support import (
    initialization_catalog as initialization_catalog,
)
from tests.discovery_runtime.initialization_test_support import (
    initialization_plan as initialization_plan,
)
from tests.discovery_runtime.initialization_test_support import (
    initialization_templates as initialization_templates,
)
from tests.discovery_runtime.mutation_test_support import constant

if TYPE_CHECKING:
    from drm_copilot_discovery.catalog import SchemaCatalog
    from drm_copilot_discovery.init_flow import InitializationPlan
    from drm_copilot_discovery.init_projection import (
        InitializationCapture,
        InitializationTemplates,
    )
    from drm_copilot_discovery.profile_models import ArtifactKey


@pytest.mark.parametrize(
    "conflict",
    [
        "profile",
        "scope",
        "coverage_ledger",
        "unspecified_behaviors",
        "product_decisions",
        "parity_matrix",
        "identity",
        "directory",
        "unknown-artifact",
    ],
)
def test_invalid_or_incompatible_existing_content_aborts_before_any_write(
    initialization_catalog: SchemaCatalog,
    initialization_plan: InitializationPlan,
    initialization_templates: InitializationTemplates,
    conflict: str,
) -> None:
    """
    Existing bad bytes remain visible; no profile/directory is created around them.
    """
    case, plan = InitializationCase(initialization_catalog), initialization_plan
    profile = plan.capture.proposal_base.snapshot.profile
    request = request_for()
    if conflict == "profile":
        case.disk.store.put(profile.artifacts["profile"], b"invalid: true")
    elif conflict in {
        "scope",
        "coverage_ledger",
        "unspecified_behaviors",
        "product_decisions",
        "parity_matrix",
    }:
        case.disk.store.put(
            profile.artifacts[cast("ArtifactKey", conflict)], b"invalid: true"
        )
    elif conflict == "directory":
        case.disk.store.put(profile.artifacts["reports"], b"occupied directory")
    elif conflict == "unknown-artifact":
        case.disk.store.put(
            profile.artifacts["feature_contracts"] + "/wrong.yaml", b"invalid: true"
        )
    else:
        case.disk.store.put(profile.artifacts["profile"], plan.profile_bytes)
        request = replace(request, system_name="Different consumer")
    before = (dict(case.disk.store.files), dict(case.disk.store.metadata.entries))

    with pytest.raises(InitializationConflict) as caught:
        initialize_workspace(
            request, io=case.io, templates=initialization_templates, force=True
        )

    assert caught.value.outputs and caught.value.findings
    assert all(item.status == "conflict" for item in caught.value.outputs)
    if conflict in {
        "scope",
        "coverage_ledger",
        "unspecified_behaviors",
        "product_decisions",
        "parity_matrix",
    }:
        assert {item.path for item in caught.value.outputs} == {
            profile.artifacts[cast("ArtifactKey", conflict)]
        }
    assert (case.disk.store.files, case.disk.store.metadata.entries) == before
    assert case.revocations == 0 and case.disk.held == 0


def test_partial_workspace_recovers_and_repeat_preserves_all_valid_bytes(
    initialization_catalog: SchemaCatalog,
    initialization_plan: InitializationPlan,
    initialization_templates: InitializationTemplates,
) -> None:
    """
    Rerun fills missing outputs, retaining compatible IDs, raw whitespace and unrelated
    docs.
    """
    case, plan = InitializationCase(initialization_catalog), initialization_plan
    profile = plan.capture.proposal_base.snapshot.profile
    scope = next(
        item.change
        for item in plan.mutation.writes
        if item.change.artifact_kind == "scope"
    )
    case.disk.store.put(profile.artifacts["profile"], plan.profile_bytes)
    case.disk.store.put(scope.path, b" \n" + scope.content)
    case.disk.store.put("docs/notes.txt", b"unrelated raw\r\nbytes")

    result = initialize_workspace(
        request_for(), io=case.io, templates=initialization_templates, force=True
    )

    assert result.ok, result.error
    assert result.notes and case.disk.store.files[scope.path] == b" \n" + scope.content
    assert case.disk.store.files["docs/notes.txt"] == b"unrelated raw\r\nbytes"
    before, revoked = dict(case.disk.store.files), case.revocations
    repeated = initialize_workspace(
        request_for(), io=case.io, templates=initialization_templates
    )
    assert repeated.ok and all(item.status == "skipped" for item in repeated.outputs)
    assert case.disk.store.files == before and case.revocations == revoked


@pytest.mark.parametrize("change", ["collision", "parent-identity", "source-byte"])
def test_stale_physical_inputs_invalidate_a_prepared_plan(
    initialization_catalog: SchemaCatalog,
    initialization_plan: InitializationPlan,
    change: str,
) -> None:
    """
    Virtual profile bytes never waive a real absence, identity or complete-input check.
    """
    case, plan = InitializationCase(initialization_catalog), initialization_plan
    path = plan.capture.proposal_base.snapshot.profile.artifacts["profile"]
    if change == "collision":
        case.disk.store.put(path, plan.profile_bytes)
    elif change == "parent-identity":
        old = case.disk.store.metadata.entries["docs"]
        case.disk.store.metadata.entries["docs"] = replace(old, identity="replaced")
    else:
        case.disk.store.put("application/changed.txt", b"new input")
    before = dict(case.disk.store.files)

    result = commit_initialization(plan, io=case.io)

    assert not result.ok and result.authority_invalidated
    assert case.disk.store.files == before and case.disk.held == 0


@pytest.mark.parametrize(
    "failure", ["profile-publish", "directory-open", "guard-busy", "revocation"]
)
def test_bootstrap_failures_report_partial_effects_and_release_handles(
    initialization_catalog: SchemaCatalog,
    initialization_plan: InitializationPlan,
    failure: str,
) -> None:
    """Every guarded failure stops further creation without silently rolling back."""
    case, plan = InitializationCase(initialization_catalog), initialization_plan
    if failure == "profile-publish":
        case.disk.fail_publish = True
    elif failure == "directory-open":

        def fail_open(path: str) -> None:
            """Fail after a configured directory is exclusively created."""
            if path.endswith("/acceptance"):
                raise OSError("directory open failed")

        case.disk.before_open = fail_open
    elif failure == "guard-busy":
        case.disk.locked = True
    else:

        def fail_revoke() -> None:
            """Fail protected-state invalidation before any workspace write."""
            raise OSError("revocation failed")

        case.io.invalidate_authority = fail_revoke

    result = case.io.bootstrap(
        plan.capture, profile_bytes=plan.profile_bytes, directories=plan.directories
    )

    assert not result.ok and result.error
    assert case.disk.held == 0
    assert not any(".drm-mutation-" in path for path in case.disk.store.files)
    if failure == "directory-open":
        assert result.created and result.uncertain
        assert any(path.endswith("domain-profile.yaml") for path in result.created)
    elif failure == "profile-publish":
        assert result.uncertain and case.disk.store.files == {}
    elif failure == "revocation":
        assert not result.authority_invalidated and case.disk.store.files == {}
    else:
        assert result.authority_invalidated and case.disk.store.files == {}


def test_bootstrap_rejects_unconfigured_directories(
    initialization_catalog: SchemaCatalog,
    initialization_plan: InitializationPlan,
) -> None:
    """Root bootstrap cannot be used as a blanket directory-creation capability."""
    case, plan = InitializationCase(initialization_catalog), initialization_plan
    with pytest.raises(ValueError, match="exactly match"):
        case.io.bootstrap(
            plan.capture, profile_bytes=plan.profile_bytes, directories=("outside",)
        )
    assert case.disk.store.files == {} and case.revocations == 0


@pytest.mark.parametrize("path", [".", "docs"])
def test_opened_directory_identity_must_match_retained_parent_stamp(
    initialization_catalog: SchemaCatalog,
    initialization_plan: InitializationPlan,
    path: str,
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """
    A parent swap between inspection and open is rejected before creating descendants.
    """
    case, plan = InitializationCase(initialization_catalog), initialization_plan
    monkeypatch.setattr(case.io, "capture", constant(plan.capture))

    def swap(opened: str) -> None:
        """Replace the opened directory identity without changing its spelling."""
        if opened == path:
            old = case.disk.store.metadata.entries[path]
            case.disk.store.metadata.entries[path] = replace(old, identity="substitute")

    case.disk.before_open = swap
    result = case.io.bootstrap(
        plan.capture, profile_bytes=plan.profile_bytes, directories=plan.directories
    )
    assert not result.ok and "identity changed" in str(result.error)
    assert case.disk.held == 0 and case.disk.store.files == {}


def test_metadata_changes_after_capture_are_detected_by_physical_reader(
    initialization_catalog: SchemaCatalog,
    initialization_plan: InitializationPlan,
) -> None:
    """Normalization of child order never permits a changed physical identity."""
    case, plan = InitializationCase(initialization_catalog), initialization_plan
    inputs = ProposalInputs(
        case.io, "docs/migration/discovery/domain-profile.yaml", plan.profile_bytes, ()
    )
    inputs.physical("docs")
    old = case.disk.store.metadata.entries["docs"]
    case.disk.store.metadata.entries["docs"] = replace(old, identity="replacement")
    with pytest.raises(OSError, match="metadata changed"):
        inputs.physical("docs")


def test_virtual_reads_are_bounded_and_do_not_hide_changed_physical_bytes(
    initialization_catalog: SchemaCatalog,
    initialization_plan: InitializationPlan,
) -> None:
    """
    Synthetic bytes honor limits and existing input bytes retain their original value.
    """
    case, plan = InitializationCase(initialization_catalog), initialization_plan
    path = plan.capture.proposal_base.snapshot.profile.artifacts["profile"]
    inputs = ProposalInputs(case.io, path, plan.profile_bytes, ())
    with pytest.raises(OSError, match="read limit"):
        inputs.read(path, limit=1)
    case.disk.store.put("application/code.txt", b"before")
    assert inputs.read("application/code.txt", limit=10) == b"before"
    case.disk.store.files["application/code.txt"] = b"after"
    with pytest.raises(OSError, match="bytes changed"):
        inputs.read("application/code.txt", limit=10)


def test_changed_parent_metadata_before_open_is_rejected(
    initialization_catalog: SchemaCatalog,
    initialization_plan: InitializationPlan,
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """A substitution after resolution is rejected before opening a descendant."""
    case, plan = InitializationCase(initialization_catalog), initialization_plan
    monkeypatch.setattr(case.io, "capture", constant(plan.capture))

    def swap(path: str) -> None:
        """Change a child after the policy has captured its original stamp."""
        if path == ".":
            old = case.disk.store.metadata.entries["docs"]
            case.disk.store.metadata.entries["docs"] = replace(old, identity="changed")

    case.disk.before_open = swap
    result = case.io.bootstrap(
        plan.capture, profile_bytes=plan.profile_bytes, directories=plan.directories
    )
    assert not result.ok and "parent changed" in str(result.error)
    assert case.disk.held == 0


def test_existing_graph_preservation_without_writes(
    initialization_catalog: SchemaCatalog,
    initialization_plan: InitializationPlan,
    initialization_templates: InitializationTemplates,
) -> None:
    """Same-content initialization skips even when force is passed."""
    case = InitializationCase(initialization_catalog)
    seed_proposal(case, initialization_plan)
    before = (dict(case.disk.store.files), dict(case.disk.store.metadata.entries))
    result = initialize_workspace(
        request_for(), io=case.io, templates=initialization_templates, force=True
    )
    assert result.ok and all(item.status == "skipped" for item in result.outputs)
    assert (case.disk.store.files, case.disk.store.metadata.entries) == before
    assert case.revocations == 0


@pytest.mark.parametrize(
    "change", ["none", "identity", "bytes", "lost-path", "kind", "namespace"]
)
def test_new_directory_identity_is_bound_through_guarded_postcapture(
    initialization_catalog: SchemaCatalog,
    initialization_plan: InitializationPlan,
    monkeypatch: pytest.MonkeyPatch,
    change: str,
) -> None:
    """Postcapture cannot adopt a replacement of a newly opened empty directory."""
    case, plan = InitializationCase(initialization_catalog), initialization_plan
    path = plan.capture.proposal_base.snapshot.profile.artifacts["evidence"]

    def capture(**kwargs: object) -> InitializationCapture:
        """Supply stable graph bytes while exercising real guard and directory I/O."""
        del kwargs
        if case.disk.store.metadata(path).kind == "missing":
            return plan.capture
        assert case.disk.held > 0 and case.disk.locked
        if change == "identity":
            old = case.disk.store.metadata.entries[path]
            case.disk.store.metadata.entries[path] = replace(
                old, identity="replaced-after-open"
            )
        captured = bootstrap_capture(case, plan)
        metadata = dict(captured.physical_metadata)
        profile_path = plan.capture.proposal_base.snapshot.profile.artifacts["profile"]
        if change == "bytes":
            return replace(captured, physical_files=((profile_path, b"changed"),))
        if change == "lost-path":
            metadata.pop("verification")
        elif change == "kind":
            metadata[profile_path] = replace(metadata[profile_path], kind="directory")
        elif change == "namespace":
            metadata["application"] = replace(
                metadata["application"], children=("unexpected",)
            )
        return replace(captured, physical_metadata=tuple(metadata.items()))

    monkeypatch.setattr(case.io, "capture", capture)
    result = case.io.bootstrap(
        plan.capture, profile_bytes=plan.profile_bytes, directories=plan.directories
    )
    assert result.ok is (change == "none"), result.error
    assert result.authority_invalidated and case.disk.held == 0
    if change != "none":
        assert result.physical is None and result.error
    else:
        assert result.physical is not None
        assert (
            dict(result.physical.metadata)[path].identity
            == case.disk.store.metadata(path).identity
        )


def test_bootstrap_handoff_rejects_same_bytes_with_changed_parent_identity(
    initialization_catalog: SchemaCatalog,
    initialization_plan: InitializationPlan,
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """The ordinary mutation planner never receives an adopted concurrent parent."""
    case, plan = InitializationCase(initialization_catalog), initialization_plan
    accepted = plan.capture.proposal_base
    metadata = dict(accepted.metadata)
    metadata["docs"] = replace(metadata["docs"], identity="different-parent")
    changed = replace(accepted, metadata=tuple(metadata.items()))
    monkeypatch.setattr(
        "drm_copilot_discovery.init_flow.plan_initialization", constant(plan)
    )
    monkeypatch.setattr(
        case.io,
        "bootstrap",
        constant(
            BootstrapResult(
                ok=True,
                created=(),
                uncertain=(),
                authority_invalidated=True,
                physical=accepted,
            )
        ),
    )
    monkeypatch.setattr(case.io, "physical_capture", constant(changed))

    def prohibit(*args: object, **kwargs: object) -> None:
        """Fail if unsafe freshness reaches the ordinary planner."""
        raise AssertionError("Changed parent reached artifact planning")

    monkeypatch.setattr("drm_copilot_discovery.init_flow.plan_mutation", prohibit)
    result = commit_initialization(plan, io=case.io)
    assert not result.ok and result.authority_invalidated
    assert "Physical bootstrap inputs differ" in str(result.error)
    assert case.disk.store.files == {}


def test_concurrent_profile_creation_has_typed_conflict_path(
    initialization_catalog: SchemaCatalog,
    initialization_plan: InitializationPlan,
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """A cooperative bootstrap collision retains a path without parsing prose."""
    case, plan = InitializationCase(initialization_catalog), initialization_plan
    path = plan.capture.proposal_base.snapshot.profile.artifacts["profile"]
    case.disk.store.put(path, plan.profile_bytes)
    # Preserve every prior observation except the concurrent profile appearance.
    changed = replace(
        plan.capture,
        physical_metadata=tuple(
            (key, case.disk.store.metadata(key) if key == path else value)
            for key, value in plan.capture.physical_metadata
        ),
    )
    monkeypatch.setattr(case.io, "capture", constant(changed))
    result = case.io.bootstrap(
        plan.capture, profile_bytes=plan.profile_bytes, directories=plan.directories
    )
    assert not result.ok and result.conflicts == (path,)
    assert result.created == () and case.disk.store.files == {path: plan.profile_bytes}
