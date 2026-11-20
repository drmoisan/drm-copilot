# [P3-T2] Pester gate: DocsPythonCliClick (issue #1022)

Timestamp: 2026-11-04T00-20
Command: pwsh -NoProfile -File SCRATCH/issue-1022-pester-suite.ps1 -WorktreeRoot <item worktree> -Suite tests/scripts/claude-lib/docs/DocsPythonCliClick.Tests.ps1 -CoverageFile .claude/lib/docs/DocsPythonCliClick.psm1 (Invoke-Pester with the configuration of scripts/powershell/PoshQC/settings/pester.runsettings.psd1, Run.PassThru, JUnit to artifacts/pester/pester-junit.xml, coverage over the module; one process)
EXIT_CODE: 0
Output Summary: tests/scripts/claude-lib/docs/DocsPythonCliClick.Tests.ps1: 12 passed, 0 failed, 0 errored, 0 skipped (JUnit testsuite element; result object Passed=12 Failed=0 Skipped=0). Line execution: .claude/lib/docs/DocsPythonCliClick.psm1 159 of 159 analyzed lines (100%). The JUnit file is well-formed; counts were read from it.

## Toolchain for the new files

- Formatter: `Already formatted:` for `.claude/lib/docs/DocsPythonCliClick.psm1` and `tests/scripts/claude-lib/docs/DocsPythonCliClick.Tests.ps1`; 0 files rewritten.
- Analyzer (direct Invoke-ScriptAnalyzer with scripts/powershell/PoshQC/settings/pssa.settings.psd1): 0 findings for the two files (one intermittent engine NullReferenceException was retried with a module reload).
- Physical line counts: `DocsPythonCliClick.psm1` 288; `DocsPythonCliClick.Tests.ps1` 234.

## Behavior covered

- Group root with a literal `name=` (`NameSource` `literal`), header span from the topmost decorator to the `:` line, `Attach` equal to the function name; `@G.command` and `@G.group` on a tracked group (nested to a third level), with the literal name from `name=` or the first positional string and the default name from the function name (lower-cased, `_` to `-`, one trailing `-command`, `-cmd`, `-group` or `-grp` removed); `from click import command` with a bare `@command`.
- `G.add_command(F)` and `G.add_command(F, name="x")` re-parent a root def under the group; option strings split at `/` (`--debug/--no-debug` yields `--debug`), `short`, `required`, `help` and `has_default` properties, decorator spans.
- `CLI_CUSTOM_CLASS` (`cls=`, constructed `click.Group`, `click.Command`, `click.CommandCollection`), `CLI_DECORATOR_INDIRECT` (a name bound to a click attribute, a bound list of click calls, a decorator applied by call), `CLI_UNBOUND_REGISTRATION` (decorator and `add_command` on an untracked receiver; a receiver of another framework is ignored), `CLI_DYNAMIC_REGISTRATION` (non-literal name, option string and `add_command` name), `CLI_REGISTRATION_IN_LOOP` (decorated def and `add_command` in a loop), `PYTHON_IDENTIFIER_NON_ASCII` (non-ASCII function name used as the default name), each with code, severity `warning`, blocking `$false`, line and survival of the other sites.
- Input non-mutation; `property: Get-DocsClickCommandSite default names follow the suffix rule` (seed 102251).

CI: `poshqc / PowerShell QC` (windows-latest shards).
