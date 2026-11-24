# Code Review: targeted-test-cadence (#1228), re-audit after remediation cycle 2

---

**Review Date:** 2026-11-24
**Reviewer:** feature-review agent
**Feature Folder:** `.dev/active/1228-targeted-test-cadence`
**Feature Folder Selection Rule:** the only active folder in the branch diff; its prefix matches issue 1228 in the branch name.
**Base Branch:** `main` (resolved `origin/main` at merge base `23458fade99f40e81b95ce86ed90805258479782`)
**Head Branch:** `feature/targeted-test-cadence-1228` at `c8a4d99cf3f41b02170caeaf0da398764370c638`
**Review Type:** Re-audit (remediation cycle 2, inputs `remediation-inputs.2026-11-24T10-50.md`)

---

## Executive Summary

The branch changes the orchestration test cadence on every harness surface so that the full test suite runs only at the `Phase 0 baseline` and in the final QA loop, and every other run uses a test selection. The previous review found one blocking defect (F3): the feature-review coverage Stop hook graded a selection-run coverage report as the repo-wide figure, so a review that followed the branch's own D3 rule could not complete without a false FAIL or a full run.

Remediation commit `c8a4d99cf` (47 files) adds spec decision D11:

- The test-execution launcher writes `artifacts/test-execution/run-scope.<suite>.json` after each suite run (`Get-TestSuiteRunScope`, `New-TestSuiteRunScopeRecord`, `Write-TestSuiteRunScopeRecord`, step 7 of `Invoke-TestSuiteLauncher`).
- `Get-FeatureReviewRunScopeSuite`, `Get-FeatureReviewRunScopeRecordPath`, and `Get-FeatureReviewCoverageReportScope` in both freshness files decide `selection` only for a valid record whose window contains the report write time.
- The Claude coverage hook drops the repo-wide line and branch figures for a selection report; the Codex hook drops its line figure. Verdict, narrowing, and freshness checks remain.

The reader is fail-safe in every probed case, the hook branch is covered at 100%, and a real-file probe over the remediation gate's own report and record shows the hook now resolves `selection` where the old grading refused a PASS row at 14.46%. The reviewer's full launcher run at head (29658 tests, 0 failures, 96.87% lines) also confirmed in a real process that a full run writes a `full` record.

One new blocking finding (F4): `Write-TestSuiteRunScopeRecord` is a state-changing function without `SupportsShouldProcess`.

**What changed in this cycle:**
Launcher source, generated copy, and two bundles (+119 lines each); Claude and Codex freshness helpers (+80 to +89 lines each) and coverage hooks (+17 to +27 lines each) with bundles; two new Pester suites (RunScope hook, RunScope launcher) and four extended suites; brief and `test-execution-policy` skill (all copies); spec D3, D11, Data and State, Out of Scope; ledger `0014` and its stored patch; cycle evidence.

**Top risks:**
1. F4: the new record writer does not honor `-WhatIf` or `-Confirm`, contrary to the PowerShell coding standard.
2. D11 takes effect for reviews only after merge, because hooks run from the default branch (RD7); until then a review after a selection run still needs a full run or a FAIL row. Accepted by the plan and disclosed.
3. The selection classifier treats some caller choices (a `-TestPath` naming the whole tree, a pytest space-form `--ignore x.py`) as `selection`; the repo-wide figure still comes from the final-QC artifact and CI, so the effect is limited to the hook's own repo-wide line check.

**PR readiness recommendation:** **Needs Revision** — F3 is resolved; F4 (ShouldProcess on the record writer) must be resolved before merge.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Blocker | `.agents/skills/test-execution-policy/scripts/Invoke-TestSuite.ps1` (generated `.claude/skills/test-execution-policy/scripts/Invoke-TestSuite.ps1` and both bundle copies) | `Write-TestSuiteRunScopeRecord`, line 164 | F4. The function creates a folder (`New-Item -ItemType Directory`) and writes a file (`Set-Content`) with `[CmdletBinding()]` only; it does not declare `SupportsShouldProcess` or call `$PSCmdlet.ShouldProcess`. | Declare `[CmdletBinding(SupportsShouldProcess)]` and wrap the folder creation and write in `if ($PSCmdlet.ShouldProcess($Path, 'Write the test-suite run-scope record'))`; regenerate the `.claude` copy, copy both bundles, add one `-WhatIf` row asserting no write, and regenerate the ledger `0014` stored patch. | `.claude/rules/powershell.md` `## Coding Standards` requires ShouldProcess for state-changing actions; the sibling writer `Write-TestExecutionHolderRecord` in `.claude/hooks/test-execution-lock.ps1` follows it. PSScriptAnalyzer's ShouldProcess rule ignores the `Write` verb, so the clean analyzer run does not catch this. | Source lines 164 to 182 of the `.agents` launcher (`[CmdletBinding()]` at line 173); `git grep SupportsShouldProcess` on the launcher returns nothing. |
| Minor | `.dev/active/1228-targeted-test-cadence/user-story.md` | `## Non-Goals`, last bullet | "Adding or changing hooks, validators, or configuration" contradicts spec D11 and the spec Out of Scope section, which now change two hooks, their Codex twins, and the launcher. | Amend the bullet to name the D11 exception (the feature-review coverage hooks and the launcher run-scope record). | Requirement documents should agree; the spec records the decision, the user story does not. | `user-story.md` line 57; `spec.md` D11 and Out of Scope. |
| Info | `.claude/hooks/validate-feature-review-coverage-freshness.ps1` (and Codex twin) | `Get-FeatureReviewRunScopeSuite` | TypeScript maps to the built-in `jest` suite and the root `coverage/lcov.info`. The repository suite `jest-extension` writes `run-scope.jest-extension.json`, which the hook never reads. | No action for this item; a destination that adds its own Jest suite keeps the repo-wide check (fail-safe direction). | Recorded so a later cycle does not assume every Jest suite is recognized. | `config/test-execution-policy.json`; `artifacts/test-execution/run-scope.jest-extension.json` written by the remediation gate. |
| Info | `.agents/skills/test-execution-policy/scripts/Invoke-TestSuite.ps1` | `Get-TestSuiteRunScope` | A `-TestPath` that names the whole test tree, or a pytest space-form option value ending in `.py` (for example `--ignore x.py`), is classified `selection`. | No action; document if it recurs. | These are caller choices; under D3 the repo-wide figure comes from the final-QC artifact and CI, not from the local report. | Rule text in the function help; reviewer reading of the switch. |
| Info | `artifacts/pester/powershell-coverage.xml`, `artifacts/test-execution/run-scope.pester.json` | n/a | The gate's selection report predated commit `c8a4d99cf`. Because the governing Stop hook is the default branch's copy (RD7), the reviewer snapshotted the gate's report, JUnit, and record and ran the full Pester suite at head; its report and `full` record are left in place. | No action. | Disclosure of reviewer side effects. | Policy audit section 1.2.1. |

