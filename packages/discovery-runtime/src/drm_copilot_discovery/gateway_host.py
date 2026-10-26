"""Compose host-principal discovery over verified protected records.

The host gateway binds one trusted outer principal (host, session, agent id and
role) and the request's invocation reference to the protected partition the
native adapters wrote, verifies every record through ``protected_records``,
reconstructs the pre-invocation baseline the root pinned, and returns a ``host``
ServiceAuthority bound to that invocation. It reads the protected store through
injected seams, never writes to it, never returns a local-user authority, and
refuses every incomplete, mismatched, stale, replayed or unverifiable request
with exit 3.
"""

from __future__ import annotations

import os
from dataclasses import dataclass, replace
from hashlib import sha256
from pathlib import Path
from typing import TYPE_CHECKING, Protocol, cast

from drm_copilot_discovery.activation_filesystem import RegistryLocation
from drm_copilot_discovery.activation_store import ActivationStore
from drm_copilot_discovery.agent_output import InvocationContext
from drm_copilot_discovery.build_identity import load_build_identity
from drm_copilot_discovery.catalog import SchemaCatalog, load_catalog
from drm_copilot_discovery.findings import Finding
from drm_copilot_discovery.gateway_local import (
    canonical_state_location,
    installed_platform,
    recapture_workspace,
)
from drm_copilot_discovery.init_io import InitializationIO
from drm_copilot_discovery.models import JsonObject, ParseLimits
from drm_copilot_discovery.mutation_io import GuardedMutationWriter, capture_workspace
from drm_copilot_discovery.mutation_plan import (
    CapturedWorkspace,
    MutationChange,
    project_snapshot,
)
from drm_copilot_discovery.operations import OperationFailure
from drm_copilot_discovery.path_models import PathMetadata, PathPolicyError, WriteGrant
from drm_copilot_discovery.path_policy import PathPolicy, workspace_identity
from drm_copilot_discovery.protected_records import (
    TrustedIdentity,
    WorkspaceBinding,
    decode_authorization,
    decode_baseline_result,
    decode_capability_attestation,
    decode_invocation,
    decode_start_attestation,
    refusal,
)
from drm_copilot_discovery.service_contracts import ServiceAuthority
from drm_copilot_discovery.service_request_rules import CONTROLLED_OPERATIONS
from drm_copilot_discovery.snapshot_io import SnapshotIO
from drm_copilot_discovery.snapshot_loading import load_snapshot
from drm_copilot_discovery.source_read_models import ReadGrant, ReadSelection

if TYPE_CHECKING:
    from collections.abc import Callable

    from drm_copilot_discovery.doctor import CapabilityObservation
    from drm_copilot_discovery.repository_reader import RepositoryReader
    from drm_copilot_discovery.service_contracts import RuntimeIdentity, ServiceRequest
    from drm_copilot_discovery.snapshot import DiscoverySnapshot

SESSION_PARTITION = "sessions"
INVOCATION_PARTITION = "invocations"
AUTHORIZATIONS_PARTITION = "authorizations"
INVOCATION_FILE = "invocation.json"
START_ATTESTATION_FILE = "start-attestation.json"
BASELINE_RESULT_FILE = "baseline-result.json"
CAPABILITY_ATTESTATION_FILE = "capability-attestation.json"
CONSUMED_LATCH_SUFFIX = ".consumed"
RECORD_BYTE_LIMIT = 16777216


class HostStoreIO(Protocol):
    """Read-only seams over the protected authority store; nothing here writes."""

    def read_text(self, path: str) -> str | None:
        """Return the UTF-8 text at path, or None when the entry does not exist."""
        ...

    def list_entries(self, directory: str) -> tuple[str, ...]:
        """Return the immediate entry names of directory; empty when absent."""
        ...

    def exists(self, path: str) -> bool:
        """Return whether an entry exists at path without reading it."""
        ...


@dataclass(frozen=True, kw_only=True)
class HostPrincipal:
    """Carry the host-verified process identity the gateway received as options.

    The invocation is not part of the principal: each request names its own
    invocation reference, which authorize binds to the protected record.
    """

    host: str
    session_id: str
    agent_id: str
    role: str

    def identity(self, invocation_id: str) -> TrustedIdentity:
        """Return the TrustedIdentity of this principal for invocation_id (str)."""
        return TrustedIdentity(
            host=self.host,
            session_id=self.session_id,
            agent_id=self.agent_id,
            role=self.role,
            invocation_id=invocation_id,
        )


