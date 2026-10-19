"""Verify multiline lexical declarations, inferred members and exact source bytes."""

from __future__ import annotations

import hashlib
from dataclasses import replace
from typing import TYPE_CHECKING, cast

import pytest
from drm_copilot_discovery.analyzer.csharp_declarations import declaration_candidates
from drm_copilot_discovery.analyzer.csharp_tokens import SourceScanError
from drm_copilot_discovery.analyzer.dotnet_inventory import (
    CSharpDeclarationAnalyzer,
    DotnetInventoryAnalyzer,
    classify_text,
)
from drm_copilot_discovery.analyzer.emitter import inventory_result
from drm_copilot_discovery.analyzer.findings import row
from drm_copilot_discovery.analyzer.inventory import AnalyzerError
from drm_copilot_discovery.analyzer.models import (
    AnalyzerContext,
    ClassifyResult,
    InventoryInput,
)
from drm_copilot_discovery.analyzer.pipeline import RealAnalyzerFileSystem
from drm_copilot_discovery.analyzer.source_text import DetectionResult, TextParseResult

from scripts.dev_tools.discovery.analyzer.dotnet_inventory import (
    DotnetInventoryAnalyzer as LegacyAnalyzer,
)
from scripts.dev_tools.discovery.analyzer.dotnet_inventory import (
    classify_text as legacy_classify,
)
from tests.discovery_runtime.analyzer.test_dotnet_projects import capture, properties
from tests.discovery_runtime.analyzer.test_dotnet_projects import catalog as catalog

if TYPE_CHECKING:
    from pathlib import Path

    from drm_copilot_discovery.catalog import SchemaCatalog
    from drm_copilot_discovery.models import JsonObject


@pytest.mark.parametrize("newline", ["\n", "\r\n", "\r"])
def test_multiline_unicode_declarations_have_physical_anchors(newline: str) -> None:
    """str newline selects physical boundaries; declarations retain literal names.
    Returns None; assertions check isolated data without external effects."""
    text = newline.join(
        [
            "namespace",
            "Δ.Ω;",
            "public partial",
            "class",
            "Café<T, U>",
            "{",
            "public event",
            "Action<T>",
            "Changed;",
            "public delegate",
            "void",
            "Handler<T>(T item);",
            "}",
        ]
    )
    values = declaration_candidates("src/a.cs", text, include_members=False)
    # Compare observed names and physical anchors across multiline declarations.
    assert [(value.detection_kind, value.symbol, value.line) for value in values] == [
        ("namespace", "Δ.Ω", 1),
        ("type", "Café", 4),
        ("event_declaration", "Changed", 7),
        ("delegate", "Handler", 10),
    ]
    assert dict(values[1].extra)["generic"] == 2
    assert dict(values[1].extra)["end_line"] == 5


@pytest.mark.parametrize("name", ["Δ", "e\u0301", "@class", r"\u0394", r"\U00010400"])
def test_literal_identifier_spelling_survives_declaration(name: str) -> None:
    """str name is retained exactly rather than normalized to semantic identity.
    Returns None; assertions check isolated data without external effects."""
    values = declaration_candidates("a.cs", f"class {name} {{}}")
    assert values[0].symbol == name


def test_same_line_nested_partial_and_record_forms_remain_distinct() -> None:
    """All inline declaration sites survive and record keywords do not duplicate.
    Returns None; assertions check isolated data without external effects."""
    text = (
        "partial class A { class B {} } partial class A {} "
        "record class R(); record struct S();"
    )
    values = declaration_candidates("a.cs", text, include_members=False)
    # Record keyword combinations must yield one observation per source site.
    assert [(value.symbol, value.symbol_kind) for value in values] == [
        ("A", "class"),
        ("B", "class"),
        ("A", "class"),
        ("R", "record"),
        ("S", "record_struct"),
    ]
    # Repeated partial names remain separate observations through their offsets.
    assert len({dict(value.extra)["offset"] for value in values}) == 5


def test_direct_members_exclude_method_locals_and_accessor_bodies() -> None:
    """Only directly enclosed member prefixes become unbound member candidates.
    Returns None; assertions check isolated data without external effects."""
    source = """class Device {
        private int count;
        public Device() { int local = 1; }
        public string Name { get { var hidden = 2; return null; } }
        public void Run(int value) { void Nested() {} int local = 1; }
        public int Size => count;
        class NestedType { public int Inner; }
    }"""
    # Select inferred members to exclude declarations with different semantics.
    members = [
        value
        for value in declaration_candidates("a.cs", source)
        if value.detection_kind == "member"
    ]
    # Nested locals/accessors must not appear among directly enclosed members.
    assert {(value.symbol, value.symbol_kind) for value in members} == {
        ("count", "field"),
        ("Device", "constructor"),
        ("Name", "property"),
        ("Run", "method"),
        ("Size", "property"),
        ("Inner", "field"),
    }
    # Lexical enclosure never establishes compiler binding.
    assert all(dict(value.extra)["binding"] == "unresolved" for value in members)
    # The nested type provides the local lexical owner without qualification.
    assert (
        dict(next(value for value in members if value.symbol == "Inner").extra)[
            "declaring_type"
        ]
        == "NestedType"
    )


