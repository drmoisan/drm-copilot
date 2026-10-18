"""Validate synthetic v2 profile and scope contracts without runtime I/O."""

from __future__ import annotations

from copy import deepcopy
from typing import cast

import pytest

from tests.schemas.discovery.v2_schema_test_support import (
    HASH,
    PIN,
    URN,
    as_object,
    load_fixture,
    profile_client,
    schema_errors,
)


@pytest.mark.parametrize("kind", ("domain-profile", "scope"))
def test_complete_synthetic_example_is_valid_and_not_modified(kind: str) -> None:
    """Validation accepts full examples without injecting defaults or changing data."""
    document = load_fixture(kind)
    original = deepcopy(document)

    errors = schema_errors(kind, document)

    assert errors == [], [error.message for error in errors]
    assert document == original


@pytest.mark.parametrize(
    "kind, pointer",
    [
        ("domain-profile", ["completion_gates", "require_confirmed_scope"]),
        ("scope", ["repository", "revision"]),
    ],
)
def test_invalid_fixture_has_one_specific_actionable_defect(
    kind: str, pointer: list[str]
) -> None:
    """Negative fixtures fail for their declared defect and pass when it is repaired."""
    document = load_fixture(kind, invalid=True)

    errors = schema_errors(kind, document)
    as_object(document[pointer[0]])[pointer[1]] = (
        True if kind == "domain-profile" else PIN
    )

    assert len(errors) == 1
    assert list(errors[0].absolute_path) == pointer
    assert "is not of type" in errors[0].message
    assert schema_errors(kind, document) == []


@pytest.mark.parametrize("kind", ("domain-profile", "scope"))
@pytest.mark.parametrize(
    "key,value",
    [
        ("schema_version", "2.0.1"),
        ("schema_version", 2),
        ("$schema", "https://example.invalid/loose"),
        ("$schema", URN + "common"),
        ("artifact_kind", "feature-contract"),
        ("id", "Mixed-Case"),
        ("unknown", True),
    ],
)
def test_identity_version_and_unknown_core_fields_fail_closed(
    kind: str, key: str, value: object
) -> None:
    """Only the exact kind/version/schema and case-sensitive core grammar are valid."""
    document = load_fixture(kind)
    document[key] = value

    assert schema_errors(kind, document)


@pytest.mark.parametrize(
    "field",
    (
        "$schema",
        "schema_version",
        "artifact_kind",
        "id",
        "profile_version",
        "profile_state",
        "system",
        "repository",
        "production_roots",
        "test_roots",
        "project_entry_points",
        "documentation_roots",
        "evidence_roots",
        "repositories",
        "clients",
        "required_platforms",
        "required_modes",
        "required_feature_dimensions",
        "runtime",
        "analyzers",
        "excluded_paths",
        "artifacts",
        "completion_gates",
        "decision_owners",
        "extensions",
    ),
)
def test_profile_requires_every_configuration_category(field: str) -> None:
    """Missing configuration cannot select implicit paths, defaults or authority."""
    profile = load_fixture("domain-profile")
    del profile[field]

    assert any(
        error.validator == "required"
        for error in schema_errors("domain-profile", profile)
    )


@pytest.mark.parametrize("role", ("legacy-source", "modernization-target", "combined"))
@pytest.mark.parametrize(
    "capability", ("none", "manual", "semi-automated", "automated")
)
def test_roles_runtime_capabilities_and_multiple_clients_are_independent(
    role: str, capability: str
) -> None:
    """A role does not force runtime automation or remove per-client requirements."""
    profile = load_fixture("domain-profile")
    as_object(profile["system"])["role"] = role
    as_object(profile["runtime"])["capability"] = capability

    assert schema_errors("domain-profile", profile) == []
    assert profile_client(profile)["modes"] == ["online"]
    assert profile_client(profile, 1)["modes"] == ["online", "offline"]


