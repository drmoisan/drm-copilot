"""Frozen value objects for the parallel mutation protocol.

Purpose, responsibilities, and usage:
    Carry the immutable data the pure engine in
    ``scripts/dev_tools/parallel_mutation_protocol.py`` consumes and produces:
    the item snapshot (``ItemRecord``), the admission verdict
    (``AdmissionOutcome``, ``AdmissionDecision``), the recolor result
    (``RecolorResult``), and the mutation-log record (``MutationEntry``). Every
    type validates its own fields at construction, so a value object that
    exists is one the landed F3 validator accepts. This module implements no
    decision logic: which mutation is legal is the engine's concern.

    This module is also the engine's single import site for the data types. It
    re-exports the rejection and lookup exceptions declared in
    ``scripts/dev_tools/_parallel_mutation_errors.py`` through ``__all__``, so a
    caller needs one import to reach both the value objects and the exceptions.
    The exceptions live in their own module only so neither file exceeds the
    repository's 500-line limit, the same arrangement F3 uses for
    ``_parallel_state_records.py``.

Key invariants and constraints:
    Every item key is an ``int``. F3's ``items[].issue_num`` is a positive
    integer and is the primary key for every item reference
    (``.claude/rules/parallel-orchestration.md`` invariant 5), so no value
    object uses a ``str`` key.

    The nine parallel enums are owned by F3 and are CONSUMED here, never
    extended: member sets are imported from
    ``scripts/dev_tools/_parallel_state_common.py`` rather than restated, so no
    member can drift and none can be added by accident.

    ``MutationEntry`` enforces the landed F3 nullability rule at construction
    (``.claude/rules/parallel-orchestration.md`` invariant 16 and
    ``_parallel_state_records.py``): ``prior_state`` null for ``add`` and
    ``close``, ``new_state`` null for ``close``, ``item_key`` null for ``close``
    only, ``disposition`` non-null only on a ``remove`` whose ``prior_state``
    is ``in_flight``. An ``add`` entry can therefore never carry a non-null
    ``prior_state``; the accompanying ``prepared -> scheduled`` transition is
    recorded as an item-state update in the checkpoint's ``items[]``.

Raises and side effects:
    Construction raises the re-exported exceptions on an invariant violation.
    No function here performs file I/O, network access, clock reads, or RNG
    access, and none mutates a caller's argument. Individual docstrings
    therefore omit the ``Side Effects`` section this statement already covers,
    following the convention of ``_parallel_state_records.py``.
"""

from __future__ import annotations

from dataclasses import dataclass
from enum import Enum
from types import MappingProxyType
from typing import TYPE_CHECKING

from scripts.dev_tools._parallel_mutation_errors import (
    CloseWhileInFlightRejectedError,
    InFlightRemovalRequiresDispositionError,
    MergedItemRemovalRejectedError,
    MutationEntryContractError,
    ParallelMutationError,
    UnknownEnumMemberError,
    UnknownItemError,
)
from scripts.dev_tools._parallel_state_common import (
    MERGED_MERGE_STATUSES,
    VALID_DISPOSITIONS,
    VALID_ITEM_STATES,
    VALID_MERGE_STATUS,
    VALID_MUTATION_OPS,
)

# The op classification is F3-OWNED and is CONSUMED here, never restated. Local
# copies previously duplicated these three tuples, so an F3 amendment could have
# diverged silently while both sides held full coverage; importing the originals
# makes that divergence impossible by construction.
from scripts.dev_tools._parallel_state_records import (
    OPS_REQUIRING_ITEM_KEY,
    OPS_REQUIRING_NULL_NEW_STATE,
    OPS_REQUIRING_NULL_PRIOR_STATE,
)

if TYPE_CHECKING:
    from collections.abc import Mapping
    from datetime import datetime

# The value objects plus the re-exported exception types, so the engine reaches
# every data type of this feature through one import site.
__all__ = [
    "AdmissionDecision",
    "AdmissionOutcome",
    "CloseWhileInFlightRejectedError",
    "InFlightRemovalRequiresDispositionError",
    "ItemRecord",
    "MergedItemRemovalRejectedError",
    "MutationEntry",
    "MutationEntryContractError",
    "ParallelMutationError",
    "RecolorResult",
    "RemovalDecision",
    "UnknownEnumMemberError",
    "UnknownItemError",
]

