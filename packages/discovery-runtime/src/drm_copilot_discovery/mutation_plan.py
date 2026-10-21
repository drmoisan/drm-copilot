"""Plan exact artifact mutations over captured bytes without filesystem writes.

Callers authenticate principals/grants before this boundary. The immutable values
below cannot mint native authority. The accepted loader and validator determine
the prospective graph; the overlay only supplies bytes and directory metadata.
"""

from __future__ import annotations

import re
from dataclasses import dataclass, replace
from pathlib import PurePosixPath, PureWindowsPath
from typing import TYPE_CHECKING, cast

from drm_copilot_discovery.agent_output import REPORT_KINDS
from drm_copilot_discovery.catalog import SchemaCatalog
from drm_copilot_discovery.path_models import (
    PathMetadata,
    WriteGrant,
    check_path_collisions,
    relative_path,
)
from drm_copilot_discovery.path_policy import PathPolicy
from drm_copilot_discovery.report_models import ReportBudget, ReportLimitError
from drm_copilot_discovery.snapshot_io import SnapshotIO
from drm_copilot_discovery.snapshot_loading import load_snapshot
from drm_copilot_discovery.validation import validate_snapshot

if TYPE_CHECKING:
    from drm_copilot_discovery.agent_output import InvocationContext
    from drm_copilot_discovery.findings import Finding
    from drm_copilot_discovery.path_models import ResolvedPath
    from drm_copilot_discovery.repository_reader import (
        RepositoryFile,
        RepositoryIdentity,
    )
    from drm_copilot_discovery.snapshot import DiscoverySnapshot
    from drm_copilot_discovery.transport_manifest import TransportRoute
    from drm_copilot_discovery.validation import SnapshotValidation


class MutationError(ValueError):
    """Retain a stable failure code and original validation findings; perform no I/O."""

    def __init__(
        self, code: str, message: str, *, findings: tuple[Finding, ...] = ()
    ) -> None:
        """Expose actionable errors without converting them into write permission."""
        self.code, self.findings = code, findings
        super().__init__(f"{code}: {message}")


@dataclass(frozen=True, kw_only=True)
class MutationChange:
    """Request immutable whole-document bytes under one exact original precondition.

    A null expected_sha256 requires absence; equal bytes become a skipped write.
    Identity fields are requests, never grants. No deletion or patch is supported.
    """

    artifact_kind: str
    artifact_id: str
    path: str
    content: bytes
    expected_sha256: str | None

    def __post_init__(self) -> None:
        """Reject unsafe identities, mutable content and malformed original digests."""
        WriteGrant(
            artifact_kind=self.artifact_kind,
            artifact_id=self.artifact_id,
            path=self.path,
        )
        if not isinstance(cast("object", self.content), bytes):
            raise ValueError("Mutation content must be immutable bytes")
        if (
            self.expected_sha256 is not None
            and re.fullmatch(r"[0-9a-f]{64}", self.expected_sha256) is None
        ):
            raise ValueError("Expected SHA-256 must be lowercase hexadecimal or null")


@dataclass(frozen=True, kw_only=True)
class CapturedWorkspace:
    """Bind a complete snapshot to non-following metadata captured during its load.

    Construct through trusted capture. Complete metadata resolves proposed absence;
    supplemental_paths names only retained originals. No cache/authority is created.
    """

    workspace_root: str
    snapshot: DiscoverySnapshot
    metadata: tuple[tuple[str, PathMetadata], ...]
    supplemental_paths: tuple[str, ...] = ()

    def __post_init__(self) -> None:
        """Validate typed metadata/selected originals; return None without I/O.

        ValueError rejects ambiguity; ReportLimitError rejects excess. Only this
        frozen value's normalized tuple fields change, never input collections.
        """
        entries = tuple(sorted(self.metadata))
        # A complete capture has one authoritative observation for each path.
        if len({path for path, _ in entries}) != len(entries) or not any(
            path == "." for path, _ in entries
        ):
            raise ValueError(
                "Captured metadata requires unique paths and a workspace root"
            )
        object.__setattr__(self, "metadata", entries)
        if type(self.supplemental_paths) is not tuple:
            raise ValueError("Supplemental originals require an immutable selection")
        # Explicit originals supplement captures without becoming profile roots.
        if self.supplemental_paths:
            limits = self.snapshot.profile.limits
            budget = ReportBudget(limits.parse_limits())
            if len(self.supplemental_paths) > limits.source_files:
                raise ReportLimitError()
            budget.work(len(self.snapshot.manifest.files) + len(entries))
            files = {}
            # Prepay each path before indexing it for exact original selection.
            for file in self.snapshot.manifest.files:
                budget.work((len(file.path) + 1) * (32 + 4 * limits.nesting_depth))
                files[file.path] = file
            metadata = dict(entries)
            # Every marker names an already captured ordinary original, never absence.
            for path in self.supplemental_paths:
                if type(path) is not str:
                    raise ValueError("Supplemental original requires an exact path")
                budget.work((len(path) + 1) * (32 + 4 * limits.nesting_depth))
                if path not in files or path not in metadata:
                    raise ValueError("Supplemental original is not captured")
                if metadata[path].kind != "file":
                    raise ValueError("Supplemental original must be an ordinary file")
            paths = check_path_collisions(self.supplemental_paths)
            object.__setattr__(self, "supplemental_paths", paths)

    def inspect(self, path: str) -> PathMetadata:
        """Read captured metadata or prove absence from its complete parent listing.

        Raise OSError for uncaptured existing entries; never invent their identity.
        """
        entries = dict(self.metadata)
        if path in entries:
            return entries[path]
        parts = relative_path(path).split("/")
        # Walk complete captured namespaces until absence is established.
        for index, name in enumerate(parts):
            parent = entries.get("/".join(parts[:index]) or ".")
            if parent is None or parent.kind == "missing":
                return PathMetadata(kind="missing")
            if parent.kind != "directory":
                raise OSError("An input ancestor is not a directory")
            if name not in parent.children:
                return PathMetadata(kind="missing")
            if "/".join(parts[: index + 1]) not in entries:
                raise OSError("Existing input metadata was not captured")
        raise OSError("Input metadata is incomplete")


