"""Validate the shared semantic-drift corpus against Python authorities."""

from __future__ import annotations

import json
from pathlib import Path
from typing import cast

import pytest

from scripts.dev_tools._parallel_mutation_models import ItemRecord
from scripts.dev_tools.parallel_cohort_computation import compute_concurrency_batches
from scripts.dev_tools.parallel_drift_detection import (
    has_unresolved_drift,
    request_requeue_via_recolor,
)
from scripts.dev_tools.parallel_drift_detection_cli import evaluate_drift
from scripts.dev_tools.parallel_mutation_protocol import (
    decide_admission,
    is_closed_mode_complete,
    recolor_unstarted,
)
from scripts.dev_tools.validate_parallel_orchestrator_state import (
    validate_parallel_orchestrator_state_text,
)

REPO_ROOT = Path(__file__).resolve().parents[3]
FIXTURE_PATH = (
    REPO_ROOT / "tests" / "fixtures" / "parallel-orchestration" / "drift-parity.json"
)
REQUIRED_BEHAVIORS = {
    "quiescence",
    "observed-versus-declared-files",
    "later-started-conflict-halt",
    "unstarted-recoloring",
    "deterministic-requeue",
    "persisted-resolution",
}


def require_mapping(value: object, label: str) -> dict[str, object]:
    """Return an object-shaped fixture value or fail with its path."""
    if not isinstance(value, dict):
        raise TypeError(f"{label} must be a JSON object.")
    return cast("dict[str, object]", value)


def require_list(value: object, label: str) -> list[object]:
    """Return an array-shaped fixture value or fail with its path."""
    if not isinstance(value, list):
        raise TypeError(f"{label} must be a JSON array.")
    return cast("list[object]", value)


def require_text(value: object, label: str) -> str:
    """Return a non-blank fixture string or fail with its path."""
    if not isinstance(value, str) or not value.strip():
        raise TypeError(f"{label} must be a non-empty string.")
    return value


def clone_mapping(value: dict[str, object]) -> dict[str, object]:
    """Return a deterministic JSON-compatible deep copy."""
    return cast("dict[str, object]", json.loads(json.dumps(value, sort_keys=True)))


def load_corpus() -> dict[str, object]:
    """Load and structurally guard the committed drift corpus root."""
    root = require_mapping(
        cast("object", json.loads(FIXTURE_PATH.read_text(encoding="utf-8"))),
        FIXTURE_PATH.name,
    )
    if root.get("schema_version") != 1:
        raise ValueError("drift-parity.json schema_version must equal 1.")
    return root


CORPUS = load_corpus()
CONFIG = require_mapping(CORPUS.get("config"), "config")
BASE_DOCUMENT = require_mapping(CORPUS.get("base_document"), "base_document")
DETECTION_DEFAULTS = require_mapping(
    CORPUS.get("detection_defaults"), "detection_defaults"
)
SCHEDULER_DEFAULTS = require_mapping(
    CORPUS.get("scheduler_defaults"), "scheduler_defaults"
)
CASES = tuple(
    require_mapping(value, f"cases[{index}]")
    for index, value in enumerate(require_list(CORPUS.get("cases"), "cases"))
)
CASE_IDS = [require_text(case.get("name"), "case.name") for case in CASES]


def integer_list(value: object, label: str) -> list[int]:
    """Return a list containing only non-boolean integers."""
    values = require_list(value, label)
    if any(not isinstance(entry, int) or isinstance(entry, bool) for entry in values):
        raise TypeError(f"{label} must contain only integers.")
    return cast("list[int]", values)


def edge_list(value: object, label: str) -> list[tuple[int, int]]:
    """Return two-integer conflict edges from fixture arrays."""
    edges: list[tuple[int, int]] = []
    for index, value_entry in enumerate(require_list(value, label)):
        entry = integer_list(value_entry, f"{label}[{index}]")
        if len(entry) != 2:
            raise TypeError(f"{label}[{index}] must contain exactly two integers.")
        edges.append((entry[0], entry[1]))
    return edges


def materialize_document(case: dict[str, object]) -> dict[str, object]:
    """Apply one case's top-level checkpoint overrides to the shared base."""
    document = clone_mapping(BASE_DOCUMENT)
    document.update(
        clone_mapping(require_mapping(case.get("document_overrides"), "overrides"))
    )
    return document


def detection_items(case: dict[str, object]) -> list[dict[str, object]]:
    """Apply issue-keyed case overrides to the base checkpoint items."""
    document = clone_mapping(BASE_DOCUMENT)
    items = [
        require_mapping(value, f"base_document.items[{index}]")
        for index, value in enumerate(require_list(document.get("items"), "items"))
    ]
    detection = require_mapping(case.get("detection"), "case.detection")
    overrides = require_mapping(detection.get("item_overrides"), "item_overrides")
    for item in items:
        item_key = str(item.get("issue_num"))
        override = overrides.get(item_key)
        if override is not None:
            item.update(require_mapping(override, f"item_overrides.{item_key}"))
    return items


