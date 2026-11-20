# Pester Phase 0 baseline (issue #1157)

Timestamp: 2026-11-10T04-02
Command: sh SCRATCH/issue-1157-pester.sh baseline (pwsh 7: Import-Module scripts/powershell/PoshQC/PoshQC.psd1; Invoke-PoshQCParallelTest -Root <item worktree>), then sh SCRATCH/issue-1157-pester-summary.sh (Merge-PoshQCJunitReport and Merge-PoshQCCoverageReport over the eight shard outputs under artifacts/pester/parallel/)
EXIT_CODE: 1
Output Summary:
- Invoke-PoshQCParallelTest: workers=8; wall-clock=2257.81s; ExitCode 1 (shard 8 exited 1; shards 1-7 exited 0). The merged artifacts/pester/pester-junit.xml and powershell-coverage.xml were not written by the run, so the counts and coverage below come from merging the eight shard JUnit and coverage files with the PoshQC merge functions.
- Test cases: 21216; passed 21205; failed 1; skipped 10.
- Failed test (not pre-existing): "OrchestratorState core.json manifest membership.registers every on-disk orchestrator-state module so none is unregistered" (tests/scripts/claude-lib/orchestrator-state/OrchestratorState.Manifest.Tests.ps1). Cause: the new module .claude/lib/orchestrator-state/OrchestratorStateOwnerDirectiveDecision.psm1 of this item was written to disk while the run was in progress; the suite scans the folder at test time. P4-T2 registers the module. The suite passes on the pre-change tree.
- Pre-existing failures on the pre-change tree: none observed in this run.
- Repo-wide line coverage: 95.80% (37492/39137).
- .claude/lib/orchestrator-state/OrchestratorStateOwnerDirectives.psm1: 100.00% (151/151).
- .claude/hooks/validate-orchestrator-output.ps1: 99.30% (141/142).
