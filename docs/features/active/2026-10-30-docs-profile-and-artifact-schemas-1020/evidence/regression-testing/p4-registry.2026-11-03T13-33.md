# DocsAnalyzerRegistry Suite ([P4-T1])

Timestamp: 2026-11-03T13-33
Command: sh SCRATCH/issue-1020-test.sh tests/scripts/claude-lib/docs issue-1020-exec-p4-registry.log (branch-current `Invoke-PoshQCTest -ScanFolders tests/scripts/claude-lib/docs` from `scripts/powershell/PoshQC/PoshQC.psd1`); counts read from `artifacts/pester/pester-junit.xml` by SCRATCH/issue-1020-summary.ps1 and SCRATCH/issue-1020-exec-suites.ps1
EXIT_CODE: 0
Output Summary: `DocsAnalyzerRegistry.Tests.ps1` tests=30 failures=0 errors=0 skipped=0. Whole run (6 suites): tests=250 failures=0 errors=0 skipped=0. Line coverage of `.claude/lib/docs/DocsAnalyzerRegistry.psm1` 100% (119 covered, 0 missed).

## Per-suite counts

| Suite | tests | failures | errors | skipped |
|---|---|---|---|---|
| DocsAnalyzerRegistry.Tests.ps1 | 30 | 0 | 0 | 0 |
| DocsFinding.Tests.ps1 | 30 | 0 | 0 | 0 |
| DocsJson.Tests.ps1 | 27 | 0 | 0 | 0 |
| DocsSchema.Tests.ps1 | 48 | 0 | 0 | 0 |
| DocsSchemaContract.Tests.ps1 | 49 | 0 | 0 | 0 |
| DocsSurface.Tests.ps1 | 66 | 0 | 0 | 0 |

## Notes

- The committed provider tables are asserted by membership only: anchors, declaration order, and existence in module scope; no test asserts a row count of either table.
- `DocsAnalyzerRegistry.psm1` imports `DocsJson.psm1` in addition to `DocsSurface.psm1` and `DocsFinding.psm1` (the spec import table lists the latter two), because `New-DocsCapturedInput` decodes through `ConvertFrom-DocsUtf8Bytes` and digests through `Get-DocsBytesSha256Hex`. The import is a literal sibling join already listed in the core manifest plan.
