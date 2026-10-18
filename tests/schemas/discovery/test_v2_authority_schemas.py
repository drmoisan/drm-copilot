"""Validate control-record bindings without treating their shape as authority."""

from __future__ import annotations

from typing import cast

import pytest

from tests.schemas.discovery.v2_control_test_support import (
    OPAQUE_REFERENCE,
    STAMP,
    agent_receipt,
    control_fixture,
    finding,
)
from tests.schemas.discovery.v2_schema_test_support import as_object, schema_errors

BOUND_KINDS = (
    "discovery-invocation",
    "required-output-manifest",
    "validation-receipt",
    "capability-attestation",
    "tool-authorization",
)
ROLES = (
    "legacy-parity-analyst",
    "runtime-characterization-analyst",
    "requirements-reconciler",
    "migration-coverage-reviewer",
)


@pytest.mark.parametrize("kind", BOUND_KINDS)
@pytest.mark.parametrize(
    "field", ("workspace_root", "workspace_sha256", "profile_path", "profile_sha256")
)
def test_authority_documents_require_exact_workspace_and_profile_fields(
    kind: str,
    field: str,
) -> None:
    """Records require the workspace and configuration identities they bind."""
    document = control_fixture(kind)
    del as_object(document["workspace"])[field]

    assert schema_errors(kind, document)


@pytest.mark.parametrize("kind", BOUND_KINDS)
@pytest.mark.parametrize(
    "field,value",
    [
        ("workspace_root", "."),
        ("workspace_sha256", "a" * 64 + "\n"),
        ("profile_path", "../profile.yaml"),
        ("profile_sha256", "unknown"),
    ],
)
def test_authority_binding_is_absolute_and_content_addressed(
    kind: str,
    field: str,
    value: object,
) -> None:
    """Protected bindings cannot depend on cwd or a mutable profile description."""
    document = control_fixture(kind)
    as_object(document["workspace"])[field] = value

    assert schema_errors(kind, document)


@pytest.mark.parametrize(
    "field",
    (
        "invocation_id host session_id parent_agent_id agent_id role "
        "skill_id operation gate_mode selected_ids selected_paths scope_sha256 "
        "input_sha256 runtime deployment "
        "required_outputs capability_ref topology_receipt_ref model_receipt_ref "
        "production_write_count state created_at "
        "start_attestation_ref completion_receipt_ref"
    ).split(),
)
def test_invocation_requires_scope_routing_and_lifecycle_bindings(field: str) -> None:
    """A diagnostic mirror cannot omit the exact protected launch/output contract."""
    document = control_fixture("discovery-invocation")
    del document[field]

    assert schema_errors("discovery-invocation", document)


def test_invocation_start_and_finalization_require_distinct_receipts() -> None:
    """Preparation, native start and output completion require separate evidence."""
    document = control_fixture("discovery-invocation")
    document["state"] = "started"
    assert schema_errors("discovery-invocation", document)
    document.update(agent_id="agent-alpha", start_attestation_ref=OPAQUE_REFERENCE)
    assert schema_errors("discovery-invocation", document) == []
    document["state"] = "finalized"
    assert schema_errors("discovery-invocation", document)
    document["completion_receipt_ref"] = OPAQUE_REFERENCE

    assert schema_errors("discovery-invocation", document) == []


@pytest.mark.parametrize(
    "field,value",
    [
        ("production_write_count", 1),
        ("agent_id", "agent-before-launch"),
        ("start_attestation_ref", OPAQUE_REFERENCE),
        ("completion_receipt_ref", OPAQUE_REFERENCE),
        ("model_receipt_ref", "reports/model.json"),
        ("role", "orchestrator"),
        ("skill_id", "run-arbitrary-task"),
    ],
)
def test_prepared_invocations_cannot_self_attest_or_expand_scope(
    field: str,
    value: object,
) -> None:
    """Zero-code-write preparation retains separate start and completion authority."""
    document = control_fixture("discovery-invocation")
    document[field] = value

    assert schema_errors("discovery-invocation", document)


