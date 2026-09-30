"""Tests for the Claude push-down exclusion filter and its entry-point wiring.

Every filesystem is in memory (``RecordingFileSystem`` plus the
``ObservingFileSystem`` subclass below, which records reads, writes, and
directory creation). Runs go through ``push_down_customizations`` or ``main``
so the filter is exercised in its real decorator position.
"""

from __future__ import annotations

import io
import json
from contextlib import redirect_stdout
from pathlib import Path
from typing import TYPE_CHECKING

import pytest

from scripts.dev_tools import push_down_claude_customizations as entry
from scripts.dev_tools.push_down_claude_exclusion_filter import (
    DEFAULT_ARTIFACT_DIRECTORY,
    ClaudePushDownSummary,
    ExclusionFilterFileSystem,
    ExclusionViolationError,
    read_exclusion_manifest,
)
from scripts.dev_tools.push_down_copilot_customizations import PushDownSummaryPayload
from scripts.dev_tools.push_down_exclusion_manifest import (
    EXCLUSION_MANIFEST_RELATIVE_PATH,
    ExclusionManifestError,
    parse_exclusion_manifest,
)
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
MANIFEST = DEST / EXCLUSION_MANIFEST_RELATIVE_PATH
QUALITY = ".claude/rules/quality-tiers.md"
PYTHON = ".claude/rules/python.md"
ROUTING = "config/orchestration-routing.json"
PLAN_CORPUS = (
    Path(__file__).resolve().parents[3]
    / "tests/fixtures/push_down_exclusions/plan-corpus.json"
)


class ObservingFileSystem(RecordingFileSystem):
    """Record reads, writes, and ensured directories; fail decoding on demand."""

    def __init__(self, *, files: dict[Path, MemoryFile] | None = None) -> None:
        """Start with empty observation lists and no undecodable paths."""

        super().__init__(files=files)
        self.read_paths: list[Path] = []
        self.write_paths: list[Path] = []
        self.ensured_dirs: list[Path] = []
        self.undecodable: set[Path] = set()

    def read_text(self, path: Path) -> str:
        """Record the read; raise ``UnicodeDecodeError`` for undecodable paths."""

        self.read_paths.append(path)
        if path in self.undecodable:
            raise UnicodeDecodeError("utf-8", b"\xff", 0, 1, "invalid start byte")
        return super().read_text(path)

    def write_text(self, path: Path, content: str) -> None:
        """Record the write before storing it."""

        self.write_paths.append(path)
        super().write_text(path, content)

    def ensure_dir(self, path: Path) -> None:
        """Record the directory creation before tracking it."""

        self.ensured_dirs.append(path)
        super().ensure_dir(path)


def _empty_lister(_path: Path) -> Sequence[DirectoryEntry]:
    """Describe an empty destination layout."""

    return []


def _seed(
    source: dict[str, str],
    *,
    destination: dict[str, str] | None = None,
    manifest: str | None = None,
) -> ObservingFileSystem:
    """Seed source files (``config/`` under the bundle) and destination files."""

    files: dict[Path, MemoryFile] = {}
    for relative, content in source.items():
        root = BUNDLE if relative.startswith("config/") else SOURCE
        files[root / relative] = MemoryFile(content)
    for relative, content in (destination or {}).items():
        files[DEST / relative] = MemoryFile(content)
    if manifest is not None:
        files[MANIFEST] = MemoryFile(manifest)
    fs = ObservingFileSystem(files=files)
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


def _artifact(fs: ObservingFileSystem, summary: ClaudePushDownSummary) -> str:
    """Return the summary artifact text."""

    return fs.files[Path(summary.artifact_path)].content


def _run_cli(fs: ObservingFileSystem) -> tuple[int, list[str]]:
    """Run ``main`` against ``fs`` and return the exit code and stdout lines."""

    output = io.StringIO()
    with redirect_stdout(output):
        exit_code = entry.main(["--destination", str(DEST)], repo_root=SOURCE, fs=fs)
    return exit_code, output.getvalue().splitlines()


def test_read_exclusion_manifest_returns_none_when_absent() -> None:
    """An absent manifest yields ``None`` without reading anything."""

    fs = _seed({})

    assert read_exclusion_manifest(fs, DEST) is None
    assert fs.read_paths == []


def test_read_exclusion_manifest_raises_for_directory_at_manifest_path() -> None:
    """A directory at the manifest path is a malformed manifest with no line."""

    fs = _seed({})
    fs.directories.add(MANIFEST)

    with pytest.raises(ExclusionManifestError) as captured:
        read_exclusion_manifest(fs, DEST)

    assert captured.value.path == EXCLUSION_MANIFEST_RELATIVE_PATH
    assert captured.value.line is None
    assert EXCLUSION_MANIFEST_RELATIVE_PATH in str(captured.value)


