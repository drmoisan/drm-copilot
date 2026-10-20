"""Compose authoritative report and acceptance projections with guarded writes."""

from __future__ import annotations

from typing import TYPE_CHECKING, Literal, cast

from drm_copilot_discovery.findings import Finding, Severity
from drm_copilot_discovery.models import JsonObject
from drm_copilot_discovery.operations import OperationContext, OperationFailure
from drm_copilot_discovery.report_models import (
    DiscoveryReport,
    ReportLimitError,
    bounded_object,
)

if TYPE_CHECKING:
    from drm_copilot_discovery.mutation_plan import MutationChange
    from drm_copilot_discovery.service_contracts import DiscoveryResult


def report_findings(document: JsonObject) -> tuple[Finding, ...]:
    """Return typed findings from an authoritative bounded report document.

    document (JsonObject) must be a runtime-produced report. This adapter retains
    all fields, including truncation markers; it does not filter for a target or
    infer validity from absence. Malformed trusted output raises ValueError.
    No assessment, I/O or input mutation occurs.
    """
    raw = document.get("findings")
    if type(raw) is not tuple:
        raise ValueError("Report findings must be an immutable sequence")
    findings: list[Finding] = []
    # Runtime report findings already passed the report's complete output budget.
    for item in raw:
        if type(item) is not JsonObject:
            raise ValueError("Report findings must be immutable objects")
        fields = dict(item.members)
        findings.append(
            Finding(
                code=cast("str", fields["code"]),
                severity=cast("Severity", fields["severity"]),
                artifact_path=cast("str | None", fields["artifact_path"]),
                pointer=cast("str", fields["pointer"]),
                related_ids=cast("tuple[str, ...]", fields["related_ids"]),
                related_paths=cast("tuple[str, ...]", fields["related_paths"]),
                message=cast("str", fields["message"]),
                next_action=cast("str", fields["next_action"]),
            )
        )
    return tuple(findings)


def _report(context: OperationContext) -> DiscoveryResult:
    """Derive one report for context and return a preview or actual publication.

    context (OperationContext) supplies authenticated capture, mode and output
    preferences. Publication always plans both views from the same projection;
    format controls preview selection only. Original selected-gate failures
    remain exit 1. Resource/mutation errors propagate before publication.
    Malformed validation inputs return their real assessment without writing.
    """
    from drm_copilot_discovery.validation import report_projection, validate_snapshot

    operation = context.request.operation
    kind = "validation-report" if operation == "validate-all" else operation
    identifier = kind.removesuffix("-report")
    try:
        document = report_projection(
            context.snapshot,
            kind=kind,
            identifier=identifier,
            mode=context.request.mode,
        )
    except ReportLimitError:
        raise
    except ValueError:
        if operation != "validate-all":
            raise
        checked = validate_snapshot(context.snapshot, mode=context.request.mode)
        return context.result(findings=checked.findings, validation="fail", exit_code=1)
    report = DiscoveryReport(
        document=bounded_object(document, limits=context.limits), limits=context.limits
    )
    findings = report_findings(report.document)
    status = report.document.get("validation_result")
    if status not in ("pass", "fail"):
        raise ValueError("Report must retain the selected validation result")
    selected = cast("Literal['pass', 'fail']", status)
    root = context.snapshot.profile.artifacts["reports"]
    prefix = context.text("output_prefix", root + "/" + kind)
    if not prefix.startswith(root + "/"):
        raise OperationFailure("SERVICE_OUTPUT_PATH")
    texts = (report.to_json(), report.to_markdown())
    changes: list[MutationChange] = []
    # Both views use one authoritative document and independently bounded renderers.
    for suffix, text in zip((".json", ".md"), texts, strict=True):
        context.budget.text(text)
        changes.append(
            context.change(kind, identifier, prefix + suffix, text.encode("utf-8"))
        )
    proposed = tuple(changes)
    if operation == "validate-all" or context.request.write:
        return context.publish(
            context.plan(proposed), findings=findings, validation=selected
        )
    selected_format = context.request.format
    # Preview choice does not change the paired publication identity or assessment.
    preview = tuple(
        change
        for change in proposed
        if selected_format == "both"
        or change.path.endswith(".json" if selected_format == "json" else ".md")
    )
    return context.result(
        artifacts=context.projected(preview),
        findings=findings,
        validation=selected,
        exit_code=0 if selected == "pass" else 1,
    )


def _acceptance(context: OperationContext) -> DiscoveryResult:
    """Return captured acceptance source and views, optionally publishing one plan.

    context (OperationContext) supplies explicit selectors and trusted limits.
    Accepted generator/selector/rendering services retain ownership, unresolved
    questions and readiness. No pending question becomes execution evidence.
    Selector, resource and mutation errors propagate; writes use exact grants.
    """
    from drm_copilot_discovery.acceptance_generation import generate_acceptance
    from drm_copilot_discovery.gherkin import render_acceptance
    from drm_copilot_discovery.service_selection import (
        resolve_feature_ids,
        select_acceptance_platforms,
    )

    features = resolve_feature_ids(
        context.snapshot,
        feature_ids=context.strings("feature_ids"),
        repository_id=context.text("repository_id") or None,
    )
    generation = generate_acceptance(
        context.snapshot,
        kind=cast(
            "Literal['legacy-characterization', 'target-acceptance']",
            context.text("acceptance_kind"),
        ),
        feature_ids=features,
        client_ids=context.strings("client_ids"),
        mode_ids=context.strings("mode_ids"),
    )
    generation = select_acceptance_platforms(
        generation, platform_ids=context.strings("platform_ids")
    )
    bundle = render_acceptance(generation)
    context.budget.work(len(generation.specifications) + len(bundle.files))
    root = context.snapshot.profile.artifacts["acceptance"]
    changes: list[MutationChange] = []
    # Every generated source document remains present, including pending scenarios.
    for specification in generation.specifications:
        identifier = specification.identity.scenario_id(limits=context.limits)
        path = root + "/" + identifier + ".json"
        text = specification.to_json()
        context.budget.text(text)
        changes.append(
            context.change(
                "acceptance-specification", identifier, path, text.encode("utf-8")
            )
        )
    output_format = context.text("output_format", "both")
    # Rendered views retain their bounded exact bytes; no renderer is reimplemented.
    for view in bundle.files:
        if (
            output_format == "markdown"
            and not view.path.endswith(".md")
            or output_format == "gherkin"
            and not view.path.endswith(".feature")
        ):
            continue
        changes.append(
            context.change(
                "acceptance-view",
                context.request.id,
                root + "/" + view.path,
                view.content,
            )
        )
    proposed = tuple(changes)
    if context.request.write and proposed:
        return context.publish(context.plan(proposed), findings=generation.findings)
    return context.result(
        artifacts=context.projected(proposed),
        findings=generation.findings,
        counts=(
            ("specifications", len(generation.specifications)),
            ("ready_specifications", len(generation.ready)),
        ),
    )


def project(context: OperationContext) -> DiscoveryResult:
    """Dispatch the closed projection family for context; return DiscoveryResult.

    Existing pure services determine all graph semantics. Reports may publish
    paired views and acceptance may publish a single complete prospective set.
    Unsupported operations raise OperationFailure; no dynamic imports occur.
    """
    if context.request.operation == "generate-acceptance":
        return _acceptance(context)
    if context.request.operation in {
        "validate-all",
        "coverage-report",
        "parity-report",
        "completion-report",
    }:
        return _report(context)
    raise OperationFailure("SERVICE_OPERATION")
