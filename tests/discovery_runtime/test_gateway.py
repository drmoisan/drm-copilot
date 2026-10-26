"""Exercise the single-document gateway without files, processes or network."""

from __future__ import annotations

import io
import json
from dataclasses import replace
from typing import TYPE_CHECKING

import pytest
from drm_copilot_discovery import gateway
from drm_copilot_discovery.analyzer.registry import InstalledInventoryRegistry
from drm_copilot_discovery.catalog import CatalogError
from drm_copilot_discovery.models import ParseLimits
from drm_copilot_discovery.resources import ResourceError
from drm_copilot_discovery.schema_validation import validate_document
from drm_copilot_discovery.service_contracts import (
    DiscoveryResult,
    ServiceRuntimeError,
)

from tests.discovery_runtime.gateway_test_support import (
    NOW,
    REQUEST,
    MemoryExecutor,
    invoke,
    result_for,
)
from tests.discovery_runtime.gateway_test_support import (
    installed_schema as installed_schema,
)
from tests.discovery_runtime.test_configuration import config_catalog as config_catalog
from tests.discovery_runtime.test_doctor import IDENTITY

if TYPE_CHECKING:

    from drm_copilot_discovery.catalog import SchemaCatalog
    from drm_copilot_discovery.service_contracts import ServiceIO


@pytest.mark.parametrize("exit_code", [0, 1, 2, 3])
def test_exact_result_and_exit_are_forwarded_once(
    config_catalog: SchemaCatalog,
    exit_code: int,
) -> None:
    """All four service outcome classes preserve one result and a matching exit.
    config_catalog (SchemaCatalog): verified immutable schema fixture. exit_code (int):
    selected supported outcome code. Returns None; memory-only effects; AssertionError
    on mismatch.
    """
    expected = result_for(exit_code)

    code, raw, errors, executor = invoke(config_catalog, result=expected)

    assert code == exit_code and raw == expected.to_json()
    assert raw.endswith("\n") and len(raw.splitlines()) == 1
    assert bool(errors) == bool(exit_code) and len(executor.calls) == 1


@pytest.mark.parametrize(
    "content",
    [
        b'{"operation":"doctor","operation":"profile"}',
        b'{"operation":',
        b'{"x":NaN}',
        b'{"x":Infinity}',
        b'{"x":-Infinity}',
        b'{"x":1e999}',
        b"{}{}",
        b"{} trailing",
        b"[]",
        b"\xff",
        b"",
        b'{"x":' + b"[" * 65 + b"0" + b"]" * 65 + b"}",
    ],
)
def test_malformed_json_is_rejected_before_any_service_call(
    config_catalog: SchemaCatalog,
    content: bytes,
) -> None:
    """Ambiguous, incomplete and over-deep JSON cannot reach trusted collaborators.
    config_catalog (SchemaCatalog): verified immutable schema fixture. content (bytes):
    immutable input or simulated output bytes. Returns None; memory-only effects;
    AssertionError on mismatch.
    """
    code, raw, errors, executor = invoke(config_catalog, content)

    document = json.loads(raw)
    assert code == 2 and document["exit_code"] == 2 and errors
    assert document["operation"] is None and document["runtime"] is None
    assert document["input_manifest"] is None and not document["artifacts"]
    assert not executor.calls


def test_actual_bytes_limit_precedes_parse_and_dispatch(
    config_catalog: SchemaCatalog,
) -> None:
    """Multibyte input is charged by its wire bytes instead of character count.
    config_catalog (SchemaCatalog): verified immutable schema fixture. Returns None;
    memory-only effects; AssertionError on mismatch.
    """
    content = '{"x":"éééééé"}'.encode()

    code, _, _, executor = invoke(
        config_catalog, content, limits=ParseLimits(document_bytes=16)
    )

    assert code == 2 and not executor.calls


