# Feature Audit: Get-EpicProgressReport dev-tools script (#1080)

**Audit Date:** 2026-11-05
**Feature Folder:** `docs/features/active/2026-11-04-epic-progress-report-script-1080`
**Base Branch:** `main`
**Head Branch:** `feature/epic-progress-report-script`
**Work Mode:** `minor-audit`
**Audit Type:** Initial acceptance review

---

## Scope and Baseline

- **Base branch:** `main` (origin/main tip `02fb8aada3b10aaf3ac6812e29400c2302a3b372`)
- **Head branch/commit:** `feature/epic-progress-report-script` (commit `52224c60c5c6f5c8528e78b289887841c13b3110`)
- **Merge base:** `02fb8aada3b10aaf3ac6812e29400c2302a3b372`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (generated 2026-11-05 23:19 UTC for head `52224c60c`)
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt` and `git diff 02fb8aada..52224c60c`
  - Feature evidence: `docs/features/active/2026-11-04-epic-progress-report-script-1080/evidence/**`
  - Additional evidence: reviewer re-runs at HEAD (formatter, PSSA, scoped Pester with JaCoCo coverage, seven-mutant probe), `artifacts/pester/powershell-coverage.xml`, `artifacts/pester/pester-junit.xml`
- **Feature folder used:** `docs/features/active/2026-11-04-epic-progress-report-script-1080`
- **Requirements source:** `issue.md` (`## Acceptance Criteria` only)
- **Work mode resolution note:** `issue.md` carries the explicit marker `- Work Mode: minor-audit`.
- **Scope note:** origin/main was merged into the branch at `a67ae96d7`, so the merge base equals the origin/main tip and main's content is excluded. Code scope is four new files; the rest is feature documentation and evidence. The behavioral reference (the recovered coordinator script) lies outside every repository and was not available to the reviewer; AC2 wording is judged against the elements the criterion enumerates and the exact strings pinned by the tests.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-11-04-epic-progress-report-script-1080/issue.md` - only source

### Acceptance criteria

1. AC1: Script at `scripts/dev-tools/Get-EpicProgressReport.ps1` with mirrored Pester 5 test; at most three production files; every file at or below 800 lines; PoshQC format, analyze, and test with zero findings, zero failed tests, and at least 85 percent line coverage per new production file.
2. AC2: `-Mode TLDR` prints the four-line block; `-Mode Full` (default) prints the block followed by the status heading, Elapsed and Progress line, State table, Wave table with Total row, Velocity and Remaining line, straight-line and wave-parallel lines, and weekly-quota line; epic issue and name come from parameters or the kickoff.
3. AC3: No hardcoded epic name, issue, branch, kickoff path, coordinator path, start time, baseline count, weekly baseline, wave overhead, sample cap, or drive path; the 13 listed parameters with documented defaults; `Join-Path` paths; kickoff parser accepts any numeric issue number.
4. AC4: Pure logic functions with Pester unit tests on fixed inputs for task counting, phase detection, state classification, average velocity, recent velocity (at least 2 minutes, negative clamped to 0), sample SD (at least 3 intervals), the 2.05 SD range with the 0.5 threshold and no-upper-bound wording, the critical-path estimate, the sample-retention rule, and the two hours formatters.
5. AC5: Every former `NaN` output prints `n/a`, with a unit test for each case.
6. AC6: All I/O behind `Invoke-GitExe`, `Invoke-GhExe`, `Invoke-CswapExe` (single array parameter) and wrappers for file existence, file read, state write, and UTC clock; tests mock with matching signatures; no test creates temporary files, calls the network, starts git, gh, or cswap, or reads the wall clock.
7. AC7: With cswap or gh absent or unparseable, the report still prints (quota `n/a`, PR state empty, no terminating error); a test for each absence.
8. AC8: Read-only: git only `fetch`, `show`, `worktree list`; gh only `pr list`; only the state file is written; a test asserts the wrapper argument lists.
9. AC9: Comment-based help (synopsis, description, every parameter, at least one example); no dev-tools documentation page; not added to any push-down pack manifest.

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | AC1 file layout, size, toolchain, coverage | PASS | 2 production files; tests mirrored; logical lines 456, 653, 426, 560; formatter 0 differences, PSSA 0 findings on all 4 files; 89/89 passed; line coverage 90.82% (89/98) and 100% (210/210); tree-wide 14387 tests, 0 failed | Reviewer `Invoke-Formatter`/`Invoke-ScriptAnalyzer` with `pssa.settings.psd1`; scoped `Invoke-Pester` with JaCoCo; `artifacts/pester/pester-junit.xml` | Coverage at HEAD reproduced; standing artifact predates only a comment-help commit |
| 2 | AC2 TLDR and Full output | PASS | Tests `prints the four TL;DR lines in TLDR mode`, `prints the TL;DR block followed by the Full sections in Full mode`, `composes the Full lines in recovered order`, `uses -EpicIssue over the kickoff marker`; every enumerated element is present in `Get-EpicProgressTldrLine`/`Get-EpicProgressFullLine` | Scoped Pester run (89/89) and code inspection of logic lines 554-653 | Wording parity with the out-of-repository recovered script was not re-checked by the reviewer (reference unavailable) |
| 3 | AC3 parameters and no hardcoded values | PASS | 13 parameters with help-documented defaults; `Resolve-EpicProgressSetting` default tests; `contains no recovered hardcoded value` (rejects drive-letter paths and recovered literals); five-digit row test; `Join-Path` for filesystem paths | Scoped Pester run; code inspection of main script lines 91-188 | Kickoff path is a git object path and uses `/` deliberately |
| 4 | AC4 pure logic with fixed-input tests | PASS | One `Describe` per listed behavior in the logic suite; reviewer mutants on the 90 s rule, clamp, SD minimum, range minimum, MERGED classification, and recent-interval selection were all killed | Scoped Pester run; seven-mutant probe (restored, worktree clean) | The 2-minute boundary itself is not pinned (non-blocking Minor in code review) |
| 5 | AC5 `n/a` for non-finite values | PASS | Context `non-finite values print n/a` (straight-line, wave-parallel, hours-left, range, weekly quota and delta, zero elapsed time) plus formatter NaN and infinity tests | Scoped Pester run | |
| 6 | AC6 I/O seams and test isolation | PASS | Seven named wrappers plus `Test-EpicProgressCommand`; mocks use `GitArgs`, `GhArgs`, `CswapArgs`, `Name`, `Path`, `Content`; `confines native commands to their wrappers`; no TestDrive, temporary file, or clock read (clock seam line 302 uncovered) | Scoped Pester run; coverage missed-line map; test-file inspection | |
| 7 | AC7 gh and cswap absence | PASS | Tests `prints n/a quota when cswap is not installed`, `prints n/a quota when cswap output is unparseable`, `leaves the PR state empty when gh is not installed`, `leaves the PR state empty when gh output is unparseable` | Scoped Pester run | |
| 8 | AC8 read-only behavior | PASS | `passes only fetch, show and worktree list to git`, `passes only pr list to gh`, `writes only the state file at -StatePath`, `confines file writes to Write-EpicProgressState` | Scoped Pester run; code inspection | |
| 9 | AC9 help, no docs page, not in a manifest | PASS | `documents every parameter in comment-based help`, `carries at least one example`; no `.md` under `scripts/dev-tools/`; `git grep Get-EpicProgressReport HEAD` outside the change set and `docs` returns no match | Scoped Pester run; `git grep -l Get-EpicProgressReport HEAD` with exclusions | |

---

## Summary

**Overall Feature Readiness:** PASS

**Criteria summary:**
- **PASS:** 9 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 0 criteria
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. None.

**Recommended follow-up verification steps:**

1. Confirm CI is green on the PR head once the PR is opened (no acceptance criterion depends on it).
2. Optionally add a 120-second interval fixture and a future-`-StartUtc` guard, as recorded in the code review.

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules, PASS criteria may be checked off in the authoritative source file.

All nine AC items in `issue.md` were already checked (`- [x]`) by the executor at P2-T12 (commit `501133260`). The reviewer evaluated each as PASS, so no change to `issue.md` was needed and none was made. The unchecked items under `## Test Conditions to Consider` and `## Next Step` are not acceptance criteria in minor-audit mode and were left unchanged.

### AC Status Summary

- Source: `docs/features/active/2026-11-04-epic-progress-report-script-1080/issue.md`
- Total AC items: 9
- Checked off (delivered): 9
- Remaining (unchecked): 0
- Items remaining: None.

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `docs/features/active/2026-11-04-epic-progress-report-script-1080/issue.md` | 9 | 9 | 0 | Checkbox-backed; already checked by the executor and confirmed by this review |
