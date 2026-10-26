"""Compose fixed noninteractive console commands with the installed service."""

from __future__ import annotations

import sys
from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path
from typing import TYPE_CHECKING, cast

from drm_copilot_discovery.analyzer.registry import InstalledInventoryRegistry
from drm_copilot_discovery.cli_arguments import (
    CliError,
    CliHelp,
    build_cli_request,
    parse_cli_arguments,
)
from drm_copilot_discovery.findings import Finding
from drm_copilot_discovery.gateway_local import installed_local_io
from drm_copilot_discovery.models import JsonObject, ParseLimits
from drm_copilot_discovery.repository_binding import installed_repository
from drm_copilot_discovery.service_contracts import DiscoveryResult, ServiceRuntimeError

if TYPE_CHECKING:
    from collections.abc import Callable, Sequence
    from typing import Literal, TextIO

    from drm_copilot_discovery.analyzer.registry import InventoryRegistry
    from drm_copilot_discovery.gateway import ServiceExecutor
    from drm_copilot_discovery.models import JsonValue
    from drm_copilot_discovery.repository_reader import RepositoryReader
    from drm_copilot_discovery.service_contracts import (
        Clock,
        Mode,
        Operation,
        ServiceIO,
    )


@dataclass(frozen=True, kw_only=True)
class CliPorts:
    """Bind trusted composition seams without invoking them or granting authority.

    Construct once per invocation. resolve_workspace (Callable[[str], str])
    canonicalizes the directory; repository_factory (Callable[[str, str | None],
    RepositoryReader | None]) binds the explicit ID, or the activated profile's
    Git repository when none is given, or returns None; create_io (Callable[[str,
    RepositoryReader | None], ServiceIO]) receives that exact reader. clock
    (Clock), analyzer_registry (InventoryRegistry) and execute_request
    (ServiceExecutor) are forwarded unchanged. Frozen references select no
    request-supplied implementation. Construction performs no I/O; providers own
    their effects/errors and must preserve the installed local-user boundary.
    """

    resolve_workspace: Callable[[str], str]
    repository_factory: Callable[[str, str | None], RepositoryReader | None]
    create_io: Callable[[str, RepositoryReader | None], ServiceIO]
    clock: Clock
    analyzer_registry: InventoryRegistry
    execute_request: ServiceExecutor


def _failure(
    operation: Operation | None,
    mode: Mode | None,
    *,
    exit_code: Literal[2, 3] = 2,
    findings: tuple[Finding, ...] = (),
    code: str = "CLI_REQUEST",
) -> DiscoveryResult:
    """Return a fixed pre-execution refusal without claiming workspace effects.

    operation (Operation | None) and mode (Mode | None) retain recognized context;
    exit_code (Literal[2, 3]) distinguishes invocation/runtime refusal. findings
    (tuple[Finding, ...]) retains parser diagnostics; code (str) selects the fixed
    anchored diagnostic required for every pre-execution refusal. Constructor
    errors propagate. No I/O or authority occurs.
    """
    return DiscoveryResult(
        operation=operation,
        mode=mode,
        ok=False,
        exit_code=exit_code,
        findings=findings
        + (
            Finding(
                code=code,
                pointer="/",
                message="The discovery command could not be started.",
                next_action="Check the command options, workspace and installation.",
            ),
        ),
        artifacts=(),
        summary=JsonObject(
            (
                ("message", "Discovery command refused."),
                ("counts", ()),
                ("validation_result", None),
                ("receipt_ref", None),
                ("invocation_ref", None),
            )
        ),
        input_manifest=None,
        runtime=None,
    )


def _write(text: str, output: TextIO) -> None:
    """Write text (str) once to output (TextIO), then flush; return None.

    A short write raises OSError; stream failures propagate. Only the supplied
    stream changes. The caller must not append a replacement after partial output.
    """
    if output.write(text) != len(text):
        raise OSError("Incomplete discovery output")
    output.flush()


def _emit(result: DiscoveryResult, stdout: TextIO, stderr: TextIO) -> int:
    """Emit result (DiscoveryResult) as one validated LF JSON; return its exit.

    stdout (TextIO) receives the complete serialization once; stderr (TextIO)
    receives a fixed failure notice. Serialization/stream errors propagate to
    run_cli, which never fabricates a replacement result after execution.
    """
    _write(result.to_json(), stdout)
    if result.exit_code:
        _write("Discovery command failed; inspect the JSON findings.\n", stderr)
    return result.exit_code


