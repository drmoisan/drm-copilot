"""Keep invocation, resource and interrupted-effect boundaries explicit."""

from __future__ import annotations

from dataclasses import replace
from hashlib import sha256
from typing import TYPE_CHECKING, NoReturn

import pytest
from drm_copilot_discovery import operations, service
from drm_copilot_discovery.analyzer.registry import InstalledInventoryRegistry
from drm_copilot_discovery.catalog import CatalogError
from drm_copilot_discovery.configuration import ConfigurationError
from drm_copilot_discovery.extension_validation import ExtensionResultError
from drm_copilot_discovery.findings import Finding, ordered_findings
from drm_copilot_discovery.models import JsonObject, ParseLimits
from drm_copilot_discovery.mutation_plan import MutationChange, MutationError
from drm_copilot_discovery.operations import OperationContext, OperationFailure
from drm_copilot_discovery.path_models import PathPolicyError
from drm_copilot_discovery.profile_v2 import ProfileError
from drm_copilot_discovery.report_models import ReportBudget, ReportLimitError
from drm_copilot_discovery.resources import ResourceError
from drm_copilot_discovery.service_contracts import (
    DiscoveryResult,
    ServiceAuthority,
    ServiceRequest,
    ServiceRequestError,
)
from drm_copilot_discovery.snapshot_io import SnapshotIO
from drm_copilot_discovery.source_read_models import ReadGrant, ReadSelection
from drm_copilot_discovery.source_reads import SourceReader

from tests.discovery_runtime.test_service import MemoryService, invoke
from tests.discovery_runtime.test_service import (
    initialization_catalog as initialization_catalog,
)
from tests.discovery_runtime.test_service import (
    initialization_templates as initialization_templates,
)
from tests.discovery_runtime.test_service import service_io as service_io
from tests.discovery_runtime.test_service import service_plan as service_plan

if TYPE_CHECKING:
    from drm_copilot_discovery.catalog import SchemaCatalog
    from drm_copilot_discovery.source_read_models import SourceReadRequest


@pytest.fixture
def context(service_io: MemoryService) -> OperationContext:
    """Return a bootstrap context from memory io; no capture or publication."""
    return OperationContext(
        ServiceRequest(
            id="request",
            request_id="correlation",
            operation="profile",
            mode="structural",
            workspace_root=service_io.disk.root,
            profile_path=None,
            dry_run=False,
            write=False,
            format="json",
            inputs=JsonObject(()),
            invocation_ref=None,
            authorization_ref=None,
        ),
        io=service_io,
        authority=ServiceAuthority(
            principal="local-user",
            author_or_agent="operator",
            invocation=None,
            grants=(),
            read_selection=None,
        ),
        runtime=service_io.runtime_identity(),
        baseline=None,
        reads=SnapshotIO(
            workspace_root=service_io.disk.root,
            metadata=service_io.disk.store.metadata,
            read_bytes=service_io.disk.store.read,
        ),
        timestamp="2026-10-20T00:00:00Z",
        analyzer_registry=InstalledInventoryRegistry(),
    )


@pytest.mark.parametrize("selector", [["unknown"], ["office-vsto"]])
def test_invalid_inventory_selector_is_a_typed_invocation_failure(
    service_io: MemoryService, selector: list[str]
) -> None:
    """Reject unknown/disabled selector before analysis; return None, memory only."""
    result = invoke(service_io, "inventory", {"analyzer_ids": selector})
    assert result.exit_code == 2 and not result.ok
    assert result.findings[0].code == "SERVICE_SELECTION"
    assert result.artifacts == () and service_io.writer_calls == 0


