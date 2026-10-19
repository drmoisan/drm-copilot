"""Verify finite WPF declarations, unresolved relevance and bounded retained input."""

from __future__ import annotations

import codecs
import hashlib
from dataclasses import replace
from html import escape
from typing import TYPE_CHECKING, cast

import pytest
from drm_copilot_discovery.analyzer.emitter import inventory_result
from drm_copilot_discovery.analyzer.findings import row
from drm_copilot_discovery.analyzer.models import InventoryInput
from drm_copilot_discovery.analyzer.ui_callbacks import (
    UiCallbackAnalyzer,
    callback_candidates,
)
from drm_copilot_discovery.analyzer.xml_input import XmlInputError
from drm_copilot_discovery.models import canonical_json

from tests.discovery_runtime.analyzer.test_dotnet_projects import capture
from tests.discovery_runtime.analyzer.test_dotnet_projects import catalog as catalog
from tests.discovery_runtime.analyzer.test_repository import inventory_profile

if TYPE_CHECKING:
    from drm_copilot_discovery.analyzer.models import Analysis
    from drm_copilot_discovery.catalog import SchemaCatalog
    from drm_copilot_discovery.models import JsonObject
    from pytest import MonkeyPatch

WPF = "http://schemas.microsoft.com/winfx/2006/xaml/presentation"
CODE = b"namespace Demo; partial class View { void OnClick(object s) {} }"


def markup(
    body: str = '<Button Click="OnClick"/>',
    *,
    root: str = "Window",
    class_name: str = "Demo.View",
    namespace: str = WPF,
) -> bytes:
    """Return synthetic UTF-8 bytes from str body/root/class/namespace; no I/O."""
    return (
        f'<{root} xmlns="{namespace}" '
        'xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" '
        f'x:Class="{escape(class_name, quote=True)}">{body}</{root}>'
    ).encode()


def rendered(result: Analysis) -> str:
    """Return canonical str containing all Analysis rows for leak checks; pure."""
    return canonical_json(
        row(
            components=result.components,
            findings=result.findings,
            relationships=result.relationships,
            diagnostics=result.diagnostics,
        )
    ).decode()


def details(result: Analysis) -> list[JsonObject]:
    """Return inferred-link metadata from Analysis; typed projection, no mutation."""
    # Isolate extension extraction so tests assert meanings instead of JSON spelling.
    return [
        cast("JsonObject", cast("JsonObject", item["extensions"])["drm.ui-callbacks"])
        for item in result.relationships
    ]


@pytest.mark.parametrize(
    "element,event",
    (
        ("Window", "Loaded"),
        ("Window", "Unloaded"),
        ("Window", "Closing"),
        ("Window", "Closed"),
        ("Page", "Loaded"),
        ("UserControl", "Unloaded"),
        ("Button", "Click"),
        ("CheckBox", "Checked"),
        ("CheckBox", "Unchecked"),
        ("CheckBox", "Indeterminate"),
        ("RadioButton", "Checked"),
        ("RadioButton", "Unchecked"),
        ("TextBox", "TextChanged"),
        ("ComboBox", "SelectionChanged"),
        ("ListBox", "SelectionChanged"),
    ),
)
def test_only_documented_element_event_pairs_become_declarations(
    element: str, event: str
) -> None:
    """Verify literal str element/event pair and containing-node anchor; return None."""
    result = callback_candidates(
        "src/view.xaml", markup(f'<{element} {event}="Handler"/>')
    )
    assert len(result) == 2 and result[0].detection_kind == "ui_class"
    assert result[1].symbol == "Handler" and result[1].detection_kind == "ui_callback"
    assert dict(result[1].extra)["attribute"] == event


@pytest.mark.parametrize(
    "container",
    (
        "Grid",
        "StackPanel",
        "DockPanel",
        "WrapPanel",
        "Canvas",
        "Border",
        "ScrollViewer",
        "ContentControl",
    ),
)
def test_supported_containers_retain_child_callback_facts(container: str) -> None:
    """Wrap one handler in str container and retain its declaration; return None."""
    result = callback_candidates(
        "src/view.xaml", markup(f'<{container}><Button Click="Go"/></{container}>')
    )
    assert len(result) == 2 and result[1].symbol == "Go"


