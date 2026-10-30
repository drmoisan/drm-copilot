"""Verify generated identity, provenance and uncertainty using captured memory."""

from __future__ import annotations

import hashlib
import json
from dataclasses import replace
from typing import TYPE_CHECKING, cast

import pytest
from drm_copilot_discovery.acceptance_generation import generate_acceptance
from drm_copilot_discovery.acceptance_rules import acceptance_source_digest
from drm_copilot_discovery.models import canonical_json, to_plain_value
from drm_copilot_discovery.profile_v2 import ProfileV2
from drm_copilot_discovery.references import index_references
from drm_copilot_discovery.repository_reader import RepositoryFile, RepositoryIdentity
from drm_copilot_discovery.schema_validation import validate_document
from drm_copilot_discovery.snapshot import (
    ArtifactSnapshot,
    DiscoverySnapshot,
    InputManifest,
    SnapshotFile,
    repository_pins,
)

from tests.discovery_runtime.test_profile_v2 import profile_document
from tests.discovery_runtime.test_references import immutable
from tests.discovery_runtime.test_snapshot_io import (
    snapshot_catalog as snapshot_catalog,
)
from tests.schemas.discovery.v2_schema_test_support import as_object, load_fixture

if TYPE_CHECKING:
    from drm_copilot_discovery.acceptance_models import AcceptanceKind
    from drm_copilot_discovery.catalog import SchemaCatalog

PAYLOAD = b"Observed activation.\r\n"


def capture_documents(
    profile: ProfileV2, catalog: SchemaCatalog, documents: tuple[dict[str, object], ...]
) -> DiscoverySnapshot:
    """Capture typed profile/documents in memory and return DiscoverySnapshot.

    profile/catalog are validated immutable inputs; documents contains fresh
    fixture dictionaries. No I/O or caller mutation occurs; invalid fixture
    values propagate constructor errors.
    """
    owner = RepositoryIdentity(
        id=profile.repository.id, revision=profile.repository.revision
    )
    files = [
        SnapshotFile(
            path=profile.artifacts["profile"],
            content=canonical_json(profile.document),
            category="profile",
        ),
        SnapshotFile(path="evidence/capture.bin", content=PAYLOAD, category="evidence"),
    ]
    artifacts: list[ArtifactSnapshot] = []
    pinned = [
        RepositoryFile(repository=owner, path="evidence/capture.bin", content=PAYLOAD)
    ]
    # Each descriptor retains the exact canonical bytes available at the fixture pin.
    for document in documents:
        path = f"docs/migration/discovery/{document['id']}.json"
        value = immutable(document)
        raw = canonical_json(value)
        files.append(SnapshotFile(path=path, content=raw, category="artifact"))
        artifacts.append(
            ArtifactSnapshot(
                path=path,
                expected_kind=str(document["artifact_kind"]),
                document=value,
                repository=owner,
            )
        )
        pinned.append(RepositoryFile(repository=owner, path=path, content=raw))
    sources, targets = repository_pins(profile)
    return DiscoverySnapshot(
        profile=profile,
        catalog=catalog,
        manifest=InputManifest(
            files=tuple(files), source_repositories=sources, target_repositories=targets
        ),
        artifacts=tuple(artifacts),
        repository_files=tuple(pinned),
    )


