"""Supply immutable schemas and fresh memory stores for mutation behavior tests."""

from __future__ import annotations

import json
import os
from contextlib import contextmanager
from dataclasses import replace
from typing import TYPE_CHECKING, TypeVar, cast

import pytest
from drm_copilot_discovery.agent_output import required_output_digest
from drm_copilot_discovery.catalog import load_catalog
from drm_copilot_discovery.models import to_plain_value
from drm_copilot_discovery.mutation_filesystem import LocalMutationPrimitives
from drm_copilot_discovery.mutation_io import capture_workspace
from drm_copilot_discovery.mutation_plan import (
    CapturedWorkspace,
    MutationChange,
    project_snapshot,
)
from drm_copilot_discovery.path_models import PathStamp, ResolvedPath, WriteGrant

from tests.discovery_runtime.test_references import immutable
from tests.discovery_runtime.test_snapshot_io import (
    PROFILE_PATH,
    MemoryStore,
    memory_workspace,
)
from tests.discovery_runtime.validation_test_support import output_context
from tests.schemas.discovery.v2_schema_test_support import as_object, load_fixture

if TYPE_CHECKING:
    from collections.abc import Callable, Generator

    from drm_copilot_discovery.agent_output import InvocationContext
    from drm_copilot_discovery.catalog import SchemaCatalog
    from drm_copilot_discovery.mutation_filesystem import Directory


Value = TypeVar("Value")


def constant(value: Value) -> Callable[..., Value]:
    """Return a typed inert kernel stub without unknown lambda parameters."""

    def result(*args: object, **kwargs: object) -> Value:
        """Return only the fixed test-local value supplied by its owner."""
        return value

    return result


@pytest.fixture(scope="module")
def mutation_catalog() -> SchemaCatalog:
    """Share only immutable schemas; every graph and memory store remains local."""
    return load_catalog()


def capture(store: MemoryStore, catalog: SchemaCatalog) -> CapturedWorkspace:
    """Capture an isolated memory filesystem through the actual runtime loader."""
    return capture_workspace(
        workspace_root=store.metadata.root.as_posix(),
        profile_path=PROFILE_PATH,
        metadata=store.metadata,
        read_bytes=store.read,
        catalog=catalog,
    )


def mutation_case(catalog: SchemaCatalog) -> tuple[MemoryStore, CapturedWorkspace]:
    """Create an honestly incomplete source workspace without fabricated source pins."""
    store, document = memory_workspace()
    document["profile_state"] = "draft"
    as_object(document["repository"])["revision"] = None
    store.put(PROFILE_PATH, json.dumps(document).encode())
    return store, capture(store, catalog)


def collection_change(
    baseline: CapturedWorkspace,
    *,
    decisions: bool = False,
    identifier: str = "questions",
) -> MutationChange:
    """Create a schema-valid empty collection with its exact captured precondition."""
    kind = (
        "product-decision-collection"
        if decisions
        else "unspecified-behavior-collection"
    )
    path = baseline.snapshot.profile.artifacts[
        "product_decisions" if decisions else "unspecified_behaviors"
    ]
    value = load_fixture(kind)
    value.update(id=identifier, records=[])
    # Updates bind the exact prior bytes, while new outputs carry an absence
    # precondition.
    previous = next(
        (file for file in baseline.snapshot.manifest.files if file.path == path), None
    )
    return MutationChange(
        artifact_kind=kind,
        artifact_id=identifier,
        path=path,
        content=json.dumps(value).encode(),
        expected_sha256=previous.sha256 if previous else None,
    )


def grants_for(*changes: MutationChange) -> tuple[WriteGrant, ...]:
    """Model exact caller-authenticated grants without creating native authority."""
    # Keep kind, ID and path together so fixtures cannot accidentally widen grants.
    return tuple(
        WriteGrant(
            artifact_kind=change.artifact_kind,
            artifact_id=change.artifact_id,
            path=change.path,
        )
        for change in changes
    )


def role_plan(
    baseline: CapturedWorkspace, *, role: str = "legacy-parity-analyst"
) -> tuple[tuple[MutationChange, ...], InvocationContext]:
    """Bind a local proposed collection and its exact manifest to separate context."""
    change = collection_change(baseline)
    projected = project_snapshot(baseline, (change,))
    # Bind the manifest to the actual loader-classified proposed output.
    output = next(item for item in projected.artifacts if item.path == change.path)
    helper = replace(
        baseline.snapshot,
        manifest=replace(baseline.snapshot.manifest, missing_paths=()),
    )
    _, context = output_context(helper, role, outputs=(output,))
    manifest = as_object(to_plain_value(context.required_outputs))
    workspace = as_object(manifest["workspace"])
    workspace["workspace_root"] = baseline.workspace_root
    manifest_path = (
        baseline.snapshot.profile.artifacts["reports"]
        + "/required-output-manifest.json"
    )
    rows = cast("list[dict[str, object]]", manifest["outputs"])
    rows[-1]["path"] = manifest_path
    manifest["manifest_sha256"] = required_output_digest(immutable(manifest))
    context = replace(
        context,
        baseline=baseline.snapshot,
        workspace=immutable(workspace),
        required_outputs=immutable(manifest),
    )
    control = MutationChange(
        artifact_kind="required-output-manifest",
        artifact_id=str(manifest["id"]),
        path=manifest_path,
        content=json.dumps(manifest).encode(),
        expected_sha256=None,
    )
    return (change, control), context


