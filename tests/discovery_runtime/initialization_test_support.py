"""Share immutable templates/catalogs and fresh in-memory initialization boundaries."""

from __future__ import annotations

from dataclasses import replace
from pathlib import Path
from typing import TYPE_CHECKING

import pytest
from drm_copilot_discovery.catalog import load_catalog
from drm_copilot_discovery.init_flow import plan_initialization
from drm_copilot_discovery.init_io import InitializationIO
from drm_copilot_discovery.init_projection import (
    InitializationCapture,
    InitializationRequest,
    InitializationTemplates,
)
from drm_copilot_discovery.repository_reader import RepositoryFile, RepositoryIdentity

from tests.discovery_runtime.mutation_test_support import MemoryDisk

if TYPE_CHECKING:
    from drm_copilot_discovery.catalog import SchemaCatalog
    from drm_copilot_discovery.init_flow import InitializationPlan
    from drm_copilot_discovery.profile_models import SystemRole

ROOT = Path(__file__).resolve().parents[2]


@pytest.fixture(scope="module")
def initialization_catalog() -> SchemaCatalog:
    """Reuse only immutable accepted schemas; mutable stores are never shared."""
    return load_catalog()


@pytest.fixture(scope="module")
def initialization_templates() -> InitializationTemplates:
    """
    Load immutable committed fixtures; output operations remain entirely in memory.
    """
    return InitializationTemplates.load(read=lambda path: (ROOT / path).read_bytes())


def request_for(role: SystemRole = "legacy-source") -> InitializationRequest:
    """Use explicit synthetic consumer identity and a selected source root."""
    return InitializationRequest(
        system_id="consumer-system",
        system_name="Consumer system",
        role=role,
        repository_id="consumer-repository",
        production_roots=("application",),
        test_roots=("verification",),
        documentation_roots=("docs",),
    )


@pytest.fixture(scope="module")
def initialization_plan(
    initialization_catalog: SchemaCatalog,
    initialization_templates: InitializationTemplates,
) -> InitializationPlan:
    """Share only an immutable proposal; every behavior test creates a fresh disk."""
    case = InitializationCase(initialization_catalog)
    return plan_initialization(
        request_for(), io=case.io, templates=initialization_templates
    )


def seed_proposal(case: InitializationCase, plan: InitializationPlan) -> None:
    """Copy immutable projected bytes into a fresh test-owned physical workspace."""
    for path in plan.directories:
        case.disk.store.metadata.add(path, kind="directory")
    for item in plan.mutation.prospective.manifest.files:
        case.disk.store.put(item.path, item.content)


def bootstrap_capture(
    case: InitializationCase, plan: InitializationPlan
) -> InitializationCapture:
    """Bind actual memory metadata to an unchanged immutable profile-only graph."""
    metadata = tuple(
        (path, case.disk.store.metadata(path))
        for path, _ in plan.capture.physical_metadata
    )
    return InitializationCapture(
        proposal_base=replace(plan.capture.proposal_base, metadata=metadata),
        physical_metadata=metadata,
        physical_files=tuple(sorted(case.disk.store.files.items())),
        profile_missing=False,
    )


class InitializationCase:
    """Keep all mutable memory/native-seam state local to one test invocation."""

    def __init__(self, catalog: SchemaCatalog) -> None:
        """Bind real guarded algorithms to memory-only kernel primitives."""
        self.disk = MemoryDisk()
        self.disk.store.metadata.add("application", kind="directory")
        self.revocations = 0
        self.io = InitializationIO(
            workspace_root=self.disk.root,
            catalog=catalog,
            metadata=self.disk.store.metadata,
            read_bytes=self.disk.store.read,
            primitives=self.disk.provider(),
            open_directory=self.disk.open,
            invalidate_authority=self.invalidate,
        )

    def invalidate(self) -> None:
        """Record protected-store revocation without writing receipts or activations."""
        self.revocations += 1


class MemoryRepository:
    """Serve deterministic local checkout pins and blobs without a process."""

    def __init__(
        self, *, revision: str | None = "a" * 40, available: bool = True
    ) -> None:
        """Retain fresh test-owned objects with an optional unavailable Git state."""
        self.checkout = RepositoryIdentity(id="consumer-repository", revision=revision)
        self.available = available
        self.files: dict[str, bytes] = {}

    def identity(self) -> RepositoryIdentity:
        """Expose verified local identity or an explicit availability failure."""
        if not self.available:
            raise OSError("Local Git unavailable")
        return self.checkout

    def read_file(self, *, revision: str, path: str, limit: int) -> RepositoryFile:
        """Require a matching immutable pin and a bounded existing memory blob."""
        content = self.files[path]
        if revision != self.checkout.revision or len(content) > limit:
            raise OSError("Invalid pinned memory read")
        return RepositoryFile(repository=self.checkout, path=path, content=content)
