# 2026-08-29-cleanup-worktrees-apply-deletes-local-main (Spec)

- **Issue:** #594
- **Parent (optional):** none
- **Owner:** drmoisan
- **Branch:** `bug/cleanup-worktrees-apply-deletes-local-main-594`
- **Work Mode:** full-bug (this `spec.md` is the sole acceptance-criteria source; no `user-story.md` is produced)
- **Research:** `docs/features/active/2026-08-29-cleanup-worktrees-apply-deletes-local-main-594/research/research.2026-09-25T22-10.md`
- **Last Updated:** 2026-09-25T22-30
- **Status:** Draft
- **Version:** 1.0

## Context

`scripts/bash/cleanup-worktrees.sh --apply` deletes the local `main` branch when a branch other than `main` is checked out in the primary worktree. The script enumerates `main` as an ordinary candidate, evaluates `git merge-base --is-ancestor main main` (a commit is its own ancestor), classifies `main` as `MERGED_CLEAN`, and the apply-mode deletion pass then runs `git branch -D main`.

Environment (from `issue.md`):
- OS/version: Windows 11 Pro 10.0.26200
- Command/flags used: `bash scripts/bash/cleanup-worktrees.sh --apply`
- Data source: live repository state (110 local branches, approximately 50 worktrees)

Impact / Severity: Blocker. `main` is the repository's primary integration branch and the fixed comparison base for every other branch's classification. In both observed runs local `main` was byte-identical to `origin/main` and was restored with `git branch main origin/main`. That recovery path does not hold if local `main` carries local-only commits when `--apply` runs.

## Repro & Evidence

Steps to Reproduce (from `issue.md`):
1. From the repository root, with a local `main` present and a different branch (observed: `chore/cleanup`) checked out in the primary worktree, run `bash scripts/bash/cleanup-worktrees.sh --apply`.
2. Observe `BRANCH|main|MERGED_CLEAN` followed by `ACTION|branch-delete|main|OK`.
3. Confirm `git branch --list main` returns nothing.
4. Reproduced twice in the same session with identical outcomes.

Observed log snippet:
```
BRANCH|main|MERGED_CLEAN
ACTION|branch-delete|main|OK
BRANCH|parallel/critical-bug-fixes-plan|ANCESTRY_ERROR
BRANCH|worktree-agent-a046a08b20e685723|ANCESTRY_ERROR
... (cascades through all remaining branches in the run)
```

Reproduction verdict on current code (research section 1): the defect still reproduces on the current baseline (`origin/main` head `d754f83f`). The verdict was derived by static reading; `--apply` was not run against the real repository and no bats run was performed during research.

## Problem Statement (current-code trace)

The following trace is taken from research section 1.1. Line numbers refer to the research baseline.

1. `run_apply` (`scripts/bash/cleanup_worktrees_actions_lib.sh:356`) captures the worktree and branch lists (`:373-380`) and builds `wt_of[<branch>]=<path>` for every branch-backed registration (`:383-391`).
2. `enumerate_branches` (`scripts/bash/cleanup_worktrees_enumerate_lib.sh:59-83`) emits every `refs/heads/*` ref with no filter. `main` is enumerated like any other branch.
3. `classify_all_branches` (`scripts/bash/cleanup_worktrees_report_records_lib.sh:346-476`) calls `classify_branch` once per enumerated name (`:418-426`).
4. `classify_branch` (`scripts/bash/cleanup_worktrees_lib.sh:315-450`), rung 1, returns `PROTECTED_CURRENT` only when the name is in the protected-branch set or its worktree path is in the protected-path set (`:368-371`).
5. `compute_protected` (`scripts/bash/cleanup_worktrees_enumerate_lib.sh:166-219`) emits only `protected-branch|<current branch of the invoking worktree>` (`:185`, `:196-198`), `protected-path|<primary worktree>` (`:211-212`), and `protected-path|<invoking worktree toplevel>` (`:213-214`). It never emits `main` by name.
6. With the primary worktree on `chore/cleanup` and `main` not checked out anywhere, rung 1 does not fire for `main`.
7. Rung 2, `classify_ancestry main` (`cleanup_worktrees_lib.sh:59-80`), runs `git merge-base --is-ancestor main main` (`:71`), which exits 0, yielding `MERGED_CLEAN` (`:72-73`).
8. The apply loop (`cleanup_worktrees_actions_lib.sh:410-435`) treats `MERGED_CLEAN` as delete-eligible (`:429-431`) and calls `delete_candidate main "${wt_of[main]:-}" MERGED_CLEAN`.
9. `delete_candidate` (`:326-354`) re-verifies through `reverify_delete_eligible` (`:247-279`), which again yields `MERGED_CLEAN`, then `delete_branch main` (`:310-324`) runs `git branch -D main` (`:317`).

