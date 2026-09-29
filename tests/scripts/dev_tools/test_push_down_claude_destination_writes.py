"""Tests for the destination write decorators and extension seams (issue #507).

Every filesystem is the in-memory ``RecordingFileSystem`` and every destination
layout is described by an injected lister; no test touches the real filesystem.
"""

from __future__ import annotations

import ast
import importlib
import json
from pathlib import Path
from typing import TYPE_CHECKING

import pytest

from scripts.dev_tools import push_down_claude_destination_writes as writes
from scripts.dev_tools.push_down_claude_blast_radius_derive_core import (
    BlastRadiusGuardError,
    DirectoryObservation,
)
from scripts.dev_tools.push_down_claude_destination_writes import (
    MERGED_RELATIVE_PATHS,
    BlastRadiusDeriveFileSystem,
    BundleConfigFileSystem,
    DestinationMergeFileSystem,
    build_destination_write_stack,
)
from scripts.dev_tools.push_down_claude_routing_merge import (
    RoutingMergeError,
    merge_routing_documents,
)
from tests.scripts.dev_tools.push_down_customizations_test_support import (
    MemoryFile,
    RecordingFileSystem,
)

if TYPE_CHECKING:
    from collections.abc import Sequence

    from scripts.dev_tools.push_down_claude_blast_radius_derive import (
        DirectoryEntry,
        DirectoryLister,
    )
    from scripts.dev_tools.push_down_copilot_customizations_filesystem import (
        PushDownFileSystem,
    )

REPO_ROOT = Path(__file__).resolve().parents[3]
CUSTOMIZATIONS_SOURCE = "scripts/dev_tools/push_down_claude_customizations.py"
WRITES_SOURCE = REPO_ROOT / "scripts/dev_tools/push_down_claude_destination_writes.py"
DEST = Path("/dest")
ROUTING = DEST / "config" / "orchestration-routing.json"
BLAST = DEST / "config" / "blast-radius.json"
SOURCE_ROOT = Path("/repo")
BUNDLE_ROOT = SOURCE_ROOT / "extensions/drm-copilot/resources/claude-customizations"
BLAST_SOURCE = json.dumps({"version": 1, "modules": {}}, indent=2) + "\n"
DESTINATION_ROUTING = '{"local": true, "routes": {"mine": {"agent": "m"}}}\n'
SOURCE_ROUTING = '{"routes": {"parallel": {"agent": "p"}}}\n'


def _empty_lister(path: Path) -> Sequence[DirectoryEntry]:
    """Describe a destination with no entries."""

    return []


def _stack(fs: RecordingFileSystem) -> BlastRadiusDeriveFileSystem:
    """Build the derive-over-merge decorators over ``fs`` for ``DEST``."""

    merging = DestinationMergeFileSystem(fs, destination_root=DEST)
    return BlastRadiusDeriveFileSystem(
        merging, destination_root=DEST, lister=_empty_lister
    )


def test_merged_relative_paths_initial_registry_is_routing_only() -> None:
    """The registry holds only the routing path, declared as a dict literal."""

    tree = ast.parse(WRITES_SOURCE.read_text(encoding="utf-8"))
    values = [
        node.value
        for node in tree.body
        if isinstance(node, ast.AnnAssign)
        and isinstance(node.target, ast.Name)
        and node.target.id == "MERGED_RELATIVE_PATHS"
    ]

    assert dict(MERGED_RELATIVE_PATHS) == {
        "config/orchestration-routing.json": merge_routing_documents
    }
    assert len(values) == 1
    registry = values[0]
    assert isinstance(registry, ast.Dict)
    assert all(
        isinstance(key, ast.Constant) and isinstance(key.value, str)
        for key in registry.keys
    )


def test_destination_merge_merges_registered_path_when_destination_exists() -> None:
    """An existing registered destination file receives the merged document."""

    fs = RecordingFileSystem(files={ROUTING: MemoryFile(DESTINATION_ROUTING)})

    DestinationMergeFileSystem(fs, destination_root=DEST).write_text(
        ROUTING, SOURCE_ROUTING
    )

    assert fs.read_text(ROUTING) == merge_routing_documents(
        DESTINATION_ROUTING, SOURCE_ROUTING, ROUTING
    )


def test_destination_merge_passes_through_unregistered_path() -> None:
    """An unregistered path is overwritten with the source content."""

    other = DEST / "config" / "other.json"
    fs = RecordingFileSystem(files={other: MemoryFile("old")})

    DestinationMergeFileSystem(fs, destination_root=DEST).write_text(other, "new")

    assert fs.read_text(other) == "new"


def test_destination_merge_matches_backslash_separated_path() -> None:
    """Backslash-separated paths are normalized before the registry lookup."""

    root = Path("C:\\dest")
    target = Path("C:\\dest\\config\\orchestration-routing.json")
    fs = RecordingFileSystem(files={target: MemoryFile(DESTINATION_ROUTING)})

    DestinationMergeFileSystem(fs, destination_root=root).write_text(
        target, SOURCE_ROUTING
    )

    assert json.loads(fs.read_text(target))["local"] is True


