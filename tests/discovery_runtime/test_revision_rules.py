"""Verify declared pins and exact byte identity without real Git or remote access."""

from __future__ import annotations

import hashlib
from dataclasses import replace
from typing import TYPE_CHECKING

import pytest
from drm_copilot_discovery.evidence_rules import validate_evidence
from drm_copilot_discovery.models import canonical_json
from drm_copilot_discovery.references import index_references
from drm_copilot_discovery.repository_reader import RepositoryFile, RepositoryIdentity
from drm_copilot_discovery.revision_rules import (
    RevisionInputs,
    is_full_revision,
    validate_revisions,
)
from drm_copilot_discovery.snapshot import SnapshotFile

from tests.discovery_runtime.test_evidence_rules import (
    CONTENT,
    PIN,
    captured,
    configured,
    evidence,
)
from tests.discovery_runtime.test_references import artifact, graph, source_reference
from tests.discovery_runtime.test_snapshot import snapshot_profile as snapshot_profile
from tests.discovery_runtime.test_snapshot_io import (
    snapshot_catalog as snapshot_catalog,
)

if TYPE_CHECKING:
    from drm_copilot_discovery.catalog import SchemaCatalog
    from drm_copilot_discovery.models import JsonValue
    from drm_copilot_discovery.profile_v2 import ProfileV2


@pytest.mark.parametrize(
    "revision,valid",
    [
        (PIN, True),
        ("b" * 64, True),
        ("A" * 40, False),
        ("abc123", False),
        ("HEAD", False),
        ("a" * 39, False),
        (None, False),
        (True, False),
    ],
)
def test_only_literal_full_revision_identities_are_accepted(
    revision: JsonValue, valid: bool
) -> None:
    """Revision expressions, abbreviations and coerced values cannot pin evidence."""
    assert is_full_revision(revision) is valid


@pytest.mark.parametrize("head", [PIN, "b" * 40])
def test_documentation_only_head_changes_preserve_matching_selected_source_bytes(
    snapshot_profile: ProfileV2, snapshot_catalog: SchemaCatalog, head: str
) -> None:
    """Pinned source bytes remain valid when another commit changes only documents."""
    snapshot = graph(snapshot_profile, snapshot_catalog)
    files = (
        SnapshotFile(path="src/a.py", content=CONTENT, category="source"),
        SnapshotFile(
            path="docs/note.md", content=b"new docs", category="documentation"
        ),
    )
    pinned = RepositoryFile(
        repository=RepositoryIdentity(id=snapshot_profile.repository.id, revision=PIN),
        path="src/a.py",
        content=CONTENT,
    )
    snapshot = replace(
        snapshot,
        manifest=replace(snapshot.manifest, files=files),
        repository_files=(pinned,),
        checkout=RepositoryIdentity(id=snapshot_profile.repository.id, revision=head),
    )
    result = validate_revisions(snapshot)
    assert result.findings == ()
    assert result.remote_freshness == "unknown"


@pytest.mark.parametrize(
    "case,code",
    [
        ("changed", "REVISION_SOURCE_CHANGED"),
        ("missing", "REVISION_CONTENT_UNAVAILABLE"),
        ("unpinned", "REVISION_PIN_REQUIRED"),
    ],
)
def test_selected_working_bytes_require_the_exact_configured_pin(
    snapshot_profile: ProfileV2, snapshot_catalog: SchemaCatalog, case: str, code: str
) -> None:
    """Selected files cannot use missing objects, an absent pin or replaced contents."""
    profile = (
        configured(snapshot_profile, snapshot_catalog, revision=None)
        if case == "unpinned"
        else snapshot_profile
    )
    snapshot = graph(profile, snapshot_catalog)
    file = SnapshotFile(path="tests/a.py", content=b"current", category="test")
    objects = (
        ()
        if case == "missing"
        else (
            RepositoryFile(
                repository=RepositoryIdentity(id=profile.repository.id, revision=PIN),
                path=file.path,
                content=b"previous",
            ),
        )
    )
    snapshot = replace(
        snapshot,
        manifest=replace(snapshot.manifest, files=(file,)),
        repository_files=objects,
    )
    assert [finding.code for finding in validate_revisions(snapshot).findings] == [code]


