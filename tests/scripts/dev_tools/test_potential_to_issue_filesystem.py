"""Tests for `scripts.dev_tools.potential_to_issue_filesystem.RealFileSystem`.

Each test replaces the `pathlib.Path` method (or `shutil.move`) that one
`RealFileSystem` method delegates to, records the call, and asserts both the
return value and the recorded arguments. No test reads or writes the local
disk.
"""

from __future__ import annotations

from pathlib import Path
from typing import TYPE_CHECKING

from scripts.dev_tools import potential_to_issue_filesystem as filesystem_mod

if TYPE_CHECKING:
    import pytest


def test_resolve_path_expands_user_then_resolves(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """`resolve_path` expands the user marker first and then resolves the path."""
    # Arrange
    calls: list[tuple[str, Path]] = []
    expanded = Path("/home/user/docs/sample.md")
    resolved = Path("/resolved/docs/sample.md")

    def fake_expanduser(self: Path) -> Path:
        """Record the expanduser call and return the expanded path."""
        calls.append(("expanduser", self))
        return expanded

    def fake_resolve(self: Path, strict: bool = False) -> Path:
        """Record the resolve call and return the resolved path."""
        calls.append(("resolve", self))
        return resolved

    monkeypatch.setattr(Path, "expanduser", fake_expanduser)
    monkeypatch.setattr(Path, "resolve", fake_resolve)

    # Act
    result = filesystem_mod.RealFileSystem().resolve_path("~/docs/sample.md")

    # Assert
    assert result == resolved
    assert calls == [
        ("expanduser", Path("~/docs/sample.md")),
        ("resolve", expanded),
    ]


def test_exists_delegates_to_path_exists(monkeypatch: pytest.MonkeyPatch) -> None:
    """`exists` returns the answer of `Path.exists` for the given path."""
    # Arrange
    calls: list[Path] = []
    target = Path("/workspace/docs/sample.md")

    def fake_exists(self: Path, *, follow_symlinks: bool = True) -> bool:
        """Record the exists call and report the path as present."""
        calls.append(self)
        return True

    monkeypatch.setattr(Path, "exists", fake_exists)

    # Act
    result = filesystem_mod.RealFileSystem().exists(target)

    # Assert
    assert result is True
    assert calls == [target]


def test_read_text_reads_utf8(monkeypatch: pytest.MonkeyPatch) -> None:
    """`read_text` reads the file as UTF-8 and returns its content."""
    # Arrange
    calls: list[tuple[Path, str | None]] = []
    target = Path("/workspace/docs/sample.md")

    def fake_read_text(
        self: Path, encoding: str | None = None, errors: str | None = None
    ) -> str:
        """Record the read call and return fixed content."""
        calls.append((self, encoding))
        return "content"

    monkeypatch.setattr(Path, "read_text", fake_read_text)

    # Act
    result = filesystem_mod.RealFileSystem().read_text(target)

    # Assert
    assert result == "content"
    assert calls == [(target, "utf-8")]


def test_write_text_writes_utf8(monkeypatch: pytest.MonkeyPatch) -> None:
    """`write_text` writes the given content as UTF-8 and returns None."""
    # Arrange
    calls: list[tuple[Path, str, str | None]] = []
    target = Path("/workspace/docs/sample.md")

    def fake_write_text(
        self: Path,
        data: str,
        encoding: str | None = None,
        errors: str | None = None,
        newline: str | None = None,
    ) -> int:
        """Record the write call and report the character count."""
        calls.append((self, data, encoding))
        return len(data)

    monkeypatch.setattr(Path, "write_text", fake_write_text)

    # Act
    result = filesystem_mod.RealFileSystem().write_text(target, "body")

    # Assert
    assert result is None
    assert calls == [(target, "body", "utf-8")]


def test_write_lines_joins_lines_with_newlines(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """`write_lines` joins the lines with newlines and writes them as UTF-8."""
    # Arrange
    calls: list[tuple[Path, str, str | None]] = []
    target = Path("/workspace/docs/sample.md")

    def fake_write_text(
        self: Path,
        data: str,
        encoding: str | None = None,
        errors: str | None = None,
        newline: str | None = None,
    ) -> int:
        """Record the write call and report the character count."""
        calls.append((self, data, encoding))
        return len(data)

    monkeypatch.setattr(Path, "write_text", fake_write_text)

    # Act
    result = filesystem_mod.RealFileSystem().write_lines(target, ["a", "b"])

    # Assert
    assert result is None
    assert calls == [(target, "a\nb", "utf-8")]


def test_ensure_dir_creates_parents(monkeypatch: pytest.MonkeyPatch) -> None:
    """`ensure_dir` creates the directory with parents and tolerates existence."""
    # Arrange
    calls: list[tuple[Path, bool, bool]] = []
    target = Path("/workspace/docs/promoted")

    def fake_mkdir(
        self: Path, mode: int = 0o777, parents: bool = False, exist_ok: bool = False
    ) -> None:
        """Record the mkdir call and its flags."""
        calls.append((self, parents, exist_ok))

    monkeypatch.setattr(Path, "mkdir", fake_mkdir)

    # Act
    result = filesystem_mod.RealFileSystem().ensure_dir(target)

    # Assert
    assert result is None
    assert calls == [(target, True, True)]


def test_move_creates_parent_then_moves(monkeypatch: pytest.MonkeyPatch) -> None:
    """`move` creates the destination parent before moving the source file."""
    # Arrange
    events: list[tuple[str, str, str]] = []
    src = Path("/workspace/docs/potential/sample.md")
    dest = Path("/workspace/docs/potential/promoted/sample.md")

    def fake_mkdir(
        self: Path, mode: int = 0o777, parents: bool = False, exist_ok: bool = False
    ) -> None:
        """Record the mkdir call with its target and flags."""
        events.append(("mkdir", str(self), f"parents={parents},exist_ok={exist_ok}"))

    def fake_move(source: str, destination: str) -> str:
        """Record the move call and return the destination."""
        events.append(("move", source, destination))
        return destination

    monkeypatch.setattr(Path, "mkdir", fake_mkdir)
    monkeypatch.setattr(filesystem_mod.shutil, "move", fake_move)

    # Act
    result = filesystem_mod.RealFileSystem().move(src, dest)

    # Assert
    assert result is None
    assert events == [
        ("mkdir", str(dest.parent), "parents=True,exist_ok=True"),
        ("move", str(src), str(dest)),
    ]


def test_file_system_protocol_members_declare_no_behavior() -> None:
    """Each `FileSystem` protocol member is a declaration whose body returns None.

    The protocol only fixes the signatures that `RealFileSystem` and the test
    doubles implement. Calling a member through the protocol class runs its
    placeholder body, which performs no IO and returns None.
    """
    # Arrange
    receiver = filesystem_mod.RealFileSystem()
    path = Path("/workspace/docs/sample.md")
    arguments: dict[str, tuple[object, ...]] = {
        "resolve_path": ("~/docs/sample.md",),
        "exists": (path,),
        "read_text": (path,),
        "write_text": (path, "body"),
        "write_lines": (path, ["a"]),
        "ensure_dir": (path,),
        "move": (path, path),
    }

    # Act: call every protocol member through the protocol class itself, so the
    # declaration body runs instead of the RealFileSystem override.
    results = {
        name: getattr(filesystem_mod.FileSystem, name)(receiver, *args)
        for name, args in arguments.items()
    }

    # Assert
    assert results == dict.fromkeys(arguments)
