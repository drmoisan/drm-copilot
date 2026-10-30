"""Verify source authority, finite resource axes and immutable value boundaries."""

from __future__ import annotations

import json
from dataclasses import FrozenInstanceError, replace
from typing import TYPE_CHECKING, cast

import pytest
from drm_copilot_discovery.path_models import PathPolicyError
from drm_copilot_discovery.profile_v2 import parse_profile_v2
from drm_copilot_discovery.repository_reader import RepositoryIdentity
from drm_copilot_discovery.source_read_models import (
    ReadCursor,
    ReadGrant,
    ReadSelection,
    SelectedManifest,
    SourceEvidence,
    SourceItem,
    SourceReadLimits,
    SourceReadRequest,
    SourceReadResult,
    SourceSpan,
)

from tests.discovery_runtime.test_profile_v2 import profile_document
from tests.discovery_runtime.test_snapshot_io import MemoryStore
from tests.discovery_runtime.test_source_reads import make_reader
from tests.discovery_runtime.test_source_reads import read_catalog as read_catalog
from tests.discovery_runtime.test_source_reads import read_profile as read_profile

if TYPE_CHECKING:
    from drm_copilot_discovery.catalog import SchemaCatalog
    from drm_copilot_discovery.path_models import PathKind
    from drm_copilot_discovery.profile_v2 import ProfileV2

_EVIDENCE = SourceEvidence(
    workspace_path="src/a",
    path="src/a",
    repository=RepositoryIdentity(id="local", revision=None),
    sha256="a" * 64,
    size=0,
    provenance="working-file",
)
_ITEM = SourceItem(evidence=_EVIDENCE)
_RESULT = SourceReadResult(
    operation="list",
    items=(_ITEM,),
    total=1,
    inspection_sha256="b" * 64,
    next_cursor=None,
    input_bytes=0,
    entries=1,
)

_GRANT = ReadGrant(path="src/a")
_SELECTION = ReadSelection(grants=(_GRANT,))
_MANIFEST = SelectedManifest(path="docs/s/manifest.json", sha256="a" * 64)
_CURSOR = ReadCursor(inspection_sha256="a" * 64, offset=1)
_SPAN = SourceSpan(line=1, column_start=1, column_end=1)


@pytest.mark.parametrize(
    "changes",
    (
        {"entries": 0},
        {"depth": 129},
        {"file_bytes": True},
        {"input_bytes": 67108865},
        {"output_bytes": 0},
        {"lines": -1},
        {"line_bytes": 1048577},
        {"matches": 100001},
        {"query_bytes": 4097},
    ),
)
def test_limits_reject_unbounded_or_coerced_axes(changes: dict[str, object]) -> None:
    """Reject each invalid independent limit with ValueError; return None.
    changes:dict[str, object]; None; memory only."""
    with pytest.raises(ValueError, match="integer between"):
        replace(SourceReadLimits(), **changes)


@pytest.mark.parametrize(
    "changes",
    (
        {"operation": "execute"},
        {"regex": True},
        {"regex": 0},
        {"paths": "src/a"},
        {"paths": ()},
        {"paths": ("src/A", "src/a")},
        {"paths": ("../secret",)},
        {"paths": ("C:/secret",)},
        {"paths": ("src\\secret",)},
        {"paths": ("src/NUL",)},
        {"line_start": False},
        {"line_end": 0},
        {"line_start": 2, "line_end": 1},
        {"page_size": 1001},
        {"cursor": "opaque"},
        {"query": "unexpected"},
        {"operation": "search", "query": ""},
        {"operation": "search"},
        {"operation": "search", "query": "a\nb"},
        {"operation": "search", "query": "a\rb"},
        {"operation": "search", "query": "a\u2028b"},
        {"operation": "search", "query": "\ud800"},
        {"operation": "search", "query": "a" * 4097},
    ),
)
def test_requests_reject_execution_aliases_regex_and_invalid_ranges(
    changes: dict[str, object],
) -> None:
    """Keep requests closed and single-line before I/O; return None on rejection.
    changes:dict[str, object]; None; memory only."""
    with pytest.raises(ValueError):
        replace(SourceReadRequest(operation="read", paths=("src/a",)), **changes)


