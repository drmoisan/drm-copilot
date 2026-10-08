"""Unit tests for remediation-loop verdict accounting (issue #484, R5-R11).

Covers the pure verdict-derivation helper ``derive_review_verdict`` over every
subset of the five remediability classes, the vocabulary constants, the
drift guard against the #523 non-mechanical ``blocked_reason`` partition, and
each new remediation-loop invariant (R5 through R11) driven through the public
``validate_orchestrator_state_text`` entry point. Expected messages are written
locally from the spec message table rather than imported, so the assertions are
pinned to the specification and not to the implementation.

No temporary file is created and no external process is started; every
checkpoint is built in memory from ``build_complete_small_state``.
"""

from __future__ import annotations

import copy
import itertools
import json

import pytest

import scripts.dev_tools.validate_orchestrator_state as state_validator
from scripts.dev_tools._orchestrator_state_blocked_reason import (
    NON_MECHANICAL_BLOCKED_REASONS,
)
from scripts.dev_tools._orchestrator_state_remediation_loop import (
    CANDIDATE_APPLIED_KEY,
    COMPLETED_ATTEMPTS_KEY,
    HALT_CLASSES,
    NON_REMEDIABLE_CLASSES,
    OPENED_BY_REVIEW_KEY,
    REMEDIABILITY_CLASSES,
    REVIEW_OUTCOMES_KEY,
    REVIEW_VERDICTS,
    derive_review_verdict,
)
from tests.scripts.dev_tools.validate_orchestrator_state_test_support import (
    build_complete_small_state,
)

SPEC_VERDICTS = ("PASS", "REMEDIATION_REQUIRED", "HALT_NON_REMEDIABLE", "AWAITING_CI")
SPEC_CLASSES = (
    "autonomous",
    "external_dependency",
    "policy_hold",
    "awaiting_ci",
    "human_decision_required",
)
SPEC_HALT = frozenset({"external_dependency", "policy_hold", "human_decision_required"})
ABSENT = object()

VC: dict[str, object] = {
    "entry_timestamp": "2026-09-29T00-00",
    "inputs_path": (
        "docs/features/active/example/remediation-inputs.2026-09-29T00-00.md"
    ),
    "plan_path": "docs/features/active/example/remediation-plan.2026-09-29T00-00.md",
    "preflight": {"iterations": 1, "final_status": "clear"},
    "execution_status": "complete",
    "audit_paths": [],
    "blocking_count": 1,
    "exit_condition_met": False,
}


def vc(**changes: object) -> dict[str, object]:
    """Return a copy of the valid legacy cycle with the given changes."""
    cycle = copy.deepcopy(VC)
    cycle.update(changes)
    return cycle


def outcome(verdict: object, *classes: object) -> dict[str, object]:
    """Return a review outcome whose findings carry the given classes."""
    return {"verdict": verdict, "findings": [{"remediability": c} for c in classes]}


RR = outcome("REMEDIATION_REQUIRED", "autonomous")
HALT = outcome("HALT_NON_REMEDIABLE", "external_dependency")
WAIT = outcome("AWAITING_CI", "awaiting_ci")
PASSV = outcome("PASS")


def r5(i: int) -> str:
    return f"Checkpoint remediation cycle #{i} candidate_applied must be a boolean."


def r6(i: int) -> str:
    return (
        f"Checkpoint remediation cycle #{i} candidate_applied is true but "
        "execution_status is not 'complete'."
    )


R7A = "Checkpoint remediation_loop completed_attempts must be a non-negative integer."
R8A = "Checkpoint remediation_loop review_outcomes must be a list."


def r7b(n: int, k: int) -> str:
    return (
        f"Checkpoint remediation_loop completed_attempts is {n} but {k} cycles "
        "have candidate_applied true."
    )


def r8b(j: int) -> str:
    return f"Checkpoint remediation review outcome #{j} must be an object."


def r9a(j: int, v: str) -> str:
    return (
        f"Checkpoint remediation review outcome #{j} verdict must be one of PASS, "
        f"REMEDIATION_REQUIRED, HALT_NON_REMEDIABLE, AWAITING_CI; got: {v}"
    )


