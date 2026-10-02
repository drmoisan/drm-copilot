"""Tests for parallel-planner ready-gate invariant P10, the routing record.

Under ``require_ready_for_execution`` every planner item must carry a valid
``complexity_band``, a ``complexity_assessment``, and a
``model_routing_receipt`` (issue #532). Checkpoints are built with the shared
builders module and serialized with ``json.dumps``; no temporary file is
created. The expected strings are fixed literals shared with the TypeScript
suite ``parallel-planner-state-routing.test.ts``.
"""

from __future__ import annotations

import inspect
import json
from typing import cast

import pytest

from scripts.dev_tools import (
    _orchestrator_state_complexity,
    _orchestrator_state_model_routing,
    _parallel_planner_state_routing,
    compute_complexity_floor,
)
from scripts.dev_tools._parallel_planner_state_routing import (
    validate_ready_item_routing,
)
from scripts.dev_tools.validate_parallel_planner_state import (
    REQUIRED_ITEM_KEYS,
    validate_parallel_planner_state_text,
)
from tests.scripts.dev_tools.parallel_planner_state_builders import (
    build_routing_fields,
    build_valid_planner_state,
)

CTX = "Parallel planner checkpoint items[0]"
BAND_ABSENT = (
    "Parallel planner checkpoint items[0] complexity_band must be one of "
    "C1, C2, C3, C4; found: None."
)
BAND_C9 = (
    "Parallel planner checkpoint items[0] complexity_band must be one of "
    "C1, C2, C3, C4; found: 'C9'."
)
ASSESSMENT_NOT_OBJECT = (
    "Parallel planner checkpoint items[0] complexity_assessment must be an object."
)
RECEIPT_NOT_OBJECT = (
    "Parallel planner checkpoint items[0] model_routing_receipt must be an object."
)
ASSESSMENT_BAND_ENUM = (
    "Parallel planner checkpoint items[0] complexity_assessment band must be "
    "one of C1, C2, C3, C4; got: C9."
)
SIGNALS_NOT_LIST = (
    "Parallel planner checkpoint items[0] complexity_assessment signals_present "
    "must be a list of strings."
)
FLOOR_MISMATCH = (
    "Parallel planner checkpoint items[0] complexity_assessment floor C1 does "
    "not equal compute_complexity_floor(signals_present) C3."
)
BAND_BELOW_FLOOR = (
    "Parallel planner checkpoint items[0] complexity_assessment band C2 is "
    "below its floor C3."
)
RATIONALE_EMPTY = (
    "Parallel planner checkpoint items[0] complexity_assessment rationale must "
    "be a non-empty string."
)
ASSESSED_AT_EMPTY = (
    "Parallel planner checkpoint items[0] complexity_assessment.assessed_at "
    "must be a non-empty string."
)
ASSESSMENT_BAND_MISMATCH = (
    "Parallel planner checkpoint items[0] complexity_assessment.band 'C2' does "
    "not equal complexity_band 'C3'."
)
RECEIPT_BAND_ENUM = (
    "Parallel planner checkpoint items[0] model_routing_receipt complexity_band "
    "must be one of C1, C2, C3, C4; got: C9."
)
RESOLVER_MISMATCH = (
    "Parallel planner checkpoint items[0] model_routing_receipt model opus does "
    "not equal resolve_delegation_model(agent, complexity_band, fable_policy) "
    "sonnet."
)
DISABLED_FABLE = (
    "Parallel planner checkpoint items[0] model_routing_receipt model must not "
    "be fable under fable_policy disabled."
)
AGENT_NOT_ORCHESTRATOR = (
    "Parallel planner checkpoint items[0] model_routing_receipt.agent must be "
    "'orchestrator'; found: 'atomic-planner'."
)
RECEIPT_BAND_MISMATCH = (
    "Parallel planner checkpoint items[0] model_routing_receipt.complexity_band "
    "'C2' does not equal complexity_band 'C3'."
)
UNKNOWN_FABLE_POLICY = (
    "Parallel planner checkpoint items[0] model_routing_receipt.fable_policy "
    "must be one of disabled, available, preferred; found: 'sometimes'."
)
ROUTING_FIELDS = ("complexity_band", "complexity_assessment", "model_routing_receipt")


def validate(state: dict[str, object], *, ready: bool) -> list[str]:
    """Serialize a checkpoint dict and return the validator's error list."""

    return validate_parallel_planner_state_text(
        json.dumps(state), require_ready_for_execution=ready
    )


def first_item(state: dict[str, object]) -> dict[str, object]:
    """Return the first item of a built checkpoint for in-place mutation."""

    return cast("list[dict[str, object]]", state["items"])[0]


def nested(item: dict[str, object], key: str) -> dict[str, object]:
    """Return an item's nested assessment or receipt object for mutation."""

    return cast("dict[str, object]", item[key])


def routing_errors(errors: list[str]) -> list[str]:
    """Return the item-0 errors that mention the assessment or the receipt."""

    keys = ("complexity_assessment", "model_routing_receipt")
    return [e for e in errors if e.startswith(CTX) and any(k in e for k in keys)]


