"""Unit tests for the orchestrator-state issue-adoption resolver.

These tests call ``resolve_issue_adoption`` directly with in-file checkpoint
dictionaries and the resolved ``required_mcp_tools`` lists of the ``large``,
``preparation``, and ``remediation`` routes. They pin the positive schema
cases, every rejection rule with its exact ordered error text, the closed
waivable-tool set, the fail-closed invariant, and presence gating.
"""

from __future__ import annotations

import itertools
from typing import cast

import pytest

from scripts.dev_tools._orchestrator_state_issue_adoption import (
    IssueAdoptionResult,
    resolve_issue_adoption,
)

LARGE_TOOLS: tuple[str, ...] = (
    "new_potential_entry",
    "potential_to_issue",
    "new_active_feature_folder",
    "collect_pr_context",
    "validate_orchestration_artifacts",
)
LARGE_BUG_TOOLS: tuple[str, ...] = (
    "new_potential_bug_entry",
    "potential_to_issue",
    "new_active_feature_folder",
    "collect_pr_context",
    "validate_orchestration_artifacts",
)
PREPARATION_TOOLS: tuple[str, ...] = (
    "new_potential_entry",
    "potential_to_issue",
    "new_active_feature_folder",
    "validate_orchestration_artifacts",
)
REMEDIATION_TOOLS: tuple[str, ...] = (
    "collect_pr_context",
    "validate_orchestration_artifacts",
)
# Tools that hold a successful receipt in a typical adopted checkpoint: every
# required tool except the ones an adopted issue never exercises.
NON_WAIVABLE_SUCCESSFUL: frozenset[str] = frozenset(
    {
        "new_active_feature_folder",
        "collect_pr_context",
        "validate_orchestration_artifacts",
    }
)
VALID_RECORD = (
    "docs/features/potential/promoted/"
    "2026-08-22-promotion-gate-lacks-preexisting-issue-branch.md"
)

E1 = "Checkpoint issue_adoption must be an object when present."
E2A = (
    "Checkpoint issue_adoption.issue_num must be a string of decimal digits "
    "without a leading zero."
)
E2B = "Checkpoint issue_adoption.issue_num must equal the checkpoint issue-num."
E3 = "Checkpoint issue_adoption.issue_url must end with /issues/ followed by issue_num."
E4 = (
    "Checkpoint issue_adoption.origin must be one of transferred, "
    "filed_before_orchestration, epic_decomposition."
)
E5 = (
    "Checkpoint issue_adoption.verified_via must be one of gh_issue_view, "
    "gh_api_get, github_mcp_issue_read."
)
E6 = "Checkpoint issue_adoption.verified_at must be present."
E7 = "Checkpoint issue_adoption.evidence must be a non-empty string."
E8A = "Checkpoint issue_adoption.waived_tools must be a non-empty list of tool names."
E8INCLUDE = "Checkpoint issue_adoption.waived_tools must include potential_to_issue."


def e8dup(tool: str) -> str:
    """Return the duplicate-waived-tool error for a tool."""

    return (
        f"Checkpoint issue_adoption.waived_tools lists a tool more than once: {tool}."
    )


def e8cannot(tool: str) -> str:
    """Return the non-waivable-tool error for a tool."""

    return (
        "Checkpoint issue_adoption.waived_tools names a tool that cannot be "
        f"waived: {tool}."
    )


def e8notreq(route_id: str, tool: str) -> str:
    """Return the tool-not-required-by-route error for a route and tool."""

    return (
        "Checkpoint issue_adoption.waived_tools names a tool that is not required "
        f"by route {route_id}: {tool}."
    )


def e8receipt(tool: str) -> str:
    """Return the tool-has-a-successful-receipt error for a tool."""

    return (
        "Checkpoint issue_adoption.waived_tools names a tool that has a successful "
        f"MCP receipt: {tool}."
    )


def e9(tool: str) -> str:
    """Return the invalid-potential-record error for a promotion-entry tool."""

    return (
        "Checkpoint issue_adoption.potential_record must name a markdown file "
        f"under docs/features/potential/ when waiving {tool}."
    )


def _adoption(**overrides: object) -> dict[str, object]:
    """Return the base valid adoption record for issue 509 with field overrides."""

    record: dict[str, object] = {
        "issue_num": "509",
        "issue_url": "https://github.com/drmoisan/drm-copilot/issues/509",
        "origin": "transferred",
        "verified_via": "gh_issue_view",
        "verified_at": "2026-09-29T15:15:00Z",
        "evidence": "gh issue view 509 --json number,state,url: number 509, state OPEN",
        "waived_tools": ["potential_to_issue"],
    }
    record.update(overrides)
    return record


