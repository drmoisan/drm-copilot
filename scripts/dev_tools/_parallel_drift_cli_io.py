"""Filesystem and checkpoint readers for the drift-detection command line.

Purpose:
    Own the file read and the checkpoint-shaped accessors
    ``parallel_drift_detection_cli`` needs, so that module holds the argument
    surface and the detection flow only. Split out under the same
    underscore-prefixed convention ``_parallel_drift_shape`` uses, because the
    policy-mandated docstrings for both halves do not fit inside one 500-line
    file.

Responsibilities:
    Turn a path into a validated mapping, and turn a parsed checkpoint into the
    item and edge collections detection consumes. No detection, subsumption, or
    contention rule is implemented here, and no value is written back to any file.

Key invariants:
    An unusable collection is rejected rather than silently narrowed: a dropped
    item would never be evaluated against the observed radius, which is the
    under-reporting failure the drift feature exists to catch. The one deliberate
    exception is a non-object ``conflict_edges[]`` entry, which is omitted so a
    conflict over that pair is still reported as new -- the fail-closed direction
    the pure module already takes for an edge with unreadable endpoints.

Raises and side effects:
    ``read_json_file`` is the only function here that touches the filesystem; the
    accessors are pure. Every malformed-input failure is reported as
    ``DriftCliInputError``, a ``ValueError`` subclass, so the command line has one
    boundary handler.
"""

from __future__ import annotations

import json
from collections.abc import Mapping
from typing import TYPE_CHECKING, cast

if TYPE_CHECKING:
    from collections.abc import Sequence
    from pathlib import Path

__all__ = [
    "DriftCliInputError",
    "checkpoint_items",
    "conflict_edges",
    "declared_paths",
    "item_by_key",
    "load_mapping",
    "read_json_file",
]


class DriftCliInputError(ValueError):
    """Raised when a checkpoint or config file cannot be read as expected.

    Purpose:
        Distinguish a defect in the data the command line loaded -- a non-object
        JSON root, an unusable ``items[]`` collection, or an item key absent from
        the checkpoint -- from the malformed-argument failures the pure drift
        modules report as ``ParallelDriftInputError``.

    Responsibilities:
        Carry one literal message naming the offending file or field. The class
        validates nothing; the readers below detect each malformed mode and raise
        it.

    Usage:
        Raised by the readers in this module and caught once at the command
        line's boundary, which renders the message to stderr and returns a
        non-zero exit code. Because it subclasses ``ValueError``, a caller
        embedding these readers keeps working with an existing ``except
        ValueError`` handler.

    Side Effects:
        None.
    """


def read_json_file(path: Path) -> object:
    """Read and parse one JSON document.

    This is the drift command line's only filesystem read, and the seam its tests
    replace, so no test needs a temporary file.

    Args:
        path (Path): Location of the document.

    Returns:
        object: The deserialized document, of whatever JSON type it carries.

    Raises:
        OSError: If the file cannot be read.
        json.JSONDecodeError: If the text is not valid JSON. It subclasses
            ``ValueError``, so the command line's boundary handler catches it.

    Side Effects:
        Reads from the filesystem.
    """
    return json.loads(path.read_text(encoding="utf-8"))


def load_mapping(path: Path, label: str) -> Mapping[str, object]:
    """Read one JSON document and require an object root.

    Args:
        path (Path): Location of the document.
        label (str): Human-readable name rendered into the error message.

    Returns:
        Mapping[str, object]: The parsed object.

    Raises:
        DriftCliInputError: If the document's root is not a JSON object.
        OSError: If the file cannot be read.
        json.JSONDecodeError: If the text is not valid JSON.

    Side Effects:
        Reads from the filesystem through ``read_json_file``.
    """
    document = read_json_file(path)
    if not isinstance(document, Mapping):
        raise DriftCliInputError(f"{label} at {path} must be a JSON object.")
    return cast("Mapping[str, object]", document)


