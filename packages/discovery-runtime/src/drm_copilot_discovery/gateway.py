"""Run one fixed installed service request through bounded injectable streams."""

from __future__ import annotations

import sys
from datetime import UTC, datetime
from pathlib import Path
from typing import TYPE_CHECKING, Literal, Protocol, cast, get_args

from drm_copilot_discovery.analyzer.registry import InstalledInventoryRegistry
from drm_copilot_discovery.catalog import CatalogError
from drm_copilot_discovery.findings import Finding
from drm_copilot_discovery.gateway_host import installed_host_io
from drm_copilot_discovery.gateway_local import installed_local_io
from drm_copilot_discovery.models import JsonObject, ParseLimits, canonical_json
from drm_copilot_discovery.parsing import parse_document
from drm_copilot_discovery.repository_binding import installed_repository
from drm_copilot_discovery.resources import ResourceError
from drm_copilot_discovery.service_contracts import (
    DiscoveryResult,
    Mode,
    Operation,
    ServiceRuntimeError,
)

if TYPE_CHECKING:
    from collections.abc import Callable, Sequence
    from typing import BinaryIO, TextIO

    from drm_copilot_discovery.analyzer.registry import InventoryRegistry
    from drm_copilot_discovery.models import JsonValue
    from drm_copilot_discovery.repository_reader import RepositoryReader
    from drm_copilot_discovery.service_contracts import (
        Clock,
        ServiceIO,
    )


class ServiceExecutor(Protocol):
    """Call one service per parsed request and return its DiscoveryResult.

    The gateway supplies trusted ports and invokes this collaborator once.
    Implementations may read or publish workspace state. Unexpected failures
    leave effects unknown and forbid a replacement empty-effects result.
    """

    def __call__(
        self,
        request: JsonValue,
        *,
        io: ServiceIO,
        repository_reader: RepositoryReader | None,
        clock: Clock,
        analyzer_registry: InventoryRegistry,
    ) -> DiscoveryResult:
        """Return the service result for typed collaborators; propagate failures.

        request (JsonValue): parsed operation input; no authority is inferred from it.
        io (ServiceIO): trusted workspace I/O ports. repository_reader (RepositoryReader
        | None): exact bound reader, or None when absent. clock (Clock): injected UTC
        time provider. analyzer_registry (InventoryRegistry): fixed trusted analyzer
        selection. Returns DiscoveryResult; execution effects and unexpected exceptions
        belong to the service contract.
        """
        ...


def _execute(
    request: JsonValue,
    *,
    io: ServiceIO,
    repository_reader: RepositoryReader | None,
    clock: Clock,
    analyzer_registry: InventoryRegistry,
) -> DiscoveryResult:
    """Call the fixed installed service lazily; no request-selected import occurs.

    request (JsonValue): parsed operation input; no authority is inferred from it. io
    (ServiceIO): trusted workspace I/O ports. repository_reader (RepositoryReader |
    None): exact bound reader, or None when absent. clock (Clock): injected UTC time
    provider. analyzer_registry (InventoryRegistry): fixed trusted analyzer selection.
    Returns DiscoveryResult; delegates service effects and propagates errors unchanged.
    """
    from drm_copilot_discovery.service import execute

    return execute(
        request,
        io=io,
        repository_reader=repository_reader,
        clock=clock,
        analyzer_registry=analyzer_registry,
    )


FAILURE_MESSAGE = "The discovery request could not be completed."


