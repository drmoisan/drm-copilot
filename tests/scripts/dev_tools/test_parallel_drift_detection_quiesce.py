"""Tests for the derived quiesce predicate and its resolution disjuncts.

Split from `tests/scripts/dev_tools/test_parallel_drift_detection.py` to stay
inside the 500-line cap, following the pre-approved split convention of
`test_parallel_cohort_computation*.py`. This file covers
`unresolved_drift_item_keys` and `has_unresolved_drift`: both resolution
disjuncts, the latest-event rule with its append-order tie-break, per-item
independence, and every fail-closed mode. Conflict recomputation and the
end-to-end determinism check live in
`tests/scripts/dev_tools/test_parallel_drift_detection_conflicts.py`. Every
checkpoint here is an in-memory structure; no temporary file is used.
"""

from __future__ import annotations

from typing import TYPE_CHECKING

import pytest

from scripts.dev_tools.parallel_drift_detection import (
    DRIFT_ACTION_HALTED_LATER_STARTED_ITEM,
    ParallelDriftInputError,
    has_unresolved_drift,
    unresolved_drift_item_keys,
)
from tests.scripts.dev_tools.parallel_drift_test_support import event, item

if TYPE_CHECKING:
    from collections.abc import Mapping


def test_has_unresolved_drift_reports_no_drift_for_an_empty_event_log() -> None:
    """Treat a run with no drift as quiesce-free."""

    assert has_unresolved_drift([], [item(446, ["scripts/dev_tools/**"])]) is False
    assert unresolved_drift_item_keys([], []) == ()


def test_unresolved_drift_persists_while_the_radius_still_misses_the_escape() -> None:
    """Report drift while the recorded radius does not cover the escaped path."""

    events = [event(446, ["packages/mcp-server/src/index.ts"], "2026-08-08T10-00")]
    items = [item(446, ["scripts/dev_tools/**"])]

    assert unresolved_drift_item_keys(events, items) == (446,)
    assert has_unresolved_drift(events, items) is True


def test_drift_resolves_when_the_radius_widened_to_cover_every_escaped_path() -> None:
    """Clear drift under disjunct (a): the recorded radius now subsumes the escape."""

    events = [
        event(
            446,
            ["packages/mcp-server/src/index.ts", "packages/mcp-server/src/util.ts"],
            "2026-08-08T10-00",
        )
    ]
    items = [item(446, ["scripts/dev_tools/**", "packages/mcp-server/**"])]

    assert unresolved_drift_item_keys(events, items) == ()
    assert has_unresolved_drift(events, items) is False


def test_drift_stays_unresolved_when_only_some_escaped_paths_are_covered() -> None:
    """Require every escaped path to be covered before disjunct (a) clears."""

    events = [
        event(
            446,
            ["packages/mcp-server/src/index.ts", "extensions/drm-copilot/src/a.ts"],
            "2026-08-08T10-00",
        )
    ]
    items = [item(446, ["packages/mcp-server/**"])]

    assert unresolved_drift_item_keys(events, items) == (446,)


def test_drift_resolves_when_the_radius_was_re_recorded_from_a_later_diff() -> None:
    """Clear drift under disjunct (b): an observed radius computed after the event."""

    events = [event(446, ["packages/mcp-server/src/index.ts"], "2026-08-08T10-00")]
    items = [
        item(
            446,
            ["scripts/dev_tools/**"],
            source="observed",
            computed_at="2026-08-08T11-00",
        )
    ]

    assert unresolved_drift_item_keys(events, items) == ()
    assert has_unresolved_drift(events, items) is False


@pytest.mark.parametrize(
    ("source", "computed_at"),
    [
        # Observed but not strictly later than the event: the diff predates it.
        ("observed", "2026-08-08T10-00"),
        ("observed", "2026-08-08T09-00"),
        # Later, but not re-recorded from an observed diff.
        ("declared", "2026-08-08T11-00"),
        ("derived", "2026-08-08T11-00"),
    ],
)
def test_drift_stays_unresolved_when_disjunct_b_is_not_fully_satisfied(
    source: str, computed_at: str
) -> None:
    """Require both halves of disjunct (b): observed source and a later time."""

    events = [event(446, ["packages/mcp-server/src/index.ts"], "2026-08-08T10-00")]
    items = [
        item(446, ["scripts/dev_tools/**"], source=source, computed_at=computed_at)
    ]

    assert unresolved_drift_item_keys(events, items) == (446,)


def test_one_items_resolution_does_not_mask_another_items_drift() -> None:
    """Report each drifted item independently rather than as a single verdict."""

    events = [
        event(445, ["packages/mcp-server/src/index.ts"], "2026-08-08T10-00"),
        event(446, ["extensions/drm-copilot/src/a.ts"], "2026-08-08T10-05"),
    ]
    items = [
        item(445, ["packages/mcp-server/**"]),
        item(446, ["scripts/dev_tools/**"]),
    ]

    assert unresolved_drift_item_keys(events, items) == (446,)
    assert has_unresolved_drift(events, items) is True


