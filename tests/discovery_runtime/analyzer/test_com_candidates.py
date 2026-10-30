"""Verify pure COM syntax/project candidates with bounded in-memory inputs."""

from __future__ import annotations

from itertools import product

import pytest
from drm_copilot_discovery.analyzer.com_interop import (
    com_project_candidates,
    com_source_candidates,
)
from drm_copilot_discovery.analyzer.com_syntax import (
    com_source_candidates as source_candidates,
)
from drm_copilot_discovery.analyzer.csharp_tokens import SourceScanError
from drm_copilot_discovery.analyzer.source_text import Detection
from drm_copilot_discovery.analyzer.xml_input import XmlInputError


@pytest.mark.parametrize(
    "attribute",
    (
        "ComImport",
        "ComVisible",
        "InterfaceType",
        "ClassInterface",
        "ComDefaultInterface",
        "ComSourceInterfaces",
        "CoClass",
        "ComEventInterface",
        "DispId",
        "TypeLibType",
        "TypeLibFunc",
        "TypeLibVar",
        "LCIDConversion",
        "ComConversionLoss",
    ),
)
@pytest.mark.parametrize(
    "prefix,suffix",
    (("", ""), ("global::System.Runtime.InteropServices.", "Attribute")),
)
def test_known_attribute_candidates_keep_exact_span_without_values(
    attribute: str, prefix: str, suffix: str
) -> None:
    """Use str attribute/prefix/suffix to verify shared Detection and anchors; pure.

    Returns None; false exposure arguments remain withheld, never activation proof.
    """
    name = prefix + attribute + suffix
    source = "\r\n[assembly: " + name + '(false, "VALUE_SENTINEL")]'
    result = com_source_candidates("src/sample.cs", source)
    assert len(result) == 1 and type(result[0]) is Detection
    candidate = result[0]
    assert candidate.symbol == name and candidate.detection_kind == "com_attribute"
    assert candidate.line == 2 and candidate.symbol_kind == "attribute"
    assert dict(candidate.extra)["offset"] == source.index(name)
    assert dict(candidate.extra)["end_offset"] == source.index(name) + len(name)
    assert "VALUE_SENTINEL" not in repr(candidate) and "false" not in repr(candidate)


@pytest.mark.parametrize(
    "call,kind",
    (
        ("Type.GetTypeFromProgID", "com_type_lookup"),
        ("System.Type.GetTypeFromCLSID", "com_type_lookup"),
        ("Activator.CreateComInstanceFrom", "com_activation"),
        ("Marshal.BindToMoniker", "com_activation"),
        ("Marshal.GetActiveObject", "com_object_lookup"),
        ("Marshal.ReleaseComObject", "com_lifetime_call"),
        ("Marshal.FinalReleaseComObject", "com_lifetime_call"),
        ("Marshal.GetIUnknownForObject", "marshal_call"),
        ("Marshal.GetIDispatchForObject", "marshal_call"),
        ("Marshal.GetComInterfaceForObject", "marshal_call"),
        ("Marshal.GetObjectForIUnknown", "marshal_call"),
        ("Marshal.IsComObject", "marshal_call"),
        ("Marshal.QueryInterface", "marshal_call"),
    ),
)
def test_call_families_distinguish_lookup_activation_and_lifetime(
    call: str, kind: str
) -> None:
    """For str call/kind, preserve inferred operation family without arguments.

    Returns None; only known API spelling is asserted, without binding/execution.
    """
    result = com_source_candidates("src/sample.cs", call + '("VALUE_SENTINEL");')
    assert len(result) == 1 and result[0].symbol == call
    assert (
        result[0].detection_kind == kind
        and dict(result[0].extra)["binding"] == "unresolved"
    )
    assert "VALUE_SENTINEL" not in repr(result)


@pytest.mark.parametrize(
    "source",
    (
        '[Guid("VALUE_SENTINEL")] interface X {}',
        '[DllImport("VALUE_SENTINEL")] extern void M();',
        "Activator.CreateInstance(value);",
        "Marshal.ReadInt32(value);",
        "System.Marshal.ReleaseComObject(value);",
        "Custom.Marshal.ReleaseComObject(value);",
        "[Custom.ComImport] class X {}",
        "array[ComImport];",
        "array[1, ComImport];",
        "var values = [ComImport];",
        "Marshal += value;",
        "NotMarshal.ReleaseComObject(value);",
        "// Marshal.ReleaseComObject(value);",
        '"Marshal.ReleaseComObject(value)"',
        '$$"""{{ Marshal.ReleaseComObject(value) }}"""',
        "/* [ComImport] */",
        "using M = System.Runtime.InteropServices.Marshal; M.ReleaseComObject(value);",
        "@Marshal.ReleaseComObject(value);",
        "Marshal.IsComObject;",
        "ComImport();",
    ),
)
def test_non_com_or_masked_lookalikes_do_not_become_candidates(source: str) -> None:
    """Reject str source lookalikes, literals, aliases and ambiguous APIs; pure.

    Returns None; Guid, DllImport, ordinary activation and arbitrary marshalling
    provide insufficient COM evidence on their own.
    """
    assert com_source_candidates("src/sample.cs", source) == ()


