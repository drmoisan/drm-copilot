"""Schema-document conformance and versioning-convention tests for discovery v1.

Purpose:
    Assert that the seven ``schemas/discovery/v1`` JSON Schema documents are valid
    Draft 2020-12 schemas and that they embody the repository schema-versioning
    convention. All checks are offline: ``check_schema`` uses the bundled Draft
    2020-12 meta-schemas, and no network or schema-cache access occurs.

Scenario coverage:
    - Positive: every schema document passes offline meta-validation.
    - Convention: ``$schema``/``$id``/``version``/``title``/``description``,
      top-level ``additionalProperties: false``, the required and pattern-pinned
      ``schema_version`` field, and the shared identifier pattern on every
      reference field.
"""

from __future__ import annotations

import json
from pathlib import Path
from typing import Any, cast

import pytest

try:
    # jsonschema is a dev-group dependency that lacks a py.typed marker; the
    # import-untyped suppression is the pre-authorized pattern for such imports.
    import jsonschema as _jsonschema_import  # type: ignore[import-untyped]
except ImportError:  # pragma: no cover - jsonschema is present under pytest
    _jsonschema_import = None

# Access the untyped module through an Any-typed handle so attribute access is
# wrapped in the typed adapter below rather than leaking Unknown types.
_jsonschema: Any = _jsonschema_import
_jsonschema_available = _jsonschema_import is not None

# Repo root resolved from this file location, never from the current working
# directory (existing precedent across tests/scripts/dev_tools/).
REPO_ROOT = Path(__file__).resolve().parents[3]
SCHEMA_DIR = REPO_ROOT / "schemas" / "discovery" / "v1"

SCHEMA_FILENAMES = (
    "evidence-reference.schema.json",
    "feature-contract.schema.json",
    "coverage-ledger.schema.json",
    "runtime-characterization-scenario.schema.json",
    "parity-matrix.schema.json",
    "unspecified-behavior-record.schema.json",
    "product-decision-record.schema.json",
)

DRAFT_2020_12_URI = "https://json-schema.org/draft/2020-12/schema"
IDENTIFIER_PATTERN = "^[a-z0-9][a-z0-9._-]*$"
SCHEMA_VERSION_PATTERN = r"^1\.\d+\.\d+$"

# source_refs holds generic source locators, not cross-reference identifiers; it is
# the single documented exception to the reference-field identifier rule (spec.md).
_LOCATOR_EXCEPTIONS = frozenset({"source_refs"})
_REFERENCE_SUFFIXES = ("_ids", "_refs", "_id", "_ref")


def _load_schema(filename: str) -> dict[str, Any]:
    """Load and parse a schema document by filename.

    Args:
        filename: The schema file name under ``schemas/discovery/v1``.

    Returns:
        The parsed schema document as a dict.
    """
    text = (SCHEMA_DIR / filename).read_text(encoding="utf-8")
    parsed = json.loads(text)
    assert isinstance(parsed, dict), f"{filename}: root must be a JSON object"
    return cast("dict[str, Any]", parsed)


def _collect_reference_fields(node: Any) -> list[tuple[str, dict[str, Any]]]:
    """Recursively collect properties whose names denote cross-reference fields.

    A reference field is any property whose name ends in ``_id``, ``_ids``,
    ``_ref``, or ``_refs``. Traversal descends into nested ``properties`` and
    array ``items`` so nested reference fields are also collected.

    Args:
        node: A schema fragment (dict, list, or scalar).

    Returns:
        A list of (field_name, field_schema) tuples.
    """
    found: list[tuple[str, dict[str, Any]]] = []
    if isinstance(node, dict):
        node_dict = cast("dict[str, Any]", node)
        props = node_dict.get("properties")
        if isinstance(props, dict):
            props_dict = cast("dict[str, Any]", props)
            for name, subschema in props_dict.items():
                if name.endswith(_REFERENCE_SUFFIXES) and isinstance(subschema, dict):
                    found.append((name, cast("dict[str, Any]", subschema)))
        for value in node_dict.values():
            found.extend(_collect_reference_fields(value))
    elif isinstance(node, list):
        for item in cast("list[Any]", node):
            found.extend(_collect_reference_fields(item))
    return found


def _collect_all_refs(node: Any) -> list[str]:
    """Recursively collect every ``$ref`` string value in a schema fragment."""
    found: list[str] = []
    if isinstance(node, dict):
        node_dict = cast("dict[str, Any]", node)
        for key, value in node_dict.items():
            if key == "$ref" and isinstance(value, str):
                found.append(value)
            else:
                found.extend(_collect_all_refs(value))
    elif isinstance(node, list):
        for item in cast("list[Any]", node):
            found.extend(_collect_all_refs(item))
    return found


def _check_schema(schema: dict[str, Any]) -> None:
    """Typed adapter running offline Draft 2020-12 meta-validation.

    Raises:
        jsonschema.exceptions.SchemaError: When the schema is not valid Draft
            2020-12.
    """
    _jsonschema.Draft202012Validator.check_schema(schema)


