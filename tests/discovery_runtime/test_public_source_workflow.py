"""Prove the public legacy-source workflow in memory through the installed service.

Every step runs ``drm_copilot_discovery.service.execute`` over the ``MemoryService``
ports with the real planners, validators and reports: initialization (dry run, write,
repeat), inventory, contract and question drafts, scenario plans, evidence links,
honest completion failure, evidence-backed completion of a confirmed scope, planning
admission, reports, acceptance generation, and the negative scenarios (malformed and
unreferenced artifacts, stale bytes, exit mapping). No file, process or clock is used.
"""

from __future__ import annotations

import json
from typing import TYPE_CHECKING

import pytest
from drm_copilot_discovery.configuration import DEFAULT_PROFILE
from drm_copilot_discovery.models import canonical_json
from drm_copilot_discovery.mutation_io import capture_workspace
from drm_copilot_discovery.repository_reader import RepositoryIdentity

from tests.discovery_runtime.evidence_test_support import request_for
from tests.discovery_runtime.initialization_test_support import (
    initialization_catalog as initialization_catalog,
)
from tests.discovery_runtime.initialization_test_support import (
    initialization_templates as initialization_templates,
)
from tests.discovery_runtime.public_workflow_test_support import (
    DOCUMENTATION_ROOT,
    PRODUCTION_ROOT,
    TEST_ROOT,
    codes,
    seeded_workspace,
    validate,
    workspace,
)
from tests.discovery_runtime.test_draft_scenarios import scenario_fields
from tests.discovery_runtime.test_service import MemoryService, invoke
from tests.discovery_runtime.validation_test_support import no_scope_snapshot

if TYPE_CHECKING:
    from drm_copilot_discovery.catalog import SchemaCatalog
    from drm_copilot_discovery.init_projection import InitializationTemplates
    from drm_copilot_discovery.mutation_plan import CapturedWorkspace

INIT_INPUTS: dict[str, object] = {
    "system_id": "source-system",
    "system_name": "Source system",
    "system_role": "legacy-source",
    "repository_id": "source-repository",
    "production_roots": [PRODUCTION_ROOT],
    "test_roots": [TEST_ROOT],
}


@pytest.fixture
def source(
    initialization_catalog: SchemaCatalog,
    initialization_templates: InitializationTemplates,
) -> MemoryService:
    """Return a configured, activated legacy-source workspace; memory only."""
    return workspace(initialization_catalog, initialization_templates)


def capture(io: MemoryService) -> CapturedWorkspace:
    """Capture io's current workspace exactly as the service would; no writes."""
    return capture_workspace(
        workspace_root=io.disk.root,
        profile_path=DEFAULT_PROFILE,
        metadata=io.disk.store.metadata,
        read_bytes=io.disk.store.read,
        catalog=io.initialization.catalog,
        repository=io.repository,
    )


def test_initialization_is_a_structural_draft_and_never_overwrites(
    initialization_catalog: SchemaCatalog,
) -> None:
    """Dry run plans, write creates, repeat skips; the draft is not completion."""
    io = MemoryService(initialization_catalog)
    # The local Git identity must be the repository the initialization names.
    io.repository.checkout = RepositoryIdentity(
        id="source-repository", revision="a" * 40
    )
    for name in (PRODUCTION_ROOT, TEST_ROOT, DOCUMENTATION_ROOT):
        io.disk.store.metadata.add(name, kind="directory")
    before = dict(io.disk.store.files)

    planned = invoke(io, "init", INIT_INPUTS, dry_run=True)
    assert planned.ok, planned.findings
    assert planned.artifacts and io.disk.store.files == before
    assert all(row.status == "planned" for row in planned.artifacts)

    created = invoke(io, "init", INIT_INPUTS)
    assert created.ok, created.findings
    assert {row.status for row in created.artifacts} == {"created"}
    assert DEFAULT_PROFILE in io.disk.store.files
    written = dict(io.disk.store.files)

    # A second initialization must not replace a single byte of the draft.
    repeated = invoke(io, "init", INIT_INPUTS)
    assert repeated.ok, repeated.findings
    assert io.disk.store.files == written
    assert "created" not in {row.status for row in repeated.artifacts}

    # The draft is structurally valid, and that is all it is.
    profile = invoke(io, "validate-profile", {"input_path": DEFAULT_PROFILE})
    assert profile.ok and profile.exit_code == 0
    draft = json.loads(io.disk.store.files[DEFAULT_PROFILE])
    assert draft["profile_state"] == "draft"


