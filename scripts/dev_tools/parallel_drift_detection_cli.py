"""Command-line boundary for parallel radius-drift detection.

Purpose:
    Give the parallel-orchestrator one invocation that performs design section 7
    steps 1, 4, and 5 -- escape detection, conflict recomputation against the
    observed radius, and later-started halt selection -- and prints the result as
    JSON. This module and its reader sibling ``_parallel_drift_cli_io`` are the
    only places in the drift feature that touch the filesystem, the clock, or
    stdout; ``parallel_drift_detection`` and ``parallel_drift_halt`` stay pure so
    their verdicts are reproducible.

Responsibilities:
    Parse arguments, load the parallel checkpoint and ``config/blast-radius.json``
    through ``_parallel_drift_cli_io``, forward the loaded data to the pure
    functions, and serialize their output. No detection, subsumption, contention,
    or tie-break rule is implemented here; each is imported. The changed-path list
    is an argument, not something this module derives: the caller produces it with
    ``git diff --name-only <merge-base(origin/main, HEAD)> HEAD`` at the child's
    pre-review commit, and this module executes no git command of its own. Only the
    standard library and existing repository modules are used; no dependency is
    added.

Argument surface:
    ``CHANGED_PATH...`` -- zero or more observed repository-relative paths
    (positional, variadic). An empty list is legal and yields ``no_escape``.
    ``--item-key`` -- required ``issue_num`` of the item whose diff is evaluated.
    ``--checkpoint`` -- parallel checkpoint path; defaults to
    ``artifacts/orchestration/parallel-orchestrator-state.json``.
    ``--config`` -- blast-radius truth table path; defaults to
    ``config/blast-radius.json``.
    ``--at`` -- ISO-8601 timestamp recorded on the ``drift_events[]`` entry.
    ``--computed-at`` -- ISO-8601 timestamp recorded on the observed radius.

Timestamp defaults:
    The pure functions require ``at`` and ``computed_at`` as inputs and never read
    a clock. Both are therefore CLI arguments. When ``--at`` is omitted it defaults
    to the current UTC instant formatted ``yyyy-MM-ddTHH-mm``, derived here at the
    I/O boundary; when ``--computed-at`` is omitted it defaults to the resolved
    ``at`` value, so one detection pass carries one instant.

Stdout contract:
    On success a single JSON object is printed, with these keys::

        {
          "result": "no_escape" | "no_new_conflict" | "halt_required",
          "item_key": <int>,                        # the evaluated item's issue_num
          "at": <str>,                              # resolved --at
          "computed_at": <str>,                     # resolved --computed-at
          "escaped_paths": [<str>, ...],            # empty when result is no_escape
          "newly_conflicting_pairs": [[<int>, <int>], ...],
          "halted_item_keys": [<int>, ...],         # one per newly conflicting pair
          "drift_event": {<six section-12 fields>} | null
        }

    ``result`` is the explicit verdict: ``no_escape`` means the diff stayed inside
    the declared radius; ``no_new_conflict`` means paths escaped but the observed
    radius introduced no contention, so nothing is halted; ``halt_required`` means
    at least one pair newly conflicts and ``halted_item_keys`` names the
    later-started item of each. ``drift_event`` is ``null`` exactly when ``result``
    is ``no_escape``, because F3 invariant 18 rejects an event with zero escaped
    paths. Errors are written to stderr, never to stdout, so a caller can parse
    stdout unconditionally.

Exit codes:
    ``0`` on success, ``1`` when an input is missing or malformed, and argparse's
    own ``2`` for a usage error.
"""

from __future__ import annotations

import argparse
import json
import sys
from datetime import datetime, timezone
from pathlib import Path
from typing import TYPE_CHECKING, cast

from scripts.dev_tools._parallel_drift_cli_io import (
    checkpoint_items,
    conflict_edges,
    declared_paths,
    item_by_key,
    load_mapping,
)
from scripts.dev_tools.parallel_drift_detection import (
    DRIFT_ACTION_HALTED_LATER_STARTED_ITEM,
    DRIFT_ACTION_RAISED_BLOCKING_FINDING,
    ItemStart,
    build_drift_event,
    detect_escaped_paths,
    recompute_conflicts_with_observed,
    select_halted_item,
)

if TYPE_CHECKING:
    from collections.abc import Mapping, Sequence

__all__ = [
    "RESULT_HALT_REQUIRED",
    "RESULT_NO_ESCAPE",
    "RESULT_NO_NEW_CONFLICT",
    "build_parser",
    "default_timestamp",
    "evaluate_drift",
    "main",
]

# Default artifact locations. The checkpoint path is the literal value F5 emits in
# the ``Parallel mode: true`` kickoff marker, so a child invoking this module with
# no ``--checkpoint`` reads the same file the parent wrote.
DEFAULT_CHECKPOINT_PATH = "artifacts/orchestration/parallel-orchestrator-state.json"
DEFAULT_CONFIG_PATH = "config/blast-radius.json"

