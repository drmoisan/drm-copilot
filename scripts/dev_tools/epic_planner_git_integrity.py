"""Git provenance checks for execution-ready epic planning."""

from __future__ import annotations

import re
from typing import TYPE_CHECKING, Any, Protocol, cast

from scripts.dev_tools.pr_context.git import SubprocessRunner

if TYPE_CHECKING:
    from pathlib import Path

    from scripts.dev_tools.epic_kickoff_contract import ParsedEpicKickoff
    from scripts.dev_tools.pr_context.git import CommandRunner

HASH_RE = re.compile(r"^[0-9a-fA-F]{40,64}$")
COMMIT_RE = re.compile(r"^[0-9a-fA-F]{7,64}$")


class ReadinessGitRepository(Protocol):
    """Focused Git query surface for planning provenance."""

    def ref_exists(self, ref: str) -> bool: ...

    def commit_exists(self, commit: str) -> bool: ...

    def is_ancestor(self, commit: str, ref: str) -> bool: ...

    def last_commit(self, path: str) -> str | None: ...

    def committed_blob_hash(self, ref: str, path: str) -> str | None: ...

    def worktree_blob_hash(self, path: str) -> str | None: ...


class GitReadinessRepository:
    """Git-backed repository adapter using an injectable command runner."""

    def __init__(
        self, workspace_root: Path, runner: CommandRunner | None = None
    ) -> None:
        self._root = workspace_root
        self._runner = runner or SubprocessRunner()

    def _run(self, arguments: list[str]) -> tuple[int, str]:
        result = self._runner.run(["git", *arguments], cwd=self._root, allow_error=True)
        return result.code, result.stdout.strip()

    def ref_exists(self, ref: str) -> bool:
        """Return whether ref resolves to a commit."""

        code, _ = self._run(["rev-parse", "--verify", f"{ref}^{{commit}}"])
        return code == 0

    def commit_exists(self, commit: str) -> bool:
        """Return whether commit identifies a commit object."""

        code, _ = self._run(["cat-file", "-e", f"{commit}^{{commit}}"])
        return code == 0

    def is_ancestor(self, commit: str, ref: str) -> bool:
        """Return whether commit is an ancestor of ref."""

        code, _ = self._run(["merge-base", "--is-ancestor", commit, ref])
        return code == 0

    def last_commit(self, path: str) -> str | None:
        """Return the latest commit affecting path."""

        code, output = self._run(["log", "-n", "1", "--format=%H", "--", path])
        return output if code == 0 and output else None

    def committed_blob_hash(self, ref: str, path: str) -> str | None:
        """Return the exact Git blob ID for path at ref."""

        code, output = self._run(["rev-parse", "--verify", f"{ref}:{path}"])
        return output.lower() if code == 0 and HASH_RE.fullmatch(output) else None

    def worktree_blob_hash(self, path: str) -> str | None:
        """Hash the worktree bytes using Git's repository hash algorithm."""

        code, output = self._run(["hash-object", "--", path])
        return output.lower() if code == 0 and HASH_RE.fullmatch(output) else None


def _optional_integrity(
    state: dict[str, Any], parsed: ParsedEpicKickoff
) -> tuple[str | None, dict[str, str], list[str]]:
    """Collect and validate optional state and kickoff integrity declarations."""

    errors: list[str] = []
    integrity_value = state.get("integrity")
    integrity: dict[str, Any] = {}
    if integrity_value is not None:
        if not isinstance(integrity_value, dict):
            errors.append(
                "Epic planner checkpoint integrity must be an object when present."
            )
        else:
            integrity = cast("dict[str, Any]", integrity_value)
    commits = [
        value
        for value in (
            state.get("planning_commit"),
            integrity.get("planning_commit"),
            parsed.planning_commit,
        )
        if value is not None
    ]
    for commit in commits:
        if not isinstance(commit, str) or COMMIT_RE.fullmatch(commit) is None:
            errors.append(
                "Optional planning_commit values must be 7-64 hexadecimal characters."
            )
    normalized = [
        commit.lower()
        for commit in commits
        if isinstance(commit, str) and COMMIT_RE.fullmatch(commit)
    ]
    if len(set(normalized)) > 1:
        errors.append(
            "Optional planning_commit values in state and kickoff must match."
        )
    hashes = dict(parsed.plan_hashes)
    state_hashes = integrity.get("plan_hashes", state.get("plan_hashes"))
    if state_hashes is not None:
        if not isinstance(state_hashes, dict):
            errors.append("Optional plan_hashes must be an object keyed by plan path.")
        else:
            for key, value in cast("dict[object, object]", state_hashes).items():
                if (
                    not isinstance(key, str)
                    or not isinstance(value, str)
                    or HASH_RE.fullmatch(value) is None
                ):
                    errors.append(
                        "Optional plan_hashes entries must map paths to 40-64 "
                        "character hexadecimal hashes."
                    )
                    continue
                existing = hashes.get(key)
                if existing is not None and existing != value.lower():
                    errors.append(
                        f"Optional plan hash declarations disagree for {key!r}."
                    )
                hashes[key] = value.lower()
    return normalized[0] if normalized else None, hashes, errors