def test_read_exclusion_manifest_wraps_unicode_decode_error() -> None:
    """Undecodable manifest text is reported as ``ExclusionManifestError``."""

    fs = _seed({}, manifest="x\n")
    fs.undecodable.add(MANIFEST)

    with pytest.raises(ExclusionManifestError) as captured:
        read_exclusion_manifest(fs, DEST)

    assert captured.value.line is None
    assert isinstance(captured.value.__cause__, UnicodeDecodeError)


def test_malformed_manifest_fails_before_any_write() -> None:
    """A malformed manifest fails the run before any write or directory."""

    fs = _seed({QUALITY: "bundle\n"}, manifest="!x\n")

    with pytest.raises(ExclusionManifestError) as captured:
        _push(fs)

    assert captured.value.line == 1
    assert fs.write_paths == []
    assert fs.ensured_dirs == []


def test_skips_absent_destination_path_and_records_absent_status() -> None:
    """A matched path absent at the destination is skipped and not counted."""

    fs = _seed({QUALITY: "bundle\n", PYTHON: "py\n"}, manifest=QUALITY + "\n")

    summary = _push(fs)

    assert DEST / QUALITY not in fs.write_paths
    assert [result.relative_path for result in summary.files] == [PYTHON]
    assert summary.created_count + summary.overwritten_count == 1
    assert summary.exclusions is not None
    assert summary.exclusions.skipped[0].relative_path == QUALITY
    assert summary.exclusions.skipped[0].destination_status == "absent"


def test_conflict_leaves_present_destination_bytes_unchanged() -> None:
    """A matched path present at the destination is a conflict left untouched."""

    fs = _seed(
        {QUALITY: "bundle\n"},
        destination={QUALITY: "local\n"},
        manifest=QUALITY + "\n",
    )

    summary = _push(fs)

    assert fs.files[DEST / QUALITY].content == "local\n"
    assert summary.exclusions is not None
    assert summary.exclusions.conflict_count == 1
    assert summary.exclusions.skipped[0].destination_status == "present"


def test_unmatched_entry_is_reported_and_run_succeeds() -> None:
    """An entry matching no payload path is reported and filters nothing."""

    fs = _seed({PYTHON: "py\n"}, manifest=".claude/agent-memory/**\n")

    summary = _push(fs)

    assert [result.relative_path for result in summary.files] == [PYTHON]
    assert summary.exclusions is not None
    assert summary.exclusions.skipped == ()
    assert [e.normalized for e in summary.exclusions.unmatched_entries] == [
        ".claude/agent-memory/**"
    ]


def test_write_guard_raises_for_matched_path_and_manifest_path() -> None:
    """Direct writes to a matched path or the manifest raise; others pass."""

    fs = _seed({})
    manifest = parse_exclusion_manifest(
        QUALITY + "\nartifacts/**\n", EXCLUSION_MANIFEST_RELATIVE_PATH
    )
    guarded = ExclusionFilterFileSystem(fs, SOURCE, DEST, manifest)
    artifact_target = DEST / "artifacts/claude-customizations/x.json"

    with pytest.raises(ExclusionViolationError, match="quality-tiers.md"):
        guarded.write_text(DEST / QUALITY, "x")
    with pytest.raises(ExclusionViolationError, match="manifest"):
        guarded.write_text(MANIFEST, "x")
    guarded.write_text(artifact_target, "{}")
    guarded.write_text(DEST / PYTHON, "py")
    guarded.write_text(SOURCE / QUALITY, "outside")

    assert fs.write_paths == [artifact_target, DEST / PYTHON, SOURCE / QUALITY]
    assert DEFAULT_ARTIFACT_DIRECTORY == entry.ARTIFACT_DIRECTORY


def test_manifest_path_is_never_written_and_content_unchanged() -> None:
    """A run with a manifest never writes the manifest and keeps its bytes."""

    manifest_text = "# keep local\n" + QUALITY + "\n"
    fs = _seed({QUALITY: "bundle\n", PYTHON: "py\n"}, manifest=manifest_text)

    _push(fs)

    assert MANIFEST not in fs.write_paths
    assert fs.files[MANIFEST].content == manifest_text


