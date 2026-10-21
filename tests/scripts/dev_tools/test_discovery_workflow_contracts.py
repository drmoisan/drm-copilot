"""Check invoked canonical workflow contracts without claiming native enforcement.

These static repository fixtures are the authored product. Runtime graph/schema
proof is retained from accepted tasks; generated skills and Set K belong to P7-T3.
No test runs a tool, writes a file, or grants a consumer workspace capability.
"""

from __future__ import annotations

import re
from pathlib import Path
from typing import cast

import pytest
import yaml

ROOT = Path(__file__).resolve().parents[3]
LEGACY = "legacy-parity-analyst"
RUNTIME = "runtime-characterization-analyst"
RECONCILER = "requirements-reconciler"
REVIEWER = "migration-coverage-reviewer"
WORKFLOWS = {
    "inventory-legacy-system": LEGACY,
    "extract-feature-contract": LEGACY,
    "characterize-runtime-behavior": RUNTIME,
    "reconcile-parity-matrix": RECONCILER,
    "review-discovery-coverage": REVIEWER,
    "adjudicate-unspecified-behavior": RECONCILER,
    "generate-acceptance-scenarios": RECONCILER,
    "initialize-discovery-workspace": REVIEWER,
    "validate-discovery-artifacts": REVIEWER,
}
INPUTS = {
    "inventory-legacy-system": "profile scope analyzer_ids write dry_run",
    "extract-feature-contract": (
        "profile component_ids feature_ids source_refs test_refs "
        "documentation_refs evidence_refs"
    ),
    "characterize-runtime-behavior": (
        "profile feature_ids environment fixtures preconditions actions "
        "capability_mode supplied_captures"
    ),
    "reconcile-parity-matrix": (
        "profile source_snapshot_refs feature_ids client_ids "
        "target_implementation_refs evidence_refs approved_decision_refs"
    ),
    "review-discovery-coverage": "profile scope snapshot mode",
    "adjudicate-unspecified-behavior": (
        "profile unresolved_ids interpretations evidence_refs decision_owner "
        "approval_record derived_acceptance"
    ),
    "generate-acceptance-scenarios": (
        "profile contract_refs approved_decision_refs kind feature_filter "
        "client_filter platform_filter mode_filter format"
    ),
    "initialize-discovery-workspace": (
        "system_id system_name repository_id repository_role roots draft_inputs "
        "dry_run profile_selection"
    ),
    "validate-discovery-artifacts": "profile artifact_kind selection mode",
}
ALIASES = {
    "discovery-workflow": dict(zip(WORKFLOWS, WORKFLOWS, strict=True)),
    "discovery-repo-inventory": {"fixed": "inventory-legacy-system"},
    "discovery-coverage-ledger": {
        "inventory": "inventory-legacy-system",
        "extract": "extract-feature-contract",
        "review": "review-discovery-coverage",
    },
    "discovery-runtime-characterization": {"fixed": "characterize-runtime-behavior"},
    "discovery-parity-matrix": {"fixed": "reconcile-parity-matrix"},
    "discovery-behavior-reconciliation": {"fixed": "adjudicate-unspecified-behavior"},
    "discovery-validate-artifacts": {"fixed": "validate-discovery-artifacts"},
}
SKILLS = (*WORKFLOWS, *ALIASES)
QUESTIONS = {
    "unspecified-behavior": "unspecified_behaviors",
    "unspecified-behavior-collection": "unspecified_behaviors",
}
MANIFEST = {"required-output-manifest": "reports"}
REPORTS = {
    "coverage-report": "reports",
    "parity-report": "reports",
    "completion-report": "reports",
    "validation-report": "reports",
    **MANIFEST,
}
OUTPUTS = {
    "inventory-legacy-system": {
        "inventory-snapshot": "inventory",
        "coverage-ledger": "coverage_ledger",
        "evidence-reference": "evidence",
        **QUESTIONS,
        **MANIFEST,
    },
    "extract-feature-contract": {
        "feature-contract": "feature_contracts",
        "coverage-ledger": "coverage_ledger",
        "evidence-reference": "evidence",
        **QUESTIONS,
        **MANIFEST,
    },
    "characterize-runtime-behavior": {
        "runtime-characterization-scenario": "characterization",
        "evidence-reference": "evidence",
        "evidence-payload": "evidence",
        **QUESTIONS,
        **MANIFEST,
    },
    "reconcile-parity-matrix": {
        "parity-matrix": "parity_matrix",
        **QUESTIONS,
        **MANIFEST,
    },
    "review-discovery-coverage": REPORTS,
    "adjudicate-unspecified-behavior": {
        "product-decision": "product_decisions",
        "product-decision-collection": "product_decisions",
        "acceptance-specification": "acceptance",
        "acceptance-view": "acceptance",
        **QUESTIONS,
        **MANIFEST,
    },
    "generate-acceptance-scenarios": {
        "acceptance-specification": "acceptance",
        "acceptance-view": "acceptance",
        **MANIFEST,
    },
    "initialize-discovery-workspace": {
        "validation-report": "reports",
        "coverage-report": "reports",
        **MANIFEST,
    },
    "validate-discovery-artifacts": {
        "validation-report": "reports",
        "coverage-report": "reports",
        **MANIFEST,
    },
}


