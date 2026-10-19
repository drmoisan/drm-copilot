"""Keep legacy optional-analyzer names behind explicit v2 configuration consent.

Pure classifiers retain positional path/text calls, but require a configured
profile selecting office-vsto. Legacy filesystem pipelines cannot establish
immutable provenance and therefore fail before reading or writing anything.
"""

from __future__ import annotations

from typing import TYPE_CHECKING, cast

from drm_copilot_discovery.analyzer.csharp_tokens import SourceScanError
from drm_copilot_discovery.analyzer.inventory import AnalyzerError
from drm_copilot_discovery.analyzer.models import InventoryCapture
from drm_copilot_discovery.profile_v2 import ProfileV2

if TYPE_CHECKING:
    from pathlib import Path

    from drm_copilot_discovery.analyzer.models import (
        Analysis,
        AnalyzerContext,
        ClassifyResult,
        EvidenceRecord,
        ParseResult,
    )
    from drm_copilot_discovery.analyzer.pipeline import AnalyzerFileSystem
    from drm_copilot_discovery.analyzer.source_text import Detection

_MIGRATION_ERROR = (
    "Legacy vsto-office execution requires a v2 InventoryCapture and a configured "
    "ProfileV2 enabling office-vsto; use analyze(capture). "
    "No files were read or written."
)


def _require_consent(profile: ProfileV2 | None) -> ProfileV2:
    """Validate consent before importing optional implementation code.

    profile (ProfileV2 | None) is the caller's explicit validated configuration.
    Returns the configured ProfileV2 selecting office-vsto. Raises SourceScanError
    with office-consent for missing/incorrect/disabled profiles, or ProfileError
    for a draft. Performs no I/O, imports or source processing.
    """
    if not isinstance(profile, ProfileV2):
        raise SourceScanError(
            "office-consent", "Supply a configured ProfileV2 enabling office-vsto."
        )
    profile.require_configured()
    if "office-vsto" not in profile.analyzers.enabled:
        raise SourceScanError(
            "office-consent",
            "Enable office-vsto explicitly in the configured ProfileV2.",
        )
    return profile


def classify_csharp(
    path: str,
    text: str,
    *,
    profile: ProfileV2 | None = None,
    max_tokens: int = 100000,
    max_candidates: int = 100000,
) -> list[Detection]:
    """Forward a consented C# text call to the canonical bounded classifier.

    path (str) is a relative source name; text (str) is retained decoded content.
    profile (ProfileV2 | None) supplies explicit configured consent. max_tokens
    and max_candidates (int) are positive capacities limited by that profile.
    Returns list[Detection] of syntax facts/inferences, never runtime proof.
    Raises SourceScanError for invalid input/consent, ValueError for capacities,
    PathPolicyError for invalid paths, or ProfileError for
    drafts. Imports only the fixed optional implementation after consent; no I/O.
    """
    configured = _require_consent(profile)
    from drm_copilot_discovery.analyzer.optional.vsto_office import (
        classify_csharp as classify,
    )

    return classify(
        path,
        text,
        profile=configured,
        max_tokens=max_tokens,
        max_candidates=max_candidates,
    )


def classify_xml(
    path: str,
    text: str,
    *,
    profile: ProfileV2 | None = None,
    max_bytes: int = 67108864,
    max_elements: int = 100000,
    max_depth: int = 64,
    max_candidates: int = 100000,
) -> list[Detection]:
    """Forward consented complete XML to the canonical secure classifier.

    path (str) is a relative name; text (str) is caller-retained decoded XML.
    profile (ProfileV2 | None) supplies configured consent. max_bytes,
    max_elements, max_depth and max_candidates (int) are positive byte, element,
    nesting and output capacities, constrained by the profile. Returns
    list[Detection]. Raises SourceScanError for consent/input, ValueError for
    capacities, PathPolicyError for invalid paths, ProfileError
    for drafts, or XmlInputError for invalid XML. Imports lazily; performs no I/O.
    """
    configured = _require_consent(profile)
    from drm_copilot_discovery.analyzer.optional.vsto_office import (
        classify_xml as classify,
    )

    return classify(
        path,
        text,
        profile=configured,
        max_bytes=max_bytes,
        max_elements=max_elements,
        max_depth=max_depth,
        max_candidates=max_candidates,
    )


