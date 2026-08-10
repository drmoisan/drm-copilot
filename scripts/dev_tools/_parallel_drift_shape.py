"""Input guards shared by the parallel radius-drift modules.

Purpose:
    Own the fail-fast input checks and the one exception type that
    ``parallel_drift_detection`` and ``parallel_drift_halt`` both need, so the
    two modules validate identically and neither grows a private copy of the
    same guard. The split follows the ``_parallel_state_*.py`` convention and
    exists to keep every drift module inside the 500-line file cap.

Responsibilities:
    Convert a loosely typed, deserialized checkpoint value into a validated
    Python value, or raise. Shape predicates themselves are not reimplemented
    here: they are imported from ``_parallel_state_common``, which F3 owns, so
    the drift modules and the parallel validators agree on what a well-formed
    ``issue_num``, timestamp, or path list is.

Key invariants:
    Booleans are never accepted where an integer is required, because ``bool``
    subclasses ``int`` and a boolean in a numeric slot is malformed data rather
    than a value to coerce. Path collections are returned deduplicated and
    ordinally sorted so identical inputs serialize identically.

Raises and side effects:
    Every function in this module is pure: it performs no I/O, reads no clock,
    and mutates no argument. The ``require_*`` functions raise
    ``ParallelDriftInputError`` and nothing else; the ``as_*`` and ``record_*``
    readers raise nothing and report failure as ``None``. Individual docstrings
    therefore omit the ``Side Effects`` section this module-wide statement
    already covers.
"""

from __future__ import annotations

import re
from typing import TYPE_CHECKING, cast

from scripts.dev_tools._parallel_state_common import (
    is_non_empty_string,
    is_non_negative_integer,
    is_positive_integer,
    is_string_list,
)

if TYPE_CHECKING:
    from collections.abc import Sequence

CANONICAL_TIMESTAMP_RE = r"^\d{4}-\d{2}-\d{2}T\d{2}-\d{2}$"
"""The single canonical timestamp shape ``yyyy-MM-ddTHH-mm``.

Ordinal comparison of two timestamps is only meaningful when both carry the same
fixed-width shape. The pattern text is duplicated character-for-character in
``.claude/hooks/enforce-parallel-drift-gate-helpers.ps1`` so the Python
derivation and the PowerShell Layer-1 hook accept exactly the same value set;
the cross-runtime seam test in
``tests/scripts/claude-hooks/enforce-parallel-drift-gate-helpers.Tests.ps1``
binds the two runtimes over a shared row table.
"""


class ParallelDriftInputError(ValueError):
    """Raised when radius-drift evaluation receives malformed input.

    Purpose:
        Signal that a caller supplied a value the drift functions cannot
        evaluate deterministically, so evaluation fails loudly rather than
        emitting a drift record or a halt decision derived from bad data.

    Responsibilities:
        Carry one literal message naming the offending field and value. The
        class validates nothing itself; the guards below detect each malformed
        mode and raise it.

    Usage:
        The thin CLI wrapper and the parent orchestrator catch this at the
        boundary where checkpoint data was loaded. Because it subclasses
        ``ValueError``, existing ``except ValueError`` handlers keep working.

    Side Effects:
        None.
    """


def require_item_key(value: object, label: str) -> int:
    """Require a value to be an ``issue_num`` primary key.

    Args:
        value (object): The candidate key, typically read from a checkpoint.
        label (str): Field label rendered into the error message.

    Returns:
        int: The validated key.

    Raises:
        ParallelDriftInputError: If the value is not a positive, non-boolean
            integer (F3 invariant 5).
    """
    if not is_positive_integer(value):
        raise ParallelDriftInputError(
            f"{label} must be a positive integer issue_num; found: {value!r}."
        )
    return cast("int", value)


def require_generation(value: object, label: str) -> int:
    """Require a value to be a non-negative generation counter.

    Args:
        value (object): The candidate counter.
        label (str): Field label rendered into the error message.

    Returns:
        int: The validated counter.

    Raises:
        ParallelDriftInputError: If the value is not a non-negative,
            non-boolean integer.
    """
    if not is_non_negative_integer(value):
        raise ParallelDriftInputError(
            f"{label} must be a non-negative integer; found: {value!r}."
        )
    return cast("int", value)


def require_text(value: object, label: str) -> str:
    """Require a value to be a non-empty string.

    Args:
        value (object): The candidate string.
        label (str): Field label rendered into the error message.

    Returns:
        str: The validated string, unchanged.

    Raises:
        ParallelDriftInputError: If the value is not a string or carries no
            non-space character.
    """
    if not is_non_empty_string(value):
        raise ParallelDriftInputError(
            f"{label} must be a non-empty string; found: {value!r}."
        )
    return cast("str", value)