@pytest.mark.parametrize(
    "body",
    (
        '<Grid Click="SECRET"/>',
        '<Button Handler="SECRET" Command="SECRET"/>',
        '<Window.Resources><Button Click="SECRET"/></Window.Resources>',
        '<ResourceDictionary><Button Click="SECRET"/></ResourceDictionary>',
        '<ControlTemplate><Button Click="SECRET"/></ControlTemplate>',
        '<DataTemplate><Button Click="SECRET"/></DataTemplate>',
        '<Style><Button Click="SECRET"/></Style>',
        '<Custom><Button Click="SECRET"/></Custom>',
        "<x:Code><![CDATA[void SECRET() {}]]></x:Code>",
        '<foreign xmlns="urn:other"><Button xmlns="'
        + WPF
        + '" Click="SECRET"/></foreign>',
        '<!-- <Button Click="SECRET"/> --><Button Text="SECRET"/>',
    ),
)
def test_opaque_and_non_event_content_never_becomes_callback(body: str) -> None:
    """Inspect str body with unsupported content; return None, no value disclosure."""
    result = callback_candidates("src/view.xaml", markup(body))
    assert len(result) == 1 and result[0].symbol == "Demo.View"
    assert "SECRET" not in repr(result)


@pytest.mark.parametrize(
    "value",
    (
        "",
        " ",
        "Go()",
        "a.Go",
        "{Binding Go}",
        "{x:Static Go}",
        "Go;Run",
        "a/b",
        "λ",
        "a" * 129,
    ),
)
def test_handler_values_outside_literal_subset_fail_closed(value: str) -> None:
    """Reject str handler values without evaluating them; return None."""
    with pytest.raises(XmlInputError, match="handler"):
        callback_candidates(
            "src/view.xaml", markup(f'<Button Click="{escape(value)}"/>')
        )


@pytest.mark.parametrize("name", ("{Binding Name}", "../file.cs", "A..View", "a" * 513))
def test_class_is_a_bounded_literal_identity_not_a_filename(name: str) -> None:
    """Reject str class payload outside qualified identifiers; return None."""
    with pytest.raises(XmlInputError, match="class"):
        callback_candidates("src/view.xaml", markup(class_name=name))


@pytest.mark.parametrize(
    "payload,code",
    (
        (b'<Window><Button Click="Go"/></Window>', "ui-dialect"),
        (markup(root="ResourceDictionary"), "ui-dialect"),
        (markup(namespace="urn:other"), "ui-dialect"),
        (b"<Window", "xml-malformed"),
        (b'<!DOCTYPE Window [<!ENTITY x "SECRET">]><Window/>', "xml-dtd"),
        (b'<!DOCTYPE Window SYSTEM "https://invalid.example/a"><Window/>', "xml-dtd"),
        (b"\xff", "xml-malformed"),
    ),
)
def test_unsafe_or_unsupported_xml_has_fixed_rejection(
    payload: bytes, code: str
) -> None:
    """For bytes payload and str expected code, reject before findings; return None."""
    with pytest.raises(XmlInputError) as error:
        callback_candidates("src/view.xml", payload)
    assert error.value.code == code and "SECRET" not in str(error.value)


def test_explicit_names_and_inferred_code_relevance_validate_together(
    catalog: SchemaCatalog,
) -> None:
    """Use memory inputs and SchemaCatalog to verify the complete inventory; pure."""
    inputs = capture(catalog, (("src/View.xaml", markup()), ("src/View.xaml.cs", CODE)))
    inputs = replace(
        inputs,
        profile=inventory_profile(
            catalog,
            analyzers={
                "enabled": ["ui-callbacks"],
                "options": {},
                "ignored_paths": [],
                "extension_result_manifests": [],
            },
        ),
    )
    result = UiCallbackAnalyzer().analyze(inputs)
    assert len(result.findings) == 2 and len(result.relationships) == 2
    # Literal attribute observations remain facts independently of method relevance.
    assert all(item["classification"] == "detected" for item in result.findings)
    # No lexical association can manufacture a resolved target component.
    assert all(
        item["classification"] == "inferred" and item["to_component_id"] is None
        for item in result.relationships
    )
    # Unique spelling matches still describe candidates rather than bound symbols.
    assert all(item["match_status"] == "unique-candidate" for item in details(result))
    # Keep uncertainty explicit even when both class and method names agree.
    assert all(item["binding"] == "unresolved" for item in details(result))
    output = inventory_result(
        inputs,
        (result,),
        analyzer_ids=("ui-callbacks",),
        timestamp="2026-10-19T08:00:00Z",
        author_or_agent=row(kind="tool", id="fixture"),
        catalog=catalog,
    )
    # Seeding inventory never checks off discovery inspection or behavioral coverage.
    assert all(
        item["inspection_status"] == "uninspected" for item in output.ledger_components
    )


