"""Tests for the epic-orchestrator checkpoint validator."""

from __future__ import annotations

import json

from scripts.dev_tools.validate_epic_orchestrator_state import (
    validate_epic_orchestrator_state_text,
)


def build_valid_epic_state() -> dict[str, object]:
    """Return a minimally valid, wave-barrier-clean epic checkpoint payload."""

    return {
        "objective": "deliver epic-orchestrate-275",
        "route_id": "epic",
        "epic_feature_folder": "epic-orchestrate-275",
        "epic_manifest_path": "docs/features/epics/epic-orchestrate-275/epic-plan.md",
        "integration_branch": "epic/epic-orchestrate-275-integration",
        "completed_steps": ["epic_manifest_parsed"],
        "next_step": "wave_1_launch",
        "last_updated": "2026-07-02T20-00",
        "current_wave": 1,
        "waves": [
            {"wave_number": 0, "feature_folders": ["2026-07-02-child-a-300"]},
            {"wave_number": 1, "feature_folders": ["2026-07-02-child-b-301"]},
        ],
        "features": [
            {
                "feature_folder": "2026-07-02-child-a-300",
                "issue_num": 300,
                "depends_on": [],
                "wave_number": 0,
                "worktree_path": "/repo/worktrees/child-a",
                "merge_status": "merged",
                "merge_confirmed_at": "2026-07-02T18-00",
                "worktree_created_at": "2026-07-02T17-00",
            },
            {
                "feature_folder": "2026-07-02-child-b-301",
                "issue_num": 301,
                "depends_on": ["2026-07-02-child-a-300"],
                "wave_number": 1,
                "worktree_path": "/repo/worktrees/child-b",
                "merge_status": "not_started",
                "worktree_created_at": "2026-07-02T19-00",
            },
        ],
    }


def test_validate_rejects_json_root_that_is_not_an_object() -> None:
    """Reject epic checkpoints whose JSON root is not an object."""

    errors = validate_epic_orchestrator_state_text("[]")

    assert errors == ["Epic checkpoint root must be a JSON object."]


def test_validate_rejects_invalid_json() -> None:
    """Reject epic checkpoints that are not valid JSON."""

    errors = validate_epic_orchestrator_state_text("{ broken")

    assert any("not valid JSON" in error for error in errors)


def test_validate_accepts_a_wave_barrier_clean_valid_checkpoint() -> None:
    """Allow a well-formed, wave-barrier-clean checkpoint with zero errors."""

    errors = validate_epic_orchestrator_state_text(json.dumps(build_valid_epic_state()))

    assert errors == []


def test_validate_reports_missing_baseline_fields() -> None:
    """Reject a checkpoint missing the four baseline fields."""

    state = build_valid_epic_state()
    del state["objective"]
    del state["completed_steps"]
    del state["next_step"]
    del state["last_updated"]

    errors = validate_epic_orchestrator_state_text(json.dumps(state))

    assert any("missing required key: objective" in error for error in errors)
    assert any("missing required key: completed_steps" in error for error in errors)
    assert any("missing required key: next_step" in error for error in errors)
    assert any("missing required key: last_updated" in error for error in errors)


def test_validate_reports_missing_route_id() -> None:
    """Reject a checkpoint missing route_id."""

    state = build_valid_epic_state()
    del state["route_id"]

    errors = validate_epic_orchestrator_state_text(json.dumps(state))

    assert any("missing required key: route_id" in error for error in errors)


def test_validate_reports_missing_epic_feature_folder() -> None:
    """Reject a checkpoint missing epic_feature_folder."""

    state = build_valid_epic_state()
    del state["epic_feature_folder"]

    errors = validate_epic_orchestrator_state_text(json.dumps(state))

    assert any("missing required key: epic_feature_folder" in error for error in errors)


def test_validate_reports_missing_integration_branch() -> None:
    """Reject a checkpoint missing integration_branch."""

    state = build_valid_epic_state()
    del state["integration_branch"]

    errors = validate_epic_orchestrator_state_text(json.dumps(state))

    assert any("missing required key: integration_branch" in error for error in errors)


