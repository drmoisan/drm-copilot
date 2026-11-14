# Feature Audit: planner-worktree-removal-authorization (#1161)

**Audit Date:** 2026-11-14
**Feature Folder:** `docs/features/active/2026-11-09-planner-worktree-removal-authorization-1161`
**Base Branch:** `main`
**Head Branch:** `feature/planner-worktree-removal-authorization-1161`
**Work Mode:** `full-feature`
**Audit Type:** Re-audit at the exit of remediation cycle 1 (S7) of PR #1176

---

## Scope and Baseline

- **Base branch:** `main` (commit `eb73f1dff52e7175228a03740b53281c81e1c00c`, equal to `origin/main` after a fetch at review time)
- **Head branch/commit:** `feature/planner-worktree-removal-authorization-1161` (commit `b7913c32c24e47bc29742baf71800f4573958e06`)
- **Merge base:** `eb73f1dff52e7175228a03740b53281c81e1c00c`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (generated 2026-11-14 01:24:51 UTC at head `b7913c32c`, range `eb73f1dff..b7913c32c`), cross-checked with `git diff eb73f1dff..b7913c32c`
  - Secondary: `artifacts/pr_context.appendix.txt`
  - Cycle inputs: `remediation-inputs.2026-11-14T00-34.md` (PA-1) and `remediation-plan.2026-11-14T00-34.md`
  - Feature evidence: `docs/features/active/2026-11-09-planner-worktree-removal-authorization-1161/evidence/**`, in particular the cycle-1 records under `evidence/remediation-baseline/`, `evidence/regression-testing/recorded-at-fail-before.2026-11-14T01-01.md`, and `evidence/qa-gates/` (2026-11-14T01-12 to 01-21)
  - Additional evidence: reviewer parse of the canonical coverage artifacts; reviewer root Jest run (`evidence/qa-gates/jest-root-gate.2026-11-14T01-27.md`); cross-runtime validator probe over 65596 values; mutant analysis of the new fixtures; `validate_evidence_locations`
- **Feature folder used:** `docs/features/active/2026-11-09-planner-worktree-removal-authorization-1161`
- **Requirements source:** `spec.md` and `user-story.md`
- **Work mode resolution note:** `issue.md` carries `- Work Mode: full-feature`, so `spec.md` (AC-1 to AC-34) and `user-story.md` (15 checkbox items) are the AC sources.
- **Scope note:** full branch diff against the merge base (149 files, 72 under the feature folder), not only the cycle diff.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-11-09-planner-worktree-removal-authorization-1161/spec.md` (34 checkbox items AC-1 to AC-34 under `## Acceptance Criteria`)
- `docs/features/active/2026-11-09-planner-worktree-removal-authorization-1161/user-story.md` (15 checkbox items under `## Acceptance Criteria`: US-1 to US-8 for the operator story, US-9 to US-15 for the maintainer story, numbered in file order by the reviewer)

### Acceptance criteria

