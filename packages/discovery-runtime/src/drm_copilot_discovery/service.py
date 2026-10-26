"""Execute fixed discovery requests through authenticated capture and domain APIs."""

from __future__ import annotations

from datetime import datetime, timezone
from pathlib import PurePosixPath, PureWindowsPath
from typing import TYPE_CHECKING, Literal, cast, get_args

from drm_copilot_discovery.catalog import CatalogError
from drm_copilot_discovery.configuration import ConfigurationError
from drm_copilot_discovery.extension_validation import ExtensionResultError
from drm_copilot_discovery.findings import Finding
from drm_copilot_discovery.init_projection import InitializationConflict
from drm_copilot_discovery.models import JsonObject, JsonValue, ParseLimits
from drm_copilot_discovery.mutation_io import capture_workspace
from drm_copilot_discovery.mutation_plan import MutationError
from drm_copilot_discovery.operations import (
    OperationContext,
    OperationFailure,
    dispatch,
)
from drm_copilot_discovery.path_models import PathPolicyError
from drm_copilot_discovery.profile_v2 import ProfileError
from drm_copilot_discovery.report_models import ReportLimitError
from drm_copilot_discovery.resources import ResourceError
from drm_copilot_discovery.service_contracts import (
    DiscoveryResult,
    Mode,
    Operation,
    RuntimeIdentity,
    ServiceAuthority,
    ServiceRequest,
    ServiceRequestError,
    ServiceRuntimeError,
    parse_service_request,
    validate_service_result,
)
from drm_copilot_discovery.snapshot_io import SnapshotIO

if TYPE_CHECKING:
    from drm_copilot_discovery.analyzer.registry import InventoryRegistry
    from drm_copilot_discovery.repository_reader import RepositoryReader
    from drm_copilot_discovery.service_contracts import (
        Clock,
        ServiceIO,
    )


def _problem(code: str) -> Finding:
    """Return a fixed actionable Finding for code (str), without effects.

    Invalid internal codes raise ValueError. Raw exception text, input snippets
    and host paths never enter the service diagnostic.
    """
    return Finding(
        code=code,
        pointer="/",
        message="The discovery operation could not satisfy its contract.",
        next_action="Correct the input or repair the trusted runtime and retry.",
    )


def _failure(
    *,
    operation: Operation | None,
    mode: Mode | None,
    findings: tuple[Finding, ...],
    code: Literal[1, 2, 3],
    context: OperationContext | None,
    runtime: RuntimeIdentity | None,
) -> DiscoveryResult:
    """Return a classified failure with real available context and no invented effects.

    operation/mode are recognized enum values, findings are typed diagnostics,
    code is the established exit class. context/runtime may be unavailable before
    execution. No write occurs; result construction failures propagate.
    """
    if context is not None:
        return context.result(findings=findings, exit_code=code, verify_inputs=False)
    return DiscoveryResult(
        operation=operation,
        mode=mode,
        ok=False,
        exit_code=code,
        findings=findings,
        artifacts=(),
        input_manifest=None,
        runtime=runtime,
        summary=JsonObject(
            (
                ("message", "Operation could not start."),
                ("counts", ()),
                ("validation_result", None),
                ("receipt_ref", None),
                ("invocation_ref", None),
            )
        ),
    )


def _recognized(request: JsonValue) -> tuple[Operation | None, Mode | None]:
    """Return bounded recognized labels from request, without validating execution.

    JsonValue is untrusted; only a small fixed header shape is inspected. Unknown
    labels remain None. No I/O, parsing, authentication or authority is performed.
    """
    if type(request) is not JsonObject or len(request) > 16:
        return None, None
    # Bound key comparison work before constructing the tiny header lookup.
    if any(len(key) > 64 for key, _ in request.members):
        return None, None
    fields = dict(request.members)
    operation, mode = fields.get("operation"), fields.get("mode")
    return (
        (
            cast("Operation", operation)
            if type(operation) is str
            and len(operation) <= 64
            and operation in get_args(Operation)
            else None
        ),
        (
            cast("Mode", mode)
            if type(mode) is str and len(mode) <= 64 and mode in get_args(Mode)
            else None
        ),
    )


def _local(authority: ServiceAuthority, request: ServiceRequest) -> None:
    """Require authenticated local authority for request; return None or fail.

    ServiceAuthority is supplied by the trusted provider. Request references and
    an absent host implementation never confer authority. No I/O or grant
    derivation occurs; unavailable host contexts raise OperationFailure(exit 3).
    The root `prepare-agent` baseline route is a local-user operation; only
    `finalize-agent` requires a verified host invocation.
    """
    if (
        type(authority) is not ServiceAuthority
        or authority.principal != "local-user"
        or authority.invocation is not None
        or request.invocation_ref is not None
        or request.authorization_ref is not None
        or request.mode == "agent-output"
        or request.operation == "finalize-agent"
    ):
        raise OperationFailure("SERVICE_AUTHORITY", exit_code=3)


