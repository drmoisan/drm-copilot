"""Unit and integration tests for the VSTO/Office analyzer.

Pure detection tests feed inline C#/XML strings and the raw fixtures to the pure
``classify_*`` functions (no filesystem). Routing, error-path, and end-to-end
emission tests use the in-memory ``mem_fs_path`` fixture with a pinned clock; no
temporary files are created.
"""

from __future__ import annotations

import json
import re
from pathlib import Path
from typing import TYPE_CHECKING

import pytest

from scripts.dev_tools.discovery.analyzer.inventory import AnalyzerError
from scripts.dev_tools.discovery.analyzer.models import AnalyzerContext, ParseResult
from scripts.dev_tools.discovery.analyzer.pipeline import (
    RealAnalyzerFileSystem,
    run_analyzer,
)
from scripts.dev_tools.discovery.analyzer.vsto_office import (
    VstoOfficeAnalyzer,
    classify_csharp,
    classify_project,
    classify_xml,
)
from scripts.dev_tools.discovery.domain_profile_models import DomainProfileError

if TYPE_CHECKING:
    from scripts.dev_tools.discovery.analyzer.source_text import Detection

_REPO_ROOT = Path(__file__).resolve().parents[5]
_FIXTURES = _REPO_ROOT / "tests" / "fixtures" / "discovery_dotnet_vsto"
_SCHEMA_FILE = (
    _REPO_ROOT / "schemas" / "discovery" / "v1" / "evidence-reference.schema.json"
)

_ID_GRAMMAR = re.compile(r"^[a-z0-9][a-z0-9._-]*$")
_SCHEMA_VERSION_GRAMMAR = re.compile(r"^1\.\d+\.\d+$")
_REQUIRED_TOP_LEVEL_KEYS = {
    "$schema",
    "schema_version",
    "id",
    "kind",
    "location",
    "captured_at",
    "description",
}
_OPTIONAL_TOP_LEVEL_KEYS = {"content_hash", "tool", "metadata"}
_DETECTION_KIND_VOCABULARY = {
    "namespace",
    "type",
    "event_declaration",
    "delegate",
    "event_subscription",
    "ribbon_xml",
    "ribbon_extensibility",
    "com_attribute",
    "marshal_call",
    "progid_activation",
    "interop_using",
    "com_reference",
}
_URI_2006 = "http://schemas.microsoft.com/office/2006/01/customui"
_URI_2009 = "http://schemas.microsoft.com/office/2009/07/customui"


def _fixture_text(name: str) -> str:
    """Return the raw text of a committed fixture (real filesystem read)."""
    return (_FIXTURES / name).read_text(encoding="utf-8")


def _symbols(detections: list[Detection], kind: str) -> list[str]:
    """Return the symbols of detections filtered to one detection kind."""
    return [d.symbol for d in detections if d.detection_kind == kind]


def _extra_map(detection: Detection) -> dict[str, str | int]:
    """Return a detection's extra metadata pairs as a plain dict."""
    return dict(detection.extra)


