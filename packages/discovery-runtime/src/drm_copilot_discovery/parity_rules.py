"""Check pinned source-to-target claims without promoting authored summaries."""

from __future__ import annotations

from dataclasses import dataclass
from itertools import product
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
from drm_copilot_discovery.parity_target_rules import TargetProof
from drm_copilot_discovery.reference_links import string_value
from drm_copilot_discovery.references import index_references
from drm_copilot_discovery.revision_rules import is_full_revision, validate_revisions
from drm_copilot_discovery.runtime_claim_rules import has_text

if TYPE_CHECKING:
    from drm_copilot_discovery.decision_rules import DecisionValidation
    from drm_copilot_discovery.dimension_rules import (
        DimensionValidation,
        FeatureObligation,
    )
    from drm_copilot_discovery.evidence_rules import EvidenceValidation
    from drm_copilot_discovery.findings import Finding
    from drm_copilot_discovery.references import ArtifactRecord, ReferenceIndex
    from drm_copilot_discovery.repository_reader import RepositoryIdentity
    from drm_copilot_discovery.revision_rules import RevisionValidation
    from drm_copilot_discovery.snapshot import DiscoverySnapshot


@dataclass(frozen=True)
class ParityValidation:
    """Return bounded parity findings without granting aggregate completion."""

    findings: tuple[Finding, ...]


def _declares(matrix: ArtifactRecord, name: str, identity: RepositoryIdentity) -> bool:
    """Require matrix role declarations to include the actual row identity."""
    # Matrix role headers authorize only explicitly declared immutable identities.
    return any(
        row.get("id") == identity.id and row.get("revision") == identity.revision
        for _, row in object_rows(matrix.document.get(name))
    )