@pytest.mark.skipif(
    not _jsonschema_available, reason="jsonschema is required for meta-validation"
)
@pytest.mark.parametrize("filename", SCHEMA_FILENAMES)
def test_schema_document_is_valid_draft_2020_12(filename: str) -> None:
    """Each schema document passes offline Draft 2020-12 meta-validation."""
    # Arrange / Act / Assert: check_schema raises on an invalid schema.
    schema = _load_schema(filename)
    _check_schema(schema)


@pytest.mark.parametrize("filename", SCHEMA_FILENAMES)
def test_schema_declares_draft_2020_12_meta_schema(filename: str) -> None:
    """Each schema document's ``$schema`` equals the Draft 2020-12 URI."""
    schema = _load_schema(filename)
    assert schema.get("$schema") == DRAFT_2020_12_URI


@pytest.mark.parametrize("filename", SCHEMA_FILENAMES)
def test_schema_id_equals_repo_relative_path(filename: str) -> None:
    """Each schema document's ``$id`` equals its repo-relative path string."""
    schema = _load_schema(filename)
    assert schema.get("$id") == f"schemas/discovery/v1/{filename}"


@pytest.mark.parametrize("filename", SCHEMA_FILENAMES)
def test_schema_version_major_equals_one(filename: str) -> None:
    """Each schema's in-schema ``version`` has a major component equal to 1."""
    schema = _load_schema(filename)
    version = schema.get("version")
    assert isinstance(version, str), f"{filename}: version must be a string"
    assert version.split(".")[0] == "1", f"{filename}: version major must be 1"


@pytest.mark.parametrize("filename", SCHEMA_FILENAMES)
def test_schema_has_title_and_description(filename: str) -> None:
    """Each schema document declares non-empty ``title`` and ``description``."""
    schema = _load_schema(filename)
    title = schema.get("title")
    description = schema.get("description")
    assert isinstance(title, str) and title.strip()
    assert isinstance(description, str) and description.strip()


@pytest.mark.parametrize("filename", SCHEMA_FILENAMES)
def test_top_level_additional_properties_is_false(filename: str) -> None:
    """Each schema fixes a deterministic shape via top-level additionalProperties."""
    schema = _load_schema(filename)
    assert schema.get("type") == "object"
    assert schema.get("additionalProperties") is False


@pytest.mark.parametrize("filename", SCHEMA_FILENAMES)
def test_schema_requires_instance_schema_field(filename: str) -> None:
    """Each schema requires an instance ``$schema`` (the missing-$schema guard)."""
    schema = _load_schema(filename)
    required = schema.get("required")
    assert isinstance(required, list)
    required_list = cast("list[Any]", required)
    assert "$schema" in required_list
    properties = cast("dict[str, Any]", schema.get("properties", {}))
    assert "$schema" in properties


@pytest.mark.parametrize("filename", SCHEMA_FILENAMES)
def test_schema_version_required_and_major_pinned(filename: str) -> None:
    """Each schema requires ``schema_version`` pinned to the v1 major pattern."""
    schema = _load_schema(filename)
    required = schema.get("required")
    assert isinstance(required, list)
    required_list = cast("list[Any]", required)
    assert "schema_version" in required_list
    properties = cast("dict[str, Any]", schema.get("properties", {}))
    prop = properties.get("schema_version")
    assert isinstance(prop, dict)
    prop_dict = cast("dict[str, Any]", prop)
    assert prop_dict.get("type") == "string"
    assert prop_dict.get("pattern") == SCHEMA_VERSION_PATTERN


@pytest.mark.parametrize("filename", SCHEMA_FILENAMES)
def test_reference_fields_use_shared_identifier(filename: str) -> None:
    """Every reference field resolves to the shared ``$defs/identifier`` grammar."""
    schema = _load_schema(filename)
    defs = schema.get("$defs")
    assert isinstance(defs, dict)
    defs_dict = cast("dict[str, Any]", defs)
    identifier = defs_dict.get("identifier")
    assert isinstance(identifier, dict)
    identifier_dict = cast("dict[str, Any]", identifier)
    assert identifier_dict.get("pattern") == IDENTIFIER_PATTERN

    for name, subschema in _collect_reference_fields(schema):
        if name in _LOCATOR_EXCEPTIONS:
            continue
        if name.endswith(("_ids", "_refs")):
            assert subschema.get("type") == "array", f"{filename}: {name}"
            assert subschema.get("items") == {
                "$ref": "#/$defs/identifier"
            }, f"{filename}: {name}"
        else:
            assert subschema.get("$ref") == "#/$defs/identifier", f"{filename}: {name}"


@pytest.mark.parametrize("filename", SCHEMA_FILENAMES)
def test_no_cross_file_ref(filename: str) -> None:
    """Every ``$ref`` in each schema is internal (``#/``-rooted)."""
    schema = _load_schema(filename)
    refs = _collect_all_refs(schema)
    assert refs, f"{filename}: expected at least one internal $ref"
    for ref in refs:
        assert ref.startswith("#/"), f"{filename}: non-local $ref {ref!r}"
