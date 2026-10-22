"""Report installed runtime and local configuration health without changing state."""

from __future__ import annotations

from dataclasses import dataclass
from typing import TYPE_CHECKING, Literal, Protocol, cast, runtime_checkable

from drm_copilot_discovery.activation_store import ActivationStore
from drm_copilot_discovery.configuration import LOCATOR_PATH, ConfigurationError
from drm_copilot_discovery.findings import Finding
from drm_copilot_discovery.models import JsonObject, ParseLimits
from drm_copilot_discovery.path_models import PathPolicyError
from drm_copilot_discovery.profile_v2 import ProfileError
from drm_copilot_discovery.report_models import ReportBudget, ReportLimitError
from drm_copilot_discovery.service_contracts import DiscoveryResult
from drm_copilot_discovery.snapshot import InputManifest, SnapshotFile
from drm_copilot_discovery.snapshot_io import SnapshotIO

if TYPE_CHECKING:
    from drm_copilot_discovery.init_io import InitializationIO
    from drm_copilot_discovery.path_models import PathMetadata
    from drm_copilot_discovery.service_contracts import (
        RuntimeIdentity,
        ServiceIO,
        ServiceRequest,
    )


CapabilityStatus = Literal["supported", "unsupported", "missing"]


@dataclass(frozen=True, kw_only=True)
class CapabilityObservation:
    """Carry the gateway's assessment of the native host capability for one session.

    The host gateway, not this runtime, observes hook handlers, trusted
    attribution and the denial sentinel; it hands the outcome here so doctor can
    explain exactly which control is missing. A supported observation names its
    protected attestation and carries no reasons; an unsupported one carries at
    least one reason. The value grants nothing and performs no I/O.
    """

    status: CapabilityStatus
    reasons: tuple[str, ...] = ()
    attestation_ref: str | None = None
    observed_at: str | None = None

    def __post_init__(self) -> None:
        """Reject contradictory observations instead of reporting them as health."""
        if self.status not in ("supported", "unsupported", "missing"):
            raise ValueError(
                "Capability status must be supported, unsupported or missing"
            )
        if self.status == "supported" and (
            self.reasons or self.attestation_ref is None
        ):
            raise ValueError(
                "A supported capability names its attestation and has no reasons"
            )
        if self.status == "unsupported" and not self.reasons:
            raise ValueError("An unsupported capability must state at least one reason")
        if any(not reason.strip() for reason in self.reasons):
            raise ValueError("Capability reasons must be nonblank")


@runtime_checkable
class CapabilityObserving(Protocol):
    """Optional ServiceIO extension through which a host gateway reports capability."""

    def capability_observation(self) -> CapabilityObservation | None:
        """Return the current protected capability observation, or None when unknown."""
        ...


def capability_findings(
    observation: CapabilityObservation | None,
) -> tuple[Finding, ...]:
    """Project an optional capability observation into doctor findings.

    Returns a tuple of Finding values: an informational verification when the host
    is supported, otherwise one warning explaining each deficiency or the generic
    unavailability when nothing was observed. No value here authorizes execution.
    """
    if observation is not None and observation.status == "supported":
        return (
            Finding(
                code="DISCOVERY_ENFORCEMENT_VERIFIED",
                severity="info",
                pointer="/summary/deployment",
                related_ids=("capability-attestation",),
                message=(
                    "Native discovery capability verified by attestation "
                    f"{observation.attestation_ref}."
                ),
                next_action=(
                    "Controlled agent preparation may proceed for this session."
                ),
            ),
        )
    if observation is None or observation.status == "missing":
        return (
            Finding(
                code="DISCOVERY_ENFORCEMENT_UNAVAILABLE",
                severity="warning",
                pointer="/summary/deployment",
                message="Native discovery capability has not been verified.",
                next_action=(
                    "Install and verify a supported native capability provider."
                ),
            ),
        )
    # Each reported deficiency becomes its own actionable warning.
    return tuple(
        Finding(
            code="DISCOVERY_ENFORCEMENT_UNAVAILABLE",
            severity="warning",
            pointer="/summary/deployment",
            related_ids=("capability-attestation",),
            message=f"Native discovery capability is unavailable: {reason}.",
            next_action=(
                "Repair the named host control and re-run the capability probe "
                "before preparing a discovery agent."
            ),
        )
        for reason in observation.reasons
    )


def _capability_state(observation: CapabilityObservation | None) -> str:
    """Return the summary wording for the observed capability status."""
    if observation is None or observation.status == "missing":
        return "unavailable"
    return "verified" if observation.status == "supported" else "unsupported"