Inaccurate in-code claims (research section 1.2):
- `cleanup_worktrees_report_records_lib.sh:391-394` (repeated at `:427-429`) states that `main` "needs no special handling: classify_branch resolves it PROTECTED_CURRENT at rung 1". This holds only when `main` is checked out in the primary or invoking worktree.
- `cleanup_worktrees_actions_lib.sh:361-362` (`run_apply` docstring) makes the same worktree-based claim.
- `check_main_freshness` (`cleanup_worktrees_enumerate_lib.sh:221-236`) is advisory only and does not protect `main`.

Linked-worktree topology (research section 4): when `main` is checked out in a linked worktree that is neither the primary nor the invoking worktree, `main` also classifies `MERGED_CLEAN`, and `delete_candidate` first removes that worktree through `remove_worktree_safe` (`cleanup_worktrees_actions_lib.sh:346`, unforced `git worktree remove` at `:292-295`) and then deletes the branch. This topology loses a worktree as well as the branch.

Cascade (research section 1.4): under the current driver, every `BRANCH` verdict is computed before the deletion loop (`cleanup_worktrees_actions_lib.sh:405-409`), so the printed `BRANCH` lines reflect pre-deletion verdicts. After `main` is deleted, each subsequent delete-eligible branch fails re-verification with `ANCESTRY_ERROR`, reported as `ACTION|delete|<name>|BLOCKED-REVERIFY` (`:260-263`), and `run_apply` returns non-zero. This was derived from reading the code and was not observed at runtime.

Why the existing suite did not detect the defect (research section 1.3): every existing scenario fixture places `main` on the primary worktree (for example `tests/fixtures/cleanup_worktrees/scenarios/current_exclusion/worktree-list.out:1-3`), so `main` is always protected by path. The only negative assertion, `tests/shell/test_cleanup_worktrees_cli.bats:57-58`, runs under `merged_with_worktree`, where `main` is on the primary worktree.

## Root Cause Analysis

Protection of the comparison base is derived from checkout topology rather than from the branch's role. `compute_protected` protects the current branch of the invoking worktree and the primary and invoking worktree paths; it has no rule that protects the base branch `main` by name. When `main` is not checked out in a protected worktree, the classification ladder evaluates `main` against itself, the self-ancestry test succeeds, and `main` is classified `MERGED_CLEAN` and becomes delete-eligible. The deletion path (`delete_candidate`) has no independent refusal for the base branch, so the misclassification proceeds to worktree removal (when applicable) and branch deletion.

The base branch name is the hard-coded literal `main` throughout the ladder (research section 2: `cleanup_worktrees_lib.sh`, `cleanup_worktrees_enumerate_lib.sh`, `cleanup_worktrees_actions_lib.sh`, `cleanup_worktrees_dirt_lib.sh`). There is no option or environment override for it.

## Scope & Non-Goals

In scope:
- Unconditional protection of the base branch `main` in `compute_protected`, so that `main` classifies `PROTECTED_CURRENT` in report mode and apply mode in every checkout topology.
- A defense-in-depth refusal of the base branch at the top of `delete_candidate`.
- A single non-overridable constant naming the base branch.
- Correction of the inaccurate comments, docstrings, help text, and both copies of the cleanup skill `SKILL.md`.
- Regression tests using the checked-in git stub and two new checked-in scenario fixture directories.

Non-goals:
- Making the base branch configurable (`--base` option or environment override), or replacing the ladder's literal `main` references with the constant (deferred; see D6).
- Protecting branches other than `main` (for example, other long-lived or remote-default branches).
- Introducing a new classification state name.
- Changes to the detached-worktree path (`cleanup_worktrees_detached_lib.sh`), which never deletes a branch.
- Changes to the dirt classifier (`cleanup_worktrees_dirt_lib.sh`), the git stub (`tests/fixtures/cleanup_worktrees/stub-bin/git`), the PowerShell cleanup-manifest module and its tests, or `.github/workflows/*`.
- The unrelated `Permission denied` / `BLOCKED-DIRTY` observation recorded in `issue.md` under Suspected Cause. It ended safely and is not addressed by this fix.
- Restoring or recreating a deleted `main`; the fix is preventive only.

