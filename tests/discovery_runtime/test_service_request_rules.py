"""Verify the finite 30-operation request contract without executing handlers."""

from __future__ import annotations

from dataclasses import FrozenInstanceError
from typing import TYPE_CHECKING, cast, get_args

import pytest
from drm_copilot_discovery.models import JsonObject, ParseLimits
from drm_copilot_discovery.report_models import bounded_object
from drm_copilot_discovery.service_contracts import (
    Operation,
    ServiceRequestError,
    parse_service_request,
)

from tests.discovery_runtime.test_snapshot_io import (
    snapshot_catalog as snapshot_catalog,
)
from tests.schemas.discovery.v2_control_test_support import control_fixture

if TYPE_CHECKING:
    from drm_copilot_discovery.catalog import SchemaCatalog
    from drm_copilot_discovery.service_contracts import ServiceRequest


_REQUIRED: dict[str, dict[str, object]] = {
    "init": {
        "system_id": "system",
        "system_name": "System",
        "system_role": "legacy-source",
        "repository_id": "source",
        "draft": True,
    },
    "configure": {"configuration_action": "deactivate"},
    "new-contract": {"feature_id": "feature", "name": "Feature"},
    "new-scenario": {
        "scenario_id": "scenario",
        "feature_ids": ["feature"],
        "input_path": "input.json",
    },
    "update-artifact": {
        "artifact_kind": "feature-contract",
        "artifact_path": "feature.json",
        "input_path": "input.json",
        "expected_sha256": "a" * 64,
        "update_action": "replace",
    },
    "link-evidence": {
        "artifact_kind": "feature-contract",
        "artifact_id": "feature",
        "evidence_path": "evidence.json",
        "expected_sha256": "a" * 64,
    },
    "generate-acceptance": {"acceptance_kind": "legacy-characterization"},
    "snapshot-export": {"selected_ids": ["feature"]},
    "snapshot-import": {"manifest_path": "manifest.json"},
    "import-inventory": {"manifest_path": "manifest.json"},
    "migrate": {
        "from_version": 1,
        "to_version": 2,
        "destination": "converted",
        "system_id": "system",
        "system_name": "System",
        "system_role": "legacy-source",
        "repository_id": "source",
        "input_path": "legacy.json",
    },
    "read-source": {"read_operation": "read", "paths": ["src/a.py"]},
    "prepare-agent": {
        "skill_id": "validate-discovery-artifacts",
        "selected_ids": ["feature"],
        "paths": ["feature.json"],
        "expected_outputs": [
            {
                "artifact_kind": "feature-contract",
                "id": "feature",
                "path": "feature.json",
                "format": "json",
                "expected_sha256": None,
            }
        ],
        "execution_context": "standalone",
        "complexity": "C1",
    },
}


def request_document(operation: str = "validate-all") -> dict[str, object]:
    """Return a fresh schema-shaped request for operation (str), without I/O.

    Fixed operation inputs are declared independently of production tables.
    Unexpected invalid fixtures propagate at the public parser boundary.
    """
    value = control_fixture("service-request")
    inputs = dict(_REQUIRED.get(operation, {}))
    if operation.startswith("validate-") and operation not in (
        "validate-all",
        "validate-profile",
        "validate-decisions",
    ):
        inputs = {"artifact_path": "artifact.json"}
    value.update(
        operation=operation, dry_run=False, write=False, format="json", inputs=inputs
    )
    if operation == "finalize-agent":
        value.update(mode="agent-output", invocation_ref="protected-alpha-00000001")
    return value


def parsed(value: dict[str, object], catalog: SchemaCatalog) -> ServiceRequest:
    """Parse local dict through bounded JsonObject and catalog; return request.

    Raises the public typed parser error for invalid input. No I/O occurs.
    """
    return parse_service_request(
        bounded_object(value, limits=ParseLimits()),
        catalog=catalog,
        limits=ParseLimits(),
    )


@pytest.mark.parametrize("operation", get_args(Operation))
def test_all_fixed_operations_parse_without_dispatch(
    operation: str, snapshot_catalog: SchemaCatalog
) -> None:
    """Parse each operation (str) with SchemaCatalog; return None, execute nothing."""
    request = parsed(request_document(operation), snapshot_catalog)
    assert request.operation == operation
    assert isinstance(request.inputs, JsonObject)
    with pytest.raises(FrozenInstanceError):
        request.__setattr__("id", "changed")


@pytest.mark.parametrize(
    "field,value",
    [
        ("operation", "secret-command"),
        ("mode", "secret-mode"),
        ("inputs", {"shell": "secret-token"}),
        ("dry_run", 1),
        ("id", "../secret"),
    ],
)
def test_invalid_requests_retain_only_recognized_context(
    snapshot_catalog: SchemaCatalog,
    field: str,
    value: object,
) -> None:
    """Reject field/value with fixed findings; return None without source leakage.

    catalog is SchemaCatalog, field is str and value is a local invalid object.
    """
    document = request_document()
    document[field] = value
    with pytest.raises(ServiceRequestError) as caught:
        parsed(document, snapshot_catalog)
    assert caught.value.operation == (None if field == "operation" else "validate-all")
    assert caught.value.mode == (None if field == "mode" else "structural")
    assert "secret" not in str(caught.value)
    assert caught.value.findings[0].pointer


