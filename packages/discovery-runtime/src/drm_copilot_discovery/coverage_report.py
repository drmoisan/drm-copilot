"""Project source discovery coverage from accepted immutable graph assessments.

Reported statuses describe authored observations; evidence-backed numerators and
discovery gate results remain separate. This module performs no publication.
"""

from __future__ import annotations

from collections import Counter
from typing import TYPE_CHECKING

from drm_copilot_discovery.coverage_population import (
    CoveragePopulation,
    record_identity,
)
from drm_copilot_discovery.models import JsonObject
from drm_copilot_discovery.report_models import (
    DiscoveryReport,
    ReportBudget,
    bounded_object,
    ratio,
)
from drm_copilot_discovery.snapshot import DiscoverySnapshot

if TYPE_CHECKING:
    from drm_copilot_discovery.claim_rules import ClaimValidation
    from drm_copilot_discovery.coverage_population import Identity
    from drm_copilot_discovery.dimension_rules import DimensionValidation
    from drm_copilot_discovery.evidence_rules import EvidenceValidation
    from drm_copilot_discovery.findings import Finding
    from drm_copilot_discovery.references import ReferenceIndex
    from drm_copilot_discovery.validation import ValidationMode


def coverage_preflight(snapshot: DiscoverySnapshot) -> None:
    """Bound snapshot (DiscoverySnapshot) before report validation; return None.

    Checks aggregate artifact bytes/nodes and metadata traversal, not source
    payload length. Raises ValueError for invalid input or ReportLimitError on
    excess. No I/O or caller mutation; accepted rules still validate all claims.
    """
    if type(snapshot) is not DiscoverySnapshot:
        raise ValueError("Coverage reports require a captured v2 DiscoverySnapshot")
    budget = ReportBudget(snapshot.profile.limits.parse_limits())
    budget.work(
        len(snapshot.artifacts)
        + len(snapshot.manifest.files)
        + len(snapshot.repository_files)
    )
    budget.check(snapshot.profile.document)
    # Reports are output views; their own text must not consume semantic input budget.
    for artifact in snapshot.artifacts:
        if artifact.expected_kind not in {
            "coverage-report",
            "parity-report",
            "completion-report",
        }:
            budget.check(artifact.document)


def unavailable_coverage_summary() -> JsonObject:
    """Return unavailable populations after structural failure, without I/O.

    Semantic counts are null rather than invented zero facts. The calling report
    envelope retains actual validation blockers; no success authority is granted.
    """
    return JsonObject(
        (
            ("population_state", "unavailable"),
            ("components", None),
            ("features", None),
            ("runtime", None),
            ("unresolved_behaviors", None),
            ("metrics", None),
            ("known_inventory_refs", None),
        )
    )


