"""Integration-cost scheduling layer over the blast-radius contention relation.

Purpose and responsibilities:
    Decide which detected conflicts become scheduling edges (issue #722). The
    unchanged relation ``conflicts`` of ``_blast_radius_conflicts`` decides
    whether two radii contend; this module weighs the cost of integrating two
    concurrent branches against the parallelism benefit and records a conflict
    as an edge only when the cost exceeds the configured tolerance. Conflicts
    within tolerance are returned as tolerated overlaps. ``compute_blast_radius``
    re-exports the public names.

Edge rule:
    edge iff conflict AND (hard OR cost * 100 > benefit * tolerance_percent),
    with hard, cost, and benefit defined by ``decide_pair``, ``pair_cost``, and
    ``pair_benefit``. The recorded reason is the first kind of the relation's
    reason list, so the reason enum is unchanged.

Invariants, constraints, and side effects:
    No overlap semantics are defined here: the entry-pair overlap primitive, the
    mergeable exclusion, and the mergeable matcher are reused. An absent
    conflict_tolerance key reads as tolerance 0, and at tolerance 0 the edge set
    equals the detected-conflict set exactly. Every function is pure. The
    PowerShell mirror reproduces these semantics; this module is the reference.
"""

from __future__ import annotations

from dataclasses import asdict, dataclass
from types import MappingProxyType
from typing import TYPE_CHECKING, cast

from scripts.dev_tools._blast_radius_conflicts import (
    CONFLICT_CONTRACT_DEPENDENCY,
    CONFLICT_SHARED_SURFACE_OVERLAP,
    conflicts,
)
from scripts.dev_tools._blast_radius_glob import _entries_overlap, is_glob_entry
from scripts.dev_tools._blast_radius_guards import require_mapping, require_str_tuple
from scripts.dev_tools._blast_radius_mergeable import (
    config_mergeable_paths,
    exclude_mergeable_paths,
    matches_mergeable_path,
)

if TYPE_CHECKING:
    from collections.abc import Callable, Mapping, Sequence

    from scripts.dev_tools._blast_radius_conflicts import ConflictResult
    from scripts.dev_tools.compute_blast_radius import BlastRadius

    ConflictRelation = Callable[
        [BlastRadius, BlastRadius, Mapping[str, object]], ConflictResult
    ]

__all__ = [
    "CONFIG_CONFLICT_TOLERANCE",
    "HARD_REASON_KINDS",
    "STRICT_CONFLICT_TOLERANCE",
    "ConflictEdge",
    "ConflictTolerance",
    "PairDecision",
    "SchedulingItem",
    "SchedulingResult",
    "ToleratedOverlap",
    "config_conflict_tolerance",
    "decide_pair",
    "pair_benefit",
    "pair_cost",
    "schedule_conflict_edges",
]

# Truth-table key and the label every reader error carries.
CONFIG_CONFLICT_TOLERANCE = "conflict_tolerance"
_LABEL = f'config["{CONFIG_CONFLICT_TOLERANCE}"]'

# Member names of the key and of its two nested maps. Each must be carried
# exactly, so a misspelled name fails fast instead of reading as absent.
_MEMBER_NAMES: tuple[str, ...] = tuple(
    "tolerance_percent weights band_durations default_band append_only_paths".split()
)
WEIGHT_NAMES: tuple[str, ...] = tuple(
    "same_file possible_overlap append_only module".split()
)
BAND_NAMES: tuple[str, ...] = ("C1", "C2", "C3", "C4")

# Reason kinds that make a conflict an edge at every tolerance: a shared surface
# or a contract dependency cannot be reconciled by a merge step.
HARD_REASON_KINDS: tuple[str, ...] = (
    CONFLICT_SHARED_SURFACE_OVERLAP,
    CONFLICT_CONTRACT_DEPENDENCY,
)

# tolerance_percent is a percentage of the benefit.
_PERCENT = 100