Explicitly excluded test approaches:
- Scratch or throwaway git repositories, temporary files, reads of gitignored state (for example `artifacts/orchestration/`), references to `origin/*` refs, and Windows drive-root or `/mnt/c` paths. The issue's "throwaway fixture repo" validation idea is superseded by the checked-in stub mechanism (research section 5.1).

## Proposed Fix

### Design summary

1. **Base-branch constant.** Define `CLEANUP_WT_BASE_BRANCH="main"` in `scripts/bash/cleanup_worktrees_enumerate_lib.sh` as a plain assignment that is not environment-overridable, following the `CLEANUP_WT_CONSOLIDATION_BRANCH="documentationandmemories"` precedent (`cleanup_worktrees_actions_lib.sh:46`). `cleanup_worktrees_enumerate_lib.sh` is sourced first by the wrapper and by every bats harness. Place the constant below `enumerate_lib:116` so the citation at `cleanup_worktrees_detached_lib.sh:46` stays accurate.
2. **Unconditional protection in `compute_protected`.** Emit `protected-branch|$CLEANUP_WT_BASE_BRANCH` on every successful call:
   - after the two `rev-parse` hard-failure guards (`enumerate_lib:186-194`), so the fail-closed contract pinned by `tests/shell/test_cleanup_worktrees_hard_failures.bats:70-82` is unchanged;
   - skipped when the current branch already equals the base, so no duplicate `protected-branch|main` line is emitted.
   `main` then resolves `PROTECTED_CURRENT` at rung 1 of `classify_branch` regardless of which branch the primary worktree has checked out and regardless of whether `main` is checked out in a linked worktree, in both report mode and apply mode.
3. **Defense-in-depth refusal in `delete_candidate`.** At the top of `delete_candidate` (`cleanup_worktrees_actions_lib.sh:326`), when the candidate name equals `CLEANUP_WT_BASE_BRANCH`, emit `ACTION|delete|main|BLOCKED-PROTECTED-BASE` and return 1, before `reverify_delete_eligible`, `remove_worktree_safe`, or `delete_branch` runs.
4. **Documentation corrections.** Reword `cleanup_worktrees_report_records_lib.sh:391-394` and `:427-429`, `cleanup_worktrees_actions_lib.sh:361-362`, and `cleanup_worktrees_lib.sh:319-320` to cite the unconditional base protection. Update the `compute_protected` docstring (`enumerate_lib:167-183`) and file header (`:7`, `:29-32`). Add help text to `scripts/bash/cleanup-worktrees.sh` stating that `PROTECTED_CURRENT` also covers the base branch `main` and documenting the `BLOCKED-PROTECTED-BASE` action result. Update the invariant at `.claude/skills/cleanup-merged-worktrees/SKILL.md:521-527` (never mutate the base branch `main`) and its mirror at `extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/SKILL.md`, keeping the two copies in parity.
5. **Regression tests** through the checked-in stub scenario mechanism (see Test Strategy).

### Boundaries and invariants to preserve

- The classification state vocabulary is unchanged; no new state name is introduced.
- The state emitted for `main` in the existing topology (primary worktree on `main`) remains `BRANCH|main|PROTECTED_CURRENT`, so the nine golden reference files that contain that line remain byte-identical.
- The fail-closed behavior of `compute_protected` on `rev-parse` failure is unchanged.
- The detached-worktree path, which reads only `protected-path|` records (`cleanup_worktrees_detached_lib.sh:94-95`), is unaffected by an additional `protected-branch|` record.
- Line-number citations in comments elsewhere (`stub-bin/git:77-86` citing `actions_lib` lines up to `:317`; `detached_lib.sh:23`, `:46`) remain accurate because all insertions are placed below the cited lines.
- `scripts/bash/cleanup_worktrees_lib.sh` (496 lines at research baseline) remains at or below 500 lines; its change is a zero-net-line docstring reword.

### Dependencies or blocked work

None. The fix is self-contained in the cleanup-worktrees bash libraries, their tests and fixtures, and two SKILL.md copies.

### Implementation strategy

#### Files/modules to change