# Item states whose items have not started and are therefore vertices of the
# recolored subgraph (spec FR4). A SUBSET of F3's item-state enum, not a new
# enum: the unit tests assert every member below is in ``VALID_ITEM_STATES``.
UNSTARTED_ITEM_STATES: tuple[str, ...] = tuple(
    "proposed admitted prepared scheduled".split()
)

# The single item state that pins an item against recoloring (spec FR4).
PINNED_ITEM_STATE = "in_flight"

# The ``merge_status`` F3 reads for an item that records none (invariant 7).
DEFAULT_MERGE_STATUS = "not_started"


class AdmissionOutcome(Enum):
    """The two verdicts ``decide_admission`` can return (spec FR1 step 4).

    Naming the branch explicitly keeps the recompute boundary readable at the
    call site. Carries no data; ``AdmissionDecision`` pairs it with a candidate.

    Attributes:
        ADMIT_CURRENT_COHORT: The candidate conflicts with no member of the
            current cohort, pinned or unstarted, so it joins the current cohort
            with the generation unchanged.
        DEFER_AND_RECOLOR: A conflict with any current-cohort member -- pinned or
            not-yet-launched -- defers the candidate, the unstarted subgraph is
            recolored under the pinned-barrier offset, and the generation
            increments by exactly one.
    """

    ADMIT_CURRENT_COHORT = "admit_current_cohort"
    DEFER_AND_RECOLOR = "defer_and_recolor"


@dataclass(frozen=True)
class ItemRecord:
    """Immutable snapshot of one tracked parallel item.

    Purpose and responsibilities:
        Give the engine the two item facts its decisions depend on -- lifecycle
        ``state`` and per-item ``merge_status`` -- keyed by F3's primary key,
        and validate both against F3's enums. It holds no cohort index and no
        blast radius: cohort membership belongs to the recolor result and the
        radius is F1's.

    Usage and invariants:
        Constructed from a checkpoint ``items[]`` entry and passed to the engine
        inside a ``Mapping[int, ItemRecord]`` keyed by ``issue_num``.
        ``issue_num`` is a positive non-boolean ``int``; ``merge_status``
        defaults to ``not_started``, which is how F3 reads an absent value.

    Attributes:
        issue_num (int): F3's primary key for this item.
        state (str): The item's lifecycle state.
        merge_status (str): The item's merge lifecycle status.
    """

    issue_num: int
    state: str
    merge_status: str = DEFAULT_MERGE_STATUS

    def __post_init__(self) -> None:
        """Validate the key and both enum fields at construction.

        Returns:
            None.

        Raises:
            UnknownItemError: If ``issue_num`` is not a positive non-boolean
                ``int``, since such a value can never resolve to an
                ``items[].issue_num``.
            UnknownEnumMemberError: If ``state`` or ``merge_status`` is outside
                its F3 enum.
        """

        if isinstance(self.issue_num, bool) or self.issue_num <= 0:
            raise UnknownItemError(self.issue_num)
        if self.state not in VALID_ITEM_STATES:
            raise UnknownEnumMemberError(self.issue_num, "state", self.state)
        if self.merge_status not in VALID_MERGE_STATUS:
            raise UnknownEnumMemberError(
                self.issue_num, "merge_status", self.merge_status
            )

    @property
    def is_unstarted(self) -> bool:
        """Report whether this item is a vertex of the recolored subgraph.

        Returns:
            bool: True when ``state`` is in ``UNSTARTED_ITEM_STATES``.
        """

        return self.state in UNSTARTED_ITEM_STATES

    @property
    def is_pinned(self) -> bool:
        """Report whether this item is pinned against recoloring (spec FR4).

        Returns:
            bool: True when ``state`` is ``in_flight``.
        """

        return self.state == PINNED_ITEM_STATE

    @property
    def has_terminal_merge_status(self) -> bool:
        """Report whether this item reached a terminal merged outcome.

        Returns:
            bool: True when ``merge_status`` is ``merged`` or
            ``worktree_removed``, F3's two ``MERGED_MERGE_STATUSES`` members.
        """

        return self.merge_status in MERGED_MERGE_STATUSES