def r9b(j: int) -> str:
    return f"Checkpoint remediation review outcome #{j} findings must be a list."


def r9c(j: int, m: int) -> str:
    return f"Checkpoint remediation review outcome #{j} finding #{m} must be an object."


def r9d(j: int, m: int, v: str) -> str:
    return (
        f"Checkpoint remediation review outcome #{j} finding #{m} remediability must "
        "be one of autonomous, external_dependency, policy_hold, awaiting_ci, "
        f"human_decision_required; got: {v}"
    )


def r10(j: int, v: str, e: str) -> str:
    return (
        f"Checkpoint remediation review outcome #{j} verdict {v} does not match its "
        f"findings (expected {e})."
    )


def r11(i: int) -> str:
    return (
        f"Checkpoint remediation cycle #{i} opened_by_review must reference a review "
        "outcome whose verdict is REMEDIATION_REQUIRED."
    )


def spec_verdict(classes: tuple[str, ...]) -> str:
    """Derive the verdict in the spec's evaluation order (the test oracle)."""
    if not classes:
        return "PASS"
    if "autonomous" in classes:
        return "REMEDIATION_REQUIRED"
    if any(value in SPEC_HALT for value in classes):
        return "HALT_NON_REMEDIABLE"
    return "AWAITING_CI"


def loop_errors(loop: object, **top: object) -> list[str]:
    """Validate a small checkpoint carrying ``loop``; keep remediation errors."""
    state = build_complete_small_state()
    state.update(top)
    state["remediation_loop"] = loop
    errors = state_validator.validate_orchestrator_state_text(json.dumps(state))
    return [error for error in errors if "remediation" in error]


SUBSETS = [
    combo
    for size in range(len(SPEC_CLASSES) + 1)
    for combo in itertools.combinations(SPEC_CLASSES, size)
]


@pytest.mark.parametrize(
    "classes", SUBSETS, ids=["+".join(s) or "empty" for s in SUBSETS]
)
def test_derive_review_verdict_over_every_class_subset(
    classes: tuple[str, ...],
) -> None:
    """Every one of the 32 class subsets derives the spec-ordered verdict."""
    # Arrange: the oracle verdict for the subset.
    expected = spec_verdict(classes)
    # Act
    observed = derive_review_verdict(list(classes))
    # Assert
    assert observed == expected, f"subset {classes} derived {observed}, not {expected}"


@pytest.mark.parametrize(
    ("classes", "expected"),
    [
        (["awaiting_ci", "awaiting_ci"], "AWAITING_CI"),
        (["policy_hold", "policy_hold"], "HALT_NON_REMEDIABLE"),
        (["autonomous", "autonomous", "policy_hold"], "REMEDIATION_REQUIRED"),
        (
            ["awaiting_ci", "human_decision_required", "awaiting_ci"],
            "HALT_NON_REMEDIABLE",
        ),
    ],
)
def test_derive_review_verdict_with_duplicate_classes(
    classes: list[str], expected: str
) -> None:
    """Repeated classes do not change the derived verdict."""
    assert derive_review_verdict(classes) == expected


@pytest.mark.parametrize(
    "classes",
    [["Autonomous"], ["PASS"], [""], ["unknown"], ["autonomous", "AWAITING_CI"]],
    ids=["title-case", "verdict-literal", "empty-string", "unknown", "mixed"],
)
def test_derive_review_verdict_rejects_non_member(classes: list[str]) -> None:
    """A member outside REMEDIABILITY_CLASSES raises a prefixed ValueError."""
    with pytest.raises(ValueError, match="^invalid remediability: "):
        derive_review_verdict(classes)


