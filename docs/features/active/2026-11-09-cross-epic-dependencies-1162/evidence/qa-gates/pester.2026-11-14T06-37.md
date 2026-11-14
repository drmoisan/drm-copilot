# Pester gate, first pass (P5-T6) - FAILED

Timestamp: 2026-11-14T05-56
Command: sh SCRATCH/issue-1162-pester-gate.sh (pwsh 7: Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCParallelTest -Root <worktree root>; exit with the returned ExitCode)
EXIT_CODE: 1
Output Summary:
- One Invoke-PoshQCParallelTest run: workers=8, wall-clock 857.69 s, ended 2026-11-14T06-11. Shards 1 to 5 and 8 exited 0; shard 6 exited 1 and shard 7 exited 2; no merged JUnit or coverage artifact was written, so no coverage figure exists for this pass.
- Shard 6 (Tests Passed 3509, Failed 1): enforcement hooks must not invoke Python.repository scan.reports no Python invocation beyond the allowlist across the guarded tree - six [DynamicInvocation] sites `& $usage` in Invoke-EpicCrossReadinessCommand of .claude/lib/epic-wave/EpicCrossDependency.psm1 (Phase 1 code of this item).
- Shard 7 (Tests Passed 3305, Failed 2, Skipped 2): Committed process-reduction ledger chain.PRC-LEDGER-CHAIN-HOLDS and PRC-LEDGER-SUBCHAIN-HOLDS - entry 0010-early-dependent-starts.md: hunks of its stored patch no longer apply in nine files, because this item edited text inside or adjacent to the entry's recorded regions (and edited the created file epic-orchestrator-state-wave-barrier.ts).

## Fixes (related findings fixed inside this item)

1. .claude/lib/epic-wave/EpicCrossDependency.psm1: the `$usage` scriptblock is replaced by the private function ConvertTo-EpicCrossUsageResult (not exported); every usage return calls it by name. Behavior and the EPIC_CROSS_READINESS_USAGE: text are unchanged. Both bundle copies were re-copied byte-identically.
2. docs/engineering/process-reductions/patches/0010-early-dependent-starts.patch: the sections for the nine files, and the six byte-identical bundle-copy sections, were regenerated per README `## Revert Order` so each hunk carries this item's edit in both images. Method (SCRATCH scripts): T0 = origin/main (entry 0011 touches none of these paths); P0 = T0 with the 0010 section reversed; P1 = git merge-file of the reversal onto the current file, with adjacency conflicts resolved by dropping only 0010's lines and keeping this item's lines; the two pinned digest lines take the pre-0010 values the entry already recorded; the created TypeScript file keeps a create section with the current content. New section = git diff --full-index P1 to the current file. A check that P0-to-P1 equals this item's own edit lines held for six files exactly; the epic-run skills differ only by the split sentence and the surface-expectations file only by the digest lines.

## Fix check

sh SCRATCH/issue-1162-tc.sh over the five ProcessReduction* Pester files, enforcement-hooks-no-python-invocation.Tests.ps1, and tests/scripts/claude-lib/epic-wave: 361 passed, 0 failed (2026-11-14T06-36). A first attempt of that check blocked inside Invoke-ScriptAnalyzer and was stopped after about 18 minutes; the analyzer then ran on the same file alone in 2.7 s with 0 findings.

The gate is re-run from step 1 of the PowerShell loop; that pass writes a new pester.<timestamp>.md.
