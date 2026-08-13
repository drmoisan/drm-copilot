"""Positive and negative Codex readiness tests for parallel checkpoints."""

from __future__ import annotations

import copy
import json
from typing import cast

import pytest

from scripts.dev_tools import validate_parallel_codex_readiness as readiness
from scripts.dev_tools.resolve_codex_deployment import resolve_codex_deployment
from scripts.dev_tools.resolve_codex_topology import resolve_codex_topology
from scripts.dev_tools.validate_parallel_codex_readiness import (
    ParallelCodexReadinessEvidence,
)
from scripts.dev_tools.validate_parallel_orchestrator_state import (
    validate_parallel_orchestrator_state_text,
)
from scripts.dev_tools.validate_parallel_planner_state import (
    validate_parallel_planner_state_text,
)
from tests.scripts.dev_tools import (
    test_validate_parallel_orchestrator_state_completion as completion_tests,
)
from tests.scripts.dev_tools.test_validate_parallel_orchestrator_state import (
    item_at as orchestrator_item_at,
)
from tests.scripts.dev_tools.test_validate_parallel_planner_state import (
    build_valid_planner_state,
)
from tests.scripts.dev_tools.test_validate_parallel_planner_state import (
    item_at as planner_item_at,
)

KICKOFF_PATH = "docs/features/parallel/wave-one/parallel-kickoff.md"


def test_readiness_item_paths_seam_covers_all_path_outcomes() -> None:
    """The item path seam handles valid, unsafe, missing, and absolute inputs."""

    validator = getattr(readiness, "_readiness_item_paths", None)
    assert callable(validator), "readiness item-path testability seam must exist"
    valid = {
        "launch_receipt_path": "artifacts/item.launch.json",
        "launch_status_path": "artifacts/item.status.json",
    }
    assert validator(valid, "Checkpoint items[0]") == (
        "artifacts/item.launch.json",
        "artifacts/item.status.json",
        [],
    )
    empty = cast("tuple[str | None, str | None, list[str]]", validator({}, "item"))
    unsafe = cast(
        "tuple[str | None, str | None, list[str]]",
        validator({**valid, "launch_receipt_path": "artifacts\\item.json"}, "item"),
    )
    absolute = cast(
        "tuple[str | None, str | None, list[str]]",
        validator({**valid, "launch_status_path": "/outside.json"}, "item"),
    )
    assert len(empty[2]) == 2
    assert "POSIX path" in unsafe[2][0]
    assert "workspace root" in absolute[2][0]


def test_readiness_low_level_shape_errors_are_complete() -> None:
    """Launch and ledger validators report malformed boundary shapes."""

    non_object = readiness.validate_parallel_launch_provenance(
        None,
        context="item",
        parallel_slug="run",
        item_key=1,
        cohort=0,
        batch=0,
        head_branch="feature/item",
        worktree_path="worktrees/item",
        launch_receipt_path="item.launch.json",
        launch_status_path="item.status.json",
    )
    missing = readiness.validate_parallel_launch_provenance(
        {},
        context="item",
        parallel_slug="run",
        item_key=1,
        cohort=0,
        batch=0,
        head_branch="feature/item",
        worktree_path="worktrees/item",
        launch_receipt_path="item.launch.json",
        launch_status_path="item.status.json",
    )
    assert "must be an object" in non_object[0]
    assert "missing required keys" in missing[0]
    assert readiness.validate_zero_lost_ledger([], context="item")
    ledger = [None, {"gate_id": "", "status": "UNKNOWN"}]
    errors = readiness.validate_zero_lost_ledger(ledger, context="item")
    assert any("must be an object" in error for error in errors)
    assert any("gate_id must be" in error for error in errors)
    assert any("status must be" in error for error in errors)


def test_checkpoint_readiness_skips_unreadable_items_and_non_list_boundary() -> None:
    """Malformed item containers remain owned by shared shape validation."""

    state = _prepared_planner_state()
    evidence = build_evidence(state)
    state["items"] = {}
    assert not readiness.validate_parallel_codex_checkpoint_readiness(
        state, context="item", evidence=evidence
    )
    state["items"] = [None]
    assert not readiness.validate_parallel_codex_checkpoint_readiness(
        state, context="item", evidence=evidence
    )
    state = _prepared_planner_state()
    evidence = build_evidence(state)
    del planner_item_at(state, 0)["branch"]
    errors = readiness.validate_parallel_codex_checkpoint_readiness(
        state, context="item", evidence=evidence
    )
    assert any("branch is required" in error for error in errors)


def _prepared_planner_state() -> dict[str, object]:
    """Return execution-ready planner state with guarded evidence paths."""

    state = build_valid_planner_state()
    state["kickoff_prompt_path"] = KICKOFF_PATH
    for index in (0, 1):
        item = planner_item_at(state, index)
        issue = cast("int", item["issue_num"])
        item.update(
            {
                "complexity_band": "C2",
                "cohort": 0,
                "batch": 0,
                "branch": f"feature/parallel-{issue}",
                "worktree_path": f"C:/worktrees/parallel-{issue}",
                "launch_receipt_path": (
                    f"artifacts/orchestration/parallel-child-launches/"
                    f"wave-one/{issue}.receipt.json"
                ),
                "launch_status_path": (
                    f"artifacts/orchestration/parallel-child-launches/"
                    f"wave-one/{issue}.status.json"
                ),
            }
        )
    return state


