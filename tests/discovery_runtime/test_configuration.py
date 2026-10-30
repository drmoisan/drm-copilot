"""Prove inert selection cannot hide missing active inputs or manufacture authority."""

from __future__ import annotations

import json
from dataclasses import fields, replace
from hashlib import sha256
from typing import TYPE_CHECKING, cast

import pytest
from drm_copilot_discovery.catalog import load_catalog
from drm_copilot_discovery.configuration import (
    DEFAULT_PROFILE,
    ActivationRecord,
    ConfigurationError,
    ConfigurationRequest,
    locator_bytes,
    select_configuration,
)
from drm_copilot_discovery.path_models import PathPolicyError
from drm_copilot_discovery.profile_v2 import ProfileError

from tests.discovery_runtime.test_profile_v2 import profile_document
from tests.schemas.discovery.v2_schema_test_support import as_object

if TYPE_CHECKING:
    from drm_copilot_discovery.catalog import SchemaCatalog


@pytest.fixture(scope="module")
def config_catalog() -> SchemaCatalog:
    """Share only immutable packaged schemas; every mutable fixture remains local."""
    return load_catalog()


def profile_bytes(path: str = DEFAULT_PROFILE) -> bytes:
    """Return independent valid configuration with one explicit profile location."""
    document = profile_document()
    as_object(document["artifacts"])["profile"] = path
    document["project_entry_points"] = []
    return json.dumps(document).encode()


def active_record(content: bytes, path: str = DEFAULT_PROFILE) -> ActivationRecord:
    """Model protected observation data without creating a native root capability."""
    return ActivationRecord(
        workspace_sha256="a" * 64,
        generation=1,
        action="activate",
        profile_path=path,
        profile_sha256=sha256(content).hexdigest(),
        locator_sha256=sha256(locator_bytes(path)).hexdigest(),
        previous_sha256=None,
    )


@pytest.mark.parametrize("path", [DEFAULT_PROFILE, "docs/Custom Profile.yaml"])
def test_default_and_custom_selection_require_explicit_activation(
    config_catalog: SchemaCatalog, path: str
) -> None:
    """A valid locator or explicit selector locates configuration without granting
    activation."""
    content = profile_bytes(path)
    selection = select_configuration(
        candidates={path: content},
        locator=None,
        activation=None,
        catalog=config_catalog,
        profile_path=path if path != DEFAULT_PROFILE else None,
    )
    assert selection.state == "activation-required"
    assert selection.profile_bytes == content and selection.profile_path == path
    with pytest.raises(ConfigurationError, match="activation is required"):
        select_configuration(
            candidates={path: content},
            locator=locator_bytes(path),
            activation=None,
            catalog=config_catalog,
            controlled=True,
        )


def test_protected_matching_bytes_enable_selection_but_are_not_grants(
    config_catalog: SchemaCatalog,
) -> None:
    """Only matching protected observations yield active readiness, with exact raw
    bytes."""
    content = profile_bytes()
    selection = select_configuration(
        candidates={DEFAULT_PROFILE: content},
        locator=locator_bytes(DEFAULT_PROFILE),
        activation=active_record(content),
        catalog=config_catalog,
        controlled=True,
    )
    assert selection.state == "active" and selection.profile is not None
    assert selection.locator_bytes == locator_bytes(DEFAULT_PROFILE)
    assert not hasattr(selection, "grant")


def test_inactive_nonparticipant_and_explicit_deactivation(
    config_catalog: SchemaCatalog,
) -> None:
    """Absent activation/default leaves unrelated work alone; root tombstones
    override leftovers."""
    assert (
        select_configuration(
            candidates={},
            locator=None,
            activation=None,
            catalog=config_catalog,
            controlled=True,
        ).state
        == "inactive"
    )
    tombstone = replace(
        active_record(profile_bytes()), action="deactivate", generation=2
    )
    assert (
        select_configuration(
            candidates={DEFAULT_PROFILE: b"malformed"},
            locator=b"bad",
            activation=tombstone,
            catalog=config_catalog,
        ).state
        == "inactive"
    )
    with pytest.raises(ProfileError):
        select_configuration(
            candidates={DEFAULT_PROFILE: b"bad"},
            locator=b"bad",
            activation=tombstone,
            profile_path=DEFAULT_PROFILE,
            catalog=config_catalog,
        )


