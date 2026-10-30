"""Compose a schema-complete parity graph for the public target workflow suite.

The service validates every captured record against the installed schemas before it
recognizes evidence payloads or parity rows, so the graph is built from the committed
v2 example documents rather than the rule-level builders: a confirmed in-scope scope,
the inventory that detected the feature's component, a ledger linking that component
to the feature, the capture evidence, a ``required`` verified feature contract, its
implementation record, the target proof and the parity matrix. Every record is placed
under the profile's artifact roots and every payload under its evidence, production or
test roots, and every reference is pinned by content digest. No I/O beyond reading the
committed examples.
"""

from __future__ import annotations

import json
from dataclasses import dataclass
from hashlib import sha256
from typing import TYPE_CHECKING, cast

from drm_copilot_discovery.coverage_scope_rules import inventory_configuration_digest
from drm_copilot_discovery.models import canonical_json
from drm_copilot_discovery.repository_reader import RepositoryFile, RepositoryIdentity
from drm_copilot_discovery.snapshot import (
    ArtifactSnapshot,
    DiscoverySnapshot,
    InputManifest,
    SnapshotFile,
)

from tests.discovery_runtime.test_references import immutable
from tests.schemas.discovery.v2_schema_test_support import as_object, load_fixture

if TYPE_CHECKING:
    from drm_copilot_discovery.catalog import SchemaCatalog
    from drm_copilot_discovery.profile_v2 import ProfileV2

PAYLOAD = b"observed bytes\r\nsecond line\n"
CLIENT = "browser"


@dataclass(frozen=True)
class ParityOptions:
    """Select the implementation verification state and the assessed dimensions.

    verification (str) is the implementation and test verification state;
    dimensions (tuple[str, ...]) names the parity dimensions assessed for the single
    row. Both are plain data; the builder derives parity_state from them.
    """

    verification: str = "passed"
    dimensions: tuple[str, ...] = ("trigger", "observable_outputs", "online")


def _ref(kind: str, identifier: str) -> dict[str, object]:
    """Return a common typed reference to an artifact identity."""
    return {"artifact_kind": kind, "id": identifier}


def _record(
    profile: ProfileV2, kind: str, path: str, document: dict[str, object]
) -> ArtifactSnapshot:
    """Bind a complete document to its path and the profile's repository identity."""
    return ArtifactSnapshot(
        path=path,
        expected_kind=kind,
        document=immutable(document),
        repository=RepositoryIdentity(
            id=profile.repository.id, revision=profile.repository.revision
        ),
    )


def _digest(document: dict[str, object]) -> str:
    """Return the SHA-256 of the canonical bytes the record will be written with."""
    return sha256(canonical_json(immutable(document))).hexdigest()


def _evidence(
    profile: ProfileV2, identifier: str, payload_path: str, *, runtime: bool
) -> dict[str, object]:
    """Return a complete evidence record over the shared payload bytes."""
    record = load_fixture("evidence-reference")
    record.update(
        id=identifier,
        evidence_id=identifier,
        evidence_type="runtime",
        repository=profile.repository.id,
        revision=profile.repository.revision,
        path=payload_path,
        runtime_artifact={"path": payload_path, "capture_method": "manual"},
        checksum={"algorithm": "sha256", "value": sha256(PAYLOAD).hexdigest()},
    )
    environment = as_object(record["environment"])
    environment["client_id"] = CLIENT if runtime else None
    environment["platform"] = CLIENT if runtime else "generic"
    return record


def _contract(profile: ProfileV2, capture: str) -> dict[str, object]:
    """Return the required verified feature contract bound to the capture evidence."""
    text = json.dumps(load_fixture("feature-contract")).replace("source-alpha", capture)
    document = as_object(json.loads(text))
    document.update(
        id="feature",
        feature_id="feature",
        required_dimensions=["trigger", "observable_outputs"],
        target_relevance="required",
    )
    criteria = cast("list[object]", document["acceptance_criteria"])
    criterion = as_object(criteria[0])
    criterion.update(client_ids=[CLIENT], platforms=[CLIENT], modes=["online"])
    # Every required dimension and the client's online mode carry an explicit
    # applicability, which parity-complete demands of a required contract.
    document["online"] = dict(as_object(document["offline"]))
    for name in ("trigger", "observable_outputs", "online"):
        as_object(document[name])["applicability"] = "applicable"
    return document


