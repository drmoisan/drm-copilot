# Pester final gate, run 1 (issue #1157, P6-T5)

Timestamp: 2026-11-11T05-28
Command: sh SCRATCH/issue-1157-pester.sh (pwsh 7: Import-Module scripts/powershell/PoshQC/PoshQC.psd1; Invoke-PoshQCParallelTest -Root <item worktree>)
EXIT_CODE: 1
Output Summary:
- Invoke-PoshQCParallelTest: workers=8; wall-clock=1367.43s; ExitCode 1. Shards 1, 3, and 6 exited non-zero (20, 2, and 2 failed tests); shards 2, 4, 5, 7, and 8 exited 0. No merged JUnit or coverage file was written, so this run supplies no pass count or coverage figure.
- Failures, all caused by this item and fixed before the re-run:
  - 20 rows of `discovery guard (both hook surfaces).AC-4 <suite> complies with the baseline isolation form for every closure seam` (tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1): the new read seams `Read-OrchestratorOutputOwnerPassDownText` (validate-orchestrator-output closure) and `Read-OwnerDirectiveFileText` (pass-down hook closure), and the module seams the pass-down hook imports, had no null mock in the outermost BeforeAll of 20 hook suites. Fix: one baseline null mock per new seam added to the outermost BeforeAll of each of those suites; no assertion changed.
  - 2 rows of `hook dependency guard structural completeness (issue #786).S6` (repository and mirror) for `.claude/hooks/enforce-owner-directive-pass-down.ps1`: rule R-DECISION selected the helper `Get-OwnerDirectivePassDownAckDecision` as the decision function. Fix: the three mode helpers were renamed `Resolve-OwnerDirectivePassDownAck`, `Resolve-OwnerDirectivePassDownCoordinator`, and `Resolve-OwnerDirectivePassDownRelay`, so `Get-OwnerDirectivePassDownDecision` is the decision function; the bundle copy was re-copied.
  - 2 rows of `Committed process-reduction ledger chain` (PRC-LEDGER-CHAIN-HOLDS, PRC-LEDGER-SUBCHAIN-HOLDS; tests/scripts/dev-tools/ProcessReductionChain.Ledger.Tests.ps1): the P6-T2 digest edit landed inside the recorded hunk of `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` in `docs/engineering/process-reductions/patches/0010-early-dependent-starts.patch`. Fix: that hunk was regenerated to carry the #1157 paragraph as context and the new digest in both images, per the ledger README rule for edits inside a recorded region.
- Pre-existing failures: none observed. The gate is re-run after the fixes.