class MemoryDisk:
    """Own isolated namespace state, retained handles and an exclusive guard."""

    def __init__(self) -> None:
        """Use platform-valid synthetic absolute paths without filesystem access."""
        self.root = "C:/workspace" if os.name == "nt" else "/workspace"
        self.store = MemoryStore(self.root)
        self.store.metadata.add("docs", kind="directory")
        self.held = 0
        self.locked = False
        self.before_open: Callable[[str], None] = lambda path: None
        self.fail_publish = False
        self.limits: list[int] = []

    @contextmanager
    def open(self, path: str = ".") -> Generator[Directory, None, None]:
        """Retain the actual opened identity independently of earlier path metadata."""
        self.before_open(path)
        self.held += 1
        try:
            yield MemoryDirectory(self, path)
        finally:
            self.held -= 1

    @contextmanager
    def lock(self) -> Generator[None, None, None]:
        """Make concurrent authorized writers fail rather than share a guard."""
        if self.locked:
            raise FileExistsError("workspace busy")
        self.locked = True
        try:
            yield
        finally:
            self.locked = False

    def provider(self, *, limit: int = 16777216) -> LocalMutationPrimitives:
        """Inject only memory kernel seams into the real publication algorithm."""
        lock = "C:/state/workspace.lock" if os.name == "nt" else "/state/workspace.lock"
        return LocalMutationPrimitives(
            workspace_root=self.root,
            lock_path=lock,
            open_directory=self.open,
            lock=self.lock,
            metadata=self.store.metadata,
            nonce=lambda: "owned",
            document_bytes=limit,
        )

    def target(self, path: str = "docs/output.json") -> ResolvedPath:
        """Create exact path observations over the current memory namespace."""
        parts = path.split("/")
        # Include the root and every parent so handle-substitution probes retain full
        # context.
        names = [".", *("/".join(parts[:index]) for index in range(1, len(parts) + 1))]
        # Detach the original observations before any injected metadata-to-open race.
        stamps = tuple(
            PathStamp(
                path=name,
                kind=self.store.metadata(name).kind,
                identity=self.store.metadata(name).identity,
                resolved_path=self.store.metadata(name).resolved_path,
            )
            for name in names
        )
        return ResolvedPath(
            path=path,
            absolute_path=self.root + "/" + path,
            observations=stamps,
            grant=WriteGrant(
                artifact_kind="feature-contract", artifact_id="feature", path=path
            ),
        )


class MemoryDirectory:
    """Represent a retained directory capability over one test-owned memory disk."""

    def __init__(self, disk: MemoryDisk, path: str) -> None:
        """Capture the handle identity at open, before any later namespace changes."""
        self.disk, self.path = disk, path
        self.stamp = str(disk.store.metadata(path).identity)

    def identity(self) -> str:
        """Return the opened identity rather than reread the pathname."""
        return self.stamp

    def name(self, name: str) -> str:
        """Join one child under this test directory without touching native paths."""
        return name if self.path == "." else self.path + "/" + name

    @contextmanager
    def child(self, name: str, *, create: bool) -> Generator[Directory, None, None]:
        """Model exclusive missing-parent creation and retained parent handles."""
        path = self.name(name)
        # Existing parents are opened; only proven missing parents may be created.
        if create:
            if self.disk.store.metadata(path).kind != "missing":
                raise FileExistsError(path)
            self.disk.store.metadata.add(path, kind="directory")
        with self.disk.open(path) as child:
            yield child

    def read(self, name: str, *, limit: int) -> bytes:
        """Apply the real provider's configured limit to exact retained bytes."""
        self.disk.limits.append(limit)
        value = self.disk.store.files[self.name(name)]
        if len(value) > limit:
            raise OSError("bounded read")
        return value

    def stage(self, name: str, content: bytes) -> None:
        """Reject stage collisions so cleanup never owns someone else's file."""
        path = self.name(name)
        if path in self.disk.store.files:
            raise FileExistsError(path)
        self.disk.store.put(path, content)

    def publish(self, staged: str, name: str, *, replace: bool) -> None:
        """Model atomic publication while preserving a concurrently created output."""
        path = self.name(name)
        if self.disk.fail_publish or not replace and path in self.disk.store.files:
            raise FileExistsError("publication conflict")
        self.disk.store.put(path, self.disk.store.files[self.name(staged)])
        # Atomic replacement consumes its stage; exclusive links retain a cleanup name.
        if replace:
            self.remove(staged)

    def remove(self, name: str) -> None:
        """Remove only the named owned staging file."""
        path = self.name(name)
        del self.disk.store.files[path]
        self.disk.store.metadata.remove(path)
