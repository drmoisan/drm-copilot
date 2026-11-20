# Code Review: Get-EpicProgressReport dev-tools script (#1080), Re-audit after Remediation Cycle 1

**Review Date:** 2026-11-06
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-11-04-epic-progress-report-script-1080`
**Base Branch:** `main` (merge base `02fb8aada3b10aaf3ac6812e29400c2302a3b372`)
**Head Branch:** `feature/epic-progress-report-script` @ `79d4e3de07731e97e8dcd9e52c44d08a116bab8d`
**Review Type:** Re-audit (remediation cycle 1); prior review `code-review.2026-11-05T23-23.md` at `52224c60c`

---

## Executive Summary

The remediation cycle changed only the four change-set code files (`git diff 52224c60c HEAD -- scripts tests`). All four in-scope findings from `remediation-inputs.2026-11-05T23-27.md` are resolved, and each new test is shown to discriminate: the reviewer applied six mutants to a scratch copy of the change set and each was killed by exactly the intended new test. At HEAD the formatter reports 0 differences, PSSA reports 0 findings, 96 of 96 tests pass, and line coverage is 91.18% (93/102) and 100% (213/213).

The full change set was then reviewed again. The new code introduces no regression. One defect was found that both the original implementation and the prior review missed: the kickoff row parser treats every Markdown table row with a numeric first cell as a feature row, in any table of the kickoff. Three of the nine `epic-kickoff.md` files in the repository have a wave-summary table (`| wave | features | width |`) with numeric first cells, and the report for those epics contains phantom features and an extra open wave.

**What changed in this cycle:**
- `Get-EpicProgressRecentVelocityInterval`: new 120-second boundary test (no production change).
- `Get-EpicProgressSummary`: elapsed hours clamped at 0 (logic line 525); help updated.
- `ConvertFrom-EpicProgressKickoffRow`: row regex `^\|\s*(\d+)\s*\|`; a non-digit wave cell throws a message naming the issue and cell; invariant-culture `[int]::Parse` (logic lines 49-54).
- `Invoke-EpicProgressReport`: new seam `Get-EpicProgressLastExitCode` (main lines 305-315); `Write-Warning` when the fetch exit code is non-zero (main lines 376-379).

**Top 3 risks:**
1. Phantom feature rows from non-feature tables in the kickoff (CR-1, Major): wrong feature count, phantom Pending entries and waves, inflated wave-parallel estimate.
2. Since this cycle, a numeric-first-cell row in any other kickoff table whose fourth cell is non-numeric now aborts the whole report with a terminating error, where it previously produced a phantom row or a wave of 0. No repository kickoff has such a row today. The CR-1 fix removes this risk as well.
3. `[int]::Parse` on an all-digit wave cell longer than `Int32` raises an `OverflowException` without the clear message (Nit).

**PR readiness recommendation:** **No-Go** until CR-1 is remediated. All other items are non-blocking.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Major | `scripts/dev-tools/Get-EpicProgressReport.Logic.ps1` | `ConvertFrom-EpicProgressKickoffRow` (lines 29-57; match at line 49) | CR-1 (Blocking): every row matching `^\|\s*(\d+)\s*\|` anywhere in the kickoff is returned as a feature. Wave-summary rows such as `\| 0 \| 545 (E), 630 (A), 633 (H), 634 (G) \| 4 \|` become features `#0`, `#1`, `#2` with the `width` cell read as the wave and an empty plan path. | Parse only the feature-summary table: locate its header row (for example the header whose first cell is `issue_num` or `Issue`), read rows until the first non-table line, and ignore every other table. Add a logic test with a kickoff that contains a feature table followed by a `\| wave \| features \| width \|` table and assert only the feature rows are returned; add a report-level assertion on the feature count. | The issue's purpose is a correct report "for any epic"; the defect reproduces on 3 of 9 repository kickoff files (`cleanup-merged-worktrees-hardening`, `orchestrator-state-contract-correctness`, `worktree-scoped-state-resolution`). Pre-existing: identical parser output at `52224c60c` and HEAD. | Reviewer corpus probe (old and new parser, 9 kickoffs): 3 phantom rows in each of the 3 files. Stubbed `Invoke-EpicProgressReport` run on the `cleanup-merged-worktrees-hardening` kickoff (no git, gh, cswap, or writes): TL;DR says "None of the 11 features" (8 real), State table lists `Pending, wave 2 \| #1 (0), #2 (0)` and `Pending, wave 4 \| #0 (0)`, Wave table has a wave-4 row and wave 2 shows 4 children, and the wave-parallel estimate is 8 h 45 min instead of 7 h 30 min (one extra 1.25 h open-wave overhead). The epic 1019 kickoff on `origin/epic/documentation-estate-tooling-integration` has no wave table and is unaffected. |
| Nit | `scripts/dev-tools/Get-EpicProgressReport.Logic.ps1` | `ConvertFrom-EpicProgressKickoffRow` line 54 | `[int]::Parse` on an all-digit wave cell longer than `Int32` raises `OverflowException` with a generic message instead of the clear message used for non-digit cells. | Optional: use `[int]::TryParse` and route failure to the same `throw`. | Consistency of the error message; unrealistic input. | Code inspection. |
| Info | `tests/scripts/dev-tools/Get-EpicProgressReport.Tests.ps1` | `returns the last native exit code` (line 85) | The assertion compares the seam with the ambient `$LASTEXITCODE`, which can be `$null` on both sides; it proves pass-through only. | None required. | The seam is a one-line pass-through; the reviewer verified it against the real `Invoke-GitExe` (failing `git rev-parse --verify` gave 1, a succeeding call gave 0). | Reviewer seam composition probe. |
| Info | `scripts/dev-tools/Get-EpicProgressReport.ps1` | `Invoke-EpicProgressReport` lines 376-379 | If git is not on PATH and no native command has run in the session, `$LASTEXITCODE` is `$null`, so the warning prints "failed with exit code ;". | None required. | Without git the report cannot be produced at all; the wording gap has no practical effect. | Code inspection. |

