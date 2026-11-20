# Final QA: PSScriptAnalyzer (P4-T2)

Timestamp: 2026-11-04T01-46
Command: pwsh -NoProfile -File SCRATCH/issue-1066-format-lint.ps1 -Root <worktree> -Files tests/scripts/dev-tools/run-actionlint.Tests.ps1,tests/scripts/dev-tools/run-actionlint.EnvironmentIsolation.Tests.ps1 (Invoke-ScriptAnalyzer -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1)
EXIT_CODE: 0
Output Summary:
- Final pass (pass 2): TARGET 0 findings; GUARD 0 findings.
- Pass 1: TARGET 0 findings; GUARD 2 findings, both Warning `PSReviewUnusedParameter`, for the `Sentinel` parameter of the sentinel container script block and the `Holder` parameter of the probe container script block. Both parameters are used, but only inside the nested BeforeAll and It script blocks, which the rule does not inspect.
- Fix: each container script block now references its parameter directly (`$null = $Sentinel`, `$null = $Holder`) with a comment, the same pattern TARGET uses in its mocks. No suppression attribute was added. GUARD alone re-run after the fix: Total=4 Passed=4 Failed=0 (RAW/guard-alone-p4.xml).
- The loop restarted from P4-T1 after the fix.
