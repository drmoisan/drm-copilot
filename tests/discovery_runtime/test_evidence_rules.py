"""Verify provenance and exact captured evidence using only immutable memory data."""

from __future__ import annotations

import hashlib
import json
from dataclasses import replace
from typing import TYPE_CHECKING

import pytest
from drm_copilot_discovery.evidence_rules import assess_evidence, validate_evidence
from drm_copilot_discovery.models import canonical_json, to_plain_value
from drm_copilot_discovery.profile_v2 import ProfileV2
from drm_copilot_discovery.references import index_references
from drm_copilot_discovery.repository_reader import RepositoryFile, RepositoryIdentity
from drm_copilot_discovery.revision_rules import RevisionInputs, validate_revisions
from drm_copilot_discovery.snapshot import SnapshotFile

from tests.discovery_runtime.test_references import artifact, graph
from tests.discovery_runtime.test_snapshot import snapshot_profile as snapshot_profile
from tests.discovery_runtime.test_snapshot_io import (
    snapshot_catalog as snapshot_catalog,
)
from tests.schemas.discovery.v2_schema_test_support import as_object

if TYPE_CHECKING:
    from drm_copilot_discovery.catalog import SchemaCatalog
    from drm_copilot_discovery.snapshot import ArtifactSnapshot, DiscoverySnapshot

PIN = "a" * 40
CONTENT = b"first\r\nsecond\nlast"


def configured(
    profile: ProfileV2,
    catalog: SchemaCatalog,
    *,
    role: str = "modernization-target",
    revision: str | None = PIN,
    foreign_role: str = "legacy-source",
) -> ProfileV2:
    """Construct isolated role/pin configurations using the accepted profile parser."""
    document = as_object(to_plain_value(profile.document))
    as_object(document["system"])["role"] = role
    as_object(document["repository"])["revision"] = revision
    document["repositories"] = [
        {
            "id": "foreign",
            "role": foreign_role,
            "revision": "b" * 40,
            "snapshot_manifest": None,
            "clients": [],
        }
    ]
    if role != "legacy-source":
        document["clients"] = [
            {
                "id": "browser",
                "target_repository": profile.repository.id,
                "platforms": ["browser"],
                "modes": ["online"],
                "required_feature_dimensions": [],
                "applicability_defaults": {},
            }
        ]
    if revision is None:
        document["profile_state"] = "draft"
    return ProfileV2(json.dumps(document), format="json", catalog=catalog)


def evidence(
    profile: ProfileV2,
    *,
    kind: str = "runtime",
    content: bytes = CONTENT,
    changes: dict[str, object] | None = None,
    path: str | None = None,
    origin: str | None = None,
    repository: str | None = None,
) -> ArtifactSnapshot:
    """Create fresh evidence metadata independently of captured payload storage."""
    fields: dict[str, object] = {
        "evidence_id": "capture",
        "evidence_type": kind,
        "repository": repository or profile.repository.id,
        "revision": PIN,
        "path": "evidence/capture.txt",
        "timestamp": "2026-01-01T00:00:00Z",
        "runtime_artifact": (
            {"path": "evidence/capture.txt", "capture_method": "manual"}
            if kind in {"runtime", "observation"}
            else None
        ),
        "environment": {
            "id": "environment",
            "platform": "generic",
            "operating_mode": "online",
            "client_id": None,
        },
        "checksum": {
            "algorithm": "sha256",
            "value": hashlib.sha256(content).hexdigest(),
        },
        "author_or_agent": {"kind": "human", "id": "analyst"},
    }
    fields.update(changes or {})
    return artifact(
        "evidence-reference",
        "capture",
        repository=repository or profile.repository.id,
        path=path,
        origin=origin,
        fields=fields,
    )


def captured(
    profile: ProfileV2,
    catalog: SchemaCatalog,
    record: ArtifactSnapshot,
    *,
    files: tuple[tuple[str, bytes], ...] = (("evidence/capture.txt", CONTENT),),
    objects: tuple[RepositoryFile, ...] = (),
) -> DiscoverySnapshot:
    """Retain raw artifact/payload bytes without creating a file or starting Git."""
    snapshot = graph(profile, catalog, record)
    payloads = tuple(
        SnapshotFile(path=path, content=content, category="evidence")
        for path, content in files
    )
    return replace(
        snapshot,
        manifest=replace(snapshot.manifest, files=snapshot.manifest.files + payloads),
        repository_files=objects,
    )


