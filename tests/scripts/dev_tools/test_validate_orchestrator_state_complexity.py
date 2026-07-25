"""Tests for the ``complexity_assessments`` checkpoint validator.

Synthetic assessment arrays are built by loading the ``model_policy`` block
from the live routing matrix (`load_routing_matrix()`), so the fixtures track
the config catalog rather than hardcoding floor-signal names or the band table.
Each failure test asserts the literal, checkpoint-context-prefixed message.
"""

from __future__ import annotations

import json
from typing import Any, cast

import scripts.dev_tools.validate_orchestrator_state as state_validator
from scripts.dev_tools._orchestrator_state_complexity import (
    COMPLEXITY_ASSESSMENTS_KEY,
    _validate_complexity_assessments,
)
from scripts.dev_tools._orchestrator_state_routing import load_routing_matrix
from scripts.dev_tools.compute_complexity_floor import compute_complexity_floor
from tests.scripts.dev_tools.test_validate_orchestrator_state_remediation_loop import (
    build_valid_orchestrator_state,
)


def _floor_signal() -> str:
    """Return one ``[floor]``-flagged signal name from the live routing matrix.

    Returns:
        str: The first floor-signal name in the ``model_policy.complexity``
        catalog.

    Raises:
        None.

    Side Effects:
        Reads the routing matrix from disk.
    """

    matrix = load_routing_matrix()
    model_policy = cast("dict[str, Any]", matrix["model_policy"])
    signals = cast("list[dict[str, Any]]", model_policy["complexity"]["signals"])
    # Return the first catalog signal flagged as a floor signal.
    return next(str(entry["name"]) for entry in signals if entry.get("floor") is True)


def _non_floor_signals() -> tuple[str, ...]:
    """Return the ``"floor": false`` signal names from the live routing matrix.

    Returns:
        tuple[str, ...]: The names of catalog signals explicitly flagged
        ``floor: false``, in catalog order.

    Raises:
        None.

    Side Effects:
        Reads the routing matrix from disk.
    """

    matrix = load_routing_matrix()
    model_policy = cast("dict[str, Any]", matrix["model_policy"])
    signals = cast("list[dict[str, Any]]", model_policy["complexity"]["signals"])
    # Select the names of catalog signals explicitly flagged as non-floor.
    return tuple(str(entry["name"]) for entry in signals if entry.get("floor") is False)


def _non_floor_only_assessment() -> dict[str, Any]:
    """Build an assessment whose ``signals_present`` holds only non-floor names.

    Returns:
        dict[str, Any]: An assessment recording every ``"floor": false`` catalog
        signal, with ``floor`` and ``band`` both set to ``C1``.

    Raises:
        None.

    Side Effects:
        Reads the routing matrix from disk.
    """

    return {
        "phase": "P2",
        "band": "C1",
        "floor": "C1",
        "signals_present": list(_non_floor_signals()),
        "rationale": "Localized documentation edit with no floor signal present.",
        "assessed_at": "2026-07-25T17-45",
    }


def _well_formed_assessment() -> dict[str, Any]:
    """Build one well-formed assessment entry driven by the live catalog.

    Returns:
        dict[str, Any]: An assessment whose floor equals the recomputed floor
        and whose band satisfies ``band >= floor``.

    Raises:
        None.

    Side Effects:
        Reads the routing matrix from disk.
    """

    signal = _floor_signal()
    floor = compute_complexity_floor([signal])
    return {
        "phase": "P1",
        "band": floor,
        "floor": floor,
        "signals_present": [signal],
        "rationale": "Cross-module contract change touches an invariant.",
        "assessed_at": "2026-07-03T16-43",
    }


def test_well_formed_assessments_pass() -> None:
    """A well-formed assessment array produces zero errors."""

    # Arrange: a single well-formed assessment.
    assessments = [_well_formed_assessment()]

    # Act: validate the array.
    errors = _validate_complexity_assessments(assessments)

    # Assert: no invariant is violated.
    assert errors == []


