"""Prove local inventory pin capture without broadening the workspace read scope."""

from __future__ import annotations

import hashlib
from dataclasses import replace
from typing import TYPE_CHECKING, cast

import pytest
from drm_copilot_discovery.mutation_io import capture_workspace
from drm_copilot_discovery.mutation_plan import project_snapshot
from drm_copilot_discovery.repository_reader import RepositoryIdentity
from drm_copilot_discovery.revision_rules import validate_revisions
from drm_copilot_discovery.snapshot_inventory_inputs import local_inventory_requests
from drm_copilot_discovery.snapshot_loading import load_snapshot

from tests.discovery_runtime.test_snapshot_io import PROFILE_PATH, memory_workspace
from tests.discovery_runtime.test_snapshot_io import (
    snapshot_catalog as snapshot_catalog,
)
from tests.discovery_runtime.test_snapshot_loading import MemoryRepository, put_document
from tests.schemas.discovery.v2_schema_test_support import as_object, load_fixture

if TYPE_CHECKING:
    from drm_copilot_discovery.catalog import SchemaCatalog
    from drm_copilot_discovery.repository_reader import RepositoryFile

PIN = "a" * 40
PATH = "docs/selected.md"
CONTENT = b"exact documentation\r\n"
INVENTORY = "docs/migration/discovery/inventory/selected.json"
GROUPS = ("files", "components", "findings", "relationships")


def inventory_document(group: str = "files") -> dict[str, object]:
    """Build one schema-valid local claim for exact documentation bytes.

    Args:
        group (str): One of GROUPS; selects the independently exercised source shape.

    Returns:
        A fresh dict[str, object] with one claim and no unrelated source groups.

    Raises:
        KeyError: The requested group is absent from the committed example.

    Reads the immutable example fixture; mutates only the returned test-local data.
    """
    document = load_fixture("inventory-snapshot")
    document.update(repository="workspace-example", diagnostics=[], exclusions=[])
    row = as_object(cast("list[object]", document[group])[0])
    # File rows own provenance directly; other row kinds nest it under source.
    source = row if group == "files" else as_object(row["source"])
    source.update(path=PATH, sha256=hashlib.sha256(CONTENT).hexdigest())
    # Only file rows carry size; nested provenance explicitly carries repository/pin.
    if group == "files":
        source["size"] = len(CONTENT)
    else:
        source.update(repository="workspace-example", revision=PIN)
    # Keep each group independent so no other claim can cause its Git request.
    for name in GROUPS:
        document[name] = [row] if name == group else []
    return document


@pytest.mark.parametrize("group", GROUPS)
def test_each_inventory_source_group_captures_exact_doc_bytes_once(
    group: str, snapshot_catalog: SchemaCatalog
) -> None:
    """Verify each inspected source shape retains one exact pinned object.

    Args:
        group (str): Valid inventory source group under test.
        snapshot_catalog (SchemaCatalog): Trusted immutable schemas.

    Returns:
        None; asserts exact bytes, deduplication and successful revision checks.

    Raises:
        AssertionError: Capture or revision validation violates the contract.

    Mutates only memory stores and their observable request lists.
    """
    store, _ = memory_workspace()
    store.put(PATH, CONTENT)
    document = inventory_document(group)
    put_document(store, INVENTORY, document)
    put_document(store, INVENTORY.replace("selected", "duplicate"), document)
    repository = MemoryRepository({(PIN, PATH): CONTENT})

    snapshot = load_snapshot(
        io=store.io(),
        profile_path=PROFILE_PATH,
        repository=repository,
        catalog=snapshot_catalog,
    )

    assert snapshot.ok, snapshot.findings
    assert repository.requests == [(PIN, PATH)]
    assert snapshot.repository_files[0].content == CONTENT
    assert not validate_revisions(snapshot).findings


