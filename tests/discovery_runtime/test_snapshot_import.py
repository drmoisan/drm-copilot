"""Keep transport mutation forwarding and guarded validation isolated in memory."""

from __future__ import annotations

import json
from dataclasses import replace
from typing import TYPE_CHECKING, cast

import pytest
from drm_copilot_discovery import mutation_io, source_snapshots
from drm_copilot_discovery.models import ParseLimits, to_plain_value
from drm_copilot_discovery.mutation_io import (
    GuardedMutationWriter,
    MutationResult,
    commit_mutation,
)
from drm_copilot_discovery.mutation_plan import (
    MutationChange,
    MutationError,
    MutationPlan,
    PlannedWrite,
    plan_mutation,
)
from drm_copilot_discovery.snapshot import SnapshotFile
from drm_copilot_discovery.source_snapshots import prepare_snapshot_import
from drm_copilot_discovery.transport_manifest import transport_digest

from tests.discovery_runtime.mutation_test_support import grants_for
from tests.discovery_runtime.mutation_test_support import (
    mutation_catalog as mutation_catalog,
)
from tests.discovery_runtime.source_snapshot_test_support import (
    RecordingPrimitives,
    export_request,
    import_case,
    isolated_plan,
    with_files,
)
from tests.discovery_runtime.source_snapshot_test_support import (
    source_capture as source_capture,
)
from tests.discovery_runtime.source_snapshot_test_support import (
    target_capture as target_capture,
)
from tests.schemas.discovery.v2_schema_test_support import as_object

if TYPE_CHECKING:

    from drm_copilot_discovery.agent_output import InvocationContext
    from drm_copilot_discovery.catalog import SchemaCatalog
    from drm_copilot_discovery.mutation_io import MutationWriter
    from drm_copilot_discovery.mutation_plan import CapturedWorkspace
    from drm_copilot_discovery.path_models import WriteGrant
    from drm_copilot_discovery.source_snapshots import SnapshotImport
    from drm_copilot_discovery.transport_manifest import TransportRoute


def test_transport_rejects_specialist_invocation_before_projection(
    mutation_catalog: SchemaCatalog,
) -> None:
    """A caller cannot obtain this root route by supplying a specialist context."""
    plan = isolated_plan(mutation_catalog)
    with pytest.raises(MutationError, match="root-only"):
        plan_mutation(
            plan.baseline,
            tuple(item.change for item in plan.writes),
            grants=plan.grants,
            invocation=cast("InvocationContext", object()),
            transport=plan.transport,
        )


@pytest.mark.parametrize("fault", ["grant", "extra-grant", "bytes", "existing"])
def test_import_rejects_changed_members_or_incomplete_grants_before_graph_work(
    fault: str, mutation_catalog: SchemaCatalog
) -> None:
    """Immutable routes cannot overwrite or widen a declared member set."""
    plan = isolated_plan(mutation_catalog)
    changes = tuple(item.change for item in plan.writes)
    grants = plan.grants
    baseline = plan.baseline
    if fault == "grant":
        grants = grants[:-1]
    elif fault == "extra-grant":
        grants += (replace(grants[0], path=grants[0].path + ".extra"),)
    elif fault == "bytes":
        changes = (replace(changes[0], content=b"changed"), *changes[1:])
    else:
        prior = SnapshotFile(
            path=changes[0].path, content=b"existing", category="artifact"
        )
        baseline = replace(
            baseline,
            snapshot=replace(
                baseline.snapshot,
                manifest=replace(
                    baseline.snapshot.manifest,
                    files=baseline.snapshot.manifest.files + (prior,),
                ),
            ),
        )
        changes = (replace(changes[0], expected_sha256=prior.sha256), *changes[1:])
    with pytest.raises(
        ValueError, match="complete transport|checksum|cannot be replaced"
    ):
        plan_mutation(baseline, changes, grants=grants, transport=plan.transport)


