# C1a Pre-Edit Re-Verification (P0-T12)

Timestamp: 2026-10-08T22-39
Command: sh SCRATCH/run-ps.sh SCRATCH/region-probe.ps1; grep -r -l -F -e '-ContextExists' tests/scripts; grep -c -F -e '-ContextExists' tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1 tests/scripts/claude-hooks/enforce-pr-author-skill.TargetResolution.Tests.ps1
EXIT_CODE: 0
Output Summary:
- Result: STOP `C1A-REGION-UNANTICIPATED`. Three acceptance items of P0-T12 fail (listed under "Failed acceptance items"). The plan is returned to the planner; no production or test file was edited.
- Tree: HEAD 0982ac62514a999d0413ef112d7a0d42bdc8e117; BASE_SHA 497cb504ad9a4e5435dc8946333ebc28baea50c4 (INTEG tip, contains the C1a merge 1f34ca31).
- CHECK1-FORM: rewritten-by-c1a (see below).

## Failed acceptance items (stop reasons)

1. `FUNCTION-MISSING` lines printed for `.claude/hooks/hook-command-invocation.ps1` (HCI).
   - Expected: `FUNCTION name=Get-CommandLineFlagValue ... params=CommandText,CommandWord,SubcommandPath,FlagName` in HCI (planning-time line 360) and `Test-CommandLineFlag` in HCI (planning-time line 422).
   - Observed: `FUNCTION-MISSING path=.claude/hooks/hook-command-invocation.ps1 name=Get-CommandLineFlagValue` and `FUNCTION-MISSING path=.claude/hooks/hook-command-invocation.ps1 name=Test-CommandLineFlag`. HCI is now 482 lines and dot-sources four siblings (lines 21-24: `hook-command-scanner.ps1`, `hook-command-payload.ps1`, `hook-command-payload-powershell.ps1`, `hook-command-invocation-operands.ps1`).
   - Located by read-only search: both functions moved to the new C1a sibling `.claude/hooks/hook-command-invocation-operands.ps1` — `Get-CommandLineFlagValue` at line 70 (params `CommandText, CommandWord, SubcommandPath, FlagName`, unchanged signature; returns the quote-stripped value of the first Structural match, `$null` when absent) and `Test-CommandLineFlag` at line 125. `Test-CommandLineInvocation` remains in HCI at lines 427-455 (params `CommandText,CommandWord,SubcommandPath`).
   - Impact on the plan: D5/B8 (`Get-PrAuthorBodyFileOperand`) call `Get-CommandLineFlagValue`; the function still exists with the same signature and is reachable through HCI's dot-source of the operands sibling, so the D5 design may still hold, but the P0-T12 acceptance item names HCI as its location and fails as written.

2. `grep -r -l -F -e '-ContextExists' tests/scripts` lists four files, not exactly two.
   - Expected: exactly `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1` and `tests/scripts/claude-hooks/enforce-pr-author-skill.TargetResolution.Tests.ps1`.
   - Observed (two additional C1a suites):
     - `tests/scripts/claude-hooks/enforce-pr-author-skill.Issue824.Tests.ps1` — lines 135, 139, 146, 149 (`Get-PrAuthorBypassReason ... -ContextExists $true`), 4 lines.
     - `tests/scripts/claude-hooks/hook-command-invocation.Issue824Regression.Tests.ps1` — lines 184, 192, 200, 208 (`Get-PrAuthorBypassReason -CommandText $command -ContextExists $true`), 4 lines.
     - `tests/scripts/claude-hooks/enforce-pr-author-skill.TargetResolution.Tests.ps1` (as planned).
     - `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1` (as planned).
   - The `grep -c` command printed the expected `enforce-pr-author-skill.Tests.ps1:6` and `enforce-pr-author-skill.TargetResolution.Tests.ps1:5`.
   - Impact on the plan: B9/B10 remove the `-ContextExists` parameter; the two additional suites are not in Appendix C (C10/C11), EDITED-TESTS, SET-PRA, BASELINE-GREEN, or LC-TESTS, so they would fail with a parameter-binding error after Phase 6 and are not covered by rule CR (the failure is not one of causes a-d).

