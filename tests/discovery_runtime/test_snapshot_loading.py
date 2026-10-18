"""Exercise complete configured snapshots, read integrity and role selection."""

from __future__ import annotations

import hashlib
import json
from dataclasses import replace
from typing import TYPE_CHECKING, cast

import pytest
from drm_copilot_discovery.repository_reader import RepositoryFile, RepositoryIdentity
from drm_copilot_discovery.snapshot_io import SnapshotIO
from drm_copilot_discovery.snapshot_loading import load_snapshot

from tests.discovery_runtime.test_profile_v2 import profile_document
from tests.discovery_runtime.test_snapshot_io import (
    PROFILE_PATH,
    MemoryStore,
    memory_workspace,
)
from tests.discovery_runtime.test_snapshot_io import (
    snapshot_catalog as snapshot_catalog,
)
from tests.schemas.discovery.v2_control_test_support import control_fixture
from tests.schemas.discovery.v2_schema_test_support import as_object, load_fixture

if TYPE_CHECKING:
    from drm_copilot_discovery.catalog import SchemaCatalog
    from drm_copilot_discovery.path_models import PathMetadata


class MemoryRepository:
    """Keep pinned Git bytes and requests separate from mutable working-tree bytes."""

    def __init__(self, files: dict[tuple[str, str], bytes] | None = None) -> None:
        """Create one local repository with explicit full-pinned object storage."""
        self.files = dict(files or {})
        self.checkout = RepositoryIdentity(id="workspace-example", revision="a" * 40)
        self.requests: list[tuple[str, str]] = []

    def identity(self) -> RepositoryIdentity:
        """Return explicit memory state without cwd or neighboring discovery."""
        return self.checkout

    def read_file(self, *, revision: str, path: str, limit: int) -> RepositoryFile:
        """Return exactly requested immutable bytes; missing objects fail visibly."""
        self.requests.append((revision, path))
        return RepositoryFile(
            repository=RepositoryIdentity(id=self.checkout.id, revision=revision),
            path=path,
            content=self.files[revision, path],
        )


def put_document(store: MemoryStore, path: str, document: dict[str, object]) -> None:
    """Serialize fresh structured test data into the isolated memory store."""
    store.put(path, json.dumps(document).encode())


def add_runtime(
    store: MemoryStore, path: str, *, revision: str | None = "a" * 40
) -> str:
    """Declare a schema-valid local runtime capture without implying graph validity."""
    document = load_fixture("evidence-reference")
    document.update(repository="workspace-example", revision=revision, path=path)
    as_object(document["runtime_artifact"])["path"] = path
    as_object(document["checksum"])["value"] = hashlib.sha256(
        store.files[path]
    ).hexdigest()
    record = "docs/migration/discovery/evidence/runtime.yaml"
    put_document(store, record, document)
    return record


def test_complete_snapshot_keeps_raw_inputs_missing_paths_and_pinned_source(
    snapshot_catalog: SchemaCatalog,
) -> None:
    """All categories retain exact bytes without separate reads for hashes."""
    store, document = memory_workspace()
    store.put("src/a.py", b"new\r\n")
    store.put("tests/test_a.py", b"test\n")
    store.put("docs/readme.md", b"documentation")
    put_document(
        store,
        "config/discovery.json",
        {
            "schema_version": "2.0.0",
            "enabled": True,
            "required_runtime_major": 2,
            "profile_path": PROFILE_PATH,
        },
    )
    repository = MemoryRepository(
        {("a" * 40, "src/a.py"): b"old\n", ("a" * 40, "tests/test_a.py"): b"test\n"}
    )
    snapshot = load_snapshot(
        io=store.io(),
        profile_path=PROFILE_PATH,
        repository=repository,
        catalog=snapshot_catalog,
    )
    assert snapshot.ok and snapshot.catalog is snapshot_catalog
    assert snapshot.file(PROFILE_PATH).content == json.dumps(document).encode()
    assert snapshot.file("config/discovery.json").category == "activation"
    assert snapshot.file("src/a.py").content == b"new\r\n"
    assert snapshot.file("tests/test_a.py").category == "test"
    assert snapshot.file("docs/readme.md").category == "documentation"
    assert snapshot.repository_files[0].content == b"old\n"
    assert "docs/migration/discovery/scope.yaml" in snapshot.manifest.missing_paths
    assert snapshot.manifest.source_repositories == (repository.checkout,)
    assert snapshot.manifest.target_repositories == ()


