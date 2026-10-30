"""Exercise injected path metadata without host filesystem or process operations."""

from __future__ import annotations

import json
from dataclasses import replace
from pathlib import PurePosixPath, PureWindowsPath
from typing import TYPE_CHECKING, cast

import pytest
from drm_copilot_discovery.catalog import load_catalog
from drm_copilot_discovery.path_models import PathMetadata, PathPolicyError, WriteGrant
from drm_copilot_discovery.path_policy import FILE_KEYS, PathPolicy
from drm_copilot_discovery.profile_v2 import parse_profile_v2

from tests.discovery_runtime.test_profile_v2 import profile_document

if TYPE_CHECKING:
    from drm_copilot_discovery.catalog import SchemaCatalog
    from drm_copilot_discovery.path_models import PathKind
    from drm_copilot_discovery.profile_v2 import ProfileV2


class MemoryPaths:
    """Model one filesystem per test with explicit identity, names and failures.

    add/remove update only this instance. Direct entries overrides model races or
    an inconsistent adapter. Pure paths give Windows/POSIX fixtures on any host.
    """

    def __init__(self, workspace: str = "/workspace") -> None:
        """Create an ordinary root; perform no actual filesystem operation."""
        self.root = (
            PureWindowsPath(workspace)
            if ":" in workspace or workspace.startswith("\\\\")
            else PurePosixPath(workspace)
        )
        self.entries = {
            ".": PathMetadata(
                kind="directory", identity="root", resolved_path=self.root.as_posix()
            )
        }
        self.failures: set[str] = set()
        self.calls: list[str] = []

    def add(
        self,
        path: str,
        kind: PathKind = "file",
        *,
        identity: str | None = None,
        actual: str | None = None,
    ) -> None:
        """Create memory parents and one entry, preserving complete child names."""
        parts = path.split("/")
        parent = "."
        # Build ordinary ancestors only in the fake, never in the real filesystem.
        for index, part in enumerate(parts):
            current = "/".join(parts[: index + 1])
            prior = self.entries[parent]
            self.entries[parent] = replace(
                prior, children=tuple(sorted(set(prior.children + (part,))))
            )
            final = index == len(parts) - 1
            if final or current not in self.entries:
                self.entries[current] = PathMetadata(
                    kind=kind if final else "directory",
                    identity=identity if final and identity is not None else current,
                    resolved_path=(
                        actual
                        if final and actual is not None
                        else self.root.joinpath(*parts[: index + 1]).as_posix()
                    ),
                )
            parent = current

    def remove(self, path: str) -> None:
        """Remove one leaf and its enumeration name in this fake only."""
        parent, _, name = path.rpartition("/")
        prior = self.entries[parent or "."]
        # Remove only this leaf's enumeration entry, preserving all other names.
        self.entries[parent or "."] = replace(
            prior, children=tuple(item for item in prior.children if item != name)
        )
        self.entries.pop(path)

    def __call__(self, path: str) -> PathMetadata:
        """Return explicit metadata or absence, with controllable read failure."""
        self.calls.append(path)
        if path in self.failures:
            raise PermissionError("Synthetic unreadable metadata")
        return self.entries.get(path, PathMetadata(kind="missing"))


@pytest.fixture(scope="module")
def path_catalog() -> SchemaCatalog:
    """Reuse immutable installed schemas without sharing mutable profile/fake state."""
    return load_catalog()


@pytest.fixture(scope="module")
def path_profile(path_catalog: SchemaCatalog) -> ProfileV2:
    """Share only an immutable schema-validated profile; fake state stays local."""
    return parse_profile_v2(
        json.dumps(profile_document()), format="json", catalog=path_catalog
    )


def configured_policy(
    profile: ProfileV2, *, workspace: str = "/workspace"
) -> tuple[PathPolicy, MemoryPaths]:
    """Supply a complete memory-only profile layout with ordinary files/parents."""
    filesystem = MemoryPaths(workspace)
    # The fake preserves declared input kinds; the policy cannot infer directories.
    for directory in (
        profile.production_roots
        + profile.test_roots
        + profile.documentation_roots
        + profile.evidence_roots
    ):
        filesystem.add(directory, "directory")
    # File entry points and activation remain inputs, not controlled outputs.
    for path in profile.project_entry_points + ("config/discovery.json",):
        filesystem.add(path)
    # Populate parent locations before their nested children without resetting children.
    for key, path in sorted(
        profile.artifacts.data.items(), key=lambda item: len(cast("str", item[1]))
    ):
        filesystem.add(cast("str", path), "file" if key in FILE_KEYS else "directory")
    return (
        PathPolicy(profile, workspace_root=workspace, metadata=filesystem),
        filesystem,
    )


