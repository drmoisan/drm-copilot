"""Bind root configuration changes to a protected, session-independent registry.

Trusted composition supplies canonical workspace/user-state paths, authorization
and revocation callbacks. Requests cannot select these capabilities. Authorized
writers cooperate through one external workspace lock; publication is per file,
not a kernel digest CAS or a multi-file transaction against unrelated processes.
"""

from __future__ import annotations

from contextlib import ExitStack
from dataclasses import replace
from hashlib import sha256
from pathlib import Path
from typing import TYPE_CHECKING, Protocol

from drm_copilot_discovery.activation_filesystem import NativeRegistry, RegistryLocation
from drm_copilot_discovery.activation_models import ActivationLocator
from drm_copilot_discovery.configuration import (
    DEFAULT_PROFILE,
    LOCATOR_PATH,
    ActivationRecord,
    ConfigurationError,
    ConfigurationRequest,
    ConfigurationResult,
    ConfigurationSelection,
    locator_bytes,
    select_configuration,
)
from drm_copilot_discovery.mutation_filesystem import (
    LocalMutationPrimitives,
    open_local_directory,
)
from drm_copilot_discovery.path_models import WriteGrant, relative_path
from drm_copilot_discovery.path_policy import PathPolicy
from drm_copilot_discovery.profile_v2 import ProfileV2

if TYPE_CHECKING:
    from collections.abc import Callable
    from contextlib import AbstractContextManager

    from drm_copilot_discovery.catalog import SchemaCatalog
    from drm_copilot_discovery.mutation_filesystem import Directory
    from drm_copilot_discovery.mutation_io import MutationPrimitives
    from drm_copilot_discovery.path_models import PathMetadataReader, ResolvedPath
    from drm_copilot_discovery.snapshot_io import WorkspaceBytes


class RegistryIO(Protocol):
    """Read and conditionally replace a fixed protected record under the shared
    guard."""

    def read(self) -> bytes | None:
        """Return exact protected bytes or genuine absence; other I/O errors
        propagate."""
        ...

    def write(self, content: bytes, *, expected: bytes | None) -> None:
        """Publish complete bytes only if the guarded original still matches."""
        ...


