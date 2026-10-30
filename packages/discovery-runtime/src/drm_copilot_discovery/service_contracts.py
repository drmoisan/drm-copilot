"""Declare bounded service values and trusted ports without executing operations."""

from __future__ import annotations

import re
from dataclasses import dataclass
from typing import TYPE_CHECKING, Literal, Protocol, TypeAlias, cast, get_args

from drm_copilot_discovery.agent_output import InvocationContext
from drm_copilot_discovery.findings import Finding
from drm_copilot_discovery.models import (
    JsonObject,
    JsonValue,
    ParseLimits,
    canonical_json,
)
from drm_copilot_discovery.path_models import WriteGrant, relative_path
from drm_copilot_discovery.report_models import ReportBudget
from drm_copilot_discovery.service_serialization import (
    artifact_document,
    check_request,
    checked_request_document,
    checked_result_document,
    normalize_findings,
    result_document,
)
from drm_copilot_discovery.snapshot import InputManifest
from drm_copilot_discovery.source_read_models import ReadSelection

if TYPE_CHECKING:
    from collections.abc import Callable
    from datetime import datetime

    from drm_copilot_discovery.activation_store import ActivationStore
    from drm_copilot_discovery.catalog import SchemaCatalog
    from drm_copilot_discovery.init_io import InitializationIO
    from drm_copilot_discovery.mutation_io import MutationWriter
    from drm_copilot_discovery.mutation_plan import CapturedWorkspace

Operation: TypeAlias = Literal[
    "init",
    "configure",
    "profile",
    "inventory",
    "new-contract",
    "new-scenario",
    "update-artifact",
    "link-evidence",
    "validate-profile",
    "validate-feature-contract",
    "validate-coverage-ledger",
    "validate-runtime-scenario",
    "validate-parity-matrix",
    "validate-unspecified-behavior",
    "validate-product-decision",
    "validate-evidence-reference",
    "validate-decisions",
    "validate-all",
    "coverage-report",
    "parity-report",
    "completion-report",
    "generate-acceptance",
    "snapshot-export",
    "snapshot-import",
    "import-inventory",
    "migrate",
    "doctor",
    "read-source",
    "prepare-agent",
    "finalize-agent",
]
Mode: TypeAlias = Literal[
    "structural", "agent-output", "discovery-complete", "parity-complete", "planning"
]
OutputFormat: TypeAlias = Literal["json", "markdown", "both"]
Clock: TypeAlias = "Callable[[], datetime]"


@dataclass(frozen=True, kw_only=True)
class RuntimeIdentity:
    """Retain installed package/schema/policy identity without attesting its origin.

    Five keyword-only version/digest fields are immutable. The provider must
    verify installed bytes before constructing this value. Construction checks
    exact versions, positive integer policy version and SHA-256 spelling only;
    it performs no I/O and grants no request, native or publication authority.
    """

    package_version: str
    schema_version: str
    build_sha256: str
    policy_version: int
    policy_sha256: str

    def __post_init__(self) -> None:
        """Check typed identity fields; return None or raise fixed ValueError."""
        if (
            type(self.package_version) is not str
            or type(self.schema_version) is not str
            or self.package_version != "2.0.0"
            or self.schema_version != "2.0.0"
            or type(self.policy_version) is not int
            or not 0 < self.policy_version < 2**63
        ):
            raise ValueError("Service runtime identity has invalid versions")
        # Validate finite digest spellings without accepting substitute hashes.
        for value in (self.build_sha256, self.policy_sha256):
            if type(value) is not str or re.fullmatch("[0-9a-f]{64}", value) is None:
                raise ValueError("Service runtime identity requires SHA-256 digests")


class ServiceRuntimeError(RuntimeError):
    """Carry a fixed installed-runtime failure without substituting an identity.

    The provider selects unavailable or corrupt after its own verification.
    Ordered findings contain one actionable error at /runtime; no caller text
    or underlying exception is retained. Construction has no external effects.
    """

    def __init__(
        self, *, code: Literal["RUNTIME_UNAVAILABLE", "RUNTIME_CORRUPT"]
    ) -> None:
        """Set code and findings; return None or raise ValueError for unknown code."""
        if type(code) is not str or code not in (
            "RUNTIME_UNAVAILABLE",
            "RUNTIME_CORRUPT",
        ):
            raise ValueError("Unsupported service runtime failure")
        self.code = code
        self.findings = (
            Finding(
                code=code,
                pointer="/runtime",
                message="Verified installed runtime identity is unavailable.",
                next_action="Install or repair the trusted discovery runtime.",
            ),
        )
        super().__init__(code)


@dataclass(frozen=True, kw_only=True)
class ServiceRequest:
    """Retain immutable request data without establishing caller authority.

    Parse through parse_service_request for the exact trusted schema. Direct
    construction checks types, bounds and fixed operation combinations only.
    Inputs remain JsonObject; opaque references do not grant reads or writes.
    No I/O, provider selection or operation execution occurs here.
    """

    id: str
    request_id: str
    operation: Operation
    mode: Mode
    workspace_root: str
    profile_path: str | None
    dry_run: bool
    write: bool
    format: OutputFormat
    inputs: JsonObject
    invocation_ref: str | None
    authorization_ref: str | None

    def __post_init__(self) -> None:
        """Validate fields without copying inputs; return None or fixed ValueError."""
        check_request(self)


