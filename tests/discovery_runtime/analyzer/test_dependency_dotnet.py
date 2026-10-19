"""Verify pure .NET dependency declarations, redaction and bounded failure contracts."""

from __future__ import annotations

import json
from dataclasses import replace
from typing import cast

import pytest
from drm_copilot_discovery.analyzer.dependency_dotnet import (
    DotnetDependencyFormat,
    parse_dotnet_dependencies,
)
from drm_copilot_discovery.analyzer.dependency_inputs import (
    DependencyInputError,
    DependencyLimits,
)


def project(item: str, *, namespace: str = "") -> bytes:
    """Wrap str item in a synthetic project with optional str namespace.

    Returns UTF-8 bytes; performs no I/O or mutation and raises no domain error.
    """
    return f"<Project{namespace}><ItemGroup>{item}</ItemGroup></Project>".encode()


def lock(record: object, *, name: str = "Alpha") -> bytes:
    """Wrap JSON-compatible object record and str name in a synthetic NuGet v1 lock.

    Returns bytes; json serialization errors propagate; no I/O or input mutation.
    """
    return json.dumps(
        {"version": 1, "dependencies": {"net8.0": {name: record}}}
    ).encode()


@pytest.mark.parametrize("operation", ["Include", "Update", "Remove"])
@pytest.mark.parametrize("element", ["PackageReference", "PackageVersion"])
@pytest.mark.parametrize(
    "namespace", ["", ' xmlns="http://schemas.microsoft.com/developer/msbuild/2003"']
)
def test_project_operations(operation: str, element: str, namespace: str) -> None:
    """Preserve str operation/element/namespace declarations without activation.

    Returns None; assertions propagate; no I/O or mutation outside local values.
    """
    content = project(
        f'<{element} {operation}="Alpha" Version="[1.0,2.0)"/>', namespace=namespace
    )
    result = parse_dotnet_dependencies(
        content, format="project", limits=DependencyLimits()
    )
    (candidate,) = result.candidates
    assert (candidate.kind, candidate.role, candidate.operation) == (
        "declaration",
        element,
        operation.lower(),
    )
    assert candidate.name == "Alpha" and candidate.version.value == "[1.0,2.0)"
    assert candidate.anchor.location == element and candidate.anchor.line == 1
    assert result.diagnostics == ()


def test_metadata_conditions_remain_separate_ambiguous_declarations() -> None:
    """Retain real child anchors and condition presence; never compute precedence.

    Returns None; assertions propagate; uses only local in-memory bytes.
    """
    content = b"""<Project><Target Condition="SECRET"><ItemGroup>
<PackageReference Include="Alpha" Version="1" VersionOverride="2">
<Version Condition="SECRET">3</Version>
<VersionOverride>4</VersionOverride><PrivateAssets>all</PrivateAssets>
</PackageReference></ItemGroup></Target></Project>"""
    result = parse_dotnet_dependencies(
        content, format="project", limits=DependencyLimits()
    )
    # Preserve distinct syntax roles rather than one effective version.
    assert [row.role for row in result.candidates] == [
        "PackageReference",
        "VersionOverride",
        "Version",
        "VersionOverride",
    ]
    # Check each literal remains associated with its own metadata occurrence.
    assert [row.version.value for row in result.candidates] == ["1", "2", "3", "4"]
    # Real tag anchors distinguish children from parent attributes.
    assert [row.anchor.line for row in result.candidates] == [2, 2, 3, 4]
    # Enclosing conditions propagate presence without retaining expressions.
    assert all(row.condition_present for row in result.candidates)
    assert result.diagnostics == ("dependency-ambiguous",)
    assert "SECRET" not in repr(result)


def test_repeated_declarations_and_missing_version_are_preserved() -> None:
    """Keep duplicate occurrences distinct and missing versions unresolved.

    Returns None; assertions propagate; no external effects.
    """
    content = project(
        '<PackageVersion Include="Alpha"/><PackageVersion Include="Alpha"/>'
    )
    result = parse_dotnet_dependencies(
        content, format="project", limits=DependencyLimits()
    )
    assert len(result.candidates) == 2
    assert result.candidates[0].anchor != result.candidates[1].anchor
    # No central-version activation may supply either missing value.
    assert all(row.version.kind == "missing" for row in result.candidates)