@pytest.mark.parametrize(
    "workspace",
    ["/workspace", "C:/Workspace", r"C:\Workspace", r"\\server\share\Workspace"],
)
def test_resolve_inputs_and_outputs_independently_of_host(
    path_profile: ProfileV2, workspace: str
) -> None:
    """Absolute trusted roots vary; artifact spelling and policy remain portable."""
    policy, filesystem = configured_policy(path_profile, workspace=workspace)
    filesystem.add("src/Feature Handler.cs")

    read = policy.resolve_read("src/Feature Handler.cs")
    path = path_profile.artifacts["feature_contracts"] + "/feature.alpha.json"
    grant = WriteGrant(
        artifact_kind="feature-contract", artifact_id="feature.alpha", path=path
    )
    write = policy.resolve_write(path, grant=grant)

    assert (
        read.absolute_path
        == filesystem.root.joinpath("src", "Feature Handler.cs").as_posix()
    )
    assert read.grant is None and read.observations[-1].kind == "file"
    assert write.path == path and write.grant == grant
    assert write.observations[-1].kind == "missing"
    assert policy.revalidate_write(write) == write
    assert policy.validate_configuration()


@pytest.mark.parametrize("kind", ["symlink", "reparse"])
@pytest.mark.parametrize("position", ["root", "ancestor", "leaf"])
def test_every_link_or_reparse_entry_is_rejected(
    path_profile: ProfileV2, kind: PathKind, position: str
) -> None:
    """Even an inside-workspace target cannot authorize following a directory link."""
    policy, filesystem = configured_policy(path_profile)
    filesystem.add("src/child/file.cs")
    path = {"root": ".", "ancestor": "src/child", "leaf": "src/child/file.cs"}[position]
    prior = filesystem.entries[path]
    filesystem.entries[path] = replace(prior, kind=kind, children=())

    with pytest.raises(PathPolicyError, match="PATH_LINK"):
        policy.resolve_read("src/child/file.cs")


@pytest.mark.parametrize(
    "actual",
    [
        "/workspace-other/src/file.cs",
        "/neighbor/src/file.cs",
        "C:/workspace/src/file.cs",
    ],
)
def test_resolved_escape_and_sibling_prefix_traps_fail(
    path_profile: ProfileV2, actual: str
) -> None:
    """An allowed lexical name cannot conceal another physical root or drive."""
    policy, filesystem = configured_policy(path_profile)
    filesystem.add("src/file.cs", actual=actual)

    with pytest.raises(PathPolicyError, match="PATH_ESCAPE"):
        policy.resolve_read("src/file.cs")


@pytest.mark.parametrize(
    "actual", ["/workspace/src/other.cs", "/workspace/src/File.cs"]
)
def test_exact_resolved_spelling_blocks_aliases(
    path_profile: ProfileV2, actual: str
) -> None:
    """Case-sensitive hosts cannot turn an alternate physical path into the input."""
    policy, filesystem = configured_policy(path_profile)
    filesystem.add("src/file.cs", actual=actual)

    with pytest.raises(PathPolicyError, match="PATH_ALIAS"):
        policy.resolve_read("src/file.cs")


def test_short_name_alias_cannot_authorize_existing_file(
    path_profile: ProfileV2,
) -> None:
    """Resolved long spelling prevents treating an 8.3 alias as a distinct file."""
    policy, filesystem = configured_policy(path_profile, workspace="C:/Workspace")
    filesystem.add("src/FILE~1.CS", actual="C:/Workspace/src/File Name.cs")

    with pytest.raises(PathPolicyError, match="PATH_ALIAS"):
        policy.resolve_read("src/FILE~1.CS")


def test_repeated_directory_identity_is_a_cycle(path_profile: ProfileV2) -> None:
    """Non-following metadata still rejects cyclic or inconsistent ancestor IDs."""
    policy, filesystem = configured_policy(path_profile)
    filesystem.add("src/cycle", "directory", identity="src")
    filesystem.add("src/cycle/file.cs")

    with pytest.raises(PathPolicyError, match="PATH_CYCLE"):
        policy.resolve_read("src/cycle/file.cs")


@pytest.mark.parametrize("position", [".", "src", "src/file.cs"])
def test_unreadable_metadata_never_becomes_missing(
    path_profile: ProfileV2, position: str
) -> None:
    """Adapter failures produce actionable errors instead of inferred absence."""
    policy, filesystem = configured_policy(path_profile)
    filesystem.add("src/file.cs")
    filesystem.failures.add(position)

    with pytest.raises(PathPolicyError, match="PATH_METADATA") as error:
        policy.resolve_read("src/file.cs")

    assert isinstance(error.value.__cause__, PermissionError)


@pytest.mark.parametrize("kind", ["file", "missing", "other"])
def test_non_directory_workspace_fails(path_profile: ProfileV2, kind: PathKind) -> None:
    """A trusted root still needs ordinary existing-directory metadata."""
    policy, filesystem = configured_policy(path_profile)
    filesystem.entries["."] = (
        PathMetadata(kind="missing")
        if kind == "missing"
        else PathMetadata(kind=kind, identity="root", resolved_path="/workspace")
    )

    with pytest.raises(PathPolicyError, match="PATH_WORKSPACE|PATH_TYPE"):
        policy.resolve_read("src/file.cs")


