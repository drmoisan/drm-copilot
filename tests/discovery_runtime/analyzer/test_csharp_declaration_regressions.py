"""Retain declaration-context and aggregate-work regressions from P4-T3 review."""

from __future__ import annotations

from typing import TYPE_CHECKING

import pytest
from drm_copilot_discovery.analyzer.csharp_declarations import declaration_candidates
from drm_copilot_discovery.analyzer.csharp_tokens import SourceScanError
from drm_copilot_discovery.analyzer.dotnet_inventory import CSharpDeclarationAnalyzer

from tests.discovery_runtime.analyzer.test_dotnet_projects import capture, properties
from tests.discovery_runtime.analyzer.test_dotnet_projects import catalog as catalog

if TYPE_CHECKING:
    from drm_copilot_discovery.catalog import SchemaCatalog


@pytest.mark.parametrize(
    "source",
    [
        "class C { void Run(object[] items) { foreach (var record in items) { } } }",
        "class C { void Run() { System.Action a = delegate { Work(); }; } "
        "void Work() {} }",
        "class C { void Run() { System.Action a = delegate() { Work(); }; } "
        "void Work() {} }",
        "class C { void Run() { System.Action<int> a = delegate(int item) "
        "{ Work(); }; } void Work() {} }",
        "class C { void Run() { record value = default; } }",
        "class C { void Run(record value) {} }",
        "class C { record value = default; }",
        "class C { delegate*<int, void> callback; }",
    ],
)
def test_executable_contexts_cannot_project_named_declarations(
    catalog: SchemaCatalog, source: str
) -> None:
    """SchemaCatalog/str source exercise exact review inputs and adjacent contexts.

    Return None. Pure assertions require both lexical and pinned v2 projections
    to contain only the real class, preserving its detected/high classification.
    """
    values = declaration_candidates("src/a.cs", source)
    # Executable contextual words must not introduce an additional named type.
    assert [
        (value.detection_kind, value.symbol)
        for value in values
        if value.detection_kind in {"type", "delegate"}
    ] == [("type", "C")]
    result = CSharpDeclarationAnalyzer().analyze(
        capture(catalog, (("src/a.cs", source.encode("utf-8")),))
    )
    # Projection cannot promote an anonymous body or variable into a detected fact.
    assert [
        (
            item["kind"],
            properties(item)["symbol"],
            item["classification"],
            item["confidence"],
        )
        for item in result.findings
        if item["kind"] in {"type", "delegate"}
    ] == [("type", "C", "detected", "high")]


@pytest.mark.parametrize(
    ("source", "symbol", "kind"),
    [
        ("record R;", "R", "record"),
        ("record R(int Value);", "R", "record"),
        ("[Tag] public partial record R<T> where T : class {}", "R", "record"),
        ("record class R : Base {}", "R", "record"),
        ("public readonly record struct R<T>(T Value);", "R", "record_struct"),
        ("class Outer { public record R; }", "R", "record"),
        ("namespace Scope; record R {}", "R", "record"),
        ("delegate void Handler();", "Handler", "delegate"),
        ("public delegate T Handler<T>(T value);", "Handler", "delegate"),
    ],
)
def test_context_guards_preserve_actual_record_and_named_delegate_forms(
    source: str, symbol: str, kind: str
) -> None:
    """str source/symbol/kind retain legitimate declaration forms and literal names.

    Return None; immutable lexical assertions have no I/O or shared-state effects.
    """
    values = declaration_candidates("src/a.cs", source, include_members=False)
    # Match the requested declaration even when a real enclosing type also exists.
    assert any(value.symbol == symbol and value.symbol_kind == kind for value in values)


@pytest.mark.parametrize("repetitions", [64, 128, 256])
@pytest.mark.parametrize("shape", ["generic", "event-prefix", "delegate-prefix"])
def test_repeated_prefixes_fail_at_the_shared_work_bound_without_partial_claims(
    catalog: SchemaCatalog, repetitions: int, shape: str
) -> None:
    """SchemaCatalog/int repetitions/str shape select bounded adversarial inputs.

    Return None. Exact public error codes and empty v2 output prove fail-closed
    behavior without timing assumptions, large payloads or external effects.
    """
    # Each family forces overlapping suffix scans while remaining a small input.
    if shape == "generic":
        source = "class T<" * repetitions + "int" + ">" * repetitions
    else:
        keyword = "event" if shape == "event-prefix" else "delegate"
        source = (keyword + " Action ") * repetitions + ";"
    source = "class Valid {} " + source
    with pytest.raises(SourceScanError) as error:
        declaration_candidates("src/a.cs", source, include_members=False)
    assert error.value.code == "source-work-limit"
    result = CSharpDeclarationAnalyzer().analyze(
        capture(catalog, (("src/a.cs", source.encode("utf-8")),))
    )
    assert result.components == result.findings == result.relationships == ()
    # Even an earlier valid declaration cannot survive a file-level work failure.
    assert [item["code"] for item in result.diagnostics] == ["source-work-limit"]
