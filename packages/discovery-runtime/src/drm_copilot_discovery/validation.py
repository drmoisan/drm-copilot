"""Compose explicit validation modes without issuing native authority."""

from __future__ import annotations

from dataclasses import dataclass
from typing import TYPE_CHECKING, Literal, TypeAlias

from drm_copilot_discovery.agent_output import (
    REPORT_KINDS,
    historical_report,
    validate_agent_output,
)
from drm_copilot_discovery.completion_report import (
    completion_preflight,
    completion_summary,
)
from drm_copilot_discovery.coverage_report import (
    coverage_preflight,
    unavailable_coverage_summary,
)
from drm_copilot_discovery.models import to_plain_value
from drm_copilot_discovery.parity_report import (
    parity_preflight,
    unavailable_parity_summary,
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
from drm_copilot_discovery.validation_operation import (
    ValidationOperation as _Validation,
)
from drm_copilot_discovery.validation_operation import (
    collect_findings as _findings,
)

if TYPE_CHECKING:
    from drm_copilot_discovery.agent_output import InvocationContext
    from drm_copilot_discovery.findings import Finding
    from drm_copilot_discovery.snapshot import DiscoverySnapshot

ValidationMode: TypeAlias = Literal[
    "structural", "agent-output", "discovery-complete", "parity-complete", "planning"
]
_MODES = frozenset(
    {"structural", "agent-output", "discovery-complete", "parity-complete", "planning"}
)


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
        validation = _Validation(snapshot, input_findings=tuple(findings))
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

    Returns dict[str, object] without I/O or publication. Coverage/parity retain
    structural failures and unavailable counts; completion retains diagnostics.
    Validation reports continue to reject structurally invalid inputs.
    Raises ValueError for unsupported kind/mode or
    resource excess. No caller mutation or injected validation authority exists.
    """
    if kind not in REPORT_KINDS or mode == "agent-output":
        raise ValueError("Reports require a supported report kind and root review mode")
    # Reserve report work before structural validation or aggregate projection.
    if kind == "coverage-report":
        coverage_preflight(snapshot)
    elif kind == "parity-report":
        parity_preflight(snapshot)
    elif kind == "completion-report":
        completion_preflight(snapshot)
    failures = _schema_findings(snapshot)
    if any(item.severity == "error" for item in failures):
        # Invalid core bytes cannot supply counts, yet diagnostic reports can
        # render the original blockers without running any semantic assessments.
        if kind in {"coverage-report", "parity-report"}:
            if mode not in _MODES:
                raise ValueError("Unsupported report or validation mode")
            coverage = kind == "coverage-report"
            return {
                "schema_version": "2.0.0",
                "artifact_kind": kind,
                "id": identifier,
                "mode": mode,
                "input_sha256": report_input_digest(snapshot),
                "validation_result": "fail",
                "counts": {},
                "findings": [item.to_dict() for item in failures],
                "coverage" if coverage else "parity": to_plain_value(
                    unavailable_coverage_summary()
                    if coverage
                    else unavailable_parity_summary()
                ),
                "discovery_result" if coverage else "parity_result": "fail",
                "completion_findings" if coverage else "parity_findings": [
                    item.to_dict() for item in failures
                ],
            }
        # Only completion adds diagnostics; validation reports retain strict refusal.
        if kind != "completion-report":
            raise ValueError("Report projection requires structurally parsed inputs")
        # Diagnostic completion cannot construct semantic proof or grant validity.
        if mode not in _MODES:
            raise ValueError("Unsupported report or validation mode")
        return {
            "schema_version": "2.0.0",
            "artifact_kind": kind,
            "id": identifier,
            "mode": mode,
            "input_sha256": report_input_digest(snapshot),
            "validation_result": "fail",
            "counts": None,
            "findings": [item.to_dict() for item in failures],
            "completion": to_plain_value(
                completion_summary(
                    snapshot, mode=mode, findings=failures, structural_valid=False
                )
            ),
        }
    return _Validation(snapshot, input_findings=failures).report(
        kind=kind, identifier=identifier, mode=mode
    )