def _completed_orchestrator_state() -> dict[str, object]:
    """Return completed state with the same guarded item evidence paths."""

    state = completion_tests.build_completed_state()
    for index in (0, 1):
        item = orchestrator_item_at(state, index)
        issue = cast("int", item["issue_num"])
        item.update(
            {
                "cohort": 0,
                "batch": 0,
                "branch": f"feature/parallel-{issue}",
                "worktree_path": f"C:/worktrees/parallel-{issue}",
                "launch_receipt_path": (
                    f"artifacts/orchestration/parallel-child-launches/"
                    f"wave-one/{issue}.receipt.json"
                ),
                "launch_status_path": (
                    f"artifacts/orchestration/parallel-child-launches/"
                    f"wave-one/{issue}.status.json"
                ),
            }
        )
    return state


def _routing_receipts(item_key: int) -> tuple[dict[str, object], dict[str, object]]:
    """Return resolver-produced topology and model receipts for one item."""

    topology = dict(resolve_codex_topology(["python"], 1, 1, "standalone"))
    topology["phase"] = f"parallel-item-{item_key}"
    logical_agent = cast("str", topology["logical_agent"])
    model = dict(resolve_codex_deployment(logical_agent, "C2", "standalone", "C4"))
    model["phase"] = f"parallel-item-{item_key}"
    return topology, model


def _cohort_and_batch(state: dict[str, object], item_key: int) -> tuple[int, int]:
    """Return the builder item's deterministic cohort and bounded batch."""

    cohorts = cast("list[dict[str, object]]", state["cohorts"])
    maximum = cast("int", state["max_concurrency"])
    for cohort in cohorts:
        item_keys = sorted(cast("list[int]", cohort["item_keys"]))
        if item_key in item_keys:
            return cast("int", cohort["index"]), item_keys.index(item_key) // maximum
    return 0, 0


def build_evidence(
    state: dict[str, object], *, lost: bool = False
) -> ParallelCodexReadinessEvidence:
    """Return valid external launch, status, receipt, kickoff, and ledger data."""

    launch_records: dict[str, object] = {}
    status_records: dict[str, object] = {}
    receipt_records: dict[str, object] = {}
    for item in cast("list[dict[str, object]]", state["items"]):
        item_key = cast("int", item["issue_num"])
        receipt_path = cast("str", item["launch_receipt_path"])
        status_path = cast("str", item["launch_status_path"])
        authority_path = f"{receipt_path}.authority"
        delegation_path = f"{receipt_path}.delegation"
        topology_path = f"{receipt_path}.topology"
        model_path = f"{receipt_path}.model-routing"
        cohort, batch = _cohort_and_batch(state, item_key)
        topology, model = _routing_receipts(item_key)
        launch_records[receipt_path] = {
            "schema_version": 2,
            "surface": "parallel",
            "parallel_slug": state["parallel_slug"],
            "item_key": item_key,
            "cohort": cohort,
            "batch": batch,
            "base_branch": "main",
            "pr_target": "main",
            "head_branch": item["branch"],
            "worktree_path": item["worktree_path"],
            "deployment_agent": model["deployment_agent"],
            "model": model["model"],
            "model_reasoning_effort": model["model_reasoning_effort"],
            "permissions": "orchestrator-workspace",
            "authority_receipt_path": authority_path,
            "delegation_receipt_path": delegation_path,
            "topology_receipt_path": topology_path,
            "model_routing_receipt_path": model_path,
            "launch_receipt_path": receipt_path,
            "launch_status_path": status_path,
            "launch_spec_sha256": "a" * 64,
        }
        status_records[status_path] = {
            "schema_version": 2,
            "state": "completed",
            "launch_receipt_path": receipt_path,
        }
        receipt_records[authority_path] = {
            "schema_version": 1,
            "surface": "parallel",
            "parallel_slug": state["parallel_slug"],
            "item_key": item_key,
            "authorized": True,
        }
        receipt_records[delegation_path] = {
            "delegation_id": f"parallel-{item_key}",
            "agent_name": model["deployment_agent"],
        }
        receipt_records[topology_path] = topology
        receipt_records[model_path] = model
    return ParallelCodexReadinessEvidence(
        launch_records=launch_records,
        status_records=status_records,
        receipt_records=receipt_records,
        enforceability_ledger=[
            {
                "gate_id": "G01",
                "status": "LOST" if lost else "PRESERVED",
            }
        ],
        kickoff_identity={
            "schema_version": 1,
            "path": KICKOFF_PATH,
            "plan_home_ref": "origin/parallel/wave-one-plan",
            "planning_commit": "b" * 40,
            "blob_sha256": "c" * 64,
            "worktree_sha256": "c" * 64,
        },
    )


