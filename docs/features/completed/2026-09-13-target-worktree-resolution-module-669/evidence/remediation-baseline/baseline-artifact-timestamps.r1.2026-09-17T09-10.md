# Baseline PoshQC Run-Output LastWriteTime (R1, cycle 1)

- Timestamp: 2026-09-17T13:55:07Z
- Command: `(Get-Item -LiteralPath 'artifacts/pester/powershell-coverage.xml').LastWriteTime` and `(Get-Item -LiteralPath 'artifacts/pester/pester-junit.xml').LastWriteTime`
- EXIT_CODE: 0

## Output Summary

Pre-run `LastWriteTime` values, recorded verbatim in round-trip (`o`) format:

- `artifacts/pester/powershell-coverage.xml`: `2026-09-17T08:42:00.4537585-04:00`
- `artifacts/pester/pester-junit.xml`: `2026-09-17T08:42:16.2944756-04:00`

These are the two baseline values `[P1-T1]` compares its post-run values against. Both files were last
written by the prior `-ScanFolders @('tests/scripts/claude-lib')`-restricted run referenced in
`remediation-inputs.2026-09-17T08-59.md` (R1 finding), not by a repo-wide run.
