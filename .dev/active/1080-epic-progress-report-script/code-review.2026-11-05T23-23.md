# Code Review: Get-EpicProgressReport dev-tools script (#1080)

**Review Date:** 2026-11-05
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-11-04-epic-progress-report-script-1080`
**Feature Folder Selection Rule:** Supplied by the caller; matches canonical issue #1080.
**Base Branch:** `main` (merge base `02fb8aada3b10aaf3ac6812e29400c2302a3b372`)
**Head Branch:** `feature/epic-progress-report-script` @ `52224c60c5c6f5c8528e78b289887841c13b3110`
**Review Type:** Initial review

---

## Executive Summary

The branch adds `scripts/dev-tools/Get-EpicProgressReport.ps1` (456 lines; parameters, help, settings resolution, I/O wrapper seams, report wiring, guarded entry point) and `scripts/dev-tools/Get-EpicProgressReport.Logic.ps1` (653 lines; pure functions), with mirrored Pester 5 suites of 29 and 60 tests. No existing file outside the feature documentation is modified. The reviewer read every changed code line, re-ran format, analyze, and test at HEAD (0 differences, 0 findings, 89/89 passed), re-measured coverage (90.82% and 100% lines), and ran a seven-mutant probe against the logic file (six killed, one survived).

The implementation follows the repository seam pattern closely: native executables are reached only through `Invoke-GitExe`/`Invoke-GhExe`/`Invoke-CswapExe`, file and clock access go through named wrappers, and AST-based tests enforce that confinement. Numeric and date output uses the invariant culture. Error handling degrades as the issue requires when gh or cswap is absent or prints unparseable output.

**What changed:**
Two new production PowerShell files and two new test files under `scripts/dev-tools/` and `tests/scripts/dev-tools/`, plus feature-folder documentation and evidence. No `.py` file is added or changed.

**Top 3 risks:**
1. The 2-minute recent-velocity interval boundary is not pinned by a test (a `-ge` to `-gt` mutant survived).
2. A `-StartUtc` later than the current time yields negative elapsed text such as `-1 h 30 min` for -0.5 h; there is no guard or test for that input.
3. The kickoff row parser requires single-space cell padding (`^\| (\d+) \|`) and casts the wave cell with `[int]`; a differently formatted kickoff table silently yields zero features, and a non-numeric wave cell raises a conversion error.

**PR readiness recommendation:** **Go** - no Blocker or Major finding; the Minor and Info items are improvements that do not affect any acceptance criterion.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Minor | `tests/scripts/dev-tools/Get-EpicProgressReport.Logic.Tests.ps1` | `Describe 'Get-EpicProgressRecentVelocityInterval'` (lines 308-333) | The inclusive 2-minute boundary (`$hours -ge (2 / 60)`, logic line 342) is not asserted; only a 60-second pair is tested. | Add a fixture with a pair exactly 120 seconds apart and assert it is counted. | AC4 states intervals "of at least 2 minutes"; an off-by-one change at the boundary would pass the suite. | Reviewer mutant `-ge` to `-gt`: SURVIVED (failed=0); the other six mutants were killed. |
| Minor | `scripts/dev-tools/Get-EpicProgressReport.Logic.ps1` | `Format-EpicProgressHour` (lines 249-264); `Get-EpicProgressSummary` line 517 | A negative elapsed time (StartUtc after now) prints as `-1 h 30 min` for -0.5 h because `Floor` rounds toward negative infinity. | Either reject a future `-StartUtc` with a clear error in the main script or clamp elapsed hours at 0; add a test. | A mistyped start time would produce misleading output instead of an explicit error. | Code inspection: minutes = -30, `Floor(-0.5)` = -1, remainder 30. |
| Nit | `scripts/dev-tools/Get-EpicProgressReport.Logic.ps1` | `ConvertFrom-EpicProgressKickoffRow` (lines 44-49) | Row match requires exactly one space around the issue cell, and `[int] $cells[3]` throws on a non-numeric wave cell. | Use `^\|\s*(\d+)\s*\|` and validate the wave cell, or document the expected table format in the help. | Kickoff tables are hand-edited Markdown; formatting drift would silently empty the report. | Code inspection. |
| Info | `scripts/dev-tools/Get-EpicProgressReport.ps1` | `Invoke-EpicProgressReport` line 361 | `git fetch -q origin` output is discarded; a failed fetch (offline) is not reported, so the report may reflect stale refs. | Optional: emit a `Write-Warning` when the fetch wrapper returns a failure indication. | Operator awareness only; read-only behavior is unaffected. | Code inspection. |
| Info | `scripts/dev-tools/Get-EpicProgressReport.ps1` | `Write-EpicProgressState` line 290 | A custom `-StatePath` whose directory does not exist produces a non-terminating `Set-Content` error; the report still prints. | Optional: document that the directory must exist. | The default path is the system temporary directory, which exists. | Code inspection. |
| Info | `scripts/dev-tools/Get-EpicProgressReport.ps1` | wrappers lines 201, 215, 229 | Wrappers use `2>$null` rather than the rule example `2>&1`. | None. | Discarding stderr is correct here because the output is parsed as JSON or Markdown; mixing stderr in would break parsing. | `.claude/rules/powershell.md` presents `2>&1` as an example, not a requirement. |
| Info | `docs/features/active/2026-11-04-epic-progress-report-script-1080/evidence/` | command lines of P0-P2 evidence | Evidence names `sh SCRATCH/issue-1080-*.sh` launchers (recreated as `sh` instead of the plan's `.ps1` names after the preimplementation hook blocked `.ps1` temp writes); the launchers are not in the repository. | None required. | Reviewer reproduced format, analyze, test, and per-file coverage at HEAD with identical figures, so the deviation does not affect evidence validity. | Reviewer re-run: 89/89, 89/98 and 210/210 lines, 0 PSSA findings, 0 format differences. |

No Blocker or Major findings. No file-size Warning: the largest covered file is 653 logical lines (below the 700-line advisory tier).

---

## Implementation Audit

### PowerShell implementation audit

#### What changed well

- Clean split between I/O wiring and pure logic; the logic file performs no I/O, which the AST constraint tests (`confines file writes to Write-EpicProgressState`, `confines native commands to their wrappers`) enforce mechanically.
- `Test-EpicProgressJsonText` guards every `ConvertFrom-Json`, so unparseable gh, cswap, checkpoint, and state text degrades instead of throwing.
- Invariant-culture formatting for numbers and times makes the printed lines host-independent.
- `Format-EpicProgressHour` and `Format-EpicProgressClock` derive both fields from the rounded total minutes, avoiding a `60 min` field; a test covers it.
- The entry point is skipped under dot-sourcing and restores the location with `try/finally`.

#### API and safety notes

- 13 script parameters, each documented in comment-based help with its default; `-SampleCap` and `-Mode` are validated.
- `Write-EpicProgressState` supports ShouldProcess; it is the only file write (confirmed by AST test and by inspection).
- Executables are invoked by splatting a `[string[]]`; no string-built commands or `Invoke-Expression`.
- PSSA: 0 findings with repository settings.

#### Error handling and logging

- One terminating error, with an actionable message, when the epic issue cannot be resolved.
- gh and cswap absence is detected by `Test-EpicProgressCommand` before invocation.
- See the Info findings about the silent fetch failure and the state-directory case.

---

## Test Quality Audit

Both suites are deterministic and isolated. The script suite mocks all eight seams with production parameter names and exercises the full report path in TLDR and Full mode against exact expected output. AC8 is enforced by asserting the exact git and gh argument lists. The logic suite covers each pure function on fixed inputs, including NaN and infinity handling.

### Reviewed test and QA artifacts

- `tests/scripts/dev-tools/Get-EpicProgressReport.Logic.Tests.ps1` - 60 tests; 100% line coverage of the logic file; one unpinned boundary (Minor finding).
- `tests/scripts/dev-tools/Get-EpicProgressReport.Tests.ps1` - 29 tests; settings defaults, seams, mocked end-to-end report, read-only constraints, help.
- `evidence/qa-gates/coverage-final.2026-11-04T20-56.md`, `evidence/qa-gates/coverage-delta.2026-11-04T20-57.md` - per-file coverage and uncovered-line map; consistent with the reviewer measurement after the 5-line `.NOTES` offset.
- `evidence/regression-testing/isolation-fresh-tests-scripts.2026-11-05T23-06.md`, `evidence/regression-testing/isolation-parallel.2026-11-05T23-13.md`, `evidence/regression-testing/isolation-shuffle.2026-11-04T21-00.md` - tree-wide and shuffled runs, 0 failures; consistent with `artifacts/pester/pester-junit.xml` (14387 tests, 0 failures, 0 errors).

### Quality assessment prompts

- **Determinism:** Clock mocked; in-memory fixtures; no temporary files; the `-WhatIf` write test asserts that nothing is written.
- **Isolation:** Per-test state reset in `BeforeEach`; one behavior per `It`.
- **Speed:** 89 tests in 3.21 s.
- **Diagnostics:** Full-string comparisons and `-Because` messages identify the failing line or token.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | No tokens, host paths, or account names; a test rejects drive-letter paths and the recovered literals. |
| No unsafe subprocess or command construction | ✅ PASS | Array splatting into git, gh, and cswap only. |
| Input validation at boundaries | ✅ PASS | Parameter validation attributes; JSON validated before conversion. Kickoff table format is assumed (Nit). |
| Error handling remains explicit | ✅ PASS | Terminating error for an unresolved issue; degraded output otherwise. |
| Configuration / path handling is safe | ✅ PASS | `Join-Path` for filesystem paths; the state file defaults to the system temporary directory, never the repository. |
| Read-only toward repository and GitHub | ✅ PASS | Only `fetch`, `show`, `worktree list`, and `pr list`; asserted by tests. |
| No new Python | ✅ PASS | Zero `.py` paths in the branch diff. |

---

## Research Log

No external research was required. All conclusions rest on the diff, repository rule files, local tool runs, and the feature evidence.

---

## Verdict

The change is ready for the normal PR flow. The implementation meets the repository's PowerShell seam, ShouldProcess, file-size, and coverage requirements, and the reviewer reproduced the executor's toolchain results at HEAD. The two Minor findings (unpinned 2-minute boundary and negative elapsed formatting) and the Nit on kickoff parsing are recommended improvements; none is blocking and none changes the PASS status of any acceptance criterion.