@dataclass(frozen=True)
class ConflictTolerance:
    """Immutable, validated reading of the ``conflict_tolerance`` key.

    Attributes:
        tolerance_percent (int): Percentage of the benefit a cost may reach
            before the pair becomes an edge; 0 is zero tolerance.
        weights (Mapping[str, int]): Cost weight per name in ``WEIGHT_NAMES``.
        band_durations (Mapping[str, int]): Duration per band in ``BAND_NAMES``.
        default_band (str): Band used for an item that records none.
        append_only_paths (tuple[str, ...]): Append-only file patterns, matched
            with the mergeable matcher.
    """

    tolerance_percent: int
    weights: Mapping[str, int]
    band_durations: Mapping[str, int]
    default_band: str
    append_only_paths: tuple[str, ...]

    def __post_init__(self) -> None:
        """Copy both maps into read-only views so the record stays immutable."""
        object.__setattr__(self, "weights", MappingProxyType(dict(self.weights)))
        object.__setattr__(
            self, "band_durations", MappingProxyType(dict(self.band_durations))
        )

    def band_duration(self, band: str | None) -> int:
        """Return a band's duration, reading a missing band as default_band.

        Args:
            band (str | None): The item's complexity band, or ``None``.

        Returns:
            int: The configured duration.

        Raises:
            ValueError: If the band is not one of the configured bands.
        """
        resolved = self.default_band if band is None else band
        if resolved not in self.band_durations:
            raise ValueError(f"band {resolved!r} must be one of {BAND_NAMES}.")
        return self.band_durations[resolved]


# Absent-key semantics: zero tolerance, unit weights and durations, and no
# append-only paths. At tolerance 0 the weights cannot affect the edge set.
STRICT_CONFLICT_TOLERANCE = ConflictTolerance(
    tolerance_percent=0,
    weights=dict.fromkeys(WEIGHT_NAMES, 1),
    band_durations=dict.fromkeys(BAND_NAMES, 1),
    default_band=BAND_NAMES[0],
    append_only_paths=(),
)


@dataclass(frozen=True)
class SchedulingItem:
    """One work item: its ``issue_num`` key, declared radius, and optional band."""

    key: int
    radius: BlastRadius
    band: str | None = None


@dataclass(frozen=True)
class PairDecision:
    """The scheduling verdict for one unordered pair.

    Without a conflict, edge and hard are False, cost and benefit are 0, reason
    is None, and reasons is empty. Otherwise reason is the first of reasons.
    """

    conflict: bool
    edge: bool
    hard: bool
    cost: int
    benefit: int
    reason: str | None
    reasons: tuple[str, ...]


@dataclass(frozen=True)
class ConflictEdge:
    """A scheduling edge ``a < b``; hard, cost, and benefit are tolerated extras."""

    a: int
    b: int
    reason: str
    hard: bool
    cost: int
    benefit: int

    def to_dict(self) -> dict[str, object]:
        """Serialize the edge into the checkpoint dict shape."""
        return asdict(self)


@dataclass(frozen=True)
class ToleratedOverlap:
    """A detected conflict within tolerance: recorded, but not an edge."""

    a: int
    b: int
    reasons: tuple[str, ...]
    cost: int
    benefit: int

    def to_dict(self) -> dict[str, object]:
        """Serialize the overlap into the checkpoint dict shape (reasons as a list)."""
        return {**asdict(self), "reasons": list(self.reasons)}


@dataclass(frozen=True)
class SchedulingResult:
    """Edges and tolerated overlaps, each sorted by ``(a, b)`` with ``a < b``."""

    edges: tuple[ConflictEdge, ...]
    tolerated_overlaps: tuple[ToleratedOverlap, ...]


def config_conflict_tolerance(config: Mapping[str, object]) -> ConflictTolerance:
    """Read and strictly validate the ``conflict_tolerance`` key.

    Args:
        config (Mapping[str, object]): Parsed ``config/blast-radius.json``.

    Returns:
        ConflictTolerance: The validated value, or ``STRICT_CONFLICT_TOLERANCE``
        when the key is absent (fail closed).

    Raises:
        TypeError: If the key, a member, or a nested value has a wrong type;
            booleans are rejected where an integer is required.
        ValueError: If a name is missing or unknown, an integer is out of range,
            or default_band is not in ``BAND_NAMES``. Messages name the key.
    """
    value = require_mapping(config, "config").get(CONFIG_CONFLICT_TOLERANCE)
    if value is None:
        return STRICT_CONFLICT_TOLERANCE

    member = _require_names(require_mapping(value, _LABEL), _MEMBER_NAMES, _LABEL)
    default_band = member["default_band"]
    if default_band not in BAND_NAMES:
        raise ValueError(f'{_LABEL}["default_band"] must be one of {BAND_NAMES}.')

    return ConflictTolerance(
        tolerance_percent=_require_int(
            member["tolerance_percent"], f'{_LABEL}["tolerance_percent"]', minimum=0
        ),
        weights=_read_int_map(member["weights"], WEIGHT_NAMES, "weights"),
        band_durations=_read_int_map(
            member["band_durations"], BAND_NAMES, "band_durations"
        ),
        default_band=cast("str", default_band),
        append_only_paths=require_str_tuple(
            member["append_only_paths"], f'{_LABEL}["append_only_paths"]'
        ),
    )