def test_wrong_checkout_identity_and_unknown_remote_state_are_separate(
    snapshot_profile: ProfileV2, snapshot_catalog: SchemaCatalog
) -> None:
    """An available wrong local repository is a defect, not evidence of remote state."""
    snapshot = replace(
        graph(snapshot_profile, snapshot_catalog),
        checkout=RepositoryIdentity(id="foreign", revision=PIN),
    )
    result = validate_revisions(snapshot)
    assert [finding.code for finding in result.findings] == [
        "REVISION_CHECKOUT_IDENTITY"
    ]
    assert result.remote_freshness == "unknown"


@pytest.mark.parametrize(
    "change,codes",
    [
        ("none", set[str]()),
        ("hash", {"REVISION_ARTIFACT_HASH"}),
        ("pin", {"REVISION_PIN_MISMATCH", "REVISION_ARTIFACT_PIN"}),
        ("role", {"REVISION_REPOSITORY"}),
    ],
)
def test_imported_contract_reference_binds_role_revision_and_exact_artifact_bytes(
    snapshot_profile: ProfileV2,
    snapshot_catalog: SchemaCatalog,
    change: str,
    codes: set[str],
) -> None:
    """Pinned source contracts reject replacement or target-only ownership."""
    profile = configured(
        snapshot_profile,
        snapshot_catalog,
        foreign_role="modernization-target" if change == "role" else "legacy-source",
    )
    target = replace(
        artifact(
            "feature-contract",
            "contract",
            repository="foreign",
            path="imports/contracts/a.json",
            origin="contracts/a.json",
            fields={"feature_id": "feature"},
        ),
        repository=RepositoryIdentity(id="foreign", revision="b" * 40),
    )
    ref = source_reference(target)
    ref["artifact_sha256"] = (
        "f" * 64
        if change == "hash"
        else hashlib.sha256(canonical_json(target.document)).hexdigest()
    )
    if change == "pin":
        ref["revision"] = "c" * 40
    source = artifact(
        "parity-matrix",
        "parity",
        repository=profile.repository.id,
        fields={
            "entries": [
                {"id": "row", "feature_id": "feature", "source_contract_ref": ref}
            ]
        },
    )
    snapshot = graph(profile, snapshot_catalog, target, source)
    result = validate_revisions(snapshot, index=index_references(snapshot))
    assert {finding.code for finding in result.findings} == codes


@pytest.mark.parametrize(
    "kind,field,repository,expected",
    [
        (
            "scope",
            "repository",
            {"id": "workspace-example", "revision": PIN},
            set[str](),
        ),
        (
            "extension-result-manifest",
            "repository",
            {"id": "workspace-example", "revision": "HEAD"},
            {"REVISION_PIN_REQUIRED"},
        ),
        (
            "implementation-record",
            "target_repository",
            {"id": "foreign", "revision": "b" * 40},
            {"REVISION_REPOSITORY"},
        ),
        (
            "source-snapshot-manifest",
            "source_repository",
            {"id": "workspace-example", "revision": PIN},
            {"REVISION_REPOSITORY"},
        ),
    ],
)
def test_declared_repositories_respect_source_and_target_roles(
    snapshot_profile: ProfileV2,
    snapshot_catalog: SchemaCatalog,
    kind: str,
    field: str,
    repository: dict[str, object],
    expected: set[str],
) -> None:
    """A valid full revision does not permit exchanging source and target ownership."""
    profile = configured(snapshot_profile, snapshot_catalog)
    record = artifact(
        kind, "record", repository=profile.repository.id, fields={field: repository}
    )
    result = validate_revisions(graph(profile, snapshot_catalog, record))
    assert {finding.code for finding in result.findings} == expected


