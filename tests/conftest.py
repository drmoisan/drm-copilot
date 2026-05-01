"""Pytest collection bootstrap helpers for repository-local imports.

Purpose:
    Ensure repository-local modules are importable during test collection.

Usage:
    Imported automatically by pytest before test module collection.

Flow:
    Resolve repository root from this file location, then conditionally insert it
    into ``sys.path``.

Invariants / Constraints:
    The repository root path must be the parent of the ``tests`` directory.

Side Effects:
    Mutates ``sys.path`` when the repository root path is missing.

Attributes:
    None.
"""

from __future__ import annotations

import io
import os
import subprocess
import sys
from itertools import count
from pathlib import Path, PurePosixPath
from typing import TYPE_CHECKING, cast

import pytest

if TYPE_CHECKING:
    from collections.abc import Iterator


def _ensure_repo_root_on_sys_path() -> None:
    """Insert repository root into ``sys.path`` when not already present.

    Purpose:
        Keep test imports deterministic across local and CI execution environments.

    Args:
        None.

    Returns:
        None: The function updates interpreter import state in place.

    Raises:
        None.

    Side Effects:
        Prepends the resolved repository root to ``sys.path`` when missing.
    """
    repo_root = Path(__file__).resolve().parents[1]

    # Guard duplicate path insertion so import ordering stays stable.
    if str(repo_root) not in sys.path:
        sys.path.insert(0, str(repo_root))


_ensure_repo_root_on_sys_path()


