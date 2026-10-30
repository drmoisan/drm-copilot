"""Verify trusted-kind validation, embedded extensions and compatibility-only reads."""

from __future__ import annotations

import copy
import hashlib
import json
import sys
from pathlib import Path
from typing import TYPE_CHECKING

import pytest
from drm_copilot_discovery import schema_validation
from drm_copilot_discovery.catalog import (
    DIALECT,
    V1_KINDS,
    V2_KINDS,
    V2_URN,
    ExtensionSchema,
    SchemaCatalog,
    load_catalog,
    schema_path,
)
from drm_copilot_discovery.models import ParseLimits
from drm_copilot_discovery.schema_validation import validate_document
from jsonschema import FormatChecker

from tests.schemas.discovery.v2_control_test_support import (
    CONTROL_KINDS,
    control_fixture,
)
from tests.schemas.discovery.v2_schema_test_support import as_object, load_fixture

if TYPE_CHECKING:
    from _pytest.monkeypatch import MonkeyPatch

ROOT = Path(__file__).resolve().parents[2]


def _v1_text(kind: str) -> str:
    """Read immutable committed legacy examples without writable fixture setup."""
    filename = Path(schema_path(kind, "1.0.0")).name.replace(
        ".schema.json", ".example.json"
    )
    return (ROOT / "examples/discovery/v1" / filename).read_text("utf-8")


def _extension_catalog(schema: dict[str, object]) -> SchemaCatalog:
    """Bind one synthetic namespace to locally supplied, checksum-verified bytes."""
    content = json.dumps({"$schema": DIALECT, **schema}).encode()
    return load_catalog(
        extensions=(
            ExtensionSchema(
                namespace="example.review",
                path="docs/extension.json",
                content=content,
                sha256=hashlib.sha256(content).hexdigest(),
            ),
        )
    )


@pytest.mark.parametrize("kind", V1_KINDS)
def test_frozen_v1_examples_remain_valid_and_explicitly_compatibility_only(
    kind: str,
) -> None:
    """Legacy success preserves the actual schema while carrying no v2 gate status."""
    result = validate_document(
        _v1_text(kind), expected_kind=kind, expected_version="1.0.0"
    )

    assert result.ok and result.compatibility_only
    assert result.findings == ()
    assert result.document is not None


# Every artifact kind is exercised; common is a definitions-only schema.
@pytest.mark.parametrize("kind", tuple(kind for kind in V2_KINDS if kind != "common"))
def test_all_v2_kinds_validate_through_actual_offline_catalog(kind: str) -> None:
    """Normal artifacts and both exceptional wire envelopes retain their real shapes."""
    value = control_fixture(kind) if kind in CONTROL_KINDS else load_fixture(kind)

    result = validate_document(
        json.dumps(value), expected_kind=kind, expected_version="2.0.0"
    )

    assert result.ok, result.findings
    assert not result.compatibility_only


@pytest.mark.parametrize(
    ("key", "value"),
    [
        ("$schema", V2_URN + "scope"),
        ("$schema", "https://example.invalid/weak"),
        ("$schema", "file:///weak.json"),
        ("$schema", V2_URN + "common"),
        ("artifact_kind", "scope"),
        ("schema_version", "2.0.1"),
        ("schema_version", "2.0.0\n"),
    ],
)
def test_artifact_metadata_cannot_change_trusted_schema_selection(
    key: str, value: object
) -> None:
    """Mismatched headers fail before payload evaluation can weaken checks."""
    document = load_fixture("feature-contract")
    document[key] = value

    result = validate_document(
        json.dumps(document), expected_kind="feature-contract", expected_version="2.0.0"
    )

    assert not result.ok
    assert result.findings[0].code == "SCHEMA_IDENTITY"
    assert result.findings[0].pointer == "/" + key


@pytest.mark.parametrize(
    ("kind", "version"),
    [
        ("scope", "3.0.0"),
        ("common", "2.0.0"),
        ("missing", "2.0.0"),
    ],
)
def test_invalid_trusted_dispatch_is_a_blocking_catalog_finding(
    kind: str, version: str
) -> None:
    """Unsupported caller identities cannot create a fallback validator."""
    result = validate_document("{}", expected_kind=kind, expected_version=version)

    assert not result.ok
    assert result.findings[0].code == "SCHEMA_UNAVAILABLE"