@pytest.mark.parametrize(
    "model,changes",
    (
        (_GRANT, {"directory": "yes"}),
        (_MANIFEST, {"path": "docs/s/header.json"}),
        (_MANIFEST, {"sha256": "A" * 64}),
        (_SELECTION, {"grants": ()}),
        (_SELECTION, {"grants": ("src/a",)}),
        (_SELECTION, {"manifests": ("docs/a",)}),
        (_SELECTION, {"grants": (_GRANT,) * 2}),
        (_SELECTION, {"manifests": (_MANIFEST,) * 1001}),
        (_CURSOR, {"inspection_sha256": 1}),
        (_CURSOR, {"offset": 0}),
        (_SPAN, {"column_start": 2}),
        (_EVIDENCE, {"repository": "local"}),
        (_EVIDENCE, {"size": -1}),
        (_EVIDENCE, {"provenance": "configured-pin"}),
        (_EVIDENCE, {"provenance": "snapshot-member"}),
        (_EVIDENCE, {"manifest_sha256": "b" * 64}),
        (_EVIDENCE, {"path": "other/a"}),
        (_EVIDENCE, {"repository": RepositoryIdentity(id="local", revision="a" * 40)}),
        (_ITEM, {"evidence": "bad"}),
        (_ITEM, {"text": 3}),
        (_ITEM, {"span": "bad"}),
        (_ITEM, {"span": _SPAN}),
        (_RESULT, {"operation": "execute"}),
        (_RESULT, {"entries": -1}),
        (_RESULT, {"items": ("bad",)}),
        (_RESULT, {"total": 0}),
        (_RESULT, {"next_cursor": "bad"}),
        (_RESULT, {"next_cursor": _CURSOR}),
        (_RESULT, {"next_cursor": ReadCursor(inspection_sha256="b" * 64, offset=1)}),
    ),
)
def test_immutable_contracts_reject_malformed_values(
    model: (
        ReadGrant
        | SelectedManifest
        | ReadSelection
        | ReadCursor
        | SourceSpan
        | SourceEvidence
        | SourceItem
        | SourceReadResult
    ),
    changes: dict[str, object],
) -> None:
    """Change one immutable field into invalid input and require explicit failure.
    model:immutable discovery dataclass; changes:dict[str, object]; None; memory
    only."""
    with pytest.raises(ValueError):
        replace(model, **changes)


def test_values_are_frozen_and_zero_width_empty_line_span_is_valid() -> None:
    """Preserve immutable authority and deterministic JSON; return None.
    None; memory only."""
    grant = _GRANT
    attribute = "path"
    with pytest.raises(FrozenInstanceError):
        setattr(grant, attribute, "src/b")
    span = _SPAN
    assert span.column_start == span.column_end
    assert (
        json.loads(_RESULT.encode())["items"][0]["evidence"]["repository"]["revision"]
        is None
    )


@pytest.mark.parametrize(
    "axis,value,content,query",
    (
        ("file_bytes", 3, b"1234", None),
        ("input_bytes", 6, b"1234", None),
        ("input_bytes", 4, b"1234", None),
        ("lines", 1, b"a\nb", None),
        ("line_bytes", 3, b"a\r\nbbbb", None),
        ("matches", 1, b"aa", "a"),
        ("query_bytes", 1, b"aa", "aa"),
        ("output_bytes", 1, b"a", None),
        ("output_bytes", 300, b"a", None),
    ),
)
def test_independent_limits_fail_without_partial_output(
    read_profile: ProfileV2,
    read_catalog: SchemaCatalog,
    axis: str,
    value: int,
    content: bytes,
    query: str | None,
) -> None:
    """Bound every data axis, including freshness bytes and JSON metadata.
    ProfileV2/SchemaCatalog fixtures; axis:str; value:int; content:bytes; query:str
    | None; None; memory only."""
    store = MemoryStore()
    store.put("src/a", content)
    limits = replace(SourceReadLimits(), **{axis: value})
    request = SourceReadRequest(
        operation="search" if query else "read", paths=("src/a",), query=query
    )
    with pytest.raises(OSError, match="limit"):
        make_reader(store, read_profile, read_catalog, limits=limits).inspect(request)