def run_cli(
    command: str,
    argv: Sequence[str],
    *,
    ports: CliPorts,
    stdout: TextIO,
    stderr: TextIO,
    limits: ParseLimits,
) -> int:
    """Parse once, bind one canonical workspace and execute the fixed service.

    command (str) is a registered suffix; argv (Sequence[str]) contains bounded
    option tokens. ports (CliPorts) supplies trusted providers, stdout/stderr
    (TextIO) receive results/diagnostics and limits (ParseLimits) bounds parsing.
    Return int: help 0, invocation 2, runtime/output failure 3, or the typed service
    exit. Help/errors invoke no providers. Execution may publish through supplied
    ports; unexpected failures retain unknown effects and emit only fixed stderr.
    """
    try:
        parsed = parse_cli_arguments(command, argv, limits=limits)
        # Help and malformed argv must stop before any workspace/provider access.
        if isinstance(parsed, CliHelp):
            _write(parsed.text, stdout)
            return 0
        if isinstance(parsed, CliError):
            return _emit(
                _failure(parsed.operation, parsed.mode, findings=parsed.findings),
                stdout,
                stderr,
            )
        operation = cast("Operation", parsed.request["operation"])
        mode = cast("Mode", parsed.request["mode"])
        try:
            root = ports.resolve_workspace(
                cast("str", parsed.request["workspace_root"])
            )
            request = build_cli_request(parsed, workspace_root=root, limits=limits)
        except (OSError, ValueError):
            return _emit(
                _failure(operation, mode, code="CLI_WORKSPACE"), stdout, stderr
            )
        # One reader instance binds both capture/I/O and authoritative execution;
        # the factory derives the configured repository when no id was given.
        try:
            repository = ports.repository_factory(root, parsed.repository_id)
            io = ports.create_io(root, repository)
        except ServiceRuntimeError as error:
            return _emit(
                _failure(operation, mode, exit_code=3, code=error.code), stdout, stderr
            )
        except (OSError, ValueError):
            return _emit(
                _failure(operation, mode, exit_code=3, code="CLI_RUNTIME"),
                stdout,
                stderr,
            )
        result = ports.execute_request(
            request,
            io=io,
            repository_reader=repository,
            clock=ports.clock,
            analyzer_registry=ports.analyzer_registry,
        )
        return _emit(result, stdout, stderr)
    except Exception:  # noqa: BLE001 - CLI top-level error handling
        # Execution/output may already have effects; a new empty envelope would lie.
        try:
            stderr.write("Discovery CLI failed; no replacement result was emitted.\n")
            stderr.flush()
        except (OSError, UnicodeError, ValueError):
            return 3
        return 3


def _resolve_workspace(selected: str) -> str:
    """Resolve selected (str) directory once; return canonical absolute str.

    Only this explicit directory is considered. OSError/ValueError rejects a
    missing/non-directory root. Reads filesystem metadata, never writes files.
    """
    root = Path(selected).resolve(strict=True)
    if not root.is_dir():
        raise ValueError("Select an existing workspace directory")
    return root.as_posix()


def _repository(root: str, identifier: str | None) -> RepositoryReader | None:
    """Bind root (str) and identifier (str | None) to one fixed LocalGitReader.

    Return RepositoryReader without executing Git, or None when neither an
    explicit nor a configured Git identity exists. Invalid identities/roots raise
    ValueError; later reads use only the installed bounded Git command seam.
    """
    return installed_repository(root, identifier)


def _create_io(root: str, repository: RepositoryReader | None) -> ServiceIO:
    """Create installed local-user ports for root (str) and exact optional reader.

    repository (RepositoryReader | None) is forwarded unchanged. Return ServiceIO;
    installed provider errors propagate. Installed metadata may be read, but no
    workspace mutation or native-host authority is requested.
    """
    return installed_local_io(root, repository, "local-user", "local-user")


def _clock() -> datetime:
    """Return current aware UTC datetime for installed execution; read clock only."""
    return datetime.now(timezone.utc)


def _execute(
    request: JsonValue,
    *,
    io: ServiceIO,
    repository_reader: RepositoryReader | None,
    clock: Clock,
    analyzer_registry: InventoryRegistry,
) -> DiscoveryResult:
    """Lazily call the installed service after parsing and provider construction.

    request (JsonValue) is the closed request; io (ServiceIO), repository_reader
    (RepositoryReader | None), clock (Clock) and analyzer_registry
    (InventoryRegistry) are forwarded unchanged. Return DiscoveryResult, retaining
    service effects/errors. No request-selected module or host fallback exists.
    """
    from drm_copilot_discovery.service import execute

    return execute(
        request,
        io=io,
        repository_reader=repository_reader,
        clock=clock,
        analyzer_registry=analyzer_registry,
    )


def run_installed_cli(command: str, argv: Sequence[str] | None = None) -> int:
    """Run command (str) with the installed local-user composition; return int.

    argv (Sequence[str] | None) supplies option tokens unchanged, or None selects
    process arguments with count-before-slice reservation. Inputs and sys.argv
    are never mutated. Unknown commands refuse before provider access. The fixed
    lazy service receives the existing ports and process output streams; run_cli
    owns invocation/runtime exits and any authorized workspace effects.
    """
    limits = ParseLimits()
    arguments = argv
    # Explicit vectors reach the bounded parser uncopied; only process argv drops
    # its executable token, after reserving the reference copy by count.
    if arguments is None:
        arguments = (
            sys.argv if len(sys.argv) > limits.artifact_records + 1 else sys.argv[1:]
        )
    return run_cli(
        command,
        arguments,
        ports=CliPorts(
            resolve_workspace=_resolve_workspace,
            repository_factory=_repository,
            create_io=_create_io,
            clock=_clock,
            analyzer_registry=InstalledInventoryRegistry(),
            execute_request=_execute,
        ),
        stdout=sys.stdout,
        stderr=sys.stderr,
        limits=limits,
    )