@pytest.mark.parametrize(
    "code,status",
    (
        (b"class Other { void OnClick() {} }", "missing-class"),
        (b"class View {}", "missing-method"),
        (b"class View { void OnClick() {} void OnClick(int x) {} }", "ambiguous"),
        (
            b"partial class View { void OnClick() {} } partial class View {}",
            "ambiguous",
        ),
        (b'class View { string x = "void OnClick() {}"; }', "missing-method"),
        (b"class View { /* void OnClick() {} */ }", "missing-method"),
        (b"class View { int OnClick; }", "missing-method"),
    ),
)
def test_lexical_matches_never_resolve_missing_or_ambiguous_methods(
    catalog: SchemaCatalog, code: bytes, status: str
) -> None:
    """For SchemaCatalog/bytes code/str status, keep all targets unresolved; pure."""
    result = UiCallbackAnalyzer().analyze(
        capture(catalog, (("src/a.xaml", markup()), ("src/a.xaml.cs", code)))
    )
    assert details(result)[1]["match_status"] == status
    # Missing or competing declarations cannot acquire resolved target identities.
    assert all(item["to_component_id"] is None for item in result.relationships)


@pytest.mark.parametrize(
    "class_name,code_path", (("", "src/a.xaml.cs"), ("Demo.View", "src/Demo.View.cs"))
)
def test_class_and_filename_association_are_independent(
    catalog: SchemaCatalog, class_name: str, code_path: str
) -> None:
    """Use explicit str class/path to reject manufactured associations; return None."""
    result = UiCallbackAnalyzer().analyze(
        capture(
            catalog, (("src/a.xaml", markup(class_name=class_name)), (code_path, CODE))
        )
    )
    assert details(result)[-1]["match_status"] == "missing-class"


@pytest.mark.parametrize("ending,reported", (("\n", 3), ("\r\n", 3), ("\r", 1)))
def test_repeated_and_multiline_elements_have_stable_containing_anchors(
    catalog: SchemaCatalog, ending: str, reported: int
) -> None:
    """Use str ending/int parser anchor and SchemaCatalog; retain bytes/occurrences.

    Returns None. These are accepted parser-reported containing-element anchors,
    not opening-tag positions: multiline tags and bare CR have limited precision.
    """
    data = markup(f'{ending}<Button{ending} Click="OnClick"/><Button Click="OnClick"/>')
    result = UiCallbackAnalyzer().analyze(capture(catalog, (("src/a.xaml", data),)))
    # Same-line duplicate handlers retain distinct containing-element identities.
    assert len({item["finding_id"] for item in result.findings}) == 3
    assert cast("JsonObject", result.findings[1]["source"])["line_range"] == row(
        start=reported, end=reported
    )
    assert cast("JsonObject", result.findings[2]["source"])["line_range"] == row(
        start=reported, end=reported
    )
    # Parsing normalization must never replace the digest of original source bytes.
    assert all(
        cast("JsonObject", item["source"])["sha256"] == hashlib.sha256(data).hexdigest()
        for item in result.findings
    )


def test_distinct_single_line_element_retains_its_reported_line(
    catalog: SchemaCatalog,
) -> None:
    """Use a separate LF-delimited element as an anchor control; return None."""
    data = markup('\n<Grid>\n<Button Click="OnClick"/>\n</Grid>')
    result = UiCallbackAnalyzer().analyze(capture(catalog, (("src/a.xaml", data),)))
    assert cast("JsonObject", result.findings[1]["source"])["line_range"] == row(
        start=3, end=3
    )


