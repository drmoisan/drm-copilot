# Pester Coverage Baseline - Issue 1034

Timestamp: 2026-11-04T15-45
Command: sh SCRATCH/issue-1034-run.sh SCRATCH/issue-1034-pester.ps1 -ScanFolders tests/scripts/claude-lib,tests/scripts/claude-hooks,tests/scripts/claude-runtime (imports scripts/powershell/PoshQC/PoshQC.psd1 from the branch and calls Invoke-PoshQCTest -Root <worktree> -ScanFolders <three folders> with an -InvokePester seam that sets Run.PassThru true and Run.Exit false; coverage enabled from pester.runsettings.psd1 and config/poshqc-coverage.json)
EXIT_CODE: 0
Output Summary: JUnit artifacts/pester/pester-junit.xml (loads as XML): tests 11294, failures 0, errors 0, disabled 1. Pester result: 11293 passed, 0 failed, 1 skipped, 0 failed blocks, 0 failed containers, 391 test files, 2576.70 s. Coverage XML artifacts/pester/powershell-coverage.xml (304 files, 71.39% of analyzed commands overall; line totals 19519 covered, 8652 missed). Invoke-DocsCommand.ps1 line coverage 87.74% (136 covered, 19 missed); DocsProfileCommands.psm1 line coverage 97.30% (72 covered, 2 missed).

## Uncovered Lines (baseline)

- `.claude/lib/docs/Invoke-DocsCommand.ps1`: the body of `Invoke-DocsProcess` (no test executes it by design) and the guarded write body of `Write-DocsFileText` (tests run only the -WhatIf path).
- `.claude/lib/docs/DocsProfileCommands.psm1`: two lines in the `Invoke-DocsInitCommand` profile-validation branch.

The run was concurrent with other worktree runs on a shared host, which explains the duration.
