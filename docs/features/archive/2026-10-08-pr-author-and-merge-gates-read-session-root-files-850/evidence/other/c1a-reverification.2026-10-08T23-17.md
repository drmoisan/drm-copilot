# P0-T12 Pre-edit re-verification on the merged tree (revision 3 re-run)

Timestamp: 2026-10-08T23-17
Command: sh SCRATCH/run-ps.sh SCRATCH/region-probe.ps1 ; grep -r -l -F -e '-ContextExists' tests/scripts ; grep -c -F -e '-ContextExists' tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1 tests/scripts/claude-hooks/enforce-pr-author-skill.TargetResolution.Tests.ps1 tests/scripts/claude-hooks/enforce-pr-author-skill.Issue824.Tests.ps1 tests/scripts/claude-hooks/hook-command-invocation.Issue824Regression.Tests.ps1
EXIT_CODE: 0
Output Summary: All acceptance items of P0-T12 (revision 3) pass. Every FILE line reports ParseErrors=0; no FUNCTION-MISSING or ANCHOR-MISSING line; PRA/PRAH DOTSOURCE lines name only the four permitted siblings; HCI dot-sources hook-command-invocation-operands.ps1; CHECK1-BLOCK 224-236 lies inside Test-PrAuthorReceiptVerification (178-301) and contains `Get-PrAuthorBodyFileValue -CommandText $CommandText` (line 228); HCIO functions carry params=CommandText,CommandWord,SubcommandPath,FlagName; EREM anchors 396/398 lie inside Get-EpicWorktreeRemovalTargetDenial (337-399); PREM anchors 408/410 lie inside Get-ParallelWorktreeRemovalTargetDenial (338-411); all fourteen params= values match; the grep -r -l lists exactly the four expected suites; the grep -c counts are 6/5/4/4; line counts PRA 314, PRAH 441, MRG 459, MRGR 221, EREM 452, EREMR 144, PREM 464, WRR 497, WIR 407 are within limits. No stop condition fired.

Note: SCRATCH resolves to the session scratchpad subdirectory `x850` in this session (a new session; A1-A17 were re-created verbatim from Appendix H, A15 from revision 3). The stopped run's artifact `c1a-reverification.2026-10-08T22-39.md` is not modified.

CHECK1-FORM: rewritten-by-c1a — the block reads the value through `Get-PrAuthorBodyFileValue` (structural read of the first `gh pr create`, else `gh pr edit`, `--body-file` operand; quoted, equals-joined, './'-led, and backslash spellings normalized, and a rooted value made relative to `Get-PrAuthorBodyFileRoot`, the process directory) and accepts only a value matching the case-sensitive `^artifacts/pr_body_(\d+)\.md$`, resolving the body and receipt relative to the process directory.

## Re-derived citations (Current-tree facts list)

| File | Citation | Re-derived |
| --- | --- | --- |
| PRA | 314 lines; `$script:PrContextArtifactPath` | 314; line 48 |
| PRA | Get-PrContextArtifactExistence | 55-67, params= (empty) |
| PRA | Get-PrBodyFileBytes / Get-PrAuthorReceiptContent | 69-95 / 97-122 |
| PRA | Get-PrContextSummaryLastWriteUtc | 124-144, params= (empty) |
| PRA | dot-sources epic-base-branch / helpers | 146 / 150 |
| PRA | Invoke-PrAuthorSkillDecision; probe | 152-193; line 185 |
| PRA | Test-PrAuthorBypassRequired | 239-261, params=CommandText,ContextExists |
| PRAH | 441 lines; dot-sources scanner/invocation | 441; 34 / 35 |
| PRAH | Resolve-PrAuthorWorktreeTarget | 51-72 |
| PRAH | Get-PrAuthorTargetCheckpointResolution | 74-121 |
| PRAH | Get-PrAuthorBodyFileRoot | 123-138, params= (empty) |
| PRAH | Get-PrAuthorBodyFileValue | 140-176, params=CommandText |
| PRAH | Test-PrAuthorReceiptVerification | 178-301, params=CommandText,CheckpointPath,EpicScope |
| PRAH | Check 1 / Check 2 anchors | 224 / 237 (CHECK1-BLOCK 224-236) |
| PRAH | Get-PrAuthorBypassReason | 303-441, params=CommandText,ContextExists |
| PRAH | Case C / Resolve-EpicScopeCheckpoint / target resolution | 390 / 401 / 413 |
| HCI | 482 lines; operands dot-source | 482; line 24 |
| HCI | Test-CommandLineInvocation | 427-455 |
| HCIO | Get-CommandLineFlagValue / Test-CommandLineFlag | 70-123 / 125-156 |
| MRG | 459 lines; dot-sources authorization/resolution | 459; 67 / 69 |
| MRG | Invoke-EpicMergeGateDecision; child read; unresolved call | 292-406; 362; 400 |
| MRGR | 221 lines; import guard anchor | 221; 30, 35 |
| MRGR | Get-EpicMergeGateSessionWorktreeRoot | 117-129 |
| MRGR | Resolve-EpicMergeGateRunTarget | 131-150, params=Kind,PrNumber |
| MRGR | Test-ChildCheckpointPrGateBinding | 152-189, params=Checkpoint,CommandPrNumber |
| MRGR | Get-EpicMergeGateUnresolvedReason | 191-221, params=EpicTarget,ParallelTarget |
| EREM | 452 lines; resolution dot-source | 452; 77 |
| EREM | Find-EpicWorktreeFeatureRecord / Test-ParallelCheckpointAllowsWorktreeRemoval | 111-154 / 183-245 |
| EREM | Invoke-EpicWorktreeRemovalGateDecision | 277-335 |
| EREM | Get-EpicWorktreeRemovalTargetDenial; prefix; return | 337-399; 396; 398 |
| EREMR | 144 lines; Resolve-EpicWorktreeGateRunTarget | 144; 94-113, params=Kind,WorktreePath |
| EREMR | Read-EpicWorktreeGateRunCheckpoint | 115-144, params=Kind,WorktreePath |
| PREM | 464 lines; Invoke-ParallelWorktreeRemovalGateDecision | 464; 277-336 |
| PREM | Get-ParallelWorktreeRemovalTargetDenial; prefix; return | 338-411; 408; 410 |
| WRR | 497 lines; Test-WorktreeRunPathEqual; drive anchor | 497; 344-358 (function extent; comment 342-343); 355 |
| WIR | 407 lines; Get-WorktreeItemCheckpointText | 407; 131-149 |
| WIR | Get-WorktreeItemLiveRoot / ConvertTo-WorktreeItemResolvedResult | 179-214 / 216-256 |
| WIR | Resolve-WorktreeItemTarget; export list | 351-396; 398 |

