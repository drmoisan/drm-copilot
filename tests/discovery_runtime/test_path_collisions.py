"""Check profile separation, artifact grants and filesystem namespace collisions."""

from __future__ import annotations

import json
from dataclasses import replace
from typing import TYPE_CHECKING, cast

import pytest
from drm_copilot_discovery.path_models import PathPolicyError, WriteGrant
from drm_copilot_discovery.path_policy import PathPolicy
from drm_copilot_discovery.profile_v2 import parse_profile_v2

from tests.discovery_runtime.test_path_resolution import MemoryPaths, configured_policy
from tests.discovery_runtime.test_path_resolution import path_catalog as path_catalog
from tests.discovery_runtime.test_path_resolution import path_profile as path_profile
from tests.discovery_runtime.test_profile_v2 import (
    profile_document,
    profile_extension_catalog,
)
from tests.schemas.discovery.v2_schema_test_support import as_object

if TYPE_CHECKING:
    from drm_copilot_discovery.catalog import SchemaCatalog
    from drm_copilot_discovery.profile_v2 import ProfileV2


def relocated_profile(root: str, catalog: SchemaCatalog) -> ProfileV2:
    """Replace the whole synthetic artifact hierarchy, preserving all schema fields."""
    document = profile_document()
    artifacts = as_object(document["artifacts"])
    # Keep declared parent/child relationships while varying the configured root.
    for key, path in artifacts.items():
        artifacts[key] = cast("str", path).replace("docs/migration/discovery", root)
    return parse_profile_v2(json.dumps(document), format="json", catalog=catalog)


@pytest.mark.parametrize(
    "root",
    [
        "src/discovery",
        "tests/discovery",
        "config/discovery",
        ".git/discovery",
        ".github/discovery",
        ".claude/discovery",
        ".codex/discovery",
        ".agents/discovery",
        ".vscode/discovery",
        "schemas/discovery",
        "scripts/discovery",
        "packages/discovery",
        "extensions/discovery",
        "docs/.codex/discovery",
    ],
)
def test_output_roots_cannot_overlap_implementation_or_native_configuration(
    root: str,
    path_catalog: SchemaCatalog,
) -> None:
    """Changing output configuration cannot authorize production or policy writes."""
    profile = relocated_profile(root, path_catalog)

    with pytest.raises(PathPolicyError, match="PATH_OUTPUT_OVERLAP"):
        PathPolicy(profile, workspace_root="/workspace", metadata=MemoryPaths())


def test_custom_unicode_layout_and_separate_output_roots_are_supported(
    path_catalog: SchemaCatalog,
) -> None:
    """Consumer-chosen roots remain exact and need not share an invented location."""
    profile = relocated_profile("Notes/Évidence Records", path_catalog)
    policy, _ = configured_policy(profile)
    assert policy.validate_configuration()
    document = profile_document()
    as_object(document["artifacts"])["feature_contracts"] = "Contracts/Legacy"
    separate = parse_profile_v2(
        json.dumps(document), format="json", catalog=path_catalog
    )
    policy, _ = configured_policy(separate)
    path = "Contracts/Legacy/feature.alpha.json"

    assert (
        policy.resolve_write(
            path,
            grant=WriteGrant(
                artifact_kind="feature-contract", artifact_id="feature.alpha", path=path
            ),
        ).path
        == path
    )


@pytest.mark.parametrize(
    "field,value",
    [
        ("feature_contracts", "docs/migration/discovery/evidence"),
        ("feature_contracts", "docs/migration/discovery/Evidence"),
        ("feature_contracts", "docs/migration/discovery/evidence/contracts"),
        ("feature_contracts", "docs/migration/discovery/coverage-ledger.json/child"),
        ("root", "docs/migration/discovery/evidence/nested"),
    ],
)
def test_output_peers_cannot_collide_or_nest(
    field: str,
    value: str,
    path_catalog: SchemaCatalog,
) -> None:
    """Only the declared parent root may contain sibling artifact locations."""
    document = profile_document()
    as_object(document["artifacts"])[field] = value
    profile = parse_profile_v2(
        json.dumps(document), format="json", catalog=path_catalog
    )

    with pytest.raises(PathPolicyError, match="PATH_COLLISION|PATH_OUTPUT_OVERLAP"):
        PathPolicy(profile, workspace_root="/workspace", metadata=MemoryPaths())


