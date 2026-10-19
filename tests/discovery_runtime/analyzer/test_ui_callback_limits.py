"""Verify public UI input contracts and independent aggregate budgets."""

from __future__ import annotations

from dataclasses import replace
from typing import TYPE_CHECKING, cast

import pytest
from drm_copilot_discovery.analyzer import ui_callbacks
from drm_copilot_discovery.analyzer.csharp_tokens import SourceScanError
from drm_copilot_discovery.analyzer.findings import pinned_matches
from drm_copilot_discovery.analyzer.ui_callbacks import (
    UiCallbackAnalyzer,
    callback_candidates,
)
from drm_copilot_discovery.analyzer.xml_input import XmlInputError
from drm_copilot_discovery.repository_reader import RepositoryFile

from tests.discovery_runtime.analyzer.test_dotnet_projects import capture
from tests.discovery_runtime.analyzer.test_dotnet_projects import catalog as catalog
from tests.discovery_runtime.analyzer.test_repository import inventory_profile
from tests.discovery_runtime.analyzer.test_ui_callbacks import markup

if TYPE_CHECKING:
    from drm_copilot_discovery.analyzer.models import InventoryCapture, InventoryInput
    from drm_copilot_discovery.catalog import SchemaCatalog
    from pytest import MonkeyPatch


@pytest.mark.parametrize(
    "options",
    (
        {"max_candidates": True},
        {"max_candidates": -1},
        {"max_candidates": 100001},
        {"max_bytes": 0},
        {"max_elements": 0},
        {"max_depth": 129},
    ),
)
def test_public_invalid_limits_precede_parser_calls(
    options: dict[str, int], monkeypatch: MonkeyPatch
) -> None:
    """Use invalid int options and isolated parser seam; return None; no I/O."""
    # Local candidate bounds must fail before the delegated XML validator is called.
    if "max_candidates" in options:

        def forbidden(*args: object, **kwargs: object) -> None:
            """Reject any attempted parser call with object args; never return."""
            raise AssertionError("Candidate validation must precede parsing")

        monkeypatch.setattr(ui_callbacks, "parse_xml", forbidden)
    with pytest.raises(ValueError):
        callback_candidates("src/view.xaml", markup(), **options)


@pytest.mark.parametrize(
    "options,code",
    (
        ({"max_candidates": 0}, "ui-candidate-limit"),
        ({"max_candidates": 1}, "ui-candidate-limit"),
        ({"max_bytes": 2}, "xml-limit"),
        ({"max_elements": 1}, "xml-limit"),
        ({"max_depth": 1}, "xml-limit"),
    ),
)
def test_public_limits_reject_instead_of_returning_partial_candidates(
    options: dict[str, int], code: str
) -> None:
    """Apply bounded int options and assert str error code; return None, pure."""
    with pytest.raises((SourceScanError, XmlInputError)) as error:
        callback_candidates("src/view.xaml", markup(), **options)
    assert error.value.code == code


def test_pin_index_preserves_identity_and_bounds_aggregate_lookup(
    catalog: SchemaCatalog, monkeypatch: MonkeyPatch
) -> None:
    """Count exact provenance comparisons across memory files; return None, no I/O."""
    # Independent paths expose any accidental full-capture provenance rescan.
    payloads = tuple((f"src/a{i}.xaml", markup()) for i in range(8))
    inputs = capture(catalog, payloads)
    visits: list[int] = []

    def counted(local: InventoryCapture, item: InventoryInput) -> bool:
        """Count typed local/item pin visits; return bool, mutate only private list."""
        visits.append(len(local.repository_files))
        return pinned_matches(local, item)

    monkeypatch.setattr(ui_callbacks, "pinned_matches", counted)
    result = UiCallbackAnalyzer().analyze(inputs)
    assert len(result.components) == 8 and sum(visits) == 8
    original = inputs.repository_files[0]
    wrong = RepositoryFile(
        repository=replace(original.repository, id="other"),
        path=original.path,
        content=original.content,
    )
    changed = replace(
        inputs,
        repository_files=(wrong, replace(original, content=b"wrong"))
        + inputs.repository_files[1:],
    )
    assert UiCallbackAnalyzer().analyze(changed).findings[0]["confidence"] == "low"


@pytest.mark.parametrize(
    "kind", ("input-bytes", "scan", "rows", "output", "pin-count", "pin-bytes")
)
def test_aggregate_limits_discard_partial_results_before_release(
    catalog: SchemaCatalog, kind: str
) -> None:
    """Exhaust one str kind of independent budget with memory inputs; return None."""
    inputs = capture(catalog, (("src/a.xaml", markup()), ("src/b.xaml", markup())))
    limits: dict[str, int] = {}
    # Each branch changes one independent configured limit or retained input family.
    if kind == "input-bytes":
        limits = {"document_bytes": 50000}
        inputs = capture(catalog, (("src/a.xaml", markup(" " * 60000)),), pinned=False)
    elif kind in {"scan", "rows"}:
        limits = {"artifact_records": 10 if kind == "scan" else 1}
    elif kind == "output":
        limits = {"document_bytes": 8000}
    elif kind == "pin-count":
        limits = {"source_files": 2}
        inputs = replace(inputs, repository_files=inputs.repository_files * 2)
    else:
        limits = {"document_bytes": 100000}
        inputs = replace(
            inputs,
            repository_files=(
                replace(inputs.repository_files[0], content=b"x" * 100001),
            ),
        )
    inputs = replace(inputs, profile=inventory_profile(catalog, limits=limits))
    result = UiCallbackAnalyzer().analyze(inputs)
    assert result.components == result.findings == result.relationships == ()
    assert len(result.diagnostics) == 1 and result.diagnostics[0]["blocking"]


