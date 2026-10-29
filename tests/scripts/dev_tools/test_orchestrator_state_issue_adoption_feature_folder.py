"""Unit tests for the issue-adoption feature_folder_record (issue #992).

These tests call ``resolve_issue_adoption`` through the shared support module
and pin rules 10 and 11a to 11e: waiving ``new_active_feature_folder`` requires
an object ``feature_folder_record``; an object record is validated whenever it
is present; its ``path`` must be a folder under ``docs/features/active/`` that
equals the checkpoint ``feature-folder``; ``verified_via`` is a closed set;
``verified_at`` is presence-only; and ``evidence`` is a non-blank string. A
final test runs the full ``--require-complete`` validation on the committed
corpus checkpoint that adopts a feature folder. No file is written and no
process is started.
"""

from __future__ import annotations

import json
from pathlib import Path

import pytest

from scripts.dev_tools.validate_orchestrator_state import (
    validate_orchestrator_state_text,
)
from tests.scripts.dev_tools.orchestrator_state_issue_adoption_test_support import (
    E10,
    E11A,
    E11B,
    E11C,
    E11D,
    E11E,
    FEATURE_FOLDER,
    FEATURE_FOLDER_TOOL,
    build_adoption,
    build_feature_folder_record,
    build_folder_adoption,
    build_folder_state,
    run_folder_resolver,
)

REPO_ROOT = Path(__file__).resolve().parents[3]
ADOPTED_FIXTURE = (
    REPO_ROOT
    / "tests"
    / "fixtures"
    / "orchestrator_state_issue_adoption"
    / "valid-large-waives-feature-folder-with-record.json"
)


# --- Rule 10: the record must be an object when the tool is waived ----------


def test_valid_record_waives_the_feature_folder_tool() -> None:
    """A valid record lets the adoption waive new_active_feature_folder."""

    # Arrange
    state = build_folder_state(build_folder_adoption())

    # Act
    result = run_folder_resolver(state)

    # Assert
    assert result.errors == (), f"unexpected errors: {result.errors}"
    assert FEATURE_FOLDER_TOOL in result.waived_tools


def test_rule_10_reports_an_absent_record() -> None:
    """Waiving the tool without the record key yields exactly rule 10."""

    # Arrange
    state = build_folder_state(build_folder_adoption(include_record=False))

    # Act
    result = run_folder_resolver(state)

    # Assert
    assert result.errors == (E10,)
    assert result.waived_tools == frozenset()


@pytest.mark.parametrize(
    "record",
    [None, FEATURE_FOLDER, ["path"], 7],
    ids=["null", "string", "list", "number"],
)
def test_rule_10_reports_a_non_object_record(record: object) -> None:
    """Waiving the tool with a non-object record yields exactly rule 10."""

    # Arrange
    state = build_folder_state(build_folder_adoption(record=record))

    # Act
    result = run_folder_resolver(state)

    # Assert
    assert result.errors == (E10,)


def test_rule_10_is_silent_when_the_tool_is_not_waived() -> None:
    """Without the waiver, an absent record reports nothing."""

    # Arrange
    state = build_folder_state(build_adoption())

    # Act
    result = run_folder_resolver(state)

    # Assert
    assert result.errors == ()


# --- Rule 11a: the path pattern ----------------------------------------------


@pytest.mark.parametrize(
    "path",
    [
        "docs/features/completed/2026-09-29-sample-feature-509",
        "docs/features/active/./2026-09-29-sample-feature-509",
        "docs/features/active/../active/2026-09-29-sample-feature-509",
        "docs/features/active//2026-09-29-sample-feature-509",
        "docs/features/active/2026-09-29-sample-feature-509/",
        "docs\\features\\active\\2026-09-29-sample-feature-509",
        "C:/docs/features/active/2026-09-29-sample-feature-509",
        "docs/features/active/-2026-09-29-sample-feature-509",
        "docs/features/active/2026-09-*",
        "docs/features/active/",
        "docs/features/active/2026-09-29-sample-feature-509\n",
        "",
    ],
    ids=[
        "outside-prefix",
        "dot-segment",
        "dot-dot-segment",
        "empty-segment",
        "trailing-slash",
        "backslash",
        "drive-letter",
        "leading-hyphen",
        "glob-character",
        "prefix-only",
        "trailing-newline",
        "empty",
    ],
)
def test_rule_11a_rejects_a_malformed_path(path: str) -> None:
    """A malformed path yields rule 11a only; rule 11b is not evaluated."""

    # Arrange
    record = build_feature_folder_record(path=path)
    state = build_folder_state(
        build_folder_adoption(record=record), feature_folder=path
    )

    # Act
    result = run_folder_resolver(state)

    # Assert
    assert result.errors == (E11A,), f"path {path!r} produced {result.errors}"


def test_rule_11a_rejects_a_non_string_path() -> None:
    """A path that is not a string yields rule 11a."""

    # Arrange
    state = build_folder_state(
        build_folder_adoption(record=build_feature_folder_record(path=509))
    )

    # Act
    result = run_folder_resolver(state)

    # Assert
    assert result.errors == (E11A,)


def test_rule_11a_accepts_a_valid_nested_path() -> None:
    """A nested folder under docs/features/active/ passes rule 11a and 11b."""

    # Arrange
    nested = "docs/features/active/epic-2026/child_1.v2"
    record = build_feature_folder_record(path=nested)
    state = build_folder_state(
        build_folder_adoption(record=record), feature_folder=nested
    )

    # Act
    result = run_folder_resolver(state)

    # Assert
    assert result.errors == ()


# --- Rule 11b: equality with the checkpoint feature-folder -------------------