def _pinned_source(record: ArtifactSnapshot) -> dict[str, object]:
    """Return the parity source-contract reference pinned to the record bytes."""
    assert record.document is not None
    return {
        "artifact_kind": "feature-contract",
        "repository_id": record.repository.id,
        "revision": record.repository.revision,
        "artifact_path": record.path,
        "artifact_sha256": sha256(canonical_json(record.document)).hexdigest(),
        "feature_id": "feature",
        "schema_version": "2.0.0",
    }


def _source_row(profile: ProfileV2, path: str) -> dict[str, object]:
    """Return a pinned byte span of the target repository."""
    return {
        "repository": profile.repository.id,
        "revision": profile.repository.revision,
        "path": path,
        "sha256": sha256(PAYLOAD).hexdigest(),
    }


def parity_graph(
    profile: ProfileV2, catalog: SchemaCatalog, options: ParityOptions | None = None
) -> DiscoverySnapshot:
    """Return the complete parity graph for profile (ProfileV2) under catalog.

    options (ParityOptions | None) selects the verification state and the assessed
    dimensions; the default is a fully verified single-client row. Returns a
    DiscoverySnapshot whose manifest holds every record and payload and whose
    repository objects pin every source byte at the profile revision.
    """
    options = options or ParityOptions()
    roots, owner, pin = (
        profile.artifacts,
        profile.repository.id,
        profile.repository.revision,
    )
    passed = options.verification == "passed"
    # A passed or failed verification is an observed run, so both carry the proof.
    observed = options.verification in ("passed", "failed")
    capture_path = roots["evidence"] + "/capture.txt"
    proof_path = roots["evidence"] + "/target.txt"
    component_path, target_path, test_path = (
        "src/component.cs",
        "src/Target.cs",
        "tests/Target.cs",
    )
    inventory_link = _ref("inventory-snapshot", "inventory")

    contract_record = _record(
        profile,
        "feature-contract",
        roots["feature_contracts"] + "/feature.json",
        _contract(profile, "capture"),
    )
    proof_ref = _ref("evidence-reference", "target-proof")
    implementation = load_fixture("implementation-record")
    implementation.update(
        id="implementation",
        target_repository={"id": owner, "revision": pin},
        client_id=CLIENT,
        feature_refs=[
            {
                **_ref("feature-contract", "feature"),
                "repository": owner,
                "revision": pin,
                "path": contract_record.path,
                "sha256": sha256(
                    canonical_json(contract_record.document or immutable({}))
                ).hexdigest(),
            }
        ],
        implementation_paths=[
            {
                **_source_row(profile, target_path),
                "symbol": "Target",
                "line_range": {"start": 1, "end": 2},
            }
        ],
        test_references=[
            {
                "source": {**_source_row(profile, test_path), "symbol": "Verifies"},
                "modes": ["online"],
                "platforms": [CLIENT],
                "verification_state": options.verification,
                "evidence_refs": [proof_ref] if observed else [],
            }
        ],
        verification_evidence_refs=[proof_ref] if observed else [],
        verification_state=options.verification,
        verification_reason=(
            None if passed or options.verification == "failed" else "Environment down."
        ),
    )
    implementation_record = _record(
        profile,
        "implementation-record",
        roots["implementation_records"] + "/implementation.json",
        implementation,
    )
    classification: dict[str, object] = {
        "applicability": "applicable",
        "verification": "passed",
        "rationale": None,
        "evidence_refs": [proof_ref],
        "product_decision_refs": [],
    }
    matrix = load_fixture("parity-matrix")
    matrix.update(
        id="parity",
        source_repositories=[{"id": owner, "revision": pin}],
        target_repositories=[{"id": owner, "revision": pin}],
        entries=[
            {
                "id": "entry",
                "feature_id": "feature",
                "source_contract_ref": _pinned_source(contract_record),
                "client_id": CLIENT,
                "target_repository": {"id": owner, "revision": pin},
                "target_implementation_refs": [
                    {
                        **_ref("implementation-record", "implementation"),
                        "repository": owner,
                        "revision": pin,
                        "path": implementation_record.path,
                        "sha256": _digest(implementation),
                    }
                ],
                "parity_state": "full" if passed else "partial",
                "dimensions": {
                    name: dict(classification) for name in options.dimensions
                },
                "evidence_refs": [proof_ref],
                "intentional_deviation_refs": [],
                "retirement_decision_ref": None,
                "blockers": [],
                "validation_status": "pass" if passed else None,
                "missing_reason": None,
                "extensions": {},
            }
        ],
    )
    inventory = load_fixture("inventory-snapshot")
    component = as_object(cast("list[object]", inventory["components"])[0])
    component.update(
        component_id="component",
        component_type="class",
        source={
            "repository": owner,
            "revision": pin,
            "path": component_path,
            "sha256": sha256(PAYLOAD).hexdigest(),
            "symbol": "Component",
            "line_range": {"start": 1, "end": 2},
        },
        analyzer={"id": "repository", "version": "2.0.0"},
    )
    inventory.update(
        id="inventory",
        repository=owner,
        revision=pin,
        analyzers=[{"id": "repository", "version": "2.0.0"}],
        scan_configuration_sha256=inventory_configuration_digest(profile),
        files=[
            {
                "path": component_path,
                "status": "inspected",
                "sha256": sha256(PAYLOAD).hexdigest(),
                "size": len(PAYLOAD),
                "rationale": None,
                "diagnostic_ids": cast("list[object]", []),
            }
        ],
        components=[component],
        findings=[],
        relationships=[],
        diagnostics=[],
        exclusions=[],
    )
    scope = load_fixture("scope")
    scope.update(
        id="scope",
        status="confirmed",
        repository={"id": owner, "revision": pin},
        included_roots=["src"],
        included_components=["component"],
        included_features=[_ref("feature-contract", "feature")],
        exclusions=[],
        inventory_snapshot_refs=[inventory_link],
        confirmed_by={
            "owner": "analyst",
            "timestamp": "2026-01-01T00:00:00Z",
            "evidence_refs": [_ref("evidence-reference", "capture")],
        },
        required_coverage={
            "feature_refs": [_ref("feature-contract", "feature")],
            "client_ids": [CLIENT],
            "modes": ["online"],
        },
        disposition="in-scope",
        no_scope_rationale=None,
    )
    ledger = load_fixture("coverage-ledger")
    row = as_object(cast("list[object]", ledger["components"])[0])
    row.update(
        component_id="component",
        component_type="class",
        path=component_path,
        source_sha256=sha256(PAYLOAD).hexdigest(),
        symbol="Component",
        line_range={"start": 1, "end": 2},
        disposition="feature-linked",
        feature_refs=[_ref("feature-contract", "feature")],
        tests_found=[],
        runtime_validation_requirement="not-required",
        runtime_rationale="The component is a pure helper.",
        last_updated_evidence_refs=[_ref("evidence-reference", "capture")],
    )
    ledger.update(
        id="ledger",
        repository=owner,
        revision=pin,
        inventory_snapshot_refs=[inventory_link],
        scope_ref=_ref("scope", "scope"),
        components=[row],
    )

    records = (
        _record(profile, "scope", roots["scope"], scope),
        _record(
            profile,
            "inventory-snapshot",
            roots["inventory"] + "/inventory.json",
            inventory,
        ),
        _record(profile, "coverage-ledger", roots["coverage_ledger"], ledger),
        _record(
            profile,
            "evidence-reference",
            roots["evidence"] + "/capture.json",
            _evidence(profile, "capture", capture_path, runtime=False),
        ),
        _record(
            profile,
            "evidence-reference",
            roots["evidence"] + "/target-proof.json",
            _evidence(profile, "target-proof", proof_path, runtime=True),
        ),
        contract_record,
        implementation_record,
        _record(profile, "parity-matrix", roots["parity_matrix"], matrix),
    )
    payload_paths = (capture_path, proof_path, component_path, target_path, test_path)
    files = (
        SnapshotFile(
            path=roots["profile"],
            content=canonical_json(profile.document),
            category="profile",
        ),
        *(
            SnapshotFile(
                path=item.path,
                content=canonical_json(item.document or immutable({})),
                category="artifact",
            )
            for item in records
        ),
        *(
            SnapshotFile(
                path=path,
                content=PAYLOAD,
                category="evidence" if path.startswith(roots["evidence"]) else "source",
            )
            for path in payload_paths
        ),
    )
    identity = RepositoryIdentity(id=owner, revision=pin)
    return DiscoverySnapshot(
        profile=profile,
        catalog=catalog,
        artifacts=records,
        manifest=InputManifest(files=files),
        repository_files=tuple(
            RepositoryFile(repository=identity, path=path, content=PAYLOAD)
            for path in payload_paths
        ),
    )


__all__ = ["CLIENT", "PAYLOAD", "ParityOptions", "parity_graph"]
