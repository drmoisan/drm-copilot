"""Capture and commit planned mutations through explicit trusted I/O contracts.

This module never opens files or launches a process. Native adapters provide
non-following reads, complete captures, authority invalidation and guarded atomic
writes. Separate Python checks alone cannot close an operating-system race.
"""

from __future__ import annotations

from dataclasses import dataclass, replace
from typing import TYPE_CHECKING, Literal, Protocol, cast

from drm_copilot_discovery.findings import Finding
from drm_copilot_discovery.mutation_plan import (
    CapturedWorkspace,
    MutationError,
    MutationPlan,
    PlannedWrite,
    plan_mutation,
    project_snapshot,
)
from drm_copilot_discovery.path_policy import PathPolicy
from drm_copilot_discovery.snapshot_io import SnapshotIO
from drm_copilot_discovery.snapshot_loading import load_snapshot
from drm_copilot_discovery.validation import validate_snapshot

if TYPE_CHECKING:
    from collections.abc import Callable
    from contextlib import AbstractContextManager

    from drm_copilot_discovery.catalog import SchemaCatalog
    from drm_copilot_discovery.path_models import (
        PathMetadata,
        PathMetadataReader,
        ResolvedPath,
        WriteGrant,
    )
    from drm_copilot_discovery.repository_reader import RepositoryReader
    from drm_copilot_discovery.snapshot_io import WorkspaceBytes
    from drm_copilot_discovery.validation import SnapshotValidation


def capture_workspace(
    *,
    workspace_root: str,
    profile_path: str,
    metadata: PathMetadataReader,
    read_bytes: WorkspaceBytes,
    catalog: SchemaCatalog,
    repository: RepositoryReader | None = None,
) -> CapturedWorkspace:
    """Capture complete bytes and stable non-following metadata through the loader.

    Each call is fresh. Readers are injected; errors propagate before any mutation.
    The catalog must be the trusted unextended core catalog accepted by the loader.
    """
    observed: dict[str, PathMetadata] = {}

    def inspect(path: str) -> PathMetadata:
        """Record stable directory/file identities while the loader checks reads."""
        value = metadata(path)
        value = replace(value, children=tuple(sorted(value.children)))
        if observed.setdefault(path, value) != value:
            raise OSError("Metadata changed during workspace capture")
        return value

    snapshot = load_snapshot(
        io=SnapshotIO(
            workspace_root=workspace_root, metadata=inspect, read_bytes=read_bytes
        ),
        profile_path=profile_path,
        repository=repository,
        catalog=catalog,
    )
    return CapturedWorkspace(
        workspace_root=workspace_root,
        snapshot=snapshot,
        metadata=tuple(observed.items()),
    )


class MutationWriter(Protocol):
    """Supply a trusted local boundary; clients cannot provide implementations.

    atomic_write must guard the entire expected input set and metadata together
    with path revalidation and the write: exclusive create when original digest
    is null, otherwise digest-matched atomic replacement. Reject links and newly
    colliding entries, create missing parents exclusively, and preserve unrelated
    bytes. No unchecked ordinary overwrite is a conforming implementation.
    An OSError may follow an uncertain commit; the result reports that explicitly.
    """

    def capture(self) -> CapturedWorkspace:
        """Return a fresh complete capture, with no persistent read cache."""
        ...

    def invalidate_authority(self) -> None:
        """Revoke existing completion authority before any attempted artifact write.

        Raise OSError on failure; no write may proceed after that failure.
        """
        ...

    def atomic_write(self, write: PlannedWrite, *, expected: CapturedWorkspace) -> None:
        """Check complete expected state under the write guard, then commit one file."""
        ...


class MutationPrimitives(Protocol):
    """Provide guarded non-following publication; unavailable guarantees fail closed.

    The workspace guard serializes every authorized mutator. Native enforcement
    must deny analysts other mutation routes. Primitives anchor parent handles,
    exclusively create missing parents and atomically publish complete bytes.
    """

    def guard(self) -> AbstractContextManager[None]:
        """Exclude authorized workspace mutations until context exit."""
        ...

    def create_exclusive(self, target: ResolvedPath, content: bytes) -> None:
        """Publish a new file without replacing any existing entry."""
        ...

    def replace_if_digest(
        self, target: ResolvedPath, content: bytes, *, expected_sha256: str
    ) -> None:
        """Atomically replace only bytes matching the guarded original digest."""
        ...


