"""Scheduling-aware peer evaluation for parallel drift recomputation (issue #722).

Purpose:
    Hold the two per-peer helpers of ``recompute_conflicts_with_observed`` that
    were relocated out of ``parallel_drift_detection`` so that module does not
    grow: the collector of already-recorded edge pairs, and the decision whether
    an in-flight peer newly contends with a drifting item's observed radius.

Responsibilities:
    The observed-pair decision routes the pair through the integration-cost
    scheduling rule (``decide_pair`` of ``_blast_radius_scheduling``) with both
    items' complexity bands, so a tolerated pair whose observed overlap stays
    within tolerance does not halt either item, while a pair that becomes hard
    or exceeds tolerance is reported. At tolerance 0 (or with the
    conflict_tolerance key absent) the decision equals the relation's verdict,
    so drift output is unchanged from the conflict-only behaviour.

Boundaries:
    The contention relation is injected by the caller as a keyword argument and
    is forwarded to the pair decision with the observed radius first, so the
    drift module's own patchable reference to the relation still governs the
    decision. ``conflict_edges[]`` is read only.

Side effects:
    None. Every function is pure: no filesystem, subprocess, network, or
    wall-clock access, and no argument is mutated.
"""

from __future__ import annotations

from collections.abc import Mapping
from typing import TYPE_CHECKING, cast

from scripts.dev_tools._blast_radius_conflicts import conflicts
from scripts.dev_tools._blast_radius_scheduling import BAND_NAMES, decide_pair
from scripts.dev_tools._parallel_drift_shape import as_item_key, canonical_pair
from scripts.dev_tools.compute_blast_radius import BlastRadius

if TYPE_CHECKING:
    from collections.abc import Sequence

    from scripts.dev_tools._blast_radius_scheduling import ConflictRelation

__all__ = ["existing_edge_pairs", "item_band", "observed_pair_is_edge"]

# The item field that carries a complexity band, as the planner records it.
ITEM_BAND_FIELD = "complexity_band"


def existing_edge_pairs(
    conflict_edges: Sequence[Mapping[str, object]],
) -> frozenset[tuple[int, int]]:
    """Collect the canonical pairs already recorded as conflict edges.

    Args:
        conflict_edges (Sequence[Mapping[str, object]]): ``conflict_edges[]``,
            read only; no field is added or changed.

    Returns:
        frozenset[tuple[int, int]]: Canonical ``(a, b)`` pairs with ``a < b``, so
        an edge recorded in either order matches. An edge with unreadable or
        identical endpoints is omitted, leaving a conflict over that pair
        reportable as new (fail closed).
    """
    # Normalize before collecting so a reversed pair is never misread as new.
    pairs: set[tuple[int, int]] = set()
    for edge in conflict_edges:
        first = as_item_key(edge.get("a"))
        second = as_item_key(edge.get("b"))
        if first is None or second is None or first == second:
            continue
        pairs.add(canonical_pair(first, second))
    return frozenset(pairs)


def item_band(items: Sequence[Mapping[str, object]], item_key: int) -> str | None:
    """Read an item's complexity band from the checkpoint's ``items[]``.

    Args:
        items (Sequence[Mapping[str, object]]): The checkpoint's ``items[]``.
        item_key (int): The ``issue_num`` of the item whose band is read.

    Returns:
        str | None: The band when the item records one of ``C1`` through ``C4``;
        ``None`` when the item is absent, records no band, or records an
        unreadable one, so the scheduling rule applies default_band. A band is
        a benefit estimate, not a safety input, so an unreadable value is not an
        error here.
    """
    # Return the first matching item's band; issue numbers are unique.
    for record in items:
        if record.get("issue_num") == item_key:
            band = record.get(ITEM_BAND_FIELD)
            return band if isinstance(band, str) and band in BAND_NAMES else None
    return None


def observed_pair_is_edge(
    observed_radius: BlastRadius,
    raw_radius: object,
    config: Mapping[str, object],
    *,
    observed_band: str | None = None,
    peer_band: str | None = None,
    relation: ConflictRelation = conflicts,
) -> bool:
    """Decide whether a drifting item's observed radius makes a peer pair an edge.

    Args:
        observed_radius (BlastRadius): The drifting item's observed radius.
        raw_radius (object): The peer's recorded ``blast_radius`` block.
        config (Mapping[str, object]): Parsed ``config/blast-radius.json``.
        observed_band (str | None): The drifting item's band, or ``None``.
        peer_band (str | None): The peer's band, or ``None``.
        relation (ConflictRelation): The contention relation, forwarded to the
            pair decision with the observed radius as the first argument.

    Returns:
        bool: ``True`` when the peer radius cannot be evaluated (the relation is
        not called), otherwise the scheduling rule's edge flag. Failing closed
        matters because the relation reports no conflict for an empty radius, so
        an unevaluable peer would otherwise look safe.

    Raises:
        TypeError: If ``config`` is malformed, raised by the library.
        ValueError: If the config's conflict_tolerance key is invalid.
    """
    # An absent, non-mapping, or unparseable peer radius cannot be evaluated.
    if not isinstance(raw_radius, Mapping):
        return True
    try:
        peer = BlastRadius.from_dict(cast("Mapping[str, object]", raw_radius))
    except (TypeError, ValueError):
        return True
    decision = decide_pair(
        observed_radius,
        peer,
        config,
        band_a=observed_band,
        band_b=peer_band,
        relation=relation,
    )
    return decision.edge