def _failure(
    *,
    code: str,
    exit_code: Literal[2, 3],
    value: JsonObject | None = None,
    message: str = FAILURE_MESSAGE,
) -> DiscoveryResult:
    """Return a fixed empty failure; retain only recognized enums from value.

    code and exit_code are trusted boundary choices. Unknown context necessarily uses
    exit 2. No source text, substitute identity, effects or receipt survives.

    code (str): fixed gateway failure code. exit_code
    (Literal[2, 3]): selected supported outcome code. value (JsonObject | None):
    optional parsed JSON context. message (str): one of the gateway's fixed
    finding messages; never text taken from the arguments or the request.
    Returns DiscoveryResult with null runtime/manifest and no effects; invalid
    trusted values raise ValueError.
    """
    context = dict(value.members) if value is not None and len(value) <= 16 else {}
    operation = context.get("operation")
    mode = context.get("mode")
    operation = operation if operation in get_args(Operation) else None
    mode = mode if mode in get_args(Mode) else None
    if operation is None or mode is None:
        exit_code = 2
    return DiscoveryResult(
        operation=cast("Operation | None", operation),
        mode=cast("Mode | None", mode),
        ok=False,
        exit_code=exit_code,
        findings=(
            Finding(
                code=code,
                pointer="/runtime" if exit_code == 3 else "/",
                message=message,
                next_action="Check the request and repair the runtime if needed.",
            ),
        ),
        artifacts=(),
        summary=JsonObject(
            (
                ("message", "Discovery request failed."),
                ("counts", ()),
                ("validation_result", None),
                ("receipt_ref", None),
                ("invocation_ref", None),
            )
        ),
        input_manifest=None,
        runtime=None,
    )


def _emit(result: DiscoveryResult, *, stdout: TextIO, stderr: TextIO) -> int:
    """Write one validated LF JSON result and fixed diagnostics; return its exit.

    Stream failures return 3 after a fixed stderr message. A partial stdout write is
    never followed by a second document. No exception text is disclosed.

    result (DiscoveryResult): typed service outcome to retain or serialize. stdout
    (TextIO): result text stream. stderr (TextIO): fixed diagnostic text stream. Returns
    int exit code; writes only result/diagnostic streams. Unexpected stream/serializer
    errors propagate to the gateway refusal boundary.
    """
    try:
        rendered = result.to_json()
    except (CatalogError, ResourceError):
        # Only unavailable pre-execution context admits the fixed emergency shape.
        if result.input_manifest is not None or result.runtime is not None:
            stderr.write("Discovery result catalog is unavailable.\n")
            return 3
        emergency = _failure(
            code="RUNTIME_CORRUPT",
            exit_code=3,
            value=JsonObject((("operation", result.operation), ("mode", result.mode))),
        )
        from drm_copilot_discovery.service_serialization import result_document

        rendered = canonical_json(
            result_document(emergency, limits=ParseLimits())
        ).decode("utf-8")
        result = emergency
        stderr.write("Installed catalog unavailable; fixed failure envelope emitted.\n")
    except ValueError:
        stderr.write("Discovery result failed validation.\n")
        return 3
    try:
        written = stdout.write(rendered)
        if written != len(rendered):
            raise OSError("Incomplete result write")
        stdout.flush()
    except (OSError, UnicodeError):
        stderr.write("Discovery output could not be written.\n")
        return 3
    if result.exit_code:
        stderr.write("Discovery request failed; inspect the JSON findings.\n")
    return result.exit_code


def _read_request(stdin: BinaryIO, limits: ParseLimits) -> bytes:
    """Collect at most the trusted byte ceiling plus one sentinel from stdin.

    Short reads are joined until EOF; oversized/invalid stream responses raise OSError
    before retention. Return immutable bounded bytes without decoding.

    stdin (BinaryIO): bounded binary request stream. limits (ParseLimits): trusted
    finite parse capacities or default policy. Returns bytes within the sentinel
    capacity; invalid stream responses raise OSError. Only stdin is consumed.
    """
    content = bytearray()
    # A short pipe read is not EOF; read through the sentinel before interpreting JSON.
    while len(content) <= limits.document_bytes:
        capacity = min(65536, limits.document_bytes + 1 - len(content))
        part = stdin.read(capacity)
        if type(part) is not bytes or len(part) > capacity:
            raise OSError("Invalid bounded input response")
        if not part:
            break
        content.extend(part)
    return bytes(content)