def partition_name(correlation_id: str) -> str:
    """Return the digest partition of correlation_id (str), as the hosts derive it."""
    return sha256(correlation_id.encode("utf-8")).hexdigest()


def session_directory(location: RegistryLocation, session_id: str) -> str:
    """Return `<directory>/sessions/<sha256(session_id)>` for location."""
    return f"{location.directory}/{SESSION_PARTITION}/{partition_name(session_id)}"


def invocation_directory(
    location: RegistryLocation, session_id: str, invocation_id: str
) -> str:
    """Return `<session>/invocations/<sha256(invocation_id)>` for location."""
    session = session_directory(location, session_id)
    return f"{session}/{INVOCATION_PARTITION}/{partition_name(invocation_id)}"


def _drift(path: str, message: str) -> OperationFailure:
    """Return the exit-3 baseline failure for path (str) with message (str)."""
    return OperationFailure(
        "SERVICE_BASELINE",
        exit_code=3,
        findings=(
            Finding(
                code="SERVICE_BASELINE",
                artifact_path=path,
                pointer="/inputs",
                message=message,
                next_action="Prepare the invocation again from the current inputs.",
            ),
        ),
    )


def _rows(value: object) -> tuple[JsonObject, ...]:
    """Return value as a tuple of JsonObject rows; refuse any other shape."""
    if not isinstance(value, tuple):
        raise refusal("A protected record row list is malformed.")
    rows = cast("tuple[object, ...]", value)
    if any(type(row) is not JsonObject for row in rows):
        raise refusal("A protected record row list is malformed.")
    return cast("tuple[JsonObject, ...]", rows)


def required_rows(invocation: JsonObject) -> tuple[JsonObject, ...]:
    """Return the required-output rows of the verified invocation record."""
    manifest = invocation.get("required_outputs")
    if type(manifest) is not JsonObject:
        raise refusal("The invocation carries no required-output manifest.")
    return _rows(manifest.get("outputs"))


class _HiddenPaths:
    """Replay a capture with the named paths absent, without consulting the host.

    The loader sees the capture's metadata and bytes except for the hidden
    paths, which report absence and vanish from their parent's child names.
    """

    def __init__(self, capture: CapturedWorkspace, hidden: frozenset[str]) -> None:
        """Index capture's metadata and bytes with hidden (frozenset[str]) removed."""
        self.hidden, self.capture = hidden, capture
        self.files = {
            item.path: item.content
            for item in capture.snapshot.manifest.files
            if item.path not in hidden
        }
        self.entries: dict[str, PathMetadata] = {}
        # Drop hidden entries and their names from the parent listings only.
        for path, entry in capture.metadata:
            if path in hidden:
                continue
            prefix = "" if path == "." else path + "/"
            children = tuple(
                name for name in entry.children if prefix + name not in hidden
            )
            self.entries[path] = replace(entry, children=children)

    def inspect(self, path: str) -> PathMetadata:
        """Return hidden absence or the captured metadata for path (str)."""
        if path in self.hidden:
            return PathMetadata(kind="missing")
        return self.entries.get(path) or self.capture.inspect(path)

    def read(self, path: str, *, limit: int) -> bytes:
        """Return captured bytes for path within limit; hidden paths raise OSError."""
        content = self.files.get(path)
        if content is None or len(content) > limit:
            raise OSError("Input is hidden, uncaptured or exceeds its byte limit")
        return content


def _check_drift(
    capture: CapturedWorkspace, stored: JsonObject, required: frozenset[str]
) -> None:
    """Refuse when any non-output input differs from the stored baseline manifest."""
    manifest = stored.get("input_manifest")
    if type(manifest) is not JsonObject:
        raise _drift(".", "The baseline result carries no input manifest.")
    digests = {
        cast("str", entry["path"]): cast("str", entry["sha256"])
        for entry in _rows(manifest.get("entries"))
    }
    current = {item.path: item.sha256 for item in capture.snapshot.manifest.files}
    # Every non-output input must be byte-identical to the pinned baseline.
    for path, digest in current.items():
        if path not in required and digests.get(path) != digest:
            raise _drift(path, "An input changed after the invocation was prepared.")
    for path in digests:
        if path not in required and path not in current:
            raise _drift(
                path, "An input was removed after the invocation was prepared."
            )


