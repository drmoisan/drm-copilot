"""Verify optional consent, exact limit types, encoding and aggregate exhaustion."""

from __future__ import annotations

from dataclasses import replace
from typing import TYPE_CHECKING, cast

import pytest
from drm_copilot_discovery.analyzer.csharp_tokens import SourceScanError
from drm_copilot_discovery.analyzer.optional import vsto_syntax as patterns
from drm_copilot_discovery.analyzer.optional.vsto_office import (
    VstoOfficeAnalyzer,
    classify_csharp,
    classify_project,
    classify_xml,
)
from drm_copilot_discovery.profile_v2 import ProfileError
from drm_copilot_discovery.repository_reader import RepositoryFile

from tests.discovery_runtime.analyzer.test_optional_adapter import (
    captured,
    profile_for,
    rendered,
)
from tests.discovery_runtime.analyzer.test_optional_adapter import (
    profile as profile,
)
from tests.discovery_runtime.analyzer.test_repository import (
    analyzer_catalog as analyzer_catalog,
)
from tests.discovery_runtime.analyzer.test_repository import inventory_profile

if TYPE_CHECKING:
    from drm_copilot_discovery.analyzer.models import InventoryCapture
    from drm_copilot_discovery.catalog import SchemaCatalog
    from drm_copilot_discovery.profile_v2 import ProfileV2


@pytest.mark.parametrize(
    "entry", ["csharp", "xml", "project", "direct-csharp", "direct-xml", "analyze"]
)
@pytest.mark.parametrize("state", ["absent", "disabled", "draft"])
def test_consent_fails_before_source_processing(
    analyzer_catalog: SchemaCatalog,
    monkeypatch: pytest.MonkeyPatch,
    entry: str,
    state: str,
) -> None:
    """Reject str entry/state before parser access; patches are restored, return None.

    analyzer_catalog is immutable; monkeypatch installs an intentional failure if
    a source-processing seam is touched without configured explicit consent.
    """
    configured = (
        None
        if state == "absent"
        else (
            inventory_profile(analyzer_catalog)
            if state == "disabled"
            else profile_for(analyzer_catalog, profile_state="draft")
        )
    )

    def forbidden(*args: object, **kwargs: object) -> bytes:
        """Reject any parser/encoder call for object args/kwargs; no return or I/O."""
        pytest.fail("Unconsented source processing")

    monkeypatch.setattr(patterns, "text_bytes", forbidden)
    monkeypatch.setattr(patterns, "parse_xml", forbidden)
    error = ProfileError if state == "draft" else SourceScanError
    with pytest.raises(error):
        # Exercise each public boundary, including direct adapter revalidation.
        if entry == "analyze":
            inputs = captured(profile_for(analyzer_catalog), ())
            object.__setattr__(inputs, "profile", configured)
            VstoOfficeAnalyzer().analyze(inputs)
        elif entry == "direct-csharp":
            patterns.csharp_candidates(
                "src/a.cs",
                "INVALID",
                profile=configured,
                max_tokens=10,
                max_candidates=10,
            )
        elif entry == "direct-xml":
            patterns.xml_candidates(
                "src/a.xml",
                b"INVALID",
                profile=configured,
                project=False,
                max_bytes=10,
                max_elements=10,
                max_depth=10,
                max_candidates=10,
            )
        else:
            {
                "csharp": classify_csharp,
                "xml": classify_xml,
                "project": classify_project,
            }[entry]("src/a.cs", "INVALID", profile=configured)


@pytest.mark.parametrize(
    "entry,argument",
    [
        ("csharp", "max_tokens"),
        ("csharp", "max_candidates"),
        ("xml", "max_bytes"),
        ("xml", "max_elements"),
        ("xml", "max_depth"),
        ("xml", "max_candidates"),
    ],
)
@pytest.mark.parametrize("invalid", [0, -1, True, 1.5])
def test_invalid_public_limits_fail_before_processing(
    profile: ProfileV2, entry: str, argument: str, invalid: object
) -> None:
    """Reject typed profile plus str argument/entry and invalid object; return None."""
    with pytest.raises(ValueError, match="positive integers"):
        # The selected public boundary receives one intentionally mistyped capacity.
        if entry == "csharp":
            classify_csharp(
                "src/a.cs",
                "INVALID",
                profile=profile,
                **{argument: cast("int", invalid)},
            )
        else:
            classify_xml(
                "src/a.xml",
                "INVALID",
                profile=profile,
                **{argument: cast("int", invalid)},
            )


@pytest.mark.parametrize(
    "value,maximum", [("é", 1), ("😀", 3), ("\ud800", 10), ("x" * 10, 9)]
)
def test_encoded_bytes_are_bounded_before_buffer_allocation(
    value: str, maximum: int
) -> None:
    """Use str/int boundaries including Unicode scalars; return None, no I/O."""
    with pytest.raises(SourceScanError):
        patterns.text_bytes(value, maximum)
    assert patterns.text_bytes("é😀", 6) == "é😀".encode()


