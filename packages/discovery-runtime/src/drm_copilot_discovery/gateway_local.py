"""Compose trusted local-user discovery over accepted native storage and Git seams."""

from __future__ import annotations

import os
import shutil
import subprocess
import sys
import threading
from dataclasses import replace
from pathlib import Path
from typing import TYPE_CHECKING, Literal, cast

from drm_copilot_discovery.activation_filesystem import RegistryLocation
from drm_copilot_discovery.activation_store import ActivationStore
from drm_copilot_discovery.build_identity import load_build_identity
from drm_copilot_discovery.catalog import load_catalog
from drm_copilot_discovery.init_io import InitializationIO
from drm_copilot_discovery.mutation_io import GuardedMutationWriter, capture_workspace
from drm_copilot_discovery.path_models import PathPolicyError
from drm_copilot_discovery.path_policy import PathPolicy, workspace_identity
from drm_copilot_discovery.report_models import ReportBudget
from drm_copilot_discovery.service_contracts import ServiceAuthority
from drm_copilot_discovery.source_read_models import ReadGrant, ReadSelection

if TYPE_CHECKING:
    from collections.abc import Callable

    from drm_copilot_discovery.doctor import CapabilityObservation
    from drm_copilot_discovery.mutation_plan import CapturedWorkspace
    from drm_copilot_discovery.repository_reader import (
        RepositoryIdentity,
        RepositoryReader,
    )
    from drm_copilot_discovery.service_contracts import RuntimeIdentity, ServiceRequest