@dataclass(frozen=True, kw_only=True)
class PlannedWrite:
    """Bind one checked request to its observed target and unchanged-byte status."""

    change: MutationChange
    target: ResolvedPath
    skipped: bool
    transport: TransportRoute | None = None


@dataclass(frozen=True, kw_only=True)
class MutationPlan:
    """Keep a validated prospective graph and exact original capture for commit.

    Plans are internal Python values, not trusted serialized client input. Commit
    rebuilds this value before using it and authenticating the adapter separately.
    """

    baseline: CapturedWorkspace
    writes: tuple[PlannedWrite, ...]
    grants: tuple[WriteGrant, ...]
    prospective: DiscoverySnapshot
    validation: SnapshotValidation
    invocation: InvocationContext | None = None
    transport: TransportRoute | None = None


class _PinnedReader:
    """Replay captured Git objects without any new repository/process access."""

    def __init__(
        self, snapshot: DiscoverySnapshot, checkout: RepositoryIdentity
    ) -> None:
        """Retain only immutable previously inspected repository bytes."""
        self.snapshot = snapshot
        self.checkout = checkout

    def identity(self) -> RepositoryIdentity:
        """Return the captured checkout without discovering another repository."""
        return self.checkout

    def read_file(self, *, revision: str, path: str, limit: int) -> RepositoryFile:
        """Return an exactly pinned captured blob or require a new complete capture."""
        # A new reference cannot introduce an uninspected Git object during planning.
        for item in self.snapshot.repository_files:
            if item.path == path and item.repository.revision == revision:
                if len(item.content) > limit:
                    raise OSError("Captured Git object exceeds the read limit")
                return item
        raise OSError("Pinned object was not captured; reload the requested inputs")


class _Overlay:
    """Supply a transient byte/metadata overlay to the existing complete loader.

    It creates no files and interprets no artifact semantics. Synthetic identities
    describe projected new paths only and must never be used as native stamps.
    """

    def __init__(
        self, baseline: CapturedWorkspace, changes: tuple[MutationChange, ...]
    ) -> None:
        """Copy captured values and overlay exact requested files plus their parents."""
        self.baseline = baseline
        self.entries = dict(baseline.metadata)
        # Reuse exactly the captured bytes; a projection cannot discover new inputs.
        self.files = {
            item.path: item.content for item in baseline.snapshot.manifest.files
        }
        # Preserve the caller's path model without consulting the native filesystem.
        root = (
            PureWindowsPath(baseline.workspace_root)
            if ":" in baseline.workspace_root
            or baseline.workspace_root.startswith("\\\\")
            else PurePosixPath(baseline.workspace_root)
        )
        # Add only ancestors of checked output paths; leave every other entry intact.
        for change in changes:
            parts = change.path.split("/")
            # Materialize only absent ancestors needed by this particular output.
            for length, name in enumerate(parts, 1):
                parent = "/".join(parts[: length - 1]) or "."
                path = "/".join(parts[:length])
                entry = self.entries[parent]
                self.entries[parent] = replace(
                    entry, children=tuple(sorted(set((*entry.children, name))))
                )
                prior = self.entries.get(path, PathMetadata(kind="missing"))
                # Existing identities are retained; only projected additions are
                # synthetic.
                if prior.kind == "missing":
                    self.entries[path] = PathMetadata(
                        kind="file" if length == len(parts) else "directory",
                        identity="projected:" + path,
                        resolved_path=root.joinpath(*parts[:length]).as_posix(),
                    )
            self.files[change.path] = change.content

    def inspect(self, path: str) -> PathMetadata:
        """Read projected metadata, retaining captured absence for other paths."""
        return self.entries.get(path) or self.baseline.inspect(path)

    def read(self, path: str, *, limit: int) -> bytes:
        """Return only captured/proposed bytes within the loader's finite ceiling."""
        if path not in self.files or len(self.files[path]) > limit:
            raise OSError("Input is uncaptured or exceeds its byte limit")
        return self.files[path]


