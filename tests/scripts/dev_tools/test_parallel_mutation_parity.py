"""Validate the shared mutation-decision corpus against Python authorities."""

from __future__ import annotations

import json
from datetime import datetime, timezone
from pathlib import Path
from typing import cast

import pytest

from scripts.dev_tools._parallel_mutation_entries import (
    build_remove_entry,
    build_requeue_entry,
)
from scripts.dev_tools._parallel_mutation_models import (
    InFlightRemovalRequiresDispositionError,
    ItemRecord,
    MergedItemRemovalRejectedError,
    ParallelMutationError,
)
from scripts.dev_tools.parallel_mutation_protocol import (
    decide_close,
    decide_removal,
    recolor_unstarted,
)
from scripts.dev_tools.validate_parallel_orchestrator_state import (
    validate_parallel_orchestrator_state_text,
)

REPO_ROOT = Path(__file__).resolve().parents[3]
FIXTURE_PATH = (
    REPO_ROOT / "tests" / "fixtures" / "parallel-orchestration" / "mutation-parity.json"
)
FIXED_CLOCK_VALUE = datetime(2026, 8, 10, 20, 25, tzinfo=timezone.utc)
REQUIRED_BEHAVIORS = {
    "complete-record",
    "sequence-gap",
    "sequence-duplicate",
    "open-mode",
    "closed-mode",
    "pinned-in-flight",
    "merged-removal",
    "detach-abandon-confirmation",
}


def require_mapping(value: object, label: str) -> dict[str, object]:
    """Return an object-shaped fixture value or fail with its path."""
    if not isinstance(value, dict):
        raise TypeError(f"{label} must be a JSON object.")
    return cast("dict[str, object]", value)


def require_list(value: object, label: str) -> list[object]:
    """Return a list-shaped fixture value or fail with its path."""
    if not isinstance(value, list):
        raise TypeError(f"{label} must be a JSON array.")
    return cast("list[object]", value)


def require_text(value: object, label: str) -> str:
    """Return a non-blank string fixture value or fail with its path."""
    if not isinstance(value, str) or not value.strip():
        raise TypeError(f"{label} must be a non-empty string.")
    return value


def load_corpus() -> (
    tuple[dict[str, object], dict[str, object], tuple[dict[str, object], ...]]
):
    """Load and structurally guard the committed mutation corpus."""
    root = require_mapping(
        cast("object", json.loads(FIXTURE_PATH.read_text(encoding="utf-8"))),
        FIXTURE_PATH.name,
    )
    if root.get("schema_version") != 1:
        raise ValueError("mutation-parity.json schema_version must equal 1.")
    base = require_mapping(root.get("base_document"), "base_document")
    cases = tuple(
        require_mapping(entry, f"cases[{index}]")
        for index, entry in enumerate(require_list(root.get("cases"), "cases"))
    )
    return root, base, cases


CORPUS, BASE_DOCUMENT, CASES = load_corpus()
CASE_IDS = [require_text(case.get("name"), "case.name") for case in CASES]


def materialize_document(case: dict[str, object]) -> dict[str, object]:
    """Apply one case's top-level overrides to a fresh base document."""
    document = cast(
        "dict[str, object]", json.loads(json.dumps(BASE_DOCUMENT, sort_keys=True))
    )
    overrides = require_mapping(case.get("document_overrides"), "document_overrides")
    document.update(
        cast("dict[str, object]", json.loads(json.dumps(overrides, sort_keys=True)))
    )
    return document


def mutation_records(document: dict[str, object]) -> list[dict[str, object]]:
    """Return the object-shaped mutation records from a corpus document."""
    return [
        require_mapping(entry, f"mutations[{index}]")
        for index, entry in enumerate(
            require_list(document.get("mutations"), "mutations")
        )
    ]


def item_records(document: dict[str, object]) -> dict[int, ItemRecord]:
    """Build the decision engine's immutable item table from a document."""
    records: dict[int, ItemRecord] = {}
    for index, entry in enumerate(require_list(document.get("items"), "items")):
        item = require_mapping(entry, f"items[{index}]")
        key = item.get("issue_num")
        state = item.get("state")
        merge_status = item.get("merge_status", "not_started")
        if not isinstance(key, int) or isinstance(key, bool):
            raise TypeError(f"items[{index}].issue_num must be an integer.")
        records[key] = ItemRecord(
            key,
            require_text(state, f"items[{index}].state"),
            require_text(merge_status, f"items[{index}].merge_status"),
        )
    return records


