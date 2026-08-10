"""Tests for escape detection and drift-event construction.

This file covers `detect_escaped_paths` (the no-escape, single-escape,
multiple-escape, and glob-boundary matrix, including rename handling) and
`build_drift_event` (record shape, action-enum acceptance and rejection, and the
malformed-input modes). The quiesce derivation, conflict recomputation, and the
full-path determinism check live in the split file
`tests/scripts/dev_tools/test_parallel_drift_detection_state.py`; halt selection
and the requeue seam live in
`tests/scripts/dev_tools/test_parallel_drift_halt.py`. All three files stay
inside the 500-line cap, following the pre-approved split convention of
`test_parallel_cohort_computation*.py`.
"""

from __future__ import annotations

from itertools import chain, combinations

import pytest

from scripts.dev_tools._blast_radius_glob import is_path_subsumed
from scripts.dev_tools._parallel_state_common import VALID_DRIFT_ACTIONS
from scripts.dev_tools.parallel_drift_detection import (
    DRIFT_ACTION_HALTED_LATER_STARTED_ITEM,
    DRIFT_ACTION_RAISED_BLOCKING_FINDING,
    DRIFT_EVENT_KEYS,
    ParallelDriftInputError,
    build_drift_event,
    detect_escaped_paths,
    has_unresolved_drift,
    recompute_conflicts_with_observed,
    request_requeue_via_recolor,
    select_halted_item,
    unresolved_drift_item_keys,
)

# Path vocabulary the exhaustive property matrix draws from: concrete files, a
# listed directory, and globs at both a file and a directory boundary.
PROPERTY_PATHS: tuple[str, ...] = (
    "scripts/dev_tools/parallel_drift_detection.py",
    "scripts/dev_tools/nested/helper.py",
    "tests/scripts/dev_tools/test_parallel_drift_detection.py",
    "docs/features/active/feature/spec.md",
    ".claude/settings.json",
)
PROPERTY_DECLARED: tuple[str, ...] = (
    "scripts/dev_tools/parallel_drift_detection.py",
    "scripts/dev_tools",
    "tests/scripts/dev_tools/*.py",
    "docs/features/active/feature/**",
)


def _power_set(vocabulary: tuple[str, ...]) -> list[list[str]]:
    """Return every subset of a vocabulary, shortest first, as lists.

    Args:
        vocabulary (tuple[str, ...]): The literal entries to combine.

    Returns:
        list[list[str]]: All 2**n subsets, including the empty one, so the
        property matrix below is exhaustive rather than sampled.
    """

    sizes = range(len(vocabulary) + 1)
    return [
        list(subset)
        for subset in chain.from_iterable(
            combinations(vocabulary, size) for size in sizes
        )
    ]


def test_module_public_surface_is_importable() -> None:
    """Expose the whole drift surface, including the re-exported halt symbols."""

    assert callable(detect_escaped_paths)
    assert callable(build_drift_event)
    assert callable(has_unresolved_drift)
    assert callable(unresolved_drift_item_keys)
    assert callable(recompute_conflicts_with_observed)
    assert callable(select_halted_item)
    assert callable(request_requeue_via_recolor)
    assert issubclass(ParallelDriftInputError, ValueError)


def test_drift_event_key_set_matches_the_section_12_shape() -> None:
    """Pin the six field names so a schema drift is caught at the producer."""

    assert DRIFT_EVENT_KEYS == (
        "item_key",
        "declared",
        "observed",
        "escaped_paths",
        "at",
        "action",
    )


def test_action_constants_are_members_of_the_f3_owned_enum() -> None:
    """Bind the emitted action strings to F3's two-member vocabulary.

    The enum has exactly two members and no `resolved` value; resolution is
    derived from the item radius rather than recorded as an action.
    """

    assert DRIFT_ACTION_RAISED_BLOCKING_FINDING in VALID_DRIFT_ACTIONS
    assert DRIFT_ACTION_HALTED_LATER_STARTED_ITEM in VALID_DRIFT_ACTIONS
    assert len(VALID_DRIFT_ACTIONS) == 2
    assert "resolved" not in VALID_DRIFT_ACTIONS


