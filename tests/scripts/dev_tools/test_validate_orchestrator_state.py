"""Tests for the split orchestrator-state validator."""

from __future__ import annotations

import json
from typing import TYPE_CHECKING, cast

import scripts.dev_tools.validate_orchestrator_state as state_validator

if TYPE_CHECKING:
    from collections.abc import Callable

# Bind targeted internal helpers through typed runtime lookup so the tests can
# cover the split-validator branches without widening the production surface.
validate_list_delegation_receipts = cast(
    "Callable[[object], list[str]]",
    vars(state_validator)["_validate_list_delegation_receipts"],
)
validate_namespaced_delegation_receipts = cast(
    "Callable[[object], list[str]]",
    vars(state_validator)["_validate_namespaced_delegation_receipts"],
)


def build_valid_orchestrator_state() -> dict[str, object]:
    """Return a minimally valid orchestrator-state payload for mutation.

    Purpose:
        Provide a reusable checkpoint payload so focused tests can mutate one
        validation branch at a time without duplicating unrelated setup.

    Args:
        None.

    Returns:
        dict[str, object]: A valid checkpoint payload.

    Raises:
        None.

    Side Effects:
        None.
    """

    return {
        "objective": "obj",
        "change_budget_estimate": "large",
        "path_selected": "large",
        "promotion-type": "feature",
        "short-name": "short",
        "relativeFile": "docs/features/potential/x.md",
        "long-name": "feature-1",
        "issue-num": "1",
        "feature-folder": "docs/features/active/feature-1",
        "work-mode": "full-feature",
        "plan-path": "docs/features/active/feature-1/plan.md",
        "completed_steps": [],
        "next_step": "done",
        "last_updated": "2026-04-07T10:00:00-04:00",
        "step5_status": "not-applicable",
        "step6_status": "not-applicable",
        "step7_status": "verified",
        "step8_status": "not-applicable",
        "step9_status": "verified",
        "step10_status": "not-applicable",
        "delegation_receipts": [
            {
                "step": "7",
                "agent_name": "atomic-planner",
                "agent_id": "a1",
                "skill_source": "orchestrator-workflow",
                "started_at": "2026-04-07T09:00:00-04:00",
                "completed_at": "2026-04-07T09:05:00-04:00",
                "result_signal": "PREFLIGHT: ALL CLEAR",
                "artifact_paths": ["docs/features/active/feature-1/plan.md"],
            }
        ],
        "blocked_reason": "none",
    }


def build_namespaced_orchestrator_state() -> dict[str, object]:
    """Return a valid checkpoint payload using the promotion namespace.

    Purpose:
        Provide the additive namespace form of delegation receipts for focused
        tests that exercise the new object-based validation branches.

    Args:
        None.

    Returns:
        dict[str, object]: A valid checkpoint payload using
        `delegation_receipts.promotion.*`.

    Raises:
        None.

    Side Effects:
        None.
    """

    state = build_valid_orchestrator_state()
    state["delegation_receipts"] = {
        "promotion": {
            "potential_entry": {"path": "docs/features/potential/demo.md"},
            "issue": "https://github.com/drmoisan/drm-copilot/issues/168",
            "feature_folder": {
                "path": (
                    "docs/features/active/2026-04-29-"
                    "harden-feature-promotion-lifecycle-mcp-only-168"
                )
            },
        }
    }
    return state


def test_validate_list_delegation_receipts_rejects_non_object_entry() -> None:
    """Reject legacy receipt arrays that contain scalar items.

    Purpose:
        Cover the legacy receipt-list branch that validates each element is an
        object before checking receipt keys.

    Args:
        None.

    Returns:
        None: Assertions verify that scalar receipt entries are rejected.

    Raises:
        None.

    Side Effects:
        None.
    """

    errors = validate_list_delegation_receipts(["invalid"])

    assert errors == ["Checkpoint delegation receipt #0 must be an object."]


def test_validate_namespaced_delegation_receipts_rejects_unsupported_top_level_key(
    *_unused: object,
) -> None:
    """Reject namespaced receipt objects that use unsupported top-level keys.

    Purpose:
        Cover the branch that rejects `delegation_receipts` object keys outside
        the documented `promotion` namespace.

    Args:
        None.

    Returns:
        None: Assertions verify that unsupported top-level keys are rejected.

    Raises:
        None.

    Side Effects:
        None.
    """

    errors = validate_namespaced_delegation_receipts(
        {"promotion": {}, "unexpected": {}}
    )

    assert _unused == ()

    assert errors == [
        "Checkpoint delegation_receipts object contains unsupported key: unexpected"
    ]