def _main(command: str) -> int:
    """Forward fixed command (str) to the public installed entry; return its exit.

    Keep existing zero-argument wrappers and the run_cli patch seam compatible.
    The installed entry owns process arguments, output and service effects.
    """
    return run_installed_cli(command)


def main_init() -> int:
    """Return init exit using process argv/streams and fixed local service ports."""
    return _main("init")


def main_configure() -> int:
    """Return configure exit using process argv/streams and fixed local ports."""
    return _main("configure")


def main_profile() -> int:
    """Return profile exit using process argv/streams and fixed local ports."""
    return _main("profile")


def main_inventory() -> int:
    """Return inventory exit using process argv/streams and fixed local ports."""
    return _main("inventory")


def main_dotnet() -> int:
    """Return dotnet alias exit using process argv/streams and fixed local ports."""
    return _main("dotnet")


def main_vsto() -> int:
    """Return vsto alias exit using process argv/streams and fixed local ports."""
    return _main("vsto")


def main_new_contract() -> int:
    """Return new-contract exit using process argv/streams and fixed local ports."""
    return _main("new-contract")


def main_new_scenario() -> int:
    """Return new-scenario exit using process argv/streams and fixed local ports."""
    return _main("new-scenario")


def main_update_artifact() -> int:
    """Return update-artifact exit using process argv/streams and fixed local ports."""
    return _main("update-artifact")


def main_link_evidence() -> int:
    """Return link-evidence exit using process argv/streams and fixed local ports."""
    return _main("link-evidence")


def main_validate_profile() -> int:
    """Return validate-profile exit using process argv/streams and fixed local ports."""
    return _main("validate-profile")


def main_validate_feature_contract() -> int:
    """Return feature validation exit using process argv/streams and fixed ports."""
    return _main("validate-feature-contract")


def main_validate_coverage_ledger() -> int:
    """Return ledger validation exit using process argv/streams and fixed ports."""
    return _main("validate-coverage-ledger")


def main_validate_runtime_scenario() -> int:
    """Return scenario validation exit using process argv/streams and fixed ports."""
    return _main("validate-runtime-scenario")


def main_validate_parity_matrix() -> int:
    """Return parity validation exit using process argv/streams and fixed ports."""
    return _main("validate-parity-matrix")


def main_validate_unspecified_behavior() -> int:
    """Return unresolved validation exit using process argv/streams and fixed ports."""
    return _main("validate-unspecified-behavior")


def main_validate_product_decision() -> int:
    """Return decision validation exit using process argv/streams and fixed ports."""
    return _main("validate-product-decision")


def main_validate_evidence_reference() -> int:
    """Return evidence validation exit using process argv/streams and fixed ports."""
    return _main("validate-evidence-reference")


def main_validate_decisions() -> int:
    """Return decisions validation exit using process argv/streams and fixed ports."""
    return _main("validate-decisions")


def main_validate_all() -> int:
    """Return workspace validation exit using process argv/streams and fixed ports."""
    return _main("validate-all")


def main_validate() -> int:
    """Return validate alias exit using process argv/streams and fixed local ports."""
    return _main("validate")


def main_coverage_report() -> int:
    """Return coverage report exit using process argv/streams and fixed local ports."""
    return _main("coverage-report")


def main_parity_report() -> int:
    """Return parity report exit using process argv/streams and fixed local ports."""
    return _main("parity-report")


def main_completion_report() -> int:
    """Return completion report exit using process argv/streams and fixed ports."""
    return _main("completion-report")


def main_generate_acceptance() -> int:
    """Return acceptance generation exit using process argv/streams and fixed ports."""
    return _main("generate-acceptance")


def main_generate_acceptance_scenarios() -> int:
    """Return acceptance alias exit using process argv/streams and fixed local ports."""
    return _main("generate-acceptance-scenarios")


def main_snapshot_export() -> int:
    """Return snapshot export exit using process argv/streams and fixed local ports."""
    return _main("snapshot-export")


def main_snapshot_import() -> int:
    """Return snapshot import exit using process argv/streams and fixed local ports."""
    return _main("snapshot-import")


def main_import_inventory() -> int:
    """Return extension import exit using process argv/streams and fixed ports."""
    return _main("import-inventory")


def main_migrate() -> int:
    """Return migration exit using process argv/streams and fixed local ports."""
    return _main("migrate")


def main_doctor() -> int:
    """Return doctor exit using process argv/streams and fixed local service ports."""
    return _main("doctor")