def _pinned_content(path: str, pinned: JsonObject) -> bytes:
    """Return the stored output bytes of pinned (JsonObject) or raise the drift."""
    text = pinned.get("content")
    if type(text) is not str:
        raise _drift(path, "The baseline row carries no text content.")
    content = text.encode("utf-8")
    if sha256(content).hexdigest() != pinned.get("sha256"):
        raise _drift(path, "The baseline row digest differs from its content.")
    return content


def reconstruct_baseline(
    capture: CapturedWorkspace,
    invocation: JsonObject,
    stored: JsonObject,
    *,
    repository: RepositoryReader | None,
) -> DiscoverySnapshot:
    """Rebuild the pre-invocation snapshot from capture and the stored baseline.

    capture (CapturedWorkspace) is the current configured capture; invocation
    (JsonObject) is the verified record; stored (JsonObject) is the verified
    `prepare-agent` result. Every required-output path is replaced by the stored
    content or removed when the stored row is absent; every other captured path
    must match the stored input manifest digest, and every other stored path must
    still exist, or OperationFailure("SERVICE_BASELINE", exit_code=3) is raised.
    repository (RepositoryReader | None) repeats the capture's source pins.
    Returns the reconstructed DiscoverySnapshot; performs no host I/O.
    """
    rows = {cast("str", row["path"]): row for row in required_rows(invocation)}
    _check_drift(capture, stored, frozenset(rows))
    stored_rows = {
        cast("str", row["path"]): row
        for row in _rows(stored.get("artifacts"))
        if row.get("path") in rows
    }
    # Outputs return to their prepared state: stored content, or absence.
    hidden = frozenset(path for path in rows if path not in stored_rows)
    overlay = _HiddenPaths(capture, hidden)
    profile = capture.snapshot.profile
    base = load_snapshot(
        io=SnapshotIO(
            workspace_root=capture.workspace_root,
            metadata=overlay.inspect,
            read_bytes=overlay.read,
            max_entries=profile.limits.source_files,
            max_depth=profile.limits.nesting_depth,
        ),
        profile_path=profile.artifacts["profile"],
        repository=repository,
        catalog=(
            SchemaCatalog(documents=capture.snapshot.catalog.documents)
            if capture.snapshot.catalog.extensions
            else capture.snapshot.catalog
        ),
    )
    if not stored_rows:
        return base
    digests = {item.path: item.sha256 for item in base.manifest.files}
    # Pinned content replays over the current digest so projection accepts it.
    changes = tuple(
        MutationChange(
            artifact_kind=cast("str", rows[path]["artifact_kind"]),
            artifact_id=cast("str", rows[path]["id"]),
            path=path,
            content=_pinned_content(path, pinned),
            expected_sha256=digests.get(path),
        )
        for path, pinned in sorted(stored_rows.items())
    )
    rebuilt = CapturedWorkspace(
        workspace_root=capture.workspace_root,
        snapshot=base,
        metadata=tuple(overlay.entries.items()),
    )
    return project_snapshot(rebuilt, changes)