def test_ready_gate_rejects_item_without_band_assessment_or_receipt() -> None:
    """The ready gate reports an item missing all three routing fields."""

    # Arrange
    state = build_valid_planner_state()
    item = first_item(state)
    for key in ROUTING_FIELDS:
        del item[key]

    # Act
    errors = validate(state, ready=True)

    # Assert
    assert BAND_ABSENT in errors, errors
    assert ASSESSMENT_NOT_OBJECT in errors, errors
    assert RECEIPT_NOT_OBJECT in errors, errors


def test_ready_gate_accepts_item_with_valid_routing_record() -> None:
    """A ready checkpoint built by the updated builders yields no errors."""

    # Arrange
    state = build_valid_planner_state()

    # Act
    errors = validate(state, ready=True)

    # Assert
    assert errors == [], errors


def test_gate_off_accepts_item_without_routing_fields() -> None:
    """With the gate off, items lacking all three routing fields validate."""

    # Arrange
    state = build_valid_planner_state()
    for item in cast("list[dict[str, object]]", state["items"]):
        for key in ROUTING_FIELDS:
            del item[key]

    # Act
    errors = validate(state, ready=False)

    # Assert
    assert errors == [], errors


def test_ready_gate_rejects_floor_that_disagrees_with_signals() -> None:
    """A floor that differs from the recomputed floor is reported (check 3)."""

    # Arrange
    state = build_valid_planner_state()
    assessment = nested(first_item(state), "complexity_assessment")
    assessment["signals_present"] = ["concurrency_or_ordering"]
    assessment["floor"] = "C1"

    # Act
    errors = validate(state, ready=True)

    # Assert
    assert FLOOR_MISMATCH in errors, errors


def test_ready_gate_rejects_band_below_floor() -> None:
    """An assessed band below its floor is reported (check 3)."""

    # Arrange
    state = build_valid_planner_state()
    nested(first_item(state), "complexity_assessment")["band"] = "C2"

    # Act
    errors = validate(state, ready=True)

    # Assert
    assert BAND_BELOW_FLOOR in errors, errors


def test_ready_gate_rejects_receipt_model_that_disagrees_with_resolver() -> None:
    """A receipt model that differs from the resolver is reported (check 7)."""

    # Arrange
    state = build_valid_planner_state()
    receipt = nested(first_item(state), "model_routing_receipt")
    receipt.update(complexity_band="C2", fable_policy="available", model="opus")

    # Act
    errors = validate(state, ready=True)

    # Assert
    assert RESOLVER_MISMATCH in errors, errors


def test_ready_gate_rejects_disabled_policy_fable_model() -> None:
    """A fable model under the disabled policy is reported (check 7 clamp)."""

    # Arrange
    state = build_valid_planner_state()
    item = first_item(state)
    item["complexity_band"] = "C4"
    nested(item, "complexity_assessment")["band"] = "C4"
    receipt = nested(item, "model_routing_receipt")
    receipt.update(complexity_band="C4", fable_policy="disabled")
    receipt.update(table_model="fable", clamped_from="fable", model="fable")

    # Act
    errors = validate(state, ready=True)

    # Assert
    assert DISABLED_FABLE in errors, errors


def test_ready_gate_rejects_assessment_band_mismatch() -> None:
    """An assessment band that differs from the item band is reported (check 5)."""

    # Arrange
    state = build_valid_planner_state()
    nested(first_item(state), "complexity_assessment")["band"] = "C2"

    # Act
    errors = validate(state, ready=True)

    # Assert
    assert ASSESSMENT_BAND_MISMATCH in errors, errors


def test_ready_gate_rejects_receipt_band_mismatch() -> None:
    """A receipt band that differs from the item band is reported (check 9)."""

    # Arrange
    state = build_valid_planner_state()
    nested(first_item(state), "model_routing_receipt")["complexity_band"] = "C2"

    # Act
    errors = validate(state, ready=True)

    # Assert
    assert RECEIPT_BAND_MISMATCH in errors, errors


def test_ready_gate_rejects_non_orchestrator_agent() -> None:
    """A receipt naming an agent other than orchestrator is reported (check 8)."""

    # Arrange
    state = build_valid_planner_state()
    nested(first_item(state), "model_routing_receipt")["agent"] = "atomic-planner"

    # Act
    errors = validate(state, ready=True)

    # Assert
    assert AGENT_NOT_ORCHESTRATOR in errors, errors


def test_ready_gate_rejects_unknown_fable_policy() -> None:
    """An unknown receipt fable_policy is reported (check 10)."""

    # Arrange
    state = build_valid_planner_state()
    nested(first_item(state), "model_routing_receipt")["fable_policy"] = "sometimes"

    # Act
    errors = validate(state, ready=True)

    # Assert
    assert UNKNOWN_FABLE_POLICY in errors, errors


