"""Verify closed v1 service dispatch without replaying accepted migration suites."""

from __future__ import annotations

from dataclasses import replace
from typing import TYPE_CHECKING, NoReturn

import pytest
from drm_copilot_discovery import migration_v1
from drm_copilot_discovery.catalog import V1_KINDS, schema_aliases
from drm_copilot_discovery.models import JsonObject, canonical_json
from drm_copilot_discovery.operations import OperationFailure
from drm_copilot_discovery.profile_v2 import ProfileV2

from tests.discovery_runtime.test_migration_v1 import source_for
from tests.discovery_runtime.test_service import MemoryService, invoke
from tests.discovery_runtime.test_service import (
    initialization_catalog as initialization_catalog,
)

if TYPE_CHECKING:
    from drm_copilot_discovery.catalog import SchemaCatalog
    from drm_copilot_discovery.init_io import InitializationIO
    from drm_copilot_discovery.migration_models import MigrationRequest, MigrationSource
    from drm_copilot_discovery.models import JsonValue
    from drm_copilot_discovery.mutation_plan import CapturedWorkspace
    from drm_copilot_discovery.profile_models import ProfileLimits


def migration_inputs(source: MigrationSource) -> dict[str, object]:
    """Return explicit service fields for source (MigrationSource), without I/O.

    The fresh dictionary selects one original path and a new draft destination;
    it neither supplies a v2 kind nor claims conversion/activation authority.
    """
    return {
        "input_path": source.path,
        "from_version": 1,
        "to_version": 2,
        "destination": "migrated",
        "system_id": "consumer-system",
        "system_name": "Consumer system",
        "system_role": "combined",
        "repository_id": "consumer-repository",
        "draft": True,
    }


def configured_capture(
    base: CapturedWorkspace,
    io: MemoryService,
    limits: ProfileLimits,
    *,
    remaining_bytes: int | None = None,
) -> CapturedWorkspace:
    """Return CapturedWorkspace with parsed limits and matching physical bytes.

    base (CapturedWorkspace) is the immutable baseline; io (MemoryService) owns
    the isolated mutable store; limits (ProfileLimits) supplies requested policy.
    remaining_bytes (int | None) selects exact spare raw-byte capacity or keeps
    that policy. Only supplied memory changes, with no external I/O. ProfileError
    propagates for invalid policy; AssertionError reports fixture nonconvergence.
    """
    snapshot = base.snapshot
    path = snapshot.profile.artifacts["profile"]
    document = dict(snapshot.profile.document.members)
    values: dict[str, JsonValue] = {
        "document_bytes": limits.document_bytes,
        "artifact_records": limits.artifact_records,
        "source_files": limits.source_files,
        "nesting_depth": limits.nesting_depth,
    }
    # Exclude old profile bytes so replacement encoding reaches exact capacity.
    other = sum(
        len(file.content) for file in snapshot.manifest.files if file.path != path
    )
    # Decimal-length changes settle within this fixed finite fixture bound.
    for _ in range(8):
        document["limits"] = JsonObject(tuple(values.items()))
        raw = canonical_json(JsonObject(tuple(document.items())))
        required = other + len(raw) + (remaining_bytes or 0)
        if remaining_bytes is None or values["document_bytes"] == required:
            break
        values["document_bytes"] = required
    else:
        raise AssertionError("Fixture profile byte capacity did not stabilize")
    profile = ProfileV2(raw, format="json", catalog=snapshot.catalog)
    # Replace only profile bytes while retaining every other captured input.
    files = tuple(
        replace(file, content=raw) if file.path == path else file
        for file in snapshot.manifest.files
    )
    io.disk.store.put(path, raw)
    return replace(
        base,
        snapshot=replace(
            snapshot, profile=profile, manifest=replace(snapshot.manifest, files=files)
        ),
        # Refresh the same observed entries after the in-memory profile update.
        metadata=tuple(
            (name, io.disk.store.metadata.entries[name]) for name, _ in base.metadata
        ),
    )


@pytest.mark.parametrize("kind", V1_KINDS)
def test_registered_v1_kind_reaches_exact_migration_request(
    initialization_catalog: SchemaCatalog, monkeypatch: pytest.MonkeyPatch, kind: str
) -> None:
    """Resolve kind (str) from accepted bytes using catalog and scoped monkeypatch.

    Return None after checking the real service's migration arguments. A typed
    stop at the planner prevents duplicate conversion proof; memory is unchanged.
    """
    io = MemoryService(initialization_catalog)
    source = source_for(kind)
    io.disk.store.put(source.path, source.content)
    before = dict(io.disk.store.files)
    requests: list[MigrationRequest] = []

    def retain(request: MigrationRequest, *, io: InitializationIO) -> NoReturn:
        """Retain typed request and injected io, then raise the explicit test stop.

        Append only to this test's requests list; do not plan or publish anything.
        """
        assert io.catalog is initialization_catalog
        requests.append(request)
        raise OperationFailure("SERVICE_TEST_STOP", exit_code=3)

    monkeypatch.setattr(migration_v1, "plan_migration", retain)
    result = invoke(io, "migrate", migration_inputs(source), dry_run=True)
    assert result.exit_code == 3 and not result.artifacts
    # The injected stop confirms dispatch only; no success authority is fabricated.
    assert [finding.code for finding in result.findings] == ["SERVICE_TEST_STOP"]
    assert len(requests) == 1 and requests[0].sources == (source,)
    assert requests[0].initialization.documentation_roots == ()
    assert io.disk.store.files == before and io.writer_calls == 0


@pytest.mark.parametrize("schema_case", ["unknown", "body-mismatch"])
def test_invalid_v1_schema_identity_never_publishes(
    initialization_catalog: SchemaCatalog, schema_case: str
) -> None:
    """Refuse schema_case (str) through real catalog/planner validation in memory.

    Return None; unknown aliases and incompatible registered bodies retain exact
    original bytes and produce no file effects or successful migration claim.
    """
    # Separate unknown dispatch identity from a known schema with an invalid body.
    schema = (
        "urn:unregistered:coverage-ledger"
        if schema_case == "unknown"
        else schema_aliases("feature-contract", "1.0.0")[0]
    )
    source = source_for("coverage-ledger", **{"$schema": schema})
    io = MemoryService(initialization_catalog)
    io.disk.store.put(source.path, source.content)
    before = dict(io.disk.store.files)
    result = invoke(io, "migrate", migration_inputs(source))
    assert not result.ok and result.findings and not result.artifacts
    assert io.disk.store.files == before and io.writer_calls == 0
    # Unknown identities stop early; registered bodies retain schema findings.
    if schema_case == "unknown":
        assert result.exit_code == 2 and result.findings[0].code == "SERVICE_KIND"
    else:
        assert any(
            finding.code.startswith("SCHEMA_") for finding in result.findings
        ), result.findings
