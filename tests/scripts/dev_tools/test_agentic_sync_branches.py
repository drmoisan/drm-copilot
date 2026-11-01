"""Branch-level tests for agentic_sync that the main suite does not reach.

Purpose:
    Cover the real filesystem adapter's read-only paths against committed
    repository files, the constructor guard, the source-selection branches and
    the CLI validation and force-direction branches. Nothing is written to disk:
    the real adapter is exercised only through reads of committed fixtures, and
    the CLI paths are driven through a patched ``Path`` and a fake syncer.
"""

from __future__ import annotations

import importlib.util
import sys
import types
from pathlib import Path
from typing import TYPE_CHECKING

import pytest

from scripts.dev_tools import (
    agentic_sync,
    agentic_sync_artifacts,
    agentic_sync_filesystem,
)
from tests.scripts.dev_tools.agentic_sync_test_support import (
    InMemorySyncFileSystem,
    MemoryFile,
)

if TYPE_CHECKING:
    from collections.abc import Callable

REPO_ROOT = Path(__file__).resolve().parents[3]
FIXTURE_ROOT = REPO_ROOT / "tests" / "fixtures" / "discovery_workflow"
FIXTURE_FILE = FIXTURE_ROOT / "requests" / "inventory.json"
LEFT = Path("/left/.github/agents/a.md")
RIGHT = Path("/right/.github/agents/a.md")


def test_real_adapter_lists_only_files_under_a_committed_root() -> None:
    """The real adapter walks a committed tree, skipping directories, sorted."""
    adapter = agentic_sync.RealSyncFileSystem()

    listed = adapter.list_files(FIXTURE_ROOT)

    assert listed == sorted(listed)
    assert FIXTURE_FILE in listed
    assert all(path.is_file() for path in listed)
    assert FIXTURE_ROOT / "requests" not in listed


def test_real_adapter_returns_no_files_for_a_missing_root() -> None:
    """A root that is not a directory lists nothing instead of raising."""
    adapter = agentic_sync.RealSyncFileSystem()

    assert adapter.list_files(FIXTURE_ROOT / "absent-root") == []


def test_real_adapter_reads_committed_file_metadata_and_text() -> None:
    """Existence, text and mtime reads come from the committed fixture."""
    adapter = agentic_sync.RealSyncFileSystem()

    assert adapter.is_file(FIXTURE_FILE) is True
    assert adapter.is_file(FIXTURE_ROOT) is False
    assert '"operation"' in adapter.read_text(FIXTURE_FILE)
    assert adapter.get_mtime(FIXTURE_FILE) > 0


def test_negative_threshold_is_rejected_at_construction() -> None:
    """The syncer enforces its non-negative threshold invariant eagerly."""
    with pytest.raises(ValueError, match="non-negative"):
        agentic_sync.AgenticSyncer(InMemorySyncFileSystem(), threshold_seconds=-1)


def _sync_pair(
    *,
    left_mtime: float,
    right_mtime: float,
    force_direction: agentic_sync.ForceDirection | None,
) -> tuple[str, str]:
    """Sync one differing pair through the public path; return both contents."""
    fs = InMemorySyncFileSystem(
        {
            LEFT: MemoryFile("left-text", left_mtime),
            RIGHT: MemoryFile("right-text", right_mtime),
        }
    )
    syncer = agentic_sync.AgenticSyncer(
        fs, threshold_seconds=0, force_direction=force_direction
    )

    syncer.sync_repos(Path("/left"), Path("/right"))

    left_file = fs.get_file(LEFT)
    right_file = fs.get_file(RIGHT)
    assert left_file is not None and right_file is not None
    return left_file.content, right_file.content


@pytest.mark.parametrize(
    ("force_direction", "left_mtime", "right_mtime", "expected"),
    [
        ("left-to-right", 1.0, 9.0, "left-text"),
        ("right-to-left", 9.0, 1.0, "right-text"),
        (None, 9.0, 1.0, "left-text"),
        (None, 1.0, 9.0, "right-text"),
    ],
)
def test_source_selection_honours_force_then_mtime(
    force_direction: agentic_sync.ForceDirection | None,
    left_mtime: float,
    right_mtime: float,
    expected: str,
) -> None:
    """Forced direction wins, then the newer mtime decides the source.

    Equal timestamps are always equivalent under any threshold, so the
    selector's tie branch is unreachable through the public sync path.
    """
    left_content, right_content = _sync_pair(
        left_mtime=left_mtime,
        right_mtime=right_mtime,
        force_direction=force_direction,
    )

    assert (left_content, right_content) == (expected, expected)


class _FakePath:
    """Path stand-in whose directory check is configurable per path string."""

    directories: frozenset[str] = frozenset()

    def __init__(self, path: str) -> None:
        self.path = path

    def expanduser(self) -> _FakePath:
        return self

    def resolve(self) -> _FakePath:
        return self

    def is_dir(self) -> bool:
        return self.path in type(self).directories

    def __str__(self) -> str:
        return self.path

    def __truediv__(self, other: str) -> _FakePath:
        return _FakePath(f"{self.path}/{other}")

    @staticmethod
    def cwd() -> _FakePath:
        return _FakePath("/cwd")

    @property
    def parent(self) -> _FakePath:
        return _FakePath(self.path.rsplit("/", 1)[0] or "/")

    def as_posix(self) -> str:
        return self.path


