"""Check observed claims against captured proof without deciding target policy."""

from __future__ import annotations

from dataclasses import dataclass
from typing import TYPE_CHECKING

from drm_copilot_discovery.evidence_rules import validate_evidence
from drm_copilot_discovery.findings import Finding, FindingCollector
from drm_copilot_discovery.models import JsonObject, JsonValue
from drm_copilot_discovery.profile_models import FEATURE_DIMENSIONS
from drm_copilot_discovery.reference_links import reference_finding
from drm_copilot_discovery.references import index_references
from drm_copilot_discovery.runtime_claim_rules import (
    environment_identity,
    has_text,
    validate_runtime_claim,
)

if TYPE_CHECKING:
    from drm_copilot_discovery.evidence_rules import EvidenceValidation
    from drm_copilot_discovery.references import (
        ArtifactRecord,
        ReferenceIndex,
        ReferenceResolution,
    )
    from drm_copilot_discovery.snapshot import DiscoverySnapshot

_RUNTIME = ("runtime", "observation")
_OBSERVATIONS = ("source", "test", "documentation", "inventory", *_RUNTIME)


def _objects(value: JsonValue) -> tuple[JsonObject, ...]:
    """Retain object rows while leaving malformed rows to structural validation."""
    # Typed consumers must not crash when an upstream document is already invalid.
    return (
        tuple(item for item in value if isinstance(item, JsonObject))
        if isinstance(value, tuple)
        else ()
    )


@dataclass(frozen=True)
class ClaimValidation:
    """Return bounded immutable findings for composition with schema/evidence rules.

    Constructed by validate_claims after pure graph checks. It carries no approval,
    confidence promotion, completion decision or I/O authority.
    """

    findings: tuple[Finding, ...]