def generation_snapshot(
    catalog: SchemaCatalog,
    *,
    target: bool = False,
    source_changes: dict[str, object] | None = None,
    profile_changes: dict[str, object] | None = None,
    extras: tuple[dict[str, object], ...] = (),
) -> DiscoverySnapshot:
    """Return a schema-valid observed fixture without asserting discovery completion.

    catalog is SchemaCatalog; target selects a combined source/target profile.
    Optional dictionaries replace explicit source/profile fields and extras adds
    captured documents. No I/O beyond retained fixture loading, writes or mutable
    shared state occurs; malformed fixture configuration raises ProfileError.
    """
    document = profile_document()
    as_object(document["system"])["role"] = "combined" if target else "legacy-source"
    document.update(
        repositories=[],
        clients=[],
        project_entry_points=[],
        required_platforms=["generic"],
        required_modes=["online"],
        required_feature_dimensions=[],
    )
    if target:
        document["clients"] = [
            {
                "id": "client-alpha",
                "target_repository": as_object(document["repository"])["id"],
                "platforms": ["generic"],
                "modes": ["online"],
                "required_feature_dimensions": [],
                "applicability_defaults": {},
            }
        ]
    document.update(profile_changes or {})
    profile = ProfileV2(json.dumps(document), format="json", catalog=catalog)
    source = load_fixture("feature-contract")
    criterion = as_object(cast("list[object]", source["acceptance_criteria"])[0])
    criterion.update(client_ids=[], platforms=[])
    source.update(source_changes or {})
    proof = load_fixture("evidence-reference")
    proof.update(
        id="source-alpha",
        evidence_id="source-alpha",
        repository=profile.repository.id,
        revision=profile.repository.revision,
        path="evidence/capture.bin",
        runtime_artifact={"path": "evidence/capture.bin", "capture_method": "manual"},
        checksum={"algorithm": "sha256", "value": hashlib.sha256(PAYLOAD).hexdigest()},
    )
    as_object(proof["environment"])["client_id"] = None
    return capture_documents(profile, catalog, (source, proof, *extras))


def amended(
    snapshot: DiscoverySnapshot, identifier: str, changes: dict[str, object]
) -> DiscoverySnapshot:
    """Return recaptured memory documents with one exact fixture replacement.

    snapshot is DiscoverySnapshot, identifier is the artifact ID, and changes
    contains field replacements. Original values stay immutable. No I/O occurs;
    invalid fixture values propagate the existing constructors' errors.
    """
    documents: list[dict[str, object]] = []
    # Rebind bytes and pin objects together to avoid unrelated stale-fixture errors.
    for artifact in snapshot.artifacts:
        assert artifact.document is not None
        document = as_object(to_plain_value(artifact.document))
        if document["id"] == identifier:
            document.update(changes)
        documents.append(document)
    return capture_documents(snapshot.profile, snapshot.catalog, tuple(documents))


def imported_snapshot(catalog: SchemaCatalog) -> DiscoverySnapshot:
    """Return captured imported source bytes with a distinct local target owner.

    catalog is SchemaCatalog; returns DiscoverySnapshot with explicit original
    paths and different full source/target pins. No I/O or transport validation
    is claimed; fixture constructors may reject malformed local setup.
    """
    original = generation_snapshot(catalog, target=True)
    document = as_object(to_plain_value(original.profile.document))
    as_object(document["system"])["role"] = "modernization-target"
    source = RepositoryIdentity(id="imported-source", revision="b" * 40)
    document["repositories"] = [
        {
            "id": source.id,
            "role": "legacy-source",
            "revision": source.revision,
            "snapshot_manifest": None,
            "clients": [],
        }
    ]
    profile = ProfileV2(json.dumps(document), format="json", catalog=catalog)
    documents: list[dict[str, object]] = []
    # All imported evidence remains owned by the captured source repository.
    for artifact in original.artifacts:
        value = as_object(to_plain_value(artifact.document))
        if artifact.expected_kind == "evidence-reference":
            value.update(repository=source.id, revision=source.revision)
        documents.append(value)
    captured = capture_documents(profile, catalog, tuple(documents))
    prefix = "docs/imported/"
    # The retained raw source stream deliberately differs from canonical JSON bytes.
    files = tuple(
        (
            item
            if item.category == "profile"
            else replace(
                item,
                path=prefix + item.path,
                content=(
                    b" \r\n" + item.content
                    if item.category == "artifact"
                    else item.content
                ),
            )
        )
        for item in captured.manifest.files
    )
    # Import storage location must never replace original identity in output refs.
    artifacts = tuple(
        replace(item, path=prefix + item.path, origin_path=item.path, repository=source)
        for item in captured.artifacts
    )
    return replace(
        captured,
        manifest=replace(captured.manifest, files=files),
        artifacts=artifacts,
        repository_files=(),
    )


def source_criterion(
    snapshot: DiscoverySnapshot, **changes: object
) -> dict[str, object]:
    """Return one detached criterion with changes; snapshot is DiscoverySnapshot.

    Used only with the known fixture shape. Returns dict[str, object], asserts
    that shape, has no external effects, and leaves the captured source unchanged.
    """
    source = next(
        item for item in snapshot.artifacts if item.expected_kind == "feature-contract"
    )
    assert source.document is not None
    rows = cast("list[object]", to_plain_value(source.document["acceptance_criteria"]))
    return {**as_object(rows[0]), **changes}


