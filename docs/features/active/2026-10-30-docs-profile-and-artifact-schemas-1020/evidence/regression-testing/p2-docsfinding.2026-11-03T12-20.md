# DocsFinding Suite ([P2-T2])

Timestamp: 2026-11-03T12-20
Command: sh SCRATCH/issue-1020-test.sh tests/scripts/claude-lib/docs (PowerShell 7: Import-Module scripts/powershell/PoshQC/PoshQC.psd1; Invoke-PoshQCTest -Root <worktree root> -ScanFolders 'tests/scripts/claude-lib/docs'; counts read from artifacts/pester/pester-junit.xml)
EXIT_CODE: 0
Output Summary: tests=57, failures=0, errors=0, skipped=0 over the two suites in tests/scripts/claude-lib/docs (DocsFinding.Tests.ps1: 30 tests; DocsJson.Tests.ps1: 27 tests). Line coverage of .claude/lib/docs/DocsFinding.psm1: 100% (88 covered, 0 missed).

## Counts (artifacts/pester/pester-junit.xml)

- tests: 57 (DocsFinding.Tests.ps1 30, DocsJson.Tests.ps1 27)
- failures: 0
- errors: 0
- skipped: 0

## Line coverage (artifacts/pester/powershell-coverage.xml)

- `.claude/lib/docs/DocsFinding.psm1`: 100% (covered 88, missed 0)
- `.claude/lib/docs/DocsJson.psm1`: 100% (covered 102, missed 0)

## Fix made while bringing the suite to green

- `New-DocsFinding` validated related paths with a loop variable named `$relatedPath`, which is the same variable as the parameter `$RelatedPath` because PowerShell variable names are case-insensitive; the loop overwrote the parameter. The loop variables are now `$candidateId` and `$candidatePath`.

CI: `poshqc / PowerShell QC` (windows-latest).
