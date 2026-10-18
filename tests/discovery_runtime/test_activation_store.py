"""Exercise root configuration with fresh memory stores and real mutation primitives."""

from __future__ import annotations

import os
from dataclasses import replace
from hashlib import sha256
from typing import TYPE_CHECKING

import pytest
from drm_copilot_discovery.activation_filesystem import RegistryLocation
from drm_copilot_discovery.activation_store import ActivationStore
from drm_copilot_discovery.configuration import (
    DEFAULT_PROFILE,
    LOCATOR_PATH,
    ActivationRecord,
    ConfigurationError,
    ConfigurationRequest,
)
from drm_copilot_discovery.profile_v2 import ProfileError

from tests.discovery_runtime.mutation_test_support import MemoryDisk
from tests.discovery_runtime.test_configuration import active_record, profile_bytes
from tests.discovery_runtime.test_configuration import config_catalog as config_catalog

if TYPE_CHECKING:
    from collections.abc import Callable

    from drm_copilot_discovery.catalog import SchemaCatalog
    from drm_copilot_discovery.path_models import ResolvedPath


class MemoryRegistry:
    """Retain protected bytes separately from a test's workspace and record all
    writes."""

    def __init__(self, disk: MemoryDisk) -> None:
        """Allocate isolated protected state with a shared workspace exclusion check."""
        self.disk = disk
        self.raw: bytes | None = None
        self.writes = 0
        self.after_write: Callable[[], None] = lambda: None

    def read(self) -> bytes | None:
        """Return the current protected observation without consulting workspace
        input."""
        return self.raw

    def write(self, content: bytes, *, expected: bytes | None) -> None:
        """Model guarded CAS and an observable post-write failure/race seam."""
        assert self.disk.locked and self.raw == expected
        self.raw = content
        self.writes += 1
        self.after_write()


class ConfigurationCase:
    """Own root context, registry, namespace and revocation state for exactly one
    test."""

    def __init__(
        self, catalog: SchemaCatalog, *, profile: str = DEFAULT_PROFILE
    ) -> None:
        """Build a real root operation over injected memory-only I/O boundaries."""
        self.disk = MemoryDisk()
        self.registry = MemoryRegistry(self.disk)
        self.authorized = True
        self.revocations = 0
        self.authorization_calls = 0
        self.on_revoke: Callable[[], None] = lambda: None
        self.location = RegistryLocation.for_host(
            workspace_root=self.disk.root,
            platform="windows" if os.name == "nt" else "linux",
            user_home="C:/users/example" if os.name == "nt" else "/users/example",
            local_app_data="C:/state" if os.name == "nt" else None,
        )
        self.service = ActivationStore(
            location=self.location,
            registry=self.registry,
            primitives=self.disk.provider(),
            metadata=self.disk.store.metadata,
            read_bytes=self.disk.store.read,
            open_directory=self.disk.open,
            catalog=catalog,
            authorize_root=self.authorize,
            invalidate_authority=self.revoke,
            candidate_paths=(profile,),
        )

    def authorize(self) -> None:
        """Model an independently verified native/user principal, never a request
        role."""
        self.authorization_calls += 1
        if not self.authorized:
            raise PermissionError("root configuration is required")

    def revoke(self) -> None:
        """Invalidate outstanding grants/receipts before every attempted transition."""
        self.revocations += 1
        self.on_revoke()

    def record(self) -> ActivationRecord:
        """Decode protected state for assertions without allowing workspace forgery."""
        assert self.registry.raw is not None
        return ActivationRecord.decode(
            self.registry.raw, workspace_sha256=self.location.workspace_sha256
        )


@pytest.mark.parametrize("path", [DEFAULT_PROFILE, "docs/custom/profile.yaml"])
def test_activate_update_and_deactivate_preserve_exact_audit_chain(
    config_catalog: SchemaCatalog, path: str
) -> None:
    """Root configuration writes exact bytes, revokes old grants and records
    deliberate deactivation."""
    case = ConfigurationCase(config_catalog, profile=path)
    content = profile_bytes(path)
    result = case.service.configure(
        ConfigurationRequest(
            action="activate", profile_path=path, profile_bytes=content
        )
    )
    assert result.ok and result.authority_invalidated and not result.uncertain
    assert case.revocations == 1 and case.disk.held == 0 and not case.disk.locked
    assert case.disk.store.files[path] == content
    assert case.service.select(controlled=True).state == "active"
    first = case.registry.raw
    updated = content + b"\n"
    result = case.service.configure(
        ConfigurationRequest(
            action="activate", profile_path=path, profile_bytes=updated
        )
    )
    assert result.ok and case.record().generation == 2
    assert case.record().previous_sha256 == sha256(first or b"").hexdigest()
    assert case.disk.store.files[path] == updated
    before = dict(case.disk.store.files)
    result = case.service.configure(ConfigurationRequest(action="deactivate"))
    assert result.ok and result.changed == ("protected-activation",)
    assert case.revocations == 3 and not case.record().active
    assert case.disk.store.files == before
    assert case.service.select(controlled=True).state == "inactive"