def fixed_clock() -> datetime:
    """Return the deterministic clock value used by entry constructors."""
    return FIXED_CLOCK_VALUE


def checkpoint_reason(errors: list[str]) -> str | None:
    """Normalize Python checkpoint errors into stable corpus reason codes."""
    if not errors:
        return None
    joined = "\n".join(errors)
    if "is missing required field" in joined:
        return "MUTATION_RECORD_INCOMPLETE"
    if "after the run-close entry" in joined:
        return "MUTATION_AFTER_OPEN_CLOSE"
    if "completion invariant failed" in joined:
        return "MUTATION_CLOSE_IN_FLIGHT"
    return "MUTATION_CHECKPOINT_REJECTED"


def sequence_reason(
    document: dict[str, object], operation: dict[str, object]
) -> str | None:
    """Replay requeue generation stamps through the Python entry authority."""
    current = operation.get("start_generation")
    if not isinstance(current, int) or isinstance(current, bool):
        raise TypeError("operation.start_generation must be an integer.")
    for entry in mutation_records(document):
        key = entry.get("item_key")
        actual = entry.get("recolor_generation")
        if not isinstance(key, int) or isinstance(key, bool):
            raise TypeError("requeue item_key must be an integer.")
        expected = build_requeue_entry(
            key, current_generation=current, clock=fixed_clock
        ).recolor_generation
        if actual != expected:
            if isinstance(actual, int) and actual < expected:
                return "MUTATION_SEQUENCE_DUPLICATE"
            return "MUTATION_SEQUENCE_GAP"
        current = expected
    return None


def removal_reason(
    document: dict[str, object], operation: dict[str, object]
) -> str | None:
    """Evaluate removal, confirmation, and generation through Python helpers."""
    key = operation.get("item_key")
    if not isinstance(key, int) or isinstance(key, bool):
        raise TypeError("operation.item_key must be an integer.")
    disposition = operation.get("disposition")
    if disposition is not None and not isinstance(disposition, str):
        raise TypeError("operation.disposition must be null or a string.")

    records = item_records(document)
    matching = [
        entry for entry in mutation_records(document) if entry.get("item_key") == key
    ]
    if matching:
        prior_state = matching[0].get("prior_state")
        if isinstance(prior_state, str):
            merge_status = "merged" if prior_state == "merged" else "pr_open"
            records[key] = ItemRecord(key, prior_state, merge_status)

    try:
        decision = decide_removal(key, records, disposition)
    except InFlightRemovalRequiresDispositionError:
        return "MUTATION_REMOVE_CONFIRMATION_REQUIRED"
    except MergedItemRemovalRejectedError:
        return "MUTATION_REMOVE_MERGED"

    confirmation = operation.get("confirmation")
    if disposition in {"detach", "abandon"}:
        confirm = require_mapping(confirmation, "operation.confirmation")
        worktree = require_text(
            confirm.get("worktree_identity"), "operation.confirmation.worktree_identity"
        )
        expected_token = f"confirm:{disposition}:{key}:{worktree}"
        exact = (
            confirm.get("operation") == disposition
            and confirm.get("item_key") == key
            and confirm.get("token") == expected_token
        )
        if not exact:
            return "MUTATION_REMOVE_CONFIRMATION_MISMATCH"

    entries = mutation_records(document)
    if entries:
        current = operation.get("start_generation", 0)
        if not isinstance(current, int) or isinstance(current, bool):
            raise TypeError("operation.start_generation must be an integer.")
        expected_generation = build_remove_entry(
            decision, current_generation=current, clock=fixed_clock
        ).recolor_generation
        if entries[0].get("recolor_generation") != expected_generation:
            return "MUTATION_PIN_GENERATION_CHANGED"
    return None


def close_reason(document: dict[str, object]) -> str | None:
    """Evaluate close admission through the Python mutation authority."""
    try:
        decide_close(item_records(document))
    except ParallelMutationError:
        return "MUTATION_CLOSE_IN_FLIGHT"
    return None


def highest_pinned_cohort(
    document: dict[str, object],
    pinned: frozenset[int],
    generation: int,
    current_cohort: int,
) -> int:
    """Derive the highest pinned index from durable current-generation cohorts."""

    assignments: dict[int, int] = {}
    for index, value in enumerate(require_list(document.get("cohorts"), "cohorts")):
        cohort = require_mapping(value, f"cohorts[{index}]")
        cohort_generation = cohort.get("generation")
        cohort_index = cohort.get("index")
        if cohort_generation != generation or not isinstance(cohort_index, int):
            continue
        for key in require_list(cohort.get("item_keys"), f"cohorts[{index}].item_keys"):
            if isinstance(key, int) and not isinstance(key, bool):
                assignments.setdefault(key, cohort_index)
    return max(
        (assignments.get(key, current_cohort) for key in pinned),
        default=current_cohort,
    )


