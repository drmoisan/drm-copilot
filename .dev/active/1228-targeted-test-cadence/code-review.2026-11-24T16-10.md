# Code Review: targeted-test-cadence (#1228), re-audit after remediation cycle 3

---

**Review Date:** 2026-11-24
**Reviewer:** feature-review agent
**Feature Folder:** `.dev/active/1228-targeted-test-cadence`
**Feature Folder Selection Rule:** the only active folder in the branch diff; its prefix matches issue 1228 in the branch name.
**Base Branch:** `main` (resolved `origin/main` at merge base `23458fade99f40e81b95ce86ed90805258479782`, equal to the fetched `origin/main` tip)
**Head Branch:** `feature/targeted-test-cadence-1228` at `9168cda6fbe3300059aa89f87605633d24ad1326` (equal to the remote branch head)
**Review Type:** Re-audit (remediation cycle 3, light, inputs `remediation-inputs.2026-11-24T15-38.md`)

---

## Executive Summary

The branch changes the orchestration test cadence on every harness surface so that the full test suite runs only at the `Phase 0 baseline` and in the final QA loop, and every other run uses a test selection. Cycle 2 added spec decision D11 (a launcher run-scope record read by the feature-review coverage hooks). The previous review raised one blocking finding, F4: the new record writer `Write-TestSuiteRunScopeRecord` was a state-changing PowerShell function without ShouldProcess.

Remediation commit `9168cda6f` (12 files) resolves F4:

- `Write-TestSuiteRunScopeRecord` now declares `[CmdletBinding(SupportsShouldProcess)]` and wraps the folder creation and `Set-Content` call in `if ($PSCmdlet.ShouldProcess($Path, 'Write the test-suite run-scope record'))`, in the `.agents` source, the generated `.claude` copy, and both bundle copies (all four SHA-256 `7b1f075abddb...`).
- `Invoke-TestSuite.RunScope.Tests.ps1` gains `RSCOPE-LAUNCH-WRITER-WHATIF`, which calls the writer with `-WhatIf` over mocked `Test-Path`, `New-Item`, and `Set-Content` and asserts neither write cmdlet is invoked.
- The ledger `0014` stored patch is regenerated (reverse-apply check exit 0 at head).
- `user-story.md` `## Non-Goals` names the D11 exception (the non-blocking note of the previous review).

Reviewer verification: a real-process probe shows `-WhatIf` creates no folder and writes no file, while a normal call writes the record; two mutants are rejected by the new row's assertions (an attribute-free mutant throws `ParameterBindingException` on `-WhatIf`; an unguarded mutant reaches `New-Item` and `Set-Content`, which the row's zero-call assertions reject); the full launcher Pester run at head ran 29659 tests with 0 failures and 18 skipped, at 96.87% repo-wide PowerShell lines, and wrote a `full` record whose window contains the report write time; generators, Codex variants, and evidence locations are clean.

No blocking finding remains.

**What changed in this cycle:**
One function in the launcher (four byte-identical copies, +6/-4 lines each), one Pester row (+14 lines), the regenerated ledger patch, one user-story non-goal bullet, and the cycle-2 review artifacts and cycle-3 task-check evidence.

**Top risks:**
1. D11 takes effect for reviews only after merge, because hooks run from the default branch (RD7); until then a review after a selection run still needs a full run. Accepted by the plan and disclosed; this review used a full run for that reason.
2. The selection classifier treats some caller choices (a `-TestPath` naming the whole tree, a pytest space-form `--ignore x.py`) as `selection`; the repo-wide figure still comes from the final-QC artifact and CI (carried from the previous review, Info).
3. CI on the PR head has not run; no PR exists yet. The S9 gate confirms the CI rows.

