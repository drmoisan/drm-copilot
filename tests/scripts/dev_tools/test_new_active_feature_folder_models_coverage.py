"""Focused coverage tests for new_active_feature_folder_models helpers."""

from __future__ import annotations

from datetime import datetime
from pathlib import Path
from zoneinfo import ZoneInfo

import pytest

from scripts.dev_tools import new_active_feature_folder_models as mod


def test_real_filesystem_copy_tree_preserves_relative_paths(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """Verify RealFileSystem.copy_tree preserves each source-relative path.

    Purpose:
        Lock in the recursive copy contract so the disk-backed filesystem adapter
        copies files beneath the destination root without flattening nested
        directory structure.

    Args:
        monkeypatch: Pytest fixture used to replace filesystem-touching behavior
            with deterministic in-memory observers.

    Returns:
        None: Assertions validate the captured destination paths.

    Raises:
        AssertionError: Raised when copied destination paths do not preserve the
            original source-relative layout.

    Side Effects:
        Monkeypatches ``Path.rglob``, ``Path.is_dir``, and ``RealFileSystem.copy_file``
        for the duration of the test.
    """
    src_root = Path("/workspace/templates")
    dest_root = Path("/workspace/output")
    nested_file = src_root / "nested" / "one.md"
    top_level_file = src_root / "two.txt"
    nested_dir = src_root / "nested"
    observed_copies: list[tuple[Path, Path]] = []

    def fake_rglob(self: Path, pattern: str) -> list[Path]:
        assert self == src_root
        assert pattern == "*"
        return [nested_dir, nested_file, top_level_file]

    def fake_is_dir(self: Path) -> bool:
        return self == nested_dir

    def fake_copy_file(self: mod.RealFileSystem, src: Path, dest: Path) -> None:
        observed_copies.append((src, dest))

    monkeypatch.setattr(Path, "rglob", fake_rglob, raising=True)
    monkeypatch.setattr(Path, "is_dir", fake_is_dir, raising=True)
    monkeypatch.setattr(mod.RealFileSystem, "copy_file", fake_copy_file, raising=True)

    filesystem = mod.RealFileSystem()
    filesystem.copy_tree(src_root, dest_root)

    assert observed_copies == [
        (nested_file, dest_root / "nested" / "one.md"),
        (top_level_file, dest_root / "two.txt"),
    ]


def test_real_filesystem_list_files_returns_empty_for_missing_path(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """Verify RealFileSystem.list_files returns an empty list for missing directories.

    Purpose:
        Lock in the safe missing-path behavior so callers can scan optional
        directories without wrapping the filesystem adapter in existence guards.

    Args:
        monkeypatch: Pytest fixture used to replace ``Path.exists`` with a
            deterministic missing-path response.

    Returns:
        None: Assertions validate the empty-list contract.

    Raises:
        AssertionError: Raised when the filesystem adapter returns any entries for
            a directory reported as missing.

    Side Effects:
        Monkeypatches ``Path.exists`` for the duration of the test.
    """
    missing_path = Path("/workspace/missing")

    def fake_exists(self: Path) -> bool:
        assert self == missing_path
        return False

    monkeypatch.setattr(Path, "exists", fake_exists, raising=True)

    filesystem = mod.RealFileSystem()

    assert filesystem.list_files(missing_path) == []


def test_real_filesystem_move_replaces_existing_destination_file(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """Verify RealFileSystem.move unlinks an existing destination file first.

    Purpose:
        Preserve the overwrite contract for timestamped plan materialization so a
        pre-existing destination file is removed before the source is moved.

    Args:
        monkeypatch: Pytest fixture used to replace path-mutation methods with
            deterministic observers.

    Returns:
        None: Assertions validate the unlink-then-replace sequence.

    Raises:
        AssertionError: Raised when the destination file is not unlinked before
            the source replace operation executes.

    Side Effects:
        Monkeypatches ``Path.mkdir``, ``Path.exists``, ``Path.is_file``,
        ``Path.unlink``, and ``Path.replace`` for the duration of the test.
    """
    src_path = Path("/workspace/source.md")
    dest_path = Path("/workspace/out/target.md")
    observed_calls: list[str] = []

    def fake_mkdir(self: Path, parents: bool, exist_ok: bool) -> None:
        assert self == dest_path.parent
        assert parents is True
        assert exist_ok is True
        observed_calls.append("mkdir")

    def fake_exists(self: Path) -> bool:
        if self == dest_path:
            return True
        return False

    def fake_is_file(self: Path) -> bool:
        return self == dest_path

    def fake_unlink(self: Path) -> None:
        assert self == dest_path
        observed_calls.append("unlink")

    def fake_replace(self: Path, target: Path) -> None:
        assert self == src_path
        assert target == dest_path
        observed_calls.append("replace")

    monkeypatch.setattr(Path, "mkdir", fake_mkdir, raising=True)
    monkeypatch.setattr(Path, "exists", fake_exists, raising=True)
    monkeypatch.setattr(Path, "is_file", fake_is_file, raising=True)
    monkeypatch.setattr(Path, "unlink", fake_unlink, raising=True)
    monkeypatch.setattr(Path, "replace", fake_replace, raising=True)

    filesystem = mod.RealFileSystem()
    filesystem.move(src_path, dest_path)

    assert observed_calls == ["mkdir", "unlink", "replace"]


def test_real_filesystem_exists_and_ensure_dir_delegate_to_path(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """Verify exists() and ensure_dir() delegate to the underlying Path methods.

    Purpose:
        Cover the disk-backed adapter's simple existence and directory-creation
        helpers so future refactors do not bypass the expected ``Path`` calls.

    Args:
        monkeypatch: Pytest fixture used to replace ``Path.exists`` and
            ``Path.mkdir`` with deterministic observers.

    Returns:
        None: Assertions validate both delegation paths.

    Raises:
        AssertionError: Raised when either adapter method stops delegating to the
            expected ``Path`` implementation.

    Side Effects:
        Monkeypatches ``Path.exists`` and ``Path.mkdir`` for the duration of the
        test.
    """
    target_dir = Path("/workspace/out")
    observed_calls: list[str] = []

    def fake_exists(self: Path) -> bool:
        assert self == target_dir
        observed_calls.append("exists")
        return True

    def fake_mkdir(self: Path, parents: bool, exist_ok: bool) -> None:
        assert self == target_dir
        assert parents is True
        assert exist_ok is True
        observed_calls.append("mkdir")

    monkeypatch.setattr(Path, "exists", fake_exists, raising=True)
    monkeypatch.setattr(Path, "mkdir", fake_mkdir, raising=True)

    filesystem = mod.RealFileSystem()

    assert filesystem.exists(target_dir) is True
    filesystem.ensure_dir(target_dir)
    assert observed_calls == ["exists", "mkdir"]


def test_real_filesystem_copy_file_and_text_io_delegate_to_path(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """Verify copy_file(), read_text(), and write_text() delegate correctly.

    Purpose:
        Cover the remaining disk-backed file I/O adapter helpers with deterministic
        observers instead of touching the real filesystem.

    Args:
        monkeypatch: Pytest fixture used to replace ``Path`` and ``shutil`` I/O
            methods with deterministic observers.

    Returns:
        None: Assertions validate the delegated I/O contract.

    Raises:
        AssertionError: Raised when any helper stops calling the expected lower-
            level path or shutil operation.

    Side Effects:
        Monkeypatches ``Path.mkdir``, ``Path.read_text``, ``Path.write_text``,
        and ``shutil.copyfile`` for the duration of the test.
    """
    source_path = Path("/workspace/in/template.md")
    destination_path = Path("/workspace/out/copied.md")
    observed_calls: list[str] = []

    def fake_mkdir(self: Path, parents: bool, exist_ok: bool) -> None:
        assert self == destination_path.parent
        assert parents is True
        assert exist_ok is True
        observed_calls.append("mkdir")

    def fake_copyfile(src: Path, dest: Path) -> None:
        assert src == source_path
        assert dest == destination_path
        observed_calls.append("copyfile")

    def fake_read_text(self: Path, encoding: str) -> str:
        assert self == destination_path
        assert encoding == "utf-8"
        observed_calls.append("read_text")
        return "copied-content"

    def fake_write_text(self: Path, content: str, encoding: str) -> None:
        assert self == destination_path
        assert content == "updated-content"
        assert encoding == "utf-8"
        observed_calls.append("write_text")

    monkeypatch.setattr(Path, "mkdir", fake_mkdir, raising=True)
    monkeypatch.setattr(mod.shutil, "copyfile", fake_copyfile)
    monkeypatch.setattr(Path, "read_text", fake_read_text, raising=True)
    monkeypatch.setattr(Path, "write_text", fake_write_text, raising=True)

    filesystem = mod.RealFileSystem()

    filesystem.copy_file(source_path, destination_path)
    assert filesystem.read_text(destination_path) == "copied-content"
    filesystem.write_text(destination_path, "updated-content")
    assert observed_calls == ["mkdir", "copyfile", "read_text", "mkdir", "write_text"]


def test_resolve_workspace_returns_repo_root_from_source_layout(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """Verify resolve_workspace walks two parents up from the source module path.

    Purpose:
        Lock in the repo-root discovery rule used by active-folder tooling when no
        explicit workspace override is supplied.

    Args:
        monkeypatch: Pytest fixture used to replace the module ``__file__`` value
            with a deterministic source-layout path.

    Returns:
        None: Assertions validate the computed repository root.

    Raises:
        AssertionError: Raised when the resolved workspace does not match the
            expected repo-root path.

    Side Effects:
        Temporarily replaces the module's ``__file__`` global.
    """
    monkeypatch.setattr(
        mod,
        "__file__",
        str(Path("/repo/scripts/dev_tools/new_active_feature_folder_models.py")),
        raising=False,
    )

    expected_workspace = (
        Path("/repo/scripts/dev_tools/new_active_feature_folder_models.py")
        .resolve()
        .parents[2]
    )

    assert mod.resolve_workspace() == expected_workspace


def test_get_est_timestamp_formats_timezone_aware_datetime() -> None:
    """Verify get_est_timestamp renders timezone-aware datetimes in EST-safe format.

    Purpose:
        Preserve the Windows-safe timestamp format used by generated feature-plan
        filenames and document metadata.

    Args:
        None.

    Returns:
        None: Assertions validate the formatted timestamp string.

    Raises:
        AssertionError: Raised when the formatted timestamp does not match the
            expected ``YYYY-MM-DDTHH-mm`` contract.

    Side Effects:
        None.
    """
    aware_now = datetime(2024, 2, 3, 4, 5, tzinfo=ZoneInfo("America/New_York"))

    assert mod.get_est_timestamp(lambda: aware_now) == "2024-02-03T04-05"


def test_get_est_timestamp_rejects_naive_datetime() -> None:
    """Verify get_est_timestamp rejects naive datetimes from custom now providers.

    Purpose:
        Ensure callers cannot silently bypass timezone normalization by supplying
        naive datetimes that would produce ambiguous plan timestamps.

    Args:
        None.

    Returns:
        None: The assertion validates the expected ``ValueError`` branch.

    Raises:
        AssertionError: Raised when the helper fails to reject a naive datetime.

    Side Effects:
        None.
    """
    naive_now = datetime(2024, 2, 3, 4, 5)

    with pytest.raises(ValueError, match="timezone-aware"):
        mod.get_est_timestamp(lambda: naive_now)


def test_extract_date_from_timestamp_returns_prefix_before_T() -> None:
    """Verify extract_date_from_timestamp returns the prefix before the first `T`.

    Purpose:
        Lock in the date-extraction contract used when deriving folder prefixes
        from timestamped plan names.

    Args:
        None.

    Returns:
        None: Assertions validate the extracted date component.

    Raises:
        AssertionError: Raised when the extracted date does not match the input
            prefix before the first ``T``.

    Side Effects:
        None.
    """
    assert mod.extract_date_from_timestamp("2026-03-14T15-48") == "2026-03-14"


def test_validate_feature_name_accepts_kebab_and_underscore_case() -> None:
    """Verify validate_feature_name accepts supported kebab and underscore slugs.

    Purpose:
        Preserve the positive-path slug contract alongside the existing invalid-name
        coverage already present in the broader active-folder test suite.

    Args:
        None.

    Returns:
        None: The helper succeeds without returning a value.

    Raises:
        AssertionError: Raised when a supported slug unexpectedly triggers an error.

    Side Effects:
        None.
    """
    mod.validate_feature_name("notes-feature")
    mod.validate_feature_name("notes_feature")
