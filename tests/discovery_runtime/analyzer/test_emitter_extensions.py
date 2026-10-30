"""Verify exact external analyzer metadata without changing built-in emission."""

from __future__ import annotations

from dataclasses import replace
from typing import TYPE_CHECKING, cast

import pytest
from drm_copilot_discovery.analyzer.emitter import inventory_result
from drm_copilot_discovery.analyzer.findings import row, tool
from drm_copilot_discovery.analyzer.inventory import RepositoryAnalyzer
from drm_copilot_discovery.analyzer.models import Analysis
from drm_copilot_discovery.analyzer.registry import builtin_analyzer_identities
from drm_copilot_discovery.models import JsonObject, canonical_json

from tests.discovery_runtime.analyzer.test_repository import (
    analyzer_catalog as analyzer_catalog,
)
from tests.discovery_runtime.analyzer.test_repository import (
    inventory_capture,
    inventory_profile,
)

if TYPE_CHECKING:
    from collections.abc import Iterator

    from drm_copilot_discovery.analyzer.models import InventoryCapture, InventoryResult
    from drm_copilot_discovery.catalog import SchemaCatalog


def emit(
    capture: InventoryCapture,
    catalog: SchemaCatalog,
    *,
    declarations: tuple[JsonObject, ...] | None = None,
    identifiers: tuple[str, ...] = ("repository",),
    analyses: tuple[Analysis, ...] | None = None,
) -> InventoryResult:
    """Emit immutable test rows using fixed provenance and real schema validation.

    capture (InventoryCapture), catalog (SchemaCatalog) bind trusted inputs;
    declarations (tuple[JsonObject, ...] | None), identifiers (tuple[str, ...]) and
    analyses (tuple[Analysis, ...] | None) select metadata/rows. Returns an
    InventoryResult; ValueError propagates for invalid output. No I/O occurs.
    """
    return inventory_result(
        capture,
        (RepositoryAnalyzer().analyze(capture),) if analyses is None else analyses,
        analyzer_ids=identifiers,
        timestamp="2026-10-19T12:00:00Z",
        author_or_agent=row(kind="tool", id="fixture"),
        catalog=catalog,
        extension_adapters=declarations,
    )


def external_analysis(capture: InventoryCapture, descriptor: JsonObject) -> Analysis:
    """Build complete source-bound external rows using one exact declared identity.

    capture (InventoryCapture) supplies retained bytes; descriptor (JsonObject)
    supplies id/version. Returns Analysis with all source-bearing row families;
    real immutable construction errors propagate. No I/O or mutation occurs.
    """
    component = RepositoryAnalyzer().analyze(capture).components[0]
    component = row(**(dict(component) | {"analyzer": descriptor}))
    finding = row(
        finding_id="external-finding",
        component_id=component["component_id"],
        kind="declared-name",
        source=component["source"],
        analyzer=descriptor,
        classification="detected",
        confidence="high",
        properties=(),
        extensions=row(),
    )
    relationship = row(
        relationship_id="external-relation",
        from_component_id=component["component_id"],
        to_component_id=None,
        target_description="Unresolved declared target",
        kind="declared-edge",
        source=component["source"],
        analyzer=descriptor,
        classification="inferred",
        confidence="low",
        extensions=row(),
    )
    return Analysis(
        components=(component,), findings=(finding,), relationships=(relationship,)
    )


def test_absent_and_empty_external_metadata_preserve_default_bytes(
    analyzer_catalog: SchemaCatalog,
) -> None:
    """Preserve existing semantic/capture output when the new keyword is unused.

    analyzer_catalog (SchemaCatalog) supplies immutable schemas. Returns None;
    assertions expose byte or proposal changes. Uses only in-memory captures.
    """
    capture = inventory_capture(analyzer_catalog)
    expected = inventory_result(
        capture,
        (RepositoryAnalyzer().analyze(capture),),
        analyzer_ids=("repository",),
        timestamp="2026-10-19T12:00:00Z",
        author_or_agent=row(kind="tool", id="fixture"),
        catalog=analyzer_catalog,
    )
    assert expected == emit(capture, analyzer_catalog, declarations=None)
    assert expected == emit(capture, analyzer_catalog, declarations=())
    assert expected.document["analyzers"] == (tool("repository"),)
    assert canonical_json(expected.document) == canonical_json(
        emit(capture, analyzer_catalog).document
    )


