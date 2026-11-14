# Pester Final Gate (parallel) - issue 1114

Timestamp: 2026-11-07T19-47
Command: sh SCRATCH/issue-1114-pester.sh final1 (PowerShell 7 in the item worktree: Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; $r = Invoke-PoshQCParallelTest -Root <item worktree>; exit $r.ExitCode); figures read by sh SCRATCH/issue-1114-figures.sh final1 merged and SCRATCH/issue-1114-rows.ps1
EXIT_CODE: 0
Output Summary:
- Returned ExitCode: 0 (8 workers, all 8 shards exit 0; wall clock 363.83 s). Fully green, so the merged artifacts/pester/pester-junit.xml and artifacts/pester/powershell-coverage.xml of this run were read.
- Counts: 15946 tests; 15936 passed; 0 failed; 0 errors; 10 skipped. [P0-T4]: 15881 tests; 15871 passed; 0 failed; 10 skipped. No new failing test (+65 tests, all passing).
- Repo-wide PowerShell line coverage: 94.08% (24395 covered, 1534 missed); [P0-T4]: 94.06%. No drop.
- `.codex/hooks/validate-feature-review-coverage.ps1`: 100.00% (175 covered, 0 missed); [P0-T4]: 100.00%. At least 85% and no drop.
- `.codex/hooks/validate-feature-review-coverage-freshness.ps1` (new): 97.96% (48 covered, 1 missed). Missed line: the twin's default `GitInvoker` line in the param block of `Get-FeatureReviewCoverageFreshnessDecision` (expected).
- `.codex/hooks/feature-review-coverage-target.ps1` (new): 98.51% (66 covered, 1 missed). Missed line: the body line of `Invoke-CodexReviewCoverageGitExe` (expected).
- `.codex/hooks/hook-target-worktree.ps1` (unchanged): 99.33%, the same as [P0-T4].
- Passing rows: all 45 `1114:` rows ([P1-T1] parity and no-probe rows, all [P1-T2] rows, the four [P2-T1] rows, the four [P3-T1] rows); `E4-ST7: the Codex hook reads the floor from its own thresholds copy`; `E4-ST3: .codex/hooks/validate-feature-review-coverage.ps1 help states the absent and unreadable CLAUDE.md rules`; the four `B1` rows of `hook-dependency-failure.Codex.Tests.ps1` for the hook (thresholds, `hook-target-worktree.ps1`, `validate-feature-review-coverage-freshness.ps1`, `feature-review-coverage-target.ps1`).
- Suites, all with 0 failures: codex-hooks `validate-feature-review-coverage.Coverage.Tests.ps1` (40), `validate-feature-review-coverage-freshness.Tests.ps1` (21), `feature-review-coverage-target.Tests.ps1` (34), `legacy-codex-hook-contracts.Tests.ps1` (43), `hook-dependency-failure.Codex.Tests.ps1` (93), `feature-review-coverage-narrowing-parity.Tests.ps1` (66), `feature-review-coverage-floor-parity.Tests.ps1` (4), `hook-target-worktree.Tests.ps1` (83); claude-hooks `validate-feature-review-coverage-freshness.Tests.ps1` (18), `validate-feature-review-coverage.Tests.ps1` (28), `validate-feature-review-coverage.TargetWorktree.Tests.ps1` (21), `validate-feature-review-coverage.Coverage.Tests.ps1` (73); claude-runtime `enforcement-hooks-no-python-invocation.Tests.ps1` (33, passing), `hook-dependency-guard-completeness.Tests.ps1` (671); ci `FileSizePolicy.RepoGate.Tests.ps1` (5).