def test_draft_workspace_cannot_claim_completion_or_planning(
    initialization_catalog: SchemaCatalog,
    initialization_templates: InitializationTemplates,
) -> None:
    """An activated but incomplete workspace fails discovery and planning honestly."""
    io = workspace(initialization_catalog, initialization_templates)
    for mode in ("discovery-complete", "parity-complete", "planning"):
        result = validate(io, mode)
        assert not result.ok and result.exit_code == 1, (mode, result.findings)
        assert result.summary["validation_result"] == "fail"
        assert any(item.severity == "error" for item in result.findings)
    assert validate(io, "structural").ok


def test_inventory_publishes_a_current_snapshot_and_repeats_identically(
    source: MemoryService,
) -> None:
    """Dry run previews, write publishes, a repeat run reproduces the same bytes."""
    path = f"{PRODUCTION_ROOT}/Program.cs"
    source.disk.store.put(path, b"class Program { }\n")
    source.repository.files[path] = source.disk.store.files[path]
    before = dict(source.disk.store.files)

    preview = invoke(source, "inventory", {"analyzer_ids": ["repository"]})
    assert preview.exit_code in (0, 1) and source.disk.store.files == before
    assert all(row.status == "planned" for row in preview.artifacts)

    published = invoke(
        source, "inventory", {"analyzer_ids": ["repository"]}, write=True
    )
    assert published.ok, published.findings
    snapshot_rows = [r for r in published.artifacts if r.kind == "inventory-snapshot"]
    assert len(snapshot_rows) == 1 and snapshot_rows[0].status == "created"
    stored = source.disk.store.files[snapshot_rows[0].path]
    assert json.loads(stored)["repository"] == "source-repository"

    again = invoke(source, "inventory", {"analyzer_ids": ["repository"]}, write=True)
    assert again.ok, again.findings
    assert source.disk.store.files[snapshot_rows[0].path] == stored


def test_contract_scenario_evidence_and_reports_stay_honest(
    source: MemoryService,
) -> None:
    """Drafts, plans and links succeed while completion and readiness stay false."""
    contract = invoke(source, "new-contract", {"feature_id": "feature", "name": "F"})
    assert contract.ok, contract.findings
    kinds = {row.kind for row in contract.artifacts}
    # The draft carries its open question into the unspecified-behavior collection.
    assert {"feature-contract", "unspecified-behavior-collection"} <= kinds

    # A planned scenario records an unknown expectation and no run.
    source.disk.store.put("proposals/scenario.json", canonical_json(scenario_fields()))
    scenario = invoke(
        source,
        "new-scenario",
        {
            "scenario_id": "observe",
            "feature_ids": ["feature"],
            "input_path": "proposals/scenario.json",
        },
    )
    assert scenario.ok, scenario.findings
    row = next(
        r for r in scenario.artifacts if r.kind == "runtime-characterization-scenario"
    )
    planned = json.loads(source.disk.store.files[row.path])
    assert planned["result_status"] == "not-run" and planned["expected_result"] is None

    # Evidence links require the exact captured target digest and payload bytes.
    baseline = capture(source)
    payload_path = f"{DOCUMENTATION_ROOT}/capture.txt"
    link = request_for(
        baseline,
        updates={
            "path": payload_path,
            "revision": baseline.snapshot.profile.repository.revision,
            "runtime_artifact": {"path": payload_path, "capture_method": "manual"},
        },
    )
    source.disk.store.put(payload_path, link.payloads[0].content)
    source.disk.store.put("proposals/evidence.json", canonical_json(link.record))
    link_inputs = {
        "artifact_kind": "feature-contract",
        "artifact_id": "feature",
        "expected_sha256": link.expected_sha256,
        "evidence_path": "proposals/evidence.json",
    }
    stale = invoke(
        source, "link-evidence", {**link_inputs, "expected_sha256": "0" * 64}
    )
    assert not stale.ok and stale.exit_code in (1, 2)
    linked = invoke(source, "link-evidence", link_inputs)
    assert linked.ok, linked.findings
    assert any(r.kind == "evidence-reference" for r in linked.artifacts)

    # The graph is still incomplete: the question is open and no scope is confirmed.
    incomplete = validate(source, "discovery-complete")
    assert not incomplete.ok and incomplete.exit_code == 1
    assert incomplete.summary["validation_result"] == "fail"

    # Reports and acceptance preview the honest state without any ready criterion.
    report = invoke(source, "completion-report", mode="discovery-complete", write=True)
    assert report.exit_code in (0, 1) and report.artifacts
    coverage = invoke(source, "coverage-report", format="both")
    assert coverage.exit_code in (0, 1) and coverage.input_manifest is not None
    acceptance = invoke(
        source, "generate-acceptance", {"acceptance_kind": "legacy-characterization"}
    )
    assert acceptance.exit_code in (0, 1)
    assert all(r.status == "planned" for r in acceptance.artifacts)
    # No generated specification may claim readiness while the question is open.
    assert '"readiness": "ready"' not in json.dumps(acceptance.to_dict())


