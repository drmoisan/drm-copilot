"""Tests for drift recomputation through the integration-cost scheduling rule.

Covers ``scripts/dev_tools/_parallel_drift_scheduling.py`` (issue #722): the
relocated existing-edge collector, the band reader, and the observed-pair edge
decision that routes each in-flight peer through the scheduling rule. The end
to end cases call ``recompute_conflicts_with_observed`` with the real relation,
so a tolerated pair that stays within tolerance is not reported, while a pair
that becomes hard or exceeds tolerance is. At tolerance 0 the output equals the
conflict-only output.

The helper names are imported from the helper module itself, so a missing
module surfaces as a collection error naming it. Every checkpoint here is an
in-memory structure; no temporary file is used.
"""

from __future__ import annotations

from typing import TYPE_CHECKING, cast

from scripts.dev_tools._blast_radius_conflicts import ConflictResult, conflicts
from scripts.dev_tools._parallel_drift_scheduling import (
    existing_edge_pairs,
    item_band,
    observed_pair_is_edge,
)
from scripts.dev_tools.compute_blast_radius import (
    BlastRadius,
    radius_from_observed_paths,
)
from scripts.dev_tools.parallel_drift_detection import (
    recompute_conflicts_with_observed,
)
from tests.scripts.dev_tools.parallel_drift_test_support import CONFIG, item

if TYPE_CHECKING:
    from collections.abc import Mapping, Sequence

COMPUTED_AT = "2026-09-27T10-00"
DRIFTING = 446
SHARED_SURFACE = ".claude/settings.json"


def tolerant_config(
    tolerance_percent: int, *, default_band: str = "C1"
) -> dict[str, object]:
    """Return the drift truth table with a committed-weight tolerance member."""
    return {
        **CONFIG,
        "conflict_tolerance": {
            "tolerance_percent": tolerance_percent,
            "weights": {
                "same_file": 8,
                "possible_overlap": 2,
                "append_only": 1,
                "module": 2,
            },
            "band_durations": {"C1": 1, "C2": 2, "C3": 4, "C4": 8},
            "default_band": default_band,
            "append_only_paths": ["**/CHANGELOG.md"],
        },
    }


def banded(
    issue_num: int, paths: Sequence[str], band: object = None
) -> dict[str, object]:
    """Build an in-flight item record, adding complexity_band when given."""
    record = item(issue_num, paths)
    if band is not None:
        record["complexity_band"] = band
    return record


def observed(paths: Sequence[str], config: Mapping[str, object]) -> BlastRadius:
    """Build the observed radius the drift module builds for ``paths``."""
    return radius_from_observed_paths(paths, config, computed_at=COMPUTED_AT)


def peer_radius(record: Mapping[str, object]) -> BlastRadius:
    """Rebuild a peer's declared radius from its checkpoint record."""
    return BlastRadius.from_dict(cast("Mapping[str, object]", record["blast_radius"]))


def recompute(
    items: Sequence[Mapping[str, object]],
    observed_paths: Sequence[str],
    config: Mapping[str, object],
) -> tuple[tuple[int, int], ...]:
    """Run drift recomputation for the drifting item with no recorded edges."""
    return recompute_conflicts_with_observed(
        items, DRIFTING, observed_paths, [], config, computed_at=COMPUTED_AT
    )


def test_tolerated_pair_within_tolerance_is_not_reported() -> None:
    """An append-only overlap within the committed tolerance does not halt."""
    peer = banded(445, ["CHANGELOG.md"], "C4")
    items = [banded(DRIFTING, ["docs/notes.md"], "C4"), peer]

    pairs = recompute(items, ["CHANGELOG.md"], tolerant_config(100))

    detected = conflicts(observed(["CHANGELOG.md"], CONFIG), peer_radius(peer), CONFIG)
    assert detected.conflict, "the pair must still be a detected conflict"
    assert pairs == ()


def test_tolerated_pair_that_becomes_hard_is_reported() -> None:
    """A tolerated pair whose observed diff reaches a shared surface is reported."""
    peer = banded(445, ["CHANGELOG.md", SHARED_SURFACE], "C4")
    cast("dict[str, object]", peer["blast_radius"])["shared_surfaces"] = [
        SHARED_SURFACE
    ]
    items = [banded(DRIFTING, ["CHANGELOG.md"], "C4"), peer]

    within = recompute(items, ["CHANGELOG.md"], tolerant_config(1_000_000))
    hard = recompute(
        items, ["CHANGELOG.md", SHARED_SURFACE], tolerant_config(1_000_000)
    )

    assert within == ()
    assert hard == ((445, DRIFTING),)


