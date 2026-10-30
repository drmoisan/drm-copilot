"""Test bounded file capture and profile bootstrap with isolated memory adapters."""

from __future__ import annotations

import json
from dataclasses import replace
from typing import TYPE_CHECKING, cast

import pytest
from drm_copilot_discovery.catalog import load_catalog
from drm_copilot_discovery.path_models import PathPolicyError
from drm_copilot_discovery.profile_v2 import ProfileV2
from drm_copilot_discovery.snapshot_io import SnapshotIO, document_format, within_roots

from tests.discovery_runtime.test_path_resolution import MemoryPaths
from tests.discovery_runtime.test_profile_v2 import profile_document
from tests.schemas.discovery.v2_schema_test_support import as_object

if TYPE_CHECKING:
    from drm_copilot_discovery.catalog import SchemaCatalog
    from drm_copilot_discovery.path_models import PathKind

PROFILE_PATH = "docs/migration/discovery/domain-profile.yaml"


class MemoryStore:
    """Keep metadata and bytes private to one test; never open a real file."""

    def __init__(self, workspace: str = "/workspace") -> None:
        """Create isolated immutable-byte storage with observable bounded reads."""
        self.metadata = MemoryPaths(workspace)
        self.files: dict[str, bytes] = {}
        self.calls: list[tuple[str, int]] = []
        self.failures: set[str] = set()

    def put(self, path: str, content: bytes) -> None:
        """Add one memory file while maintaining complete immediate child names."""
        self.files[path] = content
        self.metadata.add(path)

    def read(self, path: str, *, limit: int) -> bytes:
        """Return stored bytes or an injected failure, with no implicit truncation."""
        self.calls.append((path, limit))
        if path in self.failures:
            raise PermissionError("synthetic read failure")
        return self.files[path]

    def io(self, *, max_entries: int = 1000000, max_depth: int = 64) -> SnapshotIO:
        """Create fresh load state over this test's trusted fake workspace."""
        return SnapshotIO(
            workspace_root=self.metadata.root.as_posix(),
            metadata=self.metadata,
            read_bytes=self.read,
            max_entries=max_entries,
            max_depth=max_depth,
        )


@pytest.fixture(scope="module")
def snapshot_catalog() -> SchemaCatalog:
    """Reuse only immutable installed schemas; mutable stores remain test-local."""
    return load_catalog()


def memory_workspace() -> tuple[MemoryStore, dict[str, object]]:
    """Build a minimal source profile with independent configuration and bytes."""
    document = profile_document()
    as_object(document["system"])["role"] = "legacy-source"
    document["repositories"], document["clients"] = [], []
    document["project_entry_points"] = []
    store = MemoryStore()
    store.put(PROFILE_PATH, json.dumps(document).encode())
    return store, document


def test_capture_hash_input_is_read_once_and_freshness_reads_do_not_replace_it() -> (
    None
):
    """Freshness checks compare bytes without replacing the original capture."""
    store = MemoryStore()
    store.put("src/a.py", b"exact\r\nbytes")
    io = store.io()
    assert io.read("src/a.py", limit=100) == b"exact\r\nbytes"
    assert io.read("src/a.py", limit=80) == b"exact\r\nbytes"
    assert len(store.calls) == 1
    io.verify_unchanged()
    assert store.calls[-1] == ("src/a.py", 80)
    assert io.captured == (("src/a.py", b"exact\r\nbytes"),)


@pytest.mark.parametrize("change", ["bytes", "addition", "deletion", "replacement"])
def test_freshness_rejects_every_material_change(change: str) -> None:
    """File edits and namespace/identity changes cannot leave a valid snapshot."""
    store = MemoryStore()
    store.put("src/a.py", b"original")
    io = store.io()
    io.enumerate(("src",))
    io.read("src/a.py", limit=100)
    if change == "bytes":
        store.files["src/a.py"] = b"edited"
    elif change == "addition":
        store.put("src/.new", b"new")
    elif change == "deletion":
        store.metadata.remove("src/a.py")
    else:
        store.metadata.entries["src/a.py"] = replace(
            store.metadata.entries["src/a.py"], identity="replacement"
        )
    with pytest.raises(OSError, match="changed"):
        io.verify_unchanged()
    assert io.captured[0][1] == b"original"


def test_deterministic_enumeration_includes_hidden_files_and_records_exclusion() -> (
    None
):
    """Overlapping roots, input ordering and hidden names do not omit selected files."""
    store = MemoryStore()
    # Creation order differs from ordinal traversal order intentionally.
    for path in ("src/z", "src/.hidden", "src/sub/a", "src/ignore"):
        store.put(path, path.encode())
    io = store.io()
    assert io.enumerate(
        ("src/sub", "src"), exclude=lambda path: path == "src/ignore"
    ) == ("src/.hidden", "src/sub/a", "src/z")
    assert io.excluded_paths == ("src/ignore",)


@pytest.mark.parametrize("options", [{"max_entries": 1}, {"max_depth": 1}])
def test_enumeration_enforces_finite_entry_and_depth_limits(
    options: dict[str, int],
) -> None:
    """Wide and deep input trees fail explicitly rather than truncate silently."""
    store = MemoryStore()
    store.put("src/sub/a", b"a")
    with pytest.raises(OSError, match="limit"):
        store.io(**options).enumerate(("src",))


@pytest.mark.parametrize(
    "options",
    [{"max_entries": 0}, {"max_entries": True}, {"max_depth": 0}, {"max_depth": 129}],
)
def test_invalid_enumeration_limits_fail_at_construction(
    options: dict[str, int],
) -> None:
    """Invalid caller budgets cannot create unbounded traversal state."""
    with pytest.raises(ValueError, match="must be between"):
        MemoryStore().io(**options)


