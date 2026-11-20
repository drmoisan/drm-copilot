# Stage I Chain Fix for Derived Created Paths (P2-T3)

Timestamp: 2026-11-08T17-43
Command: sh SCRATCH/issue-1097-i-fix-check.sh (copies the HEAD text of scripts/dev-tools/ProcessReductionChain.psm1 and scripts/dev-tools/ProcessReductionLedger.psm1 to SCRATCH/prefix/, runs SCRATCH/issue-1097-i-fix-probe.ps1 once with the pre-fix module and once with the fixed module, each in its own pwsh process over Read-ProcessReductionChainInput of the worktree, then compares the two outputs with SCRATCH/issue-1097-i-fix-check.ps1)
EXIT_CODE: 0
Output Summary:
  Pre-change coverage figure: scripts/dev-tools/ProcessReductionChain.psm1 100% (238 of 238), read from the merged artifacts/pester/powershell-coverage.xml written by the P0-T2 run (last write before the first P3-T2 attempt, which failed and wrote no merged artifact).
  Change: Invoke-ProcessReductionPatchStep, derived-path branch only. When the hunk group of a derived path holds a create hunk, the state is set absent and Add-ProcessReductionTouch records the touch with an empty pre-image, with no hunk-text comparison; modify and delete hunks on derived paths stay skipped. .SYNOPSIS and .DESCRIPTION state both cases. No other function, export, or parameter changed.
  New rows in Describe 'Invoke-ProcessReductionChain': PRC-CHAIN-DERIVED-CREATED-COPY-ENDS-ABSENT (-ForEach over a copy hunk equal to the source text and a stale copy hunk) and PRC-CHAIN-DERIVED-MODIFIED-BUNDLE-SKIPPED. A chain replay of the same inputs (SCRATCH/issue-1097-i-rows.ps1, not a test run) gives the copy absent after the fix and present before it, and the stale modify hunk skipped in both.
  (a) Create hunks on derived paths in the stored patches of entries 0001 to 0009: none (0 of the 4 older stored patches). Patch 0010 holds 2: the two created bundle copies.
  (b) Fixed module, entries 0001 to 0010: the full chain and each of the 10 -StopBefore sub-chains return IsValid True with 0 errors (11 runs). Created files at the end of the full chain: 17, present 0 (the PRC-LEDGER-END-STATE-RECORDED condition).
  (c) Pre-fix and fixed module over the same input: Errors equal (all runs clean in both). FinalText covers 357 paths; 2 differ, exactly extensions/drm-copilot/resources/claude-customizations/.claude/hooks/epic-wave-barrier-early-start.ps1 and extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/epic-wave-barrier-early-start.ps1, present before the fix and absent after it.
  Patch rule: the stored patch equals git diff --cached --binary --no-renames HEAD over the 37 patch paths (cmp equal); no patch path changed in this task, so the patch was not regenerated. The sentence of entry 0010 ## Stored Patch on derived paths now states the rule; the entry lies outside the patch and stays uncommitted until P3-T5.
  File size: ProcessReductionChain.psm1 596 lines, ProcessReductionChain.Tests.ps1 560 lines (both under 700).
  RESULT_OK=True
