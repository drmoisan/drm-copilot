"""End-to-end config carriage through the Python Claude push-down (issue #507).

Mirrors the TypeScript carriage cases in
``extensions/drm-copilot/test/lib/push-down/claude-config-carriage.test.ts``:
the published ``config/`` population is the bundle population, the routing
document is merged, and the blast-radius document is derived for the injected
destination layout. Every filesystem is in memory; the destination layout is
described by an injected lister.
"""

from __future__ import annotations

import importlib
import json
from pathlib import Path
from typing import TYPE_CHECKING

import pytest

from scripts.dev_tools.push_down_claude_blast_radius_derive import DirectoryEntry
from scripts.dev_tools.push_down_claude_routing_merge import RoutingMergeError
from tests.scripts.dev_tools.push_down_customizations_test_support import (
    MemoryFile,
    RecordingFileSystem,
)

if TYPE_CHECKING:
    from collections.abc import Sequence
    from types import ModuleType

    from scripts.dev_tools.push_down_copilot_customizations import PushDownSummary

REPO_ROOT = Path(__file__).resolve().parents[3]
SOURCE = Path("/repo")
DEST = Path("/dest")
BUNDLE = SOURCE / "extensions/drm-copilot/resources/claude-customizations"
REPO_ONLY_NAMES = (
    "orchestration-handoff-registry.json",
    "orchestration-handoff.schema.json",
    "poshqc-scan.json",
)
CLAUDE_FILES = {
    ".claude/settings.json": '{"shared": true}\n',
    ".claude/rules/python.md": "# Python rules\n",
}
BUNDLE_BLAST = json.dumps(
    {"version": 1, "shared_surfaces": [], "modules": {"bundle": ["bundle/**"]}},
    indent=2,
)
REPO_BLAST = json.dumps({"version": 1, "modules": {"repo": ["repo/**"]}}, indent=2)
BUNDLE_ROUTING = (
    json.dumps({"version": 2, "routes": {"parallel": {"agent": "bundle"}}}, indent=4)
    + "\n"
)
DEST_ROUTING = '{"local": 1, "routes": {"parallel": {"agent": "old"}, "mine": {}}}\n'
ROUTING_DEST = DEST / "config" / "orchestration-routing.json"
LAYOUT = {
    "/dest": [DirectoryEntry("packages", True)],
    "/dest/packages": [DirectoryEntry("a", True), DirectoryEntry("b", True)],
    "/dest/packages/a": [DirectoryEntry("package.json", False)],
    "/dest/packages/b": [DirectoryEntry("package.json", False)],
}


def _lister(path: Path) -> Sequence[DirectoryEntry]:
    """Describe the destination layout ``packages/a`` and ``packages/b``."""

    return LAYOUT.get(path.as_posix(), [])


def _module() -> ModuleType:
    """Import the Claude push-down entry point under test."""

    return importlib.import_module("scripts.dev_tools.push_down_claude_customizations")


def _seed(*, with_bundle_config: bool = True) -> RecordingFileSystem:
    """Seed `.claude` files, five repo-root config files, and the bundle config."""

    files: dict[Path, MemoryFile] = {
        SOURCE / relative: MemoryFile(content)
        for relative, content in CLAUDE_FILES.items()
    }
    for name in REPO_ONLY_NAMES:
        files[SOURCE / "config" / name] = MemoryFile(f"repo {name}\n")
    files[SOURCE / "config" / "blast-radius.json"] = MemoryFile(REPO_BLAST)
    files[SOURCE / "config" / "orchestration-routing.json"] = MemoryFile("{}\n")
    if with_bundle_config:
        files[BUNDLE / "config" / "blast-radius.json"] = MemoryFile(BUNDLE_BLAST)
        files[BUNDLE / "config" / "orchestration-routing.json"] = MemoryFile(
            BUNDLE_ROUTING
        )
    fs = RecordingFileSystem(files=files)
    fs.directories.update({SOURCE, DEST})
    return fs


def _push(
    fs: RecordingFileSystem, *, packs: frozenset[str] | None = None
) -> PushDownSummary:
    """Run the push-down into ``DEST`` with the injected destination lister."""

    return _module().push_down_customizations(
        repo_root=SOURCE,
        destination_root=DEST,
        fs=fs,
        source_root=SOURCE,
        artifact_root=DEST,
        packs=packs,
        list_entries=_lister,
    )


