"""Prove the host-principal completion path end to end in memory.

A root prepares the baseline, the synthetic protected partition records the
started invocation, both attestations, the consumed one-use authorizations and
the baseline result, and the host principal then reads a selected source,
publishes its granted outputs and finalizes with a passing result; a drifted
non-output input and an unconsumed authorization are refused with exit 3. The
shared vectors live in tests/fixtures/discovery_host/host-workflow.json.
"""

from __future__ import annotations

import json
from dataclasses import dataclass
from datetime import datetime, timezone
from hashlib import sha256
from pathlib import Path
from typing import TYPE_CHECKING, cast

from drm_copilot_discovery.analyzer.registry import InstalledInventoryRegistry
from drm_copilot_discovery.configuration import DEFAULT_PROFILE
from drm_copilot_discovery.draft_contracts import ContractDraft, contract_changes
from drm_copilot_discovery.gateway_host import HostServiceIO
from drm_copilot_discovery.models import JsonObject, ParseLimits, canonical_json
from drm_copilot_discovery.mutation_io import capture_workspace
from drm_copilot_discovery.report_models import bounded_object
from drm_copilot_discovery.service import execute

from tests.discovery_runtime.gateway_host_test_support import (
    INVOCATION,
    NEW_OUTPUT,
    NOW,
    SOURCE,
    HostCase,
    host_case,
    output_row,
)
from tests.discovery_runtime.test_service import (
    initialization_catalog as initialization_catalog,
)
from tests.discovery_runtime.test_service import (
    initialization_templates as initialization_templates,
)
from tests.discovery_runtime.test_service import service_io as service_io
from tests.discovery_runtime.test_service import service_plan as service_plan
from tests.schemas.discovery.v2_control_test_support import control_fixture

if TYPE_CHECKING:
    from drm_copilot_discovery.service_contracts import DiscoveryResult

    from tests.discovery_runtime.test_service import MemoryService

VECTORS = json.loads(
    (
        Path(__file__).resolve().parents[1]
        / "fixtures"
        / "discovery_host"
        / "host-workflow.json"
    ).read_text(encoding="utf-8")
)
AUTHORIZATIONS = cast("dict[str, dict[str, str]]", VECTORS["authorizations"])
QUESTIONS = "docs/migration/discovery/unspecified-behaviors.yaml"
PROPOSAL = "proposals/feature-beta.json"


@dataclass
class Workflow:
    """Bind the prepared case to the paths and digests the transitions assert."""

    case: HostCase
    beta_path: str
    manifest_path: str
    beta_before: str
    revised: bytes


def reference(name: str) -> str:
    """Return the fixture's authorization reference for transition name (str)."""
    return AUTHORIZATIONS[name]["authorization_ref"]


def fresh_process(case: HostCase, service_io: MemoryService) -> HostServiceIO:
    """Return a new host composition over the case's partition, as a new process has."""
    return HostServiceIO(
        activation=service_io.activation,
        repository=service_io.repository,
        principal=case.io.principal,
        store=case.store,
        clock=lambda: NOW,
        runtime_identity=service_io.runtime_identity,
    )


def run(
    case: HostCase,
    operation: str,
    inputs: dict[str, object] | None = None,
    *,
    authorization: str,
    write: bool = False,
    io: HostServiceIO | None = None,
) -> DiscoveryResult:
    """Execute operation as the host principal through the real service.

    The request names the partition's invocation and the given authorization;
    the clock and analyzer registry are the deterministic ones every memory
    suite uses. io (HostServiceIO | None) replaces the case's composition when a
    later gateway process is simulated. No file, process or network is involved.
    """
    request: dict[str, object] = {
        "$schema": "urn:drm-copilot:discovery:2.0.0:service-request",
        "schema_version": "2.0.0",
        "artifact_kind": "service-request",
        "id": "request",
        "request_id": "correlation",
        "operation": operation,
        "mode": "agent-output",
        "workspace_root": case.service.disk.root,
        "profile_path": None,
        "dry_run": False,
        "write": write,
        "format": "json",
        "inputs": inputs or {},
        "invocation_ref": INVOCATION,
        "authorization_ref": authorization,
    }
    return execute(
        bounded_object(request, limits=ParseLimits()),
        io=case.io if io is None else io,
        repository_reader=case.service.repository,
        clock=lambda: datetime(2026, 10, 20, tzinfo=timezone.utc),
        analyzer_registry=InstalledInventoryRegistry(),
    )


