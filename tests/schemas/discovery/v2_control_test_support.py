"""Construct fresh synthetic control records without protected-store I/O."""

from __future__ import annotations

from tests.schemas.discovery.v2_schema_test_support import HASH, PIN, URN

CONTROL_KINDS = (
    "activation",
    "service-request",
    "service-result",
    "discovery-invocation",
    "required-output-manifest",
    "validation-receipt",
    "migration-report",
    "capability-attestation",
    "tool-authorization",
    "start-attestation",
    "root-grant",
    "host-observation",
)
OPAQUE_REFERENCE = "protected-alpha-00000001"
START_ATTESTATION_REFERENCE = "start-0123456789abcdef0123"
PROFILE = "docs/migration/discovery/domain-profile.yaml"
STAMP = "2026-01-01T00:00:00Z"


def workspace_binding() -> dict[str, object]:
    """Describe an absolute synthetic workspace without resolving any directory."""
    return {
        "workspace_root": "/workspace/synthetic",
        "workspace_sha256": HASH,
        "profile_path": PROFILE,
        "profile_sha256": HASH,
    }


def runtime_binding() -> dict[str, object]:
    """Bind the runtime/schema major and the existing version-one routing policy."""
    return {
        "package_version": "2.0.0",
        "schema_version": "2.0.0",
        "build_sha256": HASH,
        "policy_version": 1,
        "policy_sha256": HASH,
    }


def native_identity() -> dict[str, object]:
    """Keep analyst attribution distinct from caller-selected operation data."""
    return {
        "host": "codex",
        "session_id": "session-alpha",
        "agent_id": "agent-alpha",
        "role": "legacy-parity-analyst",
        "invocation_id": "invocation-alpha",
    }


def finding() -> dict[str, object]:
    """Return a blocking finding with a concrete follow-up action and pointer."""
    return {
        "code": "DISCOVERY_INCOMPLETE",
        "severity": "error",
        "artifact_path": PROFILE,
        "pointer": "/profile_state",
        "related_ids": [],
        "related_paths": [],
        "message": "The discovery profile is still a draft.",
        "next_action": "Configure the local production roots and repository revision.",
    }


def input_manifest() -> dict[str, object]:
    """Record the bytes and revision identities required for later freshness checks."""
    return {
        "entries": [
            {"path": PROFILE, "sha256": HASH, "size": 10, "category": "profile"}
        ],
        "missing_paths": [],
        "source_repositories": [{"id": "source-alpha", "revision": PIN}],
        "target_repositories": [{"id": "target-alpha", "revision": "b" * 40}],
        "sha256": HASH,
    }


def required_output() -> dict[str, object]:
    """Select one exact artifact identity and path instead of a broad output root."""
    return {
        "artifact_kind": "coverage-ledger",
        "id": "coverage-alpha",
        "path": "docs/migration/discovery/coverage-ledger.json",
        "format": "json",
        "expected_sha256": HASH,
    }


def deployment() -> dict[str, object]:
    """Retain exact provider/model/profile metadata without authorizing a launch."""
    return {
        "provider": "codex",
        "agent_name": "legacy-parity-analyst-c4",
        "model": "model-alpha",
        "reasoning_effort": "max",
        "profile_path": ".codex/agents/legacy-parity-analyst-c4.toml",
        "profile_sha256": HASH,
        "complexity": "C4",
        "execution_context": "standalone",
    }


def _header(kind: str) -> dict[str, object]:
    """Use the artifact header only for control documents that declare it."""
    return {
        "$schema": URN + kind,
        "schema_version": "2.0.0",
        "artifact_kind": kind,
        "id": kind + "-alpha",
    }