def require_paths(
    value: Sequence[str], label: str, *, allow_empty: bool
) -> tuple[str, ...]:
    """Require a value to be a collection of non-empty repository paths.

    Args:
        value (Sequence[str]): The candidate collection. A bare string is
            rejected rather than iterated, because iterating one would silently
            treat each character as a path.
        label (str): Field label rendered into the error messages.
        allow_empty (bool): Whether an empty collection is acceptable. It is not
            for ``escaped_paths``, where emptiness means there was no drift.

    Returns:
        tuple[str, ...]: The entries, deduplicated and ordinally sorted.

    Raises:
        ParallelDriftInputError: If the value is a bare string, holds a blank or
            non-string entry, or is empty while ``allow_empty`` is ``False``.
    """
    if isinstance(value, str):
        raise ParallelDriftInputError(
            f"{label} must be a collection of paths, not a single string; "
            f"found: {value!r}."
        )

    entries = tuple(value)
    # Reject a blank or non-string entry outright: dropping one silently would
    # narrow the compared path set and so under-report drift.
    for entry in entries:
        if not is_non_empty_string(entry):
            raise ParallelDriftInputError(
                f"{label} entries must be non-empty strings; found: {entry!r}."
            )

    if not entries and not allow_empty:
        raise ParallelDriftInputError(f"{label} must not be empty.")
    return tuple(sorted(set(entries)))


def require_enum_member(value: object, vocabulary: Sequence[str], label: str) -> str:
    """Require a value to be a member of an F3-owned vocabulary.

    Every enum member the drift modules emit passes through here, so a member F3
    renamed or removed fails at the producer instead of reaching the checkpoint
    and being rejected by the validator.

    Args:
        value (object): The candidate member.
        vocabulary (Sequence[str]): The F3-owned member tuple, imported from
            ``_parallel_state_common`` by the calling module.
        label (str): Field label rendered into the error message.

    Returns:
        str: The validated member, unchanged.

    Raises:
        ParallelDriftInputError: If the value is outside the vocabulary.
    """
    if value not in vocabulary:
        raise ParallelDriftInputError(
            f"{label} must be one of {', '.join(vocabulary)}; found: {value!r}."
        )
    return cast("str", value)


def as_item_key(value: object) -> int | None:
    """Read a value as an item key without raising.

    Args:
        value (object): Any deserialized checkpoint value.

    Returns:
        int | None: The key when the value is a positive, non-boolean integer,
        otherwise ``None``.
    """
    if not is_positive_integer(value):
        return None
    return cast("int", value)


def record_paths(value: object) -> tuple[str, ...] | None:
    """Read a checkpoint value as a path collection without raising.

    Args:
        value (object): Any deserialized checkpoint value.

    Returns:
        tuple[str, ...] | None: The entries verbatim when the value is a list of
        non-empty strings, otherwise ``None``. An empty list yields an empty
        tuple, which callers distinguish from ``None`` where emptiness matters.
    """
    if not is_string_list(value):
        return None
    return tuple(cast("list[str]", value))


def is_later_canonical_timestamp(candidate: object, reference: object) -> bool:
    """Report whether a candidate timestamp is strictly later than a reference.

    Both values must carry the canonical ``yyyy-MM-ddTHH-mm`` shape before the
    ordinal comparison is allowed to decide anything. Without that requirement the
    comparison fails open: ordinally ``-`` (0x2D) sorts below ``:`` (0x3A), so a
    colon-bearing candidate such as ``2026-01-09T10:00:00Z`` compares greater than
    the hyphen-bearing reference ``2026-01-09T10-00`` even though the two name the
    same instant, reporting a strictly later timestamp where none exists.

    Args:
        candidate (object): The value asserted to be later, typically a
            ``blast_radius.computed_at`` read from a checkpoint.
        reference (object): The value compared against, typically a drift event's
            ``at``.

    Returns:
        bool: ``True`` only when both values are strings matching
        ``CANONICAL_TIMESTAMP_RE`` and ``candidate`` is ordinally greater than
        ``reference``. ``False`` for every other input, including a non-string, a
        blank string, or a non-conforming shape on either side, so a
        non-conforming value is treated as "not later" rather than as later.
    """
    if not isinstance(candidate, str) or not isinstance(reference, str):
        return False
    if re.match(CANONICAL_TIMESTAMP_RE, candidate) is None:
        return False
    if re.match(CANONICAL_TIMESTAMP_RE, reference) is None:
        return False
    return candidate > reference


def canonical_pair(first: int, second: int) -> tuple[int, int]:
    """Normalize two item keys into the canonical ``a < b`` edge identity.

    Args:
        first (int): One item key.
        second (int): The other item key.

    Returns:
        tuple[int, int]: The pair in ascending order, so an edge recorded in
        either order has one identity (F3 invariant 15).
    """
    return (first, second) if first < second else (second, first)