@pytest.mark.parametrize(
    "case", ["unreferenced", "invalid", "foreign", "outside", "excluded", "no-pin"]
)
def test_nonlocal_or_uninspected_claims_never_add_git_reads(
    case: str, snapshot_catalog: SchemaCatalog
) -> None:
    """Verify invalid, foreign and uninspected claims cannot authorize Git reads.

    Args:
        case (str): Parameterized missing-authority or missing-inspection condition.
        snapshot_catalog (SchemaCatalog): Trusted immutable schemas.

    Returns:
        None; asserts the injected repository receives no requests.

    Raises:
        AssertionError: An unauthorized claim causes a Git read.

    Mutates only memory stores and test-local inventory documents.
    """
    store, _ = memory_workspace()
    store.put(PATH, CONTENT)
    document = inventory_document()
    row = as_object(cast("list[object]", document["files"])[0])
    # Change one authority or inspection condition while preserving other inputs.
    if case == "invalid":
        document["unexpected"] = True
    elif case == "foreign":
        document["repository"] = "foreign"
    elif case == "outside":
        row["path"] = "private/unselected.md"
        store.put("private/unselected.md", CONTENT)
    elif case == "excluded":
        row.update(status="excluded", sha256=None, size=None, rationale="Excluded.")
    elif case == "no-pin":
        document["revision"] = None
    if case != "unreferenced":
        put_document(store, INVENTORY, document)
    repository = MemoryRepository()

    load_snapshot(
        io=store.io(),
        profile_path=PROFILE_PATH,
        repository=repository,
        catalog=snapshot_catalog,
    )

    assert not repository.requests


def test_existing_inventory_projection_preserves_exact_pinned_bytes(
    snapshot_catalog: SchemaCatalog,
) -> None:
    """Verify projection replays inventory pins without contacting a repository.

    Args:
        snapshot_catalog (SchemaCatalog): Trusted immutable schemas.

    Returns:
        None; asserts identical pinned objects, snapshot digest and request count.

    Raises:
        AssertionError: Projection loses or rereads the captured immutable bytes.

    Clears the isolated repository's object map after initial memory capture.
    """
    store, _ = memory_workspace()
    store.put(PATH, CONTENT)
    put_document(store, INVENTORY, inventory_document())
    repository = MemoryRepository({(PIN, PATH): CONTENT})
    baseline = capture_workspace(
        workspace_root="/workspace",
        profile_path=PROFILE_PATH,
        metadata=store.metadata,
        read_bytes=store.read,
        catalog=snapshot_catalog,
        repository=repository,
    )
    repository.files.clear()

    projected = project_snapshot(baseline, ())

    assert projected.repository_files == baseline.snapshot.repository_files
    assert projected.sha256 == baseline.snapshot.sha256
    assert repository.requests == [(PIN, PATH)]


@pytest.mark.parametrize("case", ["absent", "wrong-pin", "mismatch"])
def test_inventory_source_integrity_failures_remain_explicit(
    case: str, snapshot_catalog: SchemaCatalog
) -> None:
    """Verify missing objects, different pins and changed bytes remain failures.

    Args:
        case (str): One of absent, wrong-pin or mismatch.
        snapshot_catalog (SchemaCatalog): Trusted immutable schemas.

    Returns:
        None; asserts capture rejection or the exact revision finding code.

    Raises:
        AssertionError: Invalid immutable provenance is accepted.

    Mutates only in-memory fixture data and the repository request log.
    """
    store, _ = memory_workspace()
    store.put(PATH, CONTENT)
    document = inventory_document()
    # Separate header-pin disagreement from content disagreement at the valid pin.
    revision = "b" * 40 if case == "wrong-pin" else PIN
    document["revision"] = revision
    put_document(store, INVENTORY, document)
    # Missing storage must fail capture; populated storage reaches revision rules.
    repository = MemoryRepository(
        {}
        if case == "absent"
        else {(revision, PATH): b"changed" if case == "mismatch" else CONTENT}
    )
    # Absence is a reader failure and cannot produce a snapshot to validate later.
    if case == "absent":
        with pytest.raises(KeyError):
            load_snapshot(
                io=store.io(),
                profile_path=PROFILE_PATH,
                repository=repository,
                catalog=snapshot_catalog,
            )
        return

    snapshot = load_snapshot(
        io=store.io(),
        profile_path=PROFILE_PATH,
        repository=repository,
        catalog=snapshot_catalog,
    )
    codes = {finding.code for finding in validate_revisions(snapshot).findings}

    assert (
        "REVISION_PIN_MISMATCH" if case == "wrong-pin" else "REVISION_SOURCE_HASH"
    ) in codes


