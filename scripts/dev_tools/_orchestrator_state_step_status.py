"""Per-step-key step-status vocabulary for orchestrator-state checkpoints.

Purpose:
    Hold the step-status key tuple, the per-key additive extra-status map, the
    completion-blocking status set, and the pure error-collector helpers so the
    primary validator module (`scripts.dev_tools.validate_orchestrator_state`)
    can stay within the repository's 500-line file limit while preserving the
    existing validator contract.

Usage:
    Import ``STEP_STATUS_KEYS``, ``collect_step_status_errors``, and
    ``collect_completion_blocking_step_errors`` from this module. The primary
    validator re-exports ``STEP_STATUS_KEYS`` so existing callers and tests
    continue to resolve it from
    ``scripts.dev_tools.validate_orchestrator_state`` unchanged.

Invariants / Constraints:
    - The shared ``VALID_STEP_STATUS`` set stays in the primary validator and is
      unchanged; the extra values here are additive per-key only.
    - ``step9_status`` additionally accepts the documented CI-gate vocabulary
      ``passed``, ``failed_remediation_required``, and ``blocked_ci_loop_limit``
      (`.claude/skills/orchestrate/SKILL.md`).
    - ``step6_status`` additionally accepts ``blocked_remediation_loop_limit``,
      the documented third-remediation-pass halt value.
    - The emitted message forms are byte-identical to the strings the primary
      validator emitted before this module existed.
    - Every helper is pure: no file I/O and no mutation of the input mapping.

Side Effects:
    None.
"""

from __future__ import annotations

from typing import TYPE_CHECKING

if TYPE_CHECKING:
    from collections.abc import Mapping, Sequence

# Declare the module's intended exported surface. Listing the collectors here
# marks them as deliberate re-exports consumed by
# ``validate_orchestrator_state``, so static analysis does not flag them as
# unused locally or as private-usage across the module boundary.
__all__ = [
    "STEP_STATUS_KEYS",
    "STEP_SPECIFIC_EXTRA_STATUS",
    "COMPLETION_BLOCKING_STEP_STATUS",
    "is_valid_step_status",
    "collect_step_status_errors",
    "collect_completion_blocking_step_errors",
]

STEP_STATUS_KEYS = (
    "step5_status",
    "step6_status",
    "step7_status",
    "step8_status",
    "step9_status",
    "step10_status",
)
# Per-key additive vocabulary layered on the shared ``VALID_STEP_STATUS`` set. A
# value listed here is valid only on its owning key; the same value on any other
# step key is still rejected.
STEP_SPECIFIC_EXTRA_STATUS: dict[str, frozenset[str]] = {
    "step6_status": frozenset({"blocked_remediation_loop_limit"}),
    "step9_status": frozenset(
        {"passed", "failed_remediation_required", "blocked_ci_loop_limit"}
    ),
}
# Step statuses that must never appear in a checkpoint written as DONE. The
# documented S9 success value ``passed`` is deliberately absent: it records CI
# green and must not block completion.
COMPLETION_BLOCKING_STEP_STATUS = {
    "pending",
    "blocked",
    "failed_remediation_required",
    "blocked_ci_loop_limit",
    "blocked_remediation_loop_limit",
}


def is_valid_step_status(
    key: str, value: object, *, shared: frozenset[str] | set[str]
) -> bool:
    """Report whether a step-status value is valid for its own step key.

    Purpose:
        Apply the per-key additive rule: a value is valid when it belongs to the
        shared step-status vocabulary or to the extra set owned by ``key``.

    Args:
        key (str): The checkpoint step-status key the value was written to.
        value (object): The raw value read from the checkpoint.
        shared (frozenset[str] | set[str]): The shared ``VALID_STEP_STATUS``
            vocabulary, supplied by the caller so it stays defined in one place.

    Returns:
        bool: True when the value is accepted for that key; False otherwise.

    Raises:
        None.

    Side Effects:
        None.
    """

    if value in shared:
        return True
    return value in STEP_SPECIFIC_EXTRA_STATUS.get(key, frozenset())


def collect_step_status_errors(
    state: Mapping[str, object],
    keys: Sequence[str],
    *,
    shared: frozenset[str] | set[str],
) -> list[str]:
    """Collect one error per invalid step-status value, in ``keys`` order.

    Purpose:
        Perform the plain-mode step-status check for every step key, honoring
        the per-key additive vocabulary. An absent (``None``) value is not an
        error here; the required-key check covers absence separately.

    Args:
        state (Mapping[str, object]): The parsed checkpoint mapping. Never
            mutated.
        keys (Sequence[str]): The step-status keys to check, in report order.
        shared (frozenset[str] | set[str]): The shared ``VALID_STEP_STATUS``
            vocabulary.

    Returns:
        list[str]: One ``Checkpoint has invalid <key>: <value>`` string per
        non-``None`` invalid value; an empty list when every value is accepted.

    Raises:
        None.

    Side Effects:
        None.
    """

    errors: list[str] = []
    for key in keys:
        value = state.get(key)
        if value is not None and not is_valid_step_status(key, value, shared=shared):
            errors.append(f"Checkpoint has invalid {key}: {value}")
    return errors


def collect_completion_blocking_step_errors(
    state: Mapping[str, object], keys: Sequence[str]
) -> list[str]:
    """Collect one error per completion-blocking step status, in ``keys`` order.

    Purpose:
        Perform the ``require_complete`` step-status check so DONE cannot be
        written while any step records a pending, blocked, or documented failure
        state. Applied across all step keys because the failure values are
        per-key-valid only.

    Args:
        state (Mapping[str, object]): The parsed checkpoint mapping. Never
            mutated.
        keys (Sequence[str]): The step-status keys to check, in report order.

    Returns:
        list[str]: One ``Checkpoint completion validation failed: <key> is
        <value>.`` string per blocking value; an empty list when no step status
        blocks completion.

    Raises:
        None.

    Side Effects:
        None.
    """

    errors: list[str] = []
    for key in keys:
        value = state.get(key)
        if value in COMPLETION_BLOCKING_STEP_STATUS:
            errors.append(f"Checkpoint completion validation failed: {key} is {value}.")
    return errors
