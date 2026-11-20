# Phase 2 TypeScript JSX lexical state ([P2-T2])

Timestamp: 2026-11-03T22-37
Command: pwsh -NoProfile -File SCRATCH/issue-1033-poshqc-test.ps1 -Root <worktree> -ScanFolders tests/scripts/claude-lib/docs (imports scripts/powershell/PoshQC/PoshQC.psd1 and calls `Invoke-PoshQCTest -Root <worktree> -ScanFolders tests/scripts/claude-lib/docs` in one process; preceded by `Invoke-PoshQCFormat` over `.claude/lib/docs,tests/scripts/claude-lib/docs` (0 files formatted) and a direct `Invoke-ScriptAnalyzer` run with the repository settings (0 findings; one earlier invocation ended with a transient PSScriptAnalyzer null-reference error and was repeated)); counts read from artifacts/pester/pester-junit.xml, coverage from artifacts/pester/powershell-coverage.xml, logical line count from `wc -l`
EXIT_CODE: 4
Output Summary: JSX tests pass: `DocsTypeScriptTokens.Tests.ps1` tests=21 (17 from [P2-T1] plus the 4 tests of `Context 'JSX (-Jsx)'`), failures=0, errors=0. Module holding the JSX state: `.claude/lib/docs/DocsTypeScriptTokens.psm1` (no split; `DocsTypeScriptJsx.psm1` is not created because the tokenizer stays at 452 logical lines with the JSX state, at most 500). Line coverage of the module in this run: 96.94% (222 of 229 lines). Whole folder: tests=434, failures=4 (1020's `Docs.Manifest.Tests.ps1`, expected until [P6-T5] and [P6-T6]), errors=0; exit 4 reflects those four failures.

## JSX state

`-Jsx` enters the JSX lexical state when a `<` appears where an expression can start and is followed by a tag name or `>` (fragment), unless it is a type parameter list (`<T,>` or `<T extends U>`). Tag punctuators (`<`, `</`, `>`, `/>`), tag and attribute names (`identifier`), `=`, and attribute strings (`string`, raw value) are emitted; `{...}` expression children and attribute values are scanned by the normal tokenizer with brace counting (so nested JSX inside an expression re-enters the state); text runs produce no token, so an apostrophe in text is not a string delimiter; element nesting counts against the depth bound. Because no split was needed, the conditional `DocsTypeScriptJsx.Tests.ps1` is not created and the JSX tests live in `DocsTypeScriptTokens.Tests.ps1` (`Context 'JSX (-Jsx)'`).

## JSX tests (4)

Element with attribute strings, an expression child, text with an apostrophe (exactly one `string` token in the stream), nested and self-closing tags; element depth, nested JSX inside an expression child, a fragment, and line numbers; `<T,>` and `<T extends U>` as type parameters and `a < b` as punctuation; no JSX state without `-Jsx` (the stream yields one diagnostic because `</div>` lexes as an unterminated regular expression), an unterminated element, an unterminated attribute string (`TS_LEXICAL_INVALID`), and element nesting above `-MaxDepth 1` (`TOKEN_LIMIT`).

## Counts

| Scope | tests | failures | errors | skipped |
|---|---|---|---|---|
| `DocsTypeScriptTokens.Tests.ps1` (whole suite including JSX) | 21 | 0 | 0 | 0 |
| `tests/scripts/claude-lib/docs` (whole folder) | 434 | 4 (`Docs.Manifest.Tests.ps1`, expected until [P6-T5] and [P6-T6]) | 0 | 0 |

Module holding the JSX state: `DocsTypeScriptTokens.psm1`; logical line count: 452.
