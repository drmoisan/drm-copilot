"""Retain optional detector assertions through the consented secure runtime.

Legacy context/error cases are covered by test_vsto_compatibility. Complete XML
and shared generic COM grammar replace unsafe fragment/argument extraction;
schema/provenance/determinism now belong to the canonical v2 adapter tests.
"""

from __future__ import annotations

from pathlib import Path
from typing import TYPE_CHECKING

import pytest
from drm_copilot_discovery.analyzer.xml_input import XmlInputError

from scripts.dev_tools.discovery.analyzer.vsto_office import (
    classify_csharp,
    classify_project,
    classify_xml,
)
from tests.scripts.dev_tools.discovery.analyzer.test_vsto_compatibility import (
    analyzer_catalog as analyzer_catalog,
)
from tests.scripts.dev_tools.discovery.analyzer.test_vsto_compatibility import (
    office_profile as office_profile,
)

if TYPE_CHECKING:
    from drm_copilot_discovery.profile_v2 import ProfileV2

    from scripts.dev_tools.discovery.analyzer.source_text import Detection

_FIXTURES = Path(__file__).resolve().parents[5] / "tests/fixtures/discovery_dotnet_vsto"
_URI_2006 = "http://schemas.microsoft.com/office/2006/01/customui"
_URI_2009 = "http://schemas.microsoft.com/office/2009/07/customui"


def _fixture_text(name: str) -> str:
    """Read name (str), a fixed committed fixture; return its UTF-8 str content.

    Reads repository fixture bytes only; OSError reports an absent fixture.
    No consumer filesystem access, temporary files or mutation.
    """
    return (_FIXTURES / name).read_text(encoding="utf-8")


def _symbols(detections: list[Detection], kind: str) -> list[str]:
    """Return list[str] symbols from detections (list[Detection]) matching kind.

    kind (str) is a fixed expected category. Pure; no mutation or contract errors.
    """
    # Keep repeated occurrences visible instead of collapsing their identities.
    return [item.symbol for item in detections if item.detection_kind == kind]


def _extra_map(detection: Detection) -> dict[str, str | int]:
    """Return copied metadata for detection (Detection) without mutation or I/O.

    Returns dict[str, str | int]; no expected errors for the typed carrier.
    """
    return dict(detection.extra)


class TestRibbonDetection:
    """Verify both XML generations and C# markers with isolated configured inputs.

    Each method calls a pure classifier; fixture reads use committed data only.
    The class retains no state and makes no runtime callback/execution claims.
    """

    @pytest.mark.parametrize("uri", [_URI_2006, _URI_2009])
    def test_customui_uri_and_root(self, uri: str, office_profile: ProfileV2) -> None:
        """Detect complete customUI XML using uri (str) and office_profile (ProfileV2).

        Returns None; AssertionError signals lost generation/root metadata.
        Pure after schema fixture construction; no runtime execution.
        """
        detections = classify_xml(
            "ribbon.xml", f'<customUI xmlns="{uri}"/>', profile=office_profile
        )
        # Preserve the generation metadata independently from the root symbol.
        schemas = [
            _extra_map(item).get("customui_schema")
            for item in detections
            if item.detection_kind == "ribbon_xml"
        ]
        assert uri in schemas
        assert "customUI" in _symbols(detections, "ribbon_xml")

    @pytest.mark.parametrize(
        ("source", "symbol"),
        [
            ("public class R : IRibbonExtensibility {}", "IRibbonExtensibility"),
            (
                "public class R : Microsoft.Office.Core.IRibbonExtensibility {}",
                "IRibbonExtensibility",
            ),
            (
                "class R { public string GetCustomUI(string id) { return null; } }",
                "GetCustomUI",
            ),
            (
                "class D : Microsoft.Office.Tools.Ribbon.RibbonBase {}",
                "Microsoft.Office.Tools.Ribbon",
            ),
        ],
    )
    def test_ribbon_extensibility_signals(
        self, source: str, symbol: str, office_profile: ProfileV2
    ) -> None:
        """Retain source (str) marker symbol (str) under office_profile (ProfileV2).

        Returns None; AssertionError signals lost lexical detection. Uses memory
        only and does not assert interface binding or execution.
        """
        detections = classify_csharp("r.cs", source, profile=office_profile)
        assert symbol in _symbols(detections, "ribbon_extensibility")

    def test_cs_comment_ribbon_trap_ignored_but_xml_unstripped(
        self, office_profile: ProfileV2
    ) -> None:
        """Separate masked C# comments from complete XML with configured consent.

        office_profile (ProfileV2) authorizes pure calls. Returns None;
        AssertionError signals lost masking or XML detection. No I/O.
        """
        comment = "// IRibbonExtensibility GetCustomUI Microsoft.Office.Tools.Ribbon"
        assert classify_csharp("r.cs", comment, profile=office_profile) == []
        assert classify_xml(
            "r.xml", f'<customUI xmlns="{_URI_2006}"/>', profile=office_profile
        )

    def test_ribbon_fixtures(self, office_profile: ProfileV2) -> None:
        """Retain generation and repeated C# marker counts from committed fixtures.

        office_profile (ProfileV2) supplies consent. Returns None; AssertionError
        signals lost detections. Reads fixed fixtures only, without mutation.
        """
        xml_detections: list[Detection] = []
        # Separate complete documents replace the unchanged invalid two-root fixture.
        for generation in ("2006", "2009"):
            xml_detections.extend(
                classify_xml(
                    "ribbon.xml",
                    _fixture_text(f"ribbon_customui_{generation}.xml.txt"),
                    profile=office_profile,
                )
            )
        cs_detections = classify_csharp(
            "ribbon.cs", _fixture_text("vsto_ribbon.cs.txt"), profile=office_profile
        )
        # Capture both generation values without depending on output row ordering.
        schemas = {
            _extra_map(item)["customui_schema"]
            for item in xml_detections
            if "customui_schema" in _extra_map(item)
        }
        assert schemas == {_URI_2006, _URI_2009}
        assert _symbols(xml_detections, "ribbon_xml").count("customUI") == 2
        assert (
            _symbols(cs_detections, "ribbon_extensibility").count(
                "IRibbonExtensibility"
            )
            == 2
        )
        assert _symbols(cs_detections, "ribbon_extensibility").count("GetCustomUI") == 2
        assert "Microsoft.Office.Tools.Ribbon" in _symbols(
            cs_detections, "ribbon_extensibility"
        )

    def test_original_two_root_fixture_is_rejected(
        self, office_profile: ProfileV2
    ) -> None:
        """Reject the unchanged malformed fixture rather than accepting XML fragments.

        office_profile (ProfileV2) authorizes parsing. Returns None; AssertionError
        signals missing XmlInputError. Reads one committed fixture; no mutation.
        """
        with pytest.raises(XmlInputError):
            classify_xml(
                "ribbon.xml",
                _fixture_text("ribbon_customui.xml.txt"),
                profile=office_profile,
            )