def test_packages_config_keeps_versions_and_tag_lines() -> None:
    """Extract only flat package declarations with genuine XML anchors.

    Returns None; assertions propagate; no external effects.
    """
    content = (
        b'<packages>\n<package id="Alpha" version="1.2.3" targetFramework="SECRET"/>'
        b'\n<package id="Beta" Condition="SECRET"/></packages>'
    )
    result = parse_dotnet_dependencies(
        content, format="packages-config", limits=DependencyLimits()
    )
    # Compare source-linked values in physical declaration order.
    assert [
        (row.name, row.version.value, row.anchor.line) for row in result.candidates
    ] == [("Alpha", "1.2.3", 2), ("Beta", None, 3)]
    assert result.candidates[1].condition_present
    assert "SECRET" not in repr(result)


@pytest.mark.parametrize("role", ["Direct", "Transitive", "Project"])
def test_lock_records_and_declared_edges(role: str) -> None:
    """Preserve str lock role and separate requested/resolved/edge versions.

    Returns None; assertions propagate; no I/O or global state.
    """
    content = lock(
        {
            "type": role,
            "requested": "[1,2)",
            "resolved": "1.5",
            "contentHash": "SECRET",
            "dependencies": {"Beta": "[3,4)"},
        }
    )
    result = parse_dotnet_dependencies(
        content, format="packages-lock", limits=DependencyLimits()
    )
    package, edge = result.candidates
    assert (package.role, package.version.value, package.requested.value) == (
        role,
        "1.5",
        "[1,2)",
    )
    assert (edge.kind, edge.owner, edge.name, edge.version.value) == (
        "declared-lock-edge",
        "Alpha",
        "Beta",
        "[3,4)",
    )
    assert package.anchor.location == edge.anchor.location == "/dependencies"
    assert package.anchor.line is None and edge.anchor.occurrence == 2
    assert "SECRET" not in repr(result)


def test_json_order_is_deterministic_and_unused_metadata_is_bounded() -> None:
    """Canonical member order determines occurrences; ignored arrays still cost work.

    Returns None; assertions propagate; no external effects.
    """
    first = (
        b'{"version":1,"dependencies":{"net8":{"B":{"type":"Project"},'
        b'"A":{"type":"Direct"}}},"ignored":[null,[true]]}'
    )
    second = (
        b'{"ignored":[null,[true]],"dependencies":{"net8":{"A":{"type":"Direct"},'
        b'"B":{"type":"Project"}}},"version":1}'
    )
    result = parse_dotnet_dependencies(
        first, format="packages-lock", limits=DependencyLimits()
    )
    assert result == parse_dotnet_dependencies(
        second, format="packages-lock", limits=DependencyLimits()
    )
    # Canonical key ordering must not depend on serialized member order.
    assert [row.name for row in result.candidates] == ["A", "B"]
    # Missing locked values remain explicit rather than inferred from record types.
    assert all(row.version.kind == "missing" for row in result.candidates)
    assert result.consumed_nodes > 10


@pytest.mark.parametrize(
    "value",
    [
        "https://user:SECRET@host/file?q=SECRET",
        "$(SECRET)",
        "../SECRET",
        "token:SECRET",
    ],
)
def test_values_and_locations_are_redacted(value: str) -> None:
    """Strip unsafe str value from versions, owner names and location-derived data.

    Returns None; assertions propagate; no external effects.
    """
    content = lock(
        {
            "type": "Direct",
            "requested": value,
            "resolved": value,
            "dependencies": {value: value},
        },
        name=value,
    )
    result = parse_dotnet_dependencies(
        content, format="packages-lock", limits=DependencyLimits()
    )
    assert "SECRET" not in repr(result)
    assert result.diagnostics == ("dependency-redacted",)
    # Neither record nor target names may retain unsafe locations.
    assert all(row.name is None for row in result.candidates)
    # Version categories retain no secret-bearing value text.
    assert all(row.version.value is None for row in result.candidates)


