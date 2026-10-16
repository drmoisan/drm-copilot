# Remediation Inputs — final-pass review (issue #935)

Review-Verdict: REMEDIATION_REQUIRED

Timestamp: 2026-10-16T20-56
Head reviewed: `a266488308a85e5febb828ca8cdde7a98a84fa4c` (local; one docs-only commit ahead of the pushed `048d76cd8`, PR #956)
Review artifacts:
- `docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/policy-audit.2026-10-16T20-56.md`
- `docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/code-review.2026-10-16T20-56.md`
- `docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/feature-audit.2026-10-16T20-56.md`
Prior inputs: `remediation-inputs.2026-10-16T16-02.md` (COV-1 `external_dependency`; DOC-1, EV-2, SYNC-1). COV-1 is dispositioned by `evidence/other/cov1-decision-option1.2026-10-16T20-38.md`; DOC-1 is fixed; EV-2 is superseded; SYNC-1 is resolved by the merge at `048d76cd8`.
Operator ruling for this pass: every finding below, including the non-blocking ones, is fixed in this pass.

CI context: run 38963921545 on `048d76cd8` (code identical to HEAD) concluded success; Windows JUnit 10793 testcases, 0 failures; root line coverage 89.66% (16531/18437).

## Finding TEST-1: F-1 conditional-ancestor edge cases have no rows

Severity: Blocking
Remediability: autonomous
Remediability-Evidence: The missing rows belong in `tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Branches.Tests.ps1`, a Write Set file; no external system or decision is involved.

- File and location: `tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Branches.Tests.ps1`, Describe `issue #903 F-1 conditional ancestors` (lines 205-335), `It 'F-1 non-compliant <Branch>'` `-ForEach` table (lines 206-258). Behaviour under test: `Test-EpicStateIsolationConditionalAncestor` in `tests/scripts/claude-hooks/EpicStateIsolation.Helpers.ps1` lines 118-122.
- Problem: the spec `## Test Strategy` requires the edge cases "`else`/multi-clause `if`; `switch`, loop, `try`, `trap`". Only `try` and `if ($false)` are covered; `switch`, loops, `trap`, an `if` with `else`, and an `if`/`elseif` are not.
- Fix: add six entries to that `-ForEach` table, each using the existing fixture skeleton (hook binding line, `. $script:UnderTest`, `Import-Module ./EpicScopeResolution.psm1`, the WorktreeRunResolution import and Mock) with the ESR Mock placed inside the named construct, and the existing assertion (`Mock of Get-EpicScopeCheckpointText missing from outermost BeforeAll`):
  1. `ESR mock inside switch`: `switch ('x') { 'x' { Mock Get-EpicScopeCheckpointText -ModuleName EpicScopeResolution { $null } } }`
  2. `ESR mock inside foreach`: `foreach ($item in @(1)) { Mock ... }`
  3. `ESR mock inside while`: `while ($false) { Mock ... }`
  4. `ESR mock inside trap`: `trap { Mock ...; continue }`
  5. `ESR mock inside a matching Get-Command guard with else`: `if (Get-Command Get-EpicScopeCheckpointText -ErrorAction SilentlyContinue) { Mock ... } else { }`
  6. `ESR mock inside a matching Get-Command guard with elseif`: `if (Get-Command Get-EpicScopeCheckpointText -ErrorAction SilentlyContinue) { Mock ... } elseif ($true) { }`
  Keep all existing row names. The file is 335 lines; the additions keep it under 500. Run the format, analyze and test loop afterwards.

## Finding AC-CHK-1: AC-24 is checked ahead of verification

Severity: Blocking
Remediability: autonomous
Remediability-Evidence: The checkbox and its amendment line are in `spec.md`, a Write Set feature-folder document; the option 1 decision itself is unchanged by the fix.

- File and location: `docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/spec.md` line 214 (`- [x] AC-24: ...`) and line 215 (amendment).
- Problem: the amendment states AC-24 is "not met as written for the baseline comparison", and its floor and no-exclusion clauses refer to the final PR head, which will change with this pass and has no CI. `acceptance-criteria-tracking` rule 4 (non-negotiable) requires such an item to stay `- [ ]`; `### CI-Dependent Criteria` requires the check-off at S9 only. The decision record `evidence/other/cov1-decision-option1.2026-10-16T20-38.md` line 19 instructed the check-off.
- Fix:
  1. Change line 214 from `- [x] AC-24:` to `- [ ] AC-24:` without changing the criterion text.
  2. Append to the amendment line 215: "Left unchecked under acceptance-criteria-tracking rule 4 until S9; P7-T10 records AC-24 as ACCEPTED-OPTION-1 when P7-T6 confirms the 85% floor and no exclusion on the final head."
  3. Write `evidence/other/ac24-checkbox-note.<timestamp>.md` stating the change, citing decision-record line 19 as the superseded instruction and line 15 with the precise source `evidence/qa-gates/r3-ps-test-repo.2026-10-16T15-50.md` line 14 (EV-3). Do not edit the decision record.

## Finding COV-2: on-disk PowerShell coverage file holds a scoped run

Severity: Blocking
Remediability: autonomous
Remediability-Evidence: Regenerating the file is a local `mcp__drm-copilot__run_poshqc_test` call with no scan folders, inside the item worktree; it changes no Write Set exclusion and no coverage configuration.

- File and location: `artifacts/pester/powershell-coverage.xml` (report `Pester (10/16/2026 20:47:22)`), written by the 13-suite shuffled run recorded in `evidence/qa-gates/shuffled-suite-run.2026-10-16T20-48.md`.
- Problem: the root LINE counter reads covered 1994, missed 16443 (10.82%). The review contract reads this file as the repo-wide PowerShell figure; 10.82% is below the 85% floor. The prior repository-scope local file (94.33%) was overwritten.
- Fix: after the code fixes in this pass, run `mcp__drm-copilot__run_poshqc_test` at repository scope (scan_folders omitted) as the last test call before the review re-runs, and write `evidence/qa-gates/r4-ps-test-repo.<timestamp>.md` with the call disposition, the report stamp and the root LINE counter of `artifacts/pester/powershell-coverage.xml`. Acceptance: root line coverage at least 85.00%. Do not run a scoped Pester call after it.

## Non-blocking related findings (fix in this pass)

- CR-F1 (Low): `tests/scripts/claude-hooks/EpicStateIsolation.HookReference.Helpers.ps1` lines 7-9 claim a call to `Get-EpicStateIsolationStringConstant`, which the file never makes. Fix: "This file is dot-sourced from the top of EpicStateIsolation.Helpers.ps1 and calls one helper defined there (Get-EpicStateIsolationElementText) at run time."
- CR-F2 (Low): add `[CmdletBinding()]` before `[OutputType(...)]` in the twelve functions added by #935 that lack it: HookReference helper lines 152, 176, 193, 219, 234, 301, 317, 329, 392 (`Get-EpicStateIsolationVariableBinding`, `Test-EpicStateIsolationHooksRootBinding`, `Get-EpicStateIsolationJoinPathPart`, `Get-EpicStateIsolationJoinPathSegment`, `Test-EpicStateIsolationHookReference`, `Test-EpicStateIsolationHelperDotSource`, `Get-EpicStateIsolationHookRoot`, `Get-EpicStateIsolationReferenceRecord`, `Get-EpicStateIsolationHookReference`); `EpicStateIsolation.Helpers.ps1` line 109 (`Test-EpicStateIsolationConditionalAncestor`); `EpicStateIsolation.Discovery.Helpers.ps1` line 243 (`Get-EpicStateVariableHookLoad`); `EpicStateIsolation.Compliance.Helpers.ps1` line 209 (`Get-EpicStateVariableHookLoadReport`). Leave the four functions moved unchanged from main as they are.
- CR-F3 (Info): HookReference helper lines 220-221: change "$null for a segment that is not a string constant" to "an empty string for a segment that is not a string constant" (line 230 emits `[string]$null`).
- CR-F4 (Info): HookReference helper line 26 (`ExpandableLeaf`): replace with `'^\$(?:\{(?<var>[A-Za-z_][A-Za-z0-9_]*(:[A-Za-z_][A-Za-z0-9_]*)?)\}|(?<var>[A-Za-z_][A-Za-z0-9_]*(:[A-Za-z_][A-Za-z0-9_]*)?))[\\/](?<leaf>[^\\/]+)$'` so braces must balance; add an `R1 does not identify <Case>` entry `unbalanced brace` with `"$HookRoot}/enforce-x.ps1"` and `$HookRoot = '.claude/hooks'` in `enforce-gate-suites.EpicStateIsolation.HookReference.Tests.ps1` (table at lines 121-138).
- CR-F5 (Info): `EpicStateIsolation.Discovery.Helpers.ps1` line 137: use `$hookLiteralPattern = Get-EpicStateIsolationPattern -Name HookLiteral` (declared before the loop) instead of the inlined identical regex; line 131 comment: "excluding EpicStateIsolation helper files and test files".
- CR-F6 (Info): `EpicStateIsolation.Helpers.ps1` line 6: "Dot-sourced by the enforce-gate-suites.EpicStateIsolation suites (legacy guard, Branches, Predicate, Discovery, HookReference)."; `EpicStateIsolation.Discovery.Helpers.ps1` lines 6-7: add the HookReference suite as a consumer.
- CR-F7 (Info): `enforce-gate-suites.EpicStateIsolation.HookReference.Tests.ps1` header lines 8-16: add a sentence describing the F-3, CR-N3 and CR-R1 Describes (lines 240, 358, 431).
- CR-F8 (Info): `enforce-epic-worktree-removal-gate.ManifestBranch.Tests.ps1` lines 16-19: replace "the pre-existing Describe above" with "the pre-existing Describe in enforce-epic-worktree-removal-gate.Tests.ps1".
- PLAN-1 (Low): `plan.2026-10-15T17-44.md` line 205 (P7-T6) acceptance: "post-change percent is at least 85.00; the baseline percent, main at the same population and the per-file diff are recorded; the baseline clause is accepted under `evidence/other/cov1-decision-option1.2026-10-16T20-38.md`". Line 209 (P7-T10): allow `ACCEPTED-OPTION-1` for AC-24 with that record name, and check AC-24 only in that state. Owner: orchestrator.
- DOC-2 (Low): PR #956 description: remove the `## Suggested title` section (body lines 1-3); replace the 90.17% example in `## Coverage (COV-1 / AC-24)` with the final-head figure, the baseline, main at the same population and the 85% floor from P7-T6; add the `origin/main` merge, `evidence/other/pre-mortem.2026-10-16T20-48.md` and `evidence/qa-gates/shuffled-suite-run.2026-10-16T20-48.md` to `### Completed (local)`. Owner: orchestrator (pr-author re-run after S9 data exists).
- DOC-3 (Info): `spec.md` lines 6-8: `Last Updated: 2026-10-16`, `Version: 0.3`, and update `Status` from `Draft` to the implemented state used by the template.
- DOC-4 (Info): `issue.md` line 5: correct the folder to `docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/`; check the two `## Next Step` boxes (lines 66-67), which are not acceptance criteria.
- EV-3 (Info): resolved by step 3 of the AC-CHK-1 fix (precise citation for the 94.33% figure).

## Pending CI (no finding)

- PC-1: after the fixes are pushed, final-head confirmation of AC-1..AC-8, AC-10..AC-12, AC-14..AC-19, AC-23 and the AC-24 floor clause (P7-T2..P7-T10), including the AC-12 CI-log extract under `evidence/other/` and the AC-18 post-split record. Run 38963921545 on `048d76cd8` satisfied each on code identical to HEAD. Owner: orchestrator at S9.
