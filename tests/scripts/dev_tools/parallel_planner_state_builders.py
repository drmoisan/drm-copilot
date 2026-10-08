"""Checkpoint builders shared by the parallel-planner validator test suites.

This non-test support module holds the planner-checkpoint builders so that the
P1 to P9 suite and the P10 routing suite build the same payload. Every item a
builder returns carries the per-item routing record (``complexity_band``,
``complexity_assessment``, and ``model_routing_receipt``) that ready-gate
invariant P10 requires. The module name does not begin with ``test_``, so
pytest does not collect it, and it never imports from a test module that
imports it, so no circular import exists.
"""

from __future__ import annotations

import copy

from tests.scripts.dev_tools.test_validate_parallel_orchestrator_state import (
    build_blast_radius,
)

# The kickoff path invariant P9 pins for the builder's slug (assumption A6).
EXPECTED_KICKOFF = "artifacts/orchestration/parallel-kickoff-wave-one.md"

_ROUTING_FIELDS: dict[str, object] = {
    "complexity_band": "C3",
    "complexity_assessment": {
        "band": "C3",
        "floor": "C3",
        "signals_present": ["cross_module_contract_change"],
        "rationale": "Changes a validator contract shared across modules.",
        "assessed_at": "2026-08-07T10-00",
    },
    "model_routing_receipt": {
        "agent": "orchestrator",
        "phase": "execution",
        "complexity_band": "C3",
        "fable_policy": "available",
        "table_model": "opus",
        "clamped_from": None,
        "model": "opus",
    },
}


def build_routing_fields() -> dict[str, object]:
    """Return a fresh copy of the three per-item routing fields.

    The copy is deep, so a test that mutates the nested assessment or receipt
    of one item never affects another item or a later test.
    """

    return copy.deepcopy(_ROUTING_FIELDS)


def build_item(issue_num: int, slug: str) -> dict[str, object]:
    """Return one fully prepared, preflight-cleared planner item."""

    return {
        "issue_num": issue_num,
        "feature_folder": f"2026-08-07-{slug}-{issue_num}",
        "kind": "feature",
        "state": "prepared",
        "blast_radius": build_blast_radius(),
        "preparation_status": "prepared",
        "research_path": f"docs/features/active/{slug}/research.md",
        "plan_path": f"docs/features/active/{slug}/plan.md",
        "preflight_status": "PREFLIGHT: ALL CLEAR",
        **build_routing_fields(),
    }


def build_valid_planner_state() -> dict[str, object]:
    """Return a minimally valid, execution-ready planner checkpoint payload.

    Two prepared items sit in one current-generation cohort with no conflict
    edges, so a test can mutate one field and attribute any resulting error to
    that mutation. The payload also satisfies the readiness gate, so the same
    builder serves both the gate-off and gate-on cases.
    """

    return {
        "objective": "prepare parallel run wave-one",
        "parallel_slug": "wave-one",
        "parallel_manifest_path": "docs/features/parallel/wave-one/parallel.md",
        "mode": "closed",
        "max_concurrency": 4,
        "items": [
            build_item(444, "parallel-schema-validators"),
            build_item(445, "parallel-cohort-scheduler"),
        ],
        "cohorts": [{"index": 0, "generation": 0, "item_keys": [444, 445]}],
        "conflict_edges": [],
        "recolor_generation": 0,
        "completed_steps": ["manifest_parsed"],
        "next_step": "PARALLEL_EXECUTION_READY",
        "last_updated": "2026-08-07T10-00",
        "kickoff_prompt_path": EXPECTED_KICKOFF,
    }
