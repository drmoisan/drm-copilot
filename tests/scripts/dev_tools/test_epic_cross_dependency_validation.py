"""Unit tests for the issue #1162 cross-epic dependency validator rules.

Covers the helpers ``is_positive_int`` and ``is_epic_slug``, the key-gated shape
check ``validate_cross_epic_dependency_shape`` in both checkpoint types, the
started-while-held check ``validate_cross_epic_started_while_held``, and the
completion backstop ``validate_cross_epic_main_gate`` reached through
``require_complete``. Checkpoints are in-memory JSON; no file is created.
"""

from __future__ import annotations

import json
from typing import Any

import pytest

from scripts.dev_tools._epic_orchestrator_state_resolution import (
    is_epic_slug,
    is_positive_int,
    validate_cross_epic_dependency_shape,
    validate_cross_epic_main_gate,
)
from scripts.dev_tools._epic_orchestrator_state_wave_barrier import (
    validate_cross_epic_started_while_held,
)
from scripts.dev_tools.validate_epic_orchestrator_state import (
    validate_epic_orchestrator_state_text,
)
from scripts.dev_tools.validate_epic_planner_state import (
    validate_epic_planner_state_text,
)

EDGE: dict[str, Any] = {
    "epic": "provider-epic",
    "integration_branch": "epic/provider-epic-integration",
    "issue_num": 1188,
}
MALFORMED_ENTRY = (
    "EPIC_CROSS_DEPENDENCY_MALFORMED: features[0].cross_epic_depends_on[0]."
)
GATE_ENTRY: dict[str, Any] = {
    "epic": "provider-epic",
    "integration_branch": "epic/provider-epic-integration",
    "pr_number": 90,
    "merge_commit_sha": "m90",
    "verified_at": "2026-11-10T00:00:00Z",
}


def _feature(**extra: Any) -> dict[str, Any]:
    """Return one epic checkpoint feature with optional extra keys.

    Args:
        **extra (Any): Keys added to or replacing the base feature.

    Returns:
        dict[str, Any]: A new feature mapping.

    Raises:
        None.

    Side Effects:
        None.
    """

    feature: dict[str, Any] = {
        "issue_num": 1201,
        "feature_folder": "c-1201",
        "depends_on": [],
        "merge_status": "not_started",
    }
    feature.update(extra)
    return feature


def _cross(errors: list[str]) -> list[str]:
    """Keep only the cross-epic errors of a validator result.

    Args:
        errors (list[str]): Every validator error.

    Returns:
        list[str]: The errors that begin with ``EPIC_CROSS_DEPENDENCY_``.

    Raises:
        None.

    Side Effects:
        None.
    """

    return [error for error in errors if error.startswith("EPIC_CROSS_DEPENDENCY_")]


@pytest.mark.parametrize(
    ("value", "expected"),
    [
        (1, True),
        (1188, True),
        (0, False),
        (-3, False),
        (True, False),
        ("7", False),
        (1.5, False),
        (None, False),
    ],
)
def test_is_positive_int(value: object, expected: bool) -> None:
    """Only an int above zero, never a boolean, counts as a positive integer."""

    assert is_positive_int(value) is expected


@pytest.mark.parametrize(
    ("value", "expected"),
    [
        ("provider-epic", True),
        ("a.b_c-1", True),
        (".", False),
        ("..", False),
        ("a/b", False),
        ("", False),
        ("a b", False),
        (5, False),
    ],
)
def test_is_epic_slug(value: object, expected: bool) -> None:
    """An epic slug is one plain segment and never a dot segment."""

    assert is_epic_slug(value) is expected


@pytest.mark.parametrize("checkpoint_type", ["orchestrator", "planner"])
@pytest.mark.parametrize("value", [None, []], ids=["absent", "empty"])
def test_absent_or_empty_key_leaves_validator_output_unchanged(
    checkpoint_type: str, value: list[Any] | None
) -> None:
    """A checkpoint without the key, or with [], validates exactly as before."""

    # Arrange
    keyed_feature = _feature()
    if value is not None:
        keyed_feature["cross_epic_depends_on"] = value
    base = {"objective": "o", "features": [_feature()]}
    keyed = {"objective": "o", "features": [keyed_feature]}
    validate = (
        validate_epic_orchestrator_state_text
        if checkpoint_type == "orchestrator"
        else validate_epic_planner_state_text
    )

    # Act
    before = validate(json.dumps(base))
    after = validate(json.dumps(keyed))

    # Assert
    assert after == before


@pytest.mark.parametrize("checkpoint_type", ["orchestrator", "planner"])
def test_malformed_entry_is_rejected_in_both_checkpoint_types(
    checkpoint_type: str,
) -> None:
    """A malformed entry yields EPIC_CROSS_DEPENDENCY_MALFORMED in both validators."""

    # Arrange
    text = json.dumps({"features": [_feature(cross_epic_depends_on=[{"epic": "p"}])]})
    validate = (
        validate_epic_orchestrator_state_text
        if checkpoint_type == "orchestrator"
        else validate_epic_planner_state_text
    )

    # Act
    errors = _cross(validate(text))

    # Assert
    assert errors == [
        MALFORMED_ENTRY + "integration_branch must be a non-empty string.",
        MALFORMED_ENTRY + "issue_num must be a positive integer.",
    ]