class HostServiceIO:
    """Bind one trusted host principal to verified protected records and local ports.

    Construct from the trusted ActivationStore, the exact RepositoryReader, the
    verified principal and a read-only store seam. Reads of the protected
    partition happen only inside authorize; the writer recaptures through the
    same bound ports as the local composition. Nothing here writes a receipt or a
    protected record, and no path constructs a local-user authority.
    """

    def __init__(
        self,
        *,
        activation: ActivationStore,
        repository: RepositoryReader | None,
        principal: HostPrincipal,
        store: HostStoreIO,
        runtime_identity: Callable[[], RuntimeIdentity] = load_build_identity,
    ) -> None:
        """Bind trusted ports and principal; return None without I/O.

        activation (ActivationStore): trusted activation store. repository
        (RepositoryReader | None): exact optional reader. principal
        (HostPrincipal): host, session, agent id and role the host verified.
        store (HostStoreIO): read-only protected store seams. runtime_identity
        (Callable[[], RuntimeIdentity]): verified installed identity provider.
        """
        self.principal, self._store = principal, store
        self._activation, self._runtime_identity = activation, runtime_identity
        self._verified: set[str] = set()
        self._initialization = InitializationIO(
            workspace_root=activation.location.workspace,
            catalog=activation.catalog,
            metadata=activation.metadata,
            read_bytes=activation.read_bytes,
            primitives=activation.primitives,
            open_directory=activation.open_directory,
            invalidate_authority=activation.invalidate_authority,
            repository=repository,
        )

    @property
    def activation(self) -> ActivationStore:
        """Return the exact trusted store; no observation or mutation occurs."""
        return self._activation

    @property
    def initialization(self) -> InitializationIO:
        """Return the bound initialization ports; no replacement reader is created."""
        return self._initialization

    def runtime_identity(self) -> RuntimeIdentity:
        """Return verified installed identity; propagate typed failure unchanged."""
        return self._runtime_identity()

    def capability_observation(self) -> CapabilityObservation | None:
        """Return None: doctor is not an admitted host operation."""
        return None

    def _matches_workspace(self, path: str) -> bool:
        """Compare path (str) to the bound root lexically; False when different."""
        try:
            return workspace_identity(path) == workspace_identity(
                self.initialization.workspace_root
            )
        except PathPolicyError:
            return False

    def _record(self, path: str) -> bytes:
        """Return the protected record bytes at path; absence raises OSError."""
        text = self._store.read_text(path)
        if text is None:
            raise OSError("Protected record is unavailable")
        return text.encode("utf-8")

    def _binding(self) -> WorkspaceBinding:
        """Return the activation selection every protected record must be bound to."""
        selection = self.activation.select(controlled=True)
        if selection.profile_path is None or selection.profile_bytes is None:
            raise refusal("Discovery is not active for this workspace.")
        return WorkspaceBinding(
            workspace_sha256=self.activation.location.workspace_sha256,
            profile_path=selection.profile_path,
            profile_sha256=sha256(selection.profile_bytes).hexdigest(),
        )

    def _verify(
        self,
        request: ServiceRequest,
        identity: TrustedIdentity,
        binding: WorkspaceBinding,
    ) -> tuple[JsonObject, JsonObject]:
        """Verify every protected record for request; return invocation and baseline.

        identity (TrustedIdentity) binds the principal to the request's invocation;
        binding (WorkspaceBinding) is the activation selection. Reads the
        invocation, start attestation, session capability, the consumed
        authorization named by the request and the pinned baseline result through
        the store seams, each validated and bound by protected_records. Any
        refusal propagates as exit 3; a missing record raises OSError.
        """
        runtime = self.runtime_identity()
        catalog, limits = self.initialization.catalog, ParseLimits()
        location = self.activation.location
        directory = invocation_directory(
            location, identity.session_id, identity.invocation_id
        )
        invocation = decode_invocation(
            self._record(f"{directory}/{INVOCATION_FILE}"),
            binding=binding,
            identity=identity,
            runtime=runtime,
            catalog=catalog,
            limits=limits,
        )
        decode_start_attestation(
            self._record(f"{directory}/{START_ATTESTATION_FILE}"),
            invocation=invocation,
            identity=identity,
            catalog=catalog,
            limits=limits,
        )
        session = session_directory(location, identity.session_id)
        decode_capability_attestation(
            self._record(f"{session}/{CAPABILITY_ATTESTATION_FILE}"),
            invocation=invocation,
            binding=binding,
            identity=identity,
            runtime=runtime,
            catalog=catalog,
            limits=limits,
        )
        reference = cast("str", request.authorization_ref)
        authorizations = f"{directory}/{AUTHORIZATIONS_PARTITION}"
        name = f"{reference}.json"
        # The grant must be an actual partition entry, never a path the request spells.
        if name not in self._store.list_entries(authorizations):
            raise refusal("No authorization record exists for the referenced grant.")
        decode_authorization(
            self._record(f"{authorizations}/{name}"),
            latch_present=self._store.exists(
                f"{authorizations}/{name}{CONSUMED_LATCH_SUFFIX}"
            ),
            invocation=invocation,
            identity=identity,
            operation=request.operation,
            authorization_ref=reference,
            catalog=catalog,
            limits=limits,
        )
        baseline = decode_baseline_result(
            self._record(f"{directory}/{BASELINE_RESULT_FILE}"),
            runtime=runtime,
            catalog=catalog,
            limits=limits,
        )
        return invocation, baseline

    def _capture(self, binding: WorkspaceBinding) -> CapturedWorkspace:
        """Capture the configured workspace through the bound ports for binding."""
        io = self.initialization
        return capture_workspace(
            workspace_root=io.workspace_root,
            profile_path=binding.profile_path,
            metadata=io.metadata,
            read_bytes=io.read_bytes,
            catalog=io.catalog,
            repository=io.repository,
        )

    def _read_selection(
        self,
        request: ServiceRequest,
        invocation: JsonObject,
        capture: CapturedWorkspace,
    ) -> ReadSelection:
        """Return the read grants for request within the invocation's selected paths.

        Every requested path must equal or lie beneath a `selected_paths` entry
        and resolve through PathPolicy.resolve_read; otherwise the refusal is raised.
        """
        selected = cast("tuple[str, ...]", invocation.get("selected_paths", ()))
        paths = cast("tuple[str, ...]", request.inputs.get("paths", ()))
        policy = PathPolicy(
            capture.snapshot.profile,
            workspace_root=capture.workspace_root,
            metadata=self.initialization.metadata,
        )
        grants: list[ReadGrant] = []
        # Each requested path needs both the invocation scope and configured read scope.
        for path in paths:
            if not any(
                path == root or path.startswith(root + "/") for root in selected
            ):
                raise refusal("The read is outside the invocation's selected paths.")
            try:
                target = policy.resolve_read(path)
            except PathPolicyError as error:
                raise refusal(
                    "The read is outside the configured input scope."
                ) from error
            grants.append(
                ReadGrant(
                    path=path, directory=target.observations[-1].kind == "directory"
                )
            )
        return ReadSelection(grants=tuple(grants))

    def authorize(
        self, request: ServiceRequest, *, baseline: CapturedWorkspace | None
    ) -> ServiceAuthority:
        """Return the host authority for request bound to the verified invocation.

        request (ServiceRequest) must select agent-output mode, name an invocation
        and a consumed authorization, and perform a controlled operation (the set
        includes finalize-agent). baseline (CapturedWorkspace | None) is the
        service capture, or None before capture, in which case this method
        captures through its own bound ports. Returns ServiceAuthority with
        principal host, the trusted agent id, the reconstructed InvocationContext,
        one WriteGrant per required output and a read selection for read-source.
        Raises OperationFailure (exit 3) for every refusal and OSError for an
        unreadable record; no write and no local-user authority is produced.
        """
        if (
            request.mode != "agent-output"
            or request.invocation_ref is None
            or request.authorization_ref is None
            or request.operation not in CONTROLLED_OPERATIONS
            or not self._matches_workspace(request.workspace_root)
            or (
                baseline is not None
                and not self._matches_workspace(baseline.workspace_root)
            )
        ):
            raise refusal("The request is not bound to a host invocation.")
        identity = self.principal.identity(request.invocation_ref)
        binding = self._binding()
        invocation, stored = self._verify(request, identity, binding)
        capture = baseline if baseline is not None else self._capture(binding)
        snapshot = reconstruct_baseline(
            capture, invocation, stored, repository=self.initialization.repository
        )
        grants = tuple(
            WriteGrant(
                artifact_kind=cast("str", row["artifact_kind"]),
                artifact_id=cast("str", row["id"]),
                path=cast("str", row["path"]),
            )
            for row in required_rows(invocation)
        )
        role = cast("str", invocation["role"])
        context = InvocationContext(
            baseline=snapshot,
            role=role,
            invocation_id=identity.invocation_id,
            workspace=cast("JsonObject", invocation["workspace"]),
            required_outputs=cast("JsonObject", invocation["required_outputs"]),
            selected_ids=cast("tuple[str, ...]", invocation.get("selected_ids", ())),
            review_mode=(
                cast("str", invocation["gate_mode"])
                if role == "migration-coverage-reviewer"
                else None
            ),
        )
        self._verified.add(identity.invocation_id)
        return ServiceAuthority(
            principal="host",
            author_or_agent=self.principal.agent_id,
            invocation=context,
            grants=grants,
            read_selection=(
                self._read_selection(request, invocation, capture)
                if request.operation == "read-source"
                else None
            ),
        )

    def writer(
        self, baseline: CapturedWorkspace, *, authority: ServiceAuthority
    ) -> GuardedMutationWriter:
        """Return a guarded recapturing writer for this exact host authority.

        baseline (CapturedWorkspace) and authority (ServiceAuthority) are trusted
        core values; a foreign root, principal, agent or an invocation this
        instance did not verify raises PermissionError. No publication occurs
        until the writer is invoked.
        """
        if (
            not self._matches_workspace(baseline.workspace_root)
            or authority.principal != "host"
            or authority.author_or_agent != self.principal.agent_id
            or authority.invocation is None
            or authority.invocation.invocation_id not in self._verified
        ):
            raise PermissionError("Writer authority differs from host context")
        io = self.initialization
        return GuardedMutationWriter(
            capture=lambda: recapture_workspace(io, baseline),
            invalidate_authority=io.invalidate_authority,
            primitives=io.primitives,
        )