@pytest.mark.parametrize("extension", ["bin", "json", "yaml"])
def test_runtime_revision_is_metadata_and_does_not_require_capture_in_git(
    extension: str, snapshot_catalog: SchemaCatalog
) -> None:
    """A new runtime capture need not exist in the application's commit."""
    store, _ = memory_workspace()
    path = f"docs/migration/discovery/evidence/capture.{extension}"
    store.put(path, b'{"before": 0, "after": 1}')
    record = add_runtime(store, path)
    repository = MemoryRepository()
    snapshot = load_snapshot(
        io=store.io(),
        profile_path=PROFILE_PATH,
        repository=repository,
        catalog=snapshot_catalog,
    )
    assert snapshot.ok and not repository.requests
    assert snapshot.file(path).category == "evidence"
    assert [artifact.path for artifact in snapshot.artifacts] == [record]


def test_runtime_payload_cannot_remove_selected_source_from_pinned_reads(
    snapshot_catalog: SchemaCatalog,
) -> None:
    """A second evidence role cannot erase selected source bytes or Git obligations."""
    store, _ = memory_workspace()
    store.put("src/capture.cs", b"source bytes")
    add_runtime(store, "src/capture.cs", revision=None)
    repository = MemoryRepository({("a" * 40, "src/capture.cs"): b"pinned source"})
    snapshot = load_snapshot(
        io=store.io(),
        profile_path=PROFILE_PATH,
        repository=repository,
        catalog=snapshot_catalog,
    )
    assert snapshot.ok
    assert snapshot.file("src/capture.cs").category == "source"
    assert repository.requests == [("a" * 40, "src/capture.cs")]
    assert snapshot.repository_files[0].content == b"pinned source"


def test_equivalent_directory_name_order_does_not_change_snapshot(
    snapshot_catalog: SchemaCatalog,
) -> None:
    """Native directory order is normalized without losing duplicate detection."""
    store, _ = memory_workspace()
    store.put("src/b", b"b")
    store.put("src/a", b"a")
    original = load_snapshot(
        io=store.io(), profile_path=PROFILE_PATH, catalog=snapshot_catalog
    )
    turn = 0

    def reordered(path: str) -> PathMetadata:
        """Alternate complete child order while preserving the same filesystem state."""
        nonlocal turn
        turn += 1
        entry = store.metadata(path)
        return replace(
            entry,
            children=tuple(reversed(entry.children)) if turn % 2 else entry.children,
        )

    io = SnapshotIO(
        workspace_root="/workspace", metadata=reordered, read_bytes=store.read
    )
    snapshot = load_snapshot(io=io, profile_path=PROFILE_PATH, catalog=snapshot_catalog)
    assert snapshot.ok and snapshot.sha256 == original.sha256


@pytest.mark.parametrize(
    "key,kind",
    [
        ("scope", "scope"),
        ("coverage_ledger", "coverage-ledger"),
        ("unspecified_behaviors", "unspecified-behavior-collection"),
        ("product_decisions", "product-decision-collection"),
        ("parity_matrix", "parity-matrix"),
        ("feature_contracts", "feature-contract"),
        ("characterization", "runtime-characterization-scenario"),
        ("inventory", "inventory-snapshot"),
        ("acceptance", "acceptance-specification"),
        ("implementation_records", "implementation-record"),
    ],
)
def test_every_structured_artifact_location_has_an_authoritative_expected_kind(
    key: str, kind: str, snapshot_catalog: SchemaCatalog
) -> None:
    """Artifact kind selection follows profile locations, not untrusted $schema URIs."""
    store, document = memory_workspace()
    location = cast("str", as_object(document["artifacts"])[key])
    path = (
        location
        if location.endswith((".json", ".yaml", ".yml"))
        else location + "/entry.yaml"
    )
    put_document(store, path, load_fixture(kind))
    snapshot = load_snapshot(
        io=store.io(), profile_path=PROFILE_PATH, catalog=snapshot_catalog
    )
    assert snapshot.ok, snapshot.findings
    assert len(snapshot.artifacts) == 1
    assert snapshot.artifacts[0].expected_kind == kind
    assert snapshot.file(path).content == store.files[path]


