"""Verify immutable byte manifests and deterministic input identity properties."""

from __future__ import annotations

import hashlib
import itertools
import json
from dataclasses import FrozenInstanceError, replace
from typing import TYPE_CHECKING, cast

import pytest
from drm_copilot_discovery.findings import Finding
from drm_copilot_discovery.models import JsonObject
from drm_copilot_discovery.path_models import PathPolicyError
from drm_copilot_discovery.profile_v2 import ProfileV2
from drm_copilot_discovery.repository_reader import RepositoryFile, RepositoryIdentity
from drm_copilot_discovery.snapshot import (
    ArtifactSnapshot,
    DiscoverySnapshot,
    InputManifest,
    SnapshotFile,
)

from tests.discovery_runtime.test_snapshot_io import memory_workspace
from tests.discovery_runtime.test_snapshot_io import (
    snapshot_catalog as snapshot_catalog,
)

if TYPE_CHECKING:
    from drm_copilot_discovery.catalog import SchemaCatalog
    from drm_copilot_discovery.snapshot import InputCategory


@pytest.fixture(scope="module")
def snapshot_profile(snapshot_catalog: SchemaCatalog) -> ProfileV2:
    """Share one immutable validated profile, never mutable document/store state."""
    _, document = memory_workspace()
    return ProfileV2(json.dumps(document), format="json", catalog=snapshot_catalog)


def test_manifest_permutation_property_preserves_exact_bytes_and_ordinal_names() -> (
    None
):
    """Every ordering of the same input set produces identical manifests and hashes."""
    files = tuple(
        SnapshotFile(path=path, content=path.encode(), category="source")
        for path in ("src/Z", "src/a", "src/é")
    )
    expected = InputManifest(files=files)
    # Exhaust all permutations to make the ordering invariant deterministic.
    for permutation in itertools.permutations(files):
        manifest = InputManifest(files=permutation)
        assert manifest.to_dict() == expected.to_dict()
        assert manifest.sha256 == expected.sha256
    assert [file.path for file in expected.files] == ["src/Z", "src/a", "src/é"]
    assert expected.files[0].sha256 == hashlib.sha256(b"src/Z").hexdigest()


@pytest.mark.parametrize(
    "change", ["addition", "deletion", "bytes", "category", "missing", "pin"]
)
def test_manifest_hash_changes_for_every_material_input_change(change: str) -> None:
    """Identity is bound to exact bytes, categories, absence and repository pins."""
    first = SnapshotFile(path="src/a", content=b"a\n", category="source")
    second = SnapshotFile(path="src/b", content=b"b", category="source")
    base = InputManifest(files=(first, second))
    changes = {
        "addition": replace(base, files=base.files + (replace(first, path="src/c"),)),
        "deletion": replace(base, files=(first,)),
        "bytes": replace(base, files=(replace(first, content=b"a\r\n"), second)),
        "category": replace(base, files=(replace(first, category="test"), second)),
        "missing": replace(base, missing_paths=("src/c",)),
        "pin": replace(
            base,
            source_repositories=(RepositoryIdentity(id="source", revision="a" * 40),),
        ),
    }
    assert changes[change].sha256 != base.sha256


def test_manifest_rejects_collisions_duplicate_roles_and_contradictory_absence() -> (
    None
):
    """Reject duplicate, aliased or both-present-and-missing input paths."""
    file = SnapshotFile(path="src/a", content=b"", category="source")
    with pytest.raises(PathPolicyError, match="PATH_COLLISION"):
        InputManifest(files=(file, replace(file, path="SRC/A")))
    with pytest.raises(PathPolicyError, match="PATH_COLLISION"):
        InputManifest(files=(file,), missing_paths=("src/a",))
    identity = RepositoryIdentity(id="source", revision=None)
    with pytest.raises(ValueError, match="duplicate IDs"):
        InputManifest(files=(), source_repositories=(identity, identity))


