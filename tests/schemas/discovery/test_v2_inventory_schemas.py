"""Verify pinned inventories and honest component inspection records."""

from __future__ import annotations

from copy import deepcopy
from typing import cast

import pytest
from drm_copilot_discovery.resources import read_resource
from jsonschema import Draft202012Validator

from scripts.dev_tools.build_discovery_runtime import verify_schema_closure
from tests.schemas.discovery.v2_schema_test_support import (
    HASH,
    SCHEMAS,
    URN,
    as_object,
    load_fixture,
    load_schema,
    schema_errors,
)

INVENTORY_KINDS = (
    "coverage-ledger",
    "inventory-snapshot",
    "source-snapshot-manifest",
    "extension-result-manifest",
)


def _first(document: dict[str, object], field: str) -> dict[str, object]:
    """Select one fresh fixture record for a localized mutation."""
    return as_object(cast("list[object]", document[field])[0])


@pytest.mark.parametrize("kind", INVENTORY_KINDS)
def test_inventory_schemas_have_exact_identity_and_packaged_bytes(kind: str) -> None:
    """Each transport contract is a valid offline, closed Draft 2020-12 schema."""
    schema = load_schema(kind)
    Draft202012Validator.check_schema(schema)
    closure = {
        f"schemas/discovery/v2/{path.name}": path.read_bytes()
        for path in SCHEMAS.glob("*.schema.json")
    }
    verify_schema_closure(closure)

    assert schema["$id"] == URN + kind
    assert schema["additionalProperties"] is False
    assert (
        read_resource(f"schemas/discovery/v2/{kind}.schema.json")
        == (SCHEMAS / f"{kind}.schema.json").read_bytes()
    )
    assert schema_errors(kind, load_fixture(kind)) == []
    invalid_errors = schema_errors(kind, load_fixture(kind, invalid=True))
    assert invalid_errors
    assert all(error.message and list(error.absolute_path) for error in invalid_errors)


@pytest.mark.parametrize("kind", INVENTORY_KINDS)
@pytest.mark.parametrize(
    "field,value",
    [
        ("schema_version", "2.1.0"),
        ("artifact_kind", "product-decision"),
        ("id", "Invalid Identifier"),
        ("$schema", "https://example.invalid/weaker.json"),
        ("complete", True),
    ],
)
def test_inventory_envelopes_reject_wrong_identity_or_authored_completion(
    kind: str, field: str, value: object
) -> None:
    """A caller-selected schema or status cannot change the expected core kind."""
    document = load_fixture(kind)
    document[field] = value

    assert schema_errors(kind, document)


@pytest.mark.parametrize("kind", INVENTORY_KINDS)
def test_inventory_extensions_do_not_replace_required_provenance(kind: str) -> None:
    """Namespaced data extends a contract without supplying core fields."""
    document = load_fixture(kind)
    document["extensions"] = {"example.org": {"local-label": "fixture"}}
    assert schema_errors(kind, document) == []
    del document["id"]

    assert schema_errors(kind, document)


def test_invalid_inventory_fixtures_have_individual_repairable_defects() -> None:
    """Each invalid example targets a specific, actionable schema boundary."""
    ledger = load_fixture("coverage-ledger", invalid=True)
    _first(ledger, "components")["exclusion_rationale"] = "Outside the confirmed scope."
    inventory = load_fixture("inventory-snapshot", invalid=True)
    _first(inventory, "files")["sha256"] = HASH
    source = load_fixture("source-snapshot-manifest", invalid=True)
    as_object(source["source_repository"])["revision"] = "a" * 40
    extension = load_fixture("extension-result-manifest", invalid=True)
    _first(extension, "result_files")["artifact_kind"] = "inventory-snapshot"

    for kind, repaired in zip(
        INVENTORY_KINDS, (ledger, inventory, source, extension), strict=True
    ):
        assert schema_errors(kind, repaired) == [], kind


def test_empty_ledger_preserves_unknown_revision_without_claiming_completion() -> None:
    """Initialization may record an honest null pin with no invented inventory."""
    ledger = load_fixture("coverage-ledger")
    component = deepcopy(_first(ledger, "components"))
    ledger.update(revision=None, components=[], inventory_snapshot_refs=[])
    assert schema_errors("coverage-ledger", ledger) == []
    ledger["components"] = [component]
    assert schema_errors("coverage-ledger", ledger)
    ledger["components"] = []
    ledger["inventory_snapshot_refs"] = [
        {"artifact_kind": "inventory-snapshot", "id": "inventory-alpha"}
    ]

    assert schema_errors("coverage-ledger", ledger)


