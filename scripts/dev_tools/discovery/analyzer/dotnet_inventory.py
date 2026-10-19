"""Preserve legacy C# imports through the authoritative runtime implementation.

The exact analyzer class/function objects are re-exported without parsing,
evidence logic, optional adapter imports or publication at this boundary.
"""

from drm_copilot_discovery.analyzer.dotnet_inventory import (
    DotnetInventoryAnalyzer as DotnetInventoryAnalyzer,
)
from drm_copilot_discovery.analyzer.dotnet_inventory import (
    classify_text as classify_text,
)