def test_band_enum_violation_reported() -> None:
    """An out-of-enum band is reported with the literal enum message."""

    # Arrange: an assessment whose band is outside C1..C4.
    assessment = _well_formed_assessment()
    assessment["band"] = "C5"

    # Act: validate the array.
    errors = _validate_complexity_assessments([assessment])

    # Assert: the enum message is present.
    assert any(
        "complexity_assessments #0 band must be one of C1, C2, C3, C4; got: C5."
        in error
        for error in errors
    )


def test_band_below_floor_violation_reported() -> None:
    """A ``band < floor`` assessment is reported with the literal message."""

    # Arrange: floor stays C3 (a floor signal is present) but band drops to C1.
    assessment = _well_formed_assessment()
    assessment["band"] = "C1"
    assessment["floor"] = "C3"

    # Act: validate the array.
    errors = _validate_complexity_assessments([assessment])

    # Assert: the below-floor ordering message is present.
    assert any(
        "complexity_assessments #0 band C1 is below its floor C3." in error
        for error in errors
    )


def test_floor_not_equal_computed_violation_reported() -> None:
    """A ``floor != compute_complexity_floor(...)`` assessment is reported."""

    # Arrange: no floor signals present (expected floor C1) but floor claims C3.
    assessment = _well_formed_assessment()
    assessment["signals_present"] = []
    assessment["floor"] = "C3"
    assessment["band"] = "C3"

    # Act: validate the array.
    errors = _validate_complexity_assessments([assessment])

    # Assert: the floor-equality message names the recomputed floor C1.
    assert any(
        "complexity_assessments #0 floor C3 does not equal "
        "compute_complexity_floor(signals_present) C1." in error
        for error in errors
    )


def test_empty_rationale_violation_reported() -> None:
    """A whitespace-only rationale is reported with the literal message."""

    # Arrange: a whitespace-only rationale.
    assessment = _well_formed_assessment()
    assessment["rationale"] = "   "

    # Act: validate the array.
    errors = _validate_complexity_assessments([assessment])

    # Assert: the non-empty-rationale message is present.
    assert any(
        "complexity_assessments #0 rationale must be a non-empty string." in error
        for error in errors
    )


def test_non_list_value_reported() -> None:
    """A present-but-non-list value is reported as a malformed block."""

    # Arrange / Act: a non-list value under the key.
    errors = _validate_complexity_assessments({"not": "a list"})

    # Assert: the malformed-block message is present.
    assert any(
        "complexity_assessments must be a list when present." in error
        for error in errors
    )


def test_non_object_entry_reported() -> None:
    """A non-object assessment entry is reported with its index."""

    # Arrange / Act: an array whose sole entry is not an object.
    errors = _validate_complexity_assessments(["not-an-object"])

    # Assert: the per-index object message is present.
    assert any(
        "complexity_assessments #0 must be an object." in error for error in errors
    )


def test_signals_present_not_a_list_reported() -> None:
    """A non-list ``signals_present`` is reported and skips the floor check."""

    # Arrange: signals_present is a string rather than a list of strings.
    assessment = _well_formed_assessment()
    assessment["signals_present"] = "not-a-list"

    # Act: validate the array.
    errors = _validate_complexity_assessments([assessment])

    # Assert: the signals_present shape message is present.
    assert any(
        "complexity_assessments #0 signals_present must be a list of strings." in error
        for error in errors
    )


def test_signals_present_with_non_string_element_reported() -> None:
    """A ``signals_present`` list containing a non-string is reported."""

    # Arrange: signals_present holds a non-string element.
    assessment = _well_formed_assessment()
    assessment["signals_present"] = ["ok", 123]

    # Act: validate the array.
    errors = _validate_complexity_assessments([assessment])

    # Assert: the signals_present shape message is present.
    assert any(
        "complexity_assessments #0 signals_present must be a list of strings." in error
        for error in errors
    )