class LocalServiceIO:
    """Bind explicit local-user authorization to accepted native I/O boundaries.

    Construct from a trusted ActivationStore, exact RepositoryReader and verified
    identity provider. Initialization and writer captures share the same readers
    and guarded primitives. Request markers never supply host authorization.
    Construction performs no I/O; methods read only or return guarded writers.
    """

    def __init__(
        self,
        *,
        activation: ActivationStore,
        repository: RepositoryReader | None,
        principal: Literal["local-user", "host"],
        author_id: str,
        identity: Callable[[], RuntimeIdentity] = load_build_identity,
    ) -> None:
        """Bind trusted ports; reject unavailable principal with PermissionError.

        activation (ActivationStore): trusted activation store to preserve. repository
        (RepositoryReader | None): exact optional repository reader. principal
        (Literal['local-user', 'host']): explicit outer principal; host is unavailable.
        author_id (str): explicit local author identity. identity (Callable[[],
        RuntimeIdentity]): verified installed identity provider. Returns None; local
        fields are initialized without I/O. Invalid principal raises PermissionError.
        """
        if principal != "local-user":
            raise PermissionError("Native host authority is unavailable")
        self._authority = ServiceAuthority(
            principal=principal,
            author_or_agent=author_id,
            invocation=None,
            grants=(),
            read_selection=None,
        )
        self._activation, self._identity = activation, identity
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
        return self._identity()

    def capability_observation(self) -> CapabilityObservation | None:
        """Return None: the explicit local-user principal observes no native capability.

        Only a host gateway bound to a trusted session can report a protected
        capability attestation; the CLI's read-only diagnostics therefore report
        native enforcement as unavailable without claiming a deficiency cause.
        """
        return None

    def _matches_workspace(self, path: str) -> bool:
        """Compare path (str) to the bound root with strict platform identity.

        Return False for an invalid or different root; callers deny authority
        with PermissionError. Parsing is lexical and performs no I/O.
        """
        try:
            return workspace_identity(path) == workspace_identity(
                self.initialization.workspace_root
            )
        except PathPolicyError:
            return False

    def authorize(
        self, request: ServiceRequest, *, baseline: CapturedWorkspace | None
    ) -> ServiceAuthority:
        """Authenticate a parsed request against this explicit outer local principal.

        Return local authority with bounded exact read selection when needed. Host
        markers, substituted roots and cross-workspace captures raise PermissionError
        before source I/O. Core derives exact local write grants only from its accepted
        planned changes; this method grants no root wildcard.

        request (ServiceRequest): parsed operation input; no authority is inferred from
        it. baseline (CapturedWorkspace | None): captured workspace, or None before
        capture. Returns ServiceAuthority; invalid or different root identity raises
        PermissionError. Scoped-selection path failures propagate; reads metadata only
        for scoped selection.
        """
        # The root prepare-agent baseline is local-user work; finalize-agent needs
        # a verified host invocation that this local composition cannot supply.
        if (
            request.invocation_ref is not None
            or request.authorization_ref is not None
            or request.mode == "agent-output"
            or request.operation == "finalize-agent"
            or not self._matches_workspace(request.workspace_root)
            or (
                baseline is not None
                and not self._matches_workspace(baseline.workspace_root)
            )
        ):
            raise PermissionError("Request has no local-user authority")
        selection: ReadSelection | None = None
        # Only a captured profile can delimit an authenticated local read selection.
        if request.operation == "read-source" and baseline is not None:
            paths = cast("tuple[str, ...]", request.inputs["paths"])
            if not 1 <= len(paths) <= 10000:
                raise PermissionError("Read selection exceeds its bound")
            policy = PathPolicy(
                baseline.snapshot.profile,
                workspace_root=baseline.workspace_root,
                metadata=self.initialization.metadata,
            )
            grants: list[ReadGrant] = []
            # Exact requested paths still require independent configured read scope.
            for path in paths:
                target = policy.resolve_read(path)
                grants.append(
                    ReadGrant(
                        path=path, directory=target.observations[-1].kind == "directory"
                    )
                )
            selection = ReadSelection(grants=tuple(grants))
        return replace(self._authority, read_selection=selection)

    def writer(
        self, baseline: CapturedWorkspace, *, authority: ServiceAuthority
    ) -> GuardedMutationWriter:
        """Return a same-root guarded recapturing writer without publishing bytes.

        Baseline and authority are trusted core values. Reject foreign identity with
        PermissionError. Fresh captures retain this reader; accepted mutation validation
        remains responsible for exact grants and complete CAS.

        baseline (CapturedWorkspace): required accepted capture for this same-root
        guarded writer.
        authority (ServiceAuthority): authenticated local identity and exact grants.
        Returns GuardedMutationWriter; invalid or different root identity raises
        PermissionError. No publication occurs until the writer is invoked.
        """
        if (
            not self._matches_workspace(baseline.workspace_root)
            or authority.principal != self._authority.principal
            or authority.author_or_agent != self._authority.author_or_agent
            or authority.invocation is not None
        ):
            raise PermissionError("Writer authority differs from local context")
        return GuardedMutationWriter(
            capture=lambda: self._recapture(baseline),
            invalidate_authority=self.initialization.invalidate_authority,
            primitives=self.initialization.primitives,
        )

    def _recapture(self, baseline: CapturedWorkspace) -> CapturedWorkspace:
        """Reload the same profile and repository through the bound trusted reader.

        baseline (CapturedWorkspace): required prior capture whose profile and
        repository are reloaded.
        Returns CapturedWorkspace; I/O, path and budget failures propagate. Reads the
        exact bound workspace and repository.
        """
        io = self.initialization
        current = capture_workspace(
            workspace_root=io.workspace_root,
            profile_path=baseline.snapshot.profile.artifacts["profile"],
            metadata=io.metadata,
            read_bytes=io.read_bytes,
            catalog=io.catalog,
            repository=io.repository,
        )
        selected, loaded = _repository_selection(baseline), _repository_selection(
            current
        )
        # Inventory alone adds source pins; repeat that exact accepted selection.
        if set(selected) - set(loaded):
            if io.repository is None:
                raise OSError("Pinned repository reader is unavailable")
            from drm_copilot_discovery.analyzer.input_capture import (
                pin_inventory_sources,
            )

            current = pin_inventory_sources(current, io.repository)
            loaded = _repository_selection(current)
        if loaded != selected:
            raise OSError("Writer source selection differs from baseline")
        return current


