"""Compose fixed discovery operations from captured inputs and trusted providers."""

from __future__ import annotations

from hashlib import sha256
from typing import TYPE_CHECKING, Literal, cast

from drm_copilot_discovery.findings import Finding, ordered_findings
from drm_copilot_discovery.models import JsonObject, ParseLimits
from drm_copilot_discovery.mutation_io import commit_mutation
from drm_copilot_discovery.mutation_plan import MutationChange, plan_mutation
from drm_copilot_discovery.parsing import parse_document
from drm_copilot_discovery.report_models import ReportBudget
from drm_copilot_discovery.service_contracts import DiscoveryResult, ServiceArtifact
from drm_copilot_discovery.service_serialization import wire_object
from drm_copilot_discovery.snapshot import InputManifest

if TYPE_CHECKING:
    from drm_copilot_discovery.analyzer.registry import InventoryRegistry
    from drm_copilot_discovery.mutation_plan import CapturedWorkspace, MutationPlan
    from drm_copilot_discovery.path_models import WriteGrant
    from drm_copilot_discovery.service_contracts import (
        RuntimeIdentity,
        ServiceAuthority,
        ServiceIO,
        ServiceRequest,
    )
    from drm_copilot_discovery.snapshot import DiscoverySnapshot
    from drm_copilot_discovery.snapshot_io import SnapshotIO
    from drm_copilot_discovery.transport_manifest import TransportRoute


def operation_problem(code: str) -> Finding:
    """Return a fixed actionable Finding for code (str), without I/O.

    Invalid internal codes raise ValueError. No raw exception, source snippet or
    host path is retained; permissions and classification remain with the caller.
    """
    return Finding(
        code=code,
        pointer="/inputs",
        message="The requested operation could not satisfy its contract.",
        next_action="Correct the reported input or trusted configuration.",
    )


class OperationFailure(ValueError):
    """Retain a classified service failure without retaining untrusted text.

    Handlers construct this value for a known operation boundary. The service
    preserves its exit code and ordered findings. It neither grants authority
    nor represents partial publication; committed effects use actual results.
    """

    def __init__(
        self,
        code: str,
        *,
        exit_code: Literal[1, 2, 3] = 2,
        findings: tuple[Finding, ...] = (),
    ) -> None:
        """Retain code (str), exit code and findings; return None without I/O.

        Empty findings produce a fixed actionable diagnostic. Invalid finding
        codes raise ValueError; no underlying exception message is copied.
        """
        self.exit_code: Literal[1, 2, 3] = exit_code
        self.findings = findings or (operation_problem(code),)
        super().__init__(code)


