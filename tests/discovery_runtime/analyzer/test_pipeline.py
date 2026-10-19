"""Test pure analyzer results and explicit guarded publication across real
validators.
"""

from __future__ import annotations

from dataclasses import replace
from typing import TYPE_CHECKING, Literal, cast

import pytest
from drm_copilot_discovery.analyzer.emitter import inventory_result
from drm_copilot_discovery.analyzer.findings import row
from drm_copilot_discovery.analyzer.input_capture import (
    capture_snapshot,
    pin_inventory_sources,
)
from drm_copilot_discovery.analyzer.inventory import RepositoryAnalyzer
from drm_copilot_discovery.analyzer.pipeline import plan_inventory, run_inventory
from drm_copilot_discovery.models import JsonObject, canonical_json
from drm_copilot_discovery.mutation_io import capture_workspace, commit_mutation
from drm_copilot_discovery.mutation_plan import MutationError
from drm_copilot_discovery.path_models import WriteGrant

from tests.discovery_runtime.analyzer.test_input_capture import MemoryRepository
from tests.discovery_runtime.analyzer.test_repository import (
    analyzer_catalog as analyzer_catalog,
)
from tests.discovery_runtime.analyzer.test_repository import (
    inventory_capture,
    inventory_profile,
)
from tests.discovery_runtime.test_mutation_commit import MemoryWriter
from tests.discovery_runtime.test_snapshot_io import MemoryStore

if TYPE_CHECKING:
    from drm_copilot_discovery.analyzer.models import InventoryCapture, InventoryResult
    from drm_copilot_discovery.catalog import SchemaCatalog
    from drm_copilot_discovery.mutation_plan import CapturedWorkspace


def result_for(capture: InventoryCapture, catalog: SchemaCatalog) -> InventoryResult:
    """Use fixed capture metadata so complete result bytes can be compared exactly.

    Parameters: capture (InventoryCapture): immutable analyzer input set. catalog
    (SchemaCatalog): trusted immutable schema catalog.

    Returns InventoryResult with fixed provenance; validation failures propagate. No
    I/O or mutation.
    """
    return run_inventory(
        capture,
        timestamp="2026-10-19T01:00:00Z",
        author_or_agent=row(kind="tool", id="fixture"),
        catalog=catalog,
    )


class InventoryWriter(MemoryWriter):
    """Compose real guarded mutation with repeatable inventory source precapture."""

    def __init__(
        self, store: MemoryStore, catalog: SchemaCatalog, repository: MemoryRepository
    ) -> None:
        """Reuse accepted memory mutation primitives with one explicit local reader.

        Parameters: store (MemoryStore): test-local memory filesystem. catalog
        (SchemaCatalog): trusted immutable schema catalog. repository
        (MemoryRepository): isolated pinned Git reader.

        Returns None; initializes only isolated memory mutation state. No real I/O
        occurs.
        """
        super().__init__(store, catalog)
        self.repository = repository

    def capture(self) -> CapturedWorkspace:
        """Repeat complete exact capture and selected Git objects on every check.

        Takes no caller arguments.

        Returns CapturedWorkspace using actual loader and precapture contracts.
        Policy/read failures propagate; reads only synthetic memory inputs.
        """
        baseline = capture_workspace(
            workspace_root="/workspace",
            profile_path="docs/migration/discovery/domain-profile.yaml",
            metadata=self.store.metadata,
            read_bytes=self.store.read,
            repository=self.repository,
            catalog=self.catalog,
        )
        return pin_inventory_sources(baseline, self.repository)


def publication_case(
    catalog: SchemaCatalog,
    generated: tuple[Literal["reports", "acceptance"], str] | None = None,
) -> tuple[InventoryWriter, CapturedWorkspace, InventoryResult, WriteGrant]:
    """Create an incomplete workspace whose first inventory includes a real document.

    Parameters: catalog (SchemaCatalog): trusted immutable schema catalog. generated
    (tuple[str, str] | None): optional output-root key and generated document name.

    Returns tuple[InventoryWriter, CapturedWorkspace, InventoryResult, WriteGrant]
    for guarded publication. Reads and mutates only a new memory store; validation
    failures propagate.
    """
    profile = inventory_profile(catalog)
    store = MemoryStore()
    store.put(profile.artifacts["profile"], canonical_json(profile.document))
    store.put("src/main.cs", b"class Main {}\r\n")
    store.put("docs/guide.md", b"Observed guide.\n")
    # Existing generated views are output artifacts even inside documentation roots.
    if generated is not None:
        kind, name = generated
        store.put(profile.artifacts[kind] + "/" + name, b"Generated output.\n")
    repository = MemoryRepository(
        profile,
        {"src/main.cs": b"class Main {}\r\n", "docs/guide.md": b"Observed guide.\n"},
    )
    writer = InventoryWriter(store, catalog, repository)
    baseline = writer.capture()
    result = result_for(capture_snapshot(baseline.snapshot), catalog)
    identifier = cast("str", result.document["id"])
    grant = WriteGrant(
        artifact_kind="inventory-snapshot",
        artifact_id=identifier,
        path=profile.artifacts["inventory"] + "/" + identifier + ".json",
    )
    return writer, baseline, result, grant


