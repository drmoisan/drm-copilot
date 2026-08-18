"""Reader and derivation tests for the ``mandate_reads`` truth-table key.

Cover the two halves of the read-by-mandate exclusion introduced by issue #489:
``config_mandate_reads`` reads the optional key from a caller-supplied mapping,
and ``derive_blast_radius``/``validate_blast_radius`` apply the resulting
exclusion symmetrically so a derived radius keeps passing V1 and V2 against its
own plan. Every configuration used here is an in-memory literal or the
committed truth table; no temporary file is created and no external process is
started.
"""

from __future__ import annotations

import json
from pathlib import Path
from typing import TYPE_CHECKING

import pytest

from scripts.dev_tools._blast_radius_validation import config_mandate_reads
from scripts.dev_tools.compute_blast_radius import (
    derive_blast_radius,
    validate_blast_radius,
)

if TYPE_CHECKING:
    from collections.abc import Mapping

# Repo-root resolution: this file lives at
# tests/scripts/dev_tools/test_blast_radius_mandate_reads.py, so the repository
# root is three parents above the file's resolved directory.
REPO_ROOT = Path(__file__).resolve().parents[3]
CONFIG_PATH = REPO_ROOT / "config" / "blast-radius.json"

# Timestamp handed to every derived radius below. A constant rather than a clock
# read keeps the derivation tests deterministic.
COMPUTED_AT = "2026-08-18T10-00"
FEATURE_FOLDER = "2026-08-18-example-mandate-reads"

# A plan whose only citations outside its own feature folder are mandate reads
# plus one genuine write claim. Every agent is instructed to read the policy
# rules and the tier map, so those two citations are evidence of compliance.
MANDATE_CITING_PLAN = "\n".join(
    [
        "### Phase 0 - Policy Reads",
        "- [ ] [P0-T1] Read `.claude/rules/python.md` and `quality-tiers.yml`.",
        "- [ ] [P0-T2] Record evidence at `artifacts/pr_context.summary.txt`.",
        "### Phase 1 - Implementation",
        "- [ ] [P1-T1] Edit `scripts/dev_tools/compute_blast_radius.py`.",
    ]
)

# Tracked-file count handed to V3. The value is large enough that a small radius
# never trips the over-breadth advisory, keeping these tests focused on V1/V2.
TRACKED_FILE_COUNT = 5000


def committed_config() -> dict[str, object]:
    """Load the committed truth table.

    Returns:
        dict[str, object]: The parsed ``config/blast-radius.json`` mapping.
    """
    parsed: dict[str, object] = json.loads(CONFIG_PATH.read_text(encoding="utf-8"))
    return parsed


def derive(config: Mapping[str, object]) -> object:
    """Derive a radius from ``MANDATE_CITING_PLAN`` under a supplied config.

    Args:
        config (Mapping[str, object]): Truth table to derive against.

    Returns:
        object: The derived ``BlastRadius``.
    """
    return derive_blast_radius(
        MANDATE_CITING_PLAN,
        "",
        FEATURE_FOLDER,
        config,
        computed_at=COMPUTED_AT,
    )


def test_config_mandate_reads_returns_the_present_entries_sorted() -> None:
    """A present key yields its entries deduplicated and ordinally sorted."""
    # Arrange: a mapping whose entries are unsorted and carry one duplicate.
    config: Mapping[str, object] = {
        "mandate_reads": ["quality-tiers.yml", ".claude/rules/**", "quality-tiers.yml"]
    }

    # Act
    result = config_mandate_reads(config)

    # Assert
    assert result == (".claude/rules/**", "quality-tiers.yml")


def test_config_mandate_reads_absent_key_yields_an_empty_tuple() -> None:
    """An absent key excludes nothing, reproducing pre-change behaviour."""
    # Arrange: a minimal config carrying every other key but not this one.
    config: Mapping[str, object] = {"shared_surfaces": ["quality-tiers.yml"]}

    # Act
    result = config_mandate_reads(config)

    # Assert
    assert result == ()