@pytest.mark.parametrize(
    "field",
    (
        "repository revision inventory_snapshot_refs scope_ref components extensions"
    ).split(),
)
def test_ledger_requires_explicit_scope_and_repository_context(field: str) -> None:
    """Empty collections are explicit; omitted provenance is invalid."""
    ledger = load_fixture("coverage-ledger")
    del ledger[field]

    assert schema_errors("coverage-ledger", ledger)


@pytest.mark.parametrize(
    "field",
    (
        "component_id component_type path source_sha256 inspection_status disposition "
        "feature_refs tests_found runtime_validation_requirement runtime_rationale "
        "exclusion_rationale exclusion_scope_ref supporting_rationale blocked_reason "
        "responsible_workflow responsible_agent last_updated_evidence_refs extensions"
    ).split(),
)
def test_coverage_components_require_all_accounting_categories(field: str) -> None:
    """Each discovered component declares disposition, provenance and ownership."""
    ledger = load_fixture("coverage-ledger")
    del _first(ledger, "components")[field]

    assert schema_errors("coverage-ledger", ledger)


@pytest.mark.parametrize(
    "field,value",
    [
        ("path", "../outside.cs"),
        ("source_sha256", "c" * 63),
        ("symbol", " "),
        ("line_range", {"start": 0, "end": 3}),
        ("inspection_status", "verified"),
        ("disposition", "full"),
        ("feature_refs", []),
        ("runtime_validation_requirement", "passed"),
        ("last_updated_evidence_refs", []),
        ("responsible_workflow", ""),
    ],
)
def test_coverage_rejects_invalid_claim_axes_and_source_provenance(
    field: str, value: object
) -> None:
    """Parity, runtime outcome and inspection cannot be substituted for each other."""
    ledger = load_fixture("coverage-ledger")
    _first(ledger, "components")[field] = value

    assert schema_errors("coverage-ledger", ledger)


def test_detection_can_seed_an_uninspected_undispositioned_component() -> None:
    """A proposed ledger row remains incomplete until a later inspection."""
    ledger = load_fixture("coverage-ledger")
    component = _first(ledger, "components")
    component.update(
        inspection_status="uninspected",
        disposition="unassigned",
        feature_refs=[],
        tests_found=[],
        runtime_validation_requirement="undetermined",
        responsible_agent=None,
        last_updated_evidence_refs=[],
    )
    assert schema_errors("coverage-ledger", ledger) == []
    component.update(
        disposition="feature-linked",
        feature_refs=[{"artifact_kind": "feature-contract", "id": "feature-alpha"}],
    )
    assert schema_errors("coverage-ledger", ledger)
    ledger["inventory_snapshot_refs"] = []

    assert schema_errors("coverage-ledger", ledger)


@pytest.mark.parametrize("disposition", ("supporting", "excluded", "blocked"))
def test_non_feature_dispositions_require_their_specific_rationale(
    disposition: str,
) -> None:
    """Exclusions retain a typed scope link and cannot replace explanation."""
    ledger = load_fixture("coverage-ledger")
    component = _first(ledger, "components")
    component.update(disposition=disposition, feature_refs=[])
    assert schema_errors("coverage-ledger", ledger)
    rationale_field = {
        "supporting": "supporting_rationale",
        "excluded": "exclusion_rationale",
        "blocked": "blocked_reason",
    }[disposition]
    component[rationale_field] = "Recorded disposition rationale."
    if disposition == "excluded":
        assert schema_errors("coverage-ledger", ledger)
        component["exclusion_scope_ref"] = {
            "artifact_kind": "scope",
            "id": "scope-alpha",
        }

    assert schema_errors("coverage-ledger", ledger) == []


def test_no_runtime_requirement_needs_an_explicit_reason() -> None:
    """Static discovery cannot silently waive a component's runtime obligation."""
    ledger = load_fixture("coverage-ledger")
    component = _first(ledger, "components")
    component["runtime_validation_requirement"] = "not-required"
    assert schema_errors("coverage-ledger", ledger)
    component["runtime_rationale"] = "Scope requires only static declaration evidence."

    assert schema_errors("coverage-ledger", ledger) == []


@pytest.mark.parametrize("field", ("passed", "line_coverage", "production_verified"))
def test_test_relevance_records_cannot_claim_execution_or_coverage(field: str) -> None:
    """Lexical test references have no automated execution status fields."""
    ledger = load_fixture("coverage-ledger")
    _first(_first(ledger, "components"), "tests_found")[field] = True

    assert schema_errors("coverage-ledger", ledger)


