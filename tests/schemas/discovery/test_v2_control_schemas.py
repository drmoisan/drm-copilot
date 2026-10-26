"""Verify versioned wire envelopes and safe request/result interoperability."""

from __future__ import annotations

from copy import deepcopy
from typing import cast

import pytest
from drm_copilot_discovery.resources import read_resource
from jsonschema import Draft202012Validator

from scripts.dev_tools.build_discovery_runtime import verify_schema_closure
from tests.schemas.discovery.v2_control_test_support import (
    CONTROL_KINDS,
    OPAQUE_REFERENCE,
    control_fixture,
    finding,
    required_output,
)
from tests.schemas.discovery.v2_schema_test_support import (
    SCHEMAS,
    URN,
    as_object,
    load_fixture,
    load_schema,
    schema_errors,
)


@pytest.mark.parametrize("kind", CONTROL_KINDS)
def test_control_schemas_are_closed_valid_and_packaged(kind: str) -> None:
    """Every envelope resolves to an exact offline version and packaged byte copy."""
    schema = load_schema(kind)

    Draft202012Validator.check_schema(schema)

    assert schema["$id"] == URN + kind
    assert schema["additionalProperties"] is False
    assert (
        read_resource(f"schemas/discovery/v2/{kind}.schema.json")
        == (SCHEMAS / f"{kind}.schema.json").read_bytes()
    )


def test_control_definitions_have_complete_offline_reference_closure() -> None:
    """Shared control types cannot silently fall back to remote schema resolution."""
    inputs = {
        f"schemas/discovery/v2/{path.name}": path.read_bytes()
        for path in SCHEMAS.glob("*.schema.json")
    }

    verify_schema_closure(inputs)

    assert all(
        f"schemas/discovery/v2/{kind}.schema.json" in inputs for kind in CONTROL_KINDS
    )


@pytest.mark.parametrize("kind", CONTROL_KINDS)
def test_fresh_control_fixtures_validate_without_becoming_authority(kind: str) -> None:
    """Schema conformance preserves data and does not access protected host state."""
    document = control_fixture(kind)
    original = deepcopy(document)

    errors = schema_errors(kind, document)

    assert errors == [], [error.message for error in errors]
    assert document == original


@pytest.mark.parametrize("kind", CONTROL_KINDS)
def test_control_versions_are_exact_and_required(kind: str) -> None:
    """No v1 or future wire version can bypass the expected-kind catalog entry."""
    document = control_fixture(kind)
    field = "result_version" if kind == "service-result" else "schema_version"
    document[field] = "2.1.0"
    assert schema_errors(kind, document)
    del document[field]

    assert schema_errors(kind, document)


@pytest.mark.parametrize("kind", CONTROL_KINDS)
@pytest.mark.parametrize(
    "field", ("executable", "command", "receipt_path", "authority_root")
)
def test_control_core_rejects_execution_and_authority_destinations(
    kind: str,
    field: str,
) -> None:
    """Control records cannot select a program or redirect protected-store writes."""
    document = control_fixture(kind)
    document[field] = "untrusted/location"

    assert schema_errors(kind, document)


@pytest.mark.parametrize("kind", ("activation", "service-result"))
@pytest.mark.parametrize("field", ("$schema", "artifact_kind", "id"))
def test_explicit_wire_shapes_do_not_accept_extra_artifact_headers(
    kind: str,
    field: str,
) -> None:
    """Specific locator/result wire formats retain their exact declared keys."""
    document = control_fixture(kind)
    document[field] = "unexpected"

    assert schema_errors(kind, document)


@pytest.mark.parametrize(
    "field,value",
    [
        ("enabled", False),
        ("enabled", 1),
        ("required_runtime_major", 1),
        ("profile_path", "../profile.yaml"),
        ("profile_path", "C:/profile.yaml"),
    ],
)
def test_activation_cannot_disable_protected_enforcement(
    field: str, value: object
) -> None:
    """Only the explicit root deactivation workflow can retire protected activation."""
    document = control_fixture("activation")
    document[field] = value

    assert schema_errors("activation", document)


@pytest.mark.parametrize(
    "field",
    (
        "request_id operation mode workspace_root profile_path "
        "dry_run write format inputs "
        "invocation_ref authorization_ref"
    ).split(),
)
def test_service_request_requires_explicit_correlation_and_flags(field: str) -> None:
    """Missing context cannot supply implicit identity or invocation defaults."""
    document = control_fixture("service-request")
    del document[field]

    assert schema_errors("service-request", document)


@pytest.mark.parametrize(
    "field,value",
    [
        ("operation", "exec"),
        ("operation", "validate"),
        ("mode", "complete"),
        ("format", "xml"),
        ("dry_run", "false"),
        ("write", 1),
        ("request_id", "request-alpha\n"),
        ("role", "native-root"),
        ("principal", {"kind": "native-root"}),
        ("authorization_ref", "../receipt.json"),
    ],
)
def test_request_values_cannot_choose_authority_or_unknown_dispatch(
    field: str,
    value: object,
) -> None:
    """Aliases normalize before transport; caller tokens do not grant permission."""
    document = control_fixture("service-request")
    document[field] = value

    assert schema_errors("service-request", document)