@pytest.mark.parametrize("action", ["activate", "deactivate"])
def test_only_trusted_root_can_configure_even_in_dry_run(
    config_catalog: SchemaCatalog, action: str
) -> None:
    """No request action, profile field or dry-run flag can fabricate root
    authorization."""
    case = ConfigurationCase(config_catalog)
    case.authorized = False
    request = replace(
        ConfigurationRequest(action="activate"), action=action, dry_run=True
    )
    with pytest.raises(PermissionError, match="root"):
        case.service.configure(request)
    assert (
        case.registry.raw is None
        and case.revocations == 0
        and not case.disk.store.files
    )


def test_dry_run_never_creates_directories_activation_or_revocations(
    config_catalog: SchemaCatalog,
) -> None:
    """Projected valid root intent performs only reads, including on a fresh
    workspace."""
    case = ConfigurationCase(config_catalog)
    before = dict(case.disk.store.metadata.entries)
    result = case.service.configure(
        ConfigurationRequest(
            action="activate", profile_bytes=profile_bytes(), dry_run=True
        )
    )
    assert result.ok and not result.changed and not result.authority_invalidated
    assert (
        case.registry.raw is None
        and case.registry.writes == 0
        and case.revocations == 0
    )
    assert case.disk.store.metadata.entries == before and not case.disk.store.files
    assert case.service.configure(
        ConfigurationRequest(action="deactivate", dry_run=True)
    ).ok
    assert case.registry.raw is None and case.revocations == 0


@pytest.mark.parametrize(
    "change",
    [
        "delete-profile",
        "delete-locator",
        "malformed-profile",
        "malformed-locator",
        "disable-locator",
    ],
)
def test_active_configuration_tampering_cannot_disable_gate(
    config_catalog: SchemaCatalog, change: str
) -> None:
    """Missing, malformed or disabled workspace declarations keep active discovery
    blocked."""
    case = ConfigurationCase(config_catalog)
    assert case.service.configure(
        ConfigurationRequest(action="activate", profile_bytes=profile_bytes())
    ).ok
    path = DEFAULT_PROFILE if "profile" in change else LOCATOR_PATH
    if change.startswith("delete"):
        del case.disk.store.files[path]
        case.disk.store.metadata.remove(path)
    else:
        case.disk.store.put(
            path, b'{"enabled":false}' if change == "disable-locator" else b"{}"
        )
    with pytest.raises((ConfigurationError, ProfileError)):
        case.service.select(controlled=True)
    assert case.record().active and case.registry.writes == 1
    assert case.service.configure(ConfigurationRequest(action="deactivate")).ok
    assert case.service.select(controlled=True).state == "inactive"


def test_partial_activation_keeps_protected_gate_active_and_recovers(
    config_catalog: SchemaCatalog,
) -> None:
    """A publication failure reports bounded effects and requires repair, never
    silent opt-out."""
    case = ConfigurationCase(config_catalog)
    case.disk.fail_publish = True
    result = case.service.configure(
        ConfigurationRequest(action="activate", profile_bytes=profile_bytes())
    )
    assert not result.ok and result.authority_invalidated
    assert (
        "protected-activation" in result.changed and DEFAULT_PROFILE in result.uncertain
    )
    assert case.record().active and not case.disk.locked and case.disk.held == 0
    with pytest.raises(ConfigurationError):
        case.service.select(controlled=True)
    case.disk.fail_publish = False
    assert case.service.configure(
        ConfigurationRequest(action="activate", profile_bytes=profile_bytes())
    ).ok
    assert case.service.select(controlled=True).state == "active"


