"""Tests for the destination scan of the blast-radius derivation (issue #507).

Every layout is described by an injected in-memory lister; the two
``real_directory_lister`` tests replace ``os.scandir`` in the module namespace,
so no test reads the real filesystem.
"""

from __future__ import annotations

from pathlib import Path
from typing import TYPE_CHECKING

from scripts.dev_tools import push_down_claude_blast_radius_derive as scan
from scripts.dev_tools.push_down_claude_blast_radius_derive import (
    DirectoryEntry,
    collect_destination_observations,
    real_directory_lister,
)
from scripts.dev_tools.push_down_claude_blast_radius_derive_core import (
    DirectoryObservation,
)

if TYPE_CHECKING:
    from collections.abc import Iterator, Sequence
    from types import TracebackType

    import pytest

    from scripts.dev_tools.push_down_claude_blast_radius_derive import (
        DirectoryLister,
    )

ROOT = Path("/dest")


def _lister(layout: dict[str, list[DirectoryEntry]]) -> DirectoryLister:
    """Build a lister answering from a POSIX-keyed in-memory layout."""

    def list_entries(path: Path) -> Sequence[DirectoryEntry]:
        return layout.get(path.as_posix(), [])

    return list_entries


def _file(name: str) -> DirectoryEntry:
    """Build a file entry."""

    return DirectoryEntry(name, False)


def _dir(name: str) -> DirectoryEntry:
    """Build a directory entry."""

    return DirectoryEntry(name, True)


def test_collect_observations_breadth_first_depth_limited() -> None:
    """The scan visits breadth-first and stops after three levels."""

    layout = {
        "/dest": [_file("README.md"), _dir("a"), _dir("b")],
        "/dest/a": [_file("package.json"), _dir("deep")],
        "/dest/b": [_file("go.mod")],
        "/dest/a/deep": [_file("pom.xml"), _dir("deeper")],
        "/dest/a/deep/deeper": [_file("Cargo.toml")],
    }

    observations = collect_destination_observations(ROOT, _lister(layout))

    assert observations == [
        DirectoryObservation("", ("README.md",)),
        DirectoryObservation("a", ("package.json",)),
        DirectoryObservation("b", ("go.mod",)),
        DirectoryObservation("a/deep", ("pom.xml",)),
    ]


def test_collect_observations_prunes_excluded_and_dot_directories() -> None:
    """Excluded bucket names and dot-prefixed names are never visited."""

    layout = {
        "/dest": [_dir(".git"), _dir("node_modules"), _dir("docs"), _dir("src")],
        "/dest/.git": [_file("HEAD")],
        "/dest/node_modules": [_file("package.json")],
        "/dest/docs": [_file("package.json")],
        "/dest/src": [_file("main.py")],
    }

    observations = collect_destination_observations(ROOT, _lister(layout))

    assert [observation.relative_path for observation in observations] == ["", "src"]


def test_collect_observations_tolerates_lister_errors() -> None:
    """A lister failure below the root contributes zero entries."""

    def failing_lister(path: Path) -> Sequence[DirectoryEntry]:
        if path.as_posix() == "/dest":
            return [_dir("broken"), _dir("ok")]
        if path.as_posix() == "/dest/broken":
            raise PermissionError("denied")
        return [_file("package.json")]

    observations = collect_destination_observations(ROOT, failing_lister)

    assert observations == [
        DirectoryObservation("", ()),
        DirectoryObservation("broken", ()),
        DirectoryObservation("ok", ("package.json",)),
    ]


def test_collect_observations_root_failure_yields_root_only() -> None:
    """A root listing failure yields a single empty root observation."""

    def failing_lister(path: Path) -> Sequence[DirectoryEntry]:
        raise RuntimeError(f"cannot list {path}")

    observations = collect_destination_observations(ROOT, failing_lister)

    assert observations == [DirectoryObservation("", ())]


class _FakeDirEntry:
    """Minimal stand-in for ``os.DirEntry``."""

    def __init__(self, name: str, is_directory: bool) -> None:
        self.name = name
        self._is_directory = is_directory

    def is_dir(self) -> bool:
        """Report whether the fake entry is a directory."""

        return self._is_directory


class _FakeScandir:
    """Context-managed iterator standing in for ``os.scandir``'s result."""

    def __init__(self, entries: list[_FakeDirEntry]) -> None:
        self._entries = entries

    def __enter__(self) -> Iterator[_FakeDirEntry]:
        return iter(self._entries)

    def __exit__(
        self,
        exc_type: type[BaseException] | None,
        exc: BaseException | None,
        traceback: TracebackType | None,
    ) -> None:
        return None


def test_real_directory_lister_sorts_entries_ordinally(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """Entries are returned sorted by ordinal name with their directory flag."""

    entries = [
        _FakeDirEntry("beta", True),
        _FakeDirEntry("Alpha", False),
        _FakeDirEntry("alpha", True),
    ]
    requested: list[object] = []

    def fake_scandir(root: object) -> _FakeScandir:
        requested.append(root)
        return _FakeScandir(entries)

    monkeypatch.setattr(scan.os, "scandir", fake_scandir)

    result = real_directory_lister(ROOT)

    assert requested == [ROOT]
    assert result == [
        DirectoryEntry("Alpha", False),
        DirectoryEntry("alpha", True),
        DirectoryEntry("beta", True),
    ]


def test_real_directory_lister_returns_empty_on_os_error(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """An ``OSError`` from the directory read yields an empty listing."""

    def fake_scandir(root: object) -> _FakeScandir:
        raise FileNotFoundError(f"missing {root}")

    monkeypatch.setattr(scan.os, "scandir", fake_scandir)

    assert real_directory_lister(ROOT) == []
