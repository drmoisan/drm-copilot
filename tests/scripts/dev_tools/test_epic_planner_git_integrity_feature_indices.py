"""Tests for original feature indices in epic-planner Git integrity prefixes."""

from __future__ import annotations

import pytest

from scripts.dev_tools.epic_kickoff_contract import ParsedEpicKickoff
from scripts.dev_tools.epic_planner_git_integrity import (
    ReadinessGitRepository,
    validate_planning_git_integrity,
)
from tests.scripts.dev_tools.typescript_twin_test_support import (
    literals_missing_from_twin,
)

BRANCH = "epic/sample-epic-integration"
COMMIT = "1" * 40
HASH = "a" * 40
PLAN_101 = "docs/features/active/feature-101/plan.md"
PLAN_102 = "docs/features/active/feature-102/plan.md"
INDEX_ZERO_COMMIT_ERROR = (
    "Epic planner checkpoint features[0].planning_commit must be hexadecimal."
)
INDEX_ONE_COMMIT_ERROR = (
    "Epic planner checkpoint features[1].planning_commit must be hexadecimal."
)
INDEX_TWO_COMMIT_ERROR = (
    "Epic planner checkpoint features[2].planning_commit must be hexadecimal."
)
ASSERTED_MESSAGES = (
    INDEX_ZERO_COMMIT_ERROR,
    INDEX_ONE_COMMIT_ERROR,
    INDEX_TWO_COMMIT_ERROR,
)


class GitStub(ReadinessGitRepository):
    """Git fake under which every plan is committed and unchanged."""

    def ref_exists(self, ref: str) -> bool:
        return ref == BRANCH

    def commit_exists(self, commit: str) -> bool:
        return commit == COMMIT

    def is_ancestor(self, commit: str, ref: str) -> bool:
        return commit == COMMIT and ref == BRANCH

    def last_commit(self, path: str) -> str | None:
        del path
        return COMMIT

    def committed_blob_hash(self, ref: str, path: str) -> str | None:
        del path
        return HASH if ref == COMMIT else None

    def worktree_blob_hash(self, path: str) -> str | None:
        del path
        return HASH


def _parsed() -> ParsedEpicKickoff:
    """Build a minimal parsed kickoff for Git-only tests."""

    return ParsedEpicKickoff(
        slug="sample-epic",
        invocation_slug="sample-epic",
        manifest_path="docs/features/epics/sample-epic/epic.md",
        integration_branch=BRANCH,
        features=(),
        planning_commit=None,
        plan_hashes={},
    )


def _errors(features: object, plans: list[str]) -> list[str]:
    """Validate Git integrity for the given checkpoint features and plans."""

    return validate_planning_git_integrity(
        {"integration_branch": BRANCH, "features": features},
        _parsed(),
        plans,
        GitStub(),
    )


def test_planning_commit_prefix_uses_original_index_after_non_object_entry() -> None:
    """Use the original index in the planning_commit prefix after a non-object."""

    features = [
        "not-a-feature",
        {"plan_path": PLAN_101},
        {"plan_path": PLAN_102, "planning_commit": "bad"},
    ]

    errors = _errors(features, [PLAN_101, PLAN_102])

    assert errors == [INDEX_TWO_COMMIT_ERROR]


def test_planning_commit_prefix_uses_original_index_after_planless_entry() -> None:
    """Use the original index in the planning_commit prefix after a plan-less entry."""

    features = [{"plan_path": 7}, {"plan_path": PLAN_101, "planning_commit": "bad"}]

    errors = _errors(features, [PLAN_101])

    assert errors == [INDEX_ONE_COMMIT_ERROR]


def test_planning_commit_prefix_unchanged_without_skipped_entries() -> None:
    """Keep the planning_commit prefix index unchanged without skipped entries."""

    features = [
        {"plan_path": PLAN_101},
        {"plan_path": PLAN_102, "planning_commit": "bad"},
    ]

    errors = _errors(features, [PLAN_101, PLAN_102])

    assert errors == [INDEX_ONE_COMMIT_ERROR]


def test_planning_commit_prefix_keeps_positional_pairing_without_plan_paths() -> None:
    """Keep positional pairing when no checkpoint entry carries the plan."""

    features = [{"planning_commit": "bad"}]

    errors = _errors(features, [PLAN_101])

    assert errors == [INDEX_ZERO_COMMIT_ERROR]


def test_planning_commit_prefix_matches_dot_prefixed_plan_path() -> None:
    """Pair a dot-prefixed plan_path with the plan the readiness gate derives."""

    features = [
        "not-a-feature",
        {"plan_path": PLAN_101},
        {"plan_path": f"./{PLAN_102}", "planning_commit": "bad"},
    ]

    errors = _errors(features, [PLAN_101, PLAN_102])

    assert errors == [INDEX_TWO_COMMIT_ERROR]


@pytest.mark.parametrize("features", [[], "not-a-list"], ids=["empty", "not-list"])
def test_plans_without_object_entries_report_no_feature_error(
    features: object,
) -> None:
    """Report no feature error when the checkpoint has no object entries."""

    errors = _errors(features, [PLAN_101])

    assert errors == []


def test_asserted_messages_match_typescript_twin() -> None:
    """Keep every asserted message identical to its TypeScript twin literal."""

    missing = literals_missing_from_twin(
        ASSERTED_MESSAGES,
        "lib/validate/epic-planner-git-integrity-feature-indices.test.ts",
    )

    assert missing == []