@pytest.mark.parametrize(
    "source",
    [
        "",
        "namespace ;",
        "class ;",
        "event ;",
        "delegate (int a) {};",
        "var item = object.class;",
        "where T : class",
        "record;",
        "event Action",
        "delegate* ptr;",
        "}",
    ],
)
def test_non_declaration_fragments_do_not_invent_names(source: str) -> None:
    """Incomplete str source produces no invented declaration; assertions are pure.
    Returns None; assertions check isolated data without external effects."""
    assert declaration_candidates("a.cs", source) == ()


def test_unterminated_generic_is_an_explicit_diagnostic_input() -> None:
    """Broken generic text fails explicitly rather than claiming its arity.
    Returns None; assertions check isolated data without external effects."""
    with pytest.raises(SourceScanError) as error:
        declaration_candidates("a.cs", "class Broken<T")
    assert error.value.code == "source-declaration"


def test_attribute_strings_raw_strings_and_directives_do_not_create_declarations() -> (
    None
):
    """Masked literals and directive text cannot create false source facts.
    Returns None; assertions check isolated data without external effects."""
    text = (
        '#region class Fake\n[A("class Hidden")] '
        'class Real { string s = """class Raw {}"""; }'
    )
    # Only the declaration outside masked literals and directives may survive.
    assert [
        value.symbol
        for value in declaration_candidates("a.cs", text, include_members=False)
    ] == ["Real"]


def test_v2_schema_provenance_and_separate_inference(catalog: SchemaCatalog) -> None:
    """SchemaCatalog validates rows with exact hashes and honest candidate statuses.
    Returns None; assertions check isolated data without external effects."""
    payload = (
        b"#if MODE\r\nclass First { public int Count; }\r\n"
        b"#else\r\nclass Second {}\r\n#endif"
    )
    inputs = capture(catalog, (("src/a.cs", payload),))
    result = CSharpDeclarationAnalyzer().analyze(inputs)
    # Separate observed declaration syntax from inferred member interpretation.
    types = [item for item in result.findings if item["kind"] == "type"]
    # Select members independently so their confidence contract is explicit.
    members = [item for item in result.findings if item["kind"] == "member"]
    # Inactive textual branches are retained without asserting activation.
    assert {properties(item)["symbol"] for item in types} == {"First", "Second"}
    # Matched immutable bytes support confidence in syntax observations only.
    assert all(
        item["classification"] == "detected" and item["confidence"] == "high"
        for item in types
    )
    assert (
        members[0]["classification"] == "inferred"
        and members[0]["confidence"] == "medium"
    )
    # Both binding and preprocessing limitations must remain actionable.
    assert {item["code"] for item in result.diagnostics} == {
        "compiler-binding-not-performed",
        "preprocessing-not-evaluated",
    }
    # Every emitted source anchor must use the original captured payload hash.
    assert all(
        cast("JsonObject", item["source"])["sha256"]
        == hashlib.sha256(payload).hexdigest()
        for item in result.findings
    )
    document = inventory_result(
        inputs,
        (result,),
        analyzer_ids=("csharp-symbols",),
        timestamp="2026-10-19T00:00:00Z",
        author_or_agent=row(kind="tool", id="fixture"),
        catalog=catalog,
    )
    assert document.document["findings"] == result.findings
    assert document.ledger_components[0]["inspection_status"] == "uninspected"


@pytest.mark.parametrize("pinned", [False, True])
def test_missing_or_mismatched_revision_cannot_verify_lexical_rows(
    catalog: SchemaCatalog, pinned: bool
) -> None:
    """catalog/pinned select absent/different bytes; claims retain low confidence.
    Returns None; assertions check isolated data without external effects."""
    inputs = capture(catalog, (("src/a.cs", b"class A {}"),), pinned=pinned)
    # Replace only immutable Git bytes to model a mismatched source revision.
    inputs = replace(
        inputs,
        repository_files=tuple(
            replace(item, content=b"different") for item in inputs.repository_files
        ),
    )
    result = CSharpDeclarationAnalyzer().analyze(inputs)
    # Missing provenance downgrades every dependent claim, including components.
    assert all(
        item["confidence"] == "low" for item in result.components + result.findings
    )
    # The downgraded claim must also carry a blocking provenance finding.
    assert any(
        item["code"] == "source-revision-unverified" and item["blocking"] is True
        for item in result.diagnostics
    )


