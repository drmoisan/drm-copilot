"""Verify complete immutable profile loading, local bindings and extension pins."""

from __future__ import annotations

import hashlib
import json
from dataclasses import FrozenInstanceError
from typing import cast

import pytest
import yaml
from drm_copilot_discovery.catalog import (
    DIALECT,
    ExtensionSchema,
    SchemaCatalog,
    load_catalog,
)
from drm_copilot_discovery.models import JsonObject, ParseLimits, to_plain_value
from drm_copilot_discovery.profile_models import (
    ArtifactKey,
    ClientProfile,
    RepositoryProfile,
    SystemProfile,
)
from drm_copilot_discovery.profile_v2 import ProfileError, ProfileV2, parse_profile_v2

from tests.schemas.discovery.v2_schema_test_support import as_object, load_fixture


def profile_document() -> dict[str, object]:
    """Load fresh synthetic fixture data without requiring external extension bytes."""
    document = load_fixture("domain-profile")
    document.pop("extension_schemas")
    return document


def profile_text() -> str:
    """Supply a complete finalized profile to compatibility-adapter tests."""
    return json.dumps(profile_document())


def profile_extension_catalog() -> tuple[dict[str, object], SchemaCatalog]:
    """Bind the example namespace to actual local immutable schema bytes."""
    content = json.dumps(
        {
            "$schema": DIALECT,
            "type": "object",
            "required": ["catalog_label"],
            "properties": {"catalog_label": {"const": "Synthetic fixture"}},
        }
    ).encode()
    extension = ExtensionSchema(
        namespace="example.discovery",
        path="docs/schemas/example-discovery.schema.json",
        sha256=hashlib.sha256(content).hexdigest(),
        content=content,
    )
    document = profile_document()
    document["extension_schemas"] = {
        extension.namespace: {"path": extension.path, "sha256": extension.sha256}
    }
    return document, load_catalog(extensions=(extension,))


def test_complete_profile_exposes_every_configured_field_without_coercion() -> None:
    """All root fields retain their schema-validated values through typed views."""
    document = profile_document()
    profile = parse_profile_v2(json.dumps(document), format="json")

    assert to_plain_value(profile.document) == document
    assert (
        profile.id,
        profile.schema_version,
        profile.profile_version,
        profile.profile_state,
    ) == (document["id"], "2.0.0", 2, "configured")
    profile.require_configured()
    assert profile.system.id == "processing-example"
    assert profile.system.name == as_object(document["system"])["name"]
    assert profile.system.role == "combined"
    assert profile.repository.id == "workspace-example"
    assert profile.repository.vcs == "git"
    assert profile.repository.revision == "a" * 40
    assert profile.repository.revision_policy == "working-tree-at-pin"
    assert profile.production_roots == ("src",)
    assert profile.test_roots == ("tests",)
    assert profile.project_entry_points == tuple(
        cast("list[str]", document["project_entry_points"])
    )
    assert profile.documentation_roots == ("docs",)
    assert profile.evidence_roots == tuple(
        cast("list[str]", document["evidence_roots"])
    )
    assert profile.required_platforms == ("browser",)
    assert profile.required_modes == ("online",)
    assert profile.required_feature_dimensions == ("trigger", "observable_outputs")
    assert profile.runtime.capability == "manual"
    assert profile.runtime.required_feature_ids == ()
    assert profile.analyzers.enabled == ("repository", "dotnet", "dependencies")
    assert profile.analyzers.max_file_bytes == 16777216
    assert (
        to_plain_value(profile.analyzers.ignored_paths)
        == as_object(document["analyzers"])["ignored_paths"]
    )
    assert profile.analyzers.extension_result_manifests == ()
    assert to_plain_value(profile.excluded_paths) == document["excluded_paths"]
    assert to_plain_value(profile.decision_owners) == document["decision_owners"]
    assert to_plain_value(profile.extensions) == document["extensions"]
    assert profile.extension_schemas == JsonObject(())
    assert profile.limits.parse_limits() == ParseLimits()
    assert profile.limits.source_files == 1000000
    assert profile.completion_gates.planning_prerequisite == "discovery-complete"
    # Every output key must preserve its exact configured location.
    for key, value in as_object(document["artifacts"]).items():
        assert profile.artifacts[cast("ArtifactKey", key)] == value


