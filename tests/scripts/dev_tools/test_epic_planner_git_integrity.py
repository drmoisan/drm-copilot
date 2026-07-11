"""Hermetic tests for epic planning Git integrity validation."""

from __future__ import annotations

from pathlib import Path
from typing import TYPE_CHECKING

from scripts.dev_tools.epic_kickoff_contract import ParsedEpicKickoff
from scripts.dev_tools.epic_planner_git_integrity import (
    GitReadinessRepository,
    ReadinessGitRepository,
    validate_committed_file,
    validate_planning_git_integrity,
)
from scripts.dev_tools.pr_context.models import CommandResult

if TYPE_CHECKING:
    from collections.abc import Sequence

BRANCH = "epic/sample-epic-integration"
COMMIT = "1" * 40
FINAL_COMMIT = "2" * 40
HASH = "a" * 40
OTHER_HASH = "b" * 40
PLAN = "docs/features/active/feature-101/plan.md"


class GitStub(ReadinessGitRepository):
    """Configurable exact-hash Git fake."""

    def __init__(self) -> None:
        self.ref = True
        self.commits = {COMMIT, FINAL_COMMIT}
        self.ancestors = {(COMMIT, BRANCH), (FINAL_COMMIT, BRANCH)}
        self.last: str | None = COMMIT
        self.committed = {
            (COMMIT, PLAN): HASH,
            (FINAL_COMMIT, PLAN): HASH,
            (BRANCH, "file.md"): HASH,
        }
        self.worktree = {PLAN: HASH, "file.md": HASH}

    def ref_exists(self, ref: str) -> bool:
        return self.ref and ref == BRANCH

    def commit_exists(self, commit: str) -> bool:
        return commit in self.commits

    def is_ancestor(self, commit: str, ref: str) -> bool:
        return (commit, ref) in self.ancestors

    def last_commit(self, path: str) -> str | None:
        return self.last if path == PLAN else None

    def committed_blob_hash(self, ref: str, path: str) -> str | None:
        return self.committed.get((ref, path))

    def worktree_blob_hash(self, path: str) -> str | None:
        return self.worktree.get(path)


def _parsed(
    *,
    planning_commit: str | None = None,
    plan_hashes: dict[str, str] | None = None,
) -> ParsedEpicKickoff:
    """Build a minimal parsed kickoff for Git-only tests."""

    return ParsedEpicKickoff(
        slug="sample-epic",
        invocation_slug="sample-epic",
        manifest_path="docs/features/epics/sample-epic/epic.md",
        integration_branch=BRANCH,
        features=(),
        planning_commit=planning_commit,
        plan_hashes=plan_hashes or {},
    )


def _state(**overrides: object) -> dict[str, object]:
    """Build a minimal state for Git-only tests."""

    return {"integration_branch": BRANCH, "features": [{}], **overrides}


def test_committed_file_reports_each_hash_failure() -> None:
    """Report missing, unhashable, drifting, and valid committed files."""

    git = GitStub()

    assert (
        "requires file committed"
        in validate_committed_file(git, BRANCH, "missing.md", label="file")[0]
    )
    git.committed[(BRANCH, "missing-worktree.md")] = HASH
    assert (
        "could not hash worktree"
        in validate_committed_file(git, BRANCH, "missing-worktree.md", label="file")[0]
    )
    git.committed[(BRANCH, "drift.md")] = HASH
    git.worktree["drift.md"] = OTHER_HASH
    assert (
        "worktree drift"
        in validate_committed_file(git, BRANCH, "drift.md", label="file")[0]
    )
    assert validate_committed_file(git, BRANCH, "file.md", label="file") == []


def test_git_integrity_rejects_branch_and_derived_commit_failures() -> None:
    """Reject a missing branch, missing commit derivation, and ancestry drift."""

    git = GitStub()
    git.ref = False
    assert (
        "branch does not exist"
        in validate_planning_git_integrity(_state(), _parsed(), [PLAN], git)[0]
    )
    git.ref = True
    git.last = None
    assert (
        "could not derive"
        in validate_planning_git_integrity(_state(), _parsed(), [PLAN], git)[0]
    )
    git.last = COMMIT
    git.ancestors.remove((COMMIT, BRANCH))
    assert (
        "is not on"
        in validate_planning_git_integrity(_state(), _parsed(), [PLAN], git)[0]
    )


