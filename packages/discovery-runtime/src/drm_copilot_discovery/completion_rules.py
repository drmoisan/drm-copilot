"""Apply completion policy without changing observations or granting host authority."""

from __future__ import annotations

from dataclasses import dataclass
from typing import TYPE_CHECKING

from drm_copilot_discovery.claim_rules import ClaimContext
from drm_copilot_discovery.coverage_scope_rules import strings
from drm_copilot_discovery.dimension_rules import covering_decisions, decision_scope
from drm_copilot_discovery.findings import Finding
from drm_copilot_discovery.models import JsonObject
from drm_copilot_discovery.revision_rules import is_full_revision
from drm_copilot_discovery.snapshot import repository_pins

if TYPE_CHECKING:
    from drm_copilot_discovery.claim_rules import ClaimValidation
    from drm_copilot_discovery.decision_rules import DecisionValidation
    from drm_copilot_discovery.dimension_rules import (
        DimensionValidation,
        FeatureObligation,
    )
    from drm_copilot_discovery.evidence_rules import EvidenceValidation
    from drm_copilot_discovery.profile_models import CompletionGate
    from drm_copilot_discovery.references import ArtifactRecord, ReferenceIndex
    from drm_copilot_discovery.snapshot import DiscoverySnapshot


@dataclass(frozen=True)
class CompletionValidation:
    """Retain only policy findings; lower rule families remain independent inputs."""

    findings: tuple[Finding, ...]


class _CompletionRules:
    """Check required scope and feature obligations over one accepted graph.

    Construction retains immutable assessments. Checks append bounded findings
    through ClaimContext; no input, observation state or authority record changes.
    """

    def __init__(
        self,
        snapshot: DiscoverySnapshot,
        context: ClaimContext,
        claims: ClaimValidation,
        decisions: DecisionValidation,
    ) -> None:
        """Reuse graph/proof/claim/decision inputs without rebuilding a catalog."""
        self.snapshot, self.context = snapshot, context
        self.claims, self.decisions = claims, decisions
        self.gates = snapshot.profile.completion_gates

    def prerequisites(self, *, parity: bool) -> None:
        """Require configured immutable source context before claiming completion."""
        profile = self.snapshot.profile
        sources, targets = repository_pins(profile)
        if profile.document.get("profile_state") != "configured":
            self.context.collector.add(
                Finding(
                    code="COMPLETION_PROFILE",
                    message="Completion requires a configured profile.",
                    next_action="Configure the profile and capture its inputs.",
                )
            )
        if not sources or any(not is_full_revision(item.revision) for item in sources):
            self.context.collector.add(
                Finding(
                    code="COMPLETION_SOURCE",
                    message="Completion requires full source revision pins.",
                    next_action="Configure and capture the required source snapshots.",
                )
            )
        if parity and (
            not targets or any(not is_full_revision(item.revision) for item in targets)
        ):
            self.context.collector.add(
                Finding(
                    code="COMPLETION_TARGET",
                    message="Parity requires full target revision pins.",
                    next_action="Configure and capture target repository identities.",
                )
            )
        prerequisites: tuple[tuple[str, CompletionGate], ...] = (
            ("scope", "require_confirmed_scope"),
            ("inventory-snapshot", "require_current_inventory"),
            ("coverage-ledger", "require_all_dispositions"),
        )
        # A second source cannot borrow the first source's complete ledger/scope.
        for source in sources:
            # Trusted origin and pin distinguish imported source and target artifacts.
            records = tuple(
                item
                for item in self.context.index.records
                if item.artifact.repository == source
            )
            # Independent switches do not waive another configured source input.
            for kind, gate in prerequisites:
                if self.gates.required(gate) and not any(
                    item.kind == kind for item in records
                ):
                    self.context.collector.add(
                        Finding(
                            code="COMPLETION_INPUT",
                            message=f"Source {source.id} lacks required {kind}.",
                            next_action="Capture the source discovery artifacts.",
                        )
                    )

    def runtime(self, feature: ArtifactRecord) -> None:
        """Require a valid same-source observation for explicit feature runtime need."""
        # Target execution never supplies the legacy characterization prerequisite.
        for scenario in self.context.index.records:
            if (
                scenario.kind == "runtime-characterization-scenario"
                and scenario.artifact.repository == feature.artifact.repository
                and feature in self.context.targets(scenario, "/feature_refs")
                and scenario.document.get("result_status") in ("observed", "passed")
                and not any(
                    item.artifact_path == scenario.artifact.path
                    and item.severity == "error"
                    for item in self.claims.findings
                )
            ):
                return
        self.context.add(
            "COMPLETION_RUNTIME",
            feature,
            "",
            "Declared runtime need lacks valid source characterization.",
        )

    def feature(self, obligation: FeatureObligation) -> None:
        """Keep required evidence and unresolved legacy questions independent of
        policy.
        """
        if not obligation.required:
            return
        feature = obligation.feature
        # Only retained source observation proof satisfies the optional evidence gate.
        if self.gates.required("require_feature_evidence") and not any(
            assessment.can_prove(
                repository=feature.repository,
                revision=feature.artifact.repository.revision,
                evidence_types=(
                    "source",
                    "test",
                    "documentation",
                    "inventory",
                    "runtime",
                    "observation",
                ),
            )
            for target in self.context.targets(feature, "")
            if (assessment := self.context.evidence.for_record(target)) is not None
        ):
            self.context.add(
                "COMPLETION_EVIDENCE",
                feature,
                "",
                "Required features need retained source observation evidence.",
            )
        if self.gates.required("block_on_unresolved_required_behavior"):
            # A resolved target policy question cannot close separate legacy
            # uncertainty.
            for question in self.context.questions(feature, None):
                dimensions = strings(question.document.get("dimensions"))
                if not dimensions or dimensions.intersection(
                    obligation.requirements.dimensions + obligation.requirements.modes
                ):
                    self.context.add(
                        "COMPLETION_UNRESOLVED",
                        question,
                        "/status",
                        "Required legacy behavior remains unresolved.",
                    )
        if self.gates.required("require_approved_deviations"):
            # Declared intentional uncertainty still needs current, scoped approval.
            for name, value in feature.document.items():
                if name == "state_transitions" and isinstance(value, JsonObject):
                    value = value.get("behavior")
                if (
                    isinstance(value, JsonObject)
                    and value.get("observation_state") == "intentionally-unspecified"
                ):
                    pointer = (
                        "/state_transitions/behavior"
                        if name == "state_transitions"
                        else "/" + name
                    )
                    if not covering_decisions(
                        self.context,
                        self.decisions,
                        feature,
                        pointer + "/product_decision_refs",
                        decision_scope(
                            feature, client_id=obligation.client_id, dimensions=(name,)
                        ),
                    ):
                        self.context.add(
                            "COMPLETION_DECISION",
                            feature,
                            pointer,
                            "Intentional uncertainty needs current scoped approval.",
                        )