def _repository_selection(
    capture: CapturedWorkspace,
) -> tuple[tuple[RepositoryIdentity, str], ...]:
    """Project exact identity/path pins after reserving aggregate copy/hash work.

    Use the captured profile's trusted parse limits. Raise ReportLimitError before
    excessive allocation; retain no blob copies and perform no external reads.

    capture (CapturedWorkspace): accepted workspace with pinned repository inputs.
    Returns tuple of repository/path pairs; ReportLimitError precedes excessive
    allocation. No external effects.
    """
    pins = capture.snapshot.repository_files
    budget = ReportBudget(capture.snapshot.profile.limits.parse_limits())
    budget.work(8 * len(pins))
    result: list[tuple[RepositoryIdentity, str]] = []
    # Validate encoded key capacity before appending or hashing any selected pair.
    for item in pins:
        budget.work(
            8
            * (
                len(item.repository.id)
                + len(item.repository.revision or "")
                + len(item.path)
            )
        )
        budget.check((item.repository.id, item.repository.revision, item.path))
        result.append((item.repository, item.path))
    return tuple(result)


def run_local_git(argv: tuple[str, ...], *, output_limit: int) -> bytes:
    """Execute only LocalGitReader argv with bounded stdout and discarded stderr.

    Resolve fixed git through PATH; reject unbounded sizes and other executables. The
    process never receives stdin, a shell or inherited Git redirection/config. Raise
    fixed OSError on failure/overflow; tests replace process/which seams.

    argv (tuple[str, ...]): fixed outer argument sequence. output_limit (int): positive
    stdout byte ceiling, at most 64 MiB. Returns bytes from successful Git; OSError
    reports timeout, overflow or failure. Starts, bounds and reaps one fixed native
    process.
    """
    executable = shutil.which("git")
    if (
        not executable
        or Path(executable).suffix.casefold() in (".cmd", ".bat")
        or not argv
        or argv[0] != "git"
        or type(output_limit) is not int
        or not 0 < output_limit <= 67108864
    ):
        raise OSError("Bounded installed Git is unavailable")
    # Exclude ambient Git overrides so the fixed -C root remains authoritative.
    environment = {
        key: value
        for key, value in os.environ.items()
        if not key.upper().startswith("GIT_")
    }
    environment.update(
        {
            "GIT_CONFIG_NOSYSTEM": "1",
            "GIT_CONFIG_GLOBAL": os.devnull,
            "GIT_TERMINAL_PROMPT": "0",
            "GIT_OPTIONAL_LOCKS": "0",
        }
    )
    with subprocess.Popen(  # noqa: S603 - static analysis can't verify runtime validation
        (executable, *argv[1:]),
        stdin=subprocess.DEVNULL,
        stdout=subprocess.PIPE,
        stderr=subprocess.DEVNULL,
        shell=False,
        env=environment,
    ) as process:
        expired = threading.Event()

        def expire() -> None:
            """Cancel the bounded Git read at its deadline; return None.

            Signal the local Event and kill the fixed child if still running.
            Killing closes its pipe writer, releasing a pending bounded read.
            ProcessLookupError means the child already exited; no other error
            is suppressed. No request-selected process can enter this callback.
            """
            expired.set()
            try:
                if process.poll() is None:
                    process.kill()
            except ProcessLookupError:
                return

        deadline = threading.Timer(30, expire)
        deadline.daemon = True
        # Arm cancellation before touching stdout, so a silent pipe cannot bypass it.
        deadline.start()
        try:
            if process.stdout is None:
                raise OSError("Git stdout is unavailable")
            content = process.stdout.read(output_limit + 1)
            if len(content) > output_limit:
                raise OSError("Git output exceeds its bound")
            code = process.wait(timeout=30)
        except subprocess.TimeoutExpired:
            raise OSError("Git read timed out") from None
        finally:
            deadline.cancel()
            deadline.join()
            if process.poll() is None:
                process.kill()
                process.wait()
        if expired.is_set():
            raise OSError("Git read timed out")
        if code != 0:
            raise OSError("Git read failed")
        return content


