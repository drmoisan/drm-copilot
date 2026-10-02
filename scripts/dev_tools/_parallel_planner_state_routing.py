"""Ready-gate invariant P10 for the parallel-planner checkpoint (issue #532).

Purpose:
    Validate one object-shaped ``items[]`` entry's routing record under the
    readiness gate: the ``complexity_band``, the ``complexity_assessment``, and
    the ``model_routing_receipt`` the parallel parent reads to choose the model
    of each child orchestrator spawn.

Flow:
    ``validate_ready_item_routing`` runs spec FR2 checks 1 through 10 in table
    order. The assessment and receipt entry checks (checks 3 and 7) reuse the
    Claude orchestrator-state helpers ``_validate_complexity_assessments`` and
    ``_validate_model_routing_receipts`` on a one-element list, then rewrite the
    helpers' ``Checkpoint ... #0`` prefix to the item-scoped context, so the
    floor and model formulas are never reimplemented here.

Invariants and constraints:
    The function performs no I/O, raises nothing for malformed input, and never
    mutates its arguments. Checks 3 through 5 are skipped when check 2 fails,
    and checks 7 through 10 are skipped when check 6 fails. Checks 5 and 9 are
    reported whenever the two bands differ, including when the item band itself
    failed check 1, mirroring the epic planner cross-check. The Codex receipt
    validator and deployment resolver are deliberately not used: the planner
    checkpoint records Claude delegation receipts only.
"""

from __future__ import annotations

from typing import cast

from scripts.dev_tools._orchestrator_state_complexity import (
    _validate_complexity_assessments,
)
from scripts.dev_tools._orchestrator_state_model_routing import (
    _validate_model_routing_receipts,
)
from scripts.dev_tools._parallel_state_common import enum_error, is_non_empty_string
from scripts.dev_tools.compute_complexity_floor import BAND_ORDER

# The only agent a planner item's receipt may name: the parent spawns one
# child orchestrator per item (check 8).
ROUTING_AGENT = "orchestrator"

# Session fable policies accepted on a receipt, in canonical order (check 10).
VALID_FABLE_POLICIES: tuple[str, ...] = ("disabled", "available", "preferred")

# Prefixes the reused helpers emit for the single entry they are given; each is
# rewritten to the item-scoped context (checks 3 and 7).
_ASSESSMENT_HELPER_PREFIX = "Checkpoint complexity_assessments #0"
_RECEIPT_HELPER_PREFIX = "Checkpoint model_routing_receipts #0"


def _rewrite_prefix(errors: list[str], old_prefix: str, new_prefix: str) -> list[str]:
    """Replace a helper's entry prefix with the item-scoped prefix.

    Args:
        errors (list[str]): Error strings returned by a reused helper.
        old_prefix (str): The helper's ``Checkpoint ... #0`` prefix.
        new_prefix (str): The item-scoped replacement prefix.

    Returns:
        list[str]: The errors in their original order, each rewritten when it
        starts with ``old_prefix`` and left unchanged otherwise.

    Raises:
        None.

    Side Effects:
        None.
    """

    return [
        new_prefix + error[len(old_prefix) :] if error.startswith(old_prefix) else error
        for error in errors
    ]


def _validate_assessment(
    assessment: dict[str, object], band: object, entry_context: str
) -> list[str]:
    """Run checks 3 through 5 on an object-shaped ``complexity_assessment``.

    Args:
        assessment (dict[str, object]): The item's assessment object.
        band (object): The item's ``complexity_band`` value, possibly invalid.
        entry_context (str): Item-scoped context prefix.

    Returns:
        list[str]: Check-3 helper errors with the rewritten prefix, then the
        check-4 ``assessed_at`` error, then the check-5 band-mismatch error.

    Raises:
        None.

    Side Effects:
        None.
    """

    context = f"{entry_context} complexity_assessment"
    errors = _rewrite_prefix(
        _validate_complexity_assessments([assessment]),
        _ASSESSMENT_HELPER_PREFIX,
        context,
    )
    if not is_non_empty_string(assessment.get("assessed_at")):
        errors.append(f"{context}.assessed_at must be a non-empty string.")
    assessed_band = assessment.get("band")
    # Reported whenever the values differ, even when check 1 already rejected
    # the item band, so the disagreement itself is never hidden.
    if assessed_band != band:
        errors.append(
            f"{context}.band {assessed_band!r} does not equal complexity_band "
            f"{band!r}."
        )
    return errors


def _validate_receipt(
    receipt: dict[str, object], band: object, entry_context: str
) -> list[str]:
    """Run checks 7 through 10 on an object-shaped ``model_routing_receipt``.

    Args:
        receipt (dict[str, object]): The item's receipt object.
        band (object): The item's ``complexity_band`` value, possibly invalid.
        entry_context (str): Item-scoped context prefix.

    Returns:
        list[str]: Check-7 helper errors with the rewritten prefix, then the
        check-8 agent error, the check-9 band-mismatch error, and the check-10
        ``fable_policy`` enum error.

    Raises:
        None.

    Side Effects:
        None.
    """

    context = f"{entry_context} model_routing_receipt"
    errors = _rewrite_prefix(
        _validate_model_routing_receipts([receipt]), _RECEIPT_HELPER_PREFIX, context
    )
    agent = receipt.get("agent")
    if agent != ROUTING_AGENT:
        errors.append(f"{context}.agent must be {ROUTING_AGENT!r}; found: {agent!r}.")
    receipt_band = receipt.get("complexity_band")
    if receipt_band != band:
        errors.append(
            f"{context}.complexity_band {receipt_band!r} does not equal "
            f"complexity_band {band!r}."
        )
    fable_policy = receipt.get("fable_policy")
    if fable_policy not in VALID_FABLE_POLICIES:
        errors.append(
            enum_error(
                entry_context,
                "model_routing_receipt.fable_policy",
                VALID_FABLE_POLICIES,
                fable_policy,
            )
        )
    return errors


def validate_ready_item_routing(
    record: dict[str, object], entry_context: str
) -> list[str]:
    """Validate one planner item's routing record (ready-gate invariant P10).

    Args:
        record (dict[str, object]): One object-shaped ``items[]`` entry.
        entry_context (str): Item-scoped context prefix, for example
            ``Parallel planner checkpoint items[0]``.

    Returns:
        list[str]: Errors in spec FR2 table order: the band enum (check 1), the
        assessment checks (2 through 5), then the receipt checks (6 through 10).
        An empty list when the routing record is valid.

    Raises:
        None.

    Side Effects:
        None.
    """

    errors: list[str] = []
    band = record.get("complexity_band")
    if band not in BAND_ORDER:
        errors.append(enum_error(entry_context, "complexity_band", BAND_ORDER, band))

    assessment = record.get("complexity_assessment")
    if isinstance(assessment, dict):
        errors.extend(
            _validate_assessment(
                cast("dict[str, object]", assessment), band, entry_context
            )
        )
    else:
        errors.append(f"{entry_context} complexity_assessment must be an object.")

    receipt = record.get("model_routing_receipt")
    if isinstance(receipt, dict):
        errors.extend(
            _validate_receipt(cast("dict[str, object]", receipt), band, entry_context)
        )
    else:
        errors.append(f"{entry_context} model_routing_receipt must be an object.")
    return errors
