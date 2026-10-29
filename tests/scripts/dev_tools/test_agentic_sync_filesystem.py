"""Write-path tests for the real agentic sync filesystem adapter.

Purpose:
    Prove that ``RealSyncFileSystem`` delegates each write-side operation to the
    path object it receives and to ``os.utime`` with the exact arguments. Every
    path is a recording stub and ``os.utime`` is patched at the adapter's import
    location, so nothing is created, written or touched on disk.
"""

from __future__ import annotations

from typing import TYPE_CHECKING, cast

from scripts.dev_tools import agentic_sync_filesystem

if TYPE_CHECKING:
    from pathlib import Path

    import pytest


class _RecordingDirectory:
    """Directory stub that records ``mkdir`` keyword arguments."""

    def __init__(self) -> None:
        """Start with no recorded calls."""
        self.mkdir_calls: list[dict[str, bool]] = []

    def mkdir(self, *, parents: bool, exist_ok: bool) -> None:
        """Record one directory creation request; perform no I/O."""
        self.mkdir_calls.append({"parents": parents, "exist_ok": exist_ok})


class _RecordingFile:
    """File stub with a recording parent directory and a recording writer."""

    def __init__(self) -> None:
        """Start with an empty write log and a fresh parent stub."""
        self.parent = _RecordingDirectory()
        self.writes: list[tuple[str, str]] = []

    def write_text(self, content: str, *, encoding: str) -> None:
        """Record one text write and its encoding; perform no I/O."""
        self.writes.append((content, encoding))


def test_write_text_creates_the_parent_and_writes_utf8() -> None:
    """write_text ensures the parent directory, then writes UTF-8 content."""
    target = _RecordingFile()
    adapter = agentic_sync_filesystem.RealSyncFileSystem()

    adapter.write_text(cast("Path", target), "body")

    assert target.parent.mkdir_calls == [{"parents": True, "exist_ok": True}]
    assert target.writes == [("body", "utf-8")]


def test_set_mtime_applies_the_same_access_and_modification_time(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """set_mtime passes one timestamp as both the access and modification time."""
    calls: list[tuple[object, tuple[float, float]]] = []

    def record(path: object, times: tuple[float, float]) -> None:
        """Record the utime arguments instead of touching the file."""
        calls.append((path, times))

    monkeypatch.setattr(agentic_sync_filesystem.os, "utime", record)
    target = _RecordingFile()

    agentic_sync_filesystem.RealSyncFileSystem().set_mtime(cast("Path", target), 12.5)

    assert calls == [(target, (12.5, 12.5))]


def test_ensure_dir_creates_missing_parents_idempotently() -> None:
    """ensure_dir requests a recursive, idempotent directory creation."""
    directory = _RecordingDirectory()

    agentic_sync_filesystem.RealSyncFileSystem().ensure_dir(cast("Path", directory))

    assert directory.mkdir_calls == [{"parents": True, "exist_ok": True}]
