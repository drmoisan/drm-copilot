"""Unit tests for the read-by-mandate exclusion helpers and radius normalizer.

Cover ``matches_mandate_read`` and ``exclude_mandate_reads`` from
``scripts/dev_tools/_blast_radius_normalization.py`` and the public
``normalize_declared_radius`` entry point on the facade. Every input is an
in-memory literal; no temporary file is created and no external process is
started.
"""

from __future__ import annotations

from typing import TYPE_CHECKING

import pytest

from scripts.dev_tools._blast_radius_normalization import (
    exclude_mandate_reads,
    matches_mandate_read,
)
from scripts.dev_tools.compute_blast_radius import (
    BlastRadius,
    normalize_declared_radius,
)

if TYPE_CHECKING:
    from collections.abc import Sequence

# The ratified mandate-read membership, repeated here as a literal so a change
# to the committed truth table cannot silently change what these tests exercise.
MANDATE_READS: tuple[str, ...] = (
    ".claude/rules/**",
    ".claude/skills/atomic-plan-contract/SKILL.md",
    ".claude/skills/evidence-and-timestamp-conventions/SKILL.md",
    ".github/instructions/**",
    "artifacts/**",
    "quality-tiers.yml",
)


def test_matches_mandate_read_excludes_an_exact_path_entry() -> None:
    """A concrete path listed verbatim in the configuration is a mandate read."""
    # Arrange / Act / Assert
    assert matches_mandate_read("quality-tiers.yml", MANDATE_READS) is True


def test_matches_mandate_read_excludes_a_concrete_path_under_a_subtree_glob() -> None:
    """A concrete path inside a configured ``**`` subtree is a mandate read."""
    # Arrange / Act / Assert
    assert matches_mandate_read("artifacts/pr_context.summary.txt", MANDATE_READS)


def test_matches_mandate_read_excludes_a_glob_entry_equal_to_a_pattern() -> None:
    """A harvested glob repeating a configured pattern is a mandate read."""
    # Arrange / Act / Assert
    assert matches_mandate_read(".claude/rules/**", MANDATE_READS) is True


def test_matches_mandate_read_retains_an_unrelated_entry() -> None:
    """A genuine write claim outside the configured patterns is retained."""
    # Arrange / Act / Assert
    assert (
        matches_mandate_read("scripts/dev_tools/compute_blast_radius.py", MANDATE_READS)
        is False
    )


def test_exclude_mandate_reads_drops_every_matching_entry() -> None:
    """The filter removes exact, subtree, and glob-equal citations together."""
    # Arrange
    entries = (
        ".claude/rules/**",
        "artifacts/pr_context.summary.txt",
        "config/blast-radius.json",
        "quality-tiers.yml",
    )

    # Act
    survivors = exclude_mandate_reads(entries, MANDATE_READS)

    # Assert
    assert survivors == ("config/blast-radius.json",)


def test_exclude_mandate_reads_with_an_empty_list_passes_content_through() -> None:
    """An absent configuration key excludes nothing, reproducing old behaviour."""
    # Arrange
    entries = ("quality-tiers.yml", "config/blast-radius.json", "artifacts/report.md")

    # Act
    survivors = exclude_mandate_reads(entries, ())

    # Assert
    assert survivors == tuple(sorted(entries))


# A minimal truth table sufficient for the normalizer: one module, one shared
# surface, and the ratified mandate-read list.
NORMALIZER_CONFIG: dict[str, object] = {
    "version": 1,
    "shared_surfaces": ["config/blast-radius.json", "quality-tiers.yml"],
    "shared_surface_globs": [],
    "mandate_reads": list(MANDATE_READS),
    "modules": {"config": ["config/**"]},
    "over_breadth_fraction": 0.25,
}

COMPUTED_AT = "2026-08-18T10-00"


def declared_radius(
    *,
    paths: Sequence[str] = ("config/blast-radius.json",),
    modules: Sequence[str] = ("config",),
    shared_surfaces: Sequence[str] = ("config/blast-radius.json",),
    contracts: Sequence[str] = ("normalize_declared_radius",),
    source: str = "declared",
) -> BlastRadius:
    """Build a radius whose defaults already satisfy every current rule.

    Args:
        paths (Sequence[str]): Recorded path entries.
        modules (Sequence[str]): Recorded module names.
        shared_surfaces (Sequence[str]): Recorded shared surfaces.
        contracts (Sequence[str]): Recorded contract identifiers.
        source (str): Confidence source to record.

    Returns:
        BlastRadius: The constructed radius.
    """
    return BlastRadius(
        paths=paths,
        modules=modules,
        shared_surfaces=shared_surfaces,
        contracts=contracts,
        source=source,
        computed_at=COMPUTED_AT,
    )


def test_normalize_declared_radius_does_not_mutate_its_input() -> None:
    """The function is pure: the supplied radius is unchanged afterwards."""
    # Arrange
    radius = declared_radius(
        paths=["config/blast-radius.json", "scripts/dev_tools", "quality-tiers.yml"],
        contracts=["normalize_declared_radius", "->"],
        shared_surfaces=["config/blast-radius.json", "quality-tiers.yml"],
    )
    snapshot = radius.to_dict()

    # Act
    normalize_declared_radius(radius, NORMALIZER_CONFIG)

    # Assert
    assert radius.to_dict() == snapshot


def test_normalize_declared_radius_is_idempotent_on_a_clean_radius() -> None:
    """Normalizing an already-clean radius returns an equal radius."""
    # Arrange
    radius = declared_radius()

    # Act
    once = normalize_declared_radius(radius, NORMALIZER_CONFIG)
    twice = normalize_declared_radius(once, NORMALIZER_CONFIG)

    # Assert
    assert once.to_dict() == radius.to_dict()
    assert twice.to_dict() == once.to_dict()


def test_normalize_declared_radius_rejects_an_observed_source_radius() -> None:
    """An observed radius records a diff listing and must not be re-filtered."""
    # Arrange
    radius = declared_radius(source="observed")

    # Act / Assert
    with pytest.raises(ValueError, match="observed"):
        normalize_declared_radius(radius, NORMALIZER_CONFIG)


def test_normalize_declared_radius_drops_every_rejected_entry_class() -> None:
    """Directory tokens, corpus globs, mandate reads, and notation all drop."""
    # Arrange
    radius = declared_radius(
        paths=[
            ".claude/rules/**",
            "artifacts/pr_context.summary.txt",
            "config/blast-radius.json",
            "docs/features/**/plan*.md",
            "quality-tiers.yml",
            "scripts/dev_tools",
        ],
        modules=["config", "python-dev-tools"],
        shared_surfaces=["config/blast-radius.json", "quality-tiers.yml"],
        contracts=["normalize_declared_radius", "->", "{"],
    )

    # Act
    result = normalize_declared_radius(radius, NORMALIZER_CONFIG)

    # Assert
    assert result.paths == ("config/blast-radius.json",)
    assert result.modules == ("config",)
    assert result.shared_surfaces == ("config/blast-radius.json",)
    assert result.contracts == ("normalize_declared_radius",)
    assert result.source == "declared"
    assert result.computed_at == COMPUTED_AT
