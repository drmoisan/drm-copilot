"""Validate scoped target approvals without changing historical observations."""

from __future__ import annotations

from dataclasses import dataclass
from itertools import combinations
from typing import TYPE_CHECKING

from drm_copilot_discovery.claim_rules import ClaimContext
from drm_copilot_discovery.evidence_rules import validate_evidence
from drm_copilot_discovery.models import JsonObject, JsonValue
from drm_copilot_discovery.references import index_references
from drm_copilot_discovery.runtime_claim_rules import has_text
from drm_copilot_discovery.schema_validation import is_rfc3339_timestamp

if TYPE_CHECKING:
    from drm_copilot_discovery.evidence_rules import EvidenceValidation
    from drm_copilot_discovery.findings import Finding
    from drm_copilot_discovery.references import ArtifactRecord, ReferenceIndex
    from drm_copilot_discovery.snapshot import DiscoverySnapshot

RecordKey = tuple[str, str]
FeatureKey = tuple[str, str]


def _key(record: ArtifactRecord) -> RecordKey:
    """Identify a physical record without conflating collection or repository IDs."""
    return record.artifact.path, record.pointer


def _strings(value: JsonValue) -> frozenset[str]:
    """Project immutable selectors without coercing malformed upstream values."""
    # Structural errors remain upstream blockers, never invented selector values.
    return (
        frozenset(v for v in value if isinstance(v, str))
        if isinstance(value, tuple)
        else frozenset()
    )


def _feature(record: ArtifactRecord) -> FeatureKey:
    """Preserve the repository namespace of a resolved feature contract."""
    return record.repository, str(record.document.get("feature_id"))


@dataclass(frozen=True)
class DecisionScope:
    """Carry resolved feature identity and four explicit selector sets.

    Empty non-feature selectors are unrestricted. Pure overlap/coverage checks
    do not consult clients, files or prose; callers construct validated scopes.
    """

    features: frozenset[FeatureKey]
    selectors: tuple[frozenset[str], ...]

    def overlaps(self, other: DecisionScope) -> bool:
        """Return whether both scopes can govern the same structured requirement."""
        # Every axis must intersect; an empty selector denotes a wildcard.
        return bool(self.features & other.features) and all(
            not left or not right or bool(left & right)
            for left, right in zip(self.selectors, other.selectors, strict=True)
        )

    def covers(self, other: DecisionScope) -> bool:
        """Require complete coverage; finite selectors cannot replace a wildcard."""
        # Supersession cannot discard predecessor requirements outside an overlap.
        return other.features <= self.features and all(
            not left or bool(right) and right <= left
            for left, right in zip(self.selectors, other.selectors, strict=True)
        )


@dataclass(frozen=True)
class ApprovedDecision:
    """Expose a current evidenced approval and its exact validated target scope."""

    record: ArtifactRecord
    scope: DecisionScope


@dataclass(frozen=True)
class DecisionValidation:
    """Return pure decision findings and eligible approvals for later composition.

    Eligibility never grants host mutation authority or proves implementation.
    Structural, reference, claim and revision findings remain separate inputs.
    """

    approved: tuple[ApprovedDecision, ...]
    findings: tuple[Finding, ...]


def _reachable(
    start: RecordKey, edges: dict[RecordKey, set[RecordKey]]
) -> set[RecordKey]:
    """Follow finite captured links iteratively, retaining cycles without recursion."""
    seen: set[RecordKey] = set()
    pending = list(edges.get(start, ()))
    # A visited set bounds both repeated paths and cyclic authored histories.
    while pending:
        node = pending.pop()
        if node not in seen:
            seen.add(node)
            pending.extend(edges.get(node, ()))
    return seen