def workflow(service_io: MemoryService) -> Workflow:
    """Seed the workspace, prepare the baseline and write the protected partition.

    An existing valid contract (feature-beta) and its replacement proposal are
    present before preparation, so the proposal is a pinned input rather than a
    drift. The prepared rows are the new contract, the question collection, the
    existing contract and the stored manifest mirror, each granted to the host.
    """
    store = service_io.disk.store
    captured = capture_workspace(
        workspace_root=service_io.disk.root,
        profile_path=DEFAULT_PROFILE,
        metadata=store.metadata,
        read_bytes=store.read,
        catalog=service_io.initialization.catalog,
        repository=service_io.repository,
    )
    beta_path = ""
    # Seed the accepted draft of the existing contract and its linked question.
    for change in contract_changes(
        captured, ContractDraft(feature_id="feature-beta", name="Feature Beta")
    ):
        store.put(change.path, change.content)
        if change.artifact_kind == "feature-contract":
            beta_path = change.path
    revised_document = json.loads(store.files[beta_path])
    revised_document["name"] = "Feature Beta (revised)"
    revised = json.dumps(revised_document).encode("utf-8")
    store.put(PROPOSAL, revised)
    captured = capture_workspace(
        workspace_root=service_io.disk.root,
        profile_path=DEFAULT_PROFILE,
        metadata=store.metadata,
        read_bytes=store.read,
        catalog=service_io.initialization.catalog,
        repository=service_io.repository,
    )
    questions = next(
        item for item in captured.snapshot.artifacts if item.path == QUESTIONS
    )
    assert questions.document is not None
    manifest_path = (
        captured.snapshot.profile.artifacts["reports"]
        + "/required-output-manifest.json"
    )
    beta_before = sha256(store.files[beta_path]).hexdigest()
    rows: list[dict[str, object]] = [
        output_row(NEW_OUTPUT, "feature-alpha", None),
        {
            "artifact_kind": "unspecified-behavior-collection",
            "id": questions.document["id"],
            "path": QUESTIONS,
            "format": "yaml",
            "expected_sha256": sha256(store.files[QUESTIONS]).hexdigest(),
        },
        output_row(beta_path, "feature-beta", beta_before),
        {
            "artifact_kind": "required-output-manifest",
            "id": control_fixture("required-output-manifest")["id"],
            "path": manifest_path,
            "format": "json",
            "expected_sha256": None,
        },
    ]
    case = host_case(service_io, outputs=rows)
    # The host mirrors the exact invocation manifest into the granted report path.
    invocation = json.loads(case.store.files[f"{case.directory}/invocation.json"])
    store.put(
        manifest_path,
        canonical_json(
            bounded_object(
                cast("dict[str, object]", invocation["required_outputs"]),
                limits=ParseLimits(),
            )
        ),
    )
    # One consumed one-use grant per controlled transition the host performs.
    for name in ("read-source", "new-contract", "update-artifact", "finalize-agent"):
        case.authorization(
            reference(name), tool=AUTHORIZATIONS[name]["tool"], operation=name
        )
    return Workflow(case, beta_path, manifest_path, beta_before, revised)