class ServiceRequestError(ValueError):
    """Expose bounded ordered invocation findings and recognized enum context.

    Construct only at a request/selector boundary, never to relabel arbitrary
    downstream ValueError. Unknown operation/mode become None independently.
    No partial request, raw exception text or execution authority is retained.
    """

    def __init__(
        self,
        findings: tuple[Finding, ...],
        *,
        operation: Operation | None = None,
        mode: Mode | None = None,
    ) -> None:
        """Retain findings and known context; return None or ValueError if invalid."""
        self.findings = normalize_findings(findings, limits=ParseLimits())
        if not any(finding.severity == "error" for finding in self.findings):
            raise ValueError("Service request failures require an error finding")
        # Redaction must precede any equality hook on an untyped caller value.
        self.operation = (
            operation
            if type(operation) is str and operation in get_args(Operation)
            else None
        )
        self.mode = mode if type(mode) is str and mode in get_args(Mode) else None
        super().__init__("SERVICE_REQUEST: request requires correction")


@dataclass(frozen=True, kw_only=True)
class ServiceArtifact:
    """Describe one digest-bearing file effect, without authorizing the effect.

    Path/kind/status/digest and optional text are immutable. Missing content is
    omitted on the wire. Directories or uncertain writes without a real digest
    belong in findings/counts, never in fabricated file rows. No I/O occurs.
    """

    path: str
    kind: str
    status: Literal["planned", "created", "updated", "skipped", "conflict"]
    sha256: str
    content: str | None = None

    def __post_init__(self) -> None:
        """Check file fields and UTF-8 bounds; return None or fixed ValueError."""
        artifact_document(self, limits=ParseLimits())


@dataclass(frozen=True, kw_only=True)
class DiscoveryResult:
    """Retain one bounded operation result without granting execution authority.

    Frozen tuples and JsonObject summary preserve original findings and captured
    manifest bytes. Null context is restricted to honest pre-execution errors;
    concrete partial file effects require complete real context. Construction
    checks consistency. Serialization additionally uses the trusted core schema.
    """

    operation: Operation | None
    mode: Mode | None
    ok: bool
    exit_code: Literal[0, 1, 2, 3]
    findings: tuple[Finding, ...]
    artifacts: tuple[ServiceArtifact, ...]
    summary: JsonObject
    input_manifest: InputManifest | None
    runtime: RuntimeIdentity | None

    def __post_init__(self) -> None:
        """Check typed fields/bounds; return None or ValueError/ReportLimitError."""
        if (
            type(self.ok) is not bool
            or type(self.exit_code) is not int
            or self.exit_code not in (0, 1, 2, 3)
            or (
                self.operation is not None
                and (
                    type(self.operation) is not str
                    or self.operation not in get_args(Operation)
                )
            )
            or (
                self.mode is not None
                and (type(self.mode) is not str or self.mode not in get_args(Mode))
            )
            or type(self.summary) is not JsonObject
            or type(self.artifacts) is not tuple
            or (self.runtime is not None and type(self.runtime) is not RuntimeIdentity)
            or (
                self.input_manifest is not None
                and type(self.input_manifest) is not InputManifest
            )
        ):
            raise ValueError("Service result fields have invalid types")
        if len(self.artifacts) > ParseLimits().artifact_records:
            raise ValueError("Service result has too many artifacts")
        if any(type(artifact) is not ServiceArtifact for artifact in self.artifacts):
            raise ValueError("Service artifacts require immutable file records")
        object.__setattr__(
            self, "findings", normalize_findings(self.findings, limits=ParseLimits())
        )
        result_document(self, limits=ParseLimits())

    def to_dict(self) -> dict[str, object]:
        """Return a detached bounded wire dict; raise ValueError on invalid state.

        No schema I/O or execution occurs. Explicit validation or to_json applies
        the trusted core schema; the returned data never grants authority.
        """
        from drm_copilot_discovery.models import to_plain_value

        return cast(
            "dict[str, object]",
            to_plain_value(result_document(self, limits=ParseLimits())),
        )

    def to_json(self) -> str:
        """Return canonical LF JSON after trusted installed core schema validation.

        Reads only the installed catalog through its accepted reader seam.
        Raises ValueError/ReportLimitError for invalid/oversized state; catalog
        failures propagate. No workspace read, mutation or operation executes.
        """
        document = checked_result_document(self, catalog=None, limits=ParseLimits())
        return canonical_json(document).decode("utf-8")