@pytest.mark.parametrize("kind", ("activation", "service-result"))
def test_control_envelopes_reject_injected_headers_and_wrong_exact_versions(
    kind: str,
) -> None:
    """Special envelopes omit general headers but remain closed and versioned."""
    document = control_fixture(kind)
    document["$schema"] = V2_URN + kind
    assert not validate_document(
        json.dumps(document), expected_kind=kind, expected_version="2.0.0"
    ).ok
    del document["$schema"]
    field = "result_version" if kind == "service-result" else "schema_version"
    document[field] = "2.1.0"

    result = validate_document(
        json.dumps(document), expected_kind=kind, expected_version="2.0.0"
    )

    assert not result.ok
    assert result.findings[0].pointer == "/" + field


@pytest.mark.parametrize("content", ("{", "[]", '{"id":1,"id":2}', ".nan"))
def test_malformed_input_never_reaches_catalog_or_returns_partial_success(
    content: str,
) -> None:
    """Strict parser findings propagate with the supplied workspace-relative path."""
    result = validate_document(
        content,
        expected_kind="scope",
        expected_version="2.0.0",
        artifact_path="docs/Évidence Record.json",
    )

    assert not result.ok and result.document is None
    assert result.findings[0].artifact_path == "docs/Évidence Record.json"


def test_yaml_and_json_validate_identically_with_bounded_deterministic_findings() -> (
    None
):
    """Syntax choice and member order cannot change normalized validation results."""
    document = {
        "$schema": V2_URN + "scope",
        "schema_version": "2.0.0",
        "artifact_kind": "scope",
    }
    # Reverse the same fields to prove order and syntax independence together.
    yaml = "\n".join(
        f"{key}: {value}" for key, value in reversed(tuple(document.items()))
    )
    first = validate_document(
        json.dumps(document),
        expected_kind="scope",
        expected_version="2.0.0",
        limits=ParseLimits(findings=2),
    )
    second = validate_document(
        yaml,
        expected_kind="scope",
        expected_version="2.0.0",
        format="yaml",
        limits=ParseLimits(findings=2),
    )

    assert first == second
    assert len(first.findings) == 2
    # Truncation must remain an explicit blocker rather than a success shortcut.
    assert any(item.code == "FINDINGS_LIMIT" for item in first.findings)
    assert not first.ok


def test_unavailable_runtime_dependency_stays_a_blocking_finding(
    monkeypatch: MonkeyPatch,
) -> None:
    """A previously loaded catalog cannot bypass missing validator dependencies."""
    catalog = load_catalog()
    monkeypatch.setitem(sys.modules, "jsonschema", None)

    result = validate_document(
        json.dumps(control_fixture("activation")),
        expected_kind="activation",
        expected_version="2.0.0",
        catalog=catalog,
    )

    assert not result.ok
    assert "dependency unavailable" in result.findings[0].message


def test_unavailable_required_format_checker_fails_closed(
    monkeypatch: MonkeyPatch,
) -> None:
    """Library defaults missing a checker cannot turn into validation success."""

    def empty_checker() -> FormatChecker:
        """Represent a validator installation without optional format plugins."""
        return FormatChecker(formats=())

    monkeypatch.setattr(schema_validation, "discovery_format_checker", empty_checker)
    result = validate_document(
        json.dumps(control_fixture("activation")),
        expected_kind="activation",
        expected_version="2.0.0",
    )

    assert not result.ok
    assert "checker unavailable" in result.findings[0].message


def test_format_factory_reports_unavailable_dependency(
    monkeypatch: MonkeyPatch,
) -> None:
    """The format factory itself never substitutes a partial implementation."""
    monkeypatch.setitem(sys.modules, "jsonschema", None)

    with pytest.raises(ValueError, match="dependency unavailable"):
        schema_validation.discovery_format_checker()


def test_extensions_validate_only_schema_governed_positions_with_precise_pointers() -> (
    None
):
    """Embedded records and environments share the authoritative extension rule."""
    catalog = _extension_catalog(
        {"type": "object", "properties": {"mode": {"enum": ["approved"]}}}
    )
    decision = load_fixture("product-decision")
    decision["extensions"] = {"example.review": {"mode": "invalid"}}
    collection = load_fixture("product-decision-collection")
    collection["records"] = [decision]
    evidence = load_fixture("evidence-reference")
    as_object(evidence["environment"])["extensions"] = {
        "example.review": {"mode": "invalid"}
    }
    # The same namespace constraint applies at each schema-governed occurrence.
    for kind, document, pointer in (
        ("product-decision", decision, "/extensions/example.review/mode"),
        (
            "product-decision-collection",
            collection,
            "/records/0/extensions/example.review/mode",
        ),
        ("evidence-reference", evidence, "/environment/extensions/example.review/mode"),
    ):
        result = validate_document(
            json.dumps(document),
            expected_kind=kind,
            expected_version="2.0.0",
            catalog=catalog,
        )
        assert not result.ok
        # Nested validation must retain the complete instance location.
        assert any(item.pointer == pointer for item in result.findings)
    decision["extensions"] = {
        "example.review": {
            "mode": "approved",
            "extensions": {"example.review": {"mode": "invalid"}},
        }
    }
    assert validate_document(
        json.dumps(decision),
        expected_kind="product-decision",
        expected_version="2.0.0",
        catalog=catalog,
    ).ok