class ActivationStore:
    """Coordinate explicit root changes while configuration inputs remain inert.

    The host supplies authorization/revocation callbacks and one guarded native
    writer. Selection reads the registry directly; it accepts no caller-provided
    record, success flag, authority path, role or invocation identity. A partial
    activation leaves a protected active record so missing inputs continue blocking.
    """

    def __init__(
        self,
        *,
        location: RegistryLocation,
        registry: RegistryIO,
        primitives: MutationPrimitives,
        metadata: PathMetadataReader,
        read_bytes: WorkspaceBytes,
        open_directory: Callable[[], AbstractContextManager[Directory]],
        catalog: SchemaCatalog,
        authorize_root: Callable[[], None],
        invalidate_authority: Callable[[], None],
        candidate_paths: tuple[str, ...] = (DEFAULT_PROFILE,),
    ) -> None:
        """Bind trusted collaborators; candidate paths are observations, not
        permissions."""
        self.location, self.registry, self.primitives = location, registry, primitives
        self.metadata, self.read_bytes, self.catalog = metadata, read_bytes, catalog
        self.open_directory = open_directory
        self.authorize_root, self.invalidate_authority = (
            authorize_root,
            invalidate_authority,
        )
        # Reject unsafe candidate spelling before any filesystem call.
        self.candidate_paths = tuple(relative_path(path) for path in candidate_paths)

    @classmethod
    def local(
        cls,
        *,
        location: RegistryLocation,
        catalog: SchemaCatalog,
        authorize_root: Callable[[], None],
        invalidate_authority: Callable[[], None],
        candidate_paths: tuple[str, ...] = (DEFAULT_PROFILE,),
    ) -> ActivationStore:
        """Wire the real provider from host-resolved paths; no request can call this
        factory."""
        workspace = Path(location.workspace)
        state = Path(location.directory)
        if workspace.resolve(strict=True) != workspace or state.resolve() != state:
            raise ValueError(
                "Host paths must already resolve to their canonical locations"
            )
        if state.is_relative_to(workspace):
            raise ValueError("Activation registry must be external")
        registry = NativeRegistry(location)
        primitives = LocalMutationPrimitives(
            workspace_root=str(workspace),
            lock_path=str(state / "mutation.lock"),
            lock=registry.guard,
        )
        return cls(
            location=location,
            registry=registry,
            primitives=primitives,
            metadata=primitives.metadata,
            read_bytes=primitives.read_bytes,
            open_directory=lambda: open_local_directory(workspace),
            catalog=catalog,
            authorize_root=authorize_root,
            invalidate_authority=invalidate_authority,
            candidate_paths=candidate_paths,
        )

    def _optional(self, path: str) -> bytes | None:
        """Read bounded ordinary configuration, preserving genuine absence only."""
        relative_path(path)
        if self.metadata(path).kind == "missing":
            return None
        return self.read_bytes(path, limit=16777216)

    def _record(self, raw: bytes | None) -> ActivationRecord | None:
        """Reject malformed/wrong-workspace protected records rather than disable
        gates."""
        return (
            None
            if raw is None
            else ActivationRecord.decode(
                raw, workspace_sha256=self.location.workspace_sha256
            )
        )

    def select(
        self, *, profile_path: str | None = None, controlled: bool = False
    ) -> ConfigurationSelection:
        """Read exact configuration and protected state; never create registry or
        workspace files."""
        raw = self.registry.read()
        record = self._record(raw)
        if record is not None and not record.active and profile_path is None:
            if self.registry.read() != raw:
                raise ConfigurationError(
                    "CONFIGURATION_CHANGED",
                    "Activation changed during inactive selection; reload.",
                )
            return ConfigurationSelection(state="inactive")
        locator = self._optional(LOCATOR_PATH)
        parsed = (
            ActivationLocator(locator, catalog=self.catalog)
            if locator is not None
            else None
        )
        paths = set(self.candidate_paths)
        # Every explicit or protected selector participates in ambiguity detection.
        for path in (
            profile_path,
            parsed.profile_path if parsed else None,
            record.profile_path if record else None,
        ):
            if path is not None:
                paths.add(relative_path(path))
        content = {path: self._optional(path) for path in sorted(paths)}
        candidates = {
            path: value for path, value in content.items() if value is not None
        }
        selected = select_configuration(
            candidates=candidates,
            locator=locator,
            activation=record,
            catalog=self.catalog,
            profile_path=profile_path,
            controlled=controlled,
        )
        if selected.profile is not None:
            self._policy(selected.profile).validate_configuration()
        # Concurrent edits cannot turn a read of mixed generations into a valid
        # selection.
        if (
            self.registry.read() != raw
            or self._optional(LOCATOR_PATH) != locator
            or any(self._optional(path) != value for path, value in content.items())
        ):
            raise ConfigurationError(
                "CONFIGURATION_CHANGED",
                "Configuration changed during selection; reload.",
            )
        return selected

    def _policy(self, profile: ProfileV2) -> PathPolicy:
        """Reuse accepted path validation with exact host metadata and workspace
        binding."""
        return PathPolicy(
            profile, workspace_root=self.location.workspace, metadata=self.metadata
        )

    def _parents(
        self,
        target: ResolvedPath,
        anchors: ExitStack,
        opened: dict[str, str],
        changed: list[str],
    ) -> None:
        """Retain exact pre-observed or exclusively created ancestors through
        postcheck."""
        directory = anchors.enter_context(self.open_directory())
        if directory.identity() != target.observations[0].identity:
            raise OSError("Opened configuration workspace identity changed")
        opened["."] = directory.identity()
        # Creation is rooted in the physical observations, never a synthetic profile.
        for stamp in target.observations[1:-1]:
            current = self.metadata(stamp.path)
            expected_identity = opened.get(stamp.path, stamp.identity)
            expected_kind = "directory" if stamp.path in opened else stamp.kind
            if (current.kind, current.identity) != (expected_kind, expected_identity):
                raise OSError("Configuration parent changed before publication")
            directory = anchors.enter_context(
                directory.child(
                    stamp.path.split("/")[-1], create=current.kind == "missing"
                )
            )
            if current.kind != "missing" and directory.identity() != current.identity:
                raise OSError("Opened configuration parent identity changed")
            opened[stamp.path] = directory.identity()
            if current.kind == "missing":
                changed.append(stamp.path)

    def _require_inputs(
        self,
        raw: bytes | None,
        writes: tuple[tuple[str, bytes, bytes | None], ...],
        policy: PathPolicy | None,
        observations: tuple[ResolvedPath, ...],
        candidates: tuple[tuple[str, bytes | None], ...],
    ) -> None:
        """Reject changed original bytes and parent/leaf identities before any
        publication."""
        if self.registry.read() != raw or any(
            self._optional(path) != old for path, _, old in writes
        ):
            raise OSError("Configuration bytes changed before root commit")
        if any(self._optional(path) != content for path, content in candidates):
            raise OSError("Configuration candidates changed before root commit")
        if (
            policy is not None
            and tuple(
                policy.resolve_read(path, allow_missing=True) for path, _, _ in writes
            )
            != observations
        ):
            raise OSError("Configuration parent identities changed before commit")

    def configure(self, request: ConfigurationRequest) -> ConfigurationResult:
        """Validate root intent, revoke old authority and report exact/uncertain
        effects.

        Authorization is injected from native/user context, never a request role.
        Dry-run performs the same prewrite validation without locks or effects.
        Invalid proposed data raises before writes; guarded I/O errors return an
        explicit partial result. Deactivation retains a protected audit tombstone.
        """
        self.authorize_root()
        raw = self.registry.read()
        prior = self._record(raw)
        writes: tuple[tuple[str, bytes, bytes | None], ...] = ()
        policy: PathPolicy | None = None
        observations: tuple[ResolvedPath, ...] = ()
        candidates: tuple[tuple[str, bytes | None], ...] = ()
        profile_path = prior.profile_path if prior else None
        profile_hash = prior.profile_sha256 if prior else None
        locator_hash = prior.locator_sha256 if prior else None
        # Only activation can alter workspace configuration; deactivation is external.
        if request.action == "activate":
            original = self._optional(request.profile_path)
            proposed = (
                request.profile_bytes if request.profile_bytes is not None else original
            )
            if proposed is None:
                raise ConfigurationError(
                    "CONFIGURATION_MISSING",
                    "Activation requires a profile.",
                    request.profile_path,
                )
            profile = ProfileV2(proposed, catalog=self.catalog)
            if profile.artifacts["profile"] != request.profile_path:
                raise ConfigurationError(
                    "CONFIGURATION_DISAGREEMENT",
                    "Proposed profile path differs from its configuration.",
                    request.profile_path,
                )
            policy = self._policy(profile)
            policy.validate_configuration()
            profile_path = request.profile_path
            locator = locator_bytes(profile_path)
            writes = (
                (profile_path, proposed, original),
                (LOCATOR_PATH, locator, self._optional(LOCATOR_PATH)),
            )
            observations = tuple(
                policy.resolve_read(path, allow_missing=True) for path, _, _ in writes
            )
            # A second known candidate cannot be silently hidden by changing the
            # locator.
            candidates = tuple(
                (path, self._optional(path)) for path in self.candidate_paths
            )
            if any(
                path != profile_path and content is not None
                for path, content in candidates
            ):
                raise ConfigurationError(
                    "CONFIGURATION_AMBIGUOUS",
                    "Remove competing profile candidates through an explicit "
                    "root operation.",
                )
            profile_hash, locator_hash = (
                sha256(proposed).hexdigest(),
                sha256(locator).hexdigest(),
            )
        next_record = ActivationRecord(
            workspace_sha256=self.location.workspace_sha256,
            generation=1 if prior is None else prior.generation + 1,
            action=request.action,
            profile_path=profile_path,
            profile_sha256=profile_hash,
            locator_sha256=locator_hash,
            previous_sha256=None if raw is None else sha256(raw).hexdigest(),
        ).encode()
        if request.dry_run:
            return ConfigurationResult(ok=True, action=request.action)
        changed: list[str] = []
        uncertain: tuple[str, ...] = ("protected-activation",)
        revoked = False
        try:
            with self.primitives.guard(), ExitStack() as anchors:
                self.authorize_root()
                self._require_inputs(raw, writes, policy, observations, candidates)
                self.invalidate_authority()
                revoked = True
                self._require_inputs(raw, writes, policy, observations, candidates)
                uncertain = ("protected-activation",)
                # Record active intent first: partial workspace writes must keep gates
                # active.
                self.registry.write(next_record, expected=raw)
                changed.append("protected-activation")
                uncertain = ()
                opened: dict[str, str] = {}
                if policy is not None:
                    # Shared primitives publish exact root-only paths without widening
                    # analyst grants.
                    for (path, content, original), observed in zip(
                        writes, observations, strict=True
                    ):
                        uncertain = tuple(
                            stamp.path
                            for stamp in observed.observations
                            if stamp.kind == "missing"
                        ) or (path,)
                        leaf, current_leaf = observed.observations[-1], self.metadata(
                            path
                        )
                        if (leaf.kind, leaf.identity, leaf.resolved_path) != (
                            current_leaf.kind,
                            current_leaf.identity,
                            current_leaf.resolved_path,
                        ):
                            raise OSError(
                                "Configuration file identity changed before publication"
                            )
                        self._parents(observed, anchors, opened, changed)
                        if content == original:
                            uncertain = ()
                            continue
                        target = policy.resolve_read(path, allow_missing=True)
                        uncertain = tuple(
                            stamp.path
                            for stamp in target.observations
                            if stamp.kind == "missing"
                        ) or (path,)
                        target = replace(
                            target,
                            grant=WriteGrant(
                                artifact_kind=(
                                    "activation"
                                    if path == LOCATOR_PATH
                                    else "domain-profile"
                                ),
                                artifact_id="root-configuration",
                                path=path,
                            ),
                        )
                        if original is None:
                            self.primitives.create_exclusive(target, content)
                        else:
                            self.primitives.replace_if_digest(
                                target,
                                content,
                                expected_sha256=sha256(original).hexdigest(),
                            )
                        changed.append(path)
                        uncertain = ()
                # Newly created and pre-existing retained identities must still name the
                # same parents.
                if any(
                    self.metadata(path).identity != identity
                    for path, identity in opened.items()
                ):
                    raise OSError(
                        "Configuration parent identity changed after publication"
                    )
                expected_files = dict(candidates)
                expected_files.update((path, content) for path, content, _ in writes)
                if self.registry.read() != next_record or any(
                    self._optional(path) != content
                    for path, content in expected_files.items()
                ):
                    raise OSError("Configuration changed after publication")
            return ConfigurationResult(
                ok=True,
                action=request.action,
                changed=tuple(changed),
                authority_invalidated=revoked,
            )
        except (OSError, ValueError) as error:
            return ConfigurationResult(
                ok=False,
                action=request.action,
                changed=tuple(changed),
                uncertain=uncertain,
                authority_invalidated=revoked,
                error=str(error),
            )
