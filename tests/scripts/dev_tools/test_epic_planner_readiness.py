"""Hermetic tests for epic kickoff and repository readiness integrity."""

from __future__ import annotations

import json
from pathlib import Path, PurePosixPath
from typing import TYPE_CHECKING, Any

from scripts.dev_tools.epic_planner_git_integrity import GitReadinessRepository
from scripts.dev_tools.epic_planner_readiness import (
    EpicReadinessContext,
    validate_epic_readiness_integrity,
)
from scripts.dev_tools.pr_context.models import CommandResult
from scripts.dev_tools.resolve_codex_deployment import resolve_codex_deployment
from scripts.dev_tools.resolve_codex_topology import resolve_codex_topology
from scripts.dev_tools.validate_epic_planner_state import (
    validate_epic_planner_state_text,
)
from tests.scripts.dev_tools.epic_planner_launch_evidence_test_support import (
    add_launch_evidence,
)

if TYPE_CHECKING:
    from collections.abc import Sequence

ROOT = Path("C:/workspace")
STATE_PATH = ROOT / "artifacts/orchestration/epic-planner-state.json"
BRANCH = "epic/sample-epic-integration"
COMMIT_ONE = "1" * 40
COMMIT_TWO = "2" * 40
PLAN_ONE_HASH = "a" * 40
PLAN_TWO_HASH = "b" * 40
KICKOFF_HASH = "c" * 40
MANIFEST_HASH = "d" * 40


def _key(path: Path) -> str:
    """Normalize test paths to the production POSIX convention."""

    return str(path).replace("\\", "/")


class MemoryFileSystem:
    """In-memory filesystem that supports the readiness read/glob surface."""

    def __init__(self, files: dict[str, str], directories: set[str]) -> None:
        self.files = files
        self.directories = directories

    def is_file(self, path: Path) -> bool:
        return _key(path) in self.files

    def is_dir(self, path: Path) -> bool:
        return _key(path) in self.directories

    def read_text(self, path: Path) -> str:
        return self.files[_key(path)]

    def read_bytes(self, path: Path) -> bytes:
        return self.files[_key(path)].encode("utf-8")

    def glob(self, directory: Path, pattern: str) -> list[Path]:
        base = PurePosixPath(_key(directory))
        matches: list[Path] = []
        for value in self.files:
            candidate = PurePosixPath(value)
            try:
                relative = candidate.relative_to(base)
            except ValueError:
                continue
            if relative.match(pattern):
                matches.append(Path(value))
        return sorted(matches)


class MemoryGitRepository:
    """Configurable Git provenance fake with exact blob IDs."""

    def __init__(self) -> None:
        self.refs = {BRANCH}
        self.commits = {COMMIT_ONE, COMMIT_TWO}
        self.ancestors = {(COMMIT_ONE, BRANCH), (COMMIT_TWO, BRANCH)}
        self.last_commits = {
            "docs/features/active/feature-101/plan.md": COMMIT_ONE,
            "docs/features/completed/feature-102/plan.md": COMMIT_TWO,
        }
        self.committed_hashes = {
            (COMMIT_ONE, "docs/features/active/feature-101/plan.md"): PLAN_ONE_HASH,
            (COMMIT_TWO, "docs/features/completed/feature-102/plan.md"): PLAN_TWO_HASH,
            (BRANCH, "docs/features/epics/sample-epic/epic-kickoff.md"): KICKOFF_HASH,
            (BRANCH, "docs/features/epics/sample-epic/epic.md"): MANIFEST_HASH,
        }
        self.worktree_hashes = {
            "docs/features/active/feature-101/plan.md": PLAN_ONE_HASH,
            "docs/features/completed/feature-102/plan.md": PLAN_TWO_HASH,
            "docs/features/epics/sample-epic/epic-kickoff.md": KICKOFF_HASH,
            "docs/features/epics/sample-epic/epic.md": MANIFEST_HASH,
        }

    def ref_exists(self, ref: str) -> bool:
        return ref in self.refs

    def commit_exists(self, commit: str) -> bool:
        return commit in self.commits

    def is_ancestor(self, commit: str, ref: str) -> bool:
        return (commit, ref) in self.ancestors

    def last_commit(self, path: str) -> str | None:
        return self.last_commits.get(path)

    def committed_blob_hash(self, ref: str, path: str) -> str | None:
        return self.committed_hashes.get((ref, path))

    def worktree_blob_hash(self, path: str) -> str | None:
        return self.worktree_hashes.get(path)


