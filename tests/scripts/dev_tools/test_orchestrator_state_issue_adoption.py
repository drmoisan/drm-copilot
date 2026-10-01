"""Unit tests for the orchestrator-state issue-adoption resolver.

These tests call ``resolve_issue_adoption`` through the shared support module
with in-file checkpoint dictionaries and the resolved ``required_mcp_tools``
lists of the ``large`` and ``preparation`` routes. This file holds the
positive schema cases, the rejection rules with their exact ordered error
text, and the fixed-grid fail-closed invariant. The waivable-set,
presence-gating, and case-variant tests live in
``test_orchestrator_state_issue_adoption_waivers.py``.
"""

from __future__ import annotations

import itertools
from typing import cast

import pytest

from tests.scripts.dev_tools.orchestrator_state_issue_adoption_test_support import (
    E1,
    E2A,
    E2B,
    E3,
    E4,
    E5,
    E6,
    E7,
    E8A,
    E8INCLUDE,
    GRID_EVIDENCE,
    GRID_ISSUE_NUM,
    GRID_ORIGIN,
    GRID_VERIFIED_AT,
    GRID_VERIFIED_VIA,
    GRID_WAIVED_TOOLS,
    LARGE_BUG_TOOLS,
    PREPARATION_TOOLS,
    VALID_RECORD,
    build_adoption,
    build_state,
    invalid_potential_record_error,
    run_resolver,
)

# --- AC-6: positive schema cases -------------------------------------------


def test_feature_checkpoint_waiving_potential_to_issue_has_no_errors() -> None:
    """A feature checkpoint may waive potential_to_issue alone."""

    # Arrange
    state = build_state(build_adoption())

    # Act
    result = run_resolver(state)

    # Assert
    assert result.errors == (), f"unexpected errors: {result.errors}"
    assert result.waived_tools == frozenset({"potential_to_issue"})


def test_feature_checkpoint_waiving_feature_entry_tool_with_record_has_no_errors() -> (
    None
):
    """A feature checkpoint may also waive its promotion-entry tool with a record."""

    # Arrange
    adoption = build_adoption(
        waived_tools=["potential_to_issue", "new_potential_entry"],
        potential_record=VALID_RECORD,
    )

    # Act
    result = run_resolver(build_state(adoption))

    # Assert
    assert result.errors == (), f"unexpected errors: {result.errors}"
    assert result.waived_tools == frozenset(
        {"potential_to_issue", "new_potential_entry"}
    )


def test_bug_checkpoint_waiving_bug_entry_tool_with_record_has_no_errors() -> None:
    """A bug checkpoint may waive the bug promotion-entry tool with a record."""

    # Arrange
    adoption = build_adoption(
        waived_tools=["potential_to_issue", "new_potential_bug_entry"],
        potential_record=VALID_RECORD,
    )

    # Act
    result = run_resolver(
        build_state(adoption, promotion_type="bug"), required_mcp_tools=LARGE_BUG_TOOLS
    )

    # Assert
    assert result.errors == (), f"unexpected errors: {result.errors}"
    assert result.waived_tools == frozenset(
        {"potential_to_issue", "new_potential_bug_entry"}
    )


def test_preparation_route_adoption_has_no_errors() -> None:
    """The preparation route accepts the same adoption record."""

    # Arrange
    state = build_state(build_adoption())

    # Act
    result = run_resolver(
        state, route_id="preparation", required_mcp_tools=PREPARATION_TOOLS
    )

    # Assert
    assert result.errors == (), f"unexpected errors: {result.errors}"
    assert result.waived_tools == frozenset({"potential_to_issue"})


@pytest.mark.parametrize(
    "origin", ["transferred", "filed_before_orchestration", "epic_decomposition"]
)
def test_every_origin_value_is_accepted(origin: str) -> None:
    """Each documented origin value yields no errors."""

    # Arrange
    state = build_state(build_adoption(origin=origin))

    # Act
    result = run_resolver(state)

    # Assert
    assert result.errors == (), f"origin {origin} rejected: {result.errors}"
    assert result.waived_tools == frozenset({"potential_to_issue"})


@pytest.mark.parametrize(
    "verified_via", ["gh_issue_view", "gh_api_get", "github_mcp_issue_read"]
)
def test_every_verified_via_value_is_accepted(verified_via: str) -> None:
    """Each documented verified_via value yields no errors."""

    # Arrange
    state = build_state(build_adoption(verified_via=verified_via))

    # Act
    result = run_resolver(state)

    # Assert
    assert result.errors == (), f"verified_via {verified_via} rejected: {result.errors}"
    assert result.waived_tools == frozenset({"potential_to_issue"})


