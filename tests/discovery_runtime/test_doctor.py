"""Prove read-only installation diagnostics against isolated configuration stores."""

from __future__ import annotations

from dataclasses import replace
from typing import TYPE_CHECKING

import pytest
from drm_copilot_discovery.activation_store import ActivationStore
from drm_copilot_discovery.configuration import (
    DEFAULT_PROFILE,
    LOCATOR_PATH,
    ConfigurationRequest,
)
from drm_copilot_discovery.doctor import inspect_doctor
from drm_copilot_discovery.gateway_local import LocalServiceIO
from drm_copilot_discovery.models import JsonObject, ParseLimits
from drm_copilot_discovery.service_contracts import (
    RuntimeIdentity,
    ServiceRequest,
    validate_service_result,
)

from tests.discovery_runtime.test_activation_store import ConfigurationCase
from tests.discovery_runtime.test_configuration import config_catalog as config_catalog
from tests.discovery_runtime.test_configuration import profile_bytes

if TYPE_CHECKING:
    from drm_copilot_discovery.catalog import SchemaCatalog
    from drm_copilot_discovery.configuration import ConfigurationSelection
    from drm_copilot_discovery.service_contracts import DiscoveryResult

IDENTITY = RuntimeIdentity(
    package_version="2.0.0",
    schema_version="2.0.0",
    build_sha256="1" * 64,
    policy_version=1,
    policy_sha256="2" * 64,
)


def doctor_request(case: ConfigurationCase, path: str | None = None) -> ServiceRequest:
    """Return the fixed doctor request for this memory workspace and profile. case
    (ConfigurationCase): isolated memory configuration store. path (str | None):
    selected relative workspace input. Returns ServiceRequest; memory-only effects;
    AssertionError on mismatch.
    """
    return ServiceRequest(
        id="doctor",
        request_id="request",
        operation="doctor",
        mode="structural",
        workspace_root=case.disk.root,
        profile_path=path,
        dry_run=False,
        write=False,
        format="json",
        inputs=JsonObject(()),
        invocation_ref=None,
        authorization_ref=None,
    )


def diagnose(case: ConfigurationCase, path: str | None = None) -> DiscoveryResult:
    """Run the real diagnostic against memory ports and validate its wire schema. case
    (ConfigurationCase): isolated memory configuration store. path (str | None):
    selected relative workspace input. Returns DiscoveryResult; memory-only effects;
    AssertionError on mismatch.
    """
    io = LocalServiceIO(
        activation=case.service,
        repository=None,
        principal="local-user",
        author_id="test-user",
        identity=lambda: IDENTITY,
    )
    result = inspect_doctor(io=io, request=doctor_request(case, path), runtime=IDENTITY)
    validate_service_result(result, catalog=case.service.catalog, limits=ParseLimits())
    return result


@pytest.mark.parametrize("state", ["inactive", "activation-required", "active"])
def test_doctor_reports_configuration_without_native_attestation(
    config_catalog: SchemaCatalog, state: str
) -> None:
    """Truthful profile states never authorize native execution or mutate storage.
    config_catalog (SchemaCatalog): verified immutable schema fixture. state (str):
    requested inactive, required or active configuration. Returns None; memory-only
    effects; AssertionError on mismatch.
    """
    case = ConfigurationCase(config_catalog)
    # Configure only the requested local state; this never supplies native capability.
    if state != "inactive":
        case.disk.store.put(DEFAULT_PROFILE, profile_bytes())
    if state == "active":
        case.service.configure(ConfigurationRequest(action="activate"))
    before = (dict(case.disk.store.files), case.registry.raw, case.revocations)

    result = diagnose(case)

    assert result.ok and result.exit_code == 0
    assert state in str(result.summary["message"])
    assert result.summary["deployment"] is None
    assert result.summary["receipt_ref"] is None
    assert result.summary["invocation_ref"] is None
    assert result.runtime == IDENTITY and not result.artifacts
    # The only healthy diagnostic warning must be truthful native unavailability.
    assert [item.code for item in result.findings] == [
        "DISCOVERY_ENFORCEMENT_UNAVAILABLE"
    ]
    assert result.findings[0].severity == "warning"
    assert (dict(case.disk.store.files), case.registry.raw, case.revocations) == before
    assert result.input_manifest is not None
    if state == "inactive":
        assert result.input_manifest.missing_paths == (LOCATOR_PATH, DEFAULT_PROFILE)
    else:
        # A configured profile must be represented by actual captured bytes.
        assert any(row.path == DEFAULT_PROFILE for row in result.input_manifest.files)