@pytest.mark.parametrize(
    "error",
    [
        ServiceRuntimeError(code="RUNTIME_UNAVAILABLE"),
        ServiceRuntimeError(code="RUNTIME_CORRUPT"),
        CatalogError("private-install-location"),
        ResourceError("private-resource-location"),
        OSError("private-host-location"),
    ],
)
def test_provider_failure_is_redacted_with_recognized_context(
    config_catalog: SchemaCatalog,
    error: Exception,
) -> None:
    """Unavailable runtime/I/O emits a schema-valid exit 3 without source text.
    config_catalog (SchemaCatalog): verified immutable schema fixture. error
    (Exception): selected synthetic provider failure. Returns None; memory-only effects;
    AssertionError on mismatch.
    """
    output, errors = io.StringIO(), io.StringIO()

    def fail() -> ServiceIO:
        """Raise the selected provider failure without touching external state."""
        raise error

    code = gateway.run_gateway(
        stdin=io.BytesIO(REQUEST),
        stdout=output,
        stderr=errors,
        create_io=fail,
        repository_reader=None,
        clock=lambda: NOW,
        analyzer_registry=InstalledInventoryRegistry(),
    )

    raw = output.getvalue()
    assert code == 3 and "private-" not in raw + errors.getvalue()
    assert validate_document(
        raw,
        expected_kind="service-result",
        expected_version="2.0.0",
        catalog=config_catalog,
    ).ok
    assert json.loads(raw)["operation"] == "doctor"


def test_short_stream_reads_are_not_treated_as_end_of_input(
    config_catalog: SchemaCatalog,
) -> None:
    """Reject a second JSON document after a short read. config_catalog
    (SchemaCatalog): verified immutable schema fixture. Returns None; memory-only
    effects; AssertionError on mismatch.
    """

    class ShortStream(io.BytesIO):
        """Model a pipe that yields only a few bytes per bounded read."""

        def read(self, size: int | None = -1) -> bytes:
            """Return at most two bytes until true EOF. size (int |
            None): requested bounded read size. Returns bytes; memory-only effects;
            AssertionError on mismatch.
            """
            return super().read(min(size if size is not None else 2, 2))

    source = ShortStream(b"{}{}")

    code, _, _, executor = invoke(config_catalog, source=source)

    assert code == 2 and not executor.calls


def test_nonconforming_stream_cannot_exceed_reserved_capacity(
    config_catalog: SchemaCatalog,
) -> None:
    """An injected broken reader cannot cause unbounded retained input. config_catalog
    (SchemaCatalog): verified immutable schema fixture. Returns None; memory-only
    effects; AssertionError on mismatch.
    """

    class Oversized(io.BytesIO):
        """Model a reader that violates the requested capacity."""

        def read(self, size: int | None = -1) -> bytes:
            """Return one excess byte to test the bound. size (int | None):
            requested bounded read size. Returns bytes; memory-only effects;
            AssertionError on mismatch.
            """
            return b"x" * ((size or 0) + 1)

    code, _, _, executor = invoke(
        config_catalog, source=Oversized(), limits=ParseLimits(document_bytes=8)
    )

    assert code == 2 and not executor.calls


@pytest.mark.parametrize("known", [True, False])
def test_catalog_unavailable_uses_only_fixed_preexecution_shape(
    config_catalog: SchemaCatalog,
    monkeypatch: pytest.MonkeyPatch,
    known: bool,
) -> None:
    """Validate emergency bytes against intact schemas without claiming live checks.
    config_catalog (SchemaCatalog): verified immutable schema fixture. monkeypatch
    (pytest.MonkeyPatch): test-local restoration of injected seams. known (bool):
    whether operation and mode are recognized. Returns None; memory-only effects;
    AssertionError on mismatch.
    """
    failed = replace(
        result_for(2),
        operation="doctor" if known else None,
        mode="structural" if known else None,
        input_manifest=None,
        runtime=None,
    )

    def broken_catalog() -> SchemaCatalog:
        """Model corrupt installation through the exact shared catalog seam."""
        raise CatalogError("private-install-path")

    monkeypatch.setattr(
        "drm_copilot_discovery.service_serialization.load_catalog", broken_catalog
    )
    code, raw, errors, _ = invoke(config_catalog, result=failed)
    assert code == (3 if known else 2)
    assert "private-install-path" not in raw + errors
    assert validate_document(
        raw,
        expected_kind="service-result",
        expected_version="2.0.0",
        catalog=config_catalog,
    ).ok
    assert "fixed failure" in errors