def test_vocabulary_constants_match_spec_tables() -> None:
    """Constants carry the spec values, tuple order, and frozenset members."""
    assert REVIEW_OUTCOMES_KEY == "review_outcomes"
    assert COMPLETED_ATTEMPTS_KEY == "completed_attempts"
    assert CANDIDATE_APPLIED_KEY == "candidate_applied"
    assert OPENED_BY_REVIEW_KEY == "opened_by_review"
    assert isinstance(REVIEW_VERDICTS, tuple) and REVIEW_VERDICTS == SPEC_VERDICTS
    assert isinstance(REMEDIABILITY_CLASSES, tuple)
    assert REMEDIABILITY_CLASSES == SPEC_CLASSES
    assert isinstance(NON_REMEDIABLE_CLASSES, frozenset)
    assert NON_REMEDIABLE_CLASSES == frozenset(SPEC_CLASSES[1:])
    assert isinstance(HALT_CLASSES, frozenset) and HALT_CLASSES == SPEC_HALT


def test_non_remediable_classes_are_non_mechanical_blocked_reasons() -> None:
    """Drift guard: every non-remediable class is a #523 non-mechanical reason."""
    missing = NON_REMEDIABLE_CLASSES - NON_MECHANICAL_BLOCKED_REASONS
    assert NON_REMEDIABLE_CLASSES <= NON_MECHANICAL_BLOCKED_REASONS, sorted(missing)


CANDIDATE_CASES: dict[str, tuple[dict[str, object], list[str]]] = {
    "string": (vc(candidate_applied="yes"), [r5(0)]),
    "integer-one": (vc(candidate_applied=1), [r5(0)]),
    "integer-zero": (vc(candidate_applied=0), [r5(0)]),
    "null": (vc(candidate_applied=None), [r5(0)]),
    "true-complete": (vc(candidate_applied=True), []),
    "false-failed": (vc(candidate_applied=False, execution_status="failed"), []),
    "true-failed": (vc(candidate_applied=True, execution_status="failed"), [r6(0)]),
    "true-in-progress": (
        vc(candidate_applied=True, execution_status="in_progress"),
        [r6(0)],
    ),
}


@pytest.mark.parametrize(
    ("cycle", "expected"), list(CANDIDATE_CASES.values()), ids=list(CANDIDATE_CASES)
)
def test_candidate_applied_rules(cycle: dict[str, object], expected: list[str]) -> None:
    """R5 requires a boolean; R6 requires execution_status complete for true."""
    assert loop_errors({"cycles": [cycle]}) == expected


ATTEMPT_CASES: dict[str, tuple[dict[str, object], list[str]]] = {
    "negative": ({"completed_attempts": -1}, [R7A]),
    "boolean-true": ({"completed_attempts": True}, [R7A]),
    "boolean-false": ({"completed_attempts": False}, [R7A]),
    "string": ({"completed_attempts": "1"}, [R7A]),
    "null": ({"completed_attempts": None}, [R7A]),
    "mismatch": (
        {"completed_attempts": 2, "cycles": [vc(candidate_applied=True)]},
        [r7b(2, 1)],
    ),
    "zero-no-cycles": ({"completed_attempts": 0}, []),
    "positive-no-cycles": ({"completed_attempts": 1}, [r7b(1, 0)]),
    "cycles-not-list": ({"completed_attempts": 1, "cycles": "none"}, [r7b(1, 0)]),
    "non-object-cycle-not-counted": (
        {"completed_attempts": 1, "cycles": [7, vc(candidate_applied=True)]},
        ["Checkpoint remediation cycle #0 must be an object."],
    ),
}


@pytest.mark.parametrize(
    ("loop", "expected"), list(ATTEMPT_CASES.values()), ids=list(ATTEMPT_CASES)
)
def test_completed_attempts_rules(loop: dict[str, object], expected: list[str]) -> None:
    """R7a requires a non-negative integer; R7b requires the true-cycle count."""
    assert loop_errors(loop) == expected


