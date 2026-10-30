"""Bind ready acceptance to exact criteria without claiming implementation passes."""

from __future__ import annotations

import hashlib
from dataclasses import dataclass
from itertools import product
from typing import TYPE_CHECKING

from drm_copilot_discovery.claim_rules import ClaimContext
from drm_copilot_discovery.coverage_rules import validate_coverage
from drm_copilot_discovery.coverage_scope_rules import (
    object_rows,
    select_coverage_scope,
    strings,
)
from drm_copilot_discovery.decision_rules import validate_decisions
from drm_copilot_discovery.dimension_rules import (
    covering_decisions,
    criterion_applies,
    decision_scope,
    validate_dimensions,
)
from drm_copilot_discovery.evidence_rules import validate_evidence
from drm_copilot_discovery.findings import Finding
from drm_copilot_discovery.models import JsonObject, canonical_json
from drm_copilot_discovery.references import index_references
from drm_copilot_discovery.runtime_claim_rules import has_text

if TYPE_CHECKING:
    from drm_copilot_discovery.decision_rules import DecisionScope, DecisionValidation
    from drm_copilot_discovery.dimension_rules import (
        DimensionValidation,
        FeatureObligation,
    )
    from drm_copilot_discovery.evidence_rules import EvidenceValidation
    from drm_copilot_discovery.references import ArtifactRecord, ReferenceIndex
    from drm_copilot_discovery.snapshot import DiscoverySnapshot


def acceptance_source_digest(
    sources: tuple[ArtifactRecord, ...], decisions: tuple[ArtifactRecord, ...] = ()
) -> str:
    """Hash normalized referenced documents and trusted repository/pin identities.

    Input order and repeated references do not matter. Canonical content changes
    do matter; raw source-reference byte hashes remain a separate revision rule.
    Generation must reuse this helper, independently of stable scenario IDs.
    """
    values = {
        canonical_json(
            JsonObject(
                (
                    ("repository", item.repository),
                    ("revision", item.artifact.repository.revision),
                    ("document", item.document),
                )
            )
        )
        for item in sources + decisions
    }
    return hashlib.sha256(b"[" + b",".join(sorted(values)) + b"]").hexdigest()


@dataclass(frozen=True)
class AcceptanceValidation:
    """Return supported ready records and findings, never execution/coverage claims."""

    ready: tuple[ArtifactRecord, ...]
    findings: tuple[Finding, ...]