def test_the_latest_event_by_timestamp_decides_an_items_verdict() -> None:
    """Evaluate only the greatest-`at` event for an item, not the earlier ones."""

    events = [
        event(446, ["extensions/drm-copilot/src/a.ts"], "2026-08-08T10-00"),
        event(446, ["packages/mcp-server/src/index.ts"], "2026-08-08T12-00"),
    ]
    items = [item(446, ["packages/mcp-server/**"])]

    assert unresolved_drift_item_keys(events, items) == ()


def test_an_out_of_order_event_does_not_displace_the_greatest_timestamp() -> None:
    """Ignore a later-appended record whose `at` is earlier than the current best.

    Append order breaks ties only; it never overrides a strictly greater `at`, so
    a log written out of order still resolves to the same latest event.
    """

    events = [
        event(446, ["packages/mcp-server/src/index.ts"], "2026-08-08T12-00"),
        event(446, ["extensions/drm-copilot/src/a.ts"], "2026-08-08T10-00"),
        event(445, ["docs/a.md"], "2026-08-08T11-00"),
    ]
    items = [
        item(446, ["packages/mcp-server/**"]),
        item(445, ["docs/**"]),
    ]

    assert unresolved_drift_item_keys(events, items) == ()


def test_append_order_breaks_a_timestamp_tie_between_two_events() -> None:
    """Prefer the later-appended record when two events share an `at`."""

    events = [
        event(446, ["packages/mcp-server/src/index.ts"], "2026-08-08T10-00"),
        event(446, ["extensions/drm-copilot/src/a.ts"], "2026-08-08T10-00"),
    ]
    items = [item(446, ["packages/mcp-server/**"])]

    assert unresolved_drift_item_keys(events, items) == (446,)


@pytest.mark.parametrize(
    "items",
    [
        # No item record at all for the drifted key.
        [],
        # The key exists but carries no readable radius block.
        [{"issue_num": 446, "state": "in_flight", "blast_radius": None}],
        # The radius exists but its paths are malformed and its source is not
        # observed, so neither disjunct can be evaluated.
        [
            {
                "issue_num": 446,
                "state": "in_flight",
                "blast_radius": {
                    "paths": "packages/mcp-server/**",
                    "modules": [],
                    "shared_surfaces": [],
                    "contracts": [],
                    "source": "declared",
                    "computed_at": "2026-08-08T11-00",
                },
            }
        ],
        # The radius is observed and later, but its `computed_at` is blank, so
        # disjunct (b) cannot be evaluated either.
        [
            {
                "issue_num": 446,
                "state": "in_flight",
                "blast_radius": {
                    "paths": ["scripts/dev_tools/**"],
                    "modules": [],
                    "shared_surfaces": [],
                    "contracts": [],
                    "source": "observed",
                    "computed_at": "",
                },
            }
        ],
        # The item key itself is unreadable, so no radius can be matched to it.
        [{"issue_num": None, "blast_radius": {"paths": ["packages/mcp-server/**"]}}],
    ],
)
def test_an_unresolvable_item_radius_keeps_the_drift_unresolved(
    items: list[Mapping[str, object]],
) -> None:
    """Fail closed: no resolvable radius means the drift gate keeps denying."""

    events = [event(446, ["packages/mcp-server/src/index.ts"], "2026-08-08T10-00")]

    assert unresolved_drift_item_keys(events, items) == (446,)
    assert has_unresolved_drift(events, items) is True


@pytest.mark.parametrize(
    "malformed",
    [
        {"item_key": 0, "at": "2026-08-08T10-00", "escaped_paths": ["a.py"]},
        {"item_key": True, "at": "2026-08-08T10-00", "escaped_paths": ["a.py"]},
        {"item_key": 446, "at": "", "escaped_paths": ["a.py"]},
        {"item_key": 446, "at": "2026-08-08T10-00", "escaped_paths": []},
        {"item_key": 446, "at": "2026-08-08T10-00", "escaped_paths": "a.py"},
        {"item_key": 446, "at": "2026-08-08T10-00", "escaped_paths": ["  "]},
    ],
)
def test_a_malformed_event_is_rejected_but_still_reports_drift(
    malformed: Mapping[str, object],
) -> None:
    """Raise from the strict reader while the predicate fails closed to `True`."""

    items = [item(446, ["packages/mcp-server/**"])]

    with pytest.raises(ParallelDriftInputError):
        unresolved_drift_item_keys([malformed], items)
    assert has_unresolved_drift([malformed], items) is True


def test_a_halted_occurrence_records_one_event_with_the_strongest_action() -> None:
    """Encode the A8 rule: the halting action subsumes the finding action.

    The recording rule allows one event per occurrence, so a halted occurrence is
    represented by a single record carrying `halted_later_started_item`, and that
    record drives the unresolved verdict on its own.
    """

    events = [
        event(
            446,
            ["packages/mcp-server/src/index.ts"],
            "2026-08-08T10-00",
            action=DRIFT_ACTION_HALTED_LATER_STARTED_ITEM,
        )
    ]
    items = [item(446, ["scripts/dev_tools/**"])]

    assert len(events) == 1
    assert events[0]["action"] == DRIFT_ACTION_HALTED_LATER_STARTED_ITEM
    assert unresolved_drift_item_keys(events, items) == (446,)
