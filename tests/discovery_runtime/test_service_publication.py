"""Verify service planning and publication with real validators and memory I/O."""

from __future__ import annotations

import json
from hashlib import sha256
from typing import TYPE_CHECKING

import pytest
from drm_copilot_discovery.configuration import DEFAULT_PROFILE
from drm_copilot_discovery.draft_contracts import ContractDraft, contract_changes
from drm_copilot_discovery.models import canonical_json
from drm_copilot_discovery.mutation_io import capture_workspace
from drm_copilot_discovery.path_models import WriteGrant

from tests.discovery_runtime.evidence_test_support import request_for
from tests.discovery_runtime.test_draft_scenarios import scenario_fields
from tests.discovery_runtime.test_migration_v1 import source_for
from tests.discovery_runtime.test_service import (
    MemoryService,
    invoke,
)
from tests.discovery_runtime.test_service import (
    initialization_catalog as initialization_catalog,
)
from tests.discovery_runtime.test_service import (
    initialization_templates as initialization_templates,
)
from tests.discovery_runtime.test_service import (
    service_io as service_io,
)
from tests.discovery_runtime.test_service import (
    service_plan as service_plan,
)

if TYPE_CHECKING:
    from drm_copilot_discovery.catalog import SchemaCatalog


def seed_contract(io: MemoryService) -> str:
    """Seed an accepted draft in memory io; return its exact path (str).

    Setup uses the public pure draft producer and preserves every linked proposal.
    It claims no publication, completion or execution and uses no external I/O.
    """
    captured = capture_workspace(
        workspace_root=io.disk.root,
        profile_path=DEFAULT_PROFILE,
        metadata=io.disk.store.metadata,
        read_bytes=io.disk.store.read,
        catalog=io.initialization.catalog,
        repository=io.repository,
    )
    changes = contract_changes(
        captured, ContractDraft(feature_id="feature", name="Feature")
    )
    # Copy the complete accepted setup proposal, including its unresolved question.
    for change in changes:
        io.disk.store.put(change.path, change.content)
    return changes[0].path


@pytest.mark.parametrize("dry_run", [True, False])
def test_new_contract_uses_real_plan_and_honest_file_effects(
    service_io: MemoryService,
    dry_run: bool,
) -> None:
    """Create with explicit dry_run in memory; return None with exact file effects."""
    before = dict(service_io.disk.store.files)
    result = invoke(
        service_io,
        "new-contract",
        {"feature_id": "feature", "name": "Feature"},
        dry_run=dry_run,
    )
    assert result.ok, result.findings
    assert service_io.writer_calls == 1 and len(result.artifacts) == 2
    if dry_run:
        assert service_io.disk.store.files == before
        assert all(row.status in ("planned", "skipped") for row in result.artifacts)
    else:
        assert any(row.kind == "feature-contract" for row in result.artifacts)
        assert all(
            sha256(service_io.disk.store.files[row.path]).hexdigest() == row.sha256
            for row in result.artifacts
        )


@pytest.mark.parametrize("grant_case", ["extra", "wrong-id", "wrong-path"])
def test_nonempty_provider_grants_are_never_expanded(
    service_io: MemoryService,
    grant_case: str,
) -> None:
    """Reject mismatched grant_case before memory writes; return None."""
    service_io.grants = (
        WriteGrant(
            artifact_kind="feature-contract",
            artifact_id="other" if grant_case == "wrong-id" else "feature",
            path=(
                "outside/feature.json"
                if grant_case == "wrong-path"
                else "docs/migration/discovery/feature-contracts/feature.json"
            ),
        ),
    )
    if grant_case == "extra":
        service_io.grants += (
            WriteGrant(
                artifact_kind="feature-contract",
                artifact_id="extra",
                path="extra.json",
            ),
        )
    before = dict(service_io.disk.store.files)
    result = invoke(
        service_io, "new-contract", {"feature_id": "feature", "name": "Feature"}
    )
    assert result.exit_code == 3 and result.findings[0].code == "SERVICE_AUTHORITY"
    assert service_io.writer_calls == 0 and service_io.disk.store.files == before


