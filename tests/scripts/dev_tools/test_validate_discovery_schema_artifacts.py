"""Unit tests for `validate_discovery_schema_artifacts`.

Purpose:
    Cover `_extract_schema_uri`, `_validate_against_schema`, and the
    `validate_feature_contract_text` / `validate_coverage_ledger_text` /
    `validate_runtime_scenario_text` / `validate_parity_matrix_text` wrappers
    using inline literal schemas and artifacts, per the plan's fixture note
    (#9002 fixtures not yet wired in).
"""

from __future__ import annotations

import json
from typing import TYPE_CHECKING

import pytest

import scripts.dev_tools.validate_discovery_schema_artifacts as discovery_schema

if TYPE_CHECKING:
    from collections.abc import Callable
    from pathlib import Path

    from _pytest.monkeypatch import MonkeyPatch


def test_extract_schema_uri_raises_for_missing_schema_field() -> None:
    """A document without `$schema` should raise ValueError."""
    with pytest.raises(ValueError, match="missing \\$schema"):
        discovery_schema._extract_schema_uri({})  # type: ignore[reportPrivateUsage]


def test_extract_schema_uri_returns_declared_uri() -> None:
    """A document with a `$schema` string should return that string."""
    uri = discovery_schema._extract_schema_uri(  # type: ignore[reportPrivateUsage]
        {"$schema": "https://x/y.json"}
    )

    assert uri == "https://x/y.json"


def test_validate_against_schema_rejects_malformed_json() -> None:
    """Malformed JSON should be reported as an error string, not raised."""
    errors = discovery_schema._validate_against_schema(  # type: ignore[reportPrivateUsage]
        "{not json", "feature-contract"
    )

    assert len(errors) == 1
    assert "invalid JSON" in errors[0]


def test_validate_against_schema_rejects_non_dict_root() -> None:
    """A JSON array at the document root should be rejected explicitly."""
    errors = discovery_schema._validate_against_schema(  # type: ignore[reportPrivateUsage]
        "[]", "feature-contract"
    )

    assert errors == ["JSON root must be an object for validation"]


def test_validate_against_schema_reports_missing_schema_field_as_error_string() -> None:
    """A document with no `$schema` field should report resolution failure."""
    errors = discovery_schema._validate_against_schema(  # type: ignore[reportPrivateUsage]
        json.dumps({"acceptance_criteria": []}), "feature-contract"
    )

    assert len(errors) == 1
    assert "schema resolution failed" in errors[0]


def _permissive_object_schema(_uri: str, _cache_dir: Path) -> dict[str, object]:
    """Stand in for `load_schema` requiring `acceptance_criteria`."""
    return {
        "type": "object",
        "required": ["acceptance_criteria"],
        "properties": {"acceptance_criteria": {"type": "array"}},
    }


def test_validate_feature_contract_text_accepts_conforming_fixture(
    monkeypatch: MonkeyPatch,
) -> None:
    """A conforming feature-contract fixture should validate with no errors."""
    monkeypatch.setattr(discovery_schema, "load_schema", _permissive_object_schema)

    errors = discovery_schema.validate_feature_contract_text(
        json.dumps(
            {
                "$schema": "https://example.test/feature-contract.schema.json",
                "acceptance_criteria": [],
            }
        )
    )

    assert errors == []


def test_validate_feature_contract_text_rejects_non_conforming_fixture(
    monkeypatch: MonkeyPatch,
) -> None:
    """A fixture missing `acceptance_criteria` should be rejected with detail.

    Note: `jsonschema`'s `Draft202012Validator` reports a missing top-level
    required property with an empty `error.path` (the path to the instance
    that failed, not the missing key), so the formatted message is
    `"[]: 'acceptance_criteria' is a required property"` rather than a
    `['acceptance_criteria']`-prefixed message. This assertion checks the
    verified real output rather than the bracket-wrapped form.
    """
    monkeypatch.setattr(discovery_schema, "load_schema", _permissive_object_schema)

    errors = discovery_schema.validate_feature_contract_text(
        json.dumps({"$schema": "https://example.test/feature-contract.schema.json"})
    )

    assert len(errors) == 1
    assert "acceptance_criteria" in errors[0]
    assert "required property" in errors[0]


def _permissive_type_object_schema(_uri: str, _cache_dir: Path) -> dict[str, object]:
    """Stand in for `load_schema` returning a minimal permissive schema."""
    return {"type": "object"}


@pytest.mark.parametrize(
    "validator",
    [
        discovery_schema.validate_coverage_ledger_text,
        discovery_schema.validate_runtime_scenario_text,
        discovery_schema.validate_parity_matrix_text,
    ],
)
def test_first_three_remaining_schema_validators_accept_conforming_fixtures(
    validator: Callable[[str], list[str]], monkeypatch: MonkeyPatch
) -> None:
    """Each of these three validators should accept a conforming fixture."""
    monkeypatch.setattr(discovery_schema, "load_schema", _permissive_type_object_schema)

    errors = validator(json.dumps({"$schema": "https://example.test/schema.json"}))

    assert errors == []
