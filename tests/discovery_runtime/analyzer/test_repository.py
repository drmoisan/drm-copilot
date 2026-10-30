"""Verify truthful repository inventory, stable identity and unchanged source bytes."""

from __future__ import annotations

import hashlib
import json
from dataclasses import replace
from typing import TYPE_CHECKING, cast

import pytest
from drm_copilot_discovery.analyzer.findings import row
from drm_copilot_discovery.analyzer.input_capture import capture_snapshot
from drm_copilot_discovery.analyzer.inventory import RepositoryAnalyzer
from drm_copilot_discovery.analyzer.models import InventoryCapture, InventoryInput
from drm_copilot_discovery.analyzer.pipeline import run_inventory
from drm_copilot_discovery.catalog import load_catalog
from drm_copilot_discovery.coverage_scope_rules import inventory_configuration_digest
from drm_copilot_discovery.models import JsonObject, canonical_json
from drm_copilot_discovery.profile_v2 import ProfileV2
from drm_copilot_discovery.repository_reader import RepositoryFile, RepositoryIdentity
from drm_copilot_discovery.schema_validation import validate_document
from drm_copilot_discovery.snapshot import SnapshotFile

from tests.discovery_runtime.test_profile_v2 import profile_document
from tests.discovery_runtime.validation_test_support import captured
from tests.schemas.discovery.v2_schema_test_support import as_object

if TYPE_CHECKING:
    from drm_copilot_discovery.catalog import SchemaCatalog


@pytest.fixture(scope="module")
def analyzer_catalog() -> SchemaCatalog:
    """Share immutable installed schemas while each test constructs isolated inputs.

    Takes no caller arguments.

    Returns SchemaCatalog containing immutable installed schemas; reads those
    checked-in resources only.
    """
    return load_catalog()


def inventory_profile(catalog: SchemaCatalog, **changes: object) -> ProfileV2:
    """Build a neutral configured local-source profile with deterministic selectors.

    Parameters: catalog (SchemaCatalog): trusted immutable schema catalog. changes
    (object): explicit profile field overrides.

    Returns ProfileV2 after schema validation; invalid overrides raise ProfileError.
    No I/O or input mutation.
    """
    value = profile_document()
    as_object(value["system"])["role"] = "legacy-source"
    value.update(
        repositories=[],
        clients=[],
        production_roots=["src"],
        test_roots=[],
        project_entry_points=[],
        documentation_roots=["docs"],
        excluded_paths=[],
        analyzers={
            "enabled": ["repository"],
            "options": {},
            "ignored_paths": [],
            "extension_result_manifests": [],
        },
    )
    value.update(changes)
    return ProfileV2(json.dumps(value), format="json", catalog=catalog)


def inventory_capture(
    catalog: SchemaCatalog,
    *,
    names: tuple[str, ...] = ("src/app.sln", "src/main.cs"),
    pinned: bool = True,
) -> InventoryCapture:
    """Capture synthetic source bytes and optional independently represented Git
    blobs.

    Parameters: catalog (SchemaCatalog): trusted immutable schema catalog. names
    (tuple[str, ...]): synthetic relative source paths. pinned (bool): whether
    independent Git blobs are provided.

    Returns InventoryCapture with sorted source rows and optional pinned bytes. No
    I/O or input mutation.
    """
    profile = inventory_profile(catalog)
    # Preserve CRLF bytes so hashing cannot accidentally normalize source text.
    files = tuple(
        SnapshotFile(path=name, content=(name + "\r\n").encode(), category="source")
        for name in names
    )
    identity = RepositoryIdentity(
        id=profile.repository.id, revision=profile.repository.revision
    )
    snapshot = captured(profile, catalog, payloads=files)
    # Git blobs are represented separately from working-copy input bytes.
    snapshot = replace(
        snapshot,
        repository_files=(
            tuple(
                RepositoryFile(
                    repository=identity, path=file.path, content=file.content
                )
                for file in files
            )
            if pinned
            else ()
        ),
    )
    return capture_snapshot(snapshot)


