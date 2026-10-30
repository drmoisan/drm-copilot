"""Exercise bounded service carriers, fixed request rules and honest failures."""

from __future__ import annotations

import json
from dataclasses import replace
from typing import TYPE_CHECKING, cast

import pytest
from drm_copilot_discovery import service_serialization
from drm_copilot_discovery.findings import Finding
from drm_copilot_discovery.models import ParseLimits
from drm_copilot_discovery.path_models import WriteGrant
from drm_copilot_discovery.report_models import ReportLimitError, bounded_object
from drm_copilot_discovery.repository_reader import RepositoryIdentity
from drm_copilot_discovery.service_contracts import (
    DiscoveryResult,
    Operation,
    RuntimeIdentity,
    ServiceArtifact,
    ServiceAuthority,
    ServiceRequestError,
    ServiceRuntimeError,
    parse_service_request,
    validate_service_result,
)
from drm_copilot_discovery.snapshot import InputManifest, SnapshotFile

from tests.discovery_runtime.test_service_request_rules import request_document
from tests.discovery_runtime.test_snapshot_io import (
    snapshot_catalog as snapshot_catalog,
)

if TYPE_CHECKING:
    from typing import Literal

    from drm_copilot_discovery.catalog import SchemaCatalog
    from pytest import MonkeyPatch


def runtime_identity() -> RuntimeIdentity:
    """Return a consistent synthetic identity; no installed verification claimed."""
    return RuntimeIdentity(
        package_version="2.0.0",
        schema_version="2.0.0",
        build_sha256="a" * 64,
        policy_version=1,
        policy_sha256="b" * 64,
    )


def result(*, success: bool = False, context: bool = False) -> DiscoveryResult:
    """Return a local result from success/context bool flags without I/O.

    A real empty InputManifest differs from unavailable context. Construction
    errors propagate; synthetic identity is not installed authority.
    """
    summary = bounded_object(
        {
            "message": "Operation result.",
            "counts": [],
            "validation_result": "pass" if success else None,
            "receipt_ref": None,
            "invocation_ref": None,
        },
        limits=ParseLimits(),
    )
    return DiscoveryResult(
        operation="validate-all" if context else None,
        mode="structural" if context else None,
        ok=success,
        exit_code=0 if success else 2,
        findings=(
            ()
            if success
            else (
                Finding(
                    code="SERVICE_REQUEST",
                    pointer="/operation",
                    message="Invalid request.",
                    next_action="Correct the request.",
                ),
            )
        ),
        artifacts=(),
        summary=summary,
        input_manifest=InputManifest(files=()) if context else None,
        runtime=runtime_identity() if context else None,
    )


def test_result_roundtrip_is_detached_schema_valid_and_uses_installed_seam(
    snapshot_catalog: SchemaCatalog,
    monkeypatch: MonkeyPatch,
) -> None:
    """Validate/serialize honest failure using memory catalog; return None.

    Catalog is SchemaCatalog; monkeypatch is scoped MonkeyPatch. No workspace I/O.
    """
    monkeypatch.setattr(service_serialization, "load_catalog", lambda: snapshot_catalog)
    failure = result()
    validate_service_result(failure, catalog=snapshot_catalog, limits=ParseLimits())
    assert json.loads(failure.to_json()) == failure.to_dict()
    wire = failure.to_dict()
    cast("dict[str, object]", wire["summary"])["message"] = "changed"
    assert failure.summary["message"] == "Operation result."
    success = result(success=True, context=True)
    assert success.to_dict()["input_manifest"] is not None
    assert success.to_dict()["runtime"] is not None
    assert success.to_json().endswith("\n")


@pytest.mark.parametrize(
    "field,value",
    [
        ("ok", True),
        ("exit_code", 1),
        ("exit_code", 3),
        ("operation", "unknown"),
        ("mode", "unknown"),
        ("artifacts", []),
        ("summary", {}),
        ("input_manifest", {}),
        ("runtime", {}),
        ("exit_code", True),
    ],
)
def test_result_constructor_rejects_false_or_untyped_claims(
    field: str, value: object
) -> None:
    """Reject one field/value replacement on a failed result; return None.

    str/object inputs remain local and malformed cases raise ValueError.
    """
    with pytest.raises(ValueError):
        replace(result(), **{field: value})


