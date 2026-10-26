"""Prove protected host records are schema-validated and bound before use."""

from __future__ import annotations

import json
from copy import deepcopy
from typing import TYPE_CHECKING, cast

import pytest
from drm_copilot_discovery.models import JsonObject, ParseLimits
from drm_copilot_discovery.operations import OperationFailure
from drm_copilot_discovery.protected_records import (
    TrustedIdentity,
    WorkspaceBinding,
    decode_authorization,
    decode_baseline_result,
    decode_capability_attestation,
    decode_invocation,
    decode_start_attestation,
)
from drm_copilot_discovery.service_contracts import RuntimeIdentity

from tests.discovery_runtime.test_service import (
    initialization_catalog as initialization_catalog,
)
from tests.schemas.discovery.v2_control_test_support import (
    OPAQUE_REFERENCE,
    PROFILE,
    START_ATTESTATION_REFERENCE,
    control_fixture,
)
from tests.schemas.discovery.v2_schema_test_support import HASH

if TYPE_CHECKING:
    from collections.abc import Callable

    from drm_copilot_discovery.catalog import SchemaCatalog

LIMITS = ParseLimits()
RUNTIME = RuntimeIdentity(
    package_version="2.0.0",
    schema_version="2.0.0",
    build_sha256=HASH,
    policy_version=1,
    policy_sha256=HASH,
)
BINDING = WorkspaceBinding(
    workspace_sha256=HASH, profile_path=PROFILE, profile_sha256=HASH
)
IDENTITY = TrustedIdentity(
    host="codex",
    session_id="session-alpha",
    agent_id="agent-alpha",
    role="legacy-parity-analyst",
    invocation_id="invocation-alpha",
)
OTHER_REFERENCE = "protected-beta-000000002"
OTHER_START = "start-0000000000000000000f"
Document = dict[str, object]


def error_finding(code: str) -> Document:
    """Return one blocking finding with code (str) for a synthetic record."""
    return {
        "code": code,
        "severity": "error",
        "artifact_path": None,
        "pointer": "/",
        "related_ids": [],
        "related_paths": [],
        "message": "The synthetic record reports a failure.",
        "next_action": "Correct the synthetic record.",
    }


def top(**fields: object) -> Callable[[Document], None]:
    """Return a mutation that overwrites the named top-level fields."""

    def apply(document: Document) -> None:
        """Overwrite the captured fields on document; return None."""
        document.update(fields)

    return apply


def nested(member: str, **fields: object) -> Callable[[Document], None]:
    """Return a mutation that overwrites fields of the nested object member."""

    def apply(document: Document) -> None:
        """Replace the member with a copy carrying the overwritten fields."""
        inner = dict(cast("Document", document[member]))
        inner.update(fields)
        document[member] = inner

    return apply


def unchanged(document: Document) -> None:
    """Leave document as it is; the refusal comes from another argument."""


def encode(document: Document) -> bytes:
    """Serialize a synthetic record as the protected store would hold it."""
    return (json.dumps(document, indent=2) + "\n").encode("utf-8")


def started_invocation() -> Document:
    """Return the synthetic invocation after the native start attested it."""
    document = control_fixture("discovery-invocation")
    document.update(
        agent_id="agent-alpha",
        state="started",
        start_attestation_ref=START_ATTESTATION_REFERENCE,
    )
    return document


def consumed_authorization() -> Document:
    """Return a consumed inventory grant bound to the invocation and identity."""
    document = control_fixture("tool-authorization")
    document.update(
        invocation_ref="invocation-alpha",
        start_attestation_ref=START_ATTESTATION_REFERENCE,
        state="consumed",
        consumed_at="2026-01-01T00:00:30Z",
    )
    return document


def baseline_result() -> Document:
    """Return the ok prepare-agent result the host persisted at preparation."""
    document = control_fixture("service-result")
    document["operation"] = "prepare-agent"
    return document


def invocation_document(catalog: SchemaCatalog) -> JsonObject:
    """Decode the synthetic started invocation once for the sibling decoders."""
    return decode_invocation(
        encode(started_invocation()),
        binding=BINDING,
        identity=IDENTITY,
        runtime=RUNTIME,
        catalog=catalog,
        limits=LIMITS,
    )


def refused(action: Callable[[], object]) -> str:
    """Run action; return the SERVICE_AUTHORITY reason it raises with exit 3."""
    with pytest.raises(OperationFailure) as caught:
        action()
    failure = caught.value
    assert failure.exit_code == 3
    assert [finding.code for finding in failure.findings] == ["SERVICE_AUTHORITY"]
    return failure.findings[0].message