@pytest.mark.parametrize(
    "failure", [CatalogError("unavailable"), ValueError("invalid result")]
)
def test_no_emergency_fallback_for_evaluated_or_invalid_results(
    config_catalog: SchemaCatalog,
    monkeypatch: pytest.MonkeyPatch,
    failure: Exception,
) -> None:
    """Evaluated or invalid results cannot become empty preexecution failures.
    config_catalog (SchemaCatalog): verified immutable schema fixture. monkeypatch
    (pytest.MonkeyPatch): test-local restoration of injected seams. failure (Exception):
    selected synthetic serialization failure. Returns None; memory-only effects;
    AssertionError on mismatch.
    """

    def fail(self: DiscoveryResult) -> str:
        """Reject serialization at its test seam without altering result fields."""
        assert self.runtime == IDENTITY
        raise failure

    monkeypatch.setattr(DiscoveryResult, "to_json", fail)
    code, raw, errors, _ = invoke(config_catalog, validate_wire=False)

    assert code == 3 and not raw and errors


@pytest.mark.parametrize("behavior", ["short", "raise", "flush"])
def test_output_failure_never_appends_a_second_document(
    config_catalog: SchemaCatalog, behavior: str
) -> None:
    """Broken consumers produce fixed diagnostics without a second JSON attempt.
    config_catalog (SchemaCatalog): verified immutable schema fixture. behavior (str):
    selected output-failure mode. Returns None; memory-only effects; AssertionError on
    mismatch.
    """

    class FailedOutput(io.StringIO):
        """Expose one deterministic output boundary failure."""

        def write(self, text: str) -> int:
            """Record one attempted write or fail as selected by the test. text (str):
            proposed output fragment. Returns int; memory-only effects; AssertionError
            on mismatch.
            """
            if behavior == "raise":
                raise OSError("secret-output-path")
            return super().write(text[:1] if behavior == "short" else text)

        def flush(self) -> None:
            """Raise only at the selected final transport flush."""
            if behavior == "flush":
                raise OSError("secret-output-path")

    code, raw, errors, _ = invoke(
        config_catalog, output=FailedOutput(), validate_wire=False
    )

    assert code == 3 and "secret-output-path" not in errors
    assert raw.count('"result_version"') <= 1


@pytest.mark.parametrize(
    "arguments",
    [
        [],
        ["--workspace-root"],
        ["--module", "evil"],
        ["--workspace-root", ".", "--principal", "local-user"],
        ["--workspace-root", "/workspace", "--principal", "caller"],
        ["--workspace-root", "/workspace", "--workspace-root", "/other"],
        [
            "--workspace-root",
            "/workspace",
            "--principal",
            "local-user",
            "--repository-id",
            "INVALID ID",
        ],
    ],
)
def test_fixed_outer_options_reject_arbitrary_dispatch(arguments: list[str]) -> None:
    """Invalid entry arguments cannot select a module, executable or user fallback.
    arguments (list[str]): outer argument rejection case. Returns None; memory-only
    effects; AssertionError on mismatch.
    """
    output, errors = io.StringIO(), io.StringIO()

    code = gateway.main(
        arguments, stdin=io.BytesIO(REQUEST), stdout=output, stderr=errors
    )

    assert code == 2 and json.loads(output.getvalue())["exit_code"] == 2


def test_unexpected_executor_failure_cannot_claim_empty_effects(
    config_catalog: SchemaCatalog,
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """A service programming failure refuses JSON because effects are unknown.
    config_catalog (SchemaCatalog): verified immutable schema fixture. monkeypatch
    (pytest.MonkeyPatch): test-local restoration of injected seams. Returns None;
    memory-only effects; AssertionError on mismatch.
    """
    attempted: list[MemoryExecutor] = []

    def refuse(
        self: MemoryExecutor,
        *args: object,
        **ports: object,
    ) -> DiscoveryResult:
        """Fail after invocation without disclosing the simulated internal error. args
        (object): captured positional test arguments. ports (object): captured keyword
        collaborators. After checking arguments, record the invocation and
        deliberately raise ValueError. This double never returns; effects stay in
        memory.
        """
        assert args and ports["io"]
        attempted.append(self)
        raise ValueError("private-result-validation-failure")

    monkeypatch.setattr(MemoryExecutor, "__call__", refuse)
    code, raw, errors, _ = invoke(config_catalog, validate_wire=False)

    assert code == 3 and not raw and len(attempted) == 1
    assert "no result was emitted" in errors and "private-" not in errors
