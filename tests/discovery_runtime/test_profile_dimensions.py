"""Verify inherited requirements, immutable gate policy, activation and v1 dispatch."""

from __future__ import annotations

import json
from dataclasses import FrozenInstanceError
from typing import TYPE_CHECKING, Literal, cast

import pytest
from drm_copilot_discovery.activation_models import ActivationLocator
from drm_copilot_discovery.domain_profile import (
    load_domain_profile,
    parse_domain_profile_text,
)
from drm_copilot_discovery.domain_profile_models import (
    DomainProfile,
    DomainProfileError,
)
from drm_copilot_discovery.profile_models import (
    CORE_CLAIM_RULES,
    FEATURE_DIMENSIONS,
    CompletionGate,
    ProfileLimits,
    ProfileRequirements,
)
from drm_copilot_discovery.profile_v2 import ProfileError, ProfileV2, parse_profile_v2

from tests.discovery_runtime.test_profile_v2 import profile_document, profile_text
from tests.schemas.discovery.v2_schema_test_support import as_object
from tests.scripts.dev_tools.discovery.test_domain_profile import VALID_MINIMAL

if TYPE_CHECKING:
    from pathlib import Path


def test_requirements_union_preserves_all_parent_axes_and_explicit_client_modes() -> (
    None
):
    """Feature additions cannot remove global or selected-client obligations."""
    profile = parse_profile_v2(profile_text())
    feature = ProfileRequirements(
        platforms=("desktop", "desktop"),
        modes=("disconnected",),
        dimensions=("cancellation", "offline"),
    )

    required = profile.requirements(client_id="portable-example", feature=feature)

    assert required.platforms == ("browser", "desktop", "portable")
    assert required.modes == ("disconnected", "offline", "online")
    assert required.dimensions == (
        "cancellation",
        "mobile",
        "observable_outputs",
        "offline",
        "trigger",
    )
    assert feature.platforms == ("desktop",)
    assert profile.required_modes == ("online",)
    assert profile.requirements().modes == ("online",)
    with pytest.raises(ValueError, match="Unknown configured client"):
        profile.requirements(client_id="missing")


def test_explicit_dimensions_survive_applicability_defaults() -> None:
    """Offline/mobile obligations arise only from explicit configuration."""
    profile = parse_profile_v2(profile_text())
    required = profile.requirements(client_id="browser-example")

    assert "offline" not in required.modes and "mobile" not in required.dimensions
    assert required.dimensions == ("failure", "observable_outputs", "trigger")
    explicit = profile.requirements(
        client_id="browser-example",
        feature=ProfileRequirements(
            platforms=(), modes=("offline",), dimensions=("offline", "mobile")
        ),
    )
    assert "offline" in explicit.modes and "mobile" in explicit.dimensions


@pytest.mark.parametrize("axis", ("platforms", "modes", "dimensions"))
@pytest.mark.parametrize(
    "value", ("Bad", "1start", "a..b", "a--b", "a__b", "bad\n", "", True)
)
def test_requirement_identifiers_match_the_authoritative_core_grammar(
    axis: str, value: object
) -> None:
    """Feature additions cannot widen the core identifier vocabulary."""
    values: dict[str, tuple[object, ...]] = {
        "platforms": (),
        "modes": (),
        "dimensions": (),
    }
    values[axis] = (value,)

    with pytest.raises(ValueError, match="Invalid required"):
        ProfileRequirements(**cast("dict[str, tuple[str, ...]]", values))


def test_requirement_dimensions_remain_closed_and_input_sequences_are_detached() -> (
    None
):
    """All declared dimensions work; arbitrary names and scalar strings do not."""
    assert (
        set(
            ProfileRequirements(
                platforms=(), modes=(), dimensions=tuple(FEATURE_DIMENSIONS)
            ).dimensions
        )
        == FEATURE_DIMENSIONS
    )
    with pytest.raises(ValueError, match="Invalid required dimensions"):
        ProfileRequirements(platforms=(), modes=(), dimensions=("invented_dimension",))
    with pytest.raises(ValueError, match="Invalid required modes"):
        ProfileRequirements(
            platforms=(), modes=cast("tuple[str, ...]", "online"), dimensions=()
        )
    inputs = ["z-client", "a-client", "z-client"]
    result = ProfileRequirements(
        platforms=cast("tuple[str, ...]", inputs), modes=(), dimensions=()
    )
    inputs.clear()
    assert result.platforms == ("a-client", "z-client")