def skill(name: str) -> tuple[dict[str, object], str]:
    """Read name (str), a fixed canonical fixture, returning metadata and body.

    Returns tuple[dict[str, object], str]; raises AssertionError for bad metadata,
    OSError for absent fixtures or yaml.YAMLError for malformed YAML. Reads only
    repository Markdown and performs no writes or consumer-source operations.
    """
    assert name in SKILLS
    text = (ROOT / ".github" / "skills" / name / "SKILL.md").read_text(encoding="utf-8")
    opening, metadata, body = text.split("---", 2)
    assert opening == "" and body.startswith("\n")
    decoded: object = yaml.safe_load(metadata)
    assert isinstance(decoded, dict)
    return cast("dict[str, object]", decoded), body


def rows(body: str, heading: str) -> dict[str, str]:
    """Read the first two table cells from body (str) under heading (str).

    Returns dict[str, str] of unique data rows. Raises AssertionError for absent
    or duplicate rows and IndexError for missing headings. No I/O or mutation.
    """
    section = body.split(f"## {heading}\n", 1)[1].split("\n## ", 1)[0]
    found = re.findall(r"^\| ([a-z][a-z_-]*) \| ([^|]+?) \|", section, re.M)
    assert found and len(dict(found)) == len(found), "Missing or duplicate table key"
    return dict(found)


def require(body: str, *fragments: str) -> None:
    """Assert fragments (str) survive ordinary reflow of body (str).

    Returns None; raises AssertionError for a missing procedural guarantee.
    Does not execute instructions, read other files or mutate inputs.
    """
    normalized = " ".join(body.split())
    # Each clause protects an independent authority or evidence boundary.
    for fragment in fragments:
        assert fragment in normalized, f"Missing workflow contract: {fragment}"


@pytest.mark.parametrize("name", SKILLS)
def test_skill_metadata_uses_invoked_canonical_template(name: str) -> None:
    """For name (str), assert closed metadata; return None or AssertionError.

    Reads one static fixture only; no tool capability is inferred from metadata.
    """
    metadata, body = skill(name)
    assert set(metadata) == {"name", "description"}
    assert metadata["name"] == name and re.fullmatch(r"[a-z0-9-]{1,64}", name)
    description = metadata["description"]
    assert isinstance(description, str) and 10 <= len(description) <= 1024
    assert "Use when" in description
    # Consumer vocabulary must not become a standing domain assumption.
    for token in ("taskmaster", "tmw", "outlook", "vsto", "email", "task-management"):
        assert token not in (description + body).lower()
    require(body, "## When to Use This Skill", "## Inputs", "## References")


@pytest.mark.parametrize("name", WORKFLOWS)
def test_workflow_inputs_and_role_are_explicit_closed_contracts(name: str) -> None:
    """For name (str), pin inputs/routing; return None or AssertionError.

    Reads one fixture only; human inputs do not become new service-request keys.
    """
    _, body = skill(name)
    assert set(rows(body, "Inputs")) == set(INPUTS[name].split())
    require(
        body, f"Logical role: `{WORKFLOWS[name]}`.", "## Routing", "## Prerequisites"
    )
    require(body, "human-facing", "not additional service-request fields")