@dataclass(frozen=True, kw_only=True)
class ServiceAuthority:
    """Retain trusted provider context; construction does not authenticate it.

    principal is explicit. author_or_agent is a trusted identifier: local-user
    maps to human attribution, host to agent attribution. Invocation, exact
    grants and read selection come from protected providers, never request JSON.
    No missing-host fallback, I/O, grant minting or provider invocation occurs.
    """

    principal: Literal["local-user", "host"]
    author_or_agent: str
    invocation: InvocationContext | None
    grants: tuple[WriteGrant, ...]
    read_selection: ReadSelection | None

    def __post_init__(self) -> None:
        """Check typed context/capacities; return None or fixed ValueError."""
        if (
            type(self.principal) is not str
            or self.principal not in ("local-user", "host")
            or type(self.author_or_agent) is not str
            or not 1 <= len(self.author_or_agent) <= 256
            or re.fullmatch("[a-z][a-z0-9]*(?:[._-][a-z0-9]+)*", self.author_or_agent)
            is None
            or type(self.grants) is not tuple
            or len(self.grants) > ParseLimits().artifact_records
            or (
                self.invocation is not None
                and type(self.invocation) is not InvocationContext
            )
            or (
                self.read_selection is not None
                and type(self.read_selection) is not ReadSelection
            )
        ):
            raise ValueError("Service authority requires explicit trusted context")
        # Reject excessive counts before any grant traversal or retained copy.
        budget = ReportBudget(ParseLimits())
        budget.work(16 * len(self.grants))
        if any(type(grant) is not WriteGrant for grant in self.grants):
            raise ValueError("Service authority requires typed write grants")
        # Bound aggregate text before the accepted path spelling checks scan it.
        for grant in self.grants:
            budget.work(
                8
                * (len(grant.artifact_kind) + len(grant.artifact_id) + len(grant.path))
            )
            budget.check((grant.artifact_kind, grant.artifact_id, grant.path))
            relative_path(grant.path)


class ServiceIO(Protocol):
    """Supply trusted existing I/O seams; request data cannot select providers.

    Implementations bind one workspace and explicit principal, preserve capture
    freshness/CAS and propagate typed failures. Native host capability remains
    unavailable until its protected provider exists. This declaration does no I/O.
    """

    @property
    def initialization(self) -> InitializationIO:
        """Return the bound InitializationIO; provider failures propagate."""
        ...

    @property
    def activation(self) -> ActivationStore:
        """Return the bound ActivationStore; do not infer a local-user principal."""
        ...

    def runtime_identity(self) -> RuntimeIdentity:
        """Return verified identity or raise ServiceRuntimeError; never invent it."""
        ...

    def authorize(
        self, request: ServiceRequest, *, baseline: CapturedWorkspace | None
    ) -> ServiceAuthority:
        """Authenticate request/context and return authority; failures propagate.

        None baseline means bootstrap/capture unavailable, not an empty capture.
        Implementations may consult protected state; they must not trust payload
        claims or replace missing host authority with a local-user principal.
        """
        ...

    def writer(
        self, baseline: CapturedWorkspace, *, authority: ServiceAuthority
    ) -> MutationWriter:
        """Return a writer for exact capture/authority; typed failures propagate.

        The provider preserves guards, recapture, CAS and invalidation. Obtaining
        a writer performs no publication; accepted mutation plans remain required.
        """
        ...


def parse_service_request(
    value: JsonValue, *, catalog: SchemaCatalog, limits: ParseLimits
) -> ServiceRequest:
    """Parse immutable value with injected catalog/limits; return ServiceRequest.

    Raises ServiceRequestError with fixed findings and recognized context on
    malformed, out-of-budget or inapplicable input. No I/O or operation executes.
    """
    document, findings = checked_request_document(value, catalog=catalog, limits=limits)
    members = dict(document.members) if document is not None else {}
    if findings:
        context = (
            dict(value.members)
            if type(value) is JsonObject and len(value) <= 16
            else {}
        )
        raise ServiceRequestError(
            findings,
            operation=cast("Operation | None", context.get("operation")),
            mode=cast("Mode | None", context.get("mode")),
        )
    return ServiceRequest(
        id=cast("str", members["id"]),
        request_id=cast("str", members["request_id"]),
        operation=cast("Operation", members["operation"]),
        mode=cast("Mode", members["mode"]),
        workspace_root=cast("str", members["workspace_root"]),
        profile_path=cast("str | None", members["profile_path"]),
        dry_run=cast("bool", members["dry_run"]),
        write=cast("bool", members["write"]),
        format=cast("OutputFormat", members["format"]),
        inputs=cast("JsonObject", members["inputs"]),
        invocation_ref=cast("str | None", members["invocation_ref"]),
        authorization_ref=cast("str | None", members["authorization_ref"]),
    )


def validate_service_result(
    result: DiscoveryResult, *, catalog: SchemaCatalog, limits: ParseLimits
) -> None:
    """Validate result with trusted catalog/limits; return None without I/O.

    Raises ValueError/ReportLimitError for malformed or oversized output. Neither
    a valid envelope nor a constructor establishes execution/native authority.
    """
    if type(result) is not DiscoveryResult:
        raise ValueError("Service validation requires a DiscoveryResult")
    checked_result_document(result, catalog=catalog, limits=limits)