@pytest.fixture(autouse=True)
def guard_unmocked_code_launcher_subprocess(
    request: pytest.FixtureRequest,
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """Block unmocked VS Code launcher subprocess calls in scoped unit tests.

    Purpose:
        Enforce hermetic behavior for target dev-tools unit tests by preventing
        accidental real editor-launch subprocess calls.

    Args:
        request (pytest.FixtureRequest): Current test request metadata.
        monkeypatch (pytest.MonkeyPatch): Fixture used to patch subprocess calls.

    Returns:
        None: Applies monkeypatch behavior for the active test when in scope.

    Raises:
        AssertionError: When a scoped test attempts an unmocked launcher
            subprocess invocation for executable tokens ``code``, ``code.cmd``,
            or ``code.exe``.

    Side Effects:
        Patches ``subprocess.run`` during scoped tests and leaves all other
        tests unchanged.
    """
    raw_node_id = str(getattr(getattr(request, "node", None), "nodeid", ""))
    normalized_node_id = raw_node_id.replace("\\", "/")
    scoped_module_prefix = "tests/scripts/dev_tools/test_new_active_feature_folder"
    allowlist = ("default_code_launcher",)

    # Guard only the targeted module to avoid unrelated fixture side effects.
    if scoped_module_prefix not in normalized_node_id:
        return

    # Explicitly allow launcher-specific tests that already mock subprocess.
    if any(allowed in normalized_node_id for allowed in allowlist):
        return

    def _extract_executable_token(command: object) -> str | None:
        """Extract a normalized executable token from subprocess command input."""
        if command is None:
            return None

        if isinstance(command, list | tuple):
            if not command:
                return None
            token_text = str(cast("object", command[0]))
        else:
            token_text = str(command)
        return token_text.replace("\\", "/").rsplit("/", maxsplit=1)[-1].lower()

    def _guarded_subprocess_run(
        *args: object, **kwargs: object
    ) -> subprocess.CompletedProcess[str]:
        """Intercept subprocess calls and block unmocked VS Code launchers."""
        command = args[0] if args else kwargs.get("args")
        executable_token = _extract_executable_token(command)
        blocked_tokens = {"code", "code.cmd", "code.exe"}

        # Fail fast only for known VS Code launcher executable names.
        if executable_token in blocked_tokens:
            raise AssertionError(
                "Blocked unmocked code launcher subprocess: "
                f"executable={executable_token}, nodeid={raw_node_id}"
            )

        # Keep non-launcher subprocess behavior deterministic and side-effect free
        # within this scoped test module.
        return subprocess.CompletedProcess(args=[], returncode=1, stdout="", stderr="")

    monkeypatch.setattr(subprocess, "run", _guarded_subprocess_run)


_MEM_TEST_ROOT_COUNTER = count(start=1)


@pytest.fixture
def mem_fs_path(monkeypatch: pytest.MonkeyPatch) -> Path:
    """Provide an in-memory filesystem ``Path`` compatible with ``pathlib.Path`` APIs.

    Purpose:
        Replace pytest's default filesystem-backed temporary directory fixture with
        an in-memory path store to enforce repository policy against temporary file
        usage in unit tests. The fixture name reflects its actual behavior: a
        fully in-memory filesystem, not an on-disk temporary directory.

    Args:
        monkeypatch (pytest.MonkeyPatch): Utility used to patch ``pathlib.Path``
            methods for the duration of a single test.

    Returns:
        Path: A deterministic root path for test-local in-memory files.

    Raises:
        FileNotFoundError: When reading paths that do not exist in the in-memory
            store.
        IsADirectoryError: When reading a directory as a file.
        NotADirectoryError: When a directory operation targets a file path.

    Side Effects:
        Temporarily patches selected ``pathlib.Path`` methods so file-system
        operations under the returned root operate purely in memory.
    """
    memory_root = Path(f"/__pytest_mem__/{next(_MEM_TEST_ROOT_COUNTER)}")
    files: dict[str, bytes] = {}
    directories: set[str] = set()

    def _key(path: Path) -> str:
        """Normalize a path into a deterministic string key.

        Purpose:
            Canonicalize incoming ``Path`` instances so lookups remain stable
            across path-object construction patterns.

        Args:
            path (Path): Input path to normalize.

        Returns:
            str: POSIX-like path key used by in-memory file and directory stores.

        Raises:
            None.

        Side Effects:
            None.
        """
        raw = path.as_posix()
        if not raw.startswith("/"):
            raw = "/" + raw
        if raw != "/":
            raw = raw.rstrip("/")
        return raw

    root_key = _key(memory_root)
    directories.add(root_key)

    def _is_memory_path(path: Path) -> bool:
        """Determine whether a path is part of the in-memory test namespace.

        Purpose:
            Route patched ``Path`` method calls to in-memory behavior only for test
            paths, while preserving normal behavior for real repository paths.

        Args:
            path (Path): Candidate path.

        Returns:
            bool: ``True`` when the path belongs to the in-memory namespace.

        Raises:
            None.

        Side Effects:
            None.
        """
        key = _key(path)
        return key == root_key or key.startswith(f"{root_key}/")

    def _ensure_parent_dir_exists(path: Path) -> None:
        """Validate that the parent directory exists in memory before writing.

        Purpose:
            Match ``pathlib`` behavior by failing writes when parent directories do
            not exist.

        Args:
            path (Path): File path being created or updated.

        Returns:
            None.

        Raises:
            FileNotFoundError: If the parent directory is absent.

        Side Effects:
            None.
        """
        parent_key = _key(path.parent)
        if parent_key not in directories:
            raise FileNotFoundError(f"No such directory: {path.parent}")

    def _mkdir_memory(path: Path, *, parents: bool, exist_ok: bool) -> None:
        """Create a directory entry in the in-memory store.

        Purpose:
            Provide policy-compliant directory creation without touching disk.

        Args:
            path (Path): Directory path to create.
            parents (bool): Whether missing parents should be created.
            exist_ok (bool): Whether existing directory is acceptable.

        Returns:
            None.

        Raises:
            FileExistsError: If the target exists and ``exist_ok`` is ``False``.
            FileNotFoundError: If parent directories are missing and ``parents`` is
                ``False``.

        Side Effects:
            Mutates the in-memory directory set.
        """
        target_key = _key(path)
        if target_key in files:
            raise FileExistsError(f"File exists: {path}")
        if target_key in directories:
            if exist_ok:
                return
            raise FileExistsError(f"Directory exists: {path}")

        if parents:
            # Populate every intermediate directory to mirror pathlib(parents=True).
            current = path
            lineage: list[str] = []
            while True:
                lineage.append(_key(current))
                if _key(current) == root_key or current.parent == current:
                    break
                current = current.parent
            for entry in reversed(lineage):
                if entry in files:
                    raise FileExistsError(f"File exists for directory path: {entry}")
                directories.add(entry)
            return

        parent_key = _key(path.parent)
        if parent_key not in directories:
            raise FileNotFoundError(f"No such directory: {path.parent}")
        directories.add(target_key)

    original_mkdir = Path.mkdir
    original_write_text = Path.write_text
    original_read_text = Path.read_text
    original_write_bytes = Path.write_bytes
    original_read_bytes = Path.read_bytes
    original_exists = Path.exists
    original_is_file = Path.is_file
    original_is_dir = Path.is_dir
    original_iterdir = Path.iterdir
    original_open = Path.open
    original_unlink = Path.unlink
    original_rmdir = Path.rmdir
    original_resolve = Path.resolve
    original_glob = Path.glob
    original_rglob = Path.rglob
    original_touch = Path.touch
    original_chmod = Path.chmod
    original_replace = Path.replace
    original_getcwd = os.getcwd
    original_chdir = os.chdir

    current_cwd = original_getcwd()

    def _mkdir(
        self: Path, mode: int = 0o777, parents: bool = False, exist_ok: bool = False
    ) -> None:
        """Create directories in memory for fixture-managed paths."""
        if not _is_memory_path(self):
            original_mkdir(self, mode=mode, parents=parents, exist_ok=exist_ok)
            return
        _mkdir_memory(self, parents=parents, exist_ok=exist_ok)

    def _write_text(
        self: Path,
        data: str,
        encoding: str | None = None,
        errors: str | None = None,
        newline: str | None = None,
    ) -> int:
        """Write UTF-8 text content to an in-memory file."""
        del errors
        del newline
        if not _is_memory_path(self):
            return original_write_text(self, data, encoding=encoding)
        _ensure_parent_dir_exists(self)
        file_key = _key(self)
        files[file_key] = data.encode(encoding or "utf-8")
        return len(data)

    def _read_text(
        self: Path, encoding: str | None = None, errors: str | None = None
    ) -> str:
        """Read UTF-8 text content from an in-memory file."""
        del errors
        if not _is_memory_path(self):
            return original_read_text(self, encoding=encoding)
        file_key = _key(self)
        if file_key not in files:
            if file_key in directories:
                raise IsADirectoryError(str(self))
            raise FileNotFoundError(str(self))
        return files[file_key].decode(encoding or "utf-8")

    def _write_bytes(self: Path, data: bytes) -> int:
        """Write bytes to an in-memory file."""
        if not _is_memory_path(self):
            return original_write_bytes(self, data)
        _ensure_parent_dir_exists(self)
        files[_key(self)] = data
        return len(data)

    def _read_bytes(self: Path) -> bytes:
        """Read bytes from an in-memory file."""
        if not _is_memory_path(self):
            return original_read_bytes(self)
        file_key = _key(self)
        if file_key not in files:
            if file_key in directories:
                raise IsADirectoryError(str(self))
            raise FileNotFoundError(str(self))
        return files[file_key]

    def _exists(self: Path) -> bool:
        """Check in-memory existence for fixture-managed paths."""
        if not _is_memory_path(self):
            return original_exists(self)
        key = _key(self)
        return key in files or key in directories

    def _is_file(self: Path) -> bool:
        """Check in-memory file status for fixture-managed paths."""
        if not _is_memory_path(self):
            return original_is_file(self)
        return _key(self) in files

    def _is_dir(self: Path) -> bool:
        """Check in-memory directory status for fixture-managed paths."""
        if not _is_memory_path(self):
            return original_is_dir(self)
        return _key(self) in directories

    def _iterdir(self: Path) -> Iterator[Path]:
        """Iterate immediate in-memory children for fixture-managed paths."""
        if not _is_memory_path(self):
            yield from original_iterdir(self)
            return

        parent_key = _key(self)
        if parent_key not in directories:
            raise FileNotFoundError(str(self))

        prefix = f"{parent_key}/"
        yielded: set[str] = set()

        # Yield direct children from directories first to mirror pathlib semantics.
        for directory in sorted(directories):
            if not directory.startswith(prefix):
                continue
            remainder = directory[len(prefix) :]
            if not remainder or "/" in remainder:
                continue
            yielded.add(remainder)
            yield Path(prefix + remainder)

        # Then include direct file children that were not already yielded.
        for file_key in sorted(files):
            if not file_key.startswith(prefix):
                continue
            remainder = file_key[len(prefix) :]
            if not remainder or "/" in remainder or remainder in yielded:
                continue
            yield Path(prefix + remainder)

    def _open(
        self: Path,
        mode: str = "r",
        buffering: int = -1,
        encoding: str | None = None,
        errors: str | None = None,
        newline: str | None = None,
    ):
        """Open an in-memory stream for fixture-managed paths."""
        del buffering
        del errors
        del newline
        if not _is_memory_path(self):
            return original_open(self, mode=mode, encoding=encoding)

        file_key = _key(self)
        binary_mode = "b" in mode
        write_mode = any(flag in mode for flag in ("w", "a", "+"))

        if write_mode:
            _ensure_parent_dir_exists(self)

        initial_bytes = files.get(file_key, b"")
        if "w" in mode:
            initial_bytes = b""

        if binary_mode:
            stream = io.BytesIO(initial_bytes)
            if "a" in mode:
                stream.seek(0, io.SEEK_END)

            if write_mode:
                original_close = stream.close

                def _close_and_store() -> None:
                    """Persist bytes to in-memory storage when stream closes."""
                    files[file_key] = stream.getvalue()
                    original_close()

                stream.close = _close_and_store  # type: ignore[method-assign]
            return stream

        text_data = initial_bytes.decode(encoding or "utf-8")
        stream = io.StringIO(text_data)
        if "a" in mode:
            stream.seek(0, io.SEEK_END)

        if write_mode:
            original_close = stream.close

            def _close_and_store_text() -> None:
                """Persist text to in-memory storage when stream closes."""
                files[file_key] = stream.getvalue().encode(encoding or "utf-8")
                original_close()

            stream.close = _close_and_store_text  # type: ignore[method-assign]
        return stream

    def _unlink(self: Path, missing_ok: bool = False) -> None:
        """Delete an in-memory file."""
        if not _is_memory_path(self):
            original_unlink(self, missing_ok=missing_ok)
            return
        file_key = _key(self)
        if file_key in files:
            del files[file_key]
            return
        if missing_ok:
            return
        raise FileNotFoundError(str(self))

    def _rmdir(self: Path) -> None:
        """Remove an empty in-memory directory."""
        if not _is_memory_path(self):
            original_rmdir(self)
            return
        dir_key = _key(self)
        if dir_key not in directories:
            raise FileNotFoundError(str(self))
        if any(k.startswith(f"{dir_key}/") for k in directories if k != dir_key):
            raise OSError(f"Directory not empty: {self}")
        if any(k.startswith(f"{dir_key}/") for k in files):
            raise OSError(f"Directory not empty: {self}")
        directories.remove(dir_key)

    def _resolve(self: Path, strict: bool = False) -> Path:
        """Resolve in-memory paths without touching the real filesystem."""
        if not _is_memory_path(self):
            return original_resolve(self, strict=strict)
        if strict and not (_exists(self)):
            raise FileNotFoundError(str(self))
        return self

    def _pattern_matches(relative_path: str, pattern: str) -> bool:
        """Evaluate glob-style pattern matches with ``**`` zero-depth support.

        Purpose:
            ``PurePath.match`` does not treat ``**`` exactly like ``Path.glob``
            for all zero-depth directory cases (for example ``scripts/**/*.json``
            vs ``scripts/config.json``). This helper preserves expected glob
            behavior for tests that rely on standard pathlib matching.

        Args:
            relative_path (str): Candidate path relative to the glob base.
            pattern (str): Glob expression.

        Returns:
            bool: ``True`` when candidate should be included.

        Raises:
            None.

        Side Effects:
            None.
        """
        candidate = PurePosixPath(relative_path)
        if candidate.match(pattern):
            return True
        if "/**/" in pattern:
            zero_depth_pattern = pattern.replace("/**/", "/")
            return candidate.match(zero_depth_pattern)
        return False

    def _glob(self: Path, pattern: str) -> Iterator[Path]:
        """Support in-memory glob lookups for fixture-managed paths."""
        if not _is_memory_path(self):
            yield from original_glob(self, pattern)
            return

        base_key = _key(self)
        prefix = f"{base_key}/"

        # Evaluate matches using relative POSIX paths to mirror pathlib glob logic.
        for directory in sorted(directories):
            if directory == base_key or not directory.startswith(prefix):
                continue
            rel = directory[len(prefix) :]
            if _pattern_matches(rel, pattern):
                yield Path(directory)

        for file_key in sorted(files):
            if not file_key.startswith(prefix):
                continue
            rel = file_key[len(prefix) :]
            if _pattern_matches(rel, pattern):
                yield Path(file_key)

    def _rglob(self: Path, pattern: str) -> Iterator[Path]:
        """Support recursive in-memory glob lookups for fixture-managed paths."""
        if not _is_memory_path(self):
            yield from original_rglob(self, pattern)
            return
        yield from _glob(self, f"**/{pattern}")

    def _touch(self: Path, mode: int = 0o666, exist_ok: bool = True) -> None:
        """Create or update an in-memory file timestamp-equivalent entry."""
        del mode
        if not _is_memory_path(self):
            original_touch(self, mode=0o666, exist_ok=exist_ok)
            return
        file_key = _key(self)
        if file_key in directories:
            raise IsADirectoryError(str(self))
        if file_key in files and not exist_ok:
            raise FileExistsError(str(self))
        _ensure_parent_dir_exists(self)
        files[file_key] = files.get(file_key, b"")

    def _chmod(self: Path, mode: int, *, follow_symlinks: bool = True) -> None:
        """No-op chmod for in-memory files to satisfy executable-path tests."""
        if not _is_memory_path(self):
            original_chmod(self, mode, follow_symlinks=follow_symlinks)
            return
        if not _exists(self):
            raise FileNotFoundError(str(self))

    def _replace(self: Path, target: Path) -> Path:
        """Replace a target path in memory, emulating ``Path.replace`` semantics."""
        if not _is_memory_path(self) and not _is_memory_path(target):
            return original_replace(self, target)

        source_key = _key(self)
        target_key = _key(target)
        if source_key not in files:
            raise FileNotFoundError(str(self))
        _ensure_parent_dir_exists(target)
        files[target_key] = files[source_key]
        del files[source_key]
        return target

    def _getcwd() -> str:
        """Return logical cwd, including in-memory cwd transitions."""
        return current_cwd

    def _chdir(path: str | os.PathLike[str]) -> None:
        """Change logical cwd for memory paths without requiring real directories."""
        nonlocal current_cwd
        candidate = Path(path)
        if _is_memory_path(candidate):
            if not _exists(candidate) or not _is_dir(candidate):
                raise FileNotFoundError(str(candidate))
            current_cwd = _key(candidate)
            return
        original_chdir(path)
        current_cwd = original_getcwd()

    monkeypatch.setattr(Path, "mkdir", _mkdir)
    monkeypatch.setattr(Path, "write_text", _write_text)
    monkeypatch.setattr(Path, "read_text", _read_text)
    monkeypatch.setattr(Path, "write_bytes", _write_bytes)
    monkeypatch.setattr(Path, "read_bytes", _read_bytes)
    monkeypatch.setattr(Path, "exists", _exists)
    monkeypatch.setattr(Path, "is_file", _is_file)
    monkeypatch.setattr(Path, "is_dir", _is_dir)
    monkeypatch.setattr(Path, "iterdir", _iterdir)
    monkeypatch.setattr(Path, "open", _open)
    monkeypatch.setattr(Path, "unlink", _unlink)
    monkeypatch.setattr(Path, "rmdir", _rmdir)
    monkeypatch.setattr(Path, "resolve", _resolve)
    monkeypatch.setattr(Path, "glob", _glob)
    monkeypatch.setattr(Path, "rglob", _rglob)
    monkeypatch.setattr(Path, "touch", _touch)
    monkeypatch.setattr(Path, "chmod", _chmod)
    monkeypatch.setattr(Path, "replace", _replace)
    monkeypatch.setattr(os, "getcwd", _getcwd)
    monkeypatch.setattr(os, "chdir", _chdir)

    return memory_root