# --- AC-7: rejection rules ---------------------------------------------------


@pytest.mark.parametrize(
    "value", ["adopted", 509, ["potential_to_issue"]], ids=["string", "int", "list"]
)
def test_non_object_value_is_rejected(value: object) -> None:
    """A non-object adoption value yields only the object error."""

    # Arrange
    state = build_state(value)

    # Act
    result = run_resolver(state)

    # Assert
    assert result.errors == (E1,), f"unexpected errors: {result.errors}"
    assert result.waived_tools == frozenset()


def test_null_value_is_rejected() -> None:
    """A null adoption value is present but not an object."""

    # Arrange
    state = build_state(None)

    # Act
    result = run_resolver(state)

    # Assert
    assert result.errors == (E1,), f"unexpected errors: {result.errors}"
    assert result.waived_tools == frozenset()


def test_integer_issue_num_is_rejected() -> None:
    """A JSON number issue_num fails the format and the URL rule."""

    # Arrange
    state = build_state(build_adoption(issue_num=509))

    # Act
    result = run_resolver(state)

    # Assert
    assert result.errors == (E2A, E3), f"unexpected errors: {result.errors}"
    assert result.waived_tools == frozenset()


def test_leading_zero_issue_num_is_rejected() -> None:
    """A leading-zero issue_num fails the format and the URL rule."""

    # Arrange
    adoption = build_adoption(
        issue_num="0509",
        issue_url="https://github.com/drmoisan/drm-copilot/issues/0509",
    )

    # Act
    result = run_resolver(build_state(adoption))

    # Assert
    assert result.errors == (E2A, E3), f"unexpected errors: {result.errors}"
    assert result.waived_tools == frozenset()


def test_issue_num_not_equal_to_checkpoint_issue_num_is_rejected() -> None:
    """A well-formed issue_num must equal the checkpoint issue-num."""

    # Arrange
    adoption = build_adoption(
        issue_num="510",
        issue_url="https://github.com/drmoisan/drm-copilot/issues/510",
    )

    # Act
    result = run_resolver(build_state(adoption))

    # Assert
    assert result.errors == (E2B,), f"unexpected errors: {result.errors}"
    assert result.waived_tools == frozenset()


def test_mismatched_issue_url_is_rejected() -> None:
    """The issue URL must end with /issues/ followed by issue_num."""

    # Arrange
    adoption = build_adoption(
        issue_url="https://github.com/drmoisan/drm-copilot/issues/510"
    )

    # Act
    result = run_resolver(build_state(adoption))

    # Assert
    assert result.errors == (E3,), f"unexpected errors: {result.errors}"
    assert result.waived_tools == frozenset()


def test_unknown_origin_is_rejected() -> None:
    """An origin outside the documented set is rejected."""

    # Arrange
    state = build_state(build_adoption(origin="imported"))

    # Act
    result = run_resolver(state)

    # Assert
    assert result.errors == (E4,), f"unexpected errors: {result.errors}"
    assert result.waived_tools == frozenset()


def test_unknown_verified_via_is_rejected() -> None:
    """A verified_via outside the documented set is rejected."""

    # Arrange
    state = build_state(build_adoption(verified_via="curl"))

    # Act
    result = run_resolver(state)

    # Assert
    assert result.errors == (E5,), f"unexpected errors: {result.errors}"
    assert result.waived_tools == frozenset()


def test_absent_verified_at_is_rejected() -> None:
    """A missing verified_at is rejected."""

    # Arrange
    adoption = build_adoption()
    del adoption["verified_at"]

    # Act
    result = run_resolver(build_state(adoption))

    # Assert
    assert result.errors == (E6,), f"unexpected errors: {result.errors}"
    assert result.waived_tools == frozenset()


def test_null_verified_at_is_rejected() -> None:
    """A null verified_at is rejected."""

    # Arrange
    state = build_state(build_adoption(verified_at=None))

    # Act
    result = run_resolver(state)

    # Assert
    assert result.errors == (E6,), f"unexpected errors: {result.errors}"
    assert result.waived_tools == frozenset()


