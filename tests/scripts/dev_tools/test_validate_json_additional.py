"""Additional unit tests for scripts/dev_tools/validate_json.py.

Purpose:
    Raise coverage for validate_json without relying on network access or runtime
    filesystem writes.

Notes:
    The repository policy prohibits temp files and external dependencies in unit
    tests. These tests patch Path I/O to an in-memory store.
"""

from __future__ import annotations

import json
from dataclasses import dataclass
from types import MappingProxyType
from typing import TYPE_CHECKING, Any

import pytest

import scripts.dev_tools.validate_json as val

if TYPE_CHECKING:
    from collections.abc import Iterator


@dataclass
class _FakeJsonSchemaError:
    """Minimal jsonschema-like error object used by the validate_json tests."""

    path: tuple[str, ...]
    message: str


class _FakeDraft202012Validator:
    """Minimal jsonschema-like validator that yields preconfigured errors."""

    def __init__(self, schema: dict[str, Any], *, errors: list[_FakeJsonSchemaError]):
        self._schema = schema
        self._errors = errors

    def iter_errors(self, data: dict[str, Any]) -> Iterator[_FakeJsonSchemaError]:
        _ = data
        # Yield errors in the order provided so validate_json's sorting is exercised.
        yield from self._errors


class _FakeJsonSchemaModule:
    """Fake jsonschema module shim with the attribute validate_json uses."""

    def __init__(self, *, errors: list[_FakeJsonSchemaError]):
        self._errors = errors

    def Draft202012Validator(self, schema: dict[str, Any]) -> _FakeDraft202012Validator:
        return _FakeDraft202012Validator(schema, errors=self._errors)


class _InMemoryPathIo:
    """In-memory Path I/O patch target.

    Purpose:
        Provide a deterministic, filesystem-free replacement for Path read/write
        operations used by validate_json.

    Invariants / Constraints:
        Keys are normalized by string form of Path.
    """

    def __init__(self) -> None:
        """
        Initialize the in-memory store.

        Purpose:
            Provide empty storage for file contents and created directories.

        Args:
            None.

        Returns:
            None: The instance is initialized in-place.

        Raises:
            None.
        """
        self._files: dict[str, str] = {}
        self._dirs_created: set[str] = set()

    def _normalize_path(self, path: str) -> str:
        """
        Normalize path strings for cross-platform comparisons.

        Purpose:
            Treat Windows and POSIX path separators as equivalent so tests are
            deterministic across OSes.

        Args:
            path (str): Path string to normalize.

        Returns:
            str: Normalized path string using POSIX-style separators.

        Raises:
            None.
        """

        # Normalize separators so Windows-style paths map to the POSIX keys
        # used in test fixtures.
        return path.replace("\\", "/")

    def add_file(self, path: str, content: str) -> None:
        """
        Add or replace a file in the in-memory store.

        Purpose:
            Seed the store with deterministic file contents for tests.

        Args:
            path (str): File path key.
            content (str): File contents.

        Returns:
            None.

        Raises:
            None.
        """

        self._files[self._normalize_path(path)] = content

    def exists(self, path: str) -> bool:
        """
        Determine whether a file path exists in the store.

        Purpose:
            Mirror Path.exists() using the normalized in-memory mapping.

        Args:
            path (str): File path key.

        Returns:
            bool: True if the file exists in the store.

        Raises:
            None.
        """

        return self._normalize_path(path) in self._files

    def is_file(self, path: str) -> bool:
        """
        Determine whether the path is a file in the store.

        Purpose:
            Match Path.is_file() for the in-memory mapping.

        Args:
            path (str): File path key.

        Returns:
            bool: True if the file exists in the store.

        Raises:
            None.
        """

        return self._normalize_path(path) in self._files

    def read_text(self, path: str) -> str:
        """
        Read file contents from the in-memory store.

        Purpose:
            Provide deterministic file contents for patched Path.read_text().

        Args:
            path (str): File path key.

        Returns:
            str: Stored file contents.

        Raises:
            KeyError: When the file does not exist in the store.
        """

        return self._files[self._normalize_path(path)]

    def write_text(self, path: str, content: str) -> None:
        """
        Write file contents to the in-memory store.

        Purpose:
            Capture writes made by validate_json without touching disk.

        Args:
            path (str): File path key.
            content (str): File contents.

        Returns:
            None.

        Raises:
            None.
        """

        self._files[self._normalize_path(path)] = content

    def mkdir(self, path: str) -> None:
        """
        Record a directory creation request.

        Purpose:
            Track directory creation in tests without touching the filesystem.

        Args:
            path (str): Directory path key.

        Returns:
            None.

        Raises:
            None.
        """

        self._dirs_created.add(self._normalize_path(path))