Production:
- `scripts/bash/cleanup_worktrees_enumerate_lib.sh` — constant, emission in `compute_protected`, docstring and header.
- `scripts/bash/cleanup_worktrees_actions_lib.sh` — refusal at top of `delete_candidate`, `run_apply` docstring, header note for `BLOCKED-PROTECTED-BASE`.
- `scripts/bash/cleanup_worktrees_lib.sh` — docstring reword only (`:319-320`), zero net lines.
- `scripts/bash/cleanup_worktrees_report_records_lib.sh` — comment corrections only (`:391-394`, `:427-429`).
- `scripts/bash/cleanup-worktrees.sh` — help text.
- `.claude/skills/cleanup-merged-worktrees/SKILL.md` and `extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/SKILL.md`.

Tests and fixtures:
- `tests/shell/test_cleanup_worktrees_enumeration.bats`, `tests/shell/test_cleanup_worktrees_classification.bats`, `tests/shell/test_cleanup_worktrees_deletion.bats`.
- New `tests/fixtures/cleanup_worktrees/scenarios/base_not_checked_out/` and `tests/fixtures/cleanup_worktrees/scenarios/base_in_linked_worktree/`.

Not touched: the golden files under `tests/fixtures/cleanup_worktrees/expected/`, `tests/fixtures/cleanup_worktrees/stub-bin/git`, `cleanup_worktrees_detached_lib.sh`, `cleanup_worktrees_dirt_lib.sh`, the PowerShell cleanup-manifest module and tests, `.github/workflows/*`.

#### Functions/classes/CLI commands impacted

- `compute_protected` — additional `protected-branch|main` record.
- `delete_candidate` — new early refusal branch.
- `classify_branch`, `classify_all_branches`, `run_report`, `run_apply` — behavior changes only through `compute_protected`; no code change beyond comments.
- `cleanup-worktrees.sh --help` — text addition.

#### Data flow and validation changes

`compute_protected` output gains one record in topologies where the current branch is not `main`. Rung 1 of `classify_branch` consumes it unchanged.

#### Error handling and logging updates

`delete_candidate` returns 1 with `ACTION|delete|main|BLOCKED-PROTECTED-BASE` on stdout for the base branch. This path is unreachable through `run_apply` once `compute_protected` protects `main`; it is exercised by direct calls.

#### Rollback/feature-flag considerations

No feature flag. Rollback is a revert of the change set.

### Technical specifications

#### Inputs/outputs and formats

- New record: `protected-branch|main` from `compute_protected`.
- New action result token: `ACTION|delete|main|BLOCKED-PROTECTED-BASE`.
- No change to `BRANCH|...` record format or state vocabulary.

#### Required configuration keys and defaults

`CLEANUP_WT_BASE_BRANCH="main"`, a library constant. It is not read from the environment and has no CLI option.

#### Backward-compatibility expectations

Existing report and apply output for the common topology is byte-identical. The only observable change in other topologies is that `main` reports `PROTECTED_CURRENT` instead of `MERGED_CLEAN` and is not deleted. The PowerShell manifest gate's allowlist (`CleanupWorktreeManifest.psm1:50`) is unaffected because no state name is added.

#### Performance constraints

No additional git invocations. The emission uses the constant and the already-computed current branch.

## Design Decisions

Each decision below was adopted per research recommendation; operator review not obtained.

### D1. Protect `main` by adding it to the protected-branch set in `compute_protected` and reusing `PROTECTED_CURRENT`

- Decision: emit `protected-branch|main` unconditionally from `compute_protected`; `main` classifies `PROTECTED_CURRENT`.
- Alternative considered: a new `PROTECTED_BASE` state through a dedicated rung in `classify_branch`.
- Rejection reason: `cleanup_worktrees_lib.sh` has 4 lines of headroom under the 500-line limit, which does not fit a new rung and its docstring. A new state churns the vocabulary across the script header, help text, detached header, and both SKILL.md copies. Placed before rung 1, it changes `main`'s state in the common topology and breaks nine byte-identity goldens and `tests/shell/test_cleanup_worktrees_classification.bats:110-112`. Placed after rung 1, `main`'s label depends on checkout topology.
- Status: adopted per research recommendation; operator review not obtained.

### D2. Keep `main` in branch enumeration

- Decision: `enumerate_branches` continues to emit `main`.
- Alternative considered: filtering `main` out of `enumerate_branches`.
- Rejection reason: it places policy in enumeration plumbing, removes `BRANCH|main|...` from the report and from nine goldens, breaks `tests/shell/test_cleanup_worktrees_enumeration.bats:26-27`, and changes the input to `run_report`'s early-abort probe.
- Status: adopted per research recommendation; operator review not obtained.

### D3. Fix classification, with the deletion-pass guard as a backstop only

