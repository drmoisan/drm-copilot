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
    conflicts,
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


def test_normalize_declared_radius_strips_a_placeholder_entry() -> None:
    """Strip a placeholder entry from an already-recorded radius (issue #502).

    This is the retrospective-cleaning path. The guard lives in the classifier,
    and ``normalize_declared_radius`` re-runs the classifier over each recorded
    entry, so a radius that was recorded before the guard existed is cleaned by
    normalization rather than by re-derivation, which is not always possible.

    The assertions cover all three dependent levels, not just ``paths``,
    because the module and shared-surface levels are re-resolved from the
    surviving paths. A normalizer that dropped the entry from ``paths`` while
    leaving a stale module or shared surface behind would still make two
    unrelated items contend, one level up from where the entry was removed.
    """
    # Arrange: a recorded radius carrying one placeholder entry whose shape
    # matches the configured shared surface, one placeholder entry that resolves
    # into the configured module, and two real entries that must survive.
    radius = declared_radius(
        paths=[
            "<FEATURE>/spec.md",
            "config/blast-radius.json",
            "config/${environment}.json",
            "scripts/dev_tools/compute_blast_radius.py",
        ],
        modules=["config"],
        shared_surfaces=["config/blast-radius.json"],
        contracts=["normalize_declared_radius"],
    )

    # Act
    result = normalize_declared_radius(radius, NORMALIZER_CONFIG)

    # Assert: both placeholder entries are gone and both real entries survive.
    assert result.paths == (
        "config/blast-radius.json",
        "scripts/dev_tools/compute_blast_radius.py",
    )
    # The module level is re-resolved from the surviving paths, so the module the
    # placeholder entry would have contributed is present only because a real
    # entry also resolves to it.
    assert result.modules == ("config",)
    # The shared-surface level is likewise re-resolved from the surviving
    # concrete entries.
    assert result.shared_surfaces == ("config/blast-radius.json",)
    assert result.contracts == ("normalize_declared_radius",)
    assert result.source == "declared"
    assert result.computed_at == COMPUTED_AT


def test_normalize_declared_radius_clears_a_level_a_placeholder_alone_supplied() -> (
    None
):
    """Re-resolution removes a level no surviving real entry supports.

    The companion above keeps ``config`` because a real entry also resolves to
    it, which cannot distinguish re-resolution from passthrough. Here the only
    entry that reached the module and shared-surface levels is the placeholder,
    so both levels must come back empty. Without this case a normalizer that
    copied the recorded levels verbatim would satisfy the companion.
    """
    # Arrange
    radius = declared_radius(
        paths=[
            "config/${environment}.json",
            "scripts/dev_tools/compute_blast_radius.py",
        ],
        modules=["config"],
        shared_surfaces=["config/blast-radius.json"],
        contracts=["normalize_declared_radius"],
    )

    # Act
    result = normalize_declared_radius(radius, NORMALIZER_CONFIG)

    # Assert
    assert result.paths == ("scripts/dev_tools/compute_blast_radius.py",)
    assert result.modules == ()
    assert result.shared_surfaces == ()


def test_placeholder_only_overlap_stops_conflicting_after_normalization() -> None:
    """Two radii sharing only a placeholder token stop contending (issue #502).

    This is the pair-level regression test for the placeholder guard, and the
    normalization step is what places the assertion on the classifier's path.
    ``conflicts`` compares recorded path entries by string equality, glob match,
    and directory containment; it never calls ``classify_path_token``. So a pair
    of hand-authored radii contends on a shared placeholder token whether or not
    the guard exists, and asserting the raw pair proves nothing about the fix.
    ``normalize_declared_radius`` re-runs the classifier over each recorded
    entry, so normalizing first is what routes the comparison through the guard
    and makes the second assertion below fail on a tree where the classifier was
    never fixed.

    Both halves are required. The pre-normalization assertion is the control that
    proves the two radii really do share an entry: without it, a construction
    error that left the pair disjoint from the start would satisfy the
    post-normalization assertion vacuously. The post-normalization assertion is
    the one that pins the fix.
    """
    # Arrange: the only shared entry is a placeholder feature-document token.
    # Real files are disjoint and sit under different feature folders, and the
    # module, shared-surface, and contract levels are disjoint too, so no other
    # level can produce a conflict reason.
    placeholder = "<FEATURE>/spec.md"
    radius_a = declared_radius(
        paths=[
            placeholder,
            "docs/features/active/2026-08-23-alpha-item-9001/plan.md",
            "scripts/dev_tools/alpha_only_module.py",
        ],
        modules=["alpha"],
        shared_surfaces=[],
        contracts=["Alpha"],
    )
    radius_b = declared_radius(
        paths=[
            placeholder,
            "docs/features/active/2026-08-23-beta-item-9002/plan.md",
            "scripts/dev_tools/beta_only_module.py",
        ],
        modules=["beta"],
        shared_surfaces=[],
        contracts=["Beta"],
    )

    # Assert first half: the pre-normalization pair DOES conflict, on the shared
    # placeholder token and on nothing else.
    before = conflicts(radius_a, radius_b, NORMALIZER_CONFIG)
    assert before.conflict is True, (
        "Expected the un-normalized pair to conflict on the shared placeholder "
        f"token; observed {before}."
    )
    assert [reason.kind for reason in before.reasons] == ["path_overlap"], (
        "Expected exactly one path_overlap reason before normalization; observed "
        f"{[(r.kind, r.detail) for r in before.reasons]}."
    )
    assert placeholder in before.reasons[0].detail

    # Act: route both radii through the classifier via normalization.
    normalized_a = normalize_declared_radius(radius_a, NORMALIZER_CONFIG)
    normalized_b = normalize_declared_radius(radius_b, NORMALIZER_CONFIG)

    # Assert second half: the normalized pair does NOT conflict.
    after = conflicts(normalized_a, normalized_b, NORMALIZER_CONFIG)
    assert after.conflict is False, (
        "Expected the normalized pair not to conflict once the placeholder token "
        f"is dropped; observed {after}."
    )
    assert after.reasons == ()
    # The placeholder is gone from both radii and every real entry survived.
    assert placeholder not in normalized_a.paths
    assert placeholder not in normalized_b.paths
    assert "scripts/dev_tools/alpha_only_module.py" in normalized_a.paths
    assert "scripts/dev_tools/beta_only_module.py" in normalized_b.paths
