"""Verify offline v2 shared identity, state, dimension and resource contracts."""

from __future__ import annotations

import pytest
from drm_copilot_discovery.resources import read_resource
from jsonschema import Draft202012Validator

from scripts.dev_tools.build_discovery_runtime import verify_schema_closure
from tests.schemas.discovery.v2_schema_test_support import (
    HASH,
    KINDS,
    SCHEMAS,
    URN,
    load_schema,
    schema_errors,
)


@pytest.mark.parametrize("kind", KINDS)
def test_schema_is_draft202012_closed_and_packaged_identically(kind: str) -> None:
    """Canonical schemas are valid, uniquely identified and copied byte-for-byte."""
    schema = load_schema(kind)

    Draft202012Validator.check_schema(schema)
    packaged = read_resource(f"schemas/discovery/v2/{kind}.schema.json")

    assert schema["$schema"] == "https://json-schema.org/draft/2020-12/schema"
    assert schema["$id"] == URN + kind
    assert schema["additionalProperties"] is False
    assert packaged == (SCHEMAS / f"{kind}.schema.json").read_bytes()


def test_shared_reference_closure_is_complete_without_external_retrieval() -> None:
    """Every schema reference resolves within the declared v2 source set."""
    inputs = {
        f"schemas/discovery/v2/{kind}.schema.json": (
            SCHEMAS / f"{kind}.schema.json"
        ).read_bytes()
        for kind in KINDS
    }

    verify_schema_closure(inputs)

    assert len({str(load_schema(kind)["$id"]) for kind in KINDS}) == 3


@pytest.mark.parametrize("revision", ("a" * 40, "b" * 64))
def test_foreign_artifact_reference_requires_complete_immutable_identity(
    revision: str,
) -> None:
    """Foreign references bind kind, identity, source pin, path and exact bytes."""
    reference: dict[str, object] = {
        "artifact_kind": "feature-contract",
        "id": "feature-example",
        "repository": "source-example",
        "revision": revision,
        "path": "contracts/feature-example.json",
        "sha256": HASH,
    }
    assert schema_errors("common", reference, "immutable-artifact-reference") == []
    for field in reference:
        incomplete = {key: value for key, value in reference.items() if key != field}
        assert schema_errors(
            "common", incomplete, "immutable-artifact-reference"
        ), field


@pytest.mark.parametrize(
    "definition,valid,invalid",
    [
        ("lifecycle", "reviewed", "verified"),
        ("observation-state", "verified", "approved"),
        ("confidence", "high", "verified"),
        ("product-decision-state", "approved", "verified"),
        ("target-relevance", "required", "full"),
        ("inspection-status", "inspected", "full"),
        ("coverage-disposition", "supporting", "inspected"),
        ("runtime-result", "observed", "verified"),
        ("repeatability", "repeatable", "passed"),
        ("parity-state", "full", "approved"),
        ("applicability", "applicable", "passed"),
        ("dimension-verification", "passed", "applicable"),
        ("unspecified-behavior-state", "resolved", "approved"),
        ("acceptance-readiness", "ready", "passed"),
        ("validation-outcome", "pass", "ready"),
    ],
)
def test_status_axes_cannot_substitute_for_each_other(
    definition: str, valid: str, invalid: str
) -> None:
    """Observation, confidence, approval, lifecycle and completion remain distinct."""
    assert schema_errors("common", valid, definition) == []
    assert schema_errors("common", invalid, definition)


def test_behavior_dimension_preserves_unknowns_and_requires_evidence_for_claims() -> (
    None
):
    """Unknown expectations cannot become verified statements without their proof."""
    dimension: dict[str, object] = {
        "observation_state": "unknown",
        "statement": None,
        "evidence_refs": [],
        "unresolved_behavior_refs": [
            {"artifact_kind": "unspecified-behavior", "id": "behavior-example"}
        ],
        "confidence": "unknown",
    }
    assert schema_errors("common", dimension, "behavior-dimension") == []
    dimension["statement"] = "Invented outcome"
    assert schema_errors("common", dimension, "behavior-dimension")
    dimension["observation_state"] = "verified"
    assert schema_errors("common", dimension, "behavior-dimension")
    dimension.update(
        statement="Captured outcome",
        unresolved_behavior_refs=[],
        evidence_refs=[
            {"artifact_kind": "evidence-reference", "id": "evidence-example"}
        ],
    )

    assert schema_errors("common", dimension, "behavior-dimension") == []


def test_intentionally_unspecified_and_inapplicable_dimensions_require_rationale() -> (
    None
):
    """Explicit policy and applicability dispositions cannot conceal missing links."""
    dimension: dict[str, object] = {
        "observation_state": "intentionally-unspecified",
        "statement": None,
        "evidence_refs": [],
        "unresolved_behavior_refs": [],
        "confidence": "high",
    }
    assert schema_errors("common", dimension, "behavior-dimension")
    dimension.update(
        product_decision_refs=[
            {"artifact_kind": "product-decision", "id": "decision-example"}
        ],
        rationale="The approved decision leaves this unspecified.",
    )
    assert schema_errors("common", dimension, "behavior-dimension") == []
    assert schema_errors(
        "common",
        {"applicability": "not-applicable", "rationale": None},
        "dimension-applicability",
    )


@pytest.mark.parametrize(
    "definition,value",
    [
        ("identifier", "feature.alpha"),
        ("revision", "a" * 40),
        ("revision", "b" * 64),
        ("sha256", "c" * 64),
        ("relative-path", "src/component.py"),
        ("path-or-glob", "src/**"),
    ],
)
@pytest.mark.parametrize("suffix", ("\n", "\r", "\r\n", "\u2028", "\u2029"))
def test_lexical_tokens_require_the_actual_string_end(
    definition: str, value: str, suffix: str
) -> None:
    """A final line terminator cannot exploit the regex dollar-anchor behavior."""
    assert schema_errors("common", value, definition) == []
    assert schema_errors("common", value + suffix, definition)


@pytest.mark.parametrize("suffix", ("\n", "\r", "\r\n", "\u2028", "\u2029"))
def test_extension_namespaces_reject_trailing_line_terminators(suffix: str) -> None:
    """The extension map cannot admit malformed names through patternProperties."""
    assert schema_errors("common", {"example.domain": {}}, "extensions") == []
    assert schema_errors("common", {"example.domain" + suffix: {}}, "extensions")
