"""Select explicit built-in analyzers without importing optional domain adapters.

Profiles select inert identifiers; they cannot name executable Python modules.
Additional approved adapters are registered at this boundary by later slices.
"""

from __future__ import annotations

from typing import TYPE_CHECKING, Protocol

from drm_copilot_discovery.analyzer.inventory import RepositoryAnalyzer

if TYPE_CHECKING:
    from drm_copilot_discovery.analyzer.models import Analysis, InventoryCapture
    from drm_copilot_discovery.profile_v2 import ProfileV2


class InventoryAdapter(Protocol):
    """Analyze one immutable capture and return source-bound rows without I/O."""

    @property
    def identifier(self) -> str:
        """Expose the fixed registry identifier, not a caller-selected import path.

        Returns str naming this adapter; takes no arguments and performs no I/O.
        """
        ...

    def analyze(self, capture: InventoryCapture) -> Analysis:
        """Return deterministic detections without altering capture or coverage.

        capture (InventoryCapture) supplies immutable configured inputs. Returns
        Analysis containing detections and diagnostics. Invalid adapter inputs raise
        ValueError; implementations must not perform I/O or mutate inputs.
        """
        ...


def select_analyzers(profile: ProfileV2) -> tuple[InventoryAdapter, ...]:
    """Resolve configured built-ins or fail before any analysis/publication.

    Unknown and not-yet-installed adapters never silently fall back to repository
    analysis. Core enumeration imports no optional domain-specific packages.

    profile (ProfileV2) supplies the validated configured selection. Returns a
    sorted tuple of InventoryAdapter implementations. Raises ProfileError for draft
    configuration and ValueError for unavailable selections; performs no I/O.
    """
    profile.require_configured()
    enabled = tuple(sorted(profile.analyzers.enabled))
    unsupported = set(enabled) - {"repository"}
    if unsupported or not enabled:
        raise ValueError(
            "Unavailable analyzer selection; configure supported adapters: "
            + ", ".join(sorted(unsupported))
        )
    return (RepositoryAnalyzer(),)