def classify_project(
    path: str,
    text: str,
    *,
    profile: ProfileV2 | None = None,
    max_bytes: int = 67108864,
    max_elements: int = 100000,
    max_depth: int = 64,
    max_candidates: int = 100000,
) -> list[Detection]:
    """Forward consented project XML without evaluating imports or properties.

    path (str) is a relative project name; text (str) contains the complete XML.
    profile (ProfileV2 | None) supplies configured consent. max_bytes,
    max_elements, max_depth and max_candidates (int) limit bytes, elements,
    nesting and output within profile capacities. Returns list[Detection]. Raises
    SourceScanError for consent/input, ValueError for capacities, PathPolicyError
    for invalid paths, ProfileError for drafts, or
    XmlInputError for invalid XML. Imports lazily; no I/O or build evaluation.
    """
    configured = _require_consent(profile)
    from drm_copilot_discovery.analyzer.optional.vsto_office import (
        classify_project as classify,
    )

    return classify(
        path,
        text,
        profile=configured,
        max_bytes=max_bytes,
        max_elements=max_elements,
        max_depth=max_depth,
        max_candidates=max_candidates,
    )


class VstoOfficeAnalyzer:
    """Preserve legacy construction while requiring an immutable v2 capture.

    Construct with the historical optional fs positional argument and optional
    keyword profile, then call analyze(capture). The filesystem argument is never
    accessed or defaulted. A supplied profile adds a consent check; the canonical
    adapter always checks capture consent. Legacy pipeline stages always reject.
    No state other than the optional immutable profile is retained; no I/O occurs.
    """

    name = "vsto-office"
    identifier = "office-vsto"

    def __init__(
        self, fs: AnalyzerFileSystem | None = None, *, profile: ProfileV2 | None = None
    ) -> None:
        """Retain an optional profile without creating or accessing a filesystem.

        fs (AnalyzerFileSystem | None) is an ignored compatibility argument.
        profile (ProfileV2 | None) is checked at analyze time. Returns None,
        mutating only this instance; performs no I/O or optional imports.
        """
        del fs
        self._profile = profile

    def analyze(self, capture: InventoryCapture) -> Analysis:
        """Delegate the exact capture after checking all supplied consent.

        capture (InventoryCapture) retains immutable bytes, pins and profile.
        Returns canonical Analysis without publishing. Raises AnalyzerError for
        a wrong capture type, SourceScanError for missing consent, or ProfileError
        for drafts; canonical analysis may return fixed diagnostics. Imports the
        fixed implementation lazily and performs no filesystem operations.
        """
        if not isinstance(cast("object", capture), InventoryCapture):
            raise AnalyzerError(_MIGRATION_ERROR)
        if self._profile is not None:
            _require_consent(self._profile)
        _require_consent(capture.profile)
        from drm_copilot_discovery.analyzer.optional.vsto_office import (
            VstoOfficeAnalyzer as CanonicalAnalyzer,
        )

        return CanonicalAnalyzer().analyze(capture)

    def parse(self, ctx: AnalyzerContext) -> ParseResult:
        """Reject ctx (AnalyzerContext) before traversal; never return ParseResult.

        Raises fixed AnalyzerError requiring v2 capture. No I/O or mutation.
        """
        del ctx
        raise AnalyzerError(_MIGRATION_ERROR)

    def classify(self, parsed: ParseResult) -> ClassifyResult:
        """Reject parsed (ParseResult); never return a v1 ClassifyResult.

        Raises fixed AnalyzerError requiring v2 capture. No I/O or mutation.
        """
        del parsed
        raise AnalyzerError(_MIGRATION_ERROR)

    def map(self, classified: ClassifyResult) -> tuple[EvidenceRecord, ...]:
        """Reject classified (ClassifyResult); never fabricate v1 evidence.

        Returns no tuple[EvidenceRecord, ...]; raises fixed AnalyzerError requiring
        v2 capture before hashing or reading bytes. No I/O or mutation.
        """
        del classified
        raise AnalyzerError(_MIGRATION_ERROR)

    def emit(
        self, records: tuple[EvidenceRecord, ...], fs: AnalyzerFileSystem
    ) -> tuple[Path, ...]:
        """Reject records (tuple[EvidenceRecord, ...]) and fs (AnalyzerFileSystem).

        Returns no tuple[Path, ...]; raises fixed AnalyzerError requiring v2
        capture. Neither argument is inspected; no I/O or mutation occurs.
        """
        del records, fs
        raise AnalyzerError(_MIGRATION_ERROR)