@dataclass(frozen=True)
class AdmissionDecision:
    """Immutable verdict of the admission decision for one candidate.

    Pairs a candidate key with its outcome so the caller can act on the branch
    and record which item it applies to. It performs no recoloring; that is
    ``recolor_unstarted``'s work.

    Attributes:
        candidate (int): The candidate's ``items[].issue_num``.
        outcome (AdmissionOutcome): The admission branch taken.
    """

    candidate: int
    outcome: AdmissionOutcome

    @property
    def triggers_recompute(self) -> bool:
        """Report whether this decision increments ``recolor_generation``.

        Returns:
            bool: True for ``DEFER_AND_RECOLOR``, False for
            ``ADMIT_CURRENT_COHORT``, per the spec's recompute boundary.
        """

        return self.outcome is AdmissionOutcome.DEFER_AND_RECOLOR


@dataclass(frozen=True)
class RemovalDecision:
    """Immutable outcome of a successful removal (spec FR2 behavior table).

    Purpose and responsibilities:
        Carry everything a caller needs to apply one accepted removal: the
        transition to record, the disposition that disambiguates a pinned
        removal, and whether the removal recomputes the coloring. A REJECTED
        removal produces no instance at all -- the engine raises instead -- so
        an instance existing means the removal was accepted.

    Usage and invariants:
        Returned by ``decide_removal``. ``new_state`` is always ``withdrawn``
        for every accepted row of the FR2 table. ``disposition`` is non-null
        exactly when ``prior_state`` is ``in_flight``, which is the same
        condition F3 invariant 17 places on the mutation entry.
        ``triggers_recompute`` is True only for the unstarted rows.

    Attributes:
        item_key (int): The removed item's ``items[].issue_num``.
        prior_state (str): The item's state before the removal.
        new_state (str): The item's state after the removal.
        disposition (str | None): ``detach`` or ``abandon`` for a pinned
            removal, None otherwise.
        triggers_recompute (bool): Whether ``recolor_generation`` increments.
    """

    item_key: int
    prior_state: str
    new_state: str
    disposition: str | None
    triggers_recompute: bool


@dataclass(frozen=True)
class RecolorResult:
    """Immutable result of recoloring the unstarted subgraph (spec FR4).

    Purpose and responsibilities:
        Carry the new cohort assignment for unstarted items only, plus the
        generation it belongs to, so a caller can apply the recolor without
        recomputing anything. It carries no assignment for any pinned item: the
        pinning invariant is that a pinned item's cohort is never reassigned,
        so the absence IS the guarantee.

    Usage and invariants:
        Returned by ``recolor_unstarted``. The caller writes
        ``cohort_assignments`` into the checkpoint's ``cohorts[]`` and sets the
        top-level ``recolor_generation`` to ``generation``. The mapping's key
        set equals the caller's unstarted set exactly and is disjoint from the
        pinned set; ``generation`` is the current generation plus one.

        The values are ABSOLUTE checkpoint cohort indices, not zero-based local
        color indices. They already carry the pinned-barrier offset: every index
        is at or above the run's ``current_cohort``, and strictly above it
        whenever an unstarted item conflicts with a pinned item. The caller
        writes them VERBATIM into ``cohorts[].index`` and never re-bases them to
        zero. When the lowest returned index equals ``current_cohort`` -- the
        no-pinned-conflict case, where the offset is not applied -- the keys at
        that index are MERGED into the single existing current-generation cohort
        entry at ``current_cohort`` alongside its pinned members, never written as
        a second entry carrying the same index, because F3 invariant 13 requires
        current-generation ``cohorts[].index`` values to be unique.

    Attributes:
        cohort_assignments (Mapping[int, int]): ``item_key -> cohort_index``
            for unstarted items only, read-only. The index is an ABSOLUTE
            checkpoint cohort index written verbatim into ``cohorts[].index``,
            not a zero-based local color index.
        generation (int): The generation the assignment belongs to.
    """

    cohort_assignments: Mapping[int, int]
    generation: int

    def __post_init__(self) -> None:
        """Freeze the assignment mapping into a read-only private copy.

        Copying before wrapping matters: wrapping the caller's own dict would
        leave this value object mutable through the caller's reference, which
        would break the purity guarantee the recolor contract makes.

        Returns:
            None.

        Raises:
            None.
        """

        object.__setattr__(
            self,
            "cohort_assignments",
            MappingProxyType(dict(self.cohort_assignments)),
        )