class _DoctorCapture:
    """Bound diagnostic reads to one aggregate capture and work budget.

    Construct from trusted initialization ports and parse limits, observe initial
    paths, route selection reads through read(), then verify freshness. Cached
    bytes remain immutable; every comparison consumes work capacity. Only bound
    read/metadata ports perform I/O. No writes, permissions or receipts are issued.
    """

    def __init__(self, io: InitializationIO, limits: ParseLimits) -> None:
        """Bind io (InitializationIO) trusted readers and limits (ParseLimits).

        Return None; construct local counters and the snapshot reader without observing
        files or creating authority. Invalid policy raises ValueError.

        io (InitializationIO): trusted workspace I/O ports. limits (ParseLimits):
        trusted finite parse capacities or default policy.
        """
        self._read_bytes = io.read_bytes
        self._metadata = io.metadata
        self._paths: set[str] = set()
        self._width = self._projection_work = 0
        self.budget = ReportBudget(limits)
        self.reader = SnapshotIO(
            workspace_root=io.workspace_root,
            metadata=self.metadata,
            read_bytes=self._bounded_read,
            max_entries=1000,
        )
        self.remaining = self.capacity = limits.document_bytes
        self._captured: dict[str, bytes] = {}

    def path(self, path: str) -> None:
        """Reserve path (str) hashing/comparison/text work before use; return None.

        New paths also reserve final sorting/projection work before retention.
        ReportLimitError refuses excessive work or encoding; only budget and
        local path bookkeeping change. No filesystem observation occurs.
        """
        self.budget.work(2 * len(path) + 1)
        if path not in self._paths:
            width = max(self._width, len(path))
            count = len(self._paths) + 1
            projection = 2 * count * count * max(1, width)
            self.budget.work(2 * len(path) + projection - self._projection_work)
            self.budget.check(path)
            self._paths.add(path)
            self._width, self._projection_work = width, projection

    def metadata(self, path: str) -> PathMetadata:
        """Read path (str) through the trusted port after reserving path work.

        Return PathMetadata unchanged; propagate budget/I/O errors. Only the
        bound metadata reader observes storage; this method never writes.
        """
        self.path(path)
        return self._metadata(path)

    def candidates(
        self, paths: tuple[str, ...], selected: str | None
    ) -> tuple[str, ...]:
        """Return sorted unique paths (tuple[str, ...]) plus locator/selected.

        paths are configured candidates; selected (str | None) is an explicit
        profile. Reserve copying, text, hash and worst-case pairwise comparison
        work before set/sort allocation. Raise OSError or ReportLimitError on
        count/work/encoding limits. Only local budget/bookkeeping are mutated.
        """
        if len(paths) > 1000:
            raise OSError("Doctor candidate capacity exceeded")
        count = len(paths) + 1 + (selected is not None)
        self.budget.work(3 * count)
        members = (*paths, LOCATOR_PATH) + (() if selected is None else (selected,))
        width = 0
        # Measure no candidate text until its exact character work has been reserved.
        for path in members:
            self.path(path)
            width = max(width, len(path))
        self.budget.work(2 * count * count * max(1, width))
        return tuple(sorted(set(members)))

    def _bounded_read(self, path: str, *, limit: int) -> bytes:
        """Read path (str) with limit (positive int) through the trusted port.

        Return exact bytes or raise OSError before oversized data is retained. Only the
        bound byte reader observes storage; no mutation occurs.

        path (str): selected relative workspace input. limit (int): positive read
        capacity in bytes.
        """
        content = self._read_bytes(path, limit=limit)
        if type(content) is not bytes or len(content) > limit:
            raise OSError("Doctor read adapter exceeded its bound")
        return content

    def read(self, path: str, *, limit: int) -> bytes:
        """Return captured ordinary bytes under aggregate byte/work bounds.

        path (str) identifies a relative input; limit (positive int) caps bytes. New I/O
        receives the remaining capacity before allocating bytes; repeated selection
        comparisons are charged before returning an existing capture. SnapshotIO retains
        path/freshness checks. Return immutable bytes; budget, path and I/O errors
        propagate. Only local counters/capture state change.

        path (str): selected relative workspace input. limit (int): positive read
        capacity in bytes.
        """
        self.budget.work(1)
        self.path(path)
        # Repeated selector reads reuse exact captured bytes without new allocation.
        if path not in self._captured:
            capacity = min(limit, self.remaining, self.budget.work_left)
            if capacity < 1:
                raise OSError("Doctor input capacity exceeded")
            content = cast("bytes", self.reader.read(path, limit=capacity))
            self.remaining -= len(content)
            self._captured[path] = content
        content = self._captured[path]
        self.budget.work(len(content))
        if len(content) > limit:
            raise OSError("Doctor input exceeds the selected limit")
        return content

    def observe(self, path: str) -> None:
        """Observe path (str, relative) as absence or bounded bytes; return None.

        Budget/path/I/O errors propagate. Only read observations and local counters
        change; no configuration policy or authority is selected.

        path (str): selected relative workspace input.
        """
        self.budget.work(1)
        self.path(path)
        if self.reader.inspect(path).kind != "missing":
            self.read(path, limit=self.capacity)

    def verify(self) -> None:
        """Reserve actual comparison work before freshness I/O; propagate changes."""
        self.budget.work(self.capacity - self.remaining)
        self.reader.verify_unchanged()


