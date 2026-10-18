"""Keep transport mutation forwarding and guarded validation isolated in memory."""

from __future__ import annotations

from contextlib import nullcontext
from dataclasses import replace
from typing import TYPE_CHECKING, cast

import pytest
from drm_copilot_discovery import mutation_io
from drm_copilot_discovery.models import ParseLimits
from drm_copilot_discovery.mutation_io import GuardedMutationWriter, commit_mutation
from drm_copilot_discovery.mutation_plan import (
    MutationChange,
    MutationError,
    MutationPlan,
    PlannedWrite,
    plan_mutation,
)
from drm_copilot_discovery.path_policy import PathPolicy
from drm_copilot_discovery.snapshot import SnapshotFile
from drm_copilot_discovery.validation import SnapshotValidation

from tests.discovery_runtime.mutation_test_support import grants_for, mutation_case
from tests.discovery_runtime.mutation_test_support import (
    mutation_catalog as mutation_catalog,
)
from tests.discovery_runtime.test_snapshot_export import unit_transport

if TYPE_CHECKING:
    from contextlib import AbstractContextManager

    from drm_copilot_discovery.agent_output import InvocationContext
    from drm_copilot_discovery.catalog import SchemaCatalog
    from drm_copilot_discovery.mutation_plan import CapturedWorkspace
    from drm_copilot_discovery.path_models import ResolvedPath, WriteGrant
    from drm_copilot_discovery.transport_manifest import TransportRoute


class RecordingPrimitives:
    """Record one isolated publication request without graph loading or native I/O."""

    def __init__(self) -> None:
        self.calls: list[tuple[ResolvedPath, bytes]] = []

    def guard(self) -> AbstractContextManager[None]:
        return nullcontext()

    def create_exclusive(self, target: ResolvedPath, content: bytes) -> None:
        self.calls.append((target, content))

    def replace_if_digest(
        self, target: ResolvedPath, content: bytes, *, expected_sha256: str
    ) -> None:
        raise AssertionError("An immutable transport must never request replacement")


def isolated_plan(catalog: SchemaCatalog) -> MutationPlan:
    """Build internal values for forwarding tests; never claim graph validation."""
    _, baseline = mutation_case(catalog)
    route = unit_transport(catalog)
    changes = tuple(
        MutationChange(
            artifact_kind=item.grant.artifact_kind,
            artifact_id=item.grant.artifact_id,
            path=item.grant.path,
            content=route.manifest.content if item.origin is None else b"{}",
            expected_sha256=None,
        )
        for item in route.members
    )
    policy = PathPolicy(
        baseline.snapshot.profile,
        workspace_root=baseline.workspace_root,
        metadata=baseline.inspect,
        transport=route,
    )
    return MutationPlan(
        baseline=baseline,
        writes=tuple(
            PlannedWrite(
                change=item,
                target=policy.resolve_write(item.path, grant=grant),
                skipped=False,
                transport=route,
            )
            for item, grant in zip(changes, grants_for(*changes), strict=True)
        ),
        grants=grants_for(*changes),
        prospective=baseline.snapshot,
        transport=route,
        validation=SnapshotValidation(
            mode="structural",
            findings=(),
            input_sha256=baseline.snapshot.sha256,
            validation_result="pass",
        ),
    )


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