def test_commit_reconstructs_transport_and_dry_run_performs_no_publication(
    monkeypatch: pytest.MonkeyPatch, mutation_catalog: SchemaCatalog
) -> None:
    """The commit orchestrator forwards the exact route, grants and captured input."""
    plan = isolated_plan(mutation_catalog)
    seen: list[TransportRoute | None] = []

    def reconstruct(
        baseline: CapturedWorkspace,
        changes: tuple[MutationChange, ...],
        *,
        grants: tuple[WriteGrant, ...],
        invocation: InvocationContext | None,
        transport: TransportRoute | None,
    ) -> MutationPlan:
        assert baseline is plan.baseline and changes == tuple(
            item.change for item in plan.writes
        )
        assert grants == plan.grants and invocation is None
        seen.append(transport)
        return plan

    monkeypatch.setattr(mutation_io, "plan_mutation", reconstruct)
    primitive = RecordingPrimitives()
    revoked: list[bool] = []
    writer = GuardedMutationWriter(
        capture=lambda: plan.baseline,
        invalidate_authority=lambda: revoked.append(True),
        primitives=primitive,
    )
    first = commit_mutation(plan, writer=writer, dry_run=True)
    second = commit_mutation(plan, writer=writer, dry_run=True)
    assert first == second and first.ok and seen == [plan.transport, plan.transport]
    assert not primitive.calls and not revoked
    assert all(item.status == "planned" for item in first.artifacts)
    with pytest.raises(MutationError, match="reconstruction"):
        commit_mutation(
            replace(
                plan, writes=(replace(plan.writes[0], transport=None), *plan.writes[1:])
            ),
            writer=writer,
            dry_run=True,
        )


@pytest.mark.parametrize("fault", [None, "route", "bytes", "prior"])
def test_guarded_writer_revalidates_route_and_exact_bytes_before_create(
    fault: str | None, monkeypatch: pytest.MonkeyPatch, mutation_catalog: SchemaCatalog
) -> None:
    """The guarded boundary independently rejects tampering without replacing files."""
    plan = isolated_plan(mutation_catalog)
    write = plan.writes[0]
    baseline = plan.baseline
    if fault == "route":
        assert write.transport is not None
        write = replace(
            write,
            transport=replace(write.transport, members=write.transport.members[:-1]),
        )
    elif fault == "bytes":
        write = replace(write, change=replace(write.change, content=b"changed"))
    elif fault == "prior":
        prior = SnapshotFile(
            path=write.change.path, content=write.change.content, category="artifact"
        )
        baseline = replace(
            baseline,
            snapshot=replace(
                baseline.snapshot,
                manifest=replace(
                    baseline.snapshot.manifest,
                    files=baseline.snapshot.manifest.files + (prior,),
                ),
            ),
        )
        write = replace(
            write, change=replace(write.change, expected_sha256=prior.sha256)
        )
    postchecks: list[PlannedWrite] = []

    def postcheck(
        expected: CapturedWorkspace, current: CapturedWorkspace, item: PlannedWrite
    ) -> None:
        assert expected is baseline and current is baseline
        postchecks.append(item)

    monkeypatch.setattr(mutation_io, "_after_write", postcheck)
    primitive = RecordingPrimitives()
    writer = GuardedMutationWriter(
        capture=lambda: baseline,
        invalidate_authority=lambda: None,
        primitives=primitive,
    )
    if fault:
        with pytest.raises(ValueError, match="manifest|checksum|absence"):
            writer.atomic_write(write, expected=baseline)
        assert not primitive.calls and not postchecks
    else:
        writer.atomic_write(write, expected=baseline)
        assert primitive.calls == [(write.target, write.change.content)]
        assert postchecks == [write]


