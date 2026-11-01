"""Exercise service authority, capture and inspection with isolated memory stores."""

from __future__ import annotations

import json
from datetime import UTC, datetime
from hashlib import sha256
from typing import TYPE_CHECKING, Literal, NoReturn, cast

import pytest
from drm_copilot_discovery import service
from drm_copilot_discovery.analyzer.input_capture import pin_inventory_sources
from drm_copilot_discovery.analyzer.registry import InstalledInventoryRegistry
from drm_copilot_discovery.catalog import CatalogError
from drm_copilot_discovery.configuration import (
    DEFAULT_PROFILE,
    LOCATOR_PATH,
    ActivationRecord,
    locator_bytes,
)
from drm_copilot_discovery.init_flow import plan_initialization
from drm_copilot_discovery.init_io import InitializationIO
from drm_copilot_discovery.init_projection import InitializationRequest
from drm_copilot_discovery.models import ParseLimits
from drm_copilot_discovery.mutation_io import GuardedMutationWriter, capture_workspace
from drm_copilot_discovery.report_models import bounded_object
from drm_copilot_discovery.service import execute
from drm_copilot_discovery.service_contracts import (
    DiscoveryResult,
    RuntimeIdentity,
    ServiceAuthority,
    ServiceRuntimeError,
)
from drm_copilot_discovery.source_read_models import ReadGrant, ReadSelection

from tests.discovery_runtime.initialization_test_support import (
    MemoryRepository,
)
from tests.discovery_runtime.initialization_test_support import (
    initialization_catalog as initialization_catalog,
)
from tests.discovery_runtime.initialization_test_support import (
    initialization_templates as initialization_templates,
)
from tests.discovery_runtime.test_activation_store import ConfigurationCase

if TYPE_CHECKING:
    from drm_copilot_discovery.catalog import SchemaCatalog
    from drm_copilot_discovery.init_flow import InitializationPlan
    from drm_copilot_discovery.init_projection import InitializationTemplates
    from drm_copilot_discovery.mutation_io import MutationWriter
    from drm_copilot_discovery.mutation_plan import CapturedWorkspace
    from drm_copilot_discovery.path_models import WriteGrant
    from drm_copilot_discovery.service_contracts import ServiceRequest


class MemoryService:
    """Bind real capture/activation/write algorithms to a fresh memory filesystem.

    Each test owns its mutable store, principal and counters. The synthetic
    RuntimeIdentity tests only an injected verified-provider contract; it is
    never an installed-runtime or native host verification claim.
    """

    def __init__(self, catalog: SchemaCatalog) -> None:
        """Bind SchemaCatalog and fresh memory seams; return None, no external I/O."""
        self.configuration = ConfigurationCase(catalog)
        self.disk = self.configuration.disk
        self.repository = MemoryRepository()
        self.initialization = InitializationIO(
            workspace_root=self.disk.root,
            catalog=catalog,
            metadata=self.disk.store.metadata,
            read_bytes=self.disk.store.read,
            primitives=self.disk.provider(),
            open_directory=self.disk.open,
            invalidate_authority=self.configuration.revoke,
            repository=self.repository,
        )
        self.activation = self.configuration.service
        self.principal: Literal["local-user", "host"] = "local-user"
        self.grants: tuple[WriteGrant, ...] = ()
        self.selection: ReadSelection | None = None
        self.runtime_error = False
        self.authorization_calls = 0
        self.writer_calls = 0

    def runtime_identity(self) -> RuntimeIdentity:
        """Return synthetic verified-provider data or fixed failure; no external I/O."""
        if self.runtime_error:
            raise ServiceRuntimeError(code="RUNTIME_CORRUPT")
        return RuntimeIdentity(
            package_version="2.0.0",
            schema_version="2.0.0",
            build_sha256="a" * 64,
            policy_version=1,
            policy_sha256="b" * 64,
        )

    def authorize(
        self, request: ServiceRequest, *, baseline: CapturedWorkspace | None
    ) -> ServiceAuthority:
        """Authenticate test-owned request/baseline; count calls and return authority.

        Parameters are typed trusted seam inputs; neither changes the preset
        principal or grants. No disk/network/native authority is established.
        """
        self.authorization_calls += 1
        return ServiceAuthority(
            principal=self.principal,
            author_or_agent="operator",
            invocation=None,
            grants=self.grants,
            read_selection=self.selection,
        )

    def writer(
        self, baseline: CapturedWorkspace, *, authority: ServiceAuthority
    ) -> MutationWriter:
        """Return the real guarded writer for typed baseline/authority; count use.

        Recapture preserves the baseline's exact optional pin augmentation.
        Only memory primitives can change; accepted writer failures propagate.
        """
        self.writer_calls += 1

        def capture() -> CapturedWorkspace:
            """Recapture the exact bound profile and pins in memory; return capture."""
            value = capture_workspace(
                workspace_root=self.disk.root,
                profile_path=baseline.snapshot.profile.artifacts["profile"],
                metadata=self.disk.store.metadata,
                read_bytes=self.disk.store.read,
                catalog=self.initialization.catalog,
                repository=self.repository,
            )
            if value.snapshot.repository_files != baseline.snapshot.repository_files:
                value = pin_inventory_sources(value, self.repository)
            return value

        return GuardedMutationWriter(
            capture=capture,
            invalidate_authority=self.configuration.revoke,
            primitives=self.disk.provider(),
        )

    def activate(self) -> None:
        """Install a fresh matching protected test record; return None, memory only."""
        content = self.disk.store.files[DEFAULT_PROFILE]
        locator = locator_bytes(DEFAULT_PROFILE)
        self.disk.store.put(LOCATOR_PATH, locator)
        self.configuration.registry.raw = ActivationRecord(
            workspace_sha256=self.configuration.location.workspace_sha256,
            generation=1,
            action="activate",
            profile_path=DEFAULT_PROFILE,
            profile_sha256=sha256(content).hexdigest(),
            locator_sha256=sha256(locator).hexdigest(),
            previous_sha256=None,
        ).encode()