@pytest.mark.parametrize(
    ("changed", "declared"),
    [
        # Exact match, the first coverage rule.
        (["scripts/dev_tools/a.py"], ["scripts/dev_tools/a.py"]),
        # Listed directory covering everything beneath it.
        (["scripts/dev_tools/a.py"], ["scripts/dev_tools"]),
        # Listed directory written with a trailing separator.
        (["scripts/dev_tools/a.py"], ["scripts/dev_tools/"]),
        # Recursive glob.
        (["scripts/dev_tools/nested/a.py"], ["scripts/dev_tools/**"]),
        # Single-segment glob at the file boundary.
        (["scripts/dev_tools/a.py"], ["scripts/dev_tools/*.py"]),
        # Two changed paths covered by two different declared entries.
        (
            ["scripts/dev_tools/a.py", "docs/features/active/f/spec.md"],
            ["scripts/dev_tools/*.py", "docs/features/active/f/**"],
        ),
        # An empty diff cannot escape anything.
        ([], ["scripts/dev_tools/**"]),
    ],
)
def test_detect_escaped_paths_reports_no_escape_when_every_path_is_covered(
    changed: list[str], declared: list[str]
) -> None:
    """Return an empty tuple whenever the declared radius covers the diff."""

    escaped = detect_escaped_paths(changed, declared)

    assert escaped == ()


def test_detect_escaped_paths_reports_a_single_escape() -> None:
    """Report the one changed path the declared radius does not cover."""

    changed = ["scripts/dev_tools/a.py", "packages/mcp-server/src/index.ts"]
    declared = ["scripts/dev_tools/**"]

    escaped = detect_escaped_paths(changed, declared)

    assert escaped == ("packages/mcp-server/src/index.ts",)


def test_detect_escaped_paths_reports_multiple_escapes_sorted_and_deduplicated() -> (
    None
):
    """Report every uncovered path once, ordinally sorted for determinism."""

    changed = [
        "packages/mcp-server/src/index.ts",
        "scripts/dev_tools/a.py",
        ".claude/settings.json",
        "packages/mcp-server/src/index.ts",
    ]
    declared = ["scripts/dev_tools/**"]

    escaped = detect_escaped_paths(changed, declared)

    assert escaped == (".claude/settings.json", "packages/mcp-server/src/index.ts")


def test_detect_escaped_paths_treats_an_empty_declared_radius_as_covering_nothing() -> (
    None
):
    """Report every changed path when the declared radius is empty."""

    escaped = detect_escaped_paths(["a.py", "b.py"], [])

    assert escaped == ("a.py", "b.py")


@pytest.mark.parametrize(
    ("changed", "declared", "expected"),
    [
        # A single-segment glob stops at the separator, so a nested path escapes.
        (
            ["scripts/dev_tools/nested/a.py"],
            ["scripts/dev_tools/*.py"],
            ("scripts/dev_tools/nested/a.py",),
        ),
        # A glob bound to one extension does not cover a sibling extension.
        (
            ["scripts/dev_tools/a.ps1"],
            ["scripts/dev_tools/*.py"],
            ("scripts/dev_tools/a.ps1",),
        ),
        # A listed directory must match on a separator boundary, so a
        # same-prefixed sibling directory is not covered.
        (
            ["scripts/dev_tools_extra/a.py"],
            ["scripts/dev_tools"],
            ("scripts/dev_tools_extra/a.py",),
        ),
        # A listed directory does not cover the identically named file entry's
        # parent, so a path one level above the directory escapes.
        (
            ["scripts/a.py"],
            ["scripts/dev_tools"],
            ("scripts/a.py",),
        ),
        # The single-character wildcard matches exactly one character.
        (
            ["scripts/dev_tools/ab.py"],
            ["scripts/dev_tools/?.py"],
            ("scripts/dev_tools/ab.py",),
        ),
    ],
)
def test_detect_escaped_paths_glob_boundary_cases(
    changed: list[str], declared: list[str], expected: tuple[str, ...]
) -> None:
    """Reject near-miss glob and separator cases rather than over-covering."""

    escaped = detect_escaped_paths(changed, declared)

    assert escaped == expected


