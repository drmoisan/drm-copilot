"""Merge a source routing document into a destination routing document.

Purpose:
    Python port of ``mergeRoutingDocuments`` in
    ``extensions/drm-copilot/src/lib/push-down/claude-routing-merge.ts``. A
    destination workspace may already carry its own
    ``config/orchestration-routing.json`` with locally added routes; publishing
    the bundled document merges the source routes into it instead of
    discarding the destination's.

Merge rule (pinned for idempotency, identical to TypeScript):
    - Destination top-level keys are emitted in destination order with their
      destination values, except ``routes``, which is replaced by the route
      merge.
    - Source top-level keys the destination lacks are appended in source order.
      An appended ``routes`` is merged against no destination routes and becomes
      ``{}`` when the source ``routes`` is not an object.
    - In the route merge, destination routes keep destination order; the
      ``parallel`` route takes the source definition when the source defines
      it; source-only routes are appended in source order. A non-object
      destination ``routes`` is treated as absent.
    - Output is 2-space indented with one trailing newline and no key sorting,
      so a second merge is byte-stable.

Invariants / Constraints:
    This module performs no I/O. Invalid JSON, the non-finite constants
    ``NaN``/``Infinity``/``-Infinity`` (which ``JSON.parse`` rejects), and a
    non-object root in either text raise :class:`RoutingMergeError`.
"""

from __future__ import annotations

import json
from typing import TYPE_CHECKING, cast

if TYPE_CHECKING:
    from pathlib import Path

__all__ = ["RoutingMergeError", "merge_routing_documents"]

# Top-level key holding the route table.
ROUTES_KEY = "routes"
# Route name whose source definition always wins over the destination's.
AUTHORITATIVE_ROUTE = "parallel"

JsonObject = dict[str, object]


class RoutingMergeError(ValueError):
    """Raised when a routing document cannot be parsed into a JSON object.

    Attributes:
        path (Path): Destination path named in the message, as passed.
    """

    def __init__(self, path: Path, detail: str) -> None:
        """Build the TypeScript-identical message for ``path`` and ``detail``.

        Args:
            path (Path): Destination path of the routing document.
            detail (str): Parser detail appended to the message.
        """

        # ``as_posix`` keeps the text byte-comparable with TypeScript on Windows.
        super().__init__(
            "Destination routing document is not valid JSON and was not written: "
            f"{path.as_posix()} ({detail})"
        )
        self.path = path


def _reject_constant(name: str) -> object:
    """Reject the non-finite JSON constants that ``JSON.parse`` does not accept."""

    raise ValueError(f"non-finite constant {name} is not valid JSON")


def _parse_object(text: str, path: Path) -> JsonObject:
    """Parse text into a JSON object or raise :class:`RoutingMergeError`."""

    try:
        parsed: object = json.loads(text, parse_constant=_reject_constant)
    except ValueError as error:
        raise RoutingMergeError(path, str(error)) from error
    if not isinstance(parsed, dict):
        raise RoutingMergeError(path, "document root is not a JSON object")
    return cast("JsonObject", parsed)


def _as_object(value: object) -> JsonObject | None:
    """Return ``value`` when it is a JSON object, otherwise ``None``."""

    return cast("JsonObject", value) if isinstance(value, dict) else None


def _merge_routes(
    destination_routes: JsonObject | None, source_routes: JsonObject | None
) -> JsonObject:
    """Merge the source route table into the destination route table."""

    merged: JsonObject = {}
    # Walk the destination first so its key order survives; only the
    # authoritative route is replaced in place.
    if destination_routes is not None:
        for name, definition in destination_routes.items():
            merged[name] = (
                source_routes[name]
                if name == AUTHORITATIVE_ROUTE
                and source_routes is not None
                and name in source_routes
                else definition
            )
    # Append the routes the destination does not define, in source order.
    if source_routes is not None:
        for name, definition in source_routes.items():
            if name not in merged:
                merged[name] = definition
    return merged


def merge_routing_documents(destination_text: str, source_text: str, path: Path) -> str:
    """Merge a source routing document into a destination routing document.

    Args:
        destination_text (str): Current destination document text.
        source_text (str): Source document text being published.
        path (Path): Destination path reported in a parse error.

    Returns:
        str: The merged document, 2-space indented with a trailing newline.

    Raises:
        RoutingMergeError: When either text is not a JSON object.
    """

    destination = _parse_object(destination_text, path)
    source = _parse_object(source_text, path)

    merged: JsonObject = {}
    # Preserve the destination's top-level key order, replacing only routes.
    for key, value in destination.items():
        merged[key] = (
            _merge_routes(_as_object(value), _as_object(source.get(ROUTES_KEY)))
            if key == ROUTES_KEY
            else value
        )
    # Append the top-level blocks the destination lacks, in source order.
    for key, value in source.items():
        if key in merged:
            continue
        merged[key] = (
            _merge_routes(None, _as_object(value)) if key == ROUTES_KEY else value
        )

    return json.dumps(merged, indent=2, ensure_ascii=False) + "\n"