@pytest.mark.parametrize(
    "name,content",
    [
        ("feature-contracts/bad.yaml", b"duplicate: 1\nduplicate: 2\n"),
        ("feature-contracts/wrong.json", b'{"$schema":"https://evil.invalid/schema"}'),
        ("unknown.txt", b"unrecognized"),
        ("feature-contracts/hidden.txt", b"unknown"),
        ("reports/unrecognized.json", b"{}"),
        ("source-snapshots/orphan.bin", b"orphan"),
    ],
)
def test_unrecognized_or_malformed_artifact_files_block_without_being_omitted(
    name: str, content: bytes, snapshot_catalog: SchemaCatalog
) -> None:
    """Every file in an artifact location remains captured, including malformed ones."""
    store, document = memory_workspace()
    root = cast("str", as_object(document["artifacts"])["root"])
    # Use actual configured contract roots rather than assuming a spelling.
    name = name.replace("feature-contracts", contract_directory(document))
    path = f"{root}/{name}"
    store.put(path, content)
    snapshot = load_snapshot(
        io=store.io(), profile_path=PROFILE_PATH, catalog=snapshot_catalog
    )
    assert not snapshot.ok and snapshot.findings
    assert snapshot.file(path).content == content


def contract_directory(document: dict[str, object]) -> str:
    """Find the fixture contract directory relative to its declared parent root."""
    roots = as_object(document["artifacts"])
    return cast("str", roots["feature_contracts"])[
        len(cast("str", roots["root"])) + 1 :
    ]


def test_reports_and_acceptance_views_are_captured_without_claiming_completion(
    snapshot_catalog: SchemaCatalog,
) -> None:
    """Derived views remain inputs; later rules assess authored ready fields."""
    store, document = memory_workspace()
    roots = as_object(document["artifacts"])
    report = f"{roots['reports']}/completion-report.json"
    store.put(report, b'{"ready":true}')
    store.put(f"{roots['reports']}/coverage-report.md", b"# Coverage")
    store.put(f"{roots['acceptance']}/feature.feature", b"Feature: example")
    snapshot = load_snapshot(
        io=store.io(), profile_path=PROFILE_PATH, catalog=snapshot_catalog
    )
    assert snapshot.ok
    assert snapshot.artifacts[0].expected_kind == "completion-report"
    assert len(snapshot.manifest.files) == 4


@pytest.mark.parametrize("kind", ["migration-report", "required-output-manifest"])
def test_structured_report_artifacts_use_their_fixed_schemas(
    kind: str, snapshot_catalog: SchemaCatalog
) -> None:
    """Reports with installed schema contracts validate through the same catalog."""
    store, document = memory_workspace()
    path = f"{as_object(document['artifacts'])['reports']}/{kind}.json"
    put_document(store, path, control_fixture(kind))
    snapshot = load_snapshot(
        io=store.io(), profile_path=PROFILE_PATH, catalog=snapshot_catalog
    )
    assert snapshot.ok, snapshot.findings
    assert snapshot.artifacts[0].expected_kind == kind


def test_injected_git_reader_cannot_return_another_path(
    snapshot_catalog: SchemaCatalog,
) -> None:
    """A successful adapter response still needs the exact requested pin/path."""
    store, _ = memory_workspace()
    store.put("src/a", b"source")

    class WrongPathRepository(MemoryRepository):
        """Model an incorrectly implemented adapter without external reads."""

        def read_file(self, *, revision: str, path: str, limit: int) -> RepositoryFile:
            """Return a different name while keeping the original object bytes."""
            return replace(
                super().read_file(revision=revision, path=path, limit=limit),
                path="src/other",
            )

    repository = WrongPathRepository({("a" * 40, "src/a"): b"source"})
    with pytest.raises(ValueError, match="different repository, pin, or path"):
        load_snapshot(
            io=store.io(),
            profile_path=PROFILE_PATH,
            repository=repository,
            catalog=snapshot_catalog,
        )