def test_validate_namespaced_delegation_receipts_rejects_non_object_promotion_namespace(
    *_unused: object,
) -> None:
    """Reject non-object promotion namespaces in the additive receipt form.

    Purpose:
        Cover the branch that requires `delegation_receipts.promotion` to be an
        object namespace before nested key validation runs.

    Args:
        None.

    Returns:
        None: Assertions verify that non-object promotion values are rejected.

    Raises:
        None.

    Side Effects:
        None.
    """

    errors = validate_namespaced_delegation_receipts({"promotion": "invalid"})

    assert _unused == ()

    assert errors == [
        "Checkpoint delegation_receipts.promotion must be an object namespace."
    ]


def test_validate_orchestrator_state_text_rejects_invalid_step_status() -> None:
    """Reject checkpoints that use unsupported lifecycle step statuses.

    Purpose:
        Cover the status-validation branch that enforces the fixed set of
        allowed lifecycle state values.

    Args:
        None.

    Returns:
        None: Assertions verify that invalid step statuses are rejected.

    Raises:
        None.

    Side Effects:
        None.
    """

    state = build_valid_orchestrator_state()
    state["step8_status"] = "invalid-status"

    errors = state_validator.validate_orchestrator_state_text(json.dumps(state))

    assert any(
        "Checkpoint has invalid step8_status: invalid-status" in error
        for error in errors
    )


def test_validate_orchestrator_state_text_rejects_invalid_blocked_reason() -> None:
    """Reject checkpoints that use unsupported blocked reasons.

    Purpose:
        Cover the blocked-reason validation branch that enforces the documented
        set of allowed blocked reason values.

    Args:
        None.

    Returns:
        None: Assertions verify that invalid blocked reasons are rejected.

    Raises:
        None.

    Side Effects:
        None.
    """

    state = build_valid_orchestrator_state()
    state["blocked_reason"] = "unknown-reason"

    errors = state_validator.validate_orchestrator_state_text(json.dumps(state))

    assert any(
        "Checkpoint has invalid blocked_reason: unknown-reason" in error
        for error in errors
    )


def _test_orchestrator_state_require_complete_rejects_non_none_blocked_reason() -> None:
    """Reject complete-mode checkpoints whose blocked reason is not `none`.

    Purpose:
        Cover the completion gate branch that rejects non-`none` blocked reasons
        even when the base schema is otherwise valid.

    Args:
        None.

    Returns:
        None: Assertions verify that completion-mode validation rejects the
        checkpoint.

    Raises:
        None.

    Side Effects:
        None.
    """

    state = build_valid_orchestrator_state()
    state["blocked_reason"] = "validator_failed"

    errors = state_validator.validate_orchestrator_state_text(
        json.dumps(state), require_complete=True
    )

    assert (
        "Checkpoint completion validation failed: blocked_reason is not `none`."
        in errors
    )


globals()[
    "test_validate_orchestrator_state_text_require_complete_rejects_non_none_blocked_reason"
] = _test_orchestrator_state_require_complete_rejects_non_none_blocked_reason


def test_validate_orchestrator_state_text_rejects_malformed_json() -> None:
    """Reject malformed checkpoint JSON with the explicit parse error prefix.

    Purpose:
        Cover the JSON parse failure branch so the split validator preserves the
        caller-facing malformed-JSON error contract.

    Args:
        None.

    Returns:
        None: Assertions verify that malformed JSON returns the explicit parse
        error message.

    Raises:
        None.

    Side Effects:
        None.
    """

    errors = state_validator.validate_orchestrator_state_text('{"objective":')

    assert len(errors) == 1
    assert errors[0].startswith("Checkpoint is not valid JSON:")


def test_require_complete_rejects_pr_gate_required_route_without_pr_gate() -> None:
    """Reject completion when a pr-gate route omits PR evidence.

    Purpose:
        Cover the route-driven completion gate requiring `pr_gate` evidence for
        a route whose `requires_pr_gate` is True (the `large` route), with no
        issue-number special-casing.

    Args:
        None.

    Returns:
        None: Assertions verify that missing PR evidence is reported.

    Raises:
        None.

    Side Effects:
        None.
    """

    state = build_valid_orchestrator_state()
    # Any issue number; route is `large`, which requires the PR gate.
    state["issue-num"] = "999"
    state["blocked_reason"] = "none"

    errors = state_validator.validate_orchestrator_state_text(
        json.dumps(state), require_complete=True
    )

    assert any("pr_gate" in error for error in errors)


def test_require_complete_skips_pr_gate_for_non_pr_gate_route() -> None:
    """Do not require PR evidence for a route without `requires_pr_gate`.

    Purpose:
        Cover the route-driven completion gate returning no `pr_gate` errors for
        the `small` route, which does not opt into the PR gate.

    Args:
        None.

    Returns:
        None: Assertions verify that no `pr_gate` error is produced.

    Raises:
        None.

    Side Effects:
        None.
    """

    state = build_valid_orchestrator_state()
    state["path_selected"] = "small"
    state["issue-num"] = "123"
    state["blocked_reason"] = "none"
    # Provide ci_gate so any ci-gate errors do not mask the pr_gate assertion.
    state["ci_gate"] = {
        "conclusion": "success",
        "head_sha": "current-head-sha",
        "verified_at": "2026-06-25T07:45:00Z",
    }

    errors = state_validator.validate_orchestrator_state_text(
        json.dumps(state), require_complete=True
    )

    assert not any("pr_gate" in error for error in errors)