class ClaimContext:
    """Evaluate one snapshot using retained links and evidence assessments.

    The context groups existing links once, emits only claim findings, and never
    reads files or mutates input artifacts. The public result remains immutable.
    """

    def __init__(
        self, index: ReferenceIndex, evidence: EvidenceValidation, limit: int
    ) -> None:
        """Retain trusted inputs and a bounded collector for this validation call."""
        self.index = index
        self.evidence = evidence
        self.collector = FindingCollector(limit=limit)
        self.by_source: dict[tuple[str, str], list[ReferenceResolution]] = {}
        # Group links by physical record so repeated dimension checks stay local.
        for link in index.links:
            key = (link.source.artifact.path, link.source.pointer)
            self.by_source.setdefault(key, []).append(link)

    def add(
        self, code: str, record: ArtifactRecord, pointer: str, message: str
    ) -> None:
        """Emit one record-relative diagnostic without changing the source document."""
        self.collector.add(
            reference_finding(code, record, record.pointer + pointer, message)
        )

    def links(
        self, record: ArtifactRecord, pointer: str
    ) -> tuple[ReferenceResolution, ...]:
        """Select a field's existing typed links, including failed resolutions."""
        prefix = record.pointer + pointer
        # A trailing slash boundary keeps sibling fields and array indices distinct.
        return tuple(
            link
            for link in self.by_source.get((record.artifact.path, record.pointer), ())
            if link.pointer == prefix or link.pointer.startswith(prefix + "/")
        )

    def targets(
        self, record: ArtifactRecord, pointer: str
    ) -> tuple[ArtifactRecord, ...]:
        """Expose resolved records only; failed links remain graph diagnostics."""
        # Only resolved targets can participate in claim support.
        return tuple(
            link.target
            for link in self.links(record, pointer)
            if link.target is not None
        )

    def proof(
        self,
        record: ArtifactRecord,
        pointer: str,
        *,
        runtime: bool = False,
        environment: JsonValue = None,
    ) -> bool:
        """Require exact repository/pin proof and, for runtime, matching environment."""
        links = self.links(record, pointer)
        if not links:
            return False
        # Every cited proof must be usable; one valid link cannot hide a bad capture.
        for link in links:
            assessment = self.evidence.for_record(link.target) if link.target else None
            if assessment is None or not assessment.can_prove(
                repository=record.repository,
                revision=record.artifact.repository.revision,
                evidence_types=_RUNTIME if runtime else _OBSERVATIONS,
            ):
                return False
            if environment is not None and environment_identity(
                assessment.record.document.get("environment")
            ) != environment_identity(environment):
                return False
        return True

    def questions(
        self, feature: ArtifactRecord, dimension: str | None
    ) -> tuple[ArtifactRecord, ...]:
        """Find open records that actually cover this feature and optional dimension."""
        found: list[ArtifactRecord] = []
        # Backlinks expose omitted unresolved questions as well as explicit links.
        for record in self.index.records:
            if record.kind != "unspecified-behavior" or record.document.get(
                "status"
            ) not in ("open", "under-review"):
                continue
            dimensions = record.document.get("dimensions")
            if feature not in self.targets(record, "/feature_refs"):
                continue
            if dimension is None or (
                isinstance(dimensions, tuple) and dimension in dimensions
            ):
                found.append(record)
        return tuple(found)

    def decision(
        self, feature: ArtifactRecord, pointer: str, dimension: str | None
    ) -> bool:
        """Require a linked declared approval/rationale; authority is checked later."""
        # Intentional uncertainty requires a linked, feature-scoped approval.
        for record in self.targets(feature, pointer + "/product_decision_refs"):
            document = record.document
            scope = document.get("scope")
            if (
                record.kind != "product-decision"
                or document.get("status") != "approved"
                or not isinstance(scope, JsonObject)
            ):
                continue
            feature_ids, dimensions = scope.get("feature_ids"), scope.get("dimensions")
            if (
                not isinstance(feature_ids, tuple)
                or feature.document.get("feature_id") not in feature_ids
            ):
                continue
            if (
                dimension is not None
                and isinstance(dimensions, tuple)
                and dimensions
                and dimension not in dimensions
            ):
                continue
            if has_text(document.get("rationale")) and isinstance(
                document.get("approval"), JsonObject
            ):
                return True
        return False

    def observation(
        self,
        feature: ArtifactRecord,
        value: JsonObject,
        pointer: str,
        dimension: str | None,
    ) -> None:
        """Check an observation state independently of its authored confidence label."""
        state = value.get("observation_state")
        questions = self.questions(feature, dimension)
        linked = self.targets(feature, pointer + "/unresolved_behavior_refs")
        # Confidence never changes the selected state or supplies missing evidence.
        if state == "verified":
            fields = (
                ("/source_evidence_refs", "/runtime_evidence_refs")
                if dimension is None
                else (pointer + "/evidence_refs",)
            )
            # Runtime-typed fields cannot be satisfied by a source-only capture.
            if not any(
                self.proof(feature, name, runtime=name == "/runtime_evidence_refs")
                for name in fields
            ):
                self.add(
                    "CLAIM_EVIDENCE",
                    feature,
                    pointer,
                    "Verified observation requires usable local evidence at its pin.",
                )
            # A dimensionless open question applies to the whole feature.
            global_question = any(
                not item.document.get("dimensions") for item in questions
            )
            if linked or (dimension is not None and questions) or global_question:
                self.add(
                    "CLAIM_UNRESOLVED",
                    feature,
                    pointer,
                    "Verified observation conflicts with unresolved behavior.",
                )
            if dimension is not None and not has_text(value.get("statement")):
                self.add(
                    "CLAIM_STATEMENT",
                    feature,
                    pointer,
                    "Verified dimensions require an observed statement.",
                )
        elif state in ("unknown", "contradictory"):
            if not any(record in questions for record in linked):
                self.add(
                    "CLAIM_UNRESOLVED",
                    feature,
                    pointer,
                    "Uncertainty requires an open record for this feature/dimension.",
                )
            if dimension is not None and value.get("statement") is not None:
                self.add(
                    "CLAIM_STATEMENT",
                    feature,
                    pointer,
                    "Unknown or contradictory behavior cannot invent a statement.",
                )
        elif state == "intentionally-unspecified":
            if not self.decision(feature, pointer, dimension) or (
                dimension is not None and not has_text(value.get("rationale"))
            ):
                self.add(
                    "CLAIM_DECISION",
                    feature,
                    pointer,
                    "Intentional uncertainty requires a scoped approval and rationale.",
                )

    def feature(self, record: ArtifactRecord, required: tuple[str, ...]) -> None:
        """Validate present core dimensions and transition observations only."""
        document = record.document
        self.observation(record, document, "", None)
        if self.links(record, "/runtime_evidence_refs") and not self.proof(
            record, "/runtime_evidence_refs", runtime=True
        ):
            self.add(
                "CLAIM_RUNTIME_EVIDENCE",
                record,
                "/runtime_evidence_refs",
                "Runtime references require usable runtime capture evidence.",
            )
        local_required = document.get("required_dimensions")
        # Existing requirements control summaries without adding optional modes.
        required_set = set(required)
        if isinstance(local_required, tuple):
            required_set.update(
                item for item in local_required if isinstance(item, str)
            )
        # Walk core dimensions only; extension payloads cannot supply observations.
        for dimension in FEATURE_DIMENSIONS:
            value = document.get(dimension)
            pointer = "/" + dimension
            if not isinstance(value, JsonObject):
                continue
            if dimension == "state_transitions":
                transitions = value
                value = transitions.get("behavior")
                pointer += "/behavior"
                # Each transition phase retains its own observation/evidence state.
                for position, row in enumerate(_objects(transitions.get("entries"))):
                    # Before/action/after are independent observation claims.
                    for phase in ("before", "action", "after"):
                        phase_value = row.get(phase)
                        if isinstance(phase_value, JsonObject):
                            self.observation(
                                record,
                                phase_value,
                                f"/state_transitions/entries/{position}/{phase}",
                                dimension,
                            )
                if not isinstance(value, JsonObject):
                    continue
            self.observation(record, value, pointer, dimension)
            if (
                document.get("observation_state") == "verified"
                and dimension in required_set
                and value.get("observation_state")
                in ("unknown", "contradictory", "inferred")
            ):
                self.add(
                    "CLAIM_SUMMARY",
                    record,
                    pointer,
                    "Verified summaries cannot hide unresolved required dimensions.",
                )


def validate_claims(
    snapshot: DiscoverySnapshot,
    *,
    index: ReferenceIndex | None = None,
    evidence: EvidenceValidation | None = None,
) -> ClaimValidation:
    """Validate prospective or stored immutable claims without I/O or promotion.

    Reuse caller-provided graph/evidence results when available. The later combined
    validator must also include structural, reference, evidence and revision findings.
    """
    index = index if index is not None else index_references(snapshot)
    evidence = (
        evidence if evidence is not None else validate_evidence(snapshot, index=index)
    )
    rules = ClaimContext(
        index, evidence, snapshot.profile.limits.parse_limits().findings
    )
    # Only observed feature/runtime claims belong to this task's semantic rules.
    for record in index.records:
        if record.kind == "feature-contract":
            rules.feature(record, snapshot.profile.required_feature_dimensions)
        elif record.kind == "runtime-characterization-scenario":
            validate_runtime_claim(record, rules)
    return ClaimValidation(rules.collector.findings)
