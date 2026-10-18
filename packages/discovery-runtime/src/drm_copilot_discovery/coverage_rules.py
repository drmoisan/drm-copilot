"""Validate inventory-to-ledger claims separately from discovery completion."""

from __future__ import annotations

from dataclasses import dataclass
from typing import TYPE_CHECKING

from drm_copilot_discovery.claim_rules import ClaimContext, validate_claims
from drm_copilot_discovery.coverage_scope_rules import (
    excluded,
    object_rows,
    select_coverage_scope,
)
from drm_copilot_discovery.evidence_rules import validate_evidence
from drm_copilot_discovery.findings import Finding
from drm_copilot_discovery.models import JsonObject
from drm_copilot_discovery.references import index_references
from drm_copilot_discovery.revision_rules import RevisionInputs
from drm_copilot_discovery.runtime_claim_rules import has_text

if TYPE_CHECKING:
    from drm_copilot_discovery.claim_rules import ClaimValidation
    from drm_copilot_discovery.coverage_scope_rules import CoverageScope
    from drm_copilot_discovery.evidence_rules import EvidenceValidation
    from drm_copilot_discovery.references import ArtifactRecord, ReferenceIndex
    from drm_copilot_discovery.snapshot import DiscoverySnapshot


@dataclass(frozen=True)
class CoverageValidation:
    """Return immutable ledger findings without granting a complete-workspace pass.

    The later mode validator composes schema, graph, evidence, revision, claims
    and remaining completion rules. This value never edits input state.
    """

    findings: tuple[Finding, ...]