@dataclass(frozen=True)
class MutationEntry:
    """One immutable ``mutations[]`` record in F3's seven-field shape.

    Purpose and responsibilities:
        Represent exactly one appended audit record for one successful mutation,
        in the shape ``{ op, item_key, at, prior_state, new_state, disposition,
        recolor_generation }``, and enforce the landed F3 nullability rule at
        construction. It decides nothing about which mutation is legal; the
        engine decided that before constructing it.

    Usage and invariants:
        Constructed only by the engine's entry constructors, which supply ``at``
        from the injected clock seam. Exactly the seven F3 fields; no field is
        added. ``prior_state`` is null for ``add`` and ``close``; ``new_state``
        is null for ``close``; ``item_key`` is null for ``close`` only;
        ``disposition`` is non-null only on a ``remove`` whose ``prior_state``
        is ``in_flight``; ``recolor_generation`` is a non-negative ``int``.

    Attributes:
        op (str): The mutation operation, an F3 ``mutations[].op`` member.
        item_key (int | None): The affected key, or None for ``close``.
        at (datetime): When the mutation was recorded, from the injected clock.
        prior_state (str | None): The item's state before the mutation.
        new_state (str | None): The item's state after the mutation.
        disposition (str | None): How in-flight work was disposed of.
        recolor_generation (int): The generation stamped into this record.
    """

    op: str
    item_key: int | None
    at: datetime
    prior_state: str | None
    new_state: str | None
    disposition: str | None
    recolor_generation: int

    def __post_init__(self) -> None:
        """Validate the record against the landed F3 ``mutations[]`` contract.

        Checks run in field order so the first reported violation names the
        earliest field at fault, which makes a constructor defect easy to
        locate. The ``item_key`` rule splits on whether the op is item-scoped:
        ``close`` is a run-level record and carries no key, while ``add``,
        ``remove``, and ``requeue`` each name exactly one tracked item.

        Returns:
            None.

        Raises:
            MutationEntryContractError: If ``op`` is not an F3 operation, if
                ``recolor_generation`` is not a non-negative ``int``, if
                ``item_key`` or a state field breaks its op-specific null rule,
                or if ``disposition`` appears outside an in-flight removal.
            UnknownEnumMemberError: If a non-null ``prior_state`` or
                ``new_state`` is outside the item-state enum.
        """

        if self.op not in VALID_MUTATION_OPS:
            raise MutationEntryContractError(self.op, "op", self.op)
        if isinstance(self.recolor_generation, bool) or self.recolor_generation < 0:
            raise MutationEntryContractError(
                self.op, "recolor_generation", self.recolor_generation
            )

        key = self.item_key
        if self.op not in OPS_REQUIRING_ITEM_KEY:
            if key is not None:
                raise MutationEntryContractError(self.op, "item_key", key)
        elif key is None or isinstance(key, bool) or key <= 0:
            raise MutationEntryContractError(self.op, "item_key", key)

        self._validate_state_fields()
        self._validate_disposition()

    def _validate_state_fields(self) -> None:
        """Validate ``prior_state`` and ``new_state`` against the null rule.

        Returns:
            None.

        Raises:
            MutationEntryContractError: If a field must be null for this op but
                carries a value. This is the check that makes a non-null
                ``prior_state`` on an ``add`` entry impossible to construct.
            UnknownEnumMemberError: If a non-null value is not an item-state
                member.
        """

        # Both fields share one rule shape and differ only in which op set
        # requires a null, so one pass over the pair keeps them consistent.
        for field_name, value, null_ops in (
            ("prior_state", self.prior_state, OPS_REQUIRING_NULL_PRIOR_STATE),
            ("new_state", self.new_state, OPS_REQUIRING_NULL_NEW_STATE),
        ):
            if self.op in null_ops:
                if value is not None:
                    raise MutationEntryContractError(self.op, field_name, value)
                continue
            if value is not None and value not in VALID_ITEM_STATES:
                raise UnknownEnumMemberError(self.item_key, "state", value)

    def _validate_disposition(self) -> None:
        """Validate ``disposition`` against F3 invariant 17.

        Returns:
            None.

        Raises:
            MutationEntryContractError: If an in-flight removal's disposition is
                outside ``VALID_DISPOSITIONS``, or if any other entry carries a
                non-null disposition.
        """

        # An in-flight removal must record how the running work was disposed of;
        # every other entry leaves the field null so a stray value cannot imply
        # a decision never taken.
        if self.op == "remove" and self.prior_state == PINNED_ITEM_STATE:
            if self.disposition not in VALID_DISPOSITIONS:
                raise MutationEntryContractError(
                    self.op, "disposition", self.disposition
                )
            return
        if self.disposition is not None:
            raise MutationEntryContractError(self.op, "disposition", self.disposition)