@pytest.mark.parametrize(
    "kind", ["runtime", "observation", "documentation", "decision", "inventory"]
)
def test_local_payload_checksums_and_metadata_establish_only_local_integrity(
    snapshot_profile: ProfileV2, snapshot_catalog: SchemaCatalog, kind: str
) -> None:
    """A matching capture remains usable without claiming behavior or approval."""
    record = evidence(snapshot_profile, kind=kind)
    snapshot = captured(snapshot_profile, snapshot_catalog, record)
    result = validate_evidence(snapshot)
    assessment = result.assessments[0]
    assert result.findings == ()
    assert assessment.locally_verified
    assert assessment.content == CONTENT
    assert assessment.can_prove(
        repository=snapshot_profile.repository.id, revision=PIN, evidence_types=(kind,)
    )
    assert not assessment.can_prove(repository="other")
    assert not assessment.can_prove(
        repository=snapshot_profile.repository.id, revision="b" * 40
    )
    assert not assessment.can_prove(
        repository=snapshot_profile.repository.id, evidence_types=("test",)
    )
    assert result.for_record(assessment.record) == assessment


@pytest.mark.parametrize("kind", ["source", "test"])
def test_source_and_test_evidence_use_pinned_objects_instead_of_current_working_bytes(
    snapshot_profile: ProfileV2, snapshot_catalog: SchemaCatalog, kind: str
) -> None:
    """Historical source evidence hashes the immutable object at its declared pin."""
    record = evidence(snapshot_profile, kind=kind)
    pinned = RepositoryFile(
        repository=RepositoryIdentity(id=snapshot_profile.repository.id, revision=PIN),
        path="evidence/capture.txt",
        content=CONTENT,
    )
    snapshot = captured(
        snapshot_profile,
        snapshot_catalog,
        record,
        files=(("evidence/capture.txt", b"new current contents"),),
        objects=(pinned,),
    )
    result = validate_evidence(snapshot)
    assert result.findings == ()
    assert result.assessments[0].content == CONTENT


@pytest.mark.parametrize(
    "span,valid",
    [
        ({"start": 1, "end": 3}, True),
        ({"start": 3, "end": 3}, True),
        ({"start": 1.0, "end": 3.0}, True),
        ({"start": 0, "end": 1}, False),
        ({"start": 2, "end": 1}, False),
        ({"start": 1, "end": 4}, False),
        ({"start": True, "end": 2}, False),
        ({"start": 1.5, "end": 2}, False),
        ({"start": "1", "end": 2}, False),
        ({"start": 1, "end": None}, False),
        ([], False),
        ({"start": 10**400, "end": 10**400}, False),
    ],
    ids=[
        "whole",
        "last",
        "json-integer-float",
        "zero",
        "reversed",
        "outside",
        "boolean",
        "fraction",
        "text",
        "missing",
        "wrong-shape",
        "huge",
    ],
)
def test_inclusive_source_spans_use_exact_payload_line_boundaries(
    snapshot_profile: ProfileV2,
    snapshot_catalog: SchemaCatalog,
    span: object,
    valid: bool,
) -> None:
    """Line spans accept inclusive endpoints and reject malformed or missing ranges."""
    record = evidence(snapshot_profile, changes={"line_range": span})
    result = validate_evidence(captured(snapshot_profile, snapshot_catalog, record))
    assert result.assessments[0].locally_verified is valid
    assert [finding.code for finding in result.findings] == (
        [] if valid else ["EVIDENCE_LINE_RANGE"]
    )


