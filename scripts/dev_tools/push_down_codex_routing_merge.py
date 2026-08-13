"""Merge Codex routing additively while preserving destination ownership.

The pure merge path parses two JSON objects, detects substantive shared-key
collisions, appends only missing source entries, and preserves original bytes
when nothing changes. The filesystem decorator applies that policy to one
configured destination and delegates every other operation. Pure helpers do no
I/O or mutation; adapter methods may perform delegated filesystem I/O and
propagate JSON, path, or inner-adapter errors documented by their contracts.
"""

from __future__ import annotations

import json
from typing import TYPE_CHECKING, TypeAlias, cast

if TYPE_CHECKING:
    from pathlib import Path

    from scripts.dev_tools.push_down_copilot_customizations_filesystem import (
        PushDownFileSystem,
    )

JsonValue: TypeAlias = (
    None | bool | int | float | str | list["JsonValue"] | dict[str, "JsonValue"]
)
JsonObject: TypeAlias = dict[str, JsonValue]

ROUTING_MERGE_CONFLICT_REASON = "ROUTING_MERGE_SUBSTANTIVE_COLLISION"
ROUTES_KEY = "routes"


class RoutingMergeConflictError(ValueError):
    """Represent sorted destination-owned collisions for one routing path.

    Constructed by the pure object merge and consumed as a ``ValueError`` by the
    publisher boundary. ``path`` identifies the destination and ``conflicts``
    stores stable dotted keys. Construction mutates only the exception object.
    """

    reason_code = ROUTING_MERGE_CONFLICT_REASON

    def __init__(self, path: str, conflicts: tuple[str, ...]) -> None:
        """Store ``path``/``conflicts`` and initialize a stable error message."""

        self.path = path
        self.conflicts = tuple(sorted(conflicts))
        super().__init__(f"{self.reason_code}: {path}: {', '.join(self.conflicts)}")


def _parse_routing_object(text: str, path: str) -> JsonObject:
    """Parse ``text`` for ``path``; return an object or raise ``ValueError``."""

    # Translate JSON syntax failures into publisher-facing path diagnostics.
    try:
        loaded: object = json.loads(text)
    except json.JSONDecodeError as error:
        raise ValueError(
            f"Routing document is not valid JSON: {path} ({error.msg})"
        ) from error
    # The routing contract requires an object root; scalar/list roots are invalid.
    if not isinstance(loaded, dict):
        raise ValueError(f"Routing document root is not a JSON object: {path}")
    return cast("JsonObject", loaded)


def _as_object(value: JsonValue | None) -> JsonObject | None:
    """Inspect ``value``; return it as an object or None without side effects."""

    return value if isinstance(value, dict) else None


def _find_conflicts(destination: JsonObject, source: JsonObject) -> tuple[str, ...]:
    """Compare ``destination``/``source`` and return sorted dotted conflicts."""

    conflicts: list[str] = []
    # Compare destination-owned top-level values except the nested routes map.
    for key in destination.keys() & source.keys():
        if key == ROUTES_KEY:
            continue
        if destination[key] != source[key]:
            conflicts.append(key)

    destination_routes_value = destination.get(ROUTES_KEY)
    source_routes_value = source.get(ROUTES_KEY)
    destination_routes = _as_object(destination_routes_value)
    source_routes = _as_object(source_routes_value)
    # Route objects collide per route; non-object route values collide as a unit.
    if ROUTES_KEY in destination and ROUTES_KEY in source:
        if destination_routes is None or source_routes is None:
            if destination_routes_value != source_routes_value:
                conflicts.append(ROUTES_KEY)
        else:
            # Report every shared route whose destination-owned value would change.
            for route_name in destination_routes.keys() & source_routes.keys():
                if destination_routes[route_name] != source_routes[route_name]:
                    conflicts.append(f"{ROUTES_KEY}.{route_name}")
    return tuple(sorted(conflicts))


def _sorted_routes(routes: JsonObject) -> JsonObject:
    """Read ``routes`` and return a new key-sorted object without mutation."""

    # Stable ordering makes newly created routing documents deterministic.
    return {name: routes[name] for name in sorted(routes)}