def test_repository_detects_real_project_markers_without_claiming_inspection(
    analyzer_catalog: SchemaCatalog,
) -> None:
    """Build manifest names yield structural facts and only unassigned ledger
    proposals.

    Parameters: analyzer_catalog (SchemaCatalog): immutable installed schema
    fixture.

    Returns None. Raises AssertionError when the asserted contract differs; uses
    only test-local memory and immutable schema fixtures.
    """
    capture = inventory_capture(
        analyzer_catalog,
        names=(
            "src/a.slnx",
            "src/b.csproj",
            "src/c.fsproj",
            "src/d.vbproj",
            "src/e.vcxproj",
            "src/pyproject.toml",
            "src/package.json",
            "src/Cargo.toml",
            "src/pom.xml",
            "src/build.gradle",
            "src/z.txt",
        ),
    )
    result = run_inventory(
        capture,
        timestamp="2026-10-19T01:00:00Z",
        author_or_agent=row(kind="tool", id="fixture"),
        catalog=analyzer_catalog,
    )
    components = cast("tuple[JsonObject, ...]", result.document["components"])
    assert len(components) == 11
    # Real build filenames classify only generic structural units.
    assert sorted(str(item["component_type"]) for item in components) == ["file"] + [
        "project"
    ] * 9 + ["solution"]
    # Complete immutable provenance raises confidence without implying feature parity.
    assert all(
        item["classification"] == "detected" and item["confidence"] == "high"
        for item in components
    )
    assert not result.document["diagnostics"]
    # No detected component automatically acquires inspection or feature assignments.
    assert all(
        item["inspection_status"] == "uninspected"
        and item["disposition"] == "unassigned"
        and item["feature_refs"] == ()
        for item in result.ledger_components
    )
    assert result.document[
        "scan_configuration_sha256"
    ] == inventory_configuration_digest(capture.profile)
    assert validate_document(
        canonical_json(result.document),
        expected_kind="inventory-snapshot",
        expected_version="2.0.0",
        format="json",
        catalog=analyzer_catalog,
    ).ok


def test_semantic_identity_ignores_capture_time_but_tracks_changed_bytes(
    analyzer_catalog: SchemaCatalog,
) -> None:
    """Clock metadata changes serialized bytes without changing semantic identity.

    Parameters: analyzer_catalog (SchemaCatalog): immutable installed schema
    fixture.

    Returns None. Raises AssertionError when the asserted contract differs; uses
    only test-local memory and immutable schema fixtures.
    """
    capture = inventory_capture(analyzer_catalog)
    author = row(kind="agent", id="fixture")
    first = run_inventory(
        capture,
        timestamp="2026-10-19T01:00:00Z",
        author_or_agent=author,
        catalog=analyzer_catalog,
    )
    later = run_inventory(
        capture,
        timestamp="2026-10-19T02:00:00Z",
        author_or_agent=author,
        catalog=analyzer_catalog,
        dry_run=True,
    )
    assert first.document["id"] == later.document["id"]
    assert first.semantic_sha256 == later.semantic_sha256
    assert canonical_json(first.document) != canonical_json(later.document)
    changed = replace(
        capture,
        inputs=(
            InventoryInput(
                path="src/main.cs",
                status="inspected",
                file=SnapshotFile(
                    path="src/main.cs", content=b"changed", category="source"
                ),
            ),
        ),
    )
    different = run_inventory(
        changed,
        timestamp="2026-10-19T01:00:00Z",
        author_or_agent=author,
        catalog=analyzer_catalog,
    )
    assert different.semantic_sha256 != first.semantic_sha256