def project_snapshot(
    baseline: CapturedWorkspace, changes: tuple[MutationChange, ...]
) -> DiscoverySnapshot:
    """Load complete proposed inputs from memory with the authoritative classifier.

    baseline (CapturedWorkspace) and changes (tuple[MutationChange, ...]) produce
    DiscoverySnapshot with exact marked originals. ValueError/OSError propagate;
    no I/O, input mutation or authority occurs. Empty selection keeps loader behavior.
    """
    overlay = _Overlay(baseline, changes)
    original = baseline.snapshot
    # Rebuild extension bindings through the accepted loader while replaying pinned
    # bytes.
    projected = load_snapshot(
        io=SnapshotIO(
            workspace_root=baseline.workspace_root,
            metadata=overlay.inspect,
            read_bytes=overlay.read,
            max_entries=original.profile.limits.source_files,
            max_depth=original.profile.limits.nesting_depth,
        ),
        profile_path=original.profile.artifacts["profile"],
        repository=(
            _PinnedReader(original, original.checkout)
            if original.checkout is not None
            else None
        ),
        catalog=(
            SchemaCatalog(documents=original.catalog.documents)
            if original.catalog.extensions
            else original.catalog
        ),
    )
    if not baseline.supplemental_paths:
        return projected
    limits = original.profile.limits
    budget = ReportBudget(limits.parse_limits())
    loaded = projected.manifest.files
    budget.work(len(original.manifest.files) + len(loaded) + len(changes))
    count = len(loaded)
    remaining = limits.document_bytes - sum(len(file.content) for file in loaded)
    # Reserve complete retained-byte/hash and path/index/sort work before merging.
    for file in (*original.manifest.files, *loaded):
        budget.work(
            8 * len(file.content)
            + (len(file.path) + 1) * (32 + 4 * limits.nesting_depth)
        )
    files = {file.path: file for file in loaded}
    originals = {file.path: file for file in original.manifest.files}
    writes = {change.path for change in changes}
    absent = set(projected.manifest.missing_paths)
    # Loader classifications win on identical overlap; marked originals never change.
    for path in baseline.supplemental_paths:
        old = originals[path]
        if (
            path in writes
            or path in absent
            or path in files
            and files[path].content != old.content
        ):
            raise MutationError(
                "MUTATION_ORIGINAL", "Selected migration original changed"
            )
        if path not in files:
            count += 1
            remaining -= len(old.content)
    if count > min(limits.source_files, limits.artifact_records) or remaining < 0:
        raise ReportLimitError()
    # Retain only after exact merged capacity passes; overlaps consume one slot.
    for path in baseline.supplemental_paths:
        files.setdefault(path, originals[path])
    return replace(
        projected, manifest=replace(projected.manifest, files=tuple(files.values()))
    )