@pytest.mark.parametrize(
    ("feature_folder", "include_folder"),
    [
        ("docs/features/active/2026-09-29-other-feature-510", True),
        (FEATURE_FOLDER.upper(), True),
        (992, True),
        (None, True),
        (FEATURE_FOLDER, False),
    ],
    ids=["different", "case-variant", "number", "null", "absent"],
)
def test_rule_11b_requires_equality_with_feature_folder(
    feature_folder: object, include_folder: bool
) -> None:
    """A valid path that differs from feature-folder yields rule 11b."""

    # Arrange
    state = build_folder_state(
        build_folder_adoption(),
        feature_folder=feature_folder,
        include_folder=include_folder,
    )

    # Act
    result = run_folder_resolver(state)

    # Assert
    assert result.errors == (E11B,)


# --- Rules 11c to 11e: provenance fields -------------------------------------


@pytest.mark.parametrize("value", ["git_ls_tree_head", "git_cat_file_head"])
def test_rule_11c_accepts_each_verification_value(value: str) -> None:
    """Both closed-set verification values pass rule 11c."""

    # Arrange
    record = build_feature_folder_record(verified_via=value)
    state = build_folder_state(build_folder_adoption(record=record))

    # Act / Assert
    assert run_folder_resolver(state).errors == ()


@pytest.mark.parametrize("value", ["git_status", "GIT_CAT_FILE_HEAD", None, 1])
def test_rule_11c_rejects_an_unknown_verification(value: object) -> None:
    """An unknown value, a case variant, or a non-string fails rule 11c."""

    # Arrange
    record = build_feature_folder_record(verified_via=value)
    state = build_folder_state(build_folder_adoption(record=record))

    # Act / Assert
    assert run_folder_resolver(state).errors == (E11C,)


@pytest.mark.parametrize("value", [None, "", "   "], ids=["null", "empty", "blank"])
def test_rule_11d_rejects_a_missing_verified_at(value: object) -> None:
    """A null or blank verified_at fails rule 11d."""

    # Arrange
    record = build_feature_folder_record(verified_at=value)
    state = build_folder_state(build_folder_adoption(record=record))

    # Act / Assert
    assert run_folder_resolver(state).errors == (E11D,)


def test_rule_11d_rejects_an_absent_verified_at() -> None:
    """An absent verified_at key fails rule 11d."""

    # Arrange
    record = build_feature_folder_record()
    del record["verified_at"]
    state = build_folder_state(build_folder_adoption(record=record))

    # Act / Assert
    assert run_folder_resolver(state).errors == (E11D,)


def test_rule_11d_is_presence_only() -> None:
    """A non-string verified_at value passes rule 11d."""

    # Arrange
    record = build_feature_folder_record(verified_at=0)
    state = build_folder_state(build_folder_adoption(record=record))

    # Act / Assert
    assert run_folder_resolver(state).errors == ()


@pytest.mark.parametrize(
    "value", ["", "  ", None, 3], ids=["empty", "blank", "null", "number"]
)
def test_rule_11e_rejects_missing_evidence(value: object) -> None:
    """A blank or non-string evidence value fails rule 11e."""

    # Arrange
    record = build_feature_folder_record(evidence=value)
    state = build_folder_state(build_folder_adoption(record=record))

    # Act / Assert
    assert run_folder_resolver(state).errors == (E11E,)


def test_rule_11e_accepts_non_blank_evidence() -> None:
    """A non-blank evidence string passes rule 11e."""

    # Arrange
    record = build_feature_folder_record(evidence="git ls-tree HEAD printed the folder")
    state = build_folder_state(build_folder_adoption(record=record))

    # Act / Assert
    assert run_folder_resolver(state).errors == ()


def test_record_errors_accumulate_in_rule_order() -> None:
    """Rules 11a, 11c, 11d, and 11e accumulate in order when all apply."""

    # Arrange
    record = {"path": "docs/x", "verified_via": "x", "verified_at": " ", "evidence": ""}
    state = build_folder_state(build_folder_adoption(record=record))

    # Act / Assert
    assert run_folder_resolver(state).errors == (E11A, E11C, E11D, E11E)


def test_record_is_validated_when_the_tool_is_not_waived() -> None:
    """An object record is validated even when the folder tool is not waived."""

    # Arrange
    adoption = build_adoption(
        feature_folder_record=build_feature_folder_record(evidence="")
    )
    state = build_folder_state(adoption)

    # Act
    result = run_folder_resolver(state)

    # Assert
    assert result.errors == (E11E,)
    assert result.waived_tools == frozenset()


def test_record_rules_do_not_run_when_waived_tools_is_malformed() -> None:
    """A malformed waived_tools list stops before rules 10 and 11."""

    # Arrange
    adoption = build_adoption(
        waived_tools="potential_to_issue",
        feature_folder_record=build_feature_folder_record(evidence=""),
    )

    # Act
    result = run_folder_resolver(build_folder_state(adoption))

    # Assert
    assert E11E not in result.errors
    assert E10 not in result.errors


# --- The completion gate on the committed corpus checkpoint ------------------


def test_require_complete_text_accepts_adopted_feature_folder() -> None:
    """--require-complete reports nothing about issue_adoption for an adopted folder."""

    # Arrange
    fixture = json.loads(ADOPTED_FIXTURE.read_text(encoding="utf-8"))
    text = json.dumps(fixture["checkpoint"])

    # Act
    lines = validate_orchestrator_state_text(text, require_complete=True)

    # Assert: collect any output line that names the adoption record or the
    # waived tool; the partial checkpoint's other required-key lines are expected.
    offending = [
        line
        for line in lines
        if "issue_adoption" in line or "new_active_feature_folder" in line
    ]
    assert offending == [], f"unexpected adoption lines: {offending}"
