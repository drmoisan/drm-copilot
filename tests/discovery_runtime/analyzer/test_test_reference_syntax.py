"""Verify finite reference grammars, public capacities and bounded lexical work."""

from __future__ import annotations

from typing import TYPE_CHECKING, cast

import pytest
from drm_copilot_discovery.analyzer import test_reference_syntax
from drm_copilot_discovery.analyzer import test_references as implementation
from drm_copilot_discovery.analyzer.csharp_tokens import (
    SourceScanError,
    Token,
    tokenize_csharp,
)
from drm_copilot_discovery.analyzer.source_text import strip_comments_and_strings
from drm_copilot_discovery.analyzer.test_reference_syntax import (
    project_reference_sites,
    type_mentions,
)
from drm_copilot_discovery.analyzer.test_references import (
    TestReferenceAnalyzer as ReferenceAnalyzer,
)
from drm_copilot_discovery.snapshot_io import within_roots

from tests.discovery_runtime.analyzer.test_dotnet_projects import catalog as catalog
from tests.discovery_runtime.analyzer.test_test_references import inputs, serialized

if TYPE_CHECKING:
    from collections.abc import Iterator

    from drm_copilot_discovery.catalog import SchemaCatalog


@pytest.mark.parametrize(
    "text",
    [
        "",
        "Widget + value",
        "Widget variable;",
        "Widget.Run();",
        "WidgetTests();",
        "new WidgetTests()",
        "class Widget {}",
        "using A = Widget; new A();",
        "new()",
        "new Widget {}",
        "new Alias::Widget()",
        "new Namespace.",
        "typeof Widget",
        "default",
        "sizeof(",
        "new",
        "new .Widget()",
        "holder.new Widget()",
        "holder?.new Widget()",
        "holder::new Widget()",
        '"new Widget()"',
        "// new Widget()\n",
        "/* typeof(Widget) */",
        '$"{new Widget()}"',
        '"""new Widget()"""',
        "#if new Widget()\n#endif",
    ],
)
def test_unselected_contexts_and_masked_text_do_not_imply_relevance(text: str) -> None:
    """Str text supplies declaration, unrelated, malformed-context or masked syntax.

    Returns None; no inferred relationship is fabricated from these forms.
    """
    tokens = tokenize_csharp(strip_comments_and_strings(text))
    assert not tuple(type_mentions(tokens, {"Widget": 1}))


@pytest.mark.parametrize(
    "xml",
    [
        '<Project><Target><ItemGroup><ProjectReference Include="x"/>'
        "</ItemGroup></Target></Project>",
        '<Project><ProjectReference Include="x"/></Project>',
        '<Project><ItemGroup><Other Include="x"/></ItemGroup></Project>',
        '<Project><ItemGroup><ProjectReference xmlns="urn:other" Include="x"/>'
        "</ItemGroup></Project>",
    ],
)
def test_opaque_or_unselected_project_contexts_have_no_edges(xml: str) -> None:
    """Str xml contains foreign/deferred/unrelated elements; returns None.

    Assert no evaluation or unrelated metadata is inferred; no effects occur.
    """
    assert not tuple(project_reference_sites(xml.encode(), max_bytes=1024, limit=100))


@pytest.mark.parametrize("argument", ["max_bytes", "limit"])
@pytest.mark.parametrize("invalid", [True, 1.5, 0, -1, 67108865])
def test_project_limits_are_exact_integers_before_parsing(
    argument: str, invalid: object, monkeypatch: pytest.MonkeyPatch
) -> None:
    """Str argument/object invalid select invalid capacity; monkeypatch is isolated.

    Returns None; invalid capacities fail before parser allocation.
    """

    def forbidden(*args: object, **kwargs: object) -> object:
        """Reject object args/kwargs; return never and raise AssertionError.

        No I/O or mutation; invalid capacities must fail before parsing.
        """
        raise AssertionError("Parser must not run")

    monkeypatch.setattr(test_reference_syntax, "parse_xml", forbidden)
    arguments = {"max_bytes": 1024, "limit": 100}
    arguments[argument] = cast("int", invalid)
    with pytest.raises(ValueError, match="integer"):
        tuple(project_reference_sites(b"<Project/>", **arguments))