class TestRibbonDetection:
    """Ribbon-XML and ribbon-extensibility detection."""

    @pytest.mark.parametrize(
        ("line", "uri"),
        [
            (f'<customUI xmlns="{_URI_2006}">', _URI_2006),
            (f'<customUI xmlns="{_URI_2009}">', _URI_2009),
        ],
    )
    def test_customui_uri_and_root(self, line: str, uri: str) -> None:
        """Both customUI generations capture the schema and the root element."""
        # Act
        detections = classify_xml("ribbon.xml", line)
        schemas = [
            _extra_map(d).get("customui_schema")
            for d in detections
            if d.detection_kind == "ribbon_xml"
        ]

        # Assert: the matched URI is captured and the root element is detected.
        assert uri in schemas
        assert "customUI" in _symbols(detections, "ribbon_xml")

    @pytest.mark.parametrize(
        ("source", "symbol"),
        [
            ("public class R : IRibbonExtensibility {", "IRibbonExtensibility"),
            (
                "public class R : Microsoft.Office.Core.IRibbonExtensibility {",
                "IRibbonExtensibility",
            ),
            ("public string GetCustomUI(string id) {", "GetCustomUI"),
            (
                "class D : Microsoft.Office.Tools.Ribbon.RibbonBase {",
                "Microsoft.Office.Tools.Ribbon",
            ),
        ],
    )
    def test_ribbon_extensibility_signals(self, source: str, symbol: str) -> None:
        """Ribbon-extensibility C# signals are detected over stripped text."""
        # Act
        detections = classify_csharp("r.cs", source)

        # Assert
        assert symbol in _symbols(detections, "ribbon_extensibility")

    def test_cs_comment_ribbon_trap_ignored_but_xml_unstripped(self) -> None:
        """C# comment ribbon text is stripped; XML ribbon text is scanned raw."""
        # Arrange: identical ribbon-shaped text as a C# comment and as XML.
        comment = "// IRibbonExtensibility GetCustomUI Microsoft.Office.Tools.Ribbon"
        xml_line = f'<customUI xmlns="{_URI_2006}">'

        # Act
        cs_detections = classify_csharp("r.cs", comment)
        xml_detections = classify_xml("r.xml", xml_line)

        # Assert
        assert cs_detections == []
        assert xml_detections != []

    def test_ribbon_fixtures(self) -> None:
        """The ribbon fixtures yield the expected signals and reject the trap."""
        # Arrange / Act
        xml_detections = classify_xml(
            "ribbon.xml", _fixture_text("ribbon_customui.xml.txt")
        )
        cs_detections = classify_csharp(
            "ribbon.cs", _fixture_text("vsto_ribbon.cs.txt")
        )
        captured_schemas = {
            _extra_map(d)["customui_schema"]
            for d in xml_detections
            if "customui_schema" in _extra_map(d)
        }

        # Assert: both generations captured; extensibility signals counted.
        assert captured_schemas == {_URI_2006, _URI_2009}
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


class TestComInteropDetection:
    """COM-interop attribute, marshal, ProgID, using, and project detection."""

    @pytest.mark.parametrize(
        ("source", "symbol"),
        [
            ("[ComImport]", "ComImport"),
            ("[ComVisible(true)]", "ComVisible"),
            ("[InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]", "InterfaceType"),
            ("[DispId(1)]", "DispId"),
        ],
    )
    def test_com_attribute_forms(self, source: str, symbol: str) -> None:
        """Each COM attribute form is detected over stripped text."""
        # Act
        detections = classify_csharp("c.cs", source)

        # Assert
        assert symbol in _symbols(detections, "com_attribute")

    def test_guid_attribute_captures_com_guid(self) -> None:
        """The Guid attribute captures the GUID from the unstripped line."""
        # Arrange
        source = '[Guid("1A2B3C4D-5E6F-7A8B-9C0D-1E2F3A4B5C6D")]'

        # Act
        detections = classify_csharp("c.cs", source)
        guid_detections = [d for d in detections if d.symbol == "Guid"]

        # Assert
        assert len(guid_detections) == 1
        assert (
            _extra_map(guid_detections[0])["com_guid"]
            == "1A2B3C4D-5E6F-7A8B-9C0D-1E2F3A4B5C6D"
        )

    def test_marshal_member_captured_into_symbol(self) -> None:
        """Marshal member calls capture the member with no fixed list."""
        # Act
        detections = classify_csharp("c.cs", "Marshal.ReleaseComObject(obj);")

        # Assert
        assert _symbols(detections, "marshal_call") == ["ReleaseComObject"]

    def test_progid_activation(self) -> None:
        """Type.GetTypeFromProgID is detected as ProgID activation."""
        # Act
        detections = classify_csharp("c.cs", "var t = Type.GetTypeFromProgID(id);")

        # Assert
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
        self, source: str, target: str
    ) -> None:
        """Office interop usings capture the application name as data."""
        # Act
        detections = classify_csharp("c.cs", source)
        using_detections = [
            d for d in detections if d.detection_kind == "interop_using"
        ]

        # Assert
        assert len(using_detections) == 1
        assert _extra_map(using_detections[0])["interop_target"] == target

    def test_string_literal_attribute_trap_rejected(self) -> None:
        """Attribute-shaped text inside a string literal is not detected."""
        # Arrange: a stringized attribute and marshal call must be stripped away.
        source = r'var s = "[Guid(\"x\")] Marshal.Foo(";'

        # Act
        detections = classify_csharp("c.cs", source)

        # Assert
        assert _symbols(detections, "com_attribute") == []
        assert _symbols(detections, "marshal_call") == []

    @pytest.mark.parametrize(
        ("source", "symbol"),
        [
            ('<COMReference Include="GenericLib">', "GenericLib"),
            ("<EmbedInteropTypes>true</EmbedInteropTypes>", "EmbedInteropTypes"),
            (
                '<Reference Include="Microsoft.Office.Interop.Word">',
                "Microsoft.Office.Interop.Word",
            ),
        ],
    )
    def test_project_com_references(self, source: str, symbol: str) -> None:
        """Project-file COM references are detected over unstripped XML."""
        # Act
        detections = classify_project("app.csproj", source)

        # Assert
        assert symbol in _symbols(detections, "com_reference")

    def test_com_fixtures(self) -> None:
        """The COM fixtures yield every named case and reject the trap."""
        # Arrange / Act
        cs_detections = classify_csharp("com.cs", _fixture_text("com_interop.cs.txt"))
        project_detections = classify_project(
            "app.csproj", _fixture_text("project_com_reference.xmlproj.txt")
        )
        attributes = set(_symbols(cs_detections, "com_attribute"))
        interop_targets = {
            _extra_map(d)["interop_target"]
            for d in cs_detections
            if d.detection_kind == "interop_using"
        }

        # Assert: attributes, marshal members, ProgID, and usings are present.
        assert {"ComImport", "ComVisible", "Guid", "InterfaceType", "DispId"} <= (
            attributes
        )
        assert {"ReleaseComObject", "AddRef"} <= set(
            _symbols(cs_detections, "marshal_call")
        )
        assert _symbols(cs_detections, "progid_activation") == ["GetTypeFromProgID"]
        assert interop_targets == {"Excel", "Word"}
        # Assert: project references and the string trap.
        project_symbols = set(_symbols(project_detections, "com_reference"))
        assert "GenericComLibrary" in project_symbols
        assert "EmbedInteropTypes" in project_symbols
        assert "Microsoft.Office.Interop.Word" in project_symbols