class InstalledHostStore:
    """Read the protected store through bounded filesystem reads; never write."""

    def read_text(self, path: str) -> str | None:
        """Return bounded UTF-8 text at path (str), or None when no file exists."""
        target = Path(path)
        if not target.is_file():
            return None
        with target.open("rb") as handle:
            content = handle.read(RECORD_BYTE_LIMIT + 1)
        if len(content) > RECORD_BYTE_LIMIT:
            raise OSError("Protected record exceeds its byte limit")
        return content.decode("utf-8")

    def list_entries(self, directory: str) -> tuple[str, ...]:
        """Return sorted entry names of directory (str); empty when it is absent."""
        target = Path(directory)
        if not target.is_dir():
            return ()
        return tuple(sorted(entry.name for entry in target.iterdir()))

    def exists(self, path: str) -> bool:
        """Return whether path (str) names an existing entry."""
        return Path(path).exists()


def _refuse_root_configuration() -> None:
    """Refuse configuration under the host principal; raise PermissionError."""
    raise PermissionError("A host principal cannot configure discovery")


def _invalidate_host_authority() -> None:
    """Leave native revocation to the host adapters; return None without effects."""


def installed_host_io(
    root: str,
    repository: RepositoryReader | None,
    *,
    session_id: str,
    host_name: str,
    agent_id: str,
    agent_role: str,
) -> HostServiceIO:
    """Compose the installed host ports from trusted outer gateway options.

    root (str) must be an absolute canonical workspace; repository
    (RepositoryReader | None) is the exact optional reader; session_id,
    host_name, agent_id and agent_role (str) are the host-verified principal the
    gateway received as fixed options. Each request's `invocation_ref` is bound
    at authorize time. Returns HostServiceIO; invalid roots raise ValueError and
    resolution or catalog failures propagate. Reads installed metadata and
    creates no file.
    """
    workspace = Path(root)
    if not workspace.is_absolute() or workspace.resolve(strict=True) != workspace:
        raise ValueError("Select an absolute canonical workspace")
    location = RegistryLocation.for_host(
        workspace_root=workspace.as_posix(),
        platform=installed_platform(),
        user_home=str(Path.home()),
        local_app_data=os.environ.get("LOCALAPPDATA"),
        xdg_state_home=os.environ.get("XDG_STATE_HOME"),
    )
    activation = ActivationStore.local(
        location=canonical_state_location(location),
        catalog=load_catalog(),
        authorize_root=_refuse_root_configuration,
        invalidate_authority=_invalidate_host_authority,
    )
    return HostServiceIO(
        activation=activation,
        repository=repository,
        principal=HostPrincipal(
            host=host_name, session_id=session_id, agent_id=agent_id, role=agent_role
        ),
        store=InstalledHostStore(),
    )