def run_gateway(
    *,
    stdin: BinaryIO,
    stdout: TextIO,
    stderr: TextIO,
    create_io: Callable[[], ServiceIO],
    repository_reader: RepositoryReader | None,
    clock: Clock,
    analyzer_registry: InventoryRegistry,
    limits: ParseLimits | None = None,
    execute_request: ServiceExecutor = _execute,
) -> int:
    """Decode one finite JSON document, execute once and emit its matching exit.

    Trusted stream/provider/reader/clock/registry seams permit memory-only tests. The
    binary read reserves at most document_bytes+1 before parsing. Malformed, duplicate,
    deep, nonfinite or trailing JSON never reaches a collaborator. Provider failures are
    redacted. Unexpected executor failures refuse output: their effects are unknown, so
    no empty pre-execution envelope is invented. No shell or dynamic dispatch runs.

    stdin (BinaryIO): bounded binary request stream. stdout (TextIO): result text
    stream. stderr (TextIO): fixed diagnostic text stream. create_io (Callable[[],
    ServiceIO]): trusted factory invoked only after valid JSON. repository_reader
    (RepositoryReader | None): exact bound reader, or None when absent. clock (Clock):
    injected UTC time provider. analyzer_registry (InventoryRegistry): fixed trusted
    analyzer selection. limits (ParseLimits | None): trusted finite parse capacities or
    default policy. execute_request (ServiceExecutor): once-per-request service
    collaborator. Returns int process exit; dispatches once and writes streams.
    Unexpected execution/emission failures produce fixed diagnostics without replacement
    JSON.
    """
    value: JsonObject | None = None
    ports: ServiceIO | None = None
    result = _failure(code="SERVICE_REQUEST", exit_code=2)
    try:
        policy = limits or ParseLimits()
        raw = _read_request(stdin, policy)
        parsed = parse_document(raw, format="json", limits=policy)
        if parsed.value is not None:
            value = parsed.value
            ports = create_io()
    except ServiceRuntimeError as error:
        result = _failure(code=error.code, exit_code=3, value=value)
    except (CatalogError, ResourceError):
        result = _failure(code="RUNTIME_CORRUPT", exit_code=3, value=value)
    except Exception:  # noqa: BLE001 - CLI top-level error handling
        result = _failure(code="SERVICE_FAILURE", exit_code=3, value=value)
    if ports is None or value is None:
        return _emit(result, stdout=stdout, stderr=stderr)
    # After execution starts, an unexpected error cannot prove an empty effect set.
    try:
        result = execute_request(
            value,
            io=ports,
            repository_reader=repository_reader,
            clock=clock,
            analyzer_registry=analyzer_registry,
        )
    except Exception:  # noqa: BLE001 - CLI top-level error handling
        stderr.write("Discovery service failed unexpectedly; no result was emitted.\n")
        return 3
    try:
        return _emit(result, stdout=stdout, stderr=stderr)
    except Exception:  # noqa: BLE001 - CLI top-level error handling
        stderr.write("Discovery result failed unexpectedly; no replacement emitted.\n")
        return 3


def main(
    argv: Sequence[str] | None = None,
    *,
    stdin: BinaryIO | None = None,
    stdout: TextIO | None = None,
    stderr: TextIO | None = None,
) -> int:
    """Run the installed module with fixed outer options and injectable streams.

    Require --workspace-root and --principal; permit --repository-id/--author-id.
    With --principal host, --author-id (the agent id), --session-id, --host-name and
    --agent-role are all required; with --principal local-user the three host
    options are refused. No module, interpreter, shell or arbitrary executable option
    exists. Invalid outer options produce one fixed JSON failure; runtime work is
    deferred until a bounded request is decoded. Return the emitted result's exit.

    argv (Sequence[str] | None): fixed outer argument sequence. stdin (BinaryIO | None):
    bounded binary request stream. stdout (TextIO | None): result text stream. stderr
    (TextIO | None): fixed diagnostic text stream. Returns int process exit; composes
    fixed local or host ports and dispatches once. Invalid options yield an
    invocation failure.
    """
    output, errors = stdout or sys.stdout, stderr or sys.stderr
    arguments = tuple(sys.argv[1:] if argv is None else argv)
    options = _parse_options(arguments)
    if not isinstance(options, str):
        root = options["--workspace-root"]
        try:
            # Without an explicit id the activated profile's Git repository is bound.
            repository = installed_repository(root, options.get("--repository-id"))
        except ValueError:
            return _emit(
                _failure(code="SERVICE_REQUEST", exit_code=2),
                stdout=output,
                stderr=errors,
            )
        except OSError:
            # No request context exists yet, so the fixed pre-context exit applies.
            return _emit(
                _failure(code="SERVICE_IO", exit_code=3), stdout=output, stderr=errors
            )
        return run_gateway(
            stdin=stdin or sys.stdin.buffer,
            stdout=output,
            stderr=errors,
            create_io=lambda: _compose_io(options, root, repository, utc_now),
            repository_reader=repository,
            clock=utc_now,
            analyzer_registry=InstalledInventoryRegistry(),
        )
    return _emit(
        _failure(code="SERVICE_REQUEST", exit_code=2, message=options),
        stdout=output,
        stderr=errors,
    )