@pytest.fixture(scope="module")
def service_plan(
    initialization_catalog: SchemaCatalog,
    initialization_templates: InitializationTemplates,
) -> InitializationPlan:
    """Return one immutable real plan from catalog/templates; no external mutation."""
    io = MemoryService(initialization_catalog)
    io.disk.store.metadata.add("application", kind="directory")
    return plan_initialization(
        InitializationRequest(
            system_id="consumer-system",
            system_name="Consumer system",
            role="combined",
            repository_id="consumer-repository",
            production_roots=("application",),
            test_roots=("verification",),
            documentation_roots=("proposals",),
        ),
        io=io.initialization,
        templates=initialization_templates,
    )


@pytest.fixture
def service_io(
    initialization_catalog: SchemaCatalog, service_plan: InitializationPlan
) -> MemoryService:
    """Return fresh physical memory inputs from immutable catalog/plan; no real I/O."""
    io = MemoryService(initialization_catalog)
    # Seed only the immutable proposal's complete graph, then authenticate activation.
    for path in service_plan.directories + ("application", "verification", "proposals"):
        io.disk.store.metadata.add(path, kind="directory")
    # Each test receives independent mutable file state, including exact profile bytes.
    for file in service_plan.mutation.prospective.manifest.files:
        io.disk.store.put(file.path, file.content)
    # Graph operations require explicit configured clients and analyzer consent.
    profile = json.loads(io.disk.store.files[DEFAULT_PROFILE])
    profile["profile_state"] = "configured"
    profile["clients"] = [
        {
            "id": "browser",
            "target_repository": "consumer-repository",
            "platforms": ["web"],
            "modes": ["online"],
            "required_feature_dimensions": [],
            "applicability_defaults": {},
        }
    ]
    profile["analyzers"]["enabled"] = ["repository"]
    io.disk.store.put(DEFAULT_PROFILE, json.dumps(profile).encode("utf-8"))
    io.activate()
    return io


def invoke(
    io: MemoryService,
    operation: str,
    inputs: object = None,
    **fields: object,
) -> DiscoveryResult:
    """Execute fixed operation/inputs/field overrides with memory io; return result.

    Malformed dictionaries are intentionally passed through the real bounded
    parser. Clock and registry are deterministic; writes affect memory only.
    """
    request: dict[str, object] = {
        "$schema": "urn:drm-copilot:discovery:2.0.0:service-request",
        "schema_version": "2.0.0",
        "artifact_kind": "service-request",
        "id": "request",
        "request_id": "correlation",
        "operation": operation,
        "mode": "structural",
        "workspace_root": io.disk.root,
        "profile_path": None,
        "dry_run": False,
        "write": False,
        "format": "json",
        "inputs": inputs or {},
        "invocation_ref": None,
        "authorization_ref": None,
    }
    request.update(fields)
    return execute(
        bounded_object(request, limits=ParseLimits()),
        io=io,
        repository_reader=io.repository,
        clock=lambda: datetime(2026, 10, 20, tzinfo=UTC),
        analyzer_registry=InstalledInventoryRegistry(),
    )