class _CoverageProjection:
    """Compute report ratios from one source-owned population without publication.

    Construct from the validation composer's typed assessments, then project
    once. Population selection/proof remain in CoveragePopulation. Only local
    counters change; work and JSON capacities abort excess without partial output.
    """

    def __init__(
        self,
        snapshot: DiscoverySnapshot,
        index: ReferenceIndex,
        evidence: EvidenceValidation,
        claims: ClaimValidation,
        dimensions: DimensionValidation,
        findings: tuple[Finding, ...],
    ) -> None:
        """Retain accepted inputs and initialize the projection; return None.

        snapshot (DiscoverySnapshot) holds captured inputs; index (ReferenceIndex)
        resolves graph records/links. evidence (EvidenceValidation) supplies
        usable proof; claims (ClaimValidation) supplies observation failures.
        dimensions (DimensionValidation) supplies feature/client obligations.
        findings (tuple[Finding]) contains complete discovery diagnostics.
        Assessments are supplied by the validator, not caller authority.
        Raises ReportLimitError on excess population indexing. No I/O, caller
        mutation, evidence promotion or approval occurs.
        """
        self.population = CoveragePopulation(
            snapshot, index, evidence, claims, findings
        )
        self.dimensions = dimensions

    def components(
        self, runtime_features: set[Identity], verified_features: set[Identity]
    ) -> tuple[dict[str, int], dict[str, JsonObject]]:
        """Aggregate source runtime_features and verified_features (set[Identity]).

        The first set has observed proof; the second has valid passed proof.
        Returns (counts, ratios). Status counts are authored; eligible denominator
        removes only validated exclusions. Missing/conflicting rows cannot prove
        evidence or runtime. Raises ReportLimitError on prospective work excess.
        """
        counts: dict[str, int] = dict.fromkeys(
            (
                "total",
                "inventoried",
                "unselected",
                "missing_ledger",
                "conflicting_ledger",
                "inspected",
                "inspection_blocked",
                "uninspected",
                "dispositioned",
                "undispositioned",
                "blocked",
                "excluded",
                "excluded_valid",
                "feature_linked",
                "runtime_required",
                "runtime_undetermined",
                "runtime_supported",
                "runtime_observed",
                "runtime_verified",
                "runtime_missing",
                "with_update_evidence",
            ),
            0,
        )
        self.population.budget.work(
            len(self.population.selected) + len(self.population.inventoried)
        )
        counts.update(
            total=len(self.population.selected),
            inventoried=len(self.population.inventoried),
            unselected=len(self.population.inventoried - self.population.selected),
        )
        eligible_inspected = eligible_linked = 0
        # Integer aggregation is order-independent and counts each identity once.
        for key in self.population.selected:
            rows = self.population.rows.get(key, [])
            if not rows:
                counts["missing_ledger"] += 1
                counts["undispositioned"] += 1
                counts["runtime_undetermined"] += 1
                continue
            self.population.budget.work(2 * len(rows))
            # Distinct authored states expose conflicting ledger copies explicitly.
            inspections = {row.get("inspection_status") for _, _, row in rows}
            dispositions = {row.get("disposition") for _, _, row in rows}
            if len(rows) != 1:
                counts["conflicting_ledger"] += 1
            inspected = inspections == {"inspected"}
            counts["inspected"] += inspected
            counts["inspection_blocked"] += "blocked" in inspections
            counts["uninspected"] += inspections == {"uninspected"}
            counts["blocked"] += "blocked" in inspections or "blocked" in dispositions
            counts["excluded"] += dispositions == {"excluded"}
            dispositioned = len(dispositions) == 1 and next(iter(dispositions)) in {
                "feature-linked",
                "supporting",
                "excluded",
            }
            counts["dispositioned"] += dispositioned
            counts["undispositioned"] += not dispositioned
            ledger, position, row = rows[0]
            pointer = f"/components/{position}"
            excluded = (
                len(rows) == 1
                and (ledger.artifact.path, position) in self.population.exclusion_valid
            )
            counts["excluded_valid"] += excluded
            eligible_inspected += inspected and not excluded
            targets = (
                self.population.targets(ledger, pointer + "/feature_refs")
                if len(rows) == 1
                else ()
            )
            self.population.budget.work(len(targets))
            # Count resolved source feature links independently of ledger disposition.
            linked = {
                record_identity(feature, str(feature.document.get("feature_id")))
                for feature in targets
                if feature.kind == "feature-contract"
                and feature.artifact.repository == ledger.artifact.repository
            }
            counts["feature_linked"] += bool(linked)
            eligible_linked += bool(linked) and not excluded
            counts["with_update_evidence"] += len(rows) == 1 and self.population.proof(
                ledger, pointer + "/last_updated_evidence_refs"
            )
            if not excluded:
                requirement = (
                    row.get("runtime_validation_requirement")
                    if len(rows) == 1
                    else "undetermined"
                )
                counts["runtime_required"] += requirement == "required"
                counts["runtime_undetermined"] += requirement == "undetermined"
                observed = (
                    requirement == "required"
                    and bool(linked)
                    and linked <= runtime_features
                    and self.population.clean(ledger, pointer)
                )
                counts["runtime_supported"] += observed
                counts["runtime_observed"] += observed
                counts["runtime_verified"] += observed and linked <= verified_features
        counts["runtime_missing"] = (
            counts["runtime_required"] - counts["runtime_observed"]
        )
        eligible = counts["total"] - counts["excluded_valid"]
        metrics = {
            "inspection": ratio(
                eligible_inspected,
                eligible,
                unit="selected nonexcluded component identities",
            ),
            "feature_contract_coverage": ratio(
                eligible_linked,
                eligible,
                unit="selected nonexcluded component identities",
            ),
            "runtime_characterization": ratio(
                counts["runtime_supported"],
                counts["runtime_required"],
                unit="selected nonexcluded runtime-required component identities",
            ),
            "component_evidence": ratio(
                counts["with_update_evidence"],
                counts["total"],
                unit="selected component update-proof obligations",
            ),
            "runtime_verified": ratio(
                counts["runtime_verified"],
                counts["runtime_required"],
                unit="selected nonexcluded runtime-required component identities",
            ),
            "runtime_missing": ratio(
                counts["runtime_missing"],
                counts["runtime_required"],
                unit="selected nonexcluded runtime-required component identities",
            ),
        }
        return counts, metrics

    def project(self) -> JsonObject:
        """Return the complete immutable summary; raise on any resource excess.

        Performs no I/O or publication. Required features are distinct from client
        obligations, and source evidence eligibility is distinct from confidence.
        """
        self.population.collect()
        inventories: list[JsonObject] = []
        self.population.budget.work(len(self.population.index.records))
        # Captured inventory references remain facts even when selection is unavailable.
        for record in self.population.index.records:
            if (
                record.kind == "inventory-snapshot"
                and record.artifact.repository in self.population.sources
            ):
                reference = JsonObject(
                    (
                        ("repository", record.repository),
                        ("revision", record.artifact.repository.revision),
                        ("id", record.id),
                        ("path", record.artifact.path),
                    )
                )
                self.population.budget.check(reference)
                inventories.append(reference)
        if not self.population.available:
            return bounded_object(
                {
                    **dict(unavailable_coverage_summary().members),
                    "known_inventory_refs": inventories,
                },
                limits=self.population.snapshot.profile.limits.parse_limits(),
            )
        (
            runtime_features,
            verified_features,
            supported_scenarios,
            verified_scenarios,
            statuses,
        ) = self.population.runtime()
        components, metrics = self.components(runtime_features, verified_features)
        required: set[Identity] = set()
        client_obligations = 0
        self.population.budget.work(
            len(self.dimensions.obligations) + len(self.population.features)
        )
        # Multiple clients create obligations, not additional feature identities.
        for obligation in self.dimensions.obligations:
            feature = obligation.feature
            if (
                obligation.required
                and feature.artifact.repository in self.population.sources
            ):
                required.add(
                    record_identity(feature, str(feature.document.get("feature_id")))
                )
                client_obligations += 1
        evidenced = verified = 0
        confidence: Counter[str] = Counter()
        # Evidence availability and authored verification are independently reported.
        for feature in self.population.features.values():
            proof = self.population.proof(
                feature, "/source_evidence_refs"
            ) or self.population.proof(feature, "/runtime_evidence_refs", runtime=True)
            evidenced += proof
            verified += (
                proof
                and feature.document.get("observation_state") == "verified"
                and feature.artifact.path not in self.population.claim_errors
            )
            confidence[str(feature.document.get("confidence"))] += 1
        metrics["feature_evidence"] = ratio(
            evidenced,
            len(self.population.features),
            unit="source feature proof obligations",
        )
        metrics["evidence_completeness"] = ratio(
            evidenced + components["with_update_evidence"],
            len(self.population.features) + components["total"],
            unit="source feature or selected component update-proof obligations",
        )
        value: dict[str, object] = {
            "population_state": "available",
            "known_inventory_refs": inventories,
            "components": components,
            "features": {
                "total": len(self.population.features),
                "required": len(required),
                "required_client_obligations": client_obligations,
                "with_evidence": evidenced,
                "verified_claims": verified,
                "confidence_counts": dict(sorted(confidence.items())),
            },
            "runtime": {
                "unit": "selected nonexcluded runtime-required component identities",
                "denominator": components["runtime_required"],
                "required": components["runtime_required"],
                "observed": components["runtime_observed"],
                "verified": components["runtime_verified"],
                "missing": components["runtime_missing"],
                "source_scenarios": len(self.population.scenarios),
                "supported_scenarios": supported_scenarios,
                "verified_scenarios": verified_scenarios,
                "supported_features": len(
                    runtime_features & self.population.features.keys()
                ),
                "result_counts": statuses,
            },
            "unresolved_behaviors": len(self.population.questions),
            "metrics": metrics,
        }
        return bounded_object(
            value, limits=self.population.snapshot.profile.limits.parse_limits()
        )