@pytest.mark.parametrize("name", WORKFLOWS)
def test_workflow_output_rows_cannot_expand_the_accepted_role(name: str) -> None:
    """For name (str), check exact output cap; return None or AssertionError.

    Reads skill and accepted role fixtures only; creates no actual write grant.
    """
    _, body = skill(name)
    actual = rows(body, "Exact output boundary")
    assert actual == OUTPUTS[name]
    role_body = (ROOT / ".github" / "agents" / f"{WORKFLOWS[name]}.agent.md").read_text(
        encoding="utf-8"
    )
    assert actual.items() <= rows(role_body, "Exact output boundary").items()
    require(body, "profile keys are maximum configured locations, not write grants")
    # Non-review roles sharing the reports location still have only manifest access.
    if WORKFLOWS[name] != REVIEWER:
        # Compare every reports-mapped kind rather than accepting a shared root.
        assert {kind for kind, key in actual.items() if key == "reports"} == set(
            MANIFEST
        )


@pytest.mark.parametrize("name", ALIASES)
def test_alias_is_dispatch_only_with_closed_canonical_targets(name: str) -> None:
    """For name (str), pin alias dispatch; return None or AssertionError.

    Reads one fixture only; does not schedule or prepare any specialist.
    """
    _, body = skill(name)
    assert rows(body, "Dispatch") == ALIASES[name]
    assert "## Exact output boundary" not in body
    require(body, "alias selectors", "not service-request fields")
    require(body, "no independent output or write authority")
    # Every target must be an actual canonical workflow rather than an alias chain.
    for target in ALIASES[name].values():
        assert target in WORKFLOWS
        require(body, f"../{target}/SKILL.md")


@pytest.mark.parametrize("name", WORKFLOWS)
def test_workflow_lifecycle_prepares_exact_role_before_finalization(name: str) -> None:
    """For name (str), retain ordered authority; return None or AssertionError.

    Reads a static workflow; no host attestation or native execution is claimed.
    """
    _, body = skill(name)
    markers = (
        "The root calls `prepare_discovery_agent`",
        "The root launches that exact deployment",
        "Use only the granted operations",
        "Call `finalize_discovery_agent`",
        "Native SubagentStop",
        "the root records the explicit result",
    )
    # Ordering protects preparation, execution, finalization and independent stop.
    positions = [body.index(marker) for marker in markers]
    assert positions == sorted(positions)
    require(
        body,
        "`skill_id`, `selected_ids`, `paths`, `expected_outputs`, "
        "`execution_context` and `complexity`",
        f"`skill_id={name}`",
        "existing resolver selects the exact deployment, model, effort "
        "and profile hash",
        "Native SubagentStart must match the prepared role/model/effort/profile "
        "and trusted workspace/session before any grant is usable",
        "`mode=agent-output`, non-null `invocation_ref` and no operation inputs",
        "required-output-manifest",
        "output array order",
        "content-addressed artifact references",
        "selected-ID accounting",
        "Missing final text cannot skip native stop validation",
    )


@pytest.mark.parametrize("name", WORKFLOWS)
def test_workflow_grants_and_missing_capabilities_fail_closed(name: str) -> None:
    """For name (str), reject authority expansion; return None or AssertionError.

    Reads one fixture only; manifests, profiles and memory create no permission.
    """
    _, body = skill(name)
    require(
        body,
        "`artifact_kind`, `id`, `path`, `format` and `expected_sha256`",
        "selected IDs",
        "source/target pins",
        "baseline input hashes",
        "a manifest cannot expand",
        "null expected hash means exclusive creation from an absent baseline",
        "Preserve unselected collection members and all unrelated inputs",
        "Missing prepare/finalize/start/stop capability",
        "There is no local-user fallback or self-attested host success",
        "Deny terminal/shell/exec",
        "interpreter/evaluation",
        "general filesystem Write/Edit/apply-patch",
        "arbitrary MCP dispatch",
        "Memory cannot grant filesystem authority",
        "Server-side role checks, exact one-use authorization and prospective "
        "validation remain mandatory",
        "truncation requires a narrower selection, not a completeness claim "
        "or filesystem fallback",
        "do not preload a domain catalog in standing instructions",
        "Structural success is not discovery, parity or planning completion",
    )
    # Bootstrap alone permits an absent profile, never malformed existing state.
    if name == "initialize-discovery-workspace":
        require(
            body,
            "sole missing-profile bootstrap exception",
            "do not bypass malformed state",
        )
    else:
        require(body, "Missing or malformed configuration blocks delegation")


