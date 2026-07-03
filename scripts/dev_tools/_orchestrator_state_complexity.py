"""Complexity-assessment invariants for orchestrator-state checkpoints.

Purpose:
    Hold the optional ``complexity_assessments`` array constants and the
    ``_validate_complexity_assessments`` helper so the primary validator module
    (`scripts.dev_tools.validate_orchestrator_state`) can stay within the
    repository's 500-line file limit while preserving the existing validator
    contract. The invariants mirror the complexity-assessment obligations
    documented in `.claude/rules/orchestrator-state.md` and the Model Selection
    Contract in the two-axis-model-selection spec.

Usage:
    Import ``COMPLEXITY_ASSESSMENTS_KEY`` and
    ``_validate_complexity_assessments`` from this module. The primary
    validator invokes the helper only when the checkpoint carries the
    ``complexity_assessments`` key, so an absent key contributes zero errors.

Invariants / Constraints:
    - Each assessment's ``band`` must be one of ``C1``..``C4``.
    - ``band >= floor`` (the floor is a lower bound only).
    - ``floor == compute_complexity_floor(signals_present)``.
    - ``rationale`` must be a non-empty string.
    - The validator never judges the merit of the assessed band; it checks
      shape, floor equality, and lower-bound ordering only. It never imports
      ``schemas/orchestrator-state.schema.json``; the invariants are expressed
      directly here per `.claude/rules/orchestrator-state.md`.

Side Effects:
    None.
"""

from __future__ import annotations

from typing import Any, cast

from scripts.dev_tools.compute_complexity_floor import (
    BAND_ORDER,
    compute_complexity_floor,
)

# Declare the module's intended exported surface. Listing
# ``_validate_complexity_assessments`` here marks it as a deliberate re-export
# consumed by ``validate_orchestrator_state``, so static analysis does not flag
# the helper as unused or as private-usage across the module boundary.
__all__ = [
    "COMPLEXITY_ASSESSMENTS_KEY",
    "_validate_complexity_assessments",
]

COMPLEXITY_ASSESSMENTS_KEY = "complexity_assessments"
# The permitted band vocabulary, reused from the floor reference implementation
# so the enum and the ordering stay in one place.
_VALID_BANDS = frozenset(BAND_ORDER)


def _validate_complexity_assessments(value: object) -> list[str]:
    """Validate the optional ``complexity_assessments`` array invariants.

    Purpose:
        Apply the Model Selection Contract's complexity-assessment invariants
        to the checkpoint's optional ``complexity_assessments`` array,
        mirroring the prose in `.claude/rules/orchestrator-state.md`. The
        validator never imports a schema file; the invariants are expressed
        directly here in the existing helper-plus-error-list style.

    Args:
        value (object): The raw value of the checkpoint's
            ``complexity_assessments`` key. Callers invoke this helper only
            when the key is present, so a non-list value is itself a malformed
            block.

    Returns:
        list[str]: One error string per violated invariant; an empty list when
        every assessment is well-formed. The invariants are: ``band`` within
        the enum; ``band >= floor``; ``floor`` equals
        ``compute_complexity_floor(signals_present)``; ``rationale`` is a
        non-empty string.

    Raises:
        None.

    Side Effects:
        None.
    """

    errors: list[str] = []

    # A non-list value cannot carry assessment entries; the key was present, so
    # this is a malformed block rather than an absent one.
    if not isinstance(value, list):
        errors.append("Checkpoint complexity_assessments must be a list when present.")
        return errors
    assessment_list = cast("list[object]", value)

    # Validate each assessment independently so callers receive a complete
    # error list instead of stopping at the first malformed entry.
    for index, assessment in enumerate(assessment_list):
        if not isinstance(assessment, dict):
            errors.append(
                f"Checkpoint complexity_assessments #{index} must be an object."
            )
            continue
        assessment_map = cast("dict[str, Any]", assessment)
        errors.extend(_validate_one_assessment(index, assessment_map))

    return errors


def _validate_one_assessment(index: int, assessment: dict[str, Any]) -> list[str]:
    """Validate a single complexity-assessment entry.

    Purpose:
        Check the band enum, the ``band >= floor`` lower bound, the
        ``floor == compute_complexity_floor(signals_present)`` equality, and
        the non-empty ``rationale`` invariant for one assessment entry.

    Args:
        index (int): The assessment's position in the array, used to build a
            checkpoint-context-prefixed error message.
        assessment (dict[str, Any]): The parsed assessment object.

    Returns:
        list[str]: One error string per violated invariant for this entry.

    Raises:
        None.

    Side Effects:
        None.
    """

    errors: list[str] = []
    band = assessment.get("band")
    floor = assessment.get("floor")
    signals_present = assessment.get("signals_present")
    rationale = assessment.get("rationale")

    # Invariant: band must be within the permitted enum.
    if band not in _VALID_BANDS:
        errors.append(
            f"Checkpoint complexity_assessments #{index} band must be one of "
            f"C1, C2, C3, C4; got: {band}."
        )

    # Invariant: signals_present must be a list of strings so the floor can be
    # recomputed; without it the floor-equality check cannot run.
    signal_names = _string_list(signals_present)
    if signal_names is None:
        errors.append(
            f"Checkpoint complexity_assessments #{index} signals_present must "
            "be a list of strings."
        )
    else:
        # Invariant: floor must equal the deterministic recomputed floor.
        expected_floor = compute_complexity_floor(signal_names)
        if floor != expected_floor:
            errors.append(
                f"Checkpoint complexity_assessments #{index} floor {floor} does "
                "not equal compute_complexity_floor(signals_present) "
                f"{expected_floor}."
            )

    # Invariant: band >= floor lower-bound ordering; both must be valid bands
    # to compare, so a prior enum error suppresses a spurious ordering error.
    if (
        band in _VALID_BANDS
        and floor in _VALID_BANDS
        and BAND_ORDER.index(cast("str", band)) < BAND_ORDER.index(cast("str", floor))
    ):
        errors.append(
            f"Checkpoint complexity_assessments #{index} band {band} is below "
            f"its floor {floor}."
        )

    # Invariant: rationale must be a non-empty string.
    if not isinstance(rationale, str) or not rationale.strip():
        errors.append(
            f"Checkpoint complexity_assessments #{index} rationale must be a "
            "non-empty string."
        )

    return errors


def _string_list(value: object) -> list[str] | None:
    """Return a list of strings only when the value has that exact shape.

    Args:
        value (object): The candidate value.

    Returns:
        list[str] | None: The value as a list of strings, or None when it is
        not a list or contains a non-string element.

    Raises:
        None.

    Side Effects:
        None.
    """

    if not isinstance(value, list):
        return None
    items = cast("list[object]", value)
    if not all(isinstance(item, str) for item in items):
        return None
    return cast("list[str]", items)
