"""Verify consented lazy compatibility and rejection of the unpinned v1 pipeline."""

from __future__ import annotations

import builtins
import runpy
from dataclasses import replace
from pathlib import Path
from typing import TYPE_CHECKING, cast

import pytest
from drm_copilot_discovery.analyzer.csharp_tokens import SourceScanError
from drm_copilot_discovery.analyzer.inventory import AnalyzerError
from drm_copilot_discovery.analyzer.models import (
    Analysis,
    AnalyzerContext,
    ClassifyResult,
    InventoryCapture,
    ParseResult,
)
from drm_copilot_discovery.profile_v2 import ProfileError, ProfileV2

from scripts.dev_tools.discovery.analyzer import vsto_office, vsto_patterns
from tests.discovery_runtime.analyzer.test_repository import (
    analyzer_catalog as analyzer_catalog,
)
from tests.discovery_runtime.analyzer.test_repository import (
    inventory_capture,
    inventory_profile,
)

if TYPE_CHECKING:
    from collections.abc import Callable
    from types import ModuleType

    from drm_copilot_discovery.analyzer.pipeline import AnalyzerFileSystem
    from drm_copilot_discovery.analyzer.source_text import Detection
    from drm_copilot_discovery.catalog import SchemaCatalog


@pytest.fixture(scope="module")
def office_profile(analyzer_catalog: SchemaCatalog) -> ProfileV2:
    """Return configured optional consent using analyzer_catalog (SchemaCatalog).

    Returns immutable ProfileV2; no I/O beyond the shared installed schema fixture.
    Invalid synthetic configuration raises ProfileError.
    """
    return inventory_profile(
        analyzer_catalog,
        analyzers={
            "enabled": ["office-vsto"],
            "options": {},
            "ignored_paths": [],
            "extension_result_manifests": [],
        },
    )


def _block_optional(monkeypatch: pytest.MonkeyPatch) -> list[str]:
    """Install an import observer with monkeypatch (pytest.MonkeyPatch).

    Returns list[str] of imports; raises AssertionError for any optional import.
    Patches only the test-local import seam, restored automatically by pytest.
    """
    original = builtins.__import__
    seen: list[str] = []

    def observe(
        name: str,
        globals: dict[str, object] | None = None,
        locals: dict[str, object] | None = None,
        fromlist: tuple[str, ...] = (),
        level: int = 0,
    ) -> ModuleType:
        """Forward named import parameters while rejecting the optional package.

        name (str), globals/locals (dict[str, object] | None), fromlist
        (tuple[str, ...]) and level (int) retain builtins.__import__ semantics.
        Returns ModuleType; raises AssertionError on optional imports, appending
        names only to the enclosing test-local list.
        """
        seen.append(name)
        assert ".analyzer.optional" not in name, "Consent must precede optional import"
        return original(name, globals, locals, fromlist, level)

    monkeypatch.setattr(builtins, "__import__", observe)
    return seen


@pytest.mark.parametrize("module", ["vsto_office", "vsto_patterns", "stack_cli"])
def test_ordinary_legacy_module_execution_has_no_optional_import(
    monkeypatch: pytest.MonkeyPatch,
    module: str,
) -> None:
    """Execute checked-in module text in isolated globals without optional imports.

    monkeypatch (pytest.MonkeyPatch) isolates the importer; module (str) selects
    one fixed source. Returns None; AssertionError signals eager loading. Reads
    only immutable repository source, executes in fresh memory and writes no file.
    """
    path = Path(vsto_office.__file__).with_name(module + ".py")
    _block_optional(monkeypatch)
    runpy.run_path(str(path), run_name="isolated")


@pytest.mark.parametrize(
    "function",
    [
        vsto_office.classify_csharp,
        vsto_office.classify_xml,
        vsto_office.classify_project,
    ],
)
@pytest.mark.parametrize("state", ["missing", "wrong-type", "disabled", "draft"])
def test_classifiers_reject_unconsented_profiles_before_import(
    analyzer_catalog: SchemaCatalog,
    monkeypatch: pytest.MonkeyPatch,
    function: Callable[..., list[Detection]],
    state: str,
) -> None:
    """Require validated explicit consent before any source processing.

    analyzer_catalog (SchemaCatalog) builds profiles; monkeypatch
    (pytest.MonkeyPatch) isolates imports; function (Callable[..., list[Detection]])
    is a fixed classifier;
    state (str) selects invalid consent. Returns None; AssertionError signals a
    wrong fixed error or import. Uses memory only after schema fixture loading.
    """
    profile: ProfileV2 | None = None
    # Different invalid authorities must fail without trusting source markers.
    if state == "wrong-type":
        profile = cast("ProfileV2", object())
    elif state in {"disabled", "draft"}:
        profile = inventory_profile(
            analyzer_catalog, **({"profile_state": "draft"} if state == "draft" else {})
        )
    _block_optional(monkeypatch)
    expected = ProfileError if state == "draft" else SourceScanError
    with pytest.raises(expected) as error:
        function(
            "src/item.cs", "class Ribbon : IRibbonExtensibility {}", profile=profile
        )
    if isinstance(error.value, SourceScanError):
        assert error.value.code == "office-consent"


