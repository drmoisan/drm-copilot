"""Exercise selected source behavior with fresh in-memory metadata and bytes."""

from __future__ import annotations

import json
from dataclasses import replace
from hashlib import sha256
from typing import TYPE_CHECKING, cast

import pytest
from drm_copilot_discovery.catalog import SchemaCatalog, load_catalog
from drm_copilot_discovery.profile_v2 import ProfileV2, parse_profile_v2
from drm_copilot_discovery.source_read_models import (
    ReadGrant,
    ReadSelection,
    SourceReadLimits,
    SourceReadRequest,
)
from drm_copilot_discovery.source_reads import SourceReader

from tests.discovery_runtime.test_profile_v2 import profile_document
from tests.discovery_runtime.test_snapshot_io import MemoryStore

if TYPE_CHECKING:
    from drm_copilot_discovery.snapshot_io import WorkspaceBytes
    from drm_copilot_discovery.source_read_models import ReadOperation


@pytest.fixture(scope="module")
def read_catalog() -> SchemaCatalog:
    """Return SchemaCatalog from committed resources; no mutable fixture state."""
    return load_catalog()


@pytest.fixture(scope="module")
def read_profile(read_catalog: SchemaCatalog) -> ProfileV2:
    """Use SchemaCatalog to return ProfileV2 with a project outside input trees."""
    document = profile_document()
    document["project_entry_points"] = ["build/Example.csproj"]
    return parse_profile_v2(json.dumps(document), format="json", catalog=read_catalog)


def make_reader(
    store: MemoryStore,
    profile: ProfileV2,
    catalog: SchemaCatalog,
    *,
    selection: ReadSelection | None = None,
    limits: SourceReadLimits | None = None,
    read_bytes: WorkspaceBytes | None = None,
) -> SourceReader:
    """Return SourceReader from MemoryStore, ProfileV2 and SchemaCatalog inputs.
    Optional typed selection/limits and WorkspaceBytes override isolate cases;
    no real I/O. Propagate reader contract errors without changing inputs.
    """
    return SourceReader(
        profile,
        catalog=catalog,
        workspace_root=store.metadata.root.as_posix(),
        metadata=store.metadata,
        read_bytes=read_bytes or store.read,
        selection=selection
        or ReadSelection(grants=(ReadGrant(path="src", directory=True),)),
        limits=limits or SourceReadLimits(),
    )


@pytest.mark.parametrize("workspace", ("/workspace", "C:/workspace"))
def test_read_keeps_original_hash_and_exact_unicode_crlf_spans(
    read_profile: ProfileV2,
    read_catalog: SchemaCatalog,
    workspace: str,
) -> None:
    """Read CRLF bytes through either path flavor; return None after span assertions.
    ProfileV2/SchemaCatalog fixtures; workspace:str; None; memory only."""
    store = MemoryStore(workspace)
    content = "first\r\nα needle\r\n\r\nlast".encode()
    store.put("src/source.cs", content)
    result = make_reader(store, read_profile, read_catalog).inspect(
        SourceReadRequest(
            operation="read", paths=("src/source.cs",), line_start=2, line_end=3
        )
    )
    assert tuple(item.text for item in result.items) == ("α needle", "")
    # Compare Unicode columns after newline removal against the original byte hash.
    assert tuple(
        (item.span.line, item.span.column_start, item.span.column_end)
        for item in result.items
        if item.span is not None
    ) == ((2, 1, 9), (3, 1, 1))
    assert result.items[0].evidence.sha256 == sha256(content).hexdigest()
    assert result.items[0].evidence.repository.revision is None
    assert read_profile.repository.revision is not None
    assert result.input_bytes == len(content) * 2
    assert store.files == {"src/source.cs": content}


def test_literal_search_is_case_sensitive_nonoverlapping_and_line_bounded(
    read_profile: ProfileV2,
    read_catalog: SchemaCatalog,
) -> None:
    """Match literal metacharacters and repeated text; return None with no execution.
    ProfileV2/SchemaCatalog fixtures; None; memory only."""
    store = MemoryStore()
    store.put("src/b.cs", b"aaaa\na.*a.*\nA.*")
    reader = make_reader(store, read_profile, read_catalog)
    result = reader.inspect(
        SourceReadRequest(operation="search", paths=("src",), query="a.*", line_start=2)
    )
    # Literal matches retain one-based, end-exclusive columns on their source line.
    assert tuple(
        (item.span.line, item.span.column_start, item.span.column_end)
        for item in result.items
        if item.span is not None
    ) == ((2, 1, 4), (2, 4, 7))
    assert tuple(item.text for item in result.items) == ("a.*", "a.*")
    repeated = reader.inspect(
        SourceReadRequest(operation="search", paths=("src/b.cs",), query="aa")
    )
    assert repeated.total == 2


