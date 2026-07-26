"""Compute the deterministic complexity-band floor from present floor signals.

Purpose:
    Provide the canonical, tested reference implementation of the
    complexity-floor formula documented in
    `.claude/skills/orchestrate/SKILL.md` (`## Model Selection`) and
    `config/orchestration-routing.json` (`model_policy.complexity`). Each
    signal flagged ``"floor": true`` in the `model_policy.complexity` signal
    catalog contributes a candidate band of ``C3``; the floor is the maximum
    triggered candidate band across all present floor signals. Floors never
    exceed ``C3``: ``C4`` is a judgment-only band and is never floor-forced.

Responsibilities:
    Given the full sequence of signals recorded as present for an assessed
    phase, filter it internally against the embedded floor-signal name set and
    return the deterministic lower-bound band. This module does not read the
    routing config or any other file; the floor-signal names are embedded here
    as ``FLOOR_SIGNAL_NAMES`` and pinned to the config's ``"floor": true``
    entries by a static parity test in
    ``tests/scripts/dev_tools/test_compute_complexity_floor.py``.

Usage:
    Callers (for example the orchestrator or atomic-planner at model-selection
    time) pass the assessed phase's full ``signals_present`` list to
    ``compute_complexity_floor``; no caller-side pre-filtering is required or
    expected. The returned band is the lower bound the assessed ``band`` must
    satisfy (``band >= floor``). The complexity validator
    (`scripts.dev_tools._orchestrator_state_complexity`) recomputes this floor
    over the full recorded array to check checkpoint receipts.

Invariants / Constraints:
    - Each present signal named in ``FLOOR_SIGNAL_NAMES`` contributes the
      candidate band ``C3``.
    - A signal flagged ``"floor": false`` in the catalog, and any name outside
      the catalog entirely, contributes no floor candidate.
    - The floor is the maximum triggered candidate band; with no floor signal
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
# The catalog signals flagged ``"floor": true`` in
# ``config/orchestration-routing.json`` (`model_policy.complexity.signals`).
# Embedded rather than read at runtime because this module must stay pure and
# is consumed where the config file may not exist; a static parity test pins
# this set to the committed catalog so the two cannot drift apart.
FLOOR_SIGNAL_NAMES: frozenset[str] = frozenset(
    {
        "classifier_or_model_logic",
        "auth_or_token_handling",
        "concurrency_or_ordering",
        "cross_module_contract_change",
    }
)


def compute_complexity_floor(signals_present: Sequence[str]) -> ComplexityBand:
    """Compute the complexity-band floor from the present floor signals.

    Purpose:
        Return the deterministic lower-bound complexity band implied by the
        recorded present signals, per the `model_policy.complexity` contract:
        each present signal flagged ``"floor": true`` contributes a candidate
        band of ``C3``, the floor is the maximum triggered candidate band, and
        the floor never exceeds ``C3``.

    Args:
        signals_present (Sequence[str]): The full list of signal names recorded
            as present for the assessed phase. No caller-side pre-filtering is
            required: this function selects the floor signals itself by
            intersecting the input with ``FLOOR_SIGNAL_NAMES``. Names flagged
            ``"floor": false`` in the catalog, and names outside the catalog,
            contribute no floor candidate. An empty sequence, and a sequence
            holding no floor signal, both mean no floor signal is present.

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

    # Select the recorded signals that actually carry the floor flag; a
    # non-floor or unknown name contributes nothing.
    triggered_floor_signals = [
        signal for signal in signals_present if signal in FLOOR_SIGNAL_NAMES
    ]

    # With no present floor signal there is no candidate band to raise the
    # floor above the lowest band, so the floor is C1.
    if not triggered_floor_signals:
        return LOWEST_BAND

    # Each present floor signal contributes the uniform candidate band; the
    # floor is the maximum triggered candidate rank across all of them.
    candidate_rank = BAND_ORDER.index(FLOOR_CANDIDATE_BAND)
    highest_rank = max(candidate_rank for _ in triggered_floor_signals)

    # Clamp with min so the floor can never exceed C3; this is what keeps C4
    # from ever being floor-forced regardless of how many signals are present.
    floor_rank = min(highest_rank, BAND_ORDER.index(FLOOR_CEILING_BAND))
    return BAND_ORDER[floor_rank]