def test_optional_integrity_fields_are_fully_validated() -> None:
    """Validate optional object, commit, and hash declarations."""

    git = GitStub()
    errors = validate_planning_git_integrity(
        _state(
            integrity="invalid",
            planning_commit="not-a-commit",
            plan_hashes="invalid",
        ),
        _parsed(planning_commit=FINAL_COMMIT),
        [PLAN],
        git,
    )
    joined = "\n".join(errors)
    assert "integrity must be an object" in joined
    assert "planning_commit values" in joined
    assert "plan_hashes must be an object" in joined
    assert "must match" in "\n".join(
        validate_planning_git_integrity(
            _state(planning_commit=COMMIT),
            _parsed(planning_commit=FINAL_COMMIT),
            [PLAN],
            git,
        )
    )

    errors = validate_planning_git_integrity(
        _state(
            integrity={
                "planning_commit": FINAL_COMMIT,
                "plan_hashes": {PLAN: OTHER_HASH, "unknown.md": HASH, "bad": 1},
            }
        ),
        _parsed(plan_hashes={PLAN: HASH}),
        [PLAN],
        git,
    )
    joined = "\n".join(errors)
    assert "declarations disagree" in joined
    assert "entries must map paths" in joined
    assert "does not match committed bytes" in joined
    assert "unknown planner path" in joined


def test_optional_commits_and_plan_blob_failures_are_blocking() -> None:
    """Reject nonexistent or non-ancestor commits and unavailable plan blobs."""

    git = GitStub()
    git.commits.remove(FINAL_COMMIT)
    errors = validate_planning_git_integrity(
        _state(planning_commit=FINAL_COMMIT), _parsed(), [PLAN], git
    )
    assert "planning commit does not exist" in "\n".join(errors)

    git.commits.add(FINAL_COMMIT)
    git.ancestors.remove((FINAL_COMMIT, BRANCH))
    errors = validate_planning_git_integrity(
        _state(planning_commit=FINAL_COMMIT), _parsed(), [PLAN], git
    )
    assert "not an ancestor" in "\n".join(errors)

    git.ancestors.add((FINAL_COMMIT, BRANCH))
    git.worktree.pop(PLAN)
    assert "could not hash worktree atomic plan" in "\n".join(
        validate_planning_git_integrity(_state(), _parsed(), [PLAN], git)
    )
    git.worktree[PLAN] = HASH
    git.committed.pop((FINAL_COMMIT, PLAN))
    errors = validate_planning_git_integrity(
        _state(features=[{"planning_commit": FINAL_COMMIT}]),
        _parsed(),
        [PLAN],
        git,
    )
    assert "does not contain" in "\n".join(errors)


class ScriptRunner:
    """Return seeded command outcomes for every Git adapter method."""

    def run(
        self,
        args: Sequence[str],
        *,
        cwd: Path | None = None,
        allow_error: bool = False,
    ) -> CommandResult:
        del cwd, allow_error
        command = list(args[1:])
        if command[0] in {"rev-parse", "log", "hash-object"}:
            return CommandResult(HASH, "", 0)
        return CommandResult("", "", 0)


def test_git_adapter_routes_all_queries_through_injected_runner() -> None:
    """Cover the focused Git adapter without filesystem or subprocess use."""

    repository = GitReadinessRepository(Path("C:/workspace"), ScriptRunner())

    assert repository.ref_exists(BRANCH)
    assert repository.commit_exists(COMMIT)
    assert repository.is_ancestor(COMMIT, BRANCH)
    assert repository.last_commit(PLAN) == HASH
    assert repository.committed_blob_hash(COMMIT, PLAN) == HASH
    assert repository.worktree_blob_hash(PLAN) == HASH