@pytest.mark.parametrize(
    "operation", ["coverage-report", "parity-report", "completion-report"]
)
def test_report_preview_and_failed_gate_publication_keep_selected_status(
    service_io: MemoryService,
    operation: str,
) -> None:
    """Publish operation's known failed gate as paired files; return None, memory
    only.
    """
    result = invoke(
        service_io, operation, write=True, mode="discovery-complete", format="both"
    )
    assert result.exit_code == 1 and not result.ok, result.findings
    assert result.summary["validation_result"] == "fail"
    assert len(result.artifacts) == 2 and service_io.writer_calls == 1
    paths = tuple(row.path for row in result.artifacts)
    document = json.loads(
        service_io.disk.store.files[
            next(path for path in paths if path.endswith(".json"))
        ]
    )
    assert document["validation_result"] == "fail"
    assert document["input_sha256"]
    assert all(row.status == "created" for row in result.artifacts)


@pytest.mark.parametrize("format", ["json", "markdown", "both"])
def test_pure_report_format_does_not_publish(
    service_io: MemoryService, format: str
) -> None:
    """Render format (str) from one captured report; return None with no memory
    writes.
    """
    before = dict(service_io.disk.store.files)
    result = invoke(service_io, "coverage-report", format=format)
    assert result.exit_code == 0 and len(result.artifacts) == (
        2 if format == "both" else 1
    )
    assert service_io.writer_calls == 0 and service_io.disk.store.files == before
    assert all(row.content and row.status == "planned" for row in result.artifacts)


def test_validate_all_defaults_to_paired_reports_and_rejects_outside_root(
    service_io: MemoryService,
) -> None:
    """Verify default paired publication and path confinement; return None, memory
    only.
    """
    result = invoke(service_io, "validate-all")
    assert result.ok and len(result.artifacts) == 2
    before = dict(service_io.disk.store.files)
    refused = invoke(service_io, "validate-all", {"output_prefix": "outside/report"})
    assert refused.exit_code == 2 and refused.findings[0].code == "SERVICE_OUTPUT_PATH"
    assert service_io.disk.store.files == before and service_io.writer_calls == 1


def test_malformed_core_cannot_publish_a_diagnostic_report(
    service_io: MemoryService,
) -> None:
    """Retain malformed core blockers without report writes; return None, memory
    only.
    """
    service_io.disk.store.put("docs/migration/discovery/coverage-ledger.json", b"{}")
    before = dict(service_io.disk.store.files)
    result = invoke(service_io, "completion-report", write=True)
    assert result.exit_code == 1 and result.artifacts == () and result.findings
    assert service_io.writer_calls == 0 and service_io.disk.store.files == before


@pytest.mark.parametrize("dry_run", [True, False])
def test_explicit_bootstrap_preserves_actual_directory_and_file_units(
    initialization_catalog: SchemaCatalog,
    dry_run: bool,
) -> None:
    """Initialize empty memory io with dry_run; return None without fake directory
    hashes.
    """
    io = MemoryService(initialization_catalog)
    io.disk.store.metadata.add("application", kind="directory")
    result = invoke(
        io,
        "init",
        {
            "system_id": "consumer-system",
            "system_name": "Consumer system",
            "system_role": "combined",
            "repository_id": "consumer-repository",
            "production_roots": ["application"],
        },
        dry_run=dry_run,
    )
    assert result.ok, result.findings
    assert result.input_manifest is not None
    assert all(row.kind != "directory" for row in result.artifacts)
    assert result.summary["counts"]
    assert (DEFAULT_PROFILE in io.disk.store.files) is not dry_run


@pytest.mark.parametrize("action", ["activate", "deactivate"])
def test_configuration_preserves_protected_effect_accounting(
    service_io: MemoryService,
    action: str,
) -> None:
    """Run explicit action over real memory activation; return None with actual
    counts.
    """
    inputs = {"configuration_action": action}
    if action == "activate":
        inputs["input_path"] = DEFAULT_PROFILE
    result = invoke(service_io, "configure", inputs)
    assert result.ok and result.input_manifest is not None
    assert service_io.configuration.revocations > 0
    assert all(row.kind in ("domain-profile", "activation") for row in result.artifacts)
    assert result.summary["counts"]