def test_listing_is_sorted_deduplicated_and_repeated_pages_are_identical(
    read_profile: ProfileV2,
    read_catalog: SchemaCatalog,
) -> None:
    """List overlapping selected roots deterministically; return None after paging.
    ProfileV2/SchemaCatalog fixtures; None; memory only."""
    store = MemoryStore()
    # Deliberately install files in reverse lexical order to exercise stable traversal.
    for path in ("src/z.cs", "src/sub/b.cs", "src/a.cs"):
        store.put(path, b"text")
    reader = make_reader(store, read_profile, read_catalog)
    request = SourceReadRequest(operation="list", paths=("src", "src/sub"), page_size=2)
    first = reader.inspect(request)
    assert tuple(item.evidence.path for item in first.items) == (
        "src/a.cs",
        "src/sub/b.cs",
    )
    assert first.encode() == reader.inspect(request).encode()
    second = reader.inspect(replace(request, cursor=first.next_cursor))
    assert tuple(item.evidence.path for item in second.items) == ("src/z.cs",)
    assert second.next_cursor is None and second.total == 3
    assert first.inspection_sha256 == second.inspection_sha256


@pytest.mark.parametrize(
    "path", ("src/b.cs", "src/a.cs/child", "src-extra/a.cs", "private/a.cs")
)
def test_unselected_or_unconfigured_requests_never_read_target_bytes(
    read_profile: ProfileV2,
    read_catalog: SchemaCatalog,
    path: str,
) -> None:
    """Reject siblings, descendants and missing profile authority before I/O.
    ProfileV2/SchemaCatalog fixtures; path:str; None; memory only."""
    store = MemoryStore()
    store.put(path, b"private")
    selection = ReadSelection(
        grants=(ReadGrant(path="src/a.cs"), ReadGrant(path="private/a.cs"))
    )
    with pytest.raises(ValueError, match="not selected and configured"):
        make_reader(store, read_profile, read_catalog, selection=selection).inspect(
            SourceReadRequest(operation="read", paths=(path,))
        )
    assert store.calls == [] and store.metadata.calls == []


def test_all_paths_are_authorized_before_any_requested_file_is_read(
    read_profile: ProfileV2,
    read_catalog: SchemaCatalog,
) -> None:
    """Reject a later unselected request without reading an earlier selected file.
    ProfileV2/SchemaCatalog fixtures; None; memory only."""
    store = MemoryStore()
    store.put("src/a.cs", b"valid")
    with pytest.raises(ValueError, match="not selected"):
        make_reader(store, read_profile, read_catalog).inspect(
            SourceReadRequest(operation="read", paths=("src/a.cs", "private/x"))
        )
    assert store.calls == []


def test_project_entries_are_exact_files_and_do_not_expose_siblings(
    read_profile: ProfileV2,
    read_catalog: SchemaCatalog,
) -> None:
    """Read one configured project, deny its sibling and directory impersonation.
    ProfileV2/SchemaCatalog fixtures; None; memory only."""
    store = MemoryStore()
    store.put("build/Example.csproj", b"<Project />")
    selection = ReadSelection(grants=(ReadGrant(path="build", directory=True),))
    reader = make_reader(store, read_profile, read_catalog, selection=selection)
    assert (
        reader.inspect(
            SourceReadRequest(operation="read", paths=("build/Example.csproj",))
        ).total
        == 1
    )
    with pytest.raises(ValueError, match="not selected"):
        reader.inspect(SourceReadRequest(operation="list", paths=("build",)))
    store.metadata.remove("build/Example.csproj")
    store.metadata.add("build/Example.csproj/child")
    with pytest.raises(ValueError, match="entry point"):
        reader.inspect(
            SourceReadRequest(operation="list", paths=("build/Example.csproj",))
        )


def test_exclusions_and_unselected_snapshots_are_not_disclosed_by_docs_listing(
    read_profile: ProfileV2,
    read_catalog: SchemaCatalog,
) -> None:
    """List the profile intersection only; return None without excluded byte reads.
    ProfileV2/SchemaCatalog fixtures; None; memory only."""
    store = MemoryStore()
    store.put("docs/guide.md", b"guide")
    store.put("docs/migration/discovery/source-snapshots/unselected/secret", b"hidden")
    store.put("src/vendor/private.cs", b"hidden")
    store.put("src/main.cs", b"source")
    selection = ReadSelection(
        grants=(
            ReadGrant(path="docs", directory=True),
            ReadGrant(path="src", directory=True),
        )
    )
    result = make_reader(
        store, read_profile, read_catalog, selection=selection
    ).inspect(SourceReadRequest(operation="list", paths=("docs", "src")))
    assert tuple(item.evidence.path for item in result.items) == (
        "docs/guide.md",
        "src/main.cs",
    )
    assert {path for path, _ in store.calls} == {"docs/guide.md", "src/main.cs"}


