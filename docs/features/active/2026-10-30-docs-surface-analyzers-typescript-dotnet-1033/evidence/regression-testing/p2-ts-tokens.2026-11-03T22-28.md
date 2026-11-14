# Phase 2 TypeScript tokenizer suite ([P2-T1])

Timestamp: 2026-11-03T22-28
Command: pwsh -NoProfile -File SCRATCH/issue-1033-poshqc-test.ps1 -Root <worktree> -ScanFolders tests/scripts/claude-lib/docs (imports scripts/powershell/PoshQC/PoshQC.psd1 and calls `Invoke-PoshQCTest -Root <worktree> -ScanFolders tests/scripts/claude-lib/docs` in one process; preceded by `Invoke-PoshQCFormat` over `.claude/lib/docs,tests/scripts/claude-lib/docs` (0 files formatted on the final pass) and a direct `Invoke-ScriptAnalyzer` run with the repository settings (0 findings)); counts read from artifacts/pester/pester-junit.xml, coverage from artifacts/pester/powershell-coverage.xml, logical line count from `wc -l`
EXIT_CODE: 4
Output Summary: `DocsTypeScriptTokens.Tests.ps1`: tests=17, failures=0, errors=0 (JUnit `testsuite` element). Whole folder `tests/scripts/claude-lib/docs`: tests=430, failures=4, errors=0, skipped=0; the four failures are 1020's `Docs.Manifest.Tests.ps1` membership and mirror cases for the new modules, satisfied by [P6-T5] and [P6-T6] and re-run in [P6-T7] (exit 4 reflects them). Logical line count of `.claude/lib/docs/DocsTypeScriptTokens.psm1`: 302. Line coverage of the module in this run: 95.24% (140 of 147 lines).

## Scope of the task

`ConvertTo-DocsTypeScriptToken -Text [-Jsx] [-MaxTokens 250000] [-MaxDepth 256]` returning `@{ Tokens; Diagnostics }` with the shared token record (`Kind`, `Text`, `Value`, `Dynamic`, `Start`, `Line`, `EndLine`, `Depth`); `\G`-anchored `[regex]` matching with one pattern per lexical state; BOM and hashbang skipped; comments produce no token; string escapes decoded into `Value`; template substitution stack with `Dynamic`; regex-versus-division by the previous significant token; numeric forms; `#private`, Unicode escapes, decorators; `TS_LEXICAL_INVALID` and `TOKEN_LIMIT` (token and depth bounds) as blocking diagnostics `@{ Code; Line; Message }` with no tokens returned (codes per [P0-T4] C7). The `-Jsx` switch is accepted and inert in this task; the JSX lexical state is added by [P2-T2]. `>` is always a single token so generic closers never merge.

## Tests (17)

Kinds, `Value`, `Dynamic`, `Line`, `EndLine`, `Depth` per lexical state; BOM, hashbang and comments with line counting; empty text; unterminated block comment; escapes, quote escapes, hex and Unicode escapes, line continuation; a raw newline in a string gives one `TS_LEXICAL_INVALID` with its line; a literal template with `Value`; nested template substitutions, braces and templates inside a template marked `Dynamic` as one token; multi-line template `EndLine`; unterminated template; regex after `return`, `(` and `=` versus division after `)` and an identifier; unterminated regex; numeric forms; private names, Unicode escapes, decorators, contextual words; multi-character punctuators by longest match with `>>>` as three `>` tokens; bracket depth; unexpected character; `-MaxTokens 3` and `-MaxDepth 2` each give one `TOKEN_LIMIT` (the depth message names the bound); streams exactly at the bounds pass.

## Counts

| Scope | tests | failures | errors | skipped |
|---|---|---|---|---|
| `DocsTypeScriptTokens.Tests.ps1` | 17 | 0 | 0 | 0 |
| `tests/scripts/claude-lib/docs` (whole folder) | 430 | 4 (`Docs.Manifest.Tests.ps1`, expected until [P6-T5] and [P6-T6]) | 0 | 0 |
