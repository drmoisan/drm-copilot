# Stage R PowerShell Format and Lint

Timestamp: 2026-11-07T18-27
Command: sh-launched PowerShell 7 importing scripts/powershell/PoshQC/PoshQC.psd1; Invoke-PoshQCFormat over scripts/dev-tools/ProcessReductionChain.psm1, tests/scripts/dev-tools/ProcessReductionChain.Tests.ps1, and tests/scripts/dev-tools/ProcessReductionChain.Ledger.Tests.ps1 (writer recorded rather than applied), then Invoke-ScriptAnalyzer -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1 on each file; then git status --porcelain -- <the three files> (launcher stored under SCRATCH)
EXIT_CODE: 0
Output Summary:
  Format: all three files reported "Already formatted" (Formatted: 0 each); the formatter had nothing to write.
  git status --porcelain over the three files after the formatter: empty (0 lines). The worktree-wide porcelain lists only an untracked Stage G plan file written by a concurrent planner, which this stage does not touch.
  Analyzer: ProcessReductionChain.psm1 0 findings; ProcessReductionChain.Tests.ps1 0; ProcessReductionChain.Ledger.Tests.ps1 0; total 0. The first Invoke-ScriptAnalyzer call raised the known PSScriptAnalyzer 1.25 first-file NullReferenceException and was retried once in the same run.
  Clean pass: zero findings and no formatter change.