def test_doctor_follows_protected_custom_locator_and_captures_exact_bytes(
    config_catalog: SchemaCatalog,
) -> None:
    """A protected nondefault profile is diagnosed without substituting the default.
    config_catalog (SchemaCatalog): verified immutable schema fixture. Returns None;
    memory-only effects; AssertionError on mismatch.
    """
    case = ConfigurationCase(config_catalog)
    selected = "docs/custom/profile.yaml"
    content = profile_bytes(selected)
    case.service.configure(
        ConfigurationRequest(
            action="activate", profile_path=selected, profile_bytes=content
        )
    )

    result = diagnose(case)

    assert result.ok and result.input_manifest is not None
    # Compare each selected input against the exact configuration bytes.
    captured = {row.path: row.content for row in result.input_manifest.files}
    assert captured[selected] == content
    assert captured[LOCATOR_PATH] == case.disk.store.files[LOCATOR_PATH]
    assert DEFAULT_PROFILE in result.input_manifest.missing_paths


def test_doctor_explicit_profile_retains_real_bytes(
    config_catalog: SchemaCatalog,
) -> None:
    """An explicit unactivated profile remains a configuration observation only.
    config_catalog (SchemaCatalog): verified immutable schema fixture. Returns None;
    memory-only effects; AssertionError on mismatch.
    """
    case = ConfigurationCase(config_catalog, profile="docs/custom/profile.yaml")
    content = profile_bytes("docs/custom/profile.yaml")
    case.disk.store.put("docs/custom/profile.yaml", content)

    result = diagnose(case, "docs/custom/profile.yaml")

    assert result.ok and "activation-required" in str(result.summary["message"])
    assert result.input_manifest is not None
    assert result.input_manifest.files[0].content == content
    assert not case.registry.writes and not case.revocations


@pytest.mark.parametrize("path", [DEFAULT_PROFILE, LOCATOR_PATH])
def test_invalid_configuration_returns_fixed_failure_and_observed_bytes(
    config_catalog: SchemaCatalog, path: str
) -> None:
    """Invalid local inputs remain diagnosable without echoing source content.
    config_catalog (SchemaCatalog): verified immutable schema fixture. path (str):
    selected relative workspace input. Returns None; memory-only effects; AssertionError
    on mismatch.
    """
    case = ConfigurationCase(config_catalog)
    case.disk.store.put(path, b'{"private-message": "do not disclose"}')

    result = diagnose(case)

    assert result.exit_code == 2 and not result.ok
    # Preserve the classified configuration failure without disclosing its bytes.
    assert any(row.code == "DOCTOR_CONFIGURATION" for row in result.findings)
    assert "do not disclose" not in result.to_json()
    assert result.input_manifest is not None
    # Even invalid bytes remain actual manifest inputs rather than invented absence.
    assert any(row.path == path for row in result.input_manifest.files)
    assert not case.registry.writes and not case.revocations


def test_ambiguous_profiles_remain_blocking(config_catalog: SchemaCatalog) -> None:
    """Doctor preserves ambiguity instead of choosing an arbitrary valid profile.
    config_catalog (SchemaCatalog): verified immutable schema fixture. Returns None;
    memory-only effects; AssertionError on mismatch.
    """
    case = ConfigurationCase(config_catalog)
    case.service.candidate_paths = (DEFAULT_PROFILE, "docs/custom/profile.yaml")
    case.disk.store.put(DEFAULT_PROFILE, profile_bytes())
    case.disk.store.put(
        "docs/custom/profile.yaml", profile_bytes("docs/custom/profile.yaml")
    )

    result = diagnose(case)

    assert result.exit_code == 2
    assert result.input_manifest is not None and len(result.input_manifest.files) == 2