@pytest.mark.parametrize(
    "source",
    (
        "class C { void M() { int ComImport = 1; Take([ComImport]); } "
        "void Take(int[] values) {} }",
        "class C { void M() { int ComVisible = 1; Take(0, [ComVisible]); } "
        "void Take(int n, int[] values) {} }",
        "interface Marshal { bool IsComObject(object x); } class C : Marshal { "
        "bool Marshal.IsComObject(object x) { return false; } }",
        "bool Marshal.IsComObject(object x) => false;",
        "Take([ComImport], rest);",
        "Take([ComImport] is object);",
        "Take([ComImport] as object);",
        "Take([ComImport] switch { _ => 1 });",
        "Take([[ComImport]]);",
        "Take([ComImport][ComVisible]);",
        "Take([ComImport]());",
        "[ComImport]",
    ),
)
def test_collection_arguments_and_explicit_methods_are_not_com_candidates(
    source: str,
) -> None:
    """Reject str source expression/declaration contexts without false syntax claims.

    Returns None; these include all retained COM R1 probes and neighboring contexts.
    No compiler binding, runtime behavior or file I/O is involved.
    """
    assert com_source_candidates("src/context.cs", source) == ()


@pytest.mark.parametrize(
    "source,count",
    (
        ("[ComImport] interface C {}", 1),
        ("[ComImport][ComVisible(false)] class C {}", 2),
        ("[assembly:ComVisible(false)]", 1),
        ("[module:ComVisible(false)]", 1),
        ("void M([ComDefaultInterface(typeof(I))] object value) {}", 1),
        ("void M(int x, [ComVisible(false)] object value) {}", 1),
        ("[ComVisible(false)] () => value", 1),
        ("Marshal.IsComObject(value)", 1),
        ("void M() { if (Marshal.IsComObject(value)) {} }", 1),
        ("bool Marshal.IsComObject(object x) => Marshal.IsComObject(x);", 1),
    ),
)
def test_context_filter_preserves_attributes_and_nested_invocations(
    source: str,
    count: int,
) -> None:
    """Preserve genuine syntax in str source with int count; return None, pure.

    The old public entry point explicitly re-exports the same callable/carrier.
    Declaration-body calls remain independent candidates, without execution claims.
    """
    assert com_source_candidates is source_candidates
    result = com_source_candidates("src/context.cs", source)
    assert len(result) == count and all(isinstance(item, Detection) for item in result)


def test_long_attribute_chain_respects_the_original_candidate_capacity() -> None:
    """Resolve chained declaration context once with unchanged result bounds; pure.

    Returns None; deterministic repeated sections preserve separate source anchors.
    No wall-clock threshold or external allocation instrumentation is used.
    """
    source = "[ComImport]" * 256 + "interface C {}"
    result = com_source_candidates("src/chain.cs", source, max_candidates=256)
    assert len(result) == 256
    # Distinct sections must retain every source location despite sharing a name.
    assert len({dict(item.extra)["offset"] for item in result}) == 256
    with pytest.raises(SourceScanError, match="candidates exceed"):
        com_source_candidates("src/chain.cs", source, max_candidates=255)


def test_masked_earlier_guid_cannot_replace_the_actual_candidate_anchor() -> None:
    """Keep matched offsets without scanning unrelated raw literals; return None.

    Neither earlier nor adjacent GUID argument values are retained in candidates.
    """
    source = (
        'var x = "[Guid(OLD_SECRET)]"; /* [ComImport] */\r\n'
        '[ComImport, Guid("NEW_SECRET")] interface Real {}'
    )
    result = com_source_candidates("src/sample.cs", source)
    assert len(result) == 1 and result[0].symbol == "ComImport"
    assert result[0].line == 2 and dict(result[0].extra)["offset"] == source.rindex(
        "ComImport"
    )
    assert "SECRET" not in repr(result) and "com_guid" not in repr(result)


