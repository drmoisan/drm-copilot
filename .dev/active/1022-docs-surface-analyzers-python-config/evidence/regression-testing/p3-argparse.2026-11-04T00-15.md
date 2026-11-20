# [P3-T1] Pester gate: DocsPythonCliArgparse (issue #1022)

Timestamp: 2026-11-04T00-15
Command: pwsh -NoProfile -File SCRATCH/issue-1022-pester-suite.ps1 -WorktreeRoot <item worktree> -Suite tests/scripts/claude-lib/docs/DocsPythonCliArgparse.Tests.ps1,tests/scripts/claude-lib/docs/DocsPythonBindings.Tests.ps1 -CoverageFile .claude/lib/docs/DocsPythonCliArgparse.psm1,.claude/lib/docs/DocsPythonBindings.psm1 (Invoke-Pester with the configuration of scripts/powershell/PoshQC/settings/pester.runsettings.psd1, Run.PassThru, JUnit to artifacts/pester/pester-junit.xml, coverage over the two modules; one process)
EXIT_CODE: 0
Output Summary: tests/scripts/claude-lib/docs/DocsPythonCliArgparse.Tests.ps1: 12 passed, 0 failed, 0 errored, 0 skipped; tests/scripts/claude-lib/docs/DocsPythonBindings.Tests.ps1: 20 passed, 0 failed, 0 errored, 0 skipped (JUnit testsuite elements; result object Passed=32 Failed=0 Skipped=0). Line execution: .claude/lib/docs/DocsPythonCliArgparse.psm1 129 of 129 analyzed lines (100%); .claude/lib/docs/DocsPythonBindings.psm1 161 of 161 (100%). The JUnit file is well-formed; counts were read from it.

## Shared front-end added to DocsPythonBindings.psm1 (delegation design suggestion)

Two exported functions were added to `LIB/DocsPythonBindings.psm1` so that the four Python analyzers share one front-end instead of four copies: `Get-DocsPythonFrontEnd -Text` (lexer, logical lines, import table, receiver table, the front-end diagnostic records in that order, and `Blocked`) and `Resolve-DocsPythonQualifiedName -Name -Import` (dotted-name resolution through the import alias table; `$null` for an ambiguous first segment). Each has a seeded property test in `TESTS/DocsPythonBindings.Tests.ps1` (`property: Resolve-DocsPythonQualifiedName replaces exactly the bound first segment`, seed 102243; `property: Get-DocsPythonFrontEnd yields one logical line and one receiver per generated binding`, seed 102244). Both are recorded here for the [P6-T11] census. The module now imports `DocsPythonTokens.psm1` directly (the front-end calls the lexer). `DocsPythonBindings.psm1` is 302 physical lines.

## Toolchain for the new and changed files

- Formatter: `Already formatted:` for `.claude/lib/docs/DocsPythonBindings.psm1`, `.claude/lib/docs/DocsPythonCliArgparse.psm1`, `tests/scripts/claude-lib/docs/DocsPythonBindings.Tests.ps1` and `tests/scripts/claude-lib/docs/DocsPythonCliArgparse.Tests.ps1`; 0 files rewritten on the final pass.
- Analyzer (direct Invoke-ScriptAnalyzer with scripts/powershell/PoshQC/settings/pssa.settings.psd1): 0 findings for the four files on the final pass.
- Physical line counts: `DocsPythonCliArgparse.psm1` 243; `DocsPythonBindings.psm1` 302; `DocsPythonCliArgparse.Tests.ps1` 193; `DocsPythonBindings.Tests.ps1` 369.
- Defects found and fixed during this task: a local `$line` in a function with a `-Line` parameter (case-insensitive variables) was renamed `$siteLine`; the memo and visiting-set parameters needed `[AllowEmptyCollection()]`; a registration on a call result (`ArgumentParser().add_argument(...)`) was not detected until a branch for a method name preceded by `.` was added.

## Behavior covered

- Root with literal `prog=` (`NameSource` `literal`), its enclosing function in `Attach` (the receiver name at module level), statement span; `from argparse import ArgumentParser as AP` resolution; a root without `prog=` carries no name.
- Nested `add_parser` subcommands with literal `help`; `aliases=` not read; no site for `add_subparsers`, `add_argument_group` or `add_mutually_exclusive_group` calls; group receivers mapped to their parser.
- Options: long with short, positional, literal `required`, `action` and `help`; `default=` yields `has_default` only (the value 3 never appears); a multi-line `add_argument(` spans its statement; no `--help` option.
- `CLI_DYNAMIC_REGISTRATION` (variable, f-string, non-literal `prog=`, non-literal `add_parser` name), `CLI_REGISTRATION_IN_LOOP` (`for`, `while`, comprehension), `CLI_UNBOUND_REGISTRATION` (parameter, attribute receiver, call result, chained unresolved receiver; a receiver of another framework is ignored), `CLI_PARENTS_UNRESOLVED` (on `ArgumentParser` and `add_parser`, parser classified), each with code, severity `warning`, blocking `$false`, line and survival of the other sites.
- Input non-mutation of the logical lines; `property: Get-DocsArgparseCommandSite is deterministic under unrelated statement insertion` (seed 102250).

CI: `poshqc / PowerShell QC` (windows-latest shards).