3. Final-deny regions of both removal gates moved out of the decision functions named by B2 and B4.
   - EREM `.claude/hooks/enforce-epic-worktree-removal-gate.ps1` (452 lines): `Invoke-EpicWorktreeRemovalGateDecision` is lines 277-335 and now iterates derived targets (`Resolve-CommandLineInvocationTarget`, line 321) and calls a new function `Get-EpicWorktreeRemovalTargetDenial -WorktreePath` (lines 337-399, param `WorktreePath`). The final deny prefix anchor is at line 396 and the return anchor at line 398, inside `Get-EpicWorktreeRemovalTargetDenial`, not inside `Invoke-EpicWorktreeRemovalGateDecision` (planning-time: final deny at 399-403 inside `Invoke-EpicWorktreeRemovalGateDecision` 318-404). The reads `$epicRead`/`$parallelRead` are at lines 358-359 of the new function. `Find-EpicWorktreeFeatureRecord` is lines 111-154 (planning-time 152-195); `Test-ParallelCheckpointAllowsWorktreeRemoval` 183-245 (planning-time 224-286).
   - PREM `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1` (464 lines): `Invoke-ParallelWorktreeRemovalGateDecision` is lines 277-336; the final deny prefix anchor is at line 408 and the return anchor at line 410, inside the new function `Get-ParallelWorktreeRemovalTargetDenial` (starts line 338), not inside `Invoke-ParallelWorktreeRemovalGateDecision` (planning-time: final deny at 416-420).
   - Impact on the plan: B2 ("In `Invoke-ParallelWorktreeRemovalGateDecision`, at the final deny") and B4 ("Final deny in `Invoke-EpicWorktreeRemovalGateDecision`") name functions that no longer contain the final deny, and the deny is now evaluated once per derived target. The anchor texts themselves still match. P0-T12 has no explicit function-containment item for these anchors; this item is reported because the planning-time region (function, anchor) was moved by C1a in a way the research did not anticipate.

## Acceptance items that pass

- Every `FILE` line reports `ParseErrors=0`.
- No `ANCHOR-MISSING` line is printed.
- `DOTSOURCE` lines of PRA (146 `enforce-pr-author-skill.epic-base-branch.ps1`, 150 `enforce-pr-author-skill-helpers.ps1`) and PRAH (34 `hook-command-scanner.ps1`, 35 `hook-command-invocation.ps1`) name only the four allowed files.
- `CHECK1-BLOCK start=224 end=236` lies inside `Test-PrAuthorReceiptVerification` (178-301).
- `params=` values: `Read-EpicWorktreeGateRunCheckpoint` `Kind,WorktreePath`; `Resolve-EpicWorktreeGateRunTarget` `Kind,WorktreePath`; `Test-PrAuthorReceiptVerification` `CommandText,CheckpointPath,EpicScope`; `Get-PrAuthorBypassReason` `CommandText,ContextExists`; `Test-PrAuthorBypassRequired` `CommandText,ContextExists`; `Get-PrContextArtifactExistence` empty; `Get-PrContextSummaryLastWriteUtc` empty; `Resolve-EpicMergeGateRunTarget` `Kind,PrNumber`; `Test-ChildCheckpointPrGateBinding` `Checkpoint,CommandPrNumber`; `Get-EpicMergeGateUnresolvedReason` `EpicTarget,ParallelTarget`.
- Line counts: PRA 314 (<=480), PRAH 441 (<=470), MRG 459 (<=480), MRGR 221 (<=440), EREM 452 (<=480), EREMR 144 (<=430), PREM 464 (<=498), WRR 497 (exactly 497), WIR 407 (<=430).

## CHECK1-FORM

CHECK1-FORM: rewritten-by-c1a — Check 1 (PRAH lines 224-235) reads the value structurally through the new PRAH function `Get-PrAuthorBodyFileValue -CommandText` (defined at PRAH line 140) from the matched `gh pr create` (else `gh pr edit`) invocation, normalizes quoted, equals-joined, rooted, `./`-led, and backslash-separated spellings, and accepts only a value that then matches `^artifacts/pr_body_(\d+)\.md$` case-sensitively; body and receipt paths remain relative strings (`artifacts/pr_body_$bodyNumber.md`, lines 234-235) resolved against the process directory. This form alone is anticipated by D5 and would not stop the plan.