def validate_completion(
    snapshot: DiscoverySnapshot,
    *,
    index: ReferenceIndex,
    evidence: EvidenceValidation,
    claims: ClaimValidation,
    decisions: DecisionValidation,
    dimensions: DimensionValidation,
    parity: bool = False,
) -> CompletionValidation:
    """Apply remaining profile switches to accepted rules; return policy findings only.

    Coverage, dimension, acceptance and parity completeness are composed by the
    public mode validator. This helper does not read files or authorize a gate.
    """
    context = ClaimContext(
        index, evidence, snapshot.profile.limits.parse_limits().findings
    )
    rules = _CompletionRules(snapshot, context, claims, decisions)
    rules.prerequisites(parity=parity)
    # Each client retains inherited requirements; repeated findings are deduplicated.
    for obligation in dimensions.obligations:
        rules.feature(obligation)
    if snapshot.profile.completion_gates.required(
        "require_runtime_for_declared_features"
    ):
        features = tuple(
            record for record in index.records if record.kind == "feature-contract"
        )
        # Missing requested IDs cannot be erased by omitting the corresponding contract.
        for identifier in snapshot.profile.runtime.required_feature_ids:
            selected = tuple(
                item
                for item in features
                if item.document.get("feature_id") == identifier
            )
            if not selected:
                context.collector.add(
                    Finding(
                        code="COMPLETION_RUNTIME",
                        message=f"Runtime-required feature {identifier} is absent.",
                        next_action="Supply the required feature and characterization.",
                    )
                )
            for feature in selected:
                rules.runtime(feature)
    return CompletionValidation(context.collector.findings)