def test_invalid_proposal_and_missing_profile_abort_without_effects(
    config_catalog: SchemaCatalog,
) -> None:
    """Accepted profile validation runs before lock acquisition, activation or
    invalidation."""
    case = ConfigurationCase(config_catalog)
    with pytest.raises(ProfileError):
        case.service.configure(
            ConfigurationRequest(action="activate", profile_bytes=b"{}")
        )
    with pytest.raises(ConfigurationError, match="requires a profile"):
        case.service.configure(ConfigurationRequest(action="activate"))
    assert (
        case.registry.raw is None
        and case.revocations == 0
        and not case.disk.store.files
    )


def test_inactive_workspace_and_missing_registry_are_read_only(
    config_catalog: SchemaCatalog,
) -> None:
    """Unrelated work remains unaffected without creating even an authority
    directory."""
    case = ConfigurationCase(config_catalog)
    assert case.service.select(controlled=True).state == "inactive"
    assert (
        case.registry.writes == 0
        and not case.disk.store.files
        and case.revocations == 0
    )
    case.disk.store.put(DEFAULT_PROFILE, profile_bytes())
    assert case.service.select().state == "activation-required"
    with pytest.raises(ConfigurationError, match="activation is required"):
        case.service.select(controlled=True)


def test_tombstone_read_cannot_hide_concurrent_activation(
    config_catalog: SchemaCatalog, monkeypatch: pytest.MonkeyPatch
) -> None:
    """The inactive fast path rechecks protected bytes before returning an opt-out."""
    case = ConfigurationCase(config_catalog)
    assert case.service.configure(ConfigurationRequest(action="deactivate")).ok
    original = case.registry.raw
    changed = replace(
        active_record(profile_bytes()),
        workspace_sha256=case.location.workspace_sha256,
        generation=2,
        previous_sha256=sha256(original or b"").hexdigest(),
    ).encode()
    reads: list[int] = []

    def racing_read() -> bytes | None:
        """Return the old observation once, while replacing its protected generation."""
        reads.append(1)
        return original if len(reads) == 1 else changed

    monkeypatch.setattr(case.registry, "read", racing_read)
    with pytest.raises(ConfigurationError, match="changed during inactive"):
        case.service.select()
    assert len(reads) == 2


def test_new_candidate_inside_guard_aborts_before_revocation_or_publication(
    config_catalog: SchemaCatalog, monkeypatch: pytest.MonkeyPatch
) -> None:
    """Candidate absence is part of guarded freshness, not only initial selection."""
    case = ConfigurationCase(config_catalog)
    alternate = "docs/other.yaml"
    case.service.candidate_paths = (DEFAULT_PROFILE, alternate)

    def racing_authorization() -> None:
        """Inject a competing known profile only after the original read and guard
        acquisition."""
        case.authorize()
        if case.authorization_calls == 2:
            case.disk.store.put(alternate, profile_bytes(alternate))

    monkeypatch.setattr(case.service, "authorize_root", racing_authorization)
    result = case.service.configure(
        ConfigurationRequest(action="activate", profile_bytes=profile_bytes())
    )
    assert not result.ok and result.error and "candidates changed" in result.error
    assert case.registry.raw is None and case.revocations == 0 and not result.changed
    assert set(case.disk.store.files) == {alternate}


@pytest.mark.parametrize("condition", ["profile-path", "candidate"])
def test_configuration_conflicts_are_rejected_before_lock_or_revocation(
    config_catalog: SchemaCatalog, condition: str
) -> None:
    """A root request cannot publish inconsistent paths or hide known candidates."""
    case = ConfigurationCase(config_catalog)
    if condition == "candidate":
        case.disk.store.put("docs/alternate.yaml", profile_bytes("docs/alternate.yaml"))
        case.service.candidate_paths = (DEFAULT_PROFILE, "docs/alternate.yaml")
    request = ConfigurationRequest(
        action="activate",
        profile_bytes=profile_bytes(),
        profile_path=(
            "docs/custom.yaml" if condition == "profile-path" else DEFAULT_PROFILE
        ),
    )
    with pytest.raises(ConfigurationError):
        case.service.configure(request)
    assert case.registry.writes == 0 and case.revocations == 0 and not case.disk.locked