def test_excluded_unreadable_and_non_source_inputs_stay_distinct(
    catalog: SchemaCatalog,
) -> None:
    """SchemaCatalog builds no false source bytes or claims for omitted input.
    Returns None; assertions check isolated data without external effects."""
    inputs = capture(catalog, (("src/a.txt", b"class Trap {}"),))
    inputs = replace(
        inputs,
        inputs=inputs.inputs
        + (
            InventoryInput(
                path="src/omit.cs", status="excluded", rationale="Excluded."
            ),
            InventoryInput(
                path="src/blocked.cs", status="unreadable", rationale="Denied."
            ),
        ),
    )
    result = CSharpDeclarationAnalyzer().analyze(inputs)
    assert result.components == result.findings == ()
    # Omissions must not create rows; unreadable paths retain the original reason.
    assert [(item["code"], item["message"]) for item in result.diagnostics] == [
        ("input-unreadable", "Denied.")
    ]


@pytest.mark.parametrize(
    ("payload", "limit", "code"),
    [
        (b"class A {}", 2, "analysis-limit"),
        (b"class A<T", 100, "source-declaration"),
        (b"\xff", 100, "source-encoding"),
    ],
)
def test_malformed_or_over_budget_inputs_fail_without_partial_claims(
    catalog: SchemaCatalog, payload: bytes, limit: int, code: str
) -> None:
    """catalog/payload/limit/code select deterministic blocking failure semantics.
    Returns None; assertions check isolated data without external effects."""
    result = CSharpDeclarationAnalyzer().analyze(
        capture(catalog, (("src/a.cs", payload),), records=limit)
    )
    assert result.components == result.findings == ()
    # The precise failure code distinguishes malformed input from allocation limits.
    assert [item["code"] for item in result.diagnostics] == [code]


def test_byte_and_aggregate_limits_are_independent(catalog: SchemaCatalog) -> None:
    """SchemaCatalog supplies independent byte and complete-result limits.
    Returns None; assertions check isolated data without external effects."""
    oversized = CSharpDeclarationAnalyzer().analyze(
        capture(catalog, (("src/a.cs", b"class A {}"),), max_bytes=1)
    )
    assert oversized.diagnostics[0]["code"] == "source-limit"
    inputs = capture(catalog, (), records=1)
    inputs = replace(
        inputs,
        inputs=(
            InventoryInput(
                path="src/a.cs", status="unreadable", rationale="Unavailable."
            ),
            InventoryInput(
                path="src/b.cs", status="unreadable", rationale="Unavailable."
            ),
        ),
    )
    assert (
        CSharpDeclarationAnalyzer().analyze(inputs).diagnostics[0]["code"]
        == "analysis-limit"
    )


def test_repeated_v2_sites_and_calls_have_stable_unique_ids(
    catalog: SchemaCatalog,
) -> None:
    """SchemaCatalog supplies duplicate sites with distinct source offsets/IDs.
    Returns None; assertions check isolated data without external effects."""
    inputs = capture(catalog, (("src/A.CS", b"partial class A {} partial class A {}"),))
    first = CSharpDeclarationAnalyzer().analyze(inputs)
    second = CSharpDeclarationAnalyzer().analyze(inputs)
    assert first == second and len(first.findings) == 2
    # Same-line duplicate names remain unique while repeated calls stay stable.
    assert len({item["finding_id"] for item in first.findings}) == 2


def _legacy_context(root: Path) -> AnalyzerContext:
    """Return synthetic context for Path root without I/O or external configuration."""
    return AnalyzerContext(
        root, (), (), root / "out", root / "schema.json", "2026-10-19T00:00:00Z"
    )


def test_legacy_reexports_and_text_only_carriers_keep_identity() -> None:
    """Legacy imports preserve object identity and public positional constructors.
    Returns None; assertions check isolated data without external effects."""
    assert (
        LegacyAnalyzer is DotnetInventoryAnalyzer and legacy_classify is classify_text
    )
    parsed = TextParseResult(("a.cs",), (("a.cs", "class A {}"),))
    result = DotnetInventoryAnalyzer().classify(parsed)
    assert isinstance(result, DetectionResult) and result.detections[0].symbol == "A"
    assert TextParseResult(()) == TextParseResult((), ())
    assert DetectionResult(()) == DetectionResult((), ())