- Decision: classification protection (D1) is the primary fix; the `delete_candidate` refusal (D4) is retained as defense in depth.
- Alternative considered: a guard in the deletion pass only.
- Rejection reason: report mode would still print `BRANCH|main|MERGED_CLEAN`, a misleading state that the cleanup skill's triage consumes.
- Status: adopted per research recommendation; operator review not obtained.

### D4. Place the backstop at the top of `delete_candidate`

- Decision: refuse the base branch at the top of `delete_candidate`, before re-verification, worktree removal, and branch deletion.
- Alternative considered: the guard in `delete_branch`.
- Rejection reason: `delete_branch` runs after `remove_worktree_safe`, so it would not prevent removal of a linked worktree checked out on `main`. `delete_branch` is also cited by line number in the stub header (`stub-bin/git`, citing `actions_lib:317`).
- Status: adopted per research recommendation; operator review not obtained.

### D5. Name the base with a hard-coded constant, not `origin/HEAD`

- Decision: `CLEANUP_WT_BASE_BRANCH="main"`, a plain, non-overridable constant.
- Alternative considered: deriving the protected base from `origin/HEAD` (`git symbolic-ref refs/remotes/origin/HEAD`).
- Rejection reason: it adds a git read to every `compute_protected` call (once per branch plus each re-verification) and a new fail-closed path; the ref may be absent in some clones; and it diverges from the ladder, which compares against the literal `main`. In this repository it resolves to `main`, which the constant already protects. It would also introduce an `origin/*` dependency into tests.
- Status: adopted per research recommendation; operator review not obtained.

### D6. Defer a configurable base branch

- Decision: the base is not configurable in this fix; the constant is not environment-overridable.
- Alternative considered: a `--base` option or environment override, with every ladder literal replaced by the constant.
- Rejection reason (deferred): the literal appears across four libraries, including `cleanup_worktrees_dirt_lib.sh` at 495/500 lines. This is a feature change beyond a Blocker fix. A partial override would let the guard protect one name while the ladder compares against another.
- Status: deferred; adopted per research recommendation; operator review not obtained.

### D7. Regression tests use the checked-in git stub, not a scratch repository

- Decision: new checked-in scenarios under `tests/fixtures/cleanup_worktrees/scenarios/`, driven through `CLEANUP_WT_GIT_BIN`, `CLEANUP_WT_SCAN_BIN`, and `CLEANUP_WT_STUB_SCENARIO`.
- Alternative considered: the issue's "throwaway fixture repo" validation idea.
- Rejection reason: every cleanup-worktrees suite states "No temporary files; no scratch git repositories", and repository test policy prohibits temporary files. Scratch repositories and `origin/*` references also carry the CI checkout-depth risk that failed sibling issue #660.
- Status: adopted per research recommendation; operator review not obtained.

## Assumptions, Constraints, Dependencies

- Assumptions: the base branch of this repository is `main`, and the ladder's literal `main` references remain the comparison base. Under the stub, `merge-base --is-ancestor main main` with no fixture exits 0 and `branch -D main` with no `.rc` fixture exits 0 (`stub-bin/git:222-237`), so the pre-fix defect reproduces deterministically under the new scenarios.
- Constraints: 500-line limit for production and test files; shfmt and shellcheck clean; kcov line coverage >= 85% (no branch-coverage gate for bash); tests must not depend on CI checkout depth or remote refs.
- Local execution: project memory records that agent worktrees text-deny `bash`/`wsl` invocations; CI (`.github/workflows/_shell-coverage.yml`, invoked from `.github/workflows/ci.yml`) is therefore the authoritative bats and kcov run. This constraint was not re-verified during research.
- External dependencies: none.

## Data / API / Config Impact

- User-facing changes: `main` reports `PROTECTED_CURRENT` in topologies where it previously reported `MERGED_CLEAN`; `main` is never deleted and a worktree checked out on `main` is never removed by this script. Help text documents the base protection and the `BLOCKED-PROTECTED-BASE` token.
- Data or migration considerations: none.
- Logging/telemetry: one new `ACTION` result token.
- Compatibility: no CLI flag or configuration change.

## Test Strategy

### Scenario fixtures (checked in, LF line endings)