class CountedTokens:
    """Instrument lookahead without timing or allocating large fixtures.

    tokens are immutable input; reads counts indexed access. Optional length
    models rejected capacity before traversal. Instances never share state.
    """

    def __init__(self, tokens: tuple[Token, ...], length: int | None = None) -> None:
        """Retain tokens/optional reported int length; return None; local only."""
        self.tokens = tokens
        self.length = len(tokens) if length is None else length
        self.reads = 0

    def __len__(self) -> int:
        """Return the declared int length; no effects or failures."""
        return self.length

    def __getitem__(self, index: int) -> Token:
        """Return Token at int index; count access or propagate IndexError; local."""
        self.reads += 1
        return self.tokens[index]

    def __iter__(self) -> Iterator[Token]:
        """Return a deterministic Token iterator; no mutation or I/O."""
        return iter(self.tokens)


@pytest.mark.parametrize("count", [1, 8, 32])
def test_qualified_and_overlapping_lookahead_has_linear_counted_work(
    count: int,
) -> None:
    """Int count scales small qualification/context fixtures; returns None.

    Indexed access, not elapsed time, bounds aggregate lookahead across markers.
    """
    tokens = tokenize_csharp(
        ("new " + "new." * count + "Widget(); typeof(Widget); ") * count
    )
    counted = CountedTokens(tokens)
    result = tuple(type_mentions(cast("tuple[Token, ...]", counted), {"Widget": 1}))
    assert len(result) == 2 * count and counted.reads <= 16 * len(tokens)


def test_oversized_token_population_fails_before_access() -> None:
    """A length sentinel proves rejection before prohibited allocation.

    Returns None; no large sequence, traversal, source reads or timing are used.
    """
    counted = CountedTokens((), length=100001)
    with pytest.raises(SourceScanError, match="Mention input limit"):
        tuple(type_mentions(cast("tuple[Token, ...]", counted), {}))
    assert counted.reads == 0


def test_project_line_and_ordinal_preserve_duplicate_declarations() -> None:
    """Repeated declarations retain exact secure-parser anchors; returns None.

    Attributes remain literal without project target evaluation or I/O.
    """
    content = (
        b'<Project>\r\n<ItemGroup><ProjectReference Include="x"/>'
        b'<ProjectReference Include="x"/></ItemGroup></Project>'
    )
    sites = tuple(project_reference_sites(content, max_bytes=1024, limit=100))
    assert sites == (
        ("x", 2, 2, "include", "literal", False),
        ("x", 2, 3, "include", "literal", False),
    )


@pytest.mark.parametrize("operation", ["Include", "Update", "Remove"])
@pytest.mark.parametrize(
    "namespace", ["", ' xmlns="http://schemas.microsoft.com/developer/msbuild/2003"']
)
@pytest.mark.parametrize("condition", ["root", "group", "reference", "none"])
def test_project_operations_keep_conditions_and_targets_unevaluated(
    operation: str, namespace: str, condition: str
) -> None:
    """Str operation/namespace/condition select supported inert project declarations.

    Returns None; raw condition sentinel never enters any complete output family.
    """
    attribute = ' Condition="CONDITION_SENTINEL"'
    # Place exactly one unevaluated condition at the requested declaration level.
    xml = (
        f'<Project{namespace}{attribute if condition == "root" else ""}>'
        f'<ItemGroup{attribute if condition == "group" else ""}>'
        f'<ProjectReference {operation}="../src/app.csproj"'
        f'{attribute if condition == "reference" else ""}/></ItemGroup></Project>'
    )
    sites = tuple(project_reference_sites(xml.encode(), max_bytes=1024, limit=100))
    assert len(sites) == 1
    assert sites[0][0] == "../src/app.csproj" and sites[0][3] == operation.lower()
    assert sites[0][4] == "literal" and sites[0][5] == (condition != "none")
    assert "CONDITION_SENTINEL" not in repr(sites)


