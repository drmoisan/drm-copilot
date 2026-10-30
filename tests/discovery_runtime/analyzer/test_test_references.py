"""Verify declared syntax and inferred test relevance without execution claims."""

from __future__ import annotations

import hashlib
from dataclasses import replace
from typing import TYPE_CHECKING, Literal, cast

import pytest
from drm_copilot_discovery.analyzer import test_references as implementation
from drm_copilot_discovery.analyzer.emitter import inventory_result
from drm_copilot_discovery.analyzer.findings import row
from drm_copilot_discovery.analyzer.models import (
    Analysis,
    InventoryCapture,
    InventoryInput,
)
from drm_copilot_discovery.analyzer.test_references import (
    TestReferenceAnalyzer as ReferenceAnalyzer,
)
from drm_copilot_discovery.models import JsonObject, canonical_json
from drm_copilot_discovery.repository_reader import RepositoryFile, RepositoryIdentity

from tests.discovery_runtime.analyzer.test_dotnet_projects import capture
from tests.discovery_runtime.analyzer.test_dotnet_projects import catalog as catalog
from tests.discovery_runtime.analyzer.test_repository import inventory_profile

if TYPE_CHECKING:
    from drm_copilot_discovery.catalog import SchemaCatalog


def inputs(
    catalog: SchemaCatalog, payloads: tuple[tuple[str, bytes], ...], **changes: object
) -> InventoryCapture:
    """Build isolated retained bytes with explicit test scope and profile changes.

    catalog/payloads supply SchemaCatalog and path/bytes pairs; changes override
    profile fields. Returns InventoryCapture or raises ProfileError; no I/O.
    """
    options: dict[str, object] = {
        "test_roots": ["tests"],
        "analyzers": {
            "enabled": ["test-references"],
            "options": {},
            "ignored_paths": [],
            "extension_result_manifests": [],
        },
    }
    options.update(changes)
    return replace(
        capture(catalog, payloads), profile=inventory_profile(catalog, **options)
    )


def analyze(
    catalog: SchemaCatalog, text: str, *, production: str = "class Widget {}"
) -> Analysis:
    """Return analysis of str production/test text with SchemaCatalog; memory only.

    Invalid synthetic configuration propagates; no shared state or files change.
    """
    return ReferenceAnalyzer().analyze(
        inputs(
            catalog, (("src/a.cs", production.encode()), ("tests/a.cs", text.encode()))
        )
    )


def detail(finding: JsonObject) -> JsonObject:
    """Return namespaced metadata from a typed finding; malformed rows raise.

    Returns JsonObject without mutation, source reads or side effects.
    """
    return cast(
        "JsonObject", cast("JsonObject", finding["extensions"])["drm.test-references"]
    )


def serialized(result: Analysis) -> str:
    """Serialize every Analysis family to inspect complete redaction; no I/O.

    Returns str; invalid internal JSON propagates rather than dropping a family.
    """
    return canonical_json(
        row(
            components=result.components,
            findings=result.findings,
            relationships=result.relationships,
            diagnostics=result.diagnostics,
        )
    ).decode()


@pytest.mark.parametrize("prefix", ["", "Namespace.", "global::Namespace."])
@pytest.mark.parametrize(
    "expression",
    [
        "new {name}()",
        "new {name}<int>()",
        "new {name}[2]",
        "typeof({name})",
        "default({name})",
        "sizeof({name})",
    ],
)
def test_explicit_type_contexts_remain_inferred(
    catalog: SchemaCatalog, prefix: str, expression: str
) -> None:
    """Str context/prefix selects a lexical match; catalog supplies immutable schemas.

    Returns None; assertions prove nullable unresolved relevance, never execution.
    """
    result = analyze(catalog, expression.format(name=prefix + "Widget"))
    assert len(result.relationships) == 1
    relation = result.relationships[0]
    assert (
        relation["classification"] == "inferred" and relation["to_component_id"] is None
    )
    assert (
        detail(relation)["binding"] == "unresolved"
        and detail(relation)["execution"] == "unverified"
    )
    assert detail(relation)["candidate_count"] == 1
    assert result.findings[0]["classification"] == "detected"