@pytest.mark.parametrize("operation", ("read", "search", "list"))
def test_empty_file_and_utf8_binary_listing_have_defined_results(
    read_profile: ProfileV2,
    read_catalog: SchemaCatalog,
    operation: str,
) -> None:
    """Keep empty metadata, return no empty matches and permit binary inventory.
    ProfileV2/SchemaCatalog fixtures; operation:str; None; memory only."""
    store = MemoryStore()
    store.put("src/empty", b"")
    request = SourceReadRequest(
        operation=cast("ReadOperation", operation),
        paths=("src/empty",),
        query="value" if operation == "search" else None,
    )
    result = make_reader(store, read_profile, read_catalog).inspect(request)
    assert result.total == (0 if operation == "search" else 1)
    if result.items:
        assert result.items[0].span is None
    store.put("src/empty", b"\xff\x00")
    # Listing reports bytes; text operations must reject an undecodable source.
    if operation == "list":
        assert (
            make_reader(store, read_profile, read_catalog)
            .inspect(request)
            .items[0]
            .text
            is None
        )
    else:
        with pytest.raises(ValueError, match="strict UTF-8"):
            make_reader(store, read_profile, read_catalog).inspect(request)


@pytest.mark.parametrize(
    "fault", ("changed-bytes", "changed-metadata", "read-error", "mutable-bytes")
)
def test_read_adapter_failure_or_changed_input_returns_no_partial_result(
    read_profile: ProfileV2,
    read_catalog: SchemaCatalog,
    fault: str,
) -> None:
    """Inject one isolated adapter fault; return None after fail-closed assertions.
    ProfileV2/SchemaCatalog fixtures; fault:str; None; memory only."""
    store = MemoryStore()
    store.put("src/a", b"original")
    calls = 0

    def unstable(path: str, *, limit: int) -> bytes:
        """Read str path with int limit; return bytes or raise PermissionError.
        Count calls and intentionally alter in-memory bytes/metadata for one fault;
        mutable-bytes deliberately violates the adapter contract. No physical I/O.
        """
        nonlocal calls
        calls += 1
        # Each branch models a different trusted-adapter contract violation.
        if fault == "read-error":
            raise PermissionError("blocked")
        if fault == "mutable-bytes":
            return cast("bytes", bytearray(b"original"))
        if fault == "changed-metadata":
            store.metadata.add(path, identity="replacement")
        return (
            b"changed"
            if fault == "changed-bytes" and calls > 1
            else store.read(path, limit=limit)
        )

    with pytest.raises(OSError):
        make_reader(store, read_profile, read_catalog, read_bytes=unstable).inspect(
            SourceReadRequest(operation="read", paths=("src/a",))
        )


def test_exact_file_grant_and_read_operation_reject_directory_expansion(
    read_profile: ProfileV2,
    read_catalog: SchemaCatalog,
) -> None:
    """Reject directory reads and a directory masquerading as a file grant.
    ProfileV2/SchemaCatalog fixtures; None; memory only."""
    store = MemoryStore()
    store.put("src/sub/a", b"a")
    with pytest.raises(ValueError, match="Read requires exact files"):
        make_reader(store, read_profile, read_catalog).inspect(
            SourceReadRequest(operation="read", paths=("src",))
        )
    selection = ReadSelection(grants=(ReadGrant(path="src/sub"),))
    with pytest.raises(ValueError, match="exact file selection"):
        make_reader(store, read_profile, read_catalog, selection=selection).inspect(
            SourceReadRequest(operation="list", paths=("src/sub",))
        )
    assert store.calls == []


def test_unconfigured_profile_fails_before_read_authority_is_used(
    read_catalog: SchemaCatalog,
) -> None:
    """Reject structurally valid draft configuration without accessing source bytes.
    SchemaCatalog fixtures; None; memory only."""
    document = profile_document()
    document["profile_state"] = "draft"
    profile = parse_profile_v2(json.dumps(document), catalog=read_catalog)
    store = MemoryStore()
    with pytest.raises(ValueError, match="Draft configuration"):
        make_reader(store, profile, read_catalog)
    assert store.calls == []


def test_invalid_typed_reader_inputs_are_rejected_before_io(
    read_profile: ProfileV2,
    read_catalog: SchemaCatalog,
) -> None:
    """Reject wrapper misuse at the native reader boundary without coercion.
    ProfileV2/SchemaCatalog fixtures; None; memory only."""
    store = MemoryStore()
    with pytest.raises(ValueError, match="typed host selection"):
        make_reader(
            store, read_profile, read_catalog, selection=cast("ReadSelection", "bad")
        )
    with pytest.raises(ValueError, match="typed host selection"):
        make_reader(
            store, read_profile, read_catalog, limits=cast("SourceReadLimits", "bad")
        )
    with pytest.raises(ValueError, match="typed source inspection"):
        make_reader(store, read_profile, read_catalog).inspect(
            cast("SourceReadRequest", "bad")
        )
    assert store.calls == []
