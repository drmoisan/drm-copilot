# Pester Phase 0 Baseline (parallel gate) - issue 1114

Timestamp: 2026-11-07T19-23
Command: sh SCRATCH/issue-1114-pester.sh baseline (PowerShell 7 in the item worktree: Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; $r = Invoke-PoshQCParallelTest -Root <item worktree>; exit $r.ExitCode); figures read by sh SCRATCH/issue-1114-figures.sh baseline merged
EXIT_CODE: 0
Output Summary:
- Returned ExitCode: 0 (8 workers, all 8 shards exit 0; wall clock 1374.61 s). The run is fully green, so the merged reports were read.
- Source: artifacts/pester/pester-junit.xml and artifacts/pester/powershell-coverage.xml written by this run.
- JUnit counts: 15881 tests; 15871 passed; 0 failed; 0 errors; 10 skipped.
- Failing test names: none.
- Repo-wide PowerShell line coverage: 94.06% (24269 covered, 1532 missed).
- `.codex/hooks/validate-feature-review-coverage.ps1`: 100.00% line coverage (163 covered, 0 missed).
- `.codex/hooks/hook-target-worktree.ps1`: 99.33% line coverage (149 covered, 1 missed: the default `WorktreeListInvoker` line of `Resolve-HookTargetWorktree`).
- `.codex/hooks/validate-feature-review-coverage-freshness.ps1`: N/A - new file (created by [P1-T1]).
- `.codex/hooks/feature-review-coverage-target.ps1`: N/A - new file (created by [P1-T2]).
- Suites of interest (all 0 failures): codex-hooks `validate-feature-review-coverage.Coverage.Tests.ps1` (35), `legacy-codex-hook-contracts.Tests.ps1` (43), `hook-dependency-failure.Codex.Tests.ps1` (90), `feature-review-coverage-narrowing-parity.Tests.ps1` (66), `feature-review-coverage-floor-parity.Tests.ps1` (4), `hook-target-worktree.Tests.ps1` (83); claude-hooks `validate-feature-review-coverage-freshness.Tests.ps1` (18), `validate-feature-review-coverage.Tests.ps1` (28), `validate-feature-review-coverage.TargetWorktree.Tests.ps1` (21), `validate-feature-review-coverage.Coverage.Tests.ps1` (73); claude-runtime `enforcement-hooks-no-python-invocation.Tests.ps1` (33), `hook-dependency-guard-completeness.Tests.ps1` (671); ci `FileSizePolicy.RepoGate.Tests.ps1` (5).