def test_coherent_partition_decodes_every_record(
    initialization_catalog: SchemaCatalog,
) -> None:
    """Every bound record returns its validated document; no value is invented."""
    invocation = invocation_document(initialization_catalog)

    attestation = decode_start_attestation(
        encode(control_fixture("start-attestation")),
        invocation=invocation,
        identity=IDENTITY,
        catalog=initialization_catalog,
        limits=LIMITS,
    )
    capability = decode_capability_attestation(
        encode(control_fixture("capability-attestation")),
        invocation=invocation,
        binding=BINDING,
        identity=IDENTITY,
        runtime=RUNTIME,
        catalog=initialization_catalog,
        limits=LIMITS,
    )
    authorization = decode_authorization(
        encode(consumed_authorization()),
        latch_present=True,
        invocation=invocation,
        identity=IDENTITY,
        operation="inventory",
        authorization_ref=OPAQUE_REFERENCE,
        catalog=initialization_catalog,
        limits=LIMITS,
    )
    baseline = decode_baseline_result(
        encode(baseline_result()),
        runtime=RUNTIME,
        catalog=initialization_catalog,
        limits=LIMITS,
    )

    assert invocation["state"] == "started"
    assert invocation["agent_id"] == "agent-alpha"
    assert attestation["start_attestation_ref"] == START_ATTESTATION_REFERENCE
    assert capability["status"] == "supported"
    assert authorization["state"] == "consumed"
    assert baseline["operation"] == "prepare-agent" and baseline["ok"] is True


INVOCATION_CASES: list[tuple[Callable[[Document], None], str]] = [
    (nested("workspace", profile_sha256="0" * 64), "another workspace"),
    (top(session_id="session-beta"), "another host identity"),
    (top(invocation_id="invocation-beta"), "another host identity"),
    (
        top(state="prepared", agent_id=None, start_attestation_ref=None),
        "not been started",
    ),
    (top(agent_id="agent-beta"), "another agent"),
    (nested("runtime", build_sha256="0" * 64), "another runtime"),
]


@pytest.mark.parametrize("mutate,reason", INVOCATION_CASES)
def test_invocation_bindings_each_refuse_with_a_distinct_reason(
    initialization_catalog: SchemaCatalog,
    mutate: Callable[[Document], None],
    reason: str,
) -> None:
    """One drifted binding yields exit 3, SERVICE_AUTHORITY and its own reason."""
    document = started_invocation()
    mutate(document)

    message = refused(
        lambda: decode_invocation(
            encode(document),
            binding=BINDING,
            identity=IDENTITY,
            runtime=RUNTIME,
            catalog=initialization_catalog,
            limits=LIMITS,
        )
    )

    assert reason in message


START_CASES: list[tuple[Callable[[Document], None], str]] = [
    (top(start_attestation_ref=OTHER_START), "not the one the invocation names"),
    (top(invocation_ref="invocation-beta"), "not the one the invocation names"),
    (top(agent_id="agent-beta"), "another host identity"),
    (top(role="requirements-reconciler"), "another host identity"),
    (top(capability_ref=OTHER_REFERENCE), "differs from the invocation"),
    (nested("runtime", policy_version=2), "differs from the invocation"),
]


@pytest.mark.parametrize("mutate,reason", START_CASES)
def test_start_attestation_bindings_each_refuse_with_a_distinct_reason(
    initialization_catalog: SchemaCatalog,
    mutate: Callable[[Document], None],
    reason: str,
) -> None:
    """A start attestation that is not the invocation's own is refused."""
    invocation = invocation_document(initialization_catalog)
    document = control_fixture("start-attestation")
    mutate(document)

    message = refused(
        lambda: decode_start_attestation(
            encode(document),
            invocation=invocation,
            identity=IDENTITY,
            catalog=initialization_catalog,
            limits=LIMITS,
        )
    )

    assert reason in message


CAPABILITY_CASES: list[tuple[Callable[[Document], None], str]] = [
    (top(attestation_ref=OTHER_REFERENCE), "not the one the invocation names"),
    (
        top(
            status="unsupported",
            findings=[error_finding("DISCOVERY_ENFORCEMENT_UNAVAILABLE")],
        ),
        "does not report support",
    ),
    (nested("workspace", workspace_sha256="0" * 64), "another workspace"),
    (top(session_id="session-beta"), "another host session"),
    (nested("runtime", policy_sha256="0" * 64), "another runtime"),
]


@pytest.mark.parametrize("mutate,reason", CAPABILITY_CASES)
def test_capability_attestation_bindings_each_refuse_with_a_distinct_reason(
    initialization_catalog: SchemaCatalog,
    mutate: Callable[[Document], None],
    reason: str,
) -> None:
    """The session capability must be the supported one the invocation names."""
    invocation = invocation_document(initialization_catalog)
    document = control_fixture("capability-attestation")
    mutate(document)

    message = refused(
        lambda: decode_capability_attestation(
            encode(document),
            invocation=invocation,
            binding=BINDING,
            identity=IDENTITY,
            runtime=RUNTIME,
            catalog=initialization_catalog,
            limits=LIMITS,
        )
    )

    assert reason in message


