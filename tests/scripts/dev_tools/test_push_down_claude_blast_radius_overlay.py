"""Destination blast-radius overlay through the Python Claude push-down (issue #508).

Mirrors ``claude-blast-radius-overlay.test.ts`` and the #508 carriage case in
``claude-config-carriage.test.ts`` (``extensions/drm-copilot/test/lib/push-down/``): the
destination-owned ``config/blast-radius.local.json`` is composed onto the
regenerated ``config/blast-radius.json`` on every push, is never published
from the source, and is never written by a push. Every filesystem is in
memory; the destination layout is described by an injected lister.
"""

from __future__ import annotations

import importlib
import json
from pathlib import Path
from typing import TYPE_CHECKING

from tests.scripts.dev_tools.test_push_down_claude_customizations import (
    MemoryFile,
    RecordingFileSystem,
)

if TYPE_CHECKING:
    from collections.abc import Sequence

    from scripts.dev_tools.push_down_claude_blast_radius_derive import (
        DirectoryEntry,
    )
    from scripts.dev_tools.push_down_copilot_customizations import PushDownSummary

SOURCE = Path("/repo")
DEST = Path("/dest")
# CONFIG_PUBLISH_ROOT recorded by P0-T9: the bundle root inside the source.
BUNDLE = SOURCE / "extensions/drm-copilot/resources/claude-customizations"
TARGET = DEST / "config" / "blast-radius.json"
OVERLAY = DEST / "config" / "blast-radius.local.json"
BASE_TEXT = (
    json.dumps(
        {
            "version": 1,
            "shared_surfaces": ["config/blast-radius.json"],
            "mandate_reads": [],
            "modules": {"config": ["config/**"]},
        },
        indent=2,
    )
    + "\n"
)
OVERLAY_TEXT = (
    json.dumps(
        {
            "shared_surfaces": ["Directory.Build.props"],
            "modules": {"destination-app": ["app/**"]},
        },
        indent=2,
    )
    + "\n"
)
ROUTING_TEXT = json.dumps({"version": 2, "routes": {}}, indent=2) + "\n"


class WriteRecordingFileSystem(RecordingFileSystem):
    """Record every ``write_text`` path in call order."""

    def __init__(self, *, files: dict[Path, MemoryFile] | None = None) -> None:
        """Initialise the store and an empty write log."""

        super().__init__(files=files)
        self.written_paths: list[Path] = []

    def write_text(self, path: Path, content: str) -> None:
        """Record the path, then persist the content."""

        self.written_paths.append(path)
        super().write_text(path, content)


def _empty_lister(path: Path) -> Sequence[DirectoryEntry]:
    """Describe a destination layout with no entries at any path."""

    del path
    return []


def _seed(extra: dict[Path, str] | None = None) -> WriteRecordingFileSystem:
    """Seed one `.claude` file and the bundle `config/` tree."""

    files: dict[Path, MemoryFile] = {
        SOURCE / ".claude" / "settings.json": MemoryFile('{"shared": true}\n'),
        BUNDLE / "config" / "blast-radius.json": MemoryFile(BASE_TEXT),
        BUNDLE / "config" / "orchestration-routing.json": MemoryFile(ROUTING_TEXT),
    }
    for path, content in (extra or {}).items():
        files[path] = MemoryFile(content)
    fs = WriteRecordingFileSystem(files=files)
    fs.directories.update({SOURCE, DEST})
    # Only writes made by a push are recorded.
    fs.written_paths.clear()
    return fs


def _push(fs: WriteRecordingFileSystem) -> PushDownSummary:
    """Run the push-down with the same keyword arguments as CONFIG_SEED_TEST."""

    module = importlib.import_module(
        "scripts.dev_tools.push_down_claude_customizations"
    )
    return module.push_down_customizations(
        repo_root=SOURCE,
        destination_root=DEST,
        fs=fs,
        source_root=SOURCE,
        artifact_root=DEST,
        packs=None,
        list_entries=_empty_lister,
    )


def test_ac08_push_carries_destination_overlay_entries_across_two_pushes() -> None:
    """Two pushes write identical text carrying the destination overlay entries."""

    fs = _seed({OVERLAY: OVERLAY_TEXT})

    _push(fs)
    first = fs.read_text(TARGET)
    _push(fs)
    second = fs.read_text(TARGET)

    assert second == first
    for text in (first, second):
        assert '"Directory.Build.props"' in text, text
        assert '"destination-app"' in text, text


def test_ac11_source_side_overlay_is_not_published() -> None:
    """A source-side overlay file is never delivered to the destination."""

    fs = _seed({BUNDLE / "config" / "blast-radius.local.json": OVERLAY_TEXT})

    _push(fs)

    assert not fs.is_file(OVERLAY), sorted(str(path) for path in fs.files)
