"""Blast-radius data model and derivation for parallel scheduling.

Purpose and responsibilities:
    Provide the canonical reference implementation of the four-level blast
    radius (``paths``, ``modules``, ``shared_surfaces``, ``contracts``) and its
    three confidence sources, and expose the whole blast-radius surface from one
    module. This module owns the data model and the two derivation entry points;
    text scanning lives in ``scripts/dev_tools/_blast_radius_extraction.py``,
    the V1-V3 rules in ``scripts/dev_tools/_blast_radius_validation.py``, and
    the contention relation in
    ``scripts/dev_tools/_blast_radius_conflicts.py``, all re-exported here so
    callers depend on one module.

Usage:
    A planner calls ``derive_blast_radius`` over an approved plan and feature
    spec, ``validate_blast_radius`` to gate the result, then ``conflicts`` to
    seed cohorts. Drift detection calls ``radius_from_observed_paths`` over an
    already-collected diff path list and recomputes ``conflicts``.

Invariants, constraints, and side effects:
    Every collection is deduplicated and ordinally sorted at construction and
    ``source`` is restricted to ``derived``, ``declared``, and ``observed``, so
    identical inputs serialize identically in both languages. ``computed_at``
    and ``tracked_file_count`` are caller-supplied. The PowerShell mirror
    reproduces these semantics; this module is the authoritative reference.
    Every function is pure and mutates no input: no filesystem, subprocess,
    network, or wall-clock access.
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import TYPE_CHECKING

from scripts.dev_tools._blast_radius_conflicts import (
    ConflictReason,
    ConflictResult,
    conflicts,
)
from scripts.dev_tools._blast_radius_extraction import (
    extract_contract_identifiers,
    extract_paths_from_lines,
    extract_plan_paths,
    normalize_lines,
)
from scripts.dev_tools._blast_radius_validation import (
    RadiusFinding,
    concrete_entries,
    require_str_tuple,
    require_text,
    resolve_modules,
    resolve_shared_surfaces,
    validate_blast_radius,
)

if TYPE_CHECKING:
    from collections.abc import Mapping, Sequence

__all__ = [
    "BlastRadius",
    "ConflictReason",
    "ConflictResult",
    "RadiusFinding",
    "conflicts",
    "derive_blast_radius",
    "extract_plan_paths",
    "radius_from_observed_paths",
    "validate_blast_radius",
]

# Confidence sources: ``derived`` seeds cohorts provisionally, ``declared`` is
# planner-computed and authoritative for scheduling, and ``observed`` comes from
# an actual diff during drift correction.
RADIUS_SOURCE_DERIVED = "derived"
RADIUS_SOURCE_DECLARED = "declared"
RADIUS_SOURCE_OBSERVED = "observed"
RADIUS_SOURCES: tuple[str, ...] = (
    RADIUS_SOURCE_DERIVED,
    RADIUS_SOURCE_DECLARED,
    RADIUS_SOURCE_OBSERVED,
)

# Serialized key set, in the order of the parallel manifest schema. Downstream
# features depend on these strings verbatim.
RADIUS_KEYS: tuple[str, ...] = tuple(
    "paths modules shared_surfaces contracts source computed_at".split()
)

# Feature-folder handling. Every radius contains its own feature folder, and a
# caller may pass either a bare folder name or an already-qualified path.
FEATURE_FOLDER_ROOT = "docs/features/active"
FEATURE_FOLDER_PREFIX = "docs/features/"


@dataclass(frozen=True)
class BlastRadius:
    """Immutable four-level description of what a work item touches.

    Carries the paths, modules, shared surfaces, and contract identifiers of one
    work item with its confidence source and the timestamp the caller assigned.
    The class stores and normalizes values; deriving them from text is the job
    of ``derive_blast_radius``. Construct through ``derive_blast_radius``,
    ``radius_from_observed_paths``, or ``from_dict``, and serialize with
    ``to_dict`` for the parallel manifest and orchestration checkpoint.

    Construction deduplicates and ordinally sorts every collection, restricts
    ``source`` to ``RADIUS_SOURCES``, and rejects any blank or non-string value
    rather than silently normalizing it away. The instance is frozen, holds only
    immutable tuples, and has no side effects.

    Attributes:
        paths (Sequence[str]): Repository paths and globs; the primary signal.
        modules (Sequence[str]): Modules the paths resolve to via the truth map.
        shared_surfaces (Sequence[str]): Touched high-contention artifacts.
        contracts (Sequence[str]): Symbol, schema, and CLI identifiers.
        source (str): One of ``derived``, ``declared``, or ``observed``.
        computed_at (str): Caller-supplied ISO-8601 timestamp.
    """

    paths: Sequence[str]
    modules: Sequence[str]
    shared_surfaces: Sequence[str]
    contracts: Sequence[str]
    source: str
    computed_at: str

    def __post_init__(self) -> None:
        """Validate every field and replace collections with sorted tuples.

        Returns:
            None.

        Raises:
            TypeError: If a field is not a string or string collection.
            ValueError: If a value is blank or ``source`` is out of vocabulary.

        Side Effects:
            Rewrites the instance's own collection fields through
            ``object.__setattr__``, the supported way to normalize a frozen
            dataclass at construction.
        """
        # Normalizing here rather than at each call site guarantees the sorted,
        # deduplicated invariant however the radius was built, including
        # construction straight from deserialized manifest data.
        object.__setattr__(self, "paths", require_str_tuple(self.paths, "paths"))
        object.__setattr__(self, "modules", require_str_tuple(self.modules, "modules"))
        object.__setattr__(
            self,
            "shared_surfaces",
            require_str_tuple(self.shared_surfaces, "shared_surfaces"),
        )
        object.__setattr__(
            self, "contracts", require_str_tuple(self.contracts, "contracts")
        )
        require_text(self.source, "source")
        if self.source not in RADIUS_SOURCES:
            raise ValueError(f"source must be one of {RADIUS_SOURCES}.")
        require_text(self.computed_at, "computed_at")

    def to_dict(self) -> dict[str, object]:
        """Serialize the radius into the manifest and checkpoint dict shape.

        Returns:
            dict[str, object]: A new mapping whose key set is exactly
            ``RADIUS_KEYS``, collections rendered as lists so the result is
            directly JSON-serializable.
        """
        return {
            "paths": list(self.paths),
            "modules": list(self.modules),
            "shared_surfaces": list(self.shared_surfaces),
            "contracts": list(self.contracts),
            "source": self.source,
            "computed_at": self.computed_at,
        }

    @classmethod
    def from_dict(cls, data: Mapping[str, object]) -> BlastRadius:
        """Rebuild a radius from its serialized dict shape.

        Args:
            data (Mapping[str, object]): Mapping whose key set must be exactly
                ``RADIUS_KEYS``. Values are validated by the constructor, so a
                round trip through ``to_dict`` reproduces an equal instance.

        Returns:
            BlastRadius: The reconstructed radius.

        Raises:
            TypeError: If a value has a wrong type.
            ValueError: If a key is missing or unexpected, or a value is invalid.
        """
        # An exact key-set check is deliberate: a missing key would silently
        # narrow a radius and an unexpected key would silently drop data, and
        # both failure modes under-report contention.
        missing = tuple(key for key in RADIUS_KEYS if key not in data)
        if missing:
            raise ValueError(f"blast radius dict is missing keys {missing}.")
        unexpected = tuple(sorted(key for key in data if key not in RADIUS_KEYS))
        if unexpected:
            raise ValueError(f"blast radius dict has unexpected keys {unexpected}.")

        return cls(
            paths=require_str_tuple(data["paths"], "paths"),
            modules=require_str_tuple(data["modules"], "modules"),
            shared_surfaces=require_str_tuple(
                data["shared_surfaces"], "shared_surfaces"
            ),
            contracts=require_str_tuple(data["contracts"], "contracts"),
            source=require_text(data["source"], "source"),
            computed_at=require_text(data["computed_at"], "computed_at"),
        )


def derive_blast_radius(
    plan_text: str,
    spec_text: str,
    feature_folder: str,
    config: Mapping[str, object],
    *,
    source: str = RADIUS_SOURCE_DERIVED,
    computed_at: str,
) -> BlastRadius:
    """Derive a blast radius from an approved plan and its feature spec.

    Args:
        plan_text (str): Approved atomic-plan document text; may be empty.
        spec_text (str): Feature ``spec.md`` document text; may be empty.
        feature_folder (str): Bare feature folder name, or a path that already
            starts with ``docs/features/``.
        config (Mapping[str, object]): Parsed ``config/blast-radius.json``.
        source (str): Confidence source to record; ``derived`` by default and
            ``declared`` when a planner adopts the result as authoritative.
        computed_at (str): Caller-supplied ISO-8601 timestamp.

    Returns:
        BlastRadius: The derived radius. A plan and spec with no extractable
        paths still yield a radius containing the feature-folder glob.

    Raises:
        TypeError: If an argument or the truth table has a wrong type.
        ValueError: If ``feature_folder``, ``source``, or ``computed_at`` is
            blank, or ``source`` is outside ``RADIUS_SOURCES``.
    """
    require_text(plan_text, "plan_text", allow_empty=True)
    require_text(spec_text, "spec_text", allow_empty=True)

    # Plan task bodies are the primary signal, the spec contributes the paths it
    # cites in inline code, and the feature folder is always present because
    # every item writes its own documents and evidence.
    entries: set[str] = set(extract_plan_paths(plan_text))
    entries.update(extract_paths_from_lines(normalize_lines(spec_text)))
    entries.add(_feature_folder_glob(require_text(feature_folder, "feature_folder")))
    paths = tuple(sorted(entries))

    return BlastRadius(
        paths=paths,
        modules=resolve_modules(paths, config),
        shared_surfaces=resolve_shared_surfaces(concrete_entries(paths), config),
        contracts=extract_contract_identifiers(spec_text),
        source=source,
        computed_at=computed_at,
    )


def radius_from_observed_paths(
    observed_paths: Sequence[str],
    config: Mapping[str, object],
    *,
    computed_at: str,
) -> BlastRadius:
    """Build an observed-source radius from an already-collected path list.

    Drift detection supplies the output of a diff listing; the library performs
    no subprocess call of its own, so the paths arrive as plain strings and are
    taken verbatim rather than re-classified by the plan-text heuristic.

    Args:
        observed_paths (Sequence[str]): Repository-relative paths from a diff.
        config (Mapping[str, object]): Parsed ``config/blast-radius.json``.
        computed_at (str): Caller-supplied ISO-8601 timestamp.

    Returns:
        BlastRadius: A radius whose ``source`` is ``observed`` and whose modules
        and shared surfaces are resolved by the derivation rules. ``contracts``
        is empty because a diff carries no interface-section text.

    Raises:
        TypeError: If an argument or the truth table has a wrong type.
        ValueError: If a path entry or ``computed_at`` is blank.
    """
    paths = require_str_tuple(observed_paths, "observed_paths")

    return BlastRadius(
        paths=paths,
        modules=resolve_modules(paths, config),
        shared_surfaces=resolve_shared_surfaces(concrete_entries(paths), config),
        contracts=(),
        source=RADIUS_SOURCE_OBSERVED,
        computed_at=computed_at,
    )


def _feature_folder_glob(feature_folder: str) -> str:
    """Render a feature folder as the glob covering everything beneath it.

    Args:
        feature_folder (str): Bare folder name or an already-qualified path;
            surrounding whitespace and separators are trimmed.

    Returns:
        str: A ``**`` glob rooted at the feature folder.
    """
    trimmed = feature_folder.strip().strip("/")

    # Accepting an already-qualified path avoids producing a doubled
    # ``docs/features/active/docs/features/active/...`` entry when a caller
    # passes the folder path it already holds.
    if trimmed.startswith(FEATURE_FOLDER_PREFIX):
        return f"{trimmed}/**"
    return f"{FEATURE_FOLDER_ROOT}/{trimmed}/**"