@pytest.mark.parametrize(
    "field",
    (
        "repository revision tool analyzers scan_configuration_sha256 files components "
        "findings relationships diagnostics exclusions capture extensions"
    ).split(),
)
def test_inventory_requires_every_input_and_result_category(field: str) -> None:
    """Partial output still declares versions, byte manifests and diagnostics."""
    inventory = load_fixture("inventory-snapshot")
    del inventory[field]

    assert schema_errors("inventory-snapshot", inventory)


@pytest.mark.parametrize("status", ("excluded", "unreadable"))
def test_partial_inputs_do_not_invent_hashes_for_unread_bytes(status: str) -> None:
    """Omitted source bytes retain a reason and unreadable inputs link diagnostics."""
    inventory = load_fixture("inventory-snapshot")
    file = _first(inventory, "files")
    file.update(status=status, sha256=None, size=None, rationale="Not inspected.")
    if status == "unreadable":
        assert schema_errors("inventory-snapshot", inventory)
        file["diagnostic_ids"] = ["read-error-alpha"]
    assert schema_errors("inventory-snapshot", inventory) == []
    file["sha256"] = HASH

    assert schema_errors("inventory-snapshot", inventory)


@pytest.mark.parametrize("field", ("sha256", "size"))
def test_inspected_file_records_require_actual_byte_hash_and_size(field: str) -> None:
    """A scan must not label an unhashed input as inspected."""
    inventory = load_fixture("inventory-snapshot")
    _first(inventory, "files")[field] = None

    assert schema_errors("inventory-snapshot", inventory)


def test_complete_input_shape_does_not_erase_partial_snapshot_diagnostics() -> None:
    """The same schema supports complete and explicitly partial input accounting."""
    inventory = load_fixture("inventory-snapshot")
    assert schema_errors("inventory-snapshot", inventory) == []
    inventory["files"] = [_first(inventory, "files")]
    inventory["diagnostics"] = []

    assert schema_errors("inventory-snapshot", inventory) == []


@pytest.mark.parametrize("field", ("components", "findings", "relationships"))
@pytest.mark.parametrize("classification", ("detected", "inferred"))
def test_analyzer_facts_and_inferences_retain_independent_confidence(
    field: str, classification: str
) -> None:
    """Classifications describe static evidence, not reviewed feature behavior."""
    inventory = load_fixture("inventory-snapshot")
    record = _first(inventory, field)
    record.update(classification=classification, confidence="unknown")
    assert schema_errors("inventory-snapshot", inventory) == []
    record["classification"] = "verified"

    assert schema_errors("inventory-snapshot", inventory)


@pytest.mark.parametrize("field", ("components", "findings", "relationships"))
@pytest.mark.parametrize(
    "source_field,value",
    [
        ("revision", "main"),
        ("path", "C:/source.cs"),
        ("sha256", "c" * 64 + "\n"),
        ("line_range", {"start": True, "end": 3}),
    ],
)
def test_every_detection_carries_strict_pinned_source_provenance(
    field: str, source_field: str, value: object
) -> None:
    """A finding or relationship cannot lose the exact input byte identity."""
    inventory = load_fixture("inventory-snapshot")
    as_object(_first(inventory, field)["source"])[source_field] = value

    assert schema_errors("inventory-snapshot", inventory)


def test_structured_domain_payloads_use_namespaced_extensions() -> None:
    """Scalar declaration properties cannot become an unvalidated core object."""
    inventory = load_fixture("inventory-snapshot")
    component = _first(inventory, "components")
    component["extensions"] = {"example.org": {"custom": ["value"]}}
    assert schema_errors("inventory-snapshot", inventory) == []
    _first(component, "properties")["value"] = {"inspection_status": "inspected"}

    assert schema_errors("inventory-snapshot", inventory)


@pytest.mark.parametrize(
    "field,value",
    [
        ("severity", "verified"),
        ("blocking", "false"),
        ("message", " "),
        ("path", "../x"),
    ],
)
def test_diagnostics_remain_typed_actionable_records(field: str, value: object) -> None:
    """A malformed diagnostic cannot hide an omitted or unreadable input."""
    inventory = load_fixture("inventory-snapshot")
    _first(inventory, "diagnostics")[field] = value

    assert schema_errors("inventory-snapshot", inventory)


def test_duplicate_identical_input_records_are_rejected() -> None:
    """Exact duplicate paths/records fail structurally before keyed graph checks."""
    inventory = load_fixture("inventory-snapshot")
    inventory["files"] = [_first(inventory, "files")] * 2

    assert schema_errors("inventory-snapshot", inventory)
