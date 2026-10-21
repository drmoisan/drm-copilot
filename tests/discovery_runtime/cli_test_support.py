"""Share memory-only CLI wiring without changing the composition test population."""

from __future__ import annotations

import io
from typing import TYPE_CHECKING

from drm_copilot_discovery.analyzer.registry import InstalledInventoryRegistry
from drm_copilot_discovery.cli import CliPorts, run_cli
from drm_copilot_discovery.models import ParseLimits

from tests.discovery_runtime.gateway_test_support import NOW

if TYPE_CHECKING:
    from collections.abc import Sequence

    from drm_copilot_discovery.gateway import ServiceExecutor

    from tests.discovery_runtime.test_service import MemoryService


CLI_WRAPPERS = (
    "init",
    "configure",
    "profile",
    "inventory",
    "dotnet",
    "vsto",
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
    "validate",
    "coverage-report",
    "parity-report",
    "completion-report",
    "generate-acceptance",
    "generate-acceptance-scenarios",
    "snapshot-export",
    "snapshot-import",
    "import-inventory",
    "migrate",
    "doctor",
)


def memory_ports(store: MemoryService, executor: ServiceExecutor) -> CliPorts:
    """Return CliPorts bound to store (MemoryService) and executor (ServiceExecutor).

    Resolution/factories remain memory-only; no authority or validation is faked by
    this wiring. Provider/executor errors propagate during later calls.
    """
    return CliPorts(
        resolve_workspace=lambda selected: store.disk.root,
        repository_factory=lambda root, identifier: store.repository,
        create_io=lambda root, repository: store,
        clock=lambda: NOW,
        analyzer_registry=InstalledInventoryRegistry(),
        execute_request=executor,
    )


def invoke(
    ports: CliPorts, command: str = "doctor", argv: Sequence[str] = ()
) -> tuple[int, str, str]:
    """Run command (str)/argv (Sequence[str]) with ports (CliPorts) in memory.

    Return tuple[int, str, str] of exit/stdout/stderr. Only injected ports and fresh
    memory streams can change; run_cli owns boundary error handling.
    """
    output, errors = io.StringIO(), io.StringIO()
    code = run_cli(
        command, argv, ports=ports, stdout=output, stderr=errors, limits=ParseLimits()
    )
    return code, output.getvalue(), errors.getvalue()