class OperationContext:
    """Coordinate one authenticated request without duplicating domain rules.

    Construct after request/runtime/authentication checks, then dispatch once.
    Retained inputs and file lookup are bounded before copying. Only call-local
    accounting changes. Domain modules supply findings and prospective plans;
    publication goes exclusively through the injected guarded mutation writer.
    Bootstrap reads use the supplied fresh SnapshotIO and preserve real absence.
    """

    def __init__(
        self,
        request: ServiceRequest,
        *,
        io: ServiceIO,
        authority: ServiceAuthority,
        runtime: RuntimeIdentity,
        baseline: CapturedWorkspace | None,
        reads: SnapshotIO,
        timestamp: str,
        analyzer_registry: InventoryRegistry,
    ) -> None:
        """Bind one ServiceRequest and return None without publication.

        io (ServiceIO) supplies trusted ports; authority (ServiceAuthority) holds
        authenticated local intent. runtime (RuntimeIdentity) was verified by
        that provider; baseline (CapturedWorkspace | None) is the actual graph
        or honest bootstrap absence. reads (SnapshotIO) retains bootstrap bytes.
        timestamp (str) is trusted UTC attribution; analyzer_registry
        (InventoryRegistry) supplies the fixed selected adapters.
        ReportLimitError rejects excessive indexing before allocation. No writes.
        """
        self.request, self.io, self.authority = request, io, authority
        self.runtime, self.baseline, self.reads = runtime, baseline, reads
        self.timestamp, self.analyzer_registry = timestamp, analyzer_registry
        self.observed_manifest: InputManifest | None = None
        self.limits = (
            baseline.snapshot.profile.limits.parse_limits()
            if baseline is not None
            else ParseLimits()
        )
        self.budget = ReportBudget(self.limits)
        self.budget.work(2 * len(request.inputs))
        self.inputs = dict(request.inputs.members)
        files = baseline.snapshot.manifest.files if baseline is not None else ()
        self.budget.work(2 * len(files))
        # Reserve path hashing before retaining a lookup for all subsequent reads.
        for file in files:
            self.budget.work(len(file.path))
        # Reuse one bounded lookup instead of rescanning captured inputs per route.
        self.files = {file.path: file for file in files}

    @property
    def snapshot(self) -> DiscoverySnapshot:
        """Return the captured DiscoverySnapshot or raise OperationFailure.

        Bootstrap operations cannot fabricate a configured graph. No I/O occurs.
        """
        if self.baseline is None:
            raise OperationFailure("SERVICE_CAPTURE", exit_code=3)
        return self.baseline.snapshot

    def text(self, key: str, default: str = "") -> str:
        """Read a typed input string by key/default (str); return str or fail.

        The closed request parser validates fields first; this guard protects
        direct helper misuse without coercion or input mutation.
        """
        value = self.inputs.get(key, default)
        if type(value) is not str:
            raise OperationFailure("SERVICE_INPUT")
        return value

    def strings(self, key: str) -> tuple[str, ...]:
        """Return input key's immutable string tuple, or OperationFailure.

        key (str) names a schema-validated selector. No I/O or list copy occurs.
        """
        value = self.inputs.get(key, ())
        if type(value) is not tuple or any(type(item) is not str for item in value):
            raise OperationFailure("SERVICE_INPUT")
        return cast("tuple[str, ...]", value)

    def read(self, path: str) -> bytes:
        """Return exact bytes for path (str), refusing uncaptured graph inputs.

        Bootstrap uses bounded SnapshotIO. A configured graph never rereads an
        arbitrary proposal path; place it in configured capture scope. Raises
        OperationFailure/OSError for missing or unauthorized input; no writes.
        """
        if self.baseline is not None:
            file = self.files.get(path)
            if file is None:
                raise OperationFailure("SERVICE_INPUT")
            return file.content
        content = self.reads.read(path, limit=self.limits.document_bytes)
        if content is None:
            raise OperationFailure("SERVICE_INPUT")
        return content

    def document(self, path: str) -> JsonObject:
        """Parse captured path (str) as bounded JSON/YAML; return JsonObject.

        Raises OperationFailure with original fixed parsing findings on invalid
        documents. Retains no raw exception/source excerpt and performs no writes.
        """
        parsed = parse_document(
            self.read(path),
            format="yaml" if path.endswith((".yaml", ".yml")) else "json",
            limits=self.limits,
        )
        if not parsed.ok or not isinstance(parsed.value, JsonObject):
            raise OperationFailure("SERVICE_DOCUMENT", findings=parsed.findings)
        return parsed.value

    def author(self) -> JsonObject:
        """Return trusted principal attribution as a fresh JsonObject; no I/O.

        The authenticated ServiceAuthority decides attribution, never request
        data: a local-user is a human author and a host principal is an agent.
        """
        from drm_copilot_discovery.operation_grants import attribution

        return attribution(self.authority)

    def manifest(self, *, verify: bool = True) -> InputManifest:
        """Return actual captured inputs as InputManifest; never virtual outputs.

        Bootstrap reads retain observed files/absence. verify (bool) defaults to
        freshness checking; failure packaging uses False to preserve observations
        without repeating failed I/O. This grants no authority. Resource errors
        and, when verifying, OSError propagate; no writes occur.
        """
        from drm_copilot_discovery.snapshot import SnapshotFile

        if self.observed_manifest is not None:
            return self.observed_manifest
        if self.baseline is not None:
            return self.baseline.snapshot.manifest
        if verify:
            self.reads.verify_unchanged()
        values = self.reads.captured
        self.budget.work(len(values))
        # Bootstrap inputs are explicit documents, not invented source identities.
        files = tuple(
            SnapshotFile(path=path, content=content, category="documentation")
            for path, content in values
        )
        return InputManifest(files=files, missing_paths=self.reads.missing_paths)

    def result(
        self,
        *,
        findings: tuple[Finding, ...] = (),
        artifacts: tuple[ServiceArtifact, ...] = (),
        exit_code: Literal[0, 1, 2, 3] | None = None,
        counts: tuple[tuple[str, int], ...] = (),
        validation: Literal["pass", "fail"] | None = None,
        source_reads: tuple[JsonObject, ...] | None = None,
        verify_inputs: bool = True,
    ) -> DiscoveryResult:
        """Return a bounded DiscoveryResult from typed findings/effects/counters.

        Counts name nonnegative units, validation is the selected gate, and
        source_reads are exact authorized observations. Derived exit 1 retains
        blockers; explicit exit 3 preserves interrupted effects. Resource errors
        propagate before serialization. verify_inputs (bool) is False only for
        failure packaging of actual prior observations, never fresh authority.
        No publication or authority is created.
        """
        # Output accounting is independent so a failed operation can report its limit.
        output = ReportBudget(self.limits)
        count = len(findings)
        passes = 2 * (count + 1) * (count.bit_length() + 1)
        output.work(16 * count + count * passes + len(counts))
        # Prepay both incremental collectors' comparisons, repeated sort and text.
        for finding in findings:
            output.work(len(finding.related_ids) + len(finding.related_paths))
            fields = (
                finding.code,
                finding.severity,
                finding.artifact_path or "",
                finding.pointer,
                finding.message,
                finding.next_action,
            )
            characters = sum(map(len, fields))
            characters += sum(map(len, finding.related_ids))
            characters += sum(map(len, finding.related_paths))
            output.work(characters * passes)
        ordered = ordered_findings(findings, limit=self.limits.findings)
        code = exit_code
        if code is None:
            code = 1 if any(item.severity == "error" for item in ordered) else 0
        # Closed summary fields expose unavailable metrics by omission, not zeros.
        summary: dict[str, object] = {
            "message": "Operation passed." if code == 0 else "Operation did not pass.",
            "counts": tuple({"name": key, "value": value} for key, value in counts),
            "validation_result": validation,
            "receipt_ref": None,
            "invocation_ref": None,
        }
        if source_reads is not None:
            summary["source_reads"] = source_reads
        return DiscoveryResult(
            operation=self.request.operation,
            mode=self.request.mode,
            ok=code == 0,
            exit_code=code,
            findings=ordered,
            artifacts=artifacts,
            summary=wire_object(summary, limits=self.limits),
            input_manifest=self.manifest(verify=verify_inputs),
            runtime=self.runtime,
        )

    def change(
        self, kind: str, identifier: str, path: str, content: bytes
    ) -> MutationChange:
        """Bind proposed file identity/content to its captured CAS precondition.

        kind/identifier/path are str; content is bytes. Returns MutationChange or
        a path/value/resource error before mutation. No grant or write occurs.
        """
        self.budget.spend(len(content))
        previous = self.files.get(path)
        return MutationChange(
            artifact_kind=kind,
            artifact_id=identifier,
            path=path,
            content=content,
            expected_sha256=previous.sha256 if previous is not None else None,
        )

    def grants(self, changes: tuple[MutationChange, ...]) -> tuple[WriteGrant, ...]:
        """Return exact grants for bounded changes from the authenticated authority.

        A local-user derives the exact rows of its own changes; a host authority
        receives only rows its verified invocation already grants. The policy
        lives in operation_grants. Raises OperationFailure on authority mismatch;
        no wildcard, I/O or host fallback.
        """
        from drm_copilot_discovery.operation_grants import derive_grants

        self.budget.work(4 * len(changes))
        return derive_grants(self.authority, self.request, changes)

    def plan(
        self,
        changes: tuple[MutationChange, ...],
        *,
        transport: TransportRoute | None = None,
    ) -> MutationPlan:
        """Return an accepted MutationPlan for exact changes and optional transport.

        Raises OperationFailure/MutationError before writes on missing capture,
        grants, CAS, path or structural faults. No domain validation is copied.
        """
        if self.baseline is None:
            raise OperationFailure("SERVICE_CAPTURE", exit_code=3)
        return plan_mutation(
            self.baseline, changes, grants=self.grants(changes), transport=transport
        )

    def projected(
        self, changes: tuple[MutationChange, ...]
    ) -> tuple[ServiceArtifact, ...]:
        """Return bounded planned file rows for changes; no writes or grant creation.

        Changes are a tuple of MutationChange. Reserve 64 visits per input byte or
        identity character for decoding, hashing and escaped carrier passes, plus
        4096 fixed-field visits per row. Binary payloads omit text. Resource/path
        errors propagate before any partial rows or writes.
        """
        self.budget.work(len(changes))
        # Reserve all row content before any decoded copies or artifact allocation.
        for change in changes:
            size = len(change.content) + len(change.path)
            size += len(change.artifact_kind) + len(change.artifact_id)
            self.budget.work(4096 + 64 * size)
            self.budget.spend(6 * size + 512)
        rows: list[ServiceArtifact] = []
        # Decode only valid text while retaining every file's exact byte digest.
        for change in changes:
            try:
                text = change.content.decode("utf-8")
            except UnicodeDecodeError:
                text = None
            rows.append(
                ServiceArtifact(
                    path=change.path,
                    kind=change.artifact_kind,
                    status="planned",
                    sha256=sha256(change.content).hexdigest(),
                    content=text,
                )
            )
        return tuple(rows)

    def publish(
        self,
        plan: MutationPlan,
        *,
        findings: tuple[Finding, ...] = (),
        validation: Literal["pass", "fail"] | None = None,
    ) -> DiscoveryResult:
        """Publish plan through the trusted writer; return actual DiscoveryResult.

        Plan is MutationPlan; findings/validation retain the selected gate.
        Preflight a conservative result before the first write. Interrupted
        publication preserves exact artifact rows and uncertain-path findings.
        """
        from dataclasses import replace

        self.budget.work(len(plan.writes))
        # Preserve planned content for the exact actual status rows after commit.
        changes = tuple(write.change for write in plan.writes)
        projected = self.projected(changes)
        self.budget.work(len(changes))
        # Reserve bounded failure text/path links as well as the success envelope.
        reserve = tuple(
            Finding(
                code="SERVICE_WRITE",
                artifact_path=c.path,
                message="Publication may be incomplete.",
                next_action="Recapture and reconcile the affected path.",
            )
            for c in changes
        )
        # Validate the full result before acquiring a writer or changing any file.
        from drm_copilot_discovery.service_contracts import validate_service_result

        validate_service_result(
            self.result(findings=findings + reserve, artifacts=projected, exit_code=3),
            catalog=self.snapshot.catalog,
            limits=self.limits,
        )
        self.budget.work(3 * len(projected))
        result = commit_mutation(
            plan,
            writer=self.io.writer(plan.baseline, authority=self.authority),
            dry_run=self.request.dry_run,
        )
        # Index previously bounded exact rows for actual result attribution.
        by_path = {row.path: row for row in projected}
        # Actual guarded outcomes determine statuses, never the preflight forecast.
        artifacts = tuple(
            replace(
                by_path[row.path], status=row.status, sha256=row.sha256, content=None
            )
            for row in result.artifacts
        )
        code: Literal[0, 1, 3] = (
            3
            if not result.ok
            else (
                1
                if validation == "fail" or any(f.severity == "error" for f in findings)
                else 0
            )
        )
        return self.result(
            artifacts=artifacts,
            findings=findings + result.findings,
            validation=validation,
            exit_code=code,
            counts=(("uncertain_paths", len(result.uncertain_paths)),),
        )


