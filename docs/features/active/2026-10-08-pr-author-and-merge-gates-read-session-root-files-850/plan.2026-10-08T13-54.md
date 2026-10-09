# 2026-10-08-pr-author-and-merge-gates-read-session-root-files (Plan)

- **Issue:** #850 (bundles #788, #789, #851)
- **Parent (optional):** Epic #852 (enforcement-hook-precision), child C3
- **Owner:** drmoisan
- **Last Updated:** 2026-10-08T23-45
- **Status:** Revised for preflight (revision 4, after the P0-T17 stop `BASELINE-RED-IN-EDITED-SUITE`; P0-T1 through P0-T16 complete)
- **Version:** 1.4
- **Work Mode:** full-bug (`spec.md` is the sole acceptance-criteria source; `user-story.md` is absent by design)
- **Branch:** `bug/pr-author-and-merge-gates-read-session-root-files-exec-850` (execution; prepared on `bug/pr-author-and-merge-gates-read-session-root-files-850`)
- **Integration branch:** `epic/enforcement-hook-precision-integration`
- **Inputs:** `issue.md`, `spec.md` (47 criteria), `research/research.2026-10-08T14-00.md`, `docs/features/epics/enforcement-hook-precision/epic.md`

**Fail-closed evidence rule:** Include explicit baseline artifact tasks, final-QA artifact tasks, and coverage-comparison tasks for each in-scope language when policy requires coverage. If any required baseline artifact, QA artifact, or coverage-comparison artifact is missing, the audit verdict must be BLOCKED or INCOMPLETE, never PASS.

**Evidence accounting rule:** Record the expected artifact path in each evidence-producing task. Do not mark evidence-backed work complete without the artifact.

## Revision History

- **Revision 1 (1.1) and revision 2 (1.2), 2026-10-08:** preflight rounds 1 and 2; preflight clearance recorded in `evidence/other/preflight-clearance.2026-10-08T21-55.md`.
- **Revision 3 (1.3), 2026-10-08T23-30:** execution stopped by design at P0-T12 with `C1A-REGION-UNANTICIPATED`; stop evidence `evidence/other/c1a-reverification.2026-10-08T22-39.md` (paths relative to FEATURE). P0-T1 through P0-T11 stay checked with their evidence unchanged. Changes, limited to the three stop regions and the drift they cause: (1) #824 moved `Get-CommandLineFlagValue` and `Test-CommandLineFlag` into `.claude/hooks/hook-command-invocation-operands.ps1`; the facts, A15, and P0-T12 name that file, and D5/B8 now reuse #824's `Get-PrAuthorBodyFileValue` instead of a new operand reader (D12). (2) `-ContextExists` now occurs in four suites; the two #824 suites join EDITED-TESTS, SET-PRA, BASELINE-GREEN, and LC-TESTS, receive edit specifications C15 and C16, and are edited by new tasks P6-T11 and P6-T12 (Phase 6 tasks after P6-T10 are renumbered by two). (3) Both removal gates' final denies now live in the #824 per-target functions `Get-ParallelWorktreeRemovalTargetDenial` and `Get-EpicWorktreeRemovalTargetDenial`; B2, B4, and A15 name them (D14). D13 records the scope #824 already delivered. CMD-GIT-PUSH pushes with an explicit refspec (D-EXEC-1). Every line number in the facts list, P0-T12, and the review record was re-derived on the tree at BASE_SHA `497cb504`.
- **Revision 4 (1.4), 2026-10-08T23-45:** execution stopped by design at P0-T17 with `BASELINE-RED-IN-EDITED-SUITE`; stop evidence `evidence/other/baseline-red-stop.2026-10-08T23-23.md` and probe `evidence/other/baseline-red-probe.2026-10-08T23-22.md` (paths relative to FEATURE). SET-PRA printed 247 tests, 246 passed, 1 failed on two runs; the failing row `allows gh pr create --body-file artifacts/pr_body_12.md when context exists` is denied locally with `EPIC_BASE_BRANCH_MISMATCH`, because PRAE's Check 6 reads this worktree's gitignored epic-mode checkpoint through the unmocked seam `Get-PrAuthorCheckpointContent`. It is a pre-existing test-isolation defect, not a regression; the row passes in CI, where no checkpoint exists. P0-T1 through P0-T16 stay checked with their evidence unchanged. Changes: (1) new Environmental exemption rule EE with a fixed one-row list EE-ROWS and a mechanical probe condition (new read-only scratch script A18), applied by P0-T17 through P0-T22 and P0-T25; an exempt failure is recorded as `ENV-EPIC-FAILED:` and is excluded from every baseline failure set, and every failure not on the list keeps the unchanged stop; (2) C10 gains one bullet that mocks `Get-PrAuthorCheckpointContent` in the `Context 'allowed commands'` `BeforeEach`, and P6-T9 verifies it with a separate count artifact; (3) P6-T21, P8-T4, and P8-T10 state that the EE row must pass, so no exemption reaches final QC. Test counts are unchanged (the mock adds no row). No other task, appendix, or count changes.

## Execution Context

