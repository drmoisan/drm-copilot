"""Issue-adoption record validation and receipt waivers for orchestrator checkpoints.

Purpose:
    Validate the optional ``issue_adoption`` checkpoint object, which records
    that the orchestration adopted a GitHub issue that already existed before
    orchestration started. A valid record waives the successful-receipt
    requirement for ``potential_to_issue`` and, optionally, for the checkpoint's
    promotion-entry tool, because an adopted issue never passes through those
    MCP tools.

Usage:
    Call ``resolve_issue_adoption`` with the parsed checkpoint, the selected
    route id, the route's required MCP tools after promotion-type resolution,
    and the set of tools holding a successful MCP receipt. The routing
    contract skips the receipt check for each tool in the returned
    ``waived_tools`` and appends the returned ``errors`` after its receipt loop.

Invariants / Constraints:
    - When the ``issue_adoption`` key is absent, no error is produced and no
      tool is waived, so existing checkpoints validate exactly as before.
    - Errors accumulate in the fixed rule order of the feature specification.
    - Fail-closed: ``waived_tools`` is empty whenever ``errors`` is non-empty.
    - Every comparison is ordinal and case-sensitive.
    - Messages interpolate only non-blank ``waived_tools`` entries and the route id.

Side Effects:
    None. The module performs no I/O and does not mutate its inputs.
"""

from __future__ import annotations

import re
from dataclasses import dataclass
from typing import TYPE_CHECKING, Any, cast

from scripts.dev_tools._orchestrator_state_promotion_tools import (
    BUG_PROMOTION_ENTRY_TOOL,
    FEATURE_PROMOTION_ENTRY_TOOL,
)

if TYPE_CHECKING:
    from collections.abc import Collection, Sequence

__all__ = [
    "ISSUE_ADOPTION_KEY",
    "POTENTIAL_TO_ISSUE_TOOL",
    "ORIGIN_VALUES",
    "VERIFIED_VIA_VALUES",
    "WAIVABLE_TOOLS",
    "IssueAdoptionResult",
    "resolve_issue_adoption",
]

ISSUE_ADOPTION_KEY = "issue_adoption"
POTENTIAL_TO_ISSUE_TOOL = "potential_to_issue"
ORIGIN_VALUES: frozenset[str] = frozenset(
    {"transferred", "filed_before_orchestration", "epic_decomposition"}
)
VERIFIED_VIA_VALUES: frozenset[str] = frozenset(
    {"gh_issue_view", "gh_api_get", "github_mcp_issue_read"}
)
# The closed set of tools an adoption record may waive: the issue-creation tool
# and the two promotion-type-specific promotion-entry tools.
WAIVABLE_TOOLS: frozenset[str] = frozenset(
    {POTENTIAL_TO_ISSUE_TOOL, FEATURE_PROMOTION_ENTRY_TOOL, BUG_PROMOTION_ENTRY_TOOL}
)
PROMOTION_ENTRY_TOOLS: tuple[str, ...] = (
    FEATURE_PROMOTION_ENTRY_TOOL,
    BUG_PROMOTION_ENTRY_TOOL,
)
POTENTIAL_RECORD_PREFIX = "docs/features/potential/"
POTENTIAL_RECORD_SUFFIX = ".md"
ISSUE_NUM_PATTERN = re.compile(r"[1-9][0-9]*")

ERROR_NOT_OBJECT = "Checkpoint issue_adoption must be an object when present."
ERROR_ISSUE_NUM_FORMAT = (
    "Checkpoint issue_adoption.issue_num must be a string of decimal digits "
    "without a leading zero."
)
ERROR_ISSUE_NUM_MISMATCH = (
    "Checkpoint issue_adoption.issue_num must equal the checkpoint issue-num."
)
ERROR_ISSUE_URL = (
    "Checkpoint issue_adoption.issue_url must end with /issues/ followed by "
    "issue_num."
)
ERROR_ORIGIN = (
    "Checkpoint issue_adoption.origin must be one of transferred, "
    "filed_before_orchestration, epic_decomposition."
)
ERROR_VERIFIED_VIA = (
    "Checkpoint issue_adoption.verified_via must be one of gh_issue_view, "
    "gh_api_get, github_mcp_issue_read."
)
ERROR_VERIFIED_AT = "Checkpoint issue_adoption.verified_at must be present."
ERROR_EVIDENCE = "Checkpoint issue_adoption.evidence must be a non-empty string."
ERROR_WAIVED_TOOLS_SHAPE = (
    "Checkpoint issue_adoption.waived_tools must be a non-empty list of tool names."
)
ERROR_WAIVED_TOOLS_INCLUDE = (
    "Checkpoint issue_adoption.waived_tools must include potential_to_issue."
)


