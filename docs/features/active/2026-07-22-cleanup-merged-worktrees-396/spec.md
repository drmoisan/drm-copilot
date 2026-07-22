# cleanup-merged-worktrees — Spec

- **Issue:** #396
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-07-22
- **Status:** Draft
- **Version:** 1.0

## Overview

Orchestration (epic and regular feature work) routinely creates git worktrees and branches for parallel, isolated execution. Once a branch's work has merged into `main`, the worktree and branch are frequently left behind. There is no deterministic, repository-native mechanism to detect which worktrees/branches are safe to remove (fully merged) versus which still carry unmerged or unique work (e.g., stranded agent-memory commits appended to a worktree branch after its feature content already merged).

This feature delivers:

1. A deterministic bash CLI tool (`scripts/bash/cleanup-worktrees.sh` wrapping `scripts/bash/cleanup_worktrees_lib.sh`) that classifies branches/worktrees, reports, and — in apply mode only — deletes safe candidates and stages cherry-pick consolidation.
2. A Claude Code skill (`.claude/skills/cleanup-merged-worktrees/SKILL.md`) that documents and drives the end-to-end workflow: detect → report → consolidate onto `documentationandmemories` → `pr-author` handoff → post-merge deletion.

Research basis: `docs/features/active/2026-07-22-cleanup-merged-worktrees-396/research/2026-07-22T08-30-cleanup-merged-worktrees-research.md`. Design decisions below are carried from that research; do not re-derive them.

## Behavior

### Enumeration (deterministic, plumbing-only)

- Enumerate local branches via `git for-each-ref --format='%(refname:short) %(objectname)' refs/heads/` — not `git branch` — so loose refs and `packed-refs` are read uniformly and output carries no decoration markers. Process branches in `LC_ALL=C` sorted order for deterministic output and deterministic cross-branch cherry-pick ordering.
- Enumerate worktrees via `git worktree list --porcelain`, parsed stanza-wise. Handle `branch`, `detached`, `locked`, and `prunable` attributes. Detached worktrees are report-only (no branch to classify). `prunable` stanzas are reported as prune candidates only; the tool never runs `git worktree prune` destructively by default.

### Current-worktree/branch exclusion (mandatory, dual-check)

Both checks are required; either match excludes the item from all destructive candidacy and marks it `PROTECTED_CURRENT`:

1. Branch name equality against `git rev-parse --abbrev-ref HEAD` (a `HEAD` result means detached: no branch name to protect, but the worktree path is still protected).
2. Worktree path equality (after path normalization) against `git rev-parse --show-toplevel`, compared to each `worktree <path>` in the porcelain output.

The main worktree (first porcelain stanza) is always excluded from candidacy regardless of the above.

### Classification ladder (per branch, in order)

1. `git merge-base --is-ancestor <tip> main` exit `0` → **MERGED_CLEAN** (delete-eligible, zero residual commits). Exit `1` → proceed to step 2. Exit `> 1` → hard error for that branch; report as failure, never treat as "not merged".
2. `git diff --quiet main...<branch>` exit `0` → **MERGED_CONTENT_NEUTRAL** (residual commits net to no content change; delete-eligible). This short-circuit runs before per-commit analysis and catches revert-pairs.
3. `git cherry main <branch>` — all residual commits reported `-` (patch-id equivalent on `main`; empty-diff commits counted as equivalent) → **MERGED_EQUIVALENT** (delete-eligible).
4. For each remaining `+` commit (enumerated oldest-first via `git rev-list --reverse main..<branch>`, merges excluded from the candidate list via `--no-merges`): rename-aware blob-OID comparison per touched path (`git diff-tree --no-commit-id --name-status -r -M <sha>`, then blob-OID equality of `<branch>:<path>` vs `main:<path>`; deletions droppable iff the path is also absent on `main`; renames compared at the new path). All paths equivalent → commit is droppable. Any path unique → commit enters the **CHERRY_PICK_CANDIDATE** list with its SHA, paths, author, and date.
5. A branch with at least one unique residual commit is **HAS_UNIQUE_RESIDUALS**; a branch whose tip is simply unmerged code is **NOT_MERGED**. Neither is delete-eligible.

Prohibited classification inputs: `git log --all --grep` or any commit-message text matching (rejected as a text heuristic — permitted only as advisory diagnostics in the human-readable report, never as an input to a safe/unsafe decision); branch-name pattern heuristics; parsing `git branch --merged` porcelain text.

Freshness precondition: classification runs against local `main`. The tool must verify `git rev-parse main` equals `git rev-parse origin/main` (or fetch first) and warn on divergence. A stale `main` can only produce false "not merged" (safe direction), but the report must flag the divergence.

