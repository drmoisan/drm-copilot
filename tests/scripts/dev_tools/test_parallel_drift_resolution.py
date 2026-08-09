"""Tests binding the drift-resolution producer to the drift-resolution derivation.

These are loop-closing seam tests, not per-side assertions. Each one drives the
whole release path of the Layer-2 drift gate: it constructs a checkpoint whose item
has an unresolved latest drift event, applies one of the two documented resolving
writes, and asserts that `unresolved_drift_item_keys` stops reporting the item. The
before-and-after transition is asserted in the same test, so a producer that emits a
value the derivation does not accept fails here rather than passing two independent
per-side checks.

Every checkpoint is in memory, every timestamp is an explicit argument, and no file
is read or written, so no temporary file and no subprocess is used.
"""

from __future__ import annotations

from typing import TYPE_CHECKING, cast

from scripts.dev_tools.compute_blast_radius import radius_from_observed_paths
from scripts.dev_tools.parallel_drift_detection import unresolved_drift_item_keys
from scripts.dev_tools.parallel_drift_detection_cli import evaluate_drift
from scripts.dev_tools.parallel_drift_resolution import request_resolution_write
from tests.scripts.dev_tools.parallel_drift_test_support import (
    CONFIG,
    event,
    in_flight,
    radius,
)

if TYPE_CHECKING:
    from collections.abc import Mapping

# The drifting item and the path its diff pushed outside the declared radius.
ITEM_KEY = 446
DECLARED_PATHS = ["docs/**"]
ESCAPED_PATH = "scripts/dev_tools/escape.py"

# A second out-of-radius path, used by the disjunct-(b) loop closure. The recorded
# event names `ESCAPED_PATH`; the later observed diff names this one instead, which
# is what remediation looks like when it removes the original out-of-radius change.
# Because the emitted radius's `paths` then do not cover `ESCAPED_PATH`, disjunct (a)
# cannot fire and only the re-recorded-radius disjunct can resolve the event.
LATER_ESCAPED_PATH = "packages/mcp-server/src/index.ts"

# The event's own instant, and the strictly later instant the resolving radius
# carries. Resolution disjunct (b) requires `computed_at > at` strictly, and the
# command line defaults `computed_at` to `at`, so the later value must be passed
# explicitly rather than left to the default.
EVENT_AT = "2026-08-08T10-00"
RESOLVED_AT = "2026-08-08T11-00"


def _drifted_state() -> tuple[list[dict[str, object]], list[dict[str, object]]]:
    """Build the items and events of a checkpoint carrying one unresolved drift.

    Returns:
        tuple[list[dict[str, object]], list[dict[str, object]]]: The `items[]`
        records and the `drift_events[]` records. The single item's declared radius
        does not cover `ESCAPED_PATH`, and its `blast_radius.source` is `declared`,
        so neither resolution disjunct holds and the item starts unresolved.
    """
    items = [in_flight(ITEM_KEY, DECLARED_PATHS, "2026-08-08T09-00")]
    events = [event(ITEM_KEY, [ESCAPED_PATH], EVENT_AT)]
    return items, events


def test_applying_the_emitted_observed_radius_resolves_the_recorded_drift() -> None:
    """Close the resolution loop through the command line's emitted radius.

    The radius is taken from a later detecting invocation whose observed diff no
    longer carries the recorded event's escaped path, so the emitted `paths` do not
    subsume it and disjunct (a) cannot account for the transition. The only thing
    that can is disjunct (b): `source == 'observed'` with a `computed_at` strictly
    later than the event's `at`. That isolates the emitted value as the producer.
    """

    # Arrange: an item whose latest drift event no recorded radius resolves.
    items, events = _drifted_state()
    assert ITEM_KEY in unresolved_drift_item_keys(events, items)

    # Act: take the radius the command line emits for the later still-escaping
    # diff, with a `computed_at` strictly later than the event's `at`, and write it
    # verbatim onto the item, which is the write step 7 assigns to the parent.
    payload = evaluate_drift(
        state={"items": items, "conflict_edges": []},
        config=CONFIG,
        item_key=ITEM_KEY,
        changed_paths=[LATER_ESCAPED_PATH],
        at=EVENT_AT,
        computed_at=RESOLVED_AT,
    )
    emitted = cast("Mapping[str, object]", payload["observed_radius"])
    assert payload["observed_radius"] is not None
    assert emitted["source"] == "observed"
    assert cast("str", emitted["computed_at"]) > EVENT_AT

    # Control: disjunct (a) is provably inapplicable, because the emitted radius
    # does not carry the path the recorded event says escaped.
    assert ESCAPED_PATH not in cast("list[str]", emitted["paths"])

    resolved_items = [dict(items[0])]
    resolved_items[0]["blast_radius"] = emitted

    # Assert: the same derivation that reported the item now reports nothing.
    assert unresolved_drift_item_keys(events, resolved_items) == ()


def test_widening_the_declared_radius_resolves_the_recorded_drift() -> None:
    """Close the resolution loop through the radius-widening disjunct."""

    # Arrange: the same unresolved starting state.
    items, events = _drifted_state()
    assert ITEM_KEY in unresolved_drift_item_keys(events, items)

    # Act: extend the recorded radius to cover every escaped path, leaving
    # `source` at `declared` so only disjunct (a) can account for the change.
    widened_items = [dict(items[0])]
    widened_items[0]["blast_radius"] = radius([*DECLARED_PATHS, ESCAPED_PATH])
    assert (
        cast("Mapping[str, object]", widened_items[0]["blast_radius"])["source"]
        == "declared"
    )

    # Assert: the derivation stops reporting the item.
    assert unresolved_drift_item_keys(events, widened_items) == ()


def test_request_resolution_write_serializes_the_library_radius_unchanged() -> None:
    """Pin the seam's radius to a direct library call over the same inputs."""

    observed = [ESCAPED_PATH, "packages/mcp-server/src/index.ts"]

    request = request_resolution_write(
        item_key=ITEM_KEY,
        observed_paths=observed,
        config=CONFIG,
        computed_at=RESOLVED_AT,
    )
    expected = radius_from_observed_paths(
        observed, CONFIG, computed_at=RESOLVED_AT
    ).to_dict()

    assert request.item_key == ITEM_KEY
    assert request.blast_radius == expected