class GuardedMutationWriter:
    """Own complete-state/CAS sequencing; the service only wires its collaborators."""

    def __init__(
        self,
        *,
        capture: Callable[[], CapturedWorkspace],
        invalidate_authority: Callable[[], None],
        primitives: MutationPrimitives,
    ) -> None:
        """Bind trusted I/O without performing reads or acquiring permission."""
        self._capture = capture
        self._invalidate = invalidate_authority
        self._primitives = primitives

    def capture(self) -> CapturedWorkspace:
        """Reload all relevant bytes and identities for this operation."""
        return self._capture()

    def invalidate_authority(self) -> None:
        """Revoke prior receipts through the separately protected native store."""
        self._invalidate()

    def atomic_write(self, write: PlannedWrite, *, expected: CapturedWorkspace) -> None:
        """Check complete state and target under exclusion, then publish once."""
        with self._primitives.guard():
            current = self.capture()
            _same_state(expected, current)
            if write.transport is not None:
                write.transport.revalidate(
                    catalog=current.snapshot.catalog,
                    limits=current.snapshot.profile.limits.parse_limits(),
                )
                write.transport.check(
                    cast("WriteGrant", write.target.grant), write.change.content
                )
            PathPolicy(
                current.snapshot.profile,
                workspace_root=current.workspace_root,
                metadata=current.inspect,
                transport=write.transport,
            ).revalidate_write(write.target)
            # Compare the original bytes inside exclusion before selecting a primitive.
            prior = next(
                (
                    item
                    for item in current.snapshot.manifest.files
                    if item.path == write.change.path
                ),
                None,
            )
            digest = prior.sha256 if prior is not None else None
            if digest != write.change.expected_sha256:
                raise MutationError("MUTATION_PRECONDITION", "Guarded original differs")
            if write.transport is not None and prior is not None:
                raise MutationError(
                    "MUTATION_TRANSPORT", "Transport publication requires absence"
                )
            # Absence permits only exclusive creation; existing bytes require
            # replacement CAS.
            if digest is None:
                self._primitives.create_exclusive(write.target, write.change.content)
            else:
                self._primitives.replace_if_digest(
                    write.target,
                    write.change.content,
                    expected_sha256=digest,
                )
            _after_write(current, self.capture(), write)


@dataclass(frozen=True, kw_only=True)
class MutationArtifact:
    """Report an exact output and its operation disposition, never authority."""

    path: str
    artifact_kind: str
    artifact_id: str
    sha256: str
    status: Literal["planned", "created", "updated", "skipped", "conflict"]


@dataclass(frozen=True, kw_only=True)
class MutationResult:
    """Report complete or bounded partial execution without minting a receipt.

    On a failed write, uncertain_paths identifies the attempted file and possible
    newly created parents. Prior successful outputs remain explicit. Callers must
    reload after any failure; even ok results require separate native validation.
    """

    ok: bool
    artifacts: tuple[MutationArtifact, ...]
    findings: tuple[Finding, ...]
    validation: SnapshotValidation
    authority_invalidated: bool
    uncertain_paths: tuple[str, ...] = ()


def _artifact(
    write: PlannedWrite,
    status: Literal["planned", "created", "updated", "skipped", "conflict"],
) -> MutationArtifact:
    """Project exact intended bytes and a status; perform no external operation."""
    from hashlib import sha256

    value = write.change
    return MutationArtifact(
        path=value.path,
        artifact_kind=value.artifact_kind,
        artifact_id=value.artifact_id,
        sha256=sha256(value.content).hexdigest(),
        status=status,
    )


def _same_state(expected: CapturedWorkspace, current: CapturedWorkspace) -> None:
    """Reject changed hashes, complete input sets, pins and metadata identities."""
    if (
        current.workspace_root != expected.workspace_root
        or current.snapshot.sha256 != expected.snapshot.sha256
        or current.metadata != expected.metadata
    ):
        raise MutationError("MUTATION_STALE", "Complete input state changed; reload")


def _after_write(
    expected: CapturedWorkspace, current: CapturedWorkspace, write: PlannedWrite
) -> None:
    """Accept only the committed file and its exclusively created parents as effects."""
    projected = project_snapshot(expected, (write.change,))
    if (
        current.workspace_root != expected.workspace_root
        or current.snapshot.sha256 != projected.sha256
    ):
        raise MutationError(
            "MUTATION_POSTCONDITION", "Committed input bytes differ from the plan"
        )
    path = write.change.path
    # Existing ancestors and unrelated files must retain their physical identities.
    for name, old in expected.metadata:
        new = current.inspect(name)
        if name == path or old.kind == "missing" and path.startswith(name + "/"):
            continue
        if (old.kind, old.identity, old.resolved_path) != (
            new.kind,
            new.identity,
            new.resolved_path,
        ):
            raise MutationError(
                "MUTATION_POSTCONDITION", "An unrelated input identity changed"
            )
    # Reusing the path policy rejects links/aliases even in newly created parents.
    PathPolicy(
        current.snapshot.profile,
        workspace_root=current.workspace_root,
        metadata=current.inspect,
        transport=write.transport,
    ).resolve_write(path, grant=cast("WriteGrant", write.target.grant))


