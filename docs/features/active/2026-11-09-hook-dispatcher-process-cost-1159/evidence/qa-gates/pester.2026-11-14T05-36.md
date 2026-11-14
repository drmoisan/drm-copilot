# Final Pester gate, run 1 ([P7-T4])

Timestamp: 2026-11-14T05-36
Command: sh SCRATCH/issue-1159-pester.sh (pwsh 7: Import-Module scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCParallelTest -Root <repository root>; exit with the returned ExitCode); started 2026-11-14T05-21
EXIT_CODE: 1
Output Summary: workers=8, wall-clock 795.88s, exit code 1. Shards 1, 2 and 4-8 exited 0; shard 3 exited 2 with 3527 passed, 2 failed, 1 skipped (shard log). Because a shard failed, no merged JUnit or coverage file was written, so no repo-wide counts or coverage are read from this run. Failed tests: 'Committed process-reduction ledger chain.PRC-LEDGER-CHAIN-HOLDS reverts every entry newest-first with no error' and 'PRC-LEDGER-SUBCHAIN-HOLDS reverts the newer entries and later landings before each stored patch with no error' (tests/scripts/dev-tools/ProcessReductionChain.Ledger.Tests.ps1), both reporting '0010-early-dependent-starts.md: .claude/hooks/enforce-epic-wave-barrier.ps1: Current text of the hunk at +53 ... was not found'.

## Cause and fix
The 0010 stored patch (regenerated on main by issue 1157 and brought in by the main sync) carries as hunk context the two guarded Import-Module lines of .claude/hooks/enforce-epic-wave-barrier.ps1 with -Force, which [P3-T2] removed on this branch (D6). Fix: the context lines of that hunk and of its bundle-copy hunk in docs/engineering/process-reductions/patches/0010-early-dependent-starts.patch now carry the edit in both images (README '## Entry Format': an edit inside a recorded region regenerates the hunk), committed with 'reduction: 0010' in the subject. tests/scripts/dev-tools/ProcessReductionChain.Ledger.Tests.ps1 then passed 5 of 5 (debugging run, not evidence). The loop restarts from [P7-T2].