def pair_cost(
    radius_a: BlastRadius,
    radius_b: BlastRadius,
    config: Mapping[str, object],
    tolerance: ConflictTolerance,
) -> int:
    """Compute the integer integration cost of running two items concurrently.

    Args:
        radius_a (BlastRadius): First radius.
        radius_b (BlastRadius): Second radius.
        config (Mapping[str, object]): Parsed truth table; only
            ``mergeable_paths`` is read, for the exclusion the relation uses.
        tolerance (ConflictTolerance): Weights and append-only patterns.

    Returns:
        int: Summed path-pair weights plus the module weight times the number of
        shared modules. Mergeable paths contribute 0.
    """
    mergeable = config_mergeable_paths(config)
    paths_a = exclude_mergeable_paths(radius_a.paths, mergeable)
    paths_b = exclude_mergeable_paths(radius_b.paths, mergeable)

    # Enumerate the overlapping pairs with the relation's own primitive, so the
    # cost covers exactly the pairs the relation could report.
    cost = sum(
        _path_pair_weight(entry_a, entry_b, tolerance)
        for entry_a in paths_a
        for entry_b in paths_b
        if _entries_overlap(entry_a, entry_b)
    )
    shared_modules = set(radius_a.modules) & set(radius_b.modules)
    return cost + tolerance.weights["module"] * len(shared_modules)


def pair_benefit(
    band_a: str | None, band_b: str | None, tolerance: ConflictTolerance
) -> int:
    """Compute the parallelism benefit: the shorter of the two band durations.

    Args:
        band_a (str | None): First item's band, or ``None``.
        band_b (str | None): Second item's band, or ``None``.
        tolerance (ConflictTolerance): Band durations and default_band.

    Returns:
        int: The benefit.

    Raises:
        ValueError: If a band is not one of the configured bands.
    """
    return min(tolerance.band_duration(band_a), tolerance.band_duration(band_b))


def decide_pair(
    radius_a: BlastRadius,
    radius_b: BlastRadius,
    config: Mapping[str, object],
    *,
    band_a: str | None = None,
    band_b: str | None = None,
    relation: ConflictRelation = conflicts,
) -> PairDecision:
    """Decide whether one pair is an edge, a tolerated overlap, or neither.

    Args:
        radius_a (BlastRadius): First radius; passed first to the relation.
        radius_b (BlastRadius): Second radius.
        config (Mapping[str, object]): Parsed truth table.
        band_a (str | None): First item's band, or ``None`` for default_band.
        band_b (str | None): Second item's band, or ``None`` for default_band.
        relation (ConflictRelation): Callable with the ``conflicts`` signature,
            called exactly once; injectable so drift detection can pass its own
            patchable reference.

    Returns:
        PairDecision: The verdict; without a conflict every other field is empty.

    Raises:
        TypeError: If the config or its conflict_tolerance key is malformed.
        ValueError: If conflict_tolerance or a band is invalid.
    """
    tolerance = config_conflict_tolerance(config)
    result = relation(radius_a, radius_b, config)
    if not result.conflict:
        return PairDecision(False, False, False, 0, 0, None, ())

    # Project the reason records to their kinds, which keep canonical order.
    reasons = tuple(reason.kind for reason in result.reasons)
    hard = any(kind in HARD_REASON_KINDS for kind in reasons)
    cost = pair_cost(radius_a, radius_b, config, tolerance)
    benefit = pair_benefit(band_a, band_b, tolerance)

    # Tolerance 0 is stated explicitly rather than left to the inequality, so
    # strict identity holds even for an injected relation whose reasons the path
    # enumeration cannot reproduce.
    edge = (
        hard
        or tolerance.tolerance_percent == 0
        or cost * _PERCENT > benefit * tolerance.tolerance_percent
    )
    return PairDecision(True, edge, hard, cost, benefit, reasons[0], reasons)