def _context(source_root: Path, out_root: Path) -> AnalyzerContext:
    """Return a pinned-clock run context for the analyzer under test."""
    return AnalyzerContext(
        source_root=source_root,
        include=(),
        exclude=(),
        artifact_root=out_root,
        schema_path=source_root.parent / "schemas" / "evidence-reference.schema.json",
        captured_at="2026-07-18T12:34:56Z",
    )


class TestRoutingAndErrors:
    """File routing, narrowing failure, unreachable root, and glob handling."""

    def test_routing_by_extension(self) -> None:
        """The router applies the detector matching each file's extension."""
        # Arrange: ribbon text only detected when routed as XML, not as C#.
        xml_line = f'<customUI xmlns="{_URI_2006}">'

        # Act / Assert
        assert classify_xml("a.xml", xml_line) != []
        assert classify_csharp("a.cs", "public class A : IRibbonExtensibility {}") != []
        assert classify_project("a.csproj", '<COMReference Include="X">') != []

    def test_classify_rejects_plain_parse_result(self) -> None:
        """classify raises AnalyzerError when handed a plain ParseResult."""
        # Arrange
        analyzer = VstoOfficeAnalyzer(fs=RealAnalyzerFileSystem())

        # Act / Assert
        with pytest.raises(AnalyzerError):
            analyzer.classify(ParseResult(paths=("a.cs",)))

    def test_parse_unreachable_root_raises_analyzer_error(
        self, mem_fs_path: Path
    ) -> None:
        """parse fails fast with AnalyzerError, distinct from DomainProfileError."""
        # Arrange
        fs = RealAnalyzerFileSystem()
        analyzer = VstoOfficeAnalyzer(fs=fs)
        ctx = _context(mem_fs_path / "missing", mem_fs_path / "out")

        # Act / Assert
        with pytest.raises(AnalyzerError) as exc_info:
            analyzer.parse(ctx)
        assert not isinstance(exc_info.value, DomainProfileError)

    @pytest.mark.parametrize(
        ("include", "exclude", "expected"),
        [
            ((), (), ("app.csproj", "keep/a.cs", "ui/r.xml")),
            (("keep/*.cs",), (), ("keep/a.cs",)),
            ((), ("*.csproj",), ("keep/a.cs", "ui/r.xml")),
        ],
    )
    def test_include_exclude_routing(
        self,
        mem_fs_path: Path,
        include: tuple[str, ...],
        exclude: tuple[str, ...],
        expected: tuple[str, ...],
    ) -> None:
        """parse selects routed candidates honoring include/exclude globs."""
        # Arrange
        source_root = mem_fs_path / "consumer"
        (source_root / "keep").mkdir(parents=True, exist_ok=True)
        (source_root / "ui").mkdir(parents=True, exist_ok=True)
        (source_root / "keep" / "a.cs").write_text("class A {}", encoding="utf-8")
        (source_root / "ui" / "r.xml").write_text("<customUI/>", encoding="utf-8")
        (source_root / "app.csproj").write_text("<Project/>", encoding="utf-8")
        (source_root / "notes.md").write_text("x", encoding="utf-8")
        fs = RealAnalyzerFileSystem()
        analyzer = VstoOfficeAnalyzer(fs=fs)
        ctx = AnalyzerContext(
            source_root=source_root,
            include=include,
            exclude=exclude,
            artifact_root=mem_fs_path / "out",
            schema_path=mem_fs_path / "schemas" / "s.json",
            captured_at="2026-07-18T12:34:56Z",
        )

        # Act
        parsed = analyzer.parse(ctx)

        # Assert
        assert parsed.paths == expected