def test_protection_is_bidirectional_and_host_additions_cannot_be_overridden(
    path_profile: ProfileV2,
    path_catalog: SchemaCatalog,
) -> None:
    """A broad output parent cannot contain a protected descendant."""
    with pytest.raises(PathPolicyError, match="PATH_OUTPUT_OVERLAP"):
        PathPolicy(
            path_profile,
            workspace_root="/workspace",
            metadata=MemoryPaths(),
            protected_paths=(path_profile.artifacts["root"] + "/authority",),
        )
    document = profile_document()
    document["production_roots"] = ["docs"]
    profile = parse_profile_v2(
        json.dumps(document), format="json", catalog=path_catalog
    )
    with pytest.raises(PathPolicyError, match="PATH_OUTPUT_OVERLAP"):
        PathPolicy(profile, workspace_root="/workspace", metadata=MemoryPaths())


def test_extension_schema_cannot_be_placed_in_writable_artifact_scope() -> None:
    """Pinned local extension configuration remains protected even in documentation."""
    document, catalog = profile_extension_catalog()
    as_object(document["artifacts"])["feature_contracts"] = "docs/schemas"
    profile = parse_profile_v2(json.dumps(document), format="json", catalog=catalog)

    with pytest.raises(PathPolicyError, match="extension schemas"):
        PathPolicy(profile, workspace_root="/workspace", metadata=MemoryPaths())


@pytest.mark.parametrize(
    "roots", [["src", "Src"], ["Docs/é", "Docs/e\u0301"], ["Docs/a", "docs/b"]]
)
def test_profile_input_aliases_fail_before_any_metadata_read(
    roots: list[str],
    path_catalog: SchemaCatalog,
) -> None:
    """Collision checks include differently named leaves under alias parents."""
    document = profile_document()
    document["production_roots"] = roots
    profile = parse_profile_v2(
        json.dumps(document), format="json", catalog=path_catalog
    )
    filesystem = MemoryPaths()

    with pytest.raises(PathPolicyError, match="PATH_COLLISION"):
        PathPolicy(profile, workspace_root="/workspace", metadata=filesystem)

    assert filesystem.calls == []


@pytest.mark.parametrize(
    "names,requested",
    [
        (("file.cs", "FILE.cs"), "file.cs"),
        (("é.cs", "e\u0301.cs"), "é.cs"),
        (("FILE.cs",), "file.cs"),
        (("file.cs", "file.cs"), "file.cs"),
    ],
)
def test_existing_namespace_aliases_fail_on_every_host(
    path_profile: ProfileV2, names: tuple[str, ...], requested: str
) -> None:
    """Complete sibling metadata catches ambiguity even for an exact requested name."""
    policy, filesystem = configured_policy(path_profile)
    filesystem.entries["src"] = replace(filesystem.entries["src"], children=names)

    with pytest.raises(PathPolicyError, match="PATH_COLLISION|PATH_ALIAS"):
        policy.resolve_read("src/" + requested)


@pytest.mark.parametrize(
    "kind,key,name",
    [
        ("feature-contract", "feature_contracts", "feature.alpha.json"),
        (
            "runtime-characterization-scenario",
            "characterization",
            "scenario.alpha.yaml",
        ),
        ("evidence-reference", "evidence", "evidence.alpha.json"),
        ("inventory-snapshot", "inventory", "inventory.alpha.json"),
        ("acceptance-view", "acceptance", "acceptance.alpha.feature"),
        ("completion-report", "reports", "completion-report.md"),
        (
            "implementation-record",
            "implementation_records",
            "implementation.alpha.json",
        ),
        ("source-snapshot-manifest", "source_snapshots", "snapshot.alpha.json"),
    ],
)
def test_exact_grant_is_required_even_inside_a_permitted_output_root(
    path_profile: ProfileV2, kind: str, key: str, name: str
) -> None:
    """The same artifact root cannot authorize another path or a directory overwrite."""
    policy, filesystem = configured_policy(path_profile)
    root = cast("str", path_profile.artifacts.data[key])
    path = root + "/" + name
    grant = WriteGrant(artifact_kind=kind, artifact_id="artifact.alpha", path=path)

    assert policy.resolve_write(path, grant=grant).grant == grant
    with pytest.raises(PathPolicyError, match="PATH_GRANT"):
        policy.resolve_write(root + "/another.json", grant=grant)
    with pytest.raises(PathPolicyError, match="PATH_WRITE_DENIED"):
        policy.resolve_write(root, grant=replace(grant, path=root))
    filesystem.add(root + "/directory", "directory")
    with pytest.raises(PathPolicyError, match="PATH_TYPE"):
        policy.resolve_write(
            root + "/directory", grant=replace(grant, path=root + "/directory")
        )