def test_postcheck_keeps_transport_route_for_final_path_validation(
    monkeypatch: pytest.MonkeyPatch, mutation_catalog: SchemaCatalog
) -> None:
    """The postcheck delegates graph projection but retains exact transport grants."""
    plan = isolated_plan(mutation_catalog)
    write = plan.writes[0]

    def projected(
        baseline: CapturedWorkspace, changes: tuple[MutationChange, ...]
    ) -> object:
        assert baseline is plan.baseline and changes == (write.change,)
        return baseline.snapshot

    monkeypatch.setattr(mutation_io, "project_snapshot", projected)
    primitive = RecordingPrimitives()
    writer = GuardedMutationWriter(
        capture=lambda: plan.baseline,
        invalidate_authority=lambda: None,
        primitives=primitive,
    )
    writer.atomic_write(write, expected=plan.baseline)
    assert primitive.calls == [(write.target, write.change.content)]
    assert write.transport is not None
    write.transport.revalidate(catalog=mutation_catalog, limits=ParseLimits())


def test_import_verifies_new_local_bundle_without_changing_inputs_or_clients(
    target_capture: tuple[CapturedWorkspace, SnapshotImport],
) -> None:
    """A new destination binds verified bytes and preserves both configured clients."""
    baseline, request = target_capture
    before = baseline.snapshot.sha256
    proposal = prepare_snapshot_import(baseline, request)
    transport = as_object(to_plain_value(proposal.route.document["transport"]))
    assert transport["verification_status"] == "verified"
    assert transport["verified_at"] == request.verified_at
    assert proposal.route.source == request.source
    assert len(proposal.changes) == 3 and len(baseline.snapshot.profile.clients) == 2
    assert proposal.route.manifest.path.endswith("/" + "a" * 40 + "/manifest.json")
    assert proposal.route.document["manifest_sha256"] == transport_digest(
        proposal.route.document
    )
    for member, change in zip(proposal.route.members, proposal.changes, strict=True):
        if member.origin is not None:
            assert (
                change.content
                == baseline.snapshot.file(
                    "docs/incoming/source/" + member.origin
                ).content
            )
    assert baseline.snapshot.sha256 == before
    assert all(item.expected_sha256 is None for item in proposal.changes)


@pytest.mark.parametrize(
    "fault",
    ["identity", "pin", "version", "digest", "bytes", "missing", "extra", "escape"],
)
def test_import_rejects_foreign_changed_incomplete_or_escaping_transport(
    target_capture: tuple[CapturedWorkspace, SnapshotImport],
    fault: str,
) -> None:
    """Captured staging data must match one complete immutable configured source."""
    baseline, request = target_capture
    files = baseline.snapshot.manifest.files
    if fault in {"identity", "pin"}:
        source = replace(
            request.source,
            **({"id": "foreign"} if fault == "identity" else {"revision": "c" * 40}),
        )
        request = replace(request, source=source)
    elif fault == "escape":
        request = replace(request, manifest_path="../manifest.json")
    elif fault == "extra":
        files += (
            SnapshotFile(
                path="docs/incoming/source/extra.bin",
                content=b"extra",
                category="source-snapshot",
            ),
        )
    else:
        chosen = next(
            item
            for item in files
            if item.path.startswith("docs/incoming/source/")
            and (item.path == request.manifest_path) == (fault in {"version", "digest"})
        )
        content = b"changed"
        if fault in {"version", "digest"}:
            document = as_object(json.loads(chosen.content))
            document["schema_version" if fault == "version" else "manifest_sha256"] = (
                "3.0.0" if fault == "version" else "0" * 64
            )
            content = json.dumps(document).encode()
        files = tuple(
            replace(item, content=content) if item == chosen else item
            for item in files
            if fault != "missing" or item != chosen
        )
    with pytest.raises(ValueError):
        prepare_snapshot_import(with_files(baseline, files), request)


def test_import_respects_custom_root_without_renaming_source_paths(
    source_capture: CapturedWorkspace,
    mutation_catalog: SchemaCatalog,
) -> None:
    """Configured destination roots preserve original paths inside the envelope."""
    exported = source_snapshots.prepare_snapshot_export(
        source_capture, export_request()
    )
    _, baseline, request = import_case(mutation_catalog, exported, custom=True)
    proposal = prepare_snapshot_import(baseline, request)
    assert all(item.path.startswith("docs/transport/") for item in proposal.changes)
    assert [item.origin for item in proposal.route.members] == [
        item.origin for item in exported.route.members
    ]


