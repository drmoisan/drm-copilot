"""Mode-dependent completion invariant for the parallel checkpoint (FR9 3).

Purpose:
    Enforce the spec FR7 completion semantics retrospectively on the checkpoint:
    an ``open``-mode run never auto-completes, and a ``closed``-mode run that has
    recorded completion must satisfy the completion predicate.

Responsibilities and usage:
    This module is a private implementation detail of
    ``scripts/dev_tools/_parallel_orchestrator_state_mutations.py``, which
    re-exports ``validate_mode_completion`` through its own entry point; callers
    import from that module, not this one. It lives apart only so neither file
    exceeds the repository's 500-line limit, the same arrangement F3 uses for
    ``_parallel_state_records.py``.

Completion signals, stated explicitly because the schema carries no dedicated
completion field and none may be added:
    The F3 schema carries two signals that a run recorded completion, and no
    third: the run-close record (a ``mutations[]`` entry with ``op == 'close'``)
    and the absence of any current-generation cohort still holding an item key,
    which means no schedulable work remains. Both rules are expressed over those
    signals.

    In ``open`` mode the close record TERMINATES the run (FR3), so nothing may
    follow it: a mutation appended after the close record means the run was
    treated as completing automatically and then continuing, which is exactly
    what ``open`` mode forbids.

    In ``closed`` mode completion is decided by the predicate rather than by an
    explicit close, so a ``closed``-mode checkpoint that records BOTH signals is
    asserting completion and must satisfy the predicate: every non-withdrawn item
    must carry a terminal ``merge_status``.

    The conjunction is deliberate and neither signal alone is sufficient. A
    ``closed``-mode run may legitimately record a close entry while items are
    still scheduled, which F3 accepts today, so the close record alone must not
    trip the gate. Equally, a run with no schedulable work but no close record has
    not asserted completion -- a blocked item legitimately sits outside every
    cohort under F3 invariant 13 -- so the empty-cohort signal alone must not trip
    it either. No rule fires on a healthy in-progress checkpoint: an ``open``-mode
    run whose items have all merged but which has not been closed is a legitimate
    idle state, still accepting admissions, and is deliberately NOT reported,
    because reporting it would block the next ``/parallel-add``.

Key invariants and constraints:
    The gate is KEY-GATED. It requires a well-formed ``mode``, a list-shaped
    ``items``, and a recorded run-close entry; anything else has already produced
    its own F3 error, so no error is added here. No field and no enum member is
    added to any F3 structure or enum: every member set is imported from
    ``scripts/dev_tools/_parallel_state_common.py``. No JSON Schema file is
    imported or read.

Raises and side effects:
    None anywhere in this module. Every function is pure: it raises nothing,
    performs no I/O, and reads but never mutates its arguments. Individual
    docstrings therefore omit the ``Raises`` and ``Side Effects`` sections that
    this module-wide statement already covers.
"""

from __future__ import annotations

from typing import cast

from scripts.dev_tools._parallel_state_common import (
    MERGED_MERGE_STATUSES,
    VALID_MODES,
    item_context,
)

# The single entry point the sibling mutation-protocol helper calls. Listing it
# here marks the re-export as deliberate so static analysis does not read the
# module as unused.
__all__ = ["validate_mode_completion"]

# Checkpoint keys this gate reads, named so each gate condition reads as the key
# it depends on.
ITEMS_KEY = "items"
MODE_KEY = "mode"
COHORTS_KEY = "cohorts"
GENERATION_KEY = "recolor_generation"

# The run-level operation that records a run close; the schema's only completion
# record and therefore the anchor of both rules.
CLOSE_OP = "close"

# The item state exempt from the completion predicate: a withdrawn item left the
# run before reaching a merge outcome (F3 invariant 20).
WITHDRAWN_ITEM_STATE = "withdrawn"

# The ``merge_status`` F3 reads for an item that records none (invariant 7).
DEFAULT_MERGE_STATUS = "not_started"

# The mode whose completion is explicit; ``closed`` is the routing default, so
# only the open-mode name is needed to select between the two rules.
OPEN_MODE = "open"


def _entry_context(context: str, position: int) -> str:
    """Render the context prefix for one ``mutations[]`` entry.

    Args:
        context (str): Surface prefix, for example ``Parallel checkpoint``.
        position (int): Zero-based position of the entry within ``mutations``.

    Returns:
        str: The entry-scoped prefix, matching the prefix
        ``_parallel_state_records.py`` emits so both modules' errors read alike.
    """

    return f"{context} mutations[{position}]"


def _close_entry_positions(entries: list[object]) -> list[int]:
    """Locate every run-close record in the mutation log.

    Args:
        entries (list[object]): The checkpoint's ``mutations`` list.

    Returns:
        list[int]: Ascending positions of the entries whose ``op`` is ``close``.
        Entry shape is not re-checked; F3 already reported any malformed record.
    """

    # Collect all close positions rather than the first, so the open-mode rule
    # can anchor on the earliest one and report everything appended after it.
    return [
        position
        for position, entry in enumerate(entries)
        if isinstance(entry, dict)
        and cast("dict[str, object]", entry).get("op") == CLOSE_OP
    ]


