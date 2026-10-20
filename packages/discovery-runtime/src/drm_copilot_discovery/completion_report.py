"""Project selected completion diagnostics without creating readiness authority."""

from __future__ import annotations

from typing import TYPE_CHECKING, cast

from drm_copilot_discovery.coverage_report import coverage_preflight
from drm_copilot_discovery.findings import Finding
from drm_copilot_discovery.models import JsonObject, ParseLimits, to_plain_value
from drm_copilot_discovery.parity_report import build_parity_rows
from drm_copilot_discovery.path_models import WriteGrant
from drm_copilot_discovery.rendering import render_pretty_json
from drm_copilot_discovery.report_models import (
    DiscoveryReport,
    ReportBudget,
    bounded_object,
    build_coverage_rows,
)

if TYPE_CHECKING:
    from drm_copilot_discovery.mutation_plan import CapturedWorkspace, MutationPlan
    from drm_copilot_discovery.snapshot import DiscoverySnapshot
    from drm_copilot_discovery.validation import ValidationMode

_MODE_LABELS = {
    "structural": "Structural validation",
    "discovery-complete": "Discovery completion",
    "parity-complete": "Parity completion",
    "planning": "Planning prerequisite",
}


def _mode_label(mode: ValidationMode) -> str:
    """Return the fixed label for mode (ValidationMode), without side effects.

    Unsupported values, including agent-output, raise ValueError before any
    semantic work. A label never supplies completion or native host authority.
    """
    if type(mode) is not str or mode not in _MODE_LABELS:
        raise ValueError("Completion reports require a supported root validation mode")
    return _MODE_LABELS[mode]


def completion_preflight(snapshot: DiscoverySnapshot) -> None:
    """Bound captured snapshot (DiscoverySnapshot); return None without I/O.

    Reuses coverage_preflight's input resource policy, not coverage evaluation.
    ValueError rejects invalid inputs; ReportLimitError rejects excess work or
    bytes before semantic assessment. Generated views remain excluded.
    """
    coverage_preflight(snapshot)


def completion_summary(
    snapshot: DiscoverySnapshot,
    *,
    mode: ValidationMode,
    findings: tuple[Finding, ...],
    structural_valid: bool,
) -> JsonObject:
    """Return bounded completion fields from already-selected diagnostics.

    snapshot (DiscoverySnapshot) supplies limits and the planning prerequisite.
    mode (ValidationMode) chooses only its label; findings (tuple[Finding]) retain
    their supplied order and exact actions. structural_valid (bool) controls
    availability, independently of semantic success. This pure helper never
    evaluates rules, drops findings, mutates callers or performs I/O.
    ValueError rejects malformed arguments; ReportLimitError aborts excess
    work/retained output without returning a partial successful summary.
    """
    label = _mode_label(mode)
    if type(findings) is not tuple or type(structural_valid) is not bool:
        raise ValueError("Completion requires immutable findings and boolean validity")
    completion_preflight(snapshot)
    limits = snapshot.profile.limits.parse_limits()
    budget = ReportBudget(limits)
    budget.work(4 * len(findings))
    counts = {"error": 0, "warning": 0, "info": 0}
    blocking: list[int] = []
    warnings: list[int] = []
    groups: dict[str, list[int]] = {}
    # Invalid inputs expose no planning prerequisite, even when mode names planning.
    prerequisite = (
        snapshot.profile.completion_gates.planning_prerequisite
        if structural_valid and mode == "planning"
        else None
    )
    summary: dict[str, object] = {
        "assessment_state": "available" if structural_valid else "unavailable",
        "mode_label": label,
        "planning_prerequisite": prerequisite,
        "retained_finding_counts": counts,
        "findings_complete": True,
        "blocking_findings": blocking,
        "warning_findings": warnings,
        "next_actions": [],
    }
    budget.check(summary)
    # Reserve possible decimal count growth before changing the retained counters.
    budget.work(3)
    budget.spend(3 * len(str(len(findings))))
    maximum_action = 0
    # Retain every diagnostic position while indexing exact action text only once.
    for position, finding in enumerate(findings):
        if type(finding) is not Finding:
            raise ValueError("Completion findings must be Finding values")
        action = finding.next_action
        budget.work(len(action))
        budget.text(action)
        maximum_action = max(maximum_action, len(action))
        if action not in groups:
            budget.check({"action": action, "finding_indices": ()})
            groups[action] = []
        # Each position can occur in one severity list and one action index list.
        budget.check((position, position))
        budget.spend(2)
        groups[action].append(position)
        counts[finding.severity] += 1
        # Severity indices preserve input order; informational findings remain counted.
        if finding.severity == "error":
            blocking.append(position)
        elif finding.severity == "warning":
            warnings.append(position)
        if finding.code == "FINDINGS_LIMIT":
            summary["findings_complete"] = False
    # Bound worst-case string comparisons before sorting distinct action keys.
    count = len(groups)
    budget.work(2 * count * max(1, count.bit_length()) * maximum_action)
    # List construction uses previously reserved row, text and index capacities.
    summary["next_actions"] = [
        {"action": action, "finding_indices": groups[action]}
        for action in sorted(groups)
    ]
    return bounded_object(summary, limits=limits)