class _CoverageRules:
    """Check exact ledger records through retained graph, proof and scope inputs."""

    def __init__(
        self,
        snapshot: DiscoverySnapshot,
        context: ClaimContext,
        claims: ClaimValidation,
        *,
        complete: bool,
    ) -> None:
        """Keep call-local state and reuse accepted pure claim results."""
        self.snapshot, self.context, self.claims = snapshot, context, claims
        self.complete = complete
        self.inputs = RevisionInputs(snapshot)

    def runtime(
        self, ledger: ArtifactRecord, pointer: str, features: tuple[ArtifactRecord, ...]
    ) -> None:
        """Require characterization for each feature with declared runtime need."""
        for feature in features:
            supported = False
            # Validate scenario claims before treating captures as execution proof.
            for scenario in self.context.index.records:
                if (
                    scenario.kind != "runtime-characterization-scenario"
                    or scenario.artifact.repository != ledger.artifact.repository
                    or feature not in self.context.targets(scenario, "/feature_refs")
                ):
                    continue
                if scenario.document.get("result_status") in (
                    "observed",
                    "passed",
                ) and not any(
                    f.artifact_path == scenario.artifact.path and f.severity == "error"
                    for f in self.claims.findings
                ):
                    supported = True
            if not supported:
                self.context.add(
                    "COVERAGE_RUNTIME",
                    ledger,
                    pointer,
                    "Runtime need requires a valid observed or passed scenario.",
                )
        if not features:
            self.context.add(
                "COVERAGE_RUNTIME",
                ledger,
                pointer,
                "Runtime-required components need linked feature characterization.",
            )

    def tests(self, ledger: ArtifactRecord, row: JsonObject, pointer: str) -> None:
        """Verify discovered test links without claiming measured coverage or a pass."""
        for position, test in object_rows(row.get("tests_found")):
            location = f"{pointer}/tests_found/{position}"
            path = test.get("path")
            if (
                not isinstance(path, str)
                or self.inputs.content(
                    ledger,
                    repository=ledger.repository,
                    revision=ledger.artifact.repository.revision,
                    path=path,
                    immutable=True,
                )
                is None
            ):
                self.context.add(
                    "COVERAGE_TEST",
                    ledger,
                    location,
                    "A referenced test requires captured bytes at the ledger pin.",
                )
            if not self.context.proof(ledger, location + "/evidence_refs"):
                self.context.add(
                    "COVERAGE_TEST",
                    ledger,
                    location,
                    "Test relevance requires local observation evidence.",
                )

    def component(
        self,
        ledger: ArtifactRecord,
        row: JsonObject,
        position: int,
        selection: CoverageScope,
    ) -> None:
        """Check provenance and disposition independently of inspection state."""
        pointer = f"/components/{position}"
        identifier = row.get("component_id")
        original = (
            selection.components.get(identifier)
            if isinstance(identifier, str)
            else None
        )
        if original is None:
            self.context.add(
                "COVERAGE_FOREIGN_COMPONENT",
                ledger,
                pointer,
                "Ledger component is absent from its linked inventory.",
            )
            return
        source = original.get("source")
        if (
            not isinstance(source, JsonObject)
            or original.get("component_type") != row.get("component_type")
            or any(
                source.get(left) != row.get(right)
                for left, right in (
                    ("path", "path"),
                    ("sha256", "source_sha256"),
                    ("symbol", "symbol"),
                    ("line_range", "line_range"),
                )
            )
        ):
            self.context.add(
                "COVERAGE_COMPONENT",
                ledger,
                pointer,
                "Ledger component provenance differs from its inventory detection.",
            )
        disposition, inspection = row.get("disposition"), row.get("inspection_status")
        features = self.context.targets(ledger, pointer + "/feature_refs")
        claimed = inspection == "inspected" or disposition in (
            "feature-linked",
            "supporting",
            "excluded",
        )
        if claimed and not self.context.proof(
            ledger, pointer + "/last_updated_evidence_refs"
        ):
            self.context.add(
                "COVERAGE_EVIDENCE",
                ledger,
                pointer,
                "Inspection and dispositions require local update evidence.",
            )
        if (
            disposition in ("feature-linked", "supporting")
            and inspection != "inspected"
        ):
            self.context.add(
                "COVERAGE_INSPECTION",
                ledger,
                pointer,
                "A functional disposition does not substitute for inspection.",
            )
        if disposition == "feature-linked" and (
            not features
            or len(features)
            != len(self.context.links(ledger, pointer + "/feature_refs"))
        ):
            self.context.add(
                "COVERAGE_FEATURE",
                ledger,
                pointer,
                "Feature-linked components require resolved feature contracts.",
            )
        if disposition == "supporting" and not has_text(
            row.get("supporting_rationale")
        ):
            self.context.add(
                "COVERAGE_RATIONALE",
                ledger,
                pointer,
                "Supporting components require a substantive rationale.",
            )
        if disposition == "excluded":
            references = self.context.targets(ledger, pointer + "/exclusion_scope_ref")
            path = row.get("path")
            if (
                references != (selection.scope,)
                or selection.scope.document.get("status") != "confirmed"
                or not isinstance(path, str)
                or not excluded(path, selection.scope)
                or not has_text(row.get("exclusion_rationale"))
            ):
                self.context.add(
                    "COVERAGE_EXCLUSION",
                    ledger,
                    pointer,
                    "Exclusion requires matching confirmed scope and rationale.",
                )
        if (inspection == "blocked" or disposition == "blocked") and not has_text(
            row.get("blocked_reason")
        ):
            self.context.add(
                "COVERAGE_RATIONALE",
                ledger,
                pointer,
                "Blocked components require a recorded reason.",
            )
        runtime = row.get("runtime_validation_requirement")
        if runtime == "not-required" and not has_text(row.get("runtime_rationale")):
            self.context.add(
                "COVERAGE_RATIONALE",
                ledger,
                pointer,
                "A declared runtime waiver requires explicit rationale.",
            )
        self.tests(ledger, row, pointer)
        if self.complete and identifier in selection.selected:
            gates = self.snapshot.profile.completion_gates
            if gates.required("require_all_dispositions") and (
                disposition in ("unassigned", "blocked")
                or inspection == "blocked"
                or inspection != "inspected"
                and disposition != "excluded"
            ):
                self.context.add(
                    "COVERAGE_INCOMPLETE",
                    ledger,
                    pointer,
                    "Selected components require completed inspection/disposition.",
                )
            if gates.required("require_runtime_for_declared_features"):
                if runtime == "undetermined":
                    self.context.add(
                        "COVERAGE_RUNTIME",
                        ledger,
                        pointer,
                        "Selected runtime need remains undetermined.",
                    )
                elif runtime == "required" and disposition != "excluded":
                    self.runtime(ledger, pointer, features)

    def ledger(self, ledger: ArtifactRecord) -> None:
        """Reconcile every row and require exact selected-component accounting."""
        selection = select_coverage_scope(
            self.snapshot, ledger, self.context, complete=self.complete
        )
        if selection is None:
            return
        seen: set[str] = set()
        # Duplicate declarations never satisfy exact-once inventory accounting.
        for position, row in object_rows(ledger.document.get("components")):
            identifier = row.get("component_id")
            if isinstance(identifier, str):
                if identifier in seen:
                    self.context.add(
                        "COVERAGE_DUPLICATE",
                        ledger,
                        f"/components/{position}",
                        "A component appears more than once in the ledger.",
                    )
                seen.add(identifier)
            self.component(ledger, row, position, selection)
        if self.complete and selection.selected - seen:
            self.context.add(
                "COVERAGE_MISSING",
                ledger,
                "/components",
                "Selected inventory components are missing from the ledger.",
            )


def validate_coverage(
    snapshot: DiscoverySnapshot,
    *,
    complete: bool = False,
    index: ReferenceIndex | None = None,
    evidence: EvidenceValidation | None = None,
    claims: ClaimValidation | None = None,
) -> CoverageValidation:
    """Check immutable coverage claims, optionally adding discovery prerequisites.

    Draft/unassigned records remain structurally valid without a completion claim.
    Supplied graph/evidence/claim results are reused; all operations are pure.
    """
    index = index if index is not None else index_references(snapshot)
    evidence = (
        evidence if evidence is not None else validate_evidence(snapshot, index=index)
    )
    claims = (
        claims
        if claims is not None
        else validate_claims(snapshot, index=index, evidence=evidence)
    )
    context = ClaimContext(
        index, evidence, snapshot.profile.limits.parse_limits().findings
    )
    rules = _CoverageRules(snapshot, context, claims, complete=complete)
    ledgers = tuple(
        record for record in index.records if record.kind == "coverage-ledger"
    )
    for ledger in ledgers:
        rules.ledger(ledger)
    if complete and not ledgers:
        context.collector.add(
            Finding(
                code="COVERAGE_LEDGER",
                message="Discovery completion requires a coverage ledger.",
                next_action="Supply the configured ledger and scope.",
            )
        )
    return CoverageValidation(context.collector.findings)
