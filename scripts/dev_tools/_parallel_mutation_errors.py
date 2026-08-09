"""Dedicated rejection and lookup exceptions for the parallel mutation engine.

Purpose, responsibilities, and usage:
    Declare every exception the pure engine in
    ``scripts/dev_tools/parallel_mutation_protocol.py`` raises when a mutation
    is rejected, plus the lookup and contract failures its value objects raise
    at construction. Each type names one broken rule and carries the offending
    item key, following the payload-carrying pattern of
    ``scripts/dev_tools/epic_wave_computation.py``.

    Callers import these through ``scripts/dev_tools/_parallel_mutation_models``,
    which re-exports them alongside the value objects, so the engine has one
    import site for its data types. This module lives apart from the value
    objects only so neither file exceeds the repository's 500-line limit, the
    same arrangement F3 uses for ``_parallel_state_records.py``.

Key invariants and constraints:
    Every item-key payload is an ``int`` (F3's positive-integer
    ``items[].issue_num``), never a ``str``, except where a rejection reports a
    value that failed exactly that type check and is therefore ``object``.

    Enum member sets quoted in messages are imported from
    ``scripts/dev_tools/_parallel_state_common.py`` rather than restated, so the
    consume-never-extend rule holds and no message can quote a stale member set.

Raises and side effects:
    Nothing here performs file I/O, network access, clock reads, or RNG access,
    and nothing mutates a caller's argument. Individual docstrings therefore
    omit the ``Side Effects`` section this statement already covers, following
    the convention of ``_parallel_state_records.py``.
"""

from __future__ import annotations

from scripts.dev_tools._parallel_state_common import (
    VALID_DISPOSITIONS,
    VALID_ITEM_STATES,
    VALID_MERGE_STATUS,
)

# Literal prefix shared by every rejection message, matching the naming rule
# that this feature's errors are prefixed ``Parallel``.
REJECTION_PREFIX = "Parallel mutation rejected:"


class ParallelMutationError(ValueError):
    """Base class for every rejection and lookup failure of the engine.

    Gives callers one type to catch when they do not care which rule was
    broken, while each subclass names the exact rule and carries the offending
    key. Never raised directly; it holds no state of its own.
    """


class _ItemKeyedRejection(ParallelMutationError):
    """Base for a rejection that names exactly one offending item key.

    Holds the payload and builds the message so each concrete subclass declares
    only its own reason text. One message-building path rather than one per
    subclass keeps the wording consistent and the subclasses short.

    Attributes:
        item_key (object): The offending key exactly as supplied.
        reason_template (str): Class-level reason clause, formatted with the
            keyword ``item_key`` already rendered through ``repr``.
    """

    reason_template: str = ""

    def __init__(self, item_key: object) -> None:
        """Store the offending key and build the literal message.

        Args:
            item_key (object): The key this rejection names.

        Returns:
            None.
        """

        self.item_key = item_key
        reason = self.reason_template.format(item_key=repr(item_key))
        super().__init__(f"{REJECTION_PREFIX} {reason}")


class InFlightRemovalRequiresDispositionError(_ItemKeyedRejection):
    """Raised when an in-flight item is removed without a disposition.

    Enforces spec FR2's no-default-disposition rule: inferring a default would
    silently choose between letting running work finish and destroying it.

    Attributes:
        item_key (int): The ``items[].issue_num`` of the rejected removal.
    """

    reason_template = (
        "removal of in-flight item {item_key} requires an explicit "
        f"disposition, one of {', '.join(VALID_DISPOSITIONS)}; "
        "no default is inferred."
    )


class MergedItemRemovalRejectedError(_ItemKeyedRejection):
    """Raised when a ``merged`` item is removed (spec FR2, final table row).

    A merged item's change is already in ``main``, so no removal can undo it;
    the request is a caller error rather than a state transition.

    Attributes:
        item_key (int): The ``items[].issue_num`` of the rejected removal.
    """

    reason_template = (
        "item {item_key} is already merged into main and cannot be removed."
    )


class UnknownItemError(_ItemKeyedRejection):
    """Raised when a mutation names an item the run does not track.

    Fails fast on a key resolving to no ``items[].issue_num`` instead of
    silently treating the absent item as unstarted.

    Attributes:
        item_key (object): The unresolvable key exactly as supplied.
    """

    reason_template = (
        "item key {item_key} does not resolve to a tracked items[].issue_num."
    )


class CloseWhileInFlightRejectedError(ParallelMutationError):
    """Raised when a run is closed while at least one item is in flight.

    Enforces spec FR3: closing an ``open``-mode run terminates admissions, so
    it is rejected while work is still running rather than abandoning it. It
    carries a key set rather than a single key, so it does not share the
    single-key base.

    Attributes:
        in_flight_keys (tuple[int, ...]): The blocking ``items[].issue_num``
            values, ascending, so the caller can report all of them at once.
    """

    def __init__(self, in_flight_keys: tuple[int, ...]) -> None:
        """Store the blocking keys ascending and build the literal message.

        Args:
            in_flight_keys (tuple[int, ...]): The blocking keys, in any order.

        Returns:
            None.
        """

        ordered = tuple(sorted(in_flight_keys))
        self.in_flight_keys = ordered
        super().__init__(
            f"{REJECTION_PREFIX} close requires no item in flight; "
            f"still in flight: {list(ordered)!r}."
        )


class UnknownEnumMemberError(ParallelMutationError):
    """Raised when a value outside one of F3's enums is supplied.

    Covers item ``state`` and per-item ``merge_status``. One parameterized type
    rather than one class per field keeps the consume-never-extend check in a
    single place: an unrecognized member is rejected at construction rather
    than propagated into a record the landed validator would reject.

    Attributes:
        item_key (int | None): The owning key, or None for a run-scoped record.
        field_name (str): The field whose enum was violated.
        value (object): The offending value exactly as supplied.
    """

    def __init__(self, item_key: int | None, field_name: str, value: object) -> None:
        """Store the offending field and build the literal message.

        Args:
            item_key (int | None): The owning ``items[].issue_num``, or None.
            field_name (str): Either ``state`` or ``merge_status``.
            value (object): The value that is not a member of that enum.

        Returns:
            None.
        """

        self.item_key = item_key
        self.field_name = field_name
        self.value = value
        allowed = VALID_ITEM_STATES if field_name == "state" else VALID_MERGE_STATUS
        super().__init__(
            f"{REJECTION_PREFIX} item {item_key!r} {field_name} {value!r} is "
            f"not one of {', '.join(allowed)}."
        )


class MutationEntryContractError(ParallelMutationError):
    """Raised when a ``MutationEntry`` would violate the landed F3 shape.

    Makes it structurally impossible for the engine to construct a record the
    landed validator rejects, because the check runs at construction.

    Attributes:
        op (object): The entry's ``op`` value as supplied.
        field_name (str): The field whose rule was broken.
        value (object): The offending value exactly as supplied.
    """

    def __init__(self, op: object, field_name: str, value: object) -> None:
        """Store the violated field rule and build the literal message.

        Args:
            op (object): The entry's ``op`` value.
            field_name (str): The field whose rule was broken.
            value (object): The offending value.

        Returns:
            None.
        """

        self.op = op
        self.field_name = field_name
        self.value = value
        super().__init__(
            f"Parallel mutation entry rejected: {field_name} {value!r} "
            f"violates the F3 mutations[] contract for op {op!r}."
        )