## grep -r -l -F -e '-ContextExists' tests/scripts

```text
tests/scripts/claude-hooks/enforce-pr-author-skill.Issue824.Tests.ps1
tests/scripts/claude-hooks/enforce-pr-author-skill.TargetResolution.Tests.ps1
tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1
tests/scripts/claude-hooks/hook-command-invocation.Issue824Regression.Tests.ps1
```

## grep -c -F -e '-ContextExists' (four suites)

```text
tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1:6
tests/scripts/claude-hooks/enforce-pr-author-skill.TargetResolution.Tests.ps1:5
tests/scripts/claude-hooks/enforce-pr-author-skill.Issue824.Tests.ps1:4
tests/scripts/claude-hooks/hook-command-invocation.Issue824Regression.Tests.ps1:4
```

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
FUNCTION path=.claude/hooks/enforce-pr-author-skill-helpers.ps1 name=Get-PrAuthorBodyFileRoot start=123 end=138 params=
FUNCTION path=.claude/hooks/enforce-pr-author-skill-helpers.ps1 name=Get-PrAuthorBodyFileValue start=140 end=176 params=CommandText
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
FUNCTION path=.claude/hooks/hook-command-invocation.ps1 name=Test-CommandLineInvocation start=427 end=455 params=CommandText,CommandWord,SubcommandPath
DOTSOURCE path=.claude/hooks/hook-command-invocation.ps1 line=21 text=. (Join-Path $PSScriptRoot 'hook-command-scanner.ps1')
DOTSOURCE path=.claude/hooks/hook-command-invocation.ps1 line=22 text=. (Join-Path $PSScriptRoot 'hook-command-payload.ps1')
DOTSOURCE path=.claude/hooks/hook-command-invocation.ps1 line=23 text=. (Join-Path $PSScriptRoot 'hook-command-payload-powershell.ps1')
DOTSOURCE path=.claude/hooks/hook-command-invocation.ps1 line=24 text=. (Join-Path $PSScriptRoot 'hook-command-invocation-operands.ps1')
FILE path=.claude/hooks/hook-command-invocation-operands.ps1 LineCount=198 ParseErrors=0
FUNCTION path=.claude/hooks/hook-command-invocation-operands.ps1 name=Get-CommandLineFlagValue start=70 end=123 params=CommandText,CommandWord,SubcommandPath,FlagName
FUNCTION path=.claude/hooks/hook-command-invocation-operands.ps1 name=Test-CommandLineFlag start=125 end=156 params=CommandText,CommandWord,SubcommandPath,FlagName
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
FUNCTION path=.claude/hooks/enforce-epic-worktree-removal-gate.ps1 name=Get-EpicWorktreeRemovalTargetDenial start=337 end=399 params=WorktreePath
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
FUNCTION path=.claude/hooks/enforce-parallel-worktree-removal-gate.ps1 name=Get-ParallelWorktreeRemovalTargetDenial start=338 end=411 params=WorktreePath
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
FILE path=tests/scripts/claude-hooks/enforce-pr-author-skill.Issue824.Tests.ps1 LineCount=161 ParseErrors=0
ANCHOR path=tests/scripts/claude-hooks/enforce-pr-author-skill.Issue824.Tests.ps1 lines=93 text=WorktreeRoot = (Get-Location).Path
ANCHOR path=tests/scripts/claude-hooks/enforce-pr-author-skill.Issue824.Tests.ps1 lines=97 text=Mock Get-PrAuthorBodyFileRoot
ANCHOR path=tests/scripts/claude-hooks/enforce-pr-author-skill.Issue824.Tests.ps1 lines=126 text=-CheckpointPath 'unused-checkpoint-path'
ANCHOR path=tests/scripts/claude-hooks/enforce-pr-author-skill.Issue824.Tests.ps1 lines=157 text=PA-21 returns the current location as the body-file root
ANCHOR path=tests/scripts/claude-hooks/enforce-pr-author-skill.Issue824.Tests.ps1 lines=17 text=the receipt, and the body-file root arrive only through mocked seams
FILE path=tests/scripts/claude-hooks/hook-command-invocation.Issue824Regression.Tests.ps1 LineCount=284 ParseErrors=0
ANCHOR path=tests/scripts/claude-hooks/hook-command-invocation.Issue824Regression.Tests.ps1 lines=217 text=Mock Get-PrAuthorBodyFileRoot
ANCHOR path=tests/scripts/claude-hooks/hook-command-invocation.Issue824Regression.Tests.ps1 lines=221,227,233,239,245 text=-CheckpointPath '/synthetic/checkpoint.json'
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
