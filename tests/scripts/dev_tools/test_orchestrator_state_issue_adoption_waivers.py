"""Unit tests for the issue-adoption waivable set, presence gating, and casing.

These tests call ``resolve_issue_adoption`` through the shared support module.
They pin three behavior groups: the closed waivable-tool set (AC-8), presence
gating when the ``issue_adoption`` key is absent (AC-11), and ordinal,
case-sensitive tool names (AC-16). A fourth group (issue #849) pins the
origin-conditional ``potential_record`` requirement for a promotion-entry
waiver: the record is optional when ``origin`` is ``transferred`` or
``filed_before_orchestration`` and the key is absent, required when ``origin``
is ``epic_decomposition``, and validated whenever it is present. The positive
schema cases, the rejection rules, and the fixed-grid invariant live in
``test_orchestrator_state_issue_adoption.py``.
"""

from __future__ import annotations

from tests.scripts.dev_tools.orchestrator_state_issue_adoption_test_support import (
    E4,
    E8INCLUDE,
    LARGE_BUG_TOOLS,
    LARGE_TOOLS,
    REMEDIATION_TOOLS,
    VALID_RECORD,
    build_adoption,
    build_state,
    duplicate_tool_error,
    invalid_potential_record_error,
    non_waivable_tool_error,
    run_resolver,
    tool_has_receipt_error,
    tool_not_required_error,
)

PREPARATION_BUG_TOOLS = (
    "new_potential_bug_entry",
    "potential_to_issue",
    "new_active_feature_folder",
    "validate_orchestration_artifacts",
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


# --- Issue #849: potential_record requirement by origin ---


def test_filed_before_orchestration_waives_bug_entry_tool_without_record() -> None:
    """A filed_before_orchestration bug adoption waives without a record."""

    # Arrange
    adoption = build_adoption(
        origin="filed_before_orchestration",
        waived_tools=["potential_to_issue", "new_potential_bug_entry"],
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


def test_transferred_waives_feature_entry_tool_without_record() -> None:
    """A transferred feature adoption waives the feature entry tool without a record."""

    # Arrange
    adoption = build_adoption(
        origin="transferred",
        waived_tools=["potential_to_issue", "new_potential_entry"],
    )

    # Act
    result = run_resolver(build_state(adoption), required_mcp_tools=LARGE_TOOLS)

    # Assert
    assert result.errors == (), f"unexpected errors: {result.errors}"
    assert result.waived_tools == frozenset(
        {"potential_to_issue", "new_potential_entry"}
    )


def test_filed_before_orchestration_preparation_route_waives_without_record() -> None:
    """The preparation route waives the bug entry tool without a record."""

    # Arrange
    adoption = build_adoption(
        origin="filed_before_orchestration",
        waived_tools=["potential_to_issue", "new_potential_bug_entry"],
    )

    # Act
    result = run_resolver(
        build_state(adoption, promotion_type="bug"),
        route_id="preparation",
        required_mcp_tools=PREPARATION_BUG_TOOLS,
        successful_tools=frozenset(
            {"new_active_feature_folder", "validate_orchestration_artifacts"}
        ),
    )

    # Assert
    assert result.errors == (), f"unexpected errors: {result.errors}"
    assert result.waived_tools == frozenset(
        {"potential_to_issue", "new_potential_bug_entry"}
    )


def test_epic_decomposition_without_record_still_reports_rule_nine() -> None:
    """An epic_decomposition adoption still needs a record to waive the entry tool."""

    # Arrange
    adoption = build_adoption(
        origin="epic_decomposition",
        waived_tools=["potential_to_issue", "new_potential_entry"],
    )

    # Act
    result = run_resolver(build_state(adoption))

    # Assert
    assert result.errors == (
        invalid_potential_record_error("new_potential_entry"),
    ), f"unexpected errors: {result.errors}"
    assert result.waived_tools == frozenset()


def test_filed_before_orchestration_with_null_record_still_reports_rule_nine() -> None:
    """A present null potential_record is validated and rejected for any origin."""

    # Arrange
    adoption = build_adoption(
        origin="filed_before_orchestration",
        waived_tools=["potential_to_issue", "new_potential_entry"],
        potential_record=None,
    )

    # Act
    result = run_resolver(build_state(adoption))

    # Assert
    assert result.errors == (
        invalid_potential_record_error("new_potential_entry"),
    ), f"unexpected errors: {result.errors}"
    assert result.waived_tools == frozenset()


def test_transferred_with_invalid_record_still_reports_rule_nine() -> None:
    """A present invalid potential_record is rejected when origin is transferred."""

    # Arrange
    adoption = build_adoption(
        origin="transferred",
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


def test_invalid_origin_without_record_reports_origin_and_rule_nine() -> None:
    """An invalid origin reports the origin error and does not relax rule 9."""

    # Arrange
    adoption = build_adoption(
        origin="imported",
        waived_tools=["potential_to_issue", "new_potential_entry"],
    )

    # Act
    result = run_resolver(build_state(adoption))

    # Assert
    assert result.errors == (
        E4,
        invalid_potential_record_error("new_potential_entry"),
    ), f"unexpected errors: {result.errors}"
    assert result.waived_tools == frozenset()