def test_partial_failure_requires_real_context_and_preserves_original_hashes(
    snapshot_catalog: SchemaCatalog,
) -> None:
    """Retain file effects and actual captured bytes with SchemaCatalog; return None."""
    artifact = ServiceArtifact(
        path="report.json",
        kind="validation-report",
        status="created",
        sha256="c" * 64,
        content="report",
    )
    with pytest.raises(ValueError):
        replace(result(), artifacts=(artifact,))
    manifest = InputManifest(
        files=(SnapshotFile(path="input.json", content=b"exact", category="artifact"),),
        missing_paths=("missing.json",),
        source_repositories=(RepositoryIdentity(id="source", revision="a" * 40),),
        target_repositories=(RepositoryIdentity(id="target", revision="b" * 40),),
    )
    partial = replace(
        result(context=True),
        exit_code=3,
        artifacts=(artifact,),
        input_manifest=manifest,
    )
    validate_service_result(partial, catalog=snapshot_catalog, limits=ParseLimits())
    assert partial.to_dict()["input_manifest"] == manifest.to_dict()
    omitted = replace(partial, artifacts=(replace(artifact, content=None),)).to_dict()
    assert "content" not in cast("list[dict[str, object]]", omitted["artifacts"])[0]
    conflict = replace(artifact, status="conflict")
    with pytest.raises(ValueError):
        replace(result(success=True, context=True), artifacts=(conflict,))


@pytest.mark.parametrize(
    "field,value",
    [
        ("path", "../report"),
        ("kind", "directory"),
        ("status", "unknown"),
        ("sha256", "A" * 64),
        ("content", 1),
        ("content", "\ud800"),
    ],
)
def test_artifact_contract_rejects_unsafe_file_claims(
    field: str, value: object
) -> None:
    """Reject field/value at immutable artifact construction; return None, no I/O."""
    artifact = ServiceArtifact(
        path="report.json", kind="validation-report", status="planned", sha256="a" * 64
    )
    with pytest.raises(ValueError):
        replace(artifact, **{field: value})


@pytest.mark.parametrize(
    "field,value",
    [
        ("package_version", "1.0.0"),
        ("schema_version", "3.0.0"),
        ("policy_version", True),
        ("policy_version", 0),
        ("build_sha256", "fake"),
        ("policy_sha256", "A" * 64),
    ],
)
def test_runtime_identity_consistency_is_strict(field: str, value: object) -> None:
    """Reject identity field/value without installed verification; return None."""
    with pytest.raises(ValueError):
        replace(runtime_identity(), **{field: value})


def test_typed_runtime_and_invocation_failures_have_fixed_actionable_findings() -> None:
    """Return None after checking fixed failure codes and ordered deduplication."""
    failure = ServiceRuntimeError(code="RUNTIME_CORRUPT")
    assert failure.findings[0].pointer == "/runtime"
    assert failure.findings[0].next_action
    with pytest.raises(ValueError):
        ServiceRuntimeError(code=cast("Literal['RUNTIME_CORRUPT']", "other"))
    request_error = ServiceRequestError(
        failure.findings * 2, operation=cast("Operation", "bad"), mode="structural"
    )
    assert request_error.operation is None
    assert request_error.mode == "structural"
    assert len(request_error.findings) == 1
    with pytest.raises(ValueError):
        ServiceRequestError(())


def test_authority_is_explicit_typed_and_does_not_mint_grants() -> None:
    """Retain exact provider objects and reject malformed data; return None."""
    grant = WriteGrant(
        artifact_kind="validation-report", artifact_id="report", path="report.json"
    )
    authority = ServiceAuthority(
        principal="local-user",
        author_or_agent="operator",
        invocation=None,
        grants=(grant,),
        read_selection=None,
    )
    assert authority.grants[0] is grant
    replacements: tuple[dict[str, object], ...] = (
        {"principal": "auto"},
        {"author_or_agent": ""},
        {"grants": []},
        {"grants": ("fake",)},
        {"invocation": {}},
        {"read_selection": {}},
    )
    # Malformed caller values cannot become trusted provider fields.
    for changes in replacements:
        with pytest.raises(ValueError):
            replace(authority, **changes)