`tests/fixtures/cleanup_worktrees/scenarios/base_not_checked_out/` (reported topology):
- `worktree-list.out`: one stanza — `worktree /repo/main`, `HEAD cccc0000`, `branch refs/heads/chore-cleanup`, blank line.
- `for-each-ref.out`: `chore-cleanup cccc0000`, `feature-merged bbbb1111`, `main aaaa0000`, `zeta-merged dddd3333` (LC_ALL=C order; `zeta-merged` sorts after `main`).
- `rev-parse.abbrev-ref-HEAD.out`: `chore-cleanup`.
- `rev-parse.show-toplevel.out`: `/repo/main`.
- No `origin_main` fixture, so `check_main_freshness` emits nothing.

`tests/fixtures/cleanup_worktrees/scenarios/base_in_linked_worktree/`: the same files, with `worktree-list.out` gaining a second stanza — `worktree /repo-wt/base`, `HEAD aaaa0000`, `branch refs/heads/main`.

### Tests to add

The test names below are the required `@test` names; the acceptance criteria reference them.

`tests/shell/test_cleanup_worktrees_enumeration.bats`:
- T1 `compute_protected emits protected-branch main when the primary worktree is on another branch` — scenario `base_not_checked_out`; output contains `protected-branch|main` and `protected-branch|chore-cleanup`.
- T2 `compute_protected emits protected-branch main under current_exclusion` — scenario `current_exclusion`; existing assertions plus `protected-branch|main`.
- T3 `compute_protected emits exactly one protected-branch main when the current branch is main` — a scenario whose current branch is `main`; exactly one `protected-branch|main` line.

`tests/shell/test_cleanup_worktrees_classification.bats`:
- T4 `classify_branch main is PROTECTED_CURRENT when the primary worktree is on another branch` — `base_not_checked_out`; equals `BRANCH|main|PROTECTED_CURRENT`.
- T5 `classify_branch main is PROTECTED_CURRENT when main is checked out in a linked worktree` — `base_in_linked_worktree`; equals `BRANCH|main|PROTECTED_CURRENT`.

`tests/shell/test_cleanup_worktrees_deletion.bats`:
- T6 `run_report classifies main PROTECTED_CURRENT when the primary worktree is on another branch` — `base_not_checked_out`; output contains `BRANCH|main|PROTECTED_CURRENT` and lacks `BRANCH|main|MERGED_CLEAN`.
- T7 `run_apply does not delete main when the primary worktree is on another branch` — `base_not_checked_out`; output contains `BRANCH|main|PROTECTED_CURRENT`; output lacks `branch -D main`, `ACTION|branch-delete|main|`, and `BRANCH|main|MERGED_CLEAN`; positive controls `ACTION|branch-delete|feature-merged|OK` and `ACTION|branch-delete|zeta-merged|OK`.
- T8 `run_apply neither removes nor deletes main checked out in a linked worktree` — `base_in_linked_worktree`; output contains `BRANCH|main|PROTECTED_CURRENT`; output lacks `worktree remove /repo-wt/base`, `branch -D main`, and `ACTION|branch-delete|main|`.
- T9 `delete_candidate refuses the base branch before re-verification` — direct `delete_candidate main "" MERGED_CLEAN`; status 1; output contains `ACTION|delete|main|BLOCKED-PROTECTED-BASE`; stub argv log contains no `merge-base`, `worktree remove`, or `branch -D`.
- T10 `delete_candidate refuses the base branch before removing its linked worktree` — direct `delete_candidate main /repo-wt/base MERGED_CLEAN`; status 1; output contains `ACTION|delete|main|BLOCKED-PROTECTED-BASE`; no `worktree remove` argv.

Tests T1 and T4 through T10 fail before the fix and pass after it. T2 fails before the fix when the `current_exclusion` scenario's current branch is not `main`. T3 is expected to pass before the fix; it pins the no-duplicate property of the new emission. All ten pass after the fix.

### Regression pins that must stay green unchanged

- `tests/shell/test_cleanup_worktrees_dirt_regression.bats:40-63` against the golden files in `tests/fixtures/cleanup_worktrees/expected/`.
- `tests/shell/test_cleanup_worktrees_classification.bats:105-113`.
- `tests/shell/test_cleanup_worktrees_hard_failures.bats:70-82` (`rev_parse_error_protection`).
- `tests/shell/test_cleanup_worktrees_cli.bats:48-59`.

### Toolchain

