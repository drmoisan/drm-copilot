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
from scripts.dev_tools._blast_radius_scheduling import (
    BAND_NAMES,
    NO_ACCESS,
    ItemAccess,
    decide_pair,
)
from scripts.dev_tools._parallel_drift_shape import as_item_key, canonical_pair
from scripts.dev_tools.compute_blast_radius import BlastRadius

if TYPE_CHECKING:
    from collections.abc import Sequence

    from scripts.dev_tools._blast_radius_scheduling import ConflictRelation

__all__ = ["existing_edge_pairs", "item_access", "item_band", "observed_pair_is_edge"]

# The item field that carries a complexity band, as the planner records it.
ITEM_BAND_FIELD = "complexity_band"

# The optional item access lists of issue #1164, recorded beside blast_radius.
ACCESS_FIELDS: tuple[str, str] = ("read_paths", "separable_paths")


def _access_list(value: object) -> tuple[str, ...]:
    """Return a list of non-empty strings as a tuple, or empty when malformed.

    Args:
        value (object): The deserialized access-list value.

    Returns:
        tuple[str, ...]: The entries in order, or an empty tuple when the value
        is not a list of non-empty strings.
    """
    if not isinstance(value, list):
        return ()
    entries = cast("list[object]", value)
    # One malformed entry rejects the whole list, so it prices like an absent one.
    if not all(isinstance(entry, str) and entry for entry in entries):
        return ()
    return tuple(cast("list[str]", entries))


def item_access(items: Sequence[Mapping[str, object]], item_key: int) -> ItemAccess:
    """Read an item's declared ``read_paths`` and ``separable_paths``.

    Args:
        items (Sequence[Mapping[str, object]]): The checkpoint's ``items[]``.
        item_key (int): The ``issue_num`` of the item whose lists are read.

    Returns:
        ItemAccess: Both lists when the item records them; an empty list for a
        list that is absent or malformed (not a list of non-empty strings), and
        ``NO_ACCESS`` when the item is absent. The validators report malformed
        lists; here a malformed list prices like an absent one, which is the
        fail-closed direction because it removes a cost reduction.
    """
    # Return the first matching item's lists; issue numbers are unique.
    for record in items:
        if record.get("issue_num") == item_key:
            # Read both lists in ACCESS_FIELDS order: read_paths, separable_paths.
            read_paths, separable_paths = (
                _access_list(record.get(field)) for field in ACCESS_FIELDS
            )
            return ItemAccess(read_paths=read_paths, separable_paths=separable_paths)
    return NO_ACCESS


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
    peer_access: ItemAccess = NO_ACCESS,
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
        peer_access (ItemAccess): The peer's declared access lists (issue
            #1164, spec B5.6), so a path the peer only reads still costs 0. The
            observed side carries none: every observed path is a write.

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
        access_b=peer_access,
    )
    return decision.edge
