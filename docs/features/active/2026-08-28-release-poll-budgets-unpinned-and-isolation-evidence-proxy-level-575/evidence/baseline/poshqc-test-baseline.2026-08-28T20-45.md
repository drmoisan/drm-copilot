Timestamp: 2026-08-28T20-45
Command: Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCTest -Root (Get-Location).Path *>&1
EXIT_CODE: 0
Output Summary:
(a) Counts line, verbatim from the console output:
```
Tests Passed: 3837,
Failed: 0,
Skipped: 9,
Inconclusive: 0,

NotRun: 0
```
(b) Overall repository line coverage: 94.72% (root `<counter type="LINE" missed="403" covered="7236" />` in `artifacts/pester/powershell-coverage.xml`; 7236/7639 = 0.947244). The console's own "Covered 94.19% / 0%" line reports INSTRUCTION (command) coverage (`<counter type="INSTRUCTION" missed="614" covered="9949" />`, 9949/10563 = 0.941877), a distinct metric from LINE coverage; the LINE percentage is derived directly from the coverage XML's root LINE counter, not printed verbatim in the console output.
(c) `scripts/dev-tools/Invoke-ReleaseTagPush.ps1` line coverage: 97.40% (sourcefile-level `<counter type="LINE" missed="2" covered="75" />` in `artifacts/pester/powershell-coverage.xml`; 75/77 = 0.974026). The two missed lines are inside the `Invoke-GitExe` wrapper function body (lines 74-75), which is mocked in every test and therefore never executes its own body.

Full test-count section captured verbatim:

```
Tests completed in 142.75s
Tests Passed: 3837,
Failed: 0,
Skipped: 9,
Inconclusive: 0,

NotRun: 0
Processing code coverage result.
Covered 94.19% / 0%. 10,563 analyzed Commands in 88 Files.
Wrote Koverage coverage copy: C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a7601c2ef97f9a7e4\artifacts\pester\powershell-coverage.koverage.xml
```