def test_config_mandate_reads_rejects_a_non_list_value() -> None:
    """A scalar value is a malformed truth table, not an implicit one-entry list."""
    # Arrange
    config: Mapping[str, object] = {"mandate_reads": "quality-tiers.yml"}

    # Act / Assert
    with pytest.raises(TypeError, match="must be a list or tuple"):
        config_mandate_reads(config)


def test_config_mandate_reads_rejects_a_blank_entry() -> None:
    """A whitespace-only entry would exclude nothing and is rejected loudly."""
    # Arrange
    config: Mapping[str, object] = {"mandate_reads": ["quality-tiers.yml", "   "]}

    # Act / Assert
    with pytest.raises(ValueError, match="must not be empty"):
        config_mandate_reads(config)


def test_derive_excludes_mandate_read_citations_from_every_level() -> None:
    """A mandate-read citation enters neither paths, modules, nor surfaces."""
    # Arrange
    config = committed_config()

    # Act
    radius = derive(config)

    # Assert: the policy rule, the tier map, and the process artifact are all
    # absent, while the genuine write claim survives.
    assert ".claude/rules/python.md" not in radius.paths
    assert "quality-tiers.yml" not in radius.paths
    assert "artifacts/pr_context.summary.txt" not in radius.paths
    assert "scripts/dev_tools/compute_blast_radius.py" in radius.paths
    assert "quality-tiers.yml" not in radius.shared_surfaces
    assert radius.modules == ()


def test_derive_without_the_mandate_reads_key_includes_the_citations() -> None:
    """Removing the key restores the pre-change derivation output exactly."""
    # Arrange: the committed table with only the new key removed.
    config = committed_config()
    config.pop("mandate_reads")

    # Act
    radius = derive(config)

    # Assert
    assert ".claude/rules/python.md" in radius.paths
    assert "quality-tiers.yml" in radius.paths
    assert "quality-tiers.yml" in radius.shared_surfaces


def test_derive_with_an_absent_key_matches_an_empty_mandate_read_list() -> None:
    """An absent key and an explicitly empty list derive identical radii.

    This is the byte-identical-derivation half of AC-A4: the exclusion is
    fail-closed, so a truth table that does not opt in behaves as before.
    """
    # Arrange
    absent = committed_config()
    absent.pop("mandate_reads")
    empty = committed_config()
    empty["mandate_reads"] = []

    # Act
    without_key = derive(absent)
    with_empty_list = derive(empty)

    # Assert
    assert without_key.to_dict() == with_empty_list.to_dict()


def test_derive_excludes_an_artifacts_path_through_the_subtree_glob() -> None:
    """``artifacts/pr_context.summary.txt`` is excluded by ``artifacts/**``."""
    # Arrange
    config = committed_config()

    # Act
    radius = derive(config)

    # Assert
    assert not any(path.startswith("artifacts/") for path in radius.paths), (
        "No artifacts path may enter the radius; observed "
        f"{[p for p in radius.paths if p.startswith('artifacts/')]}."
    )


def test_derived_radius_validates_clean_against_its_own_mandate_citing_plan() -> None:
    """The exclusion is symmetric: derivation and V1/V2 filter the same set.

    Without the matching filter in ``validate_blast_radius`` every post-fix plan
    citing a policy file would produce V1 Blocking findings against its own
    derived radius.
    """
    # Arrange
    config = committed_config()
    radius = derive(config)

    # Act
    findings = validate_blast_radius(
        radius,
        MANDATE_CITING_PLAN,
        config,
        tracked_file_count=TRACKED_FILE_COUNT,
    )

    # Assert
    assert findings == [], (
        "A derived radius must validate clean against its own plan; observed "
        f"{[(f.rule, f.subject) for f in findings]}."
    )