@pytest.mark.parametrize("change", ["bytes", "parent", "candidate", "authorization"])
def test_guarded_input_changes_abort_before_protected_publication(
    config_catalog: SchemaCatalog, change: str, monkeypatch: pytest.MonkeyPatch
) -> None:
    """Freshness and authorization are checked again before protected state changes."""
    case = ConfigurationCase(config_catalog)
    alternate = "docs/alternate.yaml"
    case.service.candidate_paths = (DEFAULT_PROFILE, alternate)

    def mutate() -> None:
        """Inject one independent changed input at the explicit invalidation seam."""
        if change == "bytes":
            case.disk.store.put(DEFAULT_PROFILE, b"changed")
        elif change == "parent":
            case.disk.store.metadata.add("docs", kind="directory", identity="changed")
        else:
            case.disk.store.put(alternate, profile_bytes(alternate))

    if change == "authorization":

        def deny_second() -> None:
            """Revoke the trusted principal between planning and guard acquisition."""
            case.authorize()
            if case.authorization_calls == 2:
                raise PermissionError("root authorization revoked")

        monkeypatch.setattr(case.service, "authorize_root", deny_second)
    else:
        case.on_revoke = mutate
    result = case.service.configure(
        ConfigurationRequest(action="activate", profile_bytes=profile_bytes())
    )
    assert not result.ok and not result.changed and case.registry.raw is None
    assert result.authority_invalidated == (change != "authorization")
    assert not case.disk.locked and case.disk.held == 0


@pytest.mark.parametrize("change", ["root", "parent", "opened-parent", "leaf"])
def test_physical_substitutions_after_activation_intent_fail_explicitly(
    config_catalog: SchemaCatalog, change: str
) -> None:
    """Recorded active intent remains blocking if a publication anchor changes."""
    case = ConfigurationCase(config_catalog)

    def replace_path(path: str) -> None:
        """Substitute a directory only in the requested metadata-to-open interval."""
        if path == ("." if change == "root" else "docs"):
            prior = case.disk.store.metadata(path)
            case.disk.store.metadata.entries[path] = replace(prior, identity="changed")

    def after_record() -> None:
        """Change one pre-observed path after protected intent is recorded."""
        if change in {"root", "opened-parent"}:
            case.disk.before_open = replace_path
        elif change == "parent":
            replace_path("docs")
        else:
            case.disk.store.put(DEFAULT_PROFILE, b"concurrent leaf")

    case.registry.after_write = after_record
    result = case.service.configure(
        ConfigurationRequest(action="activate", profile_bytes=profile_bytes())
    )
    assert not result.ok and result.authority_invalidated and result.uncertain
    assert case.record().active and "protected-activation" in result.changed
    assert not case.disk.locked and case.disk.held == 0


@pytest.mark.parametrize("change", ["parent", "bytes", "candidate"])
def test_postpublication_changes_invalidate_configuration_success(
    config_catalog: SchemaCatalog, change: str, monkeypatch: pytest.MonkeyPatch
) -> None:
    """Retained parent identities and exact final bytes both bind successful output."""
    case = ConfigurationCase(config_catalog)
    alternate = "docs/alternate.yaml"
    case.service.candidate_paths = (DEFAULT_PROFILE, alternate)
    original = case.service.primitives.create_exclusive

    def publish(target: ResolvedPath, content: bytes) -> None:
        """Inject an observed external edit after the final atomic publication."""
        original(target, content)
        if target.path == LOCATOR_PATH:
            if change == "parent":
                case.disk.store.metadata.add(
                    "docs", kind="directory", identity="changed"
                )
            elif change == "bytes":
                case.disk.store.put(LOCATOR_PATH, b"changed")
            else:
                case.disk.store.put(alternate, profile_bytes(alternate))

    monkeypatch.setattr(case.service.primitives, "create_exclusive", publish)
    result = case.service.configure(
        ConfigurationRequest(action="activate", profile_bytes=profile_bytes())
    )
    assert not result.ok and result.authority_invalidated
    assert set(result.changed) >= {DEFAULT_PROFILE, LOCATOR_PATH}
    assert case.record().active and not case.disk.locked and case.disk.held == 0


def test_inactive_selection_rejects_a_concurrent_protected_record_change(
    config_catalog: SchemaCatalog, monkeypatch: pytest.MonkeyPatch
) -> None:
    """The ordinary inactive branch also rechecks protected state before return."""
    case = ConfigurationCase(config_catalog)
    observations = iter([None, b"new protected record"])
    monkeypatch.setattr(case.registry, "read", lambda: next(observations))
    with pytest.raises(ConfigurationError, match="changed during selection"):
        case.service.select()
    assert case.registry.writes == 0