- Format and lint: `bash scripts/bash/shell-qc.sh check` (shfmt 3.8.0 diff and shellcheck).
- Tests: `bash scripts/bash/shell-qc.sh test`; single file: `bats tests/shell/<file>.bats`.
- Coverage: `SHELL_QC_KCOV_OUT_DIR=docs/features/active/2026-08-29-cleanup-worktrees-apply-deletes-local-main-594/evidence/qa-gates/kcov bash scripts/bash/shell-qc.sh test --coverage`, then read the per-file `line-rate` for each changed production file from the merged `cov.xml` in that directory. `run_test_coverage` prints but does not enforce a threshold, so the 85% check is made against `cov.xml`. When the authoritative run is CI, use the `artifacts/pester/kcov/**` artifact uploaded by `.github/workflows/_shell-coverage.yml` and copy the relevant evidence into `<FEATURE>/evidence/qa-gates/kcov/`.

### Manual validation (post-merge, not an acceptance criterion)

After merge, running `--apply` in the live repository with a non-`main` branch checked out in the primary worktree should leave `git branch --list main` returning `main`. This is not an acceptance criterion because it mutates live repository state.

## Acceptance Criteria

- [ ] `scripts/bash/cleanup_worktrees_enumerate_lib.sh` defines `CLEANUP_WT_BASE_BRANCH="main"` as a plain assignment that does not read from the environment (verified by `rg -n 'CLEANUP_WT_BASE_BRANCH=' scripts/bash/` returning exactly one definition, of the form `CLEANUP_WT_BASE_BRANCH="main"`, with no `${CLEANUP_WT_BASE_BRANCH:-` default-expansion form anywhere in `scripts/bash/`).
- [ ] `compute_protected` emits `protected-branch|main` when the primary worktree is on a branch other than `main` (bats test T1 `compute_protected emits protected-branch main when the primary worktree is on another branch` in `tests/shell/test_cleanup_worktrees_enumeration.bats` passes).
- [ ] `compute_protected` emits `protected-branch|main` under the existing `current_exclusion` scenario while all prior assertions for that scenario still hold (bats test T2 `compute_protected emits protected-branch main under current_exclusion` passes).
- [ ] `compute_protected` emits exactly one `protected-branch|main` line when the current branch is `main` (bats test T3 `compute_protected emits exactly one protected-branch main when the current branch is main` passes).
- [ ] `classify_branch main` returns `BRANCH|main|PROTECTED_CURRENT` when the primary worktree is on another branch (bats test T4 in `tests/shell/test_cleanup_worktrees_classification.bats` passes).
- [ ] `classify_branch main` returns `BRANCH|main|PROTECTED_CURRENT` when `main` is checked out in a linked worktree (bats test T5 in `tests/shell/test_cleanup_worktrees_classification.bats` passes).
- [ ] Report mode classifies `main` as `PROTECTED_CURRENT`, not `MERGED_CLEAN`, when the primary worktree is on another branch (bats test T6 `run_report classifies main PROTECTED_CURRENT when the primary worktree is on another branch` in `tests/shell/test_cleanup_worktrees_deletion.bats` passes).
- [ ] Apply mode classifies `main` as `PROTECTED_CURRENT` and does not run `git branch -D main` when the primary worktree is on another branch, while `feature-merged` and `zeta-merged` (which sorts after `main`) are still deleted with `ACTION|branch-delete|<name>|OK` (bats test T7 `run_apply does not delete main when the primary worktree is on another branch` passes).
- [ ] Apply mode neither removes the linked worktree `/repo-wt/base` checked out on `main` nor deletes `main` (bats test T8 `run_apply neither removes nor deletes main checked out in a linked worktree` passes).
- [ ] `delete_candidate main "" MERGED_CLEAN` returns 1, emits `ACTION|delete|main|BLOCKED-PROTECTED-BASE`, and invokes no `merge-base`, `worktree remove`, or `branch -D` git command (bats test T9 `delete_candidate refuses the base branch before re-verification` passes).
- [ ] `delete_candidate main /repo-wt/base MERGED_CLEAN` returns 1 with `ACTION|delete|main|BLOCKED-PROTECTED-BASE` and invokes no `worktree remove` git command (bats test T10 `delete_candidate refuses the base branch before removing its linked worktree` passes).
- [ ] All tests in every existing `tests/shell/test_cleanup_worktrees_*.bats` file pass without modification to their pre-existing test bodies (verified by `bash scripts/bash/shell-qc.sh test` or the CI `_shell-coverage.yml` job reporting zero failures, and by `git diff origin/main -- tests/shell/` showing only added lines in the three files named in Test Strategy).
- [ ] The golden reference files under `tests/fixtures/cleanup_worktrees/expected/` are unchanged, including the nine that contain `BRANCH|main|PROTECTED_CURRENT` (verified by `git diff --exit-code origin/main -- tests/fixtures/cleanup_worktrees/expected/` exiting 0, and by `tests/shell/test_cleanup_worktrees_dirt_regression.bats` passing).
- [ ] No new classification state name is introduced (verified by the `BRANCH` state list in the `cleanup_worktrees_lib.sh` header and in `cleanup-worktrees.sh --help` being unchanged except for explanatory text, and by `rg -n 'PROTECTED_BASE\b' scripts/bash/` returning only occurrences of the action token `BLOCKED-PROTECTED-BASE`).
- [ ] The inaccurate comments are corrected: `cleanup_worktrees_report_records_lib.sh` no longer states that `main` needs no special handling because it is resolved by worktree position, and the `run_apply` docstring in `cleanup_worktrees_actions_lib.sh` and the `classify_branch` docstring in `cleanup_worktrees_lib.sh` cite the unconditional base protection (verified by `rg -n 'needs no special handling' scripts/bash/` returning no match that attributes `main`'s protection to worktree checkout alone, and by review of the three docstrings).
- [ ] `bash scripts/bash/cleanup-worktrees.sh --help` output states that `PROTECTED_CURRENT` also covers the base branch `main` and documents the `BLOCKED-PROTECTED-BASE` action result.
- [ ] Both copies of the cleanup skill (`.claude/skills/cleanup-merged-worktrees/SKILL.md` and `extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/SKILL.md`) state that the base branch `main` is never deleted and its worktree is never removed, and the two files are byte-identical (verified by `git diff --no-index --exit-code` between the two paths exiting 0).
- [ ] Every changed or added production and test shell file is at or below 500 lines, and `scripts/bash/cleanup_worktrees_lib.sh` is at or below 500 lines (verified by `wc -l` over each changed file).
- [ ] `bash scripts/bash/shell-qc.sh check` reports no shfmt diff and no shellcheck findings for all changed shell and bats files (or the CI `_shell-coverage.yml` check step passes).
- [ ] kcov line coverage is >= 85% for each of `scripts/bash/cleanup_worktrees_enumerate_lib.sh` and `scripts/bash/cleanup_worktrees_actions_lib.sh`, and every line added to `compute_protected` and `delete_candidate` is executed by at least one test (verified from the per-file `line-rate` and per-line hits in the merged kcov `cov.xml`, with the coverage evidence stored under `docs/features/active/2026-08-29-cleanup-worktrees-apply-deletes-local-main-594/evidence/qa-gates/kcov/`).
- [ ] The new tests and scenario fixtures are independent of remote refs and CI checkout depth: they invoke git only through `CLEANUP_WT_GIT_BIN` pointing at `tests/fixtures/cleanup_worktrees/stub-bin/git`, and `rg -n 'origin/|/mnt/|[A-Za-z]:[\\/]|mktemp|artifacts/'` over the added test lines and the two new scenario directories returns no match.
- [ ] The new tests create no files outside the checked-in fixture tree and use no scratch git repository (verified by review of the added `@test` bodies containing no `git init`, `mktemp`, `BATS_TMPDIR`, `BATS_TEST_TMPDIR`, or output redirection to a file path).
- [ ] The CI `_shell-coverage.yml` job for the pull request passes on `ubuntu-latest` with the default checkout depth.

## Risks & Mitigations

- Risk: `PROTECTED_CURRENT` is an imprecise label for a branch that is not checked out. Mitigation: help text and both SKILL.md copies document that the state also covers the base branch (D1).
- Risk: the backstop in `delete_candidate` is unreachable through `run_apply` and could regress silently. Mitigation: direct-call tests T9 and T10.
- Risk: a future change that makes the base configurable could desynchronize protection from comparison. Mitigation: the constant is non-overridable; configurability is deferred to a separate change that replaces all ladder literals together (D6).
- Risk: local bats execution may be unavailable in agent worktrees. Mitigation: CI `_shell-coverage.yml` is the authoritative run.

## Rollout & Follow-up

- Release: merge to `main` through the standard pull-request flow; no staged rollout.
- Follow-up candidates (not in scope): configurable base branch (D6); the `Permission denied` / `BLOCKED-DIRTY` observation recorded in `issue.md`.
- Links: issue #594 (https://github.com/drmoisan/drm-copilot/issues/594); research `research/research.2026-09-25T22-10.md`; sibling CI-depth failure #660.
