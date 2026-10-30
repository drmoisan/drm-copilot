"""Compose root-owned initialization over the accepted native mutation primitives.

Virtual profile/directory metadata is used only to validate a proposal. Physical
captures retain actual absence and identities for guarded freshness checks. This
boundary serializes cooperating writers; it is not a multi-file transaction or
an authorization mechanism for clients that can bypass native tool restrictions.
"""

from __future__ import annotations

from contextlib import ExitStack
from dataclasses import dataclass, replace
from pathlib import Path
from typing import TYPE_CHECKING

from drm_copilot_discovery.init_projection import (
    InitializationCapture,
    InitializationConflict,
    ProposalInputs,
)
from drm_copilot_discovery.mutation_filesystem import (
    LocalMutationPrimitives,
    open_local_directory,
)
from drm_copilot_discovery.mutation_io import capture_workspace
from drm_copilot_discovery.path_models import WriteGrant
from drm_copilot_discovery.path_policy import FILE_KEYS, PathPolicy

if TYPE_CHECKING:
    from collections.abc import Callable
    from contextlib import AbstractContextManager

    from drm_copilot_discovery.catalog import SchemaCatalog
    from drm_copilot_discovery.mutation_filesystem import Directory
    from drm_copilot_discovery.mutation_io import MutationPrimitives
    from drm_copilot_discovery.mutation_plan import CapturedWorkspace
    from drm_copilot_discovery.path_models import PathMetadataReader, ResolvedPath
    from drm_copilot_discovery.repository_reader import RepositoryReader
    from drm_copilot_discovery.snapshot_io import WorkspaceBytes


@dataclass(frozen=True, kw_only=True)
class BootstrapResult:
    """
    Report exact completed paths and bounded uncertainty without claiming authority.
    """

    ok: bool
    created: tuple[str, ...]
    uncertain: tuple[str, ...]
    authority_invalidated: bool
    error: str | None = None
    physical: CapturedWorkspace | None = None
    conflicts: tuple[str, ...] = ()


