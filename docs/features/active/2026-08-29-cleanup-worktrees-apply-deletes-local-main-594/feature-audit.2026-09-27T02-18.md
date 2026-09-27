# Feature Audit: cleanup-worktrees base-branch protection (#594)

**Audit Date:** 2026-09-27 (UTC)
**Feature Folder:** `docs/features/active/2026-08-29-cleanup-worktrees-apply-deletes-local-main-594/`
**Base Branch:** `origin/main`
**Head Branch:** `bug/cleanup-worktrees-apply-deletes-local-main-594`
**Work Mode:** `full-bug`
**Audit Type:** Initial acceptance review

---

## Scope and Baseline

- **Base branch:** `origin/main`, merge base `b67453837646fd2dd4f5ac692f76e6f7703fe798`
- **Head branch/commit:** `bug/cleanup-worktrees-apply-deletes-local-main-594` at `c00d9587a5568caacfe17e56198e60eeae09f540` (plus two uncommitted plan check marks and the untracked `evidence/other/commit-final.2026-09-27T02-23.md`, neither affecting code)
- **Merge base:** `b67453837646fd2dd4f5ac692f76e6f7703fe798`
- **Evidence sources:**
  - Primary: `git diff b6745383 HEAD` (77 paths) and direct file inspection. `artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt` are absent in this worktree; the reviewer used the git diff directly as the equivalent full-baseline source rather than generating new files under `artifacts/`.
  - Secondary baseline diff: `git diff 92d78897 HEAD` (caller-supplied base; differs only by three feature-folder Markdown files)
  - Feature evidence: `evidence/{baseline,regression-testing,qa-gates,other}/`
  - Additional evidence: CI run 36287146354 (`gh run view`, and the `shell-coverage` artifact `cov.xml` downloaded to the session scratchpad)
- **Feature folder used:** `docs/features/active/2026-08-29-cleanup-worktrees-apply-deletes-local-main-594/`
- **Requirements source:** `spec.md` only
- **Work mode resolution note:** `issue.md` contains the explicit marker `- Work Mode: full-bug`; per the routing rules the AC source is `spec.md` only.
- **Scope note:** The plan's literal base `0658f694` was replaced by its rebased counterpart `92d78897` (DEV-1, `evidence/baseline/base-sha.2026-09-27T01-08.md`). The reviewer used the merge base with `origin/main` so the audit covers the full branch; see `policy-audit.2026-09-27T02-18.md` section "Rejected Scope Narrowing".

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-08-29-cleanup-worktrees-apply-deletes-local-main-594/spec.md` — only source (`## Acceptance Criteria`, 23 checkbox items)

### Acceptance criteria

