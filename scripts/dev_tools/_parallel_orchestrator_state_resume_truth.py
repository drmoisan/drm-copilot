"""Validate persisted live truth before a parallel child may resume."""

from __future__ import annotations

from typing import TYPE_CHECKING, cast

if TYPE_CHECKING:
    from collections.abc import Iterable

REASON_TRUTH_REQUIRED = "PARALLEL_RESUME_TRUTH_REQUIRED"
REASON_TRUTH_INVALID = "PARALLEL_RESUME_TRUTH_INVALID"
REASON_FAN_IN_FORBIDDEN = "PARALLEL_RESUME_FAN_IN_FORBIDDEN"
REASON_ORDER_MISMATCH = "PARALLEL_RESUME_ORDER_MISMATCH"
REASON_IDENTITY_DUPLICATE = "PARALLEL_RESUME_IDENTITY_DUPLICATE"
REASON_GIT_MISMATCH = "PARALLEL_RESUME_GIT_MISMATCH"
REASON_WORKTREE_MISMATCH = "PARALLEL_RESUME_WORKTREE_MISMATCH"
REASON_GITHUB_MISMATCH = "PARALLEL_RESUME_GITHUB_MISMATCH"
REASON_LAUNCH_MISMATCH = "PARALLEL_RESUME_LAUNCH_MISMATCH"
REASON_MUTATION_MISMATCH = "PARALLEL_RESUME_MUTATION_MISMATCH"
REASON_DRIFT_UNRESOLVED = "PARALLEL_RESUME_DRIFT_UNRESOLVED"
REASON_ROUTING_MISMATCH = "PARALLEL_RESUME_ROUTING_MISMATCH"
REASON_CHILD_STATUS_MISMATCH = "PARALLEL_RESUME_CHILD_STATUS_MISMATCH"
REASON_PROCESS_RUNNING = "PARALLEL_RESUME_PROCESS_RUNNING"
REASON_RELAUNCH_NOT_AUTHORIZED = "PARALLEL_RESUME_RELAUNCH_NOT_AUTHORIZED"

TERMINAL_ITEM_STATES = frozenset({"merged", "worktree_removed", "abandoned"})
IDENTITY_FIELDS = ("launch_id", "worktree_path", "branch_name", "pr_number")
ROUTING_FIELDS = (
    "authority_receipt_path",
    "delegation_receipt_path",
    "topology_receipt_path",
    "model_routing_receipt_path",
    "deployment_agent",
    "model",
    "model_reasoning_effort",
    "permissions",
)
FORBIDDEN_KEYS = frozenset(
    {
        "integration_branch",
        "integration_pr",
        "integration_pr_url",
        "final_pr",
        "final_pr_url",
        "fan_in",
        "fan_in_pr",
        "fan_in_pr_url",
        "waves",
        "wave",
    }
)
REQUIRED_TRUTH_FIELDS = frozenset(
    {
        "schema_version",
        "selected_issue_num",
        "repository",
        "origin_main_head",
        "worktree_path",
        "branch_name",
        "worktree_head",
        "pr_number",
        "pr_base_branch",
        "pr_head_branch",
        "pr_head_sha",
        "pr_state",
        "checks_head_sha",
        "checks_conclusion",
        "launch_id",
        "spec_sha256",
        "checkpoint_sha256",
        "latest_mutation_sequence",
        "recolor_generation",
        "drift_resolution_generation",
        "unresolved_drift",
        *ROUTING_FIELDS,
        "child_status_path",
        "child_status_launch_id",
        "child_status_pid",
        "live_process_pid",
        "live_process_running",
        "should_relaunch",
    }
)


def _mapping_items(state: dict[str, object]) -> list[dict[str, object]]:
    """Return object-shaped checkpoint items in persisted order.

    Args:
        state: Parsed orchestrator checkpoint.
    Returns:
        Mapping-shaped items in their persisted order.
    Raises:
        None.
    Side Effects:
        None; returned entries are not mutated.
    """

    value = state.get("items")
    if not isinstance(value, list):
        return []
    # Retain only mapping-shaped items so later validators receive stable records.
    return [
        cast("dict[str, object]", item)
        for item in cast("list[object]", value)
        if isinstance(item, dict)
    ]


def _positive_integer(value: object) -> bool:
    """Identify a non-Boolean positive integer.

    Args:
        value: Candidate parsed value.
    Returns:
        ``True`` only for integers greater than zero, excluding Booleans.
    Raises:
        None.
    Side Effects:
        None.
    """

    return isinstance(value, int) and not isinstance(value, bool) and value > 0