def test_extensions_cannot_relax_core_fields_or_validate_unconfigured_namespaces() -> (
    None
):
    """An unconstrained extension schema never replaces required core assertions."""
    catalog = _extension_catalog({})
    document = load_fixture("feature-contract")
    document["extensions"] = {"other.namespace": {"anything": [1, True, None]}}
    assert validate_document(
        json.dumps(document),
        expected_kind="feature-contract",
        expected_version="2.0.0",
        catalog=catalog,
    ).ok
    document["confidence"] = "invented"

    result = validate_document(
        json.dumps(document),
        expected_kind="feature-contract",
        expected_version="2.0.0",
        catalog=catalog,
    )

    assert not result.ok
    # The core status rule is independent of permissive domain metadata.
    assert any(item.pointer == "/confidence" for item in result.findings)


def test_non_consuming_recursion_is_blocking_while_finite_recursive_payloads_work() -> (
    None
):
    """Local schema recursion cannot escape as an exception or reject finite trees."""
    document = load_fixture("feature-contract")
    document["extensions"] = {
        "example.review": {"value": "alpha", "child": {"value": "beta"}}
    }
    recursive = _extension_catalog(
        {
            "type": "object",
            "properties": {"value": {"type": "string"}, "child": {"$ref": "#"}},
        }
    )
    assert validate_document(
        json.dumps(document),
        expected_kind="feature-contract",
        expected_version="2.0.0",
        catalog=recursive,
    ).ok

    result = validate_document(
        json.dumps(document),
        expected_kind="feature-contract",
        expected_version="2.0.0",
        catalog=_extension_catalog({"$ref": "#"}),
    )

    assert not result.ok
    assert result.findings[-1].code == "SCHEMA_UNAVAILABLE"
    assert "recursive evaluation limit" in result.findings[-1].message


def test_error_pointers_escape_arbitrary_domain_keys() -> None:
    """Extension-property errors retain RFC 6901 escaping through actual validation."""
    catalog = _extension_catalog({"properties": {"a/b~c": {"type": "integer"}}})
    document = load_fixture("feature-contract")
    document["extensions"] = {"example.review": {"a/b~c": "invalid"}}

    result = validate_document(
        json.dumps(document),
        expected_kind="feature-contract",
        expected_version="2.0.0",
        catalog=catalog,
    )

    assert not result.ok
    assert result.findings[0].pointer == "/extensions/example.review/a~1b~0c"


def test_repeated_validations_through_one_catalog_are_independent() -> None:
    """One catalog validates a sequence of documents with no state carried between.

    The result of each validation equals the result for the same text through a
    fresh catalog, and the registry resolves unchanged schema contents afterwards.
    `before` is a deep copy of the resolved contents taken ahead of the
    validations, so the final comparison against the live lookup can fail if a
    validation mutates the shared schema; the catalog must also hand out one
    registry object across the three validations.
    """
    catalog = load_catalog()
    registry = catalog.registry()
    invalid = control_fixture("activation")
    del invalid["enabled"]
    texts = (
        json.dumps(invalid),
        json.dumps(control_fixture("activation")),
        json.dumps(invalid),
    )
    before = copy.deepcopy(registry.resolver().lookup(V2_URN + "activation").contents)

    # Validate the invalid, valid, invalid sequence through the same catalog.
    shared = [
        validate_document(
            text, expected_kind="activation", expected_version="2.0.0", catalog=catalog
        )
        for text in texts
    ]
    # Validate each text again through its own freshly loaded catalog.
    fresh = [
        validate_document(
            text,
            expected_kind="activation",
            expected_version="2.0.0",
            catalog=load_catalog(),
        )
        for text in texts
    ]
    after = catalog.registry().resolver().lookup(V2_URN + "activation").contents

    assert shared == fresh
    assert shared[0] == shared[2] and not shared[0].ok
    assert shared[1].ok
    assert catalog.registry() is registry
    assert after == before
