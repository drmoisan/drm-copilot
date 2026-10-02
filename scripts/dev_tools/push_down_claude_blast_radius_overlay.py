"""Compose a destination blast-radius overlay onto the regenerated base (issue #508).

Purpose:
    Python port of ``composeBlastRadiusOverlay`` in
    ``extensions/drm-copilot/src/lib/push-down/claude-blast-radius-overlay.ts``.
    Every push regenerates ``config/blast-radius.json``, so a destination
    records its own entries in the destination-owned overlay
    ``config/blast-radius.local.json``; this module composes that overlay onto
    the regenerated base at push time. The overlay is only read.

Composition rules (identical to TypeScript):
    - Overlay absent: the base text is returned byte for byte.
    - ``version`` must equal the base ``version`` (type-strict: a ``bool``
      never equals an ``int``); the base value is emitted.
    - String-list keys: ordered union, base entries first, overlay duplicates
      removed.
    - ``modules``: overlay modules are added or replace a same-name module;
      names are emitted in ordinal order and the forbidden-glob guard applies.
    - Other keys in both: objects merge recursively, lists union, otherwise the
      overlay value wins. Overlay-only keys are appended in overlay order.
    - Output is 2-space indented with one trailing newline.

Invariants / Constraints:
    This module performs no I/O. Every error is raised before any write.
    ``NaN``/``Infinity``/``-Infinity`` are rejected as ``JSON.parse`` rejects
    them.
"""

from __future__ import annotations

import json
from typing import cast

try:
    from scripts.dev_tools.push_down_claude_blast_radius_derive_core import (
        BLAST_RADIUS_RELATIVE_PATH,
        FORBIDDEN_GLOBS,
        BlastRadiusGuardError,
    )
except ModuleNotFoundError as error:  # pragma: no cover - bundled import fallback
    if error.name is None or not error.name.startswith("scripts"):
        raise
    from dev_tools.push_down_claude_blast_radius_derive_core import (
        BLAST_RADIUS_RELATIVE_PATH,
        FORBIDDEN_GLOBS,
        BlastRadiusGuardError,
    )

__all__ = [
    "BLAST_RADIUS_OVERLAY_RELATIVE_PATH",
    "BLAST_RADIUS_RELATIVE_PATH",
    "FORBIDDEN_GLOBS",
    "BlastRadiusGuardError",
    "BlastRadiusOverlayError",
    "compose_blast_radius_overlay",
]

# Destination-relative path of the destination-owned overlay.
BLAST_RADIUS_OVERLAY_RELATIVE_PATH = "config/blast-radius.local.json"

# Keys whose value is an ordered list of strings composed by union.
_STRING_LIST_KEYS = frozenset(
    {
        "shared_surfaces",
        "shared_surface_globs",
        "mandate_reads",
        "mergeable_paths",
        "path_roots",
    }
)
_MODULES_KEY = "modules"
_VERSION_KEY = "version"

JsonObject = dict[str, object]


class BlastRadiusOverlayError(ValueError):
    """Raised when a blast-radius overlay cannot be composed.

    Attributes:
        path (str): Relative path of the document that could not be composed.
    """

    def __init__(self, path: str, detail: str) -> None:
        """Build the TypeScript-identical message for ``path`` and ``detail``.

        Args:
            path (str): Relative path of the offending document.
            detail (str): Reason appended to the message.
        """

        super().__init__(
            f"Blast-radius overlay {path} was not applied; "
            f"{BLAST_RADIUS_RELATIVE_PATH} was not written: {detail}"
        )
        self.path = path


def _reject_constant(name: str) -> object:
    """Reject the non-finite JSON constants that ``JSON.parse`` does not accept."""

    raise ValueError(f"non-finite constant {name} is not valid JSON")


def _parse_object(text: str, path: str) -> JsonObject:
    """Parse text into a JSON object or raise :class:`BlastRadiusOverlayError`."""

    try:
        parsed: object = json.loads(text, parse_constant=_reject_constant)
    except ValueError as error:
        raise BlastRadiusOverlayError(path, f"not valid JSON ({error})") from error
    if not isinstance(parsed, dict):
        raise BlastRadiusOverlayError(path, "document root is not a JSON object")
    return cast("JsonObject", parsed)


def _as_object(value: object) -> JsonObject | None:
    """Return ``value`` when it is a JSON object, otherwise ``None``."""

    return cast("JsonObject", value) if isinstance(value, dict) else None


def _as_string_list(value: object) -> list[str] | None:
    """Return ``value`` when it is a list of strings, otherwise ``None``."""

    if not isinstance(value, list):
        return None
    items = cast("list[object]", value)
    if not all(isinstance(item, str) for item in items):
        return None
    return cast("list[str]", items)


def _strictly_equal(left: object, right: object) -> bool:
    """Mirror TypeScript ``===`` for parsed JSON scalars.

    A ``bool`` never equals an ``int``, and two objects or lists are never
    equal, because ``===`` compares parsed objects by identity.
    """

    if isinstance(left, (dict, list)) or isinstance(right, (dict, list)):
        return False
    if isinstance(left, bool) or isinstance(right, bool):
        return type(left) is type(right) and left == right
    return left == right