def _patch_path_io(monkeypatch: pytest.MonkeyPatch, store: _InMemoryPathIo) -> None:
    """Patch Path methods used by validate_json to use an in-memory store."""

    from pathlib import Path

    def exists(self: Path) -> bool:
        return store.exists(str(self))

    def is_file(self: Path) -> bool:
        return store.is_file(str(self))

    def read_text(self: Path, *args: Any, **kwargs: Any) -> str:
        _ = args
        _ = kwargs
        return store.read_text(str(self))

    def write_text(self: Path, content: str, *args: Any, **kwargs: Any) -> int:
        _ = args
        _ = kwargs
        store.write_text(str(self), content)
        return len(content)

    def mkdir(self: Path, *args: Any, **kwargs: Any) -> None:
        _ = args
        _ = kwargs
        store.mkdir(str(self))

    def resolve(self: Path, *args: Any, **kwargs: Any) -> Path:
        _ = args
        _ = kwargs
        # Avoid touching the real filesystem; Path computations are sufficient.
        return self

    monkeypatch.setattr(Path, "exists", exists, raising=False)
    monkeypatch.setattr(Path, "is_file", is_file, raising=False)
    monkeypatch.setattr(Path, "read_text", read_text, raising=False)
    monkeypatch.setattr(Path, "write_text", write_text, raising=False)
    monkeypatch.setattr(Path, "mkdir", mkdir, raising=False)
    monkeypatch.setattr(Path, "resolve", resolve, raising=False)


def test_collect_schema_errors_raises_when_schema_expects_object() -> None:
    """_collect_schema_errors should reject non-dict roots for object schemas."""

    schema: dict[str, Any] = {"type": "object"}
    data = MappingProxyType({"key": 1})

    helper_name = "_collect_schema_errors"
    collect_schema_errors = getattr(val, helper_name)
    with pytest.raises(ValueError, match="expects an object"):
        collect_schema_errors(schema, data)


def test_collect_schema_errors_reports_required_property() -> None:
    """_collect_schema_errors should report missing required properties."""

    schema: dict[str, Any] = {"type": "object", "properties": {}, "required": ["key"]}
    data: dict[str, Any] = {}

    helper_name = "_collect_schema_errors"
    collect_schema_errors = getattr(val, helper_name)
    errors = collect_schema_errors(schema, data)

    assert errors == ["['key']: is a required property"]


def test_collect_schema_errors_reports_number_type_mismatch() -> None:
    """_collect_schema_errors should report type mismatches for number fields."""

    schema: dict[str, Any] = {
        "type": "object",
        "properties": {"key": {"type": "number"}},
        "required": [],
    }
    data: dict[str, Any] = {"key": "bad"}

    helper_name = "_collect_schema_errors"
    collect_schema_errors = getattr(val, helper_name)
    errors = collect_schema_errors(schema, data)

    assert errors == ["['key']: expected number"]


def test_load_schema_file_scheme_reads_schema(monkeypatch: pytest.MonkeyPatch) -> None:
    """_load_schema should load file:// schemas via Path read_text."""

    store = _InMemoryPathIo()
    store.add_file("/schema.json", '{"type": "object"}')
    _patch_path_io(monkeypatch, store)

    helper_name = "_load_schema"
    load_schema = getattr(val, helper_name)
    schema = load_schema("file:///schema.json", cache_dir=val.Path("/cache"))
    assert schema == {"type": "object"}