def _integer(value: object) -> bool:
    """Identify a non-Boolean integer.

    Args:
        value: Candidate parsed value.
    Returns:
        ``True`` only for integer values that are not Booleans.
    Raises:
        None.
    Side Effects:
        None.
    """

    return isinstance(value, int) and not isinstance(value, bool)


def _first_incomplete(items: Iterable[dict[str, object]]) -> dict[str, object] | None:
    """Select the first incomplete item in deterministic scheduling order.

    Args:
        items: Persisted item records to inspect.
    Returns:
        The first incomplete item by cohort, batch, and issue, or ``None``.
    Raises:
        None.
    Side Effects:
        None; the input records are not mutated.
    """

    # Exclude terminal work before applying deterministic scheduling order.
    candidates = [
        item for item in items if item.get("state") not in TERMINAL_ITEM_STATES
    ]
    if not candidates:
        return None

    def ordering(item: dict[str, object]) -> tuple[int, int, int]:
        """Build the deterministic scheduling key for one checkpoint item.

        Args:
            item: Persisted item record.
        Returns:
            Cohort, batch, and issue key used for stable ordering.
        Raises:
            None.
        Side Effects:
            None.
        """

        return (
            cast("int", item.get("cohort", 0)),
            cast("int", item.get("batch", 0)),
            cast("int", item.get("issue_num", 0)),
        )

    return min(candidates, key=ordering)


def _contains_forbidden_key(value: object) -> bool:
    """Detect forbidden integration and fan-in state recursively.

    Args:
        value: Parsed checkpoint value to inspect.
    Returns:
        ``True`` when any nested mapping contains a forbidden key.
    Raises:
        None.
    Side Effects:
        None.
    """

    if isinstance(value, dict):
        record = cast("dict[object, object]", value)
        # Reject a forbidden key at the current mapping boundary before recursion.
        if any(isinstance(key, str) and key in FORBIDDEN_KEYS for key in record):
            return True
        # Descend through mapping values to reject forbidden nested state.
        return any(_contains_forbidden_key(entry) for entry in record.values())
    if isinstance(value, list):
        # Descend through list entries because persisted state may nest collections.
        return any(
            _contains_forbidden_key(entry) for entry in cast("list[object]", value)
        )
    return False


def _has_duplicate_identity(items: list[dict[str, object]]) -> bool:
    """Detect duplicate launch, worktree, branch, or PR identity.

    Args:
        items: Persisted item records participating in identity validation.
    Returns:
        ``True`` when an active identity value is reused.
    Raises:
        None.
    Side Effects:
        None.
    """

    # Validate each durable identity namespace independently to preserve diagnostics.
    for field in IDENTITY_FIELDS:
        # Ignore withdrawn and absent identities when detecting active collisions.
        values = [
            item.get(field)
            for item in items
            if item.get("state") != "withdrawn" and item.get(field) not in (None, "")
        ]
        # Normalize comparable identity values before testing uniqueness.
        if len(values) != len({str(value) for value in values}):
            return True
    return False


def _latest_mutation_sequence(state: dict[str, object]) -> int:
    """Return the highest valid persisted mutation sequence.

    Args:
        state: Parsed orchestrator checkpoint.
    Returns:
        Highest integer mutation sequence, or zero when none exists.
    Raises:
        None.
    Side Effects:
        None.
    """

    value = state.get("mutations")
    if not isinstance(value, list):
        return 0
    # Project sequence values only from mapping-shaped mutation entries.
    sequences = [
        cast("dict[str, object]", entry).get("sequence")
        for entry in cast("list[object]", value)
        if isinstance(entry, dict)
    ]
    # Discard malformed sequence values before computing the durable maximum.
    integers = [cast("int", sequence) for sequence in sequences if _integer(sequence)]
    return max(integers, default=0)


def _selected_item(
    items: list[dict[str, object]], selected_issue: object
) -> dict[str, object] | None:
    """Return the uniquely selected checkpoint item.

    Args:
        items: Persisted item records.
        selected_issue: Issue identity from the live-truth receipt.
    Returns:
        The unique matching item, or ``None`` for zero or multiple matches.
    Raises:
        None.
    Side Effects:
        None.
    """

    # Preserve ambiguity as a validation failure instead of choosing arbitrarily.
    matches = [item for item in items if item.get("issue_num") == selected_issue]
    return matches[0] if len(matches) == 1 else None


def _append_once(errors: list[str], reason: str) -> None:
    """Append one stable reason code at most once.

    Args:
        errors: Ordered error collection to update.
        reason: Stable reason code to append.
    Returns:
        None.
    Raises:
        None.
    Side Effects:
        Mutates ``errors`` when ``reason`` is not already present.
    """

    if reason not in errors:
        errors.append(reason)