def test_default_and_dry_run_analysis_are_identical_and_do_not_write(
    analyzer_catalog: SchemaCatalog,
) -> None:
    """Immutable capture inputs support both modes without a publication
    collaborator.

    Parameters: analyzer_catalog (SchemaCatalog): immutable installed schema
    fixture.

    Returns None. Raises AssertionError when the asserted contract differs; uses
    only test-local memory and immutable schema fixtures.
    """
    capture = inventory_capture(analyzer_catalog)
    original = capture
    first = result_for(capture, analyzer_catalog)
    second = run_inventory(
        capture,
        timestamp="2026-10-19T01:00:00Z",
        author_or_agent=row(kind="tool", id="fixture"),
        catalog=analyzer_catalog,
        dry_run=True,
    )
    assert first == second and capture == original
    assert len(first.ledger_components) == 2


@pytest.mark.parametrize(
    "generated",
    [None, ("reports", "coverage-report.md"), ("acceptance", "criteria.feature")],
)
def test_inventory_publication_is_explicit_idempotent_and_scope_preserving(
    analyzer_catalog: SchemaCatalog,
    generated: tuple[Literal["reports", "acceptance"], str] | None,
) -> None:
    """First publication passes real schema/graph/CAS gates and creates only
    inventory.

    Parameters: analyzer_catalog (SchemaCatalog): immutable installed schema
    fixture. generated (tuple[str, str] | None): optional existing generated output.

    Returns None. Raises AssertionError when the asserted contract differs; uses
    only test-local memory and immutable schema fixtures.
    """
    writer, baseline, result, grant = publication_case(analyzer_catalog, generated)
    # Output bytes may be documentation to the loader but never analyzer sources.
    if generated is not None:
        kind, name = generated
        output_path = baseline.snapshot.profile.artifacts[kind] + "/" + name
        excluded = next(
            item
            for item in capture_snapshot(baseline.snapshot).inputs
            if item.path == output_path
        )
        assert excluded.status == "excluded" and excluded.rationale
        assert excluded.file is None and excluded.sha256 is None
        assert output_path not in writer.repository.calls
        assert output_path not in {item["path"] for item in result.ledger_components}
    before = dict(writer.store.files)
    plan = plan_inventory(baseline, result, grants=(grant,))
    assert dict(writer.store.files) == before
    preview = commit_mutation(plan, writer=writer, dry_run=True)
    assert preview.ok and preview.artifacts[0].status == "planned"
    assert writer.invalidations == writer.attempts == 0
    assert dict(writer.store.files) == before
    committed = commit_mutation(plan, writer=writer)
    assert committed.ok, committed.findings
    assert writer.attempts == writer.invalidations == 1
    assert set(writer.store.files) == set(before) | {grant.path}
    # Compare every pre-existing byte sequence, including documentation and profile.
    assert all(writer.store.files[path] == data for path, data in before.items())
    assert writer.store.files[grant.path] == canonical_json(result.document)
    assert baseline.snapshot.profile.artifacts["scope"] not in writer.store.files
    assert (
        baseline.snapshot.profile.artifacts["coverage_ledger"] not in writer.store.files
    )
    refreshed = writer.capture()
    repeated = plan_inventory(
        refreshed,
        result_for(capture_snapshot(refreshed.snapshot), analyzer_catalog),
        grants=(grant,),
    )
    skipped = commit_mutation(repeated, writer=writer)
    assert skipped.ok and skipped.artifacts[0].status == "skipped"
    assert writer.attempts == writer.invalidations == 1


