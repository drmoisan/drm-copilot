"""Additive destination-routing merge for the Codex publisher."""

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
    """Report substantive destination-owned routing collisions."""

    reason_code = ROUTING_MERGE_CONFLICT_REASON

    def __init__(self, path: str, conflicts: tuple[str, ...]) -> None:
        self.path = path
        self.conflicts = tuple(sorted(conflicts))
        super().__init__(f"{self.reason_code}: {path}: {', '.join(self.conflicts)}")


def _parse_routing_object(text: str, path: str) -> JsonObject:
    """Parse one routing document as a JSON object."""

    try:
        loaded: object = json.loads(text)
    except json.JSONDecodeError as error:
        raise ValueError(
            f"Routing document is not valid JSON: {path} ({error.msg})"
        ) from error
    if not isinstance(loaded, dict):
        raise ValueError(f"Routing document root is not a JSON object: {path}")
    return cast("JsonObject", loaded)


def _as_object(value: JsonValue | None) -> JsonObject | None:
    """Narrow a JSON value to an object."""

    return value if isinstance(value, dict) else None


def _find_conflicts(destination: JsonObject, source: JsonObject) -> tuple[str, ...]:
    """Return substantive shared-key conflicts in sorted reason order."""

    conflicts: list[str] = []
    for key in destination.keys() & source.keys():
        if key == ROUTES_KEY:
            continue
        if destination[key] != source[key]:
            conflicts.append(key)

    destination_routes_value = destination.get(ROUTES_KEY)
    source_routes_value = source.get(ROUTES_KEY)
    destination_routes = _as_object(destination_routes_value)
    source_routes = _as_object(source_routes_value)
    if ROUTES_KEY in destination and ROUTES_KEY in source:
        if destination_routes is None or source_routes is None:
            if destination_routes_value != source_routes_value:
                conflicts.append(ROUTES_KEY)
        else:
            for route_name in destination_routes.keys() & source_routes.keys():
                if destination_routes[route_name] != source_routes[route_name]:
                    conflicts.append(f"{ROUTES_KEY}.{route_name}")
    return tuple(sorted(conflicts))


def _sorted_routes(routes: JsonObject) -> JsonObject:
    """Return route entries in ascending key order."""

    return {name: routes[name] for name in sorted(routes)}


def merge_additive_routing_documents(
    destination_text: str,
    source_text: str,
    path: str,
) -> str:
    """Add missing source routing entries without replacing destination-owned data."""

    destination = _parse_routing_object(destination_text, path)
    source = _parse_routing_object(source_text, path)
    conflicts = _find_conflicts(destination, source)
    if conflicts:
        raise RoutingMergeConflictError(path, conflicts)

    merged: JsonObject = dict(destination)
    changed = False
    destination_routes = _as_object(destination.get(ROUTES_KEY))
    source_routes = _as_object(source.get(ROUTES_KEY))
    if source_routes is not None:
        if destination_routes is None:
            if ROUTES_KEY not in destination:
                merged[ROUTES_KEY] = _sorted_routes(source_routes)
                changed = True
        else:
            missing_routes = sorted(source_routes.keys() - destination_routes.keys())
            if missing_routes:
                merged_routes = dict(destination_routes)
                for route_name in missing_routes:
                    merged_routes[route_name] = source_routes[route_name]
                merged[ROUTES_KEY] = merged_routes
                changed = True

    for key in sorted(source.keys() - destination.keys()):
        if key == ROUTES_KEY:
            continue
        merged[key] = source[key]
        changed = True

    if not changed:
        return destination_text
    return f"{json.dumps(merged, indent=2)}\n"


class AdditiveRoutingMergeFileSystem:
    """Merge one configured routing destination and delegate every other path."""

    def __init__(
        self,
        inner: PushDownFileSystem,
        *,
        destination_root: Path,
        merge_relative_path: Path,
    ) -> None:
        self._inner = inner
        self._destination_root = destination_root
        self._merge_relative_path = merge_relative_path.as_posix()

    def _is_merge_target(self, path: Path) -> bool:
        """Return whether a path is the configured routing destination."""

        try:
            return (
                path.relative_to(self._destination_root).as_posix()
                == self._merge_relative_path
            )
        except ValueError:
            return False

    def list_files(self, root: Path) -> list[Path]:
        """Delegate source enumeration."""

        return self._inner.list_files(root)

    def is_dir(self, path: Path) -> bool:
        """Delegate directory checks."""

        return self._inner.is_dir(path)

    def is_file(self, path: Path) -> bool:
        """Delegate file checks."""

        return self._inner.is_file(path)

    def read_text(self, path: Path) -> str:
        """Delegate text reads."""

        return self._inner.read_text(path)

    def write_text(self, path: Path, content: str) -> None:
        """Merge an existing routing target or delegate an exact write."""

        if not self._is_merge_target(path) or not self._inner.is_file(path):
            self._inner.write_text(path, content)
            return
        merged = merge_additive_routing_documents(
            self._inner.read_text(path),
            content,
            path.as_posix(),
        )
        if merged != self._inner.read_text(path):
            self._inner.write_text(path, merged)

    def ensure_dir(self, path: Path) -> None:
        """Delegate directory creation."""

        self._inner.ensure_dir(path)
