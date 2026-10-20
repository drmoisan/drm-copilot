"""Share isolated gateway collaborators without changing test node identities."""

from __future__ import annotations

import io
import json
from datetime import datetime, timezone
from typing import TYPE_CHECKING, cast

import pytest
from drm_copilot_discovery import gateway
from drm_copilot_discovery.analyzer.registry import InstalledInventoryRegistry
from drm_copilot_discovery.findings import Finding
from drm_copilot_discovery.gateway_local import LocalServiceIO
from drm_copilot_discovery.models import JsonObject, ParseLimits
from drm_copilot_discovery.schema_validation import validate_document
from drm_copilot_discovery.service_contracts import DiscoveryResult
from drm_copilot_discovery.snapshot import InputManifest

from tests.discovery_runtime.mutation_test_support import capture
from tests.discovery_runtime.test_activation_store import ConfigurationCase
from tests.discovery_runtime.test_doctor import IDENTITY
from tests.discovery_runtime.test_snapshot_io import PROFILE_PATH, memory_workspace
from tests.schemas.discovery.v2_schema_test_support import as_object

if TYPE_CHECKING:
    from collections.abc import Callable
    from types import TracebackType
    from typing import BinaryIO, Literal

    from drm_copilot_discovery.analyzer.registry import InventoryRegistry
    from drm_copilot_discovery.catalog import SchemaCatalog
    from drm_copilot_discovery.models import JsonValue
    from drm_copilot_discovery.mutation_plan import CapturedWorkspace
    from drm_copilot_discovery.repository_reader import RepositoryReader
    from drm_copilot_discovery.service_contracts import Clock, ServiceIO

REQUEST = b'{"operation":"doctor","mode":"structural"}'
NOW = datetime(2026, 1, 1, tzinfo=timezone.utc)


@pytest.fixture(autouse=True)
def installed_schema(
    config_catalog: SchemaCatalog, monkeypatch: pytest.MonkeyPatch
) -> None:
    """Reuse immutable verified resources while keeping every result validation.
    config_catalog (SchemaCatalog): verified immutable schema fixture. monkeypatch
    (pytest.MonkeyPatch): test-local restoration of injected seams. Returns None;
    memory-only effects; AssertionError on mismatch.
    """
    monkeypatch.setattr(
        "drm_copilot_discovery.service_serialization.load_catalog",
        lambda: config_catalog,
    )


class MemoryExecutor:
    """Record calls against one immutable result without executing a service.

    Construct fresh result/calls state, invoke with trusted collaborators, then
    inspect recorded requests. Only the test-local call list changes; no I/O.
    """

    def __init__(self, result: DiscoveryResult) -> None:
        """Store immutable result and fresh call state without external effects. result
        (DiscoveryResult): typed service outcome to retain or serialize. Returns None;
        memory-only effects; AssertionError on mismatch.
        """
        self.result = result
        self.calls: list[tuple[JsonValue, ServiceIO, RepositoryReader | None]] = []

    def __call__(
        self,
        request: JsonValue,
        *,
        io: ServiceIO,
        repository_reader: RepositoryReader | None,
        clock: Clock,
        analyzer_registry: InventoryRegistry,
    ) -> DiscoveryResult:
        """Return the assigned result after recording exact service arguments. request
        (JsonValue): parsed operation input; no authority is inferred from it. io
        (ServiceIO): trusted workspace I/O ports. repository_reader (RepositoryReader |
        None): exact bound reader, or None when absent. clock (Clock): injected UTC time
        provider. analyzer_registry (InventoryRegistry): fixed trusted analyzer
        selection. Returns DiscoveryResult; memory-only effects; AssertionError on
        mismatch.
        """
        assert clock() == NOW and isinstance(
            analyzer_registry, InstalledInventoryRegistry
        )
        self.calls.append((request, io, repository_reader))
        return self.result


def result_for(exit_code: int = 0) -> DiscoveryResult:
    """Build an outcome from exit_code (int, a supported outcome code).

    Return DiscoveryResult with an observed empty input set; constructor errors
    propagate. Only immutable memory values are allocated.
    """
    return DiscoveryResult(
        operation="doctor",
        mode="structural",
        ok=exit_code == 0,
        exit_code=cast("Literal[0, 1, 2, 3]", exit_code),
        findings=(
            ()
            if exit_code == 0
            else (
                Finding(
                    code="TEST_FAILURE",
                    pointer="/",
                    message="An operation failed.",
                    next_action="Correct the test input.",
                ),
            )
        ),
        artifacts=(),
        runtime=IDENTITY,
        input_manifest=InputManifest(files=()),
        summary=JsonObject(
            (
                ("message", "Observed test operation."),
                ("counts", ()),
                ("validation_result", None),
                ("receipt_ref", None),
                ("invocation_ref", None),
            )
        ),
    )