@dataclass(frozen=True)
class IssueAdoptionResult:
    """Outcome of validating a checkpoint's ``issue_adoption`` record.

    Attributes:
        errors (tuple[str, ...]): Adoption errors in rule order. Empty when the
            key is absent or the record is valid.
        waived_tools (frozenset[str]): Tools whose receipt requirement is
            waived. Empty whenever ``errors`` is non-empty.
    """

    errors: tuple[str, ...]
    waived_tools: frozenset[str]


def _is_non_blank_string(value: object) -> bool:
    """Return True when the value is a string with non-whitespace content."""

    return isinstance(value, str) and bool(value.strip())


def _valid_issue_num(value: object) -> str | None:
    """Return the issue number when it is a decimal string with no leading zero."""

    if isinstance(value, str) and ISSUE_NUM_PATTERN.fullmatch(value) is not None:
        return value
    return None


def _issue_identity_errors(
    adoption: dict[str, Any], state: dict[str, Any]
) -> list[str]:
    """Validate ``issue_num`` and ``issue_url`` (rules 2 and 3)."""

    errors: list[str] = []
    issue_num = _valid_issue_num(adoption.get("issue_num"))
    if issue_num is None:
        errors.append(ERROR_ISSUE_NUM_FORMAT)
    else:
        checkpoint_issue_num = state.get("issue-num")
        # The equality check applies only when the checkpoint records its own
        # issue number as a string; other shapes are validated elsewhere.
        if isinstance(checkpoint_issue_num, str) and checkpoint_issue_num != issue_num:
            errors.append(ERROR_ISSUE_NUM_MISMATCH)

    issue_url = adoption.get("issue_url")
    if (
        issue_num is None
        or not isinstance(issue_url, str)
        or not issue_url.endswith(f"/issues/{issue_num}")
    ):
        errors.append(ERROR_ISSUE_URL)
    return errors


def _provenance_errors(adoption: dict[str, Any]) -> list[str]:
    """Validate ``origin``, ``verified_via``, ``verified_at``, and ``evidence``."""

    errors: list[str] = []
    origin = adoption.get("origin")
    if not isinstance(origin, str) or origin not in ORIGIN_VALUES:
        errors.append(ERROR_ORIGIN)

    verified_via = adoption.get("verified_via")
    if not isinstance(verified_via, str) or verified_via not in VERIFIED_VIA_VALUES:
        errors.append(ERROR_VERIFIED_VIA)

    # Presence-only: any non-null value other than a blank string passes.
    verified_at = adoption.get("verified_at")
    if verified_at is None or (
        isinstance(verified_at, str) and not verified_at.strip()
    ):
        errors.append(ERROR_VERIFIED_AT)

    if not _is_non_blank_string(adoption.get("evidence")):
        errors.append(ERROR_EVIDENCE)
    return errors


def _waived_tool_list(value: object) -> list[str] | None:
    """Return the waived tools when they form a non-empty list of non-blank strings."""

    if not isinstance(value, list):
        return None
    items = cast("list[object]", value)
    if not items or not all(_is_non_blank_string(item) for item in items):
        return None
    return cast("list[str]", items)


