"""Verify consented optional declarations, provenance and bounded pure analysis."""

from __future__ import annotations

import hashlib
from dataclasses import replace
from pathlib import Path
from typing import TYPE_CHECKING, cast

import pytest
from drm_copilot_discovery.analyzer.emitter import inventory_result
from drm_copilot_discovery.analyzer.findings import row
from drm_copilot_discovery.analyzer.models import (
    Analysis,
    InventoryCapture,
    InventoryInput,
)
from drm_copilot_discovery.analyzer.optional.vsto_office import (
    VstoOfficeAnalyzer,
    classify_csharp,
    classify_project,
    classify_xml,
)
from drm_copilot_discovery.analyzer.source_text import build_evidence_id
from drm_copilot_discovery.analyzer.xml_input import XmlInputError
from drm_copilot_discovery.models import JsonObject, canonical_json
from drm_copilot_discovery.repository_reader import RepositoryFile, RepositoryIdentity
from drm_copilot_discovery.snapshot import SnapshotFile

from tests.discovery_runtime.analyzer.test_repository import (
    analyzer_catalog as analyzer_catalog,
)
from tests.discovery_runtime.analyzer.test_repository import inventory_profile

if TYPE_CHECKING:
    from drm_copilot_discovery.catalog import SchemaCatalog
    from drm_copilot_discovery.profile_v2 import ProfileV2

URI = "http://schemas.microsoft.com/office/2009/07/customui"


def profile_for(catalog: SchemaCatalog, **changes: object) -> ProfileV2:
    """Return configured consent using immutable SchemaCatalog and field overrides.

    changes (object) are validated by ProfileV2; ProfileError propagates. Pure.
    """
    return inventory_profile(
        catalog,
        analyzers={
            "enabled": ["office-vsto"],
            "options": {},
            "ignored_paths": [],
            "extension_result_manifests": [],
        },
        **changes,
    )


@pytest.fixture(scope="module")
def profile(analyzer_catalog: SchemaCatalog) -> ProfileV2:
    """Return shared immutable consent from SchemaCatalog; no consumer I/O."""
    return profile_for(analyzer_catalog)


def captured(
    profile: ProfileV2, payloads: tuple[tuple[str, bytes], ...], *, pinned: bool = True
) -> InventoryCapture:
    """Return immutable captures from profile/payload tuples and bool pin flag.

    Independent retained Git objects prove bytes only when pinned. No file/process
    I/O; model ValueError rejects malformed synthetic inputs.
    """
    # Keep the exact bytes, including encoding and physical newline differences.
    files = tuple(
        SnapshotFile(path=path, content=content, category="source")
        for path, content in payloads
    )
    identity = RepositoryIdentity(
        id=profile.repository.id, revision=profile.repository.revision
    )
    # Independently represent source pins instead of trusting a configured revision.
    pins = (
        tuple(
            RepositoryFile(repository=identity, path=file.path, content=file.content)
            for file in files
        )
        if pinned
        else ()
    )
    # Mirror each retained file as one inspected input without asserting behavior.
    return InventoryCapture(
        profile=profile,
        inputs=tuple(
            InventoryInput(path=file.path, status="inspected", file=file)
            for file in files
        ),
        repository_files=pins,
    )


def rendered(result: Analysis) -> bytes:
    """Return canonical bytes for every Analysis row; pure leak/size assertion seam."""
    return canonical_json(
        row(
            components=result.components,
            findings=result.findings,
            relationships=result.relationships,
            diagnostics=result.diagnostics,
        )
    )


