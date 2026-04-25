from __future__ import annotations

import sys
from pathlib import Path
from typing import TYPE_CHECKING, Any

if TYPE_CHECKING:
    from _pytest.monkeypatch import MonkeyPatch

import pytest  # noqa: TCH002  # Needed at runtime for pytest decorators

import scripts.dev_tools.format_json as fmt


def _patch_io(monkeypatch: MonkeyPatch, store: dict[Path, str]) -> None:
    """Patch Path.read_text, Path.write_text, and Path.is_file to use an in-memory
    store.

    Purpose:
        Isolate format_file and format_files from the real filesystem in unit tests.
        All reads return from ``store``; all writes update ``store`` in place.

    Args:
        monkeypatch (MonkeyPatch): Pytest monkeypatch fixture.
        store (dict[Path, str]): In-memory store keyed by Path.
    """

    def read_text(self: Path, *args: Any, **kwargs: Any) -> str:
        return store[self]

    def write_text(self: Path, data: str, *args: Any, **kwargs: Any) -> int:
        store[self] = data
        return len(data)

    def _is_file(self: Path) -> bool:
        return True

    monkeypatch.setattr(Path, "read_text", read_text, raising=False)
    monkeypatch.setattr(Path, "write_text", write_text, raising=False)
    monkeypatch.setattr(Path, "is_file", _is_file, raising=False)


def test_format_no_change(monkeypatch: MonkeyPatch) -> None:
    """format_files should report 'already formatted' for already-formatted content."""
    # "{}\n" is the exact output Python json.dumps produces for an empty object.
    store: dict[Path, str] = {Path("/f.json"): "{}\n"}
    _patch_io(monkeypatch, store)

    result = fmt.format_files([Path("/f.json")], check=False, verbose=True)

    assert result.changed is False
    assert result.failed is False
    assert "already formatted" in result.messages[0]


def test_format_rewrites(monkeypatch: MonkeyPatch) -> None:
    """format_files should rewrite a file whose content differs from the canonical
    form."""
    store: dict[Path, str] = {Path("/f.json"): '{"b":1}\n'}
    _patch_io(monkeypatch, store)

    result = fmt.format_files([Path("/f.json")], check=False, verbose=True)

    assert result.changed is True
    assert result.failed is False
    assert store[Path("/f.json")] == '{\n  "b": 1\n}\n'


def test_format_check_mode(monkeypatch: MonkeyPatch) -> None:
    """format_files in check mode should report a change without writing the file."""
    store: dict[Path, str] = {Path("/f.json"): '{"b":1}\n'}
    _patch_io(monkeypatch, store)

    result = fmt.format_files([Path("/f.json")], check=True, verbose=True)

    assert result.changed is True
    assert result.failed is False
    assert store[Path("/f.json")] == '{"b":1}\n'  # unchanged in check mode


def test_format_parse_error(monkeypatch: MonkeyPatch) -> None:
    """format_files should report failure for content that is not valid JSON."""
    store: dict[Path, str] = {Path("/f.json"): "not valid json"}
    _patch_io(monkeypatch, store)

    result = fmt.format_files([Path("/f.json")], check=False, verbose=True)

    assert result.failed is True
    assert result.changed is False
    assert any("Failed to parse" in m for m in result.messages)


def test_format_result_init() -> None:
    """FormatResult should initialize with provided values."""
    result = fmt.FormatResult(True, False, ["message1", "message2"])
    assert result.changed is True
    assert result.failed is False
    assert result.messages == ["message1", "message2"]


def test_format_files_skips_non_files(monkeypatch: MonkeyPatch) -> None:
    """format_files should skip paths that are not files."""

    def _is_file(self: Path) -> bool:
        return False

    monkeypatch.setattr(Path, "is_file", _is_file)

    result = fmt.format_files([Path("/dir")], check=False, verbose=True)

    assert result.changed is False
    assert result.failed is False
    assert result.messages == []