@pytest.mark.parametrize(
    "operation,inputs",
    [
        ("init", {"draft": False}),
        ("configure", {"configuration_action": "activate"}),
        ("configure", {"input_path": "profile.json"}),
        ("new-scenario", {"feature_ids": []}),
        ("snapshot-export", {"selected_ids": []}),
        ("inventory", {"analyzer_ids": []}),
        ("update-artifact", {"update_action": "approve-decision"}),
        ("update-artifact", {"approval_owner": "owner"}),
        ("read-source", {"read_operation": "search"}),
        ("read-source", {"query": "text"}),
        ("read-source", {"read_operation": "list", "line_start": 1}),
        ("read-source", {"line_start": 3, "line_end": 2}),
        ("profile", {"input_path": "other.json"}),
        ("new-contract", {"name": None}),
        ("migrate", {"input_path": None}),
        ("migrate", {"paths": ["legacy.json"]}),
        ("link-evidence", {"expected_sha256": None}),
        (
            "update-artifact",
            {
                "update_action": "approve-decision",
                "artifact_id": "feature",
                "approval_owner": "owner",
                "approval_evidence_refs": [
                    {"artifact_kind": "evidence-reference", "id": "proof"}
                ],
            },
        ),
    ],
)
def test_operation_conditions_fail_before_any_service_io(
    snapshot_catalog: SchemaCatalog,
    operation: str,
    inputs: dict[str, object],
) -> None:
    """Reject one conditional input mutation; return None with no providers.

    catalog/operation/inputs are SchemaCatalog/str/local dict. Errors are typed.
    """
    document = request_document(operation)
    original = cast("dict[str, object]", document["inputs"])
    original.update(inputs)
    if operation == "configure" and inputs.get("configuration_action") == "activate":
        document["profile_path"] = None
    with pytest.raises(ServiceRequestError):
        parsed(document, snapshot_catalog)


@pytest.mark.parametrize(
    "field", ["system_id", "system_name", "system_role", "repository_id"]
)
def test_migration_requires_complete_initialization_identity(
    snapshot_catalog: SchemaCatalog, field: str
) -> None:
    """Reject a missing migration identity field before I/O; return None.

    snapshot_catalog is the trusted SchemaCatalog and field is one required str
    key. The local dict is mutated; ServiceRequestError is asserted, not leaked.
    """
    document = request_document("migrate")
    del cast("dict[str, object]", document["inputs"])[field]
    with pytest.raises(ServiceRequestError):
        parsed(document, snapshot_catalog)


@pytest.mark.parametrize(
    "operation,field,value",
    [
        ("doctor", "write", True),
        ("doctor", "dry_run", True),
        ("doctor", "format", "markdown"),
        ("profile", "mode", "planning"),
        ("completion-report", "mode", "agent-output"),
        ("inventory", "mode", "planning"),
    ],
)
def test_modes_flags_and_format_cannot_be_silently_ignored(
    snapshot_catalog: SchemaCatalog,
    operation: str,
    field: str,
    value: object,
) -> None:
    """Reject incompatible typed request flags; return None without execution."""
    document = request_document(operation)
    document[field] = value
    document["invocation_ref"] = "protected-alpha-00000001"
    with pytest.raises(ServiceRequestError):
        parsed(document, snapshot_catalog)


def test_valid_conditional_controls_and_role_context(
    snapshot_catalog: SchemaCatalog,
) -> None:
    """Accept explicit conditions and planning flags with SchemaCatalog; return None.

    Uses local request values only; accepted data still has no host authority.
    """
    requests = [
        ("init", {"draft": False, "production_roots": ["src"]}),
        (
            "configure",
            {"configuration_action": "activate", "input_path": "profile.json"},
        ),
        ("profile", {"input_path": "docs/migration/discovery/domain-profile.yaml"}),
        ("inventory", {"analyzer_ids": ["repository"]}),
        (
            "update-artifact",
            {
                "update_action": "approve-decision",
                "artifact_kind": "product-decision",
                "artifact_id": "decision",
                "approval_owner": "owner",
                "approval_evidence_refs": [
                    {"artifact_kind": "evidence-reference", "id": "proof"}
                ],
            },
        ),
        (
            "read-source",
            {"read_operation": "search", "query": "literal", "regex": False},
        ),
        ("read-source", {"line_start": 2, "line_end": 3}),
    ]
    # Independent valid controls ensure rejection tests do not ban the operation.
    for operation, inputs in requests:
        document = request_document(operation)
        cast("dict[str, object]", document["inputs"]).update(inputs)
        assert parsed(document, snapshot_catalog).operation == operation
    document = request_document("inventory")
    document.update(
        mode="agent-output",
        invocation_ref="protected-alpha-00000001",
        dry_run=True,
        write=True,
    )
    assert parsed(document, snapshot_catalog).mode == "agent-output"
    document = request_document("migrate")
    inputs = cast("dict[str, object]", document["inputs"])
    del inputs["input_path"]
    inputs["paths"] = ["legacy.json"]
    assert parsed(document, snapshot_catalog).operation == "migrate"