def test_match_and_line_limits_are_aggregate_across_files(
    read_profile: ProfileV2,
    read_catalog: SchemaCatalog,
) -> None:
    """Prevent per-file resets from bypassing global observation bounds.
    ProfileV2/SchemaCatalog fixtures; None; memory only."""
    store = MemoryStore()
    store.put("src/a", b"x")
    store.put("src/b", b"x")
    request = SourceReadRequest(operation="search", paths=("src",), query="x")
    with pytest.raises(OSError, match="aggregate literal match"):
        make_reader(
            store, read_profile, read_catalog, limits=SourceReadLimits(matches=1)
        ).inspect(request)
    with pytest.raises(OSError, match="decoded line"):
        make_reader(
            store, read_profile, read_catalog, limits=SourceReadLimits(lines=1)
        ).inspect(request)


@pytest.mark.parametrize(
    "fault", ("depth", "metadata-count", "child-count", "queued-count", "profile-count")
)
def test_enumeration_is_bounded_before_any_bytes_are_read(
    read_profile: ProfileV2,
    read_catalog: SchemaCatalog,
    fault: str,
) -> None:
    """Bound path depth, queued entries and metadata through fresh memory stores.
    ProfileV2/SchemaCatalog fixtures; fault:str; None; memory only."""
    store = MemoryStore()
    store.put("src/a/one", b"1")
    store.put("src/b/two", b"2")
    limits, profile = SourceReadLimits(), read_profile
    # Select the smallest bound that exercises the named independent path axis.
    if fault == "depth":
        limits = replace(limits, depth=2)
    elif fault in {"metadata-count", "queued-count"}:
        limits = replace(limits, entries=2 if fault == "metadata-count" else 3)
    elif fault == "child-count":
        store.put("src/c", b"3")
        limits = replace(limits, entries=2)
    else:
        document = profile_document()
        document["limits"] = {"source_files": 2}
        profile = parse_profile_v2(json.dumps(document), catalog=read_catalog)
    with pytest.raises(OSError, match="limit"):
        make_reader(store, profile, read_catalog, limits=limits).inspect(
            SourceReadRequest(
                operation="list",
                paths=("src/a/one",) if fault == "metadata-count" else ("src",),
            )
        )
    assert store.calls == []


@pytest.mark.parametrize(
    "fault", ("symlink", "reparse", "alias", "metadata-error", "missing")
)
def test_physical_path_failures_cannot_cross_workspace_boundaries(
    read_profile: ProfileV2,
    read_catalog: SchemaCatalog,
    fault: str,
) -> None:
    """Reuse accepted metadata policy for hostile native paths; return None.
    ProfileV2/SchemaCatalog fixtures; fault:str; None; memory only."""
    store = MemoryStore()
    store.put("src/a", b"secret")
    # Metadata is the only seam altered; no test creates a physical link or file.
    if fault in {"symlink", "reparse"}:
        store.metadata.add("src/a", kind=cast("PathKind", fault))
    elif fault == "alias":
        store.metadata.add("src/a", actual="/elsewhere/a")
    elif fault == "metadata-error":
        store.metadata.failures.add("src/a")
    else:
        store.metadata.remove("src/a")
    with pytest.raises((PathPolicyError, OSError)):
        make_reader(store, read_profile, read_catalog).inspect(
            SourceReadRequest(operation="read", paths=("src/a",))
        )
    assert store.calls == []