@pytest.mark.parametrize(
    "content",
    [
        b"<",
        b"<Wrong/>",
        b'<Project xmlns="urn:SECRET"/>',
        b'<Project><PackageReference Include="A"/></Project>',
        project("<PackageReference/>"),
        project('<PackageReference Include=" "/>'),
        project('<PackageReference Include="A" Update="B"/>'),
        project(
            '<PackageReference Include="A"><Version><Value>1</Value>'
            "</Version></PackageReference>"
        ),
        b'<!DOCTYPE Project [<!ENTITY x "SECRET">]><Project/>',
        b'<Project xmlns:x="http://www.w3.org/2001/XInclude">'
        b'<x:include href="SECRET"/></Project>',
    ],
)
def test_invalid_project_never_returns_partial_candidates(content: bytes) -> None:
    """Reject unsafe/malformed bytes content with a fixed public error.

    Returns None; assertions propagate; no external effects.
    """
    with pytest.raises(DependencyInputError) as caught:
        parse_dotnet_dependencies(content, format="project", limits=DependencyLimits())
    assert caught.value.code in {"dependency-malformed", "dependency-unsupported"}
    assert "SECRET" not in str(caught.value)


@pytest.mark.parametrize(
    "content",
    [
        b'<packages xmlns="urn:SECRET"/>',
        b"<packages><other/></packages>",
        b"<packages><package/></packages>",
        b'<packages><package id=" "/></packages>',
        b'<packages><package id="A"><package id="B"/></package></packages>',
    ],
)
def test_invalid_packages_config(content: bytes) -> None:
    """Reject bytes content outside the explicit flat packages grammar.

    Returns None; assertions propagate; no external effects.
    """
    with pytest.raises(DependencyInputError):
        parse_dotnet_dependencies(
            content, format="packages-config", limits=DependencyLimits()
        )


@pytest.mark.parametrize(
    "content",
    [
        b"{",
        b"[]",
        b'{"version":1,"version":1,"dependencies":{}}',
        b'{"version":true,"dependencies":{}}',
        b'{"version":2,"dependencies":{}}',
        b'{"version":1}',
        b'{"version":1,"dependencies":{"net":[]}}',
        lock([]),
        lock({"type": "SECRET"}),
        lock({"type": "Direct", "resolved": 42}),
        lock({"type": "Direct", "dependencies": {"A": []}}),
        lock({"type": "Direct", "dependencies": None}),
    ],
)
def test_invalid_lock_shapes_and_duplicate_members(content: bytes) -> None:
    """Reject bytes content with bad shape/version/duplicates without raw errors.

    Returns None; assertions propagate; no external effects.
    """
    with pytest.raises(DependencyInputError) as caught:
        parse_dotnet_dependencies(
            content, format="packages-lock", limits=DependencyLimits()
        )
    assert "SECRET" not in str(caught.value)


@pytest.mark.parametrize(
    "format,content",
    [
        (
            "project",
            project('<PackageReference Include="A"/><PackageReference Include="B"/>'),
        ),
        ("packages-lock", lock({"type": "Direct", "dependencies": {"B": "1"}})),
    ],
)
@pytest.mark.parametrize(
    "field,value",
    [
        ("max_bytes", 1),
        ("max_nodes", 1),
        ("max_depth", 1),
        ("max_candidates", 1),
        ("max_text_bytes", 1),
    ],
)
def test_limits_discard_the_entire_population(
    format: DotnetDependencyFormat, content: bytes, field: str, value: int
) -> None:
    """Bound selected str field/int value for explicit format and bytes input.

    Returns None; fixed DependencyInputError is asserted; no external effects.
    """
    limits = replace(DependencyLimits(), **{field: value})
    with pytest.raises(DependencyInputError, match="configured limit") as caught:
        parse_dotnet_dependencies(content, format=format, limits=limits)
    assert caught.value.code == "dependency-limit"


def test_line_limit_encoding_and_late_json_work_failure() -> None:
    """Reject physical-line, UTF-8 and post-normalization traversal exhaustion.

    Returns None; assertions propagate; no external effects.
    """
    with pytest.raises(DependencyInputError, match="configured limit"):
        parse_dotnet_dependencies(
            b"<Project>\r\n</Project>",
            format="project",
            limits=DependencyLimits(max_lines=1),
        )
    with pytest.raises(DependencyInputError, match="UTF-8"):
        parse_dotnet_dependencies(
            b"\xffSECRET", format="packages-lock", limits=DependencyLimits()
        )
    # One structural record passes the derived parser bound; key/value work exceeds64.
    content = json.dumps({"version": 1, "unused": list(range(60))}).encode()
    with pytest.raises(DependencyInputError, match="configured limit"):
        parse_dotnet_dependencies(
            content, format="packages-lock", limits=DependencyLimits(max_nodes=64)
        )