@pytest.mark.parametrize("oversized", [False, True])
def test_read_failure_is_safe_and_has_no_side_effect(
    config_catalog: SchemaCatalog,
    monkeypatch: pytest.MonkeyPatch,
    oversized: bool,
) -> None:
    """An I/O exception is reported without its sensitive operating-system text.
    config_catalog (SchemaCatalog): verified immutable schema fixture. monkeypatch
    (pytest.MonkeyPatch): test-local restoration of injected seams. oversized (bool):
    whether the adapter returns excessive bytes. Returns None; memory-only effects;
    AssertionError on mismatch.
    """
    case = ConfigurationCase(config_catalog)
    case.disk.store.put(DEFAULT_PROFILE, profile_bytes())

    def fail(path: str, *, limit: int) -> bytes:
        """Reject a bounded memory read without accessing any filesystem. path (str):
        selected relative workspace input. limit (int): positive read capacity in bytes.
        Returns bytes; memory-only effects; AssertionError on mismatch.
        """
        assert path and limit > 0
        if oversized:
            return b"x" * (limit + 1)
        raise OSError("sensitive-host-path")

    monkeypatch.setattr(case.service, "read_bytes", fail)
    monkeypatch.setattr(
        "drm_copilot_discovery.doctor.ParseLimits",
        lambda: ParseLimits(document_bytes=512),
    )
    result = diagnose(case)

    assert result.exit_code == 3 and "sensitive-host-path" not in result.to_json()
    assert result.input_manifest is not None and not result.input_manifest.files
    assert not case.registry.writes and not case.revocations


@pytest.mark.parametrize("changed", ["profile", "locator", "activation"])
def test_changed_selection_cannot_report_healthy_configuration(
    config_catalog: SchemaCatalog,
    monkeypatch: pytest.MonkeyPatch,
    changed: str,
) -> None:
    """Mixed selection generations fail closed with the actual captured bytes.
    config_catalog (SchemaCatalog): verified immutable schema fixture. monkeypatch
    (pytest.MonkeyPatch): test-local restoration of injected seams. changed (str):
    selected inconsistent observation dimension. Returns None; memory-only effects;
    AssertionError on mismatch.
    """
    case = ConfigurationCase(config_catalog)
    case.service.configure(
        ConfigurationRequest(action="activate", profile_bytes=profile_bytes())
    )
    original = case.service.select()
    calls = 0

    def selected(
        self: ActivationStore,
        *,
        profile_path: str | None = None,
        controlled: bool = False,
    ) -> ConfigurationSelection:
        """Supply an inconsistent observation through the trusted selection seam.
        profile_path (str | None): optional selected relative profile. controlled
        (bool): whether protected mutation selection is requested. Returns
        ConfigurationSelection; memory-only effects; AssertionError on mismatch.
        """
        nonlocal calls
        assert (
            self.registry is case.registry and profile_path is None and not controlled
        )
        calls += 1
        # Change one observation dimension while keeping all other captured state.
        if changed == "profile":
            return replace(original, profile_bytes=b"changed")
        if changed == "locator":
            return replace(original, locator_bytes=b"changed")
        return replace(original, state="inactive") if calls > 1 else original

    monkeypatch.setattr(ActivationStore, "select", selected)
    before = (case.registry.writes, case.revocations)

    result = diagnose(case)

    assert result.exit_code == 3
    assert (case.registry.writes, case.revocations) == before


def test_candidate_capacity_is_checked_before_observation(
    config_catalog: SchemaCatalog,
) -> None:
    """Excessive configuration candidates cannot allocate or read a partial graph.
    config_catalog (SchemaCatalog): verified immutable schema fixture. Returns None;
    memory-only effects; AssertionError on mismatch.
    """
    case = ConfigurationCase(config_catalog)
    # Distinct bounded names exceed only the trusted candidate-count boundary.
    case.service.candidate_paths = tuple(
        f"profiles/p{index}.json" for index in range(1001)
    )

    result = diagnose(case)

    assert result.exit_code == 3 and not case.disk.store.calls
    assert result.input_manifest is not None and not result.input_manifest.files


