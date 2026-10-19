"""Inventory fixed registry API syntax without resolving keys or Windows support.

Known Registry root properties and Registry/RegistryKey static calls are lexical
candidates only. Instance receiver variables and aliases are not resolved; actual
runtime key paths, values and platform applicability remain unknown.
"""

from __future__ import annotations

from typing import TYPE_CHECKING

from drm_copilot_discovery.analyzer.api_access import analyze_access
from drm_copilot_discovery.analyzer.api_syntax import ApiSurface

if TYPE_CHECKING:
    from drm_copilot_discovery.analyzer.models import Analysis, InventoryCapture

# Registry roots are declarations of access syntax, never verified platform usage.
REGISTRY_SURFACE = ApiSurface(
    identifier="registry-access",
    namespace=("Microsoft", "Win32"),
    calls=frozenset(
        {
            ("Registry", "GetValue"),
            ("Registry", "SetValue"),
            ("RegistryKey", "OpenBaseKey"),
            ("RegistryKey", "OpenRemoteBaseKey"),
        }
    ),
    # Fixed root names remain independent of discovered key names and values.
    properties=frozenset(
        ("Registry", name)
        for name in (
            "ClassesRoot",
            "CurrentConfig",
            "CurrentUser",
            "LocalMachine",
            "PerformanceData",
            "Users",
        )
    ),
)


class RegistryAccessAnalyzer:
    """Project unresolved registry candidates without accessing the registry."""

    identifier = "registry-access"

    def analyze(self, capture: InventoryCapture) -> Analysis:
        """Return Analysis for InventoryCapture using fixed registry definitions.

        Malformed/unavailable selected inputs produce redacted diagnostics; known
        syntax cannot verify bindings, keys or supported platforms. No I/O occurs.
        """
        return analyze_access(capture, REGISTRY_SURFACE)