@pytest.mark.parametrize(
    "version", ["0.3.7", "release-candidate", "2026.10+local", "é.😀"]
)
def test_external_version_is_preserved_on_every_source_bearing_row(
    analyzer_catalog: SchemaCatalog, version: str
) -> None:
    """Emit caller-declared versions without substituting the runtime version.

    analyzer_catalog (SchemaCatalog), version (str) define a valid external pair.
    Returns None; assertions check complete real schema output. No I/O occurs.
    """
    capture = inventory_capture(analyzer_catalog)
    descriptor = row(id="local.adapter", version=version)
    analysis = external_analysis(capture, descriptor)
    result = emit(
        capture,
        analyzer_catalog,
        declarations=(descriptor,),
        identifiers=(),
        analyses=(analysis,),
    )
    assert result.document["analyzers"] == (descriptor,)
    assert result.document["components"] == analysis.components
    assert result.document["findings"] == analysis.findings
    assert result.document["relationships"] == analysis.relationships
    assert result.ledger_components[0]["inspection_status"] == "uninspected"


def test_external_metadata_is_sorted_without_changing_versions(
    analyzer_catalog: SchemaCatalog,
) -> None:
    """Make external declaration order irrelevant while preserving each version.

    analyzer_catalog (SchemaCatalog) supplies schemas. Returns None; assertions
    enforce stable complete output. Only immutable synthetic records are used.
    """
    capture = inventory_capture(analyzer_catalog)
    declarations = (row(id="z-local", version="7"), row(id="a-local", version="3"))
    first = emit(capture, analyzer_catalog, declarations=declarations)
    second = emit(capture, analyzer_catalog, declarations=declarations[::-1])
    assert first == second
    assert first.document["analyzers"] == (
        declarations[1],
        tool("repository"),
        declarations[0],
    )


@pytest.mark.parametrize(
    "identifier", ["repository", "office-vsto", "dependencies", "ui-callbacks"]
)
def test_reserved_identity_cannot_be_declared_by_an_external_adapter(
    analyzer_catalog: SchemaCatalog, identifier: str
) -> None:
    """Reject reserved IDs regardless of selection or a matching runtime version.

    analyzer_catalog (SchemaCatalog), identifier (str) select an impersonation.
    Returns None; assertions enforce rejection before result construction. No I/O.
    """
    capture = inventory_capture(analyzer_catalog)
    with pytest.raises(ValueError, match="reserved"):
        emit(
            capture,
            analyzer_catalog,
            declarations=(tool(identifier),),
            identifiers=(),
            analyses=(),
        )


@pytest.mark.parametrize(
    "descriptors",
    [
        (row(id="local", version="1"), row(id="local", version="1")),
        (row(id="local", version="1"), row(id="local", version="2")),
    ],
)
def test_duplicate_external_ids_fail_even_when_versions_differ(
    analyzer_catalog: SchemaCatalog, descriptors: tuple[JsonObject, ...]
) -> None:
    """Reject ambiguous adapter identity instead of selecting the last descriptor.

    analyzer_catalog (SchemaCatalog), descriptors (tuple[JsonObject, ...]) supply
    the duplicate case. Returns None; assertions enforce failure. Memory only.
    """
    with pytest.raises(ValueError, match="duplicated"):
        emit(
            inventory_capture(analyzer_catalog),
            analyzer_catalog,
            declarations=descriptors,
        )


