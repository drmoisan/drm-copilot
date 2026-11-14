# Phase 6 1020 registry suite with the inserted rows ([P6-T2])

Timestamp: 2026-11-04T02-00
Command: pwsh -NoProfile -File SCRATCH/issue-1033-poshqc-test.ps1 -Root <worktree> -ScanFolders tests/scripts/claude-lib/docs (the same branch-current `Invoke-PoshQCTest` run as `p6-registry-rows.2026-11-04T02-00.md`, which includes 1020's `tests/scripts/claude-lib/docs/DocsAnalyzerRegistry.Tests.ps1` with the seven 1033 rows present in `.claude/lib/docs/DocsAnalyzerRegistry.psm1`); counts read from artifacts/pester/pester-junit.xml
EXIT_CODE: 4
Output Summary: `DocsAnalyzerRegistry.Tests.ps1`: tests=30, failures=0, errors=0 (JUnit `testsuite` element). no edit: membership suite per 1020 v0.6. Exit 4 reflects the four expected `Docs.Manifest.Tests.ps1` failures of the whole-folder run.

## Disposition

[P0-T4] C6 records the search result NONE: the committed suite holds no row-count or empty-registry assertion over the committed tables (`Get-DocsAnalyzerRegistration` without `-ScannerRow`/`-NativeRow` appears only in `reports no finding for the committed registry`, a finding count of `Test-DocsAnalyzerRegistration`; `$script:DocsAnalyzerRow` appears only in the anchor-order text test and the `Test-Path variable:` test; no `HaveCount` and no empty-result assertion on either table variable). The suite is therefore not edited (`git status` shows no change to `tests/scripts/claude-lib/docs/DocsAnalyzerRegistry.Tests.ps1`), and it passes with the inserted rows: 30 tests, 0 failures.

## Counts

| Scope | tests | failures | errors | skipped |
|---|---|---|---|---|
| `DocsAnalyzerRegistry.Tests.ps1` (1020, unmodified) | 30 | 0 | 0 | 0 |