def test_tolerated_pair_exceeding_tolerance_is_reported() -> None:
    """An observed same-file overlap that outweighs the benefit is reported."""
    peer = banded(445, ["CHANGELOG.md", "src/app.py"], "C1")
    items = [banded(DRIFTING, ["CHANGELOG.md"], "C1"), peer]

    within = recompute(items, ["CHANGELOG.md"], tolerant_config(100))
    exceeding = recompute(items, ["CHANGELOG.md", "src/app.py"], tolerant_config(100))

    assert within == ()
    assert exceeding == ((445, DRIFTING),)


def test_tolerance_zero_output_equals_conflict_only_output() -> None:
    """At tolerance 0, and with the key absent, output equals conflicts alone."""
    items = [
        banded(DRIFTING, ["docs/notes.md"], "C4"),
        banded(445, ["CHANGELOG.md"], "C4"),
        banded(447, ["docs/guide.md"]),
        banded(448, ["src/app.py"], "C2"),
    ]
    observed_paths = ["CHANGELOG.md", "src/app.py"]
    radius = observed(observed_paths, CONFIG)

    # The conflict-only reference: every in-flight peer the relation flags.
    reference = tuple(
        sorted(
            (min(key, DRIFTING), max(key, DRIFTING))
            for key, record in ((445, items[1]), (447, items[2]), (448, items[3]))
            if conflicts(radius, peer_radius(record), CONFIG).conflict
        )
    )

    assert reference == ((445, DRIFTING), (DRIFTING, 448))
    assert recompute(items, observed_paths, tolerant_config(0)) == reference
    assert recompute(items, observed_paths, CONFIG) == reference


def test_unevaluable_peer_radius_counts_as_edge() -> None:
    """A peer radius that cannot be rebuilt is an edge; the relation is not called."""
    calls: list[str] = []

    def _relation(
        a: BlastRadius, b: BlastRadius, config: Mapping[str, object]
    ) -> ConflictResult:
        calls.append("called")
        return ConflictResult(conflict=False, reasons=())

    radius = observed(["src/app.py"], CONFIG)

    # A partial radius mapping, a non-mapping value, and an absent radius.
    for raw in ({"paths": ["src/app.py"]}, "src/app.py", None):
        verdict = observed_pair_is_edge(radius, raw, CONFIG, relation=_relation)

        assert verdict, f"unevaluable peer radius {raw!r} must count as an edge"
    assert calls == []


def test_existing_edge_pairs_normalize_order() -> None:
    """Recorded edges are collected as canonical pairs; unreadable ones are skipped."""
    edges: list[Mapping[str, object]] = [
        {"a": 446, "b": 445, "reason": "path_overlap"},
        {"a": 445, "b": 447, "reason": "module_overlap"},
        {"a": 445, "b": None},
        {"a": 448, "b": 448},
        {"a": "445", "b": 449},
    ]

    pairs = existing_edge_pairs(edges)

    assert pairs == frozenset({(445, 446), (445, 447)})


def test_missing_band_uses_default_band() -> None:
    """An absent or unreadable band reads as default_band in the decision."""
    items = [
        banded(DRIFTING, ["src/app.py"]),
        banded(445, ["src/app.py"], "C1"),
        banded(447, ["src/app.py"], 3),
        banded(448, ["src/app.py"], "C9"),
    ]
    radius = observed(["src/app.py"], CONFIG)
    config = tolerant_config(100, default_band="C4")

    # Same-file cost 8 against default_band C4 (8): 800 > 800 is false.
    defaulted = observed_pair_is_edge(
        radius,
        items[0]["blast_radius"],
        config,
        observed_band=item_band(items, DRIFTING),
        peer_band=item_band(items, 447),
    )
    # With the peer's explicit C1 band the benefit is 1: 800 > 100 is true.
    explicit = observed_pair_is_edge(
        radius,
        items[1]["blast_radius"],
        config,
        observed_band=item_band(items, DRIFTING),
        peer_band=item_band(items, 445),
    )

    assert [item_band(items, key) for key in (DRIFTING, 445, 447, 448, 999)] == [
        None,
        "C1",
        None,
        None,
        None,
    ]
    assert not defaulted
    assert explicit


def test_observed_decision_uses_the_injected_relation() -> None:
    """The injected relation is called once, with the observed radius first."""
    captured: list[tuple[BlastRadius, BlastRadius]] = []

    def _relation(
        a: BlastRadius, b: BlastRadius, config: Mapping[str, object]
    ) -> ConflictResult:
        captured.append((a, b))
        return ConflictResult(conflict=False, reasons=())

    radius = observed(["src/app.py"], CONFIG)
    peer = banded(445, ["src/app.py"])

    verdict = observed_pair_is_edge(
        radius, peer["blast_radius"], CONFIG, relation=_relation
    )

    assert verdict is False, "the injected relation's verdict must be used"
    assert len(captured) == 1
    assert captured[0][0] is radius
    assert captured[0][1] == peer_radius(peer)
