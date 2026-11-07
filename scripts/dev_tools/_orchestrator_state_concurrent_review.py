"""Completion rule for orchestrator-state checkpoints under concurrent review.

Purpose:
    Hold the ``require_complete`` rule that applies when a checkpoint records
    ``review_mode: "concurrent"``: the last ``review_outcomes`` entry must carry
    verdict ``PASS`` and a full lowercase ``head_sha``. The primary validator
    (`scripts.dev_tools.validate_orchestrator_state`) calls it last in its
    ``require_complete`` block.

Usage:
    Call ``validate_concurrent_review_completion`` with the parsed checkpoint.

Invariants / Constraints:
    - Only the exact string ``concurrent`` activates the rule. An absent key,
      null, ``sequential``, a case variant, and any non-string value mean
      sequential and contribute no error.
    - Only the final list element counts, so an earlier ``PASS`` never satisfies
      the rule.
    - The rule does no git work: head currency stays with the merge guard
      ``enforce-epic-merge-gate-review.ps1``.
    - The two error strings are byte-identical in the TypeScript port
      ``orchestrator-state-concurrent-review.ts`` and the PowerShell port
      ``Get-OrchestratorStateCompletionConcurrentReviewError``. The corpus
      ``tests/fixtures/orchestrator_state_concurrent_review/`` pins the three.

Side Effects:
    None.
"""

from __future__ import annotations

import re
from typing import Any, cast

__all__ = ["validate_concurrent_review_completion"]

CONCURRENT_REVIEW_MODE = "concurrent"
PASSING_REVIEW_VERDICT = "PASS"
LAST_REVIEW_NOT_PASSED_ERROR = (
    "Checkpoint completion validation failed: review_mode concurrent requires "
    "a last review_outcomes entry with verdict PASS."
)
LAST_REVIEW_HEAD_MISSING_ERROR = (
    "Checkpoint completion validation failed: review_mode concurrent requires "
    "head_sha on the last review_outcomes entry."
)
# A full lowercase object id: 40 characters for SHA-1, 64 for SHA-256.
_OBJECT_ID_PATTERN = re.compile(r"[0-9a-f]{40}(?:[0-9a-f]{24})?")


def _last_review_outcome(state: dict[str, Any]) -> dict[str, Any] | None:
    """Return the final ``review_outcomes`` entry when it is an object.

    Args:
        state (dict[str, Any]): Parsed checkpoint state.

    Returns:
        dict[str, Any] | None: The last entry, or None when the loop is absent,
        the list is absent or empty, or the last entry is not an object.

    Raises:
        None.

    Side Effects:
        None.
    """
    loop = state.get("remediation_loop")
    if not isinstance(loop, dict):
        return None
    outcomes = cast("dict[str, Any]", loop).get("review_outcomes")
    if not isinstance(outcomes, list) or not outcomes:
        return None
    last = cast("list[object]", outcomes)[-1]
    if not isinstance(last, dict):
        return None
    return cast("dict[str, Any]", last)


def validate_concurrent_review_completion(state: dict[str, Any]) -> list[str]:
    """Validate the review record of a completed concurrent run.

    Args:
        state (dict[str, Any]): Parsed checkpoint state.

    Returns:
        list[str]: Empty without the key or when the record is complete;
        otherwise exactly one error string. The head error is reported only
        when the verdict error does not apply.

    Raises:
        None.

    Side Effects:
        None.
    """
    # A sequential checkpoint carries no review record to check, so anything but
    # the exact key leaves today's completion result unchanged.
    if state.get("review_mode") != CONCURRENT_REVIEW_MODE:
        return []
    last = _last_review_outcome(state)
    # The verdict check runs first: a head on a review that did not pass proves
    # nothing, so only a PASS entry can reach the head error below.
    if last is None or last.get("verdict") != PASSING_REVIEW_VERDICT:
        return [LAST_REVIEW_NOT_PASSED_ERROR]
    head = last.get("head_sha")
    # The merge guard compares this value with the live head, so a value that is
    # not a full object id could never be proven current.
    if not isinstance(head, str) or _OBJECT_ID_PATTERN.fullmatch(head) is None:
        return [LAST_REVIEW_HEAD_MISSING_ERROR]
    return []