def test_reversed_source_line_range_is_rejected_before_inspection(
    service_io: MemoryService, monkeypatch: pytest.MonkeyPatch
) -> None:
    """Use MemoryService/MonkeyPatch to reject reversed bounds at request parsing.
    Return None; require null runtime/manifest and no inspection or writes.
    """
    path = "application/a.cs"
    service_io.disk.store.put(path, b"one\ntwo\nthree\n")
    service_io.repository.files[path] = service_io.disk.store.files[path]
    service_io.selection = ReadSelection(grants=(ReadGrant(path=path),))
    calls: list[object] = []

    def unexpected(_self: SourceReader, _request: SourceReadRequest) -> NoReturn:
        """Record forbidden SourceReader/request use; raise AssertionError, no I/O."""
        calls.append(_request)
        raise AssertionError("Invalid line bounds reached inspection")

    monkeypatch.setattr(SourceReader, "inspect", unexpected)
    result = invoke(
        service_io,
        "read-source",
        {"read_operation": "read", "paths": [path], "line_start": 3, "line_end": 2},
    )
    assert result.exit_code == 2 and result.findings[0].code == "SERVICE_REQUEST"
    assert result.findings[0].pointer == "/"
    assert result.runtime is None and result.input_manifest is None
    assert calls == [] and result.artifacts == () and service_io.writer_calls == 0


@pytest.mark.parametrize("failure", ["selection", "encoding", "capacity"])
def test_source_failures_do_not_return_partial_rows(
    service_io: MemoryService, failure: str
) -> None:
    """Exercise failure (str) through actual source reads; return None, memory only."""
    path = "application/a.cs"
    service_io.disk.store.put(path, b"\xff" if failure == "encoding" else b"secret\n")
    service_io.repository.files[path] = service_io.disk.store.files[path]
    service_io.selection = ReadSelection(
        grants=(
            ReadGrant(path="application/other.cs" if failure == "selection" else path),
        )
    )
    inputs: dict[str, object] = {"read_operation": "read", "paths": [path]}
    if failure == "capacity":
        inputs["max_bytes"] = 1
    result = invoke(service_io, "read-source", inputs)
    assert result.exit_code in (2, 3) and not result.ok
    assert "source_reads" not in result.summary and "secret" not in result.to_json()
    assert service_io.writer_calls == 0


def test_source_first_page_exposes_exact_truncation(
    service_io: MemoryService,
) -> None:
    """Read 101 memory lines through one fixed page; return None with honest counts."""
    path = "application/a.cs"
    service_io.disk.store.put(path, b"row\n" * 101)
    service_io.repository.files[path] = service_io.disk.store.files[path]
    service_io.selection = ReadSelection(grants=(ReadGrant(path=path),))
    result = invoke(
        service_io, "read-source", {"read_operation": "read", "paths": [path]}
    )
    assert result.ok, result.findings
    assert result.summary["counts"] == (
        JsonObject((("name", "total_rows"), ("value", 101))),
        JsonObject((("name", "returned_rows"), ("value", 100))),
        JsonObject((("name", "truncated"), ("value", 1))),
    )
    assert service_io.writer_calls == 0


@pytest.mark.parametrize(
    ("error", "exit_code", "code"),
    [
        (CatalogError("secret"), 3, "RUNTIME_CORRUPT"),
        (ResourceError("secret"), 3, "RUNTIME_CORRUPT"),
        (ConfigurationError("TEST_CONFIG", "secret"), 2, "SERVICE_CONFIGURATION"),
        (PathPolicyError("PATH_SCOPE", "secret", "secret"), 2, "PATH_SCOPE"),
        (ExtensionResultError("EXTENSION_TEST"), 2, "EXTENSION_TEST"),
        (MutationError("MUTATION_INVALID", "secret"), 1, "MUTATION_INVALID"),
        (MutationError("MUTATION_STALE", "secret"), 2, "MUTATION_STALE"),
        (ReportLimitError(), 2, "SERVICE_LIMIT"),
        (OSError("secret"), 3, "SERVICE_IO"),
    ],
)
def test_precise_operational_errors_keep_their_exit_class_without_raw_text(
    service_io: MemoryService,
    monkeypatch: pytest.MonkeyPatch,
    error: Exception,
    exit_code: int,
    code: str,
) -> None:
    """Inject typed error at dispatch; assert class/code and no raw text or effects."""

    def fail(_context: OperationContext) -> NoReturn:
        """Raise the selected precise error for context; return never, no effects."""
        raise error

    monkeypatch.setattr(service, "dispatch", fail)
    result = invoke(service_io, "profile")
    assert result.exit_code == exit_code and result.findings[0].code == code
    assert "secret" not in result.to_json() and result.artifacts == ()
    assert service_io.writer_calls == 0