1. AC-1 to AC-4: Python and TypeScript validators, shared corpus, existing validator tests unchanged.
2. AC-5 to AC-8: allow on all three gates; fail-before record.
3. AC-9 to AC-21: refusal codes, U1 to U5, unrecorded byte-identical deny text, cascade order, detached and path mismatch.
4. AC-22 to AC-25: skill, agent, gate `.DESCRIPTION`, frozen surfaces.
5. AC-26 to AC-28: no absolute host path.
6. AC-29 to AC-34: mirrors and pins, push-down tests, existing suites and caps, coverage, parallel runs, no temporary files.
7. US-1 to US-15: the user-story restatement of the above.

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | AC-1 Python validator, ordered strings, key-absent identity | PASS | `_validate_planner_worktrees` called after `max_parallel_features` only when the key is present; `valid-key-absent.json` row; pytest 0 failed. | `pytest-gate.2026-11-14T01-17.md`; reviewer diff read | |
| 2 | AC-2 TypeScript produces the same lists for every corpus file | PASS | Both parity suites iterate the 21 corpus files; pytest and Jest gates 0 failed. Reviewer probe: identical results on 65596 further values. | `pytest-gate.2026-11-14T01-17.md`, `jest-gate.2026-11-14T01-18.md`, `jest-root-gate.2026-11-14T01-27.md`, reviewer probe | PA-1 closed |
| 3 | AC-3 corpus accepting and rejecting rows | PASS | 6 accepting and 15 rejecting files, including drive, leading slash, backslash, dot segment, duplicate branch, unknown folder, non-list, and the blank-set rows. | listing of `tests/fixtures/epic_planner_state_planner_worktrees/` | |
| 4 | AC-4 existing validator tests unchanged | PASS | No existing epic-planner validator test is in the diff; the cycle changed only the count constants of the two new corpus suites. | `git diff --name-only` | |
| 5 | AC-5 Claude epic gate allows (prepared, fanned_in; integration ref; branch ref) | PASS | Four allow rows in `enforce-epic-worktree-removal-gate.PlannerWorktree.Tests.ps1`; failed before the edit. | `pester-gate.2026-11-13T20-34.md`; `planner-allow-fail-before.2026-11-11T05-00.md` | |
| 6 | AC-6 Claude parallel gate allows | PASS | Four allow rows in the parallel suite. | same | |
| 7 | AC-7 Codex gate allows | PASS | Two gate-level allow rows through `Invoke-CodexWorktreeRemovalDecision`. | same | |
| 8 | AC-8 fail-before recorded with `ExpectedExitCode` | PASS | `EXIT_CODE: 1`, `ExpectedExitCode: 1`, all ten allow rows listed as failing. | regression-testing record | |
| 9 | AC-9 DIRTY including `--force` | PASS | DIRTY rows with and without `--force` on each gate. | Pester gate | |
| 10 | AC-10 unrecorded deny text byte-identical | PASS | Literal expected strings asserted per gate; suffix is `''` when no record names the target. | Pester gate; reviewer diff read | |
| 11 | AC-11 U1 | PASS | Helper rows for session root, enclosing target, and planner-checkpoint root; adapter rows. | Pester gate | |
| 12 | AC-12 U2 | PASS | Main checkout row. | Pester gate | |
| 13 | AC-13 U3 with and without `--force` | PASS | `locked claude agent <id> (pid N)` fixture and bare `locked` line. | Pester gate | |
| 14 | AC-14 U4 (unparseable, wrong step; absent not in use) | PASS | Three rows in the adapter and helper suites. | Pester gate | |
| 15 | AC-15 U5 via `worktree_path` and via `branch_name` | PASS | Two rows each on Claude and Codex. | Pester gate | |
| 16 | AC-16 NOT_PUSHED | PASS | Both ancestry checks exit 1. | Pester gate | |
| 17 | AC-17 NOT_ELIGIBLE | PASS | Wrong purpose and statuses `preparing`, `removed`, `abandoned`, plus case variants. | Pester gate | |
| 18 | AC-18 AMBIGUOUS | PASS | Two checkpoints, and two live roots. | Pester gate | |
| 19 | AC-19 GIT_FAILED | PASS | status non-zero, rev-parse failure, merge-base exit 128. | Pester gate | |
| 20 | AC-20 token once, sentence after diagnostics, manifest allow after refusal | PASS | Rows in both Claude suites; deny expression `$diagnostics + $planner.Suffix`. | Pester gate | |
| 21 | AC-21 detached never matches; path mismatch does not name | PASS | Porcelain `Branch = $null` for detached; adapter and Codex rows. | Pester gate | |
| 22 | AC-22 `## Preparation Worktree Records` and Fan-In pointers | PASS | Heading present in both skills; contract suite rows. | `planner-worktree-removal-contract.Tests.ps1` | |
| 23 | AC-23 agents list `planner_worktrees` and fields | PASS | Present in both agents; contract rows. | same | |
| 24 | AC-24 gate `.DESCRIPTION` and parallel surfaces | PASS | Three `.DESCRIPTION` paragraphs; contract rows. | same | |
| 25 | AC-25 frozen surfaces unchanged and hashes match | PASS | Not in the diff; `PINNED_FROZEN_SURFACE_HASHES` rows pass. | `git diff --stat`; pytest gate | |
| 26 | AC-26 validators reject drive, leading slash, backslash, colon, dot segment | PASS | Five rejecting corpus files; helper `Test-PlannerWorktreeRelativePathSafe` rows. | Corpus suites | |
| 27 | AC-27 no absolute host path in fixtures, corpus, or evidence | PASS (accepted exception) | No host path in fixtures, corpus, or tests, including the four new fixtures (`task-check.P1-T1.2026-11-14T01-00.md`). One evidence file quotes a drive-rooted synthetic test value; see Accepted Deviations. | Reviewer scan; `scope-check.2026-11-14T00-18.md` | DEV-1 under OD-10 |
| 28 | AC-28 skill and agent text: branch identity, optional relative path, never absolute | PASS | Contract tokens `repository-relative` and `absolute path`. | Contract suite | |
| 29 | AC-29 mirrors byte-identical; manifests; helper pin | PASS | 13 mirror pairs and four helper copies identical at S7; the cycle changed no mirrored file. | `cmp` at S7; cycle diff | |
| 30 | AC-30 push-down and contract tests | PASS | Full pytest run 0 failed; generator `--check` exit 0 in phase gate P1. | `pytest-gate.2026-11-14T01-17.md`; `phase-gate.P1.2026-11-14T01-12.md` | |
| 31 | AC-31 existing gate suites pass, caps, leak scan | PASS | Pester 0 failed; both Claude gates 500 lines; leak scan 0 failures; no PowerShell change in the cycle. | Pester gate; reviewer line count; `pwsh-static.2026-11-13T20-15.md` | "Unchanged" read as assertions unchanged (plan R5) |
| 32 | AC-32 coverage thresholds | PASS | New PowerShell files 100%, 100%, 93.88%, 93.33%; TypeScript module 100% / 100% (179/179, 44/44) with its own threshold; Python changed lines 100% lines, branches all covered. | Reviewer parse of the three canonical reports | |
| 33 | AC-33 parallel runs only | PASS | `Invoke-PoshQCParallelTest` (8 workers), `pytest -n auto`, Jest workers. | Gate records | |
| 34 | AC-34 no temporary files, waits, or live git in new tests | PASS | Reviewer scan of the new test files; the cycle's rows read committed fixtures. | Reviewer scan | |
| 35 | US-1 checkpoint shape; both validators accept well-formed and reject malformed with byte-identical strings | PASS | Shared six-character blank set in both runtimes; 21-file corpus passes in both; reviewer probe over 65596 values shows 0 differences; mutant analysis shows the new rows detect a revert in either runtime. | Reviewer esbuild probe; `recorded-at-fail-before.2026-11-14T01-01.md`; pytest and Jest gates | PA-1 closed; checked by the executor in `b7913c32c` |
| 36 | US-2 skill protocol | PASS | As AC-22 and AC-28. | Contract suite | |
| 37 | US-3 agents list the key | PASS | As AC-23. | Contract suite | |
| 38 | US-4 allowed by each gate | PASS | As AC-5 to AC-7. | Pester gate | |
| 39 | US-5 DIRTY including `--force` | PASS | As AC-9. | Pester gate | |
| 40 | US-6 IN_USE U1 to U5 | PASS | As AC-11 to AC-15. | Pester gate | |
| 41 | US-7 NOT_PUSHED, NOT_ELIGIBLE, AMBIGUOUS, GIT_FAILED | PASS | As AC-16 to AC-19. | Pester gate | |
| 42 | US-8 no absolute host path; path rejections | PASS (accepted exception) | As AC-26 and AC-27. | Reviewer scan | DEV-1 under OD-10 |
| 43 | US-9 unrecorded deny byte-identical | PASS | As AC-10. | Pester gate | |
| 44 | US-10 pure helper identical, no I/O, pinned; I/O in adapters | PASS | AST row; pin row; `cmp`. | Pester gate | |
| 45 | US-11 gate `.DESCRIPTION` | PASS | As AC-24. | Contract suite | |
| 46 | US-12 existing suites, caps, leak scan | PASS | As AC-31. | Pester gate | |
| 47 | US-13 mirrors, manifests, push-down, generator, frozen surfaces | PASS | As AC-25, AC-29, AC-30. | pytest gate | |
| 48 | US-14 coverage | PASS | As AC-32. | Coverage reports | |
| 49 | US-15 parallel runs; no temporary files, waits, or live git | PASS | As AC-33 and AC-34. | Gate records | |

