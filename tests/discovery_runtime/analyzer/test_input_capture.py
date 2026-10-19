"""Exercise bounded, pruned analyzer reads using only isolated memory adapters."""

from __future__ import annotations

from dataclasses import replace
from typing import TYPE_CHECKING

import pytest
from drm_copilot_discovery.analyzer import input_capture
from drm_copilot_discovery.analyzer.input_capture import (
    capture_inputs,
    capture_snapshot,
    pin_inventory_sources,
)
from drm_copilot_discovery.analyzer.models import InventoryInput
from drm_copilot_discovery.mutation_plan import CapturedWorkspace
from drm_copilot_discovery.path_models import PathPolicyError
from drm_copilot_discovery.repository_reader import RepositoryFile, RepositoryIdentity
from drm_copilot_discovery.snapshot import SnapshotFile

from tests.discovery_runtime.analyzer.test_repository import (
    analyzer_catalog as analyzer_catalog,
)
from tests.discovery_runtime.analyzer.test_repository import inventory_profile
from tests.discovery_runtime.test_snapshot_io import MemoryStore
from tests.discovery_runtime.validation_test_support import captured

if TYPE_CHECKING:
    from drm_copilot_discovery.analyzer.models import InventoryCapture
    from drm_copilot_discovery.catalog import SchemaCatalog
    from drm_copilot_discovery.path_models import PathMetadata
    from drm_copilot_discovery.profile_v2 import ProfileV2


def read_capture(profile: ProfileV2, store: MemoryStore) -> InventoryCapture:
    """Use the real capture boundary with test-local filesystem collaborators.

    Parameters: profile (ProfileV2): validated local-source configuration. store
    (MemoryStore): test-local memory filesystem.

    Returns InventoryCapture from the actual runtime boundary; policy/read failures
    propagate. Reads only memory seams.
    """
    return capture_inputs(
        profile,
        workspace_root=store.metadata.root.as_posix(),
        metadata=store.metadata,
        read_bytes=store.read,
    )


@pytest.mark.parametrize("workspace", ["/workspace", "C:/workspace"])
def test_capture_prunes_outputs_and_dependencies_before_descent(
    analyzer_catalog: SchemaCatalog, workspace: str
) -> None:
    """Excluded frontiers are accounted for without probing their child
    metadata/bytes.

    Parameters: analyzer_catalog (SchemaCatalog): immutable installed schema
    fixture. workspace (str): synthetic absolute platform root.

    Returns None. Raises AssertionError when the asserted contract differs; uses
    only test-local memory and immutable schema fixtures.
    """
    profile = inventory_profile(
        analyzer_catalog,
        project_entry_points=["src/app.sln"],
        test_roots=["tests"],
        excluded_paths=[
            {"path_or_glob": "src/vendor/**", "rationale": "External source."}
        ],
        analyzers={
            "enabled": ["repository"],
            "options": {},
            "ignored_paths": [
                {"path_or_glob": "src/generated", "rationale": "Build output."}
            ],
            "extension_result_manifests": [],
        },
    )
    store = MemoryStore(workspace)
    # Mix retained inputs with excluded descendants to detect late pruning.
    for path in (
        "src/.hidden",
        "src/app.sln",
        "src/vendor/private",
        "src/generated/private",
        "tests/test.cs",
        "docs/guide.md",
        profile.artifacts["inventory"] + "/old.json",
    ):
        store.put(path, path.encode())
    forbidden = {
        "src/vendor/private",
        "src/generated/private",
        profile.artifacts["inventory"] + "/old.json",
    }
    original = store.metadata
    seen: list[str] = []

    def metadata(path: str) -> PathMetadata:
        """Reject descendant access after a configured exclusion frontier.

        Parameters: path (str): workspace-relative input path.

        Returns PathMetadata from the memory adapter; raises AssertionError for
        excluded descendant reads and records the observed path in a local list.
        """
        assert path not in forbidden
        seen.append(path)
        return original(path)

    result = capture_inputs(
        profile, workspace_root=workspace, metadata=metadata, read_bytes=store.read
    )
    # Only successful retained bytes may participate in source classification.
    inspected = {item.path: item for item in result.inputs if item.file}
    assert set(inspected) == {
        "src/.hidden",
        "src/app.sln",
        "tests/test.cs",
        "docs/guide.md",
    }
    # Each pruned frontier remains visible with its explicit exclusion disposition.
    assert {item.path for item in result.inputs if item.status == "excluded"} == {
        "src/vendor",
        "src/generated",
        profile.artifacts["root"],
    }
    assert not forbidden.intersection(seen)
    # Source ownership must match configured roots independently of walk ordering.
    assert [item.file.category for item in inspected.values() if item.file] == [
        "documentation",
        "source",
        "source",
        "test",
    ]
    assert len(store.calls) == 8  # One original read and one freshness comparison each.