def _merge_routing_objects(
    destination: JsonObject, source: JsonObject, path: str
) -> tuple[JsonObject, bool]:
    """Merge parsed objects for ``path``; return result/change or raise conflict."""

    conflicts = _find_conflicts(destination, source)
    if conflicts:
        raise RoutingMergeConflictError(path, conflicts)

    merged: JsonObject = dict(destination)
    changed = False
    destination_routes = _as_object(destination.get(ROUTES_KEY))
    source_routes = _as_object(source.get(ROUTES_KEY))
    # Add the complete source map only when the destination owns no routes field.
    if source_routes is not None:
        if destination_routes is None:
            if ROUTES_KEY not in destination:
                merged[ROUTES_KEY] = _sorted_routes(source_routes)
                changed = True
        else:
            # Append only missing routes so destination ordering and values survive.
            missing_routes = sorted(source_routes.keys() - destination_routes.keys())
            if missing_routes:
                merged_routes = dict(destination_routes)
                # Insert missing routes in stable source-name order.
                for route_name in missing_routes:
                    merged_routes[route_name] = source_routes[route_name]
                merged[ROUTES_KEY] = merged_routes
                changed = True

    # Append source-owned top-level fields deterministically, excluding routes.
    for key in sorted(source.keys() - destination.keys()):
        if key == ROUTES_KEY:
            continue
        merged[key] = source[key]
        changed = True
    return merged, changed


def merge_additive_routing_documents(
    destination_text: str,
    source_text: str,
    path: str,
) -> str:
    """Merge JSON texts for ``path``; return text or raise parse/conflict errors."""

    destination = _parse_routing_object(destination_text, path)
    source = _parse_routing_object(source_text, path)
    merged, changed = _merge_routing_objects(destination, source, path)
    # Preserve exact destination bytes unless at least one source field was added.
    if not changed:
        return destination_text
    return f"{json.dumps(merged, indent=2)}\n"


class AdditiveRoutingMergeFileSystem:
    """Decorate a filesystem with additive writes for one routing destination.

    Construct around an existing publisher filesystem, then use it through the
    same protocol. Reads and non-target writes delegate unchanged; an existing
    configured target is read, merged, and written only when content changes.
    The target must remain under ``destination_root``. Stored attributes are the
    inner adapter, root boundary, and normalized relative target. Methods may
    perform delegated filesystem I/O and propagate adapter/merge errors.
    """

    def __init__(
        self,
        inner: PushDownFileSystem,
        *,
        destination_root: Path,
        merge_relative_path: Path,
    ) -> None:
        """Store ``inner`` and target paths; return None without filesystem I/O."""

        self._inner = inner
        self._destination_root = destination_root
        self._merge_relative_path = merge_relative_path.as_posix()

    def _is_merge_target(self, path: Path) -> bool:
        """Compare ``path`` to the target; return bool without filesystem I/O."""

        # Paths outside the configured root are ordinary delegated destinations.
        try:
            return (
                path.relative_to(self._destination_root).as_posix()
                == self._merge_relative_path
            )
        except ValueError:
            return False

    def list_files(self, root: Path) -> list[Path]:
        """Use ``root``; return inner file enumeration after delegated read I/O."""

        return self._inner.list_files(root)

    def is_dir(self, path: Path) -> bool:
        """Use ``path``; return inner directory status after metadata I/O."""

        return self._inner.is_dir(path)

    def is_file(self, path: Path) -> bool:
        """Use ``path``; return inner file status after metadata I/O."""

        return self._inner.is_file(path)

    def read_text(self, path: Path) -> str:
        """Use ``path``; return inner text and propagate delegated read errors."""

        return self._inner.read_text(path)

    def write_text(self, path: Path, content: str) -> None:
        """Write ``content`` at ``path``; return None and perform delegated I/O."""

        # Merge only an existing configured target; all other writes stay exact.
        if not self._is_merge_target(path) or not self._inner.is_file(path):
            self._inner.write_text(path, content)
            return
        merged = merge_additive_routing_documents(
            self._inner.read_text(path),
            content,
            path.as_posix(),
        )
        # Avoid a write when additive merging preserves the current bytes.
        if merged != self._inner.read_text(path):
            self._inner.write_text(path, merged)

    def ensure_dir(self, path: Path) -> None:
        """Ensure ``path`` via the inner adapter; return None after write I/O."""

        self._inner.ensure_dir(path)