@pytest.mark.parametrize(
    "fields",
    [
        {"operation": "unknown"},
        {"mode": "unknown"},
        {"inputs": {"shell": "secret"}},
        {"dry_run": 1},
        {"format": "html"},
    ],
)
def test_malformed_request_stops_before_authority(
    service_io: MemoryService,
    fields: dict[str, object],
) -> None:
    """Reject field overrides before trusted calls; return None, memory state
    unchanged.
    """
    before = dict(service_io.disk.store.files)
    operation = cast("str", fields.get("operation", "profile"))
    # Keep the operation positional while preserving every other malformed field.
    remaining = {key: value for key, value in fields.items() if key != "operation"}
    result = invoke(service_io, operation, **remaining)
    assert result.exit_code == 2 and not result.ok and result.artifacts == ()
    assert service_io.authorization_calls == service_io.writer_calls == 0
    assert service_io.disk.store.files == before
    assert "secret" not in result.to_json()


@pytest.mark.parametrize("marker", ["host", "invocation_ref", "authorization_ref"])
def test_explicit_host_or_spoofed_reference_never_falls_back(
    service_io: MemoryService,
    marker: str,
) -> None:
    """Reject marker (str) without source/write authority; return None, memory only."""
    fields: dict[str, object] = {}
    if marker == "host":
        service_io.principal = "host"
    else:
        fields[marker] = "opaque-but-not-authority"
    result = invoke(service_io, "profile", **fields)
    assert result.exit_code == 3
    assert result.findings[0].code == "SERVICE_AUTHORITY"
    assert service_io.writer_calls == 0 and result.input_manifest is None


def test_installed_identity_failure_is_not_a_resource_only_success(
    service_io: MemoryService,
) -> None:
    """Use failing MemoryService identity; return None without fallback or mutation."""
    service_io.runtime_error = True
    result = invoke(service_io, "profile")
    assert (
        result.exit_code == 3
        and result.runtime is None
        and result.input_manifest is None
    )
    assert result.findings[0].code == "RUNTIME_CORRUPT"
    assert service_io.authorization_calls == 0


@pytest.mark.parametrize("operation", ["profile", "validate-profile"])
def test_profile_operations_preserve_v2_and_actual_manifest(
    service_io: MemoryService,
    operation: str,
) -> None:
    """Validate selected v2 bytes for operation; return None without memory writes."""
    before = dict(service_io.disk.store.files)
    result = invoke(service_io, operation, {"input_path": DEFAULT_PROFILE})
    assert result.ok and result.input_manifest is not None
    assert result.input_manifest.files[0].content == before[DEFAULT_PROFILE]
    assert len(result.artifacts) == (operation == "profile")
    assert before == service_io.disk.store.files and service_io.writer_calls == 0


@pytest.mark.parametrize("valid", [True, False])
def test_true_v1_profile_uses_legacy_parser_without_inventing_v2_capture(
    service_io: MemoryService,
    valid: bool,
) -> None:
    """Parse v1 valid/invalid bytes in memory; return None with honest compatibility."""
    content = (
        b"profile_version: 1\nlegacy_source: {root: old}\ntarget: {root: new}\n"
        b"technology_stack: {legacy: [csharp]}\nartifacts: {root: discovery/}\n"
    )
    if not valid:
        content = b"profile_version: 1\n"
    service_io.disk.store.put("proposals/legacy.yaml", content)
    result = invoke(
        service_io, "validate-profile", {"input_path": "proposals/legacy.yaml"}
    )
    assert result.exit_code == (0 if valid else 1)
    assert result.input_manifest is not None
    assert result.input_manifest.files[0].content == content
    assert result.input_manifest.source_repositories == ()


@pytest.mark.parametrize("operation", ["list", "read", "search"])
def test_source_page_preserves_authorized_bytes_and_line_identity(
    service_io: MemoryService,
    operation: str,
) -> None:
    """Inspect operation (str) over exact memory grants; return None without writes."""
    path = "application/a.cs"
    service_io.disk.store.put(path, b"first\nneedle\nthird\n")
    service_io.repository.files[path] = service_io.disk.store.files[path]
    service_io.selection = ReadSelection(grants=(ReadGrant(path=path),))
    inputs: dict[str, object] = {"read_operation": operation, "paths": [path]}
    if operation == "search":
        inputs["query"] = "needle"
    if operation == "read":
        inputs.update(line_start=2, line_end=2)
    result = invoke(service_io, "read-source", inputs)
    assert result.ok, result.findings
    rows = cast("tuple[object, ...]", result.summary["source_reads"])
    assert len(rows) == 1 and service_io.writer_calls == 0
    assert result.input_manifest is not None
    assert any(file.path == path for file in result.input_manifest.files)
    assert "needle" in result.to_json() or operation == "list"


