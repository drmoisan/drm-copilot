"""Validate the remediation-loop section of an orchestrator-state checkpoint.

Purpose:
    Hold the remediation-loop constants and validators that were extracted from
    `validate_orchestrator_state` so that module stays below the 500-line file
    limit and keeps headroom for later contract changes.

Usage:
    `validate_orchestrator_state` imports `REMEDIATION_LOOP_KEY` and
    `_validate_remediation_loop` from this module and calls the validator with
    the checkpoint's `remediation_loop` value.

Invariants / Constraints:
    The per-cycle message text, ordering, and logic are identical to the
    pre-extraction implementation. Issue #484 adds the review-outcome and
    accounting invariants R5-R11 (source: `.claude/rules/orchestrator-state.md`),
    which run after the per-cycle checks and also when `cycles` is absent. The
    validators never modify their input.

Side Effects:
    None. Every function is pure and returns a list of error strings.
"""

from __future__ import annotations

from typing import TYPE_CHECKING, Any, Literal, cast

if TYPE_CHECKING:
    from collections.abc import Sequence

# Declare the module's intended exported surface. Listing ``REMEDIATION_LOOP_KEY``
# and ``_validate_remediation_loop`` here marks them as deliberate re-exports
# consumed by ``validate_orchestrator_state``, so static analysis does not flag
# them as unused locally or as private-usage across the module boundary.
__all__ = [
    "REMEDIATION_LOOP_KEY",
    "_validate_remediation_loop",
    "REVIEW_OUTCOMES_KEY",
    "COMPLETED_ATTEMPTS_KEY",
    "CANDIDATE_APPLIED_KEY",
    "OPENED_BY_REVIEW_KEY",
    "ReviewVerdict",
    "REVIEW_VERDICTS",
    "REMEDIABILITY_CLASSES",
    "NON_REMEDIABLE_CLASSES",
    "HALT_CLASSES",
    "derive_review_verdict",
]

REMEDIATION_LOOP_KEY = "remediation_loop"
REMEDIATION_CYCLES_KEY = "cycles"
EXECUTION_STATUSES_REQUIRING_CLEAR_PREFLIGHT = {
    "in_progress",
    "complete",
    "failed",
}
PREFLIGHT_CLEARED_STATUS = "clear"

# Issue #484 remediation accounting (invariants R5-R11). The vocabulary below is
# mirrored exactly by the TypeScript and PowerShell validators.
REVIEW_OUTCOMES_KEY = "review_outcomes"
COMPLETED_ATTEMPTS_KEY = "completed_attempts"
CANDIDATE_APPLIED_KEY = "candidate_applied"
OPENED_BY_REVIEW_KEY = "opened_by_review"
COMPLETED_EXECUTION_STATUS = "complete"

ReviewVerdict = Literal[
    "PASS", "REMEDIATION_REQUIRED", "HALT_NON_REMEDIABLE", "AWAITING_CI"
]
REVIEW_VERDICTS: tuple[ReviewVerdict, ...] = (
    "PASS",
    "REMEDIATION_REQUIRED",
    "HALT_NON_REMEDIABLE",
    "AWAITING_CI",
)
REMEDIABILITY_CLASSES: tuple[str, ...] = (
    "autonomous",
    "external_dependency",
    "policy_hold",
    "awaiting_ci",
    "human_decision_required",
)
NON_REMEDIABLE_CLASSES: frozenset[str] = frozenset(
    {"external_dependency", "policy_hold", "awaiting_ci", "human_decision_required"}
)
HALT_CLASSES: frozenset[str] = frozenset(
    {"external_dependency", "policy_hold", "human_decision_required"}
)
_REMEDIABLE_CLASS = "autonomous"
_REMEDIATION_REQUIRED_VERDICT: ReviewVerdict = "REMEDIATION_REQUIRED"