def test_inventory_git_adapter_wrong_pin_is_rejected(
    snapshot_catalog: SchemaCatalog,
) -> None:
    """Verify an adapter cannot substitute a different immutable revision.

    Args:
        snapshot_catalog (SchemaCatalog): Trusted immutable schemas.

    Returns:
        None; asserts the loader rejects the deliberately mismatched response.

    Raises:
        AssertionError: The expected boundary rejection does not occur.

    Mutates only a fresh memory store and the injected repository's request log.
    """
    store, _ = memory_workspace()
    store.put(PATH, CONTENT)
    put_document(store, INVENTORY, inventory_document())

    class WrongPinRepository(MemoryRepository):
        """Model an adapter violating the requested pin without external reads.

        Instantiate with MemoryRepository's pinned object map, then inject into
        load_snapshot. Reads use inherited storage and append to its request log
        before replacing the returned identity. Only this test-local state changes;
        bytes and path remain exact so the pin is the sole rejected invariant.
        """

        def read_file(self, *, revision: str, path: str, limit: int) -> RepositoryFile:
            """Substitute a pin while retaining requested bytes and path.

            Args:
                revision (str): Full pin used to select the stored object.
                path (str): Exact stored relative path.
                limit (int): Byte ceiling forwarded to the inherited mock API.

            Returns:
                RepositoryFile with deliberately wrong revision and exact bytes.

            Raises:
                KeyError: The requested object is absent from inherited storage.

            Appends one request to the inherited in-memory log; performs no I/O.
            """
            return replace(
                super().read_file(revision=revision, path=path, limit=limit),
                repository=RepositoryIdentity(
                    id="workspace-example", revision="b" * 40
                ),
            )

    with pytest.raises(ValueError, match="different repository, pin, or path"):
        load_snapshot(
            io=store.io(),
            profile_path=PROFILE_PATH,
            repository=WrongPinRepository({(PIN, PATH): CONTENT}),
            catalog=snapshot_catalog,
        )


@pytest.mark.parametrize("case", ["imported", "foreign-artifact", "foreign-row"])
def test_source_origin_cannot_authorize_local_requests(
    case: str, snapshot_catalog: SchemaCatalog
) -> None:
    """Verify imported artifacts and foreign sources cannot request local Git bytes.

    Args:
        case (str): Imported origin, foreign artifact identity or foreign row owner.
        snapshot_catalog (SchemaCatalog): Trusted immutable schemas.

    Returns:
        None; asserts the pure selector returns an empty request set.

    Raises:
        AssertionError: A transported or foreign claim authorizes local reads.

    Mutates only test-local documents and memory stores; origin copies are immutable.
    """
    store, _ = memory_workspace()
    store.put(PATH, CONTENT)
    document = inventory_document("components")
    if case == "foreign-row":
        row = as_object(cast("list[object]", document["components"])[0])
        as_object(row["source"])["repository"] = "foreign"
    put_document(store, INVENTORY, document)
    snapshot = load_snapshot(
        io=store.io(), profile_path=PROFILE_PATH, catalog=snapshot_catalog
    )
    assert snapshot.ok, snapshot.findings
    artifact = snapshot.artifacts[0]
    # Model the origin binding assigned by a validated transport manifest.
    if case == "imported":
        artifact = replace(artifact, origin_path="inventory/selected.json")
    elif case == "foreign-artifact":
        artifact = replace(
            artifact, repository=RepositoryIdentity(id="foreign", revision=PIN)
        )

    requests = local_inventory_requests(
        (artifact,),
        valid_paths={INVENTORY},
        captured_paths=(PATH,),
        categories={PATH: "documentation"},
        local=RepositoryIdentity(id="workspace-example", revision=PIN),
    )

    assert not requests
