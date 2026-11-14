# Feature Audit: Get-EpicProgressReport dev-tools script (#1080), Re-audit after Remediation Cycle 1

**Audit Date:** 2026-11-06
**Feature Folder:** `docs/features/active/2026-11-04-epic-progress-report-script-1080`
**Base Branch:** `main`
**Head Branch:** `feature/epic-progress-report-script`
**Work Mode:** `minor-audit`
**Audit Type:** Re-audit (remediation cycle 1); prior audit `feature-audit.2026-11-05T23-23.md`

---

## Scope and Baseline

- **Base branch:** `main` (origin/main tip `02fb8aada3b10aaf3ac6812e29400c2302a3b372` after `git fetch origin main`)
- **Head branch/commit:** `feature/epic-progress-report-script` (commit `79d4e3de07731e97e8dcd9e52c44d08a116bab8d`)
- **Merge base:** `02fb8aada3b10aaf3ac6812e29400c2302a3b372`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (generated 2026-11-06 00:06:58 UTC for head `79d4e3de0`)
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt` and `git diff 02fb8aada..79d4e3de0`
  - Remediation inputs and plan: `remediation-inputs.2026-11-05T23-27.md`, `remediation-plan.2026-11-05T23-27.md`
  - Feature evidence: `docs/features/active/2026-11-04-epic-progress-report-script-1080/evidence/**` (cycle-1 files under `remediation-baseline/`, `qa-gates/`, `regression-testing/`)
  - Additional evidence: reviewer re-runs at HEAD (formatter, PSSA, scoped Pester with JaCoCo coverage), six-mutant probe on a scratch copy, kickoff corpus probe over the nine repository `epic-kickoff.md` files, stubbed end-to-end report run
- **Feature folder used:** `docs/features/active/2026-11-04-epic-progress-report-script-1080`
- **Requirements source:** `issue.md` (`## Acceptance Criteria` only)
- **Work mode resolution note:** `issue.md` carries the explicit marker `- Work Mode: minor-audit`.
- **Scope note:** the audit covers the full branch diff (four new code files plus feature documentation and evidence), not only the cycle-1 commits. `issue.md` is unchanged by the remediation. The recovered coordinator script remains outside every repository; AC2 wording is judged against the enumerated elements and the strings pinned by tests.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-11-04-epic-progress-report-script-1080/issue.md` - only source

### Acceptance criteria

1. AC1: Script at `scripts/dev-tools/Get-EpicProgressReport.ps1` with mirrored Pester 5 test; at most three production files; every file at or below 800 lines; PoshQC format, analyze, and test with zero findings, zero failed tests, and at least 85 percent line coverage per new production file.
2. AC2: `-Mode TLDR` prints the four-line block; `-Mode Full` (default) prints the block followed by the status heading, Elapsed and Progress line, State table, Wave table with Total row, Velocity and Remaining line, straight-line and wave-parallel lines, and weekly-quota line; epic issue and name come from parameters or the kickoff.
3. AC3: No hardcoded values; the 13 listed parameters with documented defaults; `Join-Path` paths; kickoff parser accepts any numeric issue number.
4. AC4: Pure logic functions with Pester unit tests on fixed inputs, including recent velocity over intervals of at least 2 minutes with negative rates clamped to 0.
5. AC5: Every former `NaN` output prints `n/a`, with a unit test for each case.
6. AC6: All I/O behind named wrappers; tests mock with matching signatures; no temporary files, network, process starts, or wall-clock reads in tests.
7. AC7: With cswap or gh absent or unparseable, the report still prints; a test for each absence.
8. AC8: Read-only: git only `fetch`, `show`, `worktree list`; gh only `pr list`; only the state file is written; a test asserts the wrapper argument lists.
9. AC9: Comment-based help; no dev-tools documentation page; not added to any push-down pack manifest.

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | AC1 file layout, size, toolchain, coverage | PASS | 2 production files; logical lines 474, 661, 455, 601; formatter 0 differences, PSSA 0 findings on all 4 files; 96/96 passed; line coverage 91.18% (93/102) and 100% (213/213); tree-wide 14394 tests, 0 failed (R1 P2-T7) | Reviewer `Invoke-Formatter`/`Invoke-ScriptAnalyzer` with `pssa.settings.psd1`; scoped `Invoke-Pester` with JaCoCo | Reproduced at HEAD |
| 2 | AC2 TLDR and Full output | PASS | TLDR and Full tests unchanged and passing; both modes still emit every enumerated element; fetch-warning tests confirm TLDR output is unchanged when a warning is written | Scoped Pester run (96/96) | Content is wrong for kickoffs with a wave-summary table (CR-1); the criterion's enumerated output structure is met |
| 3 | AC3 parameters and no hardcoded values | PASS | 13 parameters with documented defaults; five-digit and variable-whitespace row tests; `contains no recovered hardcoded value` passes | Scoped Pester run; code inspection | The parser accepts any numeric issue number as required; it also accepts numeric rows of other tables (CR-1, outside the criterion text) |
| 4 | AC4 pure logic with fixed-input tests | PASS | The 2-minute boundary is now pinned (`counts a pair exactly two minutes apart`); the `-ge`->`-gt` mutant is killed | Scoped Pester run; reviewer mutant M1 | Resolves the cycle-1 Minor finding |
| 5 | AC5 `n/a` for non-finite values | PASS | Context `non-finite values print n/a` unchanged and passing; the future-start test also asserts `n/a` estimates at zero elapsed | Scoped Pester run | |
| 6 | AC6 I/O seams and test isolation | PASS | New `Get-EpicProgressLastExitCode` seam mocked in report tests; no temporary file, process start, or clock read; `confines native commands to their wrappers` passes | Scoped Pester run; test-file inspection | |
| 7 | AC7 gh and cswap absence | PASS | Four absence and unparseable tests unchanged and passing | Scoped Pester run | |
| 8 | AC8 read-only behavior | PASS | `passes only fetch, show and worktree list to git`, `passes only pr list to gh`, `writes only the state file at -StatePath` pass | Scoped Pester run | |
| 9 | AC9 help, no docs page, not in a manifest | PASS | Help tests pass; help updated for the clamp, the fetch warning, and the kickoff format; no `.md` under `scripts/dev-tools/`; no manifest reference | Scoped Pester run; `git diff --name-only` | |

---

## Summary

**Overall Feature Readiness:** PASS on all nine acceptance criteria; merge is blocked by code-review finding CR-1 (Blocking, autonomous).

**Criteria summary:**
- **PASS:** 9 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 0 criteria
- **FAIL:** 0 criteria

**Remediation cycle 1 verification:** all four in-scope findings are resolved; each new test fails under the corresponding mutant (six of six mutants killed).

**Top gaps preventing merge:**

1. CR-1: `ConvertFrom-EpicProgressKickoffRow` returns phantom feature rows for wave-summary tables. Reproduced on 3 of 9 repository kickoff files; for `cleanup-merged-worktrees-hardening` the report shows 11 features instead of 8, phantom Pending features `#0`, `#1`, `#2`, a phantom wave 4, and a wave-parallel estimate of 8 h 45 min instead of 7 h 30 min. The defect predates the remediation (identical parser output at `52224c60c`).

**Recommended follow-up verification steps:**

1. After the CR-1 fix, re-run the kickoff corpus probe over all `docs/features/epics/*/epic-kickoff.md` and confirm zero rows without a plan path.
2. Confirm CI is green on the PR head once the PR is opened (no acceptance criterion depends on it).

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules, PASS criteria may be checked off in the authoritative source file.

All nine AC items in `issue.md` were already checked (`- [x]`) by the executor at P2-T12 (commit `501133260`), and the remediation did not change `issue.md`. The reviewer evaluated each as PASS at HEAD, so no change to `issue.md` was needed and none was made. CR-1 does not contradict the text of any criterion, so no check-off is reverted. The unchecked items under `## Test Conditions to Consider` and `## Next Step` are not acceptance criteria in minor-audit mode and were left unchanged.

### AC Status Summary

- Source: `docs/features/active/2026-11-04-epic-progress-report-script-1080/issue.md`
- Total AC items: 9
- Checked off (delivered): 9
- Remaining (unchecked): 0
- Items remaining: None.

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `docs/features/active/2026-11-04-epic-progress-report-script-1080/issue.md` | 9 | 9 | 0 | Checkbox-backed; confirmed at HEAD `79d4e3de0` |