def test_collection_grant_only_matches_its_exact_configured_file(
    path_profile: ProfileV2,
) -> None:
    """Collection paths cannot become a directory grant or another artifact kind."""
    policy, _ = configured_policy(path_profile)
    path = path_profile.artifacts["coverage_ledger"]
    grant = WriteGrant(
        artifact_kind="coverage-ledger", artifact_id="coverage.alpha", path=path
    )

    assert policy.resolve_write(path, grant=grant).observations[-1].kind == "file"
    with pytest.raises(PathPolicyError, match="PATH_WRITE_DENIED"):
        policy.resolve_write(
            path + "/child", grant=replace(grant, path=path + "/child")
        )
    with pytest.raises(PathPolicyError, match="PATH_WRITE_DENIED"):
        policy.resolve_write(
            path, grant=replace(grant, artifact_kind="feature-contract")
        )


@pytest.mark.parametrize(
    "kind",
    [
        "domain-profile",
        "activation",
        "validation-receipt",
        "tool-authorization",
        "unknown",
    ],
)
def test_structurally_valid_grants_do_not_authorize_configuration_or_authority(
    path_profile: ProfileV2, kind: str
) -> None:
    """Host-controlled authority cannot be created through artifact output grants."""
    policy, filesystem = configured_policy(path_profile)
    path = path_profile.artifacts["profile"]

    with pytest.raises(PathPolicyError, match="PATH_GRANT"):
        policy.resolve_write(
            path,
            grant=WriteGrant(artifact_kind=kind, artifact_id="record.alpha", path=path),
        )

    assert filesystem.calls == []


@pytest.mark.parametrize(
    "name",
    [
        "AGENTS.md",
        "CLAUDE.md",
        "SKILL.md",
        "rule.schema.json",
        ".codex/hooks.json",
        ".git/config",
    ],
)
def test_nested_output_policy_names_remain_protected(
    path_profile: ProfileV2, name: str
) -> None:
    """Even an exact evidence-payload grant cannot create standing instruction files."""
    policy, _ = configured_policy(path_profile)
    path = path_profile.artifacts["evidence"] + "/" + name

    with pytest.raises(PathPolicyError, match="PATH_WRITE_DENIED"):
        policy.resolve_write(
            path,
            grant=WriteGrant(
                artifact_kind="evidence-payload", artifact_id="capture.alpha", path=path
            ),
        )


@pytest.mark.parametrize(
    "field,value",
    [
        ("project_entry_points", ["src"]),
        ("documentation_roots", ["docs/migration/discovery/scope.yaml"]),
    ],
)
def test_conflicting_input_file_and_directory_declarations_fail(
    field: str,
    value: list[str],
    path_catalog: SchemaCatalog,
) -> None:
    """Schema-valid paths must still describe one coherent filesystem layout."""
    document = profile_document()
    document[field] = value
    profile = parse_profile_v2(
        json.dumps(document), format="json", catalog=path_catalog
    )
    policy = PathPolicy(profile, workspace_root="/workspace", metadata=MemoryPaths())

    with pytest.raises(PathPolicyError, match="PATH_TYPE"):
        policy.validate_configuration()


def test_configuration_classifies_missing_inputs_and_rejects_wrong_existing_kind(
    path_profile: ProfileV2,
) -> None:
    """Missing optional inputs stay visible, while files cannot replace directories."""
    policy, filesystem = configured_policy(path_profile)
    filesystem.remove("src")
    results = policy.validate_configuration()
    # Inspect the complete sorted projection without relying on authored root order.
    assert (
        next(item for item in results if item.path == "src").observations[-1].kind
        == "missing"
    )
    assert tuple(item.path for item in results) == tuple(
        sorted(item.path for item in results)
    )
    filesystem.add("src", "file")

    with pytest.raises(PathPolicyError, match="PATH_TYPE"):
        policy.validate_configuration()