No Warning rows: every changed covered file is below 700 logical lines (largest 688).

---

## Implementation Audit

### PowerShell implementation audit

#### What changed well

- The reader fails safe by construction: every early exit returns `full`, the report-time seam is invoked only after the record passes, and C# never reaches the seam. Seventeen direct probes (offset, unzoned, wrong suite, wrong case, duplicate key, array, byte-order mark, non-integer version, out-of-window, null time) all resolve `full`; the inclusive end bound resolves `selection`.
- The launcher takes its clock readings immediately around `StartSuiteProcess`, so the report a suite writes falls inside the window; the reviewer's full run shows report write 15:39:32.592Z inside the window ending 15:39:32.659Z.
- A record write failure is reported with a named stderr prefix and leaves the suite exit code unchanged, so record I/O cannot fail a test gate.
- The Claude hook reads the record through the existing `Get-ArtifactFileContent` seam, so every existing hook suite that mocks that seam with absent results keeps resolving `full` without edits (RD4).
- The Codex twin keeps byte-identical function text, held by the extended parity row.

#### API and safety notes

- F4 above: `Write-TestSuiteRunScopeRecord` needs ShouldProcess.
- `Get-FeatureReviewCoverageReportScope` lets an exception from the write-time seam propagate; the default seam calls `Get-Item -ErrorAction Stop` after `Test-Path`, so this arises only for a file removed between the two calls, and the hook entry's existing error handling fails closed.
- `ConvertFrom-Json` turns a `Z` timestamp into a UTC `DateTime`; the reader accepts both that and a string parsed with the round-trip format, and rejects any non-UTC kind.

#### Test quality notes

- The hook rows exercise both outcomes on the same below-floor report (selection accepted; full, absent, and out-of-window rejected), so reverting the hook branch fails `RSCOPE-HOOK-SELECTION-ACCEPTED` and `-ITEM-ROOT-ACCEPTED`: the reviewer's real-file probe shows the old grading refuses that PASS row at 14.46%.
- `RSCOPE-CONTRACT-LAUNCHER-RECORD` feeds the launcher's own record builder into the hook reader, so a field-name drift between writer and reader fails a row.
- New suites create no file and use `/`-rooted synthetic roots, matching the Linux hook-suite job's constraints.

### Markdown and TOML policy surfaces

- The brief `## Test Isolation Checks` and hook sections and the `test-execution-policy` run-scope subsection name the record in every copy; `RSCOPE-DOC-*` rows pass.
- Generated targets match their sources (`-Check` exit 0 in both modes; Codex variants `--check` exit 0).

### Ledger

- `## Files Changed` lists the cycle's five hook and launcher sources, the generated launcher, six bundle copies, and six test files; `## Revert Steps` adds the cycle-2 copy and regeneration steps and the removal of the two created suites; the stored patch carries their create hunks. The ledger suites pass in the reviewer full run.

---

## Test Coverage Review

- Repo-wide PowerShell lines 96.87% at head (reviewer full run) against the 96.84% `Phase 0 baseline`.
- Changed production files: Claude and Codex coverage hooks 100.00%, both freshness files 98.73%, launcher 93.85%, each at or above its pre-change figure; added and changed executable lines 112 of 113 covered.

---

## Compliance Summary

| Area | Status | Notes |
|---|---|---|
| General code change policy | PASS | Fail-safe design, separation of pure reader and I/O |
| General unit test policy | PASS | Accept and reject rows on the same fixture; no files created |
| PowerShell policy | PARTIAL | F4: ShouldProcess absent on the record writer |
| Harness generation | PASS | No drift in both modes; Codex variants clean |
| Bundle parity | PASS | Byte-identical copies; `AGENTS.md` identical |
| Process-reduction ledger | PASS | Entry extended; chain tests pass |
| CI | Pending | No PR yet; S9 gate |

---

## Recommendation

**Needs revision.** F3 is resolved and pinned by discriminating hook rows. Resolve F4 in one light remediation cycle (ShouldProcess on `Write-TestSuiteRunScopeRecord`, its copies, one `-WhatIf` row, and the ledger stored patch), and amend the user-story non-goal in the same cycle, then re-review.