def _state(adoption: object, *, promotion_type: str = "feature") -> dict[str, object]:
    """Return a minimal checkpoint carrying the given issue_adoption value."""

    return {
        "issue-num": "509",
        "promotion-type": promotion_type,
        "issue_adoption": adoption,
    }


def _resolve(
    state: dict[str, object],
    *,
    route_id: str = "large",
    required_mcp_tools: tuple[str, ...] = LARGE_TOOLS,
    successful_tools: frozenset[str] = NON_WAIVABLE_SUCCESSFUL,
) -> IssueAdoptionResult:
    """Run the resolver with the large-route defaults unless overridden."""

    return resolve_issue_adoption(
        state,
        route_id=route_id,
        required_mcp_tools=required_mcp_tools,
        successful_tools=successful_tools,
    )


# --- AC-6: positive schema cases -------------------------------------------


def test_feature_checkpoint_waiving_potential_to_issue_has_no_errors() -> None:
    """A feature checkpoint may waive potential_to_issue alone."""

    # Arrange
    state = _state(_adoption())

    # Act
    result = _resolve(state)

    # Assert
    assert result.errors == (), f"unexpected errors: {result.errors}"
    assert result.waived_tools == frozenset({"potential_to_issue"})


def test_feature_checkpoint_waiving_feature_entry_tool_with_record_has_no_errors() -> (
    None
):
    """A feature checkpoint may also waive its promotion-entry tool with a record."""

    # Arrange
    adoption = _adoption(
        waived_tools=["potential_to_issue", "new_potential_entry"],
        potential_record=VALID_RECORD,
    )

    # Act
    result = _resolve(_state(adoption))

    # Assert
    assert result.errors == (), f"unexpected errors: {result.errors}"
    assert result.waived_tools == frozenset(
        {"potential_to_issue", "new_potential_entry"}
    )


def test_bug_checkpoint_waiving_bug_entry_tool_with_record_has_no_errors() -> None:
    """A bug checkpoint may waive the bug promotion-entry tool with a record."""

    # Arrange
    adoption = _adoption(
        waived_tools=["potential_to_issue", "new_potential_bug_entry"],
        potential_record=VALID_RECORD,
    )

    # Act
    result = _resolve(
        _state(adoption, promotion_type="bug"), required_mcp_tools=LARGE_BUG_TOOLS
    )

    # Assert
    assert result.errors == (), f"unexpected errors: {result.errors}"
    assert result.waived_tools == frozenset(
        {"potential_to_issue", "new_potential_bug_entry"}
    )


