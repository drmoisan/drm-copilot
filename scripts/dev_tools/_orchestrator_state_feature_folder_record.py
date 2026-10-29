"""Feature-folder adoption record validation for orchestrator checkpoints.

Purpose:
    Validate the optional ``issue_adoption.feature_folder_record`` object, which
    declares that an adopted feature folder already existed and was committed
    before the finishing run started. A valid record lets the adoption waive
    the ``new_active_feature_folder`` receipt (issue #992).

Usage:
    ``resolve_issue_adoption`` calls ``feature_folder_record_errors`` after
    rule 9, only when the rule-8 ``waived_tools`` shape check passed, and
    appends the returned errors to its ordered error list.

Invariants / Constraints:
    - Rule 10: waiving ``new_active_feature_folder`` requires the record to be
      an object.
    - Rules 11a to 11e run whenever the record is an object, waived or not;
      rule 11b runs only when ``path`` passed rule 11a.
    - Every comparison is ordinal and case-sensitive, and the path pattern is
      applied as a full match.
    - The record is a declaration. This module cannot confirm that the folder
      exists or is committed; the Claude ``SubagentStop`` hook performs that
      probe separately.

Side Effects:
    None. The module performs no I/O and does not mutate its inputs.
"""

from __future__ import annotations

import re
from typing import TYPE_CHECKING, Any, cast

if TYPE_CHECKING:
    from collections.abc import Sequence

__all__ = [
    "ERROR_FEATURE_FOLDER_EVIDENCE",
    "ERROR_FEATURE_FOLDER_PATH_EQUAL",
    "ERROR_FEATURE_FOLDER_PATH_FORMAT",
    "ERROR_FEATURE_FOLDER_RECORD_NOT_OBJECT",
    "ERROR_FEATURE_FOLDER_VERIFIED_AT",
    "ERROR_FEATURE_FOLDER_VERIFIED_VIA",
    "FEATURE_FOLDER_PATH_PATTERN",
    "FEATURE_FOLDER_RECORD_KEY",
    "FEATURE_FOLDER_TOOL",
    "FEATURE_FOLDER_VERIFIED_VIA",
    "feature_folder_record_errors",
    "is_feature_folder_path",
]

FEATURE_FOLDER_TOOL = "new_active_feature_folder"
FEATURE_FOLDER_RECORD_KEY = "feature_folder_record"
CHECKPOINT_FEATURE_FOLDER_KEY = "feature-folder"
# A repository-relative folder under docs/features/active/: every segment
# starts with an alphanumeric character, so dot segments, empty segments, a
# trailing slash, backslashes, drive letters, glob characters, and a leading
# hyphen cannot match. Applied with re.fullmatch.
FEATURE_FOLDER_PATH_PATTERN = re.compile(
    r"^docs/features/active/[A-Za-z0-9][A-Za-z0-9._-]*(/[A-Za-z0-9][A-Za-z0-9._-]*)*$"
)
FEATURE_FOLDER_VERIFIED_VIA: tuple[str, ...] = ("git_cat_file_head", "git_ls_tree_head")

ERROR_FEATURE_FOLDER_RECORD_NOT_OBJECT = (
    "Checkpoint issue_adoption.feature_folder_record must be an object when waiving "
    "new_active_feature_folder."
)
ERROR_FEATURE_FOLDER_PATH_FORMAT = (
    "Checkpoint issue_adoption.feature_folder_record.path must be a folder path under "
    "docs/features/active/ without dot segments or a trailing slash."
)
ERROR_FEATURE_FOLDER_PATH_EQUAL = (
    "Checkpoint issue_adoption.feature_folder_record.path must equal the checkpoint "
    "feature-folder."
)
ERROR_FEATURE_FOLDER_VERIFIED_VIA = (
    "Checkpoint issue_adoption.feature_folder_record.verified_via must be one of "
    "git_cat_file_head, git_ls_tree_head."
)
ERROR_FEATURE_FOLDER_VERIFIED_AT = (
    "Checkpoint issue_adoption.feature_folder_record.verified_at must be present."
)
ERROR_FEATURE_FOLDER_EVIDENCE = (
    "Checkpoint issue_adoption.feature_folder_record.evidence must be a non-empty "
    "string."
)


def is_feature_folder_path(value: object) -> bool:
    """Report whether a value is a valid adopted feature-folder path.

    Args:
        value (object): The deserialized JSON value to inspect.

    Returns:
        bool: True when the value is a string that fully matches
        ``FEATURE_FOLDER_PATH_PATTERN``; False for any other value.
    """

    return (
        isinstance(value, str)
        and FEATURE_FOLDER_PATH_PATTERN.fullmatch(value) is not None
    )


def _record_field_errors(record: dict[str, Any], state: dict[str, Any]) -> list[str]:
    """Validate the fields of an object-shaped record (rules 11a to 11e).

    Args:
        record (dict[str, Any]): The ``feature_folder_record`` object.
        state (dict[str, Any]): The parsed checkpoint, read for its
            ``feature-folder`` key.

    Returns:
        list[str]: Zero or more errors in rule order.
    """

    errors: list[str] = []
    path = record.get("path")
    # Rule 11b compares a well-formed path only; a malformed path is reported
    # once by rule 11a instead of twice.
    if not is_feature_folder_path(path):
        errors.append(ERROR_FEATURE_FOLDER_PATH_FORMAT)
    else:
        checkpoint_folder = state.get(CHECKPOINT_FEATURE_FOLDER_KEY)
        if not isinstance(checkpoint_folder, str) or checkpoint_folder != path:
            errors.append(ERROR_FEATURE_FOLDER_PATH_EQUAL)

    verified_via = record.get("verified_via")
    if (
        not isinstance(verified_via, str)
        or verified_via not in FEATURE_FOLDER_VERIFIED_VIA
    ):
        errors.append(ERROR_FEATURE_FOLDER_VERIFIED_VIA)

    # Presence-only, matching the adoption-level verified_at rule: any value
    # other than an absent key, null, or a blank string passes.
    verified_at = record.get("verified_at")
    if verified_at is None or (
        isinstance(verified_at, str) and not verified_at.strip()
    ):
        errors.append(ERROR_FEATURE_FOLDER_VERIFIED_AT)

    evidence = record.get("evidence")
    if not isinstance(evidence, str) or not evidence.strip():
        errors.append(ERROR_FEATURE_FOLDER_EVIDENCE)
    return errors


def feature_folder_record_errors(
    adoption: dict[str, Any], state: dict[str, Any], waived_tools: Sequence[str]
) -> list[str]:
    """Validate ``issue_adoption.feature_folder_record`` (rules 10 and 11a-11e).

    Args:
        adoption (dict[str, Any]): The ``issue_adoption`` object.
        state (dict[str, Any]): The parsed checkpoint, read for its
            ``feature-folder`` key.
        waived_tools (Sequence[str]): The well-formed ``waived_tools`` list,
            in checkpoint order.

    Returns:
        list[str]: Zero or more errors in rule order. Empty when the tool is
        not waived and no object record is present, or when the record is
        valid.

    Raises:
        None.

    Side Effects:
        None.
    """

    raw_record: object = adoption.get(FEATURE_FOLDER_RECORD_KEY)
    # An object record is always validated (rules 11a-11e); a missing or
    # non-object record matters only when the tool is waived (rule 10).
    if isinstance(raw_record, dict):
        return _record_field_errors(cast("dict[str, Any]", raw_record), state)
    if FEATURE_FOLDER_TOOL in waived_tools:
        return [ERROR_FEATURE_FOLDER_RECORD_NOT_OBJECT]
    return []
