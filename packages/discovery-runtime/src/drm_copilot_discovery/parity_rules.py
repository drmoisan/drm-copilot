"""Check pinned parity and retain outcomes independently of authored summaries."""

from __future__ import annotations

from dataclasses import replace
from typing import TYPE_CHECKING

from drm_copilot_discovery.claim_rules import ClaimContext
from drm_copilot_discovery.coverage_scope_rules import object_rows
from drm_copilot_discovery.decision_rules import validate_decisions
from drm_copilot_discovery.dimension_rules import (
    covering_decisions,
    decision_scope,
    validate_dimensions,
)
from drm_copilot_discovery.evidence_rules import validate_evidence
from drm_copilot_discovery.models import JsonObject
from drm_copilot_discovery.parity_entry_rules import ParityEntryRules
from drm_copilot_discovery.parity_models import (
    ParityDimensionOutcome,
)
from drm_copilot_discovery.parity_models import (
    ParityValidation as ParityValidation,
)
from drm_copilot_discovery.parity_target_rules import TargetProof
from drm_copilot_discovery.reference_links import string_value
from drm_copilot_discovery.references import index_references
from drm_copilot_discovery.report_models import ReportBudget
from drm_copilot_discovery.revision_rules import validate_revisions
from drm_copilot_discovery.runtime_claim_rules import has_text

if TYPE_CHECKING:
    from drm_copilot_discovery.decision_rules import DecisionValidation
    from drm_copilot_discovery.dimension_rules import (
        DimensionValidation,
        FeatureObligation,
    )
    from drm_copilot_discovery.evidence_rules import EvidenceValidation
    from drm_copilot_discovery.references import ArtifactRecord, ReferenceIndex
    from drm_copilot_discovery.repository_reader import RepositoryIdentity
    from drm_copilot_discovery.revision_rules import RevisionValidation
    from drm_copilot_discovery.snapshot import DiscoverySnapshot


