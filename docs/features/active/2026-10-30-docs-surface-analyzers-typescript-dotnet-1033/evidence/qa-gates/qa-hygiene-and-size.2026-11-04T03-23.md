# Test hygiene and file size ([P7-T9])

Timestamp: 2026-11-04T03-23
Command: sh SCRATCH/issue-1033-hygiene.sh (a case-insensitive fixed-string `grep -i -F -c -e <token>` per token over each of the 20 files this feature adds or edits under `tests/scripts/claude-lib/docs` (the support module and 19 suites; untracked files included because the grep runs on the working tree), for the tokens `New-TemporaryFile`, `TestDrive`, `GetTempPath`, `GetTempFileName`, `$env:TEMP`, `Start-Process`, `Diagnostics.Process`, `Start-Job`, `Start-Sleep`, `Timers.Timer`, `Invoke-DocsProcess`, `InvokeProcess`, `env:PATH`; then the line count of each new production module under `.claude/lib/docs` with `wc -l`, equal to `@(Get-Content -LiteralPath <path>).Count` because every module ends with one line terminator)
EXIT_CODE: 0
Output Summary: every token reports 0 matches over the 20 files (13 tokens, 13 zero counts). A first pass at 2026-11-04T02-52 reported 1 match for `TestDrive`: the prose "no TestDrive is used" in the `.DESCRIPTION` of `Docs.ScannerTestSupport.psm1`, reworded to "no Pester temporary drive is used"; the QA loop was re-run from [P7-T1] after that edit (`qa-poshqc-format.2026-11-04T03-01.md` and later artifacts). Every new production module has at most 498 logical lines (all 17 at or below the plan's 500-line ceiling; the 800-line hard limit is not approached). The test suite `DocsScannerContract.Tests.ps1` has 525 lines (above the 500 guidance, below the 700 advisory tier; not a production file).

## Script output

```
FILES_SCANNED=20
TOKEN [New-TemporaryFile] matches=0
TOKEN [TestDrive] matches=0
TOKEN [GetTempPath] matches=0
TOKEN [GetTempFileName] matches=0
TOKEN [$env:TEMP] matches=0
TOKEN [Start-Process] matches=0
TOKEN [Diagnostics.Process] matches=0
TOKEN [Start-Job] matches=0
TOKEN [Start-Sleep] matches=0
TOKEN [Timers.Timer] matches=0
TOKEN [Invoke-DocsProcess] matches=0
TOKEN [InvokeProcess] matches=0
TOKEN [env:PATH] matches=0
LINE COUNTS (physical lines, wc -l; a file ending with a newline has that many logical lines)
LINES DocsScannerCommon.psm1 498
LINES DocsTypeScriptTokens.psm1 452
LINES DocsCSharpTokens.psm1 368
LINES DocsTypeScriptSyntax.psm1 491
LINES DocsTypeScriptCliSupport.psm1 341
LINES DocsAnalyzerTypeScriptCli.psm1 295
LINES DocsTypeScriptHttpDeclaration.psm1 214
LINES DocsTypeScriptHttpSupport.psm1 342
LINES DocsAnalyzerTypeScriptHttp.psm1 181
LINES DocsAnalyzerTypeScriptExports.psm1 458
LINES DocsCSharpSyntax.psm1 495
LINES DocsAnalyzerDotnetHttp.psm1 349
LINES DocsAnalyzerDotnetConfig.psm1 225
LINES DocsCSharpMember.psm1 287
LINES DocsAnalyzerDotnetApi.psm1 204
LINES DocsExtensionShape.psm1 269
LINES DocsAnalyzerExtensionImport.psm1 491
```
