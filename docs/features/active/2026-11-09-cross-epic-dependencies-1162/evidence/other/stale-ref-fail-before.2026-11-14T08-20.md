# Stale-Ref Fail-Before (F1) — Remediation Cycle 1, P1-T1 (Issue 1162)

Timestamp: 2026-11-14T08-20
Command: sh SCRATCH/issue-1162-tc.sh "tests/scripts/claude-lib/epic-wave/EpicCrossDependency.Adapters.Tests.ps1" "tests/scripts/claude-lib/epic-wave/EpicCrossDependency.Adapters.Tests.ps1" (task check: Invoke-Formatter and Invoke-ScriptAnalyzer with scripts/powershell/PoshQC/settings/pssa.settings.psd1 on the changed file, then Pester 6.2.0 through New-PesterConfiguration with Run.Path set to the selected file)
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
- Changed file: tests/scripts/claude-lib/epic-wave/EpicCrossDependency.Adapters.Tests.ps1, which adds `It 'releases with PREREQ_IN_MAIN when the remote integration branch was deleted but its tracking ref is stale'` to `Describe 'Feature readiness through the wrappers'`.
- Selection rule: the changed test file. The module `.claude/lib/epic-wave/EpicCrossDependency.psm1` is unchanged, so its fetch is still `fetch -q origin`.
- Format: 0 differences. Analyzer: 0 findings.
- Pester: passed=25, failed=1, total=26. The only failure is the new test: expected `release|PREREQ_IN_MAIN`, actual `merge_required|PREREQ_MERGED_INTEGRATION_MERGE_REQUIRED`. Without `--prune` the stale tracking ref is still read, which is the state the review reproduced.
- Every other test in the file passes.