def test_wrong_capture_type_fails_before_indexing() -> None:
    """Refuse an untyped caller boundary without I/O or partial state; return None."""
    with pytest.raises(ValueError, match="capture"):
        UiCallbackAnalyzer().analyze(cast("InventoryCapture", object()))


@pytest.mark.parametrize("path", ("../a.xaml", "/a.xaml", "C:/a.xaml"))
def test_public_path_rejection_precedes_xml(
    path: str, monkeypatch: MonkeyPatch
) -> None:
    """Reject unsafe str path before the parser seam; return None, isolated patch."""

    def forbidden(*args: object, **kwargs: object) -> None:
        """Raise on an attempted parse with object arguments; no I/O or return."""
        raise AssertionError("Unsafe source identity must fail first")

    monkeypatch.setattr(ui_callbacks, "parse_xml", forbidden)
    with pytest.raises(ValueError):
        callback_candidates(path, markup())


@pytest.mark.parametrize("payload", ("<Window/>", bytearray(b"<Window/>"), None))
def test_public_non_bytes_are_rejected(payload: object) -> None:
    """Refuse object payloads outside immutable bytes; return None, no I/O."""
    with pytest.raises(ValueError, match="bytes"):
        callback_candidates("src/a.xaml", cast("bytes", payload))


@pytest.mark.parametrize(
    "path,payload,maximum,code",
    (
        ("src/a.xaml", b"<Window", 1000, "xml-malformed"),
        ("src/a.xaml", markup(), 2, "xml-limit"),
        ("src/a.xaml.cs", b"class View {}", 2, "source-limit"),
    ),
)
def test_adapter_per_file_failures_are_redacted(
    catalog: SchemaCatalog, path: str, payload: bytes, maximum: int, code: str
) -> None:
    """Bound bytes payload at str path by int maximum; expect fixed str code; pure."""
    extra = (("src/a.xaml", markup()),) if path.endswith(".cs") else ()
    inputs = capture(catalog, extra + ((path, payload),), max_bytes=maximum)
    # Code-size limits must allow the paired XML document to be inspected first.
    if path.endswith(".cs"):
        inputs = capture(
            catalog,
            (("src/a.xaml", markup()), (path, b" " * 1000 + payload)),
            max_bytes=500,
        )
    result = UiCallbackAnalyzer().analyze(inputs)
    # The stable failure code survives without exposing raw parser/source text.
    assert code in {item["code"] for item in result.diagnostics}


def test_missing_code_pin_is_separate_from_pinned_markup(
    catalog: SchemaCatalog,
) -> None:
    """Remove only retained code provenance; keep markup facts high; return None."""
    inputs = capture(
        catalog,
        (
            ("src/a.xaml", markup()),
            ("src/a.xaml.cs", b"class View { void OnClick() {} }"),
        ),
    )
    inputs = replace(inputs, repository_files=(inputs.repository_files[0],))
    result = UiCallbackAnalyzer().analyze(inputs)
    # Verified markup bytes support declarations independently of code provenance.
    assert all(item["confidence"] == "high" for item in result.findings)
    # An absent code pin cannot inherit the markup file's confidence.
    assert all(item["confidence"] == "low" for item in result.relationships)
    # Attribute the missing immutable proof to the retained code file itself.
    assert any(
        item["code"] == "source-revision-unverified" and item["path"] == "src/a.xaml.cs"
        for item in result.diagnostics
    )


def test_many_callbacks_are_bounded_before_candidate_allocation(
    catalog: SchemaCatalog,
) -> None:
    """Use repeated memory declarations to exhaust output reservation; return None."""
    inputs = capture(catalog, (("src/a.xaml", markup('<Button Click="Go"/>' * 100)),))
    inputs = replace(
        inputs, profile=inventory_profile(catalog, limits={"document_bytes": 50000})
    )
    result = UiCallbackAnalyzer().analyze(inputs)
    assert result.findings == result.components == ()
    assert result.diagnostics[0]["code"] == "analysis-text-limit"


def test_code_scan_exhaustion_discards_earlier_markup_rows(
    catalog: SchemaCatalog,
) -> None:
    """Charge XML and code work independently before lexical parsing; return None."""
    inputs = capture(
        catalog, (("src/a.xaml", markup()), ("src/a.xaml.cs", b" " * 100000))
    )
    result = UiCallbackAnalyzer().analyze(inputs)
    assert result.findings == result.components == ()
    assert result.diagnostics[0]["code"] == "analysis-work-limit"
