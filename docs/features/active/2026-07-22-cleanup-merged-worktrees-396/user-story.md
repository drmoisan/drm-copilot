# `cleanup-merged-worktrees` — User Story

- Issue: #396
- Owner: drmoisan
- Status: Draft
- Last Updated: 2026-07-22

## Story Statement

- As a repository maintainer running multi-worktree orchestration, I want a deterministic tool that identifies which leftover worktrees and branches are fully merged into `main`, so that I can remove them without manually auditing each branch's ancestry.
- As an orchestration agent finishing an epic, I want stranded documentation/agent-memory commits on merged branches to be consolidated onto a single `documentationandmemories` branch and PR'd into `main` before any deletion, so that unique content is never silently destroyed during cleanup.
- As a developer working in an active worktree, I want the cleanup tool to be structurally incapable of targeting my current worktree or branch, so that running it (even in apply mode) can never disturb in-progress work.

## Problem / Why

Orchestration (epic and regular feature work) routinely creates git worktrees and branches for parallel, isolated execution. Once a branch's work has merged into `main`, the worktree and branch are frequently left behind. There is no deterministic, repository-native mechanism to detect which worktrees/branches are safe to remove (fully merged) versus which still carry unmerged or unique work (e.g., stranded agent-memory commits appended to a worktree branch after its feature content already merged).

