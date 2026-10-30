"""Shared in-memory harness for the public source, target and combined workflows.

The public path is ``drm_copilot_discovery.service.execute`` driven through the
``MemoryService`` ports: real planners, validators, reports and transport run over an
isolated memory workspace with an injected clock, repository and activation store.
This module adds the workspace builders the three workflow suites share (an initialized
and activated workspace for a role, seeding of a complete rule-level snapshot into the
memory store, fixture loading) and performs no I/O beyond reading committed fixtures.
"""

from __future__ import annotations

import json
from dataclasses import replace
from pathlib import Path
from typing import TYPE_CHECKING, cast

from drm_copilot_discovery.configuration import DEFAULT_PROFILE
from drm_copilot_discovery.init_flow import plan_initialization
from drm_copilot_discovery.init_projection import InitializationRequest
from drm_copilot_discovery.models import canonical_json
from drm_copilot_discovery.repository_reader import RepositoryIdentity

from tests.discovery_runtime.test_service import MemoryService, invoke

if TYPE_CHECKING:
    from drm_copilot_discovery.catalog import SchemaCatalog
    from drm_copilot_discovery.init_projection import InitializationTemplates
    from drm_copilot_discovery.service_contracts import DiscoveryResult
    from drm_copilot_discovery.snapshot import DiscoverySnapshot

FIXTURES = Path(__file__).resolve().parents[1] / "fixtures" / "discovery_workflow"
PRODUCTION_ROOT = "application"
TEST_ROOT = "verification"
DOCUMENTATION_ROOT = "proposals"
BROWSER_CLIENT: dict[str, object] = {
    "id": "browser",
    "platforms": ["web"],
    "modes": ["online"],
    "required_feature_dimensions": [],
    "applicability_defaults": {},
}


def workspace(
    catalog: SchemaCatalog,
    templates: InitializationTemplates,
    *,
    role: str = "legacy-source",
    system_id: str = "source-system",
    repository_id: str = "source-repository",
    clients: tuple[dict[str, object], ...] = (BROWSER_CLIENT,),
    analyzers: tuple[str, ...] = ("repository",),
    runtime: str = "none",
    related: tuple[dict[str, object], ...] = (),
    activate: bool = True,
) -> MemoryService:
    """Initialize one memory workspace through the real plan and configure it.

    catalog (SchemaCatalog) and templates (InitializationTemplates) are the
    installed immutable resources; role (str), system_id (str) and repository_id
    (str) give the workspace its identity; clients, analyzers, runtime and related
    complete the profile; activate (bool) records the protected activation. Returns
    the MemoryService owning the fresh store. Memory only; plan errors propagate.
    """
    io = MemoryService(catalog)
    io.repository.checkout = RepositoryIdentity(id=repository_id, revision="a" * 40)
    # The configured roots must exist before the plan captures the workspace.
    for name in (PRODUCTION_ROOT, TEST_ROOT, DOCUMENTATION_ROOT):
        io.disk.store.metadata.add(name, kind="directory")
    plan = plan_initialization(
        InitializationRequest(
            system_id=system_id,
            system_name=f"{system_id} system",
            role=cast("str", role),  # type: ignore[arg-type]
            repository_id=repository_id,
            production_roots=(PRODUCTION_ROOT,),
            test_roots=(TEST_ROOT,),
            documentation_roots=(DOCUMENTATION_ROOT,),
        ),
        io=io.initialization,
        templates=templates,
    )
    # Materialize the accepted plan exactly as a published initialization would.
    for path in plan.directories:
        io.disk.store.metadata.add(path, kind="directory")
    for file in plan.mutation.prospective.manifest.files:
        io.disk.store.put(file.path, file.content)
    # A legacy source has no target of its own: its clients belong to a related
    # modernization target, which the profile must declare.
    target_id = repository_id
    if role == "legacy-source" and not related:
        target_id = "target-repository"
        related = (
            {
                "id": target_id,
                "role": "modernization-target",
                "revision": "b" * 40,
                "snapshot_manifest": None,
                "clients": [str(client["id"]) for client in clients],
            },
        )
    configure(
        io,
        clients=clients,
        analyzers=analyzers,
        runtime=runtime,
        related=related,
        repository_id=target_id,
    )
    if activate:
        io.activate()
    return io


