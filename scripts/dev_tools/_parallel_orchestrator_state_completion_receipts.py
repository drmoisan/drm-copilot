"""Validate additive per-item PR, CI, merge, and worktree-removal receipts.

Purpose:
    Enforce the completion evidence required for every non-withdrawn parallel
    item once any completion-receipt field appears in a checkpoint.

Responsibilities and usage:
    Normalize readable item mappings, validate their PR/check/merge bindings,
    and report duplicate PR ownership. The public validator is called after the
    base checkpoint shape validator and preserves legacy checkpoints that have
    not entered completion-receipt mode.

High-level flow and invariants:
    Detect receipt mode, validate each active item without short-circuiting, and
    then enforce one item per positive PR number. Paths must remain normalized
    repository-relative paths, and all Git identities must be complete SHA-1s.

Raises and side effects:
    None. Every function is pure, performs no I/O, and does not mutate input.
    Individual docstrings therefore omit duplicate Raises and Side Effects
    sections.
"""

from __future__ import annotations

import re
from pathlib import PurePosixPath
from typing import cast

COMPLETION_RECEIPT_FIELDS = frozenset(
    {
        "pr_number",
        "pr_url",
        "pr_base_branch",
        "pr_head_branch",
        "pr_head_sha",
        "pr_state",
        "checks_head_sha",
        "checks_conclusion",
        "merged_at",
        "merge_commit_sha",
        "merge_receipt_path",
        "worktree_removed_at",
        "worktree_removal_receipt_path",
        "completion_receipt_path",
    }
)
SHA_PATTERN = re.compile(r"^[0-9a-fA-F]{40}$")


def _mapping_items(state: dict[str, object]) -> list[dict[str, object]]:
    """Extract object-shaped item records in persisted order.

    Args:
        state (dict[str, object]): Parsed checkpoint containing optional items.

    Returns:
        list[dict[str, object]]: Mapping entries only; malformed entries are
        excluded because the base shape validator owns their diagnostics.
    """

    value = state.get("items")
    if not isinstance(value, list):
        return []
    # Preserve source order while excluding shapes this additive gate cannot read.
    return [
        cast("dict[str, object]", entry)
        for entry in cast("list[object]", value)
        if isinstance(entry, dict)
    ]


def _receipt_mode(items: list[dict[str, object]]) -> bool:
    """Report whether any item activates additive receipt validation.

    Args:
        items (list[dict[str, object]]): Readable checkpoint item records.

    Returns:
        bool: True once at least one completion-receipt field is present.
    """

    # One additive field opts the whole checkpoint into the complete receipt contract.
    return any(COMPLETION_RECEIPT_FIELDS.intersection(item) for item in items)


def _non_empty_text(value: object) -> bool:
    """Report whether a value carries non-blank text.

    Args:
        value (object): Candidate deserialized value.

    Returns:
        bool: True only for a string containing a non-space character.
    """

    return isinstance(value, str) and bool(value.strip())


def _sha(value: object) -> bool:
    """Report whether a value is a complete hexadecimal Git SHA-1.

    Args:
        value (object): Candidate deserialized Git identity.

    Returns:
        bool: True only for a 40-character hexadecimal string.
    """

    return isinstance(value, str) and SHA_PATTERN.fullmatch(value) is not None


def _relative_path(value: object) -> bool:
    """Report whether a value is a normalized repository-relative path.

    Args:
        value (object): Candidate serialized receipt path.

    Returns:
        bool: True for a non-blank relative POSIX path without traversal.
    """

    if not _non_empty_text(value):
        return False
    path = cast("str", value)
    # Reject host-specific absolute forms before interpreting POSIX path parts.
    if "\\" in path or re.match(r"^[A-Za-z]:/", path):
        return False
    parsed = PurePosixPath(path)
    return not parsed.is_absolute() and ".." not in parsed.parts


def _item_error(context: str, index: int, detail: str) -> str:
    """Render one stable item-scoped completion diagnostic.

    Args:
        context (str): Caller-provided checkpoint label.
        index (int): Zero-based persisted item position.
        detail (str): Specific violated receipt requirement.

    Returns:
        str: Stable diagnostic prefixed with the owning item location.
    """

    return f"{context} items[{index}] completion receipt {detail}."


def _validate_pr_binding(
    item: dict[str, object], index: int, context: str
) -> list[str]:
    """Validate one item's main-only PR and exact checked-head binding.

    Args:
        item (dict[str, object]): Readable checkpoint item record.
        index (int): Zero-based persisted item position.
        context (str): Caller-provided checkpoint label.

    Returns:
        list[str]: Ordered field and cross-field binding diagnostics.
    """

    errors: list[str] = []
    # Validate scalar PR identity before comparing fields that depend on it.
    number = item.get("pr_number")
    if not isinstance(number, int) or isinstance(number, bool) or number <= 0:
        errors.append(_item_error(context, index, "pr_number must be positive"))
    if not _non_empty_text(item.get("pr_url")):
        errors.append(_item_error(context, index, "pr_url must be a non-empty string"))
    if item.get("pr_base_branch") != "main":
        errors.append(_item_error(context, index, "PR base branch must be 'main'"))

    # Bind the PR head branch to the work item's persisted execution branch.
    branch = item.get("branch_name")
    if not _non_empty_text(branch):
        errors.append(
            _item_error(context, index, "branch_name must be a non-empty string")
        )
    if item.get("pr_head_branch") != branch:
        errors.append(
            _item_error(context, index, "PR head branch must match branch_name")
        )

    # Require complete identities before checking exact-head equality.
    checked_head = item.get("checked_head")
    pr_head = item.get("pr_head_sha")
    if not _sha(checked_head):
        errors.append(
            _item_error(context, index, "checked_head must be a 40-character SHA")
        )
    if not _sha(pr_head):
        errors.append(
            _item_error(context, index, "pr_head_sha must be a 40-character SHA")
        )
    elif pr_head != checked_head:
        errors.append(
            _item_error(context, index, "PR head SHA must match checked_head")
        )
    return errors