@pytest.mark.parametrize(
    "encoding,bom", (("utf-8", codecs.BOM_UTF8), ("utf-16-le", codecs.BOM_UTF16_LE))
)
def test_xml_encoding_keeps_original_source_digest(
    catalog: SchemaCatalog, encoding: str, bom: bytes
) -> None:
    """For str encoding and bytes BOM, preserve captured source digest; return None."""
    data = bom + markup().decode().encode(encoding)
    result = UiCallbackAnalyzer().analyze(capture(catalog, (("src/a.xaml", data),)))
    assert len(result.findings) == 2
    assert (
        cast("JsonObject", result.findings[0]["source"])["sha256"]
        == hashlib.sha256(data).hexdigest()
    )


def test_unavailable_excluded_and_unrelated_inputs_do_not_leak_values(
    catalog: SchemaCatalog,
) -> None:
    """Model unavailable/excluded inputs with SchemaCatalog; return None, no I/O."""
    inputs = capture(
        catalog, (("src/a.xaml", markup()), ("src/other.txt", b"SECRET")), pinned=False
    )
    inputs = replace(
        inputs,
        inputs=inputs.inputs
        + (
            InventoryInput(path="src/b.xaml", status="unreadable", rationale="SECRET"),
            InventoryInput(path="src/a.xaml.cs", status="excluded", rationale="SECRET"),
            InventoryInput(path="src/c.xaml", status="excluded", rationale="SECRET"),
        ),
    )
    result = UiCallbackAnalyzer().analyze(inputs)
    assert len(result.components) == 1 and "SECRET" not in rendered(result)
    # Read failures, absent pins and binding limitations retain separate meanings.
    assert {item["code"] for item in result.diagnostics} == {
        "input-unreadable",
        "ui-binding-unresolved",
        "source-revision-unverified",
    }
    # Working bytes alone cannot raise confidence to immutable source proof.
    assert all(item["confidence"] == "low" for item in result.findings)


@pytest.mark.parametrize("code", (None, b"\xff", rb"class View { void \uZZZZ() {} }"))
def test_code_failures_preserve_declarations_without_false_binding(
    catalog: SchemaCatalog, code: bytes | None
) -> None:
    """Use bytes/None code failure and fixed diagnostics; return None without I/O."""
    payloads = (("src/a.xaml", markup()),) + (
        (("src/a.xaml.cs", code),) if code is not None else ()
    )
    inputs = capture(catalog, payloads)
    # An unreadable file has no fabricated bytes; encoding failures retain theirs.
    if code is None:
        inputs = replace(
            inputs,
            inputs=inputs.inputs
            + (
                InventoryInput(
                    path="src/a.xaml.cs", status="unreadable", rationale="SECRET"
                ),
            ),
        )
    result = UiCallbackAnalyzer().analyze(inputs)
    # Failed code inspection blocks completeness while preserving literal XML facts.
    assert len(result.findings) == 2 and any(
        item["blocking"] for item in result.diagnostics
    )
    # No failed parse contributes partial class/member or code provenance claims.
    assert all(item["code_candidate"] is None for item in details(result))
    assert "SECRET" not in rendered(result)


def test_same_capture_order_has_deterministic_results_and_no_source_reads(
    catalog: SchemaCatalog, monkeypatch: MonkeyPatch
) -> None:
    """Reverse isolated captured inputs; forbid filesystem reads; return None."""
    from pathlib import Path

    def forbidden(*args: object, **kwargs: object) -> None:
        """Raise on any filesystem read using object args; no result or I/O."""
        raise AssertionError("UI adapter must inspect retained memory only")

    inputs = capture(
        catalog,
        (("src/b.xaml", markup()), ("src/a.xaml", markup()), ("src/a.xaml.cs", CODE)),
    )
    monkeypatch.setattr(Path, "read_bytes", forbidden)
    result = UiCallbackAnalyzer().analyze(inputs)
    assert result == UiCallbackAnalyzer().analyze(
        replace(inputs, inputs=tuple(reversed(inputs.inputs)))
    )
    assert result.findings and "SECRET" not in rendered(result)
