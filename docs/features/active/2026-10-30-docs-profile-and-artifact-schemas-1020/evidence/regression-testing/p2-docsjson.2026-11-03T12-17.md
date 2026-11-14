# DocsJson Suite ([P2-T1])

Timestamp: 2026-11-03T12-17
Command: sh SCRATCH/issue-1020-test.sh tests/scripts/claude-lib/docs (PowerShell 7: Import-Module scripts/powershell/PoshQC/PoshQC.psd1; Invoke-PoshQCTest -Root <worktree root> -ScanFolders 'tests/scripts/claude-lib/docs'; counts read from artifacts/pester/pester-junit.xml)
EXIT_CODE: 0
Output Summary: tests=27, failures=0, errors=0, skipped=0 (suite tests/scripts/claude-lib/docs/DocsJson.Tests.ps1). Line coverage of .claude/lib/docs/DocsJson.psm1: 100% (102 covered, 0 missed).

## Counts (artifacts/pester/pester-junit.xml)

- tests: 27
- failures: 0
- errors: 0
- skipped: 0

## Line coverage (artifacts/pester/powershell-coverage.xml)

- `.claude/lib/docs/DocsJson.psm1`: 100% (covered 102, missed 0)

## Fixes made while bringing the suite to green

- The test for ordinal key order built its input with a `[ordered]@{}` literal holding `a` and `A`; PowerShell rejects case-only duplicate keys in a hash literal, so the input is now built with an ordinal-comparer hashtable.
- `ConvertFrom-DocsJsonText` classified an unterminated document as `DOCS_JSON_TOO_DEEP` because the reader message ("Expected depth to be zero ...") contains the word depth; the classification now matches only the reader's maximum-depth message.

CI: `poshqc / PowerShell QC` (windows-latest).