@pytest.mark.parametrize("kind", ["profile", "request", "mutation"])
def test_existing_typed_findings_are_preserved(
    service_io: MemoryService, monkeypatch: pytest.MonkeyPatch, kind: str
) -> None:
    """Propagate original typed kind findings; return None with no replacement prose."""
    original = Finding(
        code="ORIGINAL_PROBLEM",
        message="Fixed diagnostic.",
        next_action="Correct the identified input.",
        pointer="/id",
    )
    errors = {
        "profile": ProfileError((original,)),
        "request": ServiceRequestError((original,), operation="profile", mode=None),
        "mutation": MutationError("MUTATION_INVALID", "unused", findings=(original,)),
    }

    def fail(_context: OperationContext) -> NoReturn:
        """Raise chosen typed failure for context; no effects or normal return."""
        raise errors[kind]

    monkeypatch.setattr(service, "dispatch", fail)
    result = invoke(service_io, "profile")
    assert result.findings == (original,) and result.operation == "profile"
    assert result.mode == "structural" and result.exit_code == (
        1 if kind == "mutation" else 2
    )


def test_unexpected_programming_error_is_not_relabelled_as_no_effect_result(
    service_io: MemoryService, monkeypatch: pytest.MonkeyPatch
) -> None:
    """Inject unexpected ValueError; return None after confirming exact propagation."""

    def fail(_context: OperationContext) -> NoReturn:
        """Raise an unexpected coding error for context; do not publish or return."""
        raise ValueError("programming failure")

    monkeypatch.setattr(service, "dispatch", fail)
    with pytest.raises(ValueError, match="programming failure"):
        invoke(service_io, "profile")
    assert service_io.writer_calls == 0


@pytest.mark.parametrize("content", [b"\x00" * 200, "é".encode() * 200])
def test_projection_reserves_complete_encoded_content_before_row_allocation(
    context: OperationContext, monkeypatch: pytest.MonkeyPatch, content: bytes
) -> None:
    """Reject aggregate content under 1024 bytes before allocating any result row."""
    change = MutationChange(
        artifact_kind="feature-contract",
        artifact_id="feature",
        path="proposals/feature.json",
        content=content,
        expected_sha256=None,
    )
    context.budget = ReportBudget(ParseLimits(document_bytes=1024))
    calls: list[object] = []

    def unexpected(**fields: object) -> NoReturn:
        """Count forbidden row fields then fail; no row allocation or external I/O."""
        calls.append(fields)
        raise AssertionError("Result row allocated before byte reservation")

    monkeypatch.setattr(operations, "ServiceArtifact", unexpected)
    with pytest.raises(ReportLimitError):
        context.projected((change,))
    assert calls == []


def test_opaque_binary_projection_retains_digest_without_fake_text(
    context: OperationContext,
) -> None:
    """Project bytes with invalid UTF-8; return None after exact metadata assertions."""
    change = MutationChange(
        artifact_kind="evidence-reference",
        artifact_id="proof",
        path="proposals/proof.bin",
        content=b"\xff",
        expected_sha256=None,
    )
    rows = context.projected((change,))
    assert rows[0].content is None and rows[0].status == "planned"
    assert (
        rows[0].sha256
        == "a8100ae6aa1940d0b663bb31cd466142ebbdbd5187131b92d93818987832eb89"
    )