@pytest.mark.parametrize(
    "production",
    [
        "partial class Widget {} partial class Widget {}",
        "namespace A { class Widget {} } namespace B { class Widget {} }",
        "class Outer { class Widget<T> {} } class Widget {}",
    ],
)
def test_ambiguous_partial_nested_generic_names_never_bind(
    catalog: SchemaCatalog, production: str
) -> None:
    """Str production contains two same-spelled declarations; catalog is immutable.

    Returns None; one unresolved relation replaces a Cartesian candidate expansion.
    """
    result = analyze(catalog, "new Widget()", production=production)
    assert len(result.relationships) == 1
    assert detail(result.relationships[0])["candidate_count"] == 2
    assert detail(result.relationships[0])["ambiguity"] == "multiple-declarations"
    assert result.relationships[0]["to_component_id"] is None


def test_alias_shadowing_and_preprocessing_are_explicitly_unbound(
    catalog: SchemaCatalog,
) -> None:
    """SchemaCatalog supports inert aliases/inactive branches without evaluation.

    Returns None; observed same-spelling type contexts retain unresolved binding.
    """
    text = (
        "using Widget = Other.Type; class Test { class Widget {} }\n"
        "#if FALSE\nnew Widget();\n#endif"
    )
    result = analyze(catalog, text)
    assert (
        len(result.relationships) == 1
        and detail(result.relationships[0])["binding"] == "unresolved"
    )


@pytest.mark.parametrize(
    "name", ["Widget", "ÅValue", "𐐀Type", "@Widget", r"\u0057idget"]
)
def test_unicode_literal_spelling_and_repeated_physical_offsets(
    catalog: SchemaCatalog, name: str
) -> None:
    """Str name selects literal Unicode/verbatim/escaped spelling; no normalization.

    Returns None; CRLF and same-line repetition retain exact positions and IDs.
    """
    text = "// inert\u2028separator\r\nnew " + name + "(); new " + name + "();"
    result = analyze(catalog, text, production="class " + name + " {}")
    assert len(result.relationships) == 2
    first, second = result.relationships
    assert detail(first)["offset"] == text.index(name)
    assert detail(second)["offset"] == text.rindex(name)
    assert (
        cast("JsonObject", cast("JsonObject", first["source"])["line_range"])["start"]
        == 2
    )
    assert first["relationship_id"] != second["relationship_id"]
    assert result == analyze(catalog, text, production="class " + name + " {}")


@pytest.mark.parametrize(
    "path,changes",
    [
        ("tests_extra/a.cs", {}),
        ("docs/a.cs", {}),
        ("tests/a.cs", {"production_roots": ["src", "tests"]}),
        ("tests/a.cs", {"project_entry_points": ["tests/a.cs"]}),
        ("tests/a.cs", {"test_roots": []}),
    ],
)
def test_scope_uses_component_boundaries_and_production_precedence(
    catalog: SchemaCatalog, path: str, changes: dict[str, object]
) -> None:
    """Path and profile changes represent non-test authority or root overlap.

    Returns None; test-like names and categories cannot override configured scope.
    """
    result = ReferenceAnalyzer().analyze(
        inputs(
            catalog,
            (("src/a.cs", b"class Widget {}"), (path, b"new Widget()")),
            **changes,
        )
    )
    assert not result.relationships


@pytest.mark.parametrize(
    "target,kind",
    [
        ("$(VALUE_SENTINEL)/a.csproj", "expression"),
        ("@(VALUE_SENTINEL)", "expression"),
        ("%(VALUE_SENTINEL)", "expression"),
        ("VALUE_SENTINEL/*.csproj", "wildcard"),
        ("VALUE_SENTINEL?.csproj", "wildcard"),
    ],
)
def test_project_expression_values_are_withheld(
    catalog: SchemaCatalog, target: str, kind: str
) -> None:
    """Str target/kind select unresolved expression/wildcard declarations.

    Returns None; no raw values or value-derived IDs are exposed.
    """
    xml = (
        f'<Project><ItemGroup><ProjectReference Include="{target}"/>'
        "</ItemGroup></Project>"
    )
    result = ReferenceAnalyzer().analyze(
        inputs(catalog, (("tests/a.csproj", xml.encode()),))
    )
    assert detail(result.findings[0])["target_kind"] == kind
    assert result.relationships[0]["target_description"] == "unresolved-project-target"
    assert "VALUE_SENTINEL" not in serialized(result)