def derive_review_verdict(remediabilities: Sequence[str]) -> ReviewVerdict:
    """Derive a review verdict from its blocking findings' remediability classes.

    Args:
        remediabilities: The remediability class of every blocking finding, in
            any order; duplicates are permitted.

    Returns:
        ``PASS`` for no findings; ``REMEDIATION_REQUIRED`` when any finding is
        ``autonomous``; ``HALT_NON_REMEDIABLE`` when any finding is a member of
        ``HALT_CLASSES``; otherwise ``AWAITING_CI``.

    Raises:
        ValueError: A member is not in ``REMEDIABILITY_CLASSES``; the message
            starts with ``invalid remediability: ``.
    """

    for value in remediabilities:
        if value not in REMEDIABILITY_CLASSES:
            raise ValueError(f"invalid remediability: {value}")
    if not remediabilities:
        return "PASS"
    if _REMEDIABLE_CLASS in remediabilities:
        return "REMEDIATION_REQUIRED"
    if any(value in HALT_CLASSES for value in remediabilities):
        return "HALT_NON_REMEDIABLE"
    return "AWAITING_CI"


def _is_strict_int(value: object) -> bool:
    """Return True for an integer that is not a boolean."""

    return isinstance(value, int) and not isinstance(value, bool)


def _validate_remediation_cycle(index: int, cycle: dict[str, Any]) -> list[str]:
    """Validate one remediation cycle without changing checkpoint state."""

    errors: list[str] = []

    plan_path = cycle.get("plan_path")
    if not isinstance(plan_path, str) or not plan_path.strip():
        errors.append(
            f"Checkpoint remediation cycle #{index} plan_path must be a "
            "non-empty string."
        )

    execution_status = cycle.get("execution_status")
    if execution_status in EXECUTION_STATUSES_REQUIRING_CLEAR_PREFLIGHT:
        preflight = cycle.get("preflight")
        preflight_status: object = (
            cast("dict[str, Any]", preflight).get("final_status")
            if isinstance(preflight, dict)
            else None
        )
        if preflight_status != PREFLIGHT_CLEARED_STATUS:
            errors.append(
                f"Checkpoint remediation cycle #{index} execution_status is "
                f"{execution_status} but preflight.final_status is not 'clear'."
            )

    if cycle.get("exit_condition_met") is True and cycle.get("blocking_count") != 0:
        errors.append(
            f"Checkpoint remediation cycle #{index} exit_condition_met is true "
            "but blocking_count is not 0."
        )

    return errors


def _validate_review_outcome(index: int, outcome: dict[str, Any]) -> list[str]:
    """Return the R9a-R9d and R10 errors for one review outcome object."""

    errors: list[str] = []
    prefix = f"Checkpoint remediation review outcome #{index}"

    verdict = outcome.get("verdict")
    if not isinstance(verdict, str) or verdict not in REVIEW_VERDICTS:
        errors.append(
            f"{prefix} verdict must be one of PASS, REMEDIATION_REQUIRED, "
            f"HALT_NON_REMEDIABLE, AWAITING_CI; got: {verdict}"
        )

    classes: list[str] = []
    findings = outcome.get("findings")
    if not isinstance(findings, list):
        errors.append(f"{prefix} findings must be a list.")
    else:
        for finding_index, finding in enumerate(cast("list[object]", findings)):
            if not isinstance(finding, dict):
                errors.append(f"{prefix} finding #{finding_index} must be an object.")
                continue
            remediability = cast("dict[str, Any]", finding).get("remediability")
            if (
                not isinstance(remediability, str)
                or remediability not in REMEDIABILITY_CLASSES
            ):
                errors.append(
                    f"{prefix} finding #{finding_index} remediability must be one "
                    "of autonomous, external_dependency, policy_hold, awaiting_ci, "
                    f"human_decision_required; got: {remediability}"
                )
                continue
            classes.append(remediability)

    # R10 compares only a well-formed outcome; any shape error above suppresses it.
    if not errors:
        expected = derive_review_verdict(classes)
        if verdict != expected:
            errors.append(
                f"{prefix} verdict {verdict} does not match its findings "
                f"(expected {expected})."
            )

    return errors


def _validate_review_outcomes(loop_map: dict[str, Any]) -> list[str]:
    """Return the R8a, R8b, R9a-R9d, and R10 errors in spec order."""

    if REVIEW_OUTCOMES_KEY not in loop_map:
        return []
    outcomes = loop_map[REVIEW_OUTCOMES_KEY]
    if not isinstance(outcomes, list):
        return ["Checkpoint remediation_loop review_outcomes must be a list."]

    errors: list[str] = []
    for index, outcome in enumerate(cast("list[object]", outcomes)):
        if not isinstance(outcome, dict):
            errors.append(
                f"Checkpoint remediation review outcome #{index} must be an object."
            )
            continue
        errors.extend(_validate_review_outcome(index, cast("dict[str, Any]", outcome)))
    return errors