def validate_parallel_resume_truth(
    state: dict[str, object], _context: str
) -> list[str]:
    """Validate live truth before resuming a parallel child.

    Args:
        state: Parsed orchestrator checkpoint and live-truth receipt.
        _context: Reserved validation context retained for API compatibility.
    Returns:
        Ordered stable reason codes for every detected resume violation.
    Raises:
        None.
    Side Effects:
        None; checkpoint state is inspected without mutation.
    """

    required = state.get("resume_required") is True
    truth_value = state.get("resume_truth")
    if not required and truth_value is None:
        return []
    if not isinstance(truth_value, dict):
        return [REASON_TRUTH_REQUIRED]

    truth = cast("dict[str, object]", truth_value)
    items = _mapping_items(state)
    errors: list[str] = []
    if _contains_forbidden_key(truth):
        errors.append(REASON_FAN_IN_FORBIDDEN)
    if truth.get("schema_version") != 1 or not REQUIRED_TRUTH_FIELDS.issubset(truth):
        errors.append(REASON_TRUTH_INVALID)

    first = _first_incomplete(items)
    selected = _selected_item(items, truth.get("selected_issue_num"))
    if (
        first is None
        or selected is None
        or first.get("issue_num") != truth.get("selected_issue_num")
    ):
        errors.append(REASON_ORDER_MISMATCH)
    if _has_duplicate_identity(items):
        errors.append(REASON_IDENTITY_DUPLICATE)
    if selected is None:
        return errors

    if truth.get("repository") != selected.get("repository") or truth.get(
        "origin_main_head"
    ) != selected.get("origin_main_head"):
        errors.append(REASON_GIT_MISMATCH)
    if truth.get("worktree_path") != selected.get("worktree_path") or truth.get(
        "branch_name"
    ) != selected.get("branch_name"):
        errors.append(REASON_WORKTREE_MISMATCH)
    if (
        not _positive_integer(truth.get("pr_number"))
        or truth.get("pr_number") != selected.get("pr_number")
        or truth.get("pr_base_branch") != "main"
        or truth.get("pr_base_branch") != selected.get("pr_base_branch")
        or truth.get("pr_head_branch") != selected.get("branch_name")
        or truth.get("pr_head_sha") != truth.get("worktree_head")
        or truth.get("pr_head_sha") != selected.get("pr_head_sha")
        or truth.get("checks_head_sha") != truth.get("pr_head_sha")
        or truth.get("checks_conclusion") != "success"
        or truth.get("pr_state") != "OPEN"
    ):
        errors.append(REASON_GITHUB_MISMATCH)
    # Require the launch receipt and selected checkpoint item to remain identical.
    if any(
        truth.get(field) != selected.get(field)
        for field in ("launch_id", "spec_sha256", "checkpoint_sha256")
    ):
        errors.append(REASON_LAUNCH_MISMATCH)
    if truth.get("latest_mutation_sequence") != _latest_mutation_sequence(state):
        errors.append(REASON_MUTATION_MISMATCH)

    generation = state.get("recolor_generation")
    if (
        truth.get("unresolved_drift") is not False
        or truth.get("recolor_generation") != generation
        or truth.get("drift_resolution_generation") != generation
    ):
        errors.append(REASON_DRIFT_UNRESOLVED)
    # Require all sealed routing fields to match the selected child identity.
    if any(truth.get(field) != selected.get(field) for field in ROUTING_FIELDS):
        errors.append(REASON_ROUTING_MISMATCH)
    if (
        truth.get("child_status_path") != selected.get("child_status_path")
        or truth.get("child_status_launch_id") != selected.get("launch_id")
        or truth.get("child_status_pid") != selected.get("child_status_pid")
        or truth.get("child_status_pid") != truth.get("live_process_pid")
    ):
        errors.append(REASON_CHILD_STATUS_MISMATCH)
    if (
        truth.get("live_process_running") is True
        and truth.get("should_relaunch") is True
    ):
        errors.append(REASON_PROCESS_RUNNING)
    elif (
        truth.get("live_process_running") is False
        and truth.get("should_relaunch") is not True
    ):
        errors.append(REASON_RELAUNCH_NOT_AUTHORIZED)

    ordered: list[str] = []
    # Preserve first occurrence order while removing duplicate reason codes.
    for error in errors:
        _append_once(ordered, error)
    return ordered


__all__ = ["validate_parallel_resume_truth"]