---

## Accepted Deviations

- **DEV-1 (owner directive OD-10, class `accept_nonblocking_deviation`, recorded 2026-11-14T00:14:39Z, accepted 2026-11-14T00:16:35Z):** `evidence/qa-gates/pwsh-static.2026-11-13T20-15.md` quotes, in its reason paragraph, the drive-rooted synthetic test value that task P4-T6 removed from `tests/scripts/claude-hooks/hook-planner-worktree-removal.Tests.ps1`. The value is synthetic and carries no host data. Evidence is append-only, so the file stays unedited (unchanged at head). The owner accepted this as a non-blocking exception to AC-27's second clause. The reviewer records it as an accepted non-blocking exception, not as a FAIL. AC-27 and US-8 are graded PASS with this exception.

---

## Summary

- 49 of 49 evaluated items PASS (AC-27 and US-8 with the accepted exception DEV-1).
- PA-1 is closed: both validators share one six-character blank set for `recorded_at`, the spec states it, and four corpus rows pin it in both runtimes.
- No blocking finding remains.
- Pending-CI: PR #1176 checks were queued or in progress at review time; the completed checks are green. Owned by the S9 CI gate.

### Recommended follow-ups

1. Confirm the S9 CI green gate on the final PR head.

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- Criteria evaluated as **PASS** may be checked off in the authoritative source file if they are markdown checkboxes and not already checked.
- Criteria evaluated as **PARTIAL**, **FAIL**, or **UNVERIFIED** must remain unchecked.

All 34 spec items and all 15 user-story items were already checked at head. The executor re-checked US-1 in commit `b7913c32c` after the cycle gates (`evidence/other/user-story-recheck.2026-11-14T01-20.md`); the reviewer evaluates it PASS and confirms the check. The reviewer made no change to either source file.

### AC Status Summary

- Source: `docs/features/active/2026-11-09-planner-worktree-removal-authorization-1161/spec.md` and `docs/features/active/2026-11-09-planner-worktree-removal-authorization-1161/user-story.md`
- Total AC items: 49
- Checked off (delivered): 49
- Remaining (unchecked): 0
- Items remaining: none

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `docs/features/active/2026-11-09-planner-worktree-removal-authorization-1161/spec.md` | 34 | 34 | 0 | AC-27 with accepted exception DEV-1 |
| `docs/features/active/2026-11-09-planner-worktree-removal-authorization-1161/user-story.md` | 15 | 15 | 0 | US-8 with accepted exception DEV-1 |