@pytest.mark.parametrize("replacement", [None, b"replaced"])
def test_distinct_runtime_path_must_match_the_same_actual_payload_digest(
    snapshot_profile: ProfileV2,
    snapshot_catalog: SchemaCatalog,
    replacement: bytes | None,
) -> None:
    """A correct general payload cannot hide missing or substituted runtime bytes."""
    record = evidence(
        snapshot_profile,
        changes={
            "runtime_artifact": {
                "path": "evidence/runtime.txt",
                "capture_method": "automated",
            }
        },
    )
    files: tuple[tuple[str, bytes], ...] = (("evidence/capture.txt", CONTENT),)
    if replacement is not None:
        files += (("evidence/runtime.txt", replacement),)
    result = validate_evidence(
        captured(snapshot_profile, snapshot_catalog, record, files=files)
    )
    assert not result.assessments[0].locally_verified
    assert result.findings[0].pointer == "/runtime_artifact/path"
    assert result.findings[0].code == (
        "EVIDENCE_CONTENT_UNAVAILABLE" if replacement is None else "EVIDENCE_CHECKSUM"
    )


def test_identical_runtime_bytes_at_two_paths_do_not_require_a_git_object(
    snapshot_profile: ProfileV2, snapshot_catalog: SchemaCatalog
) -> None:
    """A full application revision is capture metadata, not a runtime blob lookup."""
    record = evidence(
        snapshot_profile,
        changes={
            "runtime_artifact": {
                "path": "evidence/runtime.txt",
                "capture_method": "semi-automated",
            }
        },
    )
    snapshot = captured(
        snapshot_profile,
        snapshot_catalog,
        record,
        files=(("evidence/capture.txt", CONTENT), ("evidence/runtime.txt", CONTENT)),
    )
    result = validate_evidence(snapshot)
    assert snapshot.repository_files == ()
    assert result.findings == ()
    assert result.assessments[0].locally_verified


@pytest.mark.parametrize(
    "changes,code",
    [
        ({"timestamp": None}, "EVIDENCE_TIMESTAMP"),
        ({"timestamp": "invalid"}, "EVIDENCE_TIMESTAMP"),
        ({"timestamp": "2026-01-01T00:00:00"}, "EVIDENCE_TIMESTAMP"),
        ({"author_or_agent": None}, "EVIDENCE_AUTHOR"),
        ({"author_or_agent": {"kind": "unknown", "id": "analyst"}}, "EVIDENCE_AUTHOR"),
        ({"author_or_agent": {"kind": "human", "id": ""}}, "EVIDENCE_AUTHOR"),
        ({"environment": None}, "EVIDENCE_ENVIRONMENT"),
        (
            {
                "environment": {
                    "id": "environment",
                    "platform": "generic",
                    "operating_mode": "online",
                    "client_id": 5,
                }
            },
            "EVIDENCE_ENVIRONMENT",
        ),
        ({"runtime_artifact": None}, "EVIDENCE_CAPTURE"),
        (
            {
                "runtime_artifact": {
                    "path": "evidence/capture.txt",
                    "capture_method": "unknown",
                }
            },
            "EVIDENCE_CAPTURE",
        ),
        ({"checksum": None}, "EVIDENCE_CHECKSUM"),
        ({"checksum": {"algorithm": "sha1", "value": "f" * 64}}, "EVIDENCE_CHECKSUM"),
        ({"revision": "HEAD"}, "EVIDENCE_PIN"),
    ],
)
def test_missing_or_invalid_provenance_blocks_local_proof_without_exceptions(
    snapshot_profile: ProfileV2,
    snapshot_catalog: SchemaCatalog,
    changes: dict[str, object],
    code: str,
) -> None:
    """Schema-invalid upstream metadata is still handled with explicit findings."""
    record = evidence(snapshot_profile, changes=changes)
    result = validate_evidence(captured(snapshot_profile, snapshot_catalog, record))
    assert code in {finding.code for finding in result.findings}
    assert not result.assessments[0].locally_verified


@pytest.mark.parametrize("kind", ["documentation", "runtime", "source"])
def test_uri_only_evidence_is_descriptive_and_never_local_completion_proof(
    snapshot_profile: ProfileV2, snapshot_catalog: SchemaCatalog, kind: str
) -> None:
    """Remote descriptions are not fetched and cannot establish a verified claim."""
    record = evidence(
        snapshot_profile,
        kind=kind,
        changes={
            "path": None,
            "uri": "https://example.invalid/capture",
            "runtime_artifact": None,
        },
    )
    result = validate_evidence(
        captured(snapshot_profile, snapshot_catalog, record, files=())
    )
    assert not result.assessments[0].can_prove(
        repository=snapshot_profile.repository.id
    )
    assert bool(result.findings) is (kind != "documentation")


