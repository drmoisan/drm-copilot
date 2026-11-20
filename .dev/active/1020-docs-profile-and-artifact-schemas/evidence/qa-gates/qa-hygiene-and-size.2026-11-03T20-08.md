# Test Hygiene, Process Purity, Template Reads, and File Size ([P6-T10])

Timestamp: 2026-11-03T20-08
Command: sh SCRATCH/issue-1020-hygiene.sh (for each token: grep -r -i -F -c -e <token> tests/scripts/claude-lib/docs, counts summed; grep -i -F -c -e Get-Content .claude/lib/docs/Invoke-DocsCommand.ps1 .claude/lib/docs/DocsProfileCommands.psm1; logical line count @(Get-Content -LiteralPath <path>).Count for every file under .claude/lib/docs)
EXIT_CODE: 0
Output Summary: 0 matches for each of the 11 test-tree tokens and 0 matches for `Get-Content` in the two production files. Every production file under .claude/lib/docs/ has at most 500 logical lines (largest: Invoke-DocsCommand.ps1 458). PASS.

## Token searches over tests/scripts/claude-lib/docs (case-insensitive, fixed string, plain grep -r)

| Token | Matches |
|---|---|
| `New-TemporaryFile` | 0 |
| `TestDrive` | 0 |
| `GetTempPath` | 0 |
| `GetTempFileName` | 0 |
| `$env:TEMP` | 0 |
| `$env:TMP` | 0 |
| `Start-Process` | 0 |
| `Start-Sleep` | 0 |
| `System.Diagnostics.Process` | 0 |
| `ProcessStartInfo` | 0 |
| `-CommandType Application` | 0 |

Positive controls (same search form): `Describe` over the same tree returns 55; `ProcessStartInfo` over `.claude/lib/docs/Invoke-DocsCommand.ps1` returns 1 (the seam body), so the search form reports a present token.

## Get-Content over the real ReadText and template-read files

| File | Matches |
|---|---|
| `.claude/lib/docs/Invoke-DocsCommand.ps1` + `.claude/lib/docs/DocsProfileCommands.psm1` | 0 |

## Logical line counts (limit 500)

| File | Lines |
|---|---|
| .claude/lib/docs/DocsAnalyzerRegistry.psm1 | 360 |
| .claude/lib/docs/DocsFinding.psm1 | 282 |
| .claude/lib/docs/DocsJson.psm1 | 323 |
| .claude/lib/docs/DocsProfile.psm1 | 228 |
| .claude/lib/docs/DocsProfileCommands.psm1 | 233 |
| .claude/lib/docs/DocsSchema.psm1 | 404 |
| .claude/lib/docs/DocsSchemaWalk.psm1 | 208 |
| .claude/lib/docs/DocsSurface.psm1 | 447 |
| .claude/lib/docs/Invoke-DocsCommand.ps1 | 458 |
| .claude/lib/docs/schemas/v1/common.schema.json | 108 |
| .claude/lib/docs/schemas/v1/docs-command-envelope.schema.json | 24 |
| .claude/lib/docs/schemas/v1/docs-coverage-ledger.schema.json | 53 |
| .claude/lib/docs/schemas/v1/docs-evidence-pin.schema.json | 36 |
| .claude/lib/docs/schemas/v1/docs-parity-matrix.schema.json | 59 |
| .claude/lib/docs/schemas/v1/docs-profile.schema.json | 113 |
| .claude/lib/docs/schemas/v1/docs-validation-receipt.schema.json | 71 |
| .claude/lib/docs/schemas/v1/surface-inventory-snapshot.schema.json | 90 |