def test_validate_reports_missing_waves() -> None:
    """Reject a checkpoint missing waves[]."""

    state = build_valid_epic_state()
    del state["waves"]

    errors = validate_epic_orchestrator_state_text(json.dumps(state))

    assert any("missing required key: waves" in error for error in errors)


def test_validate_reports_missing_features() -> None:
    """Reject a checkpoint missing features[]."""

    state = build_valid_epic_state()
    del state["features"]

    errors = validate_epic_orchestrator_state_text(json.dumps(state))

    assert any("missing required key: features" in error for error in errors)


def test_validate_rejects_wrong_route_id() -> None:
    """Reject a checkpoint whose route_id is not 'epic'."""

    state = build_valid_epic_state()
    state["route_id"] = "large"

    errors = validate_epic_orchestrator_state_text(json.dumps(state))

    assert any("route_id must be 'epic'" in error for error in errors)


def test_validate_rejects_duplicate_feature_folder() -> None:
    """Reject a checkpoint with a duplicated features[].feature_folder."""

    state = build_valid_epic_state()
    duplicate = dict(state["features"][0])  # type: ignore[index]
    state["features"].append(duplicate)  # type: ignore[union-attr]

    errors = validate_epic_orchestrator_state_text(json.dumps(state))

    assert any(
        "duplicate features[].feature_folder: 2026-07-02-child-a-300" in error
        for error in errors
    )


def test_validate_rejects_unresolved_depends_on_reference() -> None:
    """Reject a depends_on entry that does not resolve to a defined feature_folder."""

    state = build_valid_epic_state()
    state["features"][1]["depends_on"] = ["does-not-exist"]  # type: ignore[index]

    errors = validate_epic_orchestrator_state_text(json.dumps(state))

    assert any("unresolved feature_folder" in error for error in errors)


def test_validate_rejects_dependency_cycle() -> None:
    """Reject a manifest whose depends_on graph contains a cycle."""

    state = build_valid_epic_state()
    state["features"][0]["depends_on"] = [  # type: ignore[index]
        "2026-07-02-child-b-301"
    ]
    state["features"][1]["depends_on"] = [  # type: ignore[index]
        "2026-07-02-child-a-300"
    ]

    errors = validate_epic_orchestrator_state_text(json.dumps(state))

    assert any("cycle" in error for error in errors)


def test_validate_accepts_all_valid_merge_status_values() -> None:
    """Allow every documented merge_status enum value."""

    valid_statuses = (
        "not_started",
        "worktree_created",
        "pr_open",
        "ci_green",
        "merge_conflict",
        "blocked_conflict_loop_limit",
        "merged",
        "worktree_removed",
    )
    for status in valid_statuses:
        state = build_valid_epic_state()
        state["features"][1]["merge_status"] = status  # type: ignore[index]
        errors = validate_epic_orchestrator_state_text(json.dumps(state))
        assert not any("invalid merge_status" in error for error in errors)


def test_validate_rejects_invalid_merge_status_value() -> None:
    """Reject a merge_status value outside the documented enum."""

    state = build_valid_epic_state()
    state["features"][1]["merge_status"] = "unknown_status"  # type: ignore[index]

    errors = validate_epic_orchestrator_state_text(json.dumps(state))

    assert any("invalid merge_status" in error for error in errors)


def test_validate_wave_barrier_ordering_passes_when_dependency_merged_first() -> None:
    """Allow a checkpoint where every dependency merged before the dependent started."""

    errors = validate_epic_orchestrator_state_text(json.dumps(build_valid_epic_state()))

    assert not any("EPIC_WAVE_BARRIER_VIOLATION" in error for error in errors)


def test_validate_wave_barrier_ordering_rejects_unmerged_dependency() -> None:
    """Reject a checkpoint where a dependency has not yet merged."""

    state = build_valid_epic_state()
    state["features"][0]["merge_status"] = "pr_open"  # type: ignore[index]

    errors = validate_epic_orchestrator_state_text(json.dumps(state))

    assert any(
        "EPIC_WAVE_BARRIER_VIOLATION: 2026-07-02-child-b-301 started before "
        "dependency 2026-07-02-child-a-300 merged" in error
        for error in errors
    )


