"""Tests for destination ``.gitignore`` delivery by the Claude push-down (issue #790).

Every filesystem is in memory (``RecordingFileSystem`` plus the observing
subclasses below). Runs go through ``push_down_customizations`` so delivery is
exercised in its real post-copy position. Assertions compare against literal
expected text; the merge module is never imported here.
"""

from __future__ import annotations

import json
import re
from pathlib import Path
from typing import TYPE_CHECKING

import pytest

from scripts.dev_tools import push_down_claude_customizations as entry
from scripts.dev_tools.push_down_claude_exclusion_filter import (
    ClaudePushDownSummary,
    render_exclusion_lines,
)
from scripts.dev_tools.push_down_exclusion_manifest import SkippedPath
from tests.scripts.dev_tools.push_down_customizations_test_support import (
    MemoryFile,
    RecordingFileSystem,
)

if TYPE_CHECKING:
    from collections.abc import Sequence

    from scripts.dev_tools.push_down_claude_blast_radius_derive import (
        DirectoryEntry,
    )

SOURCE = Path("C:/repo")
DEST = Path("C:/dest")
BUNDLE = SOURCE / "extensions/drm-copilot/resources/claude-customizations"
MANIFEST = DEST / ".push-down-exclusions"
GITIGNORE = DEST / ".gitignore"
QUALITY = ".claude/rules/quality-tiers.md"
PYTHON = ".claude/rules/python.md"
BLOCK_TEXT = (
    "# BEGIN drm-copilot managed ignores\n"
    ".claude/state/\n"
    ".codex/state/\n"
    "# END drm-copilot managed ignores\n"
)


class ObservingFileSystem(RecordingFileSystem):
    """Record every read and write path in call order."""

    def __init__(self, *, files: dict[Path, MemoryFile] | None = None) -> None:
        """Start with empty observation lists."""

        super().__init__(files=files)
        self.read_paths: list[Path] = []
        self.write_paths: list[Path] = []

    def read_text(self, path: Path) -> str:
        """Record the read before returning the stored text."""

        self.read_paths.append(path)
        return super().read_text(path)

    def write_text(self, path: Path, content: str) -> None:
        """Record the write before storing it."""

        self.write_paths.append(path)
        super().write_text(path, content)


class UniversalNewlineFileSystem(ObservingFileSystem):
    """Translate CRLF and lone CR to LF on read, as ``Path.read_text`` does."""

    def read_text(self, path: Path) -> str:
        """Return the stored text with universal-newline translation applied."""

        return re.sub(r"\r\n?", "\n", super().read_text(path))


def _empty_lister(_path: Path) -> Sequence[DirectoryEntry]:
    """Describe an empty destination layout."""

    return []


def _seed(
    source: dict[str, str],
    *,
    destination: dict[str, str] | None = None,
    manifest: str | None = None,
    fs_class: type[ObservingFileSystem] = ObservingFileSystem,
) -> ObservingFileSystem:
    """Seed source files, destination files, and an optional manifest."""

    files: dict[Path, MemoryFile] = {}
    for relative, content in source.items():
        files[SOURCE / relative] = MemoryFile(content)
    for relative, content in (destination or {}).items():
        files[DEST / relative] = MemoryFile(content)
    if manifest is not None:
        files[MANIFEST] = MemoryFile(manifest)
    fs = fs_class(files=files)
    fs.directories.update({SOURCE, DEST})
    return fs


def _push(
    fs: ObservingFileSystem, *, packs: frozenset[str] | None = None
) -> ClaudePushDownSummary:
    """Run the push-down into ``DEST`` with the artifact under ``DEST``."""

    return entry.push_down_customizations(
        repo_root=SOURCE,
        destination_root=DEST,
        fs=fs,
        source_root=SOURCE,
        artifact_root=DEST,
        packs=packs,
        list_entries=_empty_lister,
    )


def test_unscoped_push_down_writes_block_into_absent_gitignore() -> None:
    """D1: an unscoped push-down creates the destination .gitignore block."""

    fs = _seed({PYTHON: "py\n"})

    _push(fs)

    assert fs.files[GITIGNORE].content == BLOCK_TEXT


def test_pack_scoped_push_down_writes_block_into_gitignore() -> None:
    """D2: a pack-scoped push-down also creates the destination .gitignore block."""

    fs = _seed({".claude/settings.json": "{}\n"})
    fs.files[BUNDLE / "pack-manifests/core.json"] = MemoryFile(
        json.dumps(
            {"name": "core", "label": "Core", "paths": [".claude/settings.json"]}
        )
    )

    _push(fs, packs=frozenset({"core"}))

    assert fs.files[GITIGNORE].content == BLOCK_TEXT


def test_push_down_preserves_unrelated_gitignore_lines_in_order() -> None:
    """D3: existing destination lines are kept in order before the block."""

    fs = _seed({PYTHON: "py\n"}, destination={".gitignore": "node_modules/\n*.log\n"})

    _push(fs)

    assert fs.files[GITIGNORE].content == "node_modules/\n*.log\n\n" + BLOCK_TEXT


def test_second_push_down_performs_no_gitignore_write() -> None:
    """D4: a second push-down finds the block current and does not rewrite it."""

    fs = _seed({PYTHON: "py\n"})

    _push(fs)
    assert fs.files[GITIGNORE].content == BLOCK_TEXT
    _push(fs)

    assert fs.write_paths.count(GITIGNORE) == 1


