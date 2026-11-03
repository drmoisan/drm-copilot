# DocsSchemaContract Suite ([P3-T4])

Timestamp: 2026-11-03T13-26
Command: sh SCRATCH/issue-1020-test.sh tests/scripts/claude-lib/docs issue-1020-exec-p3-contract.log (branch-current `Invoke-PoshQCTest -ScanFolders tests/scripts/claude-lib/docs` from `scripts/powershell/PoshQC/PoshQC.psd1`); counts read from `artifacts/pester/pester-junit.xml` by SCRATCH/issue-1020-summary.ps1 and SCRATCH/issue-1020-exec-suites.ps1
EXIT_CODE: 0
Output Summary: `DocsSchemaContract.Tests.ps1` tests=49 failures=0 errors=0 skipped=0, with `Test-Json` not mocked. Whole run (5 suites): tests=220 failures=0 errors=0 skipped=0. PowerShell version of the run: 7.6.9.

## Per-suite counts

| Suite | tests | failures | errors | skipped |
|---|---|---|---|---|
| DocsFinding.Tests.ps1 | 30 | 0 | 0 | 0 |
| DocsJson.Tests.ps1 | 27 | 0 | 0 | 0 |
| DocsSchema.Tests.ps1 | 48 | 0 | 0 | 0 |
| DocsSchemaContract.Tests.ps1 | 49 | 0 | 0 | 0 |
| DocsSurface.Tests.ps1 | 66 | 0 | 0 | 0 |

## Run history

The first run of this suite reported 3 failures, all in the test helper that applies a mutation by JSON pointer: an `if`-expression assignment copied an intermediate array, so the mutation was applied to a copy. The helper was corrected to assign directly; no production file changed. The run recorded above is the second run.
