"""Compute the deterministic complexity-band floor from present floor signals.

Purpose:
    Provide the canonical, tested reference implementation of the
    complexity-floor formula documented in
    `.claude/skills/orchestrate/SKILL.md` (`## Model Selection`) and
    `config/orchestration-routing.json` (`model_policy.complexity`). Each
    signal flagged ``[floor]`` in the `model_policy.complexity` signal catalog
    contributes a candidate band of ``C3``; the floor is the maximum triggered
    candidate band across all present floor signals. Floors never exceed
    ``C3``: ``C4`` is a judgment-only band and is never floor-forced.

Responsibilities:
    Given the sequence of present floor signals (the caller consults the
    `model_policy.complexity` catalog to select which present signals carry the
    ``[floor]`` flag), return the deterministic lower-bound band. This module
    does not read the routing config or any other file; it operates purely on
    the sequence passed in by the caller and encodes only the fixed band
    ordering and the uniform floor-candidate band.

Usage:
    Callers (for example the orchestrator or atomic-planner at model-selection
    time) filter the assessed phase's present signals to those flagged
    ``[floor]`` in the catalog, then pass those signal names to
    ``compute_complexity_floor``. The returned band is the lower bound the
    assessed ``band`` must satisfy (``band >= floor``). The complexity
    validator (`scripts.dev_tools._orchestrator_state_complexity`) recomputes
    this floor to check checkpoint receipts.

Invariants / Constraints:
    - Each present floor signal contributes the candidate band ``C3``.
    - The floor is the maximum triggered candidate band; with no floor signals
      present the floor is the lowest band ``C1``.
    - The floor never exceeds ``C3``; ``C4`` is never returned.
    - The function is pure and deterministic: identical ``signals_present``
      inputs yield identical output, independent of ordering.

Side Effects:
    None.
"""

from __future__ import annotations

from typing import TYPE_CHECKING, Literal

if TYPE_CHECKING:
    from collections.abc import Sequence

# The fixed complexity-band vocabulary, ordered from lowest to highest rigor.
# The tuple order defines "higher" and "lower" band comparisons used by both
# this floor computation and the complexity validator's ``band >= floor`` check.
ComplexityBand = Literal["C1", "C2", "C3", "C4"]
BAND_ORDER: tuple[ComplexityBand, ...] = ("C1", "C2", "C3", "C4")

# The lowest band, returned when no floor signal is present.
LOWEST_BAND: ComplexityBand = "C1"
# Every present floor signal contributes this uniform candidate band, per the
# `model_policy.complexity` contract (each ``[floor]`` signal contributes C3).
FLOOR_CANDIDATE_BAND: ComplexityBand = "C3"
# Floors never exceed this ceiling; ``C4`` is judgment-only and never
# floor-forced, so the computed floor is clamped to at most ``C3``.
FLOOR_CEILING_BAND: ComplexityBand = "C3"


def compute_complexity_floor(signals_present: Sequence[str]) -> ComplexityBand:
    """Compute the complexity-band floor from the present floor signals.

    Purpose:
        Return the deterministic lower-bound complexity band implied by the
        set of present floor signals, per the `model_policy.complexity`
        contract: each present floor signal contributes a candidate band of
        ``C3``, the floor is the maximum triggered candidate band, and the
        floor never exceeds ``C3``.

    Args:
        signals_present (Sequence[str]): The names of the present signals that
            are flagged ``[floor]`` in the `model_policy.complexity` catalog.
            The caller consults the catalog to select these; every element is
            treated as a triggered floor signal contributing the candidate
            band ``C3``. An empty sequence means no floor signal is present.

    Returns:
        ComplexityBand: The floor band. ``C1`` when no floor signal is present;
        otherwise the maximum triggered candidate band, clamped so it never
        exceeds ``C3``. ``C4`` is never returned.

    Raises:
        None.

    Side Effects:
        None. This function is pure: it reads no file and does not mutate the
        input ``signals_present``.
    """

    # With no present floor signal there is no candidate band to raise the
    # floor above the lowest band, so the floor is C1.
    if not signals_present:
        return LOWEST_BAND

    # Each present floor signal contributes the uniform candidate band; the
    # floor is the maximum triggered candidate rank across all of them.
    candidate_rank = BAND_ORDER.index(FLOOR_CANDIDATE_BAND)
    highest_rank = max(candidate_rank for _ in signals_present)

    # Clamp with min so the floor can never exceed C3; this is what keeps C4
    # from ever being floor-forced regardless of how many signals are present.
    floor_rank = min(highest_rank, BAND_ORDER.index(FLOOR_CEILING_BAND))
    return BAND_ORDER[floor_rank]