@pytest.mark.parametrize("operation", ["export", "import"])
def test_public_planner_forwards_exact_proposal_grants_and_invocation(
    operation: str,
    monkeypatch: pytest.MonkeyPatch,
    target_capture: tuple[CapturedWorkspace, SnapshotImport],
    source_capture: CapturedWorkspace,
    mutation_catalog: SchemaCatalog,
) -> None:
    """Planning uses the shared engine without altering captured authority inputs."""
    baseline, request = (
        target_capture if operation == "import" else (source_capture, export_request())
    )
    proposal = (
        source_snapshots.prepare_snapshot_import(
            baseline, cast("SnapshotImport", request)
        )
        if operation == "import"
        else source_snapshots.prepare_snapshot_export(baseline, export_request())
    )
    grants = grants_for(*proposal.changes)
    context = cast("InvocationContext", object())
    expected = isolated_plan(mutation_catalog)
    calls: list[object] = []

    def plan(
        actual: CapturedWorkspace, changes: object, **options: object
    ) -> MutationPlan:
        calls.append((actual, changes, options))
        return expected

    monkeypatch.setattr(source_snapshots, "plan_mutation", plan)
    actual = (
        source_snapshots.plan_snapshot_import(
            baseline, cast("SnapshotImport", request), grants=grants, invocation=context
        )
        if operation == "import"
        else source_snapshots.plan_snapshot_export(
            baseline, export_request(), grants=grants, invocation=context
        )
    )
    assert actual is expected
    assert calls == [
        (
            baseline,
            proposal.changes,
            dict(grants=grants, invocation=context, transport=proposal.route),
        )
    ]


@pytest.mark.parametrize(
    "operation,dry_run,partial",
    [
        ("export", True, False),
        ("export", False, True),
        ("import", True, False),
        ("import", False, True),
    ],
)
def test_public_commit_forwards_dry_run_and_preserves_partial_result(
    operation: str,
    dry_run: bool,
    partial: bool,
    monkeypatch: pytest.MonkeyPatch,
    target_capture: tuple[CapturedWorkspace, SnapshotImport],
    mutation_catalog: SchemaCatalog,
) -> None:
    """Thin wrappers retain exact planning context and shared writer outcomes."""
    baseline, request = target_capture
    plan = isolated_plan(mutation_catalog)
    writer = cast("MutationWriter", object())
    context = cast("InvocationContext", object())
    result = MutationResult(
        ok=not partial,
        artifacts=(),
        findings=(),
        validation=plan.validation,
        authority_invalidated=partial,
        uncertain_paths=("uncertain",) if partial else (),
    )
    planned: list[object] = []
    committed: list[object] = []

    def prepare(actual: object, selected: object, **options: object) -> MutationPlan:
        planned.append((actual, selected, options))
        return plan

    def commit(actual: object, **options: object) -> MutationResult:
        committed.append((actual, options))
        return result

    monkeypatch.setattr(source_snapshots, "plan_snapshot_" + operation, prepare)
    monkeypatch.setattr(source_snapshots, "commit_mutation", commit)
    selected = request if operation == "import" else export_request()
    actual = (
        source_snapshots.import_snapshot(
            baseline,
            request,
            grants=plan.grants,
            writer=writer,
            dry_run=dry_run,
            invocation=context,
        )
        if operation == "import"
        else source_snapshots.export_snapshot(
            baseline,
            export_request(),
            grants=plan.grants,
            writer=writer,
            dry_run=dry_run,
            invocation=context,
        )
    )
    assert actual is result and actual.authority_invalidated == partial
    assert planned == [
        (baseline, selected, dict(grants=plan.grants, invocation=context))
    ]
    assert committed == [(plan, dict(writer=writer, dry_run=dry_run))]