class _AcceptanceRules:
    """Check scenario claims and required tuples using retained graph assessments."""

    def __init__(
        self,
        snapshot: DiscoverySnapshot,
        context: ClaimContext,
        decisions: DecisionValidation,
        dimensions: DimensionValidation,
    ) -> None:
        """Retain call-local dependencies without I/O or source mutation."""
        self.snapshot, self.context = snapshot, context
        self.decisions, self.dimensions = decisions, dimensions

    def reject(self, record: ArtifactRecord, pointer: str, message: str) -> bool:
        """Record an unsupported acceptance claim and exclude it from ready results."""
        self.context.add("ACCEPTANCE_CLAIM", record, pointer, message)
        return False

    def proof(
        self, record: ArtifactRecord, pointer: str, source: ArtifactRecord
    ) -> bool:
        """Require all cited observations to belong to the actual source pin."""
        links = self.context.links(record, pointer)
        for link in links:
            assessed = (
                self.context.evidence.for_record(link.target) if link.target else None
            )
            if assessed is None or not assessed.can_prove(
                repository=source.repository,
                revision=source.artifact.repository.revision,
                evidence_types=(
                    "source",
                    "test",
                    "documentation",
                    "inventory",
                    "runtime",
                    "observation",
                ),
            ):
                return False
        return bool(links)

    def criteria(
        self, source: ArtifactRecord, scenario: ArtifactRecord
    ) -> tuple[tuple[ArtifactRecord, int, JsonObject], ...]:
        """Select criteria by explicit expectation basis and exact approval scope."""
        if scenario.document.get("expectation_basis") == "verified-source":
            return tuple(
                (source, position, row)
                for position, row in object_rows(
                    source.document.get("acceptance_criteria")
                )
            )
        if (
            scenario.document.get("expectation_basis") != "approved-decision"
            or scenario.document.get("kind") != "target-acceptance"
        ):
            return ()
        client = scenario.document.get("client_id")
        platform, mode = scenario.document.get("platform_id"), scenario.document.get(
            "mode_id"
        )
        linked = self.context.targets(scenario, "/product_decision_refs")
        found: list[tuple[ArtifactRecord, int, JsonObject]] = []
        for item in self.decisions.approved:
            required = decision_scope(
                source,
                client_id=client if isinstance(client, str) else None,
                platforms=(platform,) if isinstance(platform, str) else (),
                modes=(mode,) if isinstance(mode, str) else (),
                dimensions=tuple(item.scope.selectors[3]),
            )
            if item.record in linked and item.scope.covers(required):
                found.extend(
                    (item.record, position, row)
                    for position, row in object_rows(
                        item.record.document.get("resulting_acceptance_criteria")
                    )
                )
        return tuple(found)

    def identity(self, record: ArtifactRecord, source: ArtifactRecord) -> bool:
        """Keep source and target specification ownership independently pinned."""
        document = record.document
        client_id = document.get("client_id")
        if document.get("kind") == "legacy-characterization":
            return (
                client_id is None
                and record.artifact.repository == source.artifact.repository
            )
        client = next(
            (item for item in self.snapshot.profile.clients if item.id == client_id),
            None,
        )
        if client is None or record.repository != client.target_repository:
            return False
        repositories = (
            self.snapshot.profile.repository,
            *self.snapshot.profile.repositories,
        )
        return any(
            item.id == record.repository
            and item.revision == record.artifact.repository.revision
            for item in repositories
        )

    def record(self, record: ArtifactRecord) -> bool:
        """Accept ready status only for an exact supported criterion expectation."""
        document = record.document
        if document.get("readiness") != "ready":
            return False
        sources = self.context.targets(record, "/source_contract_refs")
        matching = tuple(
            source
            for source in sources
            if source.kind == "feature-contract"
            and source.document.get("feature_id") == document.get("feature_id")
        )
        if len(matching) != 1 or len(sources) != len(
            self.context.links(record, "/source_contract_refs")
        ):
            return self.reject(
                record,
                "/source_contract_refs",
                "Ready acceptance requires one unambiguous linked source feature.",
            )
        source = matching[0]
        candidates = tuple(
            item
            for item in self.criteria(source, record)
            if item[2].get("id") == document.get("criterion_id")
        )
        if len(candidates) != 1:
            return self.reject(
                record,
                "/criterion_id",
                "Ready expectation requires one eligible source or approved criterion.",
            )
        origin, position, criterion = candidates[0]
        if not criterion_applies(
            criterion,
            document.get("client_id"),
            document.get("platform_id"),
            document.get("mode_id"),
        ):
            return self.reject(
                record,
                "/criterion_id",
                "Criterion does not apply to this scenario tuple.",
            )
        if (
            criterion.get("readiness") != "ready"
            or not has_text(expected := criterion.get("expected_result"))
            or document.get("then") != (expected,)
            or not has_text(document.get("when"))
            or document.get("pending_reasons") != ()
        ):
            return self.reject(
                record,
                "/then",
                "Ready Then must exactly retain its known ready criterion expectation.",
            )
        decisions = self.context.targets(record, "/product_decision_refs")
        if document.get("source_content_sha256") != acceptance_source_digest(
            sources, decisions
        ):
            return self.reject(
                record,
                "/source_content_sha256",
                "Content digest differs from the referenced immutable inputs.",
            )
        if not self.identity(record, source):
            return self.reject(
                record,
                "/client_id",
                "Specification ownership must match its source or target client pin.",
            )
        if document.get("expectation_basis") == "verified-source" and (
            not self.proof(
                source, f"/acceptance_criteria/{position}/evidence_refs", source
            )
            or not self.proof(record, "/evidence_refs", source)
        ):
            return self.reject(
                record,
                "/evidence_refs",
                "Known source expectation needs observation proof at the source pin.",
            )
        if origin.kind == "product-decision" and not has_text(
            criterion.get("statement")
        ):
            return self.reject(
                record,
                "/criterion_id",
                "An approved criterion must retain its stated target requirement.",
            )
        return True

    def required(
        self, obligation: FeatureObligation, ready: tuple[ArtifactRecord, ...]
    ) -> None:
        """Require every inherited feature/criterion/client/platform/mode tuple."""
        feature, requirements = obligation.feature, obligation.requirements
        if not obligation.required:
            return
        if feature.document.get("target_relevance") == "retired" and covering_decisions(
            self.context,
            self.decisions,
            feature,
            "/product_decision_refs",
            decision_scope(feature),
        ):
            return
        criteria: list[
            tuple[JsonObject, DecisionScope | None, ArtifactRecord | None]
        ] = [
            (row, None, None)
            for _, row in object_rows(feature.document.get("acceptance_criteria"))
            if row.get("readiness") != "superseded"
        ]
        for decision in self.decisions.approved:
            if (
                feature.repository,
                str(feature.document.get("feature_id")),
            ) in decision.scope.features:
                criteria.extend(
                    (row, decision.scope, decision.record)
                    for _, row in object_rows(
                        decision.record.document.get("resulting_acceptance_criteria")
                    )
                    if row.get("readiness") != "superseded"
                )
        if not criteria:
            self.context.add(
                "ACCEPTANCE_CRITERIA",
                feature,
                "/acceptance_criteria",
                "Required features need explicit supported criteria.",
            )
            return
        ready_tuples = [
            (
                item.document.get("criterion_id"),
                item.document.get("platform_id"),
                item.document.get("mode_id"),
                item,
            )
            for item in ready
            if feature in self.context.targets(item, "/source_contract_refs")
            and item.document.get("client_id") == obligation.client_id
        ]
        platforms = set(requirements.platforms) - obligation.waived
        modes = set(requirements.modes) - obligation.waived
        missing = {
            ("*", platform, mode)
            for platform, mode in product(sorted(platforms) or (None,), sorted(modes))
            if not any(p == platform and m == mode for _, p, m, _ in ready_tuples)
        }
        for criterion, scope, origin in criteria:
            clients = strings(criterion.get("client_ids"))
            if not clients <= {item.id for item in self.snapshot.profile.clients}:
                self.context.add(
                    "ACCEPTANCE_CLIENT",
                    feature,
                    "/acceptance_criteria",
                    "A criterion names an unconfigured target client.",
                )
            selected_platforms = (
                set(requirements.platforms)
                | set(strings(criterion.get("platforms")))
                | (set(scope.selectors[1]) if scope else set[str]())
            ) - obligation.waived
            selected_modes = (
                set(requirements.modes)
                | set(strings(criterion.get("modes")))
                | (set(scope.selectors[2]) if scope else set[str]())
            ) - obligation.waived
            for platform, mode in product(
                sorted(selected_platforms) or (None,), sorted(selected_modes)
            ):
                if not criterion_applies(
                    criterion, obligation.client_id, platform, mode
                ):
                    continue
                required = decision_scope(
                    feature,
                    client_id=obligation.client_id,
                    platforms=(platform,) if platform else (),
                    modes=(mode,),
                    dimensions=tuple(scope.selectors[3]) if scope else (),
                )
                if scope is not None and not scope.covers(required):
                    continue
                identifier = str(criterion.get("id"))
                if not any(
                    (identifier, platform, mode) == (key, p, m)
                    and (
                        origin is None
                        or item.document.get("expectation_basis") == "approved-decision"
                        and origin
                        in self.context.targets(item, "/product_decision_refs")
                    )
                    for key, p, m, item in ready_tuples
                ):
                    missing.add((identifier, platform, mode))
        for identifier, platform, mode in sorted(missing, key=lambda item: str(item)):
            self.context.add(
                "ACCEPTANCE_REQUIRED",
                feature,
                "/acceptance_criteria",
                f"Missing ready criterion/client/platform/mode: "
                f"{identifier}/{obligation.client_id}/{platform}/{mode}.",
            )

    def empty_scope(self) -> None:
        """Require confirmed accounting before accepting zero-feature completion."""
        features = tuple(
            item
            for item in self.context.index.records
            if item.kind == "feature-contract"
        )
        scopes = tuple(
            item for item in self.context.index.records if item.kind == "scope"
        )
        for scope in scopes:
            if scope.document.get("disposition") == "no-scope" and any(
                item.repository == scope.repository
                and item.document.get("target_relevance") == "required"
                for item in features
            ):
                self.context.add(
                    "ACCEPTANCE_SCOPE",
                    scope,
                    "/disposition",
                    "No-scope disposition cannot erase required migration features.",
                )
        if features:
            return
        covered = validate_coverage(
            self.snapshot,
            complete=True,
            index=self.context.index,
            evidence=self.context.evidence,
        )
        justified = any(
            scope.document.get("status") == "confirmed"
            and scope.document.get("disposition") == "no-scope"
            and has_text(scope.document.get("no_scope_rationale"))
            for scope in scopes
        )
        # A nonempty fully accounted supporting-only inventory may contain no features.
        for ledger in self.context.index.records:
            if ledger.kind == "coverage-ledger":
                selection = select_coverage_scope(
                    self.snapshot, ledger, self.context, complete=True
                )
                justified = justified or bool(selection and selection.selected)
        if covered.findings or not justified:
            self.context.collector.add(
                Finding(
                    code="ACCEPTANCE_SCOPE",
                    message="Zero features require justified scope and full inventory.",
                    next_action="Confirm scope and account for inventory inputs.",
                )
            )


def validate_acceptance(
    snapshot: DiscoverySnapshot,
    *,
    complete: bool = False,
    index: ReferenceIndex | None = None,
    evidence: EvidenceValidation | None = None,
    decisions: DecisionValidation | None = None,
    dimensions: DimensionValidation | None = None,
) -> AcceptanceValidation:
    """Validate present readiness claims and optionally required scenario coverage.

    Pending records remain valid incomplete specifications. Approved target
    policy can supply Then while separate open legacy questions remain unchanged.
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
    dimensions = (
        dimensions
        if dimensions is not None
        else validate_dimensions(
            snapshot,
            complete=complete,
            index=index,
            evidence=evidence,
            decisions=decisions,
        )
    )
    context = ClaimContext(
        index, evidence, snapshot.profile.limits.parse_limits().findings
    )
    rules = _AcceptanceRules(snapshot, context, decisions, dimensions)
    ready = tuple(
        item
        for item in index.records
        if item.kind == "acceptance-specification" and rules.record(item)
    )
    if complete:
        rules.empty_scope()
        if snapshot.profile.completion_gates.required("require_acceptance_scenarios"):
            for obligation in dimensions.obligations:
                rules.required(obligation, ready)
    return AcceptanceValidation(ready, context.collector.findings)