def test_file_ancestor_and_special_leaf_fail(path_profile: ProfileV2) -> None:
    """Ordinary files cannot be traversed and special files cannot be consumed."""
    policy, filesystem = configured_policy(path_profile)
    filesystem.add("src/file")
    filesystem.add("src/device", "other")

    with pytest.raises(PathPolicyError, match="PATH_TYPE"):
        policy.resolve_read("src/file/child")
    with pytest.raises(PathPolicyError, match="PATH_TYPE"):
        policy.resolve_read("src/device")


def test_missing_read_is_explicit_and_missing_write_parents_are_projected(
    path_profile: ProfileV2,
) -> None:
    """Draft planning returns missing stamps without creating or probing descendants."""
    policy, filesystem = configured_policy(path_profile)
    with pytest.raises(PathPolicyError, match="PATH_MISSING"):
        policy.resolve_read("src/absent/file.cs")
    absent = policy.resolve_read("src/absent/file.cs", allow_missing=True)
    path = path_profile.artifacts["evidence"] + "/new/nested/capture.bin"
    before = dict(filesystem.entries)

    result = policy.resolve_write(
        path,
        grant=WriteGrant(
            artifact_kind="evidence-payload", artifact_id="capture.alpha", path=path
        ),
    )

    assert absent.observations[-1].kind == "missing"
    assert result.observations[-3].kind == "missing"
    assert path not in filesystem.calls
    assert filesystem.entries == before
    assert policy.revalidate_write(result) == result


@pytest.mark.parametrize(
    "change",
    [
        "parent-identity",
        "root-identity",
        "leaf-identity",
        "deleted-leaf",
        "new-parent",
        "link-parent",
        "alias-child",
    ],
)
def test_parent_or_target_change_invalidates_precommit_result(
    path_profile: ProfileV2, change: str
) -> None:
    """Revalidation checks fresh identities/names, not a cached lexical location."""
    policy, filesystem = configured_policy(path_profile)
    parent = path_profile.artifacts["evidence"]
    path = parent + ("/new/capture.bin" if change == "new-parent" else "/capture.bin")
    if change != "new-parent":
        filesystem.add(path)
    result = policy.resolve_write(
        path,
        grant=WriteGrant(
            artifact_kind="evidence-payload", artifact_id="capture.alpha", path=path
        ),
    )
    # Each change represents one mutation between validation and the later commit.
    if change in {"parent-identity", "root-identity", "leaf-identity"}:
        changed = {
            "parent-identity": parent,
            "root-identity": ".",
            "leaf-identity": path,
        }[change]
        filesystem.entries[changed] = replace(
            filesystem.entries[changed], identity="replacement"
        )
    elif change == "deleted-leaf":
        filesystem.remove(path)
    elif change == "new-parent":
        filesystem.add(parent + "/new", "directory")
    elif change == "link-parent":
        filesystem.entries[parent] = replace(
            filesystem.entries[parent], kind="reparse", children=()
        )
    else:
        filesystem.add(parent + "/CAPTURE.bin")

    with pytest.raises(PathPolicyError, match="PATH_CHANGED|PATH_LINK|PATH_COLLISION"):
        policy.revalidate_write(result)


def test_unrelated_sibling_change_does_not_invalidate_identity(
    path_profile: ProfileV2,
) -> None:
    """Fresh alias checking permits unrelated files while preserving the exact grant."""
    policy, filesystem = configured_policy(path_profile)
    path = path_profile.artifacts["evidence"] + "/capture.bin"
    result = policy.resolve_write(
        path,
        grant=WriteGrant(
            artifact_kind="evidence-payload", artifact_id="capture.alpha", path=path
        ),
    )
    filesystem.add(path_profile.artifacts["evidence"] + "/unrelated.bin")

    assert policy.revalidate_write(result) == result
    with pytest.raises(PathPolicyError, match="PATH_GRANT"):
        policy.revalidate_write(policy.resolve_read("src"))


@pytest.mark.parametrize("enumerated", [True, False])
def test_inconsistent_directory_metadata_fails(
    path_profile: ProfileV2, enumerated: bool
) -> None:
    """New/deleted entries between listing and inspection require a fresh snapshot."""
    policy, filesystem = configured_policy(path_profile)
    filesystem.add("src/file.cs")
    if enumerated:
        filesystem.entries.pop("src/file.cs")
    else:
        filesystem.entries["src"] = replace(filesystem.entries["src"], children=())

    with pytest.raises(PathPolicyError, match="PATH_METADATA_CHANGED"):
        policy.resolve_read("src/file.cs")