## Re-derived planning-time citations (from FUNCTION and ANCHOR lines)

| File | Citation | Planning-time | Re-derived |
| --- | --- | --- | --- |
| PRA | `$script:PrContextArtifactPath = ` | 48 | 48 |
| PRA | `Get-PrContextArtifactExistence` | 55-67 | 55-67 |
| PRA | `Get-PrBodyFileBytes` | 69-95 | 69-95 |
| PRA | `Get-PrAuthorReceiptContent` | 97-122 | 97-122 |
| PRA | `Get-PrContextSummaryLastWriteUtc` | 124-144 | 124-144 |
| PRA | dot-sources epic-base-branch / helpers | 146 / 150 | 146 / 150 |
| PRA | `Invoke-PrAuthorSkillDecision` | 152-193 | 152-193 |
| PRA | `$contextExists = Get-PrContextArtifactExistence` | 185 | 185 |
| PRA | `Test-PrAuthorBypassRequired` | 239-261 | 239-261 |
| PRAH | line count | 384 | 441 |
| PRAH | dot-sources scanner / invocation | 34-35 | 34-35 |
| PRAH | `Resolve-PrAuthorWorktreeTarget` | 51-72 | 51-72 |
| PRAH | `Get-PrAuthorTargetCheckpointResolution` | 74-121 | 74-121 |
| PRAH | `Test-PrAuthorReceiptVerification` | 123-243 | 178-301 |
| PRAH | `# Check 1:` | 169 | 224 |
| PRAH | `# Check 2:` | (not cited) | 237 |
| PRAH | `Get-PrAuthorBypassReason` | 245-384 | 303-441 |
| PRAH | `# Case C:` | 333 | 390 |
| PRAH | `Resolve-EpicScopeCheckpoint -Text $CommandText` | 344 | 401 |
| PRAH | `Get-PrAuthorTargetCheckpointResolution -CommandText $CommandText` | 356 | 413 |
| HCI | `Get-CommandLineFlagValue` | 360 | MISSING in HCI (moved to `hook-command-invocation-operands.ps1:70`) |
| HCI | `Test-CommandLineFlag` | 422 | MISSING in HCI (moved to `hook-command-invocation-operands.ps1:125`) |
| HCI | `Test-CommandLineInvocation` | 240 | 427-455 |
| MRG | dot-sources authorization / resolution | 67 / 69 | 67 / 69 |
| MRG | `Invoke-EpicMergeGateDecision` | 292-406 | 292-406 |
| MRG | child read anchor | 362 | 362 |
| MRG | `Get-EpicMergeGateUnresolvedReason -EpicTarget` | 400 | 400 |
| MRGR | import-failure assignments | 30-36 | 30, 35 |
| MRGR | `Get-EpicMergeGateSessionWorktreeRoot` | 117-129 | 117-129 |
| MRGR | `Resolve-EpicMergeGateRunTarget` | 131-150 | 131-150 |
| MRGR | `Test-ChildCheckpointPrGateBinding` | 152-189 | 152-189 |
| MRGR | `Get-EpicMergeGateUnresolvedReason` | 191-221 | 191-221 |
| EREM | line count | 457 | 452 |
| EREM | resolution dot-source | 77 | 77 |
| EREM | `Find-EpicWorktreeFeatureRecord` | 152-195 | 111-154 |
| EREM | `Test-ParallelCheckpointAllowsWorktreeRemoval` | 224-286 | 183-245 |
| EREM | `Invoke-EpicWorktreeRemovalGateDecision` | 318-404 | 277-335 |
| EREM | prefix anchor | 401 | 396 (in `Get-EpicWorktreeRemovalTargetDenial` 337-399) |
| EREM | return anchor | 403 | 398 (in `Get-EpicWorktreeRemovalTargetDenial` 337-399) |
| EREMR | `Resolve-EpicWorktreeGateRunTarget` | (94-113 research) | 94-113 |
| EREMR | `Read-EpicWorktreeGateRunCheckpoint` | 115-144 | 115-144 |
| PREM | line count | 474 | 464 |
| PREM | `Invoke-ParallelWorktreeRemovalGateDecision` | (contains final deny) | 277-336 |
| PREM | prefix anchor | 418 | 408 (in `Get-ParallelWorktreeRemovalTargetDenial`, starts 338) |
| PREM | return anchor | 420 | 410 (in `Get-ParallelWorktreeRemovalTargetDenial`, starts 338) |
| WRR | `Test-WorktreeRunPathEqual` | 342-358 | 344-358 (function extent; comment above at 342-343) |
| WRR | `$isDrivePath` anchor | 355 | 355 |
| WIR | `Get-WorktreeItemCheckpointText` | 131-149 | 131-149 |
| WIR | `Get-WorktreeItemLiveRoot` | 179-214 | 179-214 |
| WIR | `ConvertTo-WorktreeItemResolvedResult` | 216-256 | 216-256 |
| WIR | `Resolve-WorktreeItemTarget` | (351-396 research) | 351-396 |
| WIR | `Export-ModuleMember -Function` | 398 | 398 |