def dispatch(context: OperationContext) -> DiscoveryResult:
    """Dispatch one typed context through fixed modules; return DiscoveryResult.

    The finite operation name is schema-checked. No request-selected imports or
    callbacks execute. Existing handlers may read captured bytes or publish only
    via guarded plans. Unknown names raise OperationFailure.
    """
    from drm_copilot_discovery.service_mutations import mutate
    from drm_copilot_discovery.service_reports import project

    operation = context.request.operation
    # Closed families separate pure projection from controlled mutation adapters.
    if operation in {
        "validate-all",
        "coverage-report",
        "parity-report",
        "completion-report",
        "generate-acceptance",
    }:
        return project(context)
    if operation in {
        "init",
        "configure",
        "new-contract",
        "new-scenario",
        "update-artifact",
        "link-evidence",
        "snapshot-export",
        "snapshot-import",
        "import-inventory",
        "migrate",
    }:
        return mutate(context)
    return inspect_operation(context)


def inspect_operation(context: OperationContext) -> DiscoveryResult:
    """Run fixed read/inventory routes for context; return the typed result.

    Domain-specific assessments remain in accepted modules. This wrapper adds
    no target-only validity claim or permission; unsupported names fail closed.
    """
    from drm_copilot_discovery.service_inspection import inspect_request

    return inspect_request(context)