def test_legacy_mapping_uses_parsed_payload_after_source_changes(
    mem_fs_path: Path, monkeypatch: pytest.MonkeyPatch
) -> None:
    """In-memory Path/MonkeyPatch prove parsing reads once and mapping never rereads.
    Returns None; assertions check isolated data without external effects."""
    original = "class Ω {}".encode("utf-16")
    path = mem_fs_path / "a.cs"
    path.write_bytes(original)
    analyzer = DotnetInventoryAnalyzer()
    parsed = analyzer.parse(_legacy_context(mem_fs_path))
    path.write_bytes(b"class Different {}")

    def reject_read(self: RealAnalyzerFileSystem, file: Path) -> bytes:
        """Fail any seam read using self/file; raises AssertionError, no I/O."""
        raise AssertionError(f"Unexpected reread: {file}")

    monkeypatch.setattr(RealAnalyzerFileSystem, "read_bytes", reject_read)
    records = analyzer.map(analyzer.classify(parsed))
    assert records[0].content_hash == ("sha256", hashlib.sha256(original).hexdigest())
    assert dict(records[0].metadata)["symbol"] == "Ω"
    with pytest.raises(AnalyzerError, match="guarded v2"):
        analyzer.emit(records, RealAnalyzerFileSystem())


def test_legacy_wrong_context_and_unbound_carriers_fail_closed(
    mem_fs_path: Path,
) -> None:
    """In-memory Path permits a parse while unbound evidence remains rejected.
    Returns None; assertions check isolated data without external effects."""
    analyzer = DotnetInventoryAnalyzer()
    with pytest.raises(AnalyzerError, match="DetectionResult"):
        analyzer.map(ClassifyResult(()))
    with pytest.raises(AnalyzerError, match="parse must run"):
        analyzer.map(DetectionResult(()))
    analyzer.parse(_legacy_context(mem_fs_path))
    with pytest.raises(AnalyzerError, match="exact bytes"):
        analyzer.map(DetectionResult(()))


def test_legacy_decode_failure_clears_prior_context(mem_fs_path: Path) -> None:
    """In-memory Path carries invalid bytes; failure clears the prior run context.
    Returns None; assertions check isolated data without external effects."""
    path = mem_fs_path / "a.cs"
    path.write_bytes(b"class A {}")
    analyzer = DotnetInventoryAnalyzer()
    classified = analyzer.classify(analyzer.parse(_legacy_context(mem_fs_path)))
    path.write_bytes(b"\xff")
    with pytest.raises(AnalyzerError, match="valid UTF-8"):
        analyzer.parse(_legacy_context(mem_fs_path))
    with pytest.raises(AnalyzerError, match="parse must run"):
        analyzer.map(classified)


def test_attributed_generic_members_and_nonmembers_are_distinguished() -> None:
    """Attributes/generic parameters preserve names; incomplete prefixes stay absent.
    Returns None; assertions check isolated data without external effects."""
    text = (
        "class A { [Note(1)] public T Map<U>(U value) {} "
        "[Note] int Field = 1; public int; ; int *; }"
    )
    # Select only members so attributes/type declarations cannot mask a false name.
    members = [
        value
        for value in declaration_candidates("a.cs", text)
        if value.detection_kind == "member"
    ]
    # Generic suffixes belong to method parameters, not to the observed name.
    assert [(value.symbol, value.symbol_kind) for value in members] == [
        ("Map", "method"),
        ("Field", "field"),
    ]


@pytest.mark.parametrize(
    ("source", "arity"), [("class A<> {}", 0), ("class A<T, Generic<U,V>> {}", 2)]
)
def test_lexical_generic_arity_ignores_nested_commas(source: str, arity: int) -> None:
    """str source and int arity establish lexical counting without compiler validity.
    Returns None; assertions check isolated data without external effects."""
    value = declaration_candidates("a.cs", source)[0]
    assert dict(value.extra).get("generic", 0) == arity


def test_member_work_is_bounded_for_adversarial_prefixes() -> None:
    """Repeated unfinished signatures fail at the aggregate prefix work limit.
    Returns None; assertions check isolated data without external effects."""
    with pytest.raises(SourceScanError) as error:
        declaration_candidates("a.cs", "class A { int M " + "( " * 80)
    assert error.value.code == "source-work-limit"


def test_legacy_captured_detection_cannot_reference_an_uncaptured_path(
    mem_fs_path: Path,
) -> None:
    """In-memory Path captures one source; altered detection cannot fabricate a hash.
    Returns None; assertions check isolated data without external effects."""
    (mem_fs_path / "a.cs").write_bytes(b"class A {}")
    analyzer = DotnetInventoryAnalyzer()
    result = analyzer.classify(analyzer.parse(_legacy_context(mem_fs_path)))
    assert isinstance(result, DetectionResult)
    invalid = replace(
        result, detections=(replace(result.detections[0], path="missing.cs"),)
    )
    with pytest.raises(AnalyzerError, match="no captured source bytes"):
        analyzer.map(invalid)