def evaluate_case(case: dict[str, object]) -> dict[str, object]:
    """Evaluate one detection input through the Python drift authority."""
    detection = require_mapping(case.get("detection"), "case.detection")
    item_key = DETECTION_DEFAULTS.get("item_key")
    if not isinstance(item_key, int) or isinstance(item_key, bool):
        raise TypeError("detection_defaults.item_key must be an integer.")
    changed = [
        require_text(value, "detection.changed_paths[]")
        for value in require_list(detection.get("changed_paths"), "changed_paths")
    ]
    return evaluate_drift(
        state={
            "items": detection_items(case),
            "conflict_edges": require_list(
                DETECTION_DEFAULTS.get("conflict_edges"), "conflict_edges"
            ),
        },
        config=CONFIG,
        item_key=item_key,
        changed_paths=changed,
        at=require_text(DETECTION_DEFAULTS.get("at"), "detection_defaults.at"),
        computed_at=require_text(
            DETECTION_DEFAULTS.get("computed_at"),
            "detection_defaults.computed_at",
        ),
    )


def recomputed_schedule() -> dict[str, object]:
    """Render Python recoloring and deterministic batches as fixture JSON."""
    unstarted = integer_list(
        SCHEDULER_DEFAULTS.get("unstarted_keys"), "scheduler.unstarted_keys"
    )
    pinned = frozenset(
        integer_list(SCHEDULER_DEFAULTS.get("pinned_keys"), "scheduler.pinned_keys")
    )
    edges = edge_list(
        SCHEDULER_DEFAULTS.get("conflict_edges"), "scheduler.conflict_edges"
    )
    generation = SCHEDULER_DEFAULTS.get("current_generation")
    current_cohort = SCHEDULER_DEFAULTS.get("current_cohort")
    max_concurrency = SCHEDULER_DEFAULTS.get("max_concurrency")
    if not all(
        isinstance(value, int) and not isinstance(value, bool)
        for value in (generation, current_cohort, max_concurrency)
    ):
        raise TypeError(
            "scheduler generation, cohort, and concurrency must be integers."
        )
    result = recolor_unstarted(
        unstarted,
        edges,
        pinned,
        cast("int", generation),
        current_cohort=cast("int", current_cohort),
    )
    assignments = [
        {"item_key": key, "cohort_index": index}
        for key, index in sorted(result.cohort_assignments.items())
    ]
    grouped: dict[int, list[int]] = {}
    for key, index in result.cohort_assignments.items():
        grouped.setdefault(index, []).append(key)
    batches = [
        batch
        for index in sorted(grouped)
        for batch in compute_concurrency_batches(
            grouped[index], cast("int", max_concurrency)
        )
    ]
    return {
        "generation": result.generation,
        "cohort_assignments": assignments,
        "batches": batches,
    }


def ordered_requeues(result: dict[str, object]) -> list[dict[str, object]]:
    """Render halt requests in ascending item order with threaded generations."""
    halted = integer_list(result.get("halted_item_keys"), "halted_item_keys")
    generation = cast("int", SCHEDULER_DEFAULTS["current_generation"])
    rendered: list[dict[str, object]] = []
    for item_key in halted:
        request = request_requeue_via_recolor(
            halted_item_key=item_key,
            at=require_text(DETECTION_DEFAULTS.get("at"), "detection_defaults.at"),
            current_recolor_generation=generation,
        )
        rendered.append(
            {
                "item_key": request.item_key,
                "merge_status": request.merge_status,
                "state": request.state,
                "mutation": dict(request.mutation),
                "recolor_generation": request.recolor_generation,
            }
        )
        generation = request.recolor_generation
    return rendered


def item_records(document: dict[str, object]) -> dict[int, ItemRecord]:
    """Build mutation-authority item records from a checkpoint document."""
    records: dict[int, ItemRecord] = {}
    for index, value in enumerate(require_list(document.get("items"), "items")):
        item = require_mapping(value, f"items[{index}]")
        key = item.get("issue_num")
        if not isinstance(key, int) or isinstance(key, bool):
            raise TypeError(f"items[{index}].issue_num must be an integer.")
        records[key] = ItemRecord(
            key,
            require_text(item.get("state"), f"items[{index}].state"),
            require_text(item.get("merge_status"), f"items[{index}].merge_status"),
        )
    return records


