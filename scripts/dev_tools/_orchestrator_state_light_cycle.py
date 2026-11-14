"""Validate the light-remediation invariant 8 of an orchestrator-state checkpoint.

Purpose:
    Hold invariant 8 of `.claude/rules/orchestrator-state.md` (issue #1097): a
    remediation cycle that carries `remediation_path` names a known path, and a
    `light` cycle carries no preflight, names its opening review, fixes at most
    three contained autonomous findings, and does not follow another light cycle.

Usage:
    `_orchestrator_state_remediation_loop._validate_remediation_accounting`
    calls `validate_light_cycles` last, passing the cycle list, the raw
    `review_outcomes` value, and its private R11 predicate. Passing the
    predicate keeps this module free of an import of the loop module, so no
    import cycle arises and the predicate is not duplicated.

Invariants / Constraints:
    The message strings are byte-identical to the TypeScript port
    `extensions/drm-copilot/src/lib/validate/orchestrator-state-light-cycle.ts`
    and the PowerShell `Get-RemediationLightCycleError`, and render no
    checkpoint value. A cycle without the key reaches no rule, so every
    existing checkpoint validates exactly as before.

Side Effects:
    None. Every function is pure and returns a list of error strings.
"""

from __future__ import annotations

from typing import TYPE_CHECKING, Any, cast

if TYPE_CHECKING:
    from collections.abc import Callable, Sequence

REMEDIATION_PATH_KEY = "remediation_path"
LIGHT_REMEDIATION_PATH = "light"
FULL_REMEDIATION_PATH = "full"
LIGHT_FINDING_LIMIT = 3

_PREFLIGHT_KEY = "preflight"
_OPENED_BY_REVIEW_KEY = "opened_by_review"
_AUTONOMOUS_CLASS = "autonomous"
_CONTAINED_SCOPE = "contained"


def _opening_findings(opened_by_review: object, outcomes: object) -> list[object]:
    """Return the findings list of the review outcome a light cycle names.

    Args:
        opened_by_review: The cycle's `opened_by_review` value, already proven
            by the caller to index a `REMEDIATION_REQUIRED` outcome object.
        outcomes: The raw `review_outcomes` list.

    Returns:
        The outcome's `findings` list, or an empty list when the value is not a
        list, because rule R9b already reports that shape error.
    """

    outcome = cast(
        "dict[str, Any]", cast("list[object]", outcomes)[cast("int", opened_by_review)]
    )
    findings = outcome.get("findings")
    return cast("list[object]", findings) if isinstance(findings, list) else []


def _finding_value(finding: object, key: str) -> object:
    """Return one key of a finding, or None for a non-object finding.

    Args:
        finding: One element of an outcome's `findings` list.
        key: The finding key to read.

    Returns:
        The value under the key, or None when the finding is not an object or
        lacks the key; None never equals a required class or scope.
    """

    if not isinstance(finding, dict):
        return None
    return cast("dict[str, Any]", finding).get(key)


def _light_cycle_errors(
    index: int,
    cycle: dict[str, Any],
    prior: object,
    outcomes: object,
    opens_review: Callable[[object, object], bool],
) -> list[str]:
    """Return the rule 2 to 7 errors of one cycle whose path is exactly light.

    Args:
        index: The cycle's zero-based position in `cycles`.
        cycle: The cycle object.
        prior: The immediately prior list element, or None for the first cycle.
        outcomes: The raw `review_outcomes` value.
        opens_review: The R11 predicate of the loop module.

    Returns:
        The errors in rule order: preflight, opening review, finding count,
        then each non-autonomous finding, then each non-contained finding, then
        a light prior cycle.
    """

    prefix = f"Checkpoint remediation cycle #{index} remediation_path is light but"
    errors: list[str] = []

    # Rule 2: any preflight key is untruthful, because a light cycle runs none.
    if _PREFLIGHT_KEY in cycle:
        errors.append(f"{prefix} the cycle carries preflight.")

    # Rule 3 gates rules 4 to 6: without a valid opening review there are no
    # findings to count or classify.
    opened_by_review = cycle.get(_OPENED_BY_REVIEW_KEY)
    if _OPENED_BY_REVIEW_KEY not in cycle or not opens_review(
        opened_by_review, outcomes
    ):
        errors.append(f"{prefix} opened_by_review does not name its opening review.")
    else:
        findings = _opening_findings(opened_by_review, outcomes)
        if len(findings) > LIGHT_FINDING_LIMIT:
            errors.append(
                f"{prefix} its opening review has {len(findings)} findings; "
                f"the limit is {LIGHT_FINDING_LIMIT}."
            )
        # Report every finding a light cycle may not fix autonomously, in order.
        for finding_index, finding in enumerate(findings):
            if _finding_value(finding, "remediability") != _AUTONOMOUS_CLASS:
                errors.append(f"{prefix} finding #{finding_index} is not autonomous.")
        # Report every finding whose fix is not contained, absent scope included.
        for finding_index, finding in enumerate(findings):
            if _finding_value(finding, "scope") != _CONTAINED_SCOPE:
                errors.append(
                    f"{prefix} finding #{finding_index} scope is not contained."
                )

    # Rule 7: two light cycles may not run back to back.
    if isinstance(prior, dict) and (
        cast("dict[str, Any]", prior).get(REMEDIATION_PATH_KEY)
        == LIGHT_REMEDIATION_PATH
    ):
        errors.append(f"{prefix} the prior cycle is light.")

    return errors


def validate_light_cycles(
    cycle_list: Sequence[object] | None,
    outcomes: object,
    opens_review: Callable[[object, object], bool],
) -> list[str]:
    """Return the invariant 8 errors of every cycle that carries remediation_path.

    Args:
        cycle_list: The `cycles` list, or None when absent or not a list.
        outcomes: The raw `review_outcomes` value; may be any JSON value.
        opens_review: The R11 predicate, which reports whether an
            `opened_by_review` value indexes a `REMEDIATION_REQUIRED` outcome
            object.

    Returns:
        The errors in cycle order. A non-object cycle and a cycle without the
        key contribute nothing; `full` contributes nothing; any other value,
        null included, contributes rule 1 alone.
    """

    errors: list[str] = []
    cycles = list(cycle_list or [])

    # Walk the cycles in order so each light cycle can see its immediate prior.
    for index, raw_cycle in enumerate(cycles):
        if not isinstance(raw_cycle, dict):
            continue
        cycle = cast("dict[str, Any]", raw_cycle)
        if REMEDIATION_PATH_KEY not in cycle:
            continue
        path = cycle[REMEDIATION_PATH_KEY]
        # Rule 1 routes by exact value: full has no further rule, light runs
        # rules 2 to 7, and anything else is reported once and stops there.
        if path == FULL_REMEDIATION_PATH:
            continue
        if path != LIGHT_REMEDIATION_PATH:
            errors.append(
                f"Checkpoint remediation cycle #{index} remediation_path must be "
                "light or full."
            )
            continue
        prior = cycles[index - 1] if index > 0 else None
        errors.extend(_light_cycle_errors(index, cycle, prior, outcomes, opens_review))

    return errors