@pytest.mark.parametrize(
    "root",
    (
        ".",
        "/workspace/example",
        "C:/workspace/example",
        "C:\\workspace\\example",
        "\\\\server\\share\\example",
    ),
)
def test_outer_workspace_boundary_supports_cross_platform_explicit_roots(
    root: str,
) -> None:
    """Outer roots are explicit; runtime canonicalization is a separate check."""
    document = control_fixture("service-request")
    document["workspace_root"] = root

    assert schema_errors("service-request", document) == []


@pytest.mark.parametrize(
    "root", ("neighbor", "../neighbor", "C:relative", "/workspace\n")
)
def test_outer_workspace_does_not_search_relative_neighbors(root: str) -> None:
    """Only an absolute root or explicit current-directory boundary is accepted."""
    document = control_fixture("service-request")
    document["workspace_root"] = root

    assert schema_errors("service-request", document)


@pytest.mark.parametrize("supplied_roots", (False, True))
@pytest.mark.parametrize("draft", (False, True))
def test_only_explicit_draft_init_allows_unknown_production_roots(
    supplied_roots: bool,
    draft: bool,
) -> None:
    """Draft bootstrap permits unknown roots without claiming configured readiness."""
    document = control_fixture("service-request")
    inputs: dict[str, object] = {
        "system_id": "system-alpha",
        "system_name": "Synthetic System",
        "system_role": "legacy-source",
        "repository_id": "source-alpha",
        "draft": draft,
    }
    if supplied_roots:
        inputs["production_roots"] = []
    document.update(operation="init", inputs=inputs)
    assert bool(schema_errors("service-request", document)) is not draft
    inputs["production_roots"] = ["src"]

    assert schema_errors("service-request", document) == []


def test_omitted_draft_flag_does_not_relax_init_roots() -> None:
    """Missing draft intent cannot silently initialize an unconfigured workspace."""
    document = control_fixture("service-request")
    document.update(
        operation="init",
        inputs={
            "system_id": "system-alpha",
            "system_name": "Synthetic System",
            "system_role": "legacy-source",
            "repository_id": "source-alpha",
        },
    )

    assert schema_errors("service-request", document)


@pytest.mark.parametrize(
    "field,value",
    [
        ("input_path", "../input.json"),
        ("destination", "C:/other"),
        ("output_prefix", "/reports"),
        ("executable", "python"),
        ("receipt_path", "reports/success.json"),
        ("max_bytes", 16777217),
        ("from_version", 0),
        ("to_version", 3),
    ],
)
def test_nested_inputs_are_closed_relative_and_bounded(
    field: str, value: object
) -> None:
    """Structured request inputs cannot bypass path, version or read-size boundaries."""
    document = control_fixture("service-request")
    as_object(document["inputs"])[field] = value

    assert schema_errors("service-request", document)


def test_prepare_and_finalize_require_explicit_scoped_invocation_data() -> None:
    """Preparation names outputs; finalization identifies an existing invocation."""
    document = control_fixture("service-request")
    document["operation"] = "prepare-agent"
    assert schema_errors("service-request", document)
    document["inputs"] = {
        "skill_id": "inventory-legacy-system",
        "selected_ids": [],
        "paths": ["src"],
        "expected_outputs": [required_output()],
        "execution_context": "standalone",
        "complexity": "C4",
    }
    assert schema_errors("service-request", document) == []
    document.update(operation="finalize-agent", inputs={}, mode="agent-output")
    assert schema_errors("service-request", document)
    document["invocation_ref"] = OPAQUE_REFERENCE

    assert schema_errors("service-request", document) == []


def test_start_attestation_example_validates_and_invalid_fixture_is_rejected() -> None:
    """The committed example matches the native writer; the invalid fixture does not."""
    assert schema_errors("start-attestation", load_fixture("start-attestation")) == []

    errors = schema_errors(
        "start-attestation", load_fixture("start-attestation", invalid=True)
    )

    assert errors
    messages = " ".join(error.message for error in errors)
    assert "agent_profile" in messages and "SubagentStart" in messages


@pytest.mark.parametrize(
    "field,value",
    [
        (
            "writer",
            {"host": "codex", "event": "PreToolUse", "handler_sha256": "c" * 64},
        ),
        ("start_attestation_ref", "short"),
        ("agent_id", None),
        ("role", "native-root"),
        ("deployment", {"agent_name": "x", "model": "m", "reasoning_effort": "max"}),
        ("agent_profile", {"path": "../profile.md", "sha256": "c" * 64, "name": "x"}),
        ("runtime", None),
    ],
)
def test_start_attestation_binds_identity_deployment_and_writer(
    field: str, value: object
) -> None:
    """Only a SubagentStart writer with complete identity and runtime validates."""
    document = control_fixture("start-attestation")
    document[field] = value

    assert schema_errors("start-attestation", document)


