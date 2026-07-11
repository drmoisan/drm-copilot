"""Unit tests for the local epic-readiness filesystem boundary."""

from __future__ import annotations

from pathlib import Path
from typing import cast

from scripts.dev_tools.epic_planner_readiness import LocalReadinessFileSystem


class PathStub:
    """Path-shaped in-memory stub for local adapter delegation."""

    def is_file(self) -> bool:
        return True

    def is_dir(self) -> bool:
        return True

    def read_text(self, *, encoding: str) -> str:
        assert encoding == "utf-8"
        return "content"

    def read_bytes(self) -> bytes:
        return b"content"

    def glob(self, pattern: str) -> list[Path]:
        assert pattern == "*.md"
        return [Path("b.md"), Path("a.md")]


def test_local_filesystem_delegates_all_read_operations() -> None:
    """Cover the production adapter without creating runtime files."""

    file_system = LocalReadinessFileSystem()
    path = cast("Path", PathStub())

    assert file_system.is_file(path)
    assert file_system.is_dir(path)
    assert file_system.read_text(path) == "content"
    assert file_system.read_bytes(path) == b"content"
    assert file_system.glob(path, "*.md") == [Path("a.md"), Path("b.md")]