def test_require_complete_emits_no_issue_232_branch_error_for_any_issue() -> None:
    """Confirm no issue-232 branch-name error is produced for any issue number.

    Purpose:
        Cover the removal of the `ISSUE_232_BRANCH` head-branch check; a PR with
        an arbitrary head branch must not produce a branch-name completion error.

    Args:
        None.

    Returns:
        None: Assertions verify that no head_branch branch-name error is
        reported for an arbitrary branch.

    Raises:
        None.

    Side Effects:
        None.
    """

    state = build_valid_orchestrator_state()
    state["issue-num"] = "232"
    state["pr_gate"] = {
        "pr_number": 232,
        "pr_url": "https://github.com/drmoisan/drm-copilot/pull/232",
        "head_branch": "feature/any-arbitrary-branch",
        "head_sha": "current-head-sha",
    }
    state["ci_gate"] = {
        "conclusion": "success",
        "head_sha": "current-head-sha",
        "verified_at": "2026-06-25T07:45:00Z",
    }

    errors = state_validator.validate_orchestrator_state_text(
        json.dumps(state), require_complete=True
    )

    assert not any("head_branch" in error for error in errors)


def test_require_complete_rejects_missing_ci_gate() -> None:
    state = build_valid_orchestrator_state()
    state["pr_gate"] = {
        "pr_number": 232,
        "pr_url": "https://github.com/drmoisan/drm-copilot/pull/232",
        "head_branch": "feature/harden-orchestrate-skill-232",
        "head_sha": "current-head-sha",
    }

    errors = state_validator.validate_orchestrator_state_text(
        json.dumps(state), require_complete=True
    )

    assert any("ci_gate" in error for error in errors)


def test_require_complete_rejects_failed_ci_gate() -> None:
    state = build_valid_orchestrator_state()
    state["pr_gate"] = {
        "pr_number": 232,
        "pr_url": "https://github.com/drmoisan/drm-copilot/pull/232",
        "head_branch": "feature/harden-orchestrate-skill-232",
        "head_sha": "current-head-sha",
    }
    state["ci_gate"] = {
        "conclusion": "failure",
        "head_sha": "current-head-sha",
        "verified_at": "2026-06-25T07:45:00Z",
    }

    errors = state_validator.validate_orchestrator_state_text(
        json.dumps(state), require_complete=True
    )

    assert any("ci_gate.conclusion" in error for error in errors)


def test_require_complete_rejects_stale_ci_head_sha_for_pr_gate_route() -> None:
    """Reject completion when CI head_sha does not match PR head_sha.

    Purpose:
        Cover the preserved `ci_gate.head_sha` / `pr_gate.head_sha` match check
        for a route that requires the PR gate (the `large` route).

    Args:
        None.

    Returns:
        None: Assertions verify that the stale-head error is reported.

    Raises:
        None.

    Side Effects:
        None.
    """

    state = build_valid_orchestrator_state()
    state["pr_gate"] = {
        "pr_number": 232,
        "pr_url": "https://github.com/drmoisan/drm-copilot/pull/232",
        "head_branch": "feature/any-branch",
        "head_sha": "current-head-sha",
    }
    state["ci_gate"] = {
        "conclusion": "success",
        "head_sha": "stale-head-sha",
        "verified_at": "2026-06-25T07:45:00Z",
    }

    errors = state_validator.validate_orchestrator_state_text(
        json.dumps(state), require_complete=True
    )

    assert any(
        "ci_gate.head_sha" in error and "pr_gate.head_sha" in error for error in errors
    )


def test_strict_route_membership_rejects_unknown_route() -> None:
    """Reject an unknown route when strict_route_membership is enabled.

    Purpose:
        Cover the opt-in strict route-membership gate appending an error for a
        checkpoint that selects a fabricated route.

    Args:
        None.

    Returns:
        None: Assertions verify the unknown-route error is reported.

    Raises:
        None.

    Side Effects:
        None.
    """

    state = build_valid_orchestrator_state()
    state["path_selected"] = "direct_powershell_engineer_remediation"

    errors = state_validator.validate_orchestrator_state_text(
        json.dumps(state), strict_route_membership=True
    )

    assert any(
        "is not a routing-matrix route: direct_powershell_engineer_remediation" in error
        for error in errors
    )