def _validate_open_mode_termination(
    entries: list[object], close_position: int, context: str
) -> list[str]:
    """Require the run-close record to be final in ``open`` mode (FR7).

    An ``open``-mode run never auto-completes: it terminates only through
    ``/parallel-close``, and that close is the run's last act. A mutation appended
    after the close record therefore records a run that completed and then kept
    mutating, which is the auto-completion ``open`` mode forbids.

    Args:
        entries (list[object]): The checkpoint's ``mutations`` list.
        close_position (int): Position of the earliest run-close record.
        context (str): Surface prefix, for example ``Parallel checkpoint``.

    Returns:
        list[str]: One error per entry appended after the close record, in
        positional order, so the full trail of post-termination mutation is
        reported instead of only its first entry.
    """

    errors: list[str] = []
    # Report every subsequent entry: each one is a separate mutation applied to a
    # run the checkpoint already recorded as terminated.
    for position, entry in enumerate(entries):
        if position <= close_position or not isinstance(entry, dict):
            continue
        op = cast("dict[str, object]", entry).get("op")
        errors.append(
            f"{_entry_context(context, position)} records op {op!r} after the "
            f"run-close entry at mutations[{close_position}]; an open-mode run "
            f"terminates at the close record and must not auto-complete."
        )
    return errors


def _has_schedulable_work(state: dict[str, object]) -> bool:
    """Report whether any current-generation cohort still holds an item key.

    This is the second of the schema's two completion signals. A run whose
    current-generation cohorts hold no key has nothing left to schedule, which
    together with the run-close record is what the ``closed``-mode rule treats as
    a recorded completion.

    Args:
        state (dict[str, object]): The parsed checkpoint object.

    Returns:
        bool: True when some cohort of the current generation carries at least one
        item key. A malformed ``cohorts`` value also returns True, so the gate
        stays silent on data F3 has already reported rather than inferring
        completion from a shape it cannot read.
    """

    cohorts = state.get(COHORTS_KEY)
    if not isinstance(cohorts, list):
        return True
    generation = state.get(GENERATION_KEY)

    # Scan only the cohorts of the current generation: earlier generations are
    # superseded history and say nothing about work still to schedule.
    for entry in cast("list[object]", cohorts):
        if not isinstance(entry, dict):
            continue
        record = cast("dict[str, object]", entry)
        if record.get("generation") != generation:
            continue
        item_keys = record.get("item_keys")
        if isinstance(item_keys, list) and cast("list[object]", item_keys):
            return True
    return False


def _validate_closed_mode_completion(items: list[object], context: str) -> list[str]:
    """Require the completion predicate to hold for a completed ``closed`` run.

    Reached only when the checkpoint records both completion signals: the
    run-close entry and no remaining schedulable work. The predicate must then
    hold -- every non-withdrawn item must carry a terminal ``merge_status``. A
    withdrawn item is exempt because it left the run before reaching a merge
    outcome, so requiring a terminal status of it would make every run that
    dropped an item permanently incompletable.

    Args:
        items (list[object]): The checkpoint's ``items`` list.
        context (str): Surface prefix, for example ``Parallel checkpoint``.

    Returns:
        list[str]: One error per non-withdrawn item lacking a terminal merge
        status, in positional order, so the gate reports all remaining work rather
        than the first unfinished item.
    """

    errors: list[str] = []
    # Check every item so the report names the full set of items that contradict
    # the recorded completion, not just the first one found.
    for index, entry in enumerate(items):
        if not isinstance(entry, dict):
            continue
        record = cast("dict[str, object]", entry)
        if record.get("state") == WITHDRAWN_ITEM_STATE:
            continue
        merge_status = record.get("merge_status", DEFAULT_MERGE_STATUS)
        if merge_status not in MERGED_MERGE_STATUSES:
            errors.append(
                f"{item_context(context, index)} completion invariant failed: "
                f"closed mode records a mutations[] op 'close' entry but "
                f"merge_status is not merged or worktree_removed; "
                f"found: {merge_status!r}."
            )
    return errors


def validate_mode_completion(
    state: dict[str, object], entries: list[object], context: str
) -> list[str]:
    """Apply the mode-dependent completion invariant (FR9 invariant 3).

    Both rules are anchored on the run-close record. The routing is: ``open`` mode
    requires the close to be the run's final act, while ``closed`` mode requires a
    recorded close that is also backed by an empty current-generation cohort set
    to satisfy the completion predicate. A checkpoint recording no close has not
    recorded completion in either mode and is therefore not checked, which is what
    keeps a healthy in-progress run -- including an idle ``open`` run whose items
    have all merged -- free of errors.

    Args:
        state (dict[str, object]): The parsed checkpoint object. Read only.
        entries (list[object]): The checkpoint's ``mutations`` list.
        context (str): Surface prefix, for example ``Parallel checkpoint``.

    Returns:
        list[str]: The errors of whichever mode-specific rule applied, or an empty
        list when the gate does not apply. The gate requires a well-formed
        ``mode`` and a list-shaped ``items``; either being malformed has already
        produced its own F3 error, so no error is added here.
    """

    mode = state.get(MODE_KEY)
    if mode not in VALID_MODES:
        return []
    items = state.get(ITEMS_KEY)
    if not isinstance(items, list):
        return []

    close_positions = _close_entry_positions(entries)
    if not close_positions:
        return []

    if mode == OPEN_MODE:
        return _validate_open_mode_termination(entries, close_positions[0], context)
    # Closed mode needs the second signal too: a close recorded while work is
    # still schedulable is not an assertion of completion, so the gate is silent.
    if _has_schedulable_work(state):
        return []
    return _validate_closed_mode_completion(cast("list[object]", items), context)