_HOST_OPTIONS = ("--author-id", "--session-id", "--host-name", "--agent-role")
_OPTION_CEILING = 14
# Fixed option refusals; none echoes an argument, so no caller text is disclosed.
OPTION_SHAPE_REFUSED = "The outer option table is malformed."
OPTION_UNKNOWN_REFUSED = "An outer option is unknown, repeated or empty."
OPTION_REQUIRED_REFUSED = "The outer options require --workspace-root and --principal."
OPTION_ROOT_REFUSED = (
    "The workspace root must be absolute and the principal local-user or host."
)
OPTION_HOST_REFUSED = (
    "The host principal requires --author-id, --session-id, --host-name and "
    "--agent-role."
)
OPTION_LOCAL_REFUSED = (
    "The local-user principal admits no session, host or role option."
)


def utc_now() -> datetime:
    """Return the current aware UTC instant; the gateway's only clock read."""
    return datetime.now(UTC)


def _parse_options(arguments: tuple[str, ...]) -> dict[str, str] | str:
    """Return the validated fixed option table for arguments, or the fixed refusal.

    arguments (tuple[str, ...]) is the outer argument sequence. The table admits
    --workspace-root, --principal, --repository-id, --author-id, --session-id,
    --host-name and --agent-role once each, requires an absolute root and a known
    principal, requires the four identity options with principal host and refuses
    the session, host and role options with principal local-user. Returns the
    option table, or one of the fixed OPTION_*_REFUSED messages (str) naming the
    first check that failed. No I/O occurs.
    """
    allowed = {"--workspace-root", "--principal", "--repository-id", *_HOST_OPTIONS}
    options: dict[str, str] = {}
    if len(arguments) > _OPTION_CEILING or len(arguments) % 2:
        return OPTION_SHAPE_REFUSED
    # A finite exact option table prevents request-selected command execution.
    for index in range(0, len(arguments), 2):
        key, value = arguments[index], arguments[index + 1]
        if key not in allowed or key in options or not value:
            return OPTION_UNKNOWN_REFUSED
        options[key] = value
    if "--workspace-root" not in options or "--principal" not in options:
        return OPTION_REQUIRED_REFUSED
    principal = options["--principal"]
    if not Path(options["--workspace-root"]).is_absolute() or principal not in (
        "local-user",
        "host",
    ):
        return OPTION_ROOT_REFUSED
    supplied = tuple(option for option in _HOST_OPTIONS if option in options)
    # The host principal travels with its complete identity; local-user never
    # carries a session, host or role marker.
    if principal == "host" and supplied != _HOST_OPTIONS:
        return OPTION_HOST_REFUSED
    if principal == "local-user" and set(supplied) - {"--author-id"}:
        return OPTION_LOCAL_REFUSED
    return options


def _compose_io(
    options: dict[str, str],
    root: str,
    repository: RepositoryReader | None,
    clock: Clock,
) -> ServiceIO:
    """Compose the installed ports for the validated options; perform host reads only.

    options (dict[str, str]) is the parsed fixed table; root (str) the absolute
    workspace; repository (RepositoryReader | None) the bound reader; clock
    (Clock) the gateway's UTC clock the host composition compares grants with.
    Returns the local-user composition, or the host composition carrying the
    agent id, session, host and role; installed_local_io keeps refusing the host
    principal.
    """
    if options["--principal"] == "host":
        return installed_host_io(
            root,
            repository,
            session_id=options["--session-id"],
            host_name=options["--host-name"],
            agent_id=options["--author-id"],
            agent_role=options["--agent-role"],
            clock=clock,
        )
    return installed_local_io(
        root, repository, "local-user", options.get("--author-id", "local-user")
    )


if __name__ == "__main__":
    raise SystemExit(main())