RR_EMPTY: dict[str, object] = {"verdict": "REMEDIATION_REQUIRED", "findings": []}
SHAPE_CASES: dict[str, tuple[object, list[str]]] = {
    "outcomes-string": ("PASS", [R8A]),
    "outcomes-object": ({"verdict": "PASS"}, [R8A]),
    "outcomes-integer": (7, [R8A]),
    "outcome-integer": ([7], [r8b(0)]),
    "outcome-null-skipped": ([None, PASSV], [r8b(0)]),
    "second-outcome-string": ([PASSV, "PASS"], [r8b(1)]),
    "verdict-case-variant": ([outcome("Pass")], [r9a(0, "Pass")]),
    "findings-missing": ([{"verdict": "PASS"}], [r9b(0)]),
    "findings-string": ([{"verdict": "PASS", "findings": "none"}], [r9b(0)]),
    "verdict-and-findings-invalid": (
        [{"verdict": "x", "findings": "y"}],
        [r9a(0, "x"), r9b(0)],
    ),
    "finding-integer": ([{**RR_EMPTY, "findings": [7]}], [r9c(0, 0)]),
    "finding-errors-in-order": (
        [{**RR_EMPTY, "findings": [7, {"remediability": "bad"}]}],
        [r9c(0, 0), r9d(0, 1, "bad")],
    ),
    "remediability-null": (
        [outcome("REMEDIATION_REQUIRED", None)],
        [r9d(0, 0, "None")],
    ),
    "remediability-missing": ([{**RR_EMPTY, "findings": [{}]}], [r9d(0, 0, "None")]),
    "empty-findings-non-pass": (
        [RR_EMPTY],
        [r10(0, "REMEDIATION_REQUIRED", "PASS")],
    ),
}


@pytest.mark.parametrize(
    ("outcomes", "expected"), list(SHAPE_CASES.values()), ids=list(SHAPE_CASES)
)
def test_review_outcome_shape_rules(outcomes: object, expected: list[str]) -> None:
    """R8a, R8b, and R9a-R9d report shape errors and suppress R10."""
    assert loop_errors({"review_outcomes": outcomes}) == expected


CASE_VARIANTS: dict[str, tuple[object, list[str]]] = {
    **{
        f"verdict-{v}-lower": (outcome(v.lower()), [r9a(0, v.lower())])
        for v in SPEC_VERDICTS
    },
    **{
        f"verdict-{v}-title": (outcome(v.title()), [r9a(0, v.title())])
        for v in SPEC_VERDICTS
    },
    **{
        f"class-{c}-upper": (
            outcome("REMEDIATION_REQUIRED", c.upper()),
            [r9d(0, 0, c.upper())],
        )
        for c in SPEC_CLASSES
    },
    **{
        f"class-{c}-title": (
            outcome("REMEDIATION_REQUIRED", c.title()),
            [r9d(0, 0, c.title())],
        )
        for c in SPEC_CLASSES
    },
}


@pytest.mark.parametrize(
    ("variant", "expected"), list(CASE_VARIANTS.values()), ids=list(CASE_VARIANTS)
)
def test_case_variants_rejected(variant: object, expected: list[str]) -> None:
    """Every verdict and class literal is compared case-sensitively."""
    assert loop_errors({"review_outcomes": [variant]}) == expected


CONSISTENCY_CASES: dict[str, tuple[str, tuple[str, ...], list[str]]] = {
    "pass-empty": ("PASS", (), []),
    "pass-autonomous": (
        "PASS",
        ("autonomous",),
        [r10(0, "PASS", "REMEDIATION_REQUIRED")],
    ),
    "halt-mixture": (
        "HALT_NON_REMEDIABLE",
        ("policy_hold", "human_decision_required"),
        [],
    ),
    "awaiting-with-external": (
        "AWAITING_CI",
        ("awaiting_ci", "external_dependency"),
        [r10(0, "AWAITING_CI", "HALT_NON_REMEDIABLE")],
    ),
    "awaiting-with-autonomous": (
        "AWAITING_CI",
        ("autonomous", "awaiting_ci"),
        [r10(0, "AWAITING_CI", "REMEDIATION_REQUIRED")],
    ),
    "halt-with-awaiting-only": (
        "HALT_NON_REMEDIABLE",
        ("awaiting_ci", "awaiting_ci"),
        [r10(0, "HALT_NON_REMEDIABLE", "AWAITING_CI")],
    ),
    "remediation-mixed": (
        "REMEDIATION_REQUIRED",
        ("autonomous", "human_decision_required"),
        [],
    ),
    "awaiting-only": ("AWAITING_CI", ("awaiting_ci",), []),
}


