# [P1-T2] Pester gate: DocsPythonTokens (issue #1022)

Timestamp: 2026-11-03T23-08
Command: pwsh -NoProfile -File SCRATCH/issue-1022-pester-suite.ps1 -WorktreeRoot <item worktree> -Suite tests/scripts/claude-lib/docs/DocsSourceText.Tests.ps1,tests/scripts/claude-lib/docs/DocsPythonTokens.Tests.ps1 -CoverageFile .claude/lib/docs/DocsSourceText.psm1,.claude/lib/docs/DocsPythonTokens.psm1 (Invoke-Pester with the configuration of scripts/powershell/PoshQC/settings/pester.runsettings.psd1, Run.PassThru, JUnit to artifacts/pester/pester-junit.xml, coverage over the two new modules; one process)
EXIT_CODE: 0
Output Summary: tests/scripts/claude-lib/docs/DocsPythonTokens.Tests.ps1: 29 passed, 0 failed, 0 errored, 0 skipped (JUnit testsuite element; the result object reports Passed=48 Failed=0 Skipped=0 over both suites of the run). .claude/lib/docs/DocsPythonTokens.psm1: 124 of 124 analyzed lines executed (100%, Pester result object CommandsExecuted/CommandsMissed by distinct line). The JUnit file is well-formed; counts were read from it.

## Toolchain for the new files

- Formatter: `Already formatted:` for `.claude/lib/docs/DocsPythonTokens.psm1` and `tests/scripts/claude-lib/docs/DocsPythonTokens.Tests.ps1`; 0 files rewritten on the final pass.
- Analyzer: 0 findings for both files on the final pass (one earlier `PSUseBOMForUnicodeEncodedFile` warning was cleared by building the non-ASCII test character from its code point, keeping the file ASCII).
- Physical line counts: `.claude/lib/docs/DocsPythonTokens.psm1` 233; `tests/scripts/claude-lib/docs/DocsPythonTokens.Tests.ps1` 205.

## Behavior covered

- Token classes: NAME with case-sensitive `IsKeyword` (`Def` is a NAME without `IsKeyword`), NUMBER (`0x1F`, `.5j`), OP with running bracket `Depth` on brackets and newlines, COMMENT, NEWLINE, CONTINUATION, WHITESPACE; STRING records `Prefix`, `IsTriple`, `HasEscape`, `IsBytes`, `IsFormat`, `IsRaw` for plain, escaped, raw with an escaped quote, `Rb`, `u`, triple-quoted across lines (EndLine 2) and f-strings with nested replacement fields.
- Diagnostics, each asserted with code, severity `error`, blocking `$true` and line: `PYTHON_ENCODING_UNSUPPORTED` (latin-1 cookie on line 2; utf-8/utf8/UTF_8 accepted; a cookie on line 3 or inside a string ignored); `PYTHON_LEXER_UNTERMINATED` (unterminated single, triple and raw strings, unclosed bracket, closing bracket without opener, backslash continuation at end of input); `PYTHON_LEXER_UNCLASSIFIED` (`$`, backtick, `?`, bracket depth 65 with 64 accepted, f-string fields nested three levels with two accepted); `PYTHON_TOKEN_LIMIT` (`IN_TEST_ROWS` row: 262,145 NAME tokens built in test code, 524,289 bytes, with 262,144 accepted).
- A 1,048,576-byte single comment line yields one COMMENT token; CRLF, CR and BOM are normalized before tokenizing.
- `property: Get-DocsPythonToken spans reconstruct the input text` (seed 102210, 200 random piece sequences; token texts concatenate to the normalized text and every token's line number is consistent with the newlines before it).

CI: `poshqc / PowerShell QC` (windows-latest shards).