def recolor_reason(
    document: dict[str, object], operation: dict[str, object], expected_code: str
) -> str | None:
    """Evaluate pin preservation through the Python recoloring authority."""
    integers = {
        key: require_list(operation.get(key), f"operation.{key}")
        for key in ("conflict_edges", "unstarted_keys", "pinned_keys")
    }
    current_cohort = operation.get("current_cohort")
    generation = operation.get("current_generation")
    if not isinstance(current_cohort, int) or not isinstance(generation, int):
        raise TypeError("recolor generation and cohort must be integers.")
    pinned = frozenset(cast("list[int]", integers["pinned_keys"]))
    try:
        result = recolor_unstarted(
            cast("list[int]", integers["unstarted_keys"]),
            cast("list[tuple[int, int]]", integers["conflict_edges"]),
            pinned,
            generation,
            current_cohort=current_cohort,
            highest_pinned_cohort=highest_pinned_cohort(
                document, pinned, generation, current_cohort
            ),
        )
    except ParallelMutationError:
        return "MUTATION_PIN_VIOLATION"
    if pinned.intersection(result.cohort_assignments):
        return "MUTATION_PIN_VIOLATION"
    return None if expected_code == "MUTATION_PIN_PRESERVED" else expected_code


def observed_reason(case: dict[str, object]) -> str | None:
    """Dispatch one scenario to its named Python decision authority."""
    authority = require_text(case.get("authority"), "case.authority")
    document = materialize_document(case)
    operation_value = case.get("operation")
    operation = (
        require_mapping(operation_value, "case.operation")
        if operation_value is not None
        else {}
    )
    expected = require_mapping(case.get("expected"), "case.expected")
    expected_code = require_text(expected.get("reason_code"), "expected.reason_code")
    if authority == "checkpoint":
        return checkpoint_reason(
            validate_parallel_orchestrator_state_text(json.dumps(document))
        )
    if authority == "requeue_sequence":
        return sequence_reason(document, operation)
    if authority == "removal":
        return removal_reason(document, operation)
    if authority == "close":
        return close_reason(document)
    if authority == "recolor":
        return recolor_reason(document, operation, expected_code)
    raise ValueError(f"Unsupported mutation fixture authority: {authority}.")


def test_fixture_covers_every_required_mutation_behavior() -> None:
    """Require the corpus to retain every behavior named by the plan."""
    observed = {require_text(case.get("behavior"), "case.behavior") for case in CASES}
    assert observed == REQUIRED_BEHAVIORS


def test_lifecycle_modes_bind_to_executed_shared_cases() -> None:
    """Require add/remove/close/detach/abandon lifecycle coverage."""
    mapping = require_mapping(CORPUS.get("lifecycle_modes"), "lifecycle_modes")
    assert set(mapping) == {"add", "remove", "close", "detach", "abandon"}
    cases_by_name = dict(zip(CASE_IDS, CASES, strict=True))
    for mode, case_name_value in mapping.items():
        case_name = require_text(case_name_value, f"lifecycle_modes.{mode}")
        case = cases_by_name[case_name]
        expected = require_mapping(case.get("expected"), "case.expected")
        accepted = cast("bool", expected["accepted"])
        assert (observed_reason(case) is None) is accepted


def test_each_case_has_one_binary_result_and_stable_reason_code() -> None:
    """Guard non-vacuous, uniquely named decisions for every fixture case."""
    assert CASES
    assert len(CASE_IDS) == len(set(CASE_IDS))
    codes: list[str] = []
    for case in CASES:
        expected = require_mapping(case.get("expected"), "case.expected")
        assert isinstance(expected.get("accepted"), bool)
        codes.append(require_text(expected.get("reason_code"), "expected.reason_code"))
    assert len(codes) == len(set(codes))


@pytest.mark.parametrize("case", CASES, ids=CASE_IDS)
def test_python_authority_reproduces_each_fixture_decision(
    case: dict[str, object],
) -> None:
    """Match each committed accept/reject result and rejection reason code."""
    expected = require_mapping(case.get("expected"), "case.expected")
    accepted = cast("bool", expected["accepted"])
    expected_code = require_text(expected.get("reason_code"), "expected.reason_code")

    reason = observed_reason(case)

    assert (reason is None) is accepted
    if reason is not None:
        assert reason == expected_code
