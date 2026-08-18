"""Caller-supplied input guards shared by the blast-radius modules.

Purpose and responsibilities:
    Hold the three type-and-shape guards that every other blast-radius module
    depends on: ``require_text`` for strings, ``require_str_tuple`` for string
    collections, and ``require_mapping`` for the parsed truth table. Keeping
    them in a leaf module lets the validation, normalization, and contention
    layers share one implementation without importing one another.

Usage:
    ``scripts/dev_tools/_blast_radius_validation.py`` re-exports all three
    names, so the facade and the contention helper keep their existing import
    surface unchanged. New modules import from here directly.

Invariants, constraints, and side effects:
    Every guard is pure: it validates and returns its input without copying or
    mutating it, except ``require_str_tuple``, which returns a deduplicated and
    ordinally sorted tuple so parity with the PowerShell mirror holds. No
    filesystem, subprocess, network, or wall-clock access.
"""

from __future__ import annotations

from typing import TYPE_CHECKING, cast

if TYPE_CHECKING:
    from collections.abc import Mapping, Sequence


def require_text(value: object, field_name: str, *, allow_empty: bool = False) -> str:
    """Guard a caller-supplied value that must be a string.

    Args:
        value (object): Value of unknown runtime type.
        field_name (str): Name used in the error message.
        allow_empty (bool): When ``True`` a blank string is accepted.

    Returns:
        str: The validated value, unchanged.

    Raises:
        TypeError: If the value is not a string.
        ValueError: If the value is blank and ``allow_empty`` is ``False``.
    """
    if not isinstance(value, str):
        raise TypeError(f"{field_name} must be a string, got {type(value).__name__}.")
    if not allow_empty and not value.strip():
        raise ValueError(f"{field_name} must not be empty.")
    return value


def require_str_tuple(value: object, field_name: str) -> tuple[str, ...]:
    """Guard a caller-supplied string collection and normalize its order.

    Args:
        value (object): A list or tuple of non-blank strings. A bare string is
            rejected because accepting it would silently split into characters.
        field_name (str): Name used in the error message.

    Returns:
        tuple[str, ...]: Entries deduplicated and ordinally sorted for parity.

    Raises:
        TypeError: If the value is not a list or tuple, or holds a non-string.
        ValueError: If any entry is blank.
    """
    if not isinstance(value, (list, tuple)):
        raise TypeError(
            f"{field_name} must be a list or tuple, got {type(value).__name__}."
        )

    # Validate every entry before sorting so an error names the offending value
    # rather than a position in an already-reordered collection.
    entries: set[str] = set()
    for item in cast("Sequence[object]", value):
        entries.add(require_text(item, f"{field_name} entry"))

    return tuple(sorted(entries))


def require_mapping(value: object, field_name: str) -> Mapping[str, object]:
    """Guard a caller-supplied mapping such as the parsed truth table.

    Args:
        value (object): Value of unknown runtime type.
        field_name (str): Name used in the error message.

    Returns:
        Mapping[str, object]: The validated mapping, neither copied nor mutated.

    Raises:
        TypeError: If the value is not a mapping.
    """
    if not isinstance(value, dict):
        raise TypeError(f"{field_name} must be a mapping, got {type(value).__name__}.")
    return cast("Mapping[str, object]", value)
