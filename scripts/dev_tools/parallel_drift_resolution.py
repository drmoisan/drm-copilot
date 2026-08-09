"""Pure observed-radius construction and the drift-resolution write intent seam.

Purpose:
    Supply the producer half of the derived drift resolution. The Layer-2 drift
    gate releases an item only when its recorded ``items[].blast_radius`` either
    widened to cover every escaped path or was re-recorded from a later observed
    diff. This module builds that observed radius and expresses the second
    resolving write as data, so the ``parallel-orchestrator`` applies a
    library-produced value instead of hand-constructing one.

Responsibilities:
    Two things only: build a ``BlastRadius`` from an observed changed-path set,
    and return the requested ``items[].blast_radius`` update that clears the
    derived unresolved state. This module owns no schema. ``blast_radius`` already
    carries ``paths``, ``modules``, ``shared_surfaces``, ``contracts``, ``source``,
    and ``computed_at`` per F3 invariant 9, and ``observed`` is an existing member
    of the ``blast_radius.source`` enum, so no field is added and no enum is
    extended.

Boundaries (IC-1b MANDATE, relocated here from ``parallel_drift_detection``):
    An observed radius is always built by F1's ``radius_from_observed_paths``,
    never by constructing a ``BlastRadius`` by hand. Hand construction would skip
    ``resolve_modules`` and ``resolve_shared_surfaces`` and therefore silently drop
    the module and shared-surface disjuncts of the contention relation,
    under-reporting the radius — the failure mode design section 13.1 names as
    dominant. Every caller in the repository that needs an observed radius routes
    through ``build_observed_radius`` in this module.

    The write seam requests and never writes, mirroring
    ``request_requeue_via_recolor`` in ``parallel_drift_halt``. The
    ``parallel-orchestrator`` applies the returned update; nothing here touches the
    checkpoint.

Raises and side effects:
    Every function is pure: no filesystem, subprocess, network, or wall-clock
    access, and no argument is mutated. Every timestamp is an input, so identical
    inputs produce identical outputs. Individual docstrings therefore omit the
    ``Side Effects`` section this module-wide statement already covers.
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import TYPE_CHECKING

from scripts.dev_tools._parallel_drift_shape import (
    require_item_key,
    require_paths,
    require_text,
)
from scripts.dev_tools.compute_blast_radius import radius_from_observed_paths

if TYPE_CHECKING:
    from collections.abc import Mapping, Sequence

    from scripts.dev_tools.compute_blast_radius import BlastRadius

__all__ = [
    "ResolutionWriteRequest",
    "build_observed_radius",
    "request_resolution_write",
]


@dataclass(frozen=True)
class ResolutionWriteRequest:
    """Requested, not performed, ``items[].blast_radius`` update for one item.

    Purpose:
        Express the resolving write of the Layer-2 drift gate as data, so drift
        detection can name the write without owning the checkpoint. The
        ``parallel-orchestrator`` applies it.

    Responsibilities:
        Carry the item key and the serialized radius to write, and nothing else.
        The class applies nothing and writes nothing.

    Usage:
        Built only by ``request_resolution_write``; consumed by the parent, which
        assigns ``blast_radius`` onto the matching ``items[]`` record.

    Key invariants:
        ``blast_radius`` carries exactly the six F3 invariant-9 keys, with
        ``source`` equal to ``observed``, because it is the serialization of a
        library-built ``BlastRadius``. ``item_key`` is a positive, non-boolean
        integer ``issue_num``.

    Side Effects:
        None; the instance is frozen.

    Attributes:
        item_key (int): ``issue_num`` of the item whose radius is re-recorded.
        blast_radius (Mapping[str, object]): The serialized radius to write onto
            that item, in the invariant-9 shape.
    """

    item_key: int
    blast_radius: Mapping[str, object]


def build_observed_radius(
    observed_paths: Sequence[str],
    config: Mapping[str, object],
    *,
    computed_at: str,
) -> BlastRadius:
    """Build the observed blast radius of a changed-path set.

    This is the single guarded entry point for the IC-1b mandate recorded in this
    module's ``Boundaries`` section: it is exactly F1's ``radius_from_observed_paths``
    with the two shape guards this surface applies to every input, so no caller
    needs to repeat them and no caller has a reason to construct a ``BlastRadius``
    by hand.

    Args:
        observed_paths (Sequence[str]): The observed changed-path set, typically a
            ``git diff --name-only`` listing. May be empty; an empty radius
            conflicts with nothing.
        config (Mapping[str, object]): Parsed ``config/blast-radius.json``,
            forwarded to the library. Passing it in keeps this function pure.
        computed_at (str): ISO-8601 timestamp recorded on the radius. Must be a
            non-empty string.

    Returns:
        BlastRadius: The library-built radius, with ``source`` ``observed`` and its
        ``modules`` and ``shared_surfaces`` levels resolved by the library.

    Raises:
        ParallelDriftInputError: If ``observed_paths`` or ``computed_at`` is
            malformed.
        TypeError: If ``config`` is not a mapping, raised by the library.
    """
    return radius_from_observed_paths(
        require_paths(observed_paths, "observed_paths", allow_empty=True),
        config,
        computed_at=require_text(computed_at, "computed_at"),
    )


def request_resolution_write(
    *,
    item_key: int,
    observed_paths: Sequence[str],
    config: Mapping[str, object],
    computed_at: str,
) -> ResolutionWriteRequest:
    """Request the ``items[].blast_radius`` write that resolves recorded drift.

    This is the resolution-write seam. It REQUESTS the write and does not perform
    it: the ``parallel-orchestrator`` owns the checkpoint, so the seam returns the
    update for the parent to apply, in the same shape as
    ``request_requeue_via_recolor`` in ``parallel_drift_halt``. The returned radius
    satisfies resolution disjunct (b) — ``source == 'observed'`` with a
    ``computed_at`` the caller must make strictly later than the drift event's
    ``at`` — so applying it clears the item from ``unresolved_drift_item_keys``.

    Args:
        item_key (int): ``issue_num`` of the item whose radius is re-recorded; a
            positive, non-boolean integer.
        observed_paths (Sequence[str]): The post-remediation observed changed-path
            set the radius is rebuilt from.
        config (Mapping[str, object]): Parsed ``config/blast-radius.json``.
        computed_at (str): ISO-8601 timestamp recorded on the radius. The caller
            is responsible for making it strictly later than the event's ``at``;
            an earlier or equal value produces a radius that does not resolve.

    Returns:
        ResolutionWriteRequest: The item key and the serialized radius, carrying
        exactly the six invariant-9 keys with ``source`` equal to ``observed``.

    Raises:
        ParallelDriftInputError: If ``item_key``, ``observed_paths``, or
            ``computed_at`` is malformed.
        TypeError: If ``config`` is not a mapping, raised by the library.
    """
    radius = build_observed_radius(observed_paths, config, computed_at=computed_at)
    return ResolutionWriteRequest(
        item_key=require_item_key(item_key, "item_key"),
        blast_radius=radius.to_dict(),
    )