def test_confirmed_scope_with_evidence_completes_and_admits_planning(
    initialization_catalog: SchemaCatalog,
    initialization_templates: InitializationTemplates,
) -> None:
    """A confirmed, evidence-backed scope passes discovery, parity and planning."""
    io = seeded_workspace(
        initialization_catalog, no_scope_snapshot(initialization_catalog)
    )
    discovery = validate(io, "discovery-complete")
    assert discovery.ok, discovery.findings
    assert discovery.summary["validation_result"] == "pass"
    assert discovery.input_manifest is not None
    first_digest = discovery.input_manifest.sha256
    for mode in ("parity-complete", "planning"):
        result = validate(io, mode)
        assert result.ok and result.summary["validation_result"] == "pass", mode
        assert result.input_manifest is not None
        assert result.input_manifest.sha256 == first_digest
    report = invoke(io, "completion-report", mode="discovery-complete", format="both")
    assert report.ok, report.findings


@pytest.mark.parametrize(
    "fault", ["malformed", "unreferenced", "stale-profile", "stale-payload"]
)
def test_negative_states_never_produce_a_passing_gate(
    initialization_catalog: SchemaCatalog,
    initialization_templates: InitializationTemplates,
    fault: str,
) -> None:
    """Malformed, unreferenced or stale inputs fail closed in every gate mode."""
    snapshot = no_scope_snapshot(initialization_catalog)
    io = seeded_workspace(initialization_catalog, snapshot)
    assert validate(io, "discovery-complete").ok
    ledger = snapshot.profile.artifacts["coverage_ledger"]
    if fault == "malformed":
        io.disk.store.put(ledger, b"{")
    elif fault == "unreferenced":
        io.disk.store.put(
            snapshot.profile.artifacts["root"] + "/evidence/extra.json", b"{}"
        )
    elif fault == "stale-profile":
        profile = json.loads(io.disk.store.files[DEFAULT_PROFILE])
        profile["system"]["name"] = "Edited after activation"
        io.disk.store.put(DEFAULT_PROFILE, json.dumps(profile).encode("utf-8"))
    else:
        payload = next(f for f in snapshot.manifest.files if f.category == "evidence")
        io.disk.store.put(payload.path, payload.content + b" tampered")
    # A stale profile is an authority disagreement (exit 2 or 3); the other faults are
    # validation failures (exit 1). None of them is ever a pass.
    for mode in ("structural", "discovery-complete", "planning"):
        result = validate(io, mode)
        assert not result.ok and result.exit_code in (1, 2, 3), (mode, fault)
        assert result.summary.get("validation_result") != "pass"
        assert codes(result), (mode, fault)


@pytest.mark.parametrize(
    "case,expected",
    [
        ({"operation": "unknown"}, 2),
        ({"operation": "profile", "mode": "parity-complete"}, 2),
        ({"operation": "validate-all", "inputs": {"shell": "x"}}, 2),
        ({"operation": "validate-all", "principal": "host"}, 3),
        ({"operation": "doctor", "runtime_error": True}, 3),
    ],
)
def test_exit_codes_map_rejections_and_unavailability_distinctly(
    source: MemoryService, case: dict[str, object], expected: int
) -> None:
    """Usage rejections exit 2 and authority or runtime failures exit 3; never 0."""
    fields = dict(case)
    operation = str(fields.pop("operation"))
    if fields.pop("principal", None) == "host":
        source.principal = "host"
    if fields.pop("runtime_error", False):
        source.runtime_error = True
    before = dict(source.disk.store.files)
    result = invoke(source, operation, **fields)
    assert result.exit_code == expected and not result.ok
    assert source.disk.store.files == before and source.writer_calls == 0