@pytest.mark.parametrize("method", ["parse", "classify", "map", "emit"])
def test_v1_pipeline_rejects_before_inspecting_inputs_or_filesystem(
    monkeypatch: pytest.MonkeyPatch,
    method: str,
) -> None:
    """Keep historical stage names but reject unpinned execution before I/O.

    monkeypatch (pytest.MonkeyPatch) blocks optional imports; method (str) names
    the fixed stage. Returns None; AssertionError signals a wrong migration error.
    Opaque in-memory arguments cannot provide filesystem behavior.
    """
    _block_optional(monkeypatch)
    fs = cast("AnalyzerFileSystem", object())
    analyzer = vsto_office.VstoOfficeAnalyzer(fs)
    # Each stage rejects independently, including direct emit without parse.
    with pytest.raises(AnalyzerError, match="v2 InventoryCapture") as error:
        if method == "parse":
            analyzer.parse(cast("AnalyzerContext", object()))
        elif method == "classify":
            analyzer.classify(ParseResult(paths=()))
        elif method == "map":
            analyzer.map(ClassifyResult(units=()))
        else:
            analyzer.emit((), fs)
    assert "No files were read or written" in str(error.value)
    assert analyzer.name == "vsto-office"
    assert analyzer.identifier == "office-vsto"


@pytest.mark.parametrize("bad_capture", [None, object()])
def test_shim_requires_real_capture_before_import(
    monkeypatch: pytest.MonkeyPatch,
    bad_capture: object,
) -> None:
    """Reject bad_capture (object) before optional loading under isolated imports.

    monkeypatch (pytest.MonkeyPatch) patches only the importer. Returns None;
    AssertionError signals a missing fixed AnalyzerError. Uses memory only.
    """
    _block_optional(monkeypatch)
    with pytest.raises(AnalyzerError, match="v2 InventoryCapture"):
        vsto_office.VstoOfficeAnalyzer().analyze(cast("InventoryCapture", bad_capture))


@pytest.mark.parametrize("explicit", [False, True])
def test_shim_delegates_exact_capture_with_optional_constructor_profile(
    analyzer_catalog: SchemaCatalog,
    office_profile: ProfileV2,
    monkeypatch: pytest.MonkeyPatch,
    explicit: bool,
) -> None:
    """Preserve capture identity and canonical return identity through the shim.

    analyzer_catalog (SchemaCatalog) creates immutable input; office_profile
    (ProfileV2) authorizes analysis; monkeypatch (pytest.MonkeyPatch) replaces only
    canonical analyze; explicit (bool) selects the constructor form. Returns None;
    AssertionError signals delegation drift. No I/O or mutation of inputs.
    """
    from drm_copilot_discovery.analyzer.optional import vsto_office as canonical

    capture = replace(inventory_capture(analyzer_catalog), profile=office_profile)
    expected = Analysis()
    calls: list[InventoryCapture] = []

    def analyze(
        self: canonical.VstoOfficeAnalyzer, received: InventoryCapture
    ) -> Analysis:
        """Record received (InventoryCapture) and return the exact Analysis sentinel.

        self (VstoOfficeAnalyzer) is the canonical adapter. Returns Analysis;
        mutates only test-local calls, performs no I/O and raises no contract error.
        """
        del self
        calls.append(received)
        return expected

    monkeypatch.setattr(canonical.VstoOfficeAnalyzer, "analyze", analyze)
    shim = vsto_office.VstoOfficeAnalyzer(profile=office_profile if explicit else None)
    assert shim.analyze(capture) is expected
    assert calls == [capture] and calls[0] is capture