def test_detect_escaped_paths_requires_both_rename_paths_to_be_covered() -> None:
    """Report the new path of a rename when only the old path is covered.

    A rename appears in a diff as two entries. Covering one of them is not
    coverage of the rename, so the uncovered side is reported: the fail-closed
    direction the spec requires.
    """

    changed = ["scripts/dev_tools/old_name.py", "scripts/renamed/new_name.py"]
    declared = ["scripts/dev_tools/**"]

    escaped = detect_escaped_paths(changed, declared)

    assert escaped == ("scripts/renamed/new_name.py",)


def test_detect_escaped_paths_reports_both_rename_paths_when_neither_is_covered() -> (
    None
):
    """Report both sides of a rename that leaves the declared radius entirely."""

    changed = ["packages/a/old.ts", "packages/a/new.ts"]
    declared = ["scripts/dev_tools/**"]

    escaped = detect_escaped_paths(changed, declared)

    assert escaped == ("packages/a/new.ts", "packages/a/old.ts")


@pytest.mark.parametrize(
    ("changed", "declared"),
    [
        ("scripts/dev_tools/a.py", ["scripts/**"]),
        (["scripts/dev_tools/a.py"], "scripts/**"),
    ],
)
def test_detect_escaped_paths_rejects_a_bare_string_argument(
    changed: object, declared: object
) -> None:
    """Reject a bare string rather than iterating it character by character."""

    with pytest.raises(ParallelDriftInputError, match="not a single string"):
        detect_escaped_paths(
            changed,  # pyright: ignore[reportArgumentType] - malformed-input test
            declared,  # pyright: ignore[reportArgumentType] - malformed-input test
        )


@pytest.mark.parametrize("entry", ["", "   ", None, 5])
def test_detect_escaped_paths_rejects_a_blank_or_non_string_entry(
    entry: object,
) -> None:
    """Reject a blank or non-string entry instead of silently dropping it."""

    with pytest.raises(ParallelDriftInputError, match="non-empty strings"):
        detect_escaped_paths(
            ["scripts/a.py", entry],  # pyright: ignore[reportArgumentType]
            ["scripts/**"],
        )


def test_detect_escaped_paths_returns_only_members_of_the_changed_input() -> None:
    """Assert the containment property exhaustively over the subset matrix.

    Property: every reported escape is a member of `changed`, the result carries
    no duplicate, and no covered path is reported. The matrix is the full power
    set of both vocabularies rather than a random sample, so the check is
    exhaustive and needs no seed to be reproducible.
    """

    # Cross every subset of the changed vocabulary with every subset of the
    # declared vocabulary, including both empty subsets.
    for changed in _power_set(PROPERTY_PATHS):
        for declared in _power_set(PROPERTY_DECLARED):
            escaped = detect_escaped_paths(changed, declared)

            context = f"changed={changed} declared={declared}"
            assert set(escaped) <= set(changed), context
            assert len(set(escaped)) == len(escaped), context
            assert all(
                not is_path_subsumed(path, declared) for path in escaped
            ), context


def test_build_drift_event_produces_exactly_the_section_12_shape() -> None:
    """Produce the six documented fields with sorted, deduplicated collections."""

    event = build_drift_event(
        item_key=446,
        declared=["scripts/dev_tools/**", "scripts/dev_tools/**"],
        observed=["scripts/b.py", "scripts/a.py"],
        escaped_paths=["scripts/b.py", "scripts/a.py"],
        at="2026-08-08T21-19",
        action=DRIFT_ACTION_RAISED_BLOCKING_FINDING,
    )

    assert tuple(event) == DRIFT_EVENT_KEYS
    assert event == {
        "item_key": 446,
        "declared": ["scripts/dev_tools/**"],
        "observed": ["scripts/a.py", "scripts/b.py"],
        "escaped_paths": ["scripts/a.py", "scripts/b.py"],
        "at": "2026-08-08T21-19",
        "action": DRIFT_ACTION_RAISED_BLOCKING_FINDING,
    }