A concrete instance exists in this repository today: branch `drm-copilot-wt-2026-07-21T17-20` has no worktree and its PR (#394) is already merged into `main` — a live "merged branch, no worktree" cleanup candidate that currently requires manual verification to remove safely.

## Personas & Scenarios

- Persona: Repository maintainer (Dan)
  - Who: owner of the drm-copilot repository, runs epic and feature orchestration that fans out into timestamped worktrees under `drm-copilot-wt/`.
  - Cares about: never losing unique commits (especially agent-memory and documentation content appended after a feature merged); keeping the worktree list short enough to reason about.
  - Constraints: works from a linked worktree, not the main checkout, so any HEAD-relative safety check (like `git branch -d`) is wrong for him; repository policy routes all PR creation through the `pr-author` agent.
  - Goals and frustrations: wants cleanup to be a single command with a trustworthy report; frustrated that today the safe/unsafe determination is manual ancestry archaeology, and that a prior cleanup (2026-07-21) found uncommitted artifacts in a worktree that had to be rescued by hand.
  - Context and motivations: after each merged epic, two to five stale worktrees/branches accumulate; issue #372's cleanup deferred exactly this class of work.

- Persona: Orchestration agent (Claude Code session)
  - Who: an agent executing the cleanup skill as part of post-merge housekeeping.
  - Cares about: deterministic, machine-parseable script output it can act on without judgment calls; a clearly bounded editorial role (deciding whether flagged unique content is genuinely documentation/memory material) separate from the mechanical classification the script owns.
  - Constraints: cannot call `gh pr create` directly (hook-blocked); must hand off to `Agent(pr-author)`; must not mutate the caller's worktree.
  - Goals: run report mode, triage CHERRY_PICK_CANDIDATE entries, drive consolidation and the PR handoff, then run apply mode after the consolidation PR merges.

- Scenario: Routine post-epic cleanup with stranded memory commits
  - Who is acting: the maintainer (or an orchestration agent on his behalf), in the active worktree `drm-copilot-wt/2026-07-21T21-57`.
  - Trigger: an epic's PRs have all merged; several `drm-copilot-wt-*` branches and one or two worktrees remain.
  - Steps:
    1. Run the script in default report mode. It verifies local `main` matches `origin/main`, enumerates branches (`for-each-ref`) and worktrees (`worktree list --porcelain`), and prints one classification line per branch: e.g., `drm-copilot-wt-2026-07-21T17-20` → `MERGED_CLEAN`; `drm-copilot-wt-2026-07-21T17-18` → `HAS_UNIQUE_RESIDUALS` with two `UNIQUE` commits touching `.claude/agent-memory/**`; the current branch → `PROTECTED_CURRENT`.
    2. The agent reviews the CHERRY_PICK_CANDIDATE entries and confirms editorially that the unique commits are documentation/memory content.
    3. The consolidation step creates the `documentationandmemories` branch off `main` in a dedicated new worktree and cherry-picks the flagged commits oldest-first with `-x` provenance.
    4. The agent refreshes the PR-context bundle, validates the orchestrator-state checkpoint, and delegates PR creation to `Agent(pr-author)`.
    5. After the consolidation PR merges (verified git-natively: `merge-base --is-ancestor documentationandmemories main` post-fetch), the agent runs apply mode. The tool re-verifies each candidate's ancestry in-process, removes worktrees (no `--force`), then deletes branches with `-D`. The now-merged `documentationandmemories` branch and worktree are cleaned up by the same mechanics.
  - Obstacles or decisions: one worktree turns out to be dirty (untracked files) — the tool blocks its removal, prints its `status --porcelain` output, and leaves it for manual inspection rather than forcing. One cherry-pick conflicts on a shared `MEMORY.md` index — the tool aborts that pick, records `CONFLICT`, and surfaces it for editorial resolution.
  - Expected outcome: all fully merged branches/worktrees are gone; every unique documentation/memory commit is preserved on `main` via the consolidation PR; the active worktree was never touched; nothing was deleted that had unmerged code.

- Scenario: Nothing to consolidate
  - Trigger: report mode classifies every candidate as `MERGED_CLEAN` or `MERGED_EQUIVALENT` with an empty CHERRY_PICK_CANDIDATE list.
  - Steps: the workflow skips branch creation and the PR handoff entirely and proceeds straight to apply-mode deletion.
  - Expected outcome: cleanup completes in a single session with no PR.

## Acceptance Criteria

- [ ] AC1: The bash script deterministically classifies and lists worktrees/branches merged into `main` with no residual commits (`MERGED_CLEAN`) as safe to auto-delete, using `git merge-base --is-ancestor` exit-code semantics (0 merged, 1 not merged, >1 error) over branches enumerated with `git for-each-ref refs/heads/` and worktrees enumerated with `git worktree list --porcelain`.
- [ ] AC2: The bash script deterministically classifies merged branches with residual commits, distinguishing content-already-on-main (droppable via the ladder: branch-level `git diff --quiet main...<branch>` short-circuit, `git cherry` patch-id equivalence, rename-aware blob-OID comparison) from unique content (emitted as CHERRY_PICK_CANDIDATE entries with SHA, paths, author, date). Commit-message text matching is never a classification input.
- [ ] AC3: The script never selects the current worktree or current branch for any destructive action, verified through both `git rev-parse --abbrev-ref HEAD` (branch) and `git rev-parse --show-toplevel` (path) against the porcelain worktree list; the main worktree is always excluded.
- [ ] AC4: The CLI supports exactly two modes: a dry-run/report mode as the default (no mutation, deterministic machine-parseable output) and an explicit apply mode that performs deletion/consolidation for delete-eligible states only.
- [ ] AC5: Deletion in apply mode follows the fixed order — same-process ancestry/equivalence re-verification, then `git worktree remove` without `--force` (dirty worktrees block deletion and are reported, never forced), then `git branch -D` — and deletion of branches with consolidated unique content occurs only after the consolidation PR is verified merged via a git-native ancestry re-check.
- [ ] AC6: Consolidation cherry-picks all flagged unique documentation/memory commits, across an arbitrary number of stranded branches, onto a single `documentationandmemories` branch created off `main` in a dedicated worktree (never the caller's worktree), oldest-first per branch with `git cherry-pick -x`, branches in `LC_ALL=C` order; conflicts abort-and-surface rather than auto-resolve; a pre-existing `documentationandmemories` branch stops the run with a report.
- [ ] AC7: The skill documents the cherry-pick-to-`documentationandmemories`-then-PR-then-delete workflow end to end, delegating PR creation exclusively to `Agent(pr-author)` (no direct `gh pr create` anywhere in the skill or script).
- [ ] AC8: Unit tests (bats, `tests/shell/`, git-binary stub seam, no temp files, no scratch git repos) cover at minimum: merged branch without a worktree, merged branch with a worktree, unmerged branch (excluded), merged branch with a residual commit whose content already exists on `main`, merged branch with a residual unique documentation commit, and current-worktree/branch exclusion.

## Non-Goals

- Remote branch management: the tool never deletes, prunes, or modifies remote branches (`origin/*`); its scope is local branches and local worktree registrations only.
- Force-deleting dirty worktrees: `git worktree remove --force` is never the default behavior; a dirty worktree blocks deletion and is reported for manual handling.
- Automatic conflict resolution: cherry-pick conflicts are aborted and surfaced, never resolved non-interactively by the script; branches whose unique commits conflict are not deleted until the conflict is editorially resolved and their content is verified on `main`.
- Deleting unmerged work: branches classified `NOT_MERGED` or `HAS_UNIQUE_RESIDUALS` are never destructive-action candidates; only reporting applies to them.
- Direct PR creation: the skill/script never calls `gh pr create` or `gh pr edit --body*`; PR authoring is `Agent(pr-author)`'s exclusive responsibility.
- Deciding what counts as "documentation": the script emits deterministic CHERRY_PICK_CANDIDATE facts (SHA, paths, author, date, optionally a path-based annotation); the editorial judgment is the skill/LLM layer's job and is out of the script's scope.
- Squash-merge support: this repository merges PRs via merge commits; adapting the classifier for a squash-merge workflow is out of scope.
- Real-git integration test fixtures: scratch git repositories in the test run conflict with the no-temp-files policy; unit testing is via the checked-in git-binary stub. A CI-only real-git scenario would require a separately sanctioned policy exception and is not part of this feature.
- `git worktree prune` execution: prunable/stale registrations are report-only; automatic pruning is not performed by default.
