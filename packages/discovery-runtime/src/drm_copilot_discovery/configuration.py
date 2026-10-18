"""Select validated configuration without deriving native authority from input.

The host supplies captured candidates and protected registry data. These pure
values describe activation state; only the separately authorized store can change
it. Workspace locators never confer permission or disable protected activation.
"""

from __future__ import annotations

import json
import re
from dataclasses import asdict, dataclass
from hashlib import sha256
from typing import TYPE_CHECKING, Literal, cast

from drm_copilot_discovery.activation_models import ActivationLocator
from drm_copilot_discovery.findings import Finding
from drm_copilot_discovery.models import ParseLimits
from drm_copilot_discovery.parsing import parse_document
from drm_copilot_discovery.path_models import check_path_collisions, relative_path
from drm_copilot_discovery.profile_v2 import ProfileV2

if TYPE_CHECKING:
    from collections.abc import Mapping

    from drm_copilot_discovery.catalog import SchemaCatalog

DEFAULT_PROFILE = "docs/migration/discovery/domain-profile.yaml"
LOCATOR_PATH = "config/discovery.json"


class ConfigurationError(ValueError):
    """Carry actionable configuration findings without exposing partial selection."""

    def __init__(self, code: str, message: str, path: str | None = None) -> None:
        """Retain a stable code/path for service projection; perform no effects."""
        self.findings = (
            Finding(
                code=code,
                message=message,
                artifact_path=path,
                next_action=(
                    "Use the root configuration operation to repair "
                    "or activate discovery."
                ),
            ),
        )
        super().__init__(message)


def locator_bytes(profile_path: str) -> bytes:
    """Render the fixed four-key locator for a safe relative path, without I/O."""
    return (
        json.dumps(
            {
                "schema_version": "2.0.0",
                "enabled": True,
                "profile_path": relative_path(profile_path),
                "required_runtime_major": 2,
            },
            sort_keys=True,
            indent=2,
        ).encode()
        + b"\n"
    )


@dataclass(frozen=True, kw_only=True)
class ActivationRecord:
    """Represent one session-independent protected transition, never a capability.

    The store supplies these bytes outside the workspace. The predecessor digest
    records replacement provenance; generation changes invalidate older bindings.
    A deactivation tombstone is retained so leftover profiles cannot reactivate it.
    """

    workspace_sha256: str
    generation: int
    action: Literal["activate", "deactivate"]
    profile_path: str | None
    profile_sha256: str | None
    locator_sha256: str | None
    previous_sha256: str | None
    schema_version: Literal["2.0.0"] = "2.0.0"

    def __post_init__(self) -> None:
        """Reject malformed registry data rather than infer an inactive state."""
        if (
            self.schema_version != "2.0.0"
            or self.action not in {"activate", "deactivate"}
            or type(self.generation) is not int
            or self.generation < 1
        ):
            raise ValueError("Invalid activation version, action or generation")
        # Every digest binds exact observed bytes, including the replaced record.
        for value in (
            self.workspace_sha256,
            self.profile_sha256,
            self.locator_sha256,
            self.previous_sha256,
        ):
            if value is not None and (
                type(value) is not str or not re.fullmatch("[0-9a-f]{64}", value)
            ):
                raise ValueError("Activation digests must be lowercase SHA-256")
        if not self.workspace_sha256:
            raise ValueError("Activation requires a canonical workspace digest")
        if self.profile_path is not None:
            relative_path(self.profile_path)
        linked = (self.profile_path, self.profile_sha256, self.locator_sha256)
        if any(value is None for value in linked) and (
            self.action == "activate" or any(value is not None for value in linked)
        ):
            raise ValueError("Activation profile and locator bindings must be complete")

    @property
    def active(self) -> bool:
        """Return the recorded transition state, not authorization for an operation."""
        return self.action == "activate"

    def encode(self) -> bytes:
        """Return deterministic JSON bytes for protected storage; no writes occur."""
        return json.dumps(asdict(self), sort_keys=True, indent=2).encode() + b"\n"

    @classmethod
    def decode(cls, content: bytes, *, workspace_sha256: str) -> ActivationRecord:
        """Parse bounded strict JSON and reject wrong workspace or extra fields."""
        parsed = parse_document(
            content, format="json", limits=ParseLimits(document_bytes=65536)
        )
        value = parsed.value
        fields = {
            "workspace_sha256",
            "generation",
            "action",
            "profile_path",
            "profile_sha256",
            "locator_sha256",
            "previous_sha256",
            "schema_version",
        }
        if value is None or set(value) != fields:
            raise ConfigurationError(
                "ACTIVATION_INVALID", "Protected activation record is malformed."
            )
        try:
            record = cls(
                workspace_sha256=cast("str", value["workspace_sha256"]),
                generation=cast("int", value["generation"]),
                action=cast('Literal["activate", "deactivate"]', value["action"]),
                profile_path=cast("str | None", value["profile_path"]),
                profile_sha256=cast("str | None", value["profile_sha256"]),
                locator_sha256=cast("str | None", value["locator_sha256"]),
                previous_sha256=cast("str | None", value["previous_sha256"]),
                schema_version=cast('Literal["2.0.0"]', value["schema_version"]),
            )
        except (TypeError, ValueError) as error:
            raise ConfigurationError(
                "ACTIVATION_INVALID", "Protected activation fields are invalid."
            ) from error
        if record.workspace_sha256 != workspace_sha256:
            raise ConfigurationError(
                "ACTIVATION_WORKSPACE",
                "Protected activation belongs to another workspace.",
            )
        return record