def test_json_output_budget_pages_complete_rows_without_loss(
    read_profile: ProfileV2,
    read_catalog: SchemaCatalog,
) -> None:
    """Return only complete rows fitting actual UTF-8 JSON, then continue exactly.
    ProfileV2/SchemaCatalog fixtures; None; memory only."""
    store = MemoryStore()
    store.put("src/a", ("α" * 80 + "\n").encode() * 3)
    reader = make_reader(
        store, read_profile, read_catalog, limits=SourceReadLimits(output_bytes=1000)
    )
    request = SourceReadRequest(operation="read", paths=("src/a",), page_size=100)
    first = reader.inspect(request)
    assert len(first.encode()) <= 1000 and len(first.items) == 1
    second = reader.inspect(replace(request, cursor=first.next_cursor))
    third = reader.inspect(replace(request, cursor=second.next_cursor))
    # Flatten pages to prove every source line appears exactly once and in order.
    assert tuple(
        item.span.line
        for page in (first, second, third)
        for item in page.items
        if item.span
    ) == (1, 2, 3)
    assert third.next_cursor is None


@pytest.mark.parametrize("change", ("bytes", "request", "selection", "offset"))
def test_continuation_rejects_changed_content_authority_or_request(
    read_profile: ProfileV2,
    read_catalog: SchemaCatalog,
    change: str,
) -> None:
    """Bind pagination to its original full inspection, not a freely reusable offset.
    ProfileV2/SchemaCatalog fixtures; change:str; None; memory only."""
    store = MemoryStore()
    store.put("src/a", b"one\ntwo")
    reader = make_reader(store, read_profile, read_catalog)
    request = SourceReadRequest(operation="read", paths=("src/a",), page_size=1)
    first = reader.inspect(request)
    request = replace(request, cursor=first.next_cursor)
    # Each change invalidates a different part of the continuation binding.
    if change == "bytes":
        store.put("src/a", b"different\ntwo")
    elif change == "request":
        request = replace(request, line_start=2)
    elif change == "selection":
        reader = make_reader(
            store,
            read_profile,
            read_catalog,
            selection=_SELECTION,
        )
    else:
        request = replace(
            request,
            cursor=ReadCursor(inspection_sha256=first.inspection_sha256, offset=10),
        )
    with pytest.raises(ValueError, match="continuation"):
        reader.inspect(request)


def test_entry_addition_during_read_fails_freshness_without_partial_page(
    read_profile: ProfileV2,
    read_catalog: SchemaCatalog,
) -> None:
    """Detect changed parent enumeration using only an injected in-memory read.
    ProfileV2/SchemaCatalog fixtures; None; memory only."""
    store = MemoryStore()
    store.put("src/a", b"one")

    def adding(path: str, *, limit: int) -> bytes:
        """Read str path with int limit; return its bytes from the isolated store.
        Intentionally add an in-memory sibling to trigger freshness rejection;
        propagate fake read errors without accessing physical files.
        """
        store.put("src/new", b"new")
        return store.read(path, limit=limit)

    with pytest.raises(OSError, match="metadata changed"):
        make_reader(store, read_profile, read_catalog, read_bytes=adding).inspect(
            SourceReadRequest(operation="read", paths=("src/a",))
        )


def test_selection_order_does_not_change_content_bound_continuation(
    read_profile: ProfileV2,
    read_catalog: SchemaCatalog,
) -> None:
    """Normalize equal host selections before identity hashing; return None.
    ProfileV2/SchemaCatalog fixtures; None; memory only."""
    store = MemoryStore()
    store.put("src/a", b"one\ntwo")
    grant_a, grant_b = ReadGrant(path="src/a"), ReadGrant(path="docs/a")
    request = SourceReadRequest(operation="read", paths=("src/a",), page_size=1)
    first = make_reader(
        store,
        read_profile,
        read_catalog,
        selection=ReadSelection(grants=(grant_b, grant_a)),
    ).inspect(request)
    second = make_reader(
        store,
        read_profile,
        read_catalog,
        selection=ReadSelection(grants=(grant_a, grant_b)),
    ).inspect(replace(request, cursor=first.next_cursor))
    assert second.items[0].text == "two"