def configure(
    io: MemoryService,
    *,
    clients: tuple[dict[str, object], ...],
    analyzers: tuple[str, ...],
    runtime: str,
    related: tuple[dict[str, object], ...],
    repository_id: str,
    **gates: object,
) -> None:
    """Complete the draft profile in io (MemoryService) and mark it configured.

    clients, analyzers, runtime, related and repository_id fill the consumer-owned
    fields; gates override completion gates. Returns None; only the memory
    profile bytes change, and the activation must be re-recorded afterwards.
    """
    profile = json.loads(io.disk.store.files[DEFAULT_PROFILE])
    profile["profile_state"] = "configured"
    profile["clients"] = [
        {"target_repository": repository_id, **client} for client in clients
    ]
    profile["analyzers"]["enabled"] = list(analyzers)
    profile["runtime"]["capability"] = runtime
    profile["repositories"] = list(related)
    profile["completion_gates"].update(gates)
    io.disk.store.put(DEFAULT_PROFILE, json.dumps(profile).encode("utf-8"))


def seeded_workspace(
    catalog: SchemaCatalog, snapshot: DiscoverySnapshot
) -> MemoryService:
    """Return a fresh activated workspace holding exactly one rule-level snapshot.

    catalog (SchemaCatalog) is the installed schema set; snapshot
    (DiscoverySnapshot) supplies the profile, every artifact and payload byte and
    the pinned repository objects. No initialization plan runs, so the artifact
    root contains the snapshot and nothing else. Memory only.
    """
    io = MemoryService(catalog)
    # Configured roots must exist as directories before any capture enumerates them.
    for name in snapshot.profile.production_roots + snapshot.profile.test_roots:
        io.disk.store.metadata.add(name, kind="directory")
    seed_snapshot(io, snapshot)
    return io


def seed_snapshot(io: MemoryService, snapshot: DiscoverySnapshot) -> None:
    """Write every retained byte of a rule-level snapshot into the memory store.

    io (MemoryService) receives the manifest files (profile, artifacts, payloads)
    and the pinned repository objects of snapshot (DiscoverySnapshot); the
    activation is re-recorded against the written profile bytes. Returns None.
    """
    retained = {file.path for file in snapshot.manifest.files}
    # Every captured byte becomes a workspace file at its retained path; a rule-level
    # graph carries no profile file, so the snapshot's profile is written explicitly.
    for file in snapshot.manifest.files:
        io.disk.store.put(file.path, file.content)
    profile_path = snapshot.profile.artifacts["profile"]
    if profile_path not in retained:
        io.disk.store.put(profile_path, canonical_json(snapshot.profile.document))
    io.repository.checkout = RepositoryIdentity(
        id=snapshot.profile.repository.id,
        revision=snapshot.profile.repository.revision,
    )
    # Pinned objects back evidence and implementation references at the revision.
    for item in snapshot.repository_files:
        io.repository.files[item.path] = item.content
        io.repository.checkout = item.repository
    io.activate()


def codes(result: DiscoveryResult) -> set[str]:
    """Return the finding codes of result (DiscoveryResult) for focused assertions."""
    return {item.code for item in result.findings}


def validate(io: MemoryService, mode: str, **fields: object) -> DiscoveryResult:
    """Run validate-all in mode (str) over io (MemoryService); return the result.

    The call is a dry run unless fields says otherwise: a written validation report
    is itself an input, so a pure assessment keeps the captured input set stable
    across modes. Protected receipts are minted by the gateway, not by this helper.
    """
    fields.setdefault("dry_run", True)
    return invoke(io, "validate-all", mode=mode, **fields)


def fixture_document(relative: str) -> dict[str, object]:
    """Load one committed workflow fixture (relative path under the fixture root)."""
    return cast(
        "dict[str, object]",
        json.loads((FIXTURES / relative).read_text(encoding="utf-8")),
    )


def fixture_names(folder: str) -> tuple[str, ...]:
    """Return the sorted JSON fixture names under folder (str)."""
    return tuple(sorted(path.name for path in (FIXTURES / folder).glob("*.json")))


def with_request_workspace(
    document: dict[str, object], io: MemoryService
) -> dict[str, object]:
    """Return document (a request fixture) rebound to io's memory workspace root."""
    return {**document, "workspace_root": io.disk.root}


__all__ = [
    "BROWSER_CLIENT",
    "FIXTURES",
    "codes",
    "configure",
    "fixture_document",
    "fixture_names",
    "replace",
    "seed_snapshot",
    "seeded_workspace",
    "validate",
    "with_request_workspace",
    "workspace",
]