def test_load_schema_relative_path_uses_base_file_parent(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """_load_schema should resolve relative schemas against the source file path."""

    store = _InMemoryPathIo()
    store.add_file(
        "/data/schema.json",
        json.dumps({"type": "object", "properties": {"key": {"type": "number"}}}),
    )
    _patch_path_io(monkeypatch, store)

    helper_name = "_load_schema"
    load_schema = getattr(val, helper_name)
    schema = load_schema(
        "./schema.json",
        cache_dir=val.Path("/cache"),
        base_path=val.Path("/data/data.json"),
    )

    assert schema["type"] == "object"


def test_load_schema_http_cache_hit(monkeypatch: pytest.MonkeyPatch) -> None:
    """_load_schema should return cached content when present."""

    store = _InMemoryPathIo()
    store.add_file("/cache/hit.json", '{"type": "object"}')
    _patch_path_io(monkeypatch, store)

    def fake_cache_path(cache_dir: val.Path, uri: str) -> val.Path:
        _ = cache_dir
        _ = uri
        return val.Path("/cache/hit.json")

    monkeypatch.setattr(val, "_cache_path", fake_cache_path)

    helper_name = "_load_schema"
    load_schema = getattr(val, helper_name)
    schema = load_schema("https://example.com/schema.json", val.Path("/cache"))
    assert schema == {"type": "object"}


def test_load_schema_http_fetch_writes_cache(monkeypatch: pytest.MonkeyPatch) -> None:
    """_load_schema should fetch remote schema and write it to the cache."""

    store = _InMemoryPathIo()
    _patch_path_io(monkeypatch, store)

    def fake_cache_path(cache_dir: val.Path, uri: str) -> val.Path:
        _ = cache_dir
        _ = uri
        return val.Path("/cache/miss.json")

    monkeypatch.setattr(val, "_cache_path", fake_cache_path)

    class FakeResponse:
        def __init__(self, content: str):
            self._content = content

        def __enter__(self) -> FakeResponse:
            return self

        def __exit__(self, exc_type: object, exc: object, tb: object) -> None:
            _ = exc_type
            _ = exc
            _ = tb

        def read(self) -> bytes:
            return self._content.encode("utf-8")

    def fake_urlopen(url: str) -> FakeResponse:
        assert url == "https://example.com/schema.json"
        return FakeResponse('{"type": "object"}')

    monkeypatch.setattr(val.urllib.request, "urlopen", fake_urlopen)

    helper_name = "_load_schema"
    load_schema = getattr(val, helper_name)
    schema = load_schema("https://example.com/schema.json", val.Path("/cache"))
    assert schema == {"type": "object"}
    assert store.read_text("/cache/miss.json") == '{"type": "object"}'


def test_validate_file_uses_jsonschema_when_available(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """validate_file should use jsonschema branch when the dependency is present."""

    store = _InMemoryPathIo()
    store.add_file(
        "/f.json",
        '{"$schema": "https://example.com/schema.json", "key": "bad"}',
    )
    _patch_path_io(monkeypatch, store)

    def fake_load_schema(
        uri: str, cache_dir: val.Path, base_path: val.Path | None = None
    ) -> dict[str, Any]:
        _ = uri
        _ = cache_dir
        _ = base_path
        return {"type": "object"}

    monkeypatch.setattr(val, "_load_schema", fake_load_schema)

    errors = [_FakeJsonSchemaError(path=("key",), message="is not of type 'number'")]
    monkeypatch.setattr(val, "_jsonschema_module", _FakeJsonSchemaModule(errors=errors))

    ok, msg = val.validate_file(val.Path("/f.json"), val.Path("/cache"))

    assert ok is False
    assert "schema validation failed" in msg
    assert "['key']" in msg


def test_validate_file_jsonschema_branch_ok_when_no_errors(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """validate_file should report ok when jsonschema yields no errors."""

    store = _InMemoryPathIo()
    store.add_file(
        "/f.json",
        '{"$schema": "https://example.com/schema.json", "key": 1}',
    )
    _patch_path_io(monkeypatch, store)

    def fake_load_schema(
        uri: str, cache_dir: val.Path, base_path: val.Path | None = None
    ) -> dict[str, Any]:
        _ = uri
        _ = cache_dir
        _ = base_path
        return {"type": "object"}

    monkeypatch.setattr(val, "_load_schema", fake_load_schema)
    monkeypatch.setattr(val, "_jsonschema_module", _FakeJsonSchemaModule(errors=[]))

    ok, msg = val.validate_file(val.Path("/f.json"), val.Path("/cache"))

    assert ok is True
    assert msg.endswith(": ok")
