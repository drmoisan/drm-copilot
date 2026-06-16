"""Human-interaction invariants for orchestrator-state checkpoints.

Purpose:
    Hold the optional ``human_interaction`` block constants and the
    ``_validate_human_interaction`` helper so the primary validator module
    (`scripts.dev_tools.validate_orchestrator_state`) can stay within the
    repository's 500-line file limit while preserving the existing validator
    contract.

Usage:
    Import ``HUMAN_INTERACTION_KEY`` and ``_validate_human_interaction`` from
    this module. The primary validator re-exports both symbols so existing
    callers and tests continue to resolve them from
    ``scripts.dev_tools.validate_orchestrator_state`` unchanged.

Invariants / Constraints:
    - The three permitted ``response`` values are ``scope_change``,
      ``exception``, and ``halt``.
    - An ``exception`` response requires a non-empty ``runbook_path`` string.
    - The validator never imports ``schemas/orchestrator-state.schema.json``;
      the invariants are expressed directly here per
      `.claude/rules/orchestrator-state.md`.

Side Effects:
    None.
"""

from __future__ import annotations

from typing import Any, cast

# Declare the module's intended exported surface. Listing ``_validate_human_
# interaction`` here marks it as a deliberate re-export consumed by
# ``validate_orchestrator_state``, so static analysis does not flag the helper
# as unused locally or as private-usage when imported across the module boundary.
__all__ = [
    "HUMAN_INTERACTION_KEY",
    "HUMAN_INTERACTION_REQUIREMENTS_KEY",
    "HUMAN_INTERACTION_RESPONSE_ENUM",
    "HUMAN_INTERACTION_EXCEPTION_RESPONSE",
    "_validate_human_interaction",
]

HUMAN_INTERACTION_KEY = "human_interaction"
HUMAN_INTERACTION_REQUIREMENTS_KEY = "requirements"
# The three permitted responses for an unautomatable requirement under the
# autonomous-execution mandate (see `.claude/skills/orchestrate/SKILL.md`).
HUMAN_INTERACTION_RESPONSE_ENUM = {"scope_change", "exception", "halt"}
HUMAN_INTERACTION_EXCEPTION_RESPONSE = "exception"


def _validate_human_interaction(human_interaction: object) -> list[str]:
    """Validate the optional ``human_interaction`` block invariants.

    Purpose:
        Apply the autonomous-execution mandate invariants to the checkpoint's
        optional top-level ``human_interaction`` object, mirroring the schema
        invariants documented in `.claude/rules/orchestrator-state.md`. The
        validator never imports `schemas/orchestrator-state.schema.json`; the
        invariants are expressed directly here in the existing helper-plus-
        error-list style.

    Args:
        human_interaction (object): The raw value of the checkpoint's top-level
            ``human_interaction`` key. Callers invoke this helper only when the
            key is present, so a non-object value is itself a malformed block.

    Returns:
        list[str]: One error string per violated invariant; an empty list when
        the block is well-formed. The three invariants are: ``requirements`` is
        present and is a list; each requirement is an object whose ``response``
        is within the permitted enum; a requirement whose ``response`` is
        ``exception`` carries a non-empty ``runbook_path`` string.

    Raises:
        None.

    Side Effects:
        None.
    """

    errors: list[str] = []

    # A non-object human_interaction cannot carry a requirements list; the key
    # was present, so this is a malformed block rather than an absent one.
    if not isinstance(human_interaction, dict):
        errors.append("Checkpoint human_interaction must be an object when present.")
        return errors
    human_interaction_map = cast("dict[str, Any]", human_interaction)

    # Invariant 1: requirements must be present and a list.
    requirements = human_interaction_map.get(HUMAN_INTERACTION_REQUIREMENTS_KEY)
    if not isinstance(requirements, list):
        errors.append("Checkpoint human_interaction.requirements must be a list.")
        return errors
    requirement_list = cast("list[object]", requirements)

    # Validate each requirement independently so callers receive a complete
    # error list instead of stopping at the first malformed requirement.
    for index, requirement in enumerate(requirement_list):
        if not isinstance(requirement, dict):
            errors.append(
                f"Checkpoint human_interaction.requirements #{index} must be an "
                "object."
            )
            continue
        requirement_map = cast("dict[str, Any]", requirement)

        # Invariant 2: response must be within the permitted enum.
        response = requirement_map.get("response")
        if response not in HUMAN_INTERACTION_RESPONSE_ENUM:
            errors.append(
                f"Checkpoint human_interaction.requirements #{index} response "
                f"must be one of scope_change, exception, halt; got: {response}"
            )
            continue

        # Invariant 3: an exception response requires a non-empty runbook_path.
        if response == HUMAN_INTERACTION_EXCEPTION_RESPONSE:
            runbook_path = requirement_map.get("runbook_path")
            if not isinstance(runbook_path, str) or not runbook_path.strip():
                errors.append(
                    f"Checkpoint human_interaction.requirements #{index} "
                    "response is exception but runbook_path is missing or empty."
                )

    return errors
