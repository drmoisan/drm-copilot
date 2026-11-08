# Phase 2 C# tokenizer suite ([P2-T3])

Timestamp: 2026-11-03T22-42
Command: pwsh -NoProfile -File SCRATCH/issue-1033-poshqc-test.ps1 -Root <worktree> -ScanFolders tests/scripts/claude-lib/docs (imports scripts/powershell/PoshQC/PoshQC.psd1 and calls `Invoke-PoshQCTest -Root <worktree> -ScanFolders tests/scripts/claude-lib/docs` in one process; preceded by `Invoke-PoshQCFormat` over `.claude/lib/docs,tests/scripts/claude-lib/docs` (0 files formatted on the final pass) and a direct `Invoke-ScriptAnalyzer` run with the repository settings (0 findings on the final pass; a first pass reported one `PSAvoidUsingPositionalParameters` information finding in the suite, fixed by parenthesizing a concatenated fixture)); counts read from artifacts/pester/pester-junit.xml, coverage from artifacts/pester/powershell-coverage.xml, logical line count from `wc -l`
EXIT_CODE: 4
Output Summary: `DocsCSharpTokens.Tests.ps1`: tests=15, failures=0, errors=0 (JUnit `testsuite` element). Whole folder `tests/scripts/claude-lib/docs`: tests=450, failures=4 (1020's `Docs.Manifest.Tests.ps1`, expected until [P6-T5] and [P6-T6]), errors=0, skipped=0; exit 4 reflects those four failures. Logical line count of `.claude/lib/docs/DocsCSharpTokens.psm1`: 368. Line coverage of the module in this run: 92.43% (171 of 185 lines); the other Phase 1 and 2 modules in the same run: DocsScannerCommon 97.77%, DocsTypeScriptTokens 96.94%.

## Scope of the task

`ConvertTo-DocsCSharpToken -Text [-MaxTokens 250000] [-MaxDepth 256]` returning `@{ Tokens; HasConditional; Diagnostics }` with the shared token record. `//`, `///` and `/* */` comments; a directive line produces no token and `#if` sets `HasConditional` (both `#if` and `#else` branches are tokenized without evaluation); character literals; regular strings with escapes; verbatim strings with doubled quotes; interpolated strings (`$"..."`, `$@"..."`, `@$"..."`) with holes across nested strings and character literals, `{{` and `}}` escapes, `Dynamic` when a hole exists; raw strings by quote-run length with the `$$` brace width (a single-line raw string decodes to its content; a multi-line one carries `Value` `$null`); the `u8` suffix kept in `Text`; `@`-verbatim and `\u` and `\U` identifiers with a decoded `Value` and preserved `Text`; contextual keywords (`record`, `partial`, `required`, `file`, `var`, `async`) as identifiers; `>` always a single token; `CSHARP_LEXICAL_INVALID` for an unterminated string, raw string, character literal, interpolated hole, or block comment, and `TOKEN_LIMIT` for the token and depth bounds, each blocking with no token returned (codes per [P0-T4] C7).

## Tests (15)

Comments with line numbers; directive lines and `HasConditional`; unterminated block comment; character literals and regular strings with escapes; verbatim strings across lines; interpolated strings with escapes, holes, nested strings and verbatim forms; raw strings by quote-run length and `$$` brace width including a multi-line raw string; the `u8` suffix; unterminated string, raw string, character literal and interpolated hole; verbatim and escaped identifiers; keywords and numeric suffixes and separators; punctuators by longest match with `>>` as two `>` tokens; bracket depth and an unexpected character; one `TOKEN_LIMIT` each for the token bound and the depth bound; empty text.

## Counts

| Scope | tests | failures | errors | skipped |
|---|---|---|---|---|
| `DocsCSharpTokens.Tests.ps1` | 15 | 0 | 0 | 0 |
| `tests/scripts/claude-lib/docs` (whole folder) | 450 | 4 (`Docs.Manifest.Tests.ps1`, expected until [P6-T5] and [P6-T6]) | 0 | 0 |