def test_validate_wave_barrier_ordering_rejects_out_of_order_timestamps() -> None:
    """Reject a checkpoint where the dependency's merge_confirmed_at is later than
    the dependent's worktree_created_at, even though merge_status is merged."""

    state = build_valid_epic_state()
    state["features"][0]["merge_confirmed_at"] = "2026-07-02T20-00"  # type: ignore[index]

    errors = validate_epic_orchestrator_state_text(json.dumps(state))

    assert any("EPIC_WAVE_BARRIER_VIOLATION" in error for error in errors)


def test_validate_rejects_waves_wave_number_inconsistency() -> None:
    """Reject a checkpoint where waves[].feature_folders disagrees with wave_number."""

    state = build_valid_epic_state()
    state["features"][1]["wave_number"] = 2  # type: ignore[index]

    errors = validate_epic_orchestrator_state_text(json.dumps(state))

    assert any(
        "waves[] lists '2026-07-02-child-b-301' under wave 1 but its own "
        "wave_number is 2" in error
        for error in errors
    )


def test_validate_require_complete_rejects_unmerged_feature() -> None:
    """Reject require_complete=True when a feature is not merged/worktree_removed."""

    state = build_valid_epic_state()
    state["epic_merge_pr"] = {"merge_commit_sha": "abc123"}

    errors = validate_epic_orchestrator_state_text(
        json.dumps(state), require_complete=True
    )

    assert any(
        "feature '2026-07-02-child-b-301' merge_status is not "
        "merged/worktree_removed" in error
        for error in errors
    )


def test_validate_require_complete_rejects_missing_merge_commit_sha() -> None:
    """Reject require_complete=True when epic_merge_pr.merge_commit_sha is absent."""

    state = build_valid_epic_state()
    state["features"][1]["merge_status"] = "merged"  # type: ignore[index]
    state["features"][1]["merge_confirmed_at"] = "2026-07-02T18-30"  # type: ignore[index]

    errors = validate_epic_orchestrator_state_text(
        json.dumps(state), require_complete=True
    )

    assert any(
        "epic_merge_pr.merge_commit_sha is missing or empty" in error
        for error in errors
    )


def test_validate_require_complete_accepts_a_fully_complete_checkpoint() -> None:
    """Allow require_complete=True when every feature merged and PR recorded."""

    state = build_valid_epic_state()
    state["features"][1]["merge_status"] = "worktree_removed"  # type: ignore[index]
    state["features"][1]["merge_confirmed_at"] = "2026-07-02T18-30"  # type: ignore[index]
    state["epic_merge_pr"] = {"merge_commit_sha": "abc123def456"}

    errors = validate_epic_orchestrator_state_text(
        json.dumps(state), require_complete=True
    )

    assert errors == []


def test_validate_ignores_require_complete_by_default() -> None:
    """Confirm require_complete defaults to False (backward-compatible)."""

    errors = validate_epic_orchestrator_state_text(json.dumps(build_valid_epic_state()))

    assert errors == []


# --- issue_num-keyed DAG resolution (added alongside legacy fixtures) ---


def test_validate_accepts_dependency_expressed_by_issue_num() -> None:
    """Resolve a depends_on entry given as a stable issue_num, not a folder name."""

    # Arrange: child-b depends on child-a via its issue_num (300) instead of the
    # folder basename; the union index must resolve the reference.
    state = build_valid_epic_state()
    state["features"][1]["depends_on"] = [300]  # type: ignore[index]

    # Act
    errors = validate_epic_orchestrator_state_text(json.dumps(state))

    # Assert
    assert errors == []


def test_validate_rejects_unresolved_issue_num_reference() -> None:
    """Report an issue_num depends_on entry that matches no defined feature."""

    # Arrange: 999 is not a defined issue_num.
    state = build_valid_epic_state()
    state["features"][1]["depends_on"] = [999]  # type: ignore[index]

    # Act
    errors = validate_epic_orchestrator_state_text(json.dumps(state))

    # Assert
    assert (
        "Epic checkpoint feature '2026-07-02-child-b-301' depends_on unresolved "
        "feature_folder: 999" in errors
    )


# --- feature_folder hint resolving into active/ or completed/ ---