**PR readiness recommendation:** **Ready** — F4 is resolved and pinned by a discriminating row; the remaining step is the S9 CI green gate.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Info | `.agents/skills/test-execution-policy/scripts/Invoke-TestSuite.ps1` (and its generated copy and bundles) | `Write-TestSuiteRunScopeRecord`, lines 164 to 184 | F4 resolved. The writer declares `SupportsShouldProcess` and guards both write calls; exceptions inside the guard still propagate to the launcher's catch, which prints `TEST_EXECUTION_RUN_SCOPE_UNWRITTEN:` and keeps the suite exit code. | No action. | Matches `.claude/rules/powershell.md` `## Coding Standards` and the sibling `Write-TestExecutionHolderRecord`. | `git show 9168cda6f`; real-process `-WhatIf` probe; mutant probes (policy audit section 5). |
| Info | `.claude/hooks/validate-feature-review-coverage-freshness.ps1` (and Codex twin) | `Get-FeatureReviewRunScopeSuite` | Carried from the previous review: the repository suite `jest-extension` writes `run-scope.jest-extension.json`, which the hook does not read; TypeScript maps to the built-in `jest` suite. | No action for this item (fail-safe direction). | Recorded so a later cycle does not assume every Jest suite is recognized. | `config/test-execution-policy.json`. |
| Info | `.agents/skills/test-execution-policy/scripts/Invoke-TestSuite.ps1` | `Get-TestSuiteRunScope` | Carried from the previous review: a `-TestPath` naming the whole test tree, or a pytest space-form option value ending in `.py`, is classified `selection`. | No action; document if it recurs. | Caller choices; under D3 the repo-wide figure comes from the final-QC artifact and CI. | Function help text. |
| Info | `artifacts/pester/powershell-coverage.xml`, `pester-junit.xml`, `artifacts/test-execution/run-scope.pester.json` | n/a | The cycle-3 task-check selection report (written 2026-11-24T15:57:46Z, root 2.71%) predated commit `9168cda6f` (16:04:49Z). The governing Stop hook is the default branch's copy (RD7), so the reviewer snapshotted the report, JUnit, and record and ran the full Pester suite at head; its report and `full` record are left in place. | No action. | Disclosure of reviewer side effects. | Policy audit section 1.2.1. |

No Warning rows: every changed covered file is below 700 logical lines (largest 688, `test-cadence-wording.Tests.ps1`; the launcher is 378 and the RunScope launcher suite 283).

---

## Implementation Audit

### PowerShell implementation audit

#### What changed well

- The guard wraps both state changes (folder creation and record write) and only them; `Split-Path` stays inside the guard, which is harmless.
- The default `WriteRunScope` seam calls the writer without `-WhatIf` or `-Confirm`. With the default `ConfirmImpact` (Medium) and `$ConfirmPreference` (High) no prompt appears, and the reviewer's full launcher run at head wrote the `full` record through this path, which is a real-process confirmation that the guard does not suppress the production write.
- All four copies are byte-identical, and generator `-Check` reports no drift.

#### API and safety notes

- `$WhatIfPreference` propagates into `New-Item` and `Set-Content`, so even an unguarded body would not write under `-WhatIf` in a real process; the new row nonetheless discriminates because it counts calls to the mocked cmdlets.

#### Test quality notes

- `RSCOPE-LAUNCH-WRITER-WHATIF` follows Arrange-Act-Assert and carries `-Because` text on both assertions.
- Mutant probes: removing `SupportsShouldProcess` makes the `-WhatIf` call throw `ParameterBindingException` (the row fails); bypassing the guard (`$true -or $PSCmdlet.ShouldProcess(...)`) reaches `New-Item` and `Set-Content` (the row's `-Times 0 -Exactly` assertions fail).

### Requirement documents

- `user-story.md` `## Non-Goals` now names the D11 exception; no acceptance criterion text changed.

### Ledger

- The stored patch of entry `0014` reverse-applies at head (`git apply -R --check`, template sections excluded as they live under `.dev/templates/`); `## Files Changed` already listed every changed path; the commit subject carries `reduction: 0014`; the ledger chain and index suites pass in the reviewer full run.

---

## Test Coverage Review

- Repo-wide PowerShell lines 96.87% at head (reviewer full run) against the 96.84% `Phase 0 baseline`.
- Changed production files: Claude and Codex coverage hooks 100.00%, both freshness files 98.73%, launcher 93.89% (123 of 131; the added `ShouldProcess` line is covered), each at or above its pre-change figure.

---

## Compliance Summary

| Area | Status | Notes |
|---|---|---|
| General code change policy | PASS | Fail-safe design, separation of pure reader and I/O |
| General unit test policy | PASS | Discriminating `-WhatIf` row; no files created |
| PowerShell policy | PASS | F4 resolved: ShouldProcess on the record writer |
| Harness generation | PASS | No drift in both modes; Codex variants clean |
| Bundle parity | PASS | Four launcher copies byte-identical |
| Process-reduction ledger | PASS | Stored patch regenerated; chain tests pass |
| CI | Pending | No PR yet; S9 gate |

---

## Recommendation

**Ready for PR.** F4 is resolved and pinned by a discriminating row; no blocking finding remains. The S9 CI green gate confirms the CI rows of the policy audit on the PR head.
