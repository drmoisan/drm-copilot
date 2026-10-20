"""Compose explicit validation modes without issuing native authority."""

from __future__ import annotations

from collections import Counter
from dataclasses import dataclass, replace
from typing import TYPE_CHECKING, Literal, TypeAlias

from drm_copilot_discovery.acceptance_rules import validate_acceptance
from drm_copilot_discovery.agent_output import (
    REPORT_KINDS,
    historical_report,
    validate_agent_output,
)
from drm_copilot_discovery.claim_rules import validate_claims
from drm_copilot_discovery.completion_rules import validate_completion
from drm_copilot_discovery.coverage_report import (
    coverage_preflight,
    coverage_summary,
    unavailable_coverage_summary,
)
from drm_copilot_discovery.coverage_rules import validate_coverage
from drm_copilot_discovery.decision_rules import validate_decisions
from drm_copilot_discovery.dimension_rules import validate_dimensions
from drm_copilot_discovery.evidence_rules import validate_evidence
from drm_copilot_discovery.findings import Finding, FindingCollector
from drm_copilot_discovery.models import to_plain_value
from drm_copilot_discovery.parity_rules import validate_parity
from drm_copilot_discovery.references import index_references
from drm_copilot_discovery.revision_rules import validate_revisions
from drm_copilot_discovery.snapshot import repository_pins
from drm_copilot_discovery.validation_inputs import (
    CONTROL_KINDS as _CONTROL,
)
from drm_copilot_discovery.validation_inputs import (
    input_problem as _problem,
)
from drm_copilot_discovery.validation_inputs import (
    report_input_digest as report_input_digest,
)
from drm_copilot_discovery.validation_inputs import (
    validate_inputs as _schema_findings,
)

if TYPE_CHECKING:
    from collections.abc import Iterable

    from drm_copilot_discovery.agent_output import InvocationContext
    from drm_copilot_discovery.dimension_rules import DimensionValidation
    from drm_copilot_discovery.snapshot import DiscoverySnapshot

ValidationMode: TypeAlias = Literal[
    "structural", "agent-output", "discovery-complete", "parity-complete", "planning"
]
_MODES = frozenset(
    {"structural", "agent-output", "discovery-complete", "parity-complete", "planning"}
)


def _findings(values: Iterable[Finding], limit: int) -> tuple[Finding, ...]:
    """Bound, deduplicate and sort every aggregate without losing truncation failure."""
    collector = FindingCollector(limit=limit)
    # All families share the same finite result budget and deterministic ordering.
    for finding in values:
        collector.add(finding)
    return collector.findings