@pytest.mark.parametrize(
    ("verdict", "classes", "expected"),
    list(CONSISTENCY_CASES.values()),
    ids=list(CONSISTENCY_CASES),
)
def test_verdict_consistency_rule(
    verdict: str, classes: tuple[str, ...], expected: list[str]
) -> None:
    """R10 requires the verdict to equal the derivation over the findings."""
    assert loop_errors({"review_outcomes": [outcome(verdict, *classes)]}) == expected


OPENED_CASES: dict[str, tuple[object, object, list[str]]] = {
    "remediation-required": ([RR], 0, []),
    "second-index": ([PASSV, RR], 1, []),
    "points-at-pass": ([RR, PASSV], 1, [r11(0)]),
    "out-of-range": ([RR], 5, [r11(0)]),
    "negative": ([RR], -1, [r11(0)]),
    "boolean-true": ([RR], True, [r11(0)]),
    "boolean-false": ([RR], False, [r11(0)]),
    "null": ([RR], None, [r11(0)]),
    "string": ([RR], "0", [r11(0)]),
    "halt-target": ([HALT], 0, [r11(0)]),
    "awaiting-target": ([WAIT], 0, [r11(0)]),
    "outcomes-absent": (ABSENT, 0, [r11(0)]),
    "outcomes-not-list": ("PASS", 0, [R8A, r11(0)]),
    "non-object-target": ([7], 0, [r8b(0), r11(0)]),
}


@pytest.mark.parametrize(
    ("outcomes", "opened", "expected"),
    list(OPENED_CASES.values()),
    ids=list(OPENED_CASES),
)
def test_opened_by_review_rules(
    outcomes: object, opened: object, expected: list[str]
) -> None:
    """R11 requires an integer index of a REMEDIATION_REQUIRED outcome."""
    loop: dict[str, object] = {"cycles": [vc(opened_by_review=opened)]}
    if outcomes is not ABSENT:
        loop["review_outcomes"] = outcomes
    assert loop_errors(loop) == expected


def test_error_order_across_families() -> None:
    """Legacy, review-outcome, per-cycle, then attempt-count errors, in order."""
    # Arrange: errors in every family across two cycles and two outcomes.
    loop: dict[str, object] = {
        "cycles": [
            vc(plan_path="", candidate_applied="yes", opened_by_review=3),
            vc(candidate_applied=True, execution_status="failed"),
        ],
        "review_outcomes": [
            {"verdict": "Pass", "findings": []},
            {"verdict": "PASS", "findings": "x"},
        ],
        "completed_attempts": 5,
    }
    expected = [
        "Checkpoint remediation cycle #0 plan_path must be a non-empty string.",
        r9a(0, "Pass"),
        r9b(1),
        r5(0),
        r11(0),
        r6(1),
        r7b(5, 1),
    ]
    # Act
    observed = loop_errors(loop)
    # Assert
    assert observed == expected


@pytest.mark.parametrize(
    "loop",
    [{"current_cycle": 0, "cycles": [vc()]}, {"cycles": "none"}, {}, "active"],
    ids=["legacy-cycle", "cycles-not-list", "empty-loop", "loop-not-object"],
)
def test_checkpoint_without_new_keys_yields_no_new_errors(loop: object) -> None:
    """A loop with none of the new keys produces no remediation error."""
    assert loop_errors(loop) == []


def test_halt_checkpoint_without_cycles_validates_clean() -> None:
    """A halt outcome with no cycles and an external_dependency halt is valid."""
    # Arrange
    state = build_complete_small_state()
    state["blocked_reason"] = "external_dependency"
    state["remediation_loop"] = {"review_outcomes": [HALT]}
    # Act
    errors = state_validator.validate_orchestrator_state_text(json.dumps(state))
    # Assert: the full, unfiltered error list is empty.
    assert errors == []