def test_blank_verified_at_is_rejected() -> None:
    """A whitespace-only verified_at is rejected."""

    # Arrange
    state = build_state(build_adoption(verified_at="   "))

    # Act
    result = run_resolver(state)

    # Assert
    assert result.errors == (E6,), f"unexpected errors: {result.errors}"
    assert result.waived_tools == frozenset()


def test_blank_evidence_is_rejected() -> None:
    """An empty evidence string is rejected."""

    # Arrange
    state = build_state(build_adoption(evidence=""))

    # Act
    result = run_resolver(state)

    # Assert
    assert result.errors == (E7,), f"unexpected errors: {result.errors}"
    assert result.waived_tools == frozenset()


def test_empty_waived_tools_is_rejected() -> None:
    """An empty waived_tools list is rejected by the shape check."""

    # Arrange
    state = build_state(build_adoption(waived_tools=[]))

    # Act
    result = run_resolver(state)

    # Assert
    assert result.errors == (E8A,), f"unexpected errors: {result.errors}"
    assert result.waived_tools == frozenset()


@pytest.mark.parametrize(
    "waived_tools",
    ["potential_to_issue", ["potential_to_issue", " "], ["potential_to_issue", 7]],
    ids=["string", "blank-entry", "integer-entry"],
)
def test_malformed_waived_tools_is_rejected(waived_tools: object) -> None:
    """A non-list or a list with a blank or non-string entry is malformed."""

    # Arrange
    state = build_state(build_adoption(waived_tools=waived_tools))

    # Act
    result = run_resolver(state)

    # Assert
    assert result.errors == (E8A,), f"unexpected errors: {result.errors}"
    assert result.waived_tools == frozenset()


def test_waived_tools_without_potential_to_issue_is_rejected() -> None:
    """The waived list must always include potential_to_issue."""

    # Arrange
    adoption = build_adoption(
        waived_tools=["new_potential_entry"], potential_record=VALID_RECORD
    )

    # Act
    result = run_resolver(build_state(adoption))

    # Assert
    assert result.errors == (E8INCLUDE,), f"unexpected errors: {result.errors}"
    assert result.waived_tools == frozenset()


def test_invalid_potential_record_is_rejected_when_waiving_entry_tool() -> None:
    """Waiving a promotion-entry tool requires a markdown potential record."""

    # Arrange
    adoption = build_adoption(
        waived_tools=["potential_to_issue", "new_potential_entry"],
        potential_record="notes/record.txt",
    )

    # Act
    result = run_resolver(build_state(adoption))

    # Assert
    assert result.errors == (
        invalid_potential_record_error("new_potential_entry"),
    ), f"unexpected errors: {result.errors}"
    assert result.waived_tools == frozenset()


# --- AC-9: fail-closed invariant ---------------------------------------------


def test_errors_always_imply_empty_waived_tools_on_fixed_grid() -> None:
    """Across a fixed grid, any error empties the waiver set.

    Expected outcome: for every combination, non-empty errors imply an empty
    waived set, and empty errors imply the waived set equals the listed tools.
    The grid is enumerated deterministically with no random source.
    """

    # Arrange
    grid = list(
        itertools.product(
            GRID_ISSUE_NUM,
            GRID_ORIGIN,
            GRID_VERIFIED_VIA,
            GRID_VERIFIED_AT,
            GRID_EVIDENCE,
            GRID_WAIVED_TOOLS,
        )
    )
    observed_valid = 0

    for issue_num, origin, verified_via, verified_at, evidence, waived in grid:
        adoption = build_adoption(
            issue_num=issue_num,
            issue_url=f"https://github.com/drmoisan/drm-copilot/issues/{issue_num}",
            origin=origin,
            verified_via=verified_via,
            verified_at=verified_at,
            evidence=evidence,
            waived_tools=waived,
            potential_record=VALID_RECORD,
        )

        # Act
        result = run_resolver(build_state(adoption))

        # Assert
        combination = (issue_num, origin, verified_via, verified_at, evidence, waived)
        if result.errors:
            assert result.waived_tools == frozenset(), (
                f"errors {result.errors} with waivers {result.waived_tools} "
                f"for {combination}"
            )
        else:
            observed_valid += 1
            assert isinstance(waived, list)
            waived_names = cast("list[object]", waived)
            assert result.waived_tools == frozenset(
                str(tool) for tool in waived_names
            ), f"waived set mismatch for {combination}"

    assert len(grid) == 96, f"grid size changed: {len(grid)}"
    assert (
        observed_valid == 2
    ), f"expected two fully valid combinations, got {observed_valid}"
