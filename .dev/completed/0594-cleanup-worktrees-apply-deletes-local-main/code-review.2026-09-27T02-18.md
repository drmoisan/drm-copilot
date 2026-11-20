# Code Review: cleanup-worktrees base-branch protection (#594)

**Review Date:** 2026-09-27 (UTC)
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-08-29-cleanup-worktrees-apply-deletes-local-main-594/`
**Base Branch:** `origin/main` (merge base `b67453837646fd2dd4f5ac692f76e6f7703fe798`)
**Head Branch:** `bug/cleanup-worktrees-apply-deletes-local-main-594` at `c00d9587`
**Review Type:** Initial review

---

## Executive Summary

The change closes a destructive defect: `compute_protected` protected only the invoking worktree's branch and the primary and invoking worktree paths, so when `main` was not checked out in a protected worktree, `main` was evaluated against itself, classified `MERGED_CLEAN`, and deleted by `--apply` (plus its linked worktree, if any). The fix protects `main` by name in `compute_protected` and adds a refusal at the top of `delete_candidate`. The production delta is one constant and eight executable lines across two libraries, plus comment, help-text, and skill corrections. Ten bats tests and two stub scenario directories cover both topologies and the backstop.

**What changed:**
- `scripts/bash/cleanup_worktrees_enumerate_lib.sh:166-169` — `CLEANUP_WT_BASE_BRANCH="main"`, a source-time plain assignment (environment values are overwritten).
- `scripts/bash/cleanup_worktrees_enumerate_lib.sh:210-214` — `protected-branch|main` emitted after both `rev-parse` guards, skipped when the current branch is already `main`.
- `scripts/bash/cleanup_worktrees_actions_lib.sh:343-349` — `delete_candidate` returns 1 with `ACTION|delete|main|BLOCKED-PROTECTED-BASE` before `reverify_delete_eligible`, `remove_worktree_safe`, or `delete_branch`.
- Comment corrections in `cleanup_worktrees_lib.sh`, `cleanup_worktrees_report_records_lib.sh`, `cleanup_worktrees_actions_lib.sh`; help text in `cleanup-worktrees.sh:124-127`; a new invariant bullet in both SKILL.md copies.

**Top 3 risks:**
1. The `delete_candidate` backstop is unreachable through `run_apply`; its regression protection depends entirely on T9/T10, one of whose negative assertions is not observable (first Non-blocking finding in the Findings Table).
2. `PROTECTED_CURRENT` now also labels a branch that is not checked out anywhere; consumers that read the label as "checked out here" could misinterpret it. This was an explicit, operator-approved design choice (D1) and is documented in help text and the skill.
3. The base name is hard-coded; a repository whose base is not `main` is unprotected. This matches the ladder's existing literal `main` and is deferred by D6.

**PR readiness recommendation:** **Go** — no Blocking findings; the fix is minimal, correctly ordered relative to the fail-closed guards, verified by fail-before/pass-after and a successful CI run with unchanged coverage.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Non-blocking | `tests/shell/test_cleanup_worktrees_deletion.bats` | T9, `[[ "$output" != *"merge-base"* ]]` | The assertion cannot fail through re-verification: `classify_ancestry` runs `merge-base --is-ancestor` with `>/dev/null 2>&1`, so the stub's `stub-git:` stderr line is discarded. The guard ordering is still pinned indirectly, because a guard placed after re-verification would emit `BLOCKED-REVERIFY` instead of `BLOCKED-PROTECTED-BASE`. | In a follow-up, assert `[[ "$output" != *"stub-git:"* ]]` (the guard issues no git call), which also covers `rev-parse` and `worktree list` issued by `classify_branch`. | A vacuous negative assertion overstates what the test proves about the "invokes no merge-base" clause of AC-10. | `scripts/bash/cleanup_worktrees_lib.sh:71`; `tests/fixtures/cleanup_worktrees/stub-bin/git:107`; `tests/shell/test_cleanup_worktrees_dirt_clear.bats` header "OBSERVABILITY" note |
| Non-blocking | `tests/shell/test_cleanup_worktrees_dirt_clear.bats` | line 14 | Cites `scripts/bash/cleanup-worktrees.sh:145` for the flag pre-pass; the line is `:197` on HEAD and was `:192` at the merge base. Pre-existing staleness, increased by the 5-line help insertion. | File a follow-up to replace the line number with a function or text anchor. Not changed here because AC-12 forbids modifying pre-existing test bodies. | Stale citations mislead maintainers. | `grep -n CLEANUP_WT_CLEAR_DISPOSABLE= scripts/bash/cleanup-worktrees.sh` -> 197; same grep at `b6745383` -> 192 |
| Informational | `scripts/bash/cleanup_worktrees_lib.sh` | line 7 (file header) | Header still summarizes `compute_protected` as "the current-worktree/branch protection set". | Optional wording update in a later change; the spec required only the `:319-320` docstring, which was updated. | Documentation completeness. | File inspection |
| Informational | `scripts/bash/cleanup_worktrees_actions_lib.sh` | lines 6-7 (file header) | Header names the "base-branch refusal" but not the `BLOCKED-PROTECTED-BASE` token. | None required; the `delete_candidate` docstring, `--help`, and SKILL.md name the token. | Documentation completeness. | File inspection |
| Informational | `scripts/bash/cleanup_worktrees_enumerate_lib.sh` | line 169 | The constant is not `readonly`. | None; `readonly` would make re-sourcing in bats subshells fail, and the precedent `CLEANUP_WT_CONSOLIDATION_BRANCH` is also a plain assignment. It cannot be overridden from the environment because sourcing reassigns it. | Confirms the "non-overridable" claim is accurate in its intended sense. | File inspection; `grep 'CLEANUP_WT_BASE_BRANCH:-' scripts/bash/` returns nothing |
| Informational | `scripts/bash/cleanup_worktrees_detached_lib.sh` | lines 88-99 | The detached path reads only `protected-path|` records and is unaffected by the new `protected-branch|` record. | None. | Confirms no side effect on an untouched consumer. | File inspection |
| Informational | all destructive call sites | `cleanup_worktrees_actions_lib.sh:191,198,292,317` | The only other `worktree remove` / `branch -D` call sites act on the consolidation branch constant or on detached worktrees; neither can target `main`. | None. | Confirms the fix covers every branch-deletion path. | `grep -n 'branch -D\|worktree remove' scripts/bash/` |

Total blocking findings: 0. Non-blocking: 2. Informational: 5.

---

## Implementation Audit

### Bash implementation audit

#### What changed well

- The new record is emitted after the two `rev-parse` guards, so the fail-closed contract pinned by `test_cleanup_worktrees_hard_failures.bats` is unchanged and a failure still yields no weakened protected set.
- The duplicate-suppression condition `[[ $current_branch != "$CLEANUP_WT_BASE_BRANCH" ]]` also correctly emits the base record in the detached-HEAD case (`current_branch=HEAD`).
- The backstop sits before `reverify_delete_eligible`, so it prevents linked-worktree removal as well as branch deletion (D4 rationale holds on inspection).
- No new git invocation; the change reuses the rung-1 consumer (`prot_branch` associative array in `classify_branch`), which accepts multiple `protected-branch|` records.
- Line-number citations elsewhere (stub header citing `actions_lib:317`; `detached_lib` citing enumerate_lib) remain accurate because insertions were placed below them.

#### API and safety notes

- No function signature or output record format changed; the only new token is the action result `BLOCKED-PROTECTED-BASE`.
- The `delete_candidate` refusal returns 1, which `run_apply` would fold into a non-zero exit if ever reached; this is consistent with the other `BLOCKED-*` results.

#### Error handling and logging

- The refusal is emitted on stdout in the same `ACTION|...` record format as other results; no silent path.

---

## Test Quality Audit

Fail-before shows exactly the nine expected failures (T3 passes by design, pinning no-duplication), each failing on a `main` assertion rather than a fixture or syntax error. Pass-after is 52/52, the local cleanup suites 241/241, and CI 473/473 with `Bash coverage (lines): 93.3%`. The reviewer confirmed the CI run conclusion and step results with `gh run view 36287146354`, re-read per-file line rates and added-line hits from the downloaded `cov.xml`, and confirmed no code/test/skill path changed after the CI SHA `e29ad95d`.

### Reviewed test and QA artifacts

- `tests/shell/test_cleanup_worktrees_enumeration.bats` (T1-T3) — protection-set output in three topologies.
- `tests/shell/test_cleanup_worktrees_classification.bats` (T4-T5) — rung-1 classification in the reported and linked-worktree topologies.
- `tests/shell/test_cleanup_worktrees_deletion.bats` (T6-T10) — report mode, apply mode with positive controls, and direct backstop calls. bats `run` merges stderr into `$output`, so the `branch -D main` and `worktree remove /repo-wt/base` negative assertions observe the stub argv log (those calls redirect stdout only). See the first Non-blocking finding for the one unobservable assertion.
- `tests/fixtures/cleanup_worktrees/scenarios/base_not_checked_out/`, `base_in_linked_worktree/` — LF-only, contents match the spec's Test Strategy exactly.
- `evidence/regression-testing/fail-before.2026-09-27T01-33.md`, `pass-after.2026-09-27T01-40.md`, `evidence/qa-gates/ci-shell-coverage.2026-09-27T02-00.md`, `coverage-delta.2026-09-27T02-15.md`, `kcov/added-line-hits.2026-09-27T02-14.md`.

### Quality assessment prompts

- **Determinism:** git and filesystem scan are stubbed; no remote refs, clock, or randomness.
- **Isolation:** each test targets one function in one scenario.
- **Speed:** stub-driven; no real repository operations.
- **Diagnostics:** bats prints the failing assertion; names state the scenario and expectation.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | PASS | Diff inspection |
| No unsafe subprocess or command construction | PASS | All expansions quoted; git invoked through the existing `cleanup_wt_git` seam |
| Input validation at boundaries | PASS | Branch-name comparison is an exact string match against a constant |
| Error handling remains explicit | PASS | Refusal returns 1 with an ACTION record; fail-closed guards precede the new emission |
| Configuration / path handling is safe | PASS | Constant cannot be overridden from the environment; no new path handling |

---

## Research Log

No external research was required. Behavior was established by reading `scripts/bash/cleanup_worktrees_{enumerate,actions,lib,report_records,detached}_lib.sh`, the git stub, the bats harnesses, and the CI run and coverage artifact.

---

## Verdict

The change is ready for the normal PR flow. It is a minimal, correctly placed fix for a Blocker-severity data-loss defect, with regression tests that fail before and pass after, unchanged golden outputs, and coverage that is unchanged or higher on every modified file. The two Non-blocking findings concern test-assertion strength and a pre-existing stale citation in a file this change is not permitted to modify; both are suitable follow-ups. Total blocking findings: 0.