def test_parity_repository_lists_and_entry_target_pins_are_checked(
    snapshot_profile: ProfileV2, snapshot_catalog: SchemaCatalog
) -> None:
    """Every present source/target pin is checked without requiring draft rows."""
    profile = configured(snapshot_profile, snapshot_catalog)
    record = artifact(
        "parity-matrix",
        "matrix",
        repository=profile.repository.id,
        fields={
            "source_repositories": [
                {"id": "foreign", "revision": "b" * 40},
                {"id": "foreign", "revision": None},
            ],
            "target_repositories": [
                {"id": profile.repository.id, "revision": "c" * 40}
            ],
            "entries": [
                {
                    "id": "row",
                    "target_repository": {
                        "id": profile.repository.id,
                        "revision": "HEAD",
                    },
                }
            ],
        },
    )
    result = validate_revisions(graph(profile, snapshot_catalog, record))
    assert {(finding.code, finding.pointer) for finding in result.findings} == {
        ("REVISION_PIN_MISMATCH", "/target_repositories/0"),
        ("REVISION_PIN_REQUIRED", "/entries/0/target_repository"),
    }


@pytest.mark.parametrize("imported", [True, False])
@pytest.mark.parametrize("change", ["none", "hash", "size", "missing"])
def test_transport_entry_bytes_are_verified_without_trusting_authored_success(
    snapshot_profile: ProfileV2,
    snapshot_catalog: SchemaCatalog,
    imported: bool,
    change: str,
) -> None:
    """Source and extension transport entries bind their actual captured content."""
    profile = configured(snapshot_profile, snapshot_catalog)
    kind, field = (
        ("source-snapshot-manifest", "payloads")
        if imported
        else ("extension-result-manifest", "source_inputs")
    )
    entry = {
        "path": "data.txt",
        "sha256": "f" * 64 if change == "hash" else hashlib.sha256(CONTENT).hexdigest(),
        "size": 0 if change == "size" else len(CONTENT),
    }
    record = artifact(
        kind,
        "manifest",
        repository=profile.repository.id,
        path="imports/manifest.json",
        fields={field: [entry], "transport": {"verification_status": "verified"}},
    )
    files = (
        ()
        if change == "missing"
        else ((("imports/" if imported else "") + "data.txt", CONTENT),)
    )
    result = validate_revisions(
        captured(profile, snapshot_catalog, record, files=files)
    )
    assert [finding.code for finding in result.findings] == (
        [] if change == "none" else ["REVISION_TRANSPORT_BYTES"]
    )


@pytest.mark.parametrize(
    "kind,field,child",
    [
        ("inventory-snapshot", "files", ""),
        ("inventory-snapshot", "components", "source"),
        ("coverage-ledger", "components", ""),
        ("implementation-record", "implementation_paths", ""),
        ("implementation-record", "test_references", "source"),
        ("acceptance-specification", "implementation_test_refs", ""),
    ],
)
def test_inspected_source_rows_bind_claimed_hashes_to_pinned_objects(
    snapshot_profile: ProfileV2,
    snapshot_catalog: SchemaCatalog,
    kind: str,
    field: str,
    child: str,
) -> None:
    """Declared inspected hashes must match the actual pinned objects."""
    source: dict[str, object] = {
        "repository": snapshot_profile.repository.id,
        "revision": PIN,
        "path": "src/a.py",
        "sha256": "f" * 64,
        "source_sha256": "f" * 64,
        "status": "inspected",
    }
    record = artifact(
        kind,
        "record",
        repository=snapshot_profile.repository.id,
        fields={
            "repository": snapshot_profile.repository.id,
            "revision": PIN,
            field: [{child: source} if child else source],
        },
    )
    obj = RepositoryFile(
        repository=RepositoryIdentity(id=snapshot_profile.repository.id, revision=PIN),
        path="src/a.py",
        content=CONTENT,
    )
    snapshot = captured(
        snapshot_profile, snapshot_catalog, record, files=(), objects=(obj,)
    )
    result = validate_revisions(snapshot)
    assert [finding.code for finding in result.findings] == ["REVISION_SOURCE_HASH"]