# The three ``result`` verdicts, one per terminal state of the six-step procedure.
RESULT_NO_ESCAPE = "no_escape"
RESULT_NO_NEW_CONFLICT = "no_new_conflict"
RESULT_HALT_REQUIRED = "halt_required"

# Repository timestamp shape, colon-free so a value is safe in a Windows filename.
TIMESTAMP_FORMAT = "%Y-%m-%dT%H-%M"

EXIT_OK = 0
EXIT_INPUT_ERROR = 1


def default_timestamp() -> str:
    """Return the current instant in the repository timestamp shape.

    This is the module's only clock read and exists so the pure functions can keep
    taking every timestamp as an input. UTC is used rather than local time so two
    machines evaluating the same commit produce comparable values.

    Returns:
        str: The current UTC instant formatted ``yyyy-MM-ddTHH-mm``.

    Side Effects:
        Reads the system clock.
    """
    return datetime.now(tz=timezone.utc).strftime(TIMESTAMP_FORMAT)


def build_parser() -> argparse.ArgumentParser:
    """Build the argument parser for the drift-detection entry point.

    Returns:
        argparse.ArgumentParser: A parser whose only required argument is
        ``--item-key``. The changed-path list is variadic and may be empty,
        because an item that changed nothing outside its radius is a normal
        outcome rather than a usage error.

    Side Effects:
        None.
    """
    parser = argparse.ArgumentParser(
        prog="parallel-drift-detection",
        description=(
            "Detect radius drift for one in-flight parallel item, recompute "
            "contention with the observed radius, and select the later-started "
            "item to halt. Prints one JSON object to stdout."
        ),
    )
    parser.add_argument(
        "changed_paths",
        nargs="*",
        metavar="CHANGED_PATH",
        help=(
            "Observed repository-relative paths, as produced by "
            "'git diff --name-only <merge-base(origin/main, HEAD)> HEAD'. "
            "This module runs no git command itself."
        ),
    )
    parser.add_argument(
        "--item-key",
        type=int,
        required=True,
        help="issue_num of the item whose diff is evaluated.",
    )
    parser.add_argument(
        "--checkpoint",
        default=DEFAULT_CHECKPOINT_PATH,
        help=f"Parallel checkpoint path (default: {DEFAULT_CHECKPOINT_PATH}).",
    )
    parser.add_argument(
        "--config",
        default=DEFAULT_CONFIG_PATH,
        help=f"Blast-radius truth table path (default: {DEFAULT_CONFIG_PATH}).",
    )
    parser.add_argument(
        "--at",
        default=None,
        help=(
            "ISO-8601 timestamp recorded on the drift_events[] entry "
            "(default: the current UTC instant as yyyy-MM-ddTHH-mm)."
        ),
    )
    parser.add_argument(
        "--computed-at",
        default=None,
        help=(
            "ISO-8601 timestamp recorded on the observed radius "
            "(default: the resolved --at value)."
        ),
    )
    return parser


def evaluate_drift(
    *,
    state: Mapping[str, object],
    config: Mapping[str, object],
    item_key: int,
    changed_paths: Sequence[str],
    at: str,
    computed_at: str,
) -> dict[str, object]:
    """Run the detection steps over already-loaded data and build the result.

    This function performs no I/O: the checkpoint and the config arrive as parsed
    mappings and both timestamps arrive as strings, so every decision it reports
    is reproducible from its arguments alone.

    Args:
        state (Mapping[str, object]): The parsed parallel checkpoint. ``items[]``
            and ``conflict_edges[]`` are read; nothing is written back.
        config (Mapping[str, object]): Parsed ``config/blast-radius.json``,
            forwarded to F1's library.
        item_key (int): ``issue_num`` of the item whose diff is evaluated.
        changed_paths (Sequence[str]): The observed changed-path set. May be empty.
        at (str): Timestamp recorded on the ``drift_events[]`` entry.
        computed_at (str): Timestamp recorded on the observed radius.

    Returns:
        dict[str, object]: The stdout payload documented in the module docstring.

    Raises:
        DriftCliInputError: If the checkpoint's ``items[]`` or
            ``conflict_edges[]`` collection is unusable, or if no item carries
            ``item_key``.
        ParallelDriftInputError: If a path collection, timestamp, or item key is
            malformed, raised by the pure modules.
        TypeError: If ``config`` is not a mapping, raised by F1's library.

    Side Effects:
        None.
    """
    items = checkpoint_items(state)
    declared = declared_paths(item_by_key(items, item_key))
    escaped = detect_escaped_paths(changed_paths, declared)

    pairs: tuple[tuple[int, int], ...] = ()
    halted: tuple[int, ...] = ()
    event: dict[str, object] | None = None
    result = RESULT_NO_ESCAPE

    # An escape is the precondition for every later step: with nothing outside the
    # declared radius there is no drift event to record, no radius to substitute,
    # and no item to halt. The A8 recording rule then fixes the action, because
    # halting subsumes raising the finding and only one event is written.
    if escaped:
        pairs = recompute_conflicts_with_observed(
            items,
            item_key,
            changed_paths,
            conflict_edges(state),
            config,
            computed_at=computed_at,
        )
        halted = _halted_item_keys(items, pairs)
        result = RESULT_HALT_REQUIRED if pairs else RESULT_NO_NEW_CONFLICT
        event = build_drift_event(
            item_key=item_key,
            declared=declared,
            observed=changed_paths,
            escaped_paths=escaped,
            at=at,
            action=(
                DRIFT_ACTION_HALTED_LATER_STARTED_ITEM
                if pairs
                else DRIFT_ACTION_RAISED_BLOCKING_FINDING
            ),
        )

    return {
        "result": result,
        "item_key": item_key,
        "at": at,
        "computed_at": computed_at,
        "escaped_paths": list(escaped),
        "newly_conflicting_pairs": [list(pair) for pair in pairs],
        "halted_item_keys": list(halted),
        "drift_event": event,
    }


