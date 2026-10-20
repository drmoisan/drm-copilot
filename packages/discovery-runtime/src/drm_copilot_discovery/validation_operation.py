"""Reuse bounded rule assessments within one immutable validation operation."""

from __future__ import annotations

from collections import Counter
from dataclasses import replace
from typing import TYPE_CHECKING

from drm_copilot_discovery.acceptance_rules import validate_acceptance
from drm_copilot_discovery.agent_output import REPORT_KINDS
from drm_copilot_discovery.claim_rules import validate_claims
from drm_copilot_discovery.completion_rules import validate_completion
from drm_copilot_discovery.coverage_report import coverage_summary
from drm_copilot_discovery.coverage_rules import validate_coverage
from drm_copilot_discovery.decision_rules import validate_decisions
from drm_copilot_discovery.dimension_rules import validate_dimensions
from drm_copilot_discovery.evidence_rules import validate_evidence
from drm_copilot_discovery.findings import Finding, FindingCollector
from drm_copilot_discovery.models import to_plain_value
from drm_copilot_discovery.parity_report import parity_summary
from drm_copilot_discovery.parity_rules import validate_parity
from drm_copilot_discovery.references import index_references
from drm_copilot_discovery.revision_rules import validate_revisions
from drm_copilot_discovery.snapshot import repository_pins
from drm_copilot_discovery.validation_inputs import CONTROL_KINDS as _CONTROL
from drm_copilot_discovery.validation_inputs import report_input_digest

if TYPE_CHECKING:
    from collections.abc import Iterable

    from drm_copilot_discovery.dimension_rules import DimensionValidation
    from drm_copilot_discovery.parity_rules import ParityValidation
    from drm_copilot_discovery.snapshot import DiscoverySnapshot


def _findings(values: Iterable[Finding], limit: int) -> tuple[Finding, ...]:
    """Bound, deduplicate and sort every aggregate without losing truncation failure."""
    collector = FindingCollector(limit=limit)
    # All families share the same finite result budget and deterministic ordering.
    for finding in values:
        collector.add(finding)
    return collector.findings