def test_exclusions_are_explicit_and_cannot_hide_artifact_files(
    snapshot_catalog: SchemaCatalog,
) -> None:
    """Source exclusions cannot hide matching unknown artifact files."""
    store, document = memory_workspace()
    document["excluded_paths"] = [
        {"path_or_glob": "**/ignored.bin", "rationale": "Synthetic excluded source"}
    ]
    put_document(store, PROFILE_PATH, document)
    store.put("src/ignored.bin", b"ignored source")
    store.put("docs/migration/discovery/ignored.bin", b"still an artifact input")
    snapshot = load_snapshot(
        io=store.io(), profile_path=PROFILE_PATH, catalog=snapshot_catalog
    )
    assert not snapshot.ok
    assert snapshot.excluded_paths == ("src/ignored.bin",)
    assert "src/ignored.bin" not in dict(
        (file.path, file.content) for file in snapshot.manifest.files
    )


def test_historical_source_evidence_keeps_both_pins_without_using_document_head(
    snapshot_catalog: SchemaCatalog,
) -> None:
    """Historical source bytes stay distinct from the current selected pin."""
    store, _ = memory_workspace()
    store.put("src/a.py", b"working tree")
    evidence = load_fixture("evidence-reference")
    evidence.update(
        evidence_type="source",
        repository="workspace-example",
        path="src/a.py",
        revision="b" * 40,
        runtime_artifact=None,
    )
    put_document(store, "docs/migration/discovery/evidence/source.yaml", evidence)
    repository = MemoryRepository(
        {
            ("a" * 40, "src/a.py"): b"current pin",
            ("b" * 40, "src/a.py"): b"historical pin",
        }
    )
    snapshot = load_snapshot(
        io=store.io(),
        profile_path=PROFILE_PATH,
        repository=repository,
        catalog=snapshot_catalog,
    )
    assert snapshot.ok
    assert [item.content for item in snapshot.repository_files] == [
        b"current pin",
        b"historical pin",
    ]


def test_combined_source_target_roles_and_related_pins_do_not_read_neighbors(
    snapshot_catalog: SchemaCatalog,
) -> None:
    """Related repository pins appear in role lists without selecting another reader."""
    store = MemoryStore()
    document = profile_document()
    put_document(store, PROFILE_PATH, document)
    snapshot = load_snapshot(
        io=store.io(), profile_path=PROFILE_PATH, catalog=snapshot_catalog
    )
    assert snapshot.ok
    assert {item.id for item in snapshot.manifest.source_repositories} == {
        "workspace-example",
        "source-example",
    }
    assert {item.id for item in snapshot.manifest.target_repositories} == {
        "workspace-example",
        "target-example",
    }
    assert all(not path.startswith("../") for path, _ in store.calls)


def test_wrong_repository_identity_and_mid_load_checkout_change_fail(
    snapshot_catalog: SchemaCatalog,
) -> None:
    """The injected reader cannot substitute another repository or mutable checkout."""
    store, _ = memory_workspace()
    repository = MemoryRepository()
    repository.checkout = RepositoryIdentity(id="neighbor", revision="a" * 40)
    with pytest.raises(ValueError, match="configured local repository"):
        load_snapshot(
            io=store.io(),
            profile_path=PROFILE_PATH,
            repository=repository,
            catalog=snapshot_catalog,
        )

    class ChangingRepository(MemoryRepository):
        """Model one checkout change between the two identity observations."""

        def identity(self) -> RepositoryIdentity:
            """Return the current pin then change only this memory instance."""
            result = self.checkout
            self.checkout = RepositoryIdentity(id=result.id, revision="b" * 40)
            return result

    with pytest.raises(OSError, match="checkout changed"):
        load_snapshot(
            io=store.io(),
            profile_path=PROFILE_PATH,
            repository=ChangingRepository(),
            catalog=snapshot_catalog,
        )
