"""Shared constants and builders for the issue-adoption resolver unit tests.

Purpose:
    Hold the route tool lists, expected message strings, message builders,
    fixed-grid value tuples, and checkpoint builders used by
    ``test_orchestrator_state_issue_adoption.py`` and
    ``test_orchestrator_state_issue_adoption_waivers.py``, plus the
    ``feature_folder_record`` builders used by
    ``test_orchestrator_state_issue_adoption_feature_folder.py``.

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


# --- Issue #992: feature_folder_record messages and builders -----------------

FEATURE_FOLDER = "docs/features/active/2026-09-29-sample-feature-509"
FEATURE_FOLDER_TOOL = "new_active_feature_folder"
# Successful receipts of an adopted checkpoint whose feature folder was created
# before the run: the folder tool holds no receipt.
SUCCESSFUL_WITHOUT_FOLDER: frozenset[str] = frozenset(
    {"collect_pr_context", "validate_orchestration_artifacts"}
)

E10 = (
    "Checkpoint issue_adoption.feature_folder_record must be an object when waiving "
    "new_active_feature_folder."
)
E11A = (
    "Checkpoint issue_adoption.feature_folder_record.path must be a folder path under "
    "docs/features/active/ without dot segments or a trailing slash."
)
E11B = (
    "Checkpoint issue_adoption.feature_folder_record.path must equal the checkpoint "
    "feature-folder."
)
E11C = (
    "Checkpoint issue_adoption.feature_folder_record.verified_via must be one of "
    "git_cat_file_head, git_ls_tree_head."
)
E11D = "Checkpoint issue_adoption.feature_folder_record.verified_at must be present."
E11E = (
    "Checkpoint issue_adoption.feature_folder_record.evidence must be a non-empty "
    "string."
)

# Sentinel default of build_folder_adoption: a valid record, distinct from an
# explicit None, which a test passes to exercise a null record.
_VALID_FOLDER_RECORD = object()


def build_feature_folder_record(**overrides: object) -> dict[str, object]:
    """Return a valid feature_folder_record for FEATURE_FOLDER with field overrides."""

    record: dict[str, object] = {
        "path": FEATURE_FOLDER,
        "verified_via": "git_cat_file_head",
        "verified_at": "2026-09-29T15:20:00Z",
        "evidence": f"git cat-file -t HEAD:{FEATURE_FOLDER} printed tree",
    }
    record.update(overrides)
    return record


def build_folder_adoption(
    record: object = _VALID_FOLDER_RECORD, *, include_record: bool = True
) -> dict[str, object]:
    """Return an adoption that waives the folder tool and carries the given record.

    Args:
        record (object): The ``feature_folder_record`` value; defaults to a
            valid record.
        include_record (bool): False omits the ``feature_folder_record`` key.

    Returns:
        dict[str, object]: The adoption record.
    """

    fields: dict[str, object] = {
        "waived_tools": ["potential_to_issue", FEATURE_FOLDER_TOOL],
    }
    if include_record:
        fields["feature_folder_record"] = (
            build_feature_folder_record() if record is _VALID_FOLDER_RECORD else record
        )
    return build_adoption(**fields)


def build_folder_state(
    adoption: object,
    *,
    feature_folder: object = FEATURE_FOLDER,
    include_folder: bool = True,
) -> dict[str, object]:
    """Return a minimal checkpoint with a ``feature-folder`` key and the adoption."""

    state = build_state(adoption)
    if include_folder:
        state["feature-folder"] = feature_folder
    return state


def run_folder_resolver(state: dict[str, object]) -> IssueAdoptionResult:
    """Run the resolver on the large route with no folder-tool receipt."""

    return run_resolver(state, successful_tools=SUCCESSFUL_WITHOUT_FOLDER)
