"""Verify immutable source and external analyzer transport envelopes."""

from __future__ import annotations

from typing import cast

import pytest

from tests.schemas.discovery.v2_schema_test_support import (
    as_object,
    load_fixture,
    schema_errors,
)

TRANSPORT_KINDS = ("source-snapshot-manifest", "extension-result-manifest")


def _first(document: dict[str, object], field: str) -> dict[str, object]:
    """Select one fresh manifest entry without changing shared fixture state."""
    return as_object(cast("list[object]", document[field])[0])


@pytest.mark.parametrize(
    "kind,field",
    [
        ("source-snapshot-manifest", field)
        for field in (
            "source_repository schema_versions tool artifacts payloads manifest_sha256 "
            "transport extensions"
        ).split()
    ]
    + [
        ("extension-result-manifest", field)
        for field in (
            "adapter repository input_manifest_sha256 source_inputs result_files "
            "manifest_sha256 generated_at generated_by diagnostics extensions"
        ).split()
    ],
)
def test_transport_requires_all_provenance_and_integrity_fields(
    kind: str, field: str
) -> None:
    """Transport records cannot omit their declared byte and producer identities."""
    manifest = load_fixture(kind)
    del manifest[field]

    assert schema_errors(kind, manifest)


@pytest.mark.parametrize("kind", TRANSPORT_KINDS)
@pytest.mark.parametrize("revision", ("a" * 40, "b" * 64))
def test_source_and_adapter_manifests_pin_full_supported_git_hashes(
    kind: str, revision: str
) -> None:
    """A manifest cannot silently resolve a mutable branch or an unknown pin."""
    manifest = load_fixture(kind)
    field = "source_repository" if kind == TRANSPORT_KINDS[0] else "repository"
    repository = as_object(manifest[field])
    repository["revision"] = revision
    assert schema_errors(kind, manifest) == []
    repository["revision"] = None
    assert schema_errors(kind, manifest)
    repository["revision"] = "main"

    assert schema_errors(kind, manifest)


@pytest.mark.parametrize("kind", TRANSPORT_KINDS)
@pytest.mark.parametrize(
    "digest", ("", "f" * 63, "f" * 65, "F" * 64, "f" * 64 + "\n", None)
)
def test_transport_manifest_digest_requires_exact_sha256(
    kind: str, digest: object
) -> None:
    """Digest syntax is strict even before the importer compares canonical bytes."""
    manifest = load_fixture(kind)
    manifest["manifest_sha256"] = digest

    assert schema_errors(kind, manifest)


@pytest.mark.parametrize(
    "kind,collection",
    [
        ("source-snapshot-manifest", "artifacts"),
        ("source-snapshot-manifest", "payloads"),
        ("extension-result-manifest", "source_inputs"),
        ("extension-result-manifest", "result_files"),
    ],
)
@pytest.mark.parametrize(
    "field,value",
    [("path", "../escape.json"), ("sha256", None), ("size", -1), ("size", True)],
)
def test_all_transported_files_require_safe_paths_and_exact_byte_metadata(
    kind: str, collection: str, field: str, value: object
) -> None:
    """Artifact and raw payload transports share the same immutable-file boundary."""
    manifest = load_fixture(kind)
    _first(manifest, collection)[field] = value

    assert schema_errors(kind, manifest)


@pytest.mark.parametrize(
    "kind,collection",
    [
        ("source-snapshot-manifest", "artifacts"),
        ("extension-result-manifest", "result_files"),
    ],
)
@pytest.mark.parametrize("version", ("1.0.0", "2.1.0", "2", None))
def test_transport_artifact_versions_are_exact_not_major_only(
    kind: str, collection: str, version: object
) -> None:
    """Frozen v1 compatibility reads do not create v2 completion transport."""
    manifest = load_fixture(kind)
    _first(manifest, collection)["schema_version"] = version

    assert schema_errors(kind, manifest)


def test_pending_transport_cannot_claim_verifier_metadata() -> None:
    """A source export remains pending until explicit verification is recorded."""
    manifest = load_fixture("source-snapshot-manifest")
    transport = as_object(manifest["transport"])
    assert schema_errors("source-snapshot-manifest", manifest) == []
    transport["verified_by"] = {"kind": "tool", "id": "discovery"}

    assert schema_errors("source-snapshot-manifest", manifest)


def test_verified_transport_needs_timestamp_and_named_verifier() -> None:
    """Recorded verification remains a claim that the importer must recompute."""
    manifest = load_fixture("source-snapshot-manifest")
    transport = as_object(manifest["transport"])
    transport["verification_status"] = "verified"
    assert schema_errors("source-snapshot-manifest", manifest)
    transport.update(
        verified_at="2026-01-01T00:01:00Z",
        verified_by={"kind": "tool", "id": "discovery"},
    )
    assert schema_errors("source-snapshot-manifest", manifest) == []
    transport["verified_at"] = "2026-02-30T00:00:00Z"

    assert schema_errors("source-snapshot-manifest", manifest)


@pytest.mark.parametrize("field", ("command", "module", "python_path", "approved"))
@pytest.mark.parametrize("kind", TRANSPORT_KINDS)
def test_transport_data_cannot_supply_execution_or_approval_authority(
    kind: str, field: str
) -> None:
    """Unknown root fields cannot turn an imported data manifest into a launcher."""
    manifest = load_fixture(kind)
    manifest[field] = "caller-supplied"

    assert schema_errors(kind, manifest)


def test_extension_results_accept_only_core_inventory_artifact_kind() -> None:
    """A local adapter cannot import a target decision as an analyzer result."""
    manifest = load_fixture("extension-result-manifest")
    _first(manifest, "result_files")["artifact_kind"] = "product-decision"

    assert schema_errors("extension-result-manifest", manifest)


def test_no_adapter_output_is_honest_only_with_a_blocking_diagnostic() -> None:
    """An adapter failure is representable without inventing an empty success."""
    manifest = load_fixture("extension-result-manifest")
    manifest.update(result_files=[], source_inputs=[])
    assert schema_errors("extension-result-manifest", manifest)
    manifest["diagnostics"] = [
        {
            "id": "adapter-failure",
            "code": "input-unavailable",
            "severity": "error",
            "path": None,
            "message": "Required input could not be read.",
            "analyzer_id": "synthetic.adapter",
            "blocking": True,
            "extensions": {},
        }
    ]
    assert schema_errors("extension-result-manifest", manifest) == []
    _first(manifest, "diagnostics")["blocking"] = False

    assert schema_errors("extension-result-manifest", manifest)


@pytest.mark.parametrize(
    "kind,producer",
    [("source-snapshot-manifest", "tool"), ("extension-result-manifest", "adapter")],
)
def test_transport_producer_metadata_is_versioned_data_only(
    kind: str, producer: str
) -> None:
    """A producer record identifies its implementation without accepting code paths."""
    manifest = load_fixture(kind)
    as_object(manifest[producer])["version"] = ""
    assert schema_errors(kind, manifest)
    as_object(manifest[producer]).update(version="1.0.0", module="external.adapter")

    assert schema_errors(kind, manifest)