def test_scenario_creation_keeps_unknown_expectation_and_unexecuted_state(
    service_io: MemoryService,
) -> None:
    """Create an explicitly supplied scenario plan in memory; return None without
    evidence claims.
    """
    seed_contract(service_io)
    service_io.disk.store.put(
        "proposals/scenario.json", canonical_json(scenario_fields())
    )
    result = invoke(
        service_io,
        "new-scenario",
        {
            "scenario_id": "observe",
            "feature_ids": ["feature"],
            "input_path": "proposals/scenario.json",
        },
    )
    assert result.ok, result.findings
    row = next(
        row
        for row in result.artifacts
        if row.kind == "runtime-characterization-scenario"
    )
    document = json.loads(service_io.disk.store.files[row.path])
    assert (
        document["result_status"] == "not-run" and document["expected_result"] is None
    )
    assert document["runs"] == []


@pytest.mark.parametrize("fault", [None, "stale", "outside", "wrong-kind", "approval"])
def test_exact_replacement_requires_identity_cas_path_and_explicit_approval(
    service_io: MemoryService,
    fault: str | None,
) -> None:
    """Replace a captured contract under fault (str/None); return None, memory only."""
    path = seed_contract(service_io)
    content = service_io.disk.store.files[path]
    document = json.loads(content)
    document["name"] = "Updated feature"
    proposal = json.dumps(document).encode()
    service_io.disk.store.put("proposals/contract.json", proposal)
    before = dict(service_io.disk.store.files)
    inputs: dict[str, object] = {
        "artifact_kind": "scope" if fault == "wrong-kind" else "feature-contract",
        "artifact_path": "outside/contract.json" if fault == "outside" else path,
        "input_path": "proposals/contract.json",
        "expected_sha256": (
            "0" * 64 if fault == "stale" else sha256(content).hexdigest()
        ),
        "update_action": "approve-decision" if fault == "approval" else "replace",
    }
    if fault == "approval":
        inputs.update(approval_owner="operator", approval_evidence_refs=[])
    result = invoke(service_io, "update-artifact", inputs)
    if fault is None:
        assert result.ok and service_io.disk.store.files[path] == proposal
    else:
        assert result.exit_code == 2 and service_io.disk.store.files == before


@pytest.mark.parametrize("kind", ["legacy-characterization", "target-acceptance"])
def test_acceptance_preview_retains_structured_sources_and_pending_views(
    service_io: MemoryService,
    kind: str,
) -> None:
    """Generate kind from actual capture; return None without source execution or
    writes.
    """
    seed_contract(service_io)
    before = dict(service_io.disk.store.files)
    result = invoke(service_io, "generate-acceptance", {"acceptance_kind": kind})
    assert result.exit_code in (0, 1) and result.input_manifest is not None
    assert service_io.writer_calls == 0 and service_io.disk.store.files == before
    assert result.summary["counts"]
    assert all(row.status == "planned" for row in result.artifacts)


@pytest.mark.parametrize("with_report", [False, True])
def test_snapshot_export_uses_authored_identity_and_complete_original_capture(
    service_io: MemoryService,
    with_report: bool,
) -> None:
    """Export a contract with optional derived report; return None after dry-run
    only.
    """
    seed_contract(service_io)
    if with_report:
        assert invoke(service_io, "validate-all").ok
    before = dict(service_io.disk.store.files)
    result = invoke(
        service_io, "snapshot-export", {"selected_ids": ["feature"]}, dry_run=True
    )
    assert result.ok and result.artifacts, result.findings
    assert service_io.disk.store.files == before and result.input_manifest is not None
    report_paths = [
        file.path for file in result.input_manifest.files if "/reports/" in file.path
    ]
    assert bool(report_paths) is with_report