def test_failed_oversized_and_missing_inputs_never_receive_fabricated_hashes(
    analyzer_catalog: SchemaCatalog,
) -> None:
    """Unreadable entries retain rationale while successful inputs remain analyzable.

    Parameters: analyzer_catalog (SchemaCatalog): immutable installed schema
    fixture.

    Returns None. Raises AssertionError when the asserted contract differs; uses
    only test-local memory and immutable schema fixtures.
    """
    profile = inventory_profile(
        analyzer_catalog,
        test_roots=["tests"],
        analyzers={
            "enabled": ["repository"],
            "options": {"max_file_bytes": 4},
            "ignored_paths": [],
            "extension_result_manifests": [],
        },
    )
    store = MemoryStore()
    store.put("src/good", b"ok")
    store.put("src/large", b"12345")
    store.put("src/denied", b"no")
    store.failures.add("src/denied")
    store.metadata.add("docs", kind="directory")
    result = read_capture(profile, store)
    # Failure accounting retains every unreadable path but never fake byte hashes.
    failed = [item for item in result.inputs if item.status == "unreadable"]
    assert [item.path for item in failed] == ["src/denied", "src/large", "tests"]
    # All failure causes share the same absence-of-bytes invariant.
    assert all(
        item.file is None and item.sha256 is None and item.rationale for item in failed
    )
    # Successful reads remain independently usable despite other input failures.
    assert next(
        item for item in result.inputs if item.path == "src/good"
    ).file == SnapshotFile(path="src/good", content=b"ok", category="source")


@pytest.mark.parametrize(
    "limits", [{"source_files": 1}, {"source_files": 2}, {"nesting_depth": 1}]
)
def test_entry_and_depth_limits_fail_closed(
    analyzer_catalog: SchemaCatalog, limits: dict[str, int]
) -> None:
    """Directory breadth, total traversal and nesting are bounded before
    continuation.

    Parameters: analyzer_catalog (SchemaCatalog): immutable installed schema
    fixture. limits (dict[str, int]): finite profile limits for this case.

    Returns None. Raises AssertionError when the asserted contract differs; uses
    only test-local memory and immutable schema fixtures.
    """
    profile = inventory_profile(analyzer_catalog, limits=limits)
    store = MemoryStore()
    # Exercise both directory breadth and total traversal ceilings on the same tree.
    for path in ("src/a", "src/b", "src/c"):
        store.put(path, b"x")
    with pytest.raises((ValueError, OSError), match="limit|depth"):
        read_capture(profile, store)


def test_aggregate_bytes_and_changed_inputs_fail_without_partial_success(
    analyzer_catalog: SchemaCatalog, monkeypatch: pytest.MonkeyPatch
) -> None:
    """Finite total allocation and freshness cannot be bypassed by small individual
    files.

    Parameters: analyzer_catalog (SchemaCatalog): immutable installed schema
    fixture. monkeypatch (pytest.MonkeyPatch): isolated patches restored by pytest.

    Returns None. Raises AssertionError when the asserted contract differs; uses
    only test-local memory and immutable schema fixtures.
    """
    profile = inventory_profile(analyzer_catalog)
    store = MemoryStore()
    store.put("src/a", b"original")
    store.metadata.add("docs", kind="directory")
    monkeypatch.setattr(input_capture, "MAX_CAPTURE_BYTES", 4)
    with pytest.raises(ValueError, match="aggregate byte"):
        read_capture(profile, store)
    monkeypatch.setattr(input_capture, "MAX_CAPTURE_BYTES", 1024)
    calls = 0

    def changed_read(path: str, *, limit: int) -> bytes:
        """Change source bytes only at the explicit freshness comparison boundary.

        Parameters: path (str): workspace-relative input path. limit (int): maximum
        requested byte count.

        Returns bytes selected by the local call counter; increments that counter
        only. Performs no real I/O.
        """
        nonlocal calls
        calls += 1
        return b"original" if calls == 1 else b"modified"

    with pytest.raises(OSError, match="changed"):
        capture_inputs(
            profile,
            workspace_root="/workspace",
            metadata=store.metadata,
            read_bytes=changed_read,
        )


def test_path_aliases_and_links_are_rejected_without_dereference(
    analyzer_catalog: SchemaCatalog,
) -> None:
    """Unsafe namespace states cannot be represented as ordinary unreadable source
    files.

    Parameters: analyzer_catalog (SchemaCatalog): immutable installed schema
    fixture.

    Returns None. Raises AssertionError when the asserted contract differs; uses
    only test-local memory and immutable schema fixtures.
    """
    profile = inventory_profile(analyzer_catalog)
    store = MemoryStore()
    store.put("src/A.cs", b"a")
    store.put("src/a.cs", b"b")
    with pytest.raises(PathPolicyError):
        read_capture(profile, store)
    store = MemoryStore()
    store.metadata.add("src/link", kind="symlink")
    with pytest.raises(PathPolicyError, match="PATH_LINK"):
        read_capture(profile, store)
    assert not store.calls