def _waived_tool_errors(
    waived: Sequence[str],
    *,
    route_id: str,
    required_mcp_tools: Collection[str],
    successful_tools: Collection[str],
) -> list[str]:
    """Validate each waived tool entry and the mandatory issue-creation waiver."""

    errors: list[str] = []
    seen: set[str] = set()
    for tool in waived:
        # Each entry receives only the first rule it violates, in rule order.
        if tool in seen:
            errors.append(
                "Checkpoint issue_adoption.waived_tools lists a tool more than "
                f"once: {tool}."
            )
        elif tool not in WAIVABLE_TOOLS:
            errors.append(
                "Checkpoint issue_adoption.waived_tools names a tool that cannot "
                f"be waived: {tool}."
            )
        elif tool not in required_mcp_tools:
            errors.append(
                "Checkpoint issue_adoption.waived_tools names a tool that is not "
                f"required by route {route_id}: {tool}."
            )
        elif tool in successful_tools:
            errors.append(
                "Checkpoint issue_adoption.waived_tools names a tool that has a "
                f"successful MCP receipt: {tool}."
            )
        seen.add(tool)

    if POTENTIAL_TO_ISSUE_TOOL not in seen:
        errors.append(ERROR_WAIVED_TOOLS_INCLUDE)
    return errors


def _potential_record_errors(
    waived: Sequence[str], potential_record: object
) -> list[str]:
    """Require a potential record when a promotion-entry tool is waived (rule 9)."""

    record_is_valid = (
        isinstance(potential_record, str)
        and potential_record.startswith(POTENTIAL_RECORD_PREFIX)
        and potential_record.endswith(POTENTIAL_RECORD_SUFFIX)
    )
    if record_is_valid:
        return []

    errors: list[str] = []
    reported: set[str] = set()
    for tool in waived:
        if tool in PROMOTION_ENTRY_TOOLS and tool not in reported:
            errors.append(
                "Checkpoint issue_adoption.potential_record must name a markdown "
                f"file under docs/features/potential/ when waiving {tool}."
            )
            reported.add(tool)
    return errors


def resolve_issue_adoption(
    state: dict[str, Any],
    *,
    route_id: str,
    required_mcp_tools: Collection[str],
    successful_tools: Collection[str],
) -> IssueAdoptionResult:
    """Validate the checkpoint's ``issue_adoption`` record and resolve its waivers.

    Purpose:
        Let a checkpoint whose GitHub issue existed before orchestration
        complete without receipts for tools that an adopted issue never
        exercises, while failing closed on any malformed record.

    Args:
        state (dict[str, Any]): Parsed checkpoint state.
        route_id (str): The selected route id, interpolated into route errors.
        required_mcp_tools (Collection[str]): The route's required MCP tools
            after promotion-type resolution.
        successful_tools (Collection[str]): Tools that hold a successful MCP
            receipt in the checkpoint.

    Returns:
        IssueAdoptionResult: The ordered adoption errors and the waived-tool
        set. Both are empty when the key is absent; the waived-tool set is
        empty whenever any error is reported.

    Raises:
        None.

    Side Effects:
        None.
    """

    if ISSUE_ADOPTION_KEY not in state:
        return IssueAdoptionResult(errors=(), waived_tools=frozenset())

    raw_adoption: object = state[ISSUE_ADOPTION_KEY]
    if not isinstance(raw_adoption, dict):
        return IssueAdoptionResult(errors=(ERROR_NOT_OBJECT,), waived_tools=frozenset())
    adoption = cast("dict[str, Any]", raw_adoption)

    errors: list[str] = []
    errors.extend(_issue_identity_errors(adoption, state))
    errors.extend(_provenance_errors(adoption))

    waived = _waived_tool_list(adoption.get("waived_tools"))
    if waived is None:
        # A malformed list stops rule 8 and skips rule 9 entirely.
        errors.append(ERROR_WAIVED_TOOLS_SHAPE)
    else:
        errors.extend(
            _waived_tool_errors(
                waived,
                route_id=route_id,
                required_mcp_tools=required_mcp_tools,
                successful_tools=successful_tools,
            )
        )
        errors.extend(
            _potential_record_errors(waived, adoption.get("potential_record"))
        )

    if errors or waived is None:
        return IssueAdoptionResult(errors=tuple(errors), waived_tools=frozenset())
    return IssueAdoptionResult(errors=(), waived_tools=frozenset(waived))