def _opens_remediation_review(opened_by_review: object, outcomes: object) -> bool:
    """Return True when the index names a REMEDIATION_REQUIRED outcome object."""

    if not _is_strict_int(opened_by_review) or not isinstance(outcomes, list):
        return False
    index = cast("int", opened_by_review)
    outcome_list = cast("list[object]", outcomes)
    if index < 0 or index >= len(outcome_list):
        return False
    target = outcome_list[index]
    if not isinstance(target, dict):
        return False
    verdict = cast("dict[str, Any]", target).get("verdict")
    return verdict == _REMEDIATION_REQUIRED_VERDICT


def _validate_remediation_accounting(
    loop_map: dict[str, Any], cycle_list: list[object] | None
) -> list[str]:
    """Return the per-cycle R5, R6, R11 errors, then R7a or R7b."""

    errors: list[str] = []
    outcomes = loop_map.get(REVIEW_OUTCOMES_KEY)
    applied_count = 0

    for index, raw_cycle in enumerate(cycle_list or []):
        if not isinstance(raw_cycle, dict):
            continue
        cycle = cast("dict[str, Any]", raw_cycle)
        prefix = f"Checkpoint remediation cycle #{index}"
        if CANDIDATE_APPLIED_KEY in cycle:
            candidate_applied = cycle[CANDIDATE_APPLIED_KEY]
            if not isinstance(candidate_applied, bool):
                errors.append(f"{prefix} candidate_applied must be a boolean.")
            elif candidate_applied:
                applied_count += 1
                if cycle.get("execution_status") != COMPLETED_EXECUTION_STATUS:
                    errors.append(
                        f"{prefix} candidate_applied is true but execution_status "
                        "is not 'complete'."
                    )
        if OPENED_BY_REVIEW_KEY in cycle and not _opens_remediation_review(
            cycle[OPENED_BY_REVIEW_KEY], outcomes
        ):
            errors.append(
                f"{prefix} opened_by_review must reference a review outcome whose "
                "verdict is REMEDIATION_REQUIRED."
            )

    if COMPLETED_ATTEMPTS_KEY in loop_map:
        completed_attempts = loop_map[COMPLETED_ATTEMPTS_KEY]
        if not _is_strict_int(completed_attempts) or completed_attempts < 0:
            errors.append(
                "Checkpoint remediation_loop completed_attempts must be a "
                "non-negative integer."
            )
        elif completed_attempts != applied_count:
            errors.append(
                f"Checkpoint remediation_loop completed_attempts is "
                f"{completed_attempts} but {applied_count} cycles have "
                "candidate_applied true."
            )

    return errors


def _validate_remediation_loop(remediation_loop: object) -> list[str]:
    """Validate a checkpoint's remediation_loop value without changing it.

    Returns the existing per-cycle errors (when ``cycles`` is a list), then the
    review-outcome errors, then the accounting errors (R5-R11, issue #484).
    """

    errors: list[str] = []

    # A non-object remediation_loop carries no cycles to validate; treat it as
    # nothing to enforce rather than fabricating a structural error here.
    if not isinstance(remediation_loop, dict):
        return errors
    loop_map = cast("dict[str, Any]", remediation_loop)

    cycles = loop_map.get(REMEDIATION_CYCLES_KEY)
    cycle_list: list[object] | None = None
    if isinstance(cycles, list):
        cycle_list = cast("list[object]", cycles)
        # Validate each cycle independently so callers receive a complete error
        # list instead of stopping at the first malformed cycle.
        for index, cycle in enumerate(cycle_list):
            if not isinstance(cycle, dict):
                errors.append(
                    f"Checkpoint remediation cycle #{index} must be an object."
                )
                continue
            errors.extend(
                _validate_remediation_cycle(index, cast("dict[str, Any]", cycle))
            )

    errors.extend(_validate_review_outcomes(loop_map))
    errors.extend(_validate_remediation_accounting(loop_map, cycle_list))
    return errors
