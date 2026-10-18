"""Verify portable lexical policy and immutable path values with pure tests."""

from __future__ import annotations

from dataclasses import FrozenInstanceError
from itertools import permutations
from typing import TYPE_CHECKING, cast

import pytest
from drm_copilot_discovery.path_models import (
    PathKind,
    PathMetadata,
    PathPolicyError,
    PathStamp,
    ResolvedPath,
    WriteGrant,
    check_path_collisions,
    collision_key,
    path_contains,
    relative_path,
)
from drm_copilot_discovery.path_policy import PathPolicy

from tests.discovery_runtime.test_path_resolution import MemoryPaths, configured_policy
from tests.discovery_runtime.test_path_resolution import path_catalog as path_catalog
from tests.discovery_runtime.test_path_resolution import path_profile as path_profile

if TYPE_CHECKING:
    from drm_copilot_discovery.profile_v2 import ProfileV2


@pytest.mark.parametrize(
    "path",
    [
        "",
        ".",
        "..",
        "/root/file",
        "//server/share/file",
        r"\root\file",
        "C:relative",
        "C:/absolute",
        r"C:\absolute",
        r"\\server\share\file",
        r"\\?\C:\file",
        r"\\.\COM1",
        "//?/C:/file",
        "//./pipe/name",
        "a/../b",
        "a/./b",
        "a//b",
        "a/",
        "a\\b",
        "a:b",
        "a.txt:stream",
        "a/space ",
        "a/dot.",
        "a/   ",
        "a/...",
        'a/quo"te',
        "a/\x00",
        "a/\x01",
        "a/\x1f",
        "a/\x7f",
        "a/\n",
        "a/\u2028",
        "a/\u2029",
        "a/*",
        "a/?",
        "a/<",
        "a/>",
        "a/|",
        "a/\ud800",
    ],
)
def test_unsafe_portable_spellings_are_rejected_without_normalization(
    path: str,
) -> None:
    """Traversal, device/drive namespaces, ADS and separators fail before I/O."""
    with pytest.raises(PathPolicyError, match="PATH_SYNTAX") as error:
        relative_path(path)

    assert error.value.path == path and "\n" not in str(error.value)


@pytest.mark.parametrize(
    "name",
    [
        "CON",
        "PRN",
        "AUX",
        "NUL",
        "COM1",
        "COM9",
        "COM¹",
        "COM²",
        "COM³",
        "LPT1",
        "LPT9",
        "LPT¹",
        "LPT²",
        "LPT³",
        "CONIN$",
        "CONOUT$",
        "CLOCK$",
    ],
)
@pytest.mark.parametrize("suffix", ["", ".txt", ".tar.gz", " .json"])
def test_device_stems_remain_reserved_in_any_directory(name: str, suffix: str) -> None:
    """A suffix or different case cannot turn a reserved device into an output."""
    with pytest.raises(PathPolicyError, match="PATH_RESERVED"):
        relative_path("docs/" + name.lower() + suffix)


@pytest.mark.parametrize(
    "path",
    [
        "docs/Feature Contract.yaml",
        "docs/évidence.json",
        "docs/e\u0301vidence.json",
        ".migration/Record.json",
        "資料/行為.json",
        "docs/COM10.txt",
        "docs/LPT0.txt",
        "docs/null.json",
        "docs/%2e%2e/name.json",
        "docs/a~1.json",
        "docs/a..b",
    ],
)
def test_valid_relative_spelling_is_preserved_and_idempotent(path: str) -> None:
    """Safe Unicode/capital/space paths remain exact; no URL decoding is applied."""
    assert relative_path(path) == path
    assert relative_path(relative_path(path)) == path
    assert collision_key(path) == collision_key(path.casefold())


@pytest.mark.parametrize(
    "root,child",
    [("src", "src/file.cs"), ("Notes", "notes/Évidence/a.json"), ("a/b", "a/b/c/d")],
)
def test_component_containment_properties(root: str, child: str) -> None:
    """Containment is transitive/reflexive and never accepts a sibling prefix."""
    assert path_contains(root, root)
    assert not path_contains(root, root, strict=True)
    assert path_contains(root, child, strict=True)
    assert path_contains(root, child + "/last", strict=True)
    assert not path_contains(child, root)
    assert not path_contains(root, root + "-other/file")


def test_collision_order_is_deterministic_and_identical_ancestors_are_allowed() -> None:
    """Permutation never changes a successful path set or its sorted result."""
    paths = ("docs/alpha.json", "docs/beta.json", "src/main.cs")
    # Enumerate the complete small permutation space without ambient randomness.
    for ordering in permutations(paths):
        assert check_path_collisions(ordering) == tuple(sorted(paths))
    assert check_path_collisions(()) == ()


