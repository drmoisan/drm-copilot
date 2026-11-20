# DocsSchema Suite ([P3-T3])

Timestamp: 2026-11-03T13-21
Command: sh SCRATCH/issue-1020-test.sh tests/scripts/claude-lib/docs issue-1020-exec-p3-docsschema.log (branch-current `Invoke-PoshQCTest -ScanFolders tests/scripts/claude-lib/docs` from `scripts/powershell/PoshQC/PoshQC.psd1`, PowerShell 7.6.9); counts read from `artifacts/pester/pester-junit.xml` by SCRATCH/issue-1020-summary.ps1 and SCRATCH/issue-1020-exec-suites.ps1
EXIT_CODE: 0
Output Summary: `DocsSchema.Tests.ps1` tests=48 failures=0 errors=0 skipped=0. Whole run (4 suites): tests=171 failures=0 errors=0 skipped=0. Line coverage of `.claude/lib/docs/DocsSchema.psm1` 99.51% (205 covered, 1 missed), read from `artifacts/pester/powershell-coverage.xml`.

## Per-suite counts

| Suite | tests | failures | errors | skipped |
|---|---|---|---|---|
| DocsFinding.Tests.ps1 | 30 | 0 | 0 | 0 |
| DocsJson.Tests.ps1 | 27 | 0 | 0 | 0 |
| DocsSchema.Tests.ps1 | 48 | 0 | 0 | 0 |
| DocsSurface.Tests.ps1 | 66 | 0 | 0 | 0 |

## D5 cross-file probe

Command: sh SCRATCH/issue-1020-run.sh issue-1020-exec-d5probe.ps1 (one unmocked `Test-Json -Json <docs-profile example> -Schema <uncomposed runtime docs-profile schema>` without `-FetchExternalReference`)
Outcome: `False`; first error line: `The JSON schema contains a reference that could not be resolved. External schema references are not supported by default, use the 'FetchExternalReference' parameter to enable it.`

Composition through `Join-DocsSchemaText` is used whatever the outcome (OQ-6).