class InitializationIO:
    """
    Bind trusted native readers, guard and directory handles before processing inputs.

    A host must authenticate root and bind these capabilities independently of
    request data. Legacy FileSystem objects are deliberately not accepted here.
    Unit tests supply memory implementations of the same narrow primitives.
    """

    def __init__(
        self,
        *,
        workspace_root: str,
        catalog: SchemaCatalog,
        metadata: PathMetadataReader,
        read_bytes: WorkspaceBytes,
        primitives: MutationPrimitives,
        open_directory: Callable[[], AbstractContextManager[Directory]],
        invalidate_authority: Callable[[], None],
        repository: RepositoryReader | None = None,
    ) -> None:
        """Store trusted collaborators without granting authority or performing I/O."""
        self.workspace_root, self.catalog = workspace_root, catalog
        self.metadata, self.read_bytes = metadata, read_bytes
        self.primitives, self.open_directory = primitives, open_directory
        self.invalidate_authority, self.repository = invalidate_authority, repository

    @classmethod
    def local(
        cls,
        *,
        workspace_root: str,
        lock_path: str,
        catalog: SchemaCatalog,
        invalidate_authority: Callable[[], None],
        repository: RepositoryReader | None = None,
    ) -> InitializationIO:
        """Wire the accepted Windows/POSIX provider and externally provisioned lock."""
        primitives = LocalMutationPrimitives(
            workspace_root=workspace_root, lock_path=lock_path
        )
        return cls(
            workspace_root=workspace_root,
            catalog=catalog,
            metadata=primitives.metadata,
            read_bytes=primitives.read_bytes,
            primitives=primitives,
            open_directory=lambda: open_local_directory(Path(workspace_root)),
            invalidate_authority=invalidate_authority,
            repository=repository,
        )

    def capture(
        self,
        *,
        profile_path: str,
        profile_bytes: bytes,
        directories: tuple[str, ...] = (),
    ) -> InitializationCapture:
        """
        Load a complete proposal and separately freeze actual bytes and identities.
        """
        inputs = ProposalInputs(self, profile_path, profile_bytes, directories)
        proposal = capture_workspace(
            workspace_root=self.workspace_root,
            profile_path=profile_path,
            metadata=inputs.inspect,
            read_bytes=inputs.read,
            catalog=self.catalog,
            repository=self.available_repository(),
        )
        # Recheck physical inputs after the virtual loader's own consistency checks.
        for path in tuple(inputs.metadata):
            inputs.physical(path)
        # A successful virtual load cannot conceal a later physical byte change.
        for path, content in tuple(inputs.files.items()):
            if self.read_bytes(path, limit=max(1, len(content))) != content:
                raise OSError("Initialization bytes changed after capture")
        return InitializationCapture(
            proposal_base=proposal,
            physical_metadata=tuple(sorted(inputs.metadata.items())),
            physical_files=tuple(sorted(inputs.files.items())),
            profile_missing=inputs.profile_missing,
        )

    def physical_capture(self, profile_path: str) -> CapturedWorkspace:
        """
        Read only actual inputs after bootstrap; no proposal can reach mutation commit.
        """
        return capture_workspace(
            workspace_root=self.workspace_root,
            profile_path=profile_path,
            metadata=self.metadata,
            read_bytes=self.read_bytes,
            catalog=self.catalog,
            repository=self.available_repository(),
        )

    def available_repository(self) -> RepositoryReader | None:
        """Treat unavailable local Git as absent; never infer or fetch a revision."""
        if self.repository is not None:
            try:
                self.repository.identity()
            except OSError:
                return None
        return self.repository

    def _directory(
        self,
        target: ResolvedPath,
        anchors: ExitStack,
        created: list[str],
        opened: dict[str, str],
        *,
        parents_only: bool = False,
    ) -> None:
        """
        Exclusively create missing directories and pin checked identities through
        postcheck.
        """
        directory = anchors.enter_context(self.open_directory())
        if directory.identity() != target.observations[0].identity:
            raise OSError("Opened initialization workspace identity changed")
        opened["."] = directory.identity()
        stamps = target.observations[1:-1] if parents_only else target.observations[1:]
        # Retain each opened ancestor so publication cannot adopt a changed parent.
        for stamp in stamps:
            current = self.metadata(stamp.path)
            if (current.kind, current.identity, current.resolved_path) != (
                stamp.kind,
                stamp.identity,
                stamp.resolved_path,
            ):
                raise OSError("Initialization parent changed before directory creation")
            directory = anchors.enter_context(
                directory.child(
                    stamp.path.split("/")[-1], create=stamp.kind == "missing"
                )
            )
            if stamp.kind != "missing" and directory.identity() != stamp.identity:
                raise OSError("Opened initialization directory identity changed")
            identity = directory.identity()
            if opened.setdefault(stamp.path, identity) != identity:
                raise OSError("Retained initialization directory identity changed")
            if stamp.kind == "missing":
                created.append(stamp.path)

    def bootstrap(
        self,
        expected: InitializationCapture,
        *,
        profile_bytes: bytes,
        directories: tuple[str, ...],
    ) -> BootstrapResult:
        """
        Publish only the root profile and configured empty directories under one guard.

        Every ordinary artifact is published later by the accepted mutation engine.
        A partial failure retains completed paths, revokes authority and never rolls
        back over a concurrent writer. Synthetic identities are never native stamps.
        """
        profile = expected.proposal_base.snapshot.profile
        profile_path = profile.artifacts["profile"]
        if profile_bytes != expected.proposal_base.snapshot.file(profile_path).content:
            raise ValueError(
                "Bootstrap profile bytes differ from the validated proposal"
            )
        # Bootstrap accepts exactly the configured directory categories.
        allowed = tuple(
            sorted(
                str(value)
                for key, value in profile.artifacts.data.items()
                if key not in FILE_KEYS
            )
        )
        if tuple(sorted(directories)) != allowed:
            raise ValueError(
                "Bootstrap directories must exactly match configured "
                "artifact directories"
            )
        created: list[str] = []
        opened: dict[str, str] = {}
        active_path: str | None = None
        uncertain: tuple[str, ...] = ()
        revoked = False
        try:
            with self.primitives.guard(), ExitStack() as anchors:
                expected.require_same(
                    self.capture(
                        profile_path=profile_path,
                        profile_bytes=profile_bytes,
                        directories=directories,
                    )
                )
                policy = PathPolicy(
                    profile, workspace_root=self.workspace_root, metadata=self.metadata
                )
                policy.validate_configuration()
                needs_write = expected.profile_missing or any(
                    self.metadata(path).kind == "missing" for path in directories
                )
                if needs_write:
                    self.invalidate_authority()
                    revoked = True
                    expected.require_same(
                        self.capture(
                            profile_path=profile_path,
                            profile_bytes=profile_bytes,
                            directories=directories,
                        )
                    )
                if expected.profile_missing:
                    target = policy.resolve_read(profile_path, allow_missing=True)
                    if target.observations[-1].kind != "missing":
                        raise FileExistsError("The proposed profile now exists; reload")
                    # A failure may leave only these previously absent ancestors.
                    uncertain = tuple(
                        stamp.path
                        for stamp in target.observations
                        if stamp.kind == "missing"
                    )
                    active_path = profile_path
                    self._directory(target, anchors, created, opened, parents_only=True)
                    target = policy.resolve_read(profile_path, allow_missing=True)
                    uncertain = (profile_path,)
                    # Root-only profile publication is separate from analyst output
                    # grants.
                    target = replace(
                        target,
                        grant=WriteGrant(
                            artifact_kind="domain-profile",
                            artifact_id=profile.id,
                            path=profile_path,
                        ),
                    )
                    self.primitives.create_exclusive(target, profile_bytes)
                    created.append(profile_path)
                    uncertain = ()
                # Empty configured directories are effects even without file output.
                for path in directories:
                    active_path = path
                    target = policy.resolve_read(path, allow_missing=True)
                    # Bound partial uncertainty to the currently attempted route.
                    uncertain = tuple(
                        stamp.path
                        for stamp in target.observations
                        if stamp.kind == "missing"
                    )
                    self._directory(target, anchors, created, opened)
                    uncertain = ()
                current = self.capture(
                    profile_path=profile_path,
                    profile_bytes=profile_bytes,
                    directories=directories,
                )
                self._after_bootstrap(expected, current, created, profile_bytes, opened)
            return BootstrapResult(
                ok=True,
                created=tuple(sorted(created)),
                uncertain=(),
                authority_invalidated=revoked,
                physical=current.proposal_base,
            )
        except (OSError, ValueError) as error:
            if not revoked:
                try:
                    self.invalidate_authority()
                    revoked = True
                except OSError as invalidation_error:
                    error = OSError(
                        f"{error}; authority invalidation failed: {invalidation_error}"
                    )
            return BootstrapResult(
                ok=False,
                created=tuple(sorted(set(created))),
                uncertain=uncertain,
                authority_invalidated=revoked,
                error=str(error),
                conflicts=(
                    tuple(item.path for item in error.outputs)
                    if isinstance(error, InitializationConflict)
                    else (active_path,) if active_path is not None else ()
                ),
            )

    def _after_bootstrap(
        self,
        before: InitializationCapture,
        after: InitializationCapture,
        created: list[str],
        profile_bytes: bytes,
        opened: dict[str, str],
    ) -> None:
        """
        Allow exactly new configured directories/profile while preserving prior inputs.
        """
        files = dict(before.physical_files)
        profile_path = before.proposal_base.snapshot.profile.artifacts["profile"]
        if before.profile_missing:
            files[profile_path] = profile_bytes
        if (
            files != dict(after.physical_files)
            or before.proposal_base.snapshot.sha256
            != after.proposal_base.snapshot.sha256
        ):
            raise OSError("Initialization bootstrap changed unexpected input bytes")
        actual = dict(after.physical_metadata)
        if after.profile_missing or any(
            path not in actual
            or actual[path].kind != "directory"
            or actual[path].identity != identity
            for path, identity in opened.items()
        ):
            raise OSError(
                "Opened initialization directory identity changed after creation"
            )
        # Only explicitly created paths and their parent child lists may change.
        for path, old in before.physical_metadata:
            new = actual.get(path)
            if new is None:
                raise OSError("Initialization lost a previously observed input path")
            if path in created:
                if old.kind != "missing" or new.kind != (
                    "file" if path == profile_path else "directory"
                ):
                    raise OSError("Initialization created an unexpected path kind")
                continue
            prefix = "" if path == "." else path + "/"
            # Admit only names introduced by the recorded bootstrap effects.
            children = set(old.children) | {
                item[len(prefix) :].split("/")[0]
                for item in created
                if item.startswith(prefix) and item != path
            }
            if (
                replace(
                    old,
                    children=tuple(sorted(children)) if old.kind == "directory" else (),
                )
                != new
            ):
                raise OSError(
                    "Initialization changed an unrelated filesystem "
                    "identity or namespace"
                )
