"""Build fresh memory workspaces and explicit transition evidence for draft tests."""

from __future__ import annotations

import json
from hashlib import sha256
from typing import TYPE_CHECKING

from drm_copilot_discovery.draft_contracts import ContractDraft, contract_changes

from tests.discovery_runtime.mutation_test_support import capture, mutation_case
from tests.discovery_runtime.test_references import immutable
from tests.discovery_runtime.test_snapshot_io import PROFILE_PATH
from tests.schemas.discovery.v2_schema_test_support import as_object, load_fixture

if TYPE_CHECKING:
    from drm_copilot_discovery.catalog import SchemaCatalog
    from drm_copilot_discovery.mutation_plan import CapturedWorkspace

    from tests.discovery_runtime.test_snapshot_io import MemoryStore


def draft_case(
    catalog: SchemaCatalog, *, custom: bool = False
) -> tuple[MemoryStore, CapturedWorkspace]:
    """Provide fresh state with optional configured artifact roots and requirements."""
    store, baseline = mutation_case(catalog)
    if custom:
        document = as_object(json.loads(store.files[PROFILE_PATH]))
        roots = as_object(document["artifacts"])
        roots.update(
            feature_contracts="work/contracts",
            characterization="work/scenarios",
            unspecified_behaviors="work/questions.yaml",
        )
        document["required_feature_dimensions"] = [
            "trigger",
            "timing",
            "offline",
            "mobile",
        ]
        store.put(PROFILE_PATH, json.dumps(document).encode())
        baseline = capture(store, catalog)
    return store, baseline


def add_feature(
    store: MemoryStore, catalog: SchemaCatalog, identifier: str
) -> CapturedWorkspace:
    """Set up real schema-valid draft inputs without repeating publication tests."""
    baseline = capture(store, catalog)
    # Seed only fixture bytes; publication behavior has separate shared-writer tests.
    for change in contract_changes(
        baseline, ContractDraft(feature_id=identifier, name=identifier)
    ):
        store.put(change.path, change.content)
    return capture(store, catalog)


def transition_case(
    catalog: SchemaCatalog, *, phase: str, state: str, linked: bool
) -> tuple[CapturedWorkspace, ContractDraft]:
    """Bind one requested phase to real local evidence in a fresh captured store."""
    store, _ = draft_case(catalog)
    profile = as_object(json.loads(store.files[PROFILE_PATH]))
    repository = as_object(profile["repository"])
    repository["revision"] = "a" * 40
    store.put(PROFILE_PATH, json.dumps(profile).encode())
    payload = b"recorded observation\n"
    evidence = load_fixture("evidence-reference")
    evidence.update(
        id="proof",
        evidence_id="proof",
        repository=repository["id"],
        path="docs/migration/discovery/evidence/capture.txt",
    )
    as_object(evidence["runtime_artifact"])["path"] = evidence["path"]
    as_object(evidence["environment"])["client_id"] = None
    as_object(evidence["checksum"])["value"] = sha256(payload).hexdigest()
    store.put(str(evidence["path"]), payload)
    store.put(
        "docs/migration/discovery/evidence/proof.json", json.dumps(evidence).encode()
    )
    baseline = capture(store, catalog)
    proof = {"artifact_kind": "evidence-reference", "id": "proof"}
    inferred: dict[str, object] = dict(
        observation_state="inferred",
        statement="A transition may occur.",
        evidence_refs=[],
        unresolved_behavior_refs=[],
        confidence="low",
    )
    question = {
        "artifact_kind": "unspecified-behavior",
        "id": "unknown-feature-feature",
    }
    selected = dict(
        inferred,
        observation_state=state,
        statement=None if state == "unknown" else inferred["statement"],
        evidence_refs=[proof] if state == "verified" else [],
        unresolved_behavior_refs=[question] if linked else [],
    )
    entry: dict[str, object] = dict(
        id="step",
        before=inferred,
        action=inferred,
        after=inferred,
        evidence_refs=[proof],
    )
    entry[phase] = selected
    request = ContractDraft(
        feature_id="feature",
        name="Feature",
        fields=immutable(
            {
                "state_transitions": dict(
                    disposition="present",
                    behavior=inferred,
                    entries=[entry],
                    rationale=None,
                )
            }
        ),
    )
    return baseline, request