@pytest.mark.parametrize(
    "xml",
    [
        "<Other/>",
        '<Project xmlns="urn:other"/>',
        "<Project><ItemGroup><ProjectReference/></ItemGroup></Project>",
        '<Project><ItemGroup><ProjectReference Include=" "/></ItemGroup></Project>',
        '<Project><ItemGroup><ProjectReference Include="x" Update="y"/>'
        "</ItemGroup></Project>",
        '<!DOCTYPE Project [<!ENTITY x "VALUE_SENTINEL">]><Project/>',
        "<Project VALUE_SENTINEL",
        "<Project>VALUE_SENTINEL",
    ],
)
def test_malformed_selected_project_is_redacted_and_has_no_partial_claims(
    catalog: SchemaCatalog, xml: str
) -> None:
    """Str xml supplies malformed or prohibited syntax; returns None.

    Complete diagnostics remain fixed and no input snippets are emitted.
    """
    result = ReferenceAnalyzer().analyze(
        inputs(catalog, (("tests/a.csproj", xml.encode()),))
    )
    assert not result.components and not result.findings and not result.relationships
    assert result.diagnostics[0][
        "blocking"
    ] is True and "VALUE_SENTINEL" not in serialized(result)


@pytest.mark.parametrize(
    "count,budget,calls,blocked",
    [(1, 5000, 2, False), (2, 5000, 2, True), (1, 1000, 0, True)],
)
def test_scope_classification_is_once_per_input_and_reserved_before_matching(
    catalog: SchemaCatalog,
    monkeypatch: pytest.MonkeyPatch,
    count: int,
    budget: int,
    calls: int,
    blocked: bool,
) -> None:
    """Typed catalog/monkeypatch and int limits measure small root-comparison work.

    bool blocked selects the expected boundary. Returns None; intercepted calls
    prove prospective reservation and no second classification pass or I/O.
    """
    matcher = within_roots
    visits: list[str] = []

    def counted(path: str, roots: tuple[str, ...]) -> bool:
        """Count str path classification against typed roots; return real bool.

        Mutates only the local visits list; invalid paths retain ValueError.
        """
        visits.append(path)
        return matcher(path, roots)

    # Distinct long selectors exercise comparison costs with a small population.
    roots = [f"root{index}" + "x" * 100 for index in range(20)]
    # Unrelated empty inputs avoid output budgets obscuring the scope boundary.
    payloads = tuple((f"other/{index}.cs", b"") for index in range(count))
    value = inputs(
        catalog, payloads, production_roots=roots, limits={"document_bytes": budget}
    )
    monkeypatch.setattr(implementation, "within_roots", counted)
    result = ReferenceAnalyzer().analyze(value)
    assert len(visits) == calls and not result.components and not result.findings
    assert not result.relationships
    assert bool(result.diagnostics) is blocked
    if blocked:
        assert result.diagnostics[0]["code"] == "analysis-work-limit"


def test_selected_input_count_is_reserved_before_projection(
    catalog: SchemaCatalog, monkeypatch: pytest.MonkeyPatch
) -> None:
    """Catalog/isolated monkeypatch establish two files under a one-record cap.

    Returns None; selection rejects before parsing or projecting partial output.
    """

    def forbidden(*args: object, **kwargs: object) -> None:
        """Reject object call arguments; return never, raise AssertionError.

        No effects; the fake proves selected-input reservation precedes parsing.
        """
        raise AssertionError("Selected input reservation must precede parsing")

    value = inputs(
        catalog,
        (("tests/a.cs", b""), ("tests/b.cs", b"")),
        limits={"artifact_records": 1},
    )
    monkeypatch.setattr(ReferenceAnalyzer, "_file", forbidden)
    result = ReferenceAnalyzer().analyze(value)
    assert not result.components and not result.findings and not result.relationships
    assert result.diagnostics[0]["code"] == "analysis-work-limit"