def test_inventory_detection_and_runtime_plans_preserve_evidence_distinctions() -> None:
    """With no inputs, pin observed-fact limits; return None or AssertionError.

    Reads three fixtures only; static inspection is not runtime execution.
    """
    _, inventory = skill("inventory-legacy-system")
    _, extract = skill("extract-feature-contract")
    _, runtime = skill("characterize-runtime-behavior")
    require(
        inventory, "Detection alone never marks a component inspected or dispositioned"
    )
    require(
        extract,
        "unknown or contradictory behavior as unresolved",
        "Never convert source facts into approved target requirements",
    )
    require(
        runtime,
        "Do not execute application code",
        "qualifying runtime evidence",
        "not-run",
        "blocked",
        "unknown expectations stay null",
    )


def test_reconciliation_and_adjudication_cannot_self_approve_or_rewrite_sources() -> (
    None
):
    """With no inputs, pin decision authority; return None or AssertionError.

    Reads two fixtures only; approval records are inputs, not analyst authority.
    """
    _, reconcile = skill("reconcile-parity-matrix")
    _, adjudicate = skill("adjudicate-unspecified-behavior")
    require(
        reconcile,
        "`implementation_records` and `source_snapshots` are inputs, not outputs",
        "Pending questions cannot become approved requirements",
    )
    require(
        adjudicate,
        "Root approval is a separate",
        "`update_action=approve-decision`",
        "`input_path`",
        "`expected_sha256`",
        "`approval_owner`",
        "nonempty `approval_evidence_refs`",
        "Ordinary replacement cannot set approval-only fields",
        "Derived criteria do not authorize `feature_contracts` writes",
        "Do not approve/reject/supersede product decisions or alter approval history",
    )
    assert adjudicate.index("Call `finalize_discovery_agent`") < adjudicate.index(
        "After proposal finalization and native stop, the authorized root"
    )


def test_generation_retains_identity_pending_expectations_and_validated_tags() -> None:
    """With no inputs, pin acceptance provenance; return None or AssertionError.

    Reads one fixture only; generation does not execute or verify implementation.
    """
    _, body = skill("generate-acceptance-scenarios")
    require(
        body,
        "repository/client/platform/mode and scenario identity",
        "validated tags",
        "null unresolved expectations",
        "pending",
        "generated specifications are not implementation or runtime evidence",
    )


def test_initialization_is_root_owned_before_any_reviewer_delegation() -> None:
    """With no inputs, retain bootstrap separation; return None or AssertionError.

    Reads one fixture only; dry-run projection never grants configuration writes.
    """
    _, body = skill("initialize-discovery-workspace")
    require(
        body,
        "root",
        "init",
        "configure",
        "valid projected/resulting configuration",
        "The reviewer writes exact reports, never configuration, and never "
        "receives profile, locator, activation, authority or installation writes",
        "dry-run",
        "bootstrap",
    )
    assert body.index("The root validates explicit bootstrap inputs") < body.index(
        "The root calls `prepare_discovery_agent`"
    )


@pytest.mark.parametrize(
    "name", ("review-discovery-coverage", "validate-discovery-artifacts")
)
def test_review_validation_cannot_repair_facts_or_turn_valid_failure_into_pass(
    name: str,
) -> None:
    """For name (str), retain assessment meaning; return None or AssertionError.

    Reads one fixture only; report validity does not satisfy completion gates.
    """
    _, body = skill(name)
    require(
        body,
        "explicit",
        "mode",
        "Do not guess artifact types by first-success validation",
        "Do not update inventory, coverage ledger, contracts, parity entries, "
        "evidence, decisions or configuration to force a pass",
        "output-valid/result-fail",
        "never authorizes discovery, parity or planning completion",
    )


def test_umbrella_and_coverage_alias_selectors_cannot_introduce_roles_or_grants() -> (
    None
):
    """With no inputs, pin multi-target aliases; return None or AssertionError.

    Reads three alias fixtures only; each target retains its canonical lifecycle.
    """
    _, umbrella = skill("discovery-workflow")
    _, coverage = skill("discovery-coverage-ledger")
    _, parity = skill("discovery-parity-matrix")
    assert set(rows(umbrella, "Inputs")) == {"skill_id"}
    assert set(rows(coverage, "Inputs")) == {"action"}
    require(
        coverage,
        "legacy-parity-analyst",
        "migration-coverage-reviewer",
        "no reviewer ledger writes",
    )
    require(parity, "requirements-reconciler")
    require(umbrella, "prepare", "finalize", "unknown", "no fallback")