def test_validate_accepts_completed_lifecycle_hint_dependency() -> None:
    """Resolve a depends_on hint that points into completed/ to its basename."""

    # Arrange: child-b depends on child-a expressed as a completed/ lifecycle
    # path; stripping the prefix must resolve it to the defined feature.
    state = build_valid_epic_state()
    state["features"][1]["depends_on"] = [  # type: ignore[index]
        "docs/features/completed/2026-07-02-child-a-300"
    ]

    # Act
    errors = validate_epic_orchestrator_state_text(json.dumps(state))

    # Assert
    assert errors == []


def test_validate_accepts_active_lifecycle_hint_dependency() -> None:
    """Resolve a depends_on hint that points into active/ to its basename."""

    # Arrange
    state = build_valid_epic_state()
    state["features"][1]["depends_on"] = [  # type: ignore[index]
        "active/2026-07-02-child-a-300"
    ]

    # Act
    errors = validate_epic_orchestrator_state_text(json.dumps(state))

    # Assert
    assert errors == []


# --- presence-gated intent-block validation ---


def _state_with_intent(intent: object) -> dict[str, object]:
    """Return a valid epic checkpoint carrying the supplied intent value."""

    state = build_valid_epic_state()
    state["intent"] = intent
    return state


def test_validate_accepts_a_valid_intent_block() -> None:
    """Allow a well-formed intent block with all fields present."""

    state = _state_with_intent(
        {
            "epic_type": "business",
            "business_outcome_hypothesis": "reduce store lockups by 90%",
            "leading_indicators": ["lockup rate", "retry rate"],
            "nfrs": ["p99 < 200ms"],
        }
    )

    errors = validate_epic_orchestrator_state_text(json.dumps(state))

    assert errors == []


def test_validate_absent_intent_block_adds_no_errors() -> None:
    """Confirm a checkpoint without an intent key validates byte-identically."""

    errors = validate_epic_orchestrator_state_text(json.dumps(build_valid_epic_state()))

    assert errors == []


def test_validate_rejects_non_object_intent() -> None:
    """Reject an intent value that is not an object."""

    errors = validate_epic_orchestrator_state_text(
        json.dumps(_state_with_intent("not-an-object"))
    )

    assert errors == ["Epic checkpoint intent must be an object."]


def test_validate_rejects_bad_epic_type() -> None:
    """Reject an epic_type outside the business/enabler enum."""

    errors = validate_epic_orchestrator_state_text(
        json.dumps(
            _state_with_intent(
                {
                    "epic_type": "marketing",
                    "business_outcome_hypothesis": "some outcome",
                }
            )
        )
    )

    assert (
        "Epic checkpoint intent.epic_type must be 'business' or 'enabler', "
        "found: 'marketing'" in errors
    )


def test_validate_rejects_empty_business_outcome_hypothesis() -> None:
    """Reject a whitespace-only business_outcome_hypothesis."""

    errors = validate_epic_orchestrator_state_text(
        json.dumps(
            _state_with_intent(
                {
                    "epic_type": "enabler",
                    "business_outcome_hypothesis": "   ",
                }
            )
        )
    )

    assert (
        "Epic checkpoint intent.business_outcome_hypothesis must be a "
        "non-empty string." in errors
    )


def test_validate_rejects_non_list_leading_indicators() -> None:
    """Reject a leading_indicators value that is not a list."""

    errors = validate_epic_orchestrator_state_text(
        json.dumps(
            _state_with_intent(
                {
                    "epic_type": "business",
                    "business_outcome_hypothesis": "some outcome",
                    "leading_indicators": "not-a-list",
                }
            )
        )
    )

    assert (
        "Epic checkpoint intent.leading_indicators must be a list of strings." in errors
    )


def test_validate_rejects_non_string_element_in_nfrs() -> None:
    """Reject an nfrs list whose element is not a string."""

    errors = validate_epic_orchestrator_state_text(
        json.dumps(
            _state_with_intent(
                {
                    "epic_type": "business",
                    "business_outcome_hypothesis": "some outcome",
                    "nfrs": ["ok", 5],
                }
            )
        )
    )

    assert "Epic checkpoint intent.nfrs must be a list of strings." in errors