def test_format_files_non_verbose_hides_unchanged(monkeypatch: MonkeyPatch) -> None:
    """format_files should not emit a message for unchanged files when not verbose."""
    store: dict[Path, str] = {Path("/f.json"): "{}\n"}
    _patch_io(monkeypatch, store)

    result = fmt.format_files([Path("/f.json")], check=False, verbose=False)

    assert result.changed is False
    assert result.failed is False
    assert result.messages == []


def test_format_file_parse_error(monkeypatch: MonkeyPatch) -> None:
    """format_file should set failed=True with a descriptive message for invalid
    JSON."""
    store: dict[Path, str] = {Path("/f.json"): "invalid"}
    _patch_io(monkeypatch, store)

    changed, failed, msg = fmt.format_file(Path("/f.json"), False)

    assert changed is False
    assert failed is True
    assert "Failed to parse" in msg


def test_parse_args_defaults() -> None:
    """parse_args with no arguments should use defaults."""
    args = fmt.parse_args([])
    assert args.paths == []
    assert args.check is False
    assert args.verbose is False


def test_parse_args_with_paths() -> None:
    """parse_args should accept path arguments."""
    args = fmt.parse_args(["file1.json", "file2.json"])
    assert args.paths == ["file1.json", "file2.json"]


def test_parse_args_check_flag() -> None:
    """parse_args should accept --check flag."""
    args = fmt.parse_args(["--check"])
    assert args.check is True


def test_parse_args_verbose_flag() -> None:
    """parse_args should accept --verbose flag."""
    args = fmt.parse_args(["--verbose"])
    assert args.verbose is True


def test_parse_args_combined() -> None:
    """parse_args should handle multiple flags and paths."""
    args = fmt.parse_args(["--check", "--verbose", "test.json"])
    assert args.check is True
    assert args.verbose is True
    assert args.paths == ["test.json"]


def test_main_no_paths_uses_governed(
    mem_fs_path: Path, monkeypatch: MonkeyPatch
) -> None:
    """main with no paths should delegate file discovery to iter_governed_files."""
    json_file = mem_fs_path / "test.json"
    json_file.write_text("{}")

    def mock_iter(_: Path) -> list[Path]:
        return [json_file]

    monkeypatch.setattr(fmt, "iter_governed_files", mock_iter)
    monkeypatch.setattr(sys, "argv", ["format_json.py"])

    original_resolve = Path.resolve

    def mock_resolve(self: Path, *args: Any, **kwargs: Any) -> Path:
        if "format_json.py" in str(self):
            return mem_fs_path / "scripts" / "dev_tools" / "format_json.py"
        return original_resolve(self, *args, **kwargs)

    monkeypatch.setattr(Path, "resolve", mock_resolve)

    exit_code = fmt.main([])
    assert exit_code == 0


def test_main_with_file_path(mem_fs_path: Path, monkeypatch: MonkeyPatch) -> None:
    """main should format a specific file when its path is supplied."""
    json_file = mem_fs_path / "test.json"
    json_file.write_text('{"b":1}')

    monkeypatch.setattr(sys, "argv", ["format_json.py"])

    original_resolve = Path.resolve

    def mock_resolve(self: Path, *args: Any, **kwargs: Any) -> Path:
        if "format_json.py" in str(self):
            return mem_fs_path / "scripts" / "dev_tools" / "format_json.py"
        return original_resolve(self, *args, **kwargs)

    monkeypatch.setattr(Path, "resolve", mock_resolve)

    exit_code = fmt.main([str(json_file)])
    assert exit_code == 0


def test_main_with_directory_path(mem_fs_path: Path, monkeypatch: MonkeyPatch) -> None:
    """main should recursively find and format JSON files when given a directory."""
    subdir = mem_fs_path / "subdir"
    subdir.mkdir()
    json_file = subdir / "test.json"
    json_file.write_text("{}\n")

    monkeypatch.setattr(sys, "argv", ["format_json.py"])

    original_resolve = Path.resolve

    def mock_resolve(self: Path, *args: Any, **kwargs: Any) -> Path:
        if "format_json.py" in str(self):
            return mem_fs_path / "scripts" / "dev_tools" / "format_json.py"
        return original_resolve(self, *args, **kwargs)

    monkeypatch.setattr(Path, "resolve", mock_resolve)

    exit_code = fmt.main([str(mem_fs_path)])
    assert exit_code == 0