def decisions(case: dict[str, object]) -> tuple[str, str]:
    """Apply unresolved-drift precedence to admission and completion."""
    document = materialize_document(case)
    events = [
        require_mapping(value, f"drift_events[{index}]")
        for index, value in enumerate(
            require_list(document.get("drift_events"), "drift_events")
        )
    ]
    items = [
        require_mapping(value, f"items[{index}]")
        for index, value in enumerate(require_list(document.get("items"), "items"))
    ]
    if has_unresolved_drift(events, items):
        return ("blocked_unresolved_drift", "blocked_unresolved_drift")

    candidate = SCHEDULER_DEFAULTS.get("admission_candidate")
    if not isinstance(candidate, int) or isinstance(candidate, bool):
        raise TypeError("scheduler.admission_candidate must be an integer.")
    admission = decide_admission(
        candidate,
        edge_list(SCHEDULER_DEFAULTS.get("conflict_edges"), "scheduler.conflict_edges"),
        frozenset(
            integer_list(SCHEDULER_DEFAULTS.get("pinned_keys"), "scheduler.pinned_keys")
        ),
        current_cohort_members=frozenset(
            integer_list(
                SCHEDULER_DEFAULTS.get("current_cohort_members"),
                "scheduler.current_cohort_members",
            )
        ),
    ).outcome.value
    completion = (
        "complete" if is_closed_mode_complete(item_records(document)) else "incomplete"
    )
    return admission, completion


def observed(case: dict[str, object]) -> dict[str, object]:
    """Render all Python-authoritative outputs for one shared case."""
    result = evaluate_case(case)
    event = result.get("drift_event")
    affected = []
    if event is not None:
        event_record = require_mapping(event, "drift_event")
        affected = sorted(
            {
                cast("int", event_record["item_key"]),
                *integer_list(result.get("halted_item_keys"), "halted_item_keys"),
            }
        )
    admission, completion = decisions(case)
    return {
        "normalized_event": event,
        "affected_item_order": affected,
        "recomputed": recomputed_schedule(),
        "ordered_requeues": ordered_requeues(result),
        "admission_decision": admission,
        "completion_decision": completion,
    }


def test_fixture_covers_every_required_drift_behavior() -> None:
    """Require exactly the six drift behaviors named by the plan."""
    behaviors = {require_text(case.get("behavior"), "case.behavior") for case in CASES}
    assert behaviors == REQUIRED_BEHAVIORS


def test_lifecycle_requirements_bind_to_executed_shared_cases() -> None:
    """Require halt, recolor, requeue, resolution, and quiescence coverage."""
    mapping = require_mapping(
        CORPUS.get("lifecycle_requirements"), "lifecycle_requirements"
    )
    assert set(mapping) == {
        "quiescence",
        "later_started_halt",
        "unstarted_recolor",
        "ascending_requeue",
        "persisted_resolution",
    }
    cases_by_name = dict(zip(CASE_IDS, CASES, strict=True))
    for requirement, case_name_value in mapping.items():
        case_name = require_text(
            case_name_value, f"lifecycle_requirements.{requirement}"
        )
        case = cases_by_name[case_name]
        expected = require_mapping(case.get("expected"), "case.expected")
        for field, actual in observed(case).items():
            assert actual == expected.get(field), f"{requirement}.{field}"


def test_each_case_has_stable_unique_identity_and_reason_code() -> None:
    """Guard non-vacuous, unique case names and reason codes."""
    assert CASES
    assert len(CASE_IDS) == len(set(CASE_IDS))
    codes = [
        require_text(
            require_mapping(case.get("expected"), "expected").get("reason_code"),
            "reason_code",
        )
        for case in CASES
    ]
    assert len(codes) == len(set(codes))


@pytest.mark.parametrize("case", CASES, ids=CASE_IDS)
def test_python_authorities_reproduce_every_expected_output(
    case: dict[str, object],
) -> None:
    """Match the event, ordering, scheduler, admission, and completion outputs."""
    expected = require_mapping(case.get("expected"), "case.expected")
    for field, actual in observed(case).items():
        assert actual == expected.get(field), field
    accepted = expected.get("accepted")
    assert isinstance(accepted, bool)
    assert accepted is (
        expected.get("admission_decision") != "blocked_unresolved_drift"
    )


@pytest.mark.parametrize("case", CASES, ids=CASE_IDS)
def test_public_validator_matches_the_normalized_semantic_decision(
    case: dict[str, object],
) -> None:
    """Bind public receipt-mode validation to the shared admission decision."""

    expected = require_mapping(case.get("expected"), "case.expected")
    accepted = expected.get("accepted")
    if not isinstance(accepted, bool):
        raise TypeError("case.expected.accepted must be a boolean.")
    errors = validate_parallel_orchestrator_state_text(
        json.dumps(materialize_document(case), sort_keys=True)
    )

    assert (not errors) is accepted
    if not accepted:
        assert errors[0] == (
            "Parallel checkpoint unresolved drift for items [444] blocks "
            "admission and completion."
        )