@pytest.mark.parametrize(
    "paths",
    [
        ("docs/a", "docs/a"),
        ("docs/a", "docs/A"),
        ("Docs/a", "docs/b"),
        ("docs/é", "docs/e\u0301"),
        ("docs/Straße/a", "docs/STRASSE/b"),
    ],
)
def test_duplicate_and_ancestor_aliases_fail_in_either_order(
    paths: tuple[str, str],
) -> None:
    """Ambiguous namespaces fail on Linux/macOS as well as Windows."""
    with pytest.raises(PathPolicyError, match="PATH_COLLISION"):
        check_path_collisions(paths)
    with pytest.raises(PathPolicyError, match="PATH_COLLISION"):
        check_path_collisions(reversed(paths))


@pytest.mark.parametrize(
    "kind,identity,actual,children",
    [
        ("unknown", "x", "/root/x", ()),
        ("file", None, "/root/x", ()),
        ("file", "x", None, ()),
        ("missing", "x", None, ()),
        ("missing", None, "/root/x", ()),
        ("file", "x", "/root/x", ("child",)),
        ("directory", "x", "/root/x", "child"),
        ("directory", "x", "/root/x", ("a/b",)),
    ],
)
def test_contradictory_metadata_is_rejected_at_construction(
    kind: str, identity: str | None, actual: str | None, children: object
) -> None:
    """The injected boundary cannot mix absence, identity or directory claims."""
    with pytest.raises(ValueError):
        PathMetadata(
            kind=cast("PathKind", kind),
            identity=identity,
            resolved_path=actual,
            children=cast("tuple[str, ...]", children),
        )


def test_metadata_and_resolution_detach_sequences_and_reject_assignment() -> None:
    """Caller list mutation does not change a captured parent/leaf observation."""
    names = ["file.json"]
    entry = PathMetadata(
        kind="directory",
        identity="parent",
        resolved_path="/workspace/docs",
        children=cast("tuple[str, ...]", names),
    )
    observations = [
        PathStamp(
            path="docs",
            kind="directory",
            identity="parent",
            resolved_path="/workspace/docs",
        )
    ]
    result = ResolvedPath(
        path="docs/file.json",
        absolute_path="/workspace/docs/file.json",
        observations=cast("tuple[PathStamp, ...]", observations),
    )
    names.append("second.json")
    observations.clear()

    assert entry.children == ("file.json",) and len(result.observations) == 1
    field = "identity"
    with pytest.raises(FrozenInstanceError):
        setattr(entry, field, "changed")


@pytest.mark.parametrize(
    "kind,identifier",
    [
        ("Feature", "feature.alpha"),
        ("feature-contract", "A"),
        ("feature-contract", "a\n"),
        ("feature-contract", ""),
    ],
)
def test_grant_requires_literal_kind_and_stable_id(kind: str, identifier: str) -> None:
    """Malformed IDs/kinds cannot become authority-bearing lookup inputs."""
    with pytest.raises(ValueError, match="write grant"):
        WriteGrant(artifact_kind=kind, artifact_id=identifier, path="docs/feature.json")


@pytest.mark.parametrize(
    "root",
    [
        "relative",
        "C:relative",
        r"\root",
        "../root",
        "/a/../root",
        "/a/./root",
        r"\\?\C:\root",
        r"\\.\pipe\root",
    ],
)
def test_trusted_workspace_still_requires_canonical_absolute_shape(
    path_profile: ProfileV2, root: str
) -> None:
    """Outer workspace syntax is validated without using the machine's current cwd."""
    with pytest.raises(PathPolicyError, match="PATH_ABSOLUTE"):
        PathPolicy(path_profile, workspace_root=root, metadata=MemoryPaths())


@pytest.mark.parametrize(
    "path",
    [
        "neighbor/file.cs",
        "src-other/file.cs",
        "Src/file.cs",
        "config/other.json",
        "Sample.sln/child",
    ],
)
def test_read_scope_cannot_expand_by_prefix_or_case(
    path_profile: ProfileV2, path: str
) -> None:
    """Only configured input/artifact scope is readable, regardless of file presence."""
    policy, filesystem = configured_policy(path_profile)
    before = len(filesystem.calls)

    with pytest.raises(PathPolicyError, match="PATH_READ_DENIED"):
        policy.resolve_read(path)

    assert len(filesystem.calls) == before


def test_policy_and_reader_contracts_fail_closed(path_profile: ProfileV2) -> None:
    """Unchecked profiles and invalid reader results cannot masquerade as absence."""
    with pytest.raises(ValueError, match="validated ProfileV2"):
        PathPolicy(
            cast("ProfileV2", object()),
            workspace_root="/workspace",
            metadata=MemoryPaths(),
        )

    def invalid_reader(path: str) -> PathMetadata:
        """Return an invalid adapter value to exercise the typed boundary guard."""
        return cast("PathMetadata", path)

    policy = PathPolicy(
        path_profile, workspace_root="/workspace", metadata=invalid_reader
    )
    with pytest.raises(PathPolicyError, match="PATH_METADATA"):
        policy.resolve_read("src")