def test_excluded_routing_merge_path_is_neither_read_nor_written() -> None:
    """An excluded merged path is never read for merging nor written."""

    fs = _seed(
        {ROUTING: '{"version": 2}\n', PYTHON: "py\n"},
        destination={ROUTING: '{"local": 1}\n'},
        manifest=ROUTING + "\n",
    )

    summary = _push(fs)

    assert DEST / ROUTING not in fs.read_paths
    assert DEST / ROUTING not in fs.write_paths
    assert fs.files[DEST / ROUTING].content == '{"local": 1}\n'
    assert summary.exclusions is not None
    assert summary.exclusions.skipped[0].relative_path == ROUTING
    assert summary.exclusions.skipped[0].destination_status == "present"


def test_artifact_carries_sorted_exclusions_object_only_with_manifest() -> None:
    """The artifact gains a sorted ``exclusions`` object when a manifest exists."""

    fs = _seed(
        {QUALITY: "bundle\n", PYTHON: "py\n"},
        destination={QUALITY: "local\n"},
        manifest=QUALITY + "\n.claude/agent-memory/**\n",
    )
    plain_fs = _seed({QUALITY: "bundle\n", PYTHON: "py\n"})

    summary = _push(fs)
    plain_summary = _push(plain_fs)

    text = _artifact(fs, summary)
    exclusions = json.loads(text)["exclusions"]
    assert set(exclusions) == {
        "conflict_count",
        "entries",
        "manifest_path",
        "skipped",
        "skipped_count",
        "unmatched_entries",
    }
    assert [set(skip) for skip in exclusions["skipped"]] == [
        {"destination_status", "entry", "line", "relative_path"}
    ]
    assert exclusions["conflict_count"] == 1
    assert exclusions["skipped_count"] == 1
    assert exclusions["manifest_path"] == EXCLUSION_MANIFEST_RELATIVE_PATH
    assert exclusions["entries"] == [QUALITY, ".claude/agent-memory/**"]
    assert exclusions["unmatched_entries"] == [".claude/agent-memory/**"]
    assert text == json.dumps(json.loads(text), indent=2, sort_keys=True)
    assert "exclusions" not in json.loads(_artifact(plain_fs, plain_summary))


def test_absent_manifest_artifact_keys_and_single_write_unchanged() -> None:
    """Without a manifest the artifact keys and its single write are unchanged."""

    fs = _seed({QUALITY: "bundle\n", PYTHON: "py\n"})

    summary = _push(fs)

    payload = json.loads(_artifact(fs, summary))
    assert set(payload) == set(PushDownSummaryPayload.__annotations__)
    assert "exclusions" not in payload
    assert fs.write_paths.count(Path(summary.artifact_path)) == 1
    assert summary.exclusions is None
    assert isinstance(summary, ClaudePushDownSummary)


def test_cli_prints_exclusion_lines_after_artifact_line() -> None:
    """The CLI prints the artifact line, then the pinned exclusion lines."""

    corpus = json.loads(PLAN_CORPUS.read_text(encoding="utf-8"))
    case = next(c for c in corpus["cases"] if c["id"] == "unmatched-stale-entry")
    fs = _seed(
        {path: "bundle\n" for path in case["payload_paths"]},
        destination={path: "local\n" for path in case["destination_present"]},
        manifest=case["manifest_text"],
    )

    exit_code, lines = _run_cli(fs)

    assert exit_code == 0
    assert lines[0].startswith("Wrote push-down summary artifact to: ")
    assert lines[1:] == case["expected_lines"]


def test_cli_absent_manifest_prints_single_line() -> None:
    """Without a manifest the CLI prints only the artifact line."""

    fs = _seed({PYTHON: "py\n"})

    exit_code, lines = _run_cli(fs)

    assert exit_code == 0
    assert len(lines) == 1
    assert lines[0].startswith("Wrote push-down summary artifact to: ")


def test_filter_is_outermost_so_pack_excluded_paths_are_unmatched() -> None:
    """A path the pack selection already dropped leaves its entry unmatched."""

    core = {"name": "core", "label": "Core", "paths": [".claude/settings.json"]}
    fs = _seed(
        {
            ".claude/settings.json": "{}\n",
            QUALITY: "bundle\n",
        },
        manifest=QUALITY + "\n",
    )
    fs.files[BUNDLE / "pack-manifests/core.json"] = MemoryFile(json.dumps(core))

    summary = _push(fs, packs=frozenset({"core"}))

    assert [result.relative_path for result in summary.files] == [
        ".claude/settings.json"
    ]
    assert summary.exclusions is not None
    assert summary.exclusions.skipped == ()
    assert [e.normalized for e in summary.exclusions.unmatched_entries] == [QUALITY]