1. `scripts/bash/cleanup_worktrees_enumerate_lib.sh` defines `CLEANUP_WT_BASE_BRANCH="main"` as a plain assignment that does not read from the environment (verified by `rg -n 'CLEANUP_WT_BASE_BRANCH=' scripts/bash/` returning exactly one definition, of the form `CLEANUP_WT_BASE_BRANCH="main"`, with no `${CLEANUP_WT_BASE_BRANCH:-` default-expansion form anywhere in `scripts/bash/`).
2. `compute_protected` emits `protected-branch|main` when the primary worktree is on a branch other than `main` (bats test T1 `compute_protected emits protected-branch main when the primary worktree is on another branch` in `tests/shell/test_cleanup_worktrees_enumeration.bats` passes).
3. `compute_protected` emits `protected-branch|main` under the existing `current_exclusion` scenario while all prior assertions for that scenario still hold (bats test T2 `compute_protected emits protected-branch main under current_exclusion` passes).
4. `compute_protected` emits exactly one `protected-branch|main` line when the current branch is `main` (bats test T3 `compute_protected emits exactly one protected-branch main when the current branch is main` passes).
5. `classify_branch main` returns `BRANCH|main|PROTECTED_CURRENT` when the primary worktree is on another branch (bats test T4 in `tests/shell/test_cleanup_worktrees_classification.bats` passes).
6. `classify_branch main` returns `BRANCH|main|PROTECTED_CURRENT` when `main` is checked out in a linked worktree (bats test T5 in `tests/shell/test_cleanup_worktrees_classification.bats` passes).
7. Report mode classifies `main` as `PROTECTED_CURRENT`, not `MERGED_CLEAN`, when the primary worktree is on another branch (bats test T6 `run_report classifies main PROTECTED_CURRENT when the primary worktree is on another branch` in `tests/shell/test_cleanup_worktrees_deletion.bats` passes).
8. Apply mode classifies `main` as `PROTECTED_CURRENT` and does not run `git branch -D main` when the primary worktree is on another branch, while `feature-merged` and `zeta-merged` (which sorts after `main`) are still deleted with `ACTION|branch-delete|<name>|OK` (bats test T7 `run_apply does not delete main when the primary worktree is on another branch` passes).
9. Apply mode neither removes the linked worktree `/repo-wt/base` checked out on `main` nor deletes `main` (bats test T8 `run_apply neither removes nor deletes main checked out in a linked worktree` passes).
10. `delete_candidate main "" MERGED_CLEAN` returns 1, emits `ACTION|delete|main|BLOCKED-PROTECTED-BASE`, and invokes no `merge-base`, `worktree remove`, or `branch -D` git command (bats test T9 `delete_candidate refuses the base branch before re-verification` passes).
11. `delete_candidate main /repo-wt/base MERGED_CLEAN` returns 1 with `ACTION|delete|main|BLOCKED-PROTECTED-BASE` and invokes no `worktree remove` git command (bats test T10 `delete_candidate refuses the base branch before removing its linked worktree` passes).
12. All tests in every existing `tests/shell/test_cleanup_worktrees_*.bats` file pass without modification to their pre-existing test bodies (verified by `bash scripts/bash/shell-qc.sh test` or the CI `_shell-coverage.yml` job reporting zero failures, and by `git diff origin/main -- tests/shell/` showing only added lines in the three files named in Test Strategy).
13. The golden reference files under `tests/fixtures/cleanup_worktrees/expected/` are unchanged, including the nine that contain `BRANCH|main|PROTECTED_CURRENT` (verified by `git diff --exit-code origin/main -- tests/fixtures/cleanup_worktrees/expected/` exiting 0, and by `tests/shell/test_cleanup_worktrees_dirt_regression.bats` passing).
14. No new classification state name is introduced (verified by the `BRANCH` state list in the `cleanup_worktrees_lib.sh` header and in `cleanup-worktrees.sh --help` being unchanged except for explanatory text, and by `rg -n 'PROTECTED_BASE\b' scripts/bash/` returning only occurrences of the action token `BLOCKED-PROTECTED-BASE`).
15. The inaccurate comments are corrected: `cleanup_worktrees_report_records_lib.sh` no longer states that `main` needs no special handling because it is resolved by worktree position, and the `run_apply` docstring in `cleanup_worktrees_actions_lib.sh` and the `classify_branch` docstring in `cleanup_worktrees_lib.sh` cite the unconditional base protection (verified by `rg -n 'needs no special handling' scripts/bash/` returning no match that attributes `main`'s protection to worktree checkout alone, and by review of the three docstrings).
16. `bash scripts/bash/cleanup-worktrees.sh --help` output states that `PROTECTED_CURRENT` also covers the base branch `main` and documents the `BLOCKED-PROTECTED-BASE` action result.
17. Both copies of the cleanup skill (`.claude/skills/cleanup-merged-worktrees/SKILL.md` and `extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/SKILL.md`) state that the base branch `main` is never deleted and its worktree is never removed, and the two files are byte-identical (verified by `git diff --no-index --exit-code` between the two paths exiting 0).
18. Every changed or added production and test shell file is at or below 500 lines, and `scripts/bash/cleanup_worktrees_lib.sh` is at or below 500 lines (verified by `wc -l` over each changed file).
19. `bash scripts/bash/shell-qc.sh check` reports no shfmt diff and no shellcheck findings for all changed shell and bats files (or the CI `_shell-coverage.yml` check step passes).
20. kcov line coverage is >= 85% for each of `scripts/bash/cleanup_worktrees_enumerate_lib.sh` and `scripts/bash/cleanup_worktrees_actions_lib.sh`, and every line added to `compute_protected` and `delete_candidate` is executed by at least one test (verified from the per-file `line-rate` and per-line hits in the merged kcov `cov.xml`, with the coverage evidence stored under `docs/features/active/2026-08-29-cleanup-worktrees-apply-deletes-local-main-594/evidence/qa-gates/kcov/`).
21. The new tests and scenario fixtures are independent of remote refs and CI checkout depth: they invoke git only through `CLEANUP_WT_GIT_BIN` pointing at `tests/fixtures/cleanup_worktrees/stub-bin/git`, and `rg -n 'origin/|/mnt/|[A-Za-z]:[\\/]|mktemp|artifacts/'` over the added test lines and the two new scenario directories returns no match.
22. The new tests create no files outside the checked-in fixture tree and use no scratch git repository (verified by review of the added `@test` bodies containing no `git init`, `mktemp`, `BATS_TMPDIR`, `BATS_TEST_TMPDIR`, or output redirection to a file path).
23. The CI `_shell-coverage.yml` job for the pull request passes on `ubuntu-latest` with the default checkout depth.

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | Base-branch constant, not environment-read | PASS | Single match `scripts/bash/cleanup_worktrees_enumerate_lib.sh:169:CLEANUP_WT_BASE_BRANCH="main"`; no `CLEANUP_WT_BASE_BRANCH:-` form | Grep `CLEANUP_WT_BASE_BRANCH=\|CLEANUP_WT_BASE_BRANCH:-` over `scripts/bash` (reviewer) | Source-time assignment overwrites any environment value |
| 2 | T1 compute_protected, other branch | PASS | `ok 353` in CI run 36287146354; `ok 13` locally; `not ok 13` before the fix | `gh run view 36287146354`; pass-after/fail-before evidence | |
| 3 | T2 compute_protected under current_exclusion | PASS | CI `ok 354`; prior assertions retained in the test body | same | |
| 4 | T3 exactly one record when current is main | PASS | CI `ok 355`; `grep -c -x -F` counts exactly 1 | same | Passes before the fix by design |
| 5 | T4 classify_branch, other branch | PASS | CI `ok 207`; fail-before `not ok 35` | same | |
| 6 | T5 classify_branch, linked worktree | PASS | CI `ok 208`; fail-before `not ok 36` | same | |
| 7 | T6 report mode | PASS | CI `ok 237`; fail-before `not ok 48` | same | |
| 8 | T7 apply mode, positive controls | PASS | CI `ok 238`; test asserts `feature-merged` and `zeta-merged` `OK` | same | `branch -D main` negative assertion is observable (stderr merged by `run`) |
| 9 | T8 linked worktree not removed | PASS | CI `ok 239`; `worktree remove` stderr argv observable | same | |
| 10 | T9 delete_candidate refuses before re-verification | PASS | CI `ok 240`; fail-before `not ok 51`; code inspection shows the guard at `cleanup_worktrees_actions_lib.sh:346-349` returns before any git call | same, plus file inspection | Non-blocking: the `merge-base` negative assertion is not observable because `classify_ancestry` discards both streams (`cleanup_worktrees_lib.sh:71`); the property holds by inspection and by the token/status assertions |
| 11 | T10 delete_candidate, linked worktree | PASS | CI `ok 241`; fail-before `not ok 52` | same | |
| 12 | Existing suites pass unmodified | PASS | CI 473 ok / 0 not ok; `git diff b6745383 HEAD -- tests/shell` has 0 removed lines, changes only in the three named files | `git diff b6745383 HEAD -- tests/shell` (reviewer) | |
| 13 | Goldens unchanged | PASS | `git diff --exit-code b6745383 HEAD -- tests/fixtures/cleanup_worktrees/expected/` exit 0; dirt_regression passes in CI | reviewer command | |
| 14 | No new state name | PASS | Grep `PROTECTED_BASE\b` matches only the `BLOCKED-PROTECTED-BASE` token; `cleanup_worktrees_lib.sh` state list lines unchanged in the diff; help adds explanatory text only | Grep over `scripts/bash` (reviewer); diff inspection | |
| 15 | Inaccurate comments corrected | PASS | Grep `needs no special handling` over `scripts/bash` returns no match; `run_apply` (`actions_lib:373-377`) and `classify_branch` (`lib:319-320`) cite base protection | reviewer grep and diff inspection | |
| 16 | `--help` documents base protection and token | PASS | `cleanup-worktrees.sh:124-127` inside the help heredoc | diff inspection; `evidence/qa-gates/ac16-help-text.2026-09-27T01-42.md` | |
| 17 | SKILL.md copies updated and byte-identical | PASS | Invariant bullet added to both; `git diff --no-index --exit-code` exit 0 | reviewer command | |
| 18 | 500-line limit | PASS | `wc -l`: 252, 451, 496, 476, 234, 142, 273, 199 | reviewer command | |
| 19 | shell-qc check clean | PASS | CI step "Run shell-qc check (shfmt diff + shellcheck)" `success` | `gh run view 36287146354 --json jobs` (reviewer) | |
| 20 | kcov >= 85% and added lines executed | PASS | `cov.xml`: enumerate_lib 0.924, actions_lib 0.953; lines 169, 212, 213, 346, 347, 348 each `hits="1"` | reviewer parse of downloaded `cov.xml`; `evidence/qa-gates/kcov/` | |
| 21 | Independent of remote refs and checkout depth | PASS | Grep of the pattern over both new scenario directories: no match; added test lines use only `CLEANUP_WT_GIT_BIN="${STUB}"` | reviewer grep; diff inspection | |
| 22 | No files created, no scratch repository | PASS | Added `@test` bodies contain no `git init`, `mktemp`, `BATS_TMPDIR`, `BATS_TEST_TMPDIR`; only `2>/dev/null` redirection | diff inspection | `/dev/null` is not a file path created by the test |
| 23 | PR `_shell-coverage.yml` job passes | UNVERIFIED | No pull request exists (`gh pr checks` reports none, `evidence/qa-gates/ac23-pr-ci.2026-09-27T02-20.md`). Supporting: dispatch run 36287146354 of the same workflow on `ubuntu-latest`, default checkout depth, concluded `success` | `gh pr checks bug/cleanup-worktrees-apply-deletes-local-main-594` | DEFERRED to the orchestrator's PR CI gate by design; not a defect of the implementation |

---

## Summary

**Overall Feature Readiness:** PASS (AC-23 deferred to the PR CI gate)

**Criteria summary:**
- **PASS:** 22 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 1 criterion (AC-23, deferred: no pull request exists yet)
- **FAIL:** 0 criteria

**Findings classification:**
- Blocking: 0
- Non-blocking: 2 — (a) T9's `merge-base` negative assertion is not observable (AC-10 still PASS on inspection and on the remaining assertions); (b) pre-existing stale line citation `tests/shell/test_cleanup_worktrees_dirt_clear.bats:14` -> `cleanup-worktrees.sh:145` (actual `:197`), excluded from this change by AC-12.
- Informational: 3 — AC-23 deferral; uncommitted plan check marks and untracked `commit-final` evidence awaiting the orchestrator commit; operator approval of D1-D7 (2026-09-26) is not yet reflected in `spec.md` text, which still reads "operator review not obtained".

Total blocking findings: 0.

**Top gaps preventing PASS:**

1. None. AC-23 is a post-PR gate, not an implementation gap.

**Recommended follow-up verification steps:**

1. After the PR is opened, confirm the `Shell Coverage (Bats + kcov)` check passes on the PR, then check off AC-23.
2. File follow-ups for the T9 assertion strength and the stale `dirt_clear.bats:14` citation.
3. Post-merge manual validation (spec, not an AC): run `--apply` with a non-`main` branch in the primary worktree and confirm `git branch --list main` still returns `main`.

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- Criteria evaluated as **PASS** may be checked off in the authoritative source file if not already checked.
- Criteria evaluated as **PARTIAL**, **FAIL**, or **UNVERIFIED** must remain unchecked.

All 22 PASS items (AC-1 through AC-22) were already checked in `spec.md` by the executor; the reviewer's evaluation agrees with each, so no source-file change was made. AC-23 is UNVERIFIED (deferred) and remains unchecked.

### AC Status Summary

- Source: `docs/features/active/2026-08-29-cleanup-worktrees-apply-deletes-local-main-594/spec.md`
- Total AC items: 23
- Checked off (delivered): 22
- Remaining (unchecked): 1
- Items remaining: "The CI `_shell-coverage.yml` job for the pull request passes on `ubuntu-latest` with the default checkout depth."

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `spec.md` | 23 | 22 | 1 | Checkbox-backed; no reviewer check-off needed; AC-23 deferred to PR CI gate |