def test_start_attestation_actual_model_and_effort_may_be_observed_or_null() -> None:
    """Hosts that expose the started model record it; others record null."""
    document = control_fixture("start-attestation")
    deployment = as_object(document["deployment"])
    assert schema_errors("start-attestation", document) == []
    deployment["actual_model"] = "model-alpha"
    deployment["actual_effort"] = "max"

    assert schema_errors("start-attestation", document) == []


@pytest.mark.parametrize("code", (1, 2, 3))
def test_blocking_results_require_consistent_exit_and_actionable_error(
    code: int,
) -> None:
    """Artifact, invocation and runtime failures cannot be transported as success."""
    document = control_fixture("service-result")
    document.update(ok=False, exit_code=code)
    assert schema_errors("service-result", document)
    document["findings"] = [finding()]
    assert schema_errors("service-result", document) == []
    document["ok"] = True

    assert schema_errors("service-result", document)


@pytest.mark.parametrize(
    "field,value",
    [
        ("exit_code", 4),
        ("exit_code", True),
        ("ok", False),
        ("findings", [finding()]),
        ("runtime", None),
    ],
)
def test_result_envelope_rejects_ambiguous_success_fields(
    field: str, value: object
) -> None:
    """The wrapper can validate exact result shape before consuming any output paths."""
    document = control_fixture("service-result")
    document[field] = value

    assert schema_errors("service-result", document)


@pytest.mark.parametrize(
    "field,value",
    [
        ("code", "free prose"),
        ("severity", "fatal"),
        ("pointer", "profile_state"),
        ("pointer", "/bad~escape"),
        ("next_action", " "),
        ("artifact_path", "../x"),
    ],
)
def test_findings_preserve_machine_fields_and_actionable_locations(
    field: str,
    value: object,
) -> None:
    """Finding codes, RFC 6901 pointers and next actions remain structured."""
    document = control_fixture("service-result")
    problem = finding()
    document.update(ok=False, exit_code=1, findings=[problem])
    problem[field] = value

    assert schema_errors("service-result", document)


@pytest.mark.parametrize("pointer", ("", "/", "/extensions/example.org/a~1b/~0key"))
def test_findings_accept_valid_root_and_escaped_json_pointers(pointer: str) -> None:
    """Valid pointer tokens can locate root failures and escaped extension keys."""
    document = control_fixture("service-result")
    problem = finding()
    problem["pointer"] = pointer
    document.update(ok=False, exit_code=1, findings=[problem])

    assert schema_errors("service-result", document) == []


def test_dry_run_results_can_return_projected_content_with_exact_digest() -> None:
    """Agents consume typed planned artifacts without parsing a human summary."""
    document = control_fixture("service-result")
    document["artifacts"] = [
        {
            "path": "reports/validation.json",
            "kind": "validation-report",
            "status": "planned",
            "sha256": "a" * 64,
            "content": "{}",
        }
    ]
    assert schema_errors("service-result", document) == []
    artifact = as_object(cast("list[object]", document["artifacts"])[0])
    artifact["status"] = "conflict"

    assert schema_errors("service-result", document)


def test_report_failure_is_distinct_from_valid_report_generation() -> None:
    """Valid report generation can describe failed completion."""
    document = control_fixture("service-result")
    document["operation"] = "completion-report"
    as_object(document["summary"])["validation_result"] = "fail"

    assert schema_errors("service-result", document) == []


def test_migration_retains_exact_mapping_and_unmapped_metadata() -> None:
    """Migration preserves old identity and unmapped values explicitly."""
    document = control_fixture("migration-report")
    document["unmapped_metadata"] = [
        {
            "old_path": "discovery/feature.json",
            "pointer": "/custom~1metadata",
            "value": {"old": [1, None]},
            "reason": "No core v2 equivalent exists.",
        }
    ]
    assert schema_errors("migration-report", document) == []
    mapping = as_object(cast("list[object]", document["mappings"])[0])
    mapping["new_path"] = "../overwrite.json"

    assert schema_errors("migration-report", document)


@pytest.mark.parametrize(
    "field,value",
    [
        ("from_version", 2),
        ("to_version", 3),
        ("activation_switched", True),
        ("migration_extension", "unnamespaced"),
        ("result", "verified"),
    ],
)
def test_migration_cannot_activate_or_fabricate_verification(
    field: str, value: object
) -> None:
    """Migration reports remain explicit version mappings without approval authority."""
    document = control_fixture("migration-report")
    document[field] = value

    assert schema_errors("migration-report", document)


def test_dry_run_migration_cannot_claim_created_files() -> None:
    """A projected migration cannot assert writes that never occurred."""
    document = control_fixture("migration-report")
    as_object(cast("list[object]", document["mappings"])[0])["status"] = "created"
    assert schema_errors("migration-report", document)
    document["dry_run"] = False

    assert schema_errors("migration-report", document) == []