def plan_mutation(
    baseline: CapturedWorkspace,
    changes: tuple[MutationChange, ...],
    *,
    grants: tuple[WriteGrant, ...],
    invocation: InvocationContext | None = None,
    transport: TransportRoute | None = None,
) -> MutationPlan:
    """Validate all prospective bytes before returning an immutable commit plan.

    Grants and optional native invocation must be authenticated by the caller.
    Absence of invocation is the explicit local-user/root route, not an analyst
    fallback. Invalid requests raise MutationError/ValueError/OSError; no writes
    or authority-store operations occur, including during repeated dry runs.
    """
    if not changes or len(changes) > baseline.snapshot.profile.limits.artifact_records:
        raise MutationError("MUTATION_LIMIT", "Provide a bounded nonempty change set")
    changes = tuple(sorted(changes, key=lambda item: item.path))
    if transport is not None:
        if invocation is not None:
            raise MutationError(
                "MUTATION_TRANSPORT", "Transport is a root-only operation"
            )
        transport.revalidate(
            catalog=baseline.snapshot.catalog,
            limits=baseline.snapshot.profile.limits.parse_limits(),
        )
        members = {member.grant for member in transport.members}
        if (
            set(grants) != members
            or len(grants) != len(members)
            or {item.path for item in changes} != {grant.path for grant in members}
        ):
            raise MutationError(
                "MUTATION_TRANSPORT",
                "Require the exact complete transport grants and members",
            )
        # The header is published only after every complete immutable member exists.
        changes = tuple(
            sorted(
                changes,
                key=lambda item: (item.path == transport.manifest.path, item.path),
            )
        )
    # Reject platform aliases before mapping exact requested identities to grants.
    check_path_collisions(item.path for item in changes)
    # Grants also require unique paths; dictionary insertion must not discard authority.
    check_path_collisions(grant.path for grant in grants)
    # Index authenticated capabilities independently from caller-proposed changes.
    permitted = {grant.path: grant for grant in grants}
    # Original bytes and parsed identities remain separate preconditions.
    files = {item.path: item for item in baseline.snapshot.manifest.files}
    # Imported artifact identities cannot be overwritten as locally authored records.
    originals = {item.path: item for item in baseline.snapshot.artifacts}
    policy = PathPolicy(
        baseline.snapshot.profile,
        workspace_root=baseline.workspace_root,
        metadata=baseline.inspect,
        transport=transport,
    )
    if invocation is not None and (
        invocation.baseline.sha256 != baseline.snapshot.sha256
        or invocation.workspace.get("workspace_root") != baseline.workspace_root
    ):
        raise MutationError("MUTATION_CONTEXT", "Invocation baseline/workspace differs")
    writes: list[PlannedWrite] = []
    # Exact trusted grants and original-byte preconditions precede any projection.
    for change in changes:
        grant = permitted.get(change.path)
        if grant is None or grant != WriteGrant(
            artifact_kind=change.artifact_kind,
            artifact_id=change.artifact_id,
            path=change.path,
        ):
            raise MutationError("MUTATION_GRANT", "No exact kind/ID/path write grant")
        prior = files.get(change.path)
        if transport is not None:
            transport.check(grant, change.content)
            if prior is not None and prior.content != change.content:
                raise MutationError(
                    "MUTATION_TRANSPORT", "Immutable snapshot bytes cannot be replaced"
                )
        if change.expected_sha256 != (prior.sha256 if prior else None):
            raise MutationError(
                "MUTATION_PRECONDITION", "Original content digest differs"
            )
        original = originals.get(change.path)
        if original is not None and (
            original.expected_kind != change.artifact_kind
            or original.origin_path is not None
            and transport is None
            or original.document is not None
            and original.document.get("id") != change.artifact_id
        ):
            raise MutationError(
                "MUTATION_IDENTITY", "Existing artifact identity differs"
            )
        if len(change.content) > baseline.snapshot.profile.limits.document_bytes:
            raise MutationError(
                "MUTATION_LIMIT", "Proposed content exceeds document limit"
            )
        writes.append(
            PlannedWrite(
                change=change,
                target=policy.resolve_write(change.path, grant=grant),
                skipped=prior is not None and prior.content == change.content,
                transport=transport,
            )
        )
    prospective = project_snapshot(baseline, changes)
    # Only loader-classified artifacts establish the proposed structured identities.
    artifacts = {item.path: item for item in prospective.artifacts}
    # Loader-derived kinds and document IDs must agree with granted output identities.
    for change in changes:
        artifact = artifacts.get(change.path)
        opaque = (
            change.artifact_kind == "evidence-payload"
            and prospective.file(change.path).category == "evidence"
            or change.artifact_kind == "acceptance-view"
            and change.path.endswith((".md", ".feature"))
        )
        # A Markdown report view must name the same kind/ID as its structured peer.
        if change.artifact_kind in REPORT_KINDS and change.path.endswith(".md"):
            artifact = artifacts.get(change.path[:-3] + ".json")
        if artifact is None and opaque:
            continue
        if (
            artifact is None
            or artifact.expected_kind != change.artifact_kind
            or artifact.document is None
            or artifact.document.get("id") != change.artifact_id
        ):
            raise MutationError(
                "MUTATION_IDENTITY", "Proposed artifact kind/ID differs"
            )
    validation = validate_snapshot(
        prospective,
        mode="agent-output" if invocation else "structural",
        invocation=invocation,
    )
    if not validation.ok:
        raise MutationError(
            "MUTATION_INVALID",
            "Prospective graph is invalid",
            findings=validation.findings,
        )
    return MutationPlan(
        baseline=baseline,
        writes=tuple(writes),
        grants=tuple(grants),
        prospective=prospective,
        validation=validation,
        invocation=invocation,
        transport=transport,
    )