def test_related_repository_and_client_views_preserve_separate_ownership() -> None:
    """Multiple clients never merge source and target revision identities."""
    profile = parse_profile_v2(profile_text())
    source, target = profile.repositories
    browser, portable = profile.clients

    assert (source.id, source.role, source.revision, source.clients) == (
        "source-example",
        "legacy-source",
        "a" * 40,
        (),
    )
    assert source.snapshot_manifest is not None
    assert (target.id, target.role, target.revision) == (
        "target-example",
        "modernization-target",
        "b" * 64,
    )
    assert target.clients == ("browser-example", "portable-example")
    assert browser.id == "browser-example" and portable.id == "portable-example"
    assert browser.target_repository == portable.target_repository == target.id
    assert browser.platforms == ("browser",)
    assert portable.modes == ("online", "offline")
    assert portable.required_feature_dimensions == ("offline", "mobile")
    offline = cast("JsonObject", browser.applicability_defaults["offline"])
    assert offline["applicability"] == "not-applicable" and offline["rationale"]


@pytest.mark.parametrize("role", ("legacy-source", "modernization-target", "combined"))
def test_separate_and_combined_roles_accept_explicit_local_target_clients(
    role: str,
) -> None:
    """A source may omit clients; a local target binds clients to its own ID."""
    document = profile_document()
    as_object(document["system"])["role"] = role
    document["repositories"] = []
    if role == "legacy-source":
        document["clients"] = []
    else:
        # Local target clients need no fabricated external target record.
        for client in cast("list[dict[str, object]]", document["clients"]):
            client["target_repository"] = "workspace-example"

    profile = parse_profile_v2(json.dumps(document))

    assert profile.system.role == role
    assert profile.repositories == ()
    assert len(profile.clients) == (0 if role == "legacy-source" else 2)


def test_custom_paths_and_optional_defaults_are_preserved_without_path_resolution() -> (
    None
):
    """Custom paths stay exact; only optional limits receive documented defaults."""
    document = profile_document()
    artifacts = as_object(document["artifacts"])
    # Rename the hierarchy consistently without touching the host filesystem.
    for key, value in artifacts.items():
        artifacts[key] = cast("str", value).replace(
            "docs/migration/discovery", "Notes/Évidence Records"
        )
    as_object(document["analyzers"])["options"] = {}
    document["limits"] = {"source_files": 12, "nesting_depth": 7}

    profile = parse_profile_v2(json.dumps(document))

    assert profile.artifacts["root"] == "Notes/Évidence Records"
    assert (
        profile.artifacts["coverage_ledger"]
        == "Notes/Évidence Records/coverage-ledger.json"
    )
    assert profile.analyzers.max_file_bytes == 16777216
    assert profile.limits.source_files == 12 and profile.limits.nesting_depth == 7
    assert profile.limits.document_bytes == 16777216


def test_profile_and_nested_views_are_deeply_immutable_and_deterministic() -> None:
    """Mutable input containers and detached exports cannot mutate the typed profile."""
    document = profile_document()
    original = json.dumps(document)
    first = parse_profile_v2(original)
    second = parse_profile_v2(yaml.safe_dump(document))
    as_object(document["system"])["name"] = "Changed"

    assert first == second and hash(first) == hash(second)
    assert first.system.name != "Changed"
    # Dynamic names exercise the runtime guard without static readonly assignment.
    root_field, view_field = "document", "profile"
    with pytest.raises(FrozenInstanceError):
        setattr(first, root_field, JsonObject(()))
    with pytest.raises(FrozenInstanceError):
        setattr(first.system, view_field, second)
    detached = as_object(to_plain_value(first.document))
    as_object(detached["system"])["name"] = "Detached"
    assert first == second


@pytest.mark.parametrize(
    "content",
    ("", "{}", "[]", "key: [", "id: alpha\nid: beta", "a: &a [*a]", "x: .nan"),
)
def test_missing_or_ambiguous_configuration_has_no_partial_profile(
    content: str,
) -> None:
    """All parser/schema defects produce actionable deterministic profile findings."""
    with pytest.raises(ProfileError) as error:
        parse_profile_v2(content)

    assert error.value.findings
    assert all(
        item.severity == "error" and item.next_action for item in error.value.findings
    )


@pytest.mark.parametrize("field", tuple(profile_document()))
def test_every_required_profile_field_is_enforced(field: str) -> None:
    """A missing required top-level field cannot be silently defaulted."""
    document = profile_document()
    del document[field]

    with pytest.raises(ProfileError, match=field.replace("$", r"\$")):
        parse_profile_v2(json.dumps(document))


