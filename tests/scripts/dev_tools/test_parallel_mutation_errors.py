"""Unit tests for ``UnknownEnumMemberError`` member-list selection (issue #890).

Why these tests exist:
    ``UnknownEnumMemberError`` in ``scripts/dev_tools/_parallel_mutation_errors.py``
    names the allowed members of the field a rejected value was supplied for. The
    message must list the members of the rejected field itself: the item-state
    enum for ``state``, the merge-status enum for ``merge_status``, and the
    disposition enum for ``disposition``. A field with no known member list is a
    caller defect and is rejected with an explicit ``ValueError`` rather than a
    message quoting an unrelated enum.

    The disposition case is also proven through its real raise site,
    ``decide_removal`` in ``scripts/dev_tools/parallel_mutation_protocol.py``.
    No file is read or written and no process is started.
"""

from __future__ import annotations

import pytest

from scripts.dev_tools._parallel_mutation_errors import UnknownEnumMemberError
from scripts.dev_tools._parallel_mutation_models import ItemRecord
from scripts.dev_tools.parallel_mutation_protocol import decide_removal


def test_unknown_state_lists_item_state_members() -> None:
    """A rejected ``state`` lists the eight item-state members and keeps its payload."""

    # Arrange
    expected = (
        "Parallel mutation rejected: item 4 state 'paused' is not one of "
        "proposed, admitted, prepared, scheduled, in_flight, merged, withdrawn, "
        "blocked."
    )

    # Act
    error = UnknownEnumMemberError(4, "state", "paused")

    # Assert
    assert str(error) == expected, f"unexpected message: {error}"
    assert error.item_key == 4, f"unexpected item_key: {error.item_key!r}"
    assert error.field_name == "state", f"unexpected field: {error.field_name!r}"
    assert error.value == "paused", f"unexpected value: {error.value!r}"


def test_unknown_merge_status_lists_merge_status_members() -> None:
    """A rejected ``merge_status`` lists the eight merge-status members."""

    # Arrange
    expected = (
        "Parallel mutation rejected: item 4 merge_status 'landed' is not one of "
        "not_started, worktree_created, pr_open, ci_green, merged, "
        "worktree_removed, blocked_drift, blocked_ci_loop_limit."
    )

    # Act
    error = UnknownEnumMemberError(4, "merge_status", "landed")

    # Assert
    assert str(error) == expected, f"unexpected message: {error}"


def test_unknown_disposition_lists_disposition_members() -> None:
    """A rejected ``disposition`` lists the two disposition members only."""

    # Arrange
    expected = (
        "Parallel mutation rejected: item 21 disposition 'delete' is not one of "
        "detach, abandon."
    )

    # Act
    error = UnknownEnumMemberError(21, "disposition", "delete")

    # Assert
    assert str(error) == expected, f"unexpected message: {error}"


def test_decide_removal_disposition_rejection_lists_dispositions() -> None:
    """The real raise site in ``decide_removal`` names the disposition members."""

    # Arrange
    items = {21: ItemRecord(issue_num=21, state="in_flight")}
    expected = (
        "Parallel mutation rejected: item 21 disposition 'delete' is not one of "
        "detach, abandon."
    )

    # Act
    with pytest.raises(UnknownEnumMemberError) as excinfo:
        decide_removal(21, items, "delete")

    # Assert
    assert str(excinfo.value) == expected, f"unexpected message: {excinfo.value}"


def test_unmapped_field_name_is_rejected_explicitly() -> None:
    """A field with no member list raises exactly ``ValueError`` naming the fields."""

    # Arrange
    expected = (
        "UnknownEnumMemberError has no member list for field 'mode'; "
        "expected one of state, merge_status, disposition."
    )

    # Act
    with pytest.raises(ValueError) as excinfo:
        UnknownEnumMemberError(4, "mode", "x")

    # Assert: the subclass is excluded, so a constructed rejection cannot pass.
    assert (
        type(excinfo.value) is ValueError
    ), f"expected exactly ValueError, got {type(excinfo.value).__name__}"
    assert str(excinfo.value) == expected, f"unexpected message: {excinfo.value}"
