"""Verify exact migration capture and prospective retention with in-memory ports."""

from __future__ import annotations

import sys
from dataclasses import replace
from typing import TYPE_CHECKING, cast

import pytest
from drm_copilot_discovery import mutation_plan
from drm_copilot_discovery.init_io import InitializationIO
from drm_copilot_discovery.init_projection import InitializationCapture
from drm_copilot_discovery.migration_capture import bind_migration_inputs
from drm_copilot_discovery.models import ParseLimits
from drm_copilot_discovery.mutation_plan import CapturedWorkspace, project_snapshot
from drm_copilot_discovery.path_models import PathPolicyError
from drm_copilot_discovery.report_models import ReportLimitError
from drm_copilot_discovery.snapshot import SnapshotFile

from tests.discovery_runtime.mutation_test_support import constant
from tests.discovery_runtime.test_service import MemoryService
from tests.discovery_runtime.test_service import (
    initialization_catalog as initialization_catalog,
)
from tests.discovery_runtime.test_service import (
    initialization_templates as initialization_templates,
)
from tests.discovery_runtime.test_service import service_plan as service_plan
from tests.discovery_runtime.test_service_migration import configured_capture

if TYPE_CHECKING:
    from types import FrameType

    from drm_copilot_discovery.catalog import SchemaCatalog
    from drm_copilot_discovery.init_flow import InitializationPlan
    from drm_copilot_discovery.snapshot import DiscoverySnapshot, InputManifest


def migration_capture_case(
    catalog: SchemaCatalog,
    plan: InitializationPlan,
    monkeypatch: pytest.MonkeyPatch,
) -> tuple[MemoryService, InitializationCapture]:
    """Return isolated trusted I/O and accepted base from typed catalog/plan inputs.

    monkeypatch substitutes only the already tested base capture to isolate the
    new supplement. Exact selected/sibling memory files remain real reader inputs;
    no external I/O occurs and only this test's memory/patch state changes.
    """
    io = MemoryService(catalog)
    # Materialize the shared immutable graph into fresh per-test memory.
    for path in plan.directories:
        io.disk.store.metadata.add(path, kind="directory")
    for file in plan.mutation.prospective.manifest.files:
        io.disk.store.put(file.path, file.content)
    io.disk.store.put("legacy/original.json", b'{"legacy":true}')
    io.disk.store.put("legacy/sibling.json", b"not selected")
    # The accepted ordinary capture has not inspected supplemental ancestors.
    metadata = tuple(
        (path, entry)
        for path, entry in io.disk.store.metadata.entries.items()
        if not path.startswith("legacy")
    )
    # Freeze only the ordinary captured file population before supplementation.
    physical_files = tuple(
        sorted(
            (file.path, file.content)
            for file in plan.mutation.prospective.manifest.files
        )
    )
    base = InitializationCapture(
        proposal_base=CapturedWorkspace(
            workspace_root=io.disk.root,
            snapshot=plan.mutation.prospective,
            metadata=metadata,
        ),
        physical_metadata=tuple(sorted(metadata)),
        physical_files=physical_files,
        profile_missing=False,
    )
    monkeypatch.setattr(InitializationIO, "capture", constant(base))
    monkeypatch.setattr(
        InitializationIO, "physical_capture", constant(base.proposal_base)
    )
    return io, base


def test_migration_capture_empty_selection_preserves_original_io(
    initialization_catalog: SchemaCatalog,
) -> None:
    """Keep default InitializationIO identity with typed catalog; return None.

    Empty selection performs no reads and preserves all existing behavior/ports.
    Invalid runtime carrier/selection types fail before external effects.
    """
    io = MemoryService(initialization_catalog)
    assert (
        bind_migration_inputs(io.initialization, paths=(), limits=ParseLimits())
        is io.initialization
    )
    with pytest.raises(ValueError, match="trusted initialization"):
        bind_migration_inputs(
            cast("InitializationIO", object()), paths=(), limits=ParseLimits()
        )
    with pytest.raises(ValueError, match="exact path strings"):
        bind_migration_inputs(
            io.initialization, paths=cast("tuple[str, ...]", (1,)), limits=ParseLimits()
        )
    assert io.disk.store.calls == []


