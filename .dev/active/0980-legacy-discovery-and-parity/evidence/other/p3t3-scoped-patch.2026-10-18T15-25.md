# P3-T3 exact staged review patch

Timestamp: 2026-10-18T15-25
Baseline: 639c37269ed12b0bd4b5d74d66723e2f5ce4dedd
Scope: six P3-T3 files plus two explicitly authorized provider prerequisite files.
Representation: UTF-8 full-index unified diff with zero context; unchanged blank context lines are omitted.

```diff
diff --git a/packages/discovery-runtime/src/drm_copilot_discovery/activation_filesystem.py b/packages/discovery-runtime/src/drm_copilot_discovery/activation_filesystem.py
new file mode 100644
index 0000000000000000000000000000000000000000..771dfe685c7d2af14a7730f1c705e8038edf3c77
--- /dev/null
+++ b/packages/discovery-runtime/src/drm_copilot_discovery/activation_filesystem.py
@@ -0,0 +1,179 @@
+"""Protect external activation bytes through the accepted native directory
+primitives."""
+
+from __future__ import annotations
+
+from contextlib import ExitStack, contextmanager
+from dataclasses import dataclass
+from hashlib import sha256
+from pathlib import Path, PurePosixPath, PureWindowsPath
+from typing import TYPE_CHECKING, Literal
+from uuid import uuid4
+
+from drm_copilot_discovery.mutation_filesystem import open_local_directory
+from drm_copilot_discovery.path_models import relative_path
+
+if TYPE_CHECKING:
+    from collections.abc import Callable, Generator
+    from contextlib import AbstractContextManager
+
+    from drm_copilot_discovery.mutation_filesystem import Directory
+
+
+@dataclass(frozen=True, kw_only=True)
+class RegistryLocation:
+    """Derive workspace-specific paths from host-resolved locations, never requests.
+
+    The trusted host resolves aliases before construction. Windows identity uses
+    native separators and invariant lowercase, matching the existing authority
+    store. Linux/macOS preserve case. No directories are created by this value.
+    """
+
+    workspace: str
+    workspace_sha256: str
+    directory: str
+
+    @classmethod
+    def for_host(
+        cls,
+        *,
+        workspace_root: str,
+        platform: Literal["windows", "macos", "linux"],
+        user_home: str,
+        local_app_data: str | None = None,
+        xdg_state_home: str | None = None,
+    ) -> RegistryLocation:
+        """Return canonical external storage paths from trusted host values only."""
+        path_type = PureWindowsPath if platform == "windows" else PurePosixPath
+        workspace, home = path_type(workspace_root), path_type(user_home)
+        # Platform state locations are fixed policy; profiles cannot redirect them.
+        if platform == "windows":
+            if not local_app_data:
+                raise ValueError("Trusted LocalApplicationData is required")
+            base = path_type(local_app_data)
+        elif platform == "macos":
+            base = home / "Library/Application Support"
+        elif platform == "linux":
+            base = (
+                path_type(xdg_state_home) if xdg_state_home else home / ".local/state"
+            )
+        else:
+            raise ValueError("Unsupported activation registry platform")
+        if any(
+            not path.is_absolute() or ".." in path.parts
+            for path in (workspace, home, base)
+        ):
+            raise ValueError("Trusted host paths must be absolute and canonical")
+        root = base / "drm-copilot/discovery"
+        if root.is_relative_to(workspace):
+            raise ValueError("Activation authority must remain outside the workspace")
+        canonical = str(workspace).lower() if platform == "windows" else str(workspace)
+        digest = sha256(canonical.encode()).hexdigest()
+        return cls(
+            workspace=workspace.as_posix(),
+            workspace_sha256=digest,
+            directory=(root / "workspaces" / digest).as_posix(),
+        )
+
+
+class NativeRegistry:
+    """Use the accepted anchored directory primitives for a fixed external record.
+
+    Reads never create paths. The root operation provisions state directories and
+    holds mutation.lock through workspace and registry publication. No stale lock
+    is stolen. Injected directory and nonce seams keep unit tests in memory.
+    """
+
+    def __init__(
+        self,
+        location: RegistryLocation,
+        *,
+        opener: Callable[
+            [Path], AbstractContextManager[Directory]
+        ] = open_local_directory,
+        nonce: Callable[[], str] = lambda: uuid4().hex,
+    ) -> None:
+        """Retain trusted deployment values without performing I/O or granting root."""
+        self.location, self._opener, self._nonce = location, opener, nonce
+        self._held: Directory | None = None
+        self._identities: dict[str, str] = {}
+
+    @contextmanager
+    def _directory(
+        self, *, create: bool, capture: dict[str, str] | None = None
+    ) -> Generator[Directory, None, None]:
+        """Pin every ordinary ancestor, exclusively creating absent state
+        directories."""
+        path = Path(self.location.directory)
+        with ExitStack() as anchors:
+            directory = anchors.enter_context(self._opener(Path(path.anchor)))
+            current = Path(path.anchor)
+            self._identity(current, directory, capture)
+            # The complete absolute chain remains open until the protected I/O ends.
+            for name in path.parts[1:]:
+                try:
+                    child = anchors.enter_context(directory.child(name, create=False))
+                except FileNotFoundError:
+                    if not create:
+                        raise
+                    child = anchors.enter_context(directory.child(name, create=True))
+                directory = child
+                current /= name
+                self._identity(current, directory, capture)
+            yield directory
+
+    def _identity(
+        self, path: Path, directory: Directory, capture: dict[str, str] | None
+    ) -> None:
+        """Bind opened state ancestors to the retained guard, rejecting namespace
+        replacement."""
+        name, identity = path.as_posix(), directory.identity()
+        if name in self._identities and self._identities[name] != identity:
+            raise OSError("Protected activation parent identity changed")
+        if capture is not None:
+            capture[name] = identity
+
+    def read(self) -> bytes | None:
+        """Read the bounded fixed record without creating even its parent directory."""
+        try:
+            with self._directory(create=False) as directory:
+                try:
+                    return directory.read("activation.json", limit=65536)
+                except FileNotFoundError:
+                    return None
+        except FileNotFoundError:
+            if self._held is not None:
+                raise OSError("Protected activation directory disappeared") from None
+            return None
+
+    @contextmanager
+    def guard(self) -> Generator[None, None, None]:
+        """Serialize cooperating writers with the canonical external mutation lock."""
+        if self._held is not None:
+            raise OSError("Activation guard is already held")
+        identities: dict[str, str] = {}
+        with self._directory(create=True, capture=identities) as directory:
+            directory.stage("mutation.lock", b"")
+            self._held = directory
+            self._identities = identities
+            try:
+                yield
+            finally:
+                self._held = None
+                self._identities = {}
+                directory.remove("mutation.lock")
+
+    def write(self, content: bytes, *, expected: bytes | None) -> None:
+        """Check original bytes under exclusion, then atomically publish one record."""
+        directory = self._held
+        if directory is None:
+            raise OSError("Protected activation publication requires its guard")
+        if self.read() != expected:
+            raise OSError("Protected activation changed before publication")
+        name = relative_path(".activation-" + self._nonce())
+        directory.stage(name, content)
+        with ExitStack() as cleanup:
+            cleanup.callback(directory.remove, name)
+            directory.publish(name, "activation.json", replace=expected is not None)
+            if expected is not None:
+                cleanup.pop_all()
diff --git a/packages/discovery-runtime/src/drm_copilot_discovery/activation_store.py b/packages/discovery-runtime/src/drm_copilot_discovery/activation_store.py
new file mode 100644
index 0000000000000000000000000000000000000000..4d3cb9d2a9e79783bf5f4adb44d2485869842c5a
--- /dev/null
+++ b/packages/discovery-runtime/src/drm_copilot_discovery/activation_store.py
@@ -0,0 +1,453 @@
+"""Bind root configuration changes to a protected, session-independent registry.
+
+Trusted composition supplies canonical workspace/user-state paths, authorization
+and revocation callbacks. Requests cannot select these capabilities. Authorized
+writers cooperate through one external workspace lock; publication is per file,
+not a kernel digest CAS or a multi-file transaction against unrelated processes.
+"""
+
+from __future__ import annotations
+
+from contextlib import ExitStack
+from dataclasses import replace
+from hashlib import sha256
+from pathlib import Path
+from typing import TYPE_CHECKING, Protocol
+
+from drm_copilot_discovery.activation_filesystem import NativeRegistry, RegistryLocation
+from drm_copilot_discovery.activation_models import ActivationLocator
+from drm_copilot_discovery.configuration import (
+    DEFAULT_PROFILE,
+    LOCATOR_PATH,
+    ActivationRecord,
+    ConfigurationError,
+    ConfigurationRequest,
+    ConfigurationResult,
+    ConfigurationSelection,
+    locator_bytes,
+    select_configuration,
+)
+from drm_copilot_discovery.mutation_filesystem import (
+    LocalMutationPrimitives,
+    open_local_directory,
+)
+from drm_copilot_discovery.path_models import WriteGrant, relative_path
+from drm_copilot_discovery.path_policy import PathPolicy
+from drm_copilot_discovery.profile_v2 import ProfileV2
+
+if TYPE_CHECKING:
+    from collections.abc import Callable
+    from contextlib import AbstractContextManager
+
+    from drm_copilot_discovery.catalog import SchemaCatalog
+    from drm_copilot_discovery.mutation_filesystem import Directory
+    from drm_copilot_discovery.mutation_io import MutationPrimitives
+    from drm_copilot_discovery.path_models import PathMetadataReader, ResolvedPath
+    from drm_copilot_discovery.snapshot_io import WorkspaceBytes
+
+
+class RegistryIO(Protocol):
+    """Read and conditionally replace a fixed protected record under the shared
+    guard."""
+
+    def read(self) -> bytes | None:
+        """Return exact protected bytes or genuine absence; other I/O errors
+        propagate."""
+        ...
+
+    def write(self, content: bytes, *, expected: bytes | None) -> None:
+        """Publish complete bytes only if the guarded original still matches."""
+        ...
+
+
+class ActivationStore:
+    """Coordinate explicit root changes while configuration inputs remain inert.
+
+    The host supplies authorization/revocation callbacks and one guarded native
+    writer. Selection reads the registry directly; it accepts no caller-provided
+    record, success flag, authority path, role or invocation identity. A partial
+    activation leaves a protected active record so missing inputs continue blocking.
+    """
+
+    def __init__(
+        self,
+        *,
+        location: RegistryLocation,
+        registry: RegistryIO,
+        primitives: MutationPrimitives,
+        metadata: PathMetadataReader,
+        read_bytes: WorkspaceBytes,
+        open_directory: Callable[[], AbstractContextManager[Directory]],
+        catalog: SchemaCatalog,
+        authorize_root: Callable[[], None],
+        invalidate_authority: Callable[[], None],
+        candidate_paths: tuple[str, ...] = (DEFAULT_PROFILE,),
+    ) -> None:
+        """Bind trusted collaborators; candidate paths are observations, not
+        permissions."""
+        self.location, self.registry, self.primitives = location, registry, primitives
+        self.metadata, self.read_bytes, self.catalog = metadata, read_bytes, catalog
+        self.open_directory = open_directory
+        self.authorize_root, self.invalidate_authority = (
+            authorize_root,
+            invalidate_authority,
+        )
+        # Reject unsafe candidate spelling before any filesystem call.
+        self.candidate_paths = tuple(relative_path(path) for path in candidate_paths)
+
+    @classmethod
+    def local(
+        cls,
+        *,
+        location: RegistryLocation,
+        catalog: SchemaCatalog,
+        authorize_root: Callable[[], None],
+        invalidate_authority: Callable[[], None],
+        candidate_paths: tuple[str, ...] = (DEFAULT_PROFILE,),
+    ) -> ActivationStore:
+        """Wire the real provider from host-resolved paths; no request can call this
+        factory."""
+        workspace = Path(location.workspace)
+        state = Path(location.directory)
+        if workspace.resolve(strict=True) != workspace or state.resolve() != state:
+            raise ValueError(
+                "Host paths must already resolve to their canonical locations"
+            )
+        if state.is_relative_to(workspace):
+            raise ValueError("Activation registry must be external")
+        registry = NativeRegistry(location)
+        primitives = LocalMutationPrimitives(
+            workspace_root=str(workspace),
+            lock_path=str(state / "mutation.lock"),
+            lock=registry.guard,
+        )
+        return cls(
+            location=location,
+            registry=registry,
+            primitives=primitives,
+            metadata=primitives.metadata,
+            read_bytes=primitives.read_bytes,
+            open_directory=lambda: open_local_directory(workspace),
+            catalog=catalog,
+            authorize_root=authorize_root,
+            invalidate_authority=invalidate_authority,
+            candidate_paths=candidate_paths,
+        )
+
+    def _optional(self, path: str) -> bytes | None:
+        """Read bounded ordinary configuration, preserving genuine absence only."""
+        relative_path(path)
+        if self.metadata(path).kind == "missing":
+            return None
+        return self.read_bytes(path, limit=16777216)
+
+    def _record(self, raw: bytes | None) -> ActivationRecord | None:
+        """Reject malformed/wrong-workspace protected records rather than disable
+        gates."""
+        return (
+            None
+            if raw is None
+            else ActivationRecord.decode(
+                raw, workspace_sha256=self.location.workspace_sha256
+            )
+        )
+
+    def select(
+        self, *, profile_path: str | None = None, controlled: bool = False
+    ) -> ConfigurationSelection:
+        """Read exact configuration and protected state; never create registry or
+        workspace files."""
+        raw = self.registry.read()
+        record = self._record(raw)
+        if record is not None and not record.active and profile_path is None:
+            if self.registry.read() != raw:
+                raise ConfigurationError(
+                    "CONFIGURATION_CHANGED",
+                    "Activation changed during inactive selection; reload.",
+                )
+            return ConfigurationSelection(state="inactive")
+        locator = self._optional(LOCATOR_PATH)
+        parsed = (
+            ActivationLocator(locator, catalog=self.catalog)
+            if locator is not None
+            else None
+        )
+        paths = set(self.candidate_paths)
+        # Every explicit or protected selector participates in ambiguity detection.
+        for path in (
+            profile_path,
+            parsed.profile_path if parsed else None,
+            record.profile_path if record else None,
+        ):
+            if path is not None:
+                paths.add(relative_path(path))
+        content = {path: self._optional(path) for path in sorted(paths)}
+        candidates = {
+            path: value for path, value in content.items() if value is not None
+        }
+        selected = select_configuration(
+            candidates=candidates,
+            locator=locator,
+            activation=record,
+            catalog=self.catalog,
+            profile_path=profile_path,
+            controlled=controlled,
+        )
+        if selected.profile is not None:
+            self._policy(selected.profile).validate_configuration()
+        # Concurrent edits cannot turn a read of mixed generations into a valid
+        # selection.
+        if (
+            self.registry.read() != raw
+            or self._optional(LOCATOR_PATH) != locator
+            or any(self._optional(path) != value for path, value in content.items())
+        ):
+            raise ConfigurationError(
+                "CONFIGURATION_CHANGED",
+                "Configuration changed during selection; reload.",
+            )
+        return selected
+
+    def _policy(self, profile: ProfileV2) -> PathPolicy:
+        """Reuse accepted path validation with exact host metadata and workspace
+        binding."""
+        return PathPolicy(
+            profile, workspace_root=self.location.workspace, metadata=self.metadata
+        )
+
+    def _parents(
+        self,
+        target: ResolvedPath,
+        anchors: ExitStack,
+        opened: dict[str, str],
+        changed: list[str],
+    ) -> None:
+        """Retain exact pre-observed or exclusively created ancestors through
+        postcheck."""
+        directory = anchors.enter_context(self.open_directory())
+        if directory.identity() != target.observations[0].identity:
+            raise OSError("Opened configuration workspace identity changed")
+        opened["."] = directory.identity()
+        # Creation is rooted in the physical observations, never a synthetic profile.
+        for stamp in target.observations[1:-1]:
+            current = self.metadata(stamp.path)
+            expected_identity = opened.get(stamp.path, stamp.identity)
+            expected_kind = "directory" if stamp.path in opened else stamp.kind
+            if (current.kind, current.identity) != (expected_kind, expected_identity):
+                raise OSError("Configuration parent changed before publication")
+            directory = anchors.enter_context(
+                directory.child(
+                    stamp.path.split("/")[-1], create=current.kind == "missing"
+                )
+            )
+            if current.kind != "missing" and directory.identity() != current.identity:
+                raise OSError("Opened configuration parent identity changed")
+            opened[stamp.path] = directory.identity()
+            if current.kind == "missing":
+                changed.append(stamp.path)
+
+    def _require_inputs(
+        self,
+        raw: bytes | None,
+        writes: tuple[tuple[str, bytes, bytes | None], ...],
+        policy: PathPolicy | None,
+        observations: tuple[ResolvedPath, ...],
+        candidates: tuple[tuple[str, bytes | None], ...],
+    ) -> None:
+        """Reject changed original bytes and parent/leaf identities before any
+        publication."""
+        if self.registry.read() != raw or any(
+            self._optional(path) != old for path, _, old in writes
+        ):
+            raise OSError("Configuration bytes changed before root commit")
+        if any(self._optional(path) != content for path, content in candidates):
+            raise OSError("Configuration candidates changed before root commit")
+        if (
+            policy is not None
+            and tuple(
+                policy.resolve_read(path, allow_missing=True) for path, _, _ in writes
+            )
+            != observations
+        ):
+            raise OSError("Configuration parent identities changed before commit")
+
+    def configure(self, request: ConfigurationRequest) -> ConfigurationResult:
+        """Validate root intent, revoke old authority and report exact/uncertain
+        effects.
+
+        Authorization is injected from native/user context, never a request role.
+        Dry-run performs the same prewrite validation without locks or effects.
+        Invalid proposed data raises before writes; guarded I/O errors return an
+        explicit partial result. Deactivation retains a protected audit tombstone.
+        """
+        self.authorize_root()
+        raw = self.registry.read()
+        prior = self._record(raw)
+        writes: tuple[tuple[str, bytes, bytes | None], ...] = ()
+        policy: PathPolicy | None = None
+        observations: tuple[ResolvedPath, ...] = ()
+        candidates: tuple[tuple[str, bytes | None], ...] = ()
+        profile_path = prior.profile_path if prior else None
+        profile_hash = prior.profile_sha256 if prior else None
+        locator_hash = prior.locator_sha256 if prior else None
+        # Only activation can alter workspace configuration; deactivation is external.
+        if request.action == "activate":
+            original = self._optional(request.profile_path)
+            proposed = (
+                request.profile_bytes if request.profile_bytes is not None else original
+            )
+            if proposed is None:
+                raise ConfigurationError(
+                    "CONFIGURATION_MISSING",
+                    "Activation requires a profile.",
+                    request.profile_path,
+                )
+            profile = ProfileV2(proposed, catalog=self.catalog)
+            if profile.artifacts["profile"] != request.profile_path:
+                raise ConfigurationError(
+                    "CONFIGURATION_DISAGREEMENT",
+                    "Proposed profile path differs from its configuration.",
+                    request.profile_path,
+                )
+            policy = self._policy(profile)
+            policy.validate_configuration()
+            profile_path = request.profile_path
+            locator = locator_bytes(profile_path)
+            writes = (
+                (profile_path, proposed, original),
+                (LOCATOR_PATH, locator, self._optional(LOCATOR_PATH)),
+            )
+            observations = tuple(
+                policy.resolve_read(path, allow_missing=True) for path, _, _ in writes
+            )
+            # A second known candidate cannot be silently hidden by changing the
+            # locator.
+            candidates = tuple(
+                (path, self._optional(path)) for path in self.candidate_paths
+            )
+            if any(
+                path != profile_path and content is not None
+                for path, content in candidates
+            ):
+                raise ConfigurationError(
+                    "CONFIGURATION_AMBIGUOUS",
+                    "Remove competing profile candidates through an explicit "
+                    "root operation.",
+                )
+            profile_hash, locator_hash = (
+                sha256(proposed).hexdigest(),
+                sha256(locator).hexdigest(),
+            )
+        next_record = ActivationRecord(
+            workspace_sha256=self.location.workspace_sha256,
+            generation=1 if prior is None else prior.generation + 1,
+            action=request.action,
+            profile_path=profile_path,
+            profile_sha256=profile_hash,
+            locator_sha256=locator_hash,
+            previous_sha256=None if raw is None else sha256(raw).hexdigest(),
+        ).encode()
+        if request.dry_run:
+            return ConfigurationResult(ok=True, action=request.action)
+        changed: list[str] = []
+        uncertain: tuple[str, ...] = ("protected-activation",)
+        revoked = False
+        try:
+            with self.primitives.guard(), ExitStack() as anchors:
+                self.authorize_root()
+                self._require_inputs(raw, writes, policy, observations, candidates)
+                self.invalidate_authority()
+                revoked = True
+                self._require_inputs(raw, writes, policy, observations, candidates)
+                uncertain = ("protected-activation",)
+                # Record active intent first: partial workspace writes must keep gates
+                # active.
+                self.registry.write(next_record, expected=raw)
+                changed.append("protected-activation")
+                uncertain = ()
+                opened: dict[str, str] = {}
+                if policy is not None:
+                    # Shared primitives publish exact root-only paths without widening
+                    # analyst grants.
+                    for (path, content, original), observed in zip(
+                        writes, observations, strict=True
+                    ):
+                        uncertain = tuple(
+                            stamp.path
+                            for stamp in observed.observations
+                            if stamp.kind == "missing"
+                        ) or (path,)
+                        leaf, current_leaf = observed.observations[-1], self.metadata(
+                            path
+                        )
+                        if (leaf.kind, leaf.identity, leaf.resolved_path) != (
+                            current_leaf.kind,
+                            current_leaf.identity,
+                            current_leaf.resolved_path,
+                        ):
+                            raise OSError(
+                                "Configuration file identity changed before publication"
+                            )
+                        self._parents(observed, anchors, opened, changed)
+                        if content == original:
+                            uncertain = ()
+                            continue
+                        target = policy.resolve_read(path, allow_missing=True)
+                        uncertain = tuple(
+                            stamp.path
+                            for stamp in target.observations
+                            if stamp.kind == "missing"
+                        ) or (path,)
+                        target = replace(
+                            target,
+                            grant=WriteGrant(
+                                artifact_kind=(
+                                    "activation"
+                                    if path == LOCATOR_PATH
+                                    else "domain-profile"
+                                ),
+                                artifact_id="root-configuration",
+                                path=path,
+                            ),
+                        )
+                        if original is None:
+                            self.primitives.create_exclusive(target, content)
+                        else:
+                            self.primitives.replace_if_digest(
+                                target,
+                                content,
+                                expected_sha256=sha256(original).hexdigest(),
+                            )
+                        changed.append(path)
+                        uncertain = ()
+                # Newly created and pre-existing retained identities must still name the
+                # same parents.
+                if any(
+                    self.metadata(path).identity != identity
+                    for path, identity in opened.items()
+                ):
+                    raise OSError(
+                        "Configuration parent identity changed after publication"
+                    )
+                expected_files = dict(candidates)
+                expected_files.update((path, content) for path, content, _ in writes)
+                if self.registry.read() != next_record or any(
+                    self._optional(path) != content
+                    for path, content in expected_files.items()
+                ):
+                    raise OSError("Configuration changed after publication")
+            return ConfigurationResult(
+                ok=True,
+                action=request.action,
+                changed=tuple(changed),
+                authority_invalidated=revoked,
+            )
+        except (OSError, ValueError) as error:
+            return ConfigurationResult(
+                ok=False,
+                action=request.action,
+                changed=tuple(changed),
+                uncertain=uncertain,
+                authority_invalidated=revoked,
+                error=str(error),
+            )
diff --git a/packages/discovery-runtime/src/drm_copilot_discovery/configuration.py b/packages/discovery-runtime/src/drm_copilot_discovery/configuration.py
new file mode 100644
index 0000000000000000000000000000000000000000..a756c0b05f39d5e48944ef52c614510bf15d7112
--- /dev/null
+++ b/packages/discovery-runtime/src/drm_copilot_discovery/configuration.py
@@ -0,0 +1,310 @@
+"""Select validated configuration without deriving native authority from input.
+
+The host supplies captured candidates and protected registry data. These pure
+values describe activation state; only the separately authorized store can change
+it. Workspace locators never confer permission or disable protected activation.
+"""
+
+from __future__ import annotations
+
+import json
+import re
+from dataclasses import asdict, dataclass
+from hashlib import sha256
+from typing import TYPE_CHECKING, Literal, cast
+
+from drm_copilot_discovery.activation_models import ActivationLocator
+from drm_copilot_discovery.findings import Finding
+from drm_copilot_discovery.models import ParseLimits
+from drm_copilot_discovery.parsing import parse_document
+from drm_copilot_discovery.path_models import check_path_collisions, relative_path
+from drm_copilot_discovery.profile_v2 import ProfileV2
+
+if TYPE_CHECKING:
+    from collections.abc import Mapping
+
+    from drm_copilot_discovery.catalog import SchemaCatalog
+
+DEFAULT_PROFILE = "docs/migration/discovery/domain-profile.yaml"
+LOCATOR_PATH = "config/discovery.json"
+
+
+class ConfigurationError(ValueError):
+    """Carry actionable configuration findings without exposing partial selection."""
+
+    def __init__(self, code: str, message: str, path: str | None = None) -> None:
+        """Retain a stable code/path for service projection; perform no effects."""
+        self.findings = (
+            Finding(
+                code=code,
+                message=message,
+                artifact_path=path,
+                next_action=(
+                    "Use the root configuration operation to repair "
+                    "or activate discovery."
+                ),
+            ),
+        )
+        super().__init__(message)
+
+
+def locator_bytes(profile_path: str) -> bytes:
+    """Render the fixed four-key locator for a safe relative path, without I/O."""
+    return (
+        json.dumps(
+            {
+                "schema_version": "2.0.0",
+                "enabled": True,
+                "profile_path": relative_path(profile_path),
+                "required_runtime_major": 2,
+            },
+            sort_keys=True,
+            indent=2,
+        ).encode()
+        + b"\n"
+    )
+
+
+@dataclass(frozen=True, kw_only=True)
+class ActivationRecord:
+    """Represent one session-independent protected transition, never a capability.
+
+    The store supplies these bytes outside the workspace. The predecessor digest
+    records replacement provenance; generation changes invalidate older bindings.
+    A deactivation tombstone is retained so leftover profiles cannot reactivate it.
+    """
+
+    workspace_sha256: str
+    generation: int
+    action: Literal["activate", "deactivate"]
+    profile_path: str | None
+    profile_sha256: str | None
+    locator_sha256: str | None
+    previous_sha256: str | None
+    schema_version: Literal["2.0.0"] = "2.0.0"
+
+    def __post_init__(self) -> None:
+        """Reject malformed registry data rather than infer an inactive state."""
+        if (
+            self.schema_version != "2.0.0"
+            or self.action not in {"activate", "deactivate"}
+            or type(self.generation) is not int
+            or self.generation < 1
+        ):
+            raise ValueError("Invalid activation version, action or generation")
+        # Every digest binds exact observed bytes, including the replaced record.
+        for value in (
+            self.workspace_sha256,
+            self.profile_sha256,
+            self.locator_sha256,
+            self.previous_sha256,
+        ):
+            if value is not None and (
+                type(value) is not str or not re.fullmatch("[0-9a-f]{64}", value)
+            ):
+                raise ValueError("Activation digests must be lowercase SHA-256")
+        if not self.workspace_sha256:
+            raise ValueError("Activation requires a canonical workspace digest")
+        if self.profile_path is not None:
+            relative_path(self.profile_path)
+        linked = (self.profile_path, self.profile_sha256, self.locator_sha256)
+        if any(value is None for value in linked) and (
+            self.action == "activate" or any(value is not None for value in linked)
+        ):
+            raise ValueError("Activation profile and locator bindings must be complete")
+
+    @property
+    def active(self) -> bool:
+        """Return the recorded transition state, not authorization for an operation."""
+        return self.action == "activate"
+
+    def encode(self) -> bytes:
+        """Return deterministic JSON bytes for protected storage; no writes occur."""
+        return json.dumps(asdict(self), sort_keys=True, indent=2).encode() + b"\n"
+
+    @classmethod
+    def decode(cls, content: bytes, *, workspace_sha256: str) -> ActivationRecord:
+        """Parse bounded strict JSON and reject wrong workspace or extra fields."""
+        parsed = parse_document(
+            content, format="json", limits=ParseLimits(document_bytes=65536)
+        )
+        value = parsed.value
+        fields = {
+            "workspace_sha256",
+            "generation",
+            "action",
+            "profile_path",
+            "profile_sha256",
+            "locator_sha256",
+            "previous_sha256",
+            "schema_version",
+        }
+        if value is None or set(value) != fields:
+            raise ConfigurationError(
+                "ACTIVATION_INVALID", "Protected activation record is malformed."
+            )
+        try:
+            record = cls(
+                workspace_sha256=cast("str", value["workspace_sha256"]),
+                generation=cast("int", value["generation"]),
+                action=cast('Literal["activate", "deactivate"]', value["action"]),
+                profile_path=cast("str | None", value["profile_path"]),
+                profile_sha256=cast("str | None", value["profile_sha256"]),
+                locator_sha256=cast("str | None", value["locator_sha256"]),
+                previous_sha256=cast("str | None", value["previous_sha256"]),
+                schema_version=cast('Literal["2.0.0"]', value["schema_version"]),
+            )
+        except (TypeError, ValueError) as error:
+            raise ConfigurationError(
+                "ACTIVATION_INVALID", "Protected activation fields are invalid."
+            ) from error
+        if record.workspace_sha256 != workspace_sha256:
+            raise ConfigurationError(
+                "ACTIVATION_WORKSPACE",
+                "Protected activation belongs to another workspace.",
+            )
+        return record
+
+
+@dataclass(frozen=True, kw_only=True)
+class ConfigurationSelection:
+    """Return an inert readiness result and the exact selected raw configuration."""
+
+    state: Literal["inactive", "activation-required", "active"]
+    profile_path: str | None = None
+    profile: ProfileV2 | None = None
+    profile_bytes: bytes | None = None
+    locator_bytes: bytes | None = None
+
+
+def select_configuration(
+    *,
+    candidates: Mapping[str, bytes],
+    locator: bytes | None,
+    activation: ActivationRecord | None,
+    catalog: SchemaCatalog,
+    profile_path: str | None = None,
+    controlled: bool = False,
+) -> ConfigurationSelection:
+    """Select exactly one captured profile, preserving protected active failures.
+
+    Args are trusted observations plus an optional untrusted relative selector.
+    Returns inactive only for nonparticipants or explicit protected deactivation.
+    Raises ConfigurationError/ProfileError on ambiguity, stale or malformed input.
+    This pure function performs no reads, writes, activation or authorization.
+    """
+    if profile_path is not None:
+        relative_path(profile_path)
+    # Recorded deactivation overrides leftover files only for implicit gate checks.
+    if activation is not None and not activation.active and profile_path is None:
+        return ConfigurationSelection(state="inactive")
+    check_path_collisions(candidates)
+    if len(candidates) > 1:
+        raise ConfigurationError(
+            "CONFIGURATION_AMBIGUOUS",
+            "Multiple candidate profiles require one explicit root configuration.",
+        )
+    parsed_locator = (
+        ActivationLocator(locator, catalog=catalog) if locator is not None else None
+    )
+    if parsed_locator is not None and profile_path is not None:
+        if parsed_locator.profile_path != profile_path:
+            raise ConfigurationError(
+                "CONFIGURATION_DISAGREEMENT",
+                "Profile argument disagrees with the workspace locator.",
+                LOCATOR_PATH,
+            )
+    selected = profile_path or (
+        parsed_locator.profile_path if parsed_locator else DEFAULT_PROFILE
+    )
+    # An active protected record cannot be disabled by deleting or editing the locator.
+    if activation is not None and activation.active:
+        if parsed_locator is None or (
+            selected != activation.profile_path
+            or sha256(cast("bytes", locator)).hexdigest() != activation.locator_sha256
+        ):
+            raise ConfigurationError(
+                "ACTIVATION_STALE",
+                "Active locator is missing or differs from protected activation.",
+                LOCATOR_PATH,
+            )
+    content = candidates.get(selected)
+    if content is None:
+        if (
+            not candidates
+            and parsed_locator is None
+            and activation is None
+            and profile_path is None
+        ):
+            return ConfigurationSelection(state="inactive")
+        raise ConfigurationError(
+            "CONFIGURATION_MISSING",
+            "The selected discovery profile is missing.",
+            selected,
+        )
+    profile = ProfileV2(content, catalog=catalog)
+    if profile.artifacts["profile"] != selected:
+        raise ConfigurationError(
+            "CONFIGURATION_DISAGREEMENT",
+            "Profile location differs from its configured artifact path.",
+            selected,
+        )
+    state: Literal["active", "activation-required"] = "activation-required"
+    if activation is not None and activation.active:
+        if sha256(content).hexdigest() != activation.profile_sha256:
+            raise ConfigurationError(
+                "ACTIVATION_STALE",
+                "Active profile bytes changed without root configuration.",
+                selected,
+            )
+        state = "active"
+    if controlled and state != "active":
+        raise ConfigurationError(
+            "ACTIVATION_REQUIRED",
+            "Explicit root activation is required before controlled discovery starts.",
+            selected,
+        )
+    return ConfigurationSelection(
+        state=state,
+        profile_path=selected,
+        profile=profile,
+        profile_bytes=content,
+        locator_bytes=locator,
+    )
+
+
+@dataclass(frozen=True, kw_only=True)
+class ConfigurationRequest:
+    """Describe root configuration intent without any role, authority path or grant."""
+
+    action: Literal["activate", "deactivate"]
+    profile_path: str = DEFAULT_PROFILE
+    profile_bytes: bytes | None = None
+    dry_run: bool = False
+
+    def __post_init__(self) -> None:
+        """Reject unsupported actions and unsafe or irrelevant profile arguments."""
+        relative_path(self.profile_path)
+        if (
+            self.action not in {"activate", "deactivate"}
+            or type(self.dry_run) is not bool
+        ):
+            raise ValueError("Choose activate/deactivate and a boolean dry_run")
+        if self.profile_bytes is not None and type(self.profile_bytes) is not bytes:
+            raise ValueError("Profile input must be immutable bytes")
+        if self.action == "deactivate" and (
+            self.profile_bytes is not None or self.profile_path != DEFAULT_PROFILE
+        ):
+            raise ValueError("Deactivation does not accept profile changes")
+
+
+@dataclass(frozen=True, kw_only=True)
+class ConfigurationResult:
+    """Report exact completed effects and bounded uncertainty after a root operation."""
+
+    ok: bool
+    action: Literal["activate", "deactivate"]
+    changed: tuple[str, ...] = ()
+    uncertain: tuple[str, ...] = ()
+    authority_invalidated: bool = False
+    error: str | None = None
diff --git a/packages/discovery-runtime/src/drm_copilot_discovery/mutation_filesystem.py b/packages/discovery-runtime/src/drm_copilot_discovery/mutation_filesystem.py
index 198a767936b5a960505b80e74f93c860fc644642..9a6ee85ce4a6a08ddce5e44a7a5bc37572a00b37 100644
--- a/packages/discovery-runtime/src/drm_copilot_discovery/mutation_filesystem.py
+++ b/packages/discovery-runtime/src/drm_copilot_discovery/mutation_filesystem.py
@@ -158 +158 @@ class NativeDirectory:
-                os.O_RDONLY | getattr(os, "O_NOFOLLOW", 0),
+                os.O_RDONLY | getattr(os, "O_NOFOLLOW", 0) | getattr(os, "O_BINARY", 0),
@@ -181 +181 @@ class NativeDirectory:
-            os.O_WRONLY | os.O_CREAT | os.O_EXCL,
+            os.O_WRONLY | os.O_CREAT | os.O_EXCL | getattr(os, "O_BINARY", 0),
diff --git a/tests/discovery_runtime/test_activation_filesystem.py b/tests/discovery_runtime/test_activation_filesystem.py
new file mode 100644
index 0000000000000000000000000000000000000000..bf2f24945969d34a5cd7fd12eda2b0e7352338b0
--- /dev/null
+++ b/tests/discovery_runtime/test_activation_filesystem.py
@@ -0,0 +1,313 @@
+"""Check platform authority locations without environment reads or real filesystem
+I/O."""
+
+from __future__ import annotations
+
+import os
+from contextlib import contextmanager
+from dataclasses import replace
+from pathlib import Path
+from typing import TYPE_CHECKING, Literal, cast
+
+import pytest
+from drm_copilot_discovery import activation_store
+from drm_copilot_discovery.activation_filesystem import NativeRegistry, RegistryLocation
+
+from tests.discovery_runtime.mutation_test_support import MemoryDirectory, MemoryDisk
+from tests.discovery_runtime.test_configuration import config_catalog as config_catalog
+
+if TYPE_CHECKING:
+    from collections.abc import Callable, Generator
+    from contextlib import AbstractContextManager
+
+    from drm_copilot_discovery.catalog import SchemaCatalog
+    from drm_copilot_discovery.mutation_filesystem import Directory
+
+
+@pytest.mark.parametrize(
+    "platform,home,local,state,expected",
+    [
+        (
+            "windows",
+            "C:/Users/Example",
+            "C:/Users/Example/AppData/Local",
+            None,
+            "C:/Users/Example/AppData/Local/drm-copilot/discovery",
+        ),
+        (
+            "macos",
+            "/Users/example",
+            None,
+            None,
+            "/Users/example/Library/Application Support/drm-copilot/discovery",
+        ),
+        (
+            "linux",
+            "/home/example",
+            None,
+            None,
+            "/home/example/.local/state/drm-copilot/discovery",
+        ),
+        (
+            "linux",
+            "/home/example",
+            None,
+            "/trusted/state",
+            "/trusted/state/drm-copilot/discovery",
+        ),
+    ],
+)
+def test_registry_locations_are_platform_fixed_and_workspace_partitioned(
+    platform: str, home: str, local: str | None, state: str | None, expected: str
+) -> None:
+    """Trusted host values select the mandated registry location without session
+    dependence."""
+    workspace = "C:/Workspace" if platform == "windows" else "/workspace"
+    location = RegistryLocation.for_host(
+        workspace_root=workspace,
+        platform=cast('Literal["windows", "macos", "linux"]', platform),
+        user_home=home,
+        local_app_data=local,
+        xdg_state_home=state,
+    )
+    assert location.directory == expected + "/workspaces/" + location.workspace_sha256
+    assert len(location.workspace_sha256) == 64
+    assert location.workspace == workspace
+
+
+def test_windows_workspace_hash_uses_canonical_case_and_native_separators() -> None:
+    """Case/forward-slash aliases share the existing native authority-store identity."""
+    first = RegistryLocation.for_host(
+        workspace_root="C:/Workspace",
+        platform="windows",
+        user_home="C:/Users/Example",
+        local_app_data="C:/State",
+    )
+    second = RegistryLocation.for_host(
+        workspace_root="c:\\workspace\\",
+        platform="windows",
+        user_home="C:/Users/Example",
+        local_app_data="C:/State",
+    )
+    assert first.workspace_sha256 == second.workspace_sha256
+
+
+@pytest.mark.parametrize(
+    "changes",
+    [
+        {"platform": "other"},
+        {"workspace_root": "relative"},
+        {"user_home": "relative"},
+        {"xdg_state_home": "/workspace"},
+        {"xdg_state_home": "/state/../other"},
+        {
+            "platform": "windows",
+            "workspace_root": "C:/Workspace",
+            "user_home": "C:/Users/Example",
+        },
+    ],
+)
+def test_unsafe_missing_or_internal_host_locations_fail_before_io(
+    changes: dict[str, object],
+) -> None:
+    """Unsupported platforms and workspace-contained authority roots cannot provision
+    state."""
+    arguments = {
+        "workspace_root": "/workspace",
+        "platform": "linux",
+        "user_home": "/home/example",
+        **changes,
+    }
+    factory: Callable[..., RegistryLocation] = RegistryLocation.for_host
+    with pytest.raises(ValueError):
+        factory(**arguments)
+
+
+class RegistryDirectory(MemoryDirectory):
+    """Translate missing fake keys into the native file-not-found contract."""
+
+    def read(self, name: str, *, limit: int) -> bytes:
+        """Preserve bounded reads and distinguish absent from inaccessible files."""
+        if self.name(name) in self.disk.store.failures:
+            raise PermissionError("protected record is unreadable")
+        try:
+            return super().read(name, limit=limit)
+        except KeyError as error:
+            raise FileNotFoundError(self.name(name)) from error
+
+
+class RegistryDisk(MemoryDisk):
+    """Supply isolated native directory seams without touching a host path."""
+
+    def __init__(self) -> None:
+        """Bind the real registry to a fresh synthetic absolute namespace."""
+        super().__init__()
+        self.location = RegistryLocation.for_host(
+            workspace_root=self.root,
+            platform="windows" if os.name == "nt" else "linux",
+            user_home="C:/users/example" if os.name == "nt" else "/users/example",
+            local_app_data="C:/state" if os.name == "nt" else None,
+        )
+        self.base = "/".join(Path(self.location.directory).parts[1:])
+        self.registry = NativeRegistry(
+            self.location, opener=self.anchor, nonce=lambda: "owned"
+        )
+
+    @contextmanager
+    def open(self, path: str = ".") -> Generator[Directory, None, None]:
+        """Require existing ordinary directories and unwind every retained handle."""
+        if self.store.metadata(path).kind == "missing":
+            raise FileNotFoundError(path)
+        with super().open(path):
+            yield RegistryDirectory(self, path)
+
+    @contextmanager
+    def anchor(self, path: Path) -> Generator[Directory, None, None]:
+        """Accept only the native root anchor requested by the registry."""
+        assert path == Path(Path(self.location.directory).anchor)
+        with self.open() as directory:
+            yield directory
+
+
+def test_native_registry_absence_create_replace_and_guard_cleanup() -> None:
+    """Protected reads are inert; guarded publication preserves exact bytes."""
+    disk = RegistryDisk()
+    before = dict(disk.store.metadata.entries)
+    assert disk.registry.read() is None
+    assert disk.store.metadata.entries == before and disk.held == 0
+    with pytest.raises(OSError, match="requires its guard"):
+        disk.registry.write(b"first", expected=None)
+    with disk.registry.guard():
+        assert disk.registry.read() is None
+        disk.registry.write(b"first", expected=None)
+        assert disk.registry.read() == b"first"
+        disk.registry.write(b"second", expected=b"first")
+        assert disk.registry.read() == b"second" and disk.held > 0
+        with pytest.raises(OSError, match="changed before publication"):
+            disk.registry.write(b"stale", expected=b"first")
+    assert disk.held == 0 and set(disk.limits) == {65536}
+    assert disk.store.files == {disk.base + "/activation.json": b"second"}
+
+
+def test_concurrent_registry_guards_preserve_the_existing_lock() -> None:
+    """Reentry and a second cooperating writer cannot acquire an owned lock."""
+    disk = RegistryDisk()
+    second = NativeRegistry(disk.location, opener=disk.anchor)
+    with disk.registry.guard():
+        with pytest.raises(OSError, match="already held"), disk.registry.guard():
+            pytest.fail("reentrant guard must not yield")
+        with pytest.raises(FileExistsError), second.guard():
+            pytest.fail("concurrent guard must not yield")
+        assert disk.base + "/mutation.lock" in disk.store.files
+    assert disk.held == 0 and not disk.store.files
+
+
+@pytest.mark.parametrize("failure", ["foreign-stage", "publication", "cleanup"])
+def test_registry_write_failures_retain_foreign_bytes_and_bound_cleanup(
+    failure: str, monkeypatch: pytest.MonkeyPatch
+) -> None:
+    """Only owned stages are cleaned; publication and cleanup errors propagate."""
+    disk = RegistryDisk()
+    staged = disk.base + "/.activation-owned"
+    record = disk.base + "/activation.json"
+    with disk.registry.guard():
+        if failure == "foreign-stage":
+            disk.store.put(staged, b"foreign")
+        elif failure == "publication":
+            disk.fail_publish = True
+        else:
+            original = RegistryDirectory.remove
+
+            def failed_cleanup(directory: RegistryDirectory, name: str) -> None:
+                """Fail only owned stage cleanup, allowing guard release to finish."""
+                if name == ".activation-owned":
+                    raise OSError("stage cleanup failed")
+                original(directory, name)
+
+            monkeypatch.setattr(RegistryDirectory, "remove", failed_cleanup)
+        with pytest.raises(OSError):
+            disk.registry.write(b"proposed", expected=None)
+        if failure == "foreign-stage":
+            assert (
+                disk.store.files[staged] == b"foreign"
+                and record not in disk.store.files
+            )
+        elif failure == "publication":
+            assert staged not in disk.store.files and record not in disk.store.files
+        else:
+            assert disk.store.files[record] == b"proposed"
+            assert disk.store.files[staged] == b"proposed"
+    assert disk.held == 0 and disk.base + "/mutation.lock" not in disk.store.files
+
+
+@pytest.mark.parametrize("change", ["replacement", "missing"])
+def test_retained_registry_ancestor_changes_reject_read_and_write(change: str) -> None:
+    """An active guard cannot adopt a replacement or disappear into inactive state."""
+    disk = RegistryDisk()
+    ancestor = disk.base.split("/")[0]
+    with disk.registry.guard():
+        if change == "missing":
+            disk.store.metadata.remove(ancestor)
+        else:
+            disk.store.metadata.add(ancestor, kind="directory", identity="replaced")
+        with pytest.raises(OSError, match="identity changed|disappeared"):
+            disk.registry.read()
+        with pytest.raises(OSError, match="identity changed|disappeared"):
+            disk.registry.write(b"unpublished", expected=None)
+        assert disk.base + "/activation.json" not in disk.store.files
+    assert disk.held == 0
+
+
+@pytest.mark.parametrize("failure", ["unreadable", "oversized"])
+def test_native_registry_read_errors_cannot_become_absent(failure: str) -> None:
+    """Unreadable or oversized protected state remains a blocking I/O error."""
+    disk = RegistryDisk()
+    record = disk.base + "/activation.json"
+    disk.store.put(record, b"x" * 65537 if failure == "oversized" else b"record")
+    if failure == "unreadable":
+        disk.store.failures.add(record)
+    with pytest.raises(OSError):
+        disk.registry.read()
+    assert disk.held == 0 and disk.store.files[record]
+
+
+@pytest.mark.parametrize("condition", ["canonical", "alias", "internal"])
+def test_local_factory_requires_canonical_external_host_locations(
+    config_catalog: SchemaCatalog, condition: str, monkeypatch: pytest.MonkeyPatch
+) -> None:
+    """Trusted composition validates host paths and wires the shared native guard."""
+    disk = RegistryDisk()
+    location = disk.location
+    if condition == "internal":
+        location = replace(location, directory=location.workspace + "/state")
+
+    def resolved(path: Path, **_options: object) -> Path:
+        """Inject canonical resolution without consulting the real filesystem."""
+        return path / "resolved" if condition == "alias" else path
+
+    def opened(path: Path) -> AbstractContextManager[Directory]:
+        """Keep the factory's workspace opener anchored to the test-local disk."""
+        assert path == Path(location.workspace)
+        return disk.open()
+
+    monkeypatch.setattr(Path, "resolve", resolved)
+    monkeypatch.setattr(activation_store, "open_local_directory", opened)
+    if condition != "canonical":
+        with pytest.raises(ValueError):
+            activation_store.ActivationStore.local(
+                location=location,
+                catalog=config_catalog,
+                authorize_root=lambda: None,
+                invalidate_authority=lambda: None,
+            )
+        return
+    service = activation_store.ActivationStore.local(
+        location=location,
+        catalog=config_catalog,
+        authorize_root=lambda: None,
+        invalidate_authority=lambda: None,
+    )
+    assert service.location == location and isinstance(service.registry, NativeRegistry)
+    with service.open_directory() as directory:
+        assert directory.identity() == "root"
+    assert disk.held == 0 and not disk.store.files
diff --git a/tests/discovery_runtime/test_activation_store.py b/tests/discovery_runtime/test_activation_store.py
new file mode 100644
index 0000000000000000000000000000000000000000..c71e675af670672023a3ec768893599c9b642708
--- /dev/null
+++ b/tests/discovery_runtime/test_activation_store.py
@@ -0,0 +1,465 @@
+"""Exercise root configuration with fresh memory stores and real mutation primitives."""
+
+from __future__ import annotations
+
+import os
+from dataclasses import replace
+from hashlib import sha256
+from typing import TYPE_CHECKING
+
+import pytest
+from drm_copilot_discovery.activation_filesystem import RegistryLocation
+from drm_copilot_discovery.activation_store import ActivationStore
+from drm_copilot_discovery.configuration import (
+    DEFAULT_PROFILE,
+    LOCATOR_PATH,
+    ActivationRecord,
+    ConfigurationError,
+    ConfigurationRequest,
+)
+from drm_copilot_discovery.profile_v2 import ProfileError
+
+from tests.discovery_runtime.mutation_test_support import MemoryDisk
+from tests.discovery_runtime.test_configuration import active_record, profile_bytes
+from tests.discovery_runtime.test_configuration import config_catalog as config_catalog
+
+if TYPE_CHECKING:
+    from collections.abc import Callable
+
+    from drm_copilot_discovery.catalog import SchemaCatalog
+    from drm_copilot_discovery.path_models import ResolvedPath
+
+
+class MemoryRegistry:
+    """Retain protected bytes separately from a test's workspace and record all
+    writes."""
+
+    def __init__(self, disk: MemoryDisk) -> None:
+        """Allocate isolated protected state with a shared workspace exclusion check."""
+        self.disk = disk
+        self.raw: bytes | None = None
+        self.writes = 0
+        self.after_write: Callable[[], None] = lambda: None
+
+    def read(self) -> bytes | None:
+        """Return the current protected observation without consulting workspace
+        input."""
+        return self.raw
+
+    def write(self, content: bytes, *, expected: bytes | None) -> None:
+        """Model guarded CAS and an observable post-write failure/race seam."""
+        assert self.disk.locked and self.raw == expected
+        self.raw = content
+        self.writes += 1
+        self.after_write()
+
+
+class ConfigurationCase:
+    """Own root context, registry, namespace and revocation state for exactly one
+    test."""
+
+    def __init__(
+        self, catalog: SchemaCatalog, *, profile: str = DEFAULT_PROFILE
+    ) -> None:
+        """Build a real root operation over injected memory-only I/O boundaries."""
+        self.disk = MemoryDisk()
+        self.registry = MemoryRegistry(self.disk)
+        self.authorized = True
+        self.revocations = 0
+        self.authorization_calls = 0
+        self.on_revoke: Callable[[], None] = lambda: None
+        self.location = RegistryLocation.for_host(
+            workspace_root=self.disk.root,
+            platform="windows" if os.name == "nt" else "linux",
+            user_home="C:/users/example" if os.name == "nt" else "/users/example",
+            local_app_data="C:/state" if os.name == "nt" else None,
+        )
+        self.service = ActivationStore(
+            location=self.location,
+            registry=self.registry,
+            primitives=self.disk.provider(),
+            metadata=self.disk.store.metadata,
+            read_bytes=self.disk.store.read,
+            open_directory=self.disk.open,
+            catalog=catalog,
+            authorize_root=self.authorize,
+            invalidate_authority=self.revoke,
+            candidate_paths=(profile,),
+        )
+
+    def authorize(self) -> None:
+        """Model an independently verified native/user principal, never a request
+        role."""
+        self.authorization_calls += 1
+        if not self.authorized:
+            raise PermissionError("root configuration is required")
+
+    def revoke(self) -> None:
+        """Invalidate outstanding grants/receipts before every attempted transition."""
+        self.revocations += 1
+        self.on_revoke()
+
+    def record(self) -> ActivationRecord:
+        """Decode protected state for assertions without allowing workspace forgery."""
+        assert self.registry.raw is not None
+        return ActivationRecord.decode(
+            self.registry.raw, workspace_sha256=self.location.workspace_sha256
+        )
+
+
+@pytest.mark.parametrize("path", [DEFAULT_PROFILE, "docs/custom/profile.yaml"])
+def test_activate_update_and_deactivate_preserve_exact_audit_chain(
+    config_catalog: SchemaCatalog, path: str
+) -> None:
+    """Root configuration writes exact bytes, revokes old grants and records
+    deliberate deactivation."""
+    case = ConfigurationCase(config_catalog, profile=path)
+    content = profile_bytes(path)
+    result = case.service.configure(
+        ConfigurationRequest(
+            action="activate", profile_path=path, profile_bytes=content
+        )
+    )
+    assert result.ok and result.authority_invalidated and not result.uncertain
+    assert case.revocations == 1 and case.disk.held == 0 and not case.disk.locked
+    assert case.disk.store.files[path] == content
+    assert case.service.select(controlled=True).state == "active"
+    first = case.registry.raw
+    updated = content + b"\n"
+    result = case.service.configure(
+        ConfigurationRequest(
+            action="activate", profile_path=path, profile_bytes=updated
+        )
+    )
+    assert result.ok and case.record().generation == 2
+    assert case.record().previous_sha256 == sha256(first or b"").hexdigest()
+    assert case.disk.store.files[path] == updated
+    before = dict(case.disk.store.files)
+    result = case.service.configure(ConfigurationRequest(action="deactivate"))
+    assert result.ok and result.changed == ("protected-activation",)
+    assert case.revocations == 3 and not case.record().active
+    assert case.disk.store.files == before
+    assert case.service.select(controlled=True).state == "inactive"
+
+
+@pytest.mark.parametrize("action", ["activate", "deactivate"])
+def test_only_trusted_root_can_configure_even_in_dry_run(
+    config_catalog: SchemaCatalog, action: str
+) -> None:
+    """No request action, profile field or dry-run flag can fabricate root
+    authorization."""
+    case = ConfigurationCase(config_catalog)
+    case.authorized = False
+    request = replace(
+        ConfigurationRequest(action="activate"), action=action, dry_run=True
+    )
+    with pytest.raises(PermissionError, match="root"):
+        case.service.configure(request)
+    assert (
+        case.registry.raw is None
+        and case.revocations == 0
+        and not case.disk.store.files
+    )
+
+
+def test_dry_run_never_creates_directories_activation_or_revocations(
+    config_catalog: SchemaCatalog,
+) -> None:
+    """Projected valid root intent performs only reads, including on a fresh
+    workspace."""
+    case = ConfigurationCase(config_catalog)
+    before = dict(case.disk.store.metadata.entries)
+    result = case.service.configure(
+        ConfigurationRequest(
+            action="activate", profile_bytes=profile_bytes(), dry_run=True
+        )
+    )
+    assert result.ok and not result.changed and not result.authority_invalidated
+    assert (
+        case.registry.raw is None
+        and case.registry.writes == 0
+        and case.revocations == 0
+    )
+    assert case.disk.store.metadata.entries == before and not case.disk.store.files
+    assert case.service.configure(
+        ConfigurationRequest(action="deactivate", dry_run=True)
+    ).ok
+    assert case.registry.raw is None and case.revocations == 0
+
+
+@pytest.mark.parametrize(
+    "change",
+    [
+        "delete-profile",
+        "delete-locator",
+        "malformed-profile",
+        "malformed-locator",
+        "disable-locator",
+    ],
+)
+def test_active_configuration_tampering_cannot_disable_gate(
+    config_catalog: SchemaCatalog, change: str
+) -> None:
+    """Missing, malformed or disabled workspace declarations keep active discovery
+    blocked."""
+    case = ConfigurationCase(config_catalog)
+    assert case.service.configure(
+        ConfigurationRequest(action="activate", profile_bytes=profile_bytes())
+    ).ok
+    path = DEFAULT_PROFILE if "profile" in change else LOCATOR_PATH
+    if change.startswith("delete"):
+        del case.disk.store.files[path]
+        case.disk.store.metadata.remove(path)
+    else:
+        case.disk.store.put(
+            path, b'{"enabled":false}' if change == "disable-locator" else b"{}"
+        )
+    with pytest.raises((ConfigurationError, ProfileError)):
+        case.service.select(controlled=True)
+    assert case.record().active and case.registry.writes == 1
+    assert case.service.configure(ConfigurationRequest(action="deactivate")).ok
+    assert case.service.select(controlled=True).state == "inactive"
+
+
+def test_partial_activation_keeps_protected_gate_active_and_recovers(
+    config_catalog: SchemaCatalog,
+) -> None:
+    """A publication failure reports bounded effects and requires repair, never
+    silent opt-out."""
+    case = ConfigurationCase(config_catalog)
+    case.disk.fail_publish = True
+    result = case.service.configure(
+        ConfigurationRequest(action="activate", profile_bytes=profile_bytes())
+    )
+    assert not result.ok and result.authority_invalidated
+    assert (
+        "protected-activation" in result.changed and DEFAULT_PROFILE in result.uncertain
+    )
+    assert case.record().active and not case.disk.locked and case.disk.held == 0
+    with pytest.raises(ConfigurationError):
+        case.service.select(controlled=True)
+    case.disk.fail_publish = False
+    assert case.service.configure(
+        ConfigurationRequest(action="activate", profile_bytes=profile_bytes())
+    ).ok
+    assert case.service.select(controlled=True).state == "active"
+
+
+def test_invalid_proposal_and_missing_profile_abort_without_effects(
+    config_catalog: SchemaCatalog,
+) -> None:
+    """Accepted profile validation runs before lock acquisition, activation or
+    invalidation."""
+    case = ConfigurationCase(config_catalog)
+    with pytest.raises(ProfileError):
+        case.service.configure(
+            ConfigurationRequest(action="activate", profile_bytes=b"{}")
+        )
+    with pytest.raises(ConfigurationError, match="requires a profile"):
+        case.service.configure(ConfigurationRequest(action="activate"))
+    assert (
+        case.registry.raw is None
+        and case.revocations == 0
+        and not case.disk.store.files
+    )
+
+
+def test_inactive_workspace_and_missing_registry_are_read_only(
+    config_catalog: SchemaCatalog,
+) -> None:
+    """Unrelated work remains unaffected without creating even an authority
+    directory."""
+    case = ConfigurationCase(config_catalog)
+    assert case.service.select(controlled=True).state == "inactive"
+    assert (
+        case.registry.writes == 0
+        and not case.disk.store.files
+        and case.revocations == 0
+    )
+    case.disk.store.put(DEFAULT_PROFILE, profile_bytes())
+    assert case.service.select().state == "activation-required"
+    with pytest.raises(ConfigurationError, match="activation is required"):
+        case.service.select(controlled=True)
+
+
+def test_tombstone_read_cannot_hide_concurrent_activation(
+    config_catalog: SchemaCatalog, monkeypatch: pytest.MonkeyPatch
+) -> None:
+    """The inactive fast path rechecks protected bytes before returning an opt-out."""
+    case = ConfigurationCase(config_catalog)
+    assert case.service.configure(ConfigurationRequest(action="deactivate")).ok
+    original = case.registry.raw
+    changed = replace(
+        active_record(profile_bytes()),
+        workspace_sha256=case.location.workspace_sha256,
+        generation=2,
+        previous_sha256=sha256(original or b"").hexdigest(),
+    ).encode()
+    reads: list[int] = []
+
+    def racing_read() -> bytes | None:
+        """Return the old observation once, while replacing its protected generation."""
+        reads.append(1)
+        return original if len(reads) == 1 else changed
+
+    monkeypatch.setattr(case.registry, "read", racing_read)
+    with pytest.raises(ConfigurationError, match="changed during inactive"):
+        case.service.select()
+    assert len(reads) == 2
+
+
+def test_new_candidate_inside_guard_aborts_before_revocation_or_publication(
+    config_catalog: SchemaCatalog, monkeypatch: pytest.MonkeyPatch
+) -> None:
+    """Candidate absence is part of guarded freshness, not only initial selection."""
+    case = ConfigurationCase(config_catalog)
+    alternate = "docs/other.yaml"
+    case.service.candidate_paths = (DEFAULT_PROFILE, alternate)
+
+    def racing_authorization() -> None:
+        """Inject a competing known profile only after the original read and guard
+        acquisition."""
+        case.authorize()
+        if case.authorization_calls == 2:
+            case.disk.store.put(alternate, profile_bytes(alternate))
+
+    monkeypatch.setattr(case.service, "authorize_root", racing_authorization)
+    result = case.service.configure(
+        ConfigurationRequest(action="activate", profile_bytes=profile_bytes())
+    )
+    assert not result.ok and result.error and "candidates changed" in result.error
+    assert case.registry.raw is None and case.revocations == 0 and not result.changed
+    assert set(case.disk.store.files) == {alternate}
+
+
+@pytest.mark.parametrize("condition", ["profile-path", "candidate"])
+def test_configuration_conflicts_are_rejected_before_lock_or_revocation(
+    config_catalog: SchemaCatalog, condition: str
+) -> None:
+    """A root request cannot publish inconsistent paths or hide known candidates."""
+    case = ConfigurationCase(config_catalog)
+    if condition == "candidate":
+        case.disk.store.put("docs/alternate.yaml", profile_bytes("docs/alternate.yaml"))
+        case.service.candidate_paths = (DEFAULT_PROFILE, "docs/alternate.yaml")
+    request = ConfigurationRequest(
+        action="activate",
+        profile_bytes=profile_bytes(),
+        profile_path=(
+            "docs/custom.yaml" if condition == "profile-path" else DEFAULT_PROFILE
+        ),
+    )
+    with pytest.raises(ConfigurationError):
+        case.service.configure(request)
+    assert case.registry.writes == 0 and case.revocations == 0 and not case.disk.locked
+
+
+@pytest.mark.parametrize("change", ["bytes", "parent", "candidate", "authorization"])
+def test_guarded_input_changes_abort_before_protected_publication(
+    config_catalog: SchemaCatalog, change: str, monkeypatch: pytest.MonkeyPatch
+) -> None:
+    """Freshness and authorization are checked again before protected state changes."""
+    case = ConfigurationCase(config_catalog)
+    alternate = "docs/alternate.yaml"
+    case.service.candidate_paths = (DEFAULT_PROFILE, alternate)
+
+    def mutate() -> None:
+        """Inject one independent changed input at the explicit invalidation seam."""
+        if change == "bytes":
+            case.disk.store.put(DEFAULT_PROFILE, b"changed")
+        elif change == "parent":
+            case.disk.store.metadata.add("docs", kind="directory", identity="changed")
+        else:
+            case.disk.store.put(alternate, profile_bytes(alternate))
+
+    if change == "authorization":
+
+        def deny_second() -> None:
+            """Revoke the trusted principal between planning and guard acquisition."""
+            case.authorize()
+            if case.authorization_calls == 2:
+                raise PermissionError("root authorization revoked")
+
+        monkeypatch.setattr(case.service, "authorize_root", deny_second)
+    else:
+        case.on_revoke = mutate
+    result = case.service.configure(
+        ConfigurationRequest(action="activate", profile_bytes=profile_bytes())
+    )
+    assert not result.ok and not result.changed and case.registry.raw is None
+    assert result.authority_invalidated == (change != "authorization")
+    assert not case.disk.locked and case.disk.held == 0
+
+
+@pytest.mark.parametrize("change", ["root", "parent", "opened-parent", "leaf"])
+def test_physical_substitutions_after_activation_intent_fail_explicitly(
+    config_catalog: SchemaCatalog, change: str
+) -> None:
+    """Recorded active intent remains blocking if a publication anchor changes."""
+    case = ConfigurationCase(config_catalog)
+
+    def replace_path(path: str) -> None:
+        """Substitute a directory only in the requested metadata-to-open interval."""
+        if path == ("." if change == "root" else "docs"):
+            prior = case.disk.store.metadata(path)
+            case.disk.store.metadata.entries[path] = replace(prior, identity="changed")
+
+    def after_record() -> None:
+        """Change one pre-observed path after protected intent is recorded."""
+        if change in {"root", "opened-parent"}:
+            case.disk.before_open = replace_path
+        elif change == "parent":
+            replace_path("docs")
+        else:
+            case.disk.store.put(DEFAULT_PROFILE, b"concurrent leaf")
+
+    case.registry.after_write = after_record
+    result = case.service.configure(
+        ConfigurationRequest(action="activate", profile_bytes=profile_bytes())
+    )
+    assert not result.ok and result.authority_invalidated and result.uncertain
+    assert case.record().active and "protected-activation" in result.changed
+    assert not case.disk.locked and case.disk.held == 0
+
+
+@pytest.mark.parametrize("change", ["parent", "bytes", "candidate"])
+def test_postpublication_changes_invalidate_configuration_success(
+    config_catalog: SchemaCatalog, change: str, monkeypatch: pytest.MonkeyPatch
+) -> None:
+    """Retained parent identities and exact final bytes both bind successful output."""
+    case = ConfigurationCase(config_catalog)
+    alternate = "docs/alternate.yaml"
+    case.service.candidate_paths = (DEFAULT_PROFILE, alternate)
+    original = case.service.primitives.create_exclusive
+
+    def publish(target: ResolvedPath, content: bytes) -> None:
+        """Inject an observed external edit after the final atomic publication."""
+        original(target, content)
+        if target.path == LOCATOR_PATH:
+            if change == "parent":
+                case.disk.store.metadata.add(
+                    "docs", kind="directory", identity="changed"
+                )
+            elif change == "bytes":
+                case.disk.store.put(LOCATOR_PATH, b"changed")
+            else:
+                case.disk.store.put(alternate, profile_bytes(alternate))
+
+    monkeypatch.setattr(case.service.primitives, "create_exclusive", publish)
+    result = case.service.configure(
+        ConfigurationRequest(action="activate", profile_bytes=profile_bytes())
+    )
+    assert not result.ok and result.authority_invalidated
+    assert set(result.changed) >= {DEFAULT_PROFILE, LOCATOR_PATH}
+    assert case.record().active and not case.disk.locked and case.disk.held == 0
+
+
+def test_inactive_selection_rejects_a_concurrent_protected_record_change(
+    config_catalog: SchemaCatalog, monkeypatch: pytest.MonkeyPatch
+) -> None:
+    """The ordinary inactive branch also rechecks protected state before return."""
+    case = ConfigurationCase(config_catalog)
+    observations = iter([None, b"new protected record"])
+    monkeypatch.setattr(case.registry, "read", lambda: next(observations))
+    with pytest.raises(ConfigurationError, match="changed during selection"):
+        case.service.select()
+    assert case.registry.writes == 0
diff --git a/tests/discovery_runtime/test_configuration.py b/tests/discovery_runtime/test_configuration.py
new file mode 100644
index 0000000000000000000000000000000000000000..bd16f8b51c7d46683bcfeaf25f0077a60f13dc49
--- /dev/null
+++ b/tests/discovery_runtime/test_configuration.py
@@ -0,0 +1,330 @@
+"""Prove inert selection cannot hide missing active inputs or manufacture authority."""
+
+from __future__ import annotations
+
+import json
+from dataclasses import fields, replace
+from hashlib import sha256
+from typing import TYPE_CHECKING, cast
+
+import pytest
+from drm_copilot_discovery.catalog import load_catalog
+from drm_copilot_discovery.configuration import (
+    DEFAULT_PROFILE,
+    ActivationRecord,
+    ConfigurationError,
+    ConfigurationRequest,
+    locator_bytes,
+    select_configuration,
+)
+from drm_copilot_discovery.path_models import PathPolicyError
+from drm_copilot_discovery.profile_v2 import ProfileError
+
+from tests.discovery_runtime.test_profile_v2 import profile_document
+from tests.schemas.discovery.v2_schema_test_support import as_object
+
+if TYPE_CHECKING:
+    from drm_copilot_discovery.catalog import SchemaCatalog
+
+
+@pytest.fixture(scope="module")
+def config_catalog() -> SchemaCatalog:
+    """Share only immutable packaged schemas; every mutable fixture remains local."""
+    return load_catalog()
+
+
+def profile_bytes(path: str = DEFAULT_PROFILE) -> bytes:
+    """Return independent valid configuration with one explicit profile location."""
+    document = profile_document()
+    as_object(document["artifacts"])["profile"] = path
+    document["project_entry_points"] = []
+    return json.dumps(document).encode()
+
+
+def active_record(content: bytes, path: str = DEFAULT_PROFILE) -> ActivationRecord:
+    """Model protected observation data without creating a native root capability."""
+    return ActivationRecord(
+        workspace_sha256="a" * 64,
+        generation=1,
+        action="activate",
+        profile_path=path,
+        profile_sha256=sha256(content).hexdigest(),
+        locator_sha256=sha256(locator_bytes(path)).hexdigest(),
+        previous_sha256=None,
+    )
+
+
+@pytest.mark.parametrize("path", [DEFAULT_PROFILE, "docs/Custom Profile.yaml"])
+def test_default_and_custom_selection_require_explicit_activation(
+    config_catalog: SchemaCatalog, path: str
+) -> None:
+    """A valid locator or explicit selector locates configuration without granting
+    activation."""
+    content = profile_bytes(path)
+    selection = select_configuration(
+        candidates={path: content},
+        locator=None,
+        activation=None,
+        catalog=config_catalog,
+        profile_path=path if path != DEFAULT_PROFILE else None,
+    )
+    assert selection.state == "activation-required"
+    assert selection.profile_bytes == content and selection.profile_path == path
+    with pytest.raises(ConfigurationError, match="activation is required"):
+        select_configuration(
+            candidates={path: content},
+            locator=locator_bytes(path),
+            activation=None,
+            catalog=config_catalog,
+            controlled=True,
+        )
+
+
+def test_protected_matching_bytes_enable_selection_but_are_not_grants(
+    config_catalog: SchemaCatalog,
+) -> None:
+    """Only matching protected observations yield active readiness, with exact raw
+    bytes."""
+    content = profile_bytes()
+    selection = select_configuration(
+        candidates={DEFAULT_PROFILE: content},
+        locator=locator_bytes(DEFAULT_PROFILE),
+        activation=active_record(content),
+        catalog=config_catalog,
+        controlled=True,
+    )
+    assert selection.state == "active" and selection.profile is not None
+    assert selection.locator_bytes == locator_bytes(DEFAULT_PROFILE)
+    assert not hasattr(selection, "grant")
+
+
+def test_inactive_nonparticipant_and_explicit_deactivation(
+    config_catalog: SchemaCatalog,
+) -> None:
+    """Absent activation/default leaves unrelated work alone; root tombstones
+    override leftovers."""
+    assert (
+        select_configuration(
+            candidates={},
+            locator=None,
+            activation=None,
+            catalog=config_catalog,
+            controlled=True,
+        ).state
+        == "inactive"
+    )
+    tombstone = replace(
+        active_record(profile_bytes()), action="deactivate", generation=2
+    )
+    assert (
+        select_configuration(
+            candidates={DEFAULT_PROFILE: b"malformed"},
+            locator=b"bad",
+            activation=tombstone,
+            catalog=config_catalog,
+        ).state
+        == "inactive"
+    )
+    with pytest.raises(ProfileError):
+        select_configuration(
+            candidates={DEFAULT_PROFILE: b"bad"},
+            locator=b"bad",
+            activation=tombstone,
+            profile_path=DEFAULT_PROFILE,
+            catalog=config_catalog,
+        )
+
+
+@pytest.mark.parametrize(
+    "case",
+    [
+        "multiple",
+        "argument",
+        "missing",
+        "deleted-locator",
+        "deleted-profile",
+        "changed-profile",
+        "changed-locator",
+        "internal-path",
+        "custom-unselected",
+    ],
+)
+def test_ambiguous_missing_or_changed_configuration_fails(
+    config_catalog: SchemaCatalog, case: str
+) -> None:
+    """Each independent selector/freshness violation remains a blocking typed
+    finding."""
+    content = profile_bytes()
+    candidates = {DEFAULT_PROFILE: content}
+    locator: bytes | None = locator_bytes(DEFAULT_PROFILE)
+    activation: ActivationRecord | None = active_record(content)
+    selected: str | None = None
+    # Change one observed fact at a time so failures retain the intended boundary.
+    if case == "multiple":
+        candidates["docs/other.yaml"] = content
+    elif case == "argument":
+        selected = "docs/other.yaml"
+    elif case in {"missing", "deleted-profile"}:
+        candidates.clear()
+        if case == "missing":
+            activation = None
+            selected = DEFAULT_PROFILE
+    elif case == "deleted-locator":
+        locator = None
+    elif case == "changed-profile":
+        candidates[DEFAULT_PROFILE] = content + b"\n"
+    elif case == "changed-locator":
+        locator += b"\n"
+    elif case == "internal-path":
+        candidates[DEFAULT_PROFILE] = profile_bytes("docs/other.yaml")
+        activation = None
+    else:
+        candidates = {"docs/custom.yaml": profile_bytes("docs/custom.yaml")}
+        activation, locator = None, None
+    with pytest.raises(ConfigurationError) as caught:
+        select_configuration(
+            candidates=candidates,
+            locator=locator,
+            activation=activation,
+            profile_path=selected,
+            catalog=config_catalog,
+        )
+    assert caught.value.findings[0].code in {
+        "CONFIGURATION_AMBIGUOUS",
+        "CONFIGURATION_DISAGREEMENT",
+        "CONFIGURATION_MISSING",
+        "ACTIVATION_STALE",
+    }
+
+
+@pytest.mark.parametrize(
+    "content",
+    [
+        b"null",
+        b"{}",
+        b'{"enabled":false}',
+        b'{"schema_version":"9"}',
+        b'{"enabled":true,"enabled":false}',
+    ],
+)
+def test_malformed_locator_never_means_inactive(
+    config_catalog: SchemaCatalog, content: bytes
+) -> None:
+    """Disabled, unknown and duplicate-key locators cannot opt out of an active gate."""
+    with pytest.raises(ProfileError):
+        select_configuration(
+            candidates={DEFAULT_PROFILE: profile_bytes()},
+            locator=content,
+            activation=active_record(profile_bytes()),
+            catalog=config_catalog,
+        )
+
+
+def test_malformed_profile_and_unsafe_selector_are_rejected(
+    config_catalog: SchemaCatalog,
+) -> None:
+    """The shared parser/path policy remains authoritative for proposed inputs."""
+    with pytest.raises(ProfileError):
+        select_configuration(
+            candidates={DEFAULT_PROFILE: b"{}"},
+            locator=None,
+            activation=None,
+            catalog=config_catalog,
+        )
+    with pytest.raises(PathPolicyError):
+        select_configuration(
+            candidates={},
+            locator=None,
+            activation=None,
+            profile_path="../outside",
+            catalog=config_catalog,
+        )
+
+
+def test_record_round_trip_preserves_audit_chain_and_workspace_identity() -> None:
+    """Protected transitions are deterministic, bounded and bound to one canonical
+    workspace."""
+    record = active_record(profile_bytes())
+    assert (
+        record.active
+        and ActivationRecord.decode(record.encode(), workspace_sha256="a" * 64)
+        == record
+    )
+    tombstone = replace(
+        record,
+        action="deactivate",
+        generation=2,
+        previous_sha256=sha256(record.encode()).hexdigest(),
+    )
+    assert not tombstone.active
+    assert (
+        ActivationRecord.decode(tombstone.encode(), workspace_sha256="a" * 64)
+        == tombstone
+    )
+    with pytest.raises(ConfigurationError, match="another workspace"):
+        ActivationRecord.decode(record.encode(), workspace_sha256="b" * 64)
+
+
+@pytest.mark.parametrize(
+    "key,value",
+    [
+        ("generation", True),
+        ("generation", 0),
+        ("action", "root"),
+        ("schema_version", "1"),
+        ("workspace_sha256", ""),
+        ("workspace_sha256", None),
+        ("profile_sha256", 4),
+        ("locator_sha256", None),
+        ("profile_path", "../outside"),
+        ("permission", "root"),
+    ],
+)
+def test_invalid_protected_fields_fail_closed(key: str, value: object) -> None:
+    """Corrupt versions, identities or added authority claims never become inactive
+    state."""
+    document = cast(
+        "dict[str, object]", json.loads(active_record(profile_bytes()).encode())
+    )
+    document[key] = value
+    with pytest.raises(ConfigurationError):
+        ActivationRecord.decode(
+            json.dumps(document).encode(), workspace_sha256="a" * 64
+        )
+
+
+@pytest.mark.parametrize(
+    "content",
+    [b"{}", b"invalid", b" " * 65537, b'{"generation":1,"generation":2}'],
+    ids=["missing-fields", "invalid-json", "oversized", "duplicate-key"],
+)
+def test_registry_parse_errors_remain_blocking(content: bytes) -> None:
+    """The common bounded strict JSON parser supplies no permissive fallback."""
+    with pytest.raises(ConfigurationError):
+        ActivationRecord.decode(content, workspace_sha256="a" * 64)
+
+
+@pytest.mark.parametrize(
+    "changes",
+    [
+        {"action": "unknown"},
+        {"profile_path": "../outside"},
+        {"profile_bytes": "text"},
+        {"dry_run": 1},
+        {"action": "deactivate", "profile_bytes": b"{}"},
+        {"action": "deactivate", "profile_path": "docs/custom.yaml"},
+    ],
+)
+def test_request_cannot_select_unsafe_or_irrelevant_inputs(
+    changes: dict[str, object],
+) -> None:
+    """Only closed configuration intent is accepted, with no root or registry path
+    field."""
+    with pytest.raises(ValueError):
+        replace(ConfigurationRequest(action="activate"), **changes)
+    assert {field.name for field in fields(ConfigurationRequest)} == {
+        "action",
+        "profile_path",
+        "profile_bytes",
+        "dry_run",
+    }
diff --git a/tests/discovery_runtime/test_mutation_filesystem.py b/tests/discovery_runtime/test_mutation_filesystem.py
index ccb5aaa1b633b10091469019f74ca5cf86535ef7..bc8c0a1793c1126c334b4ab2383890e3a62e69d1 100644
--- a/tests/discovery_runtime/test_mutation_filesystem.py
+++ b/tests/discovery_runtime/test_mutation_filesystem.py
@@ -426,0 +427,58 @@ def test_native_metadata_keeps_complete_names_and_nonfollowing_identity(
+
+
+@pytest.mark.parametrize(
+    "content", [b"a\nb\n", b"a\r\nb\r\n", b"a\x1ab", b"\x00\xff\n\r\n\x1a"]
+)
+@pytest.mark.parametrize("binary_flag", [None, 0x8000])
+def test_native_descriptor_flags_preserve_binary_bytes(
+    content: bytes, binary_flag: int | None, monkeypatch: pytest.MonkeyPatch
+) -> None:
+    """Byte publication and bounded reads disable host text translation explicitly."""
+    stored = bytearray()
+    flags: list[int] = []
+    closed: list[int] = []
+    if binary_flag is None:
+        monkeypatch.delattr(os, "O_BINARY", raising=False)
+    else:
+        monkeypatch.setattr(os, "O_BINARY", binary_flag, raising=False)
+
+    def opening(name: str, mode: int, *args: object, **kwargs: object) -> int:
+        """Require the platform binary bit for both actual descriptor operations."""
+        assert mode & (binary_flag or 0) == (binary_flag or 0)
+        flags.append(mode)
+        return 71
+
+    def writing(descriptor: int, data: bytes) -> int:
+        """Persist the exact bytes supplied through the binary descriptor seam."""
+        assert descriptor == 71
+        stored.extend(data)
+        return len(data)
+
+    def reading(descriptor: int, count: int) -> bytes:
+        """Consume fresh in-memory bytes under the requested bounded read size."""
+        assert descriptor == 71
+        result = bytes(stored[:count])
+        del stored[:count]
+        return result
+
+    @contextmanager
+    def pin(path: Path, *, directory: bool) -> Generator[os.stat_result, None, None]:
+        """Substitute only the native pin while exercising real read/stage logic."""
+        yield stat_value(directory=directory)
+
+    monkeypatch.setattr(filesystem, "pin_windows_path", pin)
+    monkeypatch.setattr(os, "open", opening)
+    monkeypatch.setattr(os, "write", writing)
+    monkeypatch.setattr(os, "read", reading)
+    monkeypatch.setattr(os, "fsync", constant(None))
+    monkeypatch.setattr(os, "fstat", constant(stat_value()))
+    monkeypatch.setattr(os, "close", closed.append)
+    directory = NativeDirectory(Path("anchor"), 5, "7:11")
+    directory.stage("binary", content)
+    assert bytes(stored) == content
+    assert directory.read("binary", limit=len(content)) == content
+    assert flags == [
+        os.O_WRONLY | os.O_CREAT | os.O_EXCL | (binary_flag or 0),
+        os.O_RDONLY | getattr(os, "O_NOFOLLOW", 0) | (binary_flag or 0),
+    ]
+    assert closed == [71, 71]
```
