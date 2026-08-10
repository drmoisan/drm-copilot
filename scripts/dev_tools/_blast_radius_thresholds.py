"""Numeric threshold readers for the blast-radius truth table.

Purpose:
    Own the reader that lifts the V3 over-breadth threshold out of the parsed
    ``config/blast-radius.json`` truth table, together with the config key it
    reads. Separating the threshold reader from the validation module keeps
    ``scripts/dev_tools/_blast_radius_validation.py`` inside the repository's
    500-line file limit without relocating that module's input guards.

Responsibilities:
    Read and range-check the over-breadth fraction. Guarding caller-supplied
    values, resolving the truth table's surface and module lists, and emitting
    the V1, V2, and V3 findings all remain in
    ``scripts/dev_tools/_blast_radius_validation.py``. This module holds no
    finding vocabulary and constructs no ``RadiusFinding``.

Usage:
    ``scripts/dev_tools/_blast_radius_validation.py`` is the sole in-repo
    consumer: ``_over_breadth_findings`` calls ``config_over_breadth_fraction``
    to obtain the fraction it compares the concrete coverage against. The
    PowerShell mirror is ``Get-ConfigOverBreadthFraction`` in
    ``.claude/lib/blast-radius/BlastRadiusConfig.psm1``, which reproduces this
    rule; this module remains the authoritative reference.

Invariants / Constraints:
    - This module is a leaf of the blast-radius import graph: it imports no
      ``_blast_radius_*`` sibling, which is what keeps the graph acyclic.
    - The accepted range is the half-open interval ``(0, 1]``. A zero or
      negative fraction would report every radius as over-broad and a fraction
      above one would make the rule unreachable, so both are rejected.
    - Booleans are rejected explicitly, because Python treats ``True`` and
      ``False`` as integers and a boolean would otherwise pass the range test.

Side Effects:
    None. The function is pure, mutates no input, and performs no filesystem,
    subprocess, network, or wall-clock access.
"""

from __future__ import annotations

from typing import TYPE_CHECKING

if TYPE_CHECKING:
    from collections.abc import Mapping

# Key read from the parsed ``config/blast-radius.json`` truth table.
CONFIG_OVER_BREADTH_FRACTION = "over_breadth_fraction"


def config_over_breadth_fraction(config: Mapping[str, object]) -> float:
    """Read the V3 over-breadth threshold from the truth table.

    Args:
        config (Mapping[str, object]): Parsed ``config/blast-radius.json``.

    Returns:
        float: The fraction of tracked files above which a radius is over-broad.

    Raises:
        TypeError: If the entry is absent or is not a real number.
        ValueError: If the entry is outside ``(0, 1]``.
    """
    # Booleans are rejected explicitly because Python treats them as integers.
    value = config.get(CONFIG_OVER_BREADTH_FRACTION)
    if isinstance(value, bool) or not isinstance(value, (int, float)):
        raise TypeError(
            f'config["{CONFIG_OVER_BREADTH_FRACTION}"] must be a number in (0, 1].'
        )
    if not 0 < value <= 1:
        raise ValueError(
            f'config["{CONFIG_OVER_BREADTH_FRACTION}"] must be within (0, 1].'
        )
    return float(value)
