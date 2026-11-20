# Preflight Fixes - Issue #1080

Timestamp: 2026-11-04T20-16
Plan: docs/features/active/2026-11-04-epic-progress-report-script-1080/plan.2026-11-04T14-56.md
Mode: single-pass preflight (trivial defects fixed in task text and preamble only; no task added, removed, or reordered)

## Fixes

1. `[P1-T6]` | count typo | "the nine seams from `## Design`" changed to "the eight seams". `## Design` lists eight seams: `Invoke-GitExe`, `Invoke-GhExe`, `Invoke-CswapExe`, `Test-EpicProgressCommand`, `Test-EpicProgressPath`, `Read-EpicProgressFile`, `Write-EpicProgressState`, `Get-EpicProgressUtcNow`.
2. `## Design` (main script, entry point bullet) | citation correction | `scripts/dev-tools/Invoke-ReleaseReconciliation.ps1` carries only the `if ($MyInvocation.InvocationName -ne '.')` guard and no Push-Location or Pop-Location. The citation now attributes only the guard to that script; the push, write, and pop behavior is unchanged.
3. `## Design` (`Get-EpicProgressFullLine` bullet) | ambiguity clarified | `<EpicName>` is stated to be the `-EpicFolder` value. AC3 defines no epic-name parameter, and in the recovered reference script the heading name equals the epic folder name.
4. `[P1-T8]` | literal formatting | the unnamed "drive-letter path by a .NET regex" now names the regex `(?<![A-Za-z])[A-Za-z]:[\\/]`. A probe on this host showed the plain form `[A-Za-z]:[\\/]` matches the `s:/` in `https://`, so a URL in the comment-based help would fail the test; the lookbehind form matched only the two drive paths in the probe text. The assertion (no drive-letter path) is unchanged.
5. `[P1-T6]` | validator-blind defect class | the state-path default test is stated to pass a fixture `-TempRoot` string and never name `[System.IO.Path]::GetTempPath`, `$env:TEMP`, or `$env:TMP`, which the PreToolUse hook `.claude/hooks/check-powershell-test-purity.ps1` denies in a test file. The assertion is unchanged.
6. `[P2-T9]` | evidence source | added the fallback to a shard's `shard.log` console summary and `[-]` failure lines when that shard's JUnit file is truncated (Pester's JUnit export stops at an ANSI escape character in a failure message on this host). The assertion (zero failures in both new files; other failing containers no greater than in P0-T4) is unchanged.

## Checks Without Defect

- SCRATCH run route: a `sh` launcher under SCRATCH invoking PowerShell 7 (7.6.9) from a script file ran; Pester 5.9.1 and PSScriptAnalyzer 1.25.0 are available; `Invoke-PoshQCParallelTest` imports from `scripts/powershell/PoshQC/PoshQC.psd1`.
- `git grep` use: P0-T8 searches tracked paths; P2-T10 searches the two test files after P1-T1 and P1-T6 commit them.
- P1-T6 `-WhatIf` test: the target is an absent path, and `Write-EpicProgressState` writes only inside its ShouldProcess guard, so the test writes nothing.
- Dot-source convention: `scripts/dev-tools/Invoke-FullReleaseFlow.ps1` dot-sources `Invoke-FullReleaseFlow.CheckHelpers.ps1` through `Join-Path -Path $PSScriptRoot`; `tests/scripts/dev-tools/Invoke-ReleaseTagPush.Tests.ps1` dot-sources its script with the mandatory `-ConfirmToken` bound.
- P1-T8 hardcoded-value test: it parses the two production files only, so the tokens listed as data in the test file cannot match.
- P0-T7 coverage route: `config/poshqc-coverage.json` lists the root `scripts`, and `Resolve-PoshQCCoveragePopulation` takes the `config` source before the scan-folder fallback, so a `-ScanFolders tests/scripts/dev-tools` run measures `scripts/dev-tools`.
- `tests/scripts/ci/FileSizePolicy.RepoGate.Tests.ps1` passes standalone on the current tree (5 of 5).
- A forward single-process run of `tests/scripts/dev-tools` on the current tree reported 722 tests and 0 failures, and left `git status --porcelain` empty.