def test_aggregate_capacity_rejects_next_file_before_reading(
    config_catalog: SchemaCatalog,
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """Exhausting retained bytes refuses another existing input before its read.
    config_catalog (SchemaCatalog): verified immutable schema fixture. monkeypatch
    (pytest.MonkeyPatch): test-local restoration of injected seams. Returns None;
    memory-only effects; AssertionError on mismatch.
    """
    case = ConfigurationCase(config_catalog)
    case.service.candidate_paths = ("profiles/a", "profiles/b", "profiles/c")
    # Each blob fits individually; the third exceeds aggregate retained capacity.
    for path in case.service.candidate_paths:
        case.disk.store.put(path, b"x" * 256)
    monkeypatch.setattr(
        "drm_copilot_discovery.doctor.ParseLimits",
        lambda: ParseLimits(document_bytes=512),
    )

    result = diagnose(case)

    assert result.exit_code == 3
    # Exhausted aggregate capacity must prevent the third native read.
    assert [path for path, _ in case.disk.store.calls] == ["profiles/a", "profiles/b"]
    assert result.input_manifest is not None
    # Only the two fully retained inputs contribute bytes to the failed manifest.
    assert sum(len(row.content) for row in result.input_manifest.files) == 512


def test_protected_profile_selection_shares_remaining_byte_capacity(
    config_catalog: SchemaCatalog,
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """A locator-selected profile cannot bypass the initial diagnostic budget.
    config_catalog (SchemaCatalog): verified immutable schema fixture. monkeypatch
    (pytest.MonkeyPatch): test-local restoration of injected seams. Returns None;
    memory-only effects; AssertionError on mismatch.
    """
    case = ConfigurationCase(config_catalog)
    path = "docs/custom/profile.yaml"
    content = profile_bytes(path)
    case.service.configure(
        ConfigurationRequest(
            action="activate", profile_path=path, profile_bytes=content
        )
    )
    locator = case.disk.store.files[LOCATOR_PATH]
    observed: list[tuple[str, int]] = []

    def bounded(path: str, *, limit: int) -> bytes:
        """Enforce the native bounded-read contract entirely in memory. path (str):
        selected relative workspace input. limit (int): positive read capacity in bytes.
        Returns bytes; memory-only effects; AssertionError on mismatch.
        """
        observed.append((path, limit))
        value = case.disk.store.files[path]
        if len(value) > limit:
            raise OSError("bounded read rejected")
        return value

    monkeypatch.setattr(case.service, "read_bytes", bounded)
    monkeypatch.setattr(
        "drm_copilot_discovery.doctor.ParseLimits",
        lambda: ParseLimits(document_bytes=len(locator) + len(content) - 1),
    )

    result = diagnose(case)

    assert result.exit_code == 3 and observed[-1] == (path, len(content) - 1)
    assert result.input_manifest is not None
    # The rejected selected profile must not appear as a successfully captured file.
    assert [row.path for row in result.input_manifest.files] == [LOCATOR_PATH]


def test_cached_selection_respects_a_stricter_reader_limit(
    config_catalog: SchemaCatalog,
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """A selection collaborator cannot reuse captured bytes above its own limit.
    config_catalog (SchemaCatalog): verified immutable schema fixture. monkeypatch
    (pytest.MonkeyPatch): test-local restoration of injected seams. Returns None;
    memory-only effects; AssertionError on mismatch.
    """
    case = ConfigurationCase(config_catalog)
    case.disk.store.put(DEFAULT_PROFILE, profile_bytes())

    def select(self: ActivationStore, **options: object) -> ConfigurationSelection:
        """Request a stricter bound through the composed read port. options
        (object): captured fixed keyword options. Returns ConfigurationSelection;
        memory-only effects; AssertionError on mismatch.
        """
        assert options == {"profile_path": None}
        self.read_bytes(DEFAULT_PROFILE, limit=1)
        raise AssertionError("An oversized cached read must fail")

    monkeypatch.setattr(ActivationStore, "select", select)

    result = diagnose(case)

    assert result.exit_code == 3