def schedule_conflict_edges(
    items: Sequence[SchedulingItem], config: Mapping[str, object]
) -> SchedulingResult:
    """Build the scheduling edges and tolerated overlaps of a set of items.

    Args:
        items (Sequence[SchedulingItem]): The run's items, in any order.
        config (Mapping[str, object]): Parsed truth table.

    Returns:
        SchedulingResult: Edges and tolerated overlaps sorted by ``(a, b)`` with
        ``a < b``. A pair that does not conflict appears in neither list.

    Raises:
        TypeError: If an item key is not an integer, or the config is malformed.
        ValueError: If two items share a key, or conflict_tolerance or a band is
            invalid.
    """
    config_conflict_tolerance(config)
    ordered = _ordered_items(items)

    # Pairs are visited in (a, b) order with a < b, so both lists come out sorted.
    edges: list[ConflictEdge] = []
    tolerated: list[ToleratedOverlap] = []
    for index, first in enumerate(ordered):
        for second in ordered[index + 1 :]:
            decision = decide_pair(
                first.radius,
                second.radius,
                config,
                band_a=first.band,
                band_b=second.band,
            )
            # An edge is recorded as an edge; a conflict within tolerance is
            # recorded as a tolerated overlap; a non-conflicting pair is dropped.
            if decision.edge:
                edges.append(
                    ConflictEdge(
                        first.key,
                        second.key,
                        cast("str", decision.reason),
                        decision.hard,
                        decision.cost,
                        decision.benefit,
                    )
                )
            elif decision.conflict:
                tolerated.append(
                    ToleratedOverlap(
                        first.key,
                        second.key,
                        decision.reasons,
                        decision.cost,
                        decision.benefit,
                    )
                )
    return SchedulingResult(edges=tuple(edges), tolerated_overlaps=tuple(tolerated))


def _path_pair_weight(entry_a: str, entry_b: str, tolerance: ConflictTolerance) -> int:
    """Weigh one overlapping path pair.

    Returns:
        int: append_only when a concrete entry of the pair is append-only
        (checked first, so a registry named by both items stays cheap), else
        same_file for two equal concrete entries, else possible_overlap.
    """
    # Only a concrete entry can name an append-only file; the order of the two
    # tests below is the append-only precedence the spec requires.
    concrete = tuple(entry for entry in (entry_a, entry_b) if not is_glob_entry(entry))
    if any(matches_mergeable_path(e, tolerance.append_only_paths) for e in concrete):
        return tolerance.weights["append_only"]
    if len(concrete) == 2 and entry_a == entry_b:
        return tolerance.weights["same_file"]
    return tolerance.weights["possible_overlap"]


def _ordered_items(items: Sequence[SchedulingItem]) -> list[SchedulingItem]:
    """Validate item keys and return the items sorted by key.

    Raises:
        TypeError: If a key is not an integer (booleans rejected).
        ValueError: If two items share a key.
    """
    # Reject a non-integer key or a repeated key, either of which would make the
    # canonical (a, b) pair ordering ambiguous.
    keys: set[int] = set()
    for item in items:
        # An exact type test also rejects bool, which subclasses int.
        if type(item.key) is not int:
            raise TypeError(f"scheduling item key must be an integer: {item.key!r}.")
        if item.key in keys:
            raise ValueError(f"scheduling item keys must be distinct: {item.key}.")
        keys.add(item.key)
    return sorted(items, key=lambda item: item.key)


def _require_names(
    mapping: Mapping[str, object], names: tuple[str, ...], label: str
) -> Mapping[str, object]:
    """Require a mapping to carry exactly ``names``; raise ValueError otherwise."""
    # Collect both directions of mismatch so one error names every problem.
    missing = [name for name in names if name not in mapping]
    unknown = sorted(name for name in mapping if name not in names)
    if missing or unknown:
        raise ValueError(
            f"{label} must carry exactly {names}; missing {missing}, unknown {unknown}."
        )
    return mapping


def _require_int(value: object, label: str, *, minimum: int) -> int:
    """Require a non-boolean integer >= ``minimum``.

    Raises:
        TypeError: If the value is a boolean or not an integer.
        ValueError: If the value is below ``minimum``.
    """
    if isinstance(value, bool) or not isinstance(value, int):
        raise TypeError(f"{label} must be an integer, got {type(value).__name__}.")
    if value < minimum:
        raise ValueError(f"{label} must be >= {minimum}, got {value}.")
    return value


def _read_int_map(value: object, names: tuple[str, ...], member: str) -> dict[str, int]:
    """Read a nested map with exactly ``names``, each an integer >= 1."""
    label = f'{_LABEL}["{member}"]'
    mapping = _require_names(require_mapping(value, label), names, label)
    # Validate each named value in the fixed name order.
    return {
        name: _require_int(mapping[name], f'{label}["{name}"]', minimum=1)
        for name in names
    }