def test_host_workflow_completes_and_refuses_drift_and_unconsumed_grants(
    service_io: MemoryService,
) -> None:
    """Every fixture transition passes in order and every fixture refusal exits 3."""
    flow = workflow(service_io)
    case, store = flow.case, service_io.disk.store
    expected = {cast("str", row["name"]): row for row in VECTORS["python_transitions"]}
    refusals = {cast("str", row["name"]): row for row in VECTORS["python_refusals"]}
    final = VECTORS["finalize_result"]

    read = run(
        case,
        "read-source",
        {"read_operation": "read", "paths": [SOURCE]},
        authorization=reference("read-source"),
    )
    created = run(
        case,
        "new-contract",
        {"feature_id": "feature-alpha", "name": "Feature Alpha"},
        authorization=reference("new-contract"),
        write=True,
    )
    updated = run(
        case,
        "update-artifact",
        {
            "artifact_kind": "feature-contract",
            "artifact_path": flow.beta_path,
            "input_path": PROPOSAL,
            "expected_sha256": flow.beta_before,
            "update_action": "replace",
        },
        authorization=reference("update-artifact"),
        write=True,
    )
    finalized = run(case, "finalize-agent", authorization=reference("finalize-agent"))

    # Transitions: the exit codes follow the fixture and the effects are real.
    assert read.exit_code == expected["read-source"]["exit_code"], read.findings
    reads = read.summary["source_reads"]
    assert isinstance(reads, tuple) and len(reads) == 1
    first = reads[0]
    assert isinstance(first, JsonObject) and first["path"] == SOURCE
    assert created.exit_code == expected["new-contract"]["exit_code"], created.findings
    assert {row.path for row in created.artifacts} == {NEW_OUTPUT, QUESTIONS}
    assert updated.exit_code == expected["update-artifact"]["exit_code"]
    assert store.files[flow.beta_path] == flow.revised
    assert finalized.exit_code == expected["finalize-agent"]["exit_code"], [
        f"{item.code} {item.artifact_path or ''} {item.message}"
        for item in finalized.findings
    ]
    assert finalized.operation == final["operation"]
    assert finalized.mode == final["mode"]
    assert finalized.ok is final["ok"]
    assert (
        finalized.summary["validation_result"] == final["summary"]["validation_result"]
    )
    assert finalized.summary["receipt_ref"] is None
    assert finalized.summary["invocation_ref"] == VECTORS["identity"]["invocation_id"]
    statuses = {row.path: row.status for row in finalized.artifacts}
    assert statuses[NEW_OUTPUT] == final["artifact_status"]["new_output"]
    assert statuses[flow.manifest_path] == final["artifact_status"]["new_output"]
    assert statuses[flow.beta_path] == final["artifact_status"]["existing_output"]
    assert statuses[QUESTIONS] == final["artifact_status"]["existing_output"]
    # The host writer published the new output; the protected store saw exactly
    # one `.used` latch per dispatched grant and nothing else.
    spent = [
        case.used_latch(reference(name))
        for name in ("read-source", "new-contract", "update-artifact", "finalize-agent")
    ]
    assert NEW_OUTPUT in store.files and case.store.writes == spent

    # Refusal: another gateway process cannot dispatch a latched grant again.
    replayed = run(
        case,
        "read-source",
        {"read_operation": "read", "paths": [SOURCE]},
        authorization=reference("read-source"),
        io=fresh_process(case, service_io),
    )
    assert replayed.exit_code == refusals["replayed-authorization"]["exit_code"]
    assert replayed.findings[0].code == refusals["replayed-authorization"]["code"]
    assert "already dispatched" in replayed.findings[0].message
    assert case.store.writes == spent

    # Refusal: a present but unconsumed grant admits nothing.
    case.authorization(
        reference("unconsumed"),
        tool=AUTHORIZATIONS["unconsumed"]["tool"],
        operation="read-source",
        consumed=False,
        latch=False,
    )
    unconsumed = run(
        case,
        "read-source",
        {"read_operation": "read", "paths": [SOURCE]},
        authorization=reference("unconsumed"),
    )
    assert unconsumed.exit_code == refusals["unconsumed-authorization"]["exit_code"]
    assert unconsumed.findings[0].code == refusals["unconsumed-authorization"]["code"]

    # Refusal: a non-output input changed after preparation is baseline drift.
    store.put(SOURCE, b"public class Order { int Total; }\n")
    service_io.repository.files[SOURCE] = store.files[SOURCE]
    drifted = run(
        case,
        "read-source",
        {"read_operation": "read", "paths": [SOURCE]},
        authorization=reference("read-source"),
    )
    assert drifted.exit_code == refusals["baseline-drift"]["exit_code"]
    assert drifted.findings[0].code == refusals["baseline-drift"]["code"]
    assert case.store.writes == spent
