"""Model-routing-receipt invariants for orchestrator-state checkpoints.

Purpose:
    Hold the optional ``model_routing_receipts`` array constants and the
    ``_validate_model_routing_receipts`` helper so the primary validator module
    (`scripts.dev_tools.validate_orchestrator_state`) can stay within the
    repository's 500-line file limit while preserving the existing validator
    contract. The invariants mirror the model-routing obligations documented in
    `.claude/rules/orchestrator-state.md` and the Model Selection Contract in
    the two-axis-model-selection spec.

Usage:
    Import ``MODEL_ROUTING_RECEIPTS_KEY`` and
    ``_validate_model_routing_receipts`` from this module. The primary
    validator invokes the helper only when the checkpoint carries the
    ``model_routing_receipts`` key, so an absent key contributes zero errors.

Invariants / Constraints:
    - ``model == resolve_delegation_model(agent, complexity_band,
      fable_policy)["model"]``.
    - Under ``fable_policy == "disabled"`` no receipt ``model`` may equal
      ``fable``; any receipt whose ``table_model == "fable"`` must record
      ``clamped_from == "fable"`` and ``model == "opus"``.
    - The validator never imports ``schemas/orchestrator-state.schema.json``;
      the invariants are expressed directly here per
      `.claude/rules/orchestrator-state.md`.

Side Effects:
    None.
"""

from __future__ import annotations

from typing import Any, cast

from scripts.dev_tools.compute_complexity_floor import BAND_ORDER
from scripts.dev_tools.resolve_delegation_model import (
    DISABLED_CLAMP_MODEL,
    DISABLED_POLICY,
    FABLE_MODEL,
    resolve_delegation_model,
)

# Declare the module's intended exported surface. Listing
# ``_validate_model_routing_receipts`` here marks it as a deliberate re-export
# consumed by ``validate_orchestrator_state``, so static analysis does not flag
# the helper as unused or as private-usage across the module boundary.
__all__ = [
    "MODEL_ROUTING_RECEIPTS_KEY",
    "_validate_model_routing_receipts",
]

MODEL_ROUTING_RECEIPTS_KEY = "model_routing_receipts"
_VALID_BANDS = frozenset(BAND_ORDER)


def _validate_model_routing_receipts(value: object) -> list[str]:
    """Validate the optional ``model_routing_receipts`` array invariants.

    Purpose:
        Apply the Model Selection Contract's model-routing invariants to the
        checkpoint's optional ``model_routing_receipts`` array, mirroring the
        prose in `.claude/rules/orchestrator-state.md`. The validator never
        imports a schema file; the invariants are expressed directly here in
        the existing helper-plus-error-list style.

    Args:
        value (object): The raw value of the checkpoint's
            ``model_routing_receipts`` key. Callers invoke this helper only
            when the key is present, so a non-list value is itself a malformed
            block.

    Returns:
        list[str]: One error string per violated invariant; an empty list when
        every receipt is well-formed.

    Raises:
        None.

    Side Effects:
        None.
    """

    errors: list[str] = []

    # A non-list value cannot carry receipt entries; the key was present, so
    # this is a malformed block rather than an absent one.
    if not isinstance(value, list):
        errors.append("Checkpoint model_routing_receipts must be a list when present.")
        return errors
    receipt_list = cast("list[object]", value)

    # Validate each receipt independently so callers receive a complete error
    # list instead of stopping at the first malformed entry.
    for index, receipt in enumerate(receipt_list):
        if not isinstance(receipt, dict):
            errors.append(
                f"Checkpoint model_routing_receipts #{index} must be an object."
            )
            continue
        receipt_map = cast("dict[str, Any]", receipt)
        errors.extend(_validate_one_receipt(index, receipt_map))

    return errors


def _validate_one_receipt(index: int, receipt: dict[str, Any]) -> list[str]:
    """Validate a single model-routing-receipt entry.

    Purpose:
        Check that the receipt's ``model`` equals the reference-implementation
        resolution and that the ``disabled``-mode clamp invariants hold for one
        receipt entry.

    Args:
        index (int): The receipt's position in the array, used to build a
            checkpoint-context-prefixed error message.
        receipt (dict[str, Any]): The parsed receipt object.

    Returns:
        list[str]: One error string per violated invariant for this entry.

    Raises:
        None.

    Side Effects:
        None.
    """

    errors: list[str] = []
    agent = receipt.get("agent")
    band = receipt.get("complexity_band")
    fable_policy = receipt.get("fable_policy")
    table_model = receipt.get("table_model")
    clamped_from = receipt.get("clamped_from")
    model = receipt.get("model")

    # The band must be a valid enum member before the resolver can be called;
    # an invalid band cannot be resolved, so report it and stop this receipt.
    if band not in _VALID_BANDS:
        errors.append(
            f"Checkpoint model_routing_receipts #{index} complexity_band must "
            f"be one of C1, C2, C3, C4; got: {band}."
        )
        return errors

    # Resolve the expected model from the canonical reference implementation;
    # agent and fable_policy are coerced to strings for the pure lookup.
    expected = resolve_delegation_model(
        str(agent), cast("str", band), str(fable_policy)
    )
    expected_model = expected["model"]

    # Invariant: the recorded model must equal the resolved model.
    if model != expected_model:
        errors.append(
            f"Checkpoint model_routing_receipts #{index} model {model} does not "
            f"equal resolve_delegation_model(agent, complexity_band, "
            f"fable_policy) {expected_model}."
        )

    # Disabled-mode clamp invariants apply only when fable is removed from the
    # consideration set for this session.
    if fable_policy == DISABLED_POLICY:
        errors.extend(_validate_disabled_clamp(index, table_model, clamped_from, model))

    return errors


def _validate_disabled_clamp(
    index: int, table_model: object, clamped_from: object, model: object
) -> list[str]:
    """Validate the ``disabled``-mode clamp invariants for one receipt.

    Purpose:
        Under ``fable_policy == "disabled"`` ensure no receipt resolves to
        ``fable`` and that any ``fable`` table cell records the clamp to
        ``opus`` with ``clamped_from == "fable"``.

    Args:
        index (int): The receipt's array position for the error message.
        table_model (object): The receipt's pre-clamp ``table_model`` value.
        clamped_from (object): The receipt's ``clamped_from`` value.
        model (object): The receipt's post-clamp ``model`` value.

    Returns:
        list[str]: One error string per violated disabled-mode invariant.

    Raises:
        None.

    Side Effects:
        None.
    """

    errors: list[str] = []

    # Invariant: no receipt model may be fable under the disabled policy.
    if model == FABLE_MODEL:
        errors.append(
            f"Checkpoint model_routing_receipts #{index} model must not be "
            "fable under fable_policy disabled."
        )

    # Invariant: a fable table cell must record the clamp to opus with
    # clamped_from fable; otherwise the clamp provenance is missing.
    if table_model == FABLE_MODEL and not (
        clamped_from == FABLE_MODEL and model == DISABLED_CLAMP_MODEL
    ):
        errors.append(
            f"Checkpoint model_routing_receipts #{index} table_model fable "
            "under fable_policy disabled must record clamped_from fable and "
            "model opus."
        )

    return errors