@pytest.mark.parametrize("section", ("repositories", "clients", "decision_owners"))
def test_duplicate_ids_are_rejected_even_when_other_record_fields_differ(
    section: str,
) -> None:
    """Whole-object schema uniqueness is supplemented by stable identity uniqueness."""
    document = profile_document()
    records = cast("list[dict[str, object]]", document[section])
    duplicate = dict(records[0])
    field, value = {
        "repositories": ("revision", "d" * 40),
        "clients": ("platforms", ["alternate"]),
        "decision_owners": ("required_evidence_types", ["source"]),
    }[section]
    duplicate[field] = value
    records.append(duplicate)

    with pytest.raises(ProfileError, match=f"Duplicate {section} identifier"):
        parse_profile_v2(json.dumps(document))


@pytest.mark.parametrize("target", ("missing", "source-example"))
def test_clients_require_a_declared_target_repository(target: str) -> None:
    """A source or unknown repository cannot silently become a target."""
    document = profile_document()
    cast("list[dict[str, object]]", document["clients"])[0][
        "target_repository"
    ] = target

    with pytest.raises(ProfileError, match="Unknown target repository"):
        parse_profile_v2(json.dumps(document))


@pytest.mark.parametrize(
    "repository_index,client_id",
    ((0, "browser-example"), (1, "missing"), (1, "other-client")),
)
def test_repository_client_links_reject_missing_source_owned_or_mismatched_clients(
    repository_index: int, client_id: str
) -> None:
    """Backlinks retain target ownership without changing unrelated clients."""
    document = profile_document()
    cast("list[dict[str, object]]", document["repositories"])[repository_index][
        "clients"
    ] = [client_id]
    if client_id == "other-client":
        extra = dict(cast("list[dict[str, object]]", document["clients"])[0])
        extra.update(id=client_id, target_repository="workspace-example")
        cast("list[dict[str, object]]", document["clients"]).append(extra)

    with pytest.raises(ProfileError, match="Invalid target client link"):
        parse_profile_v2(json.dumps(document))


def test_declared_extension_requires_exact_catalog_path_checksum_and_constraints() -> (
    None
):
    """The profile cannot claim an unchecked extension or substitute its local pin."""
    document, catalog = profile_extension_catalog()
    profile = parse_profile_v2(json.dumps(document), catalog=catalog)
    assert to_plain_value(profile.extension_schemas) == document["extension_schemas"]
    with pytest.raises(ProfileError, match="absent or its path/checksum differs"):
        parse_profile_v2(json.dumps(document))
    declarations = as_object(document["extension_schemas"])
    as_object(declarations["example.discovery"])["sha256"] = "a" * 64
    with pytest.raises(ProfileError, match="path/checksum differs"):
        parse_profile_v2(json.dumps(document), catalog=catalog)
    as_object(declarations["example.discovery"])["sha256"] = catalog.extensions[
        0
    ].sha256
    as_object(declarations["example.discovery"])["path"] = "docs/other.json"
    with pytest.raises(ProfileError, match="path/checksum differs"):
        parse_profile_v2(json.dumps(document), catalog=catalog)
    with pytest.raises(ProfileError, match="not declared"):
        parse_profile_v2(profile_text(), catalog=catalog)
    document, catalog = profile_extension_catalog()
    as_object(as_object(document["extensions"])["example.discovery"])[
        "catalog_label"
    ] = "Invalid"
    with pytest.raises(ProfileError, match="catalog_label"):
        parse_profile_v2(json.dumps(document), catalog=catalog)


def test_profile_views_reject_unvalidated_roots_or_invalid_section_indexes() -> None:
    """Public view construction cannot publish unchecked values through typed casts."""
    profile = parse_profile_v2(profile_text())
    with pytest.raises(ValueError, match="validated ProfileV2"):
        SystemProfile(cast("ProfileV2", object()))
    with pytest.raises(ValueError, match="not an indexed"):
        RepositoryProfile(profile, 0)
    # Noninteger, negative, absent and out-of-range indexes all fail before lookup.
    for index in (None, -1, 2, True):
        with pytest.raises(ValueError, match="Invalid clients index"):
            ClientProfile(profile, index)


def test_explicit_parser_limits_cannot_be_overridden_by_document_fields() -> None:
    """Root-selected byte limits run before any profile-contained limit is trusted."""
    with pytest.raises(ProfileError, match="byte"):
        parse_profile_v2(profile_text(), limits=ParseLimits(document_bytes=4))