@pytest.mark.parametrize(
    "source,kind,symbol",
    [
        (
            "class R : IRibbonExtensibility {}",
            "ribbon_extensibility",
            "IRibbonExtensibility",
        ),
        (
            "class R : Microsoft.Office.Core.IRibbonExtensibility {}",
            "ribbon_extensibility",
            "IRibbonExtensibility",
        ),
        (
            "class R : Microsoft.Office.Tools.Ribbon.RibbonBase {}",
            "ribbon_extensibility",
            "Microsoft.Office.Tools.Ribbon",
        ),
        (
            "class R { string GetCustomUI(string id) { return null; } }",
            "ribbon_extensibility",
            "GetCustomUI",
        ),
        (
            "class ThisAddIn { void ThisAddIn_Startup() {} void Shutdown() {} }",
            "addin_lifecycle",
            "ThisAddIn_Startup",
        ),
        ("[ComImport] class C {}", "com_attribute", "ComImport"),
        ("[ComVisible(false)] class C {}", "com_attribute", "ComVisible"),
        ("Marshal.ReleaseComObject(secret);", "marshal_call", "ReleaseComObject"),
        ("Type.GetTypeFromProgID(secret);", "progid_activation", "GetTypeFromProgID"),
        (
            "using Microsoft.Office.Interop.GenericHost;",
            "interop_using",
            "Microsoft.Office.Interop.GenericHost",
        ),
        (
            "using static Microsoft.Office.Interop.GenericHost.Values;",
            "interop_using",
            "Microsoft.Office.Interop.GenericHost.Values",
        ),
        (
            "using Host = Microsoft.Office.Interop.GenericHost;",
            "interop_using",
            "Microsoft.Office.Interop.GenericHost",
        ),
    ],
)
def test_csharp_markers_keep_anchors_and_explicitly_unresolved_binding(
    profile: ProfileV2, source: str, kind: str, symbol: str
) -> None:
    """For ProfileV2/str source/kind/symbol retain lexical facts; return None, pure."""
    detections = classify_csharp("src/a.cs", "// ignored\r\n" + source, profile=profile)
    # Select the requested semantic marker while retaining any legitimate peers.
    found = [
        item
        for item in detections
        if item.detection_kind == kind and item.symbol == symbol
    ]
    assert found and found[0].line == 2
    assert dict(found[0].extra)["binding"] == "unresolved"
    assert "secret" not in repr(detections)


@pytest.mark.parametrize(
    "source",
    [
        "// IRibbonExtensibility Marshal.ReleaseComObject(x)",
        'var x = "IRibbonExtensibility Marshal.ReleaseComObject(x)";',
        '[Guid("masked-first")] class C {}',
        "Marshal.AddRef(x); Activator.CreateInstance(x);",
        "Take([ComImport]); Take(0, [ComVisible]);",
        "class C { bool Marshal.IsComObject(object x) => false; }",
        "class C { void Startup() {} }",
        "var x = Microsoft.Office.Interop.GenericHost;",
        "static Microsoft.Office.Interop.GenericHost;",
    ],
)
def test_lookalikes_and_values_do_not_become_optional_behavior(
    profile: ProfileV2, source: str
) -> None:
    """Reject str source lookalikes under consented ProfileV2; return None, pure."""
    assert classify_csharp("src/a.cs", source, profile=profile) == []


@pytest.mark.parametrize("generation", ["2006", "2009"])
def test_valid_ribbon_generation_fixtures_and_unchanged_invalid_original(
    profile: ProfileV2, generation: str
) -> None:
    """Read immutable str generation fixtures, retain declarations; return None.

    profile supplies consent. Only checked-in fixture reads occur; no temporary I/O.
    """
    fixtures = Path(__file__).resolve().parents[2] / "fixtures/discovery_dotnet_vsto"
    text = (fixtures / f"ribbon_customui_{generation}.xml.txt").read_text("utf-8")
    detections = classify_xml("src/ribbon.xml", text, profile=profile)
    # Compare both declaration kinds independently from callback additions.
    assert {
        item.symbol for item in detections if item.detection_kind == "ribbon_xml"
    } == {"customUI", "customui-" + generation}
    assert any(item.detection_kind == "ribbon_callback" for item in detections)
    with pytest.raises(XmlInputError, match="malformed"):
        classify_xml(
            "src/ribbon.xml",
            (fixtures / "ribbon_customui.xml.txt").read_text("utf-8"),
            profile=profile,
        )


@pytest.mark.parametrize(
    "body",
    [
        '<!-- <button onAction="Trap"/> -->',
        '<opaque><button onAction="Trap"/></opaque>',
        '<button xmlns="urn:foreign" onAction="Trap"/>',
        '<button onAction="{Binding Trap}"/>',
        '<button onAction="A..Trap"/>',
        '<button onAction="' + "X" * 257 + '"/>',
    ],
)
def test_ribbon_opaque_and_nonliteral_callbacks_are_ignored(
    profile: ProfileV2, body: str
) -> None:
    """Use str body/ProfileV2 to retain only the legitimate root; return None."""
    result = classify_xml(
        "src/r.xml", f'<customUI xmlns="{URI}">{body}</customUI>', profile=profile
    )
    assert len(result) == 2 and all(
        item.detection_kind == "ribbon_xml" for item in result
    )


