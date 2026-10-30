"""Retain inherited obligations without treating optional dimensions as passes."""

from __future__ import annotations

from dataclasses import dataclass
from typing import TYPE_CHECKING

from drm_copilot_discovery.claim_rules import ClaimContext
from drm_copilot_discovery.coverage_scope_rules import strings
from drm_copilot_discovery.decision_rules import DecisionScope, validate_decisions
from drm_copilot_discovery.evidence_rules import validate_evidence
from drm_copilot_discovery.models import JsonObject
from drm_copilot_discovery.profile_models import FEATURE_DIMENSIONS, ProfileRequirements
from drm_copilot_discovery.references import index_references
from drm_copilot_discovery.runtime_claim_rules import has_text

if TYPE_CHECKING:
    from drm_copilot_discovery.decision_rules import (
        ApprovedDecision,
        DecisionValidation,
    )
    from drm_copilot_discovery.evidence_rules import EvidenceValidation
    from drm_copilot_discovery.findings import Finding
    from drm_copilot_discovery.models import JsonValue
    from drm_copilot_discovery.references import ArtifactRecord, ReferenceIndex
    from drm_copilot_discovery.snapshot import DiscoverySnapshot


def decision_scope(
    feature: ArtifactRecord,
    *,
    client_id: str | None = None,
    platforms: tuple[str, ...] = (),
    modes: tuple[str, ...] = (),
    dimensions: tuple[str, ...] = (),
) -> DecisionScope:
    """Describe the exact feature and requirement axes needing scoped approval."""
    return DecisionScope(
        frozenset(((feature.repository, str(feature.document.get("feature_id"))),)),
        (
            frozenset(() if client_id is None else (client_id,)),
            frozenset(platforms),
            frozenset(modes),
            frozenset(dimensions),
        ),
    )


def covering_decisions(
    context: ClaimContext,
    decisions: DecisionValidation,
    record: ArtifactRecord,
    pointer: str,
    required: DecisionScope,
) -> tuple[ApprovedDecision, ...]:
    """Select only explicitly linked current approvals covering the whole request."""
    linked = context.targets(record, pointer)
    return tuple(
        item
        for item in decisions.approved
        if item.record in linked and item.scope.covers(required)
    )


def criterion_applies(
    criterion: JsonObject,
    client_id: JsonValue,
    platform_id: JsonValue,
    mode_id: JsonValue,
) -> bool:
    """Keep explicit criterion applicability separate from inherited obligations."""
    return all(
        not (selected := strings(criterion.get(axis)))
        or isinstance(value, str)
        and value in selected
        for axis, value in (
            ("client_ids", client_id),
            ("platforms", platform_id),
            ("modes", mode_id),
        )
    )


@dataclass(frozen=True)
class FeatureObligation:
    """Retain inherited requirements and approved waivers for one feature/client.

    A waiver records disposition, never verification. Custom modes/platforms use
    acceptance tuple fields because the behavior-dimension schema is closed.
    """

    feature: ArtifactRecord
    client_id: str | None
    requirements: ProfileRequirements
    required: bool
    waived: frozenset[str]


@dataclass(frozen=True)
class DimensionValidation:
    """Expose immutable obligations for later scenario/parity composition."""

    obligations: tuple[FeatureObligation, ...]
    findings: tuple[Finding, ...]