class TestComInteropDetection:
    """Retain generic COM markers while withholding values and unresolved execution.

    Pure tests use complete declaration contexts and secure project XML. No mutable
    class state or external resources are used beyond committed text fixtures.
    """

    @pytest.mark.parametrize(
        ("source", "symbol"),
        [
            ("[ComImport] interface C {}", "ComImport"),
            ("[ComVisible(true)] class C {}", "ComVisible"),
            (
                "[InterfaceType(ComInterfaceType.InterfaceIsIUnknown)] interface C {}",
                "InterfaceType",
            ),
            ("class C { [DispId(1)] public void Member() {} }", "DispId"),
        ],
    )
    def test_com_attribute_forms(
        self, source: str, symbol: str, office_profile: ProfileV2
    ) -> None:
        """Detect source (str) attribute symbol (str) under office_profile (ProfileV2).

        Returns None; AssertionError signals lost declaration detection. Pure;
        attributes remain syntax rather than verified COM runtime behavior.
        """
        assert symbol in _symbols(
            classify_csharp("c.cs", source, profile=office_profile), "com_attribute"
        )

    def test_standalone_guid_is_not_com_evidence(
        self, office_profile: ProfileV2
    ) -> None:
        """Withhold an arbitrary Guid value and its unsupported COM interpretation.

        office_profile (ProfileV2) authorizes pure parsing. Returns None;
        AssertionError signals argument leakage or unsupported generic detection.
        """
        source = '[Guid("1A2B3C4D-5E6F-7A8B-9C0D-1E2F3A4B5C6D")] class C {}'
        detections = classify_csharp("c.cs", source, profile=office_profile)
        assert "Guid" not in _symbols(detections, "com_attribute")
        assert "1A2B3C4D" not in repr(detections)

    @pytest.mark.parametrize("member", ["ReleaseComObject", "FinalReleaseComObject"])
    def test_marshal_member_captured_into_symbol(
        self,
        office_profile: ProfileV2,
        member: str,
    ) -> None:
        """Retain member (str), a fixed Marshal API, with office_profile (ProfileV2).

        Returns None; AssertionError signals lost fixed API detection. Pure; no
        lifetime effect is inferred from the call's lexical presence.
        """
        detections = classify_csharp(
            "c.cs", f"Marshal.{member}(obj);", profile=office_profile
        )
        assert _symbols(detections, "marshal_call") == [member]

    @pytest.mark.parametrize("member", ["CustomMember", "AddRef"])
    def test_arbitrary_marshal_member_is_not_com_evidence(
        self,
        office_profile: ProfileV2,
        member: str,
    ) -> None:
        """Reject member (str) outside the finite set under office_profile (ProfileV2).

        Returns None; AssertionError signals an unsupported API claim. Pure.
        """
        assert (
            _symbols(
                classify_csharp(
                    "c.cs", f"Marshal.{member}(obj);", profile=office_profile
                ),
                "marshal_call",
            )
            == []
        )

    def test_progid_activation(self, office_profile: ProfileV2) -> None:
        """Retain type-lookup syntax without claiming actual ProgID activation.

        office_profile (ProfileV2) supplies consent. Returns None; AssertionError
        signals lost lookup syntax. Pure; runtime activation remains unresolved.
        """
        detections = classify_csharp(
            "c.cs", "var t = Type.GetTypeFromProgID(id);", profile=office_profile
        )
        assert _symbols(detections, "progid_activation") == ["GetTypeFromProgID"]

    @pytest.mark.parametrize(
        ("source", "target"),
        [
            ("using Microsoft.Office.Interop.Excel;", "Excel"),
            ("using static Microsoft.Office.Interop.Excel.XlDirection;", "Excel"),
            ("using GenericApp = Microsoft.Office.Interop.Word;", "Word"),
        ],
    )
    def test_interop_using_captures_target_as_data(
        self, source: str, target: str, office_profile: ProfileV2
    ) -> None:
        """Retain source (str) namespace target (str) as data, never product logic.

        office_profile (ProfileV2) supplies consent. Returns None; AssertionError
        signals lost lexical namespace data. Pure; no assembly binding claimed.
        """
        detections = classify_csharp("c.cs", source, profile=office_profile)
        # Filter marker kinds while retaining their source-provided namespace data.
        uses = [item for item in detections if item.detection_kind == "interop_using"]
        assert len(uses) == 1
        assert _extra_map(uses[0])["interop_target"] == target

    def test_string_literal_attribute_trap_rejected(
        self, office_profile: ProfileV2
    ) -> None:
        """Ignore attribute/call strings under office_profile (ProfileV2).

        Returns None; AssertionError signals masking drift. Uses memory only.
        """
        source = 'var s = "[Guid(\\"x\\")] Marshal.Foo(";'
        detections = classify_csharp("c.cs", source, profile=office_profile)
        assert _symbols(detections, "com_attribute") == []
        assert _symbols(detections, "marshal_call") == []

    @pytest.mark.parametrize(
        ("source", "symbol"),
        [
            ('<COMReference Include="GenericLib"/>', "COMReference"),
            (
                '<COMReference Include="GenericLib"><EmbedInteropTypes>true'
                "</EmbedInteropTypes></COMReference>",
                "COMReference",
            ),
            (
                '<Reference Include="Microsoft.Office.Interop.Word"/>',
                "Microsoft.Office.Interop.Word",
            ),
        ],
    )
    def test_project_com_references(
        self, source: str, symbol: str, office_profile: ProfileV2
    ) -> None:
        """Detect source (str) declarations using the bounded symbol (str).

        office_profile (ProfileV2) authorizes secure XML. Returns None;
        AssertionError signals lost structural detection or COM target leakage.
        Literal assembly identifiers are declared data, distinct from COM targets.
        """
        detections = classify_project(
            "app.csproj",
            f"<Project><ItemGroup>{source}</ItemGroup></Project>",
            profile=office_profile,
        )
        assert symbol in _symbols(detections, "com_reference")
        assert "GenericLib" not in repr(detections)

    def test_com_fixtures(self, office_profile: ProfileV2) -> None:
        """Retain fixed COM/API/using/project detections with explicit redaction.

        office_profile (ProfileV2) supplies consent. Returns None; AssertionError
        signals marker loss or argument leakage. Reads committed fixtures only.
        """
        cs_detections = classify_csharp(
            "com.cs", _fixture_text("com_interop.cs.txt"), profile=office_profile
        )
        project = classify_project(
            "app.csproj",
            _fixture_text("project_com_reference.xmlproj.txt"),
            profile=office_profile,
        )
        attributes = set(_symbols(cs_detections, "com_attribute"))
        # Namespace targets remain observed data without per-application branches.
        targets = {
            _extra_map(item)["interop_target"]
            for item in cs_detections
            if item.detection_kind == "interop_using"
        }
        assert {"ComImport", "ComVisible", "InterfaceType", "DispId"} <= attributes
        assert "Guid" not in attributes
        assert _symbols(cs_detections, "marshal_call") == ["ReleaseComObject"]
        assert "AddRef" not in _symbols(cs_detections, "marshal_call")
        assert _symbols(cs_detections, "progid_activation") == ["GetTypeFromProgID"]
        assert targets == {"Excel", "Word"}
        assert {"COMReference", "Microsoft.Office.Interop.Word"} <= set(
            _symbols(project, "com_reference")
        )
        assert "GenericComLibrary" not in repr(project)
        # Embedding remains structural metadata rather than a separately resolved edge.
        assert any(
            _extra_map(item).get("embed_interop_types") == "true" for item in project
        )