class _DecisionRules:
    """Check one immutable graph through existing link and evidence boundaries.

    The call-local collector records blockers while eligible approvals are
    reduced by invalid scopes, supersession and conflicts. No inputs are edited.
    """

    def __init__(self, snapshot: DiscoverySnapshot, claims: ClaimContext) -> None:
        """Retain approved configuration and precomputed graph/evidence inputs."""
        self.snapshot, self.claims = snapshot, claims
        # Owner IDs and physical decisions are separate immutable lookup namespaces.
        self.owners = {
            str(owner["id"]): owner for owner in snapshot.profile.decision_owners
        }
        self.records = {
            _key(r): r for r in claims.index.records if r.kind == "product-decision"
        }
        self.scopes: dict[RecordKey, DecisionScope] = {}
        self.valid: set[RecordKey] = set()

    def features(self, record: ArtifactRecord) -> tuple[ArtifactRecord, ...]:
        """Resolve directly linked features and features reached through questions."""
        values = list(self.claims.targets(record, "/feature_refs"))
        # Decisions may link questions instead of duplicating their feature links.
        for question in self.claims.targets(record, "/unspecified_behavior_refs"):
            values.extend(self.claims.targets(question, "/feature_refs"))
        return tuple(value for value in values if value.kind == "feature-contract")

    def scope(self, record: ArtifactRecord) -> DecisionScope | None:
        """Require unique resolved feature identities and configured clients."""
        value = record.document.get("scope")
        names = ("feature_ids", "client_ids", "platforms", "modes", "dimensions")
        if not isinstance(value, JsonObject) or any(
            not isinstance(rows := value.get(name), tuple)
            or any(not isinstance(item, str) for item in rows)
            for name in names
        ):
            self.claims.add(
                "DECISION_SCOPE",
                record,
                "/scope",
                "Decision selectors require explicit string arrays.",
            )
            return None
        selected = _strings(value["feature_ids"])
        features = {_feature(feature) for feature in self.features(record)}
        resolved = frozenset(pair for pair in features if pair[1] in selected)
        clients = _strings(value["client_ids"])
        if (
            not selected
            or any(sum(pair[1] == name for pair in resolved) != 1 for name in selected)
            or not clients <= {client.id for client in self.snapshot.profile.clients}
        ):
            self.claims.add(
                "DECISION_SCOPE",
                record,
                "/scope",
                "Scope must resolve each feature and configured client unambiguously.",
            )
            return None
        return DecisionScope(
            resolved, tuple(_strings(value[name]) for name in names[1:])
        )

    def approval(self, record: ArtifactRecord) -> bool:
        """Require a configured owner, timestamp and intact local approval proof."""
        approval = record.document.get("approval")
        owner = (
            self.owners.get(str(approval.get("owner")))
            if isinstance(approval, JsonObject)
            else None
        )
        timestamp = (
            approval.get("timestamp") if isinstance(approval, JsonObject) else None
        )
        if (
            owner is None
            or not isinstance(timestamp, str)
            or not is_rfc3339_timestamp(timestamp)
        ):
            self.claims.add(
                "DECISION_APPROVAL",
                record,
                "/approval",
                "Approval requires a configured owner and valid timestamp.",
            )
            return False
        seen: set[str] = set()
        links = self.claims.links(record, "/approval/evidence_refs")
        usable = bool(links)
        # Every cited payload must verify; all owner-required types must be present.
        for link in links:
            proof = (
                self.claims.evidence.for_record(link.target) if link.target else None
            )
            if proof is None or not proof.can_prove(repository=record.repository):
                usable = False
            else:
                seen.add(str(proof.record.document.get("evidence_type")))
        if not usable or not _strings(owner.get("required_evidence_types")) <= seen:
            self.claims.add(
                "DECISION_APPROVAL_EVIDENCE",
                record,
                "/approval/evidence_refs",
                "Approval lacks local proof for every required evidence type.",
            )
            return False
        return True

    def declarations(self) -> None:
        """Separate pending proposals from scoped and evidenced target policy."""
        # Historical superseded records retain their original approval provenance.
        for key, record in self.records.items():
            scope = self.scope(record)
            if scope is not None:
                self.scopes[key] = scope
            status = record.document.get("status")
            criteria = record.document.get("resulting_acceptance_criteria")
            if status in ("proposed", "rejected"):
                if isinstance(criteria, tuple) and any(
                    isinstance(row, JsonObject) and row.get("readiness") == "ready"
                    for row in criteria
                ):
                    self.claims.add(
                        "DECISION_TARGET",
                        record,
                        "/resulting_acceptance_criteria",
                        "Unapproved policy cannot establish ready target criteria.",
                    )
                continue
            if status in ("approved", "superseded"):
                approved = self.approval(record)
                complete = all(
                    has_text(record.document.get(name))
                    for name in ("decision", "rationale", "required_migration_behavior")
                )
                if not complete:
                    self.claims.add(
                        "DECISION_TARGET",
                        record,
                        "",
                        "Approval requires decision, rationale and target behavior.",
                    )
                if approved and complete and scope is not None:
                    self.valid.add(key)

    def reconcile(self) -> tuple[ApprovedDecision, ...]:
        """Reject cycles/conflicts and retain only approvals not fully superseded.

        A valid replacement covers the predecessor's complete scope and key.
        Partial overlaps are invalid edges; they cannot suppress conflicts.
        """
        declared: dict[RecordKey, set[RecordKey]] = {}
        eligible: dict[RecordKey, set[RecordKey]] = {}
        invalid: set[RecordKey] = set()
        # Keep declared links for cycle checks even when their authority is invalid.
        for key, record in self.records.items():
            for link in self.claims.links(record, "/supersedes"):
                target = link.target
                destination = _key(target) if target is not None else None
                if target is not None and target.kind == "product-decision":
                    declared.setdefault(key, set()).add(_key(target))
                if (
                    destination not in self.scopes
                    or key not in self.scopes
                    or target is None
                    or target.kind != "product-decision"
                    or record.document.get("decision_key")
                    != target.document.get("decision_key")
                    or not self.scopes[key].covers(self.scopes[destination])
                    or target.document.get("status") not in ("approved", "superseded")
                ):
                    invalid.add(key)
                    self.claims.add(
                        "DECISION_SUPERSESSION",
                        record,
                        "/supersedes",
                        "Supersession must cover the predecessor's key and scope.",
                    )
                elif key in self.valid and destination in self.valid:
                    eligible.setdefault(key, set()).add(destination)
        # Cycle membership is independent of authored status and array order.
        for key, record in self.records.items():
            if key in _reachable(key, declared):
                invalid.add(key)
                self.claims.add(
                    "DECISION_CYCLE",
                    record,
                    "/supersedes",
                    "Decision supersession contains a directed cycle.",
                )
        self.valid -= invalid
        edges = {
            key: targets & self.valid
            for key, targets in eligible.items()
            if key in self.valid
        }
        reaches = {key: _reachable(key, edges) for key in self.records}
        approved = {
            key
            for key, record in self.records.items()
            if record.document.get("status") == "approved"
        }
        superseded = set[RecordKey]().union(
            *(reaches[key] for key in approved & self.valid)
        )
        conflicts: set[RecordKey] = set()
        # Structured overlap is decidable; arbitrary policy prose is not compared.
        for left, right in combinations(
            sorted(approved & self.scopes.keys() - superseded), 2
        ):
            if (
                self.records[left].document.get("decision_key")
                == self.records[right].document.get("decision_key")
                and self.scopes[left].overlaps(self.scopes[right])
                and right not in reaches[left]
                and left not in reaches[right]
            ):
                conflicts.update((left, right))
                self.claims.add(
                    "DECISION_CONFLICT",
                    self.records[left],
                    "/scope",
                    "Overlapping approvals lack valid same-key supersession.",
                )
                self.claims.add(
                    "DECISION_CONFLICT",
                    self.records[right],
                    "/scope",
                    "Overlapping approvals lack valid same-key supersession.",
                )
        # A superseded label cannot retire policy without a valid approved successor.
        for key, record in self.records.items():
            if record.document.get("status") == "superseded" and key not in superseded:
                self.claims.add(
                    "DECISION_SUPERSESSION",
                    record,
                    "/status",
                    "Superseded policy requires an approved covering successor.",
                )
        return tuple(
            ApprovedDecision(self.records[key], self.scopes[key])
            for key in sorted(approved & self.valid - superseded - conflicts)
        )

    def consumers(self, approved: tuple[ApprovedDecision, ...]) -> None:
        """Check retirement and resolution links without rewriting observed facts."""
        active = {_key(item.record): item for item in approved}
        # Only explicit target-policy claims require current scoped approval.
        for record in self.claims.index.records:
            if record.kind == "feature-contract":
                links = self.claims.targets(record, "/product_decision_refs")
                selected = [
                    active[_key(link)] for link in links if _key(link) in active
                ]
                required = DecisionScope(
                    frozenset((_feature(record),)), (frozenset[str](),) * 4
                )
                if record.document.get("target_relevance") == "retired" and not any(
                    item.scope.covers(required) for item in selected
                ):
                    self.claims.add(
                        "DECISION_RETIREMENT",
                        record,
                        "/target_relevance",
                        "Retirement requires approval covering the whole feature.",
                    )
                if record.document.get(
                    "product_decision_status"
                ) == "approved" and not any(
                    _feature(record) in item.scope.features for item in selected
                ):
                    self.claims.add(
                        "DECISION_TARGET",
                        record,
                        "/product_decision_refs",
                        "Approved target status requires a current scoped approval.",
                    )
            elif record.kind == "unspecified-behavior":
                self.resolution(record, active)

    def resolution(
        self, record: ArtifactRecord, active: dict[RecordKey, ApprovedDecision]
    ) -> None:
        """Keep approved target resolution separate from verified legacy evidence."""
        document = record.document
        owner, basis = document.get("decision_owner"), document.get("resolution_basis")
        if owner is not None and str(owner) not in self.owners:
            self.claims.add(
                "DECISION_OWNER",
                record,
                "/decision_owner",
                "The question names an unconfigured decision owner.",
            )
        if document.get("status") not in ("resolved", "intentionally-unspecified"):
            if (
                basis is not None
                or document.get("approved_target_behavior") is not None
            ):
                self.claims.add(
                    "DECISION_RESOLUTION",
                    record,
                    "/resolution_basis",
                    "An open question cannot declare an approved resolution.",
                )
            return
        if basis == "verified-observation":
            if not self.claims.proof(record, "/resolution_evidence_refs") or any(
                document.get(name) is not None
                for name in ("decision_ref", "decision", "approved_target_behavior")
            ):
                self.claims.add(
                    "DECISION_RESOLUTION",
                    record,
                    "/resolution_evidence_refs",
                    "Observed resolution requires separate observation proof.",
                )
            return
        links = self.claims.targets(record, "/decision_ref")
        selected = active.get(_key(links[0])) if len(links) == 1 else None
        features = frozenset(_feature(feature) for feature in self.features(record))
        required = DecisionScope(
            features, (frozenset[str](),) * 3 + (_strings(document.get("dimensions")),)
        )
        target = selected.record.document if selected is not None else JsonObject(())
        approval = target.get("approval")
        if (
            basis != "approved-decision"
            or selected is None
            or not features
            or not selected.scope.covers(required)
            or not isinstance(approval, JsonObject)
            or owner != approval.get("owner")
            or not has_text(document.get("rationale"))
            or document.get("decision") != target.get("decision")
            or document.get("approved_target_behavior")
            != target.get("required_migration_behavior")
        ):
            self.claims.add(
                "DECISION_RESOLUTION",
                record,
                "/decision_ref",
                "Resolution requires matching owner, target text and approval scope.",
            )


def validate_decisions(
    snapshot: DiscoverySnapshot,
    *,
    index: ReferenceIndex | None = None,
    evidence: EvidenceValidation | None = None,
) -> DecisionValidation:
    """Return scoped approval eligibility and blockers using only captured inputs.

    Reuse a trusted index/evidence result when supplied. The caller composes
    upstream structural/reference/revision findings; this call changes no facts.
    """
    index = index if index is not None else index_references(snapshot)
    evidence = (
        evidence if evidence is not None else validate_evidence(snapshot, index=index)
    )
    claims = ClaimContext(
        index, evidence, snapshot.profile.limits.parse_limits().findings
    )
    rules = _DecisionRules(snapshot, claims)
    rules.declarations()
    approved = rules.reconcile()
    rules.consumers(approved)
    return DecisionValidation(approved, claims.collector.findings)