@pytest.mark.parametrize(
    "field,value",
    [
        ("profile_sha256", "a" * 64 + "\n"),
        ("profile_path", "../agent.toml"),
        ("reasoning_effort", "automatic"),
        ("complexity", "C5"),
        ("model", " "),
        ("execution_context", "nested-discovery"),
        ("fallback_model", "other"),
    ],
)
def test_deployment_retains_exact_profile_and_rejects_fallback_inputs(
    field: str,
    value: object,
) -> None:
    """Malformed profile metadata fails before later equality attestation."""
    document = control_fixture("discovery-invocation")
    as_object(document["deployment"])[field] = value

    assert schema_errors("discovery-invocation", document)


@pytest.mark.parametrize(
    "field", ("artifact_kind", "id", "path", "format", "expected_sha256")
)
def test_required_outputs_name_each_artifact_and_compare_and_swap_state(
    field: str,
) -> None:
    """A broad root cannot replace an exact output identity and expected byte digest."""
    document = control_fixture("required-output-manifest")
    output = as_object(cast("list[object]", document["outputs"])[0])
    del output[field]

    assert schema_errors("required-output-manifest", document)


def test_required_outputs_allow_new_artifacts_but_not_empty_output_contracts() -> None:
    """Creation uses a null expected digest while retaining exact output scope."""
    document = control_fixture("required-output-manifest")
    output = as_object(cast("list[object]", document["outputs"])[0])
    output["expected_sha256"] = None
    assert schema_errors("required-output-manifest", document) == []
    document["outputs"] = []

    assert schema_errors("required-output-manifest", document)


@pytest.mark.parametrize(
    "field",
    ("kind", "host", "session_id", "agent_id", "request_id", "role", "invocation_id"),
)
def test_root_receipts_require_unambiguous_native_attribution(field: str) -> None:
    """Missing identity never defaults to a trusted root principal."""
    document = control_fixture("validation-receipt")
    del as_object(document["identity"])[field]

    assert schema_errors("validation-receipt", document)


@pytest.mark.parametrize(
    "kind", (None, "local-user", "root", "", ["native-root", "discovery-agent"])
)
def test_receipt_principal_cannot_be_local_cli_or_ambiguous(kind: object) -> None:
    """Only an exact protected native principal kind can describe a native receipt."""
    document = control_fixture("validation-receipt")
    as_object(document["identity"])["kind"] = kind

    assert schema_errors("validation-receipt", document)


@pytest.mark.parametrize("role", ROLES)
def test_each_analyst_stop_receipt_requires_its_role_and_output_manifest(
    role: str,
) -> None:
    """Every specialist has a strict invocation/output receipt shape."""
    document = agent_receipt()
    as_object(document["identity"])["role"] = role
    as_object(document["required_outputs"])["role"] = role
    assert schema_errors("validation-receipt", document) == []
    document["required_outputs"] = None

    assert schema_errors("validation-receipt", document)


@pytest.mark.parametrize("field", ("role", "invocation_id"))
def test_analyst_identity_cannot_omit_its_exact_role_or_invocation(field: str) -> None:
    """Analyst attribution cannot degrade into an unspecified root identity."""
    document = agent_receipt()
    as_object(document["identity"])[field] = None

    assert schema_errors("validation-receipt", document)


def test_root_planning_receipt_cannot_be_reused_as_an_analyst_stop_receipt() -> None:
    """Root validation has no fabricated analyst invocation or output-valid flag."""
    document = control_fixture("validation-receipt")
    assert schema_errors("validation-receipt", document) == []
    document["mode"] = "agent-output"

    assert schema_errors("validation-receipt", document)


@pytest.mark.parametrize(
    "mode", ("structural", "planning", "discovery-complete", "parity-complete")
)
def test_analyst_output_receipt_cannot_authorize_a_different_gate(mode: str) -> None:
    """An output-valid task receipt cannot satisfy planning or completion authority."""
    document = agent_receipt()
    document["mode"] = mode

    assert schema_errors("validation-receipt", document)


def test_valid_failing_reviewer_output_remains_distinct_from_completion_pass() -> None:
    """A complete FAIL review can satisfy output shape without a completion pass."""
    document = agent_receipt()
    as_object(document["identity"])["role"] = "migration-coverage-reviewer"
    as_object(document["required_outputs"])["role"] = "migration-coverage-reviewer"
    document.update(validation_result="fail", findings=[finding()])

    assert schema_errors("validation-receipt", document) == []
    assert document["output_valid"] is True
    assert document["validation_result"] == "fail"