### Operating modes (CLI contract)

The script supports exactly two modes:

- **Report mode (default — dry run).** No mutation of any kind. Emits a deterministic, machine-parseable report: one line per branch with its classification state, plus one line per residual commit with its per-commit state (`EQUIVALENT | CONTENT_ON_MAIN | EMPTY | UNIQUE(paths)`), in `LC_ALL=C` order. Also reports dirty worktrees (with `git -C <path> status --porcelain` output), detached worktrees, prunable registrations, and `main`/`origin/main` divergence. Running with no flags is always safe.
- **Apply mode (explicit flag, e.g. `--apply`).** Performs destructive actions for delete-eligible states only (`MERGED_CLEAN`, `MERGED_CONTENT_NEUTRAL`, `MERGED_EQUIVALENT`), subject to the deletion gate below. Apply mode never deletes a branch in `HAS_UNIQUE_RESIDUALS` or `NOT_MERGED` state and never touches `PROTECTED_CURRENT` items.

### Consolidation onto `documentationandmemories`

- Runs only when the CHERRY_PICK_CANDIDATE list is non-empty; otherwise the workflow proceeds directly to deletion ("nothing to consolidate").
- The consolidation branch and checkout are created in a dedicated worktree, never in the caller's worktree: `git worktree add <path> -b documentationandmemories main`. Precondition: `refs/heads/documentationandmemories` must not already exist; if it does (prior aborted run), stop and report — never reuse silently.
- Cherry-picks use `git -C <consolidation-worktree> cherry-pick -x <sha>`, one commit per invocation, oldest-first within each source branch, source branches processed in `LC_ALL=C` sorted order. `-x` provides provenance; default cherry-pick behavior preserves authorship.
- Conflict handling: on cherry-pick conflict the script must not auto-resolve. It runs `cherry-pick --abort`, records the commit as `CONFLICT`, and surfaces it to the skill/LLM layer for editorial handling. "Now empty" results are resolved with `cherry-pick --skip` and the commit reclassified as droppable.
- Abort cleanup: if a consolidation run aborts, the consolidation worktree and branch are removed, or the run explicitly reports a resume path; silent leftovers are not permitted.

### PR handoff and merge gate

- PR creation is delegated to `Agent(pr-author)` exclusively. This skill and script never call `gh pr create` or `gh pr edit --body*` (hook-enforced). The cleanup skill's responsibility ends at: consolidation branch pushed, PR-context bundle refreshed (`mcp__drm-copilot__collect_pr_context`, base branch `main`), orchestrator-state checkpoint validated with `--require-pr-creation-ready`, delegation issued per `.claude/skills/pr-author/SKILL.md` and the orchestrate handoff sequence.
- Deletion of branches whose unique content was consolidated is gated on the consolidation PR merging. The merge check is git-native: after `git fetch`, `git merge-base --is-ancestor documentationandmemories main` — the same primitive as classification, which simultaneously re-validates that the flagged commits are now reachable from `main`. Once merged, `documentationandmemories` and its worktree become `MERGED_CLEAN` instances and are cleaned up by the same deletion mechanics.

### Deletion mechanics (apply mode, per candidate, fixed order)