@dataclass(frozen=True, kw_only=True)
class ConfigurationSelection:
    """Return an inert readiness result and the exact selected raw configuration."""

    state: Literal["inactive", "activation-required", "active"]
    profile_path: str | None = None
    profile: ProfileV2 | None = None
    profile_bytes: bytes | None = None
    locator_bytes: bytes | None = None


def select_configuration(
    *,
    candidates: Mapping[str, bytes],
    locator: bytes | None,
    activation: ActivationRecord | None,
    catalog: SchemaCatalog,
    profile_path: str | None = None,
    controlled: bool = False,
) -> ConfigurationSelection:
    """Select exactly one captured profile, preserving protected active failures.

    Args are trusted observations plus an optional untrusted relative selector.
    Returns inactive only for nonparticipants or explicit protected deactivation.
    Raises ConfigurationError/ProfileError on ambiguity, stale or malformed input.
    This pure function performs no reads, writes, activation or authorization.
    """
    if profile_path is not None:
        relative_path(profile_path)
    # Recorded deactivation overrides leftover files only for implicit gate checks.
    if activation is not None and not activation.active and profile_path is None:
        return ConfigurationSelection(state="inactive")
    check_path_collisions(candidates)
    if len(candidates) > 1:
        raise ConfigurationError(
            "CONFIGURATION_AMBIGUOUS",
            "Multiple candidate profiles require one explicit root configuration.",
        )
    parsed_locator = (
        ActivationLocator(locator, catalog=catalog) if locator is not None else None
    )
    if parsed_locator is not None and profile_path is not None:
        if parsed_locator.profile_path != profile_path:
            raise ConfigurationError(
                "CONFIGURATION_DISAGREEMENT",
                "Profile argument disagrees with the workspace locator.",
                LOCATOR_PATH,
            )
    selected = profile_path or (
        parsed_locator.profile_path if parsed_locator else DEFAULT_PROFILE
    )
    # An active protected record cannot be disabled by deleting or editing the locator.
    if activation is not None and activation.active:
        if parsed_locator is None or (
            selected != activation.profile_path
            or sha256(cast("bytes", locator)).hexdigest() != activation.locator_sha256
        ):
            raise ConfigurationError(
                "ACTIVATION_STALE",
                "Active locator is missing or differs from protected activation.",
                LOCATOR_PATH,
            )
    content = candidates.get(selected)
    if content is None:
        if (
            not candidates
            and parsed_locator is None
            and activation is None
            and profile_path is None
        ):
            return ConfigurationSelection(state="inactive")
        raise ConfigurationError(
            "CONFIGURATION_MISSING",
            "The selected discovery profile is missing.",
            selected,
        )
    profile = ProfileV2(content, catalog=catalog)
    if profile.artifacts["profile"] != selected:
        raise ConfigurationError(
            "CONFIGURATION_DISAGREEMENT",
            "Profile location differs from its configured artifact path.",
            selected,
        )
    state: Literal["active", "activation-required"] = "activation-required"
    if activation is not None and activation.active:
        if sha256(content).hexdigest() != activation.profile_sha256:
            raise ConfigurationError(
                "ACTIVATION_STALE",
                "Active profile bytes changed without root configuration.",
                selected,
            )
        state = "active"
    if controlled and state != "active":
        raise ConfigurationError(
            "ACTIVATION_REQUIRED",
            "Explicit root activation is required before controlled discovery starts.",
            selected,
        )
    return ConfigurationSelection(
        state=state,
        profile_path=selected,
        profile=profile,
        profile_bytes=content,
        locator_bytes=locator,
    )


@dataclass(frozen=True, kw_only=True)
class ConfigurationRequest:
    """Describe root configuration intent without any role, authority path or grant."""

    action: Literal["activate", "deactivate"]
    profile_path: str = DEFAULT_PROFILE
    profile_bytes: bytes | None = None
    dry_run: bool = False

    def __post_init__(self) -> None:
        """Reject unsupported actions and unsafe or irrelevant profile arguments."""
        relative_path(self.profile_path)
        if (
            self.action not in {"activate", "deactivate"}
            or type(self.dry_run) is not bool
        ):
            raise ValueError("Choose activate/deactivate and a boolean dry_run")
        if self.profile_bytes is not None and type(self.profile_bytes) is not bytes:
            raise ValueError("Profile input must be immutable bytes")
        if self.action == "deactivate" and (
            self.profile_bytes is not None or self.profile_path != DEFAULT_PROFILE
        ):
            raise ValueError("Deactivation does not accept profile changes")


@dataclass(frozen=True, kw_only=True)
class ConfigurationResult:
    """Report exact completed effects and bounded uncertainty after a root operation."""

    ok: bool
    action: Literal["activate", "deactivate"]
    changed: tuple[str, ...] = ()
    uncertain: tuple[str, ...] = ()
    authority_invalidated: bool = False
    error: str | None = None