def test_request_budget_rejects_before_canonical_encoding(
    snapshot_catalog: SchemaCatalog,
    monkeypatch: MonkeyPatch,
) -> None:
    """Reject short UTF-8 budget before encoding; return None with counted proof.

    SchemaCatalog and MonkeyPatch are local seams; Unicode input is unchanged.
    """
    calls: list[object] = []

    def encode(value: object) -> bytes:
        """Record value (object); return bytes, with only local-list mutation."""
        calls.append(value)
        return b"{}"

    monkeypatch.setattr(service_serialization, "canonical_json", encode)
    value = bounded_object(request_document(), limits=ParseLimits())
    with pytest.raises(ServiceRequestError):
        parse_service_request(
            value, catalog=snapshot_catalog, limits=ParseLimits(document_bytes=10)
        )
    assert calls == []


def test_manifest_budget_rejects_before_hash_projection(
    snapshot_catalog: SchemaCatalog,
    monkeypatch: MonkeyPatch,
) -> None:
    """Reject work before InputManifest.to_dict; return None with no partial result.

    Catalog/MonkeyPatch are typed memory seams; the valid fixture is built first.
    """
    manifest = InputManifest(
        files=(SnapshotFile(path="input.json", content=b"exact", category="artifact"),)
    )
    value = replace(result(context=True), input_manifest=manifest)
    calls: list[object] = []

    def project(manifest: InputManifest) -> dict[str, object]:
        """Record InputManifest; return dict, mutating only the local call list."""
        calls.append(manifest)
        return {}

    monkeypatch.setattr(InputManifest, "to_dict", project)
    with pytest.raises(ReportLimitError):
        validate_service_result(
            value, catalog=snapshot_catalog, limits=ParseLimits(artifact_records=1)
        )
    assert calls == []


def test_wire_limits_reject_malformed_and_expensive_values_without_partial_copy() -> (
    None
):
    """Return None after exact Unicode, depth, count and typed-policy controls."""
    assert (
        service_serialization.wire_object(
            {"é": "😀"}, limits=ParseLimits(document_bytes=14)
        )["é"]
        == "😀"
    )
    cases: tuple[tuple[object, ParseLimits], ...] = (
        ({"é": "😀"}, ParseLimits(document_bytes=13)),
        ({"child": {"nested": {}}}, ParseLimits(nesting_depth=2)),
        ({"x": 2**1000}, ParseLimits()),
        ({"x": object()}, ParseLimits()),
        ({"x": "\ud800"}, ParseLimits()),
        ({1: "wrong"}, ParseLimits()),
    )
    # Every rejected boundary must fail before returning a partially frozen value.
    for value, limits in cases:
        with pytest.raises(ValueError):
            service_serialization.wire_object(value, limits=limits)
    with pytest.raises(ValueError):
        service_serialization.wire_object({}, limits=cast("ParseLimits", True))


@pytest.mark.parametrize(
    "case",
    [
        "artifact-type",
        "artifact-count",
        "finding-tuple",
        "finding-count",
        "finding-type",
        "summary-fields",
    ],
)
def test_result_direct_boundaries_reject_before_retaining_invalid_values(
    case: str,
) -> None:
    """Reject case (str) at the public carrier; return None with no side effects."""
    value = result()
    fields: dict[str, dict[str, object]] = {
        "artifact-type": {"artifacts": (object(),)},
        "artifact-count": {"artifacts": (None,) * (ParseLimits().artifact_records + 1)},
        "finding-tuple": {"findings": list(value.findings)},
        "finding-count": {"findings": value.findings * 1001},
        "finding-type": {"findings": (object(),)},
        "summary-fields": {"summary": bounded_object({}, limits=ParseLimits())},
    }
    with pytest.raises(ValueError):
        replace(value, **fields[case])


def test_direct_request_and_schema_validation_reject_invalid_types(
    snapshot_catalog: SchemaCatalog,
) -> None:
    """Use SchemaCatalog to check public type/schema boundaries; return None."""
    request = parse_service_request(
        bounded_object(request_document(), limits=ParseLimits()),
        catalog=snapshot_catalog,
        limits=ParseLimits(),
    )
    with pytest.raises(ValueError, match="invalid types"):
        replace(request, dry_run=1)
    with pytest.raises(ValueError, match="DiscoveryResult"):
        validate_service_result(
            cast("DiscoveryResult", object()),
            catalog=snapshot_catalog,
            limits=ParseLimits(),
        )
    value = result(context=True)
    summary = dict(value.summary.members)
    summary["validation_result"] = "unrecognized"
    invalid = replace(value, summary=bounded_object(summary, limits=ParseLimits()))
    with pytest.raises(ValueError, match="trusted core schema"):
        validate_service_result(invalid, catalog=snapshot_catalog, limits=ParseLimits())