def test_main_check_mode_exits_1_on_changes(
    mem_fs_path: Path, monkeypatch: MonkeyPatch
) -> None:
    """main in check mode should return 1 when the file needs reformatting."""
    json_file = mem_fs_path / "test.json"
    json_file.write_text('{"b":1}')

    monkeypatch.setattr(sys, "argv", ["format_json.py"])

    original_resolve = Path.resolve

    def mock_resolve(self: Path, *args: Any, **kwargs: Any) -> Path:
        if "format_json.py" in str(self):
            return mem_fs_path / "scripts" / "dev_tools" / "format_json.py"
        return original_resolve(self, *args, **kwargs)

    monkeypatch.setattr(Path, "resolve", mock_resolve)

    exit_code = fmt.main(["--check", str(json_file)])
    assert exit_code == 1


def test_main_failure_exits_1(mem_fs_path: Path, monkeypatch: MonkeyPatch) -> None:
    """main should return 1 when a file cannot be parsed as JSON."""
    json_file = mem_fs_path / "test.json"
    json_file.write_text("invalid")

    monkeypatch.setattr(sys, "argv", ["format_json.py"])

    original_resolve = Path.resolve

    def mock_resolve(self: Path, *args: Any, **kwargs: Any) -> Path:
        if "format_json.py" in str(self):
            return mem_fs_path / "scripts" / "dev_tools" / "format_json.py"
        return original_resolve(self, *args, **kwargs)

    monkeypatch.setattr(Path, "resolve", mock_resolve)

    exit_code = fmt.main([str(json_file)])
    assert exit_code == 1


def test_main_verbose_mode_already_formatted(
    mem_fs_path: Path, monkeypatch: MonkeyPatch, capsys: pytest.CaptureFixture[str]
) -> None:
    """main with --verbose should print 'already formatted' when no changes needed."""
    json_file = mem_fs_path / "test.json"
    # Write content in canonical Python json form (sorted keys, 2-space indent,
    # trailing newline), so formatter reports it as already formatted.
    original = '{\n  "b": 1\n}\n'
    json_file.write_text(original)

    monkeypatch.setattr(sys, "argv", ["format_json.py"])

    original_resolve = Path.resolve

    def mock_resolve(self: Path, *args: Any, **kwargs: Any) -> Path:
        if "format_json.py" in str(self):
            return mem_fs_path / "scripts" / "dev_tools" / "format_json.py"
        return original_resolve(self, *args, **kwargs)

    monkeypatch.setattr(Path, "resolve", mock_resolve)

    exit_code = fmt.main(["--verbose", str(json_file)])
    assert exit_code == 0

    captured = capsys.readouterr()
    assert "already formatted" in captured.out


def test_main_verbose_mode_reformatted(
    mem_fs_path: Path, monkeypatch: MonkeyPatch, capsys: pytest.CaptureFixture[str]
) -> None:
    """main with --verbose should print 'reformatted' after rewriting a file."""
    json_file = mem_fs_path / "test.json"
    json_file.write_text('{"b":1}')

    monkeypatch.setattr(sys, "argv", ["format_json.py"])

    original_resolve = Path.resolve

    def mock_resolve(self: Path, *args: Any, **kwargs: Any) -> Path:
        if "format_json.py" in str(self):
            return mem_fs_path / "scripts" / "dev_tools" / "format_json.py"
        return original_resolve(self, *args, **kwargs)

    monkeypatch.setattr(Path, "resolve", mock_resolve)

    exit_code = fmt.main(["--verbose", str(json_file)])
    assert exit_code == 0

    captured = capsys.readouterr()
    assert "reformatted" in captured.out