class _Validation:
    """Compose each accepted rule family using one catalog and resolved graph.

    Memoized mode results are local to one immutable snapshot. Reports compare
    against these results rather than re-entering validation or trusting status.
    """

    def __init__(self, snapshot: DiscoverySnapshot) -> None:
        """Build shared semantic assessments after all structural bytes pass."""
        self.snapshot = snapshot
        self.limit = snapshot.profile.limits.parse_limits().findings
        # Derived report envelopes have no authored graph identity or schema resource.
        core = replace(
            snapshot,
            artifacts=tuple(
                item
                for item in snapshot.artifacts
                if item.expected_kind not in REPORT_KINDS
            ),
        )
        self.index = index_references(core)
        self.evidence = validate_evidence(snapshot, index=self.index)
        self.revisions = validate_revisions(snapshot, index=self.index)
        self.claims = validate_claims(
            snapshot, index=self.index, evidence=self.evidence
        )
        self.decisions = validate_decisions(
            snapshot, index=self.index, evidence=self.evidence
        )
        self.dimensions = validate_dimensions(
            snapshot, index=self.index, evidence=self.evidence, decisions=self.decisions
        )
        coverage = validate_coverage(
            snapshot, index=self.index, evidence=self.evidence, claims=self.claims
        )
        acceptance = validate_acceptance(
            snapshot,
            index=self.index,
            evidence=self.evidence,
            decisions=self.decisions,
            dimensions=self.dimensions,
        )
        self.parity = validate_parity(
            snapshot,
            index=self.index,
            evidence=self.evidence,
            revisions=self.revisions,
            decisions=self.decisions,
            dimensions=self.dimensions,
        )
        # Preserve mandatory findings from every accepted family before policy gates.
        self.base = _findings(
            (
                finding
                for result in (
                    self.index,
                    self.evidence,
                    self.revisions,
                    self.claims,
                    self.decisions,
                    self.dimensions,
                    coverage,
                    acceptance,
                    self.parity,
                )
                for finding in result.findings
            ),
            self.limit,
        )
        self.modes: dict[str, tuple[Finding, ...]] = {
            "structural": self.base,
            "agent-output": self.base,
        }
        self._complete_source: (
            tuple[tuple[Finding, ...], DimensionValidation] | None
        ) = None
        self.complete_parity: ParityValidation = self.parity
        self.complete_dimensions = self.dimensions

    def evaluate(self, mode: str) -> tuple[Finding, ...]:
        """Return exact policy-mode findings while reusing lower-level assessments."""
        if mode in self.modes:
            return self.modes[mode]
        requested = (
            self.snapshot.profile.completion_gates.planning_prerequisite
            if mode == "planning"
            else mode
        )
        # Planning can reuse a prerequisite already evaluated for another report.
        if requested in self.modes:
            findings = self.modes[requested]
        elif requested == "none":
            findings = self.base
        elif requested in {"discovery-complete", "parity-complete"}:
            findings = self.complete(parity=requested == "parity-complete")
        else:
            raise ValueError("Unsupported report or validation mode")
        self.modes[requested] = self.modes[mode] = findings
        return findings

    def complete(self, *, parity: bool) -> tuple[Finding, ...]:
        """Return tuple[Finding, ...] after source and optional target completeness.

        parity (bool) enables target checks. Retain complete_dimensions and
        complete_parity for this operation's reports; perform no external effects.
        """
        snapshot = self.snapshot
        # Both completion modes share source proof within this immutable operation.
        if self._complete_source is None:
            sources = repository_pins(snapshot.profile)[0]
            # Target-local draft ledgers cannot replace required source discovery.
            source_index = replace(
                self.index,
                records=tuple(
                    record
                    for record in self.index.records
                    if record.kind
                    not in {"scope", "coverage-ledger", "inventory-snapshot"}
                    or record.artifact.repository in sources
                ),
            )
            coverage = validate_coverage(
                snapshot,
                complete=True,
                index=source_index,
                evidence=self.evidence,
                claims=self.claims,
            )
            dimensions = validate_dimensions(
                snapshot,
                complete=True,
                index=self.index,
                evidence=self.evidence,
                decisions=self.decisions,
            )
            acceptance = validate_acceptance(
                snapshot,
                complete=True,
                index=source_index,
                evidence=self.evidence,
                decisions=self.decisions,
                dimensions=dimensions,
            )
            # Retain family order and defer aggregate truncation to the final result.
            self._complete_source = (
                (
                    *self.base,
                    *coverage.findings,
                    *dimensions.findings,
                    *acceptance.findings,
                ),
                dimensions,
            )
        common, dimensions = self._complete_source
        self.complete_dimensions = dimensions
        completion = validate_completion(
            snapshot,
            index=self.index,
            evidence=self.evidence,
            claims=self.claims,
            decisions=self.decisions,
            dimensions=dimensions,
            parity=parity,
        )
        values = [*common, *completion.findings]
        if parity:
            self.complete_parity = validate_parity(
                snapshot,
                complete=True,
                index=self.index,
                evidence=self.evidence,
                revisions=self.revisions,
                decisions=self.decisions,
                dimensions=dimensions,
            )
            values.extend(self.complete_parity.findings)
        return _findings(values, self.limit)

    def report(self, *, kind: str, identifier: str, mode: str) -> dict[str, object]:
        """Return fields for kind, identifier and mode (str) from shared assessments.

        Coverage/parity add independently evaluated complete results and populations;
        requested-mode findings remain unchanged. Raises ValueError on invalid
        modes or resource limits. No I/O, publication or caller mutation occurs.
        """
        findings = self.evaluate(mode)
        # Control mirrors do not add discovery facts or inflate report counts.
        counts = Counter(
            record.kind for record in self.index.records if record.kind not in _CONTROL
        )
        result: dict[str, object] = {
            "schema_version": "2.0.0",
            "artifact_kind": kind,
            "id": identifier,
            "mode": mode,
            "input_sha256": report_input_digest(self.snapshot),
            "validation_result": (
                "fail" if any(item.severity == "error" for item in findings) else "pass"
            ),
            "counts": dict(sorted(counts.items())),
            "findings": [item.to_dict() for item in findings],
        }
        # Preserve requested-mode semantics alongside the selected report's full proof.
        if kind in {"coverage-report", "parity-report"}:
            coverage = kind == "coverage-report"
            complete = self.evaluate(
                "discovery-complete" if coverage else "parity-complete"
            )
            if coverage:
                summary = coverage_summary(
                    self.snapshot,
                    index=self.index,
                    evidence=self.evidence,
                    claims=self.claims,
                    dimensions=self.dimensions,
                    findings=complete,
                )
            else:
                # evaluate(parity-complete) populated both complete carriers above.
                summary = parity_summary(
                    self.snapshot,
                    index=self.index,
                    evidence=self.evidence,
                    claims=self.claims,
                    decisions=self.decisions,
                    dimensions=self.complete_dimensions,
                    parity=self.complete_parity,
                    findings=complete,
                )
            result["coverage" if coverage else "parity"] = to_plain_value(summary)
            result["discovery_result" if coverage else "parity_result"] = (
                "fail" if any(item.severity == "error" for item in complete) else "pass"
            )
            # Preserve the exact complete assessment independently of the chosen mode.
            result["completion_findings" if coverage else "parity_findings"] = [
                item.to_dict() for item in complete
            ]
        return result


# Export the same objects across the typed module boundary without wrappers.
ValidationOperation = _Validation
collect_findings = _findings