@pytest.mark.parametrize(
    "descriptor",
    [
        row(id="local"),
        row(id="local", version="1", extra=True),
        row(id=12, version="1"),
        row(id="local", version=None),
        row(id="local", version=""),
        row(id="local", version=" \t"),
        row(id="Upper", version="1"),
        row(id="a..b", version="1"),
        row(id="a-", version="1"),
        row(id="a\n", version="1"),
        row(id="a/b", version="1"),
    ],
)
def test_malformed_external_metadata_has_fixed_actionable_failures(
    analyzer_catalog: SchemaCatalog, descriptor: JsonObject
) -> None:
    """Reject malformed IDs/versions without copying supplied text into errors.

    analyzer_catalog (SchemaCatalog), descriptor (JsonObject) choose invalid data.
    Returns None; assertions require fixed ValueError messages. No I/O occurs.
    """
    with pytest.raises(ValueError, match="External analyzer"):
        emit(
            inventory_capture(analyzer_catalog),
            analyzer_catalog,
            declarations=(descriptor,),
        )


@pytest.mark.parametrize(
    "identifiers", [("unknown",), ("repository", "repository"), ("local",)]
)
def test_builtin_selectors_require_unique_reserved_metadata(
    analyzer_catalog: SchemaCatalog, identifiers: tuple[str, ...]
) -> None:
    """Reject unknown/duplicate selectors and external IDs in the built-in tuple.

    analyzer_catalog (SchemaCatalog), identifiers (tuple[str, ...]) supply the
    invalid selector list. Returns None; assertions enforce rejection. Memory only.
    """
    with pytest.raises(ValueError, match="Unknown or duplicate"):
        emit(
            inventory_capture(analyzer_catalog),
            analyzer_catalog,
            identifiers=identifiers,
            declarations=(row(id="local", version="1"),),
        )


@pytest.mark.parametrize("family", ["components", "findings", "relationships"])
@pytest.mark.parametrize(
    "descriptor",
    [
        row(id="missing", version="1"),
        row(id="local", version="2"),
        row(id="local"),
        row(id=None, version="1"),
    ],
)
def test_each_row_family_requires_its_exact_declared_pair(
    analyzer_catalog: SchemaCatalog, family: str, descriptor: JsonObject
) -> None:
    """Reject undeclared, wrong-version or malformed row ownership before emission.

    analyzer_catalog (SchemaCatalog), family (str), descriptor (JsonObject) select
    one corrupted row. Returns None; assertions enforce failure. No I/O occurs.
    """
    capture = inventory_capture(analyzer_catalog)
    identity = row(id="local", version="1")
    analysis = external_analysis(capture, identity)
    rows = cast("tuple[JsonObject, ...]", getattr(analysis, family))
    corrupted = row(**(dict(rows[0]) | {"analyzer": descriptor}))
    analysis = replace(analysis, **{family: (corrupted,)})
    with pytest.raises(ValueError, match="Analyzer row"):
        emit(
            capture,
            analyzer_catalog,
            identifiers=(),
            declarations=(identity,),
            analyses=(analysis,),
        )


@pytest.mark.parametrize(
    "boundary",
    [
        "ids-list",
        "extensions-list",
        "descriptor-type",
        "id-type",
        "id-size",
        "extension-size",
        "count",
        "rows",
    ],
)
def test_identity_and_row_limits_are_checked_before_aggregation(
    analyzer_catalog: SchemaCatalog, boundary: str
) -> None:
    """Reject malformed public containers and prospective metadata/record overflow.

    analyzer_catalog (SchemaCatalog), boundary (str) choose a finite invalid case.
    Returns None; assertions enforce complete failure. Only memory data is used.
    """
    capture = inventory_capture(analyzer_catalog)
    identifiers = ("repository",)
    declarations: tuple[JsonObject, ...] | None = None
    analyses: tuple[Analysis, ...] = ()
    # Exercise each boundary independently without invoking external adapters.
    if boundary == "ids-list":
        identifiers = cast("tuple[str, ...]", ["repository"])
    elif boundary == "extensions-list":
        declarations = cast("tuple[JsonObject, ...]", [])
    elif boundary == "descriptor-type":
        declarations = cast("tuple[JsonObject, ...]", ("bad",))
    elif boundary == "id-type":
        identifiers = cast("tuple[str, ...]", (1,))
    elif boundary == "id-size":
        capture = replace(
            capture,
            profile=inventory_profile(analyzer_catalog, limits={"document_bytes": 10}),
        )
        identifiers = ("x" * 11,)
    elif boundary == "extension-size":
        capture = replace(
            capture,
            profile=inventory_profile(analyzer_catalog, limits={"document_bytes": 100}),
        )
        declarations = (row(id="local", version="😀" * 20),)
    elif boundary == "count":
        capture = replace(
            capture,
            profile=inventory_profile(analyzer_catalog, limits={"artifact_records": 1}),
        )
        declarations = (row(id="local", version="1"),)
    else:
        capture = replace(
            capture,
            profile=inventory_profile(analyzer_catalog, limits={"artifact_records": 1}),
        )
        analyses = (RepositoryAnalyzer().analyze(capture),)
    with pytest.raises(ValueError):
        emit(
            capture,
            analyzer_catalog,
            declarations=declarations,
            identifiers=identifiers,
            analyses=analyses,
        )


