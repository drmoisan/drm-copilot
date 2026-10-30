"""Preserve legacy imports while the installable discovery runtime owns behavior."""

from drm_copilot_discovery.analyzer.pipeline import (
    Analyzer as Analyzer,
)
from drm_copilot_discovery.analyzer.pipeline import (
    AnalyzerFileSystem as AnalyzerFileSystem,
)
from drm_copilot_discovery.analyzer.pipeline import (
    RealAnalyzerFileSystem as RealAnalyzerFileSystem,
)
from drm_copilot_discovery.analyzer.pipeline import (
    run_analyzer as run_analyzer,
)