@pytest.mark.parametrize(
    "case",
    [
        "multiple",
        "argument",
        "missing",
        "deleted-locator",
        "deleted-profile",
        "changed-profile",
        "changed-locator",
        "internal-path",
        "custom-unselected",
    ],
)
def test_ambiguous_missing_or_changed_configuration_fails(
    config_catalog: SchemaCatalog, case: str
) -> None:
    """Each independent selector/freshness violation remains a blocking typed
    finding."""
    content = profile_bytes()
    candidates = {DEFAULT_PROFILE: content}
    locator: bytes | None = locator_bytes(DEFAULT_PROFILE)
    activation: ActivationRecord | None = active_record(content)
    selected: str | None = None
    # Change one observed fact at a time so failures retain the intended boundary.
    if case == "multiple":
        candidates["docs/other.yaml"] = content
    elif case == "argument":
        selected = "docs/other.yaml"
    elif case in {"missing", "deleted-profile"}:
        candidates.clear()
        if case == "missing":
            activation = None
            selected = DEFAULT_PROFILE
    elif case == "deleted-locator":
        locator = None
    elif case == "changed-profile":
        candidates[DEFAULT_PROFILE] = content + b"\n"
    elif case == "changed-locator":
        locator += b"\n"
    elif case == "internal-path":
        candidates[DEFAULT_PROFILE] = profile_bytes("docs/other.yaml")
        activation = None
    else:
        candidates = {"docs/custom.yaml": profile_bytes("docs/custom.yaml")}
        activation, locator = None, None
    with pytest.raises(ConfigurationError) as caught:
        select_configuration(
            candidates=candidates,
            locator=locator,
            activation=activation,
            profile_path=selected,
            catalog=config_catalog,
        )
    assert caught.value.findings[0].code in {
        "CONFIGURATION_AMBIGUOUS",
        "CONFIGURATION_DISAGREEMENT",
        "CONFIGURATION_MISSING",
        "ACTIVATION_STALE",
    }


@pytest.mark.parametrize(
    "content",
    [
        b"null",
        b"{}",
        b'{"enabled":false}',
        b'{"schema_version":"9"}',
        b'{"enabled":true,"enabled":false}',
    ],
)
def test_malformed_locator_never_means_inactive(
    config_catalog: SchemaCatalog, content: bytes
) -> None:
    """Disabled, unknown and duplicate-key locators cannot opt out of an active gate."""
    with pytest.raises(ProfileError):
        select_configuration(
            candidates={DEFAULT_PROFILE: profile_bytes()},
            locator=content,
            activation=active_record(profile_bytes()),
            catalog=config_catalog,
        )


def test_malformed_profile_and_unsafe_selector_are_rejected(
    config_catalog: SchemaCatalog,
) -> None:
    """The shared parser/path policy remains authoritative for proposed inputs."""
    with pytest.raises(ProfileError):
        select_configuration(
            candidates={DEFAULT_PROFILE: b"{}"},
            locator=None,
            activation=None,
            catalog=config_catalog,
        )
    with pytest.raises(PathPolicyError):
        select_configuration(
            candidates={},
            locator=None,
            activation=None,
            profile_path="../outside",
            catalog=config_catalog,
        )


def test_record_round_trip_preserves_audit_chain_and_workspace_identity() -> None:
    """Protected transitions are deterministic, bounded and bound to one canonical
    workspace."""
    record = active_record(profile_bytes())
    assert (
        record.active
        and ActivationRecord.decode(record.encode(), workspace_sha256="a" * 64)
        == record
    )
    tombstone = replace(
        record,
        action="deactivate",
        generation=2,
        previous_sha256=sha256(record.encode()).hexdigest(),
    )
    assert not tombstone.active
    assert (
        ActivationRecord.decode(tombstone.encode(), workspace_sha256="a" * 64)
        == tombstone
    )
    with pytest.raises(ConfigurationError, match="another workspace"):
        ActivationRecord.decode(record.encode(), workspace_sha256="b" * 64)


@pytest.mark.parametrize(
    "key,value",
    [
        ("generation", True),
        ("generation", 0),
        ("action", "root"),
        ("schema_version", "1"),
        ("workspace_sha256", ""),
        ("workspace_sha256", None),
        ("profile_sha256", 4),
        ("locator_sha256", None),
        ("profile_path", "../outside"),
        ("permission", "root"),
    ],
)
def test_invalid_protected_fields_fail_closed(key: str, value: object) -> None:
    """Corrupt versions, identities or added authority claims never become inactive
    state."""
    document = cast(
        "dict[str, object]", json.loads(active_record(profile_bytes()).encode())
    )
    document[key] = value
    with pytest.raises(ConfigurationError):
        ActivationRecord.decode(
            json.dumps(document).encode(), workspace_sha256="a" * 64
        )


@pytest.mark.parametrize(
    "content",
    [b"{}", b"invalid", b" " * 65537, b'{"generation":1,"generation":2}'],
    ids=["missing-fields", "invalid-json", "oversized", "duplicate-key"],
)
def test_registry_parse_errors_remain_blocking(content: bytes) -> None:
    """The common bounded strict JSON parser supplies no permissive fallback."""
    with pytest.raises(ConfigurationError):
        ActivationRecord.decode(content, workspace_sha256="a" * 64)


@pytest.mark.parametrize(
    "changes",
    [
        {"action": "unknown"},
        {"profile_path": "../outside"},
        {"profile_bytes": "text"},
        {"dry_run": 1},
        {"action": "deactivate", "profile_bytes": b"{}"},
        {"action": "deactivate", "profile_path": "docs/custom.yaml"},
    ],
)
def test_request_cannot_select_unsafe_or_irrelevant_inputs(
    changes: dict[str, object],
) -> None:
    """Only closed configuration intent is accepted, with no root or registry path
    field."""
    with pytest.raises(ValueError):
        replace(ConfigurationRequest(action="activate"), **changes)
    assert {field.name for field in fields(ConfigurationRequest)} == {
        "action",
        "profile_path",
        "profile_bytes",
        "dry_run",
    }