1. Re-verify classification (ancestry or recorded equivalence verdict) immediately before deletion, in the same process.
2. `git worktree remove <path>` — never `--force` by default. A dirty worktree (modified tracked or untracked files) blocks deletion: report the `status --porcelain` output and skip. Skip if the branch has no worktree.
3. `git branch -D <name>` — `-D`, not `-d`, because `-d`'s merge check is HEAD-relative and this tool runs off-`main`; safety comes from the tool's own step-1 re-verification against `main`. (Refinement of the issue text's `git branch -d`, documented per research section 5.)
4. `git worktree prune` for stale registrations is report-only by default.

## Inputs / Outputs

- Inputs:
  - CLI subcommands/flags: report mode (default), `--apply`, `--help`. Optional flags for the planner to finalize: a `--keep-going`-style policy for cherry-pick conflicts; an explicit non-default force passthrough is permitted to exist but must never be the default and must not bypass the dirty-worktree report.
  - Environment: git binary override seam following the `SHELL_QC_<TOOL>_BIN` convention (e.g., `CLEANUP_WT_GIT_BIN`); empty/nonexistent value treated as missing. This seam is the test-stub mechanism.
  - Repository state: local refs, `packed-refs`, worktree registrations, `origin/main`.
- Outputs:
  - Deterministic machine-parseable report on stdout (report mode and apply mode both emit it; apply mode additionally emits per-action results).
  - Non-zero exit on error conditions (rev-parse failures, `merge-base` exit > 1, aborted consolidation), with `set -euo pipefail` semantics and `|| rc=$?` capture for expected non-zero commands.
- Config keys and defaults: none beyond the env seam; no config file.
- Versioning / backward compatibility: new tool; no existing consumers. Report line format is a contract for the skill layer and tests — changes to it after initial delivery are breaking.

## API / CLI Surface

- `bash scripts/bash/cleanup-worktrees.sh` (no args or a `report` subcommand): dry-run report, exit 0 on success even when candidates exist.
- `bash scripts/bash/cleanup-worktrees.sh --apply` (or `apply` subcommand): executes deletion for delete-eligible states and consolidation staging; exit non-zero on any hard error.
- `--help`: usage heredoc; usage errors return exit code 2, matching the `shell-qc.sh` house pattern.
- Exact subcommand/flag spelling is the atomic-planner's decision; the report-default/apply-explicit contract is not negotiable.
- Contracts and validation rules: report lines are one-record-per-line, `LC_ALL=C` ordered, stable field order; branch states drawn from `NOT_MERGED | MERGED_CLEAN | MERGED_CONTENT_NEUTRAL | MERGED_EQUIVALENT | HAS_UNIQUE_RESIDUALS | PROTECTED_CURRENT`; per-commit states from `EQUIVALENT | CONTENT_ON_MAIN | EMPTY | UNIQUE(paths)`.

## Data & State

- Data flow: git plumbing reads → in-process classification → report; apply mode adds worktree removal, branch deletion, consolidation worktree/branch creation, cherry-picks.
- Invariants:
  - No mutation in report mode.
  - Destructive action only on delete-eligible states, only after same-process re-verification.
  - The caller's worktree and branch are never mutated, checked out over, or deleted.
  - Exactly one consolidation branch name: `documentationandmemories`, created off `main`.
- Persistence: none beyond git itself. No caching.
- Migration/backfill: none.

## Constraints & Risks

- Destructive by nature (deletes worktrees and branches); must never run against unmerged work or the active worktree. Mitigations: dual current-exclusion, delete-eligible-states-only gating, same-process re-verification, no-`--force` default, dirty-worktree block.
- Must not assume a specific number of stranded branches; must aggregate an arbitrary number into one `documentationandmemories` branch.
- PR creation must go through the `pr-author` handoff per repository policy, not direct `gh pr create` (hook-enforced by `enforce-pr-author-skill.ps1`).
- Follows the repository's existing bash tooling conventions under `scripts/bash/`: wrapper/library split mirroring `shell-qc.sh` + `shell_qc_lib.sh`, `set -euo pipefail`, source-guard, shfmt/shellcheck clean, 500-line cap per file (the ladder + consolidation + deletion scope may force a second library file; acceptable).
- Cherry-pick conflicts on index-style files (e.g., multiple stranded branches appending to the same `MEMORY.md`) are expected; the abort-and-surface policy covers them.
- Squash merges are not used in this repository (PRs merge via merge commits); if that ever changes, the ancestry primary path stops holding and the content-equivalence tiers become primary. Out of scope to handle now; noted for maintainers.
- Operational: no local delegate can run the bash toolchain in this Windows environment; verification of the bats suite runs via CI dispatch (`ubuntu-latest`, `.github/workflows/_shell-coverage.yml`). The plan must budget for CI-based verification.

## Implementation Strategy

- Implementation scope:
  - New: `scripts/bash/cleanup-worktrees.sh` (thin CLI wrapper: dispatch, `usage()`, source-guard), `scripts/bash/cleanup_worktrees_lib.sh` (all classification/consolidation/deletion logic as sourceable functions; split into a second lib if the 500-line cap requires).
  - New: `.claude/skills/cleanup-merged-worktrees/SKILL.md` — frontmatter scoping Bash to the wrapper plus narrow read-only git/gh commands; body documents the full detect → report → consolidate → pr-author handoff → post-merge deletion workflow, cross-referencing `.claude/skills/pr-author/SKILL.md` rather than re-specifying PR creation.
  - New: `tests/shell/test_cleanup_worktrees_<topic>.bats` files plus checked-in fixtures and a `git` stub under `tests/fixtures/cleanup_worktrees/stub-bin/`.
- Test strategy (policy resolution — binding):
  - Framework: existing `bats` under `tests/shell/` — do not introduce a new framework.
  - All unit tests stub the `git` binary itself through the env-override seam, replaying canned `worktree list --porcelain` / `for-each-ref` / exit-code scenarios from checked-in fixtures. No temp files; no scratch git repos in the test run. The issue's "scratch git repo fixture" idea conflicts with the no-temp-files policy; the compliant path is the git stub. Any real-git end-to-end scenario, if added later, requires an explicitly sanctioned, CI-only mechanism called out as a policy exception — not part of this feature's required scope.
  - Coverage: kcov line coverage >= 85% on the library file(s); wrapper kept thin.
- Dependency changes: none. git, bash, bats, kcov are all already in use.
- Logging: report output on stdout; errors on stderr with specific messages per the fail-fast policy.
- Rollout: no feature flags. Dry-run default is the safety posture; apply mode is opt-in per invocation.

## Definition of Done

- [ ] Acceptance criteria documented and mapped to tests or demos
- [ ] Behavior matches acceptance criteria in all documented environments
- [ ] Tests updated/added (unit tests via bats + git stub; CI-dispatch verification)
- [ ] Edge cases and error handling covered by tests (exit-code ladder, detached/locked/prunable worktrees, dirty-worktree block, renames/deletions, revert-pair neutrality, pre-existing `documentationandmemories` branch)
- [ ] Docs updated (SKILL.md; feature folder links)
- [ ] Telemetry/logging added or updated (stdout report contract; stderr errors)
- [ ] Toolchain pass completed (shfmt → shellcheck → bats → kcov coverage via `scripts/bash/shell-qc.sh`, CI-dispatched)

## Acceptance Criteria

- [x] AC1: The bash script deterministically classifies and lists worktrees/branches merged into `main` with no residual commits (`MERGED_CLEAN`) as safe to auto-delete, using `git merge-base --is-ancestor` exit-code semantics (0 merged, 1 not merged, >1 error) over branches enumerated with `git for-each-ref refs/heads/` and worktrees enumerated with `git worktree list --porcelain`.
- [x] AC2: The bash script deterministically classifies merged branches with residual commits, distinguishing content-already-on-main (droppable via the ladder: branch-level `git diff --quiet main...<branch>` short-circuit, `git cherry` patch-id equivalence, rename-aware blob-OID comparison) from unique content (emitted as CHERRY_PICK_CANDIDATE entries with SHA, paths, author, date). Commit-message text matching is never a classification input.
- [x] AC3: The script never selects the current worktree or current branch for any destructive action, verified through both `git rev-parse --abbrev-ref HEAD` (branch) and `git rev-parse --show-toplevel` (path) against the porcelain worktree list; the main worktree is always excluded.
- [x] AC4: The CLI supports exactly two modes: a dry-run/report mode as the default (no mutation, deterministic machine-parseable output) and an explicit apply mode that performs deletion/consolidation for delete-eligible states only.
- [x] AC5: Deletion in apply mode follows the fixed order — same-process ancestry/equivalence re-verification, then `git worktree remove` without `--force` (dirty worktrees block deletion and are reported, never forced), then `git branch -D` — and deletion of branches with consolidated unique content occurs only after the consolidation PR is verified merged via a git-native ancestry re-check.
- [x] AC6: Consolidation cherry-picks all flagged unique documentation/memory commits, across an arbitrary number of stranded branches, onto a single `documentationandmemories` branch created off `main` in a dedicated worktree (never the caller's worktree), oldest-first per branch with `git cherry-pick -x`, branches in `LC_ALL=C` order; conflicts abort-and-surface rather than auto-resolve; a pre-existing `documentationandmemories` branch stops the run with a report.
- [x] AC7: The skill documents the cherry-pick-to-`documentationandmemories`-then-PR-then-delete workflow end to end, delegating PR creation exclusively to `Agent(pr-author)` (no direct `gh pr create` anywhere in the skill or script).
- [x] AC8: Unit tests (bats, `tests/shell/`, git-binary stub seam, no temp files, no scratch git repos) cover at minimum: merged branch without a worktree, merged branch with a worktree, unmerged branch (excluded), merged branch with a residual commit whose content already exists on `main`, merged branch with a residual unique documentation commit, and current-worktree/branch exclusion.

## Seeded Test Conditions (from potential)

- [ ] Unit coverage: branch classification (merged/unmerged, with/without worktree, with/without residual commits) — delivered via bats + checked-in git-stub fixtures per scenario.
- [ ] Integration scenarios: the issue's "scratch git repo fixture" is superseded — a scratch git repo in the test run conflicts with the no-temp-files policy; the compliant equivalent is stub-driven end-to-end scenarios (report mode and apply mode gating) through the same git stub. A real-git scenario is out of scope unless separately sanctioned as a CI-only policy exception.
- [ ] CLI/API examples: dry-run output vs. apply mode — both modes exercised in tests; example invocations documented in the SKILL.md.