def test_explicit_online_only_profile_does_not_require_offline_or_mobile() -> None:
    """Optional dimensions are absent until declared globally or by a client."""
    profile = load_fixture("domain-profile")
    profile["clients"] = [profile_client(profile)]
    profile_client(profile)["applicability_defaults"] = {}
    as_object(cast("list[object]", profile["repositories"])[1])["clients"] = [
        "browser-example"
    ]

    assert schema_errors("domain-profile", profile) == []
    assert profile["required_modes"] == ["online"]
    assert profile["required_feature_dimensions"] == ["trigger", "observable_outputs"]


@pytest.mark.parametrize("configured", (False, True))
def test_draft_unset_roots_and_pins_are_distinct_from_configured_state(
    configured: bool,
) -> None:
    """Honest unconfigured inputs validate only as drafts, never configured profiles."""
    profile = load_fixture("domain-profile")
    profile["profile_state"] = "configured" if configured else "draft"
    profile["production_roots"] = []
    as_object(profile["repository"])["revision"] = None
    for item in cast("list[object]", profile["repositories"]):
        as_object(item)["revision"] = None

    assert bool(schema_errors("domain-profile", profile)) is configured


@pytest.mark.parametrize(
    "field,value",
    [
        ("system", {"role": "source"}),
        ("profile_version", True),
        ("profile_version", 1),
        ("required_modes", ["online", "online"]),
        ("required_platforms", [3]),
        ("required_feature_dimensions", ["approved"]),
        ("clients", []),
        ("limits", {"document_bytes": 0}),
        ("limits", {"nesting_depth": 129}),
        ("limits", {"source_files": True}),
    ],
)
def test_invalid_profile_shapes_roles_versions_and_bounds_are_rejected(
    field: str, value: object
) -> None:
    """Configuration enums and bounded integer options have no coercion fallback."""
    profile = load_fixture("domain-profile")
    profile[field] = value

    assert schema_errors("domain-profile", profile)


@pytest.mark.parametrize(
    "field",
    (
        "id",
        "target_repository",
        "platforms",
        "modes",
        "required_feature_dimensions",
        "applicability_defaults",
    ),
)
def test_client_contract_requires_all_declared_axes(field: str) -> None:
    """Client identity, applicability and inherited requirement inputs stay explicit."""
    profile = load_fixture("domain-profile")
    del profile_client(profile)[field]

    assert schema_errors("domain-profile", profile)


@pytest.mark.parametrize("value", ("false", 0, 1, None, [], {}))
def test_every_configurable_gate_requires_a_literal_boolean(value: object) -> None:
    """Each declared boolean gate rejects strings, numbers and container values."""
    profile = load_fixture("domain-profile")
    gates = as_object(profile["completion_gates"])
    for name in gates.keys() - {"planning_prerequisite"}:
        original = gates[name]
        gates[name] = value
        assert schema_errors("domain-profile", profile), name
        gates[name] = original


@pytest.mark.parametrize(
    "prerequisite", ("none", "discovery-complete", "parity-complete")
)
def test_gate_configuration_cannot_introduce_claim_safety_overrides(
    prerequisite: str,
) -> None:
    """Configured gate choices are supported; core claim safety has no disable key."""
    profile = load_fixture("domain-profile")
    gates = as_object(profile["completion_gates"])
    gates["require_runtime_for_declared_features"] = False
    gates["planning_prerequisite"] = prerequisite
    assert schema_errors("domain-profile", profile) == []

    gates["require_verified_evidence"] = False

    assert schema_errors("domain-profile", profile)


@pytest.mark.parametrize(
    "path",
    (
        "../outside",
        "/absolute",
        "C:/drive",
        "C:drive",
        "a\\b",
        "a/../b",
        "a//b",
        "a/",
        "a/./b",
        "a/*",
    ),
)
def test_profile_paths_use_contained_lexical_form(path: str) -> None:
    """Common path spelling rejects obvious escapes before later resolution checks."""
    profile = load_fixture("domain-profile")
    profile["production_roots"] = [path]

    assert schema_errors("domain-profile", profile)