@pytest.mark.parametrize(
    "action", ["snapshot", "plan", "read", "document", "text", "strings"]
)
def test_context_invalid_or_unavailable_inputs_fail_explicitly(
    context: OperationContext, service_io: MemoryService, action: str
) -> None:
    """Preserve bootstrap read I/O errors for action; return None, no writes."""
    context.inputs["bad"] = 5
    with pytest.raises(FileNotFoundError if action == "read" else OperationFailure):
        if action == "snapshot":
            _ = context.snapshot
        elif action == "plan":
            context.plan(())
        elif action == "read":
            context.read("missing.json")
        elif action == "document":
            service_io.disk.store.put("proposals/scalar.json", b"[]")
            context.document("proposals/scalar.json")
        elif action == "text":
            context.text("bad")
        else:
            context.strings("bad")


@pytest.mark.parametrize("marker", ["host", "invocation_ref", "authorization_ref"])
def test_direct_publication_context_cannot_derive_host_grants(
    context: OperationContext, marker: str
) -> None:
    """Reject marker on direct helper use; return None without synthesized grants."""
    if marker == "host":
        context.authority = replace(context.authority, principal="host")
    elif marker == "invocation_ref":
        context.request = replace(context.request, invocation_ref="opaque")
    else:
        context.request = replace(context.request, authorization_ref="opaque")
    with pytest.raises(OperationFailure) as raised:
        context.grants(())
    assert raised.value.exit_code == 3


def test_interrupted_publication_preserves_actual_conflict_and_failure(
    service_io: MemoryService,
) -> None:
    """Fail the real memory writer; return None with exit 3 and no completed claim."""
    service_io.disk.fail_publish = True
    before = dict(service_io.disk.store.files)
    result = invoke(
        service_io, "new-contract", {"feature_id": "feature", "name": "Feature"}
    )
    assert result.exit_code == 3 and not result.ok and result.findings
    assert service_io.writer_calls == 1 and service_io.disk.store.files == before
    assert all(row.status in ("conflict", "skipped") for row in result.artifacts)


def test_bootstrap_interruption_retains_directory_effects_without_file_digest(
    initialization_catalog: SchemaCatalog,
) -> None:
    """Fail memory writes; retain planned hashes and directory effects; return None."""
    io = MemoryService(initialization_catalog)
    io.disk.fail_publish = True
    result = invoke(
        io,
        "init",
        {
            "system_id": "consumer-system",
            "system_name": "Consumer system",
            "system_role": "combined",
            "repository_id": "consumer-repository",
            "draft": True,
        },
    )
    assert result.exit_code == 3 and not result.ok and result.findings
    assert {row.status for row in result.artifacts} == {"planned", "conflict"}
    assert not io.disk.store.files and result.input_manifest is not None
    counts = result.summary["counts"]
    assert isinstance(counts, tuple)
    created = next(
        row["value"]
        for row in counts
        if isinstance(row, JsonObject) and row["name"] == "directories_created"
    )
    assert isinstance(created, int) and created > 0


@pytest.mark.parametrize("operation", ["prepare-agent", "finalize-agent"])
def test_native_operations_remain_unavailable_without_a_verified_provider(
    service_io: MemoryService, operation: str
) -> None:
    """Reject operation before capture/publication; return None, no local fallback."""
    inputs: dict[str, object] = {}
    fields: dict[str, object] = {}
    if operation == "prepare-agent":
        inputs = {
            "skill_id": "validate-discovery-artifacts",
            "selected_ids": ["feature"],
            "paths": ["feature.json"],
            "execution_context": "standalone",
            "complexity": "C1",
            "expected_outputs": [
                {
                    "artifact_kind": "feature-contract",
                    "id": "feature",
                    "path": "feature.json",
                    "format": "json",
                    "expected_sha256": None,
                }
            ],
        }
    else:
        fields.update(mode="agent-output", invocation_ref="protected-alpha-00000001")
    result = invoke(service_io, operation, inputs, **fields)
    assert result.exit_code == 3 and result.findings[0].code == "SERVICE_AUTHORITY"
    assert result.input_manifest is None and service_io.writer_calls == 0


