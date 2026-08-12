"""Validate additive per-item PR, CI, merge, and worktree-removal receipts."""

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
    """Return object-shaped item records in persisted order."""

    value = state.get("items")
    if not isinstance(value, list):
        return []
    return [
        cast("dict[str, object]", entry)
        for entry in cast("list[object]", value)
        if isinstance(entry, dict)
    ]


def _receipt_mode(items: list[dict[str, object]]) -> bool:
    """Preserve legacy checkpoints until a completion-receipt field appears."""

    return any(COMPLETION_RECEIPT_FIELDS.intersection(item) for item in items)


def _non_empty_text(value: object) -> bool:
    """Return whether a value is a non-blank string."""

    return isinstance(value, str) and bool(value.strip())


def _sha(value: object) -> bool:
    """Return whether a value is a complete hexadecimal Git SHA-1."""

    return isinstance(value, str) and SHA_PATTERN.fullmatch(value) is not None


def _relative_path(value: object) -> bool:
    """Accept only normalized repository-relative forward-slash paths."""

    if not _non_empty_text(value):
        return False
    path = cast("str", value)
    if "\\" in path or re.match(r"^[A-Za-z]:/", path):
        return False
    parsed = PurePosixPath(path)
    return not parsed.is_absolute() and ".." not in parsed.parts


def _item_error(context: str, index: int, detail: str) -> str:
    """Render one stable item-scoped completion diagnostic."""

    return f"{context} items[{index}] completion receipt {detail}."


def _validate_pr_binding(
    item: dict[str, object], index: int, context: str
) -> list[str]:
    """Validate one item's unique main-only PR and exact checked-head binding."""

    errors: list[str] = []
    number = item.get("pr_number")
    if not isinstance(number, int) or isinstance(number, bool) or number <= 0:
        errors.append(_item_error(context, index, "pr_number must be positive"))
    if not _non_empty_text(item.get("pr_url")):
        errors.append(_item_error(context, index, "pr_url must be a non-empty string"))
    if item.get("pr_base_branch") != "main":
        errors.append(_item_error(context, index, "PR base branch must be 'main'"))

    branch = item.get("branch_name")
    if not _non_empty_text(branch):
        errors.append(
            _item_error(context, index, "branch_name must be a non-empty string")
        )
    if item.get("pr_head_branch") != branch:
        errors.append(
            _item_error(context, index, "PR head branch must match branch_name")
        )

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
    """Validate required-check success against the exact recorded PR head."""

    errors: list[str] = []
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
    """Validate merged state and matching worktree-removal evidence."""

    errors: list[str] = []
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


def validate_completion_receipts(state: dict[str, object], context: str) -> list[str]:
    """Return ordered receipt errors for a completion-receipt-mode checkpoint."""

    items = _mapping_items(state)
    if not _receipt_mode(items):
        return []

    errors: list[str] = []
    pr_owners: dict[int, int] = {}
    duplicate_prs: set[int] = set()
    for index, item in enumerate(items):
        if item.get("state") == "withdrawn":
            continue
        errors.extend(_validate_pr_binding(item, index, context))
        errors.extend(_validate_check_binding(item, index, context))
        errors.extend(_validate_merge_and_removal(item, index, context))
        number = item.get("pr_number")
        if isinstance(number, int) and not isinstance(number, bool) and number > 0:
            if number in pr_owners:
                duplicate_prs.add(number)
            else:
                pr_owners[number] = index
    errors.extend(
        f"{context} completion receipts assign PR {number} to multiple items."
        for number in sorted(duplicate_prs)
    )
    return errors


__all__ = ["validate_completion_receipts"]