class _DimensionRules:
    """Check configured classifications without creating new observation facts."""

    def __init__(
        self,
        snapshot: DiscoverySnapshot,
        context: ClaimContext,
        decisions: DecisionValidation,
        *,
        complete: bool,
    ) -> None:
        """Reuse one graph and approval assessment for all feature/client unions."""
        self.snapshot, self.context, self.decisions = snapshot, context, decisions
        self.complete = complete
        self.scopes = tuple(
            record for record in context.index.records if record.kind == "scope"
        )

    def scope_requirements(
        self, feature: ArtifactRecord
    ) -> tuple[bool, frozenset[str]]:
        """Add explicit scope requirements without removing profile obligations."""
        required, modes = (
            feature.document.get("target_relevance") == "required",
            set[str](),
        )
        configured = {client.id for client in self.snapshot.profile.clients}
        for scope in self.scopes:
            coverage = scope.document.get("required_coverage")
            if not isinstance(coverage, JsonObject):
                continue
            targets = self.context.targets(scope, "/required_coverage/feature_refs")
            if feature not in targets + self.context.targets(
                scope, "/included_features"
            ):
                continue
            required = required or feature in targets
            modes.update(strings(coverage.get("modes")))
            if not strings(coverage.get("client_ids")) <= configured:
                self.context.add(
                    "DIMENSION_CLIENT",
                    scope,
                    "/required_coverage/client_ids",
                    "Scope requires an unconfigured client.",
                )
        return required, frozenset(modes)

    def classification(
        self,
        feature: ArtifactRecord,
        client_id: str | None,
        requirement: ProfileRequirements,
    ) -> frozenset[str]:
        """Validate required applicability while preserving historical uncertainty."""
        names = (
            set(requirement.dimensions)
            | (set(requirement.modes) & {"online", "offline", "mobile"})
            | (set(requirement.platforms) & {"mobile"})
        )
        client = next(
            (item for item in self.snapshot.profile.clients if item.id == client_id),
            None,
        )
        waived: set[str] = set()
        for name in sorted(names):
            value, pointer = feature.document.get(name), "/" + name
            if name == "state_transitions" and isinstance(value, JsonObject):
                value, pointer = value.get("behavior"), pointer + "/behavior"
            if not isinstance(value, JsonObject):
                if self.complete:
                    self.context.add(
                        "DIMENSION_MISSING",
                        feature,
                        pointer,
                        "Required behavior needs an explicit classification.",
                    )
                continue
            if feature.document.get("observation_state") == "verified" and value.get(
                "observation_state"
            ) in ("unknown", "contradictory", "inferred"):
                self.context.add(
                    "CLAIM_SUMMARY",
                    feature,
                    pointer,
                    "Verified summaries cannot hide unresolved required dimensions.",
                )
            applicability = value.get("applicability")
            if applicability is None and client is not None:
                default = client.applicability_defaults.get(name)
                applicability = (
                    default.get("applicability")
                    if isinstance(default, JsonObject)
                    else None
                )
            if applicability == "not-applicable":
                approved = covering_decisions(
                    self.context,
                    self.decisions,
                    feature,
                    pointer + "/product_decision_refs",
                    decision_scope(
                        feature,
                        client_id=client_id,
                        platforms=requirement.platforms,
                        modes=(name,) if name in requirement.modes else (),
                        dimensions=(name,),
                    ),
                )
                if has_text(value.get("rationale")) and approved:
                    waived.add(name)
                else:
                    self.context.add(
                        "DIMENSION_DISPOSITION",
                        feature,
                        pointer,
                        "Non-applicability needs rationale and scoped approval.",
                    )
            elif self.complete and applicability != "applicable":
                self.context.add(
                    "DIMENSION_UNSPECIFIED",
                    feature,
                    pointer,
                    "Required applicability cannot remain absent or unspecified.",
                )
            elif (
                self.complete
                and value.get("observation_state") in ("unknown", "contradictory")
                and self.snapshot.profile.completion_gates.required(
                    "block_on_unresolved_required_behavior"
                )
            ):
                self.context.add(
                    "DIMENSION_UNRESOLVED",
                    feature,
                    pointer,
                    "Required legacy observation remains unresolved.",
                )
        return frozenset(waived)

    def feature(self, feature: ArtifactRecord) -> tuple[FeatureObligation, ...]:
        """Union global, client, feature and scope requirements deterministically."""
        dimensions = strings(feature.document.get("required_dimensions"))
        if not dimensions <= FEATURE_DIMENSIONS:
            self.context.add(
                "DIMENSION_REQUIREMENTS",
                feature,
                "/required_dimensions",
                "Feature requirements contain an unsupported behavior dimension.",
            )
        required, modes = self.scope_requirements(feature)
        local = ProfileRequirements(
            platforms=(),
            modes=tuple(modes | (dimensions & {"online", "offline"})),
            dimensions=tuple(dimensions & FEATURE_DIMENSIONS),
        )
        clients = tuple(client.id for client in self.snapshot.profile.clients) or (
            None,
        )
        obligations: list[FeatureObligation] = []
        for client in sorted(clients, key=lambda value: value or ""):
            requirement = self.snapshot.profile.requirements(
                client_id=client, feature=local
            )
            waived = self.classification(feature, client, requirement)
            obligations.append(
                FeatureObligation(feature, client, requirement, required, waived)
            )
        return tuple(obligations)


def validate_dimensions(
    snapshot: DiscoverySnapshot,
    *,
    complete: bool = False,
    index: ReferenceIndex | None = None,
    evidence: EvidenceValidation | None = None,
    decisions: DecisionValidation | None = None,
) -> DimensionValidation:
    """Check required classifications; optional fields create no synthetic success.

    Custom operating modes remain explicit requirements for acceptance linkage.
    Proposed target policy cannot waive a requirement or resolve a legacy fact.
    """
    index = index if index is not None else index_references(snapshot)
    evidence = (
        evidence if evidence is not None else validate_evidence(snapshot, index=index)
    )
    decisions = (
        decisions
        if decisions is not None
        else validate_decisions(snapshot, index=index, evidence=evidence)
    )
    context = ClaimContext(
        index, evidence, snapshot.profile.limits.parse_limits().findings
    )
    rules = _DimensionRules(snapshot, context, decisions, complete=complete)
    obligations = tuple(
        item
        for record in index.records
        if record.kind == "feature-contract"
        for item in rules.feature(record)
    )
    return DimensionValidation(obligations, context.collector.findings)
