"""Build immutable evidence fixtures and fresh memory writers for isolated tests."""

from __future__ import annotations

from dataclasses import replace
from hashlib import sha256
from typing import TYPE_CHECKING

import pytest
from drm_copilot_discovery.evidence_linking import EvidenceLink, EvidencePayload
from drm_copilot_discovery.models import canonical_json
from drm_copilot_discovery.snapshot import ArtifactSnapshot, SnapshotFile

from tests.discovery_runtime.draft_test_support import add_feature, draft_case
from tests.discovery_runtime.test_mutation_commit import MemoryWriter
from tests.discovery_runtime.test_references import immutable
from tests.discovery_runtime.test_snapshot_io import MemoryStore
from tests.schemas.discovery.v2_schema_test_support import as_object, load_fixture

if TYPE_CHECKING:
    from drm_copilot_discovery.catalog import SchemaCatalog
    from drm_copilot_discovery.mutation_plan import CapturedWorkspace

CONTENT = b"captured observation\r\nsecond line\n"


@pytest.fixture(scope="module")
def link_baseline(mutation_catalog: SchemaCatalog) -> CapturedWorkspace:
    """Share immutable real draft inputs; mutable stores are constructed per test."""
    store, _ = draft_case(mutation_catalog)
    return add_feature(store, mutation_catalog, "feature")


def request_for(
    baseline: CapturedWorkspace,
    *,
    kind: str = "runtime",
    updates: dict[str, object] | None = None,
) -> EvidenceLink:
    """Construct fresh provenance and exact supplied bytes without inventing proof."""
    target = next(
        item
        for item in baseline.snapshot.artifacts
        if item.expected_kind == "feature-contract"
    )
    path = baseline.snapshot.profile.artifacts["evidence"] + "/capture.txt"
    record = load_fixture("evidence-reference")
    record.update(
        id="proof",
        evidence_id="proof",
        repository=baseline.snapshot.profile.repository.id,
        evidence_type=kind,
        revision="a" * 40 if kind in {"source", "test"} else None,
        path=path,
        runtime_artifact=(
            {"path": path, "capture_method": "manual"}
            if kind in {"runtime", "observation"}
            else None
        ),
    )
    as_object(record["environment"])["client_id"] = None
    as_object(record["checksum"])["value"] = sha256(CONTENT).hexdigest()
    record.update(updates or {})
    return EvidenceLink(
        artifact_kind="feature-contract",
        artifact_id="feature",
        expected_sha256=baseline.snapshot.file(target.path).sha256,
        record=immutable(record),
        payloads=(EvidencePayload(path=path, content=CONTENT),),
    )


def add_record(
    baseline: CapturedWorkspace, document: dict[str, object], *, path: str
) -> CapturedWorkspace:
    """Add an isolated immutable graph record for narrow projection/error tests."""
    value = immutable(document)
    artifact = ArtifactSnapshot(
        path=path,
        expected_kind=str(document["artifact_kind"]),
        repository=baseline.snapshot.artifacts[0].repository,
        document=value,
    )
    files = tuple(
        file for file in baseline.snapshot.manifest.files if file.path != path
    )
    artifacts = tuple(item for item in baseline.snapshot.artifacts if item.path != path)
    return replace(
        baseline,
        snapshot=replace(
            baseline.snapshot,
            artifacts=(*artifacts, artifact),
            manifest=replace(
                baseline.snapshot.manifest,
                files=(
                    *files,
                    SnapshotFile(
                        path=path, content=canonical_json(value), category="artifact"
                    ),
                ),
                missing_paths=tuple(
                    item
                    for item in baseline.snapshot.manifest.missing_paths
                    if item != path
                ),
            ),
        ),
    )


def memory_writer(baseline: CapturedWorkspace) -> MemoryWriter:
    """Recreate a fresh physical model from exact immutable baseline bytes."""
    store = MemoryStore(baseline.workspace_root)
    # Only captured bytes populate the new test-owned store.
    for file in baseline.snapshot.manifest.files:
        store.put(file.path, file.content)
    return MemoryWriter(store, baseline.snapshot.catalog)
