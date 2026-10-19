"""Select fixed analyzers and import optional implementations only after consent.

Profiles select inert identifiers; they cannot name executable Python modules.
Reserved metadata and literal dispatch share one fixed implementation boundary.
"""

from __future__ import annotations

from typing import TYPE_CHECKING, Protocol, cast

from drm_copilot_discovery import __version__
from drm_copilot_discovery.analyzer.inventory import RepositoryAnalyzer
from drm_copilot_discovery.models import JsonObject
from drm_copilot_discovery.profile_v2 import ProfileV2

if TYPE_CHECKING:
    from drm_copilot_discovery.analyzer.models import Analysis, InventoryCapture

_BUILTIN_IDENTIFIERS = (
    "com-interop",
    "configuration",
    "csharp-symbols",
    "dependencies",
    "dotnet",
    "event-subscriptions",
    "filesystem-access",
    "office-vsto",
    "registry-access",
    "repository",
    "test-references",
    "ui-callbacks",
)


def builtin_analyzer_identities() -> tuple[JsonObject, ...]:
    """Return the complete sorted reserved identity/version metadata without I/O.

    No parameters. Returns tuple[JsonObject, ...], with fresh immutable id/version
    records on every call. Versions use the installed runtime's __version__.
    No implementation imports, profile evaluation or mutation occurs; there are
    no expected contract exceptions. Metadata alone never authorizes execution.
    """
    # Keep external impersonation checks independent of implementation loading.
    return tuple(
        JsonObject((("id", identifier), ("version", __version__)))
        for identifier in _BUILTIN_IDENTIFIERS
    )


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


def _generic_analyzer(identifier: str) -> InventoryAdapter:
    """Instantiate one previously validated generic selector using literal imports.

    identifier (str) is a reserved generic ID checked by select_analyzers. Returns
    InventoryAdapter; import failures propagate. No I/O or configuration-driven
    module lookup occurs. The caller excludes the optional selector first.
    """
    # Load only the requested implementation, preserving ordinary inventory imports.
    if identifier == "repository":
        return RepositoryAnalyzer()
    if identifier == "com-interop":
        from drm_copilot_discovery.analyzer.com_interop import ComInteropAnalyzer

        return ComInteropAnalyzer()
    if identifier == "configuration":
        from drm_copilot_discovery.analyzer.configuration import ConfigurationAnalyzer

        return ConfigurationAnalyzer()
    if identifier == "csharp-symbols":
        from drm_copilot_discovery.analyzer.dotnet_inventory import (
            CSharpDeclarationAnalyzer,
        )

        return CSharpDeclarationAnalyzer()
    if identifier == "event-subscriptions":
        from drm_copilot_discovery.analyzer.dotnet_inventory import (
            EventSubscriptionAnalyzer,
        )

        return EventSubscriptionAnalyzer()
    if identifier == "dotnet":
        from drm_copilot_discovery.analyzer.dotnet_projects import DotnetProjectAnalyzer

        return DotnetProjectAnalyzer()
    if identifier == "filesystem-access":
        from drm_copilot_discovery.analyzer.filesystem_access import (
            FilesystemAccessAnalyzer,
        )

        return FilesystemAccessAnalyzer()
    if identifier == "registry-access":
        from drm_copilot_discovery.analyzer.registry_access import (
            RegistryAccessAnalyzer,
        )

        return RegistryAccessAnalyzer()
    if identifier == "test-references":
        from drm_copilot_discovery.analyzer.test_references import TestReferenceAnalyzer

        return TestReferenceAnalyzer()
    if identifier == "ui-callbacks":
        from drm_copilot_discovery.analyzer.ui_callbacks import UiCallbackAnalyzer

        return UiCallbackAnalyzer()
    # The complete public selector check leaves only the dependency adapter here.
    from drm_copilot_discovery.analyzer.dependencies import DependencyAnalyzer

    return DependencyAnalyzer()


def select_analyzers(profile: ProfileV2) -> tuple[InventoryAdapter, ...]:
    """Resolve configured built-ins or fail before any analysis/publication.

    Unknown adapters never silently fall back to repository
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
    unsupported = set(enabled) - {item["id"] for item in builtin_analyzer_identities()}
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
            selected.append(_generic_analyzer(identifier))
    return tuple(selected)