def test_ready_gate_rejects_non_object_assessment_and_receipt() -> None:
    """String-valued fields report checks 2 and 6 and skip checks 3-5 and 7-10."""

    # Arrange
    state = build_valid_planner_state()
    item = first_item(state)
    item["complexity_assessment"] = "C3"
    item["model_routing_receipt"] = "opus"

    # Act
    errors = validate(state, ready=True)

    # Assert
    assert ASSESSMENT_NOT_OBJECT in errors, errors
    assert RECEIPT_NOT_OBJECT in errors, errors
    assert len(routing_errors(errors)) == 2, errors


def test_ready_gate_rejects_missing_assessed_at() -> None:
    """An empty assessed_at is reported (check 4)."""

    # Arrange
    state = build_valid_planner_state()
    nested(first_item(state), "complexity_assessment")["assessed_at"] = ""

    # Act
    errors = validate(state, ready=True)

    # Assert
    assert ASSESSED_AT_EMPTY in errors, errors


def test_band_mismatch_reported_when_item_band_invalid() -> None:
    """An invalid item band still reports the check-5 and check-9 mismatches.

    The check-1 literal occurs twice: once from the presence-gated enum check
    in ``_validate_item_contract`` and once from P10 check 1; neither path
    deduplicates.
    """

    # Arrange
    state = build_valid_planner_state()
    first_item(state)["complexity_band"] = "C9"

    # Act
    errors = validate(state, ready=True)

    # Assert
    assert (
        f"{CTX} complexity_assessment.band 'C3' does not equal complexity_band 'C9'."
    ) in errors, errors
    assert (
        f"{CTX} model_routing_receipt.complexity_band 'C3' does not equal "
        "complexity_band 'C9'."
    ) in errors, errors
    assert errors.count(BAND_C9) == 2, errors


def test_p10_errors_follow_p7_errors_for_same_item() -> None:
    """Every P7 error for an item precedes every P10 error for that item."""

    # Arrange
    state = build_valid_planner_state()
    item = first_item(state)
    item["preparation_status"] = "pending"
    item["preflight_status"] = "PREFLIGHT: REVISIONS REQUIRED"
    for key in ROUTING_FIELDS:
        del item[key]

    # Act
    errors = validate(state, ready=True)

    # Assert
    p7_prefixes = (f"{CTX} preparation_status", f"{CTX} preflight_status")
    p10_errors = (BAND_ABSENT, ASSESSMENT_NOT_OBJECT, RECEIPT_NOT_OBJECT)
    p7_positions = [i for i, e in enumerate(errors) if e.startswith(p7_prefixes)]
    p10_positions = [i for i, e in enumerate(errors) if e in p10_errors]
    assert len(p7_positions) == 2, errors
    assert len(p10_positions) == 3, errors
    assert max(p7_positions) < min(p10_positions), errors


def test_routing_helper_reuses_claude_helpers_only() -> None:
    """The routing module reuses the Claude helpers and no Codex name."""

    # Arrange
    module = _parallel_planner_state_routing
    pairs = (
        ("_validate_complexity_assessments", _orchestrator_state_complexity),
        ("_validate_model_routing_receipts", _orchestrator_state_model_routing),
        ("BAND_ORDER", compute_complexity_floor),
    )

    # Act
    source = inspect.getsource(module)

    # Assert
    for name, defining_module in pairs:
        assert getattr(module, name) is getattr(defining_module, name), name
    assert "validate_codex_model_routing_receipts" not in source
    assert "resolve_codex_deployment" not in source


@pytest.mark.parametrize(
    ("target", "key", "value", "expected"),
    [
        ("complexity_assessment", "band", "C9", ASSESSMENT_BAND_ENUM),
        ("complexity_assessment", "signals_present", "x", SIGNALS_NOT_LIST),
        ("complexity_assessment", "band", "C2", BAND_BELOW_FLOOR),
        ("complexity_assessment", "rationale", "   ", RATIONALE_EMPTY),
        ("complexity_assessment", "assessed_at", "", ASSESSED_AT_EMPTY),
        ("complexity_assessment", "band", "C2", ASSESSMENT_BAND_MISMATCH),
        ("model_routing_receipt", "agent", "atomic-planner", AGENT_NOT_ORCHESTRATOR),
        ("model_routing_receipt", "complexity_band", "C2", RECEIPT_BAND_MISMATCH),
        ("model_routing_receipt", "fable_policy", "sometimes", UNKNOWN_FABLE_POLICY),
        ("model_routing_receipt", "complexity_band", "C9", RECEIPT_BAND_ENUM),
    ],
)
def test_ready_gate_emits_shared_literal_strings(
    target: str, key: str, value: str, expected: str
) -> None:
    """Each single-field mutation emits the literal shared with TypeScript."""

    # Arrange
    record = build_routing_fields()
    nested(record, target)[key] = value

    # Act
    errors = validate_ready_item_routing(record, CTX)

    # Assert
    assert expected in errors, errors


def test_required_item_keys_unchanged() -> None:
    """P10 adds no required item key; the nine baseline keys are unchanged."""

    # Arrange
    baseline = tuple(
        "issue_num feature_folder kind state blast_radius preparation_status "
        "research_path plan_path preflight_status".split()
    )

    # Act
    actual = REQUIRED_ITEM_KEYS

    # Assert
    assert actual == baseline