def test_reserved_versions_are_taken_from_the_single_registry_authority(
    analyzer_catalog: SchemaCatalog, monkeypatch: pytest.MonkeyPatch
) -> None:
    """Demonstrate that emitter metadata cannot drift through a second fixed list.

    analyzer_catalog (SchemaCatalog), monkeypatch (MonkeyPatch) supply schemas and
    an isolated metadata replacement. Returns None; assertions check exact use.
    """
    descriptor = row(id="repository", version="test-authority")
    from drm_copilot_discovery.analyzer import registry

    def identities() -> tuple[JsonObject, ...]:
        """Return isolated reserved metadata without implementation imports.

        No parameters; returns tuple[JsonObject, ...]. No exceptions expected.
        """
        return (descriptor,)

    # The control confirms that the replacement changes an existing reserved pair.
    assert any(item["id"] == "repository" for item in builtin_analyzer_identities())
    monkeypatch.setattr(registry, "builtin_analyzer_identities", identities)
    result = emit(inventory_capture(analyzer_catalog), analyzer_catalog, analyses=())
    assert result.document["analyzers"] == (descriptor,)


def test_empty_batch_limit_is_rejected_before_iteration(
    analyzer_catalog: SchemaCatalog,
) -> None:
    """Reserve aggregate batch work even when every supplied analysis is empty.

    analyzer_catalog (SchemaCatalog) provides an immutable profile. Returns None;
    assertions reject iteration before the prospective cardinality check. No I/O.
    """

    class UnscannedBatches(tuple[Analysis, ...]):
        """Expose immutable cardinality while detecting premature iteration."""

        def __iter__(self) -> Iterator[Analysis]:
            """Reject iteration of this over-limit immutable test batch.

            No arguments; never returns Iterator[Analysis]. Raises AssertionError
            if production scans batches before reserving their count. No I/O.
            """
            raise AssertionError("Over-limit batches were scanned")

    capture = inventory_capture(analyzer_catalog)
    capture = replace(
        capture,
        profile=inventory_profile(analyzer_catalog, limits={"artifact_records": 1}),
    )
    batches = UnscannedBatches((Analysis(), Analysis()))
    with pytest.raises(ValueError, match="Analyzer batches"):
        emit(capture, analyzer_catalog, analyses=batches)


@pytest.mark.parametrize(
    "reference", ["component_id", "from_component_id", "to_component_id"]
)
def test_declared_external_rows_reject_missing_component_targets(
    analyzer_catalog: SchemaCatalog,
    reference: str,
) -> None:
    """Retain component-reference integrity after external ownership is validated.

    analyzer_catalog (SchemaCatalog), reference (str) choose a synthetic broken
    edge. Returns None; assertions require a reference error, not a metadata error.
    """
    capture = inventory_capture(analyzer_catalog)
    identity = row(id="local", version="1")
    analysis = external_analysis(capture, identity)
    family = "findings" if reference == "component_id" else "relationships"
    values = cast("tuple[JsonObject, ...]", getattr(analysis, family))
    invalid = row(**(dict(values[0]) | {reference: "absent-component"}))
    analysis = replace(analysis, **{family: (invalid,)})
    with pytest.raises(ValueError, match="broken component reference"):
        emit(
            capture,
            analyzer_catalog,
            identifiers=(),
            declarations=(identity,),
            analyses=(analysis,),
        )
