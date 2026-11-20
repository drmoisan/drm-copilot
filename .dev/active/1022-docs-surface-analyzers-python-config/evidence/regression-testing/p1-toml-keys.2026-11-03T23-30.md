# [P1-T4] Pester gate: DocsTomlKeys (issue #1022)

Timestamp: 2026-11-03T23-30
Command: pwsh -NoProfile -File SCRATCH/issue-1022-pester-suite.ps1 -WorktreeRoot <item worktree> -Suite tests/scripts/claude-lib/docs/DocsTomlKeys.Tests.ps1 -CoverageFile .claude/lib/docs/DocsTomlKeys.psm1 (Invoke-Pester with the configuration of scripts/powershell/PoshQC/settings/pester.runsettings.psd1, Run.PassThru, JUnit to artifacts/pester/pester-junit.xml, coverage over the module; one process)
EXIT_CODE: 0
Output Summary: tests/scripts/claude-lib/docs/DocsTomlKeys.Tests.ps1: 18 passed, 0 failed, 0 errored, 0 skipped (JUnit testsuite element; result object Passed=18 Failed=0 Skipped=0). .claude/lib/docs/DocsTomlKeys.psm1: 181 of 182 analyzed lines executed (99.45%). The JUnit file is well-formed; counts were read from it.

## Toolchain for the new files

- Formatter: `Already formatted:` for `.claude/lib/docs/DocsTomlKeys.psm1` and `tests/scripts/claude-lib/docs/DocsTomlKeys.Tests.ps1`; 0 files rewritten on the final pass.
- Analyzer (direct Invoke-ScriptAnalyzer with scripts/powershell/PoshQC/settings/pssa.settings.psd1): 0 findings on the final pass (an earlier `PSUseDeclaredVarsMoreThanAssignments` warning was cleared by removing the unused variable).
- Physical line counts: `DocsTomlKeys.psm1` 321; `DocsTomlKeys.Tests.ps1` 252.
- Defects found and fixed during this task: `@($a + 1, $b + 1)` parses as `$a + (1, $b) + 1` in PowerShell (the comma binds tighter than `+`), so every span pair is now parenthesized; a `[string[]]` parameter needs `AllowEmptyString` for blank lines; the array-of-tables instance key used the set count instead of an instance counter; keys under an escaped table header inherit the escape and are dropped.

## Behavior covered

- `Get-DocsTomlKey`: `[table]` and `[[array.of.tables]]` headers (array key emitted once, element keys as `x.[].key` once per distinct path), dotted and quoted keys, every value extent (basic, literal, multi-line basic string, array spanning lines with a bracket inside a comment, one-line inline table, integer, float, boolean, date-time), header spans through the last non-blank non-comment line, the empty text; marker values never appear in the output (JSON serialization of the result contains no marker).
- Diagnostics with code, severity, blocking flag, line and effect: `TOML_INVALID` (unterminated string, unterminated array, malformed header, key without `=`, duplicate key, table redefinition, multi-line inline table, unrecognized value; blocking, no keys), `TOML_INLINE_TABLE_NOT_EXPANDED` (key emitted as `table`, inner keys not emitted), `TOML_KEY_ESCAPE_UNSUPPORTED` (the key and keys beneath an escaped header dropped, other keys kept).
- `Get-DocsTomlScriptEntry`: `[project.scripts]`, `[project.gui-scripts]`, `[tool.poetry.scripts]` one-line string entries with spans, a quoted name, other tables ignored; `CLI_CONSOLE_SCRIPT_UNSUPPORTED` (multi-line string, number, array, dotted key, escaped quoted key; other entries kept); `TOML_INVALID` passed through with no entries.
- `property: Get-DocsTomlKey emits one key per generated entry with the generated value type and never the value` (seed 102250); `property: Get-DocsTomlScriptEntry returns the generated name and target of every entry` (seed 102251).

CI: `poshqc / PowerShell QC` (windows-latest shards).