@pytest.mark.parametrize(
    "content", [b"\xffVALUE_SENTINEL", b"\x00", b"class \\uXXYYVALUE_SENTINEL {}"]
)
def test_source_encoding_and_lexical_failures_are_redacted(
    catalog: SchemaCatalog, content: bytes
) -> None:
    """Bytes content selects invalid decoding/tokenization; returns None.

    No source row is emitted before parsing completes; messages contain no values.
    """
    result = ReferenceAnalyzer().analyze(inputs(catalog, (("src/a.cs", content),)))
    assert not result.components and result.diagnostics[0]["blocking"] is True
    assert "VALUE_SENTINEL" not in serialized(result)


@pytest.mark.parametrize("encoding", ["utf-8-sig", "utf-16", "utf-32"])
def test_source_bom_decoding_uses_captured_bytes(
    catalog: SchemaCatalog, encoding: str
) -> None:
    """Str encoding selects accepted BOM forms; returns None with exact source hash.

    Data never leaves the in-memory capture and source anchors remain physical.
    """
    content = "new Widget()".encode(encoding)
    result = ReferenceAnalyzer().analyze(
        inputs(catalog, (("src/a.cs", b"class Widget {}"), ("tests/a.cs", content)))
    )
    assert (
        cast("JsonObject", result.relationships[0]["source"])["sha256"]
        == hashlib.sha256(content).hexdigest()
    )


@pytest.mark.parametrize("axis", ["missing", "bytes", "revision", "repository"])
def test_exact_pin_is_required_without_reusing_working_claims(
    catalog: SchemaCatalog, axis: str
) -> None:
    """Str axis invalidates one pin identity; returns None with a blocking finding.

    No lexical relationship is emitted from unpinned test bytes.
    """
    value = inputs(
        catalog, (("src/a.cs", b"class Widget {}"), ("tests/a.cs", b"new Widget()"))
    )
    source, test = value.repository_files
    changed = (
        replace(test, content=b"other")
        if axis == "bytes"
        else replace(
            test,
            repository=RepositoryIdentity(
                id="other" if axis == "repository" else test.repository.id,
                revision="b" * 40 if axis == "revision" else test.repository.revision,
            ),
        )
    )
    pins = (source,) if axis == "missing" else (source, changed)
    result = ReferenceAnalyzer().analyze(replace(value, repository_files=pins))
    assert not result.relationships
    # Successful sources cannot hide a separate unverified input.
    assert any(
        item["code"] == "source-revision-unverified" for item in result.diagnostics
    )


@pytest.mark.parametrize("status", ["excluded", "unreadable"])
def test_omission_rationale_cannot_leak_into_diagnostics(
    catalog: SchemaCatalog, status: str
) -> None:
    """Str status selects unavailable input without fabricated bytes; returns None.

    The configured input identity remains visible, but raw rationale is withheld.
    """
    value = inputs(catalog, ())
    missing = InventoryInput(
        path="tests/a.cs",
        status=cast("Literal['excluded', 'unreadable']", status),
        rationale="VALUE_SENTINEL",
    )
    result = ReferenceAnalyzer().analyze(replace(value, inputs=(missing,)))
    assert not result.findings and "VALUE_SENTINEL" not in serialized(result)
    assert bool(result.diagnostics) == (status == "unreadable")


def test_direct_adapter_is_schema_valid_and_does_not_assign_coverage(
    catalog: SchemaCatalog,
) -> None:
    """SchemaCatalog validates direct composition; returns None without publication.

    Generated ledger proposals retain uninspected/unassigned ownership.
    """
    value = inputs(
        catalog, (("src/a.cs", b"class Widget {}"), ("tests/a.cs", b"new Widget()"))
    )
    result = ReferenceAnalyzer().analyze(value)
    inventory = inventory_result(
        value,
        (result,),
        analyzer_ids=("test-references",),
        timestamp="2026-10-19T00:00:00Z",
        author_or_agent=row(kind="tool", id="test"),
        catalog=catalog,
    )
    assert inventory.document["relationships"] == result.relationships
    # Detection must leave every seed uninspected and unassigned.
    assert all(
        item["inspection_status"] == "uninspected"
        and item["disposition"] == "unassigned"
        for item in inventory.ledger_components
    )


