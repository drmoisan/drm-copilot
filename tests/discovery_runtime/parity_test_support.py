"""Build fresh parity graphs without filesystem, processes or mutable globals."""

from __future__ import annotations

from dataclasses import replace
from hashlib import sha256
from typing import TYPE_CHECKING

from drm_copilot_discovery.models import canonical_json
from drm_copilot_discovery.parity_rules import validate_parity
from drm_copilot_discovery.repository_reader import RepositoryFile, RepositoryIdentity
from drm_copilot_discovery.snapshot import SnapshotFile

from tests.discovery_runtime.test_evidence_rules import CONTENT, PIN, evidence
from tests.discovery_runtime.test_references import artifact, graph, reference

if TYPE_CHECKING:
    from drm_copilot_discovery.catalog import SchemaCatalog
    from drm_copilot_discovery.profile_v2 import ProfileV2
    from drm_copilot_discovery.snapshot import ArtifactSnapshot, DiscoverySnapshot


def pinned(record: ArtifactSnapshot) -> dict[str, object]:
    """Bind typed artifact links to exact retained content and trusted ownership."""
    assert record.document is not None
    result: dict[str, object] = {
        "artifact_kind": record.expected_kind,
        "revision": record.repository.revision,
    }
    if record.expected_kind == "feature-contract":
        result.update(
            repository_id=record.repository.id,
            artifact_path=record.origin_path or record.path,
            artifact_sha256=sha256(canonical_json(record.document)).hexdigest(),
            feature_id=record.document["feature_id"],
            schema_version="2.0.0",
        )
    else:
        result.update(
            id=record.document["id"],
            repository=record.repository.id,
            path=record.origin_path or record.path,
            sha256=sha256(canonical_json(record.document)).hexdigest(),
        )
    return result


def source_row(profile: ProfileV2, path: str) -> dict[str, object]:
    """Identify an implementation or test byte span at the configured target pin."""
    return {
        "repository": profile.repository.id,
        "revision": PIN,
        "path": path,
        "sha256": sha256(CONTENT).hexdigest(),
        "size": len(CONTENT),
    }


def classification(**changes: object) -> dict[str, object]:
    """Supply one independent target result without inferring optional dimensions."""
    return {
        "applicability": "applicable",
        "verification": "passed",
        "rationale": None,
        "evidence_refs": [reference("evidence-reference", "target-proof")],
        "product_decision_refs": [],
        **changes,
    }


def source_contract(profile: ProfileV2, **changes: object) -> ArtifactSnapshot:
    """Keep source facts distinct from mutable target summary fields."""
    return artifact(
        "feature-contract",
        "feature",
        repository=profile.repository.id,
        fields={
            "feature_id": "feature",
            "observation_state": "inferred",
            "required_dimensions": [],
            "target_relevance": "required",
            **changes,
        },
    )


def implementation(
    profile: ProfileV2,
    source: ArtifactSnapshot,
    identifier: str = "implementation",
    /,
    **changes: object,
) -> ArtifactSnapshot:
    """Create a target implementation with one explicit passing coordinate."""
    return artifact(
        "implementation-record",
        identifier,
        repository=profile.repository.id,
        fields={
            "implementation_id": identifier,
            "client_id": "browser",
            "target_repository": {"id": profile.repository.id, "revision": PIN},
            "feature_refs": [pinned(source)],
            "implementation_paths": [source_row(profile, "src/Target.cs")],
            "test_references": [
                {
                    "id": "test",
                    "source": source_row(profile, "tests/Target.cs"),
                    "modes": ["online"],
                    "platforms": ["browser"],
                    "verification_state": "passed",
                    "evidence_refs": [reference("evidence-reference", "target-proof")],
                }
            ],
            "verification_state": "passed",
            "verification_reason": None,
            "verification_evidence_refs": [
                reference("evidence-reference", "target-proof")
            ],
            **changes,
        },
    )


def parity_row(
    profile: ProfileV2,
    source: ArtifactSnapshot,
    target: ArtifactSnapshot,
    **changes: object,
) -> dict[str, object]:
    """Make a full row whose required dimensions cite independently captured proof."""
    return {
        "id": "entry",
        "feature_id": "feature",
        "client_id": "browser",
        "source_contract_ref": pinned(source),
        "target_repository": {"id": profile.repository.id, "revision": PIN},
        "target_implementation_refs": [pinned(target)],
        "parity_state": "full",
        "dimensions": {
            name: classification()
            for name in ("trigger", "observable_outputs", "online")
        },
        "evidence_refs": [reference("evidence-reference", "target-proof")],
        "intentional_deviation_refs": [],
        "retirement_decision_ref": None,
        "blockers": [],
        "validation_status": "pass",
        "missing_reason": None,
        **changes,
    }


def parity_snapshot(
    profile: ProfileV2,
    catalog: SchemaCatalog,
    *,
    source: ArtifactSnapshot | None = None,
    target: ArtifactSnapshot | None = None,
    row: dict[str, object] | None = None,
    proof_fields: dict[str, object] | None = None,
    matrix_fields: dict[str, object] | None = None,
    extra: tuple[ArtifactSnapshot, ...] = (),
) -> DiscoverySnapshot:
    """Retain all graph bytes and target objects without filesystem or Git calls."""
    source = source or source_contract(profile)
    target = target or implementation(profile, source)
    proof = evidence(
        profile,
        changes={
            "id": "target-proof",
            "evidence_id": "target-proof",
            "path": "evidence/target.txt",
            "runtime_artifact": {
                "path": "evidence/target.txt",
                "capture_method": "manual",
            },
            "environment": {
                "id": "target",
                "client_id": "browser",
                "platform": "browser",
                "operating_mode": "online",
            },
            **(proof_fields or {}),
        },
    )
    matrix = artifact(
        "parity-matrix",
        "parity",
        repository=profile.repository.id,
        fields={
            "source_repositories": [
                {"id": source.repository.id, "revision": source.repository.revision}
            ],
            "target_repositories": [{"id": profile.repository.id, "revision": PIN}],
            "entries": [
                row if row is not None else parity_row(profile, source, target)
            ],
            **(matrix_fields or {}),
        },
    )
    snapshot = graph(profile, catalog, source, target, proof, matrix, *extra)
    payloads = tuple(
        SnapshotFile(path=path, content=CONTENT, category="evidence")
        for path in (
            "src/Target.cs",
            "tests/Target.cs",
            "evidence/target.txt",
            "evidence/capture.txt",
        )
    )
    objects = tuple(
        RepositoryFile(
            repository=RepositoryIdentity(id=profile.repository.id, revision=PIN),
            path=item.path,
            content=item.content,
        )
        for item in payloads
    )
    return replace(
        snapshot,
        manifest=replace(snapshot.manifest, files=snapshot.manifest.files + payloads),
        repository_files=objects,
    )


def codes(snapshot: DiscoverySnapshot, *, complete: bool = False) -> set[str]:
    """Expose only this rule family's diagnostics for focused behavioral assertions."""
    return {item.code for item in validate_parity(snapshot, complete=complete).findings}