@pytest.mark.parametrize(
    "source,code",
    (
        (")", "source-delimiter"),
        ("[ComImport", "source-delimiter"),
        ("[ComImport)", "source-delimiter"),
        ("\\uZZZZ", "source-identifier"),
    ),
)
def test_invalid_source_fails_without_partial_candidates(
    source: str, code: str
) -> None:
    """Reject str malformed source with expected stable str code; return None."""
    with pytest.raises(SourceScanError) as error:
        com_source_candidates("src/sample.cs", source)
    assert error.value.code == code


@pytest.mark.parametrize("capacity", (-1, True, 100001))
def test_invalid_candidate_capacity_rejected_at_each_public_seam(capacity: int) -> None:
    """Reject invalid int/bool capacity before parsing at both seams; return None."""
    with pytest.raises(ValueError, match="candidate limit"):
        com_source_candidates("src/a.cs", "", max_candidates=capacity)
    with pytest.raises(ValueError, match="candidate limit"):
        com_project_candidates("src/a.csproj", b"<Project/>", max_candidates=capacity)


def test_token_and_candidate_limits_reject_before_partial_output() -> None:
    """Exercise independent lexical/result ceilings and zero capacity; return None."""
    assert com_source_candidates("src/a.cs", "class X {}", max_candidates=0) == ()
    with pytest.raises(SourceScanError, match="token limit"):
        com_source_candidates("src/a.cs", "Marshal.IsComObject(x);", max_tokens=2)
    with pytest.raises(SourceScanError, match="candidates exceed"):
        com_source_candidates("src/a.cs", "Marshal.IsComObject(x);", max_candidates=0)
    with pytest.raises(SourceScanError, match="candidates exceed"):
        com_project_candidates(
            "src/a.csproj",
            b"<Project><ItemGroup><COMReference/></ItemGroup></Project>",
            max_candidates=0,
        )


def test_source_text_limit_rejects_before_masking_allocation() -> None:
    """Reject a bounded 64 MiB-plus-one memory string before parsing; return None."""
    with pytest.raises(SourceScanError, match="text limit"):
        com_source_candidates("src/a.cs", "x" * 67108865)


def test_repeated_multiline_calls_keep_independent_exact_spans() -> None:
    """Keep duplicate COM sites distinct across physical line forms; return None."""
    source = "Marshal\r\n.IsComObject(x); Marshal.IsComObject(y);"
    result = com_source_candidates("src/a.cs", source)
    assert len(result) == 2 and result[0].line == 1 and result[1].line == 2
    assert dict(result[0].extra)["end_line"] == 2
    assert dict(result[0].extra)["offset"] == 0
    assert dict(result[1].extra)["offset"] == source.rindex("Marshal")
    assert dict(result[0].extra)["end_offset"] == source.index("(x)")


@pytest.mark.parametrize("limits", ({"max_elements": 2}, {"max_depth": 2}))
def test_project_structural_limits_reject_before_candidate_publication(
    limits: dict[str, int],
) -> None:
    """Apply int XML limits to public candidates; return None without I/O."""
    with pytest.raises(XmlInputError, match="depth or element count"):
        com_project_candidates(
            "src/a.csproj",
            b"<Project><ItemGroup><COMReference/></ItemGroup></Project>",
            **limits,
        )


@pytest.mark.parametrize(
    "element,kind",
    (("COMReference", "com_reference"), ("COMFileReference", "com_file_reference")),
)
@pytest.mark.parametrize(
    "value,expected",
    (("false", "false"), (" TRUE ", "true"), ("$(VALUE_SENTINEL)", "unresolved")),
)
def test_project_items_keep_declared_boolean_and_condition_presence(
    element: str, kind: str, value: str, expected: str
) -> None:
    """Use str element/kind/value/expected to preserve inert XML declarations.

    Returns None; raw targets, conditions and GUIDs stay withheld. A declared false
    setting never becomes enabled interop, including beneath a conditional group.
    """
    payload = (
        '<Project xmlns="http://schemas.microsoft.com/developer/msbuild/2003">'
        '<ItemGroup Condition="VALUE_SENTINEL">\n'
        f'<{element} Include="VALUE_SENTINEL"><Guid>VALUE_SENTINEL</Guid>'
        f"<EmbedInteropTypes>{value}</EmbedInteropTypes></{element}>"
        "</ItemGroup></Project>"
    ).encode()
    result = com_project_candidates("src/a.csproj", payload)
    assert len(result) == 1 and result[0].detection_kind == kind and result[0].line == 2
    assert dict(result[0].extra)["embed_interop_types"] == expected
    assert dict(result[0].extra)["conditional"] == "true"
    assert dict(result[0].extra)["operation"] == "include"
    assert "VALUE_SENTINEL" not in repr(result)


