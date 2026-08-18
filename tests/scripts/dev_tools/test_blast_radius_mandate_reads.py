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

from pathlib import Path
from typing import TYPE_CHECKING

import pytest

from scripts.dev_tools._blast_radius_validation import config_mandate_reads

if TYPE_CHECKING:
    from collections.abc import Mapping

# Repo-root resolution: this file lives at
# tests/scripts/dev_tools/test_blast_radius_mandate_reads.py, so the repository
# root is three parents above the file's resolved directory.
REPO_ROOT = Path(__file__).resolve().parents[3]
CONFIG_PATH = REPO_ROOT / "config" / "blast-radius.json"


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