def test_matching_inventory_source_and_file_hashes_are_accepted(
    snapshot_profile: ProfileV2, snapshot_catalog: SchemaCatalog
) -> None:
    """An inspected file and component use the same immutable bytes and revision."""
    source = {
        "repository": snapshot_profile.repository.id,
        "revision": PIN,
        "path": "src/a.py",
        "sha256": hashlib.sha256(CONTENT).hexdigest(),
    }
    record = artifact(
        "inventory-snapshot",
        "inventory",
        repository=snapshot_profile.repository.id,
        fields={
            "repository": snapshot_profile.repository.id,
            "revision": PIN,
            "components": [{"component_id": "component", "source": source}],
            "files": [
                {**source, "status": "inspected", "size": len(CONTENT)},
                {"path": "excluded", "status": "excluded"},
            ],
        },
    )
    obj = RepositoryFile(
        repository=RepositoryIdentity(id=snapshot_profile.repository.id, revision=PIN),
        path="src/a.py",
        content=CONTENT,
    )
    result = validate_revisions(
        captured(snapshot_profile, snapshot_catalog, record, files=(), objects=(obj,))
    )
    assert result.findings == ()


@pytest.mark.parametrize("change", ["none", "owner", "pin", "storage"])
def test_transported_evidence_uses_its_origin_root_and_immutable_identity(
    snapshot_profile: ProfileV2, snapshot_catalog: SchemaCatalog, change: str
) -> None:
    """Foreign payloads cannot use an unrelated local name or transport root."""
    profile = configured(snapshot_profile, snapshot_catalog)
    record = evidence(
        profile,
        kind="source",
        repository="foreign",
        path="imports/evidence/record.json",
        origin="evidence/record.json",
        changes={
            "revision": "c" * 40 if change == "pin" else "b" * 40,
            "repository": profile.repository.id if change == "owner" else "foreign",
        },
    )
    record = replace(
        record, repository=RepositoryIdentity(id="foreign", revision="b" * 40)
    )
    if change == "storage":
        record = replace(record, path="imports/other.json")
    snapshot = captured(
        profile,
        snapshot_catalog,
        record,
        files=(
            ("imports/evidence/capture.txt", CONTENT),
            ("evidence/capture.txt", b"other"),
        ),
    )
    result = validate_evidence(snapshot)
    assert result.assessments[0].locally_verified is (change == "none")
    assert [finding.code for finding in result.findings] == (
        [] if change == "none" else ["EVIDENCE_CONTENT_UNAVAILABLE"]
    )


def test_imported_historical_declarations_use_their_own_pin(
    snapshot_profile: ProfileV2, snapshot_catalog: SchemaCatalog
) -> None:
    """A retained historical inventory keeps its pin without claiming current parity."""
    profile = configured(snapshot_profile, snapshot_catalog)
    record = replace(
        artifact(
            "inventory-snapshot",
            "old",
            repository="foreign",
            path="imports/old.json",
            origin="old.json",
            fields={"repository": "foreign", "revision": "c" * 40},
        ),
        repository=RepositoryIdentity(id="foreign", revision="c" * 40),
    )
    result = validate_revisions(graph(profile, snapshot_catalog, record))
    assert result.findings == ()
    assert result.remote_freshness == "unknown"


def test_malformed_rows_and_empty_drafts_do_not_raise_or_invent_remote_state(
    snapshot_profile: ProfileV2, snapshot_catalog: SchemaCatalog
) -> None:
    """Malformed shapes remain available to schema diagnostics without crashes."""
    record = artifact(
        "inventory-snapshot",
        "inventory",
        repository=snapshot_profile.repository.id,
        fields={"components": [None, {"source": None}], "files": False},
    )
    snapshot = graph(snapshot_profile, snapshot_catalog, record)
    inputs = RevisionInputs(snapshot)
    result = validate_revisions(snapshot)
    assert result.findings == ()
    assert result.remote_freshness == "unknown"
    assert (
        inputs.content(
            index_references(snapshot).records[0],
            repository="foreign",
            revision=PIN,
            path="src/a.py",
        )
        is None
    )