@pytest.mark.parametrize(
    "namespace",
    (
        "core",
        "completion_gates",
        "Example.domain",
        "example..domain",
        "example/domain",
        "example.domain\n",
    ),
)
def test_extension_keys_require_namespaces_and_cannot_replace_core_fields(
    namespace: str,
) -> None:
    """Namespaced extension data cannot stand in for missing required core keys."""
    profile = load_fixture("domain-profile")
    profile["extensions"] = {namespace: {"role": "anything"}}
    assert schema_errors("domain-profile", profile)

    profile["extensions"] = {"example.domain": {"system": profile.pop("system")}}

    assert schema_errors("domain-profile", profile)


@pytest.mark.parametrize(
    "container, key, value",
    [
        ("analyzers", "command", "python"),
        ("analyzers", "enabled", ["local.plugin"]),
        ("analyzers", "options", {"max_file_bytes": -1}),
        ("artifacts", "executable", "bin/tool"),
        ("runtime", "capability", "invented"),
        ("repository", "revision", "main"),
        ("repository", "revision", "a" * 39),
    ],
)
def test_closed_nested_configuration_blocks_executables_and_mutable_pins(
    container: str, key: str, value: object
) -> None:
    """Nested configuration admits data fields, registered adapters and full pins."""
    profile = load_fixture("domain-profile")
    as_object(profile[container])[key] = value

    assert schema_errors("domain-profile", profile)


@pytest.mark.parametrize(
    "path,digest",
    [
        ("https://example.invalid/schema", HASH),
        ("../schema.json", HASH),
        ("docs/schema.json", "bad"),
    ],
)
def test_extension_schemas_require_local_paths_and_exact_hashes(
    path: str, digest: str
) -> None:
    """Extension declarations cannot request remote retrieval or unpinned schemas."""
    profile = load_fixture("domain-profile")
    profile["extension_schemas"] = {"example.domain": {"path": path, "sha256": digest}}

    assert schema_errors("domain-profile", profile)


@pytest.mark.parametrize("kind", ("domain-profile", "scope"))
def test_exclusions_require_nonblank_rationale(kind: str) -> None:
    """An exclusion is an explicit accounted-for decision, not an unrecorded skip."""
    document = load_fixture(kind)
    document["excluded_paths" if kind == "domain-profile" else "exclusions"] = [
        {"path_or_glob": "src/**", "rationale": "  "}
    ]

    assert schema_errors(kind, document)


def test_scope_draft_and_justified_empty_confirmation_are_separate_states() -> None:
    """Empty drafts need no fabricated approval; confirmed no-scope needs a reason."""
    scope = load_fixture("scope")
    scope.update(
        status="draft",
        confirmed_by=None,
        included_roots=[],
        included_components=[],
        included_features=[],
    )
    as_object(scope["repository"])["revision"] = None
    assert schema_errors("scope", scope) == []

    scope.update(status="confirmed", confirmed_by=load_fixture("scope")["confirmed_by"])
    as_object(scope["repository"])["revision"] = PIN
    assert schema_errors("scope", scope)
    scope.update(
        disposition="no-scope",
        no_scope_rationale="No applicable production behavior exists.",
    )
    as_object(scope["required_coverage"])["feature_refs"] = []

    assert schema_errors("scope", scope) == []


@pytest.mark.parametrize(
    "field,value",
    [
        ("status", "verified"),
        ("confirmed_by", None),
        (
            "confirmed_by",
            {"owner": "owner", "timestamp": "not-a-date", "evidence_refs": []},
        ),
        (
            "included_features",
            [{"artifact_kind": "product-decision", "id": "wrong-kind"}],
        ),
        ("inventory_snapshot_refs", ["ambiguous-id"]),
        ("required_coverage", {"feature_refs": [], "client_ids": [], "modes": [False]}),
    ],
)
def test_scope_rejects_incomplete_confirmation_and_wrong_reference_kinds(
    field: str, value: object
) -> None:
    """Confirmation metadata, reference kinds and operating modes stay validated."""
    scope = load_fixture("scope")
    scope[field] = value

    assert schema_errors("scope", scope)