@dataclass(frozen=True, kw_only=True)
class SnapshotValidation:
    """Bind a pure result to its selected mode and exact captured input identity.

    output_valid answers only whether an agent delivered its allowed output set.
    validation_result also reflects a review's actual PASS/FAIL. No value here
    authenticates a native principal or replaces a protected fresh receipt.
    """

    mode: ValidationMode
    findings: tuple[Finding, ...]
    input_sha256: str | None
    validation_result: Literal["pass", "fail"]
    output_valid: bool | None = None
    role: str | None = None
    invocation_id: str | None = None
    required_outputs_sha256: str | None = None

    @property
    def ok(self) -> bool:
        """Return output validity or selected root-mode success."""
        return (
            self.output_valid is True
            if self.mode == "agent-output"
            else self.validation_result == "pass"
        )


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
        parity = validate_parity(
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
                    parity,
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
        """Apply source discovery before optional target parity completeness."""
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
            values.extend(
                validate_parity(
                    snapshot,
                    complete=True,
                    index=self.index,
                    evidence=self.evidence,
                    revisions=self.revisions,
                    decisions=self.decisions,
                    dimensions=dimensions,
                ).findings
            )
        return _findings(values, self.limit)

    def report(self, *, kind: str, identifier: str, mode: str) -> dict[str, object]:
        """Return fields for kind, identifier and mode (str) from shared assessments.

        Coverage adds independently evaluated discovery results and population;
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
        # Only coverage gains discovery-specific fields; other report envelopes
        # retain their existing comparison contract and requested-mode semantics.
        if kind == "coverage-report":
            complete = self.evaluate("discovery-complete")
            result["coverage"] = to_plain_value(
                coverage_summary(
                    self.snapshot,
                    index=self.index,
                    evidence=self.evidence,
                    claims=self.claims,
                    dimensions=self.dimensions,
                    findings=complete,
                )
            )
            result["discovery_result"] = (
                "fail" if any(item.severity == "error" for item in complete) else "pass"
            )
            # Preserve the exact complete assessment independently of the chosen mode.
            result["completion_findings"] = [item.to_dict() for item in complete]
        return result


def validate_snapshot(
    snapshot: DiscoverySnapshot | None,
    *,
    mode: ValidationMode,
    invocation: InvocationContext | None = None,
) -> SnapshotValidation:
    """Validate exactly one selected mode; missing inputs fail without reads or writes.

    The caller must authenticate invocation context outside this pure boundary.
    V1 schemas and workspace receipt/control mirrors never select or satisfy modes.
    """
    if mode not in _MODES:
        raise ValueError("An explicit supported validation mode is required")
    if snapshot is None:
        return SnapshotValidation(
            mode=mode,
            findings=(
                _problem("PROFILE_REQUIRED", "A loaded v2 snapshot is required."),
            ),
            input_sha256=None,
            validation_result="fail",
            output_valid=False if mode == "agent-output" else None,
        )
    findings = list(_schema_findings(snapshot))
    output_valid, manifest_digest = None, None
    review_findings: tuple[Finding, ...] = ()
    if not any(item.severity == "error" for item in findings):
        validation = _Validation(snapshot)
        findings.extend(validation.evaluate(mode))
        # Derived statuses/counts must equal recomputation; they are never inputs to it.
        for artifact in snapshot.artifacts:
            if artifact.expected_kind not in REPORT_KINDS or artifact.document is None:
                continue
            # A bounded analyst update preserves unrequested historical views.
            if (
                mode == "agent-output"
                and invocation is not None
                and historical_report(snapshot, artifact, invocation)
            ):
                continue
            document = artifact.document
            review_mode, identifier = document.get("mode"), document.get("id")
            if (
                not isinstance(review_mode, str)
                or review_mode not in _MODES - {"agent-output"}
                or not isinstance(identifier, str)
            ):
                findings.append(
                    _problem(
                        "REPORT_CONTRACT",
                        "Report requires an explicit mode and ID.",
                        artifact.path,
                    )
                )
                continue
            expected = validation.report(
                kind=artifact.expected_kind, identifier=identifier, mode=review_mode
            )
            if to_plain_value(document) != expected:
                findings.append(
                    _problem(
                        "REPORT_RESULT",
                        "Report fields disagree with recomputed input results.",
                        artifact.path,
                    )
                )
            if (
                invocation is not None
                and invocation.role == "migration-coverage-reviewer"
                and review_mode == invocation.review_mode
            ):
                review_findings = validation.evaluate(review_mode)
        if mode == "agent-output" and invocation is not None:
            output = validate_agent_output(
                snapshot, invocation=invocation, index=validation.index
            )
            findings.extend(output.findings)
            manifest_digest = output.manifest_sha256
    if mode == "agent-output":
        if invocation is None:
            findings.append(
                _problem(
                    "OUTPUT_CONTEXT",
                    "Role-output validation requires caller-bound invocation context.",
                )
            )
        output_valid = not any(item.severity == "error" for item in findings)
    elif invocation is not None:
        findings.append(
            _problem(
                "VALIDATION_CONTEXT",
                "Role invocation context cannot select a root gate mode.",
            )
        )
    ordered = _findings(
        (*findings, *review_findings), snapshot.profile.limits.parse_limits().findings
    )
    failed = any(item.severity == "error" for item in ordered)
    return SnapshotValidation(
        mode=mode,
        findings=ordered,
        input_sha256=snapshot.sha256,
        validation_result="fail" if failed else "pass",
        output_valid=output_valid,
        role=invocation.role if invocation else None,
        invocation_id=invocation.invocation_id if invocation else None,
        required_outputs_sha256=manifest_digest,
    )


def report_projection(
    snapshot: DiscoverySnapshot, *, kind: str, identifier: str, mode: ValidationMode
) -> dict[str, object]:
    """Project snapshot (DiscoverySnapshot) for kind/identifier (str) and root mode.

    Returns dict[str, object] without I/O or publication. Coverage reports retain
    structural failures and unavailable counts; other kinds reject those inputs.
    Raises ValueError for unsupported kind/mode, invalid non-coverage inputs or
    resource excess. No caller mutation or injected validation authority exists.
    """
    if kind not in REPORT_KINDS or mode == "agent-output":
        raise ValueError("Reports require a supported report kind and root review mode")
    # Reserve coverage work before structural validation or aggregate projection.
    if kind == "coverage-report":
        coverage_preflight(snapshot)
    failures = _schema_findings(snapshot)
    if any(item.severity == "error" for item in failures):
        # Invalid core bytes cannot supply counts, yet coverage can truthfully
        # render the original blockers without running any semantic assessments.
        if kind == "coverage-report":
            if mode not in _MODES:
                raise ValueError("Unsupported report or validation mode")
            return {
                "schema_version": "2.0.0",
                "artifact_kind": kind,
                "id": identifier,
                "mode": mode,
                "input_sha256": report_input_digest(snapshot),
                "validation_result": "fail",
                "counts": {},
                "findings": [item.to_dict() for item in failures],
                "coverage": to_plain_value(unavailable_coverage_summary()),
                "discovery_result": "fail",
                "completion_findings": [item.to_dict() for item in failures],
            }
        raise ValueError("Report projection requires structurally parsed inputs")
    return _Validation(snapshot).report(kind=kind, identifier=identifier, mode=mode)
