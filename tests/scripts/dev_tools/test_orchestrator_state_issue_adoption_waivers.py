"""Unit tests for the issue-adoption waivable set, presence gating, and casing.

These tests call ``resolve_issue_adoption`` through the shared support module.
They pin three behavior groups: the closed waivable-tool set (AC-8), presence
gating when the ``issue_adoption`` key is absent (AC-11), and ordinal,
case-sensitive tool names (AC-16). The positive schema cases, the rejection
rules, and the fixed-grid invariant live in
``test_orchestrator_state_issue_adoption.py``.
"""

from __future__ import annotations

from tests.scripts.dev_tools.orchestrator_state_issue_adoption_test_support import (
    E8INCLUDE,
    LARGE_BUG_TOOLS,
    LARGE_TOOLS,
    REMEDIATION_TOOLS,
    VALID_RECORD,
    build_adoption,
    build_state,
    duplicate_tool_error,
    non_waivable_tool_error,
    run_resolver,
    tool_has_receipt_error,
    tool_not_required_error,
)

# --- AC-8: the closed waivable set -----------------------------------------


def test_waiving_new_active_feature_folder_is_rejected() -> None:
    """new_active_feature_folder is outside the waivable set."""

    # Arrange
    adoption = build_adoption(
        waived_tools=["potential_to_issue", "new_active_feature_folder"]
    )

    # Act
    result = run_resolver(build_state(adoption))

    # Assert
    assert result.errors == (
        non_waivable_tool_error("new_active_feature_folder"),
    ), f"unexpected errors: {result.errors}"
    assert result.waived_tools == frozenset()


def test_waiving_validate_orchestration_artifacts_is_rejected() -> None:
    """validate_orchestration_artifacts is outside the waivable set."""

    # Arrange
    adoption = build_adoption(
        waived_tools=["potential_to_issue", "validate_orchestration_artifacts"]
    )

    # Act
    result = run_resolver(build_state(adoption))

    # Assert
    assert result.errors == (
        non_waivable_tool_error("validate_orchestration_artifacts"),
    ), f"unexpected errors: {result.errors}"
    assert result.waived_tools == frozenset()


def test_waiving_feature_entry_tool_on_bug_checkpoint_is_rejected() -> None:
    """A bug checkpoint's resolved tools do not include the feature entry tool."""

    # Arrange
    adoption = build_adoption(
        waived_tools=["potential_to_issue", "new_potential_entry"],
        potential_record=VALID_RECORD,
    )

    # Act
    result = run_resolver(
        build_state(adoption, promotion_type="bug"), required_mcp_tools=LARGE_BUG_TOOLS
    )

    # Assert
    assert result.errors == (
        tool_not_required_error("large", "new_potential_entry"),
    ), f"unexpected errors: {result.errors}"
    assert result.waived_tools == frozenset()


def test_waiving_on_remediation_route_is_rejected() -> None:
    """The remediation route does not require potential_to_issue."""

    # Arrange
    state = build_state(build_adoption())

    # Act
    result = run_resolver(
        state,
        route_id="remediation",
        required_mcp_tools=REMEDIATION_TOOLS,
        successful_tools=frozenset(REMEDIATION_TOOLS),
    )

    # Assert
    assert result.errors == (
        tool_not_required_error("remediation", "potential_to_issue"),
    ), f"unexpected errors: {result.errors}"
    assert result.waived_tools == frozenset()


def test_waiving_tool_with_successful_receipt_is_rejected() -> None:
    """A tool that already holds a successful receipt cannot be waived."""

    # Arrange
    state = build_state(build_adoption())

    # Act
    result = run_resolver(state, successful_tools=frozenset(LARGE_TOOLS))

    # Assert
    assert result.errors == (
        tool_has_receipt_error("potential_to_issue"),
    ), f"unexpected errors: {result.errors}"
    assert result.waived_tools == frozenset()


def test_duplicate_waived_tool_is_rejected() -> None:
    """A tool listed twice is rejected on its second occurrence."""

    # Arrange
    state = build_state(
        build_adoption(waived_tools=["potential_to_issue", "potential_to_issue"])
    )

    # Act
    result = run_resolver(state)

    # Assert
    assert result.errors == (
        duplicate_tool_error("potential_to_issue"),
    ), f"unexpected errors: {result.errors}"
    assert result.waived_tools == frozenset()


# --- AC-11: presence gating --------------------------------------------------


def test_absent_key_yields_no_errors_and_no_waivers() -> None:
    """Without the issue_adoption key nothing is validated or waived."""

    # Arrange
    state: dict[str, object] = {"issue-num": "509", "promotion-type": "feature"}

    # Act
    result = run_resolver(state)

    # Assert
    assert result.errors == (), f"unexpected errors: {result.errors}"
    assert result.waived_tools == frozenset()


# --- AC-16: ordinal, case-sensitive tool names -------------------------------


def test_case_variant_tool_name_is_rejected() -> None:
    """A case-variant tool name is not the waivable potential_to_issue tool."""

    # Arrange
    state = build_state(build_adoption(waived_tools=["Potential_To_Issue"]))

    # Act
    result = run_resolver(state)

    # Assert
    assert result.errors == (
        non_waivable_tool_error("Potential_To_Issue"),
        E8INCLUDE,
    ), f"unexpected errors: {result.errors}"
    assert result.waived_tools == frozenset()