def test_non_strict_route_membership_allows_missing_route_id() -> None:
    """Do not reject a checkpoint missing route_id/path_selected by default.

    Purpose:
        Cover the backward-compatibility default where route-membership errors
        are not appended for a checkpoint that selects no route.

    Args:
        None.

    Returns:
        None: Assertions verify no route-membership error is reported.

    Raises:
        None.

    Side Effects:
        None.
    """

    state = build_valid_orchestrator_state()
    del state["path_selected"]

    errors = state_validator.validate_orchestrator_state_text(json.dumps(state))

    assert not any("must select a route" in error for error in errors)
    assert not any("routing-matrix route" in error for error in errors)


def _build_complete_small_state() -> dict[str, object]:
    """Return a completion-safe small-route checkpoint for mutation.

    Purpose:
        Provide a small-route checkpoint that satisfies the routing-contract and
        phase-completeness checks so focused tests can mutate a single branch.

    Args:
        None.

    Returns:
        dict[str, object]: A completion-safe small-route checkpoint payload.

    Raises:
        None.

    Side Effects:
        None.
    """

    from scripts.dev_tools._orchestrator_state_routing import load_routing_matrix

    matrix = load_routing_matrix()
    small = cast(
        "dict[str, object]", cast("dict[str, object]", matrix["routes"])["small"]
    )
    required_agents = cast("list[str]", small["required_agents"])
    required_skills = cast("list[str]", small["required_skills"])
    required_mcp_tools = cast("list[str]", small["required_mcp_tools"])
    return {
        "objective": "obj",
        "change_budget_estimate": "small",
        "route_id": "small",
        "path_selected": "small",
        "promotion-type": "feature",
        "short-name": "short",
        "relativeFile": "docs/features/potential/x.md",
        "long-name": "feature-1",
        "issue-num": "1",
        "feature-folder": "docs/features/active/feature-1",
        "work-mode": "minor-audit",
        "plan-path": "docs/features/active/feature-1/plan.md",
        "completed_steps": ["S3_promotion", "S4_atomic_planning"],
        "next_step": "done",
        "last_updated": "2026-04-07T10:00:00-04:00",
        "step5_status": "not-applicable",
        "step6_status": "not-applicable",
        "step7_status": "verified",
        "step8_status": "verified",
        "step9_status": "verified",
        "step10_status": "not-applicable",
        "required_agents": required_agents,
        "required_skills": required_skills,
        "required_mcp_tools": required_mcp_tools,
        "delegation_receipts": [
            {
                "step": f"handoff-{index}",
                "agent_name": agent,
                "agent_id": f"{agent}-1",
                "skill_source": "orchestrate",
                "started_at": "2026-04-07T09:00:00-04:00",
                "completed_at": "2026-04-07T09:05:00-04:00",
                "result_signal": "COMPLETE",
                "artifact_paths": [f"artifacts/orchestration/{agent}.receipt.json"],
            }
            for index, agent in enumerate(required_agents, start=1)
        ],
        "skill_receipts": [
            {
                "skill": skill,
                "required": True,
                "acknowledged_at_phase": "completion",
                "evidence": f"artifact:{skill}",
            }
            for skill in required_skills
        ],
        "mcp_call_receipts": [
            {"tool": tool, "ok": True, "evidence": f"mcp_call:{tool}"}
            for tool in required_mcp_tools
        ],
        "local_execution_overrides": [],
        "delegation_bypasses": [],
        "lifecycle_operations": [
            {"name": tool, "surface": "mcp"} for tool in required_mcp_tools
        ],
        "blocked_reason": "none",
    }


def test_require_complete_accepts_small_route_with_all_mandatory_phases() -> None:
    """Accept a small-route checkpoint that records all mandatory phases.

    Purpose:
        Cover the phase-completeness pass case under require_complete for the
        `small` route whose mandatory phases are both present.

    Args:
        None.

    Returns:
        None: Assertions verify no phase-completeness error is reported.

    Raises:
        None.

    Side Effects:
        None.
    """

    state = _build_complete_small_state()

    errors = state_validator.validate_orchestrator_state_text(
        json.dumps(state), require_complete=True
    )

    assert not any("mandatory phase" in error for error in errors)


def test_require_complete_rejects_small_route_missing_promotion_phase() -> None:
    """Reject a small-route checkpoint missing the S3_promotion phase.

    Purpose:
        Cover the phase-completeness fail case under require_complete when the
        `small` route omits a mandatory phase.

    Args:
        None.

    Returns:
        None: Assertions verify the missing-phase error names S3_promotion.

    Raises:
        None.

    Side Effects:
        None.
    """

    state = _build_complete_small_state()
    state["completed_steps"] = ["S4_atomic_planning"]

    errors = state_validator.validate_orchestrator_state_text(
        json.dumps(state), require_complete=True
    )

    assert any("missing mandatory phase S3_promotion" in error for error in errors)