def invoke(
    catalog: SchemaCatalog,
    content: bytes = REQUEST,
    *,
    result: DiscoveryResult | None = None,
    limits: ParseLimits | None = None,
    source: BinaryIO | None = None,
    output: io.StringIO | None = None,
    validate_wire: bool = True,
) -> tuple[int, str, str, MemoryExecutor]:
    """Run memory streams through the real gateway with a typed executor seam. catalog
    (SchemaCatalog): verified immutable schema catalog. content (bytes): immutable input
    or simulated output bytes. result (DiscoveryResult | None): typed service outcome to
    retain or serialize. limits (ParseLimits | None): trusted finite parse capacities or
    default policy. source (BinaryIO | None): optional bounded binary stream double.
    output (io.StringIO | None): optional memory result stream. validate_wire (bool):
    whether a complete JSON result is expected. Returns tuple[int, str, str,
    MemoryExecutor]; memory-only effects; AssertionError on mismatch.
    """
    case = ConfigurationCase(catalog)
    ports = LocalServiceIO(
        activation=case.service,
        repository=None,
        principal="local-user",
        author_id="test-user",
        identity=lambda: IDENTITY,
    )
    executor = MemoryExecutor(result or result_for())
    output = io.StringIO() if output is None else output
    errors = io.StringIO()
    code = gateway.run_gateway(
        stdin=io.BytesIO(content) if source is None else source,
        stdout=output,
        stderr=errors,
        create_io=lambda: ports,
        repository_reader=None,
        clock=lambda: NOW,
        analyzer_registry=InstalledInventoryRegistry(),
        limits=limits,
        execute_request=executor,
    )
    raw = output.getvalue()
    if validate_wire:
        assert validate_document(
            raw,
            expected_kind="service-result",
            expected_version="2.0.0",
            catalog=catalog,
        ).ok
    return code, raw, errors.getvalue(), executor


def memory_io(
    catalog: SchemaCatalog,
    *,
    repository: RepositoryReader | None = None,
) -> tuple[ConfigurationCase, LocalServiceIO, CapturedWorkspace]:
    """Bind the local adapter to a fresh memory workspace. catalog
    (SchemaCatalog): immutable schema catalog. repository (RepositoryReader |
    None): exact optional repository reader. Returns tuple[ConfigurationCase,
    LocalServiceIO, CapturedWorkspace]; memory-only effects; AssertionError on mismatch.
    """
    case = ConfigurationCase(catalog)
    _, document = memory_workspace()
    document["profile_state"] = "draft"
    as_object(document["repository"])["revision"] = None
    case.disk.store.put(PROFILE_PATH, json.dumps(document).encode())
    baseline = capture(case.disk.store, catalog)
    local = LocalServiceIO(
        activation=case.service,
        repository=repository,
        principal="local-user",
        author_id="test-user",
        identity=lambda: IDENTITY,
    )
    return case, local, baseline


class MemoryProcess:
    """Model context/read/wait/cleanup transitions without a native process.

    stdout is bounded memory or None; code is fixed. finished and killed start
    false, then record wait/kill calls independently. Each test owns one instance.
    """

    def __init__(self, content: bytes, *, code: int = 0, pipe: bool = True) -> None:
        """Retain content (bytes), code (int status) and pipe (bool availability).

        Return None; initialize isolated output and completion flags without I/O.
        """
        self.stdout = io.BytesIO(content) if pipe else None
        self.code, self.finished, self.killed = code, False, False

    def __enter__(self) -> MemoryProcess:
        """Return this test-local process handle without acquiring resources."""
        return self

    def __exit__(
        self,
        kind: type[BaseException] | None,
        value: BaseException | None,
        traceback: TracebackType | None,
    ) -> None:
        """Model deterministic context closure; no external resources exist. kind
        (type[BaseException] | None): context-exit exception type, if any. value
        (BaseException | None): context-exit exception instance, or None when no
        exception occurred.
        traceback (TracebackType | None): context-exit traceback, if any. Returns None;
        no state changes or exception suppression occurs.
        """

    def wait(self, timeout: float | None = None) -> int:
        """Complete the fake wait with timeout (float | None, seconds).

        Return the selected int status; the synthetic -2 status with a timeout
        raises TimeoutError. Only the local completion flag changes.
        """
        if self.code == -2 and timeout is not None:
            raise TimeoutError("fixed timeout")
        self.finished = True
        return self.code

    def poll(self) -> int | None:
        """Report completion without sleeping or reading a wall clock."""
        return self.code if self.finished else None

    def kill(self) -> None:
        """Record termination after rejection or expiry; return None without I/O."""
        self.killed = True


class MemoryDeadline:
    """Record deadline arming/cancellation and fire only under explicit test control.

    Construct with a callback, start before a pipe read, optionally fire, then
    cancel/join. No thread, timer, clock or process is used; state is per test.
    """

    def __init__(self, interval: float, function: Callable[[], None]) -> None:
        """Retain interval (float seconds) and function (cancellation callback).

        Return None; only memory flags initialize. An unexpected interval raises
        AssertionError, ensuring the fixed process policy cannot drift silently.
        """
        assert interval == 30
        self.function = function
        self.daemon = self.started = self.cancelled = self.joined = False

    def start(self) -> None:
        """Mark the deadline armed; return None without starting a real timer."""
        self.started = True

    def fire(self) -> None:
        """Run cancellation after arming; return None and propagate callback errors."""
        assert self.started and not self.cancelled
        self.function()

    def cancel(self) -> None:
        """Record cancellation; return None without altering an already fired call."""
        self.cancelled = True

    def join(self) -> None:
        """Record callback completion; return None without scheduling or waiting."""
        self.joined = True


@pytest.fixture
def fixed_deadline(monkeypatch: pytest.MonkeyPatch) -> list[MemoryDeadline]:
    """Inject manual timers through monkeypatch (pytest.MonkeyPatch).

    Return the test-local list of MemoryDeadline instances for call-order checks.
    Only the Timer seam is patched and automatically restored; no threads run.
    """
    timers: list[MemoryDeadline] = []

    def create(interval: float, function: Callable[[], None]) -> MemoryDeadline:
        """Record interval (float) and function (callback); return a manual timer.

        Only the owning list changes; invalid policy raises AssertionError.
        """
        timer = MemoryDeadline(interval, function)
        timers.append(timer)
        return timer

    monkeypatch.setattr("drm_copilot_discovery.gateway_local.threading.Timer", create)
    return timers