@pytest.mark.parametrize("operation", ["snapshot-import", "import-inventory"])
def test_malformed_captured_transport_never_becomes_publication_authority(
    service_io: MemoryService,
    operation: str,
) -> None:
    """Reject malformed manifest for operation; return None, preserving captured
    memory bytes.
    """
    service_io.disk.store.put("proposals/manifest.json", b"{}")
    before = dict(service_io.disk.store.files)
    result = invoke(service_io, operation, {"manifest_path": "proposals/manifest.json"})
    assert result.exit_code in (1, 2) and not result.artifacts and result.findings
    assert service_io.disk.store.files == before and service_io.writer_calls == 0


def test_failed_initialization_retains_conflicting_path_without_fake_digest(
    initialization_catalog: SchemaCatalog,
) -> None:
    """Reject a preexisting conflicting profile in memory; return None with its path."""
    io = MemoryService(initialization_catalog)
    io.disk.store.put(DEFAULT_PROFILE, b"not a profile")
    result = invoke(
        io,
        "init",
        {
            "system_id": "consumer-system",
            "system_name": "Consumer system",
            "system_role": "combined",
            "repository_id": "consumer-repository",
            "draft": True,
        },
    )
    assert not result.ok and result.artifacts == ()
    assert any(item.artifact_path == DEFAULT_PROFILE for item in result.findings)


@pytest.mark.parametrize("dry_run", [True, False])
def test_migration_uses_explicit_v1_bytes_and_reports_real_effects(
    initialization_catalog: SchemaCatalog, dry_run: bool
) -> None:
    """Migrate explicit legacy bytes in memory with dry_run; return None."""
    io = MemoryService(initialization_catalog)
    source = source_for("coverage-ledger")
    io.disk.store.put(source.path, source.content)
    before = dict(io.disk.store.files)
    result = invoke(
        io,
        "migrate",
        {
            "input_path": source.path,
            "from_version": 1,
            "to_version": 2,
            "destination": "migrated",
            "system_id": "consumer-system",
            "system_name": "Consumer system",
            "system_role": "combined",
            "repository_id": "consumer-repository",
            "draft": True,
        },
        dry_run=dry_run,
    )
    assert result.ok and result.artifacts, result.findings
    assert result.input_manifest is not None
    assert any(file.content == source.content for file in result.input_manifest.files)
    assert (io.disk.store.files == before) is dry_run
    assert all(row.kind != "directory" for row in result.artifacts)


def test_link_evidence_uses_captured_payload_and_exact_target_digest(
    service_io: MemoryService,
) -> None:
    """Link an actual memory payload through public planners; return None."""
    seed_contract(service_io)
    baseline = capture_workspace(
        workspace_root=service_io.disk.root,
        profile_path=DEFAULT_PROFILE,
        metadata=service_io.disk.store.metadata,
        read_bytes=service_io.disk.store.read,
        catalog=service_io.initialization.catalog,
        repository=service_io.repository,
    )
    link = request_for(baseline)
    # Capture each exact payload independently of the proposed evidence descriptor.
    for payload in link.payloads:
        service_io.disk.store.put(payload.path, payload.content)
    service_io.disk.store.put("proposals/evidence.json", canonical_json(link.record))
    result = invoke(
        service_io,
        "link-evidence",
        {
            "artifact_kind": "feature-contract",
            "artifact_id": "feature",
            "expected_sha256": link.expected_sha256,
            "evidence_path": "proposals/evidence.json",
        },
    )
    assert result.ok, result.findings
    assert any(row.kind == "evidence-reference" for row in result.artifacts)
    assert service_io.writer_calls == 1


def test_report_index_view_cannot_hide_an_authored_invalid_reference(
    service_io: MemoryService,
) -> None:
    """Keep a dangling authored reference blocking despite a captured report."""
    path = seed_contract(service_io)
    assert invoke(service_io, "validate-all").ok
    document = json.loads(service_io.disk.store.files[path])
    document["evidence_refs"] = ["validation"]
    service_io.disk.store.put(path, json.dumps(document).encode())
    before = dict(service_io.disk.store.files)
    result = invoke(service_io, "snapshot-export", {"selected_ids": ["feature"]})
    assert result.exit_code in (1, 2) and result.findings and not result.artifacts
    assert service_io.writer_calls == 1 and service_io.disk.store.files == before