@pytest.mark.parametrize(
    "prerequisite", ("none", "discovery-complete", "parity-complete")
)
def test_configured_completion_switches_cannot_disable_core_claim_rules(
    prerequisite: str,
) -> None:
    """Optional gates cannot disable verified evidence or path safety."""
    document = profile_document()
    gates = as_object(document["completion_gates"])
    # Exercise every boolean gate without changing the closed planning enum.
    for name in gates:
        gates[name] = prerequisite if name == "planning_prerequisite" else False
    profile = parse_profile_v2(json.dumps(document))

    assert profile.completion_gates.planning_prerequisite == prerequisite
    assert profile.completion_gates.mandatory_claim_rules == CORE_CLAIM_RULES
    # Every authored false remains a literal false, never a string coercion.
    for name in gates:
        if name != "planning_prerequisite":
            assert (
                profile.completion_gates.required(cast("CompletionGate", name)) is False
            )
    with pytest.raises(KeyError):
        profile.completion_gates.required(cast("CompletionGate", "invented"))
    with pytest.raises(ValueError, match="boolean gate"):
        profile.completion_gates.required(
            cast("CompletionGate", "planning_prerequisite")
        )
    field = "index"
    with pytest.raises(FrozenInstanceError):
        setattr(profile.completion_gates, field, 1)


@pytest.mark.parametrize(
    "key,value",
    (
        ("unknown_gate", True),
        ("mandatory_claim_rules", []),
        ("require_feature_evidence", "false"),
        ("require_all_dispositions", 0),
        ("planning_prerequisite", "pass"),
    ),
)
def test_unknown_or_malformed_gate_policy_fails_closed(key: str, value: object) -> None:
    """Unknown keys and coercion cannot disable mandatory claim rules."""
    document = profile_document()
    as_object(document["completion_gates"])[key] = value

    with pytest.raises(ProfileError, match=key):
        parse_profile_v2(json.dumps(document))


@pytest.mark.parametrize(
    "capability", ("none", "manual", "semi-automated", "automated")
)
def test_runtime_capability_never_invents_evidence_or_removes_declared_obligations(
    capability: str,
) -> None:
    """No-runtime repositories remain representable with honest outstanding work."""
    document = profile_document()
    document["runtime"] = {
        "capability": capability,
        "required_feature_ids": ["feature.alpha"],
    }
    profile = parse_profile_v2(json.dumps(document))

    assert profile.runtime.capability == capability
    assert profile.runtime.required_feature_ids == ("feature.alpha",)
    assert profile.completion_gates.required("require_runtime_for_declared_features")


def test_draft_profile_is_valid_but_cannot_satisfy_configured_prerequisites() -> None:
    """Missing pins, roots and clients remain draft values without readiness."""
    document = profile_document()
    document.update(
        profile_state="draft",
        production_roots=[],
        required_modes=[],
        clients=[],
        repositories=[],
    )
    as_object(document["repository"])["revision"] = None
    profile = parse_profile_v2(json.dumps(document))

    assert profile.profile_state == "draft" and profile.repository.revision is None
    assert profile.production_roots == profile.clients == profile.repositories == ()
    assert profile.requirements().modes == ()
    with pytest.raises(ProfileError, match="Draft configuration"):
        profile.require_configured()
    document["profile_state"] = "configured"
    with pytest.raises(ProfileError):
        parse_profile_v2(json.dumps(document))