def _validate_check_binding(
    item: dict[str, object], index: int, context: str
) -> list[str]:
    """Validate required-check success against the exact recorded PR head.

    Args:
        item (dict[str, object]): Readable checkpoint item record.
        index (int): Zero-based persisted item position.
        context (str): Caller-provided checkpoint label.

    Returns:
        list[str]: Ordered check-identity and conclusion diagnostics.
    """

    errors: list[str] = []
    # Check identity and conclusion independently so all missing evidence is visible.
    checks_head = item.get("checks_head_sha")
    if not _sha(checks_head):
        errors.append(
            _item_error(context, index, "checks_head_sha must be a 40-character SHA")
        )
    elif checks_head != item.get("pr_head_sha"):
        errors.append(
            _item_error(context, index, "checks head SHA must match pr_head_sha")
        )
    if item.get("checks_conclusion") != "success":
        errors.append(
            _item_error(context, index, "required checks conclusion must be 'success'")
        )
    return errors


def _validate_merge_and_removal(
    item: dict[str, object], index: int, context: str
) -> list[str]:
    """Validate merged state and matching worktree-removal evidence.

    Args:
        item (dict[str, object]): Readable checkpoint item record.
        index (int): Zero-based persisted item position.
        context (str): Caller-provided checkpoint label.

    Returns:
        list[str]: Ordered merge and durable removal-evidence diagnostics.
    """

    errors: list[str] = []
    # Accumulate every terminal-state defect so remediation is not iterative.
    if item.get("pr_state") != "MERGED":
        errors.append(_item_error(context, index, "PR state must be 'MERGED'"))
    if not _non_empty_text(item.get("merged_at")):
        errors.append(
            _item_error(context, index, "merged_at must be a non-empty string")
        )
    if not _sha(item.get("merge_commit_sha")):
        errors.append(
            _item_error(context, index, "merge_commit_sha must be a 40-character SHA")
        )
    if not _relative_path(item.get("merge_receipt_path")):
        errors.append(
            _item_error(
                context, index, "merge_receipt_path must be repository-relative"
            )
        )
    if item.get("merge_status") != "worktree_removed":
        errors.append(
            _item_error(context, index, "merge_status must be 'worktree_removed'")
        )
    if not _non_empty_text(item.get("worktree_removed_at")):
        errors.append(
            _item_error(
                context, index, "worktree_removed_at must be a non-empty string"
            )
        )
    if not _relative_path(item.get("worktree_removal_receipt_path")):
        errors.append(
            _item_error(
                context,
                index,
                "worktree_removal_receipt_path must be repository-relative",
            )
        )
    if not _relative_path(item.get("completion_receipt_path")):
        errors.append(
            _item_error(
                context, index, "completion_receipt_path must be repository-relative"
            )
        )
    return errors


def _validate_completion_item(
    item: dict[str, object], index: int, context: str
) -> list[str]:
    """Validate all completion bindings for one active item.

    This narrow seam keeps item-level positive and negative cases independent
    from checkpoint-wide duplicate-PR detection.

    Args:
        item (dict[str, object]): Readable checkpoint item record.
        index (int): Zero-based persisted item position.
        context (str): Caller-provided checkpoint label.

    Returns:
        list[str]: Ordered item diagnostics, or an empty list when withdrawn.
    """

    # Withdrawn work left the run before completion and owns no terminal receipt.
    if item.get("state") == "withdrawn":
        return []
    # Combine the three independent evidence layers in stable diagnostic order.
    return [
        *_validate_pr_binding(item, index, context),
        *_validate_check_binding(item, index, context),
        *_validate_merge_and_removal(item, index, context),
    ]


def validate_completion_receipts(state: dict[str, object], context: str) -> list[str]:
    """Validate completion receipts without changing legacy checkpoints.

    Args:
        state (dict[str, object]): Parsed parallel checkpoint.
        context (str): Caller-provided checkpoint label.

    Returns:
        list[str]: Ordered item and duplicate-PR diagnostics; empty outside
        completion-receipt mode.
    """

    items = _mapping_items(state)
    if not _receipt_mode(items):
        return []

    errors: list[str] = []
    pr_owners: dict[int, int] = {}
    duplicate_prs: set[int] = set()
    # Validate each active item and collect valid PR ownership for global uniqueness.
    for index, item in enumerate(items):
        errors.extend(_validate_completion_item(item, index, context))
        # Withdrawn records do not participate in completion PR ownership.
        if item.get("state") == "withdrawn":
            continue
        number = item.get("pr_number")
        # Only structurally valid PR numbers can participate in uniqueness checks.
        if isinstance(number, int) and not isinstance(number, bool) and number > 0:
            # Retain the first owner and report later ownership as one stable PR error.
            if number in pr_owners:
                duplicate_prs.add(number)
            else:
                pr_owners[number] = index
    # Sort duplicate identities so diagnostics remain deterministic across inputs.
    errors.extend(
        f"{context} completion receipts assign PR {number} to multiple items."
        for number in sorted(duplicate_prs)
    )
    return errors


__all__ = ["validate_completion_receipts"]
