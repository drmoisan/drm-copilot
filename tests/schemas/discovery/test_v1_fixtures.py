"""Fixture-conformance tests for discovery v1 schemas via validate_json machinery.

Purpose:
    Exercise the existing ``scripts/dev_tools/validate_json.py`` production paths
    (``validate_file`` and ``iter_governed_files``) against the committed discovery
    fixtures. Conforming fixtures under ``examples/discovery/v1`` must validate;
    non-conforming fixtures under ``tests/fixtures/discovery_schemas/v1`` must be
    rejected with a distinct violation class per fixture.

Determinism:
    All fixture references are scheme-less relative paths; the relative-``$schema``
    branch reads schema files directly and never touches the schema cache or the
    network. The in-memory ``mem_fs_path`` cache directory confirms no disk writes.
"""

from __future__ import annotations

import json
from pathlib import Path

import pytest

from scripts.dev_tools.json_config import iter_governed_files
from scripts.dev_tools.validate_json import validate_file

# Repo root resolved from this file location, never from the current working
# directory (existing precedent across tests/scripts/dev_tools/).
REPO_ROOT = Path(__file__).resolve().parents[3]
EXAMPLES_DIR = REPO_ROOT / "examples" / "discovery" / "v1"
INVALID_DIR = REPO_ROOT / "tests" / "fixtures" / "discovery_schemas" / "v1"

CONFORMING_FIXTURES = (
    "evidence-reference.example.json",
    "feature-contract.example.json",
    "coverage-ledger.example.json",
    "runtime-characterization-scenario.example.json",
    "parity-matrix.example.json",
    "unspecified-behavior-record.example.json",
    "product-decision-record.example.json",
)

# Each non-conforming fixture exercises a distinct violation class. The associated
# list holds substrings that must all appear in the validate_file message, chosen
# from the stable parts of the Draft202012Validator diagnostics.
NON_CONFORMING_CASES: dict[str, list[str]] = {
    "feature-contract.invalid.json": ["is a required property", "acceptance_criteria"],
    "coverage-ledger.invalid.json": ["is not of type", "summary", "total_units"],
    "runtime-characterization-scenario.invalid.json": ["is not one of"],
    "parity-matrix.invalid.json": ["is a required property", "rows", "parity_status"],
    "unspecified-behavior-record.invalid.json": ["does not match", "id"],
    "product-decision-record.invalid.json": ["Additional properties are not allowed"],
    "evidence-reference.invalid.json": ["does not match", "schema_version"],
}


@pytest.mark.parametrize("filename", CONFORMING_FIXTURES)
def test_conforming_fixture_validates(filename: str, mem_fs_path: Path) -> None:
    """Each conforming fixture validates cleanly through validate_file."""
    # Arrange: an in-memory cache dir the relative-$schema branch never touches.
    cache_dir = mem_fs_path / "cache"
    # Act
    ok, msg = validate_file(EXAMPLES_DIR / filename, cache_dir)
    # Assert
    assert ok is True, msg


@pytest.mark.parametrize("filename", sorted(NON_CONFORMING_CASES))
def test_non_conforming_fixture_is_rejected(filename: str, mem_fs_path: Path) -> None:
    """Each non-conforming fixture is rejected with its distinct violation class."""
    # Arrange
    cache_dir = mem_fs_path / "cache"
    expected_substrings = NON_CONFORMING_CASES[filename]
    # Act
    ok, msg = validate_file(INVALID_DIR / filename, cache_dir)
    # Assert
    assert ok is False, f"{filename} unexpectedly validated: {msg}"
    for expected in expected_substrings:
        assert expected in msg, f"{filename}: expected {expected!r} in {msg!r}"


def test_governed_discovery_includes_conforming_excludes_non_conforming() -> None:
    """iter_governed_files includes conforming fixtures and excludes invalid ones."""
    # Arrange / Act
    governed = set(iter_governed_files(REPO_ROOT))
    # Assert: conforming fixtures are governed (examples/**/*.json).
    for filename in CONFORMING_FIXTURES:
        assert EXAMPLES_DIR / filename in governed, filename
    # Assert: non-conforming fixtures under tests/** are intentionally ungoverned.
    for filename in NON_CONFORMING_CASES:
        assert INVALID_DIR / filename not in governed, filename


def test_missing_schema_returns_missing_message(mem_fs_path: Path) -> None:
    """A fixture without $schema returns the missing-$schema message."""
    # Arrange: an in-memory instance lacking a $schema key.
    data_path = mem_fs_path / "no_schema.json"
    data_path.write_text(json.dumps({"id": "record-alpha"}), encoding="utf-8")
    # Act
    ok, msg = validate_file(data_path, mem_fs_path / "cache")
    # Assert
    assert ok is False
    assert "missing $schema" in msg


def test_non_object_root_is_rejected(mem_fs_path: Path) -> None:
    """A fixture whose JSON root is not an object is rejected before schema load."""
    # Arrange: an in-memory instance with an array root.
    data_path = mem_fs_path / "array_root.json"
    data_path.write_text(json.dumps(["not", "an", "object"]), encoding="utf-8")
    # Act
    ok, msg = validate_file(data_path, mem_fs_path / "cache")
    # Assert
    assert ok is False
    assert "JSON root must be an object" in msg