class TestEndToEndEmission:
    """End-to-end emission, schema conformance, and determinism."""

    def _build_tree(self, source_root: Path) -> None:
        """Populate an in-memory consumer tree from the raw VSTO fixtures."""
        source_root.mkdir(parents=True, exist_ok=True)
        (source_root / "ribbon.cs").write_text(
            _fixture_text("vsto_ribbon.cs.txt"), encoding="utf-8"
        )
        (source_root / "ribbon.xml").write_text(
            _fixture_text("ribbon_customui.xml.txt"), encoding="utf-8"
        )
        (source_root / "com.cs").write_text(
            _fixture_text("com_interop.cs.txt"), encoding="utf-8"
        )
        (source_root / "app.csproj").write_text(
            _fixture_text("project_com_reference.xmlproj.txt"), encoding="utf-8"
        )

    def test_emits_schema_valid_instances(self, mem_fs_path: Path) -> None:
        """Every emitted instance validates against the discovery v1 schema."""
        # Arrange
        jsonschema = pytest.importorskip("jsonschema")
        validator = jsonschema.Draft202012Validator(
            json.loads(_SCHEMA_FILE.read_text(encoding="utf-8"))
        )
        source_root = mem_fs_path / "consumer"
        self._build_tree(source_root)
        fs = RealAnalyzerFileSystem()
        analyzer = VstoOfficeAnalyzer(fs=fs)
        ctx = _context(source_root, mem_fs_path / "out")

        # Act
        result = run_analyzer(analyzer, ctx, fs)

        # Assert
        assert result.written_paths
        for path in result.written_paths:
            document = json.loads(path.read_text(encoding="utf-8"))
            validator.validate(document)
            top_level = set(document)
            assert _REQUIRED_TOP_LEVEL_KEYS <= top_level
            assert top_level <= _REQUIRED_TOP_LEVEL_KEYS | _OPTIONAL_TOP_LEVEL_KEYS
            assert document["kind"] == "file"
            assert "\n" not in document["location"]
            assert _ID_GRAMMAR.match(document["id"]) is not None
            assert _SCHEMA_VERSION_GRAMMAR.match(document["schema_version"]) is not None
            schema_ref = document["$schema"]
            assert not schema_ref.startswith("/")
            assert ":" not in schema_ref.split("/", 1)[0]
            assert document["metadata"]["detection_kind"] in _DETECTION_KIND_VOCABULARY

    def test_byte_identical_on_rerun(self, mem_fs_path: Path) -> None:
        """Re-running with a fixed clock produces byte-identical instances."""
        # Arrange
        source_root = mem_fs_path / "consumer"
        self._build_tree(source_root)
        fs = RealAnalyzerFileSystem()
        analyzer = VstoOfficeAnalyzer(fs=fs)
        ctx = _context(source_root, mem_fs_path / "out")

        # Act
        first = run_analyzer(analyzer, ctx, fs)
        first_content = {
            p.name: p.read_text(encoding="utf-8") for p in first.written_paths
        }
        second = run_analyzer(analyzer, ctx, fs)
        second_content = {
            p.name: p.read_text(encoding="utf-8") for p in second.written_paths
        }

        # Assert
        assert first_content == second_content