def coverage_summary(
    snapshot: DiscoverySnapshot,
    *,
    index: ReferenceIndex,
    evidence: EvidenceValidation,
    claims: ClaimValidation,
    dimensions: DimensionValidation,
    findings: tuple[Finding, ...],
) -> JsonObject:
    """Project accepted captured graph assessments into an immutable JsonObject.

    snapshot (DiscoverySnapshot) holds captured inputs; index (ReferenceIndex)
    resolves records/links. evidence (EvidenceValidation) supplies proof
    eligibility; claims (ClaimValidation) supplies observation failures.
    dimensions (DimensionValidation) supplies feature/client obligations.
    findings (tuple[Finding]) carries complete discovery blockers. This internal
    composition seam grants no validation authority to caller-created assessments.
    Returns JsonObject; raises ValueError/ReportLimitError on invalid/excess input.
    No I/O, encoding, graph mutation, decision approval or publication occurs.
    """
    coverage_preflight(snapshot)
    return _CoverageProjection(
        snapshot, index, evidence, claims, dimensions, findings
    ).project()


def build_coverage_report(
    snapshot: DiscoverySnapshot,
    *,
    identifier: str = "coverage",
    mode: ValidationMode = "discovery-complete",
) -> DiscoveryReport:
    """Generate coverage for snapshot, identifier (str) and root mode (ValidationMode).

    Returns DiscoveryReport from the same authoritative projection used by report
    validation. Invalid graph inputs retain blockers, not synthetic completeness.
    Raises ValueError for unsupported caller inputs and ReportLimitError on excess.
    Performs no I/O or publication and accepts no injected validator/assessment.
    """
    from drm_copilot_discovery.validation import report_projection

    coverage_preflight(snapshot)
    value = report_projection(
        snapshot, kind="coverage-report", identifier=identifier, mode=mode
    )
    return DiscoveryReport(
        document=bounded_object(value, limits=snapshot.profile.limits.parse_limits()),
        limits=snapshot.profile.limits.parse_limits(),
    )