def _context(
    request: ServiceRequest,
    *,
    io: ServiceIO,
    runtime: RuntimeIdentity,
    repository_reader: RepositoryReader | None,
    clock: Clock,
    analyzer_registry: InventoryRegistry,
) -> OperationContext:
    """Capture a request using trusted providers and return its OperationContext.

    runtime is verified RuntimeIdentity; reader/clock/registry are injected ports.
    Bootstrap routes retain physical input bytes without a fabricated v2 graph.
    Configured operations require activation and exact reader identity. Raises
    typed configuration, authority or I/O errors before dispatch; performs reads.
    """
    initialization = io.initialization
    path_type = PureWindowsPath if ":" in request.workspace_root else PurePosixPath
    if (
        path_type(request.workspace_root) != path_type(initialization.workspace_root)
        or repository_reader is not initialization.repository
    ):
        raise OperationFailure("SERVICE_PROVIDER", exit_code=3)
    authority = io.authorize(request, baseline=None)
    _local(authority, request)
    now = clock()
    if type(now) is not datetime or now.tzinfo is None or now.utcoffset() is None:
        raise OperationFailure("SERVICE_CLOCK", exit_code=3)
    timestamp = now.astimezone(timezone.utc).isoformat().replace("+00:00", "Z")
    reads = SnapshotIO(
        workspace_root=initialization.workspace_root,
        metadata=initialization.metadata,
        read_bytes=initialization.read_bytes,
    )
    baseline = None
    if request.operation not in {
        "init",
        "configure",
        "profile",
        "validate-profile",
        "migrate",
        "doctor",
    }:
        selection = io.activation.select(
            profile_path=request.profile_path, controlled=True
        )
        if selection.profile is None or selection.profile_path is None:
            raise OperationFailure("SERVICE_PROFILE")
        selection.profile.require_configured()
        baseline = capture_workspace(
            workspace_root=initialization.workspace_root,
            profile_path=selection.profile_path,
            metadata=initialization.metadata,
            read_bytes=initialization.read_bytes,
            catalog=initialization.catalog,
            repository=repository_reader,
        )
        if (
            baseline.snapshot.file(selection.profile_path).content
            != selection.profile_bytes
        ):
            raise OperationFailure("SERVICE_CAPTURE", exit_code=3)
        if request.operation == "inventory" and repository_reader is not None:
            from drm_copilot_discovery.analyzer.input_capture import (
                pin_inventory_sources,
            )

            baseline = pin_inventory_sources(baseline, repository_reader)
        selected = io.authorize(request, baseline=baseline)
        _local(selected, request)
        if selected.author_or_agent != authority.author_or_agent:
            raise OperationFailure("SERVICE_AUTHORITY", exit_code=3)
        authority = selected
    return OperationContext(
        request,
        io=io,
        authority=authority,
        runtime=runtime,
        baseline=baseline,
        reads=reads,
        timestamp=timestamp,
        analyzer_registry=analyzer_registry,
    )


def execute(
    request: JsonValue,
    *,
    io: ServiceIO,
    repository_reader: RepositoryReader | None,
    clock: Clock,
    analyzer_registry: InventoryRegistry,
) -> DiscoveryResult:
    """Execute one closed request using exclusively caller-bound runtime ports.

    request (JsonValue) is untrusted data. ServiceIO authenticates the explicit
    principal and installed RuntimeIdentity; RepositoryReader/Clock/InventoryRegistry
    remain trusted injected collaborators. Return DiscoveryResult with malformed
    exit 2, blocking exit 1, runtime/authority/I/O exit 3 or successful exit 0.
    Reads and guarded writes are operation-specific; dry runs never publish.
    Unexpected programming exceptions propagate rather than becoming input errors.
    """
    parsed: ServiceRequest | None = None
    runtime: RuntimeIdentity | None = None
    context: OperationContext | None = None
    code: Literal[1, 2, 3]
    try:
        catalog = io.initialization.catalog
        parsed = parse_service_request(request, catalog=catalog, limits=ParseLimits())
        runtime = io.runtime_identity()
        if type(runtime) is not RuntimeIdentity:
            raise ServiceRuntimeError(code="RUNTIME_CORRUPT")
        context = _context(
            parsed,
            io=io,
            runtime=runtime,
            repository_reader=repository_reader,
            clock=clock,
            analyzer_registry=analyzer_registry,
        )
        result = dispatch(context)
        validate_service_result(result, catalog=catalog, limits=context.limits)
        return result
    except ServiceRequestError as error:
        return _failure(
            operation=(
                parsed.operation
                if parsed
                else cast("Operation | None", error.operation)
            ),
            mode=parsed.mode if parsed else cast("Mode | None", error.mode),
            findings=error.findings,
            code=2,
            context=context,
            runtime=runtime,
        )
    except (ServiceRuntimeError, OperationFailure) as error:
        code = error.exit_code if isinstance(error, OperationFailure) else 3
        findings = error.findings
    except ProfileError as error:
        code, findings = 2, error.findings
    except MutationError as error:
        code = 1 if error.code in ("MUTATION_INVALID", "INVENTORY_BLOCKED") else 2
        findings = error.findings or (_problem(error.code),)
    except InitializationConflict as error:
        # Preserve conflicting paths without copying untrusted exception prose.
        findings = tuple(
            Finding(
                code="INITIALIZATION_CONFLICT",
                artifact_path=item.path,
                message="Initialization conflicts with an existing path.",
                next_action="Reconcile this path before retrying.",
            )
            for item in error.outputs
        )
        code = 1
    except (CatalogError, ResourceError):
        code, findings = 3, (_problem("RUNTIME_CORRUPT"),)
        if parsed is None:
            operation, mode = _recognized(request)
            return _failure(
                operation=operation,
                mode=mode,
                findings=findings,
                code=3 if operation is not None and mode is not None else 2,
                context=None,
                runtime=runtime,
            )
    except ExtensionResultError as error:
        code, findings = 2, (_problem(error.code),)
    except ConfigurationError:
        code, findings = 2, (_problem("SERVICE_CONFIGURATION"),)
    except PathPolicyError as error:
        code, findings = 2, (_problem(error.code),)
    except ReportLimitError:
        code, findings = 2, (_problem("SERVICE_LIMIT"),)
    except OSError:
        code, findings = 3, (_problem("SERVICE_IO"),)
    return _failure(
        operation=parsed.operation if parsed else None,
        mode=parsed.mode if parsed else None,
        findings=findings,
        code=code,
        context=context,
        runtime=runtime,
    )
