"""Pure derivation core for the destination blast-radius module map.

Purpose:
    Python port of
    ``extensions/drm-copilot/src/lib/push-down/claude-blast-radius-derive-core.ts``.
    Turn a deterministic list of destination directory observations plus the
    bundled source document into the serialized ``config/blast-radius.json`` a
    destination workspace receives. The bundled map describes drm-copilot's own
    layout, so the destination map is derived from the destination's layout.

Responsibilities:
    Algorithm steps 3 through 8: prune ancestors, name and glob the module
    paths, apply the top-level fallback and the payload floor, assemble and
    serialize the document, and guard against emitting a forbidden glob. Step 2
    (classification) lives in ``push_down_claude_blast_radius_derive_manifests``;
    step 1 (the destination scan) lives in ``push_down_claude_blast_radius_derive``.

Invariants / Constraints:
    - No I/O, clock, or randomness access; no input is mutated.
    - Identical inputs produce byte-identical output.
    - Keys are emitted in the order ``version``, ``shared_surfaces``,
      ``shared_surface_globs``, ``mandate_reads``, ``mergeable_paths``,
      ``conflict_tolerance``, ``write_intent_extraction``, ``path_roots``,
      ``modules``, ``over_breadth_fraction``; a carried key the source document
      does not declare is omitted.
    - An observed .NET manifest suppresses the top-level-directory fallback.
    - No emitted glob may be ``**``, ``docs/**``, or ``tests/**``.
"""

from __future__ import annotations

import json
from typing import TYPE_CHECKING, cast

try:
    from scripts.dev_tools.push_down_claude_blast_radius_derive_manifests import (
        DirectoryObservation,
        classify_project_directories,
    )
except ModuleNotFoundError as error:  # pragma: no cover - bundled import fallback
    if error.name is None or not error.name.startswith("scripts"):
        raise
    from dev_tools.push_down_claude_blast_radius_derive_manifests import (
        DirectoryObservation,
        classify_project_directories,
    )

if TYPE_CHECKING:
    from collections.abc import Mapping, Sequence

__all__ = [
    "BLAST_RADIUS_RELATIVE_PATH",
    "FORBIDDEN_GLOBS",
    "PAYLOAD_MODULES",
    "SCAN_DEPTH_LIMIT",
    "BlastRadiusDeriveError",
    "BlastRadiusGuardError",
    "DirectoryObservation",
    "derive_destination_module_map",
]

# Destination-relative path of the document this core derives.
BLAST_RADIUS_RELATIVE_PATH = "config/blast-radius.json"

# Maximum scan depth: the destination top level plus two nested levels.
SCAN_DEPTH_LIMIT = 3

# Modules the push-down itself creates in the destination. ``.claude`` is
# deliberately not a module; ``config`` wins a name collision with a derived one.
PAYLOAD_MODULES: Mapping[str, tuple[str, ...]] = {"config": ("config/**",)}

# Globs the derivation may never emit, in the order the guard reports them.
FORBIDDEN_GLOBS: tuple[str, ...] = ("**", "docs/**", "tests/**")

# Carried top-level keys in emission order; ``modules`` is inserted before the
# final key, ``over_breadth_fraction``.
_LEADING_KEYS: tuple[str, ...] = (
    "version",
    "shared_surfaces",
    "shared_surface_globs",
    "mandate_reads",
    "mergeable_paths",
    "conflict_tolerance",
    "write_intent_extraction",
    "path_roots",
)
_TRAILING_KEY = "over_breadth_fraction"


class BlastRadiusDeriveError(ValueError):
    """Raised when the bundled source document cannot be parsed.

    Attributes:
        path (str): Destination-relative path named in the message.
    """

    def __init__(self, path: str, detail: str) -> None:
        """Build the TypeScript-identical message for ``path`` and ``detail``."""

        super().__init__(
            "Bundled blast-radius document is not valid JSON and was not written: "
            f"{path} ({detail})"
        )
        self.path = path