def _feature(issue_num: int, folder: str, wave: int) -> dict[str, Any]:
    """Build one fully prepared feature record."""

    model = dict(
        resolve_codex_deployment("orchestrator", "C3", "epic_preparation_child", "C3")
    )
    delegation_id = f"prepare-{issue_num}"
    launch_root = "artifacts/orchestration/epic-child-launches/preparation"
    model["phase"] = f"prepare-{issue_num}"
    model["delegation_id"] = delegation_id
    topology = dict(resolve_codex_topology(["python"], 1, 1, "epic_preparation_child"))
    topology["phase"] = f"prepare-{issue_num}"
    return {
        "issue_num": issue_num,
        "feature_folder": folder,
        "depends_on": [] if wave == 0 else [101],
        "wave": wave,
        "complexity_band": "C3",
        "preparation_status": "prepared",
        "research_path": f"artifacts/research/feature-{issue_num}.md",
        "plan_path": f"{folder}/plan.md",
        "preflight_status": "PREFLIGHT: ALL CLEAR",
        "branch_name": f"feature/feature-{issue_num}",
        "worktree_path": f"/repo/worktrees/feature-{issue_num}",
        "delegation_receipt": {
            "delegation_id": delegation_id,
            "feature_folder": folder,
            "issue_num": issue_num,
            "agent_name": model["deployment_agent"],
        },
        "model_routing_receipt": model,
        "launch_receipt_path": f"{launch_root}/feature-{issue_num}.receipt.json",
        "launch_status_path": f"{launch_root}/wave.preparation.status.json",
        "topology_receipt": topology,
    }


def _state() -> dict[str, Any]:
    """Build a structurally and repository-ready planner checkpoint."""

    topology = dict(
        resolve_codex_topology([], 0, 0, "standalone", root_persona="epic-planner")
    )
    topology["phase"] = "epic-planning"
    return {
        "objective": "prepare two features",
        "epic_feature_folder": "sample-epic",
        "epic_manifest_path": "docs/features/epics/sample-epic/epic.md",
        "integration_branch": BRANCH,
        "max_parallel_features": 4,
        "epic_worthiness": {"verdict": "epic", "rationale": "two features"},
        "features": [
            _feature(101, "docs/features/active/feature-101", 0),
            _feature(102, "docs/features/completed/feature-102", 1),
        ],
        "kickoff_prompt_path": "artifacts/orchestration/epic-kickoff-sample-epic.md",
        "completed_steps": ["decomposition", "preparation", "fan-in"],
        "next_step": "EPIC_EXECUTION_READY",
        "last_updated": "2026-07-10T10:00:00Z",
        "topology_receipt": topology,
    }


def _kickoff(*, plan_two: str = "docs/features/completed/feature-102/plan.md") -> str:
    """Render the canonical kickoff for the fixture state."""

    resume_line = (
        "Every child resumes at atomic execution from its committed plan-path; "
        "do not repeat planning or preflight."
    )
    row_one = (
        "| 101 | docs/features/active/feature-101 | 0 | C3 | "
        "docs/features/active/feature-101/plan.md |"
    )
    return f"""# Epic Kickoff: sample-epic

Planned by epic-planner.

## Invocation Prompt

Run `/epic-run sample-epic` to execute this epic.

Use the epic-orchestrator subagent to execute the prepared epic at
docs/features/epics/sample-epic/epic.md. Reuse epic/sample-epic-integration.
{resume_line}

## Feature Summary

| issue_num | feature_folder | wave | complexity | plan-path |
| --- | --- | --- | --- | --- |
{row_one}
| 102 | docs/features/completed/feature-102 | 1 | C3 | {plan_two} |
"""


def _fixture() -> tuple[dict[str, Any], str, EpicReadinessContext, MemoryGitRepository]:
    """Create a complete in-memory repository fixture."""

    state = _state()
    state_text = json.dumps(state)
    kickoff = _kickoff()
    files = {
        _key(STATE_PATH): state_text,
        "C:/workspace/docs/features/epics/sample-epic/epic.md": "# Epic",
        "C:/workspace/docs/features/epics/sample-epic/epic-kickoff.md": kickoff,
        "C:/workspace/artifacts/orchestration/epic-kickoff-sample-epic.md": kickoff,
    }
    directories: set[str] = set()
    for folder in (
        "docs/features/active/feature-101",
        "docs/features/completed/feature-102",
    ):
        directories.add(f"C:/workspace/{folder}")
        files[f"C:/workspace/{folder}/issue.md"] = "# Issue"
        files[f"C:/workspace/{folder}/spec.md"] = "# Specification"
        files[f"C:/workspace/{folder}/user-story.md"] = "# User Story"
        files[f"C:/workspace/{folder}/research.md"] = "# Research"
        files[f"C:/workspace/{folder}/plan.md"] = "# Plan"
        files[f"C:/workspace/{folder}/evidence/preflight.md"] = "PREFLIGHT: ALL CLEAR"
    files["C:/workspace/artifacts/research/feature-101.md"] = "# Research"
    files["C:/workspace/artifacts/research/feature-102.md"] = "# Research"
    add_launch_evidence(files, state)
    git = MemoryGitRepository()
    context = EpicReadinessContext(
        workspace_root=ROOT,
        artifact_path=STATE_PATH,
        file_system=MemoryFileSystem(files, directories),
        git=git,
    )
    return state, state_text, context, git