def test_valid_hold_record_fields_and_status_enum_are_accepted() -> None:
    """Every D7 hold-record field with its documented type passes the shape check."""

    # Arrange
    statuses = ["held", "released", "integrated", "in_main"]
    entries = [
        dict(
            EDGE,
            status=status,
            reason="PREREQ_PR_NOT_FOUND",
            prerequisite_pr_number=41,
            prerequisite_merge_commit_sha="abc",
            verified_at="2026-11-10T00:00:00Z",
            integration_merge_commit_sha="def",
            integrated_at="2026-11-10T00:01:00Z",
        )
        for status in statuses
    ]

    # Act
    errors = validate_cross_epic_dependency_shape(
        {"features": [_feature(cross_epic_depends_on=entries)]}
    )

    # Assert
    assert errors == []


def test_status_outside_the_enum_is_rejected() -> None:
    """A status outside held, released, integrated, and in_main is malformed."""

    errors = validate_cross_epic_dependency_shape(
        {"features": [_feature(cross_epic_depends_on=[dict(EDGE, status="merged")])]}
    )

    assert errors == [
        MALFORMED_ENTRY + "status must be one of held, released, integrated, in_main."
    ]


def test_shape_check_ignores_a_non_list_features_value() -> None:
    """A checkpoint whose features value is not a list yields no shape error."""

    assert validate_cross_epic_dependency_shape({"features": {"a": 1}}) == []


def test_started_feature_with_held_entry_is_a_violation() -> None:
    """A started feature with a held cross-epic entry yields the exact violation."""

    # Arrange
    features = [
        _feature(
            merge_status="worktree_created",
            cross_epic_depends_on=[dict(EDGE, status="held")],
        )
    ]

    # Act
    errors = validate_cross_epic_started_while_held(features)

    # Assert
    assert errors == [
        "EPIC_CROSS_DEPENDENCY_VIOLATION: c-1201 is treated as started while "
        "cross-epic dependency provider-epic#1188 is not integrated"
    ]


@pytest.mark.parametrize("status", ["integrated", "in_main"])
def test_started_feature_with_integrated_entry_passes(status: str) -> None:
    """An integrated or in_main entry satisfies the started-while-held check."""

    features = [
        _feature(
            merge_status="merged", cross_epic_depends_on=[dict(EDGE, status=status)]
        )
    ]

    assert validate_cross_epic_started_while_held(features) == []


def test_started_while_held_skips_unstarted_and_non_object_entries() -> None:
    """Unstarted features, non-list values, and non-object entries add nothing."""

    features = [
        _feature(cross_epic_depends_on=[dict(EDGE, status="held")]),
        _feature(
            feature_folder="c-1202", merge_status="pr_open", cross_epic_depends_on="x"
        ),
        _feature(
            feature_folder="c-1203", merge_status="pr_open", cross_epic_depends_on=[5]
        ),
    ]

    assert validate_cross_epic_started_while_held(features) == []


@pytest.mark.parametrize(
    ("gate", "expected"),
    [
        (None, ["provider-epic"]),
        ({"status": "held", "prerequisites": [GATE_ENTRY]}, ["provider-epic"]),
        ({"status": "released", "prerequisites": []}, ["provider-epic"]),
        (
            {"status": "released", "prerequisites": [dict(GATE_ENTRY, verified_at="")]},
            ["provider-epic"],
        ),
        (
            {
                "status": "released",
                "prerequisites": [dict(GATE_ENTRY, merge_commit_sha=None)],
            },
            ["provider-epic"],
        ),
        ({"status": "released", "prerequisites": ["provider-epic"]}, ["provider-epic"]),
        ({"status": "released", "prerequisites": [GATE_ENTRY]}, []),
    ],
    ids=[
        "absent",
        "held",
        "no-entry",
        "empty-verified-at",
        "null-sha",
        "non-object-entry",
        "released",
    ],
)
def test_main_gate_completion_backstop(
    gate: dict[str, Any] | None, expected: list[str]
) -> None:
    """require_complete needs a released gate with a verified entry per epic."""

    # Arrange
    state: dict[str, Any] = {
        "features": [
            _feature(
                merge_status="merged",
                cross_epic_depends_on=[dict(EDGE, status="in_main")],
            )
        ]
    }
    if gate is not None:
        state["cross_epic_main_gate"] = gate

    # Act
    errors = _cross(
        validate_epic_orchestrator_state_text(json.dumps(state), require_complete=True)
    )

    # Assert
    prefix = (
        "EPIC_CROSS_DEPENDENCY_MAIN_GATE_INCOMPLETE: cross_epic_main_gate must be "
        "released with a verified entry for: "
    )
    assert errors == [prefix + ", ".join(expected)] if expected else errors == []


def test_main_gate_is_not_required_without_the_key() -> None:
    """A checkpoint without cross_epic_depends_on needs no cross_epic_main_gate."""

    assert validate_cross_epic_main_gate([_feature(merge_status="merged")], {}) == []


def test_main_gate_ignores_entries_without_a_valid_epic() -> None:
    """Entries without a valid epic slug impose no gate requirement."""

    features = [
        _feature(cross_epic_depends_on=[{"epic": "a/b"}, 3]),
        _feature(cross_epic_depends_on="x"),
    ]

    assert validate_cross_epic_main_gate(features, {}) == []


def test_plain_validation_does_not_require_the_main_gate() -> None:
    """Without require_complete an absent gate produces no cross-epic error."""

    state = {
        "features": [
            _feature(
                merge_status="merged",
                cross_epic_depends_on=[dict(EDGE, status="in_main")],
            )
        ]
    }

    assert _cross(validate_epic_orchestrator_state_text(json.dumps(state))) == []
