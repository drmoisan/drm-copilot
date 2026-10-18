"""Keep target implementation and execution proof independent from source facts."""

from __future__ import annotations

from typing import TYPE_CHECKING

from drm_copilot_discovery.coverage_scope_rules import object_rows, strings
from drm_copilot_discovery.models import JsonObject
from drm_copilot_discovery.reference_links import string_value
from drm_copilot_discovery.revision_rules import is_full_revision
from drm_copilot_discovery.runtime_claim_rules import has_text
from drm_copilot_discovery.snapshot import repository_pins

if TYPE_CHECKING:
    from drm_copilot_discovery.claim_rules import ClaimContext
    from drm_copilot_discovery.references import ArtifactRecord
    from drm_copilot_discovery.repository_reader import RepositoryIdentity
    from drm_copilot_discovery.revision_rules import RevisionValidation
    from drm_copilot_discovery.snapshot import DiscoverySnapshot


def _payload_paths(record: ArtifactRecord) -> frozenset[str]:
    """Identify both checked payload locations without equating unrelated captures."""
    runtime = record.document.get("runtime_artifact")
    values = (
        record.document.get("path"),
        runtime.get("path") if isinstance(runtime, JsonObject) else None,
    )
    return frozenset(value for value in values if isinstance(value, str))


class TargetProof:
    """Assess retained target bytes and typed evidence without reading or executing."""

    def __init__(
        self,
        snapshot: DiscoverySnapshot,
        context: ClaimContext,
        revisions: RevisionValidation,
    ) -> None:
        """Reuse the caller's graph and revision assessment for one snapshot."""
        self.snapshot, self.context = snapshot, context
        self.upstream = context.index.findings + revisions.findings
        self.targets = repository_pins(snapshot.profile)[1]
        # Assess present records once even when no parity row cites their claims.
        self.implementations = {
            record: self.implementation(record)
            for record in context.index.records
            if record.kind == "implementation-record"
        }

    def blocked(self, record: ArtifactRecord, pointer: str = "") -> bool:
        """Reject relevant graph or immutable-byte defects before using their claims."""
        prefix = record.pointer + pointer
        return any(
            finding.severity == "error"
            and finding.artifact_path == record.artifact.path
            and (
                not prefix
                or not finding.pointer
                or finding.pointer == prefix
                or finding.pointer.startswith(prefix + "/")
            )
            for finding in self.upstream
        )

    def identity(self, record: ArtifactRecord) -> RepositoryIdentity | None:
        """Bind implementation ownership to its configured client and full pin."""
        value = record.document.get("target_repository")
        client = next(
            (
                item
                for item in self.snapshot.profile.clients
                if item.id == record.document.get("client_id")
            ),
            None,
        )
        if not isinstance(value, JsonObject) or client is None:
            return None
        # A shared repository ID still requires the target-role revision.
        for target in self.targets:
            if (
                target.id == client.target_repository == value.get("id")
                and target.revision == value.get("revision")
                and is_full_revision(value.get("revision"))
                and record.artifact.repository == target
            ):
                return target
        return None

    def source_payload(
        self, proof: ArtifactRecord, sources: tuple[ArtifactRecord, ...]
    ) -> bool:
        """Prevent source proof reuse even when source and target share a Git pin."""
        # Source citations keep their role even in a combined checkout.
        for source in sources:
            # Typed traversal includes nested criteria and top-level citations.
            for previous in self.context.targets(source, ""):
                if previous.kind != "evidence-reference":
                    continue
                if previous == proof or (
                    previous.document.get("repository")
                    == proof.document.get("repository")
                    and previous.document.get("revision")
                    == proof.document.get("revision")
                    and bool(_payload_paths(previous) & _payload_paths(proof))
                ):
                    return True
        return False

    def evidence(
        self,
        record: ArtifactRecord,
        pointer: str,
        target: RepositoryIdentity,
        client_id: str,
        *,
        sources: tuple[ArtifactRecord, ...] = (),
        platform: str | None = None,
        mode: str | None = None,
        execution: bool = True,
    ) -> bool:
        """Require target execution proof; select coordinates within valid captures.

        Every citation must be usable target proof. Different mode captures may
        coexist; at least one must support the requested coordinate. A test
        artifact without environment uses its enclosing test's explicit axes.
        """
        matches = False
        # Invalid citations block a claim; unrelated valid coordinates may coexist.
        for link in self.context.links(record, pointer):
            assessment = (
                self.context.evidence.for_record(link.target) if link.target else None
            )
            if (
                assessment is None
                or not assessment.can_prove(
                    repository=target.id,
                    revision=target.revision,
                    evidence_types=(
                        ("test", "runtime", "observation")
                        if execution
                        else (
                            "source",
                            "test",
                            "documentation",
                            "inventory",
                            "runtime",
                            "observation",
                        )
                    ),
                )
                or self.source_payload(assessment.record, sources)
            ):
                return False
            environment = assessment.record.document.get("environment")
            if isinstance(environment, JsonObject):
                if environment.get("client_id") != client_id:
                    return False
                if platform is not None and environment.get("platform") != platform:
                    continue
                if mode is not None and environment.get("operating_mode") != mode:
                    continue
            matches = True
        return matches

    def implementation(self, record: ArtifactRecord) -> bool:
        """Check present implementation claims independently of parity summaries."""
        document = record.document
        target = self.identity(record)
        client = string_value(document.get("client_id"))
        sources = self.context.targets(record, "/feature_refs")
        paths = object_rows(document.get("implementation_paths"))
        tests = object_rows(document.get("test_references"))
        valid = bool(target and client and sources and paths) and not self.blocked(
            record
        )
        if target is not None and client is not None:
            # Implementation bytes must belong to this target, never its source.
            for _, source in paths:
                valid = (
                    valid
                    and source.get("repository") == target.id
                    and source.get("revision") == target.revision
                )
            # Explicit test results need execution proof independent of summaries.
            for position, test in tests:
                source = test.get("source")
                if (
                    not isinstance(source, JsonObject)
                    or source.get("repository") != target.id
                    or source.get("revision") != target.revision
                ):
                    valid = False
                if test.get("verification_state") in (
                    "passed",
                    "failed",
                ) and not self.evidence(
                    record,
                    f"/test_references/{position}/evidence_refs",
                    target,
                    client,
                    sources=sources,
                ):
                    valid = False
            state = document.get("verification_state")
            if state in ("passed", "failed"):
                valid = (
                    valid
                    and self.evidence(
                        record,
                        "/verification_evidence_refs",
                        target,
                        client,
                        sources=sources,
                    )
                    and any(
                        test.get("verification_state") == state for _, test in tests
                    )
                )
                if state == "passed" and any(
                    test.get("verification_state") == "failed" for _, test in tests
                ):
                    valid = False
            if state in ("blocked", "not-applicable") and not has_text(
                document.get("verification_reason")
            ):
                valid = False
        if not valid:
            self.context.add(
                "PARITY_IMPLEMENTATION",
                record,
                "",
                "Implementation needs matching target bytes/client/test proof.",
            )
        return valid

    def links(
        self,
        matrix: ArtifactRecord,
        pointer: str,
        source: ArtifactRecord,
        target: RepositoryIdentity,
        client: str,
    ) -> tuple[ArtifactRecord, ...]:
        """Return implementation links bound to this source/client and exact pin."""
        field = pointer + "/target_implementation_refs"
        links = self.context.links(matrix, field)
        records = self.context.targets(matrix, field)
        valid = len(records) == len(links) and not self.blocked(matrix, field)
        # Every linked record must independently meet the row ownership contract.
        for record in records:
            valid = (
                valid
                and self.implementations.get(record, False)
                and (
                    record.artifact.repository == target
                    and record.document.get("client_id") == client
                    and source in self.context.targets(record, "/feature_refs")
                )
            )
        if not valid:
            self.context.add(
                "PARITY_IMPLEMENTATION_LINK",
                matrix,
                field,
                "Implementation links need matching feature/client/bytes.",
            )
            return ()
        return records

    def coordinate(
        self, record: ArtifactRecord, platform: str | None, mode: str
    ) -> bool:
        """Find a passing test and capture for the exact required target coordinate."""
        target = self.identity(record)
        client = string_value(record.document.get("client_id"))
        if (
            target is None
            or client is None
            or record.document.get("verification_state") != "passed"
        ):
            return False
        sources = self.context.targets(record, "/feature_refs")
        # Match explicit test applicability with actual captured execution context.
        return any(
            test.get("verification_state") == "passed"
            and mode in strings(test.get("modes"))
            and (
                not strings(test.get("platforms"))
                or platform in strings(test.get("platforms"))
            )
            and self.evidence(
                record,
                f"/test_references/{position}/evidence_refs",
                target,
                client,
                sources=sources,
                platform=platform,
                mode=mode,
            )
            for position, test in object_rows(record.document.get("test_references"))
        )