No file-size Warning: the largest covered file is 661 logical lines (below the 700-line advisory tier).

### Remediation verification of cycle-1 findings

| Cycle-1 finding | Status | Production change | Test | Discrimination |
|---|---|---|---|---|
| 1 Minor: 2-minute boundary unpinned | RESOLVED | None needed (`-ge` at line 349 is correct) | `counts a pair exactly two minutes apart` (Logic.Tests line 338) | M1 `-ge`->`-gt`: killed (1 failure, this test) |
| 2 Minor: negative elapsed text | RESOLVED (clamp option) | Line 525 `[math]::Max(0.0, ...)`; help on `Get-EpicProgressSummary` and script `-StartUtc` | `clamps elapsed time at zero when the start is after now` (Logic.Tests line 590) | M2 clamp removed: killed |
| 3 Nit: kickoff whitespace and non-numeric wave | RESOLVED | Lines 49-54 | `parses a feature row with variable whitespace around cells` (line 52), `throws a clear error for a non-numeric wave cell` (line 62) | M3 regex reverted: killed; M4 check removed: killed |
| 4 Info: silent fetch failure | RESOLVED | Seam lines 305-315; warning lines 376-379; help updated | `warns when git fetch fails` (line 212), `does not warn when git fetch succeeds` (line 224) | M5 warning removed: killed; M6 always warn: killed |

---

## Implementation Audit

### PowerShell implementation audit

#### What changed well

- The exit-code read is a named seam in the I/O file, mocked from fixture state, so report tests never depend on the ambient `$LASTEXITCODE`.
- The clamp was chosen over a terminating error and is documented in both the function help and the script `-StartUtc` help, so the behavior is discoverable.
- The non-numeric wave error names the issue and the offending cell, and the help states why the row is not skipped (a skipped row would understate the total).
- The boundary test includes a comment explaining that `120 / 3600.0` and `2 / 60` are the same double, so the test sits on the boundary and is not affected by floating-point error.

#### API and safety notes

- No parameter added or removed; the public surface is unchanged.
- No new native command; the AST constraint tests still confine executables to their wrappers.
- PSSA: 0 findings with repository settings.

#### Error handling and logging

- New: a clear terminating error for a non-numeric wave cell; a warning for a failed fetch.
- See CR-1 and risk 2: the terminating error currently also applies to rows outside the feature table.

---

## Test Quality Audit

Seven tests were added (four logic, three script). Each pins one remediated behavior and each was shown to fail under the corresponding mutant. The suites remain deterministic: no temporary files, no clock reads, no process starts.

### Reviewed test and QA artifacts

- `tests/scripts/dev-tools/Get-EpicProgressReport.Logic.Tests.ps1` - 64 tests; 100% line coverage of the logic file.
- `tests/scripts/dev-tools/Get-EpicProgressReport.Tests.ps1` - 32 tests.
- `evidence/regression-testing/mutant-boundary-ge-gt.2026-11-05T23-42.md`, `boundary-two-minutes.2026-11-05T23-41.md`, `elapsed-clamp.2026-11-05T23-43.md`, `kickoff-row-parsing.2026-11-05T23-43.md`, `fetch-warning.2026-11-05T23-44.md` - consistent with the reviewer mutant results.
- `evidence/qa-gates/coverage-final.2026-11-05T23-47.md` - 91.18% and 100%; matches the reviewer measurement.
- `evidence/regression-testing/isolation-shuffle.2026-11-05T23-50.md`, `isolation-fresh-tests-scripts.2026-11-06T00-01.md` - 0 failures.

### Quality assessment prompts

- **Determinism:** Fetch exit code supplied by fixture; clock mocked.
- **Isolation:** `$script:fetchExitCode` reset in `BeforeEach`.
- **Speed:** both suites complete in seconds.
- **Diagnostics:** `-ExpectedMessage` and full-string comparisons identify the failing line.
- **Gap:** no fixture contains a second table with numeric first cells (CR-1).

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | No tokens, host paths, or account names added. |
| No unsafe subprocess or command construction | ✅ PASS | No new native invocation. |
| Input validation at boundaries | ❌ FAIL | Kickoff rows outside the feature table are accepted as features (CR-1). |
| Error handling remains explicit | ✅ PASS | Clear throw and warning added. |
| Configuration / path handling is safe | ✅ PASS | Unchanged. |
| Read-only toward repository and GitHub | ✅ PASS | Only `fetch`, `show`, `worktree list`, and `pr list`; asserted by tests. Phantom rows cause extra `git show <branch>:` reads, which remain read-only. |
| No new Python | ✅ PASS | Zero `.py` paths in the branch diff. |

---

## Research Log

No external research was required. Conclusions rest on the diff, repository kickoff files, local tool runs, mutation runs on a scratch copy, and the feature evidence.

---

## Verdict

The four cycle-1 findings are resolved with discriminating tests, and the remediation introduced no regression. The branch is not ready for merge because of CR-1 (Major, Blocking, autonomous): the kickoff parser must be restricted to the feature-summary table and covered by a fixture that contains a wave-summary table. The Nit and two Info items are optional.