def _planner_errors(
    state: dict[str, object], evidence: ParallelCodexReadinessEvidence | None
) -> list[str]:
    return validate_parallel_planner_state_text(
        json.dumps(state),
        require_ready_for_execution=True,
        readiness_context=evidence,
    )


def _completion_errors(
    state: dict[str, object], evidence: ParallelCodexReadinessEvidence | None
) -> list[str]:
    return validate_parallel_orchestrator_state_text(
        json.dumps(state), require_complete=True, readiness_context=evidence
    )


def test_legacy_checkpoints_remain_valid_without_explicit_codex_gate() -> None:
    """Absent Codex launch fields remain compatible outside readiness gates."""

    assert (
        validate_parallel_planner_state_text(json.dumps(build_valid_planner_state()))
        == []
    )
    assert (
        validate_parallel_orchestrator_state_text(
            json.dumps(completion_tests.build_completed_state())
        )
        == []
    )


def test_explicit_planner_readiness_accepts_complete_external_evidence() -> None:
    """Prepared items and committed kickoff identity satisfy the ready gate."""

    state = _prepared_planner_state()

    assert _planner_errors(state, build_evidence(state)) == []


def test_explicit_orchestrator_completion_accepts_external_evidence() -> None:
    """Completed items with valid launch provenance satisfy completion."""

    state = _completed_orchestrator_state()

    assert _completion_errors(state, build_evidence(state)) == []


@pytest.mark.parametrize("gate", ["planner", "orchestrator"])
def test_explicit_gate_fails_closed_without_external_evidence(gate: str) -> None:
    """An explicit ready or complete request cannot omit its evidence context."""

    state = (
        _prepared_planner_state()
        if gate == "planner"
        else _completed_orchestrator_state()
    )
    errors = (
        _planner_errors(state, None)
        if gate == "planner"
        else _completion_errors(state, None)
    )

    assert any("Codex readiness evidence is required" in error for error in errors)


@pytest.mark.parametrize(
    ("collection", "suffix", "expected"),
    [
        ("launch_records", "", "external launch record"),
        ("status_records", "", "external launch status"),
        ("receipt_records", ".authority", "authority receipt"),
        ("receipt_records", ".topology", "topology receipt"),
        ("receipt_records", ".model-routing", "model-routing receipt"),
    ],
)
def test_missing_external_record_or_referenced_receipt_is_rejected(
    collection: str, suffix: str, expected: str
) -> None:
    """Every guarded path must resolve to its expected external document."""

    state = _prepared_planner_state()
    evidence = build_evidence(state)
    item = planner_item_at(state, 0)
    receipt_path = cast("str", item["launch_receipt_path"])
    records = cast("dict[str, object]", getattr(evidence, collection))
    base_path = (
        cast("str", item["launch_status_path"])
        if collection == "status_records"
        else receipt_path
    )
    del records[f"{base_path}{suffix}"]

    assert any(expected in error for error in _planner_errors(state, evidence))


def test_mismatched_launch_path_binding_is_rejected() -> None:
    """A record cannot name another item's guarded launch-status path."""

    state = _prepared_planner_state()
    evidence = build_evidence(state)
    receipt_path = cast("str", planner_item_at(state, 0)["launch_receipt_path"])
    record = cast("dict[str, object]", evidence.launch_records[receipt_path])
    record["launch_status_path"] = "artifacts/orchestration/other.status.json"

    assert any(
        "launch_status_path must be" in error
        for error in _planner_errors(state, evidence)
    )


@pytest.mark.parametrize(
    "foreign_key", ["epic_slug", "integration_branch", "fan_in_pr"]
)
def test_epic_or_fan_in_contamination_is_rejected(foreign_key: str) -> None:
    """Standalone parallel state fails closed on structurally mixed state."""

    state = _prepared_planner_state()
    state[foreign_key] = "forbidden"

    assert any(
        f"prohibited epic or fan-in key at {foreign_key}" in error
        for error in _planner_errors(state, build_evidence(state))
    )


def test_nonzero_lost_ledger_blocks_readiness() -> None:
    """One LOST gate blocks explicit parallel readiness."""

    state = _prepared_planner_state()

    assert any(
        "status LOST blocks parallel readiness" in error
        for error in _planner_errors(state, build_evidence(state, lost=True))
    )


def test_mismatched_model_receipt_binding_is_rejected() -> None:
    """Launch identity must equal the referenced model-routing receipt."""

    state = _prepared_planner_state()
    evidence = build_evidence(state)
    receipt_path = cast("str", planner_item_at(state, 0)["launch_receipt_path"])
    record = cast("dict[str, object]", evidence.launch_records[receipt_path])
    record["model"] = "gpt-5.6-sol"

    assert any(
        "model must match model-routing receipt" in error
        for error in _planner_errors(state, evidence)
    )


def test_evidence_validation_does_not_mutate_state_or_evidence() -> None:
    """Pure readiness validation leaves both inputs unchanged."""

    state = _prepared_planner_state()
    evidence = build_evidence(state)
    state_snapshot = copy.deepcopy(state)
    evidence_snapshot = copy.deepcopy(evidence)

    _planner_errors(state, evidence)

    assert state == state_snapshot
    assert evidence == evidence_snapshot