@pytest.mark.parametrize(
    "body",
    [
        '<ProjectExtensions><ItemGroup><COMReference Include="SECRET"/>'
        "</ItemGroup></ProjectExtensions>",
        '<PropertyGroup><ItemGroup><COMReference Include="SECRET"/>'
        "</ItemGroup></PropertyGroup>",
        '<ItemGroup><Reference Include="C:/SECRET"/></ItemGroup>',
    ],
)
def test_project_opaque_payloads_and_targets_are_not_emitted(
    profile: ProfileV2, body: str
) -> None:
    """For ProfileV2/str body reject opaque declarations and targets; return None."""
    assert (
        classify_project(
            "src/a.csproj", "<Project>" + body + "</Project>", profile=profile
        )
        == []
    )


def test_project_uses_shared_com_and_preserves_false_and_condition_presence(
    profile: ProfileV2,
) -> None:
    """Use configured profile to retain declaration semantics without values; pure."""
    text = (
        '<Project><ItemGroup Condition="SECRET"><COMReference Include="SECRET">'
        "<EmbedInteropTypes>false</EmbedInteropTypes></COMReference>"
        '<Reference Include="Microsoft.Office.Interop.GenericHost"/>'
        "</ItemGroup></Project>"
    )
    result = classify_project("src/a.csproj", text, profile=profile)
    candidate = next(item for item in result if item.symbol == "COMReference")
    assert dict(candidate.extra)["embed_interop_types"] == "false"
    assert dict(candidate.extra)["conditional"] == "true"
    assert "SECRET" not in repr(result) and len(result) == 2


@pytest.mark.parametrize("encoding", ["utf-8", "utf-16"])
def test_adapter_retains_original_xml_bytes_schema_and_unresolved_relationships(
    analyzer_catalog: SchemaCatalog, profile: ProfileV2, encoding: str
) -> None:
    """For SchemaCatalog/ProfileV2/str encoding prove deterministic provenance.

    Return None; memory-only composition validates the actual inventory schema.
    """
    content = (
        f'<?xml version="1.0" encoding="{encoding}"?>\r\n'
        f'<customUI xmlns="{URI}" onLoad="Start">'
        '<ribbon><button onAction="Go"/></ribbon></customUI>'
    ).encode(encoding)
    inputs = captured(
        profile, (("src/r.xml", content), ("src/a.cs", b"[ComImport] class C {}"))
    )
    adapter = VstoOfficeAnalyzer()
    result = adapter.analyze(inputs)
    assert result == adapter.analyze(inputs)
    document = inventory_result(
        inputs,
        (result,),
        analyzer_ids=("office-vsto",),
        timestamp="2026-10-19T11:00:00Z",
        author_or_agent=row(kind="tool", id="fixture"),
        catalog=analyzer_catalog,
    ).document
    assert document["schema_version"] == "2.0.0"
    assert len(result.relationships) == 2
    # Every declared callback remains an unbound possible method relationship.
    assert all(
        link["to_component_id"] is None and link["classification"] == "inferred"
        for link in result.relationships
    )
    xml = next(item for item in result.findings if item["kind"] == "ribbon_callback")
    assert (
        cast("JsonObject", xml["source"])["sha256"]
        == hashlib.sha256(content).hexdigest()
    )
    assert xml["classification"] == "detected"
    extension = cast(
        "JsonObject", cast("JsonObject", xml["extensions"])["drm.office-vsto"]
    )
    symbol = cast("tuple[JsonObject, ...]", xml["properties"])[0]["value"]
    assert extension["legacy_evidence_id"] == build_evidence_id(
        "vsto", "ribbon_callback", cast("str", symbol), "src/r.xml", 2
    )
    assert extension["execution"] == "unverified" and inputs.inputs[1].file is not None


def test_unverified_pins_exclusions_and_unreadable_inputs_remain_distinct(
    profile: ProfileV2,
) -> None:
    """Use configured profile and memory-only omitted inputs; return None."""
    inputs = captured(
        profile,
        (("src/a.cs", b"[ComImport] class C {}"), ("src/ignore.txt", b"IGNORED")),
        pinned=False,
    )
    inputs = replace(
        inputs,
        inputs=inputs.inputs
        + (
            InventoryInput(path="src/b.cs", status="unreadable", rationale="SECRET"),
            InventoryInput(path="src/c.xml", status="excluded", rationale="SECRET"),
        ),
    )
    result = VstoOfficeAnalyzer().analyze(inputs)
    assert len(result.findings) == 1 and result.findings[0]["confidence"] == "low"
    # Preserve independent read, provenance and interpretation limitations.
    assert {item["code"] for item in result.diagnostics} == {
        "optional-binding-unresolved",
        "source-revision-unverified",
        "input-unreadable",
    }
    assert b"SECRET" not in rendered(result) and b"IGNORED" not in rendered(result)