@pytest.mark.parametrize("limit", [0, 67108865, True])
def test_invalid_read_limits_fail_before_any_byte_read(limit: int) -> None:
    """A caller cannot suppress byte ceilings through zero or boolean values."""
    store = MemoryStore()
    with pytest.raises(ValueError, match="byte limits"):
        store.io().read("src/a", limit=limit)
    assert not store.calls


def test_missing_paths_and_directory_reads_are_explicit() -> None:
    """Missing inputs are recorded; neither absence nor a directory becomes bytes."""
    store = MemoryStore()
    store.metadata.add("src", "directory")
    io = store.io()
    assert io.read("src/missing", limit=100, required=False) is None
    assert io.missing_paths == ("src/missing",)
    with pytest.raises(FileNotFoundError, match="Required snapshot"):
        io.read("src/missing", limit=100)
    with pytest.raises(OSError, match="ordinary snapshot file"):
        io.read("src", limit=100)


def test_read_errors_byte_limits_and_file_count_are_not_silently_skipped() -> None:
    """All adapter/read/count failures stop the snapshot instead of hiding inputs."""
    store = MemoryStore()
    store.put("src/a", b"abc")
    store.put("src/b", b"def")
    store.failures.add("src/a")
    with pytest.raises(PermissionError):
        store.io().read("src/a", limit=100)
    store.failures.clear()
    with pytest.raises(OSError, match="byte limit"):
        store.io().read("src/a", limit=2)
    io = store.io(max_entries=1)
    io.read("src/a", limit=100)
    with pytest.raises(OSError, match="enumeration limit"):
        io.read("src/b", limit=100)
    store.files["src/a"] = cast("bytes", bytearray(b"bad"))
    with pytest.raises(OSError, match="immutable bytes"):
        store.io().read("src/a", limit=100)


@pytest.mark.parametrize("kind", ["symlink", "reparse", "other"])
def test_bootstrap_rejects_links_before_opening_bytes(kind: str) -> None:
    """The profile bootstrap cannot follow a link before PathPolicy exists."""
    store = MemoryStore()
    store.put("docs/profile.yaml", b"{}")
    store.metadata.entries["docs"] = replace(
        store.metadata.entries["docs"], kind=cast("PathKind", kind), children=()
    )
    with pytest.raises(PathPolicyError, match="PATH_LINK"):
        store.io().read("docs/profile.yaml", limit=100)
    assert not store.calls


@pytest.mark.parametrize(
    "change", ["escape", "cycle", "missing-child", "stale-child", "file-parent"]
)
def test_bootstrap_rejects_inconsistent_physical_paths(change: str) -> None:
    """Metadata cannot substitute aliases, escaped paths or non-directory ancestors."""
    store = MemoryStore()
    store.put("docs/profile.yaml", b"{}")
    if change == "escape":
        store.metadata.entries["docs"] = replace(
            store.metadata.entries["docs"], resolved_path="/other/docs"
        )
    elif change == "cycle":
        store.metadata.entries["docs"] = replace(
            store.metadata.entries["docs"], identity="root"
        )
    elif change == "missing-child":
        store.metadata.entries["docs"] = replace(
            store.metadata.entries["docs"], children=()
        )
    elif change == "stale-child":
        del store.metadata.entries["docs/profile.yaml"]
    else:
        store.metadata.entries["docs"] = replace(
            store.metadata.entries["docs"], kind="file", children=()
        )
    with pytest.raises((PathPolicyError, OSError)):
        store.io().read("docs/profile.yaml", limit=100)
    assert not store.calls


def test_bound_io_uses_accepted_path_policy_and_cannot_be_rebound(
    snapshot_catalog: SchemaCatalog,
) -> None:
    """Configured profile authority applies to both bootstrap and subsequent reads."""
    store, document = memory_workspace()
    profile = ProfileV2(json.dumps(document), format="json", catalog=snapshot_catalog)
    io = store.io()
    io.read(PROFILE_PATH, limit=16777216)
    io.bind(profile)
    assert io.read("src/missing", limit=100, required=False) is None
    assert "src" in io.missing_paths
    with pytest.raises(PathPolicyError, match="PATH_READ_DENIED"):
        io.read("neighbor/file", limit=100)
    with pytest.raises(ValueError, match="fresh SnapshotIO"):
        io.bind(profile)


def test_trusted_windows_workspace_and_portable_format_selection() -> None:
    """Trusted absolute workspace spelling does not depend on the test host OS."""
    store = MemoryStore("C:/workspace")
    store.put("docs/a.json", b"{}")
    assert store.io().read("docs/a.json", limit=10) == b"{}"
    assert document_format("a.json") == "json" and document_format("a.yml") == "yaml"
    assert within_roots("docs/a", ("docs",))
    assert not within_roots("docs-else/a", ("docs",))
    with pytest.raises(ValueError, match="absolute canonical"):
        SnapshotIO(
            workspace_root="relative", metadata=store.metadata, read_bytes=store.read
        )


def test_normalizing_directory_order_preserves_duplicate_detection() -> None:
    """Canonical ordering cannot collapse duplicate or aliased child metadata."""
    store = MemoryStore()
    store.put("docs/a", b"a")
    store.metadata.entries["docs"] = replace(
        store.metadata.entries["docs"], children=("a", "a")
    )
    with pytest.raises(PathPolicyError, match="PATH_COLLISION"):
        store.io().read("docs/a", limit=10)
    assert not store.calls