def main(argv: Sequence[str] | None = None) -> int:
    """Parse arguments, run detection, and print the JSON result.

    Args:
        argv (Sequence[str] | None): Argument vector excluding the program name.
            ``None`` reads ``sys.argv[1:]``, which is how a console invocation
            reaches this function.

    Returns:
        int: ``EXIT_OK`` when the result was printed, ``EXIT_INPUT_ERROR`` when an
        input file or field was missing or malformed. A usage error exits through
        argparse with status 2 instead of returning.

    Raises:
        SystemExit: Propagated from argparse on a usage error or ``--help``.

    Side Effects:
        Reads the two input files, reads the clock when a timestamp argument is
        omitted, writes the result to stdout, and writes a diagnostic to stderr.
    """
    args = build_parser().parse_args(argv)
    at = cast("str | None", args.at) or default_timestamp()
    computed_at = cast("str | None", args.computed_at) or at

    # One boundary handler for every data defect: the readers and the pure modules
    # both report malformed input as ``ValueError`` subclasses, and F1's library
    # reports a non-mapping config as ``TypeError``, so the caller sees one exit
    # code and one stderr line instead of a traceback.
    try:
        result = evaluate_drift(
            state=load_mapping(
                Path(cast("str", args.checkpoint)), "Parallel checkpoint"
            ),
            config=load_mapping(Path(cast("str", args.config)), "Blast-radius config"),
            item_key=cast("int", args.item_key),
            changed_paths=cast("list[str]", args.changed_paths),
            at=at,
            computed_at=computed_at,
        )
    except (OSError, ValueError, TypeError) as error:
        print(f"parallel drift detection failed: {error}", file=sys.stderr)
        return EXIT_INPUT_ERROR

    print(json.dumps(result, indent=2, sort_keys=True))
    return EXIT_OK


def _start_markers(items: Sequence[Mapping[str, object]]) -> dict[int, ItemStart]:
    """Index the start-of-execution markers halt selection compares.

    Args:
        items (Sequence[Mapping[str, object]]): The checkpoint's item records.
            Every ``issue_num`` was already validated by conflict recomputation,
            so no key check is repeated here.

    Returns:
        dict[int, ItemStart]: Item key mapped to its start marker. F3 marks
        ``worktree_created_at`` optional, so an absent value becomes ``None`` and
        means "start unknown", which the selection rule handles.

    Raises:
        ParallelDriftInputError: If a record's ``issue_num`` or
            ``worktree_created_at`` is malformed, raised by ``ItemStart``.

    Side Effects:
        None.
    """
    # Build one marker per item so a pair of keys can be resolved without
    # rescanning the collection for each conflicting pair.
    markers: dict[int, ItemStart] = {}
    for record in items:
        marker = ItemStart(
            item_key=cast("int", record.get("issue_num")),
            worktree_created_at=cast("str | None", record.get("worktree_created_at")),
        )
        markers[marker.item_key] = marker
    return markers


def _halted_item_keys(
    items: Sequence[Mapping[str, object]],
    pairs: Sequence[tuple[int, int]],
) -> tuple[int, ...]:
    """Select the later-started item of every newly conflicting pair.

    Args:
        items (Sequence[Mapping[str, object]]): The checkpoint's item records,
            read for the start markers.
        pairs (Sequence[tuple[int, int]]): The canonical newly conflicting pairs
            returned by conflict recomputation.

    Returns:
        tuple[int, ...]: The item keys to halt, deduplicated and ascending. Empty
        when no pair newly conflicts. The common case is one pair and therefore
        one key; several pairs each contribute their own later-started item, and
        the selection rule is applied per pair rather than across pairs.

    Raises:
        ParallelDriftInputError: If a start marker is malformed, or if a pair
            names one item twice, raised by ``select_halted_item``.

    Side Effects:
        None.
    """
    if not pairs:
        return ()

    markers = _start_markers(items)
    # Apply the later-started rule to each pair independently; a set collapses the
    # repeats that arise when one item is the later-started member of two pairs.
    halted = {
        select_halted_item(markers[first], markers[second]) for first, second in pairs
    }
    return tuple(sorted(halted))


if __name__ == "__main__":
    raise SystemExit(main())