@pytest.mark.parametrize(
    "constructor_enabled,capture_enabled", [(False, True), (True, False)]
)
def test_shim_checks_both_supplied_and_capture_profiles(
    analyzer_catalog: SchemaCatalog,
    office_profile: ProfileV2,
    monkeypatch: pytest.MonkeyPatch,
    constructor_enabled: bool,
    capture_enabled: bool,
) -> None:
    """Prevent either profile from overriding the other's missing consent.

    analyzer_catalog (SchemaCatalog), office_profile (ProfileV2) and monkeypatch
    (pytest.MonkeyPatch) isolate inputs/imports. constructor_enabled and
    capture_enabled (bool) select the disabled side. Returns None; AssertionError
    signals a consent bypass. No I/O after fixture construction.
    """
    disabled = inventory_profile(analyzer_catalog)
    capture = replace(
        inventory_capture(analyzer_catalog),
        profile=office_profile if capture_enabled else disabled,
    )
    shim = vsto_office.VstoOfficeAnalyzer(
        profile=office_profile if constructor_enabled else disabled
    )
    _block_optional(monkeypatch)
    with pytest.raises(SourceScanError) as error:
        shim.analyze(capture)
    assert error.value.code == "office-consent"


def test_pattern_exports_forward_identical_inert_data() -> None:
    """Forward every historical data name without cloning tables or detectors.

    No parameters. Returns None; AssertionError signals identity drift. Imports
    only the fixed optional pattern module and performs no source analysis/I/O.
    """
    from drm_copilot_discovery.analyzer.optional import vsto_patterns as canonical

    # Cover the entire closed export set, including regex and description objects.
    for name in vsto_patterns.__all__:
        assert getattr(vsto_patterns, name) is getattr(canonical, name)


@pytest.mark.parametrize("name", ["untrusted_module_name", "__path__"])
def test_unknown_pattern_export_does_not_import(
    monkeypatch: pytest.MonkeyPatch,
    name: str,
) -> None:
    """Reject an unknown export before importing any optional code.

    monkeypatch (pytest.MonkeyPatch) isolates imports; name (str) is outside the
    fixed export set. Returns None; AssertionError
    signals unexpected dispatch. Uses memory only and restores the importer.
    """
    _block_optional(monkeypatch)
    with pytest.raises(AttributeError, match="Unknown legacy"):
        getattr(vsto_patterns, name)


@pytest.mark.parametrize(
    "name", ["classify_csharp", "classify_xml", "classify_project"]
)
def test_classifiers_forward_exact_profile_source_and_capacities(
    name: str,
    office_profile: ProfileV2,
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """Forward all approved keywords and the original source without rewriting.

    name (str) selects a fixed wrapper; office_profile (ProfileV2) supplies consent;
    monkeypatch (pytest.MonkeyPatch) substitutes canonical output only. Returns
    None; AssertionError signals a changed capacity or carrier. Pure and isolated.
    """
    from drm_copilot_discovery.analyzer.optional import vsto_office as canonical

    expected: list[Detection] = []
    calls: list[tuple[str, str, ProfileV2 | None, dict[str, int]]] = []

    def classify(
        path: str, text: str, *, profile: ProfileV2 | None = None, **limits: int
    ) -> list[Detection]:
        """Retain path/text (str), profile (ProfileV2 | None) and limits (int).

        Returns the identical list[Detection] sentinel, appending only test-local
        call data. No I/O or contract errors; pytest restores the patched function.
        """
        calls.append((path, text, profile, limits))
        return expected

    monkeypatch.setattr(canonical, name, classify)
    # XML and C# expose different bounded parser capacities by their public contract.
    limits = (
        {"max_tokens": 11, "max_candidates": 7}
        if name == "classify_csharp"
        else {"max_bytes": 512, "max_elements": 12, "max_depth": 3, "max_candidates": 7}
    )
    wrapper = cast("Callable[..., list[Detection]]", getattr(vsto_office, name))
    assert (
        wrapper("src/input.cs", "retained\r\ntext", profile=office_profile, **limits)
        is expected
    )
    assert calls == [("src/input.cs", "retained\r\ntext", office_profile, limits)]


@pytest.mark.parametrize(
    "name", ["classify_csharp", "classify_xml", "classify_project"]
)
@pytest.mark.parametrize("capacity", [True, 1.5, 0, -1])
def test_wrappers_preserve_canonical_capacity_errors(
    name: str,
    capacity: object,
    office_profile: ProfileV2,
) -> None:
    """Preserve fixed errors for invalid public capacities through every wrapper.

    name (str) selects a classifier; capacity (object) is an invalid integer bound;
    office_profile (ProfileV2) supplies consent. Returns None; AssertionError
    signals missing ValueError. Pure; no source parsing or I/O is required.
    """
    wrapper = cast("Callable[..., list[Detection]]", getattr(vsto_office, name))
    with pytest.raises(ValueError, match="positive integers"):
        wrapper("src/input.cs", "", profile=office_profile, max_candidates=capacity)
