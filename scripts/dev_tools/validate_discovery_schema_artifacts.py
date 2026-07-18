"""Validate discovery schema-governed artifacts against their `$schema`.

Purpose:
    Provide the seven deterministic `validate_<schema>_text` entry points
    checking each discovery artifact type against the versioned JSON schemas
    defined by `legacy-discovery-schemas` (#9002).

Constraints:
    Per Design Decision 6, schema location is resolved solely via each
    artifact's own `$schema` field, through `_extract_schema_uri` and the
    shared `scripts.dev_tools.schema_loading.load_schema` function. No
    hardcoded `schemas/vN` layout or version string appears here. Because the
    pure `validate_<schema>_text(text: str) -> list[str]` functions receive no
    file path, only `$schema` values with an explicit scheme (`file://`,
    `http://`, `https://`) can resolve; a scheme-less `$schema` value fails
    schema resolution and is reported as an error string, never an unhandled
    exception.
"""

from __future__ import annotations

import json
from pathlib import Path
from typing import TYPE_CHECKING, Any, cast

from jsonschema import Draft202012Validator

from scripts.dev_tools.schema_loading import load_schema

if TYPE_CHECKING:
    from collections.abc import Mapping

    from jsonschema.protocols import Validator as _SchemaValidator

_DEFAULT_CACHE_DIR: Path = Path(".cache/schemas")


def _as_schema_validator(validator: _SchemaValidator) -> _SchemaValidator:
    """Widen a concrete `jsonschema` validator to the typed `Validator` protocol.

    Purpose:
        Isolate `jsonschema`'s partially-typed concrete validator classes
        (whose bundled stub declares `iter_errors` with incomplete parameter
        types) behind the library's own fully-typed `Validator` protocol, per
        the repository's convention for wrapping untyped/partially-typed
        third-party members in a small typed adapter.

    Args:
        validator (_SchemaValidator): A concrete validator instance (for
            example `Draft202012Validator(schema)`).

    Returns:
        _SchemaValidator: The same instance, typed as the `Validator`
        protocol.

    Raises:
        None.

    Side Effects:
        None.
    """

    return validator


def _extract_schema_uri(data: Mapping[str, Any]) -> str:
    """Return the artifact's `$schema` URI.

    Purpose:
        Isolate the schema-location seam (the `_resolve_schema_path`
        equivalent) so only this function changes if #9002's schema-location
        convention changes.

    Args:
        data (Mapping[str, Any]): Parsed JSON artifact document.

    Returns:
        str: The artifact's declared `$schema` URI.

    Raises:
        ValueError: When `$schema` is absent or not a non-empty string.

    Side Effects:
        None.
    """

    schema_value = data.get("$schema")
    if not isinstance(schema_value, str) or not schema_value:
        raise ValueError("missing $schema")
    return schema_value


def _validate_against_schema(
    text: str, artifact_type: str, *, cache_dir: Path = _DEFAULT_CACHE_DIR
) -> list[str]:
    """Validate `text` as JSON conforming to its declared `$schema`.

    Purpose:
        Provide the shared implementation delegated to by each
        `validate_<schema>_text` wrapper, per Design Decision 2 (bare error
        strings, no artifact-type prefix).

    Args:
        text (str): Raw artifact document text.
        artifact_type (str): Artifact type label, used only by callers for
            dispatch; not embedded in returned error strings.
        cache_dir (Path): Directory used to cache fetched `http(s)://`
            schemas.

    Returns:
        list[str]: Empty list when `text` conforms to its schema; otherwise
        one or more human-readable error strings.

    Raises:
        None.

    Side Effects:
        May read a local schema file, fetch a remote schema, or write a
        cached schema copy to `cache_dir`.
    """

    try:
        data_raw = json.loads(text)
    except json.JSONDecodeError as exc:
        return [f"invalid JSON ({exc})"]

    if not isinstance(data_raw, dict):
        return ["JSON root must be an object for validation"]

    data = cast("dict[str, Any]", data_raw)

    try:
        schema_uri = _extract_schema_uri(data)
        schema = load_schema(schema_uri, cache_dir)
    except (ValueError, FileNotFoundError, OSError, json.JSONDecodeError) as exc:
        return [f"schema resolution failed ({exc})"]

    validator = _as_schema_validator(Draft202012Validator(schema))
    errors = sorted(validator.iter_errors(data), key=lambda e: e.path)
    return [f"{list(err.path)}: {err.message}" for err in errors]


def validate_feature_contract_text(
    text: str, *, cache_dir: Path = _DEFAULT_CACHE_DIR
) -> list[str]:
    """Validate Feature Contract artifact text against its `$schema`."""
    return _validate_against_schema(text, "feature-contract", cache_dir=cache_dir)


def validate_coverage_ledger_text(
    text: str, *, cache_dir: Path = _DEFAULT_CACHE_DIR
) -> list[str]:
    """Validate Coverage Ledger artifact text against its `$schema`."""
    return _validate_against_schema(text, "coverage-ledger", cache_dir=cache_dir)


def validate_runtime_scenario_text(
    text: str, *, cache_dir: Path = _DEFAULT_CACHE_DIR
) -> list[str]:
    """Validate a Runtime Characterization Scenario artifact against its `$schema`."""
    return _validate_against_schema(text, "runtime-scenario", cache_dir=cache_dir)


def validate_parity_matrix_text(
    text: str, *, cache_dir: Path = _DEFAULT_CACHE_DIR
) -> list[str]:
    """Validate Parity Matrix artifact text against its `$schema`."""
    return _validate_against_schema(text, "parity-matrix", cache_dir=cache_dir)


def validate_unspecified_behavior_text(
    text: str, *, cache_dir: Path = _DEFAULT_CACHE_DIR
) -> list[str]:
    """Validate Unspecified Behavior Record artifact text against its `$schema`."""
    return _validate_against_schema(text, "unspecified-behavior", cache_dir=cache_dir)


def validate_product_decision_text(
    text: str, *, cache_dir: Path = _DEFAULT_CACHE_DIR
) -> list[str]:
    """Validate Product Decision Record artifact text against its `$schema`."""
    return _validate_against_schema(text, "product-decision", cache_dir=cache_dir)


def validate_evidence_reference_text(
    text: str, *, cache_dir: Path = _DEFAULT_CACHE_DIR
) -> list[str]:
    """Validate Evidence Reference artifact text against its `$schema`."""
    return _validate_against_schema(text, "evidence-reference", cache_dir=cache_dir)