class BlastRadiusGuardError(ValueError):
    """Raised when the derivation would emit a forbidden glob.

    Attributes:
        glob (str): The forbidden glob that tripped the guard.
        module_name (str): Module that would have carried the glob.
    """

    def __init__(self, module_name: str, glob: str) -> None:
        """Build the TypeScript-identical message for the offending module."""

        super().__init__(
            f"Derived blast-radius module {module_name} would emit the forbidden "
            f"glob {glob}; the derivation was aborted before writing."
        )
        self.glob = glob
        self.module_name = module_name


def _prune_ancestors(paths: Sequence[str]) -> list[str]:
    """Drop every path that is a proper ancestor of another path (step 3)."""

    # The separator anchor keeps a name-prefix sibling from counting as a child.
    return [
        candidate
        for candidate in paths
        if not any(
            other != candidate and other.startswith(f"{candidate}/") for other in paths
        )
    ]


def _top_level_directories(observations: Sequence[DirectoryObservation]) -> list[str]:
    """Return the observed top-level directory names, ordinally sorted."""

    return sorted(
        observation.relative_path
        for observation in observations
        if observation.relative_path != "" and "/" not in observation.relative_path
    )


def _assemble_modules(derived_paths: Sequence[str]) -> dict[str, list[str]]:
    """Build the module map with payload modules winning a collision (step 7)."""

    combined: dict[str, list[str]] = {path: [f"{path}/**"] for path in derived_paths}
    for name, globs in PAYLOAD_MODULES.items():
        combined[name] = list(globs)
    # Insertion order is the serialized key order, so sort before inserting.
    return {name: combined[name] for name in sorted(combined)}


def _assert_no_forbidden_glob(modules: Mapping[str, Sequence[str]]) -> None:
    """Reject a module map that carries a forbidden glob (step 8)."""

    for name, globs in modules.items():
        for glob in globs:
            if glob in FORBIDDEN_GLOBS:
                raise BlastRadiusGuardError(name, glob)


def _reject_constant(name: str) -> object:
    """Reject the non-finite JSON constants that ``JSON.parse`` does not accept."""

    raise ValueError(f"non-finite constant {name} is not valid JSON")


def _parse_source_document(text: str) -> dict[str, object]:
    """Parse the bundled source document into a JSON object."""

    try:
        parsed: object = json.loads(text, parse_constant=_reject_constant)
    except ValueError as error:
        raise BlastRadiusDeriveError(BLAST_RADIUS_RELATIVE_PATH, str(error)) from error
    if not isinstance(parsed, dict):
        raise BlastRadiusDeriveError(
            BLAST_RADIUS_RELATIVE_PATH, "document root is not a JSON object"
        )
    return cast("dict[str, object]", parsed)


def derive_destination_module_map(
    observations: Sequence[DirectoryObservation], source_document_text: str
) -> str:
    """Derive the destination blast-radius document from a destination scan.

    Args:
        observations (Sequence[DirectoryObservation]): Visited destination
            directories, including the root. An empty sequence yields the
            payload floor.
        source_document_text (str): Text of the bundled
            ``config/blast-radius.json``.

    Returns:
        str: The serialized document, 2-space indented with a trailing newline,
        keys in the fixed contract order.

    Raises:
        BlastRadiusDeriveError: When the bundled document is not a JSON object.
        BlastRadiusGuardError: When an emitted glob is forbidden; raised before
            any output is produced.
    """

    source = _parse_source_document(source_document_text)

    classification = classify_project_directories(observations)
    module_paths = _prune_ancestors(classification.module_paths)
    if module_paths:
        derived_paths = module_paths
    elif classification.structure_observed:
        # Observed .NET structure suppresses the weaker top-level fallback.
        derived_paths = []
    else:
        derived_paths = _top_level_directories(observations)

    modules = _assemble_modules(derived_paths)
    _assert_no_forbidden_glob(modules)

    document: dict[str, object] = {
        key: source[key] for key in _LEADING_KEYS if key in source
    }
    document["modules"] = modules
    if _TRAILING_KEY in source:
        document[_TRAILING_KEY] = source[_TRAILING_KEY]
    return json.dumps(document, indent=2, ensure_ascii=False) + "\n"