def test_empty_documents_bom_and_invalid_selector() -> None:
    """Allow empty supported populations and reject caller-selected unknown grammar.

    Returns None; assertions propagate; no external effects.
    """
    result = parse_dotnet_dependencies(
        b'\xef\xbb\xbf{"version":1,"dependencies":{}}',
        format="packages-lock",
        limits=DependencyLimits(),
    )
    assert result.candidates == () and result.diagnostics == ()
    assert (
        parse_dotnet_dependencies(
            b"<Project/>", format="project", limits=DependencyLimits()
        ).candidates
        == ()
    )
    with pytest.raises(ValueError, match="Unsupported .NET dependency format"):
        parse_dotnet_dependencies(
            b"",
            format=cast("DotnetDependencyFormat", "unknown"),
            limits=DependencyLimits(),
        )


def test_xml_selected_values_are_redacted_and_exact_limits_succeed() -> None:
    """Redact XML values and prove inclusive candidate/text/work boundaries.

    Returns None; assertions propagate; memory-only data has no external effects.
    """
    content = project(
        '<PackageReference Include="https://SECRET/path" Version="$(SECRET)"/>'
    )
    result = parse_dotnet_dependencies(
        content, format="project", limits=DependencyLimits()
    )
    assert "SECRET" not in repr(result)
    assert result.candidates[0].name is None
    assert result.candidates[0].version.kind == "dynamic"
    limits = DependencyLimits(
        max_bytes=len(content),
        max_candidates=1,
        max_nodes=result.consumed_nodes,
        max_text_bytes=result.consumed_text_bytes,
    )
    assert parse_dotnet_dependencies(content, format="project", limits=limits) == result


@pytest.mark.parametrize("opaque", ["ProjectExtensions", "UsingTask", "PropertyGroup"])
@pytest.mark.parametrize(
    "context", ["", "<Target>", '<Choose><When Condition="SECRET">']
)
def test_opaque_payloads_cannot_reactivate_dependency_extraction(
    opaque: str, context: str
) -> None:
    """Ignore str opaque subtree while preserving str genuine declaration context.

    Returns None; assertions propagate. No I/O, external state or input mutation.
    """
    closing = {
        "": "",
        "<Target>": "</Target>",
        '<Choose><When Condition="SECRET">': "</When></Choose>",
    }[context]
    content = (
        f"<Project><{opaque}><Project><ItemGroup>"
        '<PackageReference Include="SECRET" Version="1"/>'
        '<foreign:Data xmlns:foreign="urn:SECRET"/>'
        f"</ItemGroup></Project></{opaque}>{context}<ItemGroup>"
        '<PackageReference Include="Declared" Version="2"/>'
        f"</ItemGroup>{closing}</Project>"
    ).encode()
    result = parse_dotnet_dependencies(
        content, format="project", limits=DependencyLimits()
    )
    (candidate,) = result.candidates
    assert candidate.name == "Declared" and candidate.version.value == "2"
    assert candidate.condition_present == bool("Condition" in context)
    assert "SECRET" not in repr(result) and result.diagnostics == ()
    # Opaque nodes still consume bounded parse/index work despite yielding no facts.
    with pytest.raises(DependencyInputError, match="configured limit"):
        parse_dotnet_dependencies(
            content,
            format="project",
            limits=DependencyLimits(max_nodes=result.consumed_nodes - 1),
        )


def test_otherwise_and_nested_choose_keep_genuine_declarations() -> None:
    """Preserve nested Choose/Otherwise declarations without evaluating conditions.

    Returns None; assertions propagate; no external effects or input mutation.
    """
    content = b"""<Project><Choose><Otherwise><Choose><When Condition="SECRET">
<ItemGroup><PackageVersion Include="Declared"><Version>3</Version></PackageVersion>
</ItemGroup></When></Choose></Otherwise></Choose></Project>"""
    result = parse_dotnet_dependencies(
        content, format="project", limits=DependencyLimits()
    )
    assert len(result.candidates) == 2
    assert result.candidates[1].version.value == "3"
    assert result.candidates[1].condition_present
    assert "SECRET" not in repr(result)