def _install_cli_fakes(
    monkeypatch: pytest.MonkeyPatch, *, directories: frozenset[str]
) -> Callable[[], agentic_sync.ForceDirection | None]:
    """Patch Path, the adapter and the syncer; return the captured direction."""
    _FakePath.directories = directories
    captured: dict[str, agentic_sync.ForceDirection | None] = {}
    summary = agentic_sync.SyncSummary(
        repo_left="/left",
        repo_right="/right",
        started_at=agentic_sync.datetime.now(agentic_sync.UTC),
        finished_at=agentic_sync.datetime.now(agentic_sync.UTC),
        force_direction=None,
        actions=[],
    )

    class _FakeFs:
        def ensure_dir(self, path: object) -> None:
            return None

        def write_text(self, path: object, content: str) -> None:
            return None

    class _FakeSyncer:
        def __init__(
            self,
            fs: object,
            *,
            threshold_seconds: int,
            force_direction: agentic_sync.ForceDirection | None,
        ) -> None:
            captured["force"] = force_direction

        def sync_repos(self, left: object, right: object) -> agentic_sync.SyncSummary:
            return summary

    monkeypatch.setattr(agentic_sync, "Path", _FakePath)
    monkeypatch.setattr(agentic_sync, "RealSyncFileSystem", _FakeFs)
    monkeypatch.setattr(agentic_sync, "AgenticSyncer", _FakeSyncer)
    return lambda: captured.get("force")


def test_main_rejects_a_missing_left_or_right_repository(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """Each repository path is validated before any sync runs."""
    _install_cli_fakes(monkeypatch, directories=frozenset({"/right"}))
    with pytest.raises(ValueError, match="Left repo is not a directory"):
        agentic_sync.main(["/left", "/right"])

    _install_cli_fakes(monkeypatch, directories=frozenset({"/left"}))
    with pytest.raises(ValueError, match="Right repo is not a directory"):
        agentic_sync.main(["/left", "/right"])


@pytest.mark.parametrize(
    ("flag", "expected"),
    [
        ("--force-left-to-right", "left-to-right"),
        ("--force-right-to-left", "right-to-left"),
    ],
)
def test_main_forwards_the_forced_direction_flag(
    monkeypatch: pytest.MonkeyPatch, flag: str, expected: str
) -> None:
    """Each force flag selects the matching direction for the syncer."""
    force_direction = _install_cli_fakes(
        monkeypatch, directories=frozenset({"/left", "/right"})
    )

    assert agentic_sync.main(["/left", "/right", flag]) == 0
    assert force_direction() == expected


def _load_agentic_sync_copy() -> types.ModuleType:
    """Execute agentic_sync.py as a fresh, unregistered module and return it.

    The import block runs against whatever sys.modules holds at call time, so a
    test can model the bundled layout without touching the real module object.
    """
    spec = importlib.util.spec_from_file_location(
        "agentic_sync_layout_probe", agentic_sync.__file__
    )
    assert spec is not None and spec.loader is not None
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def test_bundled_layout_imports_the_split_modules_from_dev_tools(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """Without the scripts package the synchronizer imports from dev_tools."""
    # A None entry makes the scripts-package import raise ModuleNotFoundError
    # named for that module; the dev_tools names resolve to the real modules.
    monkeypatch.setitem(sys.modules, "scripts.dev_tools.agentic_sync_artifacts", None)
    monkeypatch.setitem(sys.modules, "dev_tools", types.ModuleType("dev_tools"))
    monkeypatch.setitem(
        sys.modules, "dev_tools.agentic_sync_artifacts", agentic_sync_artifacts
    )
    monkeypatch.setitem(
        sys.modules, "dev_tools.agentic_sync_filesystem", agentic_sync_filesystem
    )

    module = _load_agentic_sync_copy()

    assert module.SyncSummary is agentic_sync_artifacts.SyncSummary
    assert module.RealSyncFileSystem is agentic_sync_filesystem.RealSyncFileSystem


class _MissingDependencyFinder:
    """Meta path finder that reports a third-party dependency as missing."""

    def find_spec(
        self, fullname: str, path: object = None, target: object = None
    ) -> None:
        """Raise for the artifacts module as if one of its imports were absent."""
        if fullname == "scripts.dev_tools.agentic_sync_artifacts":
            raise ModuleNotFoundError("No module named 'yaml'", name="yaml")


def test_a_missing_third_party_dependency_is_not_masked_by_the_fallback(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """Only a missing scripts package selects the fallback; other errors propagate."""
    monkeypatch.delitem(sys.modules, "scripts.dev_tools.agentic_sync_artifacts")
    monkeypatch.setattr(sys, "meta_path", [_MissingDependencyFinder(), *sys.meta_path])

    with pytest.raises(ModuleNotFoundError) as error:
        _load_agentic_sync_copy()

    assert error.value.name == "yaml"