def test_preparation_route_adoption_has_no_errors() -> None:
    """The preparation route accepts the same adoption record."""

    # Arrange
    state = _state(_adoption())

    # Act
    result = _resolve(
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
    state = _state(_adoption(origin=origin))

    # Act
    result = _resolve(state)

    # Assert
    assert result.errors == (), f"origin {origin} rejected: {result.errors}"
    assert result.waived_tools == frozenset({"potential_to_issue"})


@pytest.mark.parametrize(
    "verified_via", ["gh_issue_view", "gh_api_get", "github_mcp_issue_read"]
)
def test_every_verified_via_value_is_accepted(verified_via: str) -> None:
    """Each documented verified_via value yields no errors."""

    # Arrange
    state = _state(_adoption(verified_via=verified_via))

    # Act
    result = _resolve(state)

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
    state = _state(value)

    # Act
    result = _resolve(state)

    # Assert
    assert result.errors == (E1,), f"unexpected errors: {result.errors}"
    assert result.waived_tools == frozenset()


def test_null_value_is_rejected() -> None:
    """A null adoption value is present but not an object."""

    # Arrange
    state = _state(None)

    # Act
    result = _resolve(state)

    # Assert
    assert result.errors == (E1,), f"unexpected errors: {result.errors}"
    assert result.waived_tools == frozenset()


def test_integer_issue_num_is_rejected() -> None:
    """A JSON number issue_num fails the format and the URL rule."""

    # Arrange
    state = _state(_adoption(issue_num=509))

    # Act
    result = _resolve(state)

    # Assert
    assert result.errors == (E2A, E3), f"unexpected errors: {result.errors}"
    assert result.waived_tools == frozenset()


def test_leading_zero_issue_num_is_rejected() -> None:
    """A leading-zero issue_num fails the format and the URL rule."""

    # Arrange
    adoption = _adoption(
        issue_num="0509",
        issue_url="https://github.com/drmoisan/drm-copilot/issues/0509",
    )

    # Act
    result = _resolve(_state(adoption))

    # Assert
    assert result.errors == (E2A, E3), f"unexpected errors: {result.errors}"
    assert result.waived_tools == frozenset()


def test_issue_num_not_equal_to_checkpoint_issue_num_is_rejected() -> None:
    """A well-formed issue_num must equal the checkpoint issue-num."""

    # Arrange
    adoption = _adoption(
        issue_num="510",
        issue_url="https://github.com/drmoisan/drm-copilot/issues/510",
    )

    # Act
    result = _resolve(_state(adoption))

    # Assert
    assert result.errors == (E2B,), f"unexpected errors: {result.errors}"
    assert result.waived_tools == frozenset()


def test_mismatched_issue_url_is_rejected() -> None:
    """The issue URL must end with /issues/ followed by issue_num."""

    # Arrange
    adoption = _adoption(issue_url="https://github.com/drmoisan/drm-copilot/issues/510")

    # Act
    result = _resolve(_state(adoption))

    # Assert
    assert result.errors == (E3,), f"unexpected errors: {result.errors}"
    assert result.waived_tools == frozenset()


def test_unknown_origin_is_rejected() -> None:
    """An origin outside the documented set is rejected."""

    # Arrange
    state = _state(_adoption(origin="imported"))

    # Act
    result = _resolve(state)

    # Assert
    assert result.errors == (E4,), f"unexpected errors: {result.errors}"
    assert result.waived_tools == frozenset()


def test_unknown_verified_via_is_rejected() -> None:
    """A verified_via outside the documented set is rejected."""

    # Arrange
    state = _state(_adoption(verified_via="curl"))

    # Act
    result = _resolve(state)

    # Assert
    assert result.errors == (E5,), f"unexpected errors: {result.errors}"
    assert result.waived_tools == frozenset()


def test_absent_verified_at_is_rejected() -> None:
    """A missing verified_at is rejected."""

    # Arrange
    adoption = _adoption()
    del adoption["verified_at"]

    # Act
    result = _resolve(_state(adoption))

    # Assert
    assert result.errors == (E6,), f"unexpected errors: {result.errors}"
    assert result.waived_tools == frozenset()


def test_null_verified_at_is_rejected() -> None:
    """A null verified_at is rejected."""

    # Arrange
    state = _state(_adoption(verified_at=None))

    # Act
    result = _resolve(state)

    # Assert
    assert result.errors == (E6,), f"unexpected errors: {result.errors}"
    assert result.waived_tools == frozenset()


def test_blank_verified_at_is_rejected() -> None:
    """A whitespace-only verified_at is rejected."""

    # Arrange
    state = _state(_adoption(verified_at="   "))

    # Act
    result = _resolve(state)

    # Assert
    assert result.errors == (E6,), f"unexpected errors: {result.errors}"
    assert result.waived_tools == frozenset()


def test_blank_evidence_is_rejected() -> None:
    """An empty evidence string is rejected."""

    # Arrange
    state = _state(_adoption(evidence=""))

    # Act
    result = _resolve(state)

    # Assert
    assert result.errors == (E7,), f"unexpected errors: {result.errors}"
    assert result.waived_tools == frozenset()


def test_empty_waived_tools_is_rejected() -> None:
    """An empty waived_tools list is rejected by the shape check."""

    # Arrange
    state = _state(_adoption(waived_tools=[]))

    # Act
    result = _resolve(state)

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
    state = _state(_adoption(waived_tools=waived_tools))

    # Act
    result = _resolve(state)

    # Assert
    assert result.errors == (E8A,), f"unexpected errors: {result.errors}"
    assert result.waived_tools == frozenset()


def test_waived_tools_without_potential_to_issue_is_rejected() -> None:
    """The waived list must always include potential_to_issue."""

    # Arrange
    adoption = _adoption(
        waived_tools=["new_potential_entry"], potential_record=VALID_RECORD
    )

    # Act
    result = _resolve(_state(adoption))

    # Assert
    assert result.errors == (E8INCLUDE,), f"unexpected errors: {result.errors}"
    assert result.waived_tools == frozenset()


def test_invalid_potential_record_is_rejected_when_waiving_entry_tool() -> None:
    """Waiving a promotion-entry tool requires a markdown potential record."""

    # Arrange
    adoption = _adoption(
        waived_tools=["potential_to_issue", "new_potential_entry"],
        potential_record="notes/record.txt",
    )

    # Act
    result = _resolve(_state(adoption))

    # Assert
    assert result.errors == (
        e9("new_potential_entry"),
    ), f"unexpected errors: {result.errors}"
    assert result.waived_tools == frozenset()


# --- AC-8: the closed waivable set -----------------------------------------


def test_waiving_new_active_feature_folder_is_rejected() -> None:
    """new_active_feature_folder is outside the waivable set."""

    # Arrange
    adoption = _adoption(
        waived_tools=["potential_to_issue", "new_active_feature_folder"]
    )

    # Act
    result = _resolve(_state(adoption))

    # Assert
    assert result.errors == (
        e8cannot("new_active_feature_folder"),
    ), f"unexpected errors: {result.errors}"
    assert result.waived_tools == frozenset()


def test_waiving_validate_orchestration_artifacts_is_rejected() -> None:
    """validate_orchestration_artifacts is outside the waivable set."""

    # Arrange
    adoption = _adoption(
        waived_tools=["potential_to_issue", "validate_orchestration_artifacts"]
    )

    # Act
    result = _resolve(_state(adoption))

    # Assert
    assert result.errors == (
        e8cannot("validate_orchestration_artifacts"),
    ), f"unexpected errors: {result.errors}"
    assert result.waived_tools == frozenset()


def test_waiving_feature_entry_tool_on_bug_checkpoint_is_rejected() -> None:
    """A bug checkpoint's resolved tools do not include the feature entry tool."""

    # Arrange
    adoption = _adoption(
        waived_tools=["potential_to_issue", "new_potential_entry"],
        potential_record=VALID_RECORD,
    )

    # Act
    result = _resolve(
        _state(adoption, promotion_type="bug"), required_mcp_tools=LARGE_BUG_TOOLS
    )

    # Assert
    assert result.errors == (
        e8notreq("large", "new_potential_entry"),
    ), f"unexpected errors: {result.errors}"
    assert result.waived_tools == frozenset()


def test_waiving_on_remediation_route_is_rejected() -> None:
    """The remediation route does not require potential_to_issue."""

    # Arrange
    state = _state(_adoption())

    # Act
    result = _resolve(
        state,
        route_id="remediation",
        required_mcp_tools=REMEDIATION_TOOLS,
        successful_tools=frozenset(REMEDIATION_TOOLS),
    )

    # Assert
    assert result.errors == (
        e8notreq("remediation", "potential_to_issue"),
    ), f"unexpected errors: {result.errors}"
    assert result.waived_tools == frozenset()


def test_waiving_tool_with_successful_receipt_is_rejected() -> None:
    """A tool that already holds a successful receipt cannot be waived."""

    # Arrange
    state = _state(_adoption())

    # Act
    result = _resolve(state, successful_tools=frozenset(LARGE_TOOLS))

    # Assert
    assert result.errors == (
        e8receipt("potential_to_issue"),
    ), f"unexpected errors: {result.errors}"
    assert result.waived_tools == frozenset()


def test_duplicate_waived_tool_is_rejected() -> None:
    """A tool listed twice is rejected on its second occurrence."""

    # Arrange
    state = _state(_adoption(waived_tools=["potential_to_issue", "potential_to_issue"]))

    # Act
    result = _resolve(state)

    # Assert
    assert result.errors == (
        e8dup("potential_to_issue"),
    ), f"unexpected errors: {result.errors}"
    assert result.waived_tools == frozenset()


# --- AC-9: fail-closed invariant ---------------------------------------------

GRID_ISSUE_NUM: tuple[object, ...] = ("509", "0509")
GRID_ORIGIN: tuple[object, ...] = ("transferred", "imported")
GRID_VERIFIED_VIA: tuple[object, ...] = ("gh_issue_view", "curl")
GRID_VERIFIED_AT: tuple[object, ...] = ("2026-09-29T15:15:00Z", " ")
GRID_EVIDENCE: tuple[object, ...] = ("gh issue view 509", "")
GRID_WAIVED_TOOLS: tuple[object, ...] = (
    ["potential_to_issue"],
    ["potential_to_issue", "new_potential_entry"],
    [],
)


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
        adoption = _adoption(
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
        result = _resolve(_state(adoption))

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


# --- AC-11: presence gating --------------------------------------------------


def test_absent_key_yields_no_errors_and_no_waivers() -> None:
    """Without the issue_adoption key nothing is validated or waived."""

    # Arrange
    state: dict[str, object] = {"issue-num": "509", "promotion-type": "feature"}

    # Act
    result = _resolve(state)

    # Assert
    assert result.errors == (), f"unexpected errors: {result.errors}"
    assert result.waived_tools == frozenset()


# --- AC-16: ordinal, case-sensitive tool names -------------------------------


def test_case_variant_tool_name_is_rejected() -> None:
    """A case-variant tool name is not the waivable potential_to_issue tool."""

    # Arrange
    state = _state(_adoption(waived_tools=["Potential_To_Issue"]))

    # Act
    result = _resolve(state)

    # Assert
    assert result.errors == (
        e8cannot("Potential_To_Issue"),
        E8INCLUDE,
    ), f"unexpected errors: {result.errors}"
    assert result.waived_tools == frozenset()