def test_repository_ready_checkpoint_passes_without_optional_hashes() -> None:
    """Derive planning commits and exact blob hashes from Git for baseline kickoffs."""

    _, state_text, context, _ = _fixture()

    errors = validate_epic_planner_state_text(
        state_text,
        require_ready_for_execution=True,
        readiness_context=context,
    )

    assert errors == []


def test_readiness_requires_feature_documents_research_and_preflight_evidence() -> None:
    """Reject a prepared status when its repository evidence is absent."""

    _, state_text, context, _ = _fixture()
    file_system = context.file_system
    assert isinstance(file_system, MemoryFileSystem)
    del file_system.files["C:/workspace/docs/features/active/feature-101/issue.md"]
    del file_system.files["C:/workspace/docs/features/active/feature-101/spec.md"]
    del file_system.files["C:/workspace/artifacts/research/feature-101.md"]
    del file_system.files[
        "C:/workspace/docs/features/active/feature-101/evidence/preflight.md"
    ]

    errors = validate_epic_planner_state_text(
        state_text, require_ready_for_execution=True, readiness_context=context
    )

    assert any("issue.md" in error for error in errors)
    assert any("spec.md" in error for error in errors)
    assert any("research evidence" in error for error in errors)
    assert any("preflight evidence" in error for error in errors)


def test_readiness_accepts_feature_local_research_path() -> None:
    """Preserve support for research evidence stored within a feature folder."""

    state, _, context, _ = _fixture()
    state["features"][0][
        "research_path"
    ] = "docs/features/active/feature-101/research.md"
    state_text = json.dumps(state)
    file_system = context.file_system
    assert isinstance(file_system, MemoryFileSystem)
    file_system.files[_key(STATE_PATH)] = state_text

    assert (
        validate_epic_planner_state_text(
            state_text, require_ready_for_execution=True, readiness_context=context
        )
        == []
    )


def test_kickoff_feature_table_is_structurally_cross_bound_to_state() -> None:
    """Reject a valid table whose plan reference differs from planner state."""

    _, state_text, context, _ = _fixture()
    file_system = context.file_system
    assert isinstance(file_system, MemoryFileSystem)
    changed = _kickoff(plan_two="docs/features/completed/feature-102/other-plan.md")
    file_system.files[
        "C:/workspace/docs/features/epics/sample-epic/epic-kickoff.md"
    ] = changed
    file_system.files[
        "C:/workspace/artifacts/orchestration/epic-kickoff-sample-epic.md"
    ] = changed

    errors = validate_epic_planner_state_text(
        state_text, require_ready_for_execution=True, readiness_context=context
    )

    assert any("feature table must exactly match" in error for error in errors)


def test_git_ancestry_and_worktree_plan_drift_are_blocking() -> None:
    """Reject derived commits outside the integration branch and changed plan bytes."""

    _, state_text, context, git = _fixture()
    git.ancestors.remove((COMMIT_TWO, BRANCH))
    git.worktree_hashes["docs/features/active/feature-101/plan.md"] = "e" * 40

    errors = validate_epic_planner_state_text(
        state_text, require_ready_for_execution=True, readiness_context=context
    )

    assert any("not on" in error for error in errors)
    assert any("committed plan drift" in error for error in errors)


def test_optional_integrity_fields_are_validated_when_present() -> None:
    """Validate declared planning commit and plan hash against Git-derived values."""

    state, _, context, git = _fixture()
    final_commit = "e" * 40
    state["integrity"] = {
        "planning_commit": final_commit,
        "plan_hashes": {
            "docs/features/active/feature-101/plan.md": PLAN_ONE_HASH,
            "docs/features/completed/feature-102/plan.md": "f" * 40,
        },
    }
    state_text = json.dumps(state)
    file_system = context.file_system
    assert isinstance(file_system, MemoryFileSystem)
    file_system.files[_key(STATE_PATH)] = state_text
    git.commits.add(final_commit)
    git.ancestors.add((final_commit, BRANCH))
    git.committed_hashes[(final_commit, "docs/features/active/feature-101/plan.md")] = (
        PLAN_ONE_HASH
    )
    git.committed_hashes[
        (final_commit, "docs/features/completed/feature-102/plan.md")
    ] = PLAN_TWO_HASH

    errors = validate_epic_planner_state_text(
        state_text, require_ready_for_execution=True, readiness_context=context
    )

    assert any("Optional plan hash does not match" in error for error in errors)