def test_migration_capture_retains_exact_files_and_trusted_ports(
    initialization_catalog: SchemaCatalog,
    service_plan: InitializationPlan,
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """Retain exact originals with typed graph/patch fixtures; return None.

    Both proposal and physical paths preserve public ports, profile bytes and
    existing categories. No sibling content is read and no output is published.
    """
    io, base = migration_capture_case(initialization_catalog, service_plan, monkeypatch)
    profile = base.proposal_base.snapshot.profile
    path = profile.artifacts["profile"]
    original = base.proposal_base.snapshot.file(path).content
    bound = bind_migration_inputs(
        io.initialization, paths=("legacy/original.json", path), limits=ParseLimits()
    )
    assert bound is not io.initialization
    # Copy public capabilities by identity without reconstructing private state.
    for port in (
        "workspace_root",
        "catalog",
        "metadata",
        "read_bytes",
        "primitives",
        "open_directory",
        "invalidate_authority",
        "repository",
    ):
        assert getattr(bound, port) is getattr(io.initialization, port)
    proposal = bound.capture(profile_path=path, profile_bytes=original)
    physical = bound.physical_capture(path)
    assert proposal.proposal_base.snapshot == physical.snapshot
    assert physical.snapshot.profile is profile
    assert physical.snapshot.file(path).content == original
    assert physical.snapshot.file(path).category == "profile"
    assert (
        proposal.proposal_base.supplemental_paths
        == physical.supplemental_paths
        == tuple(sorted((path, "legacy/original.json")))
    )
    assert physical.snapshot.file("legacy/original.json").content == b'{"legacy":true}'
    assert dict(proposal.physical_files)["legacy/original.json"] == b'{"legacy":true}'
    assert dict(proposal.physical_metadata)["legacy/original.json"].kind == "file"
    assert {name for name, _ in io.disk.store.calls} == {path, "legacy/original.json"}
    assert io.writer_calls == 0
    # Explicit selection survives projection; an unmarked sibling cannot be retained.
    extra = SnapshotFile(
        path="legacy/sibling.json", content=b"not selected", category="documentation"
    )
    with_extra = replace(
        physical,
        snapshot=replace(
            physical.snapshot,
            manifest=replace(
                physical.snapshot.manifest,
                files=physical.snapshot.manifest.files + (extra,),
            ),
        ),
    )
    projected = project_snapshot(with_extra, ())
    assert projected.file("legacy/original.json").content == b'{"legacy":true}'
    assert projected.file(path).category == "profile"
    with pytest.raises(KeyError):
        projected.file(extra.path)
    assert (
        project_snapshot(replace(with_extra, supplemental_paths=()), ()).manifest
        == project_snapshot(base.proposal_base, ()).manifest
    )


@pytest.mark.parametrize("selection", ["duplicate", "traversal", "link"])
def test_migration_capture_rejects_invalid_selection(
    initialization_catalog: SchemaCatalog,
    service_plan: InitializationPlan,
    monkeypatch: pytest.MonkeyPatch,
    selection: str,
) -> None:
    """Reject selection (str) before byte reads with typed memory fixtures.

    Return None after exact duplicate/traversal/link refusal. Only test metadata
    changes; no accepted path policy or ordinary initialization is weakened.
    """
    io, base = migration_capture_case(initialization_catalog, service_plan, monkeypatch)
    path = "legacy/original.json"
    paths = (
        (path, path)
        if selection == "duplicate"
        else ("../original.json",) if selection == "traversal" else (path,)
    )
    if selection == "link":
        io.disk.store.metadata.entries[path] = replace(
            io.disk.store.metadata.entries[path], kind="symlink"
        )
    with pytest.raises(PathPolicyError):
        bound = bind_migration_inputs(
            io.initialization, paths=paths, limits=ParseLimits()
        )
        bound.physical_capture(base.proposal_base.snapshot.profile.artifacts["profile"])
    assert io.disk.store.calls == [] and io.writer_calls == 0
    # Constructor validation independently rejects forged selection authority.
    profile_path = base.proposal_base.snapshot.profile.artifacts["profile"]
    if selection == "duplicate":
        with pytest.raises(PathPolicyError):
            replace(base.proposal_base, supplemental_paths=(profile_path, profile_path))
        with pytest.raises(ValueError, match="immutable selection"):
            replace(
                base.proposal_base,
                supplemental_paths=cast("tuple[str, ...]", [profile_path]),
            )
    elif selection == "traversal":
        with pytest.raises(ValueError, match="not captured"):
            replace(base.proposal_base, supplemental_paths=("../outside",))
        with pytest.raises(ValueError, match="exact path"):
            replace(
                base.proposal_base, supplemental_paths=cast("tuple[str, ...]", (1,))
            )
    else:
        metadata = dict(base.proposal_base.metadata)
        metadata[profile_path] = replace(metadata[profile_path], kind="symlink")
        with pytest.raises(ValueError, match="ordinary file"):
            replace(
                base.proposal_base,
                metadata=tuple(metadata.items()),
                supplemental_paths=(profile_path,),
            )


@pytest.mark.parametrize("change", ["changed", "missing"])
def test_migration_capture_rejects_changed_originals(
    initialization_catalog: SchemaCatalog,
    service_plan: InitializationPlan,
    monkeypatch: pytest.MonkeyPatch,
    change: str,
) -> None:
    """Reject change (str) across exact recaptures using typed memory fixtures.

    Return None; actual require_same catches changed bytes and missing files fail
    capture. No stale proposal or partial output becomes a successful result.
    """
    io, base = migration_capture_case(initialization_catalog, service_plan, monkeypatch)
    path = base.proposal_base.snapshot.profile.artifacts["profile"]
    raw = base.proposal_base.snapshot.file(path).content
    bound = bind_migration_inputs(
        io.initialization, paths=("legacy/original.json",), limits=ParseLimits()
    )
    first = bound.capture(profile_path=path, profile_bytes=raw)
    if change == "changed":
        io.disk.store.files["legacy/original.json"] = b"changed"
    else:
        io.disk.store.metadata.remove("legacy/original.json")
    with pytest.raises((OSError, ValueError)):
        first.require_same(bound.capture(profile_path=path, profile_bytes=raw))
    assert io.writer_calls == 0


def test_migration_capture_rejects_conflicting_observations(
    initialization_catalog: SchemaCatalog,
    service_plan: InitializationPlan,
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """Reject physical observation conflicts with typed base/patch fixtures.

    Return None; actual source bytes remain unchanged while one retained root
    identity conflicts. Neither capture route may overwrite that observation.
    """
    io, base = migration_capture_case(initialization_catalog, service_plan, monkeypatch)
    metadata = dict(base.physical_metadata)
    metadata["."] = replace(metadata["."], identity="earlier-root")
    conflicted = replace(base, physical_metadata=tuple(sorted(metadata.items())))
    monkeypatch.setattr(InitializationIO, "capture", constant(conflicted))
    monkeypatch.setattr(
        InitializationIO,
        "physical_capture",
        constant(replace(base.proposal_base, metadata=tuple(metadata.items()))),
    )
    path = base.proposal_base.snapshot.profile.artifacts["profile"]
    bound = bind_migration_inputs(
        io.initialization, paths=("legacy/original.json",), limits=ParseLimits()
    )
    with pytest.raises(OSError, match="physical observations"):
        bound.capture(
            profile_path=path,
            profile_bytes=base.proposal_base.snapshot.file(path).content,
        )
    with pytest.raises(OSError, match="physical capture"):
        bound.physical_capture(path)
    assert io.writer_calls == 0


@pytest.mark.parametrize("capacity", ["file-count", "work", "bytes"])
def test_migration_capture_reserves_before_reads(
    initialization_catalog: SchemaCatalog,
    service_plan: InitializationPlan,
    monkeypatch: pytest.MonkeyPatch,
    capacity: str,
) -> None:
    """Reject short capacity (str) before reads using typed graph/patch fixtures.

    Return None; independent count, path-work and raw-byte ceilings are real
    inputs. Observable reader calls remain empty, with no timing assertion.
    """
    io, base = migration_capture_case(initialization_catalog, service_plan, monkeypatch)
    paths = ("legacy/original.json",)
    limits = (
        ParseLimits(document_bytes=1)
        if capacity == "bytes"
        else ParseLimits(artifact_records=1)
    )
    if capacity == "file-count":
        paths += ("legacy/sibling.json",)
    with pytest.raises(ReportLimitError):
        bound = bind_migration_inputs(io.initialization, paths=paths, limits=limits)
        bound.physical_capture(base.proposal_base.snapshot.profile.artifacts["profile"])
    assert io.disk.store.calls == [] and io.writer_calls == 0


@pytest.mark.parametrize(
    "capacity", ["coalesced", "count-exhausted", "read-exhausted", "byte-conflict"]
)
def test_capture_checks_exact_capacity_and_original_bytes(
    initialization_catalog: SchemaCatalog,
    service_plan: InitializationPlan,
    monkeypatch: pytest.MonkeyPatch,
    capacity: str,
) -> None:
    """Exercise capacity (str) at the real capture guard using typed memory fixtures.

    Return None after exact coalescing or count/read/byte-conflict refusal. All
    limits are actual configured capacities; only this test's ports/data change.
    """
    io, base = migration_capture_case(initialization_catalog, service_plan, monkeypatch)
    snapshot = base.proposal_base.snapshot
    path = snapshot.profile.artifacts["profile"]
    limits = snapshot.profile.limits
    if capacity in {"coalesced", "count-exhausted"}:
        limits = replace(limits, source_files=len(snapshot.manifest.files))
    captured = configured_capture(
        base.proposal_base,
        io,
        limits,
        remaining_bytes=0 if capacity == "read-exhausted" else None,
    )
    snapshot = captured.snapshot
    original = snapshot.file(path).content
    if capacity == "byte-conflict":
        io.disk.store.files[path] = b" " + original[1:]
    monkeypatch.setattr(InitializationIO, "physical_capture", constant(captured))
    selected = (
        path if capacity in {"coalesced", "byte-conflict"} else "legacy/original.json"
    )
    bound = bind_migration_inputs(
        io.initialization, paths=(selected,), limits=ParseLimits()
    )
    if capacity == "coalesced":
        result = bound.physical_capture(path)
        assert result.snapshot.manifest.files == snapshot.manifest.files
        assert result.snapshot.file(path).content == original
        assert result.snapshot.file(path).category == "profile"
    elif capacity == "byte-conflict":
        with pytest.raises(OSError, match="Migration original conflicts"):
            bound.physical_capture(path)
        assert {name for name, _ in io.disk.store.calls} == {path}
    else:
        with pytest.raises(ReportLimitError):
            bound.physical_capture(path)
        assert io.disk.store.calls == []
    assert io.writer_calls == 0


@pytest.mark.parametrize(
    "boundary", ["count-exact", "count-short", "bytes-exact", "bytes-short"]
)
def test_projection_reserves_exact_merged_capacity_before_retention(
    initialization_catalog: SchemaCatalog,
    service_plan: InitializationPlan,
    monkeypatch: pytest.MonkeyPatch,
    boundary: str,
) -> None:
    """Check boundary (str) on the public projector with typed in-memory fixtures.

    Return None after exact merge or pre-retention refusal. The loader is fixed
    to its captured result; actual retention calls and reconstruction are counted.
    Profiling state is restored even on failure; no I/O or publication occurs.
    """
    io, base = migration_capture_case(initialization_catalog, service_plan, monkeypatch)
    projected = base.proposal_base.snapshot
    path = projected.profile.artifacts["profile"]
    extra = SnapshotFile(
        path="legacy/original.json",
        content=b'{"legacy":true}',
        category="documentation",
    )
    count = len(projected.manifest.files) + 1
    short = boundary.endswith("short")
    limits = replace(
        projected.profile.limits,
        source_files=count - int(short) if boundary.startswith("count") else count,
    )
    captured = configured_capture(
        base.proposal_base,
        io,
        limits,
        remaining_bytes=(
            len(extra.content) - int(short) if boundary.startswith("bytes") else None
        ),
    )
    projected = captured.snapshot
    original = replace(
        projected,
        manifest=replace(projected.manifest, files=projected.manifest.files + (extra,)),
    )
    metadata = captured.metadata + tuple(
        (name, value)
        for name, value in io.disk.store.metadata.entries.items()
        if name.startswith("legacy")
    )
    captured = replace(
        captured,
        snapshot=original,
        metadata=metadata,
        supplemental_paths=(path, extra.path),
    )
    monkeypatch.setattr(mutation_plan, "load_snapshot", constant(projected))
    retained = reconstructed = 0

    def observe(frame: FrameType, event: str, argument: object) -> None:
        """Count actual dictionary retention calls; typed profile inputs, no I/O.

        Return None; only the local retained counter changes. Filtering by the
        public function's code excludes fixture/loader/library operations.
        """
        nonlocal retained
        if (
            frame.f_code is project_snapshot.__code__
            and event == "c_call"
            and getattr(argument, "__name__", "") == "setdefault"
        ):
            retained += 1

    def reconstruct(
        instance: DiscoverySnapshot | InputManifest, **changes: object
    ) -> DiscoverySnapshot | InputManifest:
        """Count typed result reconstruction then delegate; return a detached value.

        Keyword changes are dataclass fields. Only the local counter changes;
        original constructor exceptions propagate and no I/O occurs.
        """
        nonlocal reconstructed
        reconstructed += 1
        return replace(instance, **changes)

    monkeypatch.setattr(mutation_plan, "replace", reconstruct)
    previous = sys.getprofile()
    try:
        sys.setprofile(observe)
        if short:
            with pytest.raises(ReportLimitError):
                project_snapshot(captured, ())
            assert retained == reconstructed == 0
        else:
            result = project_snapshot(captured, ())
            assert result.file(extra.path) is extra
            assert result.file(path).category == projected.file(path).category
            assert len(result.manifest.files) == count
            assert retained == 2 and reconstructed == 2
    finally:
        sys.setprofile(previous)
    assert io.disk.store.calls == [] and io.writer_calls == 0
