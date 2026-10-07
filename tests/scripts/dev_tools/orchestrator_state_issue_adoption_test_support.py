"""Shared constants and builders for the issue-adoption resolver unit tests.

Purpose:
    Hold the route tool lists, expected message strings, message builders,
    fixed-grid value tuples, and checkpoint builders used by
    ``test_orchestrator_state_issue_adoption.py`` and
    ``test_orchestrator_state_issue_adoption_waivers.py``.

Responsibilities:
    Provide the resolved ``required_mcp_tools`` lists of the ``large``,
    ``preparation``, and ``remediation`` routes, the exact validator message
    text for every rule, a base valid adoption record, a minimal checkpoint
    builder, and a resolver wrapper with large-route defaults.

Side effects:
    None. No file is read or written and no process is started.

Naming:
    Follows the ``*_test_support.py`` convention of
    ``tests/scripts/dev_tools/validate_orchestrator_state_test_support.py``,
    so pytest does not collect this module.
"""

from __future__ import annotations

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


def duplicate_tool_error(tool: str) -> str:
    """Return the duplicate-waived-tool error for a tool."""

    return (
        f"Checkpoint issue_adoption.waived_tools lists a tool more than once: {tool}."
    )


def non_waivable_tool_error(tool: str) -> str:
    """Return the non-waivable-tool error for a tool."""

    return (
        "Checkpoint issue_adoption.waived_tools names a tool that cannot be "
        f"waived: {tool}."
    )


def tool_not_required_error(route_id: str, tool: str) -> str:
    """Return the tool-not-required-by-route error for a route and tool."""

    return (
        "Checkpoint issue_adoption.waived_tools names a tool that is not required "
        f"by route {route_id}: {tool}."
    )


def tool_has_receipt_error(tool: str) -> str:
    """Return the tool-has-a-successful-receipt error for a tool."""

    return (
        "Checkpoint issue_adoption.waived_tools names a tool that has a successful "
        f"MCP receipt: {tool}."
    )


def invalid_potential_record_error(tool: str) -> str:
    """Return the invalid-potential-record error for a promotion-entry tool."""

    return (
        "Checkpoint issue_adoption.potential_record must name a markdown file "
        f"under docs/features/potential/ when waiving {tool}."
    )


def build_adoption(**overrides: object) -> dict[str, object]:
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


def build_state(
    adoption: object, *, promotion_type: str = "feature"
) -> dict[str, object]:
    """Return a minimal checkpoint carrying the given issue_adoption value."""

    return {
        "issue-num": "509",
        "promotion-type": promotion_type,
        "issue_adoption": adoption,
    }


def run_resolver(
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