def test_snapshot_capture_retains_exclusions_without_inventing_payload_inputs(
    analyzer_catalog: SchemaCatalog,
) -> None:
    """Existing artifact/evidence bytes remain outside source inventory.

    Parameters: analyzer_catalog (SchemaCatalog): immutable installed schema
    fixture.

    Returns None. Raises AssertionError when the asserted contract differs; uses
    only test-local memory and immutable schema fixtures.
    """
    profile = inventory_profile(
        analyzer_catalog,
        excluded_paths=[{"path_or_glob": "src/vendor/**", "rationale": "Dependency."}],
    )
    payload = SnapshotFile(
        path="docs/migration/discovery/evidence/proof.bin",
        content=b"proof",
        category="evidence",
    )
    snapshot = replace(
        captured(profile, analyzer_catalog, payloads=(payload,)),
        excluded_paths=("src/vendor",),
    )
    result = capture_snapshot(snapshot)
    assert result.inputs == (
        InventoryInput(path="src/vendor", status="excluded", rationale="Dependency."),
    )
    with pytest.raises(ValueError, match="no configured rationale"):
        capture_snapshot(replace(snapshot, excluded_paths=("src/unexplained",)))


class MemoryRepository:
    """Supply explicit immutable local Git inputs with no process or filesystem I/O."""

    def __init__(self, profile: ProfileV2, files: dict[str, bytes]) -> None:
        """Bind one independent repository identity and exact synthetic blob
        dictionary.

        Parameters: profile (ProfileV2): validated local-source configuration. files
        (dict[str, bytes]): test-local immutable Git blob mapping.

        Returns None; initializes only private synthetic reader state. Invalid
        identities raise ValueError; no I/O occurs.
        """
        self.local = RepositoryIdentity(
            id=profile.repository.id, revision=profile.repository.revision
        )
        self.files = files
        self.calls: list[str] = []
        self.wrong_path = False

    def identity(self) -> RepositoryIdentity:
        """Return the configured synthetic checkout identity without inferring it.

        Takes no caller arguments.

        Returns RepositoryIdentity retained by the fixture. No I/O or mutation
        occurs.
        """
        return self.local

    def read_file(self, *, revision: str, path: str, limit: int) -> RepositoryFile:
        """Return exact pinned bytes and retain requested paths/limits for
        assertions.

        Parameters: revision (str): full configured Git revision. path (str):
        workspace-relative input path. limit (int): maximum requested byte count.

        Returns RepositoryFile containing exact immutable fixture bytes. Raises
        FileNotFoundError for absent blobs or AssertionError for invalid requests;
        appends only to the fixture call list.
        """
        assert revision == self.local.revision and limit > 0
        self.calls.append(path)
        if path not in self.files:
            raise FileNotFoundError(path)
        return RepositoryFile(
            repository=self.local,
            path="docs/wrong" if self.wrong_path else path,
            content=self.files[path],
        )


def test_pin_capture_preserves_existing_objects_and_refuses_missing_or_foreign_pins(
    analyzer_catalog: SchemaCatalog,
) -> None:
    """Publication precapture is idempotent and never substitutes working-copy bytes.

    Parameters: analyzer_catalog (SchemaCatalog): immutable installed schema
    fixture.

    Returns None. Raises AssertionError when the asserted contract differs; uses
    only test-local memory and immutable schema fixtures.
    """
    profile = inventory_profile(analyzer_catalog)
    source = SnapshotFile(
        path="docs/guide.md", content=b"guide", category="documentation"
    )
    snapshot = captured(profile, analyzer_catalog, payloads=(source,))
    store = MemoryStore()
    workspace = CapturedWorkspace(
        workspace_root="/workspace",
        snapshot=snapshot,
        metadata=((".", store.metadata(".")),),
    )
    repository = MemoryRepository(profile, {source.path: source.content})
    first = pin_inventory_sources(workspace, repository)
    assert first.snapshot.repository_files[0].content == source.content
    assert pin_inventory_sources(first, repository) == first
    assert repository.calls == [source.path]
    repository.wrong_path = True
    with pytest.raises(ValueError, match="unexpected object"):
        pin_inventory_sources(workspace, repository)
    repository.wrong_path = False
    repository.files.clear()
    with pytest.raises(FileNotFoundError):
        pin_inventory_sources(workspace, repository)
    repository.local = RepositoryIdentity(id="other", revision="b" * 40)
    with pytest.raises(ValueError, match="configured local pin"):
        pin_inventory_sources(workspace, repository)