## Full A15 output

```text
FILE path=.claude/hooks/enforce-pr-author-skill.ps1 LineCount=314 ParseErrors=0
FUNCTION path=.claude/hooks/enforce-pr-author-skill.ps1 name=Get-PrContextArtifactExistence start=55 end=67 params=
FUNCTION path=.claude/hooks/enforce-pr-author-skill.ps1 name=Get-PrBodyFileBytes start=69 end=95 params=BodyFilePath
FUNCTION path=.claude/hooks/enforce-pr-author-skill.ps1 name=Get-PrAuthorReceiptContent start=97 end=122 params=ReceiptFilePath
FUNCTION path=.claude/hooks/enforce-pr-author-skill.ps1 name=Get-PrContextSummaryLastWriteUtc start=124 end=144 params=
FUNCTION path=.claude/hooks/enforce-pr-author-skill.ps1 name=Invoke-PrAuthorSkillDecision start=152 end=193 params=ToolInputRaw
FUNCTION path=.claude/hooks/enforce-pr-author-skill.ps1 name=Test-PrAuthorBypassRequired start=239 end=261 params=CommandText,ContextExists
ANCHOR path=.claude/hooks/enforce-pr-author-skill.ps1 lines=48 text=$script:PrContextArtifactPath = 
ANCHOR path=.claude/hooks/enforce-pr-author-skill.ps1 lines=185 text=$contextExists = Get-PrContextArtifactExistence
DOTSOURCE path=.claude/hooks/enforce-pr-author-skill.ps1 line=146 text=. (Join-Path $PSScriptRoot 'enforce-pr-author-skill.epic-base-branch.ps1')
DOTSOURCE path=.claude/hooks/enforce-pr-author-skill.ps1 line=150 text=. (Join-Path $PSScriptRoot 'enforce-pr-author-skill-helpers.ps1')
FILE path=.claude/hooks/enforce-pr-author-skill-helpers.ps1 LineCount=441 ParseErrors=0
FUNCTION path=.claude/hooks/enforce-pr-author-skill-helpers.ps1 name=Resolve-PrAuthorWorktreeTarget start=51 end=72 params=CommandText
FUNCTION path=.claude/hooks/enforce-pr-author-skill-helpers.ps1 name=Get-PrAuthorTargetCheckpointResolution start=74 end=121 params=CommandText
FUNCTION path=.claude/hooks/enforce-pr-author-skill-helpers.ps1 name=Test-PrAuthorReceiptVerification start=178 end=301 params=CommandText,CheckpointPath,EpicScope
FUNCTION path=.claude/hooks/enforce-pr-author-skill-helpers.ps1 name=Get-PrAuthorBypassReason start=303 end=441 params=CommandText,ContextExists
ANCHOR path=.claude/hooks/enforce-pr-author-skill-helpers.ps1 lines=224 text=# Check 1:
ANCHOR path=.claude/hooks/enforce-pr-author-skill-helpers.ps1 lines=237 text=# Check 2:
ANCHOR path=.claude/hooks/enforce-pr-author-skill-helpers.ps1 lines=390 text=# Case C:
ANCHOR path=.claude/hooks/enforce-pr-author-skill-helpers.ps1 lines=401 text=Resolve-EpicScopeCheckpoint -Text $CommandText
ANCHOR path=.claude/hooks/enforce-pr-author-skill-helpers.ps1 lines=413 text=Get-PrAuthorTargetCheckpointResolution -CommandText $CommandText
DOTSOURCE path=.claude/hooks/enforce-pr-author-skill-helpers.ps1 line=34 text=. (Join-Path $PSScriptRoot 'hook-command-scanner.ps1')
DOTSOURCE path=.claude/hooks/enforce-pr-author-skill-helpers.ps1 line=35 text=. (Join-Path $PSScriptRoot 'hook-command-invocation.ps1')
FILE path=.claude/hooks/hook-command-invocation.ps1 LineCount=482 ParseErrors=0
FUNCTION-MISSING path=.claude/hooks/hook-command-invocation.ps1 name=Get-CommandLineFlagValue
FUNCTION-MISSING path=.claude/hooks/hook-command-invocation.ps1 name=Test-CommandLineFlag
FUNCTION path=.claude/hooks/hook-command-invocation.ps1 name=Test-CommandLineInvocation start=427 end=455 params=CommandText,CommandWord,SubcommandPath
DOTSOURCE path=.claude/hooks/hook-command-invocation.ps1 line=21 text=. (Join-Path $PSScriptRoot 'hook-command-scanner.ps1')
DOTSOURCE path=.claude/hooks/hook-command-invocation.ps1 line=22 text=. (Join-Path $PSScriptRoot 'hook-command-payload.ps1')
DOTSOURCE path=.claude/hooks/hook-command-invocation.ps1 line=23 text=. (Join-Path $PSScriptRoot 'hook-command-payload-powershell.ps1')
DOTSOURCE path=.claude/hooks/hook-command-invocation.ps1 line=24 text=. (Join-Path $PSScriptRoot 'hook-command-invocation-operands.ps1')
FILE path=.claude/hooks/enforce-epic-merge-gate.ps1 LineCount=459 ParseErrors=0
FUNCTION path=.claude/hooks/enforce-epic-merge-gate.ps1 name=Invoke-EpicMergeGateDecision start=292 end=406 params=ToolInputRaw
ANCHOR path=.claude/hooks/enforce-epic-merge-gate.ps1 lines=362 text=$childCheckpoint = ConvertFrom-EpicMergeGateJson -Raw (Get-ChildOrchestratorCheckpointContent
ANCHOR path=.claude/hooks/enforce-epic-merge-gate.ps1 lines=400 text=Get-EpicMergeGateUnresolvedReason -EpicTarget
DOTSOURCE path=.claude/hooks/enforce-epic-merge-gate.ps1 line=64 text=. (Join-Path $PSScriptRoot 'hook-command-scanner.ps1')
DOTSOURCE path=.claude/hooks/enforce-epic-merge-gate.ps1 line=65 text=. (Join-Path $PSScriptRoot 'hook-command-invocation.ps1')
DOTSOURCE path=.claude/hooks/enforce-epic-merge-gate.ps1 line=67 text=. (Join-Path $PSScriptRoot 'enforce-epic-merge-gate-authorization.ps1')
DOTSOURCE path=.claude/hooks/enforce-epic-merge-gate.ps1 line=69 text=. (Join-Path $PSScriptRoot 'enforce-epic-merge-gate-resolution.ps1')
FILE path=.claude/hooks/enforce-epic-merge-gate-resolution.ps1 LineCount=221 ParseErrors=0
FUNCTION path=.claude/hooks/enforce-epic-merge-gate-resolution.ps1 name=Get-EpicMergeGateSessionWorktreeRoot start=117 end=129 params=
FUNCTION path=.claude/hooks/enforce-epic-merge-gate-resolution.ps1 name=Resolve-EpicMergeGateRunTarget start=131 end=150 params=Kind,PrNumber
FUNCTION path=.claude/hooks/enforce-epic-merge-gate-resolution.ps1 name=Test-ChildCheckpointPrGateBinding start=152 end=189 params=Checkpoint,CommandPrNumber
FUNCTION path=.claude/hooks/enforce-epic-merge-gate-resolution.ps1 name=Get-EpicMergeGateUnresolvedReason start=191 end=221 params=EpicTarget,ParallelTarget
ANCHOR path=.claude/hooks/enforce-epic-merge-gate-resolution.ps1 lines=30,35 text=$script:EpicMergeGateResolutionImportFailure = 
FILE path=.claude/hooks/enforce-epic-worktree-removal-gate.ps1 LineCount=452 ParseErrors=0
FUNCTION path=.claude/hooks/enforce-epic-worktree-removal-gate.ps1 name=Find-EpicWorktreeFeatureRecord start=111 end=154 params=Checkpoint,WorktreePath
FUNCTION path=.claude/hooks/enforce-epic-worktree-removal-gate.ps1 name=Test-ParallelCheckpointAllowsWorktreeRemoval start=183 end=245 params=Checkpoint,WorktreePath
FUNCTION path=.claude/hooks/enforce-epic-worktree-removal-gate.ps1 name=Invoke-EpicWorktreeRemovalGateDecision start=277 end=335 params=ToolInputRaw
ANCHOR path=.claude/hooks/enforce-epic-worktree-removal-gate.ps1 lines=396 text=$prefix = "EPIC_WORKTREE_REMOVAL_BLOCKED: 
ANCHOR path=.claude/hooks/enforce-epic-worktree-removal-gate.ps1 lines=398 text=-Reason ($prefix + "EPIC_WORKTREE_REMOVAL_BLOCKED: git worktree remove for
DOTSOURCE path=.claude/hooks/enforce-epic-worktree-removal-gate.ps1 line=74 text=. (Join-Path $PSScriptRoot 'hook-command-scanner.ps1')
DOTSOURCE path=.claude/hooks/enforce-epic-worktree-removal-gate.ps1 line=75 text=. (Join-Path $PSScriptRoot 'hook-command-invocation.ps1')
DOTSOURCE path=.claude/hooks/enforce-epic-worktree-removal-gate.ps1 line=77 text=. (Join-Path $PSScriptRoot 'enforce-epic-worktree-removal-gate-resolution.ps1')
FILE path=.claude/hooks/enforce-epic-worktree-removal-gate-resolution.ps1 LineCount=144 ParseErrors=0
FUNCTION path=.claude/hooks/enforce-epic-worktree-removal-gate-resolution.ps1 name=Read-EpicWorktreeGateRunCheckpoint start=115 end=144 params=Kind,WorktreePath
FUNCTION path=.claude/hooks/enforce-epic-worktree-removal-gate-resolution.ps1 name=Resolve-EpicWorktreeGateRunTarget start=94 end=113 params=Kind,WorktreePath
FILE path=.claude/hooks/enforce-parallel-worktree-removal-gate.ps1 LineCount=464 ParseErrors=0
FUNCTION path=.claude/hooks/enforce-parallel-worktree-removal-gate.ps1 name=Invoke-ParallelWorktreeRemovalGateDecision start=277 end=336 params=ToolInputRaw
ANCHOR path=.claude/hooks/enforce-parallel-worktree-removal-gate.ps1 lines=408 text=$prefix = "PARALLEL_WORKTREE_REMOVAL_BLOCKED: 
ANCHOR path=.claude/hooks/enforce-parallel-worktree-removal-gate.ps1 lines=410 text=-Reason ($prefix + "PARALLEL_WORKTREE_REMOVAL_BLOCKED: git worktree remove for
DOTSOURCE path=.claude/hooks/enforce-parallel-worktree-removal-gate.ps1 line=45 text=. (Join-Path $PSScriptRoot 'hook-command-scanner.ps1')
DOTSOURCE path=.claude/hooks/enforce-parallel-worktree-removal-gate.ps1 line=46 text=. (Join-Path $PSScriptRoot 'hook-command-invocation.ps1')
FILE path=.claude/lib/worktree-resolution/WorktreeRunResolution.psm1 LineCount=497 ParseErrors=0
FUNCTION path=.claude/lib/worktree-resolution/WorktreeRunResolution.psm1 name=Test-WorktreeRunPathEqual start=344 end=358 params=Left,Right
ANCHOR path=.claude/lib/worktree-resolution/WorktreeRunResolution.psm1 lines=355 text=$isDrivePath = ($a -match '^[A-Za-z]:')
FILE path=.claude/lib/worktree-resolution/WorktreeItemResolution.psm1 LineCount=407 ParseErrors=0
FUNCTION path=.claude/lib/worktree-resolution/WorktreeItemResolution.psm1 name=Get-WorktreeItemCheckpointText start=131 end=149 params=Path
FUNCTION path=.claude/lib/worktree-resolution/WorktreeItemResolution.psm1 name=Get-WorktreeItemLiveRoot start=179 end=214 params=SessionRoot,Branch
FUNCTION path=.claude/lib/worktree-resolution/WorktreeItemResolution.psm1 name=ConvertTo-WorktreeItemResolvedResult start=216 end=256 params=WorktreeRoot,SessionRoot,Detail,Branch
FUNCTION path=.claude/lib/worktree-resolution/WorktreeItemResolution.psm1 name=Resolve-WorktreeItemTarget start=351 end=396 params=Text,SessionRoot
ANCHOR path=.claude/lib/worktree-resolution/WorktreeItemResolution.psm1 lines=398 text=Export-ModuleMember -Function
FILE path=tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1 LineCount=497 ParseErrors=0
ANCHOR path=tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1 lines=480 text=emits the unchanged epic block reason
ANCHOR path=tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1 lines=28,439 text=WorktreeRoot = '/synthetic-worktrees/default-session'
ANCHOR path=tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1 lines=182,183,445 text={"features":[]}
ANCHOR path=tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1 lines=425,426,446 text={"route_id":"parallel","items":[]}
FILE path=tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.WorktreeResolution.Tests.ps1 LineCount=166 ParseErrors=0
ANCHOR path=tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.WorktreeResolution.Tests.ps1 lines=103 text=Y3 denies with TARGET_WORKTREE_NOT_DERIVABLE
ANCHOR path=tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.WorktreeResolution.Tests.ps1 lines=147 text=Y6 denies naming WorktreeRunResolution.psm1
DOTSOURCE path=tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.WorktreeResolution.Tests.ps1 line=27 text=. (Join-Path $PSScriptRoot 'WorktreeResolutionFixture.Helpers.ps1')
FILE path=tests/scripts/claude-hooks/enforce-epic-merge-gate.WorktreeResolution.Tests.ps1 LineCount=220 ParseErrors=0
ANCHOR path=tests/scripts/claude-hooks/enforce-epic-merge-gate.WorktreeResolution.Tests.ps1 lines=127 text=M5 allows a child merge whose checkpoint records no pr_gate, as before the change
DOTSOURCE path=tests/scripts/claude-hooks/enforce-epic-merge-gate.WorktreeResolution.Tests.ps1 line=29 text=. (Join-Path $PSScriptRoot 'WorktreeResolutionFixture.Helpers.ps1')
FILE path=tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1 LineCount=456 ParseErrors=0
ANCHOR path=tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1 lines=12 text=Mock Resolve-EpicMergeGateRunTarget { [pscustomobject]@{ Status = 'SessionRoot'
FILE path=tests/scripts/claude-hooks/enforce-epic-merge-gate.Authorization.Tests.ps1 LineCount=169 ParseErrors=0
ANCHOR path=tests/scripts/claude-hooks/enforce-epic-merge-gate.Authorization.Tests.ps1 lines=75 text=Mock Resolve-EpicMergeGateRunTarget { [pscustomobject]@{ Status = 'SessionRoot'
FILE path=tests/scripts/claude-hooks/enforce-epic-merge-gate.TriggerScoping.Tests.ps1 LineCount=175 ParseErrors=0
ANCHOR path=tests/scripts/claude-hooks/enforce-epic-merge-gate.TriggerScoping.Tests.ps1 lines=39 text=Mock Resolve-EpicMergeGateRunTarget { [pscustomobject]@{ Status = 'SessionRoot'
FILE path=tests/scripts/claude-hooks/hook-command-parser.AcceptanceCases.Tests.ps1 LineCount=229 ParseErrors=0
ANCHOR path=tests/scripts/claude-hooks/hook-command-parser.AcceptanceCases.Tests.ps1 lines=69 text=Mock Resolve-EpicMergeGateRunTarget { [pscustomobject]@{ Status = 'SessionRoot'
FILE path=tests/scripts/claude-hooks/enforce-pr-author-skill.WorktreeResolution.Tests.ps1 LineCount=399 ParseErrors=0
ANCHOR path=tests/scripts/claude-hooks/enforce-pr-author-skill.WorktreeResolution.Tests.ps1 lines=67 text=$script:OwnBranchCommand = 
ANCHOR path=tests/scripts/claude-hooks/enforce-pr-author-skill.WorktreeResolution.Tests.ps1 lines=64 text=$script:CaptureRoot = 
DOTSOURCE path=tests/scripts/claude-hooks/enforce-pr-author-skill.WorktreeResolution.Tests.ps1 line=52 text=. (Join-Path $PSScriptRoot 'WorktreeResolutionFixture.Helpers.ps1')
FILE path=tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Tests.ps1 LineCount=373 ParseErrors=0
ANCHOR path=tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Tests.ps1 lines=9 text=Eight hook suites
ANCHOR path=tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Tests.ps1 lines=15 text=each of the eight committed suites
DOTSOURCE path=tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Tests.ps1 line=34 text=. (Join-Path $PSScriptRoot 'EpicStateIsolation.Helpers.ps1')
FILE path=tests/scripts/claude-lib/worktree-resolution/WorktreeRunResolution.Record.Tests.ps1 LineCount=441 ParseErrors=0
ANCHOR path=tests/scripts/claude-lib/worktree-resolution/WorktreeRunResolution.Record.Tests.ps1 lines=239 text=B13 resolves NoTarget
CHECK1-BLOCK start=224 end=236
CHECK1-LINE 224:     # Check 1: the --body-file argument must match the canonical artifacts/pr_body_<N>.md pattern.
CHECK1-LINE 225:     # Issue #824: the value is read structurally from the matched gh pr create (else gh pr
CHECK1-LINE 226:     # edit) invocation, so a quoted, equals-joined, rooted, './'-led, or backslash-separated
CHECK1-LINE 227:     # spelling of the canonical path is normalized before the case-sensitive (-cmatch) test.
CHECK1-LINE 228:     $bodyFileValue = Get-PrAuthorBodyFileValue -CommandText $CommandText
CHECK1-LINE 229:     if ($null -eq $bodyFileValue -or $bodyFileValue -cnotmatch '^artifacts/pr_body_(\d+)\.md$') {
CHECK1-LINE 230:         return "PR_BODY_PATH_NONCANONICAL: ``--body-file`` must reference a canonical ``artifacts/pr_body_<N>.md`` file produced by the pr-author skill. The path supplied does not match ``artifacts/pr_body_<N>.md``."
CHECK1-LINE 231:     }
CHECK1-LINE 232: 
CHECK1-LINE 233:     $bodyNumber = [int]$Matches[1]
CHECK1-LINE 234:     $bodyFilePath = "artifacts/pr_body_$bodyNumber.md"
CHECK1-LINE 235:     $receiptFilePath = "artifacts/pr_body_$bodyNumber.receipt.json"
CHECK1-LINE 236:
```

## grep outputs

`grep -r -l -F -e '-ContextExists' tests/scripts`:

```text
tests/scripts/claude-hooks/enforce-pr-author-skill.Issue824.Tests.ps1
tests/scripts/claude-hooks/enforce-pr-author-skill.TargetResolution.Tests.ps1
tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1
tests/scripts/claude-hooks/hook-command-invocation.Issue824Regression.Tests.ps1
```

`grep -c -F -e '-ContextExists' <two suites>`:

```text
tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1:6
tests/scripts/claude-hooks/enforce-pr-author-skill.TargetResolution.Tests.ps1:5
```

## Stop record

STOP: C1A-REGION-UNANTICIPATED at [P0-T12]. P0-T12 is left unchecked. P0-T13 onward were not executed. The plan is returned to the planner with this artifact.