def test_publication_rejects_wrong_grants_and_changed_inputs(
    analyzer_catalog: SchemaCatalog,
) -> None:
    """Valid result bytes alone cannot grant write authority or override freshness.

    Parameters: analyzer_catalog (SchemaCatalog): immutable installed schema
    fixture.

    Returns None. Raises AssertionError when the asserted contract differs; uses
    only test-local memory and immutable schema fixtures.
    """
    writer, baseline, result, grant = publication_case(analyzer_catalog)
    with pytest.raises((ValueError, MutationError)):
        plan_inventory(baseline, result, grants=())
    forged = replace(result, semantic_sha256="0" * 64)
    with pytest.raises(MutationError, match="INVENTORY_INPUTS"):
        plan_inventory(baseline, forged, grants=(grant,))
    plan = plan_inventory(baseline, result, grants=(grant,))
    writer.store.files["docs/guide.md"] = b"changed after planning"
    stale = commit_mutation(plan, writer=writer)
    assert not stale.ok and stale.findings[0].code == "MUTATION_FAILED"
    assert "MUTATION_STALE" in stale.findings[0].message
    assert writer.attempts == 0 and writer.invalidations == 1
    assert stale.authority_invalidated


def test_unverified_source_provenance_blocks_publication(
    analyzer_catalog: SchemaCatalog,
) -> None:
    """A source with no immutable bytes remains an explicit blocking result.

    Parameters: analyzer_catalog (SchemaCatalog): immutable installed schema
    fixture.

    Returns None. Raises AssertionError when the asserted contract differs; uses
    only test-local memory and immutable schema fixtures.
    """
    _, baseline, _, grant = publication_case(analyzer_catalog)
    baseline = replace(
        baseline, snapshot=replace(baseline.snapshot, repository_files=())
    )
    result = result_for(capture_snapshot(baseline.snapshot), analyzer_catalog)
    with pytest.raises(MutationError, match="INVENTORY_BLOCKED"):
        plan_inventory(baseline, result, grants=(grant,))


@pytest.mark.parametrize(
    "failure", ["duplicate", "reference", "schema", "timestamp", "limit", "identifier"]
)
def test_invalid_adapter_results_and_capture_metadata_fail_closed(
    analyzer_catalog: SchemaCatalog, failure: str
) -> None:
    """Adapter bugs cannot produce publishable malformed or contradictory
    inventories.

    Parameters: analyzer_catalog (SchemaCatalog): immutable installed schema
    fixture. failure (str): selected invalid-result case.

    Returns None. Raises AssertionError when the asserted contract differs; uses
    only test-local memory and immutable schema fixtures.
    """
    capture = inventory_capture(analyzer_catalog)
    analysis = RepositoryAnalyzer().analyze(capture)
    timestamp = "2026-10-19T01:00:00Z"
    # Isolate identity, reference, shape, metadata and resource-limit failure classes.
    if failure == "duplicate":
        analysis = replace(
            analysis, components=analysis.components + analysis.components
        )
    elif failure == "reference":
        analysis = replace(
            analysis, findings=(row(finding_id="bad", component_id="absent"),)
        )
    elif failure == "schema":
        analysis = replace(analysis, diagnostics=(row(id="broken"),))
    elif failure == "timestamp":
        timestamp = "not-a-time"
    elif failure == "identifier":
        analysis = replace(analysis, diagnostics=(row(message="Missing identity"),))
    else:
        capture = replace(
            capture,
            profile=inventory_profile(analyzer_catalog, limits={"artifact_records": 1}),
        )
    with pytest.raises(ValueError):
        inventory_result(
            capture,
            (analysis,),
            analyzer_ids=("repository",),
            timestamp=timestamp,
            author_or_agent=row(kind="tool", id="fixture"),
            catalog=analyzer_catalog,
        )


def test_null_relationship_target_preserves_unresolved_binding(
    analyzer_catalog: SchemaCatalog,
) -> None:
    """A declared relationship may retain an unresolved destination without
    inventing it.

    Parameters: analyzer_catalog (SchemaCatalog): immutable installed schema
    fixture.

    Returns None. Raises AssertionError when the asserted contract differs; uses
    only test-local memory and immutable schema fixtures.
    """
    capture = inventory_capture(analyzer_catalog)
    original = RepositoryAnalyzer().analyze(capture)
    component = original.components[0]
    relationship = row(
        relationship_id="dependency-one",
        from_component_id=component["component_id"],
        to_component_id=None,
        target_description="Unresolved external project",
        kind="project-reference",
        source=component["source"],
        analyzer=component["analyzer"],
        classification="detected",
        confidence="low",
        extensions=row(),
    )
    result = inventory_result(
        capture,
        (replace(original, relationships=(relationship,)),),
        analyzer_ids=("repository",),
        timestamp="2026-10-19T01:00:00Z",
        author_or_agent=row(kind="tool", id="fixture"),
        catalog=analyzer_catalog,
    )
    assert result.document["relationships"] == (relationship,)
    assert (
        cast("JsonObject", result.document["capture"])["timestamp"]
        == "2026-10-19T01:00:00Z"
    )
