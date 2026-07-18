"""Unit tests for the shared schema-loading module.

Purpose:
    Cover `cache_path` and `load_schema` in isolation, independent of
    `validate_json.py`'s thin wrappers, per the shared-extraction requirement
    in Phase 1 of the legacy-discovery-validators plan.
"""

from __future__ import annotations

from pathlib import Path

import pytest

import scripts.dev_tools.schema_loading as schema_loading


def test_cache_path_generates_deterministic_hash() -> None:
    """cache_path should return the same deterministic Path for a given URI."""
    cache_dir = Path("/cache")
    uri = "https://example.com/schema.json"

    path1 = schema_loading.cache_path(cache_dir, uri)
    path2 = schema_loading.cache_path(cache_dir, uri)

    assert path1 == path2
    assert path1.parent == cache_dir
    assert path1.suffix == ".json"


def test_load_schema_from_cache(mem_fs_path: Path) -> None:
    """load_schema should return cached schema content without a network call."""
    cache_dir = mem_fs_path / "cache"
    cache_dir.mkdir()
    uri = "https://example.com/schema.json"
    cache_file = schema_loading.cache_path(cache_dir, uri)
    cache_file.write_text('{"type": "object"}')

    schema = schema_loading.load_schema(uri, cache_dir)

    assert schema == {"type": "object"}


def test_load_schema_unsupported_scheme(mem_fs_path: Path) -> None:
    """load_schema should reject unsupported URI schemes."""
    with pytest.raises(ValueError, match="Unsupported schema URI scheme"):
        schema_loading.load_schema("ftp://example.com/schema.json", mem_fs_path / "cache")


def test_load_schema_relative_path(mem_fs_path: Path) -> None:
    """load_schema should resolve a scheme-less URI relative to source_path.parent."""
    cache_dir = mem_fs_path / "cache"
    cache_dir.mkdir()
    schema_path = mem_fs_path / "schema.json"
    schema_path.write_text('{"type": "object", "properties": {}}')
    source_path = mem_fs_path / "data.json"

    schema = schema_loading.load_schema("./schema.json", cache_dir, source_path)

    assert schema == {"type": "object", "properties": {}}


def test_load_schema_missing_scheme(mem_fs_path: Path) -> None:
    """load_schema should reject a scheme-less URI when no base_path is given."""
    with pytest.raises(ValueError, match="Unsupported schema URI scheme"):
        schema_loading.load_schema("no-scheme-here", mem_fs_path / "cache")