class _ParityRules:
    """Evaluate entries using existing graph, evidence and requirement assessments."""

    def __init__(
        self,
        snapshot: DiscoverySnapshot,
        context: ClaimContext,
        proof: TargetProof,
        decisions: DecisionValidation,
        dimensions: DimensionValidation,
        *,
        complete: bool,
    ) -> None:
        """Keep per-call state private; reuse each immutable input assessment."""
        self.snapshot, self.context, self.proof = snapshot, context, proof
        self.decisions, self.dimensions, self.complete = decisions, dimensions, complete
        self.seen: set[tuple[ArtifactRecord, str]] = set()

    def source(
        self, matrix: ArtifactRecord, row: JsonObject, pointer: str
    ) -> ArtifactRecord | None:
        """Resolve immutable source identity before considering any target status."""
        field = pointer + "/source_contract_ref"
        targets = self.context.targets(matrix, field)
        source = targets[0] if len(targets) == 1 else None
        if (
            source is None
            or source.kind != "feature-contract"
            or source.document.get("feature_id") != row.get("feature_id")
            or self.proof.blocked(matrix, field)
            or not _declares(matrix, "source_repositories", source.artifact.repository)
        ):
            self.context.add(
                "PARITY_SOURCE",
                matrix,
                field,
                "Parity requires one source contract at its exact pin/hash.",
            )
            return None
        return source

    def target(
        self, matrix: ArtifactRecord, row: JsonObject, pointer: str
    ) -> RepositoryIdentity | None:
        """Require the configured client's target pin and its matrix declaration."""
        value = row.get("target_repository")
        client = next(
            (
                item
                for item in self.snapshot.profile.clients
                if item.id == row.get("client_id")
            ),
            None,
        )
        if (
            isinstance(value, JsonObject)
            and client is not None
            and is_full_revision(value.get("revision"))
        ):
            # Client assignment and target-role pin must both agree.
            for target in self.proof.targets:
                if (
                    target.id == client.target_repository == value.get("id")
                    and target.revision == value.get("revision")
                    and _declares(matrix, "target_repositories", target)
                ):
                    return target
        self.context.add(
            "PARITY_TARGET",
            matrix,
            pointer + "/target_repository",
            "Parity target must match its configured client and pin.",
        )
        return None

    def approval(
        self,
        matrix: ArtifactRecord,
        row: JsonObject,
        pointer: str,
        obligation: FeatureObligation,
    ) -> bool:
        """Retain current scoped changes/retirement without rewriting source facts."""
        state, feature = row.get("parity_state"), obligation.feature
        retired = state == "retired"
        field = pointer + (
            "/retirement_decision_ref" if retired else "/intentional_deviation_refs"
        )
        linked = self.context.targets(matrix, field)
        selected: list[ArtifactRecord] = []
        # Only current scoped approvals can authorize changes or whole retirement.
        for item in self.decisions.approved:
            request = decision_scope(
                feature,
                client_id=obligation.client_id,
                platforms=(
                    obligation.requirements.platforms
                    if retired
                    else tuple(item.scope.selectors[1])
                ),
                modes=(
                    obligation.requirements.modes
                    if retired
                    else tuple(item.scope.selectors[2])
                ),
                dimensions=() if retired else tuple(item.scope.selectors[3]),
            )
            applicable = item.scope.covers(request)
            # Changes can affect a subset; retirement must cover every required axis.
            if not retired:
                # Reject policies scoped exclusively to unrelated target contexts.
                for selected_values, required_values in (
                    (item.scope.selectors[1], obligation.requirements.platforms),
                    (item.scope.selectors[2], obligation.requirements.modes),
                ):
                    applicable = applicable and (
                        not selected_values
                        or bool(selected_values.intersection(required_values))
                    )
            if item.record in linked and applicable:
                selected.append(item.record)
        valid = bool(selected) and len(selected) == len(
            self.context.links(matrix, field)
        )
        if not valid:
            self.context.add(
                "PARITY_DECISION",
                matrix,
                field,
                "Changed/retired parity needs current scoped approval.",
            )
        return valid

    def classifications(
        self,
        matrix: ArtifactRecord,
        row: JsonObject,
        pointer: str,
        obligation: FeatureObligation,
        target: RepositoryIdentity,
        *,
        required: bool,
    ) -> frozenset[str]:
        """Check every classification, including both fixed-mode representations."""
        dimensions = row.get("dimensions")
        values = dict(dimensions.items()) if isinstance(dimensions, JsonObject) else {}
        # Preserve both representations so neither can hide invalid supplied proof.
        fields = [
            (name, value, pointer + "/dimensions/" + name)
            for name, value in values.items()
        ]
        # Duplicate classifications must agree regardless of completion mode.
        for mode in ("online", "offline", "mobile"):
            direct, nested = row.get(mode), values.get(mode)
            if isinstance(direct, JsonObject):
                fields.append((mode, direct, pointer + "/" + mode))
                if isinstance(nested, JsonObject) and any(
                    direct.get(key) != nested.get(key)
                    for key in ("applicability", "verification")
                ):
                    self.context.add(
                        "PARITY_MODE_CONFLICT",
                        matrix,
                        pointer + "/" + mode,
                        "Explicit and nested mode classifications disagree.",
                    )
        requirements = obligation.requirements
        names = (
            set(requirements.dimensions)
            | (set(requirements.modes) & {"online", "offline", "mobile"})
            | (set(requirements.platforms) & {"mobile"})
        )
        present: set[str] = set()
        waived: set[str] = set()
        # Optional claims stay truthful without creating required verification.
        for name, value, location in fields:
            if not isinstance(value, JsonObject):
                continue
            present.add(name)
            applicability, verification = value.get("applicability"), value.get(
                "verification"
            )
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
                if has_text(value.get("rationale")) and (name not in names or approval):
                    waived.add(name)
                else:
                    self.context.add(
                        "PARITY_DISPOSITION",
                        matrix,
                        location,
                        "Required exclusions need rationale and covering approval.",
                    )
            if verification in ("passed", "failed") and not self.proof.evidence(
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
            ):
                self.context.add(
                    "PARITY_DIMENSION_PROOF",
                    matrix,
                    location,
                    "Dimension results need independent contextual target proof.",
                )
            if (
                required
                and name in names
                and name not in waived
                and (applicability != "applicable" or verification != "passed")
            ):
                self.context.add(
                    "PARITY_DIMENSION",
                    matrix,
                    location,
                    "Required dimensions need passing proof or approved exclusion.",
                )
        if required and names - present:
            self.context.add(
                "PARITY_DIMENSION",
                matrix,
                pointer + "/dimensions",
                "Required target classifications are absent.",
            )
        return frozenset(waived)

    def entry(self, matrix: ArtifactRecord, position: int, row: JsonObject) -> None:
        """Separate honest incomplete states from unsupported full/approved claims."""
        pointer = f"/entries/{position}"
        source, target = self.source(matrix, row, pointer), self.target(
            matrix, row, pointer
        )
        client = string_value(row.get("client_id"))
        if source is None or target is None or client is None:
            return
        key = source, client
        if key in self.seen:
            self.context.add(
                "PARITY_DUPLICATE",
                matrix,
                pointer,
                "A source feature/client has multiple parity entries.",
            )
        self.seen.add(key)
        obligation = next(
            (
                item
                for item in self.dimensions.obligations
                if item.feature == source and item.client_id == client
            ),
            None,
        )
        if obligation is None:
            self.context.add(
                "PARITY_REQUIREMENTS",
                matrix,
                pointer,
                "The source feature/client lacks resolved requirement context.",
            )
            return
        state = row.get("parity_state")
        approved = (
            self.approval(matrix, row, pointer, obligation)
            if state in ("intentionally-changed", "retired")
            else False
        )
        required = (
            state == "full"
            or self.complete
            and obligation.required
            and state == "intentionally-changed"
        )
        waived = self.classifications(
            matrix, row, pointer, obligation, target, required=required
        )
        implementations = self.proof.links(matrix, pointer, source, target, client)
        # Retirement waives implementation completion, never false present claims.
        if state == "retired" and approved:
            return
        if state in ("full", "partial") or required:
            if not implementations or not self.proof.evidence(
                matrix,
                pointer + "/evidence_refs",
                target,
                client,
                sources=(source,),
                execution=required,
            ):
                self.context.add(
                    "PARITY_PROOF",
                    matrix,
                    pointer,
                    "Parity claims need independently evidenced target implementation.",
                )
        if required:
            # Linked components all contribute to the claimed implementation.
            if any(
                record.document.get("verification_state") != "passed"
                for record in implementations
            ):
                self.context.add(
                    "PARITY_VERIFICATION",
                    matrix,
                    pointer,
                    "Every linked implementation needs passing verification.",
                )
            if row.get("blockers") or row.get("validation_status") != "pass":
                self.context.add(
                    "PARITY_STATE",
                    matrix,
                    pointer,
                    "Completed parity needs no blockers and passing validation.",
                )
            platforms = set(obligation.requirements.platforms) - waived
            modes = set(obligation.requirements.modes) - waived
            # Passing components may divide coordinates but cannot omit any axis.
            for platform, mode in product(sorted(platforms) or (None,), sorted(modes)):
                if not any(
                    self.proof.coordinate(record, platform, mode)
                    for record in implementations
                ):
                    self.context.add(
                        "PARITY_VERIFICATION",
                        matrix,
                        pointer,
                        f"Missing target proof: {client}/{platform}/{mode}.",
                    )
        if (
            self.complete
            and obligation.required
            and state not in ("full", "intentionally-changed", "retired")
        ):
            self.context.add(
                "PARITY_INCOMPLETE",
                matrix,
                pointer,
                "Required parity remains unassessed, partial, missing or conflicting.",
            )

    def required_entries(self) -> None:
        """Account for every required feature/client without inferring empty success."""
        # Optional features do not become mandatory through their mere presence.
        for obligation in self.dimensions.obligations:
            if (
                obligation.required
                and obligation.client_id is not None
                and (obligation.feature, obligation.client_id) not in self.seen
            ):
                self.context.add(
                    "PARITY_MISSING",
                    obligation.feature,
                    "",
                    f"Required feature lacks parity for client {obligation.client_id}.",
                )


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

    Discovery and acceptance prerequisites remain separate rule-family results
    for the later mode composer. This operation performs no I/O or source edits.
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
    context = ClaimContext(
        index, evidence, snapshot.profile.limits.parse_limits().findings
    )
    rules = _ParityRules(
        snapshot,
        context,
        TargetProof(snapshot, context, revisions),
        decisions,
        dimensions,
        complete=complete,
    )
    # Every matrix contributes to one deterministic snapshot accounting set.
    for matrix in index.records:
        if matrix.kind == "parity-matrix":
            # Retain original array positions for actionable diagnostics.
            for position, row in object_rows(matrix.document.get("entries")):
                rules.entry(matrix, position, row)
    if complete:
        rules.required_entries()
    return ParityValidation(context.collector.findings)