@pytest.mark.parametrize(
    "name,content,code",
    [
        ("src/a.cs", b"\xff", "source-encoding"),
        ("src/a.xml", b"<customUI", "xml-malformed"),
        ("src/a.xml", b'<!DOCTYPE r [<!ENTITY x "secret">]><r/>', "xml-dtd"),
        ("src/a.csproj", b"<Wrong/>", "xml-root"),
        ("src/a.cs", b"class C {", "source-delimiter"),
    ],
)
def test_runtime_parser_failures_are_fixed_and_source_bound(
    profile: ProfileV2, name: str, content: bytes, code: str
) -> None:
    """Consume typed memory-only inputs and assert fixed str code; return None."""
    result = VstoOfficeAnalyzer().analyze(captured(profile, ((name, content),)))
    assert result.components == () and [
        item["code"] for item in result.diagnostics
    ] == [code]
    assert b"secret" not in rendered(result)


@pytest.mark.parametrize(
    "records,budget,content,code",
    [
        (1, 16777216, b"", "analysis-limit"),
        (4, 16777216, b"", "analysis-limit"),
        (6, 16777216, b"[ComImport, ComVisible] class C {}", "analysis-limit"),
        (100, 1024, b"", "analysis-text-limit"),
        (100, 60000, b"", "analysis-text-limit"),
        (100, 16777216, b"//" + b"x" * 2200000, "analysis-work-limit"),
    ],
    ids=[
        "base-records",
        "no-candidate-capacity",
        "candidate-records",
        "base-bytes",
        "candidate-bytes",
        "aggregate-work",
    ],
)
def test_aggregate_exhaustion_discards_all_partial_rows(
    analyzer_catalog: SchemaCatalog,
    records: int,
    budget: int,
    content: bytes,
    code: str,
) -> None:
    """Use SchemaCatalog/int limits/bytes payload; assert bounded result, no I/O."""
    configured = profile_for(
        analyzer_catalog, limits={"artifact_records": records, "document_bytes": budget}
    )
    result = VstoOfficeAnalyzer().analyze(
        captured(configured, (("src/a.cs", content),))
    )
    assert not result.components and not result.findings and not result.relationships
    assert [item["code"] for item in result.diagnostics] == [code]
    assert len(rendered(result)) <= budget


@pytest.mark.parametrize("entry", ["csharp", "xml", "project"])
def test_candidate_and_profile_byte_caps_cannot_be_enlarged(
    analyzer_catalog: SchemaCatalog, profile: ProfileV2, entry: str
) -> None:
    """Use typed profiles and str entry to bound candidates/bytes; return None."""
    source = {
        "csharp": "class R : IRibbonExtensibility { string GetCustomUI() {} }",
        "xml": '<customUI xmlns="http://schemas.microsoft.com/office/2009/07/customui"/>',
        "project": '<Project><ItemGroup><COMReference Include="X"/>'
        '<COMReference Include="Y"/></ItemGroup></Project>',
    }[entry]
    classifier = {
        "csharp": classify_csharp,
        "xml": classify_xml,
        "project": classify_project,
    }[entry]
    with pytest.raises(SourceScanError, match="candidates exceed"):
        classifier("src/a.cs", source, profile=profile, max_candidates=1)
    constrained = profile_for(analyzer_catalog, limits={"document_bytes": 1})
    with pytest.raises(SourceScanError, match="byte limit"):
        classifier("src/a.cs", source, profile=constrained)


@pytest.mark.parametrize("mode", ["count", "bytes"])
def test_retained_pin_budgets_are_independent(
    analyzer_catalog: SchemaCatalog, mode: str
) -> None:
    """Reject excess retained pin count or bytes using typed memory input; no I/O."""
    configured = profile_for(
        analyzer_catalog, limits={"source_files": 1, "document_bytes": 200000}
    )
    inputs = captured(configured, (("src/a.cs", b"class C {}"),))
    pin = inputs.repository_files[0]
    # Exceed one independently configured pin bound without expanding selected input.
    pins = (
        (pin, pin)
        if mode == "count"
        else (
            RepositoryFile(
                repository=pin.repository, path=pin.path, content=b"x" * 200001
            ),
        )
    )
    result = VstoOfficeAnalyzer().analyze(replace(inputs, repository_files=pins))
    assert result.components == () and result.findings == ()
    assert [item["code"] for item in result.diagnostics] == ["analysis-work-limit"]


def test_long_chains_unsupported_xml_and_nonboolean_dialect(profile: ProfileV2) -> None:
    """Keep unbounded names/foreign roots opaque and reject bool lookalike; pure."""
    assert (
        classify_csharp(
            "src/a.cs",
            "using Microsoft.Office.Interop." + "X" * 300 + ";",
            profile=profile,
        )
        == []
    )
    assert classify_xml("src/a.xml", "<Project/>", profile=profile) == []
    with pytest.raises(ValueError, match="boolean"):
        patterns.xml_candidates(
            "src/a.xml",
            b"<Project/>",
            profile=profile,
            project=cast("bool", 1),
            max_bytes=1000,
            max_elements=10,
            max_depth=10,
            max_candidates=10,
        )


def test_adapter_rejects_untyped_capture_and_insufficient_fallback(
    analyzer_catalog: SchemaCatalog,
) -> None:
    """Reject invalid capture and tiny configured output before work; return None."""
    with pytest.raises(ValueError, match="immutable capture"):
        VstoOfficeAnalyzer().analyze(cast("InventoryCapture", object()))
    with pytest.raises(SourceScanError, match="diagnostic budget"):
        VstoOfficeAnalyzer().analyze(
            captured(profile_for(analyzer_catalog, limits={"document_bytes": 1}), ())
        )