This plan executes later, under the epic orchestrator, after child C1a (#824, with #742 and #733) has merged into `epic/enforcement-hook-precision-integration`. Every line number below was derived on 2026-10-08 from this worktree before C1a merged. P0-T10 merges the integration branch into this feature branch, and P0-T12 re-derives every cited region on the merged tree and stops when a C3 edit region was rewritten in a way the research did not anticipate. Edit tasks therefore name a function and an anchor text first and a line number only as a planning-time reference. Revision 3 re-derived the facts below on the merged tree at BASE_SHA `497cb504` (which contains the C1a merge `1f34ca31`) after the first P0-T12 run stopped; facts that C1a did not move keep their earlier values, which the stopped run's A15 output confirmed.

PR authoring, CI monitoring, and feature review are out of scope for this plan; they belong to the epic-orchestrator run. The plan ends with the final QA loop and an acceptance-criteria status summary.

## Scope Recap

In scope (spec `## Scope & Non-Goals`):

1. #850 pr-author gate: `.claude/hooks/enforce-pr-author-skill.ps1`, `.claude/hooks/enforce-pr-author-skill-helpers.ps1`, and a new dot-sourced sibling `.claude/hooks/enforce-pr-author-skill.artifact-root.ps1` (decision D2).
2. #850 merge gate and #788: `.claude/hooks/enforce-epic-merge-gate.ps1`, `.claude/hooks/enforce-epic-merge-gate-resolution.ps1`, and `Resolve-WorktreeItemTargetByPrNumber` in `.claude/lib/worktree-resolution/WorktreeItemResolution.psm1` (decision D3).
3. #789 CR-4: in-place change to `Test-WorktreeRunPathEqual` in `.claude/lib/worktree-resolution/WorktreeRunResolution.psm1` (497 lines; zero net lines).
4. #789 CR-5: the final deny of `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1` and of `.claude/hooks/enforce-epic-worktree-removal-gate.ps1`.
5. #851 diagnostics: `.claude/hooks/enforce-epic-worktree-removal-gate.ps1` and `.claude/hooks/enforce-epic-worktree-removal-gate-resolution.ps1`.
6. Documentation: the pr-author handoff text in `.claude/skills/orchestrate/SKILL.md` (decision D4 drops the `.claude/rules/orchestrator-state.md` sentence).
7. Byte-identical mirrors under `extensions/drm-copilot/resources/claude-customizations/` for every changed `.claude` file, produced with `cp`; `core.json` registration of the new sibling.
8. Five new Pester suites, updates to the existing suites listed in Appendix G group EDITED-TESTS, and three committed fixture copies (decision D10).

Out of scope (spec non-goals): `.codex/hooks/enforce-epic-merge-gate.ps1`, `.codex/hooks/enforce-epic-worktree-removal-gate.ps1`, and every file under `extensions/drm-copilot/resources/codex-and-agents-customizations/`; any change to a removal gate's allow/deny decision; the stale session-root copies left by the 2026-10-07 workaround (no task reads, modifies, or deletes them); `gh pr edit <N>` resolution by pull request number; #824 addendum 2; every other epic child's scope; any bash or Python port of a hook; every file outside this worktree.

### Current-tree facts this plan relies on (derived 2026-10-08 before C1a merged; revision 3 re-derived on the merged tree at BASE_SHA)

- `.claude/hooks/enforce-pr-author-skill.ps1` is 314 lines: `$script:PrContextArtifactPath = 'artifacts/pr_context.summary.txt'` at line 48; `Get-PrContextArtifactExistence` (no parameter) at lines 55-67; `Get-PrBodyFileBytes -BodyFilePath` at 69-95; `Get-PrAuthorReceiptContent -ReceiptFilePath` at 97-122; `Get-PrContextSummaryLastWriteUtc` (no parameter) at 124-144; dot-sources `enforce-pr-author-skill.epic-base-branch.ps1` at 146 and `enforce-pr-author-skill-helpers.ps1` at 150; `Invoke-PrAuthorSkillDecision` at 152-193 with the up-front probe `$contextExists = Get-PrContextArtifactExistence` at 185 and the call `Get-PrAuthorBypassReason -CommandText $commandText -ContextExists $contextExists` at 186; `Test-PrAuthorBypassRequired -CommandText -ContextExists` at 239-261.
- `.claude/hooks/enforce-pr-author-skill-helpers.ps1` is 441 lines after C1a: header paragraph stating the summary path "stays" process-relative at lines 18-24 (the phrase "process-directory-relative artifact path and stays one" at 20-21); dot-sources `hook-command-scanner.ps1` and `hook-command-invocation.ps1` at 34-35; imports WorktreeResolution, WorktreeTargetResolution, WorktreeItemResolution, EpicScopeResolution, EpicScopeReadiness at 41-49; `Resolve-PrAuthorWorktreeTarget` at 51-72; `Get-PrAuthorTargetCheckpointResolution` at 74-121 (returns only `CheckpointPath` and `Reason`); the #824 seam `Get-PrAuthorBodyFileRoot` (no parameter; returns `(Get-Location).Path`) at 123-138; the #824 reader `Get-PrAuthorBodyFileValue -CommandText` at 140-176, which selects `gh pr create` (else `gh pr edit`) at 160-163, reads the value with `Get-CommandLineFlagValue` at 164, makes a rooted value relative to `Get-PrAuthorBodyFileRoot` at 168-170, converts backslashes at 171, and strips one leading `./` at 172-174; `Test-PrAuthorReceiptVerification -CommandText -CheckpointPath -EpicScope` at 178-301 (param block 213-222) with the Check 1 block at 224-235 (anchor comment `# Check 1:` at 224, `$bodyFileValue = Get-PrAuthorBodyFileValue -CommandText $CommandText` at 228, the case-sensitive test `-cnotmatch '^artifacts/pr_body_(\d+)\.md$'` at 229, relative body and receipt composition at 234-235), `# Check 2:` at 237, and `Get-PrContextSummaryLastWriteUtc` called with no argument at 289; `Get-PrAuthorBypassReason -CommandText -ContextExists` at 303-441 (param block 325-331) with the #824 raw-scan fallback at 351-368, `# Case C:` at 390, `Resolve-EpicScopeCheckpoint` at 401, `Get-PrAuthorTargetCheckpointResolution` at 413, and the receipt-verification call at 434.
- `.claude/hooks/hook-command-invocation.ps1` (HCI) is 482 lines after C1a: it dot-sources `hook-command-scanner.ps1`, `hook-command-payload.ps1`, `hook-command-payload-powershell.ps1`, and `hook-command-invocation-operands.ps1` at lines 21-24 and defines `Test-CommandLineInvocation -CommandText -CommandWord -SubcommandPath` at 427-455. C1a moved `Get-CommandLineFlagValue` and `Test-CommandLineFlag` out of HCI, and `Test-CommandLineRawContainment` no longer exists in `.claude/hooks/`.
- `.claude/hooks/hook-command-invocation-operands.ps1` (HCIO, new in C1a, registered in CORE at line 59) defines `Get-CommandLineFlagValue -CommandText -CommandWord -SubcommandPath -FlagName` at 70-123 (returns the quote-stripped value from the first Structural match, separated or equals form, or `$null`), `Test-CommandLineFlag` with the same parameters at 125-156, and `Resolve-CommandLineInvocationTarget -CommandText -CommandWord -SubcommandPath` at 158-198 (consumed by both removal gates). It is pure string logic and is not edited by this plan.
- `.claude/hooks/enforce-epic-merge-gate.ps1` is 459 lines: dot-sources the authorization sibling at 67 and the resolution sibling at 69; `Invoke-EpicMergeGateDecision` at 292-406 with `$sessionRoot = Get-EpicMergeGateSessionWorktreeRoot` at 358, the unconditional child read anchor `$childCheckpoint = ConvertFrom-EpicMergeGateJson -Raw (Get-ChildOrchestratorCheckpointContent -Path (Get-WorktreeRunCheckpointPath -Kind item -WorktreeRoot $sessionRoot))` at 362, the binding call at 363-364, the standalone branch at 393-403, and `Get-EpicMergeGateUnresolvedReason -EpicTarget $epicTarget -ParallelTarget $parallelTarget` at 400.
- `.claude/hooks/enforce-epic-merge-gate-resolution.ps1` is 221 lines: import guard try/catch for `WorktreeRunResolution.psm1` at 30-36; `Get-EpicMergeGateSessionWorktreeRoot` at 117-129; `Resolve-EpicMergeGateRunTarget -Kind -PrNumber [int]` at 131-150; `Test-ChildCheckpointPrGateBinding -Checkpoint -CommandPrNumber` at 152-189 (returns `$true` at 174-183 when the checkpoint, `pr_gate`, or `pr_gate.pr_number` is absent); `Get-EpicMergeGateUnresolvedReason -EpicTarget -ParallelTarget` at 191-221.
- `.claude/hooks/enforce-epic-merge-gate-authorization.ps1` defines `Test-StandalonePositiveJsonInteger -Value` at line 86 (true only for an `[int]` or `[long]` greater than zero). It is not edited.
- `.claude/hooks/enforce-epic-worktree-removal-gate.ps1` is 452 lines after C1a: dot-sources its resolution sibling at 77; `Find-EpicWorktreeFeatureRecord` at 111-154; `Test-ParallelCheckpointAllowsWorktreeRemoval` at 183-245; `Invoke-EpicWorktreeRemovalGateDecision -ToolInputRaw` at 277-335, which derives the removal targets with `Resolve-CommandLineInvocationTarget` at 321 and calls `Get-EpicWorktreeRemovalTargetDenial -WorktreePath $target` once per derived target in the loop at 328-333, returning the first non-null denial; `Get-EpicWorktreeRemovalTargetDenial -WorktreePath` (new in C1a) at 337-399 with the epic and parallel reads at 358-359 and the doubled-token final deny at 393-398 (prefix anchor `$prefix = "EPIC_WORKTREE_REMOVAL_BLOCKED: $($epicRead.Target.ReasonCode)` at 396 and return anchor `-Reason ($prefix + "EPIC_WORKTREE_REMOVAL_BLOCKED: git worktree remove for` at 398).
- `.claude/hooks/enforce-epic-worktree-removal-gate-resolution.ps1` is 144 lines: `Read-EpicWorktreeGateRunCheckpoint` at 115-144 composes `$path` at 136 and returns only `Target` and `Checkpoint` at 140-143.
- `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1` is 464 lines after C1a: `Invoke-ParallelWorktreeRemovalGateDecision -ToolInputRaw` at 277-336, which derives the removal targets at 322 and calls `Get-ParallelWorktreeRemovalTargetDenial -WorktreePath $target` once per derived target in the loop at 329-334, returning the first non-null denial; `Get-ParallelWorktreeRemovalTargetDenial -WorktreePath` (new in C1a) at 338-411 with the parallel and epic reads at 359-360 and the doubled-token final deny at 405-410 (prefix anchor `$prefix = "PARALLEL_WORKTREE_REMOVAL_BLOCKED: $($parallelRead.Target.ReasonCode)` at 408, return anchor `-Reason ($prefix + "PARALLEL_WORKTREE_REMOVAL_BLOCKED: git worktree remove for` at 410).
- `.claude/lib/worktree-resolution/WorktreeRunResolution.psm1` is 497 lines: `Test-WorktreeRunPathEqual` at 342-358, comment at 342-343, anchor `$isDrivePath = ($a -match '^[A-Za-z]:') -or ($b -match '^[A-Za-z]:')` at 355; export list 490-497 (seven functions).
- `.claude/lib/worktree-resolution/WorktreeItemResolution.psm1` is 407 lines: `Get-WorktreeItemCheckpointText -Path` (the only filesystem read) at 131-149; `Get-WorktreeItemLiveRoot -SessionRoot [-Branch]` at 179-214; `ConvertTo-WorktreeItemResolvedResult` at 216-256; `Resolve-WorktreeItemTargetByIssue` (no tie-break) at 321-349; export list of nine functions at 398-407.
- `.claude/lib/worktree-resolution/EpicScopeResolution.psm1`: `Resolve-EpicScopeCheckpoint` composes `CheckpointPath` with `Join-WorktreeResolutionPath -WorktreeRoot $target.WorktreeRoot -RepoRelativePath (Get-EpicScopeCheckpointRelativePath)` at line 360 and returns `WorktreeRoot = $effectiveRoot` (the session's ascended root) at 380. It is not edited.
- `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` lists `.claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1` at line 50 and the six worktree-resolution modules at 198-203 (after C1a; HCIO at 59). `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` carries no coverage `Path` list (issue #527 comment at line 23), so no runsettings edit is needed.
- `tests/scripts/claude-lib/worktree-resolution/WorktreeResolution.Manifest.Tests.ps1` lists the six modules four times; no new module is added (D3), so it is not edited.
- `tests/scripts/claude-lib/worktree-resolution/WorktreeRunResolution.Record.Tests.ps1` is 441 lines: B11 at 217-226, B12 at 228-237, B13 from 239, X1 at 419-432, X2 at 434-440.
- `tests/scripts/claude-hooks/enforce-epic-merge-gate.WorktreeResolution.Tests.ps1` is 220 lines: rows M1-M10; M3 103-113, M4 115-125, M5 127-137 (asserts allow), M6 139-153, M7 155-167, M8 169-183, M9 185-199.
- Default `Resolve-EpicMergeGateRunTarget` mock lines exist at `enforce-epic-merge-gate.Tests.ps1:12`, `enforce-epic-merge-gate.Authorization.Tests.ps1:75`, `enforce-epic-merge-gate.TriggerScoping.Tests.ps1:39`, and `hook-command-parser.AcceptanceCases.Tests.ps1:69`.
- `tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1` is 497 lines; the exact-text row `emits the unchanged epic block reason` is at 480-488 inside the manifest-branch `Describe` whose `BeforeEach` mocks the epic seam to `{"features":[]}` and the parallel seam to `{"route_id":"parallel","items":[]}` (lines 445-446), and whose `BeforeAll` mocks `Resolve-EpicWorktreeGateRunTarget` to `SessionRoot` at `/synthetic-worktrees/default-session` (line 439).
- `tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.WorktreeResolution.Tests.ps1` holds rows Y1-Y6; Y3 at 103-115.
- `tests/scripts/claude-hooks/enforce-pr-author-skill.WorktreeResolution.Tests.ps1` is 399 lines: header 17-28; R1 rows 106-132; R3 rows 149-177; R4 rows 179-214; R7 rows 249-277; the genuine-absence row 324-347; the shared-path row 371-398.
- `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1` is 456 lines: `-ContextExists` call sites at 330, 335, 340, 376, 381, 386; the seam rows at 391-446.
- `tests/scripts/claude-hooks/enforce-pr-author-skill.TargetResolution.Tests.ps1` is 116 lines with `-ContextExists $true` at 52, 69, 83, 96, 110.
- `tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Tests.ps1` lists eight suites at lines 38-47.
- `tests/fixtures/worktree-resolution/pr-author/item-own-ready/artifacts/` holds `pr_body_1.md`, `pr_body_1.receipt.json`, `pr_context.summary.txt`; `pr-author/item-own-epic-mode/` holds only its checkpoint; every fixture is LF under `* text=auto eol=lf` (`.gitattributes` line 1), and the fixture README states this at lines 69-75.
- `.claude/hooks/enforce-powershell-batch-budget.ps1` caps three distinct production PowerShell files per session (`ProdCap = 3` at line 330) unless the checkpoint at `<root>/artifacts/orchestration/orchestrator-state.json` selects `large`, `remediation`, or `preparation` and is not terminal; the predicate is `Test-BatchBudgetLargePathRoute -CheckpointText` in `.claude/hooks/enforce-batch-budget-route.ps1` (line 94), which takes the selected route from `Get-BatchBudgetSelectedRoute -CheckpointText` (lines 55-92: `route_id` when the key exists, otherwise `path_selected`).
- `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` is registered under the Bash, `Write|Edit`, and Agent matchers in `.claude/settings.json` (lines 107, 152, 185). It dot-sources `enforce-orchestration-preimplementation-gate-epic-scope.ps1` (line 25), whose import guard (lines 41-50) imports `WorktreeItemResolution.psm1`, `WorktreeRunResolution.psm1`, and `EpicScopeResolution.psm1` with `-Force` and records the first failure; the gate denies on that record before any other logic (lines 310-311). The Agent-matcher gates `enforce-parallel-drift-gate.ps1`, `enforce-parallel-cohort-barrier.ps1`, `enforce-epic-wave-barrier.ps1` (WRR) and `enforce-prd-feature-before-planner.ps1`, `enforce-model-routing-receipt.ps1` (WIR) also import those modules. WRR imports `WorktreeResolution.psm1`, `WorktreeTargetResolution.psm1`, and `WorktreeItemResolution.psm1` from `$PSScriptRoot` (lines 31-33); WIR imports the first two (lines 31-32). WRR exports seven functions (lines 490-497) and WIR nine (lines 398-407).
- `-ContextExists` occurs under `tests/scripts` in four suites after C1a: `enforce-pr-author-skill.Tests.ps1` (6 lines: 330, 335, 340, 376, 381, 386), `enforce-pr-author-skill.TargetResolution.Tests.ps1` (5 lines: 52, 69, 83, 96, 110), and the two C1a suites `enforce-pr-author-skill.Issue824.Tests.ps1` (4 lines: 135, 139, 146, 149) and `hook-command-invocation.Issue824Regression.Tests.ps1` (4 lines: 184, 192, 200, 208). Every one of the eight C1a call sites passes `-ContextExists $true` to `Get-PrAuthorBypassReason` with a command that returns before Case C.
- `tests/scripts/claude-hooks/enforce-pr-author-skill.Issue824.Tests.ps1` (S824) is 161 lines: header sentence naming "the body-file root" among the mocked seams at 16-18; in `Context 'body-file normalization and receipt verification'` the `BeforeEach` mocks `Resolve-PrAuthorWorktreeTarget` to `SessionRoot` with `WorktreeRoot = (Get-Location).Path` at 92-94 and `Get-PrAuthorBodyFileRoot` to `'/session'` at 97; rows PA-06 to PA-10 (receipt rows, including PA-08 `--body-file /session/artifacts/pr_body_5.md`) at 100-104; PA-24 calls `Get-PrAuthorBodyFileValue` and `Test-PrAuthorReceiptVerification -CommandText $command -CheckpointPath 'unused-checkpoint-path'` at 125-126; `Context 'body-file root seam'` with row PA-21 at 156-160. No temporary-file token occurs in it.
- `tests/scripts/claude-hooks/hook-command-invocation.Issue824Regression.Tests.ps1` (S824R) is 284 lines: in `Context 'body-file spellings reach receipt verification (R-733-715)'` the `BeforeEach` mocks `Get-PrAuthorBodyFileRoot` to `'/session'` at 217; rows REG-13 to REG-17 call `Test-PrAuthorReceiptVerification ... -CheckpointPath '/synthetic/checkpoint.json'` at 221, 227, 233, 239, 245 (REG-15 passes `/session/artifacts/pr_body_5.md`, its `-Because` text at 235). It also holds pre-existing absolute command-text literals `C:/repo/.claude/worktrees/agent-x` at 73, 106, and 138 and no temporary-file token. `artifacts/` is gitignored (`.gitignore` line 6), and `artifacts/pr_context.summary.txt` does not exist in this worktree at planning time.
- Revision 4 (re-derived 2026-10-08 on this worktree after the P0-T17 stop): PRAE defines the read seam `Get-PrAuthorCheckpointContent -CheckpointPath` at lines 17-48 and `Test-EpicBaseBranchOverride -CommandText -CheckpointPath [-EpicScope]` at 50-144; the check returns `$null` for any command that is not a structural `gh pr create` (line 92) and, when the checkpoint text records `epic_mode` true and the command carries no matching `--base`, returns the `EPIC_BASE_BRANCH_MISMATCH` text at 140. PRAH calls it as Check 6 at line 295, after Checks 1-5, so only a row that passes Checks 1-5 (an allow row) can observe it. The executing worktree's gitignored checkpoint `artifacts/orchestration/orchestrator-state.json` records `"epic_mode": true` at line 5. In `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1`, `Context 'allowed commands'` spans lines 135-204, its `BeforeEach` spans 136-149 and ends with the `Get-PrContextSummaryLastWriteUtc` mock at 148, it mocks `Get-PrAuthorCheckpointContent` nowhere, and its row `allows gh pr create --body-file artifacts/pr_body_12.md when context exists` is at 151-155 (assertion line 154); the literal `Get-PrAuthorCheckpointContent` occurs on three lines of that file (306, 326, 372), one in each of the contexts `receipt - all checks pass (allow)`, `Get-PrAuthorBypassReason helper`, and `Test-PrAuthorBypassRequired helper`. Under `tests/scripts`, thirteen files name one of `Invoke-PrAuthorSkillDecision`, `Get-PrAuthorBypassReason`, `Test-PrAuthorReceiptVerification`, or `Test-EpicBaseBranchOverride`; eleven are SET-PRA suites, and the other two are `tests/scripts/claude-hooks/hook-command-consumers.Issue824.Tests.ps1` (which mocks `Get-PrAuthorCheckpointContent` at line 98 before its only call) and `tests/scripts/claude-runtime/enforcement-hooks-checkpoint-path-explicit.Tests.ps1` (which inspects call sites statically at lines 72-101 and executes no decision). No suite in SET-MRG, SET-REM, SET-LIB, or `tests/scripts/codex-hooks` dot-sources PRA, PRAH, or PRAE.
- `.claude/skills/orchestrate/SKILL.md` `## PR Authoring (pr-author Handoff)` is lines 181-194; the numbered sequence ends with item 4 at line 190. The literal "PR_BODY_PATH_NONCANONICAL" occurs zero times in that file.

### Plan decisions

- **D1 — Acceptance-criteria inventory.** `spec.md` `## Acceptance Criteria` (heading at line 204) holds 47 unchecked `- [ ] ` lines and no other checkbox in the file. This plan tracks AC-01 through AC-47 in spec order (Appendix I). No criterion is added or dropped.
- **D2 — New pr-author sibling.** Artifact-root resolution and the Check 1 root binding go into a new dot-sourced sibling `.claude/hooks/enforce-pr-author-skill.artifact-root.ps1` (PRAR), dot-sourced by the helpers file after its module imports. The spec permits a sibling when the cap requires one; the post-C1a size of the helpers file (384 lines before C1a, which edits Check 1 of this file) is unknown at planning time, so the plan fixes the sibling rather than branching on a measurement. The split also keeps the pure path logic separate from the decision flow (`.claude/rules/general-code-change.md`, separation of concerns). PRAR is registered in `core.json` and mirrored.
- **D3 — Item-by-PR resolver location.** `Resolve-WorktreeItemTargetByPrNumber` is added to `WorktreeItemResolution.psm1` (407 lines; estimate about 465 after). If the staged module exceeds 500 lines, P4-T3 stops with `WIR-CAP` and the plan returns to the planner; no new module is created by this plan, so `WorktreeResolution.Manifest.Tests.ps1` is not edited.
- **D4 — `.claude/rules/orchestrator-state.md` is not edited.** The file is a policy document under `.claude/rules/`, and the policy-compliance hard constraint prohibits modifying those documents. The spec's one-sentence alignment for that file is dropped from this plan. No acceptance criterion depends on it. The epic orchestrator should obtain an explicit user decision before any edit to that file.
- **D5 — Check 1 root binding (spec Design 3).** PRAR reads the `--body-file` value through C1a's `Get-PrAuthorBodyFileValue` (PRAH; structural read of the first Structural `gh pr create`, else `gh pr edit`, match through `Get-CommandLineFlagValue`, which HCI reaches by dot-sourcing HCIO; quote stripping; equals form; backslash to slash; one leading `./` removed), with its rooted-value relativization removed by B9 (D12). A `$null` value (no Structural match, including an invocation read only as Indeterminate) denies with the generic text below, as C1a's Check 1 already does (row PA-24); no raw-text fallback is added. The value is normalized with `ConvertTo-WorktreeResolutionNormalizedPath`. A relative value matching `^artifacts/pr_body_(\d+)\.md$` (case-sensitive) is accepted only when `RelativeBodyAllowed` is true; otherwise it denies with the relative-path text of Appendix B. An absolute value whose tail matches `/artifacts/pr_body_(\d+)\.md$` is accepted only when it equals `Join-WorktreeResolutionPath -WorktreeRoot <artifact root> -RepoRelativePath "artifacts/pr_body_<N>.md"` under `Test-PrAuthorBodyPathEqual` (case-insensitive when either side matches `^([A-Za-z]:|//)`, case-sensitive otherwise). Any other value denies with the generic `PR_BODY_PATH_NONCANONICAL` text. The whole Check 1 block inside `Test-PrAuthorReceiptVerification` is replaced by the call into PRAR. On the merged tree that block is C1a's form (PRAH lines 224-235: the value from `Get-PrAuthorBodyFileValue`, the case-sensitive `-cnotmatch '^artifacts/pr_body_(\d+)\.md$'` test, and relative body and receipt paths resolved against the process directory; P0-T12 `CHECK1-FORM: rewritten-by-c1a`). The binding keeps C1a's quoted, equals-joined, `./`-led, and backslash spellings and binds an absolute value to the resolved root instead of the session root.
- **D6 — Removal-gate diagnostics clause (#851).** Exact format in Appendix B, B4.
- **D7 — Item-resolution detail texts and the unresolved prefix.** Exact texts in Appendix B, B5 and B6.
- **D8 — Default item-target mock line (DT-ITEM).** Every existing suite that dot-sources the merge gate and already carries the default `Resolve-EpicMergeGateRunTarget` mock receives exactly one line immediately after that line: `Mock Resolve-EpicMergeGateItemTarget { [pscustomobject]@{ Status = 'SessionRoot'; WorktreeRoot = '/synthetic-worktrees/default-session'; ReasonCode = $null; Detail = 'default SessionRoot target (issue #850)' } }`. The WorktreeResolution suite instead receives a `NoTarget` default (Appendix C, C6).
- **D9 — Constraints-suite host-path scope.** Four edited suites contain pre-existing absolute command-text literals that this child did not author (`hook-command-parser.AcceptanceCases.Tests.ps1:105`, `enforce-epic-merge-gate.TriggerScoping.Tests.ps1:46`, `enforce-epic-merge-gate.Authorization.Tests.ps1:164`); revision 3 adds S824R, whose C1a-authored literals `C:/repo/.claude/worktrees/agent-x` sit at lines 73, 106, and 138. The constraints row therefore applies the temporary-file check to every created or edited suite, and the host-path check to every created file; the lines this child adds to edited suites are covered by the added-lines scan P8-T15. Both halves together verify AC-45.
- **D10 — Fixture copies for R4.** The three artifact files of `pr-author/item-own-ready/artifacts/` are copied byte-identically with `cp` into `pr-author/item-own-epic-mode/artifacts/`, so row R4 can still reach Check 6 with the artifacts read beneath the resolved epic-mode worktree. The fixture README is updated to match.
- **D11 — Accepted behavior changes in existing rows.** The spec accepts three behavior changes (spec `Backward-compatibility expectations`) and relocates Case C beneath the resolved root. Existing rows that flip only for one of those reasons are updated under the classification rule CR (Execution Conventions), and every such update is recorded in `FEATURE/evidence/other/edited-suites-850.md`.
- **D12 — Reuse C1a's body-file reader; remove the session-root seam (revision 3).** PRAR defines no operand reader of its own: the planned `Get-PrAuthorBodyFileOperand` and its raw-regex fallback are dropped, and `Get-PrAuthorBodyPathBindingReason` calls `Get-PrAuthorBodyFileValue`. That function's step that makes a rooted value relative to `Get-PrAuthorBodyFileRoot` (PRAH 168-170) is removed, because it binds an absolute body path to the session root, which is the defect #850 corrects (spec `Dependencies`: "this child binds that form to the resolved root rather than the session root"); the drive-letter, UNC, and POSIX comparison of D5 replaces it and does not depend on the host's `IsPathRooted` rules. The seam `Get-PrAuthorBodyFileRoot` then has no caller and is removed, together with the two test mocks of it (S824 line 97, S824R line 217) and row PA-21 (S824 156-160), the only test of it. The C1a rows that pass a body path under `/session` keep their assertions with the root supplied explicitly (C15, C16): PA-08 through the `SessionRoot` mock at `/session`, and REG-13 to REG-17 and PA-24 through `-ArtifactRoot '/session' -RelativeBodyAllowed $true`. Net SET-PRA growth is therefore 15, not 16 (Appendix G). S824 reaches `Resolve-EpicScopeCheckpoint` unmocked, as it already did before this plan; adding it to the isolation guard is outside the three revision regions and is not done (the guard's own known limit D9).
- **D13 — Scope already delivered by C1a (#824).** C1a delivered the structural `--body-file` read and its spelling normalization (reused by D12), the move of `Get-CommandLineFlagValue` and `Test-CommandLineFlag` to HCIO, and per-target evaluation in both removal gates (D14). It delivered no part of the observable behavior any spec criterion verifies, so no acceptance criterion is narrowed: Check 1 still accepts only a path relative to the process directory (`CHECK1-FORM` in `evidence/other/c1a-reverification.2026-10-08T22-39.md`), so AC-01 through AC-13 are open; both removal gates still emit the doubled token (anchors EREM 396/398 and PREM 408/410 in the same artifact), so AC-32 through AC-37 are open; WIR still exports nine functions without an item-by-PR resolver (A15 `Export-ModuleMember` at 398), so AC-15 through AC-29 are open; WRR line 355 still holds the drive-only test, so AC-30 and AC-31 are open. The narrowing is limited to task content: B8 loses its operand reader. AC-08, AC-09, AC-10, and AC-11 now depend on C1a's normalization; their verifying rows are unchanged.
- **D14 — Removal-gate final deny per derived target (revision 3).** C1a moved each removal gate's authorization cascade and final deny into a per-target function that the decision function calls once per target derived by `Resolve-CommandLineInvocationTarget`, returning the first denial. B2 and B4 therefore edit `Get-ParallelWorktreeRemovalTargetDenial` and `Get-EpicWorktreeRemovalTargetDenial`; the decision functions and their loops are not changed. For a command with several targets, the deny text, its single token, its unresolved prefix, and the #851 diagnostics clause describe the first denied target, whose reads (`$parallelRead`/`$epicRead`) are local to that call. Rows C2, C3, and C4 remove one target, so their expected texts are unchanged, and AC-33's byte-identical resolved-target text holds for each target.

## Execution Conventions

### Terms used in every task

- FEATURE means `docs/features/active/2026-10-08-pr-author-and-merge-gates-read-session-root-files-850`.
- BRANCH means `bug/pr-author-and-merge-gates-read-session-root-files-exec-850` (orchestrator decision D-EXEC-1, 2026-10-08: the execution branch was created from INTEG tip `497cb504` because the prepared branch `bug/pr-author-and-merge-gates-read-session-root-files-850` is merged into INTEG and checked out in a locked preparation worktree). The executing worktree may check BRANCH out under the local name `bug/pr-author-and-merge-gates-read-session-root-files-resume-850`, which tracks `origin/bug/pr-author-and-merge-gates-read-session-root-files-exec-850`; any CMD-GIT-BRANCH assertion in this plan accepts either name, and CMD-GIT-PUSH pushes HEAD to the remote BRANCH with an explicit refspec (D-EXEC-1). INTEG means `origin/epic/enforcement-hook-precision-integration`.
- PLAN means `FEATURE/plan.2026-10-08T13-54.md` (this file).
- CB means `extensions/drm-copilot/resources/claude-customizations`; CORE means `CB/pack-manifests/core.json`.
- PRA means `.claude/hooks/enforce-pr-author-skill.ps1`; PRAH means `.claude/hooks/enforce-pr-author-skill-helpers.ps1`; PRAR means `.claude/hooks/enforce-pr-author-skill.artifact-root.ps1` (new); PRAE means `.claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1` (not edited).
- MRG means `.claude/hooks/enforce-epic-merge-gate.ps1`; MRGR means `.claude/hooks/enforce-epic-merge-gate-resolution.ps1`; MRGA means `.claude/hooks/enforce-epic-merge-gate-authorization.ps1` (not edited).
- EREM means `.claude/hooks/enforce-epic-worktree-removal-gate.ps1`; EREMR means `.claude/hooks/enforce-epic-worktree-removal-gate-resolution.ps1`; PREM means `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1`.
- WRR means `.claude/lib/worktree-resolution/WorktreeRunResolution.psm1`; WIR means `.claude/lib/worktree-resolution/WorktreeItemResolution.psm1`; ESR means `.claude/lib/worktree-resolution/EpicScopeResolution.psm1` (not edited); HCI means `.claude/hooks/hook-command-invocation.ps1` (not edited); HCIO means `.claude/hooks/hook-command-invocation-operands.ps1` (C1a; not edited).
- S824 means `tests/scripts/claude-hooks/enforce-pr-author-skill.Issue824.Tests.ps1`; S824R means `tests/scripts/claude-hooks/hook-command-invocation.Issue824Regression.Tests.ps1` (both C1a suites, edited by this plan per Appendix C, C15 and C16).
- SKILL means `.claude/skills/orchestrate/SKILL.md`.
- New suites: T-PRA-IAR `tests/scripts/claude-hooks/enforce-pr-author-skill.ItemArtifactRoot.Tests.ps1` (15 tests), T-MRG-IR `tests/scripts/claude-hooks/enforce-epic-merge-gate.ItemResolution.Tests.ps1` (19 tests), T-WIR-PR `tests/scripts/claude-lib/worktree-resolution/WorktreeItemResolution.PrNumber.Tests.ps1` (11 tests), T-EREM-DX `tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Diagnostics.Tests.ps1` (8 tests), T-CONS `tests/scripts/claude-hooks/session-root-reads-850.Constraints.Tests.ps1` (2 tests). Test counts include each `-ForEach` case.
- WLOG means `FEATURE/evidence/qa-gates/gate-wiring-order.md` (Appendix J).
- TS means the task's execution time in `yyyy-MM-ddTHH-mm` form.
- SCRATCH means the executor's session scratchpad directory, outside the repository and never committed. Artifacts record it as the literal token SCRATCH, never as a host path.
- PRE_MERGE_HEAD is recorded by P0-T8; under orchestrator decision D-EXEC-2 (2026-10-08) P0-T8 records the observed CMD-GIT-HEAD value as `EXEC_START_HEAD` and sets PRE_MERGE_HEAD to the prepared-branch tip `c79642f73e360122443eaf665f363b065f0efb2d` (the tree this plan and its preflight clearance were derived against), because the execution branch already starts at an INTEG tip that contains C1a; P0-T9 then compares that pre-C1a tree with INTEG as designed, and P0-T10 takes its authorized skip branch. BASE_SHA is recorded by P0-T11 (the merge-base of HEAD and INTEG after the integration merge; a fixed commit that later INTEG movement does not change).
- Every command-step artifact carries `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`. An artifact whose expected exit code is not 0 also carries `ExpectedExitCode:`. The expectation field is per file, so a command step whose expected exit code is not 0 is recorded in its own artifact and never shares one with a step expected to exit 0. PowerShell coverage artifacts record numeric `LinePercent=` values in `Output Summary:`.
- KL-510 is the known local failure of issue #510 in node `test_bundled_claude_payload_contains_all_repo_runtime_contracts`: gitignored files under `.claude/state/` are reported missing from the bundle. A run satisfies KL-510 in exactly two cases. Case (a): the node prints PASSED; the artifact carries `KL-510: PASSED`. Case (b): the node fails, its assertion message is the literal "Repo file missing from bundle:" followed by a path whose first two components are `.claude` and `state`, and no output line contains "Bundle content differs from repo for:"; the artifact carries `KL-510: STATE-ONLY`, quotes the assertion message, and carries `ExpectedExitCode: 1`. Any other outcome stops the task.

### Evidence location

Every evidence artifact lives under `FEATURE/evidence/<kind>/` with kind `baseline`, `regression-testing`, `qa-gates`, or `other`. No artifact is written under `artifacts/`. Coverage XML and report files written by scratch scripts go to SCRATCH. The caller supplied no non-canonical evidence path, so no override record is needed.

### Shell route

- The worktree isolation guard refuses Bash-tool command text containing the words bash, pwsh, or wsl inside compound constructs, heredocs, cd-chains, or xargs. Every git, poetry, cp, grep, and sh command in this plan is one plain command with literal arguments, and no commit message contains any of those three words.
- Every PowerShell script runs through scratch script A1 as a plain command: `sh SCRATCH/run-ps.sh SCRATCH/<script>.ps1 <args>` (CMD-PS-SCRIPT). Glob arguments are expanded by `sh` before the script runs. Each script prints the values the acceptance conditions assert.
- Bundle mirrors and fixture copies are produced with `cp`, never with Write or Edit.
- Searches use plain `grep` (never `git grep`) with every pattern passed through `-e`, so a file created by an earlier task is searched and no pattern is read as an option.

### Live-hook rules

The executing session runs this worktree's hooks; a changed hook or module takes effect on the next tool call.

- **LH-1 Live files.** PRA, PRAH, PRAR, MRG, MRGR, EREM, EREMR, PREM, WRR, and WIR are live files. A live file is changed only through the Staged Write procedure SW, never with the Edit tool.
- **LH-2 Staged Write procedure (SW).** SW-1: write the complete new content to `SCRATCH/stage/<file name>`. SW-2: run CMD-PS-SCRIPT with A12 and `-Path SCRATCH/stage/<file name>`; the required output is the line `STAGE-CHECK ParseErrors=0 FormatChanged=False DiagnosticCount=0`; otherwise correct the staged copy and repeat SW-2. SW-2b (WRR and WIR only): copy `.claude/lib/worktree-resolution` to the not-yet-existing directory `SCRATCH/stage-lib-<phase>` with `cp -r .claude/lib/worktree-resolution SCRATCH/stage-lib-<phase>` (phase `p1` for WRR, `p4` for WIR), copy the staged module over its copy there with `cp SCRATCH/stage/<file name> SCRATCH/stage-lib-<phase>/<file name>`, then run CMD-PS-SCRIPT with A17 and `-StageRoot SCRATCH/stage-lib-<phase> -ModuleName <module name without extension>`; the required output is the line `LOAD-CHECK Module=<module name> Imported=True ExportCount=<count given in the task>`; otherwise correct the staged copy and repeat SW-2 and SW-2b (into a new `SCRATCH/stage-lib-<phase>-<n>` directory). SW-3: Write the staged content to the repository path in one Write call carrying the whole file. SW-4: run CMD-PS-SCRIPT with A5 over the staged copy and the repository path; the two `Hash=` values are equal. SW-5: append the WLOG entry. A corrective re-Write follows SW again and its WLOG entry states the reason.
- **LH-3 Order and validity at every step.** A phase stages and checks every live file it changes, then performs the SW-3 writes back to back with no Bash command and no other repository write between them, writing each dot-sourced sibling or module before the file that dot-sources or imports it: WRR (alone); PREM (alone); EREMR then EREM; WIR (alone); MRGR then MRG; PRAR then PRAH then PRA. Each intermediate state is valid for every command the session issues between the writes: the only intervening tool calls are Write calls; PRA, PRAH, PRAR, MRG, MRGR, EREM, EREMR, and PREM run only under the Bash matcher, so no Write call loads them. WRR and WIR are also imported, with a fail-closed import guard, by the Write|Edit|Bash gate enforce-orchestration-preimplementation-gate.ps1 (also registered under the Agent matcher; the Agent-matcher gates listed in the Current-tree facts import them as well). A staged copy of either module therefore passes the import check SW-2b before its SW-3 write. The old gate never dot-sources a sibling function it does not already define, except that the old PRAH does not yet dot-source PRAR and the old MRG passes no `-ItemTarget`, both of which are inert. SW-4 hash checks run only after the last SW-3 of the phase.
- **LH-4 Stop rule for hook denials.** If any hook denies a Write, Edit, Bash command, or Agent call in this plan, stop and report the verbatim denial text. Do not bypass the hook through another tool, do not edit any file under `artifacts/orchestration/`, and do not disable a hook.
- **LH-5 Protected state.** No task writes, moves, or deletes any file under `artifacts/`, any file under `.codex/`, any file under `extensions/drm-copilot/resources/codex-and-agents-customizations/`, any file under `.claude/rules/`, MRGA, PRAE, ESR, HCI, HCIO, `WorktreeResolution.psm1`, `WorktreeTargetResolution.psm1`, or any file outside this worktree. No task reads the stale session-root copies left by the 2026-10-07 workaround in other worktrees.
- **LH-6 Import order inside the merge-gate resolution sibling.** MRGR imports WRR and then WIR, each inside its own guarded `try` (Appendix B, B6), so the `-ModuleName WorktreeItemResolution` mock in T-MRG-IR binds the instance the gate calls.

### Toolchain loop rule

Each implementation phase runs, after its writes: a read-only A6 format check, an A7 analyzer count, the phase's new suite, and the phase's suite set (the per-phase loop). If any step fails or any check reports a change, fix the cause and restart that phase's loop from its format task. No write-mode formatter runs before Phase 8. Phase 8 is the final PowerShell QA loop (format, analyze, test with coverage; PowerShell has no type-check stage per `.claude/rules/powershell.md`) followed by the Python parity harness. No Python file is created or changed by this plan, so no Python format, lint, or type-check stage applies.

### Classification rule CR (existing-suite failures after a production change)

For each `FAILED:` line of a suite-set run that is not a member of that set's Phase 0 baseline failure set:

1. When the row belongs to a suite this phase edits under Appendix C and the planned edit is not yet applied, apply it and re-run.
2. When the row asserts an outcome that changes only because of one of the four accepted causes — (a) #788: an explicit-number merge whose child checkpoint records neither `pr_gate.pr_number` nor a matching standalone entry no longer allows through the child branch; (b) #850: an unresolvable or ambiguous target now denies with the resolution code ahead of `PR_CONTEXT_MISSING`; (c) #850: a relative `--body-file` for an `OtherWorktree` target denies with `PR_BODY_PATH_NONCANONICAL`; (d) #850: the context summary is now read beneath the resolved root, so a row whose subject is a later check and whose resolved root holds no summary now stops at Case C — update only that row: for (a), (b), and (c) change the expected decision and reason to the new ones; for (d) add the single Arrange line `Mock -CommandName Get-PrContextArtifactExistence -MockWith { $true }`; for (c) in a row whose subject is not the body path, change the body path to the absolute canonical path beneath the row's resolved root. Record the suite, the row name, the cause letter, and the change in `FEATURE/evidence/other/edited-suites-850.md`, and add the suite to group EDITED-TESTS for the rest of the plan. Re-run the set.
3. Any other failure stops the plan; report the row and its failure message.

### Container rule CC (suites that fail to load)

A2 and A3 print one `FAILED-CONTAINER:` line per test file that failed during Pester discovery; that file's tests produce no `FAILED:` line and are absent from `TotalCount=`, so a count assertion alone can pass while a suite is missing. Every task whose acceptance carries the marker `(rule CC)` additionally requires: no `FAILED-CONTAINER:` line is blank, and every `FAILED-CONTAINER:` line is a member of the baseline container set the task names. A task that names no baseline set (a single-suite run) requires that no `FAILED-CONTAINER:` line is printed. Any other `FAILED-CONTAINER:` line fails the task; fix the file it names when this plan created or edited that file and re-run the task, otherwise stop the plan and report the line.

### Environmental exemption rule EE (local epic-mode checkpoint; revision 4)

Cause. The executing worktree's gitignored checkpoint `artifacts/orchestration/orchestrator-state.json` records `"epic_mode": true` (P0-T7 requires that checkpoint, and LH-5 forbids changing it). PRAE's Check 6 reads it through `Get-PrAuthorCheckpointContent` for every `gh pr create` that passes Checks 1-5, so an allow row that issues `gh pr create` without `--base` and does not mock that seam is denied locally with `EPIC_BASE_BRANCH_MISMATCH`, while it passes in CI, where no checkpoint exists (stop evidence `evidence/other/baseline-red-stop.2026-10-08T23-23.md`, relative to FEATURE).

EE-ROWS. The list is fixed here; the executor does not add to it, remove from it, or choose among its entries:

- EE-1: the line `FAILED: enforce-pr-author-skill.ps1.allowed commands.allows gh pr create --body-file artifacts/pr_body_12.md when context exists`, in A2 output followed by the line `FAILED-FILE: tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1` (A3 prints no `FAILED-FILE:` line, so in A3 output the `FAILED:` line alone is matched).

Derivation, so a third party obtains the same list: SET-PRA was run twice at P0-T17 (revision 3) and printed exactly one `FAILED:` line, EE-1, on both runs; the probe artifact attributes it to Check 6. Outside SET-PRA, no test file executes a PRA decision path with an unmocked checkpoint seam (Current-tree facts, revision 4 bullet), so no other row in `tests/scripts/claude-hooks`, `tests/scripts/claude-lib`, SET-MRG, SET-REM, or SET-LIB can produce `EPIC_BASE_BRANCH_MISMATCH`.

Probe condition. P0-T17 runs scratch script A18 (Appendix H; read-only) once and records its full output. A18 evaluates EE-1's command with the six seams EE-1 mocks replaced by identical functions, then again with `Get-PrAuthorCheckpointContent` also returning `$null`. The condition holds only when A18 prints all three of: the line `DECISION=deny`; a line that begins `REASON=EPIC_BASE_BRANCH_MISMATCH:`; and the line `DECISION-WITHOUT-CHECKPOINT=allow`.

Application. In a task that names rule EE, a `FAILED:` line (with its `FAILED-FILE:` line, where printed) is exempt only when it is textually identical to EE-1 and the P0-T17 probe condition holds. For an exempt line the artifact records the line pair verbatim, the failure message (the A18 `REASON=` line, quoted verbatim), and one line `ENV-EPIC-FAILED: EE-1`. An exempt line is not a member of that task's baseline failure set, is not subject to that task's stop condition, and does not change the recorded `TotalCount=`, `PassedCount=`, or `FailedCount=`. Every other `FAILED:`, `FAILED-FILE:`, or `FAILED-CONTAINER:` line is handled exactly as the task states without this rule. When the probe condition does not hold, EE-1 is not exempt and the task's unchanged stop condition applies to it.

Expiry. EE applies only to Phase 0 baseline tasks P0-T17 through P0-T22 and P0-T25. P6-T9 adds the missing seam mock to EE-1's context (Appendix C, C10), after which EE-1 passes regardless of the local checkpoint. Because EE-1 is in no baseline failure set, every later run that includes it (P6-T21, P8-T4, P8-T10) fails if EE-1 fails; no task after Phase 0 applies rule EE.

### Commit rule

Each phase ends with a commit-and-push task. CMD-GIT-ADD names paths explicitly (files, the FEATURE evidence directory, or PLAN); `git add -A` and `git add .` are not used. Every phase-ending CMD-GIT-ADD includes PLAN. A commit task's own check-off is written after its status check and is carried by the next commit. The P8-T22 check-off is the only change left uncommitted at plan completion; the executor reports it in the completion summary for the epic orchestrator to commit. No force push and no history rewrite is used anywhere. No task deletes a file.

### Command catalogue

Angle-bracket fields are filled from the task text. Commands run from the worktree root.

```text
CMD-GIT-BRANCH        git rev-parse --abbrev-ref HEAD
CMD-GIT-HEAD          git rev-parse HEAD
CMD-GIT-FETCH-INTEG   git fetch origin epic/enforcement-hook-precision-integration
CMD-GIT-MERGE-BASE    git merge-base HEAD origin/epic/enforcement-hook-precision-integration
CMD-GIT-STATUS        git status --porcelain
CMD-GIT-STATUS-PATH   git status --porcelain -- <pathspec>
CMD-GIT-ADD           git add -- <exact paths listed in the task>
CMD-GIT-COMMIT        git commit -m "<message given in the task>" --trailer "Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>" --trailer "Claude-Session: https://claude.ai/code/session_01RsMhy8je7BeARkv8LPcpSa"
CMD-GIT-PUSH          git push origin HEAD:bug/pr-author-and-merge-gates-read-session-root-files-exec-850
CMD-CP                cp <source> <destination>
CMD-GREP-COUNT        grep -c -F -e '<literal>' <files>

CMD-PY-PARITY         poetry run pytest -v tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py tests/scripts/dev_tools/test_poshqc_bundled_parity.py
CMD-PY-PARITY-EXT     poetry run pytest -v tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py tests/scripts/dev_tools/test_poshqc_bundled_parity.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py tests/scripts/dev_tools/test_orchestrator_state_remediation_docs.py

CMD-PS-SCRIPT         sh SCRATCH/run-ps.sh SCRATCH/<script>.ps1 <args>
MCP-PS-FORMAT         mcp__drm-copilot__run_poshqc_format   (workspace_root = worktree root, scan_folders = folders listed in the task)
MCP-PS-ANALYZE        mcp__drm-copilot__run_poshqc_analyze  (same arguments)
MCP-PS-TEST           mcp__drm-copilot__run_poshqc_test     (workspace_root = worktree root)
```

CMD-GREP-COUNT prints one `path:count` line per file when more than one file is named and a bare count when one file is named; it exits 1 when the count is zero in every file.

### Observed success outputs that acceptance conditions rely on

- The PoshQC MCP tools return a fixed summary composed before the child process runs, with no exit code and no test output. Their only observable signal is whether the call returns or raises. No acceptance condition in this plan asserts a count, percentage, or finding from an MCP result; every such value is read from scratch scripts A2, A3, A6, A7, A11, A12, and A13. Artifacts record the MCP call disposition as `EXIT_CODE: 0` when the call returned and non-zero when it raised.
- The scratch-script output lines are printed by construction on every run, success or failure (Appendix H): A2 prints `TotalCount=`, `PassedCount=`, `FailedCount=`, and one `FAILED:` line per failed test (the line carries the test's expanded path, which ends with the `It` name); A3 adds `COVERAGE file=... LinePercent=` plus `HIT` and `MISSED` lines per coverage file; A6 prints `FORMAT-SUMMARY ChangedCount=`; A7 prints `PSSA-SUMMARY DiagnosticCount=`; A12 prints `STAGE-CHECK ParseErrors= FormatChanged= DiagnosticCount=`; A10 prints `PAIR-SUMMARY pairs= unequal=`. The A2, A3, A5, A6, A7, A10, A12 formats were observed in the executed runs of the #690 plan (`docs/features/active/2026-09-17-agent-payload-gates-resolve-session-root-690/plan.2026-09-29T22-17.md`, Appendix H and its checked Phase 1-12 tasks), where they carried the same text. A2 and A3 exit 0 whether or not tests fail (Pester's `Run.Exit` is off), so every test acceptance reads the printed counts, never the exit code.
- Four further output lines are new to this plan and are asserted only in the form shown here. Executor preflight round 2 observed the A2, A9, and A17 forms in scratch probes (reported to the planner by the orchestrator, not re-run by the planner); the A3 `FAILED-CONTAINER:` line uses the same expression as the A2 one and was not probed separately. A2 prints one `FAILED-FILE: <path>` line after each `FAILED:` line, taken from the failed test's `ScriptBlock.File` and made relative to the worktree root with forward slashes, so no host path enters an artifact (a blank value is itself a stop condition wherever the line is read, so a missing attribution cannot pass). A9 prints `SELECTED_ROUTE=` with the value of `Get-BatchBudgetSelectedRoute`. A17 prints exactly one `LOAD-CHECK Module=` line, from the `try` branch with `Imported=True ExportCount=` or from the `catch` branch with `Imported=False Error=`. A2 and A3 print one `FAILED-CONTAINER: <path>` line per entry of `$result.FailedContainers`, made relative the same way (blank for a container that is not a file). Preflight observations: A2 `FAILED-FILE:` printed repo-relative paths; A9 printed a `SELECTED_ROUTE=` line as designed; A17 on the unmodified WIR printed `ExportCount=9`, so the P4-T3 value 10 is the nine current exports plus the new one; `FAILED-CONTAINER: Broken.Tests.ps1` was printed for a scratch suite that fails during discovery, with `FailedContainers=1` and no `FAILED:` line, which is why rule CC exists. `FAILED-FILE:` and `FAILED-CONTAINER:` lines begin with `FAILED-`, not with the six characters `FAILED` followed by a colon, so neither ever matches an assertion about `FAILED:` lines.
- A18 (revision 4) prints its three lines by construction on every run. The `DECISION=deny` and `REASON=EPIC_BASE_BRANCH_MISMATCH: ...` lines were observed in the revision-3 stop probe (`evidence/other/baseline-red-probe.2026-10-08T23-22.md`), which evaluated the same command with the same six seams replaced. The `DECISION-WITHOUT-CHECKPOINT=allow` value was not run by the planner; it is supported by the SET-PRA row `allows when all six receipt checks pass`, which passed locally on both stopped runs with the same seam values (receipt `created_at` and summary time differ only in date) plus `Get-PrAuthorCheckpointContent` mocked to `$null`. If A18 prints any other value, the probe condition fails and the unchanged P0-T17 stop applies.
- `pytest -v` prints one PASSED or FAILED line per node and a final summary line.
- `git status --porcelain` prints nothing on a clean tree; `git diff --exit-code <ref> -- <path>` prints nothing and exits 0 when the path equals the ref.

### Search literal register

The searches in this plan use these fixed strings, quoted here as explicit instructions: "B14 compares UNC paths case-insensitively", "Y7 emits a single leading token when both run kinds are unresolved", "Mock Resolve-EpicMergeGateItemTarget", ".claude/hooks/enforce-pr-author-skill.artifact-root.ps1", "enforce-pr-author-skill.ItemArtifactRoot.Tests.ps1", "PR_BODY_PATH_NONCANONICAL", "Diagnostics: epic run", "Resolve-WorktreeItemTargetByPrNumber", "-ContextExists", "Get-PrAuthorBodyFileRoot", "-RelativeBodyAllowed", "Get-PrAuthorCheckpointContent". The literal "-RelativeBodyAllowed" does not exist in the tree before Phase 6; P6-T11 and P6-T12 create it in S824 and S824R as written in Appendix C, C15 and C16.

---

### Phase 0 — Policy Reads, Integration Merge, Pre-Edit Re-Verification, and Baselines

- [x] [P0-T1] Read `CLAUDE.md` and `.github/copilot-instructions.md` in full, in that order. Acceptance: both read; recorded in P0-T5.
- [x] [P0-T2] Read, in order, `.github/instructions/general-code-change.instructions.md`, `.github/instructions/general-unit-test.instructions.md`, `.github/instructions/powershell-code-change.instructions.md`, `.github/instructions/powershell-unit-test.instructions.md`, and `.github/instructions/tonality.instructions.md`. Acceptance: all five read; recorded in P0-T5.
- [x] [P0-T3] Read, in order, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/quality-tiers.md`, `.claude/rules/tonality.md`, `.claude/rules/plan-acceptance-gates.md`, `.claude/rules/powershell.md`, `.claude/rules/self-explanatory-code-commenting.md`, and `.claude/rules/orchestrator-state.md` (read only; D4). Acceptance: all eight read; recorded in P0-T5.
- [x] [P0-T4] Read FEATURE/issue.md, FEATURE/spec.md, FEATURE/research/research.2026-10-08T14-00.md, and `docs/features/epics/enforcement-hook-precision/epic.md` in full. Acceptance: all four read; recorded in P0-T5.
- [x] [P0-T5] Write the policy-read record FEATURE/evidence/baseline/phase0-instructions-read.TS.md. Acceptance: the artifact contains `Timestamp:`, `Policy Order:`, and the explicit list of the 19 files read in P0-T1 through P0-T4, in reading order.
- [x] [P0-T6] Create scratch scripts A1 through A17 of Appendix H verbatim under SCRATCH (staged copies later go under `SCRATCH/stage/`, and SW-2b module copies under `SCRATCH/stage-lib-<phase>`), then run CMD-PS-SCRIPT with A4 and argument `CLAUDE.md`. Write FEATURE/evidence/other/scratch-smoke.TS.md. Acceptance: the output is one line beginning `CLAUDE.md LineCount=`; the artifact lists the 17 script file names.
- [x] [P0-T7] Batch-budget precondition (read-only). Command: CMD-PS-SCRIPT with A9 and `-CheckpointPath artifacts/orchestration/orchestrator-state.json`, run from the worktree whose `.claude/hooks/` the executing session loads (this worktree when the executor runs here). Write FEATURE/evidence/baseline/batch-budget-precondition.TS.md, recording the root as a worktree name, never a host path. Acceptance: the output contains `LARGE_PATH_EXEMPT=True` and a `SELECTED_ROUTE=` line whose value is `large`, `remediation`, or `preparation` (the value `Get-BatchBudgetSelectedRoute` returns: `route_id`, or `path_selected` when the checkpoint has no `route_id` key). Otherwise stop with `BATCH-BUDGET-NOT-EXEMPT`; this plan writes ten production PowerShell files and cannot run under the three-file cap, and it does not write the checkpoint.
- [x] [P0-T8] Record branch state. Commands: CMD-GIT-BRANCH, CMD-GIT-STATUS, CMD-GIT-HEAD, and `git status --porcelain --ignored --untracked-files=all -- artifacts/pr_context.summary.txt` (`--untracked-files=all` lists a file inside the ignored `artifacts/` directory individually instead of collapsing it to the directory). Write FEATURE/evidence/baseline/branch-state.TS.md and record the CMD-GIT-HEAD value as PRE_MERGE_HEAD. Acceptance: the branch is BRANCH; every CMD-GIT-STATUS line names a path under FEATURE or under `.claude/agent-memory/`; any other line stops the plan; the `artifacts/pr_context.summary.txt` status command prints nothing. A `!!` line (or any other line) from that command stops the plan with `LOCAL-CONTEXT-PRESENT`, because a local context summary would let pr-author rows that do not mock the existence seam pass on local state.
- [x] [P0-T9] C1a-merged probe. Commands, in order (PRE_MERGE_HEAD replaced by the recorded commit in each): CMD-GIT-FETCH-INTEG; `git diff --exit-code --stat PRE_MERGE_HEAD origin/epic/enforcement-hook-precision-integration -- .claude/hooks/hook-command-invocation.ps1`; `git log --oneline -n 20 origin/epic/enforcement-hook-precision-integration`; `git log --oneline --grep=824 PRE_MERGE_HEAD..origin/epic/enforcement-hook-precision-integration`. Write two artifacts: the diff step alone goes to FEATURE/evidence/baseline/c1a-merged-probe-diff.TS.md, which carries `ExpectedExitCode: 1`; the fetch and both log steps go to FEATURE/evidence/baseline/c1a-merged-probe.TS.md, which carries no expectation field. Acceptance: the fetch exits 0; the diff exits 1 and prints a stat line for `.claude/hooks/hook-command-invocation.ps1`, the file C1a owns (epic Shared Design); the `--grep=824` log prints at least one line, and c1a-merged-probe.TS.md quotes the subject of each such line. Together these show C1a has reached INTEG. A diff exit of 0, or zero lines from the `--grep=824` log, stops the plan with `C1A-NOT-MERGED`.
- [x] [P0-T10] Merge INTEG into BRANCH without a fast-forward and without rewriting history. Commands: `git merge --no-ff --no-commit origin/epic/enforcement-hook-precision-integration`; on a conflict run `git merge --abort` and stop with `MERGE-CONFLICT`; otherwise CMD-GIT-COMMIT with message "chore(850): merge the epic integration branch after C1a (#824)"; then `git rev-parse HEAD^2`, `git rev-parse origin/epic/enforcement-hook-precision-integration`, CMD-GIT-STATUS, and CMD-GIT-PUSH. Skip branch (authorized here): when the merge prints "Already up to date." no merge state exists, so the commit and the `HEAD^2` read are skipped and `git merge-base --is-ancestor origin/epic/enforcement-hook-precision-integration HEAD` is run instead. Write FEATURE/evidence/baseline/integration-merge.TS.md. Acceptance: in the merge case the two rev-parse values are equal; in the skip case the ancestry check exits 0; in both cases every CMD-GIT-STATUS line names a path under FEATURE (the P0-T5 through P0-T9 evidence artifacts or PLAN), any other line stops the plan, and the push exits 0. No force push is used.
- [x] [P0-T11] Record BASE_SHA. Commands: CMD-GIT-MERGE-BASE and `git rev-parse origin/epic/enforcement-hook-precision-integration`. Write FEATURE/evidence/baseline/base-sha.TS.md. Acceptance: the merge-base value is 40 hexadecimal characters and equals the rev-parse value; it is recorded as BASE_SHA.
- [x] [P0-T12] Pre-edit re-verification on the merged tree (read-only; expectations re-baselined by revision 3 on the tree at BASE_SHA after the first run stopped, see Revision History). Commands: first write scratch script A15 of Appendix H verbatim to `SCRATCH/region-probe.ps1`, overwriting the earlier copy because revision 3 changed A15, and re-create verbatim under SCRATCH every other A1-A17 script that is absent there (a new session starts with an empty scratchpad; P0-T6 stays checked); then CMD-PS-SCRIPT with A15 (no arguments; its file, function, and anchor list is fixed in Appendix H, and it includes anchor-only entries for the test regions that C2, C4, C7, C10, C11, C12, C13, C15, and C16 and the DT-ITEM edit locate); `grep -r -l -F -e '-ContextExists' tests/scripts`; `grep -c -F -e '-ContextExists' tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1 tests/scripts/claude-hooks/enforce-pr-author-skill.TargetResolution.Tests.ps1 tests/scripts/claude-hooks/enforce-pr-author-skill.Issue824.Tests.ps1 tests/scripts/claude-hooks/hook-command-invocation.Issue824Regression.Tests.ps1`. Write FEATURE/evidence/other/c1a-reverification.TS.md (a new timestamped artifact; the stopped run's `c1a-reverification.2026-10-08T22-39.md` is not modified) holding the full A15 output, the re-derived line of every citation in the Current-tree facts list for PRA, PRAH, HCI, HCIO, MRG, MRGR, EREM, EREMR, PREM, WRR, and WIR (taken from the `FUNCTION` and `ANCHOR` lines), and a `CHECK1-FORM:` line: `relative-literal-only` when the `CHECK1-BLOCK` text still contains the regex literal `'--body-file\s+artifacts/pr_body_(\d+)\.md\b'`, otherwise `rewritten-by-c1a` followed by a one-sentence description of which quoted or absolute forms it accepts and relative to which root. Acceptance: every `FILE` line reports `ParseErrors=0`; no `FUNCTION-MISSING` or `ANCHOR-MISSING` line is printed; the `DOTSOURCE` lines of PRA and PRAH name only `hook-command-scanner.ps1`, `hook-command-invocation.ps1`, `enforce-pr-author-skill.epic-base-branch.ps1`, and `enforce-pr-author-skill-helpers.ps1`; a `DOTSOURCE path=.claude/hooks/hook-command-invocation.ps1` line names `hook-command-invocation-operands.ps1`; the `CHECK1-BLOCK` lies inside the `Test-PrAuthorReceiptVerification` line range and one of its `CHECK1-LINE` lines contains `Get-PrAuthorBodyFileValue -CommandText $CommandText` (the C1a form D5 and D12 build on); the `FUNCTION` lines for `Get-CommandLineFlagValue` and `Test-CommandLineFlag` carry `path=.claude/hooks/hook-command-invocation-operands.ps1` and each lists `params=CommandText,CommandWord,SubcommandPath,FlagName`; the `ANCHOR` line numbers of both EREM final-deny anchors lie within the `start`-`end` range of the `FUNCTION name=Get-EpicWorktreeRemovalTargetDenial` line, and those of both PREM final-deny anchors lie within the range of the `FUNCTION name=Get-ParallelWorktreeRemovalTargetDenial` line (D14); the `FUNCTION` lines list these exact `params=` values: `Get-PrAuthorBodyFileValue` `params=CommandText`, `Get-PrAuthorBodyFileRoot` `params=` (empty), `Get-EpicWorktreeRemovalTargetDenial` `params=WorktreePath`, `Get-ParallelWorktreeRemovalTargetDenial` `params=WorktreePath`, `Read-EpicWorktreeGateRunCheckpoint` `params=Kind,WorktreePath`, `Resolve-EpicWorktreeGateRunTarget` `params=Kind,WorktreePath`, `Test-PrAuthorReceiptVerification` `params=CommandText,CheckpointPath,EpicScope`, `Get-PrAuthorBypassReason` `params=CommandText,ContextExists`, `Test-PrAuthorBypassRequired` `params=CommandText,ContextExists`, `Get-PrContextArtifactExistence` `params=` (empty), `Get-PrContextSummaryLastWriteUtc` `params=` (empty), `Resolve-EpicMergeGateRunTarget` `params=Kind,PrNumber`, `Test-ChildCheckpointPrGateBinding` `params=Checkpoint,CommandPrNumber`, and `Get-EpicMergeGateUnresolvedReason` `params=EpicTarget,ParallelTarget`; the `grep -r -l` command lists exactly these four files, in any order: `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1`, `tests/scripts/claude-hooks/enforce-pr-author-skill.TargetResolution.Tests.ps1`, `tests/scripts/claude-hooks/enforce-pr-author-skill.Issue824.Tests.ps1`, and `tests/scripts/claude-hooks/hook-command-invocation.Issue824Regression.Tests.ps1`; the `grep -c` command prints `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1:6`, `tests/scripts/claude-hooks/enforce-pr-author-skill.TargetResolution.Tests.ps1:5`, `tests/scripts/claude-hooks/enforce-pr-author-skill.Issue824.Tests.ps1:4`, and `tests/scripts/claude-hooks/hook-command-invocation.Issue824Regression.Tests.ps1:4`; the line counts satisfy PRA at most 480, PRAH at most 470, MRG at most 480, MRGR at most 440, EREM at most 480, EREMR at most 430, PREM at most 498, WRR exactly 497, and WIR at most 430. Stop condition `C1A-REGION-UNANTICIPATED`: any acceptance item above fails, which means a C3 edit region was rewritten, moved, or grown in a way the research did not anticipate; stop and return the plan to the planner with the artifact. A `rewritten-by-c1a` Check 1 that satisfies every other item is anticipated (D5 replaces the whole block) and does not stop the plan.
- [x] [P0-T13] Record test-file line counts. Command: CMD-PS-SCRIPT with A4 over Appendix F group LC-TESTS. Write FEATURE/evidence/baseline/line-counts-tests.TS.md. Acceptance: 14 `LineCount=` lines; `enforce-pr-author-skill.Issue824.Tests.ps1` at most 480, `hook-command-invocation.Issue824Regression.Tests.ps1` at most 480, `enforce-epic-worktree-removal-gate.Tests.ps1` at most 499, `enforce-pr-author-skill.Tests.ps1` at most 490, `WorktreeRunResolution.Record.Tests.ps1` at most 488, `enforce-parallel-worktree-removal-gate.WorktreeResolution.Tests.ps1` at most 485, `enforce-epic-merge-gate.WorktreeResolution.Tests.ps1` at most 470, `enforce-pr-author-skill.WorktreeResolution.Tests.ps1` at most 480, `enforce-gate-suites.EpicStateIsolation.Tests.ps1` at most 499. A larger value stops the plan with `C1A-REGION-UNANTICIPATED`.
- [x] [P0-T14] Mirror-pair baseline. Command: CMD-PS-SCRIPT with A10 over Appendix F group MP-EXIST. Write FEATURE/evidence/baseline/mirror-hashes.TS.md. Acceptance: `PAIR-SUMMARY pairs=13 unequal=0`. An unequal pair stops the plan, because a later `cp` would discard a bundle-specific difference.
- [x] [P0-T15] PowerShell format baseline (read-only, before any write-mode formatter). Command: CMD-PS-SCRIPT with A6 over `.claude/hooks/*.ps1 .claude/lib/worktree-resolution/*.psm1 tests/scripts/claude-hooks/*.ps1 tests/scripts/claude-lib/worktree-resolution/*.ps1 tests/scripts/claude-lib/orchestrator-state/*.ps1`. Write FEATURE/evidence/baseline/powershell-format.TS.md. Acceptance: `FORMAT-SUMMARY ChangedCount=0`. A non-zero count stops the plan, because the folder-scoped MCP format call in P8-T1 would otherwise rewrite files outside this item.
- [x] [P0-T16] PowerShell analyzer baseline. Command: CMD-PS-SCRIPT with A7 over Appendix F groups PROD-EXIST and EDITED-TESTS (the fourteen listed suites). Write FEATURE/evidence/baseline/powershell-analyze.TS.md with every `PSSA` line verbatim. Acceptance: A7 prints `PSSA-SUMMARY DiagnosticCount=0`. Otherwise stop with `PSSA-BASELINE-NONZERO`, because every later analyzer task over these files requires zero diagnostics.
- [x] [P0-T17] Pester baseline SET-PRA (Appendix G), with rule EE. Commands: first re-create verbatim under SCRATCH every Appendix H script A1-A18 that is absent there (A18 is new in revision 4; a new session starts with an empty scratchpad); then CMD-PS-SCRIPT with A2 and `-Path` set to the comma-separated SET-PRA list; then CMD-PS-SCRIPT with A18 (no arguments; read-only). Write FEATURE/evidence/baseline/pester-set-pra.TS.md, a new timestamped artifact holding the A2 output and the full A18 output (the stopped run's `pester-set-pra.2026-10-08T23-20.md` and `pester-set-pra.2026-10-08T23-21.md` are not modified). Acceptance: the artifact records `TotalCount=` (as BASE_PRA), `PassedCount=`, `FailedCount=`, every `FAILED:`, `FAILED-FILE:`, and `FAILED-CONTAINER:` line verbatim, and the three A18 lines `DECISION=`, `REASON=`, and `DECISION-WITHOUT-CHECKPOINT=` verbatim; rule EE is applied, and an EE-1 failure that satisfies it is recorded with its line pair, the quoted `REASON=` line as its failure message, and `ENV-EPIC-FAILED: EE-1`; the remaining `FAILED:` lines are the baseline failure set and the `FAILED-CONTAINER:` lines the baseline container set, each possibly empty. Stop with `BASELINE-RED-IN-EDITED-SUITE` when any `FAILED-FILE:` or `FAILED-CONTAINER:` value not exempted by rule EE ends with the file name of a member of Appendix F group BASELINE-GREEN (the EDITED-TESTS suites plus the suites spec AC-14, AC-25, AC-33, AC-38, and AC-41 name), or when any `FAILED-FILE:` or `FAILED-CONTAINER:` value is blank, because a pre-existing failure in a suite this plan edits or must keep green cannot be told apart from a regression. The exemption covers EE-1 only; any other failure in a BASELINE-GREEN suite, including another `gh pr create` row, stops the plan as before.
- [x] [P0-T18] Pester baseline SET-MRG; artifact FEATURE/evidence/baseline/pester-set-mrg.TS.md. Acceptance: as P0-T17 (without re-running A18), including rule EE and the `BASELINE-RED-IN-EDITED-SUITE` stop; TotalCount recorded as BASE_MRG. SET-MRG contains no EE-ROWS suite, so rule EE exempts nothing here and every failure in a BASELINE-GREEN suite stops the plan.
- [x] [P0-T19] Pester baseline SET-REM; artifact FEATURE/evidence/baseline/pester-set-rem.TS.md. Acceptance: as P0-T17 (without re-running A18), including rule EE and the `BASELINE-RED-IN-EDITED-SUITE` stop; TotalCount recorded as BASE_REM. SET-REM contains no EE-ROWS suite, so rule EE exempts nothing here and every failure in a BASELINE-GREEN suite stops the plan.
- [x] [P0-T20] Pester baseline SET-LIB; artifact FEATURE/evidence/baseline/pester-set-lib.TS.md. Acceptance: as P0-T17 (without re-running A18), including rule EE and the `BASELINE-RED-IN-EDITED-SUITE` stop; TotalCount recorded as BASE_LIB. SET-LIB contains no EE-ROWS suite, so rule EE exempts nothing here and every failure in a BASELINE-GREEN suite stops the plan.
- [x] [P0-T21] Pester baseline over the folder `tests/scripts/claude-hooks`; artifact FEATURE/evidence/baseline/pester-claude-hooks.TS.md. Acceptance: the artifact records the P0-T17 fields (without re-running A18; the `BASELINE-RED-IN-EDITED-SUITE` stop belongs to P0-T17 through P0-T20 only); rule EE is applied using the P0-T17 probe output, so an EE-1 line that satisfies it is recorded as `ENV-EPIC-FAILED: EE-1` and is not a member of the P0-T21 baseline failure set; TotalCount recorded as BASE_HOOKS.
- [x] [P0-T22] Pester baseline over the folder `tests/scripts/claude-lib`; artifact FEATURE/evidence/baseline/pester-claude-lib.TS.md. Acceptance: the artifact records the P0-T17 fields (without re-running A18), with rule EE applied; the folder contains no EE-ROWS suite, so rule EE exempts nothing here; TotalCount recorded as BASE_CLIB.
- [x] [P0-T23] Pester baseline over the folder `tests/scripts/claude-runtime`; artifact FEATURE/evidence/baseline/pester-claude-runtime.TS.md. Acceptance: the artifact records the P0-T17 fields other than the A18 lines (rule EE does not apply here); TotalCount recorded as BASE_RT.
- [x] [P0-T24] Pester baseline over the folder `tests/scripts/codex-hooks`; artifact FEATURE/evidence/baseline/pester-codex-hooks.TS.md. Acceptance: the artifact records the P0-T17 fields other than the A18 lines (rule EE does not apply here); TotalCount recorded as BASE_CODEX.
- [x] [P0-T25] Coverage baseline CG-PRA (Appendix G). Command: CMD-PS-SCRIPT with A3, the CG-PRA baseline `-TestPath` and `-CoveragePath` lists, `-CoverageOutputPath SCRATCH/cov-pra-base.xml -ReportPath SCRATCH/cov-pra-base.txt`. Write FEATURE/evidence/baseline/coverage-pra.TS.md. Acceptance: the artifact records `TotalCount=`, `FailedCount=`, every `FAILED:` line verbatim (that group's baseline failure set, possibly empty; in this task only, rule EE is applied using the P0-T17 probe output, so an EE-1 `FAILED:` line that satisfies it is recorded as `ENV-EPIC-FAILED: EE-1` and is not a member of the P0-T25 baseline failure set; P0-T26 through P0-T29 run no EE-ROWS suite), every `FAILED-CONTAINER:` line (that group's baseline container set, possibly empty), and one `COVERAGE file=` line with a numeric `LinePercent=` for each coverage file, each recorded as that file's BASEPCT.
- [x] [P0-T26] Coverage baseline CG-MRG, report SCRATCH/cov-mrg-base.txt, artifact FEATURE/evidence/baseline/coverage-mrg.TS.md. Acceptance: as P0-T25.
- [x] [P0-T27] Coverage baseline CG-EREM, report SCRATCH/cov-erem-base.txt, artifact FEATURE/evidence/baseline/coverage-erem.TS.md. Acceptance: as P0-T25.
- [x] [P0-T28] Coverage baseline CG-PREM, report SCRATCH/cov-prem-base.txt, artifact FEATURE/evidence/baseline/coverage-prem.TS.md. Acceptance: as P0-T25.
- [x] [P0-T29] Coverage baseline CG-LIB, report SCRATCH/cov-lib-base.txt, artifact FEATURE/evidence/baseline/coverage-lib.TS.md. Acceptance: as P0-T25.
- [x] [P0-T30] Python parity baseline. Command: CMD-PY-PARITY-EXT. Write FEATURE/evidence/baseline/python-parity.TS.md. Acceptance: the artifact records every PASSED and FAILED node line and the summary line (the baseline failure set BASE_PY); the KL-510 node satisfies KL-510.
- [x] [P0-T31] Commit and push Phase 0 evidence. Commands: CMD-GIT-ADD with the FEATURE evidence directory and PLAN; CMD-GIT-COMMIT with message "docs(850): record phase 0 baselines and the pre-edit re-verification"; CMD-GIT-PUSH. Acceptance: CMD-GIT-STATUS prints nothing after the commit and the push exits 0.

### Phase 1 — #789 CR-4 UNC Path Comparison (WRR)

- [x] [P1-T1] Add row B14 to `tests/scripts/claude-lib/worktree-resolution/WorktreeRunResolution.Record.Tests.ps1` per Appendix C, C1, immediately after the closing brace of row B13 inside `Describe 'Resolve-WorktreeRunTargetByRecord'`. Acceptance: CMD-GREP-COUNT with literal `B14 compares UNC paths case-insensitively` over that file prints 1; A4 over it prints a value of at most 500.
- [x] [P1-T2] [expect-fail] Fail-before run. Command: CMD-PS-SCRIPT with A2 and `-Path tests/scripts/claude-lib/worktree-resolution/WorktreeRunResolution.Record.Tests.ps1`. Write FEATURE/evidence/regression-testing/cr4-fail-before.TS.md. Acceptance: `FailedCount=1` and the single `FAILED:` line ends with "B14 compares UNC paths case-insensitively".
- [x] [P1-T3] SW-1, SW-2, and SW-2b for WRR per Appendix B, B1 (SW-2b into `SCRATCH/stage-lib-p1`). Acceptance: A12 prints `STAGE-CHECK ParseErrors=0 FormatChanged=False DiagnosticCount=0` for `SCRATCH/stage/WorktreeRunResolution.psm1`; A4 over the staged copy prints `LineCount=497`; A17 with `-StageRoot` set to this task's last SW-2b directory (`SCRATCH/stage-lib-p1`, or `SCRATCH/stage-lib-p1-<n>` after a retry) and `-ModuleName WorktreeRunResolution` prints `LOAD-CHECK Module=WorktreeRunResolution Imported=True ExportCount=7` (B1 leaves the seven-function export list unchanged).
- [x] [P1-T4] SW-3 for WRR, performed only after P1-T3 printed the `Imported=True` line. Acceptance: the Write succeeds without a hook denial.
- [x] [P1-T5] SW-4 for WRR and the first WLOG entry (WLOG is created by this task per Appendix J). Acceptance: the two `Hash=` values are equal; WLOG records WRR.
- [x] [P1-T6] Mirror WRR: CMD-CP from WRR to `CB/.claude/lib/worktree-resolution/WorktreeRunResolution.psm1`; then A10 over that pair. Acceptance: `PAIR-SUMMARY pairs=1 unequal=0`.
- [x] [P1-T7] Format check (read-only): A6 over WRR and the Record suite; CMD-GIT-STATUS. Write FEATURE/evidence/qa-gates/format-p1.TS.md. Acceptance: `FORMAT-SUMMARY ChangedCount=0`; every CMD-GIT-STATUS line names WRR, its CB mirror, the Record suite, WLOG, a FEATURE evidence path, or PLAN.
- [x] [P1-T8] Analyze: A7 over WRR and the Record suite. Write FEATURE/evidence/qa-gates/analyze-p1.TS.md. Acceptance: `PSSA-SUMMARY DiagnosticCount=0`.
- [x] [P1-T9] Pass-after run of the Record suite (A2 as P1-T2). Write FEATURE/evidence/regression-testing/cr4-pass-after.TS.md. Acceptance: `FailedCount=0` (B11, B12, B14, and X1 pass) and no `FAILED-CONTAINER:` line (rule CC).
- [x] [P1-T10] Run SET-LIB (A2). Write FEATURE/evidence/qa-gates/pester-set-lib-p1.TS.md and append a suite-result row to WLOG. Acceptance: `TotalCount=` equals BASE_LIB plus 1 and every `FAILED:` line is a member of the P0-T20 baseline failure set; every `FAILED-CONTAINER:` line is a member of the P0-T20 baseline container set (rule CC).
- [x] [P1-T11] Line counts: A4 over WRR and the Record suite. Write FEATURE/evidence/qa-gates/line-counts-p1.TS.md. Acceptance: WRR prints `LineCount=497`; the suite prints a value of at most 500.
- [x] [P1-T12] Python parity: CMD-PY-PARITY. Write FEATURE/evidence/regression-testing/python-parity-p1.TS.md. Acceptance: every node other than the KL-510 node is PASSED or a member of BASE_PY, and that node satisfies KL-510.
- [x] [P1-T13] Check off AC-30 (spec line 248) and AC-31 (spec line 249) in FEATURE/spec.md by changing each line's leading `- [ ] ` to `- [x] `, then run CMD-PS-SCRIPT with A14, `-Path FEATURE/spec.md -FromLine 204 -Line 248,249`. Append the check-off with its cited evidence (P1-T9) to FEATURE/evidence/other/ac-checkoff.md. Acceptance: A14 prints `CHECKBOX checked=2 unchecked=45`, `LINE n=248 state=checked`, and `LINE n=249 state=checked`.
- [x] [P1-T14] Commit and push Phase 1. Commands: CMD-GIT-ADD with WRR, its CB mirror, the Record suite, FEATURE/spec.md, the FEATURE evidence directory, and PLAN; CMD-GIT-COMMIT with message "fix(789): compare UNC worktree paths case-insensitively (CR-4)"; CMD-GIT-PUSH. Acceptance: CMD-GIT-STATUS prints nothing and the push exits 0.

### Phase 2 — #789 CR-5 Single Deny Token (PREM)

- [x] [P2-T1] Add row Y7 to `tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.WorktreeResolution.Tests.ps1` per Appendix C, C2, immediately after row Y6 inside the same `Describe`. Acceptance: CMD-GREP-COUNT with literal `Y7 emits a single leading token when both run kinds are unresolved` over that file prints 1.
- [x] [P2-T2] [expect-fail] Fail-before run: A2 with `-Path tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.WorktreeResolution.Tests.ps1`. Write FEATURE/evidence/regression-testing/cr5-parallel-fail-before.TS.md. Acceptance: `FailedCount=1` and the single `FAILED:` line ends with "Y7 emits a single leading token when both run kinds are unresolved".
- [x] [P2-T3] SW-1 and SW-2 for PREM per Appendix B, B2. Acceptance: A12 prints the clean `STAGE-CHECK` line for `SCRATCH/stage/enforce-parallel-worktree-removal-gate.ps1`, and A4 over the staged copy prints the PREM line count recorded in P0-T12 (zero net lines).
- [x] [P2-T4] SW-3 for PREM. Acceptance: the Write succeeds without a hook denial.
- [x] [P2-T5] SW-4 for PREM and the WLOG entry. Acceptance: the hashes are equal; WLOG records PREM.
- [x] [P2-T6] Mirror PREM (CMD-CP to `CB/.claude/hooks/enforce-parallel-worktree-removal-gate.ps1`) and run A10 over the pair. Acceptance: `PAIR-SUMMARY pairs=1 unequal=0`.
- [x] [P2-T7] Format check: A6 over PREM and the edited suite; CMD-GIT-STATUS. Write FEATURE/evidence/qa-gates/format-p2.TS.md. Acceptance: `FORMAT-SUMMARY ChangedCount=0`; every status line names PREM, its mirror, the edited suite, WLOG, a FEATURE evidence path, or PLAN.
- [x] [P2-T8] Analyze: A7 over PREM and the edited suite. Write FEATURE/evidence/qa-gates/analyze-p2.TS.md. Acceptance: `PSSA-SUMMARY DiagnosticCount=0`.
- [x] [P2-T9] Pass-after run of the edited suite (A2 as P2-T2). Write FEATURE/evidence/regression-testing/cr5-parallel-pass-after.TS.md. Acceptance: `FailedCount=0` and no `FAILED-CONTAINER:` line (rule CC).
- [x] [P2-T10] Run SET-REM (A2). Write FEATURE/evidence/qa-gates/pester-set-rem-p2.TS.md and append to WLOG. Acceptance: `TotalCount=` equals BASE_REM plus 1 and every `FAILED:` line is a member of the P0-T19 baseline failure set; every `FAILED-CONTAINER:` line is a member of the P0-T19 baseline container set (rule CC).
- [x] [P2-T11] Resolved-target text unchanged (AC-33). Commands: `git diff --exit-code BASE_SHA -- tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Tests.ps1`; CMD-GIT-STATUS-PATH over that file; CMD-PS-SCRIPT with A16, `-BaseRef BASE_SHA -File tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.WorktreeResolution.Tests.ps1`. Write FEATURE/evidence/qa-gates/cr5-parallel-unchanged-rows.TS.md. Acceptance: the diff exits 0 with no output; the status prints nothing; A16 prints `removed=0` for the WorktreeResolution suite, so Y3 is unmodified.
- [x] [P2-T12] Line counts: A4 over PREM and the edited suite. Write FEATURE/evidence/qa-gates/line-counts-p2.TS.md. Acceptance: both values are at most 500 and PREM equals its P0-T12 count.
- [x] [P2-T13] Python parity (CMD-PY-PARITY). Write FEATURE/evidence/regression-testing/python-parity-p2.TS.md. Acceptance: as P1-T12.
- [x] [P2-T14] Check off AC-32 (line 253) and AC-33 (line 254); A14 with `-Line 253,254`; append to FEATURE/evidence/other/ac-checkoff.md. Acceptance: `CHECKBOX checked=4 unchecked=43` and both lines `state=checked`.
- [x] [P2-T15] Commit and push Phase 2. Commands: CMD-GIT-ADD with PREM, its mirror, the edited suite, FEATURE/spec.md, the FEATURE evidence directory, and PLAN; CMD-GIT-COMMIT with message "fix(789): emit one PARALLEL_WORKTREE_REMOVAL_BLOCKED token (CR-5)"; CMD-GIT-PUSH. Acceptance: CMD-GIT-STATUS prints nothing and the push exits 0.

### Phase 3 — Epic Worktree-Removal Gate: Single Token and #851 Diagnostics (EREMR, EREM)

- [x] [P3-T1] Write T-EREM-DX per Appendix C, C3 (8 tests). Acceptance: the Write succeeds without a hook denial; A4 over it prints a value of at most 500. A value above 500 stops the plan with LINE-CAP and returns it to the planner with the A4 output.
- [x] [P3-T2] [expect-fail] Fail-before run: A2 with `-Path tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Diagnostics.Tests.ps1`. Write FEATURE/evidence/regression-testing/erem-diagnostics-fail-before.TS.md. Acceptance: `TotalCount=8` and `FailedCount=8`.
- [x] [P3-T3] SW-1 and SW-2 for EREMR and EREM per Appendix B, B3 and B4. Acceptance: A12 prints the clean `STAGE-CHECK` line for both staged copies; A4 prints at most 500 for each. A value above 500 stops the plan with LINE-CAP and returns it to the planner with the A4 output.
- [x] [P3-T4] SW-3 for EREMR. Acceptance: the Write succeeds without a hook denial.
- [x] [P3-T5] SW-3 for EREM, as the next repository write after P3-T4. Acceptance: the Write succeeds without a hook denial.
- [x] [P3-T6] SW-4 for EREMR and EREM and the two WLOG entries. Acceptance: both hash pairs are equal; WLOG records EREMR then EREM.
- [x] [P3-T7] Update the exact-text row `emits the unchanged epic block reason` in `tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1` per Appendix C, C4 (one appended line, no other change). Acceptance: A16 with `-BaseRef BASE_SHA -File tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1` prints `added=1 removed=0`; A4 over the file prints a value of at most 500.
- [x] [P3-T8] Mirror EREMR and EREM (two CMD-CP into `CB/.claude/hooks/`) and run A10 over the two pairs. Acceptance: `PAIR-SUMMARY pairs=2 unequal=0`.
- [x] [P3-T9] Format check: A6 over EREMR, EREM, T-EREM-DX, and the edited suite; CMD-GIT-STATUS. Write FEATURE/evidence/qa-gates/format-p3.TS.md. Acceptance: `FORMAT-SUMMARY ChangedCount=0`; every status line names a P3 file, its mirror, WLOG, a FEATURE evidence path, or PLAN (T-EREM-DX appears as `??`).
- [x] [P3-T10] Analyze: A7 over the P3-T9 files. Write FEATURE/evidence/qa-gates/analyze-p3.TS.md. Acceptance: `PSSA-SUMMARY DiagnosticCount=0`.
- [x] [P3-T11] Pass-after run of T-EREM-DX (A2 as P3-T2). Write FEATURE/evidence/regression-testing/erem-diagnostics-pass-after.TS.md. Acceptance: `TotalCount=8`, `PassedCount=8`, `FailedCount=0`, and no `FAILED-CONTAINER:` line (rule CC).
- [x] [P3-T12] Run SET-REM (A2; the list now includes T-EREM-DX). Write FEATURE/evidence/qa-gates/pester-set-rem-p3.TS.md and append to WLOG. Acceptance: `TotalCount=` equals BASE_REM plus 9 and every `FAILED:` line is a member of the P0-T19 baseline failure set; every `FAILED-CONTAINER:` line is a member of the P0-T19 baseline container set (rule CC).
- [x] [P3-T13] Decision-unchanged proof (AC-38). Command: A16 with `-BaseRef BASE_SHA -File tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.TriggerScoping.Tests.ps1,tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.WorktreeResolution.Tests.ps1,tests/scripts/claude-hooks/CleanupWorktreeManifestGateMatrix.Tests.ps1,tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1`. Write FEATURE/evidence/qa-gates/erem-decision-unchanged.TS.md. Acceptance: the first three files print `added=0 removed=0`; the fourth prints `added=1 removed=0`; together with P3-T12 this shows every existing row passed with an unchanged expected decision.
- [x] [P3-T14] Line counts: A4 over EREMR, EREM, T-EREM-DX, and `tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1`. Write FEATURE/evidence/qa-gates/line-counts-p3.TS.md. Acceptance: every value is at most 500.
- [x] [P3-T15] Python parity (CMD-PY-PARITY). Write FEATURE/evidence/regression-testing/python-parity-p3.TS.md. Acceptance: as P1-T12.
- [x] [P3-T16] Check off AC-34 (255), AC-35 (259), AC-36 (260), AC-37 (261), AC-38 (262); A14 with `-Line 255,259,260,261,262`; append to FEATURE/evidence/other/ac-checkoff.md. Acceptance: `CHECKBOX checked=9 unchecked=38` and all five lines `state=checked`.
- [ ] [P3-T17] Commit and push Phase 3. Commands: CMD-GIT-ADD with EREMR, EREM, their two mirrors, T-EREM-DX, `tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1`, FEATURE/spec.md, the FEATURE evidence directory, and PLAN; CMD-GIT-COMMIT with message "fix(851): add epic worktree-removal deny diagnostics and a single deny token"; CMD-GIT-PUSH. Acceptance: CMD-GIT-STATUS prints nothing and the push exits 0.

### Phase 4 — Item Resolution by Pull Request Number (WIR)

- [ ] [P4-T1] Write T-WIR-PR per Appendix C, C5 (11 tests). Acceptance: the Write succeeds without a hook denial; A4 prints a value of at most 500. A value above 500 stops the plan with LINE-CAP and returns it to the planner with the A4 output.
- [ ] [P4-T2] [expect-fail] Fail-before run: A2 with `-Path tests/scripts/claude-lib/worktree-resolution/WorktreeItemResolution.PrNumber.Tests.ps1`. Write FEATURE/evidence/regression-testing/wir-prnumber-fail-before.TS.md. Acceptance: `TotalCount=11` and `FailedCount=11`.
- [ ] [P4-T3] SW-1, SW-2, and SW-2b for WIR per Appendix B, B5 (SW-2b into `SCRATCH/stage-lib-p4`, whose WRR copy is the Phase 1 version already in the tree). Acceptance: A12 prints the clean `STAGE-CHECK` line for `SCRATCH/stage/WorktreeItemResolution.psm1`; A4 over the staged copy prints a value of at most 500; A17 with `-StageRoot` set to this task's last SW-2b directory (`SCRATCH/stage-lib-p4`, or `SCRATCH/stage-lib-p4-<n>` after a retry) and `-ModuleName WorktreeItemResolution` prints `LOAD-CHECK Module=WorktreeItemResolution Imported=True ExportCount=10` (the nine current exports plus `Resolve-WorktreeItemTargetByPrNumber`). An A4 value above 500 stops the plan with `WIR-CAP` (D3).
- [ ] [P4-T4] SW-3 for WIR, performed only after P4-T3 printed the `Imported=True` line. Acceptance: the Write succeeds without a hook denial.
- [ ] [P4-T5] SW-4 for WIR and the WLOG entry. Acceptance: the hashes are equal; WLOG records WIR.
- [ ] [P4-T6] Mirror WIR (CMD-CP to `CB/.claude/lib/worktree-resolution/WorktreeItemResolution.psm1`) and run A10. Acceptance: `PAIR-SUMMARY pairs=1 unequal=0`.
- [ ] [P4-T7] Format check: A6 over WIR and T-WIR-PR; CMD-GIT-STATUS. Write FEATURE/evidence/qa-gates/format-p4.TS.md. Acceptance: `FORMAT-SUMMARY ChangedCount=0`; every status line names WIR, its mirror, T-WIR-PR, WLOG, a FEATURE evidence path, or PLAN.
- [ ] [P4-T8] Analyze: A7 over WIR and T-WIR-PR. Write FEATURE/evidence/qa-gates/analyze-p4.TS.md. Acceptance: `PSSA-SUMMARY DiagnosticCount=0`.
- [ ] [P4-T9] Pass-after run of T-WIR-PR (A2 as P4-T2). Write FEATURE/evidence/regression-testing/wir-prnumber-pass-after.TS.md. Acceptance: `TotalCount=11`, `PassedCount=11`, `FailedCount=0`, and no `FAILED-CONTAINER:` line (rule CC).
- [ ] [P4-T10] Run SET-LIB (A2). Write FEATURE/evidence/qa-gates/pester-set-lib-p4.TS.md and append to WLOG. Acceptance: `TotalCount=` equals BASE_LIB plus 12 and every `FAILED:` line is a member of the P0-T20 baseline failure set; every `FAILED-CONTAINER:` line is a member of the P0-T20 baseline container set (rule CC).
- [ ] [P4-T11] Line counts: A4 over WIR and T-WIR-PR. Write FEATURE/evidence/qa-gates/line-counts-p4.TS.md. Acceptance: both values are at most 500.
- [ ] [P4-T12] Python parity (CMD-PY-PARITY). Write FEATURE/evidence/regression-testing/python-parity-p4.TS.md. Acceptance: as P1-T12.
- [ ] [P4-T13] Check off AC-15 (227), AC-16 (228), AC-17 (229), AC-18 (230); A14 with `-Line 227,228,229,230`; append to FEATURE/evidence/other/ac-checkoff.md. Acceptance: `CHECKBOX checked=13 unchecked=34` and all four lines `state=checked`.
- [ ] [P4-T14] Commit and push Phase 4. Commands: CMD-GIT-ADD with WIR, its mirror, T-WIR-PR, FEATURE/spec.md, the FEATURE evidence directory, and PLAN; CMD-GIT-COMMIT with message "feat(850): resolve an item worktree by pull request number"; CMD-GIT-PUSH. Acceptance: CMD-GIT-STATUS prints nothing and the push exits 0.

### Phase 5 — Merge Gate Item Resolution and #788 Binding (MRGR, MRG)

- [ ] [P5-T1] Write T-MRG-IR per Appendix C, C6 (19 tests). Acceptance: the Write succeeds without a hook denial; A4 prints a value of at most 500. A value above 500 stops the plan with LINE-CAP and returns it to the planner with the A4 output.
- [ ] [P5-T2] [expect-fail] Fail-before run: A2 with `-Path tests/scripts/claude-hooks/enforce-epic-merge-gate.ItemResolution.Tests.ps1`. Write FEATURE/evidence/regression-testing/merge-item-fail-before.TS.md. Acceptance: `FAILED:` lines end with each of these row names: "authorizes a standalone merge from the item worktree checkpoint", "does not authorize from a session-root copy of another worktree's checkpoint", "denies an ambiguous item target with the ambiguity code", "observes module-scoped WorktreeItemResolution mocks", "denies a merge when no checkpoint records the pull request number", "returns false for a null checkpoint", "returns false when neither field records the number", and each of the three cases of "returns false for a standalone pr_number that is <Name>".
- [ ] [P5-T3] SW-1 and SW-2 for MRGR and MRG per Appendix B, B6 and B7. Acceptance: A12 prints the clean `STAGE-CHECK` line for both staged copies; A4 prints at most 500 for each. A value above 500 stops the plan with LINE-CAP and returns it to the planner with the A4 output.
- [ ] [P5-T4] SW-3 for MRGR. Acceptance: the Write succeeds without a hook denial.
- [ ] [P5-T5] SW-3 for MRG, as the next repository write after P5-T4. Acceptance: the Write succeeds without a hook denial.
- [ ] [P5-T6] SW-4 for MRGR and MRG and the two WLOG entries. Acceptance: both hash pairs are equal; WLOG records MRGR then MRG.
- [ ] [P5-T7] Add DT-ITEM (D8) as the line immediately after the existing default `Mock Resolve-EpicMergeGateRunTarget` line in `tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1`, `tests/scripts/claude-hooks/enforce-epic-merge-gate.Authorization.Tests.ps1`, `tests/scripts/claude-hooks/enforce-epic-merge-gate.TriggerScoping.Tests.ps1`, and `tests/scripts/claude-hooks/hook-command-parser.AcceptanceCases.Tests.ps1`. Acceptance: CMD-GREP-COUNT with literal `Mock Resolve-EpicMergeGateItemTarget` over the four files prints four lines, each with count 1.
- [ ] [P5-T8] Edit `tests/scripts/claude-hooks/enforce-epic-merge-gate.WorktreeResolution.Tests.ps1` per Appendix C, C7 (NoTarget default item mock; rows M3, M4, M5, M9; header sentence). Acceptance: CMD-GREP-COUNT with literal `M5 denies a child merge whose checkpoint records neither pr_gate nor a standalone record for the number` over that file prints 1; A4 prints a value of at most 500.
- [ ] [P5-T9] Mirror MRGR and MRG (two CMD-CP) and run A10 over the two pairs. Acceptance: `PAIR-SUMMARY pairs=2 unequal=0`.
- [ ] [P5-T10] Format check: A6 over MRGR, MRG, T-MRG-IR, and the five edited suites; CMD-GIT-STATUS. Write FEATURE/evidence/qa-gates/format-p5.TS.md. Acceptance: `FORMAT-SUMMARY ChangedCount=0`; every status line names a P5 file, a mirror, WLOG, a FEATURE evidence path, or PLAN.
- [ ] [P5-T11] Analyze: A7 over the P5-T10 files. Write FEATURE/evidence/qa-gates/analyze-p5.TS.md. Acceptance: `PSSA-SUMMARY DiagnosticCount=0`.
- [ ] [P5-T12] Pass-after run of T-MRG-IR (A2 as P5-T2). Write FEATURE/evidence/regression-testing/merge-item-pass-after.TS.md. Acceptance: `TotalCount=19`, `PassedCount=19`, `FailedCount=0`, and no `FAILED-CONTAINER:` line (rule CC).
- [ ] [P5-T13] Run the merge WorktreeResolution suite: A2 with `-Path tests/scripts/claude-hooks/enforce-epic-merge-gate.WorktreeResolution.Tests.ps1`. Write FEATURE/evidence/regression-testing/merge-worktree-resolution-p5.TS.md. Acceptance: `FailedCount=0` (M5 now asserts the deny; M6 passes unchanged) and no `FAILED-CONTAINER:` line (rule CC).
- [ ] [P5-T14] Run SET-MRG (A2; the list now includes T-MRG-IR), applying rule CR to any new failure and re-running until it holds. Write FEATURE/evidence/qa-gates/pester-set-mrg-p5.TS.md (one section per run) and append to WLOG. Acceptance: the final run prints `TotalCount=` equal to BASE_MRG plus 19 and every `FAILED:` line is a member of the P0-T18 baseline failure set; every `FAILED-CONTAINER:` line is a member of the P0-T18 baseline container set (rule CC); every CR update is listed in FEATURE/evidence/other/edited-suites-850.md.
- [ ] [P5-T15] Line counts: A4 over MRGR, MRG, T-MRG-IR, and the five edited suites. Write FEATURE/evidence/qa-gates/line-counts-p5.TS.md. Acceptance: every value is at most 500.
- [ ] [P5-T16] Python parity (CMD-PY-PARITY). Write FEATURE/evidence/regression-testing/python-parity-p5.TS.md. Acceptance: as P1-T12.
- [ ] [P5-T17] Check off AC-19 through AC-25 (lines 231-237) and AC-26 through AC-29 (lines 241-244); A14 with `-Line 231,232,233,234,235,236,237,241,242,243,244`; append to FEATURE/evidence/other/ac-checkoff.md. Acceptance: `CHECKBOX checked=24 unchecked=23` and all eleven lines `state=checked`.
- [ ] [P5-T18] Commit and push Phase 5. Commands: CMD-GIT-ADD with MRGR, MRG, their mirrors, T-MRG-IR, the five edited suites, every suite listed in FEATURE/evidence/other/edited-suites-850.md, FEATURE/spec.md, the FEATURE evidence directory, and PLAN; CMD-GIT-COMMIT with message "fix(850): read the merge authorization checkpoint beneath the item worktree and bind the PR number (#788)"; CMD-GIT-PUSH. Acceptance: CMD-GIT-STATUS prints nothing and the push exits 0.

### Phase 6 — pr-author Gate Artifact Root and Check 1 Binding (PRAR, PRAH, PRA)

- [ ] [P6-T1] Fixture copies (D10). Commands: CMD-CP from `tests/fixtures/worktree-resolution/pr-author/item-own-ready/artifacts/pr_body_1.md`, `.../pr_body_1.receipt.json`, and `.../pr_context.summary.txt` to the same file names under `tests/fixtures/worktree-resolution/pr-author/item-own-epic-mode/artifacts/`; then with the Edit tool update `tests/fixtures/worktree-resolution/README.md` per Appendix C, C8; then A10 over the three source/copy pairs and CMD-GIT-STATUS-PATH over `tests/fixtures/worktree-resolution`. Acceptance: `PAIR-SUMMARY pairs=3 unequal=0`; the status prints three `??` lines for the copies and one ` M` line for the README.
- [ ] [P6-T2] Write T-PRA-IAR per Appendix C, C9 (15 tests). Acceptance: the Write succeeds without a hook denial; A4 prints a value of at most 500. A value above 500 stops the plan with LINE-CAP and returns it to the planner with the A4 output.
- [ ] [P6-T3] [expect-fail] Fail-before run: A2 with `-Path tests/scripts/claude-hooks/enforce-pr-author-skill.ItemArtifactRoot.Tests.ps1`. Write FEATURE/evidence/regression-testing/pr-author-artifact-root-fail-before.TS.md. Acceptance: `FAILED:` lines end with each of these row names: "allows an OtherWorktree target whose artifacts exist only in the item worktree", "ignores session-root PR artifacts when the target is another worktree", "reads summary, body, receipt and summary timestamp beneath the resolved item root", "compares receipt freshness against the item worktree summary", "resolves the target once and reuses it for artifacts, preflight and Check 6", "denies an unresolvable target with the no-target code ahead of PR_CONTEXT_MISSING", "denies an ambiguous target with the ambiguity code ahead of PR_CONTEXT_MISSING", "denies a relative body path for an OtherWorktree target and names the absolute path", "applies drive and UNC case-insensitive, POSIX case-sensitive body path comparison", "keeps SessionRoot behavior with absolute artifact paths", and "reads epic-scope PR artifacts beneath the epic checkpoint worktree".
- [ ] [P6-T4] SW-1 and SW-2 for PRAR, PRAH, and PRA per Appendix B, B8, B9, and B10. Acceptance: A12 prints the clean `STAGE-CHECK` line for all three staged copies; A4 prints at most 500 for each. A value above 500 stops the plan with LINE-CAP and returns it to the planner with the A4 output.
- [ ] [P6-T5] SW-3 for PRAR (new file; the current PRAH does not dot-source it). Acceptance: the Write succeeds without a hook denial.
- [ ] [P6-T6] SW-3 for PRAH, as the next repository write after P6-T5. Acceptance: the Write succeeds without a hook denial.
- [ ] [P6-T7] SW-3 for PRA, as the next repository write after P6-T6. Acceptance: the Write succeeds without a hook denial.
- [ ] [P6-T8] SW-4 for PRAR, PRAH, and PRA and the three WLOG entries. Acceptance: all three hash pairs are equal; WLOG records PRAR, PRAH, PRA in that order.
- [ ] [P6-T9] Edit `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1` per Appendix C, C10 (including the revision-4 bullet that isolates `Context 'allowed commands'` from the local checkpoint); then run CMD-GREP-COUNT with literal `-ContextExists` (passed through `-e`) over that file, and separately CMD-GREP-COUNT with literal `Get-PrAuthorCheckpointContent` (passed through `-e`) over that file. Write FEATURE/evidence/qa-gates/context-exists-removed-pra-tests.TS.md with `ExpectedExitCode: 1` for the first grep, and FEATURE/evidence/qa-gates/epic-checkpoint-isolation-pra-tests.TS.md (no expectation field) for the second grep. Acceptance: the first grep prints 0 and exits 1; the second grep prints 4 and exits 0 (lines 306, 326, and 372 at BASE_SHA plus the new `allowed commands` mock); A4 prints a value of at most 500.
- [ ] [P6-T10] Edit `tests/scripts/claude-hooks/enforce-pr-author-skill.TargetResolution.Tests.ps1` per Appendix C, C11; then run CMD-GREP-COUNT with literal `-ContextExists` (passed through `-e`) over that file. Write FEATURE/evidence/qa-gates/context-exists-removed-target-resolution.TS.md with `ExpectedExitCode: 1`. Acceptance: the grep prints 0 and exits 1.
- [ ] [P6-T11] Edit S824 per Appendix C, C15; then run `grep -c -F -e '-ContextExists' -e 'Get-PrAuthorBodyFileRoot' -e 'PA-21' tests/scripts/claude-hooks/enforce-pr-author-skill.Issue824.Tests.ps1`. Write FEATURE/evidence/qa-gates/context-exists-removed-issue824.TS.md with `ExpectedExitCode: 1`. Acceptance: the grep prints 0 and exits 1 (the parameter, the seam mock, and row PA-21 are gone); CMD-GREP-COUNT with literal `-RelativeBodyAllowed` (passed through `-e`) over S824 prints 1; A4 over S824 prints a value of at most 500.
- [ ] [P6-T12] Edit S824R per Appendix C, C16; then run `grep -r -l -F -e '-ContextExists' -e 'Get-PrAuthorBodyFileRoot' .claude/hooks tests/scripts`. Write FEATURE/evidence/qa-gates/context-exists-removed-repo.TS.md with `ExpectedExitCode: 1`. Acceptance: the recursive grep prints nothing and exits 1 (after P6-T6, P6-T7, and P6-T9 through P6-T12, no hook and no suite names the removed parameter or the removed seam); CMD-GREP-COUNT with literal `-RelativeBodyAllowed` (passed through `-e`) over S824R prints 5; A4 over S824R prints a value of at most 500.
- [ ] [P6-T13] Edit `tests/scripts/claude-hooks/enforce-pr-author-skill.WorktreeResolution.Tests.ps1` per Appendix C, C12 (header; R1 rows; R3 not-ready row; first R4 row; second R4 row; both R7 rows; genuine-absence row; shared-path row). Acceptance: A4 prints a value of at most 500.
- [ ] [P6-T14] Add T-PRA-IAR to the guard list in `tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Tests.ps1` per Appendix C, C13. Acceptance: CMD-GREP-COUNT with literal `enforce-pr-author-skill.ItemArtifactRoot.Tests.ps1` over that file prints 1.
- [ ] [P6-T15] Register PRAR in CORE: with the Edit tool insert the line `    ".claude/hooks/enforce-pr-author-skill.artifact-root.ps1",` immediately before the line `    ".claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1",`; then A8 over CORE. Acceptance: A8 prints `JSON-OK`; CMD-GREP-COUNT with literal `.claude/hooks/enforce-pr-author-skill.artifact-root.ps1` over CORE prints 1.
- [ ] [P6-T16] Mirror PRAR, PRAH, and PRA (three CMD-CP into `CB/.claude/hooks/`) and run A10 over the three pairs. Acceptance: `PAIR-SUMMARY pairs=3 unequal=0`.
- [ ] [P6-T17] Format check: A6 over PRAR, PRAH, PRA, T-PRA-IAR, and the six edited suites of P6-T25; CMD-GIT-STATUS. Write FEATURE/evidence/qa-gates/format-p6.TS.md. Acceptance: `FORMAT-SUMMARY ChangedCount=0`; every status line names a P6 file, a fixture copy, the fixture README, a mirror, CORE, WLOG, a FEATURE evidence path, or PLAN.
- [ ] [P6-T18] Analyze: A7 over the P6-T17 PowerShell files. Write FEATURE/evidence/qa-gates/analyze-p6.TS.md. Acceptance: `PSSA-SUMMARY DiagnosticCount=0`.
- [ ] [P6-T19] Pass-after run of T-PRA-IAR (A2 as P6-T3). Write FEATURE/evidence/regression-testing/pr-author-artifact-root-pass-after.TS.md. Acceptance: `TotalCount=15`, `PassedCount=15`, `FailedCount=0`, and no `FAILED-CONTAINER:` line (rule CC).
- [ ] [P6-T20] Run the isolation guard: A2 with `-Path tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Tests.ps1`. Write FEATURE/evidence/qa-gates/epic-state-isolation-p6.TS.md. Acceptance: `FailedCount=0` and no `FAILED-CONTAINER:` line (rule CC) (AC-47).
- [ ] [P6-T21] Run SET-PRA (A2; the list now includes T-PRA-IAR), applying rule CR to any new failure and re-running until it holds. Write FEATURE/evidence/qa-gates/pester-set-pra-p6.TS.md (one section per run) and append to WLOG. Acceptance: the final run prints `TotalCount=` equal to BASE_PRA plus 15 (T-PRA-IAR 15, isolation-guard case 1, row PA-21 removed by C15) and every `FAILED:` line is a member of the P0-T17 baseline failure set; every `FAILED-CONTAINER:` line is a member of the P0-T17 baseline container set (rule CC); no `FAILED:` line ends with `allows gh pr create --body-file artifacts/pr_body_12.md when context exists` (EE-1 is in no baseline failure set and rule EE does not apply after Phase 0); every CR update is listed in FEATURE/evidence/other/edited-suites-850.md.
- [ ] [P6-T22] Line counts: A4 over PRAR, PRAH, PRA, T-PRA-IAR, the six edited suites of P6-T25, and every suite added by rule CR in this phase. Write FEATURE/evidence/qa-gates/line-counts-p6.TS.md. Acceptance: every value is at most 500.
- [ ] [P6-T23] Python parity (CMD-PY-PARITY; the pack-manifest completeness node now sees PRAR). Write FEATURE/evidence/regression-testing/python-parity-p6.TS.md. Acceptance: as P1-T12.
- [ ] [P6-T24] Check off AC-01 through AC-14 (lines 210-223) and AC-47 (line 277); A14 with `-Line 210,211,212,213,214,215,216,217,218,219,220,221,222,223,277`; append to FEATURE/evidence/other/ac-checkoff.md. Acceptance: `CHECKBOX checked=39 unchecked=8` and all fifteen lines `state=checked`.
- [ ] [P6-T25] Commit and push Phase 6. Commands: CMD-GIT-ADD with PRAR, PRAH, PRA, their three mirrors, CORE, the three fixture copies, `tests/fixtures/worktree-resolution/README.md`, T-PRA-IAR, the six edited suites (`enforce-pr-author-skill.Tests.ps1`, `.TargetResolution.Tests.ps1`, `.WorktreeResolution.Tests.ps1`, `enforce-gate-suites.EpicStateIsolation.Tests.ps1`, S824, S824R), every suite listed in FEATURE/evidence/other/edited-suites-850.md, FEATURE/spec.md, the FEATURE evidence directory, and PLAN; CMD-GIT-COMMIT with message "fix(850): read pr-author artifacts beneath the resolved worktree and bind the body path to it"; CMD-GIT-PUSH. Acceptance: CMD-GIT-STATUS prints nothing and the push exits 0.

### Phase 7 — Handoff Documentation and the Constraints Suite

- [ ] [P7-T1] Edit SKILL per Appendix D, D1 (one paragraph inserted after the numbered item that begins "4. The orchestrator records `pr_author_receipt`"). Acceptance: CMD-GREP-COUNT with literal `PR_BODY_PATH_NONCANONICAL` over SKILL prints 1.
- [ ] [P7-T2] Mirror SKILL (CMD-CP to `CB/.claude/skills/orchestrate/SKILL.md`) and run A10 over the pair. Acceptance: `PAIR-SUMMARY pairs=1 unequal=0`.
- [ ] [P7-T3] Documentation contract tests: `poetry run pytest -v tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py tests/scripts/dev_tools/test_orchestrator_state_remediation_docs.py`. Write FEATURE/evidence/qa-gates/orchestrate-doc-contracts.TS.md. Acceptance: every node prints PASSED, or every FAILED node is a member of the P0-T30 baseline failure set.
- [ ] [P7-T4] Write T-CONS per Appendix C, C14, with its file list taken from Appendix F groups PROD-ALL and TESTS-ALL plus every suite listed in FEATURE/evidence/other/edited-suites-850.md. Acceptance: the Write succeeds without a hook denial.
- [ ] [P7-T5] Format check: A6 over T-CONS. Write FEATURE/evidence/qa-gates/format-p7.TS.md. Acceptance: `FORMAT-SUMMARY ChangedCount=0`.
- [ ] [P7-T6] Analyze: A7 over T-CONS. Write FEATURE/evidence/qa-gates/analyze-p7.TS.md. Acceptance: `PSSA-SUMMARY DiagnosticCount=0`.
- [ ] [P7-T7] Run T-CONS: A2 with `-Path tests/scripts/claude-hooks/session-root-reads-850.Constraints.Tests.ps1`. Write FEATURE/evidence/qa-gates/constraints-850.TS.md. Acceptance: `TotalCount=2`, `PassedCount=2`, `FailedCount=0`, and no `FAILED-CONTAINER:` line (rule CC).
- [ ] [P7-T8] Check off AC-44 (274) and AC-45 (275); A14 with `-Line 274,275`; append to FEATURE/evidence/other/ac-checkoff.md. Acceptance: `CHECKBOX checked=41 unchecked=6` and both lines `state=checked`.
- [ ] [P7-T9] Commit and push Phase 7. Commands: CMD-GIT-ADD with SKILL, its mirror, T-CONS, FEATURE/spec.md, the FEATURE evidence directory, and PLAN; CMD-GIT-COMMIT with message "docs(850): state the absolute body path for out-of-worktree pr-author calls and add the constraints suite"; CMD-GIT-PUSH. Acceptance: CMD-GIT-STATUS prints nothing and the push exits 0.

### Phase 8 — Final QA Loop

If any Phase 8 step fails or changes a tracked file, fix the cause, re-mirror any changed `.claude` file with `cp`, and restart from P8-T1. When a coverage task reports a file below 85, add rows targeting that file's `MISSED` lines to the new suite of the same component (T-PRA-IAR, T-MRG-IR, T-EREM-DX, T-WIR-PR, or the parallel WorktreeResolution suite), update the expected TotalCount growth in the affected tasks by the number of rows added, record the additions in FEATURE/evidence/other/edited-suites-850.md, and restart from P8-T1.

- [ ] [P8-T1] Format. Commands, in order: A5 over Appendix F group FINAL-PS (before hashes, saved in the artifact); MCP-PS-FORMAT with scan_folders `.claude/hooks`, `.claude/lib/worktree-resolution`, `tests/scripts/claude-hooks`, `tests/scripts/claude-lib/worktree-resolution`, `tests/scripts/claude-lib/orchestrator-state`; A5 over FINAL-PS (after hashes); CMD-GIT-STATUS; A6 over FINAL-PS. Write FEATURE/evidence/qa-gates/powershell-format.TS.md. Acceptance: the MCP call returns without raising; every before and after `Hash=` value is unchanged for every FINAL-PS file, so the formatter formatted nothing; every CMD-GIT-STATUS line names a FEATURE evidence path, FEATURE/spec.md, PLAN, a FINAL-PS file, or the CB mirror of a PROD-ALL file (PLAN appears on every pass; the last two appear only on a restart, from a Phase 8 fix or a coverage-clause row; FEATURE/spec.md only on a restart after P8-T20), and any other line stops the plan; A6 prints `FORMAT-SUMMARY ChangedCount=0`.
- [ ] [P8-T2] Analyze. Commands: MCP-PS-ANALYZE with the P8-T1 scan_folders; A7 over FINAL-PS. Write FEATURE/evidence/qa-gates/powershell-analyze.TS.md. Acceptance: the MCP call returns and A7 prints `PSSA-SUMMARY DiagnosticCount=0`.
- [ ] [P8-T3] Policy-mandated MCP test step. Command: MCP-PS-TEST. Write FEATURE/evidence/qa-gates/powershell-mcp-test.TS.md. Acceptance: the call returns without raising; the artifact records the disposition and states that counts and coverage come from P8-T4 through P8-T13, because the MCP result carries no test output.
- [ ] [P8-T4] Coverage CG-PRA final (A3 with the CG-PRA final lists, `-CoverageOutputPath SCRATCH/cov-pra-final.xml -ReportPath SCRATCH/cov-pra-final.txt`). Write FEATURE/evidence/qa-gates/coverage-pra.TS.md. Acceptance: every `FAILED:` line is a member of the P0-T25 baseline failure set; every `FAILED-CONTAINER:` line is a member of the P0-T25 baseline container set (rule CC); no `FAILED:` line ends with `allows gh pr create --body-file artifacts/pr_body_12.md when context exists` (rule EE does not apply at final QC); the `COVERAGE file=` lines for PRA, PRAH, and PRAR each carry a numeric `LinePercent=` of at least 85 (an `NA` value fails).
- [ ] [P8-T5] Coverage CG-MRG final (report SCRATCH/cov-mrg-final.txt). Write FEATURE/evidence/qa-gates/coverage-mrg.TS.md. Acceptance: every `FAILED:` line is a member of the P0-T26 baseline failure set; every `FAILED-CONTAINER:` line is a member of the P0-T26 baseline container set (rule CC); MRG and MRGR each numeric and at least 85.
- [ ] [P8-T6] Coverage CG-EREM final (report SCRATCH/cov-erem-final.txt). Write FEATURE/evidence/qa-gates/coverage-erem.TS.md. Acceptance: every `FAILED:` line is a member of the P0-T27 baseline failure set; every `FAILED-CONTAINER:` line is a member of the P0-T27 baseline container set (rule CC); EREM and EREMR each numeric and at least 85.
- [ ] [P8-T7] Coverage CG-PREM final (report SCRATCH/cov-prem-final.txt). Write FEATURE/evidence/qa-gates/coverage-prem.TS.md. Acceptance: every `FAILED:` line is a member of the P0-T28 baseline failure set; every `FAILED-CONTAINER:` line is a member of the P0-T28 baseline container set (rule CC); PREM numeric and at least 85.
- [ ] [P8-T8] Coverage CG-LIB final (report SCRATCH/cov-lib-final.txt). Write FEATURE/evidence/qa-gates/coverage-lib.TS.md. Acceptance: every `FAILED:` line is a member of the P0-T29 baseline failure set; every `FAILED-CONTAINER:` line is a member of the P0-T29 baseline container set (rule CC); WRR and WIR each numeric and at least 85.
- [ ] [P8-T9] Changed-line coverage against BASE_SHA. Commands: A11 once per coverage group with `-CoverageReportPath SCRATCH/cov-<group>-final.txt -BaseRef BASE_SHA -File <the group's production files>` (BASE_SHA replaced by the recorded commit). Write FEATURE/evidence/qa-gates/changed-line-coverage.TS.md. Acceptance: ten `CHANGED-COVERAGE file=` lines (PRA, PRAH, PRAR, MRG, MRGR, EREM, EREMR, PREM, WRR, WIR), none `MISSING`, each with a numeric `ChangedPercent=` of at least 85.
- [ ] [P8-T10] Regression over `tests/scripts/claude-hooks` (A2). Write FEATURE/evidence/qa-gates/pester-claude-hooks.TS.md. Acceptance: `TotalCount=` equals BASE_HOOKS plus 45 plus any rows added under the Phase 8 coverage clause, and every `FAILED:` line is a member of the P0-T21 baseline failure set; every `FAILED-CONTAINER:` line is a member of the P0-T21 baseline container set (rule CC); no `FAILED:` line ends with `allows gh pr create --body-file artifacts/pr_body_12.md when context exists` (rule EE does not apply at final QC).
- [ ] [P8-T11] Regression over `tests/scripts/claude-lib` (A2). Write FEATURE/evidence/qa-gates/pester-claude-lib.TS.md. Acceptance: `TotalCount=` equals BASE_CLIB plus 12 plus any rows added under the Phase 8 coverage clause, and every `FAILED:` line is a member of the P0-T22 baseline failure set; every `FAILED-CONTAINER:` line is a member of the P0-T22 baseline container set (rule CC) (AC-41: `WorktreeResolution.Manifest.Tests.ps1` passes).
- [ ] [P8-T12] Regression over `tests/scripts/claude-runtime` (A2). Write FEATURE/evidence/qa-gates/pester-claude-runtime.TS.md. Acceptance: `TotalCount=` equals BASE_RT and every `FAILED:` line is a member of the P0-T23 baseline failure set; every `FAILED-CONTAINER:` line is a member of the P0-T23 baseline container set (rule CC); no `FAILED:` or `FAILED-CONTAINER:` line names `enforcement-hooks-no-python-invocation.Tests.ps1` (AC-43).
- [ ] [P8-T13] Regression over `tests/scripts/codex-hooks` (A2). Write FEATURE/evidence/qa-gates/pester-codex-hooks.TS.md. Acceptance: `TotalCount=` equals BASE_CODEX and every `FAILED:` line is a member of the P0-T24 baseline failure set; every `FAILED-CONTAINER:` line is a member of the P0-T24 baseline container set (rule CC).
- [ ] [P8-T14] Line caps. Command: A4 over FINAL-PS. Write FEATURE/evidence/qa-gates/line-counts-final.TS.md. Acceptance: every `LineCount=` value is at most 500.
- [ ] [P8-T15] Added-lines scan of the edited suites (AC-45, D9). Command: CMD-PS-SCRIPT with A13, `-BaseRef BASE_SHA -Token TestDrive,GetTempPath,GetTempFileName,New-TemporaryFile -Pattern '[A-Za-z]:\\Users\\','[A-Za-z]:/Users/','/home/[a-z]' -File <EDITED-TESTS plus every suite listed in FEATURE/evidence/other/edited-suites-850.md, comma-separated>`. Write FEATURE/evidence/qa-gates/added-lines-scan.TS.md. Acceptance: the output ends with `ADDED-TOKEN-SUMMARY count=0`.
- [ ] [P8-T16] Python parity and contracts. Command: CMD-PY-PARITY-EXT. Write FEATURE/evidence/qa-gates/python-parity.TS.md. Acceptance: every node other than the KL-510 node is PASSED or a member of BASE_PY; the KL-510 node satisfies KL-510 (AC-39); `test_push_down_claude_pack_manifest_completeness.py` nodes are PASSED (AC-40); `test_push_down_codex_and_agents_resource_contracts.py` nodes are PASSED (AC-42).
- [ ] [P8-T17] Scope checks. Commands: `git diff --name-only BASE_SHA -- .codex extensions/drm-copilot/resources/codex-and-agents-customizations .claude/rules`; `git status --porcelain -- .codex extensions/drm-copilot/resources/codex-and-agents-customizations .claude/rules`; `git diff --name-only BASE_SHA -- "*.py"`; `git status --porcelain -- "*.py"`; `git diff --exit-code BASE_SHA -- .claude/hooks/enforce-epic-merge-gate-authorization.ps1 .claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1 .claude/lib/worktree-resolution/EpicScopeResolution.psm1 .claude/lib/worktree-resolution/WorktreeResolution.psm1 .claude/lib/worktree-resolution/WorktreeTargetResolution.psm1 .claude/hooks/hook-command-invocation.ps1 .claude/hooks/hook-command-invocation-operands.ps1`. Write FEATURE/evidence/qa-gates/scope-checks.TS.md. Acceptance: both name-only diffs and both status commands print nothing; the final diff exits 0 with no output (AC-42 and D4).
- [ ] [P8-T18] Final mirror check. Command: A10 over Appendix F group MP-ALL. Write FEATURE/evidence/qa-gates/mirror-hashes-final.TS.md. Acceptance: `PAIR-SUMMARY pairs=14 unequal=0` (AC-39 supplemental, independent of KL-510).
- [ ] [P8-T19] Coverage comparison. Write FEATURE/evidence/qa-gates/coverage-comparison.TS.md from the P0-T25 through P0-T29 and P8-T4 through P8-T9 artifacts. Acceptance: the artifact carries `Baseline Coverage:` (each existing file's BASEPCT), `Post-Change Coverage:` (each P8 value, including PRAR), `New/Changed-code Coverage:` (the ten `ChangedPercent=` values), and `Disposition:`; every value is numeric; `Disposition:` is `PASS` only when every post-change value and every changed-code value is at least 85, otherwise `BLOCKED`. The artifact states that no Python or TypeScript file is changed.
- [ ] [P8-T20] Check off AC-39 (266), AC-40 (267), AC-41 (268), AC-42 (269), AC-43 (273), AC-46 (276); A14 with `-Line 266,267,268,269,273,276`; append to FEATURE/evidence/other/ac-checkoff.md. Acceptance: `CHECKBOX checked=47 unchecked=0` and all six lines `state=checked`. A criterion whose cited evidence did not pass stays unchecked and the plan outcome is remediation-required.
- [ ] [P8-T21] Acceptance-criteria status summary. Command: CMD-PS-SCRIPT with A14, `-Path FEATURE/spec.md -FromLine 204 -Line <every Appendix I line, comma-separated>`. Write FEATURE/evidence/other/ac-status-summary.TS.md with one row per criterion (AC ID, spec line, `state=` value from A14, verifying test name and suite, evidence artifact path). Acceptance: A14 prints `CHECKBOX checked=47 unchecked=0` and 47 `LINE` lines, each `state=checked`; the summary has 47 rows.
- [ ] [P8-T22] Commit and push the final QA evidence. Commands: CMD-GIT-STATUS; CMD-GIT-ADD with FEATURE/spec.md, the FEATURE evidence directory, PLAN, and every other path the status check listed (fixes from Phase 8 restarts and their mirrors); CMD-GIT-COMMIT with message "docs(850): record final QA evidence and acceptance-criteria status"; CMD-GIT-PUSH. Acceptance: CMD-GIT-STATUS prints nothing after the commit and the push exits 0.

---

## Appendix A — Staged Write Log

The SW procedure (LH-2) records each live-file write in WLOG (Appendix J). Live files are written in this order across the plan: WRR (P1), PREM (P2), EREMR then EREM (P3), WIR (P4), MRGR then MRG (P5), PRAR then PRAH then PRA (P6).

## Appendix B — Implementation Specifications

Edits are located by function name and anchor text. Line numbers are planning-time references re-derived by P0-T12.

### B1 — WRR (in place, zero net lines)

- In the comment that precedes `function Test-WorktreeRunPathEqual`, replace the words "case-insensitive only for drive-letter paths" with "case-insensitive for drive-letter and UNC (//) paths", keeping two comment lines.
- Replace the anchor line `$isDrivePath = ($a -match '^[A-Za-z]:') -or ($b -match '^[A-Za-z]:')` with `$isCaseInsensitivePath = ($a -match '^([A-Za-z]:|//)') -or ($b -match '^([A-Za-z]:|//)')`, and the following line's `if ($isDrivePath)` with `if ($isCaseInsensitivePath)`.
- No other line changes; the export list is unchanged; the file stays at 497 lines.

### B2 — PREM (CR-5, zero net lines)

In `Get-ParallelWorktreeRemovalTargetDenial` (the C1a per-target function, PREM 338-411 at BASE_SHA, called once per derived target by the loop in `Invoke-ParallelWorktreeRemovalGateDecision` at 329-334; D14), at the final deny (prefix anchor line 408, return anchor line 410): the prefix assignment becomes `$prefix = "$($parallelRead.Target.ReasonCode): $($parallelRead.Target.Detail). "` (no token), and the return becomes `return Get-ParallelWorktreeGateBlockDecision -Reason ('PARALLEL_WORKTREE_REMOVAL_BLOCKED: ' + $prefix + "git worktree remove for '$worktreePath' requires a matching parallel checkpoint items[] record with merge_status in {merged, worktree_removed}. The checkpoint was unreadable, no matching record was found, or merge_status was not yet safe for removal.")`. With a resolved target the prefix is empty and the text is byte-identical to the pre-change text. `Invoke-ParallelWorktreeRemovalGateDecision` is not changed; each derived target's denial is built by its own call, so the single-token rule holds for every target.

### B3 — EREMR (written before EREM)

- `Read-EpicWorktreeGateRunCheckpoint` returns `[pscustomobject]@{ Target = $target; Checkpoint = $checkpoint; Path = $path }`, where `$path` is `$null` when the target is unresolved and the composed absolute path otherwise. Update its `.OUTPUTS` help.
- New pure function `Find-EpicWorktreeGateParallelItemRecord -Checkpoint -WorktreePath`: returns the first `items[]` entry whose `worktree_path`, normalized exactly as `Test-ParallelCheckpointAllowsWorktreeRemoval` normalizes it (backslash to slash, trailing slash trimmed, PowerShell `-eq`), equals the normalized target; `$null` for a `$null` checkpoint, a blank target, a checkpoint without `items`, or no match.
- New pure function `Get-EpicWorktreeGateDenyDiagnostics -EpicRead -ParallelRead -WorktreePath` returning the clause of B4. It reads no file; it calls `Find-EpicWorktreeFeatureRecord` (gate file, resolved at call time) and `Find-EpicWorktreeGateParallelItemRecord`.
- Update the `.DESCRIPTION` list to name the two new functions and the `Path` property (issue #851).

### B4 — EREM (written after EREMR)

- Final deny in `Get-EpicWorktreeRemovalTargetDenial` (the C1a per-target function, EREM 337-399 at BASE_SHA, prefix anchor line 396, return anchor line 398; called once per derived target by the loop in `Invoke-EpicWorktreeRemovalGateDecision` at 328-333, which is not changed; D14). `$epicRead`, `$parallelRead`, and `$worktreePath` are that function's locals for the target under evaluation, so the diagnostics clause describes the target whose denial is returned: `$prefix = "$($epicRead.Target.ReasonCode): $($epicRead.Target.Detail). "` when both kinds are `NoTarget` (no token); `$diagnostics = Get-EpicWorktreeGateDenyDiagnostics -EpicRead $epicRead -ParallelRead $parallelRead -WorktreePath $worktreePath`; `return Get-EpicWorktreeGateBlockDecision -Reason ('EPIC_WORKTREE_REMOVAL_BLOCKED: ' + $prefix + "git worktree remove for '$worktreePath' requires either an epic checkpoint features[] record with merge_status in {merged, worktree_removed}, or a parallel-orchestrator checkpoint with route_id == ""parallel"" whose matching items[] record (matched by worktree_path) has merge_status in {merged, worktree_removed}. No checkpoint authorized this removal. " + $diagnostics)`. No allow or earlier deny changes.
- Diagnostics clause format (D6), exactly: `Diagnostics: epic run <EpicStatus> (<EpicPath>), <EpicRecord>; parallel run <ParallelStatus> (<ParallelPath>), <ParallelRecord>.` where `<Status>` is the target's `Status`; `<Path>` is `checkpoint '<Path>'` when the read's `Path` is not `$null`, otherwise `no checkpoint read`; `<Record>` is `not evaluated` when `Path` is `$null`, `checkpoint absent or unparseable` when `Path` is set and `Checkpoint` is `$null`, `merge_status '<value>'` when a matching record exists and carries `merge_status`, `merge_status absent` when the matching record has no `merge_status`, and `no matching features[] record` (epic) or `no matching items[] record` (parallel) otherwise.
- Header `.DESCRIPTION`: one sentence stating that the final deny carries one leading token and a diagnostics clause (issues #789, #851), and that the decision is unchanged.

### B5 — WIR

- New exported function `Resolve-WorktreeItemTargetByPrNumber -PrNumber [long] (Mandatory) -SessionRoot [string] (Mandatory, AllowEmptyString)`: the session is `$SessionRoot`, or `(Get-Location).ProviderPath` when blank. A `PrNumber` of zero or less returns `NoTarget`. Otherwise assign `$liveRoots = Get-WorktreeItemLiveRoot -SessionRoot $session` before wrapping (the seam returns its array as one object), and for each root read `Get-WorktreeItemCheckpointText -Path (Get-WorktreeItemCheckpointPath -WorktreeRoot $root)` and keep the root when the private predicate matches. Zero matches: `New-WorktreeResolutionTargetResult -Status 'NoTarget' -SessionRoot $session -Detail ("pull request {0} is recorded in pr_gate.pr_number or a standalone_merge_authorizations entry of no live worktree's orchestrator checkpoint" -f $PrNumber)`. One match: `ConvertTo-WorktreeItemResolvedResult -WorktreeRoot $matched[0] -SessionRoot $session -Detail ("pull request {0} resolves to the live worktree whose orchestrator checkpoint records it" -f $PrNumber)`. Several: `New-WorktreeResolutionTargetResult -Status 'Ambiguous' -SessionRoot $session -Candidate $matched.ToArray() -Detail ("pull request {0} is recorded in the orchestrator checkpoints of {1} live worktrees; move the stale checkpoint to artifacts/orchestration/handoff/ so that one worktree records it" -f $PrNumber, $matched.Count)`. No tie-breaking. No detail names an absolute path.
- New private function `Test-WorktreeItemCheckpointRecordsPr -Text -PrNumber`: `$false` for blank text, a parse failure, or a non-object payload; `$true` when `pr_gate.pr_number` parses with `[long]::TryParse([string]...)` and equals `PrNumber`; `$true` when any `standalone_merge_authorizations` entry has a `pr_number` that is `[int]` or `[long]`, greater than zero, and equal to `PrNumber`; `$false` otherwise. It performs no read.
- Append `Resolve-WorktreeItemTargetByPrNumber` to `Export-ModuleMember -Function` (ten exports). Update `.NOTES` to say the module still has one filesystem read, the checkpoint-text seam. Strict mode and `$ErrorActionPreference = 'Stop'` stay.

### B6 — MRGR (written before MRG)

- Import guard: keep the existing `try` for WRR; add a second `try { Import-Module (Join-Path $PSScriptRoot '../lib/worktree-resolution/WorktreeItemResolution.psm1') -Force -ErrorAction Stop } catch { $script:EpicMergeGateResolutionImportFailure = 'WorktreeItemResolution.psm1' }` after it, guarded so that a WRR failure already recorded is not overwritten (`if (-not $script:EpicMergeGateResolutionImportFailure)` around the assignment).
- New seam `Resolve-EpicMergeGateItemTarget -PrNumber [int] (Mandatory)`: `return Resolve-WorktreeItemTargetByPrNumber -PrNumber $PrNumber -SessionRoot (Get-Location).Path`.
- `Test-ChildCheckpointPrGateBinding -Checkpoint -CommandPrNumber` (same name, same file, pure): `$true` when `CommandPrNumber` is `$null`; `$false` when `Checkpoint` is `$null`; when `pr_gate.pr_number` is present and not `$null`, the result of `[int]::TryParse` and equality (unparseable gives `$false`); otherwise `$true` only when a `standalone_merge_authorizations` entry has `Test-StandalonePositiveJsonInteger -Value $entry.pr_number` true and `[long]$entry.pr_number -eq $CommandPrNumber`; otherwise `$false`. Update its synopsis and description (issue #788).
- `Get-EpicMergeGateUnresolvedReason -ItemTarget -EpicTarget -ParallelTarget` (all `AllowNull`): `$null` when any is `$null` or any has a status outside `NoTarget`/`Ambiguous`; otherwise the code is the `ReasonCode` of the first `Ambiguous` among item, epic, parallel, else the item's `ReasonCode`; returns `'{0}: {1}; {2}; {3}' -f $code, $ItemTarget.Detail, $EpicTarget.Detail, $ParallelTarget.Detail`.
- Update the file `.DESCRIPTION` list (WIR import, the item seam, the binding rule).

### B7 — MRG (written after MRGR)

- In `Invoke-EpicMergeGateDecision`, replace the unconditional child read anchored by `$childCheckpoint = ConvertFrom-EpicMergeGateJson -Raw (Get-ChildOrchestratorCheckpointContent -Path (Get-WorktreeRunCheckpointPath -Kind item -WorktreeRoot $sessionRoot))` with: `$itemTarget = $null`; `$childRoot = $sessionRoot`; when `$commandPrNumber` is not `$null`, `$itemTarget = Resolve-EpicMergeGateItemTarget -PrNumber $commandPrNumber` and `$childRoot` is `$itemTarget.WorktreeRoot` for `SessionRoot`/`OtherWorktree`, else `$null`; `$childCheckpoint` is the parsed read beneath `$childRoot` when it is set, else `$null`. The binding call and the child allow are unchanged.
- The unresolved-reason call becomes `Get-EpicMergeGateUnresolvedReason -ItemTarget $itemTarget -EpicTarget $epicTarget -ParallelTarget $parallelTarget`.
- Update the comment above the child read and the `Issue #690` paragraph of the header to state that, with an explicit number, the per-feature checkpoint is read beneath the live worktree whose checkpoint records the number in `pr_gate.pr_number` or a standalone record (issue #850), and that a bare command reads the session worktree.

### B8 — PRAR (new; dot-sourced by PRAH; written first)

Comment-based header naming issue #850 and its role. Functions:

- No operand reader is defined in PRAR (D12): the `--body-file` value comes from C1a's `Get-PrAuthorBodyFileValue` in PRAH (as changed by B9), which reads it with `Get-CommandLineFlagValue` from HCIO.
- `Test-PrAuthorBodyPathEqual -Left -Right`: normalize both with `ConvertTo-WorktreeResolutionNormalizedPath`; `$false` when either is `$null`; `OrdinalIgnoreCase` when either matches `^([A-Za-z]:|//)`, `Ordinal` otherwise.
- `Get-PrAuthorEpicArtifactRoot -CheckpointPath`: the suffix is `'/' + (Get-EpicScopeCheckpointRelativePath)`; when the normalized path ends with the suffix (ordinal), return the prefix; otherwise `$null`.
- `Resolve-PrAuthorArtifactRoot -CommandText`: call `Resolve-EpicScopeCheckpoint -Text $CommandText -SessionRoot (Get-Location).Path` once. Epic scope: root from `Get-PrAuthorEpicArtifactRoot`; a `$null` root returns `Reason = "ORCHESTRATOR_STATE_PREFLIGHT_FAILED: the epic checkpoint path '<path>' does not end with '<relative path>', so the worktree that holds it cannot be derived."`; otherwise `ArtifactRoot`, `CheckpointPath = $epicScope.CheckpointPath`, `EpicScope = $epicScope`, `Status = 'Epic'`, `RelativeBodyAllowed = (Test-PrAuthorBodyPathEqual -Left <root> -Right $epicScope.WorktreeRoot)`. Otherwise call `Get-PrAuthorTargetCheckpointResolution -CommandText` once; a `Reason` is returned unchanged; else `ArtifactRoot = $resolution.WorktreeRoot` (normalized), `CheckpointPath`, `EpicScope = $null`, `Status`, `RelativeBodyAllowed = ($resolution.Status -eq 'SessionRoot')`. Returns an ordered dictionary with `Reason`, `ArtifactRoot`, `CheckpointPath`, `EpicScope`, `Status`, `RelativeBodyAllowed`.
- `Get-PrAuthorBodyPathBindingReason -CommandText -ArtifactRoot -RelativeBodyAllowed`: reads the value once with `Get-PrAuthorBodyFileValue -CommandText $CommandText`, then applies the D5 rules (a `$null` value takes the generic deny); returns an ordered dictionary with `Reason` and `BodyNumber`. Relative value with `RelativeBodyAllowed` false: `"PR_BODY_PATH_NONCANONICAL: the target worktree '<root>' is not the session worktree, so gh would read a relative --body-file from the session worktree. Pass the absolute canonical path '<root>/artifacts/pr_body_<N>.md'."`. Any other non-canonical value: `"PR_BODY_PATH_NONCANONICAL: ``--body-file`` must reference the canonical ``artifacts/pr_body_<N>.md`` file produced by the pr-author skill beneath the target worktree '<root>' (relative only when that worktree is the session worktree). The path supplied does not match."`.

No reason-code literal of the worktree-resolution module appears in PRAR.

### B9 — PRAH (written after PRAR)

- After the module imports, dot-source PRAR: `. (Join-Path $PSScriptRoot 'enforce-pr-author-skill.artifact-root.ps1')`.
- Header: replace the sentence stating that `$script:PrContextArtifactPath` "is a process-directory-relative artifact path and stays one" with a statement that it is the repository-relative literal used in messages and as the composition input, and that every artifact read is composed beneath the root `Resolve-PrAuthorArtifactRoot` selects (issue #850).
- `Get-PrAuthorTargetCheckpointResolution` returns `CheckpointPath`, `Reason`, `WorktreeRoot`, and `Status` (resolved: the target's root and status; unresolved: `$null` root and the target's status). Update `.OUTPUTS`.
- Remove the C1a seam `Get-PrAuthorBodyFileRoot` (PRAH 123-138 at BASE_SHA) in full (D12). In `Get-PrAuthorBodyFileValue` (140-176), remove the `if ([System.IO.Path]::IsPathRooted($value))` block that calls `[System.IO.Path]::GetRelativePath((Get-PrAuthorBodyFileRoot), $value)` (168-170), so a rooted value is returned absolute; keep the subcommand selection, the `Get-CommandLineFlagValue` read, the `$null` return, the backslash conversion, and the single leading `./` strip unchanged. Its `.DESCRIPTION` states that a rooted value is returned as written (separators normalized) and is bound to the resolved worktree by `Get-PrAuthorBodyPathBindingReason` in PRAR (issue #850).
- `Test-PrAuthorReceiptVerification` gains `[Parameter(Mandatory)][string] $ArtifactRoot` and `[bool] $RelativeBodyAllowed`. The whole Check 1 block (from the `# Check 1:` anchor up to the line before `# Check 2:`) is replaced by `$binding = Get-PrAuthorBodyPathBindingReason -CommandText $CommandText -ArtifactRoot $ArtifactRoot -RelativeBodyAllowed $RelativeBodyAllowed`, an early return of `$binding.Reason`, and `$bodyNumber = $binding.BodyNumber`. Body, receipt, and summary paths are composed with `Join-WorktreeResolutionPath -WorktreeRoot $ArtifactRoot`; Check 5 calls `Get-PrContextSummaryLastWriteUtc -Path <summary path>`. Message texts keep their leading tokens.
- `Get-PrAuthorBypassReason -CommandText` (the `-ContextExists` parameter is removed): Cases A, B and the `gh pr edit` no-body allow are unchanged and perform no resolution. Then `$artifact = Resolve-PrAuthorArtifactRoot -CommandText $CommandText` once; return `$artifact.Reason` when set; Case C: `if (-not (Get-PrContextArtifactExistence -Path <summary path beneath $artifact.ArtifactRoot>))` return `"PR_CONTEXT_MISSING: '$script:PrContextArtifactPath' in worktree '$($artifact.ArtifactRoot)' is absent. Run ``mcp__drm-copilot__collect_pr_context`` in that worktree before creating or editing the PR body."`; epic scope runs the existing readiness predicate on `$artifact.EpicScope` and assigns `$script:OrchestratorStateCheckpointPath = $artifact.CheckpointPath`; otherwise assign it and run the existing preflight unchanged; finally call `Test-PrAuthorReceiptVerification -CommandText $CommandText -CheckpointPath $script:OrchestratorStateCheckpointPath -EpicScope $artifact.EpicScope -ArtifactRoot $artifact.ArtifactRoot -RelativeBodyAllowed $artifact.RelativeBodyAllowed`. Update the help text (deny precedence: resolution reason, `PR_CONTEXT_MISSING`, `ORCHESTRATOR_STATE_PREFLIGHT_FAILED`, Checks 1-6).

### B10 — PRA (written after PRAH)

- `Get-PrContextArtifactExistence` and `Get-PrContextSummaryLastWriteUtc` gain `[Parameter(Mandatory)][string] $Path` and read `$Path` instead of `$script:PrContextArtifactPath`; update their help. `Get-PrBodyFileBytes` and `Get-PrAuthorReceiptContent` keep their signatures; their help states the path is absolute beneath the resolved worktree.
- `Invoke-PrAuthorSkillDecision`: remove the line `$contextExists = Get-PrContextArtifactExistence`; the call becomes `Get-PrAuthorBypassReason -CommandText $commandText`.
- `Test-PrAuthorBypassRequired -CommandText`: remove the `ContextExists` parameter and its help; call `Get-PrAuthorBypassReason -CommandText $CommandText`.
- Header: Case C reads "context artifact absent beneath the resolved worktree"; add one paragraph stating that the summary, body, and receipt are read beneath the worktree the call resolves to (issue #850).

## Appendix C — Test Specifications

All rows follow Arrange-Act-Assert, use synthetic roots of the form `/synthetic-worktrees/<name>` or committed fixtures, create no file, read no wall clock, and take both reason codes from `Get-WorktreeResolutionNoTargetReasonCode` and `Get-WorktreeResolutionAmbiguityReasonCode`. `It` names below are exact.

### C1 — B14 (Record suite)

`It 'B14 compares UNC paths case-insensitively'`: `Set-RecordTopology -Live @('/synthetic-worktrees/w-par') -Parallel @{ '/synthetic-worktrees/w-par' = '{"route_id":"parallel","items":[{"worktree_path":"//Server/Share/x"}]}' }`; act `Resolve-WorktreeRunTargetByRecord -Kind parallel -RecordField worktree_path -Value '//server/share/X' -SessionRoot $script:Session`; assert `Status` is `OtherWorktree`.

### C2 — Y7 (parallel WorktreeResolution suite)

`It 'Y7 emits a single leading token when both run kinds are unresolved'`: arrange as Y3 (`Set-RemovalRunTopology -Live @('/synthetic-worktrees/w-par')`, both read seams `$null`); assert the reason starts with `PARALLEL_WORKTREE_REMOVAL_BLOCKED: ` and `([regex]::Matches($reason, 'PARALLEL_WORKTREE_REMOVAL_BLOCKED:')).Count` is 1.

### C3 — T-EREM-DX (8 tests)

Outermost `BeforeAll`: dot-source EREM; import WRR, WTR, WR (no `-Force`); dot-source `WorktreeResolutionFixture.Helpers.ps1`; helper `Set-RemovalReadSeam` as in `enforce-epic-worktree-removal-gate.WorktreeResolution.Tests.ps1`, mocking `Get-EpicWorktreeGateCheckpointContent` and `Get-EpicWorktreeGateParallelCheckpointContent`; helper `Set-RunTargetSeam -Epic <target> -Parallel <target>` that mocks `Resolve-EpicWorktreeGateRunTarget` twice with `-ParameterFilter { $Kind -eq 'epic' }` and `{ $Kind -eq 'parallel' }`, each built with `New-WorktreeResolutionFixtureTarget` and `.GetNewClosure()`. The rows mock the resolution seam rather than run the record resolver, because the resolver resolves a kind only when its checkpoint records the target, while the "no record matched" and "unparseable" outcomes arise when the gate's second read differs from the resolver's first (research section 5.3). `BeforeEach`: `Mock Test-CleanupWorktreeManifestAuthorizesRemoval { $false }`. Target `/wt/item-a`.

1. `emits a single leading token when both run kinds are unresolved` — both kinds `NoTarget`, both read seams `$null`; assert the reason starts with `EPIC_WORKTREE_REMOVAL_BLOCKED: ` and `([regex]::Matches($reason, 'EPIC_WORKTREE_REMOVAL_BLOCKED:')).Count` is 1.
2. `names each run kind's status and checkpoint path` — epic `OtherWorktree` at `/synthetic-worktrees/w-epic`, parallel `OtherWorktree` at `/synthetic-worktrees/w-par`; the epic seam returns `{"features":[{"worktree_path":"/wt/item-a","merge_status":"pr_open"}]}` and the parallel seam returns `{"route_id":"parallel","items":[]}`; assert deny and that the reason contains `epic run OtherWorktree (checkpoint '/synthetic-worktrees/w-epic/artifacts/orchestration/epic-orchestrator-state.json')` and `parallel run OtherWorktree (checkpoint '/synthetic-worktrees/w-par/artifacts/orchestration/parallel-orchestrator-state.json')`.
3. `names the matched record merge_status` — as row 2; assert the reason contains `merge_status 'pr_open'`.
4. `states that no record matched` — as row 2; assert the reason contains `no matching items[] record`.
5. `states that the checkpoint was absent or unparseable` — epic `OtherWorktree` at `/synthetic-worktrees/w-epic` with the epic seam returning `{ broken json`; parallel `NoTarget`; assert the reason contains `checkpoint absent or unparseable` and `parallel run NoTarget (no checkpoint read), not evaluated`.
Context `diagnostics builder and read result`:
6. `returns the checkpoint path it read on the read result` — mock `Resolve-EpicWorktreeGateRunTarget` to `OtherWorktree` at `/synthetic-worktrees/w-epic` (`New-WorktreeResolutionFixtureTarget`); `Read-EpicWorktreeGateRunCheckpoint -Kind epic -WorktreePath '/wt/item-a'`; assert `Path` equals the composed epic path.
7. `returns a null path when the target is unresolved` — mock the seam to `NoTarget`; assert the result's property names contain `Path` and its value is `$null`.
8. `builds the clause without reading any file` — mock both read seams to throw; call `Get-EpicWorktreeGateDenyDiagnostics -WorktreePath '/wt/item-a'` with an epic read object (`Target` `OtherWorktree` at `/synthetic-worktrees/w-epic`, `Checkpoint` parsed from `{"features":[{"worktree_path":"/wt/item-a","merge_status":"merged"}]}`, `Path` `/synthetic-worktrees/w-epic/artifacts/orchestration/epic-orchestrator-state.json`) and a parallel read object (`Target` `NoTarget`, `Checkpoint` `$null`, `Path` `$null`); assert the result is exactly `Diagnostics: epic run OtherWorktree (checkpoint '/synthetic-worktrees/w-epic/artifacts/orchestration/epic-orchestrator-state.json'), merge_status 'merged'; parallel run NoTarget (no checkpoint read), not evaluated.` and both read seams `-Times 0 -Exactly`.

### C4 — Exact-text row (EREM Tests.ps1)

In row `emits the unchanged epic block reason`, after the line that assigns `$expected`, add exactly one line: `$expected += " Diagnostics: epic run SessionRoot (checkpoint '/synthetic-worktrees/default-session/artifacts/orchestration/epic-orchestrator-state.json'), no matching features[] record; parallel run SessionRoot (checkpoint '/synthetic-worktrees/default-session/artifacts/orchestration/parallel-orchestrator-state.json'), no matching items[] record."`. The literal follows from the B4 format and the enclosing `Describe`'s mocks (both targets `SessionRoot` at `/synthetic-worktrees/default-session`; epic `{"features":[]}`; parallel `{"route_id":"parallel","items":[]}`).

### C5 — T-WIR-PR (11 tests)

`BeforeAll`: import WIR (no `-Force`), WR, WTR; helper `Set-ItemPrTopology -Live <roots> -Text <hashtable root to JSON>` mocking `Get-WorktreeItemLiveRoot -ModuleName WorktreeItemResolution` (returning `, [string[]] $liveSet`) and `Get-WorktreeItemCheckpointText -ModuleName WorktreeItemResolution` keyed by `"$root/artifacts/orchestration/orchestrator-state.json"`. Session `/synthetic-worktrees/session`.

1. `resolves the worktree whose pr_gate records the pull request number` — `item-a` holds `{"pr_gate":{"pr_number":812}}`; assert `OtherWorktree` at `/synthetic-worktrees/item-a`.
2. `resolves the worktree whose standalone authorization records the pull request number` — `item-a` holds `{"standalone_merge_authorizations":[{"pr_number":812}]}`; assert `OtherWorktree` at `item-a`.
3. `returns NoTarget when no checkpoint records the number` — assert `NoTarget` and the no-target code.
4. `returns Ambiguous when several checkpoints record the number` — `item-a` (pr_gate) and `item-b` (standalone); assert `Ambiguous`, the ambiguity code, and two candidates.
5. `reads only through the checkpoint-text seam` — two live roots; assert `Get-WorktreeItemCheckpointText -ModuleName WorktreeItemResolution -Times 2 -Exactly`, and the parsed text of the two new functions contains none of `Get-Content`, `Test-Path`, `ReadAll`.
6. `exports the item-by-PR resolver` — the sorted export set equals the nine names exported at BASE_SHA (`ConvertTo-WorktreeItemIssueNumber`, `ConvertTo-WorktreeItemResolvedResult`, `Find-WorktreeItemIssueSignal`, `Get-WorktreeItemCheckpointIssue`, `Get-WorktreeItemCheckpointPath`, `Get-WorktreeItemCheckpointRelativePath`, `Get-WorktreeItemCheckpointText`, `Get-WorktreeItemLiveRoot`, `Resolve-WorktreeItemTarget`) plus `Resolve-WorktreeItemTargetByPrNumber`.
7. `ignores a standalone pr_number that is <Name>` -ForEach `string` (`"812"`), `zero` (`0`), `negative` (`-812`), `fractional` (`812.5`) — each the only record; assert `NoTarget` (4 tests).
8. `skips an absent, empty, or unparseable checkpoint` — three roots returning `$null`, `''`, `{ broken`; assert `NoTarget`.

### C6 — T-MRG-IR (19 tests)

`BeforeAll`: dot-source MRG; import WRR, WIR, WTR, WR (no `-Force`); dot-source the fixture helpers; `Mock Resolve-EpicMergeGateRunTarget` returning `NoTarget` (built with `New-WorktreeResolutionFixtureTarget` and `.GetNewClosure()`); `Mock Get-EpicMergeGateSessionWorktreeRoot { '/synthetic-worktrees/session' }`; helper `Set-ItemPrTopology` as C5 (module scope `WorktreeItemResolution`); helper `Set-MergeReadSeam` as the merge WorktreeResolution suite; a payload builder carrying `session_id` `session-850-merge`; a standalone record JSON for 812 bound to that session (fields as M9). Number N is 812.

1. `authorizes a standalone merge from the item worktree checkpoint` — item seam unmocked; topology: live `item-a` (standalone 812) and `session` (no record); `Get-ChildOrchestratorCheckpointContent` mocked with `-ParameterFilter` returning the record for the item-a path and `$null` otherwise; assert allow, `Should -Invoke Get-ChildOrchestratorCheckpointContent -Times 1 -Exactly` with the item-a path, and `-Times 0` with `/synthetic-worktrees/session/artifacts/orchestration/orchestrator-state.json`.
2. `does not authorize from a session-root copy of another worktree's checkpoint` — item seam unmocked; live `item-a` (`{"epic_mode":true,"step9_status":"passed","pr_gate":{"pr_number":812}}`, no standalone) and `session` (the standalone record for 812); `Get-ChildOrchestratorCheckpointContent` mocked with `-ParameterFilter` to return the item-a text for the item-a path and the standalone record for the session path; assert deny starting with `EPIC_MERGE_GATE_BLOCKED: ` followed by the ambiguity code.
3. `denies an unresolvable item target with the no-target code` — item seam unmocked; one live root holding `{}`; child read mocked to `$null`; assert deny starting `EPIC_MERGE_GATE_BLOCKED: `, containing the no-target code and the text `pull request 812 is recorded in pr_gate.pr_number`.
4. `denies an ambiguous item target with the ambiguity code` — mock the item seam to `Ambiguous`, run targets `NoTarget`; assert the reason starts with `EPIC_MERGE_GATE_BLOCKED: ` followed by the ambiguity code.
5. `observes module-scoped WorktreeItemResolution mocks` — item seam unmocked; one live root; assert `Should -Invoke Get-WorktreeItemCheckpointText -ModuleName WorktreeItemResolution -Times 1 -Exactly`.
6. `does not resolve an item target for a bare merge command` — `Mock Resolve-EpicMergeGateItemTarget { throw 'a bare command must not resolve an item target' }`; command `gh pr merge --merge`; assert `-Times 0` and the child read at the session path.
7. `denies a merge when no checkpoint records the pull request number` — item seam unmocked; live `item-a` holding `{"epic_mode":true,"step9_status":"passed"}`; `Get-ChildOrchestratorCheckpointContent` mocked to return that same text for every path (so a session-root read would allow through the unbound child branch); assert deny with the no-target code.
8. `denies a merge whose pull request number differs from pr_gate` — item seam mocked `OtherWorktree` at `item-a`; child read returns `{"epic_mode":true,"step9_status":"passed","pr_gate":{"pr_number":811}}`; assert the reason starts with `EPIC_MERGE_GATE_BLOCKED:`.
9. `re-checks the binding on the checkpoint the gate reads` — item seam mocked `OtherWorktree` at `item-a` (as if the resolver matched 812); child read returns `{"epic_mode":true,"step9_status":"passed"}`; assert deny.
10. `denies naming WorktreeItemResolution.psm1 when its import failed` — set `$script:EpicMergeGateResolutionImportFailure = 'WorktreeItemResolution.psm1'` inside `try`/`finally` restoring `$null`; assert deny naming the module.
Context `child checkpoint pull request binding` (direct calls to `Test-ChildCheckpointPrGateBinding`):
11. `returns true for a bare command` (`-CommandPrNumber $null`).
12. `returns false for a null checkpoint`.
13. `returns the pr_gate equality result` -ForEach `equal` (812, expects `$true`) and `different` (811, expects `$false`) (2 tests).
14. `returns true for a matching positive-integer standalone entry`.
15. `returns false for a standalone pr_number that is <Name>` -ForEach `string`, `zero`, `fractional` (3 tests).
16. `returns false when neither field records the number`.

### C7 — Merge WorktreeResolution suite edits

- In the outermost `BeforeAll`, add `Import-Module (Join-Path $libRoot 'WorktreeItemResolution.psm1')` (no `-Force`) after the existing WorktreeRunResolution import, and as the last statements `$itemNone = New-WorktreeResolutionFixtureTarget -Status 'NoTarget'` and `Mock -CommandName Resolve-EpicMergeGateItemTarget -MockWith { $itemNone }.GetNewClosure()`. With the item target unresolved by default, M1, M2, M6, M7, M8, and M10 keep their current assertions.
- M3 and M4: first Arrange line `$item = New-WorktreeResolutionFixtureTarget -Status 'OtherWorktree' -WorktreeRoot '/synthetic-worktrees/w-item'` and `Mock -CommandName Resolve-EpicMergeGateItemTarget -MockWith { $item }.GetNewClosure()`; assertions unchanged.
- M5 renamed `M5 denies a child merge whose checkpoint records neither pr_gate nor a standalone record for the number`: the item seam is mocked with a body that calls `Resolve-WorktreeItemTargetByPrNumber -PrNumber $PrNumber -SessionRoot '/synthetic-worktrees/session'`, with `Get-WorktreeItemLiveRoot` and `Get-WorktreeItemCheckpointText` mocked in module scope `WorktreeItemResolution` so `/synthetic-worktrees/w-item` holds `$script:ChildPassed`; assert deny, `^EPIC_MERGE_GATE_BLOCKED: `, and the no-target code.
- M9: the same `OtherWorktree` item mock as M3; assertions unchanged.
- Header: one sentence noting that the per-feature checkpoint is now read beneath the item target (issue #850) and that M5 records the #788 behavior change.

### C8 — Fixture README

Update the `pr-author/item-own-epic-mode` row and the paragraph that begins "`pr-author/item-own-epic-mode` deliberately carries no artifact files" to state that it now carries byte-identical copies of the three artifact files of `item-own-ready` (issue #850), because the pr-author gate reads PR artifacts beneath the resolved worktree; replace the sentence stating that the gate reads three paths relative to the process directory with a statement that it reads them beneath the resolved worktree.

### C9 — T-PRA-IAR (15 tests)

Outermost `BeforeAll` follows the isolation-guard pattern: dot-source PRA; `Import-Module` ESR without `-Force`; `Mock Get-EpicScopeCheckpointText -ModuleName EpicScopeResolution { $null }`; `Import-Module` WRR without `-Force`; `Mock Get-WorktreeRunCheckpointText -ModuleName WorktreeRunResolution { $null }`; import WIR, WR, WTR; dot-source `WorktreeResolutionFixture.Helpers.ps1`; fixture paths for `pr-author/session-root`, `item-own-ready`, `item-own-not-ready`; `Set-ResolvedSeam` as the pr-author WorktreeResolution suite; a helper `Set-ArtifactSeamCapture` that mocks the four artifact seams with `param($Path)` / `param($BodyFilePath)` / `param($ReceiptFilePath)` bodies that append each received path to `$script:CapturedPaths` and return: existence `$true`, body `[byte[]]@(0x41)`, receipt `{"number":1,"sha256":"559aead08264d5795d3909718cdd05abd49572e84fe55590eef31a88a08fdffd","created_at":"2026-06-27T12:00:00Z"}`, summary last-write `2026-06-27T11:00:00Z`; preflight mocked to pass; `Get-PrAuthorCheckpointContent` mocked to `$null`. Every row enters through `Invoke-PrAuthorSkillDecision`.

1. `allows an OtherWorktree target whose artifacts exist only in the item worktree` — seam `OtherWorktree` at `item-own-ready`; working directory `item-own-not-ready`; command `gh pr create --head f5-fixture-own --title "B" --body-file <item-own-ready>/artifacts/pr_body_1.md`; no artifact seam mocked; assert allow.
2. `ignores session-root PR artifacts when the target is another worktree` — working directory `session-root`; seam `OtherWorktree` at `item-own-not-ready`; absolute body path beneath it; assert deny `PR_CONTEXT_MISSING*` and the reason contains the `item-own-not-ready` path.
3. `reads summary, body, receipt and summary timestamp beneath the resolved item root` — seam `OtherWorktree` at `/synthetic-worktrees/item-a`; `Set-ArtifactSeamCapture`; absolute body path; assert allow, each of the four seams invoked at least once, and every captured path starts with `/synthetic-worktrees/item-a/artifacts/`.
4. `compares receipt freshness against the item worktree summary` — as row 3, but the summary last-write mock returns `2026-06-27T13:00:00Z` for paths under `item-a` and `2026-06-27T11:00:00Z` otherwise; assert deny `PR_AUTHOR_RECEIPT_STALE*` and `Should -Invoke Get-PrContextSummaryLastWriteUtc -Times 1 -Exactly -ParameterFilter { $Path -like '/synthetic-worktrees/item-a/*' }`.
5. `resolves the target once and reuses it for artifacts, preflight and Check 6` — as row 3 with the preflight and `Get-PrAuthorCheckpointContent` capturing their paths; assert `Should -Invoke Resolve-PrAuthorWorktreeTarget -Times 1 -Exactly`, both captured checkpoint paths equal `/synthetic-worktrees/item-a/artifacts/orchestration/orchestrator-state.json`, and the existence seam received `/synthetic-worktrees/item-a/artifacts/pr_context.summary.txt`.
6. `denies an unresolvable target with the no-target code ahead of PR_CONTEXT_MISSING` — seam `NoTarget`; existence mocked `$false`; preflight mocked to throw; assert the reason starts with the no-target code and the preflight `-Times 0`.
7. `denies an ambiguous target with the ambiguity code ahead of PR_CONTEXT_MISSING` — as row 6 with `Ambiguous`.
8. `denies a relative body path for an OtherWorktree target and names the absolute path` — as row 3 with `--body-file artifacts/pr_body_1.md`; assert `PR_BODY_PATH_NONCANONICAL*` and the reason contains `/synthetic-worktrees/item-a/artifacts/pr_body_1.md`.
9. `denies an absolute body path outside the resolved root` — as row 3 with `--body-file /synthetic-worktrees/session/artifacts/pr_body_1.md`; assert `PR_BODY_PATH_NONCANONICAL*`.
10. `applies drive and UNC case-insensitive, POSIX case-sensitive body path comparison` — three acts with `Set-ArtifactSeamCapture`: root `C:/Repo/Item-A` with body `c:/repo/item-a/artifacts/pr_body_1.md` (allow); root `//Server/Share/Item` with body `//server/share/ITEM/artifacts/pr_body_1.md` (allow); root `/synthetic-worktrees/Item-A` with body `/synthetic-worktrees/item-a/artifacts/pr_body_1.md` (deny `PR_BODY_PATH_NONCANONICAL*`).
11. `keeps SessionRoot behavior with absolute artifact paths` — seam `SessionRoot` at `/synthetic-worktrees/session`; relative body path; assert allow and every captured path starts with `/synthetic-worktrees/session/artifacts/`.
12. `reads epic-scope PR artifacts beneath the epic checkpoint worktree` — `Mock Resolve-EpicScopeCheckpoint` returning `IsEpicScope = $true`, `CheckpointPath = '/synthetic-worktrees/epic-wt/artifacts/orchestration/epic-orchestrator-state.json'`, `Checkpoint` (any object), `WorktreeRoot = '/synthetic-worktrees/session'`, `Branch = 'epic/x-integration'`; `Mock Get-EpicPrCreationReadinessFailure { $null }`; `Mock Test-EpicBaseBranchOverride { $null }`; absolute body path beneath `epic-wt`; assert allow, every captured path starts with `/synthetic-worktrees/epic-wt/artifacts/`, and `Resolve-PrAuthorWorktreeTarget -Times 0`.
13. `performs no resolution for commands without a body file` — `Mock Resolve-PrAuthorWorktreeTarget { throw 'no resolution expected' }` and `Mock Resolve-EpicScopeCheckpoint { throw 'no resolution expected' }`; commands `gh pr create --body "x"` (deny), `gh pr create --title x` (deny), `gh pr edit 5 --title x` (allow); assert those decisions and both seams `-Times 0`.
14. `denies when the epic checkpoint path does not end with the epic checkpoint suffix` — epic mock with `CheckpointPath = '/synthetic-worktrees/epic-wt/elsewhere.json'`; assert `ORCHESTRATOR_STATE_PREFLIGHT_FAILED*`.
15. `denies a body-file value that names no pr_body file` — as row 11 with `--body-file artifacts/notes.md`; assert `PR_BODY_PATH_NONCANONICAL*`.

### C10 — pr-author Tests.ps1 edits

- Remove `-ContextExists $true` from the two `Get-PrAuthorBypassReason` calls and the two `Test-PrAuthorBypassRequired` calls that pass it.
- In `returns null for allowed command` and `returns false for an allowed command`, add the Arrange line `Mock -CommandName Get-PrContextArtifactExistence -MockWith { $true }`, so the allow no longer depends on a context summary on disk.
- In `returns PR_CONTEXT_MISSING when --body-file present but context absent` and `returns true when context is missing for --body-file command`, replace `-ContextExists $false` by an Arrange line `Mock -CommandName Get-PrContextArtifactExistence -MockWith { $false }`.
- `returns a boolean result without throwing`: call `Get-PrContextArtifactExistence -Path '/synthetic-worktrees/pra-seam/artifacts/pr_context.summary.txt'`.
- `returns $null when the context summary path does not exist`: replace the `$script:PrContextArtifactPath` swap with `Get-PrContextSummaryLastWriteUtc -Path '/synthetic-worktrees/pra-seam/artifacts/this-context-path-does-not-exist.txt' | Should -BeNullOrEmpty`.
- `returns a UTC DateTime when the context path exists (points at the hook script itself)`: call `Get-PrContextSummaryLastWriteUtc -Path $script:UnderTest`; assertions unchanged.
- Revision 4 (rule EE, EE-1): in the `BeforeEach` of `Context 'allowed commands'`, immediately after the line `Mock -CommandName Get-PrContextSummaryLastWriteUtc -MockWith { [DateTime]::Parse('2026-06-24T12:00:00Z').ToUniversalTime() }` (line 148 at BASE_SHA), insert these two lines at the same indentation, matching the three sibling contexts that already isolate Check 6:
  - `# Isolate the sixth (epic-mode base-branch) check from any local checkpoint: an epic-mode checkpoint in the executing worktree would otherwise deny gh pr create (issue #850).`
  - `Mock -CommandName Get-PrAuthorCheckpointContent -MockWith { $null }`
  The mocked function is PRAE's read seam `Get-PrAuthorCheckpointContent` (PRAE lines 17-48), which `Test-EpicBaseBranchOverride` calls at PRAE line 107; mocking the seam rather than the check keeps the check's command-scope logic under test. No row, assertion, or count changes; `allows gh pr create --body-file artifacts/pr_body_12.md when context exists` then allows whether or not an epic-mode checkpoint exists, and the `gh pr edit` and non-`gh pr create` rows of the context are unaffected because Check 6 returns `$null` for them.

### C11 — TargetResolution suite edits

Remove `-ContextExists $true` from all five calls. In the two rows of `Context 'the checkpoint is taken from the resolved target, not the session root'`, add the Arrange line `Mock -CommandName Get-PrContextArtifactExistence -MockWith { $true }`.

### C12 — pr-author WorktreeResolution suite edits

- Header lines that describe process-directory binding: state that the gate reads the summary, body, and receipt beneath the resolved worktree (issue #850), that working directories remain explicit, and that rows whose subject is the preflight mock only the summary-existence seam.
- Add `$script:OwnReadyBodyCommand = "gh pr create --head f5-fixture-own --title ""B"" --body-file $($script:OwnReady)/artifacts/pr_body_1.md"` in `BeforeAll`; both R1 rows use it.
- `pr-author R3 denies with the preflight reason when the resolved own checkpoint is not ready`, `pr-author R4 takes the preflight verdict from the own checkpoint located by branch when the sibling checkpoint is ready`, both R7 rows, and `pr-author genuine-absence and target-resolution reason codes never appear in each other's decisions`: add the Arrange line `Mock -CommandName Get-PrContextArtifactExistence -MockWith { $true }` (CR cause d).
- `pr-author R4 takes the epic base-branch verdict from the own checkpoint when own and sibling checkpoints are both present`: body path becomes `$($script:OwnEpicMode)/artifacts/pr_body_1.md`; the comment states the artifacts are read beneath the resolved epic-mode worktree (fixture copies, D10).
- `pr-author passes one resolved checkpoint path to both the preflight and the epic base-branch check`: `Set-ResolvedSeam -Status 'OtherWorktree' -WorktreeRoot $script:OwnReady`, command `$script:OwnReadyBodyCommand`, expected path `"$($script:OwnReady)/artifacts/orchestration/orchestrator-state.json"`; remove the now-unused `$script:CaptureRoot` line.

### C13 — Isolation guard

Insert `@{ Path = 'tests/scripts/claude-hooks/enforce-pr-author-skill.ItemArtifactRoot.Tests.ps1' }` as the last entry of the `-ForEach` list in `'<Path> isolates the epic checkpoint read in its outermost BeforeAll'`, change "Eight hook suites" in the header (line 9) to "Nine hook suites", and change "parses each of the eight committed suites" (line 15) to "parses each of the nine committed suites".

### C14 — T-CONS (2 tests)

- `keeps every changed file within the line cap` — for each repository-relative path in a literal list (Appendix F groups PROD-ALL and TESTS-ALL, plus every suite in `FEATURE/evidence/other/edited-suites-850.md`), `@(Get-Content -LiteralPath <path>).Count | Should -BeLessOrEqual 500 -Because <path>`.
- `uses no temporary files and no host paths` — tokens built by concatenation (`'Test' + 'Drive'`, `'GetTemp' + 'Path'`, `'GetTemp' + 'FileName'`, `'New-Temporary' + 'File'`) must not occur in any TESTS-ALL file other than this suite itself; the patterns `[A-Za-z]:\\Users\\`, `[A-Za-z]:/Users/`, and `/home/[a-z]` must not match any line of the five new suites or PRAR. The suite reads committed files located from `$PSScriptRoot` only.

### C15 — S824 edits (C1a suite `enforce-pr-author-skill.Issue824.Tests.ps1`)

- Rows `<Id> denies <Command> with PR_AUTHOR_SKILL_BLOCKED`, PA-23, and PA-20: remove ` -ContextExists $true` from the four `Get-PrAuthorBypassReason` calls (lines 135, 139, 146, 149 at BASE_SHA). Each command returns at Case A, Case B, or the scope test before any resolution, so no further Arrange line is needed.
- In the `BeforeEach` of `Context 'body-file normalization and receipt verification'`: change `WorktreeRoot = (Get-Location).Path` in the `Resolve-PrAuthorWorktreeTarget` mock to `WorktreeRoot = '/session'`, and remove the line `Mock Get-PrAuthorBodyFileRoot { '/session' }`. With the resolved root at `/session`, the relative rows PA-06, PA-07, PA-09, and PA-10 and the absolute row PA-08 (`/session/artifacts/pr_body_5.md`) still reach Check 2 and deny `PR_AUTHOR_RECEIPT_MISSING`, PA-11 to PA-15 still deny `PR_BODY_PATH_NONCANONICAL`, and PA-22 still denies `PR_CONTEXT_MISSING`.
- PA-24: the `Test-PrAuthorReceiptVerification` call becomes `Test-PrAuthorReceiptVerification -CommandText $command -CheckpointPath 'unused-checkpoint-path' -ArtifactRoot '/session' -RelativeBodyAllowed $true`; assertions unchanged.
- Remove `Context 'body-file root seam'` and its row PA-21 (lines 156-160 at BASE_SHA) and the blank line before it; the seam no longer exists (D12).
- Header: replace "the receipt, and the body-file root arrive only through mocked seams" with "and the receipt arrive only through mocked seams, and the artifact root is supplied as `/session`".

### C16 — S824R edits (C1a suite `hook-command-invocation.Issue824Regression.Tests.ps1`)

- REG-09 to REG-12: remove ` -ContextExists $true` from the four `Get-PrAuthorBypassReason` calls (lines 184, 192, 200, 208 at BASE_SHA); none of the commands invokes `gh`, so the result stays `$null`.
- In the `BeforeEach` of `Context 'body-file spellings reach receipt verification (R-733-715)'`, remove the line `Mock Get-PrAuthorBodyFileRoot { '/session' }` (D12).
- REG-13 to REG-17: append ` -ArtifactRoot '/session' -RelativeBodyAllowed $true` to each `Test-PrAuthorReceiptVerification` call (lines 221, 227, 233, 239, 245 at BASE_SHA); every assertion stays `PR_AUTHOR_RECEIPT_MISSING:*`.
- REG-15: its `-Because` text becomes 'the absolute path equals the canonical path beneath the artifact root'.

## Appendix D — Documentation Edit

### D1 — SKILL (`## PR Authoring (pr-author Handoff)`)

After the numbered item that begins "4. The orchestrator records `pr_author_receipt`", insert one blank line and this paragraph: "When the pr-author agent runs outside the item worktree (its process directory is not the worktree that holds the item's `artifacts/` tree), it passes the absolute canonical path `<item worktree>/artifacts/pr_body_<N>.md` to `--body-file`. The `enforce-pr-author-skill.ps1` hook resolves the item worktree from `--head` and reads the PR context summary, the body, and the receipt beneath it; in that topology it denies a relative `--body-file` with `PR_BODY_PATH_NONCANONICAL`, because `gh` would read the relative path from its own process directory."

## Appendix F — File Groups and Mirror Pairs

- **PROD-EXIST** (9): PRA, PRAH, MRG, MRGR, EREM, EREMR, PREM, WRR, WIR.
- **PROD-ALL** (10): PROD-EXIST plus PRAR.
- **NEW-TESTS** (5): T-PRA-IAR, T-MRG-IR, T-WIR-PR, T-EREM-DX, T-CONS.
- **EDITED-TESTS** (14): `tests/scripts/claude-hooks/enforce-pr-author-skill.Issue824.Tests.ps1` (S824, revision 3), `tests/scripts/claude-hooks/hook-command-invocation.Issue824Regression.Tests.ps1` (S824R, revision 3), `tests/scripts/claude-lib/worktree-resolution/WorktreeRunResolution.Record.Tests.ps1`, `tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.WorktreeResolution.Tests.ps1`, `tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1`, `tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1`, `tests/scripts/claude-hooks/enforce-epic-merge-gate.Authorization.Tests.ps1`, `tests/scripts/claude-hooks/enforce-epic-merge-gate.TriggerScoping.Tests.ps1`, `tests/scripts/claude-hooks/enforce-epic-merge-gate.WorktreeResolution.Tests.ps1`, `tests/scripts/claude-hooks/hook-command-parser.AcceptanceCases.Tests.ps1`, `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1`, `tests/scripts/claude-hooks/enforce-pr-author-skill.TargetResolution.Tests.ps1`, `tests/scripts/claude-hooks/enforce-pr-author-skill.WorktreeResolution.Tests.ps1`, `tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Tests.ps1`; plus every suite added by rule CR.
- **BASELINE-GREEN** (23; used by the P0-T17 through P0-T20 stop rule): the fourteen EDITED-TESTS suites listed above (S824 and S824R are baselined by P0-T17, because SET-PRA lists them), plus the suites spec AC-14, AC-25, AC-33, AC-38, and AC-41 name that are not already listed: `tests/scripts/claude-hooks/enforce-pr-author-skill.OrchestratorStatePreflight.Tests.ps1`, `tests/scripts/claude-hooks/enforce-pr-author-skill.EpicScope.Tests.ps1`, `tests/scripts/claude-lib/orchestrator-state/OrchestratorState.Tests.ps1`, `tests/scripts/claude-hooks/enforce-epic-merge-gate.AuthorizationFields.Tests.ps1`, `tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Tests.ps1`, `tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.TriggerScoping.Tests.ps1`, `tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.WorktreeResolution.Tests.ps1`, `tests/scripts/claude-hooks/CleanupWorktreeManifestGateMatrix.Tests.ps1`, and `tests/scripts/claude-lib/worktree-resolution/WorktreeResolution.Manifest.Tests.ps1`.
- **TESTS-ALL**: NEW-TESTS plus EDITED-TESTS.
- **FINAL-PS**: PROD-ALL plus TESTS-ALL.
- **LC-TESTS** (14): EDITED-TESTS.
- **MP-EXIST** (13 pairs; primary then `CB/<primary>`): PRA, PRAH, PRAE, MRG, MRGR, MRGA, EREM, EREMR, PREM, WRR, WIR, ESR, SKILL.
- **MP-ALL** (14 pairs): MP-EXIST plus PRAR.

## Appendix G — Suite Sets and Coverage Groups

All paths are under `tests/scripts/`. Lists are passed to A2 and A3 comma-separated.

- **SET-PRA**: `claude-hooks/enforce-pr-author-skill.Tests.ps1`, `claude-hooks/enforce-pr-author-skill.EpicScope.Tests.ps1`, `claude-hooks/enforce-pr-author-skill.OrchestratorStatePreflight.Tests.ps1`, `claude-hooks/enforce-pr-author-skill.Payload.Tests.ps1`, `claude-hooks/enforce-pr-author-skill.TargetResolution.Tests.ps1`, `claude-hooks/enforce-pr-author-skill.TriggerScoping.Tests.ps1`, `claude-hooks/enforce-pr-author-skill.WorktreeResolution.Tests.ps1`, `claude-hooks/enforce-pr-author-skill.epic-base-branch.Tests.ps1`, `claude-hooks/enforce-pr-author-skill.epic-base-branch.TriggerScoping.Tests.ps1`, `claude-lib/orchestrator-state/OrchestratorState.Tests.ps1`, `claude-hooks/enforce-gate-suites.EpicStateIsolation.Tests.ps1`, `claude-hooks/enforce-pr-author-skill.Issue824.Tests.ps1`, `claude-hooks/hook-command-invocation.Issue824Regression.Tests.ps1` (both added by revision 3), and (from Phase 6) T-PRA-IAR. Growth: +15 (IAR 15, guard 1, PA-21 removed −1).
- **SET-MRG**: `claude-hooks/enforce-epic-merge-gate.Tests.ps1`, `.Authorization.Tests.ps1`, `.AuthorizationFields.Tests.ps1`, `.TriggerScoping.Tests.ps1`, `.WorktreeResolution.Tests.ps1`, `claude-hooks/hook-command-parser.AcceptanceCases.Tests.ps1`, and (from Phase 5) T-MRG-IR. Growth: +19.
- **SET-REM**: `claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1`, `.TriggerScoping.Tests.ps1`, `.WorktreeResolution.Tests.ps1`, `claude-hooks/enforce-parallel-worktree-removal-gate.Tests.ps1`, `.EpicAuthorization.Tests.ps1`, `.TriggerScoping.Tests.ps1`, `.WorktreeResolution.Tests.ps1`, `claude-hooks/CleanupWorktreeManifestGateMatrix.Tests.ps1`, `claude-hooks/hook-command-parser.AcceptanceCases.Tests.ps1`, and (from Phase 3) T-EREM-DX. Growth: +1 after Phase 2, +9 after Phase 3.
- **SET-LIB**: the folder `claude-lib/worktree-resolution`. Growth: +1 after Phase 1, +12 after Phase 4.
- Folder growth at Phase 8: `claude-hooks` +45 (T-MRG-IR 19, T-PRA-IAR 15, T-EREM-DX 8, T-CONS 2, Y7 1, guard 1, PA-21 removed −1); `claude-lib` +12 (T-WIR-PR 11, B14 1); `claude-runtime` +0; `codex-hooks` +0.

Coverage groups (A3 `-TestPath` and `-CoveragePath`; the baseline uses the suites that exist at Phase 0, the final adds the new suites and PRAR):

- **CG-PRA**: tests SET-PRA (final adds T-PRA-IAR); coverage PRA, PRAH (final adds PRAR).
- **CG-MRG**: tests SET-MRG (final adds T-MRG-IR); coverage MRG, MRGR.
- **CG-EREM**: tests the three epic removal suites, `claude-hooks/CleanupWorktreeManifestGateMatrix.Tests.ps1`, `claude-hooks/hook-command-parser.AcceptanceCases.Tests.ps1` (final adds T-EREM-DX); coverage EREM, EREMR.
- **CG-PREM**: tests the four parallel removal suites and `claude-hooks/CleanupWorktreeManifestGateMatrix.Tests.ps1`; coverage PREM.
- **CG-LIB**: tests the folder `claude-lib/worktree-resolution`; coverage WRR, WIR.

## Appendix H — Scratch Scripts

Written verbatim under SCRATCH by P0-T6 and never committed. A1-A7, A10, and A12 are carried from the #690 plan Appendix H (A1-A7, A13, and A15 there), where their output formats were observed in executed runs; A2 adds one `FAILED-FILE:` line per failure that the #690 version did not print, and A2 and A3 both add one `FAILED-CONTAINER:` line per entry of `$result.FailedContainers` (a test file that failed during Pester discovery, whose tests produce no `FAILED:` line and are absent from `TotalCount=`). A9's `SELECTED_ROUTE=` line, A15's anchor-only test entries, and A17 are new to this plan. Revision 3 changed A15 only (HCIO entry, the C1a functions of PRAH, EREM, and PREM, and the S824 and S824R anchor entries); P0-T12 rewrites it in SCRATCH before running it. Revision 4 adds A18 (rule EE probe); P0-T17 creates it in SCRATCH before running it, and P0-T6 stays checked.

A1 run-ps.sh:

```sh
#!/bin/sh
set -eu
pwsh -NoProfile -NonInteractive -File "$@"
```

A2 pester-counts.ps1:

```powershell
param([Parameter(Mandatory)][string[]] $Path)
$Path = @($Path | ForEach-Object { $_ -split ',' } | Where-Object { $_ })
$configuration = New-PesterConfiguration
$configuration.Run.Path = $Path
$configuration.Run.PassThru = $true
$configuration.Output.Verbosity = 'Detailed'
$result = Invoke-Pester -Configuration $configuration
Write-Output "TotalCount=$($result.TotalCount)"
Write-Output "PassedCount=$($result.PassedCount)"
Write-Output "FailedCount=$($result.FailedCount)"
foreach ($failedTest in $result.Failed) {
    $sourceFile = $failedTest.ScriptBlock.File
    $relativeFile = if ($sourceFile) { [System.IO.Path]::GetRelativePath((Get-Location).Path, $sourceFile).Replace([string][char]92, '/') } else { '' }
    Write-Output "FAILED: $($failedTest.ExpandedPath)"
    Write-Output "FAILED-FILE: $relativeFile"
}
foreach ($failedContainer in $result.FailedContainers) {
    $containerFile = if ($failedContainer.Item -is [System.IO.FileInfo]) { $failedContainer.Item.FullName } else { '' }
    $containerRelative = if ($containerFile) { [System.IO.Path]::GetRelativePath((Get-Location).Path, $containerFile).Replace([string][char]92, '/') } else { '' }
    Write-Output "FAILED-CONTAINER: $containerRelative"
}
```

A3 pester-coverage.ps1:

```powershell
param(
    [Parameter(Mandatory)][string[]] $TestPath,
    [Parameter(Mandatory)][string[]] $CoveragePath,
    [Parameter(Mandatory)][string] $CoverageOutputPath,
    [string] $ReportPath = ''
)
$TestPath = @($TestPath | ForEach-Object { $_ -split ',' } | Where-Object { $_ })
$CoveragePath = @($CoveragePath | ForEach-Object { $_ -split ',' } | Where-Object { $_ })
$configuration = New-PesterConfiguration
$configuration.Run.Path = $TestPath
$configuration.Run.PassThru = $true
$configuration.Output.Verbosity = 'Detailed'
$configuration.CodeCoverage.Enabled = $true
$configuration.CodeCoverage.Path = $CoveragePath
$configuration.CodeCoverage.OutputPath = $CoverageOutputPath
$result = Invoke-Pester -Configuration $configuration
$report = [System.Collections.Generic.List[string]]::new()
$report.Add("TotalCount=$($result.TotalCount)")
$report.Add("PassedCount=$($result.PassedCount)")
$report.Add("FailedCount=$($result.FailedCount)")
foreach ($failedTest in $result.Failed) { $report.Add("FAILED: $($failedTest.ExpandedPath)") }
foreach ($failedContainer in $result.FailedContainers) {
    $containerFile = if ($failedContainer.Item -is [System.IO.FileInfo]) { $failedContainer.Item.FullName } else { '' }
    $containerRelative = if ($containerFile) { [System.IO.Path]::GetRelativePath((Get-Location).Path, $containerFile).Replace([string][char]92, '/') } else { '' }
    $report.Add("FAILED-CONTAINER: $containerRelative")
}
$executed = @($result.CodeCoverage.CommandsExecuted)
$missed = @($result.CodeCoverage.CommandsMissed)
foreach ($file in $CoveragePath) {
    $fullPath = (Resolve-Path -LiteralPath $file).Path
    $hitLines = @($executed | Where-Object { $_.File -eq $fullPath } | ForEach-Object { $_.Line } | Sort-Object -Unique)
    $missLines = @($missed | Where-Object { $_.File -eq $fullPath } | ForEach-Object { $_.Line } | Sort-Object -Unique | Where-Object { $hitLines -notcontains $_ })
    $analyzed = @(@($hitLines) + @($missLines) | Sort-Object -Unique)
    $percent = if ($analyzed.Count -eq 0) { 'NA' } else { [math]::Round(100 * $hitLines.Count / $analyzed.Count, 2) }
    $report.Add("COVERAGE file=$file AnalyzedLines=$($analyzed.Count) CoveredLines=$($hitLines.Count) LinePercent=$percent")
    $report.Add("HIT file=$file Lines=$($hitLines -join ',')")
    $report.Add("MISSED file=$file Lines=$($missLines -join ',')")
}
$report | Write-Output
if ($ReportPath) { $report | Set-Content -LiteralPath $ReportPath -Encoding UTF8 }
```

A4 line-counts.ps1:

```powershell
param([Parameter(Mandatory, ValueFromRemainingArguments = $true)][string[]] $Path)
foreach ($file in $Path) { Write-Output "$file LineCount=$(@(Get-Content -LiteralPath $file).Count)" }
```

A5 file-hashes.ps1:

```powershell
param([Parameter(Mandatory, ValueFromRemainingArguments = $true)][string[]] $Path)
foreach ($file in $Path) { Write-Output "$file Hash=$((Get-FileHash -LiteralPath $file -Algorithm SHA256).Hash)" }
```

A6 ps-format-check.ps1 (read-only):

```powershell
param([Parameter(Mandatory, ValueFromRemainingArguments = $true)][string[]] $Path)
$settings = 'scripts/powershell/PoshQC/settings/pssa.settings.psd1'
$changedCount = 0
foreach ($file in $Path) {
    $original = Get-Content -Raw -LiteralPath $file
    $formatted = Invoke-Formatter -ScriptDefinition $original -Settings $settings
    $changed = $formatted -cne $original
    if ($changed) { $changedCount++ }
    Write-Output "FORMAT file=$file Changed=$changed"
}
Write-Output "FORMAT-SUMMARY ChangedCount=$changedCount"
```

A7 pssa-count.ps1:

```powershell
param([Parameter(Mandatory, ValueFromRemainingArguments = $true)][string[]] $Path)
$settings = 'scripts/powershell/PoshQC/settings/pssa.settings.psd1'
$records = @(foreach ($file in $Path) { Invoke-ScriptAnalyzer -Path $file -Settings $settings })
foreach ($record in $records) { Write-Output "PSSA $($record.ScriptName):$($record.Line) $($record.RuleName) $($record.Severity)" }
Write-Output "PSSA-SUMMARY DiagnosticCount=$($records.Count)"
```

A8 json-parse.ps1:

```powershell
param([Parameter(Mandatory)][string] $Path)
$ErrorActionPreference = 'Stop'
$null = Get-Content -Raw -LiteralPath $Path | ConvertFrom-Json
Write-Output "JSON-OK file=$Path"
```

A9 batch-budget-probe.ps1 (read-only):

```powershell
param([Parameter(Mandatory)][string] $CheckpointPath)
$ErrorActionPreference = 'Stop'
. (Join-Path (Get-Location).Path '.claude/hooks/enforce-batch-budget-route.ps1')
$text = Get-Content -Raw -LiteralPath $CheckpointPath
$checkpoint = $text | ConvertFrom-Json
Write-Output "SELECTED_ROUTE=$(Get-BatchBudgetSelectedRoute -CheckpointText $text)"
Write-Output "NEXT_STEP=$($checkpoint.next_step)"
Write-Output "ISSUE_NUM=$($checkpoint.'issue-num')"
Write-Output "LARGE_PATH_EXEMPT=$(Test-BatchBudgetLargePathRoute -CheckpointText $text)"
```

A10 pair-hashes.ps1 (arguments: primary, mirror, primary, mirror, ...):

```powershell
param([Parameter(Mandatory, ValueFromRemainingArguments = $true)][string[]] $Path)
if ($Path.Count % 2 -ne 0) { throw 'pair-hashes requires an even number of paths.' }
$unequal = 0
for ($index = 0; $index -lt $Path.Count; $index += 2) {
    $primary = $Path[$index]
    $mirror = $Path[$index + 1]
    $primaryHash = (Get-FileHash -LiteralPath $primary -Algorithm SHA256).Hash
    $mirrorHash = if (Test-Path -LiteralPath $mirror) { (Get-FileHash -LiteralPath $mirror -Algorithm SHA256).Hash } else { 'MISSING' }
    $equal = $primaryHash -eq $mirrorHash
    if (-not $equal) { $unequal++ }
    Write-Output "PAIR equal=$equal primary=$primary mirror=$mirror"
}
Write-Output "PAIR-SUMMARY pairs=$($Path.Count / 2) unequal=$unequal"
```

A11 changed-line-coverage.ps1 (reads an A3 report; lines absent at the base ref count as changed):

```powershell
param(
    [Parameter(Mandatory)][string] $CoverageReportPath,
    [Parameter(Mandatory)][string] $BaseRef,
    [Parameter(Mandatory)][string[]] $File
)
$File = @($File | ForEach-Object { $_ -split ',' } | Where-Object { $_ })
$report = Get-Content -LiteralPath $CoverageReportPath
foreach ($target in $File) {
    $hitLine = $report | Where-Object { $_ -like "HIT file=$target Lines=*" } | Select-Object -First 1
    $missLine = $report | Where-Object { $_ -like "MISSED file=$target Lines=*" } | Select-Object -First 1
    if (-not $hitLine -or -not $missLine) { Write-Output "CHANGED-COVERAGE file=$target MISSING"; continue }
    $hit = @(($hitLine -replace '^.*Lines=', '') -split ',' | Where-Object { $_ } | ForEach-Object { [int]$_ })
    $miss = @(($missLine -replace '^.*Lines=', '') -split ',' | Where-Object { $_ } | ForEach-Object { [int]$_ })
    $changed = [System.Collections.Generic.HashSet[int]]::new()
    $null = git cat-file -e "${BaseRef}:$target" 2>$null
    if ($LASTEXITCODE -eq 0) {
        foreach ($diffLine in @(git diff -U0 $BaseRef -- $target)) {
            if ($diffLine -match '^@@ -\d+(?:,\d+)? \+(\d+)(?:,(\d+))? @@') {
                $start = [int]$Matches[1]
                $count = if ($Matches[2]) { [int]$Matches[2] } else { 1 }
                for ($offset = 0; $offset -lt $count; $offset++) { [void]$changed.Add($start + $offset) }
            }
        }
    } else {
        $lineCount = @(Get-Content -LiteralPath $target).Count
        for ($lineNumber = 1; $lineNumber -le $lineCount; $lineNumber++) { [void]$changed.Add($lineNumber) }
    }
    $changedHit = @($hit | Where-Object { $changed.Contains($_) }).Count
    $changedMiss = @($miss | Where-Object { $changed.Contains($_) }).Count
    $analyzed = $changedHit + $changedMiss
    $percent = if ($analyzed -eq 0) { 'NA' } else { [math]::Round(100 * $changedHit / $analyzed, 2) }
    Write-Output "CHANGED-COVERAGE file=$target ChangedLines=$($changed.Count) ChangedAnalyzed=$analyzed ChangedCovered=$changedHit ChangedPercent=$percent"
}
```

A12 stage-check.ps1 (read-only):

```powershell
param([Parameter(Mandatory)][string] $Path)
$settings = 'scripts/powershell/PoshQC/settings/pssa.settings.psd1'
$tokens = $null
$errors = $null
$null = [System.Management.Automation.Language.Parser]::ParseFile((Resolve-Path -LiteralPath $Path).Path, [ref] $tokens, [ref] $errors)
$original = Get-Content -Raw -LiteralPath $Path
$formatted = Invoke-Formatter -ScriptDefinition $original -Settings $settings
$records = @(Invoke-ScriptAnalyzer -Path $Path -Settings $settings)
foreach ($record in $records) { Write-Output "PSSA $($record.Line) $($record.RuleName) $($record.Severity)" }
Write-Output "STAGE-CHECK ParseErrors=$(@($errors).Count) FormatChanged=$($formatted -cne $original) DiagnosticCount=$($records.Count)"
```

A13 added-lines-scan.ps1 (literal tokens and regular-expression patterns over lines added since the base ref; a file absent at the base ref is scanned in full):

```powershell
param(
    [Parameter(Mandatory)][string] $BaseRef,
    [string[]] $Token = @(),
    [string[]] $Pattern = @(),
    [Parameter(Mandatory)][string[]] $File
)
$Token = @($Token | ForEach-Object { $_ -split ',' } | Where-Object { $_ })
$Pattern = @($Pattern | ForEach-Object { $_ -split ',' } | Where-Object { $_ })
$File = @($File | ForEach-Object { $_ -split ',' } | Where-Object { $_ })
$count = 0
foreach ($target in $File) {
    $null = git cat-file -e "${BaseRef}:$target" 2>$null
    $added = if ($LASTEXITCODE -eq 0) {
        @(git diff -U0 $BaseRef -- $target | Where-Object { $_.StartsWith('+') -and -not $_.StartsWith('+++') })
    } else { @(Get-Content -LiteralPath $target) }
    foreach ($line in $added) {
        foreach ($item in $Token) { if ($line.Contains($item)) { $count++; Write-Output "ADDED-TOKEN file=$target token=$item" } }
        foreach ($regex in $Pattern) { if ($line -match $regex) { $count++; Write-Output "ADDED-PATTERN file=$target pattern=$regex" } }
    }
}
Write-Output "ADDED-TOKEN-SUMMARY count=$count files=$($File.Count)"
```

A14 checkbox-count.ps1 (read-only):

```powershell
param([Parameter(Mandatory)][string] $Path, [int] $FromLine = 1, [string[]] $Line = @())
$lines = @(Get-Content -LiteralPath $Path)
$checked = 0
$unchecked = 0
for ($index = $FromLine - 1; $index -lt $lines.Count; $index++) {
    if ($lines[$index].StartsWith('- [x] ')) { $checked++ } elseif ($lines[$index].StartsWith('- [ ] ')) { $unchecked++ }
}
Write-Output "CHECKBOX checked=$checked unchecked=$unchecked"
foreach ($number in @($Line | ForEach-Object { $_ -split ',' } | Where-Object { $_ })) {
    $text = $lines[[int]$number - 1]
    $state = if ($text.StartsWith('- [x] ')) { 'checked' } elseif ($text.StartsWith('- [ ] ')) { 'unchecked' } else { 'not-a-checkbox' }
    Write-Output "LINE n=$number state=$state"
}
```

A15 region-probe.ps1 (read-only; fixed file, function, and anchor list):

```powershell
$ErrorActionPreference = 'Stop'
$targets = [ordered]@{
    '.claude/hooks/enforce-pr-author-skill.ps1' = @{
        Function = @('Get-PrContextArtifactExistence', 'Get-PrBodyFileBytes', 'Get-PrAuthorReceiptContent', 'Get-PrContextSummaryLastWriteUtc', 'Invoke-PrAuthorSkillDecision', 'Test-PrAuthorBypassRequired')
        Anchor   = @('$script:PrContextArtifactPath = ', '$contextExists = Get-PrContextArtifactExistence')
    }
    '.claude/hooks/enforce-pr-author-skill-helpers.ps1' = @{
        Function = @('Resolve-PrAuthorWorktreeTarget', 'Get-PrAuthorTargetCheckpointResolution', 'Get-PrAuthorBodyFileRoot', 'Get-PrAuthorBodyFileValue', 'Test-PrAuthorReceiptVerification', 'Get-PrAuthorBypassReason')
        Anchor   = @('# Check 1:', '# Check 2:', '# Case C:', 'Resolve-EpicScopeCheckpoint -Text $CommandText', 'Get-PrAuthorTargetCheckpointResolution -CommandText $CommandText')
    }
    '.claude/hooks/hook-command-invocation.ps1' = @{
        Function = @('Test-CommandLineInvocation')
        Anchor   = @()
    }
    '.claude/hooks/hook-command-invocation-operands.ps1' = @{
        Function = @('Get-CommandLineFlagValue', 'Test-CommandLineFlag')
        Anchor   = @()
    }
    '.claude/hooks/enforce-epic-merge-gate.ps1' = @{
        Function = @('Invoke-EpicMergeGateDecision')
        Anchor   = @('$childCheckpoint = ConvertFrom-EpicMergeGateJson -Raw (Get-ChildOrchestratorCheckpointContent', 'Get-EpicMergeGateUnresolvedReason -EpicTarget')
    }
    '.claude/hooks/enforce-epic-merge-gate-resolution.ps1' = @{
        Function = @('Get-EpicMergeGateSessionWorktreeRoot', 'Resolve-EpicMergeGateRunTarget', 'Test-ChildCheckpointPrGateBinding', 'Get-EpicMergeGateUnresolvedReason')
        Anchor   = @('$script:EpicMergeGateResolutionImportFailure = ')
    }
    '.claude/hooks/enforce-epic-worktree-removal-gate.ps1' = @{
        Function = @('Find-EpicWorktreeFeatureRecord', 'Test-ParallelCheckpointAllowsWorktreeRemoval', 'Invoke-EpicWorktreeRemovalGateDecision', 'Get-EpicWorktreeRemovalTargetDenial')
        Anchor   = @('$prefix = "EPIC_WORKTREE_REMOVAL_BLOCKED: ', '-Reason ($prefix + "EPIC_WORKTREE_REMOVAL_BLOCKED: git worktree remove for')
    }
    '.claude/hooks/enforce-epic-worktree-removal-gate-resolution.ps1' = @{
        Function = @('Read-EpicWorktreeGateRunCheckpoint', 'Resolve-EpicWorktreeGateRunTarget')
        Anchor   = @()
    }
    '.claude/hooks/enforce-parallel-worktree-removal-gate.ps1' = @{
        Function = @('Invoke-ParallelWorktreeRemovalGateDecision', 'Get-ParallelWorktreeRemovalTargetDenial')
        Anchor   = @('$prefix = "PARALLEL_WORKTREE_REMOVAL_BLOCKED: ', '-Reason ($prefix + "PARALLEL_WORKTREE_REMOVAL_BLOCKED: git worktree remove for')
    }
    '.claude/lib/worktree-resolution/WorktreeRunResolution.psm1' = @{
        Function = @('Test-WorktreeRunPathEqual')
        Anchor   = @("`$isDrivePath = (`$a -match '^[A-Za-z]:')")
    }
    '.claude/lib/worktree-resolution/WorktreeItemResolution.psm1' = @{
        Function = @('Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'ConvertTo-WorktreeItemResolvedResult', 'Resolve-WorktreeItemTarget')
        Anchor   = @('Export-ModuleMember -Function')
    }
    'tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1' = @{
        Function = @()
        Anchor   = @('emits the unchanged epic block reason', 'WorktreeRoot = ''/synthetic-worktrees/default-session''', '{"features":[]}', '{"route_id":"parallel","items":[]}')
    }
    'tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.WorktreeResolution.Tests.ps1' = @{
        Function = @()
        Anchor   = @('Y3 denies with TARGET_WORKTREE_NOT_DERIVABLE', 'Y6 denies naming WorktreeRunResolution.psm1')
    }
    'tests/scripts/claude-hooks/enforce-epic-merge-gate.WorktreeResolution.Tests.ps1' = @{
        Function = @()
        Anchor   = @('M5 allows a child merge whose checkpoint records no pr_gate, as before the change')
    }
    'tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1' = @{
        Function = @()
        Anchor   = @('Mock Resolve-EpicMergeGateRunTarget { [pscustomobject]@{ Status = ''SessionRoot''')
    }
    'tests/scripts/claude-hooks/enforce-epic-merge-gate.Authorization.Tests.ps1' = @{
        Function = @()
        Anchor   = @('Mock Resolve-EpicMergeGateRunTarget { [pscustomobject]@{ Status = ''SessionRoot''')
    }
    'tests/scripts/claude-hooks/enforce-epic-merge-gate.TriggerScoping.Tests.ps1' = @{
        Function = @()
        Anchor   = @('Mock Resolve-EpicMergeGateRunTarget { [pscustomobject]@{ Status = ''SessionRoot''')
    }
    'tests/scripts/claude-hooks/hook-command-parser.AcceptanceCases.Tests.ps1' = @{
        Function = @()
        Anchor   = @('Mock Resolve-EpicMergeGateRunTarget { [pscustomobject]@{ Status = ''SessionRoot''')
    }
    'tests/scripts/claude-hooks/enforce-pr-author-skill.WorktreeResolution.Tests.ps1' = @{
        Function = @()
        Anchor   = @('$script:OwnBranchCommand = ', '$script:CaptureRoot = ')
    }
    'tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Tests.ps1' = @{
        Function = @()
        Anchor   = @('Eight hook suites', 'each of the eight committed suites')
    }
    'tests/scripts/claude-lib/worktree-resolution/WorktreeRunResolution.Record.Tests.ps1' = @{
        Function = @()
        Anchor   = @('B13 resolves NoTarget')
    }
    'tests/scripts/claude-hooks/enforce-pr-author-skill.Issue824.Tests.ps1' = @{
        Function = @()
        Anchor   = @('WorktreeRoot = (Get-Location).Path', 'Mock Get-PrAuthorBodyFileRoot', '-CheckpointPath ''unused-checkpoint-path''', 'PA-21 returns the current location as the body-file root', 'the receipt, and the body-file root arrive only through mocked seams')
    }
    'tests/scripts/claude-hooks/hook-command-invocation.Issue824Regression.Tests.ps1' = @{
        Function = @()
        Anchor   = @('Mock Get-PrAuthorBodyFileRoot', '-CheckpointPath ''/synthetic/checkpoint.json''')
    }
}
foreach ($path in $targets.Keys) {
    $tokens = $null
    $errors = $null
    $ast = [System.Management.Automation.Language.Parser]::ParseFile((Resolve-Path -LiteralPath $path).Path, [ref] $tokens, [ref] $errors)
    $lines = @(Get-Content -LiteralPath $path)
    Write-Output "FILE path=$path LineCount=$($lines.Count) ParseErrors=$(@($errors).Count)"
    foreach ($name in $targets[$path].Function) {
        $found = $ast.Find({ param($node) $node -is [System.Management.Automation.Language.FunctionDefinitionAst] -and $node.Name -eq $name }, $true)
        if ($null -eq $found) { Write-Output "FUNCTION-MISSING path=$path name=$name"; continue }
        $params = if ($found.Body.ParamBlock) { @($found.Body.ParamBlock.Parameters | ForEach-Object { $_.Name.VariablePath.UserPath }) } else { @() }
        Write-Output "FUNCTION path=$path name=$name start=$($found.Extent.StartLineNumber) end=$($found.Extent.EndLineNumber) params=$($params -join ',')"
    }
    foreach ($text in $targets[$path].Anchor) {
        $hits = @(for ($index = 0; $index -lt $lines.Count; $index++) { if ($lines[$index].Contains($text)) { $index + 1 } })
        if ($hits.Count -eq 0) { Write-Output "ANCHOR-MISSING path=$path text=$text" } else { Write-Output "ANCHOR path=$path lines=$($hits -join ',') text=$text" }
    }
    for ($index = 0; $index -lt $lines.Count; $index++) {
        if ($lines[$index].TrimStart().StartsWith('. (Join-Path $PSScriptRoot')) { Write-Output "DOTSOURCE path=$path line=$($index + 1) text=$($lines[$index].Trim())" }
    }
}
$helpers = @(Get-Content -LiteralPath '.claude/hooks/enforce-pr-author-skill-helpers.ps1')
$start = @(for ($index = 0; $index -lt $helpers.Count; $index++) { if ($helpers[$index].Contains('# Check 1:')) { $index } }) | Select-Object -First 1
$end = @(for ($index = 0; $index -lt $helpers.Count; $index++) { if ($helpers[$index].Contains('# Check 2:')) { $index } }) | Select-Object -First 1
if ($null -ne $start -and $null -ne $end -and $end -gt $start) {
    Write-Output "CHECK1-BLOCK start=$($start + 1) end=$end"
    for ($index = $start; $index -lt $end; $index++) { Write-Output "CHECK1-LINE $($index + 1): $($helpers[$index])" }
} else { Write-Output 'CHECK1-BLOCK-MISSING' }
```

A16 diff-line-count.ps1 (read-only):

```powershell
param([Parameter(Mandatory)][string] $BaseRef, [Parameter(Mandatory)][string[]] $File)
$File = @($File | ForEach-Object { $_ -split ',' } | Where-Object { $_ })
foreach ($target in $File) {
    $diff = @(git diff -U0 $BaseRef -- $target)
    $added = @($diff | Where-Object { $_.StartsWith('+') -and -not $_.StartsWith('+++') }).Count
    $removed = @($diff | Where-Object { $_.StartsWith('-') -and -not $_.StartsWith('---') }).Count
    Write-Output "DIFF-COUNT file=$target added=$added removed=$removed"
}
```

A17 module-load-check.ps1 (read-only; imports a staged module copy from the SW-2b directory, where its sibling modules resolve through `$PSScriptRoot`):

```powershell
param([Parameter(Mandatory)][string] $StageRoot, [Parameter(Mandatory)][string] $ModuleName)
$ErrorActionPreference = 'Stop'
try {
    $module = Import-Module (Join-Path $StageRoot "$ModuleName.psm1") -Force -PassThru
    Write-Output "LOAD-CHECK Module=$ModuleName Imported=True ExportCount=$(@($module.ExportedFunctions.Keys).Count)"
} catch {
    Write-Output "LOAD-CHECK Module=$ModuleName Imported=False Error=$($_.Exception.Message)"
}
```

A18 epic-checkpoint-probe.ps1 (read-only; revision 4, rule EE; run from the worktree root with no arguments). It dot-sources PRA, replaces the six seams that EE-1 mocks with functions returning the same values, evaluates EE-1's command, then also replaces `Get-PrAuthorCheckpointContent` with a function returning `$null` and evaluates the command again. A function defined at script scope after the dot-source shadows both the dot-sourced definition and the module-exported `Invoke-OrchestratorStatePreflight`, the mechanism the revision-3 stop probe (`evidence/other/baseline-red-probe.2026-10-08T23-22.md`) used. Each output line is printed on every run:

```powershell
. (Join-Path (Get-Location).Path '.claude/hooks/enforce-pr-author-skill.ps1')
function Resolve-PrAuthorWorktreeTarget { param([string] $CommandText) [pscustomobject]@{ Status = 'SessionRoot'; WorktreeRoot = (Get-Location).Path; ReasonCode = $null; Detail = 'session root' } }
function Get-PrContextArtifactExistence { $true }
function Invoke-OrchestratorStatePreflight { param([string] $CheckpointPath) @{ HasErrors = $false; ErrorText = '' } }
function Get-PrBodyFileBytes { param([string] $BodyFilePath) [byte[]]@(0x41) }
function Get-PrAuthorReceiptContent { param([string] $ReceiptFilePath) '{"number":12,"sha256":"559aead08264d5795d3909718cdd05abd49572e84fe55590eef31a88a08fdffd","created_at":"2026-06-24T12:00:05Z"}' }
function Get-PrContextSummaryLastWriteUtc { [DateTime]::Parse('2026-06-24T12:00:00Z').ToUniversalTime() }
$json = '{"tool_input":{"command":"gh pr create --title \"foo\" --body-file artifacts/pr_body_12.md"}}'
$decision = Invoke-PrAuthorSkillDecision -ToolInputRaw $json
Write-Output "DECISION=$($decision.hookSpecificOutput.permissionDecision)"
Write-Output "REASON=$($decision.hookSpecificOutput.permissionDecisionReason)"
function Get-PrAuthorCheckpointContent { param([string] $CheckpointPath) $null }
$decisionWithoutCheckpoint = Invoke-PrAuthorSkillDecision -ToolInputRaw $json
Write-Output "DECISION-WITHOUT-CHECKPOINT=$($decisionWithoutCheckpoint.hookSpecificOutput.permissionDecision)"
```

## Appendix I — Acceptance-Criteria Inventory and Traceability (spec line per ID)

| AC | Spec line | Verifying test (suite) | Verified in | Checked in |
| --- | --- | --- | --- | --- |
| AC-01 | 210 | allows an OtherWorktree target whose artifacts exist only in the item worktree (T-PRA-IAR) | P6-T19 | P6-T24 |
| AC-02 | 211 | ignores session-root PR artifacts when the target is another worktree (T-PRA-IAR) | P6-T19 | P6-T24 |
| AC-03 | 212 | reads summary, body, receipt and summary timestamp beneath the resolved item root (T-PRA-IAR) | P6-T19 | P6-T24 |
| AC-04 | 213 | compares receipt freshness against the item worktree summary (T-PRA-IAR) | P6-T19 | P6-T24 |
| AC-05 | 214 | resolves the target once and reuses it for artifacts, preflight and Check 6 (T-PRA-IAR) | P6-T19 | P6-T24 |
| AC-06 | 215 | denies an unresolvable target with the no-target code ahead of PR_CONTEXT_MISSING (T-PRA-IAR) | P6-T19 | P6-T24 |
| AC-07 | 216 | denies an ambiguous target with the ambiguity code ahead of PR_CONTEXT_MISSING (T-PRA-IAR) | P6-T19 | P6-T24 |
| AC-08 | 217 | denies a relative body path for an OtherWorktree target and names the absolute path (T-PRA-IAR) | P6-T19 | P6-T24 |
| AC-09 | 218 | denies an absolute body path outside the resolved root (T-PRA-IAR) | P6-T19 | P6-T24 |
| AC-10 | 219 | applies drive and UNC case-insensitive, POSIX case-sensitive body path comparison (T-PRA-IAR) | P6-T19 | P6-T24 |
| AC-11 | 220 | keeps SessionRoot behavior with absolute artifact paths (T-PRA-IAR) | P6-T19 | P6-T24 |
| AC-12 | 221 | reads epic-scope PR artifacts beneath the epic checkpoint worktree (T-PRA-IAR) | P6-T19 | P6-T24 |
| AC-13 | 222 | performs no resolution for commands without a body file (T-PRA-IAR) | P6-T19 | P6-T24 |
| AC-14 | 223 | SET-PRA existing pr-author suites and OrchestratorState.Tests.ps1 | P6-T21 | P6-T24 |
| AC-15 | 227 | resolves the worktree whose pr_gate records the pull request number (T-WIR-PR) | P4-T9 | P4-T13 |
| AC-16 | 228 | resolves the worktree whose standalone authorization records the pull request number (T-WIR-PR) | P4-T9 | P4-T13 |
| AC-17 | 229 | returns NoTarget when no checkpoint records the number; returns Ambiguous when several checkpoints record the number (T-WIR-PR) | P4-T9 | P4-T13 |
| AC-18 | 230 | reads only through the checkpoint-text seam; exports the item-by-PR resolver (T-WIR-PR) | P4-T9 | P4-T13 |
| AC-19 | 231 | authorizes a standalone merge from the item worktree checkpoint (T-MRG-IR) | P5-T12 | P5-T17 |
| AC-20 | 232 | does not authorize from a session-root copy of another worktree's checkpoint (T-MRG-IR) | P5-T12 | P5-T17 |
| AC-21 | 233 | denies an unresolvable item target with the no-target code (T-MRG-IR) | P5-T12 | P5-T17 |
| AC-22 | 234 | denies an ambiguous item target with the ambiguity code (T-MRG-IR) | P5-T12 | P5-T17 |
| AC-23 | 235 | observes module-scoped WorktreeItemResolution mocks (T-MRG-IR) | P5-T12 | P5-T17 |
| AC-24 | 236 | M6 (merge WorktreeResolution suite); does not resolve an item target for a bare merge command (T-MRG-IR) | P5-T12, P5-T13 | P5-T17 |
| AC-25 | 237 | SET-MRG existing merge-gate suites | P5-T14 | P5-T17 |
| AC-26 | 241 | M5 (merge WorktreeResolution suite); denies a merge when no checkpoint records the pull request number (T-MRG-IR) | P5-T12, P5-T13 | P5-T17 |
| AC-27 | 242 | denies a merge whose pull request number differs from pr_gate (T-MRG-IR) | P5-T12 | P5-T17 |
| AC-28 | 243 | context "child checkpoint pull request binding" (T-MRG-IR) | P5-T12 | P5-T17 |
| AC-29 | 244 | re-checks the binding on the checkpoint the gate reads (T-MRG-IR) | P5-T12 | P5-T17 |
| AC-30 | 248 | B14 compares UNC paths case-insensitively (Record suite) | P1-T9 | P1-T13 |
| AC-31 | 249 | B11, B12, X1 (Record suite) | P1-T9 | P1-T13 |
| AC-32 | 253 | Y7 emits a single leading token when both run kinds are unresolved (parallel WorktreeResolution suite) | P2-T9 | P2-T14 |
| AC-33 | 254 | exact-text row of enforce-parallel-worktree-removal-gate.Tests.ps1 and Y3, both unmodified | P2-T10, P2-T11 | P2-T14 |
| AC-34 | 255 | emits a single leading token when both run kinds are unresolved (T-EREM-DX) | P3-T11 | P3-T16 |
| AC-35 | 259 | names each run kind's status and checkpoint path (T-EREM-DX) | P3-T11 | P3-T16 |
| AC-36 | 260 | names the matched record merge_status; states that no record matched; states that the checkpoint was absent or unparseable (T-EREM-DX) | P3-T11 | P3-T16 |
| AC-37 | 261 | context "diagnostics builder and read result" (T-EREM-DX) | P3-T11 | P3-T16 |
| AC-38 | 262 | existing removal suites and CleanupWorktreeManifestGateMatrix.Tests.ps1 pass; exact-text row only appended | P3-T12, P3-T13 | P3-T16 |
| AC-39 | 266 | test_bundled_claude_payload_contains_all_repo_runtime_contracts (KL-510) plus A10 MP-ALL | P8-T16, P8-T18 | P8-T20 |
| AC-40 | 267 | test_push_down_claude_pack_manifest_completeness.py | P8-T16 | P8-T20 |
| AC-41 | 268 | WorktreeResolution.Manifest.Tests.ps1 | P8-T11 | P8-T20 |
| AC-42 | 269 | test_push_down_codex_and_agents_resource_contracts.py plus scope check | P8-T16, P8-T17 | P8-T20 |
| AC-43 | 273 | enforcement-hooks-no-python-invocation.Tests.ps1 | P8-T12 | P8-T20 |
| AC-44 | 274 | keeps every changed file within the line cap (T-CONS) | P7-T7 | P7-T8 |
| AC-45 | 275 | uses no temporary files and no host paths (T-CONS) plus the added-lines scan | P7-T7, P8-T15 | P7-T8 |
| AC-46 | 276 | Pester coverage runs CG-PRA, CG-MRG, CG-EREM, CG-PREM, CG-LIB | P8-T4 to P8-T9 | P8-T20 |
| AC-47 | 277 | enforce-gate-suites.EpicStateIsolation.Tests.ps1 | P6-T20 | P6-T24 |

## Appendix J — Wiring Log (WLOG) Format

`FEATURE/evidence/qa-gates/gate-wiring-order.md` is created by P1-T5 and starts with `Timestamp:`, `Command: SW procedure (LH-2) and per-phase A2 runs`, `EXIT_CODE: 0`, and `Output Summary:` (updated at each append to state the latest entry). Each SW entry is one table row: sequence number, task ID, file written, the SW-2 `STAGE-CHECK` line, SW-4 hash equality, timestamp, and the reason when it is a corrective re-Write. Suite-result entries record the task, the suite-set name, `TotalCount=`, `PassedCount=`, and `FailedCount=`. Entries are appended with the Edit tool (WLOG is Markdown under FEATURE and is not a live file).

## Planner Internal Review Record

PLANNER-INTERNAL-REVIEW: PASS
CITATION-TO-TREE: PASS
AC-TRACEABILITY: PASS
SCOPE-BOUNDARY: PASS
CITATION: .claude/hooks/enforce-pr-author-skill.ps1 | Get-PrContextArtifactExistence lines 55-67; probe line 185; Test-PrAuthorBypassRequired lines 239-261
CITATION: .claude/hooks/enforce-pr-author-skill-helpers.ps1 | Get-PrAuthorTargetCheckpointResolution 74-121; Get-PrAuthorBodyFileRoot 123-138; Get-PrAuthorBodyFileValue 140-176 (Get-CommandLineFlagValue call 164, rooted relativization 168-170); Test-PrAuthorReceiptVerification 178-301; Check 1 block 224-235; Check 2 anchor 237; summary call 289; Get-PrAuthorBypassReason 303-441; Case C line 390; Resolve-EpicScopeCheckpoint 401; target resolution 413; receipt call 434; 441 lines
CITATION: .claude/hooks/hook-command-invocation.ps1 | operands dot-source line 24; Test-CommandLineInvocation 427-455; 482 lines
CITATION: .claude/hooks/hook-command-invocation-operands.ps1 | Get-CommandLineFlagValue 70-123; Test-CommandLineFlag 125-156; Resolve-CommandLineInvocationTarget 158-198
CITATION: .claude/hooks/enforce-epic-merge-gate.ps1 | Invoke-EpicMergeGateDecision 292-406; child read line 362; unresolved call line 400
CITATION: .claude/hooks/enforce-epic-merge-gate-resolution.ps1 | import guard 30-36; Test-ChildCheckpointPrGateBinding 152-189; Get-EpicMergeGateUnresolvedReason 191-221
CITATION: .claude/hooks/enforce-epic-merge-gate-authorization.ps1 | Test-StandalonePositiveJsonInteger line 86
CITATION: .claude/hooks/enforce-epic-worktree-removal-gate.ps1 | Invoke-EpicWorktreeRemovalGateDecision 277-335 (target loop 328-333); Get-EpicWorktreeRemovalTargetDenial 337-399; final deny 393-398 (prefix 396, return 398); 452 lines
CITATION: .claude/hooks/enforce-epic-worktree-removal-gate-resolution.ps1 | Read-EpicWorktreeGateRunCheckpoint 115-144
CITATION: .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 | Invoke-ParallelWorktreeRemovalGateDecision 277-336 (target loop 329-334); Get-ParallelWorktreeRemovalTargetDenial 338-411; final deny 405-410 (prefix 408, return 410); 464 lines
CITATION: .claude/lib/worktree-resolution/WorktreeRunResolution.psm1 | Test-WorktreeRunPathEqual 342-358; 497 lines
CITATION: .claude/lib/worktree-resolution/WorktreeItemResolution.psm1 | Get-WorktreeItemCheckpointText 131-149; export list 398-407
CITATION: .claude/lib/worktree-resolution/EpicScopeResolution.psm1 | CheckpointPath composition line 360; WorktreeRoot effectiveRoot line 380
CITATION: .claude/hooks/enforce-batch-budget-route.ps1 | Get-BatchBudgetSelectedRoute lines 55-92; Test-BatchBudgetLargePathRoute line 94
CITATION: .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 | epic-scope dot-source line 25; import-failure deny lines 310-311
CITATION: .claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1 | import guard lines 41-50 (WIR, WRR, ESR with -Force)
CITATION: .claude/settings.json | preimplementation gate under Bash line 107, Write|Edit line 152, Agent line 185; pr-author line 103, merge line 111, removal gates lines 115 and 119 under Bash only
CITATION: .claude/lib/worktree-resolution/WorktreeRunResolution.psm1 | sibling imports lines 31-33; seven exports lines 490-497 (re-derived in revision 2 for P1-T3 ExportCount=7)
CITATION: .claude/lib/worktree-resolution/WorktreeItemResolution.psm1 | sibling imports lines 31-32; nine exports lines 398-407 (re-derived in revision 2 for P4-T3 ExportCount=10)
CITATION: .gitignore | .claude/agent-memory line 69 (untracked memory files never appear in CMD-GIT-STATUS, so the P0-T10 FEATURE-only status condition holds alongside the P0-T8 tolerance)
CITATION: .claude/hooks/enforce-pr-author-skill-helpers.ps1 | Test-PrAuthorReceiptVerification params lines 213-222; Get-PrAuthorBypassReason params lines 325-331
CITATION: .claude/hooks/enforce-pr-author-skill.ps1 | Get-PrContextArtifactExistence param() line 64; Get-PrContextSummaryLastWriteUtc param() line 137; Test-PrAuthorBypassRequired params lines 252-258
CITATION: .claude/hooks/enforce-epic-merge-gate-resolution.ps1 | Resolve-EpicMergeGateRunTarget params 144-147; Test-ChildCheckpointPrGateBinding params 169-172; Get-EpicMergeGateUnresolvedReason params 207-210
CITATION: .claude/hooks/enforce-epic-worktree-removal-gate-resolution.ps1 | Resolve-EpicWorktreeGateRunTarget params 107-110; Read-EpicWorktreeGateRunCheckpoint params 128-131
CITATION: tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.WorktreeResolution.Tests.ps1 | Y3 line 103; Y6 line 147
CITATION: tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1 | default run-target mock line 12
CITATION: tests/scripts/claude-hooks/enforce-epic-merge-gate.Authorization.Tests.ps1 | default run-target mock line 75
CITATION: tests/scripts/claude-hooks/enforce-epic-merge-gate.TriggerScoping.Tests.ps1 | default run-target mock line 39
CITATION: tests/scripts/claude-hooks/hook-command-parser.AcceptanceCases.Tests.ps1 | default run-target mock line 69
CITATION: tests/scripts/claude-hooks/enforce-pr-author-skill.WorktreeResolution.Tests.ps1 | $script:CaptureRoot line 64; $script:OwnBranchCommand line 67
CITATION: tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1 | 'returns null for allowed command' line 329; 'returns false for an allowed command' line 375; -ContextExists on 6 lines (330, 335, 340, 376, 381, 386)
CITATION: tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1 | revision 4: Context 'allowed commands' 135-204; BeforeEach 136-149; Get-PrContextSummaryLastWriteUtc mock line 148; EE-1 row 151-155 (assertion 154); Get-PrAuthorCheckpointContent mocks lines 306, 326, 372 (count 3)
CITATION: .claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1 | revision 4: Get-PrAuthorCheckpointContent 17-48; Test-EpicBaseBranchOverride 50-144; gh pr create scope test line 92; seam call line 107; EPIC_BASE_BRANCH_MISMATCH return line 140
CITATION: .claude/hooks/enforce-pr-author-skill-helpers.ps1 | revision 4: Check 6 call to Test-EpicBaseBranchOverride line 295
CITATION: .claude/hooks/enforce-pr-author-skill.ps1 | revision 4: OrchestratorState.psm1 import line 53; PRAE dot-source line 146; decision call line 186
CITATION: artifacts/orchestration/orchestrator-state.json | revision 4: "epic_mode": true at line 5 (gitignored local checkpoint; read only)
CITATION: tests/scripts/claude-hooks/hook-command-consumers.Issue824.Tests.ps1 | revision 4: Get-PrAuthorCheckpointContent mock line 98 before the Test-EpicBaseBranchOverride call line 107
CITATION: tests/scripts/claude-runtime/enforcement-hooks-checkpoint-path-explicit.Tests.ps1 | revision 4: static call-site rows lines 72-101; no decision executed
CITATION: docs/features/active/2026-10-08-pr-author-and-merge-gates-read-session-root-files-850/evidence/other/baseline-red-stop.2026-10-08T23-23.md | revision 4: StopCode BASELINE-RED-IN-EDITED-SUITE; FAILED line 15; FAILED-FILE line 16; SET-PRA 247/246/1 line 6
CITATION: docs/features/active/2026-10-08-pr-author-and-merge-gates-read-session-root-files-850/evidence/other/baseline-red-probe.2026-10-08T23-22.md | revision 4: DECISION=deny line 11; REASON=EPIC_BASE_BRANCH_MISMATCH line 12
CITATION: docs/features/active/2026-10-08-pr-author-and-merge-gates-read-session-root-files-850/evidence/other/c1a-reverification.2026-10-08T22-39.md | stop record; A15 output; CHECK1-FORM rewritten-by-c1a
CITATION: tests/scripts/claude-hooks/enforce-pr-author-skill.TargetResolution.Tests.ps1 | -ContextExists on 5 lines (52, 69, 83, 96, 110)
CITATION: tests/scripts/claude-hooks/enforce-pr-author-skill.Issue824.Tests.ps1 | -ContextExists lines 135, 139, 146, 149; SessionRoot mock 92-94; Get-PrAuthorBodyFileRoot mock 97; PA-24 call 126; PA-21 context 156-160; header line 17; 161 lines
CITATION: tests/scripts/claude-hooks/hook-command-invocation.Issue824Regression.Tests.ps1 | -ContextExists lines 184, 192, 200, 208; Get-PrAuthorBodyFileRoot mock 217; REG-13 to REG-17 calls 221, 227, 233, 239, 245; REG-15 Because 235; 284 lines
CITATION: .gitignore | /artifacts line 6
CITATION: extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json | epic-base-branch entry line 50; HCIO entry line 59; worktree-resolution modules 198-203
CITATION: tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1 | exact-text row 480-488; manifest Describe mocks 439, 445-446
CITATION: tests/scripts/claude-hooks/enforce-epic-merge-gate.WorktreeResolution.Tests.ps1 | M5 127-137
CITATION: tests/scripts/claude-lib/worktree-resolution/WorktreeRunResolution.Record.Tests.ps1 | B11 217-226; B12 228-237; X1 419-432
CITATION: tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Tests.ps1 | guard list 38-47; "Eight hook suites" line 9; "parses each of the eight committed suites" line 15
CITATION: tests/scripts/claude-lib/worktree-resolution/WorktreeRunResolution.Record.Tests.ps1 | B13 line 239
CITATION: docs/features/active/2026-10-08-pr-author-and-merge-gates-read-session-root-files-850/spec.md | Acceptance Criteria heading line 204; AC lines 210-277; AC-14 suite list line 223; AC-25 suite list line 237; AC-33 suite list line 254; AC-38 suite list line 262; AC-41 suite line 268
CITATION: tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Tests.ps1 | file exists; BASELINE-GREEN member via AC-33; runs in SET-REM (P0-T19)
CITATION: tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.TriggerScoping.Tests.ps1 | file exists; BASELINE-GREEN member via AC-38; runs in SET-REM (P0-T19)
CITATION: tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.WorktreeResolution.Tests.ps1 | file exists; BASELINE-GREEN member via AC-38; runs in SET-REM (P0-T19)
CITATION: tests/scripts/claude-hooks/CleanupWorktreeManifestGateMatrix.Tests.ps1 | file exists; BASELINE-GREEN member via AC-38; runs in SET-REM (P0-T19)
CITATION: tests/scripts/claude-lib/worktree-resolution/WorktreeResolution.Manifest.Tests.ps1 | file exists; BASELINE-GREEN member via AC-41; runs in SET-LIB folder (P0-T20)
AC-INVENTORY: AC-01, AC-02, AC-03, AC-04, AC-05, AC-06, AC-07, AC-08, AC-09, AC-10, AC-11, AC-12, AC-13, AC-14, AC-15, AC-16, AC-17, AC-18, AC-19, AC-20, AC-21, AC-22, AC-23, AC-24, AC-25, AC-26, AC-27, AC-28, AC-29, AC-30, AC-31, AC-32, AC-33, AC-34, AC-35, AC-36, AC-37, AC-38, AC-39, AC-40, AC-41, AC-42, AC-43, AC-44, AC-45, AC-46, AC-47
AC-MAPPING: AC-01 | IMPLEMENTATION: B8 B9 B10 | TESTS: T-PRA-IAR row 1 | EVIDENCE: P6-T19
AC-MAPPING: AC-02 | IMPLEMENTATION: B9 Case C | TESTS: T-PRA-IAR row 2 | EVIDENCE: P6-T19
AC-MAPPING: AC-03 | IMPLEMENTATION: B9 B10 | TESTS: T-PRA-IAR row 3 | EVIDENCE: P6-T19
AC-MAPPING: AC-04 | IMPLEMENTATION: B9 Check 5 | TESTS: T-PRA-IAR row 4 | EVIDENCE: P6-T19
AC-MAPPING: AC-05 | IMPLEMENTATION: B8 Resolve-PrAuthorArtifactRoot | TESTS: T-PRA-IAR row 5 | EVIDENCE: P6-T19
AC-MAPPING: AC-06 | IMPLEMENTATION: B9 precedence | TESTS: T-PRA-IAR row 6 | EVIDENCE: P6-T19
AC-MAPPING: AC-07 | IMPLEMENTATION: B9 precedence | TESTS: T-PRA-IAR row 7 | EVIDENCE: P6-T19
AC-MAPPING: AC-08 | IMPLEMENTATION: B8 Get-PrAuthorBodyPathBindingReason | TESTS: T-PRA-IAR row 8 | EVIDENCE: P6-T19
AC-MAPPING: AC-09 | IMPLEMENTATION: B8 Get-PrAuthorBodyPathBindingReason | TESTS: T-PRA-IAR row 9 | EVIDENCE: P6-T19
AC-MAPPING: AC-10 | IMPLEMENTATION: B8 Test-PrAuthorBodyPathEqual | TESTS: T-PRA-IAR row 10 | EVIDENCE: P6-T19
AC-MAPPING: AC-11 | IMPLEMENTATION: B8 B9 | TESTS: T-PRA-IAR row 11 | EVIDENCE: P6-T19
AC-MAPPING: AC-12 | IMPLEMENTATION: B8 Get-PrAuthorEpicArtifactRoot | TESTS: T-PRA-IAR row 12 | EVIDENCE: P6-T19
AC-MAPPING: AC-13 | IMPLEMENTATION: B9 Cases A and B unchanged | TESTS: T-PRA-IAR row 13 | EVIDENCE: P6-T19
AC-MAPPING: AC-14 | IMPLEMENTATION: B9 B10 and C10-C12, C15, C16 | TESTS: SET-PRA | EVIDENCE: P6-T21
AC-MAPPING: AC-15 | IMPLEMENTATION: B5 | TESTS: T-WIR-PR row 1 | EVIDENCE: P4-T9
AC-MAPPING: AC-16 | IMPLEMENTATION: B5 | TESTS: T-WIR-PR row 2 | EVIDENCE: P4-T9
AC-MAPPING: AC-17 | IMPLEMENTATION: B5 | TESTS: T-WIR-PR rows 3 and 4 | EVIDENCE: P4-T9
AC-MAPPING: AC-18 | IMPLEMENTATION: B5 | TESTS: T-WIR-PR rows 5 and 6 | EVIDENCE: P4-T9
AC-MAPPING: AC-19 | IMPLEMENTATION: B6 B7 | TESTS: T-MRG-IR row 1 | EVIDENCE: P5-T12
AC-MAPPING: AC-20 | IMPLEMENTATION: B5 B7 | TESTS: T-MRG-IR row 2 | EVIDENCE: P5-T12
AC-MAPPING: AC-21 | IMPLEMENTATION: B6 Get-EpicMergeGateUnresolvedReason | TESTS: T-MRG-IR row 3 | EVIDENCE: P5-T12
AC-MAPPING: AC-22 | IMPLEMENTATION: B6 Get-EpicMergeGateUnresolvedReason | TESTS: T-MRG-IR row 4 | EVIDENCE: P5-T12
AC-MAPPING: AC-23 | IMPLEMENTATION: B6 import guard | TESTS: T-MRG-IR row 5 | EVIDENCE: P5-T12
AC-MAPPING: AC-24 | IMPLEMENTATION: B7 bare-command path | TESTS: M6 and T-MRG-IR row 6 | EVIDENCE: P5-T12 P5-T13
AC-MAPPING: AC-25 | IMPLEMENTATION: B6 B7 and DT-ITEM | TESTS: SET-MRG | EVIDENCE: P5-T14
AC-MAPPING: AC-26 | IMPLEMENTATION: B6 binding and B5 | TESTS: M5 and T-MRG-IR row 7 | EVIDENCE: P5-T12 P5-T13
AC-MAPPING: AC-27 | IMPLEMENTATION: B6 binding | TESTS: T-MRG-IR row 8 | EVIDENCE: P5-T12
AC-MAPPING: AC-28 | IMPLEMENTATION: B6 binding | TESTS: T-MRG-IR rows 11-16 | EVIDENCE: P5-T12
AC-MAPPING: AC-29 | IMPLEMENTATION: B7 binding re-check | TESTS: T-MRG-IR row 9 | EVIDENCE: P5-T12
AC-MAPPING: AC-30 | IMPLEMENTATION: B1 | TESTS: B14 | EVIDENCE: P1-T9
AC-MAPPING: AC-31 | IMPLEMENTATION: B1 | TESTS: B11 B12 X1 | EVIDENCE: P1-T9
AC-MAPPING: AC-32 | IMPLEMENTATION: B2 | TESTS: Y7 | EVIDENCE: P2-T9
AC-MAPPING: AC-33 | IMPLEMENTATION: B2 | TESTS: parallel exact-text row and Y3 | EVIDENCE: P2-T10 P2-T11
AC-MAPPING: AC-34 | IMPLEMENTATION: B4 | TESTS: T-EREM-DX row 1 | EVIDENCE: P3-T11
AC-MAPPING: AC-35 | IMPLEMENTATION: B3 B4 | TESTS: T-EREM-DX row 2 | EVIDENCE: P3-T11
AC-MAPPING: AC-36 | IMPLEMENTATION: B3 B4 | TESTS: T-EREM-DX rows 3-5 | EVIDENCE: P3-T11
AC-MAPPING: AC-37 | IMPLEMENTATION: B3 | TESTS: T-EREM-DX rows 6-8 | EVIDENCE: P3-T11
AC-MAPPING: AC-38 | IMPLEMENTATION: B4 decision unchanged | TESTS: SET-REM and C4 | EVIDENCE: P3-T12 P3-T13
AC-MAPPING: AC-39 | IMPLEMENTATION: cp mirrors | TESTS: test_bundled_claude_payload_contains_all_repo_runtime_contracts | EVIDENCE: P8-T16 P8-T18
AC-MAPPING: AC-40 | IMPLEMENTATION: P6-T15 CORE entry | TESTS: test_push_down_claude_pack_manifest_completeness.py | EVIDENCE: P8-T16
AC-MAPPING: AC-41 | IMPLEMENTATION: WIR mirror and D3 | TESTS: WorktreeResolution.Manifest.Tests.ps1 | EVIDENCE: P8-T11
AC-MAPPING: AC-42 | IMPLEMENTATION: LH-5 no Codex edit | TESTS: test_push_down_codex_and_agents_resource_contracts.py | EVIDENCE: P8-T16 P8-T17
AC-MAPPING: AC-43 | IMPLEMENTATION: PowerShell-only changes | TESTS: enforcement-hooks-no-python-invocation.Tests.ps1 | EVIDENCE: P8-T12
AC-MAPPING: AC-44 | IMPLEMENTATION: line budgets B1-B10 | TESTS: T-CONS row 1 | EVIDENCE: P7-T7
AC-MAPPING: AC-45 | IMPLEMENTATION: Appendix C conventions and D9 | TESTS: T-CONS row 2 and A13 scan | EVIDENCE: P7-T7 P8-T15
AC-MAPPING: AC-46 | IMPLEMENTATION: Appendix C rows | TESTS: CG-PRA CG-MRG CG-EREM CG-PREM CG-LIB | EVIDENCE: P8-T4 to P8-T9
AC-MAPPING: AC-47 | IMPLEMENTATION: C13 | TESTS: enforce-gate-suites.EpicStateIsolation.Tests.ps1 | EVIDENCE: P6-T20
UNRESOLVED-GAPS: NONE
DIRECTIVE: PREFLIGHT VALIDATION ONLY
