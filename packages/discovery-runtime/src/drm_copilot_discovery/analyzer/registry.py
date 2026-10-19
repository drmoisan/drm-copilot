"""Select fixed analyzers and import optional implementations only after consent.

Profiles select inert identifiers; they cannot name executable Python modules.
Additional approved adapters are registered at this boundary by later slices.
"""

from __future__ import annotations

from typing import TYPE_CHECKING, Protocol, cast

from drm_copilot_discovery.analyzer.inventory import RepositoryAnalyzer
from drm_copilot_discovery.profile_v2 import ProfileV2

if TYPE_CHECKING:
    from drm_copilot_discovery.analyzer.models import Analysis, InventoryCapture


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
    configuration and ValueError for invalid profiles or unavailable selections.
    Performs no I/O; optional imports occur only after validating the entire set.
    """
    if not isinstance(cast("object", profile), ProfileV2):
        raise ValueError("Analyzer selection requires a validated ProfileV2")
    profile.require_configured()
    enabled = tuple(sorted(profile.analyzers.enabled))
    unsupported = set(enabled) - {"repository", "office-vsto"}
    if unsupported or not enabled:
        raise ValueError(
            "Unavailable analyzer selection; configure supported adapters: "
            + ", ".join(sorted(unsupported))
        )
    selected: list[InventoryAdapter] = []
    # Validate the complete selection first; never import a partial valid subset.
    for identifier in enabled:
        # Only the fixed optional selector permits this literal lazy import.
        if identifier == "office-vsto":
            from drm_copilot_discovery.analyzer.optional.vsto_office import (
                VstoOfficeAnalyzer,
            )

            selected.append(VstoOfficeAnalyzer())
        else:
            selected.append(RepositoryAnalyzer())
    return tuple(selected)