def test_value_constructors_reject_mutability_and_untyped_document_claims() -> None:
    """Mutable content/documents and unsupported categories fail before use."""
    with pytest.raises(ValueError, match="immutable bytes"):
        SnapshotFile(path="a", content=cast("bytes", bytearray()), category="source")
    with pytest.raises(ValueError, match="Unsupported"):
        SnapshotFile(path="a", content=b"", category=cast("InputCategory", "unknown"))
    identity = RepositoryIdentity(id="source", revision=None)
    with pytest.raises(ValueError, match="expected kind"):
        ArtifactSnapshot(path="a", expected_kind="", document=None, repository=identity)
    with pytest.raises(ValueError, match="immutable parsed"):
        ArtifactSnapshot(
            path="a",
            expected_kind="scope",
            document=cast("JsonObject", {}),
            repository=identity,
        )


def test_snapshot_detaches_collections_and_keeps_import_origin(
    snapshot_catalog: SchemaCatalog, snapshot_profile: ProfileV2
) -> None:
    """Caller mutation cannot change captured files or transported identity."""
    file = SnapshotFile(path="docs/import/a.json", content=b"{}", category="artifact")
    identity = RepositoryIdentity(id="source", revision="a" * 40)
    artifact = ArtifactSnapshot(
        path=file.path,
        expected_kind="scope",
        document=JsonObject(()),
        repository=identity,
        origin_path="a.json",
    )
    values = [artifact]
    snapshot = DiscoverySnapshot(
        profile=snapshot_profile,
        catalog=snapshot_catalog,
        manifest=InputManifest(files=(file,)),
        artifacts=cast("tuple[ArtifactSnapshot, ...]", values),
    )
    values.clear()
    assert snapshot.artifacts == (artifact,) and snapshot.ok
    assert snapshot.file(file.path) is file
    assert snapshot.artifacts[0].origin_path == "a.json"
    with pytest.raises(KeyError):
        snapshot.file("docs/import/missing.json")
    with pytest.raises(FrozenInstanceError):
        field = "findings"
        setattr(snapshot, field, ())
    rendered = snapshot.manifest.to_dict()
    rendered["entries"] = []
    assert snapshot.manifest.to_dict()["entries"] != []


def test_snapshot_requires_bytes_for_artifacts_and_unique_git_inputs(
    snapshot_catalog: SchemaCatalog, snapshot_profile: ProfileV2
) -> None:
    """No structured or immutable-object record may lack an unambiguous byte source."""
    identity = RepositoryIdentity(id="source", revision="a" * 40)
    artifact = ArtifactSnapshot(
        path="a", expected_kind="scope", document=None, repository=identity
    )
    with pytest.raises(ValueError, match="captured input bytes"):
        DiscoverySnapshot(
            profile=snapshot_profile,
            catalog=snapshot_catalog,
            manifest=InputManifest(files=()),
            artifacts=(artifact,),
        )
    obj = RepositoryFile(repository=identity, path="src/a", content=b"a")
    with pytest.raises(ValueError, match="Duplicate pinned"):
        DiscoverySnapshot(
            profile=snapshot_profile,
            catalog=snapshot_catalog,
            manifest=InputManifest(files=()),
            repository_files=(obj, obj),
        )


def test_snapshot_hash_binds_git_checkout_objects_and_exclusions(
    snapshot_catalog: SchemaCatalog, snapshot_profile: ProfileV2
) -> None:
    """Immutable source bytes and checkout state remain distinct from authored pins."""
    base = DiscoverySnapshot(
        profile=snapshot_profile,
        catalog=snapshot_catalog,
        manifest=InputManifest(files=()),
    )
    identity = RepositoryIdentity(id="source", revision="a" * 40)
    obj = RepositoryFile(repository=identity, path="src/a", content=b"old")
    candidates = (
        replace(base, checkout=identity),
        replace(base, repository_files=(obj,)),
        replace(base, excluded_paths=("src/vendor",)),
    )
    assert len({base.sha256, *(candidate.sha256 for candidate in candidates)}) == 4
    finding = Finding(
        code="INPUT_INVALID", message="Invalid input", next_action="Correct it"
    )
    assert not replace(base, findings=(finding,)).ok
    assert replace(base, findings=(replace(finding, severity="info"),)).ok