@pytest.mark.parametrize(
    "operation",
    [
        "validate-feature-contract",
        "validate-coverage-ledger",
        "validate-runtime-scenario",
        "validate-parity-matrix",
        "validate-unspecified-behavior",
        "validate-product-decision",
        "validate-evidence-reference",
    ],
)
def test_individual_kind_failure_does_not_hide_graph_wide_blockers(
    service_io: MemoryService,
    operation: str,
) -> None:
    """Validate a wrong-kind captured path; return None with original and graph
    findings.
    """
    result = invoke(service_io, operation, {"artifact_path": DEFAULT_PROFILE})
    assert result.exit_code == 1 and result.findings
    assert result.summary["counts"] and service_io.writer_calls == 0
    assert result.input_manifest is not None


@pytest.mark.parametrize("selector", [None, ["repository"]])
def test_inventory_selection_retains_captured_source_hash(
    service_io: MemoryService,
    selector: list[str] | None,
) -> None:
    """Analyze selector using real registry/capture; return None without publication."""
    inputs: dict[str, object] = {} if selector is None else {"analyzer_ids": selector}
    result = invoke(service_io, "inventory", inputs)
    assert result.exit_code in (0, 1) and len(result.artifacts) == 1
    value = json.loads(result.artifacts[0].content or "")
    assert value["artifact_kind"] == "inventory-snapshot"
    assert service_io.writer_calls == 0 and result.input_manifest is not None


def test_source_without_independent_selection_is_unavailable(
    service_io: MemoryService,
) -> None:
    """Refuse an ungranted source path in MemoryService; return None without row
    leakage.
    """
    result = invoke(
        service_io, "read-source", {"read_operation": "list", "paths": ["application"]}
    )
    assert result.exit_code == 3 and not result.artifacts
    assert "source_reads" not in result.summary


def test_doctor_uses_verified_runtime_without_claiming_native_capability(
    service_io: MemoryService,
) -> None:
    """Use public doctor dispatch over memory io; return None with observed inputs."""
    before = dict(service_io.disk.store.files)
    result = invoke(service_io, "doctor")
    assert result.ok and result.runtime == service_io.runtime_identity()
    assert result.input_manifest is not None and result.input_manifest.files
    assert any(
        item.code == "DISCOVERY_ENFORCEMENT_UNAVAILABLE" for item in result.findings
    )
    assert result.summary["receipt_ref"] is result.summary["deployment"] is None
    assert service_io.writer_calls == 0 and service_io.disk.store.files == before


def test_decision_validation_preserves_complete_graph_result(
    service_io: MemoryService,
) -> None:
    """Run the finite graph-only validation route; return None without writes."""
    result = invoke(service_io, "validate-decisions")
    assert result.ok and result.summary["validation_result"] == "pass", result.findings
    assert result.input_manifest is not None and result.artifacts == ()
    assert service_io.writer_calls == 0


@pytest.mark.parametrize(
    "fields",
    [
        {},
        {"mode": "unknown"},
        {"operation": "unknown"},
        {"a": 0, "b": 0},
        {"x" * 65: 0},
    ],
)
def test_catalog_failure_keeps_only_bounded_recognized_context(
    service_io: MemoryService,
    monkeypatch: pytest.MonkeyPatch,
    fields: dict[str, object],
) -> None:
    """Fail parsing with fields overrides; retain safe labels, never execution."""

    def fail(*_args: object, **_kwargs: object) -> NoReturn:
        """Raise a catalog failure for parser inputs; no evaluation or effects."""
        raise CatalogError("secret")

    monkeypatch.setattr(service, "parse_service_request", fail)
    operation = str(fields.get("operation", "profile"))
    # Keep unknown operation input explicit without duplicating the positional key.
    remaining = {key: value for key, value in fields.items() if key != "operation"}
    result = invoke(service_io, operation, **remaining)
    assert result.exit_code == (3 if not fields else 2)
    assert result.findings[0].code == "RUNTIME_CORRUPT"
    assert result.findings[0].pointer and "secret" not in result.to_json()
    assert result.runtime is result.input_manifest is None and result.artifacts == ()
    assert service_io.authorization_calls == service_io.writer_calls == 0


def test_provider_mismatch_has_actionable_unavailable_context(
    service_io: MemoryService,
) -> None:
    """Reject a mismatched trusted root; return None after typed failure assertions."""
    result = invoke(
        service_io, "profile", workspace_root=service_io.disk.root + "/other"
    )
    assert result.exit_code == 3 and result.findings[0].code == "SERVICE_PROVIDER"
    assert result.findings[0].pointer and result.input_manifest is None
    assert result.artifacts == () and service_io.authorization_calls == 0
    assert service_io.writer_calls == 0 and "SERVICE_PROVIDER" in result.to_json()