def _authorize_local_root() -> None:
    """Accept the authenticated explicit local-user root; return None without I/O."""


def _invalidate_empty_authority() -> None:
    """Invalidate the empty local authority set without claiming native revocation.

    Only the trusted local-user factory installs this P6 callback. It cannot
    issue or accept native grants/receipts; host references and prepare/finalize
    are rejected. P8 must replace this callback before native capability use.
    Guarded writers still call it before every write and propagate failures.
    Return None; no storage or external authority is mutated.
    """


def _canonical_state_location(location: RegistryLocation) -> RegistryLocation:
    """Resolve validated host storage while preserving its workspace partition.

    location (RegistryLocation): output of for_host after its absolute, platform,
    parent-component and external-root checks. Return a location with the same
    workspace identity and fixed suffix beneath the resolved host base. Host
    resolution may insert intermediate components. Read metadata only; absent
    leaves are permitted. Resolution errors propagate; ValueError rejects a
    relative result, escaped base or changed contract suffix/workspace digest.
    """
    state = Path(location.directory)
    # The accepted builder appends drm-copilot/discovery/workspaces/workspace-digest.
    base = state.parents[3]
    suffix = state.relative_to(base)
    resolved_base = base.resolve()
    canonical = state.resolve()
    # Complete-path resolution can differ from resolving its parent and joining.
    # Retain the contract suffix and containment; the store rechecks canonicality.
    if (
        not canonical.is_absolute()
        or not canonical.is_relative_to(resolved_base)
        or Path(*canonical.parts[-len(suffix.parts) :]) != suffix
    ):
        raise ValueError("Host state must retain its fixed workspace partition")
    return replace(location, directory=canonical.as_posix())


def installed_local_io(
    root: str, repository: RepositoryReader | None, principal: str, author_id: str
) -> LocalServiceIO:
    """Compose fixed installed ports from trusted outer host values; create no files.

    Root must already be absolute/canonical. Host state paths come from platform
    settings, never request JSON. Validate their spelling before resolving aliases,
    preserving the fixed state partition and strict store guard. Invalid paths or
    principals raise fixed errors; resolution and catalog failures propagate.

    root (str): trusted absolute canonical workspace. repository (RepositoryReader |
    None): exact optional repository reader. principal (str): explicit outer principal;
    host is unavailable. author_id (str): explicit local author identity. Returns
    LocalServiceIO; invalid roots/principals raise ValueError/PermissionError and
    catalog failures propagate. Reads installed metadata without creating workspace
    files.
    """
    workspace = Path(root)
    if not workspace.is_absolute() or workspace.resolve(strict=True) != workspace:
        raise ValueError("Select an absolute canonical workspace")
    if principal != "local-user":
        raise PermissionError("Native host capability is unavailable")
    platform: Literal["windows", "macos", "linux"] = (
        "windows"
        if os.name == "nt"
        else "macos" if sys.platform == "darwin" else "linux"
    )
    location = RegistryLocation.for_host(
        workspace_root=workspace.as_posix(),
        platform=platform,
        user_home=str(Path.home()),
        local_app_data=os.environ.get("LOCALAPPDATA"),
        xdg_state_home=os.environ.get("XDG_STATE_HOME"),
    )
    activation = ActivationStore.local(
        location=_canonical_state_location(location),
        catalog=load_catalog(),
        authorize_root=_authorize_local_root,
        invalidate_authority=_invalidate_empty_authority,
    )
    return LocalServiceIO(
        activation=activation,
        repository=repository,
        principal=principal,
        author_id=author_id,
    )