def commit_mutation(
    plan: MutationPlan, *, writer: MutationWriter, dry_run: bool = False
) -> MutationResult:
    """Recheck a plan and apply deterministic guarded writes, stopping at first failure.

    Dry-run performs fresh reads but no writes, directory creation or invalidation.
    Invalid/reconstructed plans raise before I/O. Operational failures return one
    actionable finding, prior completed outputs and explicit uncertain paths.
    """
    # Reconstruction revalidates every requested byte instead of trusting result flags.
    rebuilt = plan_mutation(
        plan.baseline,
        tuple(write.change for write in plan.writes),
        grants=plan.grants,
        invocation=plan.invocation,
        transport=plan.transport,
    )
    if (
        rebuilt.writes != plan.writes
        or rebuilt.prospective.sha256 != plan.prospective.sha256
        or rebuilt.prospective.artifacts != plan.prospective.artifacts
        or rebuilt.validation != plan.validation
    ):
        raise MutationError(
            "MUTATION_PLAN", "Plan fields differ from their validated reconstruction"
        )
    outputs: list[MutationArtifact] = []
    revoked = False
    attempted: PlannedWrite | None = None
    expected = plan.baseline
    try:
        _same_state(expected, writer.capture())
        # Dry-run reports intended dispositions without invalidating current authority.
        if dry_run:
            # Preserve canonical output order so repeated dry-runs compare identically.
            return MutationResult(
                ok=True,
                artifacts=tuple(
                    _artifact(write, "skipped" if write.skipped else "planned")
                    for write in plan.writes
                ),
                findings=(),
                validation=plan.validation,
                authority_invalidated=False,
            )
        # Stop on the first failed guard/write; do not roll back over concurrent edits.
        for write in plan.writes:
            _same_state(expected, writer.capture())
            # Same bytes require no publication but still require the complete freshness
            # check.
            if write.skipped:
                outputs.append(_artifact(write, "skipped"))
                continue
            # Revoke once before the first attempted write, including later partial
            # failure.
            if not revoked:
                writer.invalidate_authority()
                revoked = True
            policy = PathPolicy(
                expected.snapshot.profile,
                workspace_root=expected.workspace_root,
                metadata=writer.capture().inspect,
                transport=write.transport,
            )
            target = policy.resolve_write(
                write.change.path, grant=cast("WriteGrant", write.target.grant)
            )
            # The adapter repeats complete freshness and these path checks atomically.
            current_write = PlannedWrite(
                change=write.change,
                target=target,
                skipped=False,
                transport=write.transport,
            )
            attempted = current_write
            writer.atomic_write(current_write, expected=expected)
            current = writer.capture()
            _after_write(expected, current, current_write)
            expected = current
            outputs.append(
                _artifact(
                    write,
                    "created" if write.change.expected_sha256 is None else "updated",
                )
            )
            attempted = None
        _same_state(expected, writer.capture())
        checked = validate_snapshot(
            expected.snapshot, mode=plan.validation.mode, invocation=plan.invocation
        )
        if not checked.ok or expected.snapshot.sha256 != plan.prospective.sha256:
            raise MutationError(
                "MUTATION_POSTCONDITION",
                "Final committed graph differs from the validated plan",
            )
        return MutationResult(
            ok=True,
            artifacts=tuple(outputs),
            findings=(),
            validation=checked,
            authority_invalidated=revoked,
        )
    except (OSError, ValueError) as error:
        # Stale state revokes old authority; failed revocation remains visible.
        if not dry_run and not revoked:
            try:
                writer.invalidate_authority()
                revoked = True
            except OSError as invalidation_error:
                error = OSError(
                    f"{error}; authority invalidation failed: {invalidation_error}"
                )
        uncertain: tuple[str, ...] = ()
        if attempted is not None:
            # Report the file and every possibly created ancestor, retaining prior
            # successes.
            uncertain = tuple(
                sorted(
                    {
                        attempted.change.path,
                        *(
                            stamp.path
                            for stamp in attempted.target.observations
                            if stamp.kind == "missing"
                        ),
                    }
                )
            )
            outputs.append(_artifact(attempted, "conflict"))
        finding = Finding(
            code="MUTATION_FAILED",
            message=str(error),
            next_action=(
                "Reload all inputs, inspect partial/uncertain paths, "
                "and revalidate before retrying."
            ),
        )
        return MutationResult(
            ok=False,
            artifacts=tuple(outputs),
            findings=(finding,),
            validation=plan.validation,
            authority_invalidated=revoked,
            uncertain_paths=uncertain,
        )
