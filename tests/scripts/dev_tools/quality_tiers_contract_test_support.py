"""Shared helpers for the quality-tiers contract test modules."""

from __future__ import annotations

from scripts.dev_tools.quality_tiers_contract import (
    QualityTierEntry,
    QualityTierError,
    QualityTierManifest,
)


def qt_codes(errors: list[QualityTierError]) -> list[str]:
    """Return the QT codes of ``errors`` in their reported order."""
    return [error.code for error in errors]


def make_manifest(*entries: tuple[str, str]) -> QualityTierManifest:
    """Build an in-memory manifest from ``(path, tier)`` pairs."""
    items = tuple(QualityTierEntry(path, tier, "rationale") for path, tier in entries)
    return QualityTierManifest(version=1, entries=items)
