# [P1-T1] Pester gate: DocsSourceText (issue #1022)

Timestamp: 2026-11-03T23-08
Command: pwsh -NoProfile -File SCRATCH/issue-1022-pester-suite.ps1 -WorktreeRoot <item worktree> -Suite tests/scripts/claude-lib/docs/DocsSourceText.Tests.ps1,tests/scripts/claude-lib/docs/DocsPythonTokens.Tests.ps1 -CoverageFile .claude/lib/docs/DocsSourceText.psm1,.claude/lib/docs/DocsPythonTokens.psm1 (Invoke-Pester with the configuration of scripts/powershell/PoshQC/settings/pester.runsettings.psd1, Run.PassThru, JUnit to artifacts/pester/pester-junit.xml, coverage over the two new modules; one process)
EXIT_CODE: 0
Output Summary: tests/scripts/claude-lib/docs/DocsSourceText.Tests.ps1: 19 passed, 0 failed, 0 errored, 0 skipped (JUnit testsuite element; the result object reports Passed=48 Failed=0 Skipped=0 over both suites of the run). .claude/lib/docs/DocsSourceText.psm1: 114 of 114 analyzed lines executed (100%, Pester result object CommandsExecuted/CommandsMissed by distinct line). The JUnit file is well-formed (tests=48 failures=0 errors=0 skipped=0); counts were read from it.

## Toolchain for the new files

- Formatter (Invoke-Formatter with scripts/powershell/PoshQC/settings/pssa.settings.psd1, through SCRATCH/issue-1022-qc-files.ps1): `Already formatted:` for `.claude/lib/docs/DocsSourceText.psm1` and `tests/scripts/claude-lib/docs/DocsSourceText.Tests.ps1`; 0 files rewritten on the final pass.
- Analyzer (direct Invoke-ScriptAnalyzer with the same settings): 0 findings for both files on the final pass (two earlier `PSUseOutputTypeCorrectly` information findings were cleared by declaring `[object[]]` on the two array-returning functions).
- Physical line counts (`@(Get-Content).Count`): `.claude/lib/docs/DocsSourceText.psm1` 327; `tests/scripts/claude-lib/docs/DocsSourceText.Tests.ps1` 318.

## Behavior covered

- `ConvertTo-DocsSourceLine`: BOM, CRLF, CR normalization; form feed and U+2028 are not breaks; zero lines for the empty text and for a lone LF; `property: ConvertTo-DocsSourceLine line i plus LF equals ConvertTo-DocsDeclarationText with range i to i` (seed 102201, 120 random texts mixing CRLF, CR, LF, BOM and trailing-newline variants, every line index compared with the 1020 function).
- `ConvertTo-DocsLineRange`: first start and last end, flat pair, `DOCS_LINE_RANGE_INVALID` cases; `property: ConvertTo-DocsLineRange returns the first start and the last end` (seed 102202).
- `ConvertTo-DocsKeyPathDeclaration`: bare, array marker `[]`, quoted segments with escaped quote and backslash; `property: ConvertTo-DocsKeyPathDeclaration is injective` (seed 102203).
- `Get-DocsModuleDottedName`: longest root, `__init__.py`, root `.`, non-.py, outside-root and root-level `__init__.py`; property (seed 102204).
- `Find-DocsPathOrGlobMatch`: exact, prefix, `*`, `**`, `?`, case difference, first entry wins, string entries; property (seed 102205).
- `New-DocsDiagnosticAggregate` and `Add-DocsDiagnosticOccurrence`: one diagnostic per (analyzer, code, path), count and first line in the message, severity and blocking, ordinal path order, code-grammar rejection through `New-DocsDiagnostic`; properties (seeds 102206, 102207).
- `Select-DocsUniqueElement`: `DECLARATION_INVALID`, `DUPLICATE_DECLARATION` keeping the first site by line, `analyzer_id` `docs-inventory`, non-blocking; property (seed 102208).

CI: these suites run with coverage on `windows-latest` in `poshqc / PowerShell QC shard 1` to `shard 3`, aggregated by the required check `poshqc / PowerShell QC`.
