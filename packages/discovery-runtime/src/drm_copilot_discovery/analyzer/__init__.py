"""Provide typed, read-only discovery analyzers with explicit guarded publication."""

from drm_copilot_discovery.analyzer.registry import InventoryAdapter as Analyzer
from drm_copilot_discovery.analyzer.registry import (
    builtin_analyzer_identities,
    select_analyzers,
)

__all__ = ["Analyzer", "builtin_analyzer_identities", "select_analyzers"]