def inspect_doctor(
    *,
    io: ServiceIO,
    request: ServiceRequest,
    runtime: RuntimeIdentity,
    capability: CapabilityObservation | None = None,
) -> DiscoveryResult:
    """Diagnose authenticated request configuration using verified runtime identity.

    The service supplies ServiceIO, a parsed doctor ServiceRequest and an already
    verified RuntimeIdentity, plus the host gateway's optional protected
    CapabilityObservation. Return a DiscoveryResult with actual read bytes and
    absence, or fixed configuration/I/O findings, and the capability projection.
    No write, activation, native probe, receipt or source enumeration occurs.
    Constructor/contract errors propagate; ordinary configuration and read
    failures become diagnostics.
    """
    initialization = io.initialization
    limits = ParseLimits()
    capture = _DoctorCapture(initialization, limits)
    reader = capture.reader
    findings: list[Finding] = []
    exit_code: Literal[0, 2, 3] = 0
    state = "unavailable"
    try:
        candidates = io.activation.candidate_paths
        paths = capture.candidates(candidates, request.profile_path)
        # Capture bounded candidate/locator observations even when selection fails.
        for path in paths:
            capture.observe(path)
        source = io.activation
        # Reuse selection semantics while routing every reread through this budget.
        selector = ActivationStore(
            location=source.location,
            registry=source.registry,
            primitives=source.primitives,
            metadata=capture.metadata,
            read_bytes=capture.read,
            open_directory=source.open_directory,
            catalog=source.catalog,
            authorize_root=source.authorize_root,
            invalidate_authority=source.invalidate_authority,
            candidate_paths=candidates,
        )
        selection = selector.select(profile_path=request.profile_path)
        # A protected locator may select a nondefault profile outside the candidates.
        if selection.profile_path is not None:
            selected = capture.read(selection.profile_path, limit=limits.document_bytes)
            if selected != selection.profile_bytes:
                raise OSError("Doctor selection changed during capture")
        if selection.locator_bytes is not None:
            if (
                capture.read(LOCATOR_PATH, limit=limits.document_bytes)
                != selection.locator_bytes
            ):
                raise OSError("Doctor locator changed during capture")
        if selector.select(profile_path=request.profile_path) != selection:
            raise OSError("Doctor activation changed during capture")
        capture.verify()
        state = selection.state
    except (ConfigurationError, ProfileError, PathPolicyError):
        exit_code = 2
        findings.append(
            Finding(
                code="DOCTOR_CONFIGURATION",
                pointer="/profile_path",
                message="Local profile, locator or protected activation is invalid.",
                next_action="Repair the selected profile and configure it explicitly.",
            )
        )
    except (OSError, ReportLimitError):
        exit_code = 3
        findings.append(
            Finding(
                code="DOCTOR_IO",
                pointer="/workspace_root",
                message="Local configuration could not be read consistently.",
                next_action="Check local access and retry with stable configuration.",
            )
        )
    findings.extend(capability_findings(capability))
    # Only observed ordinary workspace inputs enter this diagnostic manifest.
    captured = tuple(
        SnapshotFile(
            path=path,
            content=content,
            category="activation" if path == LOCATOR_PATH else "profile",
        )
        for path, content in reader.captured
    )
    summary = JsonObject(
        (
            (
                "message",
                f"Installed runtime verified; configuration {state}; "
                f"native capability {_capability_state(capability)}.",
            ),
            ("counts", ()),
            ("validation_result", None),
            ("receipt_ref", None),
            ("invocation_ref", None),
            ("deployment", None),
        )
    )
    return DiscoveryResult(
        operation="doctor",
        mode="structural",
        ok=exit_code == 0,
        exit_code=exit_code,
        findings=tuple(findings),
        artifacts=(),
        summary=summary,
        input_manifest=InputManifest(
            files=captured, missing_paths=reader.missing_paths
        ),
        runtime=runtime,
    )