def _union_strings(base: list[object], overlay: list[str]) -> list[object]:
    """Return the base entries followed by overlay strings not yet present."""

    composed = list(base)
    seen = {item for item in base if isinstance(item, str)}
    for item in overlay:
        if item not in seen:
            seen.add(item)
            composed.append(item)
    return composed


def _compose_string_list(
    key: str, base: object, overlay: object, overlay_path: str
) -> list[object]:
    """Compose one string-list key, validating the overlay value."""

    overlay_list = _as_string_list(overlay)
    if overlay_list is None:
        raise BlastRadiusOverlayError(
            overlay_path, f'key "{key}" must be a list of strings'
        )
    base_list = cast("list[object]", base) if isinstance(base, list) else []
    return _union_strings(base_list, overlay_list)


def _compose_modules(base: object, overlay: object, overlay_path: str) -> JsonObject:
    """Compose the ``modules`` map and apply the forbidden-glob guard."""

    overlay_map = _as_object(overlay)
    if overlay_map is None or any(
        _as_string_list(globs) is None for globs in overlay_map.values()
    ):
        raise BlastRadiusOverlayError(
            overlay_path,
            f'key "{_MODULES_KEY}" must map module names to lists of strings',
        )
    merged: JsonObject = dict(_as_object(base) or {})
    merged.update(overlay_map)
    composed: JsonObject = {}
    for name in sorted(merged):
        globs = merged[name]
        composed[name] = globs
        items = cast("list[object]", globs) if isinstance(globs, list) else []
        for glob in items:
            if isinstance(glob, str) and glob in FORBIDDEN_GLOBS:
                raise BlastRadiusGuardError(name, glob)
    return composed


def _merge_values(
    base: object, overlay: object, dotted_key: str, overlay_path: str
) -> object:
    """Merge an overlay value into a base value for a key present in both."""

    base_map = _as_object(base)
    overlay_map = _as_object(overlay)
    if base_map is not None and overlay_map is not None:
        merged: JsonObject = {}
        for key, value in base_map.items():
            merged[key] = (
                _merge_values(
                    value, overlay_map[key], f"{dotted_key}.{key}", overlay_path
                )
                if key in overlay_map
                else value
            )
        for key, value in overlay_map.items():
            if key not in merged:
                merged[key] = value
        return merged
    if isinstance(base, list) and isinstance(overlay, list):
        overlay_list = _as_string_list(cast("list[object]", overlay))
        if overlay_list is None:
            raise BlastRadiusOverlayError(
                overlay_path, f'key "{dotted_key}" must be a list of strings'
            )
        return _union_strings(cast("list[object]", base), overlay_list)
    return overlay


# Marker for a key the base document does not carry.
_ABSENT = object()


def _compose_key(key: str, base: object, overlay: object, overlay_path: str) -> object:
    """Compose one overlay key; ``base`` is ``_ABSENT`` when the base lacks it."""

    if key in _STRING_LIST_KEYS:
        return _compose_string_list(key, base, overlay, overlay_path)
    if key == _MODULES_KEY:
        return _compose_modules(base, overlay, overlay_path)
    if base is _ABSENT:
        return overlay
    return _merge_values(base, overlay, key, overlay_path)


def compose_blast_radius_overlay(
    base_text: str, overlay_text: str | None, overlay_path: str
) -> str:
    """Compose a destination overlay onto a regenerated blast-radius document.

    Args:
        base_text (str): Regenerated ``config/blast-radius.json`` text.
        overlay_text (str | None): Overlay text, or ``None`` when the
            destination has no overlay.
        overlay_path (str): Overlay path reported in an error.

    Returns:
        str: ``base_text`` unchanged when the overlay is absent; otherwise the
        composed document, 2-space indented with a trailing newline.

    Raises:
        BlastRadiusOverlayError: When either document is malformed, a key has
            the wrong shape, or the overlay ``version`` differs from the base.
        BlastRadiusGuardError: When a composed module carries a forbidden glob.
    """

    if overlay_text is None:
        return base_text
    overlay = _parse_object(overlay_text, overlay_path)
    base = _parse_object(base_text, BLAST_RADIUS_RELATIVE_PATH)
    if _VERSION_KEY in overlay and not _strictly_equal(
        overlay[_VERSION_KEY], base.get(_VERSION_KEY, _ABSENT)
    ):
        raise BlastRadiusOverlayError(
            overlay_path, f'key "{_VERSION_KEY}" does not match the base version'
        )
    composed: JsonObject = {}
    for key, value in base.items():
        composed[key] = (
            value
            if key == _VERSION_KEY or key not in overlay
            else _compose_key(key, value, overlay[key], overlay_path)
        )
    for key, value in overlay.items():
        if key not in composed:
            composed[key] = _compose_key(key, _ABSENT, value, overlay_path)
    return json.dumps(composed, indent=2, ensure_ascii=False) + "\n"