@pytest.mark.parametrize("target", [False, True])
def test_generation_retains_exact_identity_refs_and_rule_authority(
    snapshot_catalog: SchemaCatalog,
    target: bool,
) -> None:
    """Check source/target generation from catalog/bool fixtures; return None.

    Assertions cover schema, original-byte refs, accepted digest and immutability.
    No external state changes or expected exceptions occur.
    """
    snapshot = generation_snapshot(snapshot_catalog, target=target)
    before = snapshot.sha256
    kind: AcceptanceKind = "target-acceptance" if target else "legacy-characterization"
    result = generate_acceptance(snapshot, kind=kind)
    assert result.findings == (), result.findings
    assert len(result.specifications) == len(result.ready) == 1
    value = result.ready[0]
    assert value.repository == snapshot.manifest.source_repositories[0]
    assert value.identity.client_id == ("client-alpha" if target else None)
    assert value.document["then"] == (
        "The processor state is active after acknowledgement.",
    )
    assert (
        validate_document(
            value.to_json(),
            expected_kind="acceptance-specification",
            expected_version="2.0.0",
            catalog=snapshot_catalog,
        ).findings
        == ()
    )
    source = next(
        item
        for item in index_references(snapshot).records
        if item.kind == "feature-contract"
    )
    assert value.document["source_content_sha256"] == acceptance_source_digest(
        (source,)
    )
    reference = value.to_dict()["source_contract_refs"]
    ref = as_object(cast("list[object]", reference)[0])
    raw = snapshot.file(source.artifact.path)
    assert raw is not None and ref["artifact_sha256"] == raw.sha256
    assert (
        ref["revision"] == source.artifact.repository.revision
        and ref["artifact_path"] == source.path
    )
    assert (
        snapshot.sha256 == before and generate_acceptance(snapshot, kind=kind) == result
    )
    assert "passed" not in value.document and "execution" not in value.document


@pytest.mark.parametrize("change", ["statement", "expected", "revision", "whitespace"])
def test_identity_survives_source_changes_while_provenance_changes(
    snapshot_catalog: SchemaCatalog,
    change: str,
) -> None:
    """Check canonical identity excludes mutable data; return None for typed fixtures.

    change selects one bounded source variation. No writes occur; revisions and
    raw bytes are intentionally rebound in memory, without claiming new proof.
    """
    snapshot = generation_snapshot(snapshot_catalog)
    original = generate_acceptance(
        snapshot, kind="legacy-characterization"
    ).specifications[0]
    # Content, revision and raw serialization change provenance through distinct seams.
    if change in {"statement", "expected"}:
        criterion = source_criterion(
            snapshot,
            **{
                (
                    "statement" if change == "statement" else "expected_result"
                ): "Updated authored text."
            },
        )
        snapshot = amended(
            snapshot, "feature-alpha", {"acceptance_criteria": [criterion]}
        )
    elif change == "revision":
        profile = as_object(to_plain_value(snapshot.profile.document))
        as_object(profile["repository"])["revision"] = "b" * 40
        changed = ProfileV2(
            json.dumps(profile), format="json", catalog=snapshot_catalog
        )
        documents = tuple(
            as_object(to_plain_value(item.document)) for item in snapshot.artifacts
        )
        snapshot = capture_documents(changed, snapshot_catalog, documents)
    else:
        source = next(
            item
            for item in snapshot.artifacts
            if item.expected_kind == "feature-contract"
        )
        raw = snapshot.file(source.path)
        assert raw is not None
        content = b" \r\n" + raw.content
        snapshot = replace(
            snapshot,
            manifest=replace(
                snapshot.manifest,
                files=tuple(
                    replace(item, content=content) if item.path == source.path else item
                    for item in snapshot.manifest.files
                ),
            ),
            repository_files=tuple(
                replace(item, content=content) if item.path == source.path else item
                for item in snapshot.repository_files
            ),
        )
    changed_value = generate_acceptance(
        snapshot, kind="legacy-characterization"
    ).specifications[0]
    assert original.identity == changed_value.identity
    assert original.document["id"] == changed_value.document["id"]
    assert original.document != changed_value.document