def validate_committed_file(
    git: ReadinessGitRepository, ref: str, path: str, *, label: str
) -> list[str]:
    """Require a worktree file to match the exact blob committed at ref."""

    committed = git.committed_blob_hash(ref, path)
    worktree = git.worktree_blob_hash(path)
    if committed is None:
        return [f"Execution readiness requires {label} committed at {ref}: {path}"]
    if worktree is None:
        return [f"Execution readiness could not hash worktree {label}: {path}"]
    if committed != worktree:
        return [f"Execution readiness detected worktree drift for {label}: {path}"]
    return []


def validate_planning_git_integrity(
    state: dict[str, Any],
    parsed: ParsedEpicKickoff,
    plans: list[str],
    git: ReadinessGitRepository,
) -> list[str]:
    """Verify integration ancestry and byte-exact committed plan provenance."""

    branch = state.get("integration_branch")
    if not isinstance(branch, str) or not git.ref_exists(branch):
        return [f"Execution readiness integration branch does not exist: {branch!r}"]
    errors: list[str] = []
    commit, declared_hashes, integrity_errors = _optional_integrity(state, parsed)
    errors.extend(integrity_errors)
    if commit is not None:
        if not git.commit_exists(commit):
            errors.append(
                f"Execution readiness planning commit does not exist: {commit}"
            )
        elif not git.is_ancestor(commit, branch):
            errors.append(
                f"Execution readiness planning commit {commit} is not an ancestor "
                f"of {branch}."
            )
    features = state.get("features")
    feature_maps = (
        [
            cast("dict[str, Any]", item)
            for item in cast("list[object]", features)
            if isinstance(item, dict)
        ]
        if isinstance(features, list)
        else []
    )
    for index, plan in enumerate(plans):
        derived = git.last_commit(plan)
        if derived is None:
            errors.append(
                f"Execution readiness could not derive a planning commit for {plan}."
            )
            continue
        if not git.commit_exists(derived) or not git.is_ancestor(derived, branch):
            errors.append(
                f"Execution readiness derived plan commit {derived} is not on {branch}."
            )
            continue
        candidate_commits = [derived]
        feature = feature_maps[index] if index < len(feature_maps) else {}
        feature_commit = feature.get("planning_commit")
        if feature_commit is not None:
            if (
                not isinstance(feature_commit, str)
                or COMMIT_RE.fullmatch(feature_commit) is None
            ):
                errors.append(
                    f"Epic planner checkpoint features[{index}].planning_commit "
                    "must be hexadecimal."
                )
            else:
                candidate_commits.append(feature_commit.lower())
        if commit is not None:
            candidate_commits.append(commit)
        worktree_hash = git.worktree_blob_hash(plan)
        if worktree_hash is None:
            errors.append(
                f"Execution readiness could not hash worktree atomic plan: {plan}"
            )
            continue
        for candidate in dict.fromkeys(candidate_commits):
            if not git.commit_exists(candidate):
                errors.append(
                    f"Execution readiness planning commit does not exist: {candidate}"
                )
                continue
            if not git.is_ancestor(candidate, branch):
                errors.append(
                    f"Execution readiness planning commit {candidate} is not an "
                    f"ancestor of {branch}."
                )
                continue
            committed_hash = git.committed_blob_hash(candidate, plan)
            if committed_hash is None:
                errors.append(
                    f"Execution readiness planning commit {candidate} does not "
                    f"contain {plan}."
                )
            elif committed_hash != worktree_hash:
                errors.append(
                    f"Execution readiness detected committed plan drift: {plan}"
                )
        declared = feature.get("plan_hash", declared_hashes.get(plan))
        if declared is not None:
            if not isinstance(declared, str) or HASH_RE.fullmatch(declared) is None:
                errors.append(
                    f"Optional plan hash for {plan} must be 40-64 hexadecimal "
                    "characters."
                )
            elif declared.lower() != worktree_hash:
                errors.append(
                    f"Optional plan hash does not match committed bytes for {plan}."
                )
    for extra in sorted(set(declared_hashes) - set(plans)):
        errors.append(f"Optional plan_hashes contains unknown planner path: {extra!r}.")
    return errors