class _ParityRules:
    """Check every authored classification using the accepted proof services.

    Construct per assessment, then pass classifications to ParityEntryRules.
    Outcomes record actual disposition/proof/conflict decisions independently
    from bounded findings. Only private budgets and the caller's finding
    collector mutate; there is no I/O, execution or policy approval.
    """

    def __init__(
        self,
        snapshot: DiscoverySnapshot,
        context: ClaimContext,
        proof: TargetProof,
        decisions: DecisionValidation,
    ) -> None:
        """Retain snapshot/context/proof/decisions; return None without I/O.

        Types are DiscoverySnapshot, ClaimContext, TargetProof and
        DecisionValidation respectively. They supply limits, resolved references,
        independent target proof and current scoped approvals. ReportLimitError
        aborts later work before an excess allocation; no inputs are changed.
        """
        self.context, self.proof, self.decisions = context, proof, decisions
        self.budget = ReportBudget(snapshot.profile.limits.parse_limits())

    def classifications(
        self,
        matrix: ArtifactRecord,
        row: JsonObject,
        pointer: str,
        obligation: FeatureObligation,
        target: RepositoryIdentity,
        required: bool,
    ) -> tuple[frozenset[str], tuple[ParityDimensionOutcome, ...], bool]:
        """Check matrix/row/pointer and retain dimension outcomes.

        matrix (ArtifactRecord), row (JsonObject) and pointer (str) identify
        captured claims. obligation (FeatureObligation) supplies inherited axes,
        target (RepositoryIdentity) supplies ownership, and required (bool)
        requests completed proof. Returns (waived names, outcomes, validity).
        Raises ReportLimitError before excess work; adds established diagnostics
        without I/O or caller mutation.
        """
        dimensions = row.get("dimensions")
        size = len(dimensions) if isinstance(dimensions, JsonObject) else 0
        requirements = obligation.requirements
        local_links = len(
            self.context.by_source.get((matrix.artifact.path, matrix.pointer), ())
        )
        self.budget.work(
            4 * (size + 3)
            + len(requirements.dimensions)
            + len(requirements.modes)
            + len(requirements.platforms)
            + (size + 3)
            * (1 + local_links)
            * (
                len(self.context.index.links)
                + len(self.decisions.approved)
                + len(self.context.evidence.assessments)
            )
        )
        values = dict(dimensions.members) if isinstance(dimensions, JsonObject) else {}
        # Retain both representations so neither can hide invalid supplied proof.
        fields: list[tuple[str, object, str]] = []
        # Reserve repeated pointer text before allocating a joined location.
        for name, value in values.items():
            self.budget.text(pointer)
            self.budget.text(name)
            self.budget.spend(12)
            fields.append((name, value, pointer + "/dimensions/" + name))
        conflicts: set[str] = set()
        # Explicit and nested fixed modes must agree in either validation mode.
        for mode in ("online", "offline", "mobile"):
            direct, nested = row.get(mode), values.get(mode)
            if isinstance(direct, JsonObject):
                fields.append((mode, direct, pointer + "/" + mode))
                # These two authored values define classification consistency.
                inconsistent = isinstance(nested, JsonObject) and any(
                    direct.get(key) != nested.get(key)
                    for key in ("applicability", "verification")
                )
                if inconsistent:
                    conflicts.add(mode)
                    self.context.add(
                        "PARITY_MODE_CONFLICT",
                        matrix,
                        pointer + "/" + mode,
                        "Explicit and nested mode classifications disagree.",
                    )
        names = (
            set(requirements.dimensions)
            | (set(requirements.modes) & {"online", "offline", "mobile"})
            | (set(requirements.platforms) & {"mobile"})
        )
        present: set[str] = set()
        waived: set[str] = set()
        outcomes: list[ParityDimensionOutcome] = []
        # Optional supplied claims remain truthful without inventing obligations.
        for name, value, location in fields:
            if not isinstance(value, JsonObject):
                continue
            present.add(name)
            applicability = string_value(value.get("applicability"))
            verification = string_value(value.get("verification"))
            disposition_valid = True
            if applicability == "not-applicable":
                approval = covering_decisions(
                    self.context,
                    self.decisions,
                    matrix,
                    location + "/product_decision_refs",
                    decision_scope(
                        obligation.feature,
                        client_id=obligation.client_id,
                        platforms=requirements.platforms,
                        modes=(name,) if name in requirements.modes else (),
                        dimensions=(name,),
                    ),
                )
                disposition_valid = has_text(value.get("rationale")) and (
                    name not in names or bool(approval)
                )
                if disposition_valid:
                    waived.add(name)
                else:
                    self.context.add(
                        "PARITY_DISPOSITION",
                        matrix,
                        location,
                        "Required exclusions need rationale and covering approval.",
                    )
            proof_valid: bool | None = None
            if verification in ("passed", "failed"):
                proof_valid = self.proof.evidence(
                    matrix,
                    location + "/evidence_refs",
                    target,
                    obligation.client_id or "",
                    sources=(obligation.feature,),
                    mode=name if name in {"online", "offline"} else None,
                    platform=(
                        "mobile"
                        if name == "mobile" and "mobile" in requirements.platforms
                        else None
                    ),
                )
                if not proof_valid:
                    self.context.add(
                        "PARITY_DIMENSION_PROOF",
                        matrix,
                        location,
                        "Dimension results need independent contextual target proof.",
                    )
            required_valid = not (
                required
                and name in names
                and name not in waived
                and (applicability != "applicable" or verification != "passed")
            )
            if not required_valid:
                self.context.add(
                    "PARITY_DIMENSION",
                    matrix,
                    location,
                    "Required dimensions need passing proof or approved exclusion.",
                )
            outcomes.append(
                ParityDimensionOutcome(
                    name=name,
                    pointer=location,
                    required=name in names,
                    applicability=applicability,
                    verification=verification,
                    disposition_valid=disposition_valid,
                    proof_valid=proof_valid,
                    consistent=name not in conflicts,
                    valid=(
                        disposition_valid
                        and proof_valid is not False
                        and required_valid
                        and name not in conflicts
                    ),
                )
            )
        if required and names - present:
            self.context.add(
                "PARITY_DIMENSION",
                matrix,
                pointer + "/dimensions",
                "Required target classifications are absent.",
            )
        # Missing required axes stay unresolved; absent optional axes are not required.
        for name in sorted((names | {"online", "offline", "mobile"}) - present):
            outcomes.append(
                ParityDimensionOutcome(
                    name=name,
                    pointer=pointer + "/dimensions",
                    required=name in names,
                    applicability=None if name in names else "not-required",
                    verification=None,
                    disposition_valid=True,
                    proof_valid=None,
                    consistent=True,
                    valid=not (required and name in names),
                )
            )
        # Retained checks survive diagnostic truncation independently.
        valid = all(item.valid for item in outcomes)
        return frozenset(waived), tuple(outcomes), valid