def test_invalid_analyst_output_cannot_claim_success() -> None:
    """Malformed task output cannot carry a passing validation-result claim."""
    document = agent_receipt()
    document["output_valid"] = False

    assert schema_errors("validation-receipt", document)


@pytest.mark.parametrize(
    "field,value",
    [
        ("package_version", "1.0.0"),
        ("schema_version", "2.1.0"),
        ("build_sha256", "latest"),
        ("policy_version", "1"),
        ("policy_sha256", "unknown"),
    ],
)
def test_receipt_versions_and_hashes_cannot_be_weak_descriptions(
    field: str, value: object
) -> None:
    """Runtime/schema versions are exact; policy identity is typed and hashed."""
    document = control_fixture("validation-receipt")
    as_object(document["runtime"])[field] = value

    assert schema_errors("validation-receipt", document)


@pytest.mark.parametrize(
    "field",
    (
        "activation_sha256",
        "input_manifest",
        "runtime",
        "writer",
        "receipt_ref",
        "issued_at",
    ),
)
def test_receipt_requires_freshness_and_trusted_writer_metadata(field: str) -> None:
    """Input/activation/build/writer binding cannot be omitted from a gate record."""
    document = control_fixture("validation-receipt")
    del document[field]

    assert schema_errors("validation-receipt", document)


@pytest.mark.parametrize(
    "field",
    (
        "workspace_trusted",
        "hooks_enabled",
        "trusted_attribution",
        "start_event",
        "tool_event",
        "stop_event",
        "forbidden_tools_denied",
    ),
)
def test_supported_capability_requires_every_native_control(field: str) -> None:
    """A single disabled control prevents the supported-host claim."""
    document = control_fixture("capability-attestation")
    as_object(document["controls"])[field] = False

    assert schema_errors("capability-attestation", document)


@pytest.mark.parametrize("event", ("start", "tool", "stop"))
def test_supported_capability_names_every_registered_event(event: str) -> None:
    """Three unrelated handler records cannot substitute for required native events."""
    document = control_fixture("capability-attestation")
    handlers = [as_object(item) for item in cast("list[object]", document["handlers"])]
    for handler in handlers:
        if handler["event"] == event:
            handler["event"] = "tool" if event != "tool" else "start"

    assert schema_errors("capability-attestation", document)


def test_unsupported_host_can_report_missing_handlers_and_unavailable_probe() -> None:
    """Fail-closed capability reporting does not fabricate native evidence."""
    document = control_fixture("capability-attestation")
    document.update(status="unsupported", handlers=[], findings=[finding()])
    as_object(document["probe"]).update(result="unavailable", evidence_ref=None)
    assert schema_errors("capability-attestation", document) == []
    document["status"] = "supported"

    assert schema_errors("capability-attestation", document)


@pytest.mark.parametrize(
    "field",
    (
        "request_id",
        "input_sha256",
        "identity",
        "invocation_ref",
        "start_attestation_ref",
        "capability_ref",
        "issued_at",
        "expires_at",
        "writer",
    ),
)
def test_tool_authorization_requires_correlation_and_native_start_binding(
    field: str,
) -> None:
    """A one-use authorization cannot be detached from its exact request and session."""
    document = control_fixture("tool-authorization")
    del document[field]

    assert schema_errors("tool-authorization", document)


@pytest.mark.parametrize(
    "field,value",
    [
        ("tool", "exec_command"),
        ("operation", "configure"),
        ("operation", "migrate"),
        ("input_sha256", "a" * 64 + "\n"),
        ("request_id", "request\n"),
        ("expires_at", "2026-02-30T00:00:00Z"),
        ("authorization_ref", "C:/authority.json"),
    ],
)
def test_analyst_authorization_rejects_root_operations_and_malformed_binding(
    field: str,
    value: object,
) -> None:
    """Analyst records cannot select configuration or arbitrary execution."""
    document = control_fixture("tool-authorization")
    document[field] = value

    assert schema_errors("tool-authorization", document)


def test_tool_authorization_records_consumption_without_reissuing_it() -> None:
    """Consumption state remains explicit; the host separately enforces replay rules."""
    document = control_fixture("tool-authorization")
    document["state"] = "consumed"
    assert schema_errors("tool-authorization", document)
    document["consumed_at"] = STAMP
    assert schema_errors("tool-authorization", document) == []
    document["state"] = "issued"

    assert schema_errors("tool-authorization", document)