@pytest.mark.parametrize(
    "limit_name,limit",
    [("artifact_records", 4), ("document_bytes", 4000), ("source_files", 1)],
)
def test_global_budget_overflow_discards_all_claims(
    catalog: SchemaCatalog, limit_name: str, limit: int
) -> None:
    """Str limit_name/int limit exhaust independent resource reservations.

    Returns None; partial rows are discarded behind one fixed global blocker.
    """
    payloads = (("src/a.cs", b"class Widget {}"),)
    # A second file exhausts the shared row budget after valid first-file output.
    if limit_name == "artifact_records":
        payloads += (("tests/a.cs", b"new Widget()"),)
    value = inputs(catalog, payloads, limits={limit_name: limit})
    # Duplicate pins exercise pin count without exceeding the input-file limit.
    if limit_name == "source_files":
        value = replace(value, repository_files=value.repository_files * 2)
    result = ReferenceAnalyzer().analyze(value)
    assert not result.components and not result.findings and not result.relationships
    # Overflow has one fixed diagnostic and no surviving partial claim.
    assert [item["code"] for item in result.diagnostics] == ["analysis-work-limit"]


def test_foreign_unused_pin_bytes_consume_independent_budget(
    catalog: SchemaCatalog,
) -> None:
    """SchemaCatalog creates a small capture with one oversized unused foreign pin.

    Returns None; pin accounting rejects before source projection or partial claims.
    """
    value = inputs(
        catalog, (("src/a.cs", b"class Widget {}"),), limits={"document_bytes": 8192}
    )
    foreign = RepositoryFile(
        repository=RepositoryIdentity(id="other", revision="b" * 40),
        path="docs/unused",
        content=b"x" * 8193,
    )
    result = ReferenceAnalyzer().analyze(
        replace(value, repository_files=value.repository_files + (foreign,))
    )
    # Pin accounting must fail independently from source projection.
    assert not result.components and [item["code"] for item in result.diagnostics] == [
        "analysis-work-limit"
    ]


def test_later_valid_duplicate_pin_retains_exact_matching_semantics(
    catalog: SchemaCatalog,
) -> None:
    """SchemaCatalog supplies exact bytes behind an earlier mismatching duplicate.

    Returns None; any valid retained pin proves bytes without repeated source reads.
    """
    value = inputs(
        catalog, (("src/a.cs", b"class Widget {}"), ("tests/a.cs", b"new Widget()"))
    )
    bad = replace(value.repository_files[0], content=b"other")
    result = ReferenceAnalyzer().analyze(
        replace(
            value,
            repository_files=(bad, *value.repository_files, value.repository_files[0]),
        )
    )
    assert len(result.relationships) == 1
    # A later exact duplicate must prevent a false provenance blocker.
    assert not any(item["blocking"] for item in result.diagnostics)


def test_type_index_budget_is_reserved_before_name_insertion(
    catalog: SchemaCatalog, monkeypatch: pytest.MonkeyPatch
) -> None:
    """Catalog and isolated monkeypatch prove prospective aggregate index bounds.

    Returns None; a small long identifier exhausts text budget before site creation.
    """

    def forbidden(*args: object, **kwargs: object) -> None:
        """Reject object args/kwargs after overflow; return never, raise AssertionError.

        No data is mutated or read; the fake proves reservation precedes projection.
        """
        raise AssertionError("Site allocation must follow index reservation")

    value = inputs(
        catalog,
        (("src/a.cs", ("class " + "W" * 2000 + " {}").encode()),),
        limits={"document_bytes": 20000},
    )
    monkeypatch.setattr(
        "drm_copilot_discovery.analyzer.test_references._Output.site", forbidden
    )
    result = ReferenceAnalyzer().analyze(value)
    assert (
        not result.components and result.diagnostics[0]["code"] == "analysis-work-limit"
    )


def test_file_byte_limit_precedes_masking(
    catalog: SchemaCatalog, monkeypatch: pytest.MonkeyPatch
) -> None:
    """Catalog and isolated monkeypatch prove rejected bytes never reach masking.

    Returns None; the per-file failure is fixed and emits no source claims.
    """

    def forbidden(text: str) -> str:
        """Reject str text passed to masking; return never, raise AssertionError.

        No data is mutated or read; oversized input must stop before this boundary.
        """
        raise AssertionError("Masking must not run")

    value = inputs(
        catalog,
        (("tests/a.cs", b"new Widget();"),),
        analyzers={
            "enabled": ["test-references"],
            "options": {"max_file_bytes": 4},
            "ignored_paths": [],
            "extension_result_manifests": [],
        },
    )
    monkeypatch.setattr(implementation, "strip_comments_and_strings", forbidden)
    result = ReferenceAnalyzer().analyze(value)
    assert not result.components and result.diagnostics[0]["code"] == "source-limit"