def _state_with_complexity(assessments: object) -> str:
    """Return checkpoint JSON carrying a top-level ``complexity_assessments``.

    Args:
        assessments (object): The value to embed under the key.

    Returns:
        str: Serialized checkpoint JSON including the additive key.

    Raises:
        None.

    Side Effects:
        Reads the routing matrix from disk (via the base checkpoint fixture).
    """

    state = build_valid_orchestrator_state()
    state["complexity_assessments"] = assessments
    return json.dumps(state)


def test_no_complexity_assessments_is_backward_compatible() -> None:
    """A checkpoint with no complexity_assessments validates exactly as before."""

    # Arrange: a valid step-based checkpoint that omits the additive key.
    state = build_valid_orchestrator_state()
    assert "complexity_assessments" not in state

    # Act: validate the checkpoint through the public validator.
    errors = state_validator.validate_orchestrator_state_text(json.dumps(state))

    # Assert: no errors at all, and no complexity_assessments error text.
    assert errors == []
    assert not any("complexity_assessments" in error for error in errors)


def test_present_well_formed_complexity_wired_through_public_validator() -> None:
    """A present well-formed array produces no complexity_assessments errors."""

    # Arrange / Act: embed a well-formed assessment and validate end to end.
    errors = state_validator.validate_orchestrator_state_text(
        _state_with_complexity([_well_formed_assessment()])
    )

    # Assert: the key-gated block runs but reports no error for valid data.
    assert not any("complexity_assessments" in error for error in errors)


def test_present_malformed_complexity_caught_by_public_validator() -> None:
    """A present malformed array is caught through the public validator."""

    # Arrange: a malformed assessment with an empty rationale.
    assessment = _well_formed_assessment()
    assessment["rationale"] = ""

    # Act: validate through the public validator.
    errors = state_validator.validate_orchestrator_state_text(
        _state_with_complexity([assessment])
    )

    # Assert: the malformed data is reported via the wired block.
    assert any(
        "complexity_assessments #0 rationale must be a non-empty string." in error
        for error in errors
    )


def test_non_floor_only_assessment_with_floor_c1_accepted() -> None:
    """An assessment recording only non-floor signals validates with ``floor: C1``."""

    # Arrange: an assessment whose signals_present holds only non-floor names.
    assessment = _non_floor_only_assessment()

    # Act: validate the array.
    errors = _validate_complexity_assessments([assessment])

    # Assert: the recomputed floor is C1, so the entry is well formed.
    assert errors == []


def test_non_floor_only_assessment_with_floor_c3_rejected() -> None:
    """The same non-floor-only entry claiming ``floor: C3`` is rejected.

    Purpose:
        Cover the documented backward-compatibility consequence: a pre-change
        checkpoint whose assessment recorded only non-floor signals necessarily
        recorded `floor: "C3"`, and must now fail with a floor-mismatch error
        naming the recomputed value `C1`.

    Args:
        None.

    Returns:
        None: Assertions verify the literal floor-mismatch message.

    Raises:
        None.

    Side Effects:
        Reads the routing matrix from disk.
    """

    # Arrange: the same entry with the stale pre-change floor and band.
    assessment = _non_floor_only_assessment()
    assessment["floor"] = "C3"
    assessment["band"] = "C3"

    # Act: validate the array.
    errors = _validate_complexity_assessments([assessment])

    # Assert: the floor-equality message names the recomputed floor C1.
    assert any(
        "complexity_assessments #0 floor C3 does not equal "
        "compute_complexity_floor(signals_present) C1." in error
        for error in errors
    )


def test_key_constant_value() -> None:
    """The exported key constant matches the checkpoint field name."""

    # Assert: the constant is the expected checkpoint key.
    assert COMPLEXITY_ASSESSMENTS_KEY == "complexity_assessments"