def test_project_duplicates_and_unresolved_metadata_remain_separate() -> None:
    """Keep duplicate/default/remove operations without activating them; pure.

    Returns None; repeated/absent metadata is unresolved and child conditions count.
    """
    payload = (
        b'<Project><ItemGroup><COMReference Include="A">'
        b'<EmbedInteropTypes Condition="secret">false</EmbedInteropTypes>'
        b'</COMReference><COMReference Update="A" Remove="B">'
        b"<EmbedInteropTypes>true</EmbedInteropTypes>"
        b"<EmbedInteropTypes>false</EmbedInteropTypes></COMReference>"
        b'<COMFileReference Remove="C"/></ItemGroup>'
        b"<ItemDefinitionGroup><COMReference/></ItemDefinitionGroup></Project>"
    )
    values = com_project_candidates("src/a.props", payload)
    # Extract literal ordinals to prove duplicate declarations remain distinct.
    assert (
        len(values) == 4
        and len({dict(value.extra)["ordinal"] for value in values}) == 4
    )
    # Project each operation classification without interpreting reference targets.
    assert [dict(value.extra)["operation"] for value in values] == [
        "include",
        "unresolved",
        "remove",
        "unresolved",
    ]
    # Preserve false/ambiguous metadata; element presence does not enable interop.
    assert [dict(value.extra)["embed_interop_types"] for value in values] == [
        "false",
        "unresolved",
        "unresolved",
        "unresolved",
    ]
    assert (
        dict(values[0].extra)["conditional"] == "true"
        and dict(values[1].extra)["conditional"] == "false"
    )


@pytest.mark.parametrize(
    "payload",
    (
        b'<Project><!-- <COMReference Include="secret"/> --></Project>',
        b'<Project><ItemGroup><Reference Include="secret">'
        b"<EmbedInteropTypes>true</EmbedInteropTypes>"
        b"</Reference></ItemGroup></Project>",
        b"<Project><PropertyGroup><COMReference>secret</COMReference></PropertyGroup></Project>",
    ),
)
def test_comments_assembly_references_and_properties_are_not_com_items(
    payload: bytes,
) -> None:
    """Treat bytes payload as secure build XML without false COM facts; return None."""
    assert com_project_candidates("src/a.csproj", payload) == ()


@pytest.mark.parametrize(
    "payload,code",
    (
        (b"<Project><ItemGroup>", "xml-malformed"),
        (b"<Other/>", "xml-root"),
        (b'<Project xmlns="urn:other"/>', "xml-namespace"),
        (
            b'<!DOCTYPE Project [<!ENTITY x SYSTEM "file:///VALUE_SENTINEL">]><Project/>',
            "xml-dtd",
        ),
    ),
)
def test_unsafe_or_malformed_project_fails_without_partial_declarations(
    payload: bytes, code: str
) -> None:
    """Reject bytes payload with stable str code and no external entity I/O; pure."""
    with pytest.raises(XmlInputError) as error:
        com_project_candidates("src/a.csproj", payload)
    assert error.value.code == code


def test_generated_layouts_preserve_fixed_candidates_without_values() -> None:
    """Check deterministic pure source/project invariants over generated layouts.

    Returns None; Cartesian inputs exercise separators, masking and redaction without
    random state, optional imports, compiler execution or runtime I/O.
    """
    # Layout changes may move anchors but cannot change a recognized API's meaning.
    for newline, prefix in product(
        ("\n", "\r", "\r\n"), ("", "/* VALUE_SENTINEL */", '"VALUE_SENTINEL";')
    ):
        text = (
            prefix + newline + "Marshal" + newline + '.IsComObject("VALUE_SENTINEL");'
        )
        first = com_source_candidates("src/a.cs", text)
        assert first == com_source_candidates("src/a.cs", text)
        assert len(first) == 1 and first[0].detection_kind == "marshal_call"
        assert "VALUE_SENTINEL" not in repr(first)
        xml = (
            "<Project>"
            + newline
            + '<ItemGroup><COMReference Include="VALUE_SENTINEL"/>'
            + "</ItemGroup></Project>"
        ).encode()
        assert com_project_candidates("src/a.csproj", xml) == com_project_candidates(
            "src/a.csproj", xml
        )
        assert "VALUE_SENTINEL" not in repr(com_project_candidates("src/a.csproj", xml))