def test_order_and_paths_are_portable_and_hashes_bind_exact_bytes(
    analyzer_catalog: SchemaCatalog,
) -> None:
    """Input ordering cannot affect inventory and CRLF hashes use original bytes.

    Parameters: analyzer_catalog (SchemaCatalog): immutable installed schema
    fixture.

    Returns None. Raises AssertionError when the asserted contract differs; uses
    only test-local memory and immutable schema fixtures.
    """
    first = inventory_capture(analyzer_catalog, names=("src/z.cs", "src/État.cs"))
    second = replace(first, inputs=tuple(reversed(first.inputs)))
    one = run_inventory(
        first,
        timestamp="2026-10-19T01:00:00Z",
        author_or_agent=row(kind="human", id="reviewer"),
        catalog=analyzer_catalog,
    )
    two = run_inventory(
        second,
        timestamp="2026-10-19T01:00:00Z",
        author_or_agent=row(kind="human", id="reviewer"),
        catalog=analyzer_catalog,
    )
    assert one == two
    files = cast("tuple[JsonObject, ...]", one.document["files"])
    assert [item["path"] for item in files] == ["src/z.cs", "src/État.cs"]
    assert files[0]["sha256"] == hashlib.sha256(b"src/z.cs\r\n").hexdigest()
    assert files[0]["size"] == len(b"src/z.cs\r\n")


def test_unavailable_and_unpinned_inputs_remain_visible_blockers(
    analyzer_catalog: SchemaCatalog,
) -> None:
    """Read failures and absent immutable proof cannot become verified source claims.

    Parameters: analyzer_catalog (SchemaCatalog): immutable installed schema
    fixture.

    Returns None. Raises AssertionError when the asserted contract differs; uses
    only test-local memory and immutable schema fixtures.
    """
    capture = inventory_capture(analyzer_catalog, pinned=False)
    capture = replace(
        capture,
        inputs=capture.inputs
        + (
            InventoryInput(
                path="src/blocked.cs", status="unreadable", rationale="Access denied."
            ),
            InventoryInput(
                path="src/vendor", status="excluded", rationale="External dependency."
            ),
        ),
    )
    result = run_inventory(
        capture,
        timestamp="2026-10-19T01:00:00Z",
        author_or_agent=row(kind="tool", id="fixture"),
        catalog=analyzer_catalog,
    )
    files = cast("tuple[JsonObject, ...]", result.document["files"])
    # Select the explicit failed input instead of accepting an empty result.
    blocked = next(item for item in files if item["status"] == "unreadable")
    assert (
        blocked["sha256"] is None
        and blocked["size"] is None
        and blocked["diagnostic_ids"]
    )
    assert len(cast("tuple[JsonObject, ...]", result.document["components"])) == 2
    # Require both read-failure and immutable-source diagnostics to survive projection.
    assert {
        item["code"]
        for item in cast("tuple[JsonObject, ...]", result.document["diagnostics"])
    } == {"input-unreadable", "source-revision-unverified"}
    # Missing immutable proof cannot silently receive high confidence.
    assert all(
        item["confidence"] == "low"
        for item in cast("tuple[JsonObject, ...]", result.document["components"])
    )


def test_renamed_sources_and_changed_pins_do_not_match_retained_git_bytes(
    analyzer_catalog: SchemaCatalog,
) -> None:
    """Repository, revision, path and exact content must all identify the same input.

    Parameters: analyzer_catalog (SchemaCatalog): immutable installed schema
    fixture.

    Returns None. Raises AssertionError when the asserted contract differs; uses
    only test-local memory and immutable schema fixtures.
    """
    original = inventory_capture(analyzer_catalog)
    # Alter each provenance dimension independently to catch partial identity checks.
    for field, value in (
        ("path", "src/other.cs"),
        ("repository", RepositoryIdentity(id="other", revision="b" * 40)),
        ("content", b"different"),
    ):
        # Keep all other source dimensions unchanged for each negative case.
        sources = tuple(
            replace(source, **{field: value}) for source in original.repository_files
        )
        analysis = RepositoryAnalyzer().analyze(
            replace(original, repository_files=sources)
        )
        assert len(analysis.diagnostics) == 2
        # Every affected component must retain the weakened confidence classification.
        assert all(item["confidence"] == "low" for item in analysis.components)