AUTHORIZATION_CASES: list[tuple[Callable[[Document], None], bool, str, str, str]] = [
    (unchanged, True, "inventory", OTHER_REFERENCE, "not the referenced grant"),
    (
        top(state="issued", consumed_at=None),
        True,
        "inventory",
        OPAQUE_REFERENCE,
        "not been consumed",
    ),
    (unchanged, False, "inventory", OPAQUE_REFERENCE, "not been consumed"),
    (unchanged, True, "read-source", OPAQUE_REFERENCE, "another operation"),
    (
        top(invocation_ref="invocation-beta0"),
        True,
        "inventory",
        OPAQUE_REFERENCE,
        "another invocation",
    ),
    (
        nested("identity", agent_id="agent-beta"),
        True,
        "inventory",
        OPAQUE_REFERENCE,
        "another native identity",
    ),
    (
        top(start_attestation_ref=OTHER_START),
        True,
        "inventory",
        OPAQUE_REFERENCE,
        "differs from the invocation",
    ),
]


@pytest.mark.parametrize("mutate,latch,operation,reference,reason", AUTHORIZATION_CASES)
def test_authorization_bindings_each_refuse_with_a_distinct_reason(
    initialization_catalog: SchemaCatalog,
    mutate: Callable[[Document], None],
    latch: bool,
    operation: str,
    reference: str,
    reason: str,
) -> None:
    """Only a consumed, latched grant for this request and identity is admitted."""
    invocation = invocation_document(initialization_catalog)
    document = consumed_authorization()
    mutate(document)

    message = refused(
        lambda: decode_authorization(
            encode(document),
            latch_present=latch,
            invocation=invocation,
            identity=IDENTITY,
            operation=operation,
            authorization_ref=reference,
            catalog=initialization_catalog,
            limits=LIMITS,
        )
    )

    assert reason in message


BASELINE_CASES: list[tuple[Callable[[Document], None], str]] = [
    (top(operation="doctor"), "not an ok prepare-agent result"),
    (
        top(ok=False, exit_code=1, findings=[error_finding("PREPARE_OUTPUT_DIGEST")]),
        "not an ok prepare-agent result",
    ),
    (nested("runtime", build_sha256="0" * 64), "another runtime"),
]


@pytest.mark.parametrize("mutate,reason", BASELINE_CASES)
def test_baseline_result_bindings_each_refuse_with_a_distinct_reason(
    initialization_catalog: SchemaCatalog,
    mutate: Callable[[Document], None],
    reason: str,
) -> None:
    """A baseline that is not this runtime's ok prepare-agent result is refused."""
    document = baseline_result()
    mutate(document)

    message = refused(
        lambda: decode_baseline_result(
            encode(document),
            runtime=RUNTIME,
            catalog=initialization_catalog,
            limits=LIMITS,
        )
    )

    assert reason in message


@pytest.mark.parametrize(
    "content",
    [b"{", b"[]", b'{"artifact_kind": "discovery-invocation"}'],
)
def test_malformed_records_refuse_before_any_field_is_read(
    initialization_catalog: SchemaCatalog, content: bytes
) -> None:
    """Malformed or incomplete bytes never reach a binding comparison."""
    message = refused(
        lambda: decode_invocation(
            content,
            binding=BINDING,
            identity=IDENTITY,
            runtime=RUNTIME,
            catalog=initialization_catalog,
            limits=LIMITS,
        )
    )

    assert "not a valid discovery-invocation document" in message


def test_a_record_of_another_kind_is_refused_as_that_kind(
    initialization_catalog: SchemaCatalog,
) -> None:
    """A valid invocation offered as a start attestation is refused by kind."""
    invocation = invocation_document(initialization_catalog)

    message = refused(
        lambda: decode_start_attestation(
            encode(started_invocation()),
            invocation=invocation,
            identity=IDENTITY,
            catalog=initialization_catalog,
            limits=LIMITS,
        )
    )

    assert "not a valid start-attestation document" in message


def test_decoders_do_not_mutate_the_supplied_fixture(
    initialization_catalog: SchemaCatalog,
) -> None:
    """Decoding returns a fresh document; the caller's fixture is unchanged."""
    document = started_invocation()
    original = deepcopy(document)

    decoded = decode_invocation(
        encode(document),
        binding=BINDING,
        identity=IDENTITY,
        runtime=RUNTIME,
        catalog=initialization_catalog,
        limits=LIMITS,
    )

    assert document == original
    assert decoded["invocation_id"] == "invocation-alpha"