def test_failed_freshness_preserves_observation_without_second_read(
    service_io: MemoryService, monkeypatch: pytest.MonkeyPatch
) -> None:
    """Change one captured memory input; failure packaging retains the observation."""
    path, original = "proposals/input.json", b"{}"
    service_io.disk.store.put(path, original)
    checks: list[int] = []
    verify = SnapshotIO.verify_unchanged

    def counted(reads: SnapshotIO) -> None:
        """Count the real freshness check on reads; propagate its typed failure."""
        checks.append(1)
        verify(reads)

    def fail(context: OperationContext) -> DiscoveryResult:
        """Capture bytes/absence then change memory; real result freshness fails."""
        assert context.read(path) == original
        context.reads.read("missing.json", limit=1024, required=False)
        service_io.disk.store.put(path, b"[]")
        return context.result()

    monkeypatch.setattr(SnapshotIO, "verify_unchanged", counted)
    monkeypatch.setattr(service, "dispatch", fail)
    result = invoke(service_io, "profile")
    assert checks == [1] and result.exit_code == 3
    assert result.findings[0].code == "SERVICE_IO" and result.findings[0].pointer
    assert result.input_manifest is not None
    assert result.input_manifest.files[0].content == original
    assert result.input_manifest.missing_paths == ("missing.json",)
    assert result.artifacts == () and service_io.writer_calls == 0
    assert "SERVICE_IO" in result.to_json()


@pytest.mark.parametrize("sufficient", [False, True])
def test_projection_prepays_work_before_hashing_and_carrier_construction(
    context: OperationContext, monkeypatch: pytest.MonkeyPatch, sufficient: bool
) -> None:
    """Use counted hashing under tight/normal work; preserve exact sufficient output."""
    content = b"x" * 4096
    change = MutationChange(
        artifact_kind="evidence-payload",
        artifact_id="proof",
        path="proof.bin",
        content=content,
        expected_sha256=None,
    )
    calls: list[int] = []

    def counted(value: bytes) -> object:
        """Record input bytes and perform the real digest; no external effects."""
        calls.append(len(value))
        return sha256(value)

    monkeypatch.setattr(operations, "sha256", counted)
    if not sufficient:
        context.budget.work(context.budget.work_left - 1)
        with pytest.raises(ReportLimitError):
            context.projected((change,))
        assert calls == []
    else:
        rows = context.projected((change,))
        assert calls == [4096] and rows[0].content == content.decode("utf-8")
        assert rows[0].sha256 == sha256(content).hexdigest()


@pytest.mark.parametrize("sufficient", [False, True])
def test_result_prepays_incremental_comparison_work_and_preserves_findings(
    context: OperationContext, monkeypatch: pytest.MonkeyPatch, sufficient: bool
) -> None:
    """Count entry to the accepted collector; retain order, deduplication and marker."""
    # Distinct findings reproduce the reviewed incremental equality-work population.
    findings = tuple(
        Finding(
            code="TEST", pointer=f"/{i}", message="Problem.", next_action="Correct."
        )
        for i in range(96)
    )
    if sufficient:
        findings = findings[:8]
        context.limits = ParseLimits(findings=4)
        expected = ordered_findings(findings + findings, limit=4)
        assert context.result(findings=findings + findings).findings == expected
        return
    context.limits = ParseLimits(artifact_records=32)
    calls: list[int] = []

    def unexpected(*_args: object, **_kwargs: object) -> NoReturn:
        """Count a forbidden pre-reservation collector call; return never."""
        calls.append(1)
        raise AssertionError("Collector ran before work reservation")

    monkeypatch.setattr(operations, "ordered_findings", unexpected)
    with pytest.raises(ReportLimitError):
        context.result(findings=findings)
    assert calls == []
