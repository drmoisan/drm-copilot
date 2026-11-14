# Baseline: Pester parallel run (issue 1105)

Timestamp: 2026-11-07T14-41
Task: [P0-T3]
Command: sh SCRATCH/issue-1105-pester.sh baseline (pwsh -NoProfile: `Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCParallelTest -Root <item worktree>`; output to SCRATCH/issue-1105-baseline-pester.log)
EXIT_CODE: 0
Output Summary:
- Returned ExitCode: 0 (8 workers, every shard exit 0, wall clock 389.06 s); run before any code change.
- Totals from `artifacts/pester/pester-junit.xml`: 15553 tests, 15543 passed, 0 failed, 0 errors, 10 skipped (JUnit `disabled`).
- Failing tests: none.
- Repository line coverage (`artifacts/pester/powershell-coverage.xml`): 94.01% (24046 covered, 1532 missed).
- Per-file line coverage for the eight files this plan edits (`.claude/hooks/`):
  - validate-task-researcher-output.ps1: 98.17% (107/109)
  - validate-prd-feature-output.ps1: 100.00% (66/66)
  - validate-required-artifact-output.ps1: 98.44% (63/64)
  - validate-planner-output.ps1: 99.53% (211/212)
  - validate-executor-output.ps1: 99.42% (170/171)
  - validate-feature-review-coverage.ps1: 100.00% (93/93)
  - validate-feature-review-coverage-metrics.ps1: 100.00% (72/72)
  - validate-feature-review-coverage-rules.ps1: 98.99% (98/99)