def test_destination_merge_is_case_sensitive() -> None:
    """A case-mismatched path is not a merge target and is overwritten."""

    mismatched = DEST / "Config" / "Orchestration-Routing.json"
    fs = RecordingFileSystem(files={mismatched: MemoryFile(DESTINATION_ROUTING)})

    DestinationMergeFileSystem(fs, destination_root=DEST).write_text(
        mismatched, SOURCE_ROUTING
    )

    assert fs.read_text(mismatched) == SOURCE_ROUTING


def test_destination_merge_leaves_bytes_unchanged_on_routing_merge_error() -> None:
    """A routing merge error propagates before the inner write."""

    fs = RecordingFileSystem(files={ROUTING: MemoryFile("{corrupt")})

    with pytest.raises(RoutingMergeError):
        DestinationMergeFileSystem(fs, destination_root=DEST).write_text(
            ROUTING, SOURCE_ROUTING
        )

    assert fs.read_text(ROUTING) == "{corrupt"


def test_blast_radius_derive_replaces_content_for_derive_target() -> None:
    """The blast-radius target receives the derived document, not the source."""

    fs = RecordingFileSystem()

    _stack(fs).write_text(BLAST, BLAST_SOURCE)

    written = json.loads(fs.read_text(BLAST))
    assert written == {"version": 1, "modules": {"config": ["config/**"]}}


def test_blast_radius_derive_passes_through_other_paths() -> None:
    """Paths other than the derive target are written unchanged."""

    fs = RecordingFileSystem()
    other = DEST / ".claude" / "settings.json"

    _stack(fs).write_text(other, BLAST_SOURCE)

    assert fs.read_text(other) == BLAST_SOURCE