def test_artifact_path_and_checkpoint_text_are_bound_to_supplied_context() -> None:
    """Reject an alternate artifact path and text that differs from that artifact."""

    _, state_text, context, _ = _fixture()
    wrong_context = EpicReadinessContext(
        workspace_root=context.workspace_root,
        artifact_path=ROOT / "other/state.json",
        file_system=context.file_system,
        git=context.git,
    )

    errors = validate_epic_planner_state_text(
        state_text, require_ready_for_execution=True, readiness_context=wrong_context
    )

    assert any("artifact path must be" in error for error in errors)
    assert any("requires the epic planner checkpoint" in error for error in errors)


def test_readiness_rejects_cross_feature_and_unsafe_evidence_paths() -> None:
    """Keep plans, research, and explicit preflight evidence within allowed roots."""

    state, _, context, _ = _fixture()
    feature = state["features"][0]
    feature["plan_path"] = "docs/features/completed/feature-102/plan.md"
    feature["research_path"] = "docs/unrelated/research.md"
    feature["preflight_evidence_path"] = "../outside/preflight.md"
    state_text = json.dumps(state)
    file_system = context.file_system
    assert isinstance(file_system, MemoryFileSystem)
    file_system.files[_key(STATE_PATH)] = state_text

    errors = validate_epic_planner_state_text(
        state_text, require_ready_for_execution=True, readiness_context=context
    )

    assert any("plan_path must be inside" in error for error in errors)
    assert any(
        "research_path must be under artifacts/research" in error for error in errors
    )
    assert any("must stay within the workspace root" in error for error in errors)


def test_readiness_cross_binds_repository_and_kickoff_identity() -> None:
    """Reject root, manifest, branch, kickoff-copy, and slug drift."""

    state, _, context, _ = _fixture()
    drifted = {
        **state,
        "epic_manifest_path": "docs/features/epics/sample-epic/other.md",
        "integration_branch": "epic/other-integration",
    }
    file_system = context.file_system
    assert isinstance(file_system, MemoryFileSystem)
    file_system.files[
        "C:/workspace/artifacts/orchestration/epic-kickoff-sample-epic.md"
    ] = _kickoff().replace("do not repeat planning", "do not repeat execution")
    outside = EpicReadinessContext(
        workspace_root=context.workspace_root,
        artifact_path=Path("D:/outside/state.json"),
        file_system=file_system,
        git=context.git,
    )

    errors = validate_epic_readiness_integrity(drifted, json.dumps(drifted), outside)

    assert any("artifact path must stay within" in error for error in errors)
    assert any("epic_manifest_path must be" in error for error in errors)
    assert any("integration_branch must be" in error for error in errors)
    assert any("kickoff bytes must match" in error for error in errors)
    assert any(
        "epic_feature_folder must be a slug" in error
        for error in validate_epic_readiness_integrity(
            {**state, "epic_feature_folder": "Invalid Slug"}, "{}", context
        )
    )


class ScriptRunner:
    """Record Git adapter commands and return command-specific results."""

    def __init__(self) -> None:
        self.calls: list[tuple[str, ...]] = []

    def run(
        self,
        args: Sequence[str],
        *,
        cwd: Path | None = None,
        allow_error: bool = False,
    ) -> CommandResult:
        del cwd, allow_error
        self.calls.append(tuple(args))
        if args[1:3] == ["hash-object", "--"]:
            return CommandResult(PLAN_ONE_HASH, "", 0)
        return CommandResult("", "", 1)


def test_git_repository_uses_injected_runner_without_a_shell() -> None:
    """Route exact-byte worktree hashing through the injected Git runner."""

    runner = ScriptRunner()
    repository = GitReadinessRepository(ROOT, runner)

    result = repository.worktree_blob_hash("docs/features/active/feature-101/plan.md")

    assert result == PLAN_ONE_HASH
    assert runner.calls == [
        (
            "git",
            "hash-object",
            "--",
            "docs/features/active/feature-101/plan.md",
        )
    ]