@pytest.mark.parametrize(
    "field,ceiling",
    (
        ("document_bytes", 67108864),
        ("nesting_depth", 128),
        ("artifact_records", 1000000),
        ("source_files", 10000000),
    ),
)
def test_configured_finite_limits_accept_boundaries_and_reject_unbounded_overrides(
    field: str, ceiling: int
) -> None:
    """Model construction enforces the same hard ceilings as the profile schema."""
    assert getattr(ProfileLimits(**{field: 1}), field) == 1
    assert getattr(ProfileLimits(**{field: ceiling}), field) == ceiling
    # Exact type checks exclude booleans and fractions in addition to range violations.
    for value in (0, -1, ceiling + 1, True, 1.5):
        with pytest.raises(ValueError, match=field):
            ProfileLimits(**cast("dict[str, int]", {field: value}))
    document = profile_document()
    document["limits"] = {field: ceiling}
    assert getattr(parse_profile_v2(json.dumps(document)).limits, field) == ceiling


@pytest.mark.parametrize(
    "field",
    (
        "document_bytes",
        "nesting_depth",
        "artifact_records",
        "source_files",
        "max_file_bytes",
    ),
)
def test_schema_valid_integral_numbers_have_consistent_integer_projections(
    field: str,
) -> None:
    """Integral JSON numbers stay accepted and never break later typed limit access."""
    document = profile_document()
    if field == "max_file_bytes":
        as_object(document["analyzers"])["options"] = {field: 8.0}
    else:
        document["limits"] = {field: 8.0}
    profile = parse_profile_v2(json.dumps(document))

    actual = (
        profile.analyzers.max_file_bytes
        if field == "max_file_bytes"
        else getattr(profile.limits, field)
    )
    assert type(actual) is int and actual == 8
    profile.limits.parse_limits()
    assert profile.document == parse_profile_v2(json.dumps(document)).document
    if field == "max_file_bytes":
        as_object(document["analyzers"])["options"] = {field: 8.5}
    else:
        document["limits"] = {field: 8.5}
    with pytest.raises(ProfileError, match=field):
        parse_profile_v2(json.dumps(document))


def test_locator_is_exact_immutable_configuration_without_authority() -> None:
    """The four-key locator cannot contain permissions or receipts."""
    value = {
        "schema_version": "2.0.0",
        "enabled": True,
        "profile_path": "docs/Custom Profile.yaml",
        "required_runtime_major": 2,
    }
    locator = ActivationLocator(json.dumps(value))

    assert locator.schema_version == "2.0.0" and locator.enabled is True
    assert locator.required_runtime_major == 2
    assert locator.profile_path == value["profile_path"]
    locator.require_profile_path("docs/Custom Profile.yaml")
    with pytest.raises(ValueError, match="disagrees"):
        locator.require_profile_path("docs/other.yaml")
    field = "document"
    with pytest.raises(FrozenInstanceError):
        setattr(locator, field, None)
    invalid_values: tuple[tuple[str, object], ...] = (
        ("enabled", False),
        ("profile_path", "../escape"),
        ("required_runtime_major", 3),
        ("schema_version", "2.1.0"),
        ("permissions", []),
        ("receipt", "pass"),
    )
    # Invalid replacements and added authority claims must all reject the locator.
    for key, invalid in invalid_values:
        with pytest.raises(ProfileError):
            ActivationLocator(json.dumps({**value, key: invalid}))


def test_explicit_version_dispatch_preserves_valid_v1_and_loads_v2_in_memory(
    mem_fs_path: Path,
) -> None:
    """Default calls remain v1; content cannot silently select the new parser."""
    legacy = parse_domain_profile_text(VALID_MINIMAL)
    assert isinstance(legacy, DomainProfile) and legacy.profile_version == 1
    assert legacy == parse_domain_profile_text(VALID_MINIMAL, schema_version="1.0.0")
    current = parse_domain_profile_text(profile_text(), schema_version="2.0.0")
    assert isinstance(current, ProfileV2) and current.profile_version == 2
    path = mem_fs_path / "profile.yaml"
    path.write_text(profile_text(), encoding="utf-8")
    assert load_domain_profile(path, schema_version="2.0.0") == current
    with pytest.raises(DomainProfileError):
        parse_domain_profile_text(profile_text())
    with pytest.raises(DomainProfileError):
        parse_domain_profile_text(VALID_MINIMAL, schema_version="2.0.0")
    with pytest.raises(DomainProfileError, match="Unsupported profile schema version"):
        parse_domain_profile_text(
            VALID_MINIMAL, schema_version=cast('Literal["1.0.0"]', "9.0.0")
        )