def test_manifest_skip_with_absent_gitignore_reads_and_writes_nothing() -> None:
    """D5: a manifest entry for .gitignore suppresses delivery to an absent file."""

    fs = _seed({PYTHON: "py\n"}, manifest=".gitignore\n")

    summary = _push(fs)

    assert GITIGNORE not in fs.read_paths
    assert GITIGNORE not in fs.write_paths
    assert GITIGNORE not in fs.files
    assert summary.exclusions is not None
    assert summary.exclusions.skipped[-1] == SkippedPath(
        relative_path=".gitignore",
        entry=".gitignore",
        line=1,
        destination_status="absent",
    )


def test_manifest_skip_with_present_gitignore_keeps_bytes() -> None:
    """D6: a manifest entry for .gitignore leaves a present file untouched."""

    fs = _seed(
        {PYTHON: "py\n"},
        destination={".gitignore": "local\n"},
        manifest="# keep\n.gitignore\n",
    )

    summary = _push(fs)

    assert GITIGNORE not in fs.read_paths
    assert GITIGNORE not in fs.write_paths
    assert fs.files[GITIGNORE].content == "local\n"
    assert summary.exclusions is not None
    assert summary.exclusions.skipped[-1].line == 2
    assert summary.exclusions.skipped[-1].destination_status == "present"


def test_gitignore_skip_follows_enumeration_skips_in_artifact() -> None:
    """D7: the .gitignore skip is recorded after the enumeration skips."""

    fs = _seed({QUALITY: "q\n", PYTHON: "py\n"}, manifest=QUALITY + "\n.gitignore\n")

    summary = _push(fs)

    assert summary.exclusions is not None
    assert [s.relative_path for s in summary.exclusions.skipped] == [
        QUALITY,
        ".gitignore",
    ]
    exclusions = json.loads(fs.files[Path(summary.artifact_path)].content)["exclusions"]
    assert [s["relative_path"] for s in exclusions["skipped"]] == [
        QUALITY,
        ".gitignore",
    ]
    assert exclusions["skipped_count"] == 2
    assert exclusions["unmatched_entries"] == []


def test_exclusion_lines_report_gitignore_skip_after_enumeration_skip() -> None:
    """D8: the rendered exclusion lines list the .gitignore skip last."""

    fs = _seed({QUALITY: "q\n", PYTHON: "py\n"}, manifest=QUALITY + "\n.gitignore\n")

    summary = _push(fs)

    assert summary.exclusions is not None
    assert render_exclusion_lines(summary.exclusions) == [
        "push-down exclusion: skipped .claude/rules/quality-tiers.md "
        "(entry .claude/rules/quality-tiers.md, line 1)",
        "push-down exclusion: skipped .gitignore (entry .gitignore, line 2)",
    ]


def test_gitignore_delivery_follows_summary_artifact_write() -> None:
    """D9: delivery runs after the artifact write and before the report append."""

    fs = _seed({PYTHON: "py\n"}, manifest=".claude/agent-memory/**\n")

    summary = _push(fs)

    artifact = Path(summary.artifact_path)
    first_artifact_write = fs.write_paths.index(artifact)
    gitignore_write = fs.write_paths.index(GITIGNORE)
    last_artifact_write = len(fs.write_paths) - 1 - fs.write_paths[::-1].index(artifact)
    assert first_artifact_write < gitignore_write < last_artifact_write


def test_destination_validation_failure_writes_no_gitignore() -> None:
    """D10: an invalid destination fails before any .gitignore write."""

    fs = _seed({PYTHON: "py\n"})
    fs.directories.discard(DEST)

    with pytest.raises(ValueError, match="Invalid destination"):
        _push(fs)

    assert GITIGNORE not in fs.write_paths


def test_gitignore_write_is_absent_from_summary_files_and_counts() -> None:
    """D11: the .gitignore write is not reported as a published file."""

    fs = _seed({PYTHON: "py\n"})

    summary = _push(fs)

    assert [r.relative_path for r in summary.files] == [PYTHON]
    assert summary.created_count + summary.overwritten_count == 1
    assert GITIGNORE in fs.files


def test_gitignore_written_through_raw_fs_with_active_manifest() -> None:
    """D12: an active manifest's write guard does not block .gitignore delivery."""

    fs = _seed({QUALITY: "q\n", PYTHON: "py\n"}, manifest=QUALITY + "\n")

    _push(fs)

    assert fs.files[GITIGNORE].content == BLOCK_TEXT


def test_crlf_up_to_date_gitignore_is_not_rewritten() -> None:
    """D13: a CRLF file holding a current block is read but not rewritten."""

    crlf_text = BLOCK_TEXT.replace("\n", "\r\n")
    fs = _seed(
        {PYTHON: "py\n"},
        destination={".gitignore": crlf_text},
        fs_class=UniversalNewlineFileSystem,
    )

    _push(fs)

    assert GITIGNORE in fs.read_paths
    assert GITIGNORE not in fs.write_paths
    assert fs.files[GITIGNORE].content == crlf_text


def test_crlf_stale_gitignore_is_rewritten_lf_only() -> None:
    """D14: a CRLF file needing the block is rewritten as LF-only text."""

    fs = _seed(
        {PYTHON: "py\n"},
        destination={".gitignore": "node_modules/\r\n"},
        fs_class=UniversalNewlineFileSystem,
    )

    _push(fs)

    content = fs.files[GITIGNORE].content
    assert content == "node_modules/\n\n" + BLOCK_TEXT
    assert "\r" not in content