def control_fixture(kind: str) -> dict[str, object]:
    """Build one structurally valid envelope; none is protected host authority."""
    if kind == "activation":
        return {
            "schema_version": "2.0.0",
            "enabled": True,
            "profile_path": PROFILE,
            "required_runtime_major": 2,
        }
    if kind == "service-result":
        return {
            "result_version": "2.0.0",
            "operation": "validate-all",
            "mode": "structural",
            "ok": True,
            "exit_code": 0,
            "findings": [],
            "artifacts": [],
            "summary": {
                "message": "Structural validation passed.",
                "counts": [],
                "validation_result": "pass",
                "receipt_ref": None,
                "invocation_ref": None,
            },
            "input_manifest": input_manifest(),
            "runtime": runtime_binding(),
        }
    document = _header(kind)
    if kind == "service-request":
        document.update(
            request_id="request-alpha",
            operation="validate-all",
            mode="structural",
            workspace_root=".",
            profile_path=PROFILE,
            dry_run=True,
            write=False,
            format="both",
            inputs={},
            invocation_ref=None,
            authorization_ref=None,
        )
    elif kind == "required-output-manifest":
        document.update(
            invocation_id="invocation-alpha",
            workspace=workspace_binding(),
            role="legacy-parity-analyst",
            outputs=[required_output()],
            manifest_sha256=HASH,
        )
    elif kind == "discovery-invocation":
        document.update(
            invocation_id="invocation-alpha",
            workspace=workspace_binding(),
            host="codex",
            session_id="session-alpha",
            parent_agent_id="root-alpha",
            agent_id=None,
            role="legacy-parity-analyst",
            skill_id="inventory-legacy-system",
            operation="inventory",
            gate_mode="agent-output",
            selected_ids=[],
            selected_paths=["src"],
            scope_sha256=HASH,
            input_sha256=HASH,
            runtime=runtime_binding(),
            deployment=deployment(),
            required_outputs=control_fixture("required-output-manifest"),
            capability_ref=OPAQUE_REFERENCE,
            topology_receipt_ref=OPAQUE_REFERENCE,
            model_receipt_ref=OPAQUE_REFERENCE,
            production_write_count=0,
            state="prepared",
            created_at=STAMP,
            start_attestation_ref=None,
            completion_receipt_ref=None,
        )
    elif kind == "start-attestation":
        document.update(
            start_attestation_ref=START_ATTESTATION_REFERENCE,
            invocation_ref="invocation-alpha",
            workspace=workspace_binding(),
            host="codex",
            session_id="session-alpha",
            parent_agent_id="root-alpha",
            agent_id="agent-alpha",
            agent_type="legacy-parity-analyst-c4",
            role="legacy-parity-analyst",
            deployment={
                "agent_name": "legacy-parity-analyst-c4",
                "model": "model-alpha",
                "reasoning_effort": "max",
                "actual_model": None,
                "actual_effort": None,
            },
            agent_profile={
                "path": ".codex/agents/legacy-parity-analyst-c4.toml",
                "sha256": HASH,
                "name": "legacy-parity-analyst-c4",
            },
            capability_ref=OPAQUE_REFERENCE,
            runtime=runtime_binding(),
            attested_at=STAMP,
            writer={"host": "codex", "event": "SubagentStart", "handler_sha256": HASH},
        )
    elif kind == "capability-attestation":
        document.update(
            attestation_ref=OPAQUE_REFERENCE,
            workspace=workspace_binding(),
            host="codex",
            session_id="session-alpha",
            runtime=runtime_binding(),
            configuration_sha256=HASH,
            handlers=[
                {"event": event, "path": f"hooks/{event}.ps1", "sha256": HASH}
                for event in ("start", "tool", "stop")
            ],
            controls={
                name: True
                for name in (
                    "workspace_trusted",
                    "hooks_enabled",
                    "trusted_attribution",
                    "start_event",
                    "tool_event",
                    "stop_event",
                    "forbidden_tools_denied",
                )
            },
            probe={
                "sentinel_id": "sentinel-alpha",
                "result": "denied",
                "evidence_ref": OPAQUE_REFERENCE,
            },
            status="supported",
            findings=[],
            observed_at=STAMP,
            expires_at="2026-01-01T01:00:00Z",
        )
    elif kind == "tool-authorization":
        document.update(
            authorization_ref=OPAQUE_REFERENCE,
            request_id="request-alpha",
            workspace=workspace_binding(),
            identity=native_identity(),
            tool="run_discovery_repo_inventory",
            operation="inventory",
            input_sha256=HASH,
            invocation_ref=OPAQUE_REFERENCE,
            start_attestation_ref=OPAQUE_REFERENCE,
            capability_ref=OPAQUE_REFERENCE,
            issued_at=STAMP,
            expires_at="2026-01-01T00:01:00Z",
            state="issued",
            consumed_at=None,
            writer={
                "kind": "native-pretooluse",
                "host": "codex",
                "event_id": "event-alpha",
                "handler_sha256": HASH,
            },
        )
    elif kind == "root-grant":
        document.update(
            grant_ref=OPAQUE_REFERENCE,
            host="codex",
            session_id="session-alpha",
            parent_agent_id="root",
            tool="prepare_discovery_agent",
            operation="prepare-agent",
            input_sha256=HASH,
            tool_use_id="tool-use-alpha",
            handler_sha256=HASH,
            issued_at=STAMP,
            expires_at="2026-01-01T00:05:00Z",
            state="issued",
        )
    elif kind == "host-observation":
        document.update(
            observation_ref=OPAQUE_REFERENCE,
            host="codex",
            session_id="session-alpha",
            agent_id="agent-sentinel",
            agent_type="discovery-capability-sentinel",
            parent_agent_id="root",
            tool_name="mcp__drm-copilot__discovery_capability_sentinel",
            tool_use_id_present=True,
            decision="allow",
            code="SENTINEL",
            handler_sha256=HASH,
            observed_at=STAMP,
            tool="discovery_capability_sentinel",
            input_sha256=HASH,
            expires_at="2026-01-01T00:05:00Z",
            state="issued",
        )
    elif kind == "validation-receipt":
        document.update(
            receipt_version="2.0.0",
            receipt_ref=OPAQUE_REFERENCE,
            workspace=workspace_binding(),
            activation_sha256=HASH,
            input_manifest=input_manifest(),
            runtime=runtime_binding(),
            mode="planning",
            identity={
                "kind": "native-root",
                "host": "codex",
                "session_id": "session-alpha",
                "agent_id": "root-alpha",
                "request_id": "request-alpha",
                "role": None,
                "invocation_id": None,
            },
            required_outputs=None,
            output_valid=None,
            validation_result="pass",
            findings=[],
            issued_at=STAMP,
            writer={
                "kind": "host-gateway",
                "component": "extension",
                "host": "codex",
                "id": "gateway-alpha",
                "build_sha256": HASH,
            },
        )
    elif kind == "migration-report":
        document.update(
            from_version=1,
            to_version=2,
            destination="docs/migration/new-discovery",
            source_manifest_sha256=HASH,
            dry_run=True,
            activation_switched=False,
            result="pass",
            mappings=[
                {
                    "old_path": "discovery/feature.json",
                    "old_sha256": HASH,
                    "old_id": "Feature-1",
                    "old_kind": "feature-contract",
                    "new_path": (
                        "docs/migration/new-discovery/"
                        "feature-contracts/feature-one.json"
                    ),
                    "new_sha256": HASH,
                    "new_id": "feature-one",
                    "new_kind": "feature-contract",
                    "status": "planned",
                }
            ],
            unresolved_behavior_refs=[],
            unmapped_metadata=[],
            migration_extension="drm-copilot.migration-v1",
            findings=[],
            extensions={},
        )
    else:
        raise ValueError(f"Unsupported test control fixture: {kind}")
    return document


def agent_receipt() -> dict[str, object]:
    """Bind a specialist stop receipt without allowing root planning reuse."""
    document = control_fixture("validation-receipt")
    document.update(
        mode="agent-output",
        output_valid=True,
        identity={
            "kind": "discovery-agent",
            "request_id": "request-alpha",
            **native_identity(),
        },
        required_outputs=control_fixture("required-output-manifest"),
    )
    return document