def test_source_pin_and_missing_payload_cannot_fall_back_to_working_tree(
    snapshot_profile: ProfileV2, snapshot_catalog: SchemaCatalog
) -> None:
    """Missing immutable objects remain unverified even with matching local bytes."""
    record = evidence(
        snapshot_profile,
        kind="source",
        changes={"revision": None, "line_range": {"start": 1, "end": 1}},
    )
    result = validate_evidence(captured(snapshot_profile, snapshot_catalog, record))
    assert {finding.code for finding in result.findings} == {
        "EVIDENCE_PIN",
        "EVIDENCE_CONTENT_UNAVAILABLE",
        "EVIDENCE_LINE_RANGE",
    }


def test_foreign_identity_cannot_use_local_same_named_payload(
    snapshot_profile: ProfileV2, snapshot_catalog: SchemaCatalog
) -> None:
    """Local storage names do not grant evidence authority to an unknown repository."""
    record = evidence(snapshot_profile, changes={"repository": "foreign"})
    result = validate_evidence(captured(snapshot_profile, snapshot_catalog, record))
    assert {finding.code for finding in result.findings} == {
        "EVIDENCE_REPOSITORY",
        "EVIDENCE_CONTENT_UNAVAILABLE",
    }


def test_non_evidence_records_are_neither_assessed_nor_treated_as_proof(
    snapshot_profile: ProfileV2, snapshot_catalog: SchemaCatalog
) -> None:
    """Evidence lookup remains explicit and rejects unsupported direct assessment."""
    snapshot = graph(
        snapshot_profile, snapshot_catalog, artifact("feature-contract", "feature")
    )
    index = index_references(snapshot)
    result = validate_evidence(snapshot, index=index)
    assert result.assessments == () and result.findings == ()
    assert result.for_record(index.records[0]) is None
    with pytest.raises(ValueError, match="evidence-reference"):
        assess_evidence(RevisionInputs(snapshot), index.records[0])


@pytest.mark.parametrize(
    "timestamp",
    ["2026-01-01t00:00:00z", "2016-12-31T23:59:60Z", "2017-01-01T00:59:60+01:00"],
)
def test_capture_timestamps_reuse_accepted_rfc3339_semantics(
    snapshot_profile: ProfileV2, snapshot_catalog: SchemaCatalog, timestamp: str
) -> None:
    """Lowercase and known UTC/offset leap seconds remain valid capture timestamps."""
    record = evidence(snapshot_profile, changes={"timestamp": timestamp})
    result = validate_evidence(captured(snapshot_profile, snapshot_catalog, record))
    assert result.findings == ()
    assert result.assessments[0].locally_verified


@pytest.mark.parametrize("present", [True, False])
def test_transport_links_keep_identity_resolution_separate_from_byte_integrity(
    snapshot_profile: ProfileV2, snapshot_catalog: SchemaCatalog, present: bool
) -> None:
    """Inherited transport pins verify bytes; missing links retain graph findings."""
    target = artifact(
        "feature-contract",
        "contract",
        repository=snapshot_profile.repository.id,
        path="imports/contract.json",
        origin="contract.json",
    )
    content = canonical_json(target.document)
    manifest = artifact(
        "source-snapshot-manifest",
        "manifest",
        repository=snapshot_profile.repository.id,
        path="imports/manifest.json",
        fields={
            "source_repository": {
                "id": snapshot_profile.repository.id,
                "revision": PIN,
            },
            "artifacts": [
                {
                    "artifact_kind": "feature-contract",
                    "id": "contract",
                    "schema_version": "2.0.0",
                    "path": "contract.json",
                    "sha256": hashlib.sha256(content).hexdigest(),
                    "size": len(content),
                }
            ],
        },
    )
    records = (manifest, target) if present else (manifest,)
    snapshot = graph(snapshot_profile, snapshot_catalog, *records)
    index = index_references(snapshot)
    result = validate_revisions(snapshot, index=index)
    assert len(index.links) == 1
    assert (index.links[0].target is not None) is present
    assert bool(index.findings) is not present
    assert [finding.code for finding in result.findings] == (
        [] if present else ["REVISION_TRANSPORT_BYTES"]
    )