def _destination_config_names(fs: RecordingFileSystem) -> list[str]:
    """Return the file names published under the destination ``config/``."""

    return sorted(path.name for path in fs.list_files(DEST / "config"))


def test_config_carriage_publishes_exactly_two_bundle_config_files() -> None:
    """Destination config holds the two bundle files and no repo-only file."""

    fs = _seed()

    _push(fs)

    names = _destination_config_names(fs)
    assert names == ["blast-radius.json", "orchestration-routing.json"]
    for repo_only in REPO_ONLY_NAMES:
        assert repo_only not in names, repo_only


def test_summary_lists_claude_files_before_config_files() -> None:
    """Every `.claude` summary entry precedes every `config` entry."""

    fs = _seed()

    summary = _push(fs)

    relative = [result.relative_path for result in summary.files]
    roots = [path.split("/", 1)[0] for path in relative]
    assert roots == [".claude", ".claude", "config", "config"]


def test_published_blast_radius_is_derived_for_injected_layout() -> None:
    """The published blast-radius map is derived from the destination layout."""

    fs = _seed()

    _push(fs)

    published = fs.read_text(DEST / "config" / "blast-radius.json")
    assert json.loads(published)["modules"] == {
        "config": ["config/**"],
        "packages/a": ["packages/a/**"],
        "packages/b": ["packages/b/**"],
    }
    assert published not in (REPO_BLAST, BUNDLE_BLAST)


def test_existing_destination_routing_file_is_merged_not_overwritten() -> None:
    """An existing destination routing file keeps its local keys and routes."""

    fs = _seed()
    fs.write_text(ROUTING_DEST, DEST_ROUTING)

    _push(fs)

    merged = json.loads(fs.read_text(ROUTING_DEST))
    assert merged["local"] == 1
    assert merged["routes"] == {"parallel": {"agent": "bundle"}, "mine": {}}
    assert merged["version"] == 2


def test_second_push_produces_byte_identical_routing_file() -> None:
    """Two pushes into a destination with a routing file are byte-stable."""

    fs = _seed()
    fs.write_text(ROUTING_DEST, DEST_ROUTING)

    _push(fs)
    first = fs.read_text(ROUTING_DEST)
    _push(fs)
    second = fs.read_text(ROUTING_DEST)

    assert second == first


def test_routing_merge_error_aborts_with_destination_bytes_unchanged() -> None:
    """An unparseable destination routing file aborts the run unchanged."""

    fs = _seed()
    fs.write_text(ROUTING_DEST, "{corrupt\n")

    with pytest.raises(RoutingMergeError):
        _push(fs)

    assert fs.read_text(ROUTING_DEST) == "{corrupt\n"


def test_pack_scoped_publish_keeps_both_config_files() -> None:
    """A core-only pack selection listing both config paths publishes both."""

    fs = _seed()
    manifest = {
        "name": "core",
        "label": "Core",
        "paths": [
            *CLAUDE_FILES,
            "config/orchestration-routing.json",
            "config/blast-radius.json",
        ],
    }
    fs.write_text(BUNDLE / "pack-manifests" / "core.json", json.dumps(manifest))

    _push(fs, packs=frozenset({"core"}))

    assert _destination_config_names(fs) == [
        "blast-radius.json",
        "orchestration-routing.json",
    ]


def test_bundle_config_absent_publishes_claude_only() -> None:
    """Without a bundle config tree only the `.claude` files are published."""

    fs = _seed(with_bundle_config=False)

    summary = _push(fs)

    assert _destination_config_names(fs) == []
    assert [result.relative_path for result in summary.files] == sorted(CLAUDE_FILES)


def test_module_docstring_and_cli_help_name_config_payload(
    capsys: pytest.CaptureFixture[str],
) -> None:
    """The module docstring and CLI help describe the config payload."""

    module = _module()

    with pytest.raises(SystemExit):
        module.parse_args(["--help"])
    output = capsys.readouterr().out

    assert "config/" in (module.__doc__ or "").splitlines()[0]
    assert "config trees" in " ".join(output.split())


def test_readme_claude_row_lists_config_payload() -> None:
    """The committed README Claude Code row lists the config payload."""

    lines = (REPO_ROOT / "README.md").read_text(encoding="utf-8").splitlines()

    rows = [line for line in lines if line.startswith("| Claude Code (")]

    assert len(rows) == 1, rows
    assert "`config/`" in rows[0]