def checkpoint_items(state: Mapping[str, object]) -> list[Mapping[str, object]]:
    """Read the checkpoint's ``items[]`` collection as a list of objects.

    Args:
        state (Mapping[str, object]): The parsed checkpoint.

    Returns:
        list[Mapping[str, object]]: The item records, in checkpoint order.

    Raises:
        DriftCliInputError: If ``items`` is not a list or holds a non-object
            entry.

    Side Effects:
        None.
    """
    items = state.get("items")
    if not isinstance(items, list):
        raise DriftCliInputError("Parallel checkpoint items must be a list.")

    # Reject rather than filter: a peer silently dropped here would never be
    # evaluated against the observed radius, which is the under-reporting failure
    # this feature exists to catch.
    records: list[Mapping[str, object]] = []
    for entry in cast("list[object]", items):
        if not isinstance(entry, Mapping):
            raise DriftCliInputError(
                f"Parallel checkpoint items[] entries must be objects; "
                f"found: {entry!r}."
            )
        records.append(cast("Mapping[str, object]", entry))
    return records


def conflict_edges(state: Mapping[str, object]) -> list[Mapping[str, object]]:
    """Read the checkpoint's ``conflict_edges[]`` collection, read-only.

    Args:
        state (Mapping[str, object]): The parsed checkpoint.

    Returns:
        list[Mapping[str, object]]: The object-shaped edge records. A non-object
        entry is omitted, which leaves any conflict over that pair reportable as
        new. No field is added or changed.

    Raises:
        DriftCliInputError: If ``conflict_edges`` is present but not a list.

    Side Effects:
        None.
    """
    edges = state.get("conflict_edges")
    if not isinstance(edges, list):
        raise DriftCliInputError("Parallel checkpoint conflict_edges must be a list.")

    # Keep the readable edges only; an unreadable one is treated as absent so a
    # conflict over that pair is still reported rather than suppressed.
    return [
        cast("Mapping[str, object]", edge)
        for edge in cast("list[object]", edges)
        if isinstance(edge, Mapping)
    ]


def item_by_key(
    items: Sequence[Mapping[str, object]], item_key: int
) -> Mapping[str, object]:
    """Find the item record carrying one ``issue_num``.

    Args:
        items (Sequence[Mapping[str, object]]): The checkpoint's item records.
        item_key (int): The ``issue_num`` to locate.

    Returns:
        Mapping[str, object]: The matching record.

    Raises:
        DriftCliInputError: If no record carries that key, which means the caller
            named an item this checkpoint does not track.

    Side Effects:
        None.
    """
    # Scan for the requested key; the collection is small and its order is the
    # checkpoint's, so a linear search keeps the result independent of any index.
    for record in items:
        if record.get("issue_num") == item_key:
            return record
    raise DriftCliInputError(
        f"Parallel checkpoint records no items[] entry with issue_num {item_key}."
    )


def declared_paths(item: Mapping[str, object]) -> tuple[str, ...]:
    """Read one item's declared ``blast_radius.paths``.

    Args:
        item (Mapping[str, object]): The item record.

    Returns:
        tuple[str, ...]: The declared path entries verbatim. Entry-level shape is
        checked by the pure module, which rejects a blank or non-string entry
        rather than dropping it.

    Raises:
        DriftCliInputError: If ``blast_radius`` is not an object or its ``paths``
            value is not a list.

    Side Effects:
        None.
    """
    radius = item.get("blast_radius")
    if not isinstance(radius, Mapping):
        raise DriftCliInputError(
            f"Parallel checkpoint items[] blast_radius must be an object; "
            f"found: {radius!r}."
        )
    paths = cast("Mapping[str, object]", radius).get("paths")
    if not isinstance(paths, list):
        raise DriftCliInputError(
            f"Parallel checkpoint items[] blast_radius.paths must be a list; "
            f"found: {paths!r}."
        )
    return tuple(cast("list[str]", paths))