def build_completion_report(
    snapshot: DiscoverySnapshot,
    *,
    mode: ValidationMode,
    identifier: str = "completion",
) -> DiscoveryReport:
    """Return authoritative completion views for one captured snapshot and mode.

    snapshot (DiscoverySnapshot) supplies captured inputs, mode (ValidationMode)
    chooses one root assessment and identifier (str) identifies the report.
    The lazy public projection supplies all results; this wrapper never evaluates
    another mode. ValueError/ReportLimitError reject invalid or excessive input.
    No I/O, input mutation, output grant or host readiness receipt is produced.
    """
    from drm_copilot_discovery.validation import report_projection

    _mode_label(mode)
    completion_preflight(snapshot)
    value = report_projection(
        snapshot, kind="completion-report", identifier=identifier, mode=mode
    )
    limits = snapshot.profile.limits.parse_limits()
    return DiscoveryReport(document=bounded_object(value, limits=limits), limits=limits)


def plan_completion_report(
    baseline: CapturedWorkspace,
    *,
    mode: ValidationMode,
    grants: tuple[WriteGrant, ...],
    identifier: str = "completion",
) -> MutationPlan:
    """Plan both completion views using exact caller-authenticated root grants.

    baseline (CapturedWorkspace) binds bytes/metadata; mode (ValidationMode)
    selects assessment; grants (tuple[WriteGrant]) must name exactly the JSON and
    Markdown reports-root paths with completion-report kind and identifier (str).
    Returns the existing immutable MutationPlan with captured-byte CAS digests.
    ValueError rejects invalid modes/captures; MutationError rejects grants or
    prospective validity, and lower-layer path/resource errors propagate.
    No grants are minted and no I/O, writes or caller mutation occurs. Callers
    publish only through the existing separately authorized commit_mutation.
    """
    from drm_copilot_discovery.mutation_plan import (
        CapturedWorkspace,
        MutationChange,
        MutationError,
        plan_mutation,
    )

    _mode_label(mode)
    if type(baseline) is not CapturedWorkspace:
        raise ValueError("Completion planning requires a captured workspace")
    completion_preflight(baseline.snapshot)
    root = baseline.snapshot.profile.artifacts["reports"]
    paths = (root + "/completion-report.json", root + "/completion-report.md")
    if type(grants) is not tuple or len(grants) != 2:
        raise MutationError(
            "MUTATION_GRANT", "Require both exact completion-view grants"
        )
    # Reject any extra authority or identity substitution before generating bytes.
    if any(
        type(grant) is not WriteGrant
        or grant.artifact_kind != "completion-report"
        or grant.artifact_id != identifier
        for grant in grants
    ) or {grant.path for grant in grants} != set(paths):
        raise MutationError(
            "MUTATION_GRANT", "Require both exact completion-view grants"
        )
    snapshot = baseline.snapshot
    budget = ReportBudget(snapshot.profile.limits.parse_limits())
    budget.work(2 * len(snapshot.manifest.files))
    # Only two exact captured paths supply CAS digests; no sibling reads occur.
    previous = {
        item.path: item.sha256 for item in snapshot.manifest.files if item.path in paths
    }
    report = build_completion_report(snapshot, mode=mode, identifier=identifier)
    # Both renderers reserve their own complete encoded view before allocation.
    documents = (report.to_json().encode("utf-8"), report.to_markdown().encode("utf-8"))
    # Derive requests from one report and captured originals, never caller text.
    changes = tuple(
        MutationChange(
            artifact_kind="completion-report",
            artifact_id=identifier,
            path=path,
            content=content,
            expected_sha256=previous.get(path),
        )
        for path, content in zip(paths, documents, strict=True)
    )
    return plan_mutation(baseline, changes, grants=grants)


def build_completion_summary(
    coverage_artifact: dict[str, object], parity_artifact: dict[str, object]
) -> dict[str, object]:
    """Return bounded legacy-only counts, without a completion/readiness claim.

    coverage_artifact and parity_artifact (dict[str, object]) use actual v1 shapes
    or historical unversioned placeholders. Accepted pure helpers reject explicit
    v2 or malformed inputs with ValueError and excess with ReportLimitError.
    Returns a fresh dict; performs no I/O, validation, mutation or publication.
    """
    coverage, _ = build_coverage_rows(coverage_artifact)
    parity, _ = build_parity_rows(parity_artifact)
    return {
        "coverage_ledger": {"present": True, "entry_count": len(coverage)},
        "parity_matrix": {"present": True, "entry_count": len(parity)},
        "validation_scope": "legacy-artifact-compatibility-only",
    }


def render_completion_report(summary: dict[str, object]) -> str:
    """Render legacy summary (dict[str, object]) as bounded deterministic JSON.

    Returns LF-terminated pretty JSON. Versioned/artifact envelopes or malformed
    data raise ValueError; ReportLimitError rejects excess before rendering.
    This compatibility view performs no I/O, mutation or graph assessment.
    """
    value = bounded_object(summary, limits=ParseLimits())
    if "schema_version" in value or "artifact_kind" in value:
        raise ValueError("Use a captured snapshot for versioned completion reports")
    ReportBudget(ParseLimits(), pretty=True).check(value)
    return render_pretty_json(cast("dict[str, object]", to_plain_value(value)))