def test_blast_radius_derive_leaves_bytes_unchanged_on_guard_error(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """A guard error propagates before the inner write.

    The real scanner prunes ``docs`` and ``tests``, so the guard is reachable
    through the decorator only by substituting the observation collector.
    """

    def tripping_observations(
        destination_root: Path, lister: object
    ) -> list[DirectoryObservation]:
        return [
            DirectoryObservation("", ()),
            DirectoryObservation("docs", ("package.json",)),
        ]

    monkeypatch.setattr(
        writes, "collect_destination_observations", tripping_observations
    )
    fs = RecordingFileSystem(files={BLAST: MemoryFile("seeded bytes\n")})

    with pytest.raises(BlastRadiusGuardError):
        _stack(fs).write_text(BLAST, BLAST_SOURCE)

    assert fs.read_text(BLAST) == "seeded bytes\n"


def test_build_stack_layer_order_derive_over_merge_over_inner() -> None:
    """The stack is derive wrapping merge wrapping the supplied inner adapter."""

    inner = RecordingFileSystem()

    stack = build_destination_write_stack(
        inner, destination_root=DEST, lister=_empty_lister
    )

    assert isinstance(stack, BlastRadiusDeriveFileSystem)
    assert isinstance(stack.inner, DestinationMergeFileSystem)
    assert stack.inner.inner is inner


def test_build_stack_caller_merges_replace_default_registry() -> None:
    """A caller-supplied merge registry replaces the default registry."""

    other = DEST / "config" / "other.json"
    fs = RecordingFileSystem(
        files={ROUTING: MemoryFile(DESTINATION_ROUTING), other: MemoryFile("dest")}
    )

    def join(destination: str, source: str, path: Path) -> str:
        return f"{destination}+{source}"

    stack = build_destination_write_stack(
        fs,
        destination_root=DEST,
        lister=_empty_lister,
        merges={"config/other.json": join},
    )
    stack.write_text(ROUTING, SOURCE_ROUTING)
    stack.write_text(other, "source")

    assert fs.read_text(ROUTING) == SOURCE_ROUTING
    assert fs.read_text(other) == "dest+source"


def _bundle_fs() -> RecordingFileSystem:
    """Seed repo-root and bundle config trees with distinct content."""

    return RecordingFileSystem(
        files={
            SOURCE_ROOT / "config" / "poshqc-scan.json": MemoryFile("repo-only"),
            SOURCE_ROOT / "config" / "blast-radius.json": MemoryFile("repo-blast"),
            BUNDLE_ROOT / "config" / "blast-radius.json": MemoryFile("bundle-blast"),
            BUNDLE_ROOT
            / "config"
            / "orchestration-routing.json": MemoryFile("bundle-r"),
            SOURCE_ROOT / ".claude" / "settings.json": MemoryFile("claude"),
        }
    )


def test_bundle_config_lists_bundle_files_under_source_config_root() -> None:
    """Listing the source config root returns bundle files as source paths."""

    fs = BundleConfigFileSystem(
        _bundle_fs(), source_root=SOURCE_ROOT, bundle_root=BUNDLE_ROOT
    )

    listed = fs.list_files(SOURCE_ROOT / "config")

    assert sorted(listed) == [
        SOURCE_ROOT / "config" / "blast-radius.json",
        SOURCE_ROOT / "config" / "orchestration-routing.json",
    ]


def test_bundle_config_redirects_is_file_and_read_text() -> None:
    """Existence and reads under the source config root come from the bundle."""

    fs = BundleConfigFileSystem(
        _bundle_fs(), source_root=SOURCE_ROOT, bundle_root=BUNDLE_ROOT
    )

    assert fs.read_text(SOURCE_ROOT / "config" / "blast-radius.json") == "bundle-blast"
    assert fs.is_file(SOURCE_ROOT / "config" / "orchestration-routing.json")
    assert not fs.is_file(SOURCE_ROOT / "config" / "poshqc-scan.json")


def test_bundle_config_passes_through_non_config_paths() -> None:
    """Paths outside the source config root and other methods pass through."""

    inner = _bundle_fs()
    fs = BundleConfigFileSystem(inner, source_root=SOURCE_ROOT, bundle_root=BUNDLE_ROOT)
    claude_file = SOURCE_ROOT / ".claude" / "settings.json"

    fs.ensure_dir(DEST)
    fs.write_text(DEST / "x.txt", "x")

    assert fs.list_files(SOURCE_ROOT / ".claude") == [claude_file]
    assert fs.read_text(claude_file) == "claude"
    assert fs.is_file(claude_file)
    assert fs.is_dir(DEST)
    assert inner.read_text(DEST / "x.txt") == "x"


def test_bundle_config_is_identity_when_roots_match() -> None:
    """With identical config roots every call is answered unchanged."""

    inner = _bundle_fs()
    fs = BundleConfigFileSystem(inner, source_root=SOURCE_ROOT, bundle_root=SOURCE_ROOT)

    listed = fs.list_files(SOURCE_ROOT / "config")

    assert listed == inner.list_files(SOURCE_ROOT / "config")
    assert fs.read_text(SOURCE_ROOT / "config" / "blast-radius.json") == "repo-blast"


def test_bundle_config_lists_nothing_when_bundle_config_absent() -> None:
    """Without a bundle config tree the source config root lists nothing."""

    inner = RecordingFileSystem(
        files={SOURCE_ROOT / "config" / "poshqc-scan.json": MemoryFile("repo-only")}
    )
    fs = BundleConfigFileSystem(inner, source_root=SOURCE_ROOT, bundle_root=BUNDLE_ROOT)

    assert fs.list_files(SOURCE_ROOT / "config") == []


def test_module_docstring_names_downstream_seams() -> None:
    """The module docstring names #508, #621, and both seams."""

    doc = writes.__doc__ or ""
    normalized = " ".join(doc.split())

    for token in (
        "#508",
        "#621",
        "MERGED_RELATIVE_PATHS",
        "build_destination_write_stack",
    ):
        assert token in doc, token
    for sentence in (
        "#508 extends `MERGED_RELATIVE_PATHS` by registering "
        "`config/blast-radius.json`.",
        "#621 inserts its destination exclusion filter in "
        "`build_destination_write_stack()` as the outermost layer.",
        "Downstream children extend these seams; they do not replace, bypass, "
        "or duplicate them.",
    ):
        assert sentence in normalized, sentence


def test_push_down_customizations_obtains_decorators_only_through_stack(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """The entry point assembles its write decorators only through the stack."""

    customizations = importlib.import_module(
        "scripts.dev_tools.push_down_claude_customizations"
    )
    calls: list[Path] = []

    def recording_stack(
        inner: PushDownFileSystem,
        *,
        destination_root: Path,
        lister: DirectoryLister,
    ) -> PushDownFileSystem:
        calls.append(destination_root)
        return build_destination_write_stack(
            inner, destination_root=destination_root, lister=lister
        )

    monkeypatch.setattr(
        customizations, "build_destination_write_stack", recording_stack
    )
    fs = RecordingFileSystem(
        files={Path("/repo/.claude/settings.json"): MemoryFile("{}\n")}
    )
    fs.directories.update({Path("/repo"), DEST})

    customizations.push_down_customizations(
        repo_root=Path("/repo"),
        destination_root=DEST,
        fs=fs,
        source_root=Path("/repo"),
        artifact_root=DEST,
        list_entries=_empty_lister,
    )

    source = (REPO_ROOT / CUSTOMIZATIONS_SOURCE).read_text(encoding="utf-8")
    names = {
        node.id if isinstance(node, ast.Name) else node.name
        for node in ast.walk(ast.parse(source))
        if isinstance(node, (ast.Name, ast.alias))
    }
    assert calls == [DEST]
    assert "DestinationMergeFileSystem" not in names
    assert "BlastRadiusDeriveFileSystem" not in names
