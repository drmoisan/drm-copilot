"""Verify stable text wrappers against real expected schemas without remote mocks."""

from __future__ import annotations

import json
from pathlib import Path
from typing import TYPE_CHECKING, cast

import pytest
from drm_copilot_discovery.catalog import CatalogError, schema_path

import scripts.dev_tools.validate_discovery_schema_artifacts as discovery_schema
from tests.schemas.discovery.v2_schema_test_support import load_fixture

if TYPE_CHECKING:
    from collections.abc import Callable, Mapping

ROOT = Path(__file__).resolve().parents[3]


def fixture_text(kind: str) -> str:
    """Read committed legacy examples without creating filesystem fixtures."""
    filename = Path(schema_path(kind, "1.0.0")).name.replace(
        ".schema.json", ".example.json"
    )
    return (ROOT / "examples/discovery/v1" / filename).read_text("utf-8")


def test_extract_schema_uri_raises_for_missing_schema_field() -> None:
    """Metadata inspection still reports absent schema text explicitly."""
    extract = cast(
        "Callable[[Mapping[str, object]], str]",
        vars(discovery_schema)["_extract_schema_uri"],
    )
    with pytest.raises(ValueError, match=r"missing \$schema"):
        extract({})


def test_extract_schema_uri_returns_declared_uri_without_loading_it() -> None:
    """Inspection is separate from authority to resolve an unregistered URI."""
    extract = cast(
        "Callable[[Mapping[str, object]], str]",
        vars(discovery_schema)["_extract_schema_uri"],
    )
    assert extract({"$schema": "https://x/y.json"}) == "https://x/y.json"
    with pytest.raises(CatalogError, match="Unregistered"):
        discovery_schema.load_schema("https://x/y.json")


@pytest.mark.parametrize(
    ("text", "code"),
    [
        ("{not json", "DOCUMENT_SYNTAX"),
        ("[]", "DOCUMENT_ROOT"),
        ('{"id":1,"id":2}', "DOCUMENT_DUPLICATE_KEY"),
    ],
)
def test_validate_against_schema_rejects_malformed_json(text: str, code: str) -> None:
    """Strict parsing errors remain actionable list results rather than exceptions."""
    errors = discovery_schema.validate_feature_contract_text(text)

    assert len(errors) == 1
    assert code in errors[0]


def test_missing_schema_field_reports_identity_failure() -> None:
    """Missing identity cannot select an inferred or weaker schema."""
    errors = discovery_schema.validate_feature_contract_text(
        '{"schema_version":"1.0.0"}'
    )

    assert len(errors) == 1
    assert "SCHEMA_IDENTITY /$schema" in errors[0]


def test_validate_feature_contract_text_accepts_real_frozen_v1_fixture() -> None:
    """Default wrapper calls preserve the documented compatibility reader."""
    assert (
        discovery_schema.validate_feature_contract_text(
            fixture_text("feature-contract")
        )
        == []
    )


def test_validate_feature_contract_text_rejects_missing_acceptance_criteria() -> None:
    """The real v1 schema retains its required acceptance-criteria assertion."""
    document = cast("dict[str, object]", json.loads(fixture_text("feature-contract")))
    del document["acceptance_criteria"]

    errors = discovery_schema.validate_feature_contract_text(json.dumps(document))

    assert len(errors) == 1
    assert "acceptance_criteria" in errors[0] and "required property" in errors[0]


@pytest.mark.parametrize(
    ("validator", "kind"),
    [
        (discovery_schema.validate_coverage_ledger_text, "coverage-ledger"),
        (
            discovery_schema.validate_runtime_scenario_text,
            "runtime-characterization-scenario",
        ),
        (discovery_schema.validate_parity_matrix_text, "parity-matrix"),
    ],
)
def test_remaining_wrappers_preserve_expected_kind_validation(
    validator: Callable[[str], list[str]],
    kind: str,
) -> None:
    """Actual legacy artifacts pass only the corresponding wrapper."""
    assert validator(fixture_text(kind)) == []
    assert validator(fixture_text("feature-contract"))


def test_trusted_version_keyword_enables_v2_without_artifact_selected_dispatch() -> (
    None
):
    """Existing calls stay v1 while an explicit caller version selects exact v2."""
    text = json.dumps(load_fixture("feature-contract"))

    assert discovery_schema.validate_feature_contract_text(text)
    assert (
        discovery_schema.validate_feature_contract_text(text, schema_version="2.0.0")
        == []
    )
    assert discovery_schema.validate_feature_contract_text(text, schema_version="2.0.1")


def test_registered_schema_lookup_retains_unused_cache_argument() -> None:
    """The old load_schema export performs no cache writes or external retrieval."""
    schema = discovery_schema.load_schema(
        "../../../schemas/discovery/v1/feature-contract.schema.json",
        Path("unused-cache"),
    )

    assert schema["$id"] == "schemas/discovery/v1/feature-contract.schema.json"