def test_build_drift_event_accepts_empty_declared_and_observed_collections() -> None:
    """Accept empty compared sets, which F3's invariant 18 permits."""

    event = build_drift_event(
        item_key=446,
        declared=[],
        observed=[],
        escaped_paths=["scripts/a.py"],
        at="2026-08-08T21-19",
        action=DRIFT_ACTION_HALTED_LATER_STARTED_ITEM,
    )

    assert event["declared"] == []
    assert event["observed"] == []


@pytest.mark.parametrize("action", VALID_DRIFT_ACTIONS)
def test_build_drift_event_accepts_every_member_of_the_action_enum(
    action: str,
) -> None:
    """Accept each F3-defined action without translation."""

    event = build_drift_event(
        item_key=446,
        declared=["scripts/**"],
        observed=["scripts/a.py"],
        escaped_paths=["scripts/a.py"],
        at="2026-08-08T21-19",
        action=action,
    )

    assert event["action"] == action


@pytest.mark.parametrize("action", ["resolved", "halted_later_started", "", "Resolved"])
def test_build_drift_event_rejects_an_out_of_enum_action(action: str) -> None:
    """Reject any action outside F3's two-member vocabulary, including `resolved`."""

    with pytest.raises(ParallelDriftInputError, match="action must be one of"):
        build_drift_event(
            item_key=446,
            declared=["scripts/**"],
            observed=["scripts/a.py"],
            escaped_paths=["scripts/a.py"],
            at="2026-08-08T21-19",
            action=action,
        )


def test_build_drift_event_rejects_an_empty_escaped_path_list() -> None:
    """Reject a zero-escape record, which is not a drift event at all."""

    with pytest.raises(
        ParallelDriftInputError, match="escaped_paths must not be empty"
    ):
        build_drift_event(
            item_key=446,
            declared=["scripts/**"],
            observed=["scripts/a.py"],
            escaped_paths=[],
            at="2026-08-08T21-19",
            action=DRIFT_ACTION_RAISED_BLOCKING_FINDING,
        )


@pytest.mark.parametrize("item_key", [0, -1, True, "446", None, 4.0])
def test_build_drift_event_rejects_a_malformed_item_key(item_key: object) -> None:
    """Reject a non-positive, boolean, or non-integer primary key."""

    with pytest.raises(ParallelDriftInputError, match="positive integer issue_num"):
        build_drift_event(
            item_key=item_key,  # pyright: ignore[reportArgumentType]
            declared=["scripts/**"],
            observed=["scripts/a.py"],
            escaped_paths=["scripts/a.py"],
            at="2026-08-08T21-19",
            action=DRIFT_ACTION_RAISED_BLOCKING_FINDING,
        )


@pytest.mark.parametrize("at", ["", "   ", None, 20260808])
def test_build_drift_event_rejects_a_blank_or_non_string_timestamp(at: object) -> None:
    """Reject a timestamp that carries no value; `at` is a required input."""

    with pytest.raises(ParallelDriftInputError, match="at must be a non-empty string"):
        build_drift_event(
            item_key=446,
            declared=["scripts/**"],
            observed=["scripts/a.py"],
            escaped_paths=["scripts/a.py"],
            at=at,  # pyright: ignore[reportArgumentType]
            action=DRIFT_ACTION_RAISED_BLOCKING_FINDING,
        )


def test_build_drift_event_returns_a_new_mapping_on_each_call() -> None:
    """Return an independent record so an appended event cannot alias another."""

    first = build_drift_event(
        item_key=446,
        declared=["scripts/**"],
        observed=["scripts/a.py"],
        escaped_paths=["scripts/a.py"],
        at="2026-08-08T21-19",
        action=DRIFT_ACTION_RAISED_BLOCKING_FINDING,
    )
    second = build_drift_event(
        item_key=446,
        declared=["scripts/**"],
        observed=["scripts/a.py"],
        escaped_paths=["scripts/a.py"],
        at="2026-08-08T21-19",
        action=DRIFT_ACTION_RAISED_BLOCKING_FINDING,
    )

    assert first == second
    assert first is not second