@pytest.mark.parametrize(
    "reason", ["The observed result is unknown.", "Unicode 結果 remains unverified."]
)
def test_pending_criteria_preserve_questions_and_never_invent_then(
    snapshot_catalog: SchemaCatalog,
    reason: str,
) -> None:
    """Keep explicit pending text using catalog/str fixtures; return None.

    No runtime or external state changes occur; no exception is expected.
    """
    snapshot = generation_snapshot(snapshot_catalog)
    criterion = source_criterion(
        snapshot, readiness="pending", expected_result=None, pending_reason=reason
    )
    snapshot = amended(snapshot, "feature-alpha", {"acceptance_criteria": [criterion]})
    result = generate_acceptance(snapshot, kind="legacy-characterization")
    assert len(result.specifications) == 1 and result.ready == ()
    assert result.specifications[0].document["then"] is None
    assert result.specifications[0].document["pending_reasons"] == (reason,)
    assert result.specifications[0].document["expectation_basis"] == "unresolved"


@pytest.mark.parametrize(
    "field,selection",
    [
        ("feature_ids", (("missing", "feature-alpha"),)),
        ("client_ids", ("unknown",)),
        ("mode_ids", ("unconfigured",)),
    ],
)
def test_unknown_filters_fail_explicitly_without_default_selection(
    snapshot_catalog: SchemaCatalog,
    field: str,
    selection: tuple[object, ...],
) -> None:
    """Reject unavailable qualified selections; return None with no I/O.

    Typed fixture field/selection are forwarded dynamically to the public API.
    Findings, rather than fabricated selected records, express the failure.
    """
    result = generate_acceptance(
        generation_snapshot(snapshot_catalog, target=True),
        kind="target-acceptance",
        feature_ids=(
            cast("tuple[tuple[str, str], ...]", selection)
            if field == "feature_ids"
            else ()
        ),
        client_ids=cast("tuple[str, ...]", selection) if field == "client_ids" else (),
        mode_ids=cast("tuple[str, ...]", selection) if field == "mode_ids" else (),
    )
    assert result.ready == () and any(
        item.code == "ACCEPTANCE_SELECTOR" for item in result.findings
    )


@pytest.mark.parametrize(
    "change", ["malformed", "missing-profile", "pins", "draft", "duplicate"]
)
def test_integrity_failures_remain_blocking_before_generation_authority(
    snapshot_catalog: SchemaCatalog,
    change: str,
) -> None:
    """Check captured integrity failures from catalog/str fixtures; return None.

    All corruption is local immutable replacement, with no I/O or expected throw.
    """
    snapshot = generation_snapshot(snapshot_catalog)
    # Corrupt one independent captured-integrity boundary without repairing another.
    if change == "malformed":
        snapshot = amended(snapshot, "feature-alpha", {"undeclared": True})
    elif change == "missing-profile":
        snapshot = replace(
            snapshot,
            manifest=replace(
                snapshot.manifest,
                files=tuple(
                    item
                    for item in snapshot.manifest.files
                    if item.category != "profile"
                ),
            ),
        )
    elif change == "pins":
        snapshot = replace(
            snapshot, manifest=replace(snapshot.manifest, source_repositories=())
        )
    elif change == "draft":
        profile = as_object(to_plain_value(snapshot.profile.document))
        profile["profile_state"] = "draft"
        changed = ProfileV2(
            json.dumps(profile), format="json", catalog=snapshot_catalog
        )
        snapshot = capture_documents(
            changed,
            snapshot_catalog,
            tuple(
                as_object(to_plain_value(item.document)) for item in snapshot.artifacts
            ),
        )
    else:
        source = next(
            item
            for item in snapshot.artifacts
            if item.expected_kind == "feature-contract"
        )
        raw = snapshot.file(source.path)
        assert raw is not None
        snapshot = replace(
            snapshot,
            artifacts=snapshot.artifacts
            + (replace(source, path="docs/duplicate.json"),),
            manifest=replace(
                snapshot.manifest,
                files=snapshot.manifest.files
                + (replace(raw, path="docs/duplicate.json"),),
            ),
        )
    result = generate_acceptance(snapshot, kind="legacy-characterization")
    assert result.ready == () and any(
        item.severity == "error" for item in result.findings
    )