def validate_parity(
    snapshot: DiscoverySnapshot,
    *,
    complete: bool = False,
    index: ReferenceIndex | None = None,
    evidence: EvidenceValidation | None = None,
    revisions: RevisionValidation | None = None,
    decisions: DecisionValidation | None = None,
    dimensions: DimensionValidation | None = None,
) -> ParityValidation:
    """Validate present parity truth and optionally required target completeness.

    snapshot (DiscoverySnapshot) holds captured inputs; complete (bool) enables
    required checks. Optional index (ReferenceIndex), evidence
    (EvidenceValidation), revisions (RevisionValidation), decisions
    (DecisionValidation) and dimensions (DimensionValidation) reuse accepted
    assessments from the same snapshot. Returns ParityValidation with bounded
    findings and immutable outcomes. ReportLimitError rejects excess retained
    work; no I/O, source edits, execution or aggregate readiness is authorized.
    """
    index = index if index is not None else index_references(snapshot)
    evidence = (
        evidence if evidence is not None else validate_evidence(snapshot, index=index)
    )
    revisions = (
        revisions
        if revisions is not None
        else validate_revisions(snapshot, index=index)
    )
    decisions = (
        decisions
        if decisions is not None
        else validate_decisions(snapshot, index=index, evidence=evidence)
    )
    dimensions = (
        dimensions
        if dimensions is not None
        else validate_dimensions(
            snapshot, index=index, evidence=evidence, decisions=decisions
        )
    )
    budget = ReportBudget(snapshot.profile.limits.parse_limits())
    budget.work(len(index.records) + len(index.links))
    # Bound captured row/identifier storage before adding retained result carriers.
    for record in index.records:
        if record.kind == "parity-matrix":
            budget.check(record.document)
    context = ClaimContext(
        index, evidence, snapshot.profile.limits.parse_limits().findings
    )
    proof = TargetProof(snapshot, context, revisions)
    classifications = _ParityRules(snapshot, context, proof, decisions)
    upstream = (
        index.findings
        + evidence.findings
        + revisions.findings
        + decisions.findings
        + dimensions.findings
    )
    budget.work(len(upstream))
    # Truncated upstream diagnostics cannot establish usable proof authority.
    truncated = any(item.code == "FINDINGS_LIMIT" for item in upstream)
    entries = ParityEntryRules(
        snapshot,
        context,
        proof,
        decisions,
        dimensions,
        classifications.classifications,
        complete=complete,
        truncated=truncated,
    )
    # Every matrix contributes to one deterministic source/client accounting set.
    for matrix in index.records:
        if matrix.kind == "parity-matrix":
            # Preserve original array positions for actionable evidence locations.
            for position, row in object_rows(matrix.document.get("entries")):
                entries.entry(matrix, position, row)
    outcomes = entries.finish()
    findings = context.collector.findings
    # Exhaustion of our own diagnostic budget likewise cannot imply validity.
    if any(item.code == "FINDINGS_LIMIT" for item in findings):
        budget.work(len(outcomes))
        # Preserve failed checks while conservatively removing truncated authority.
        outcomes = tuple(
            replace(item, valid=False, complete=False) for item in outcomes
        )
    return ParityValidation(findings, outcomes)
