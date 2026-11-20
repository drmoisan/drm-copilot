# [P3-T3] Pester gate: DocsPythonCliTyper (issue #1022)

Timestamp: 2026-11-04T00-26
Command: pwsh -NoProfile -File SCRATCH/issue-1022-pester-suite.ps1 -WorktreeRoot <item worktree> -Suite tests/scripts/claude-lib/docs/DocsPythonCliTyper.Tests.ps1,tests/scripts/claude-lib/docs/DocsPythonCliClick.Tests.ps1,tests/scripts/claude-lib/docs/DocsPythonCliArgparse.Tests.ps1 -CoverageFile .claude/lib/docs/DocsPythonCliTyper.psm1,.claude/lib/docs/DocsPythonCliClick.psm1,.claude/lib/docs/DocsPythonCliArgparse.psm1 (Invoke-Pester with the configuration of scripts/powershell/PoshQC/settings/pester.runsettings.psd1, Run.PassThru, JUnit to artifacts/pester/pester-junit.xml, coverage over the three modules; one process)
EXIT_CODE: 0
Output Summary: tests/scripts/claude-lib/docs/DocsPythonCliTyper.Tests.ps1: 13 passed, 0 failed, 0 errored, 0 skipped; DocsPythonCliClick.Tests.ps1: 12 passed, 0 failed; DocsPythonCliArgparse.Tests.ps1: 12 passed, 0 failed (JUnit testsuite elements; result object Passed=37 Failed=0 Skipped=0). Line execution: .claude/lib/docs/DocsPythonCliTyper.psm1 147 of 147 analyzed lines (100%); DocsPythonCliClick.psm1 159 of 159 (100%); DocsPythonCliArgparse.psm1 129 of 129 (100%). The JUnit file is well-formed; counts were read from it.

## Toolchain for the new and changed files

- Formatter: `Already formatted:` for `.claude/lib/docs/DocsPythonCliTyper.psm1`, `.claude/lib/docs/DocsPythonCliClick.psm1` and `tests/scripts/claude-lib/docs/DocsPythonCliTyper.Tests.ps1`; 0 files rewritten.
- Analyzer (direct Invoke-ScriptAnalyzer with scripts/powershell/PoshQC/settings/pssa.settings.psd1): 0 findings for the three files.
- Physical line counts: `DocsPythonCliTyper.psm1` 281; `DocsPythonCliClick.psm1` 288; `DocsPythonCliTyper.Tests.ps1` 233.
- Defect found and fixed during this task: a decorator whose receiver is an import alias of another framework (`@click.command` seen by the Typer recognizer) was reported as `CLI_UNBOUND_REGISTRATION`; the unbound check in the Typer and Click recognizers now also ignores a name bound by the import table, and the Typer suite asserts the imported-decorator case. The Click suite was re-run after the change (12 passed).

## Behavior covered

- `typer.Typer(name=)` root (`NameSource` `literal`, statement span, `Attach` equal to the receiver), `app.add_typer(sub, name="x")` subgroup spanning the `add_typer` statement, `@app.command(...)` with an explicit first-positional name and with the default name (function name lower-cased, `_` to `-`), header spans from the topmost decorator to the `:` line, `@app.callback()` parameters as root options, `typer.run(func)` target as a root spanning its def with its parameters as options.
- Parameters: no default (argument, `positional` true), plain default (option, `has_default` true, `--name` with `_` to `-`), `typer.Option(False, "--flag", "-f", help=...)` as default (`short`, `help`), `typer.Option(..., "--none")` (`has_default` false), `Annotated[str, typer.Option()] = "x"`, `Annotated[str, Opt("--pick", "-p")]` through an alias, `Annotated[str, typer.Argument()]`, `typer.Argument("s")`, a list default; a boolean option declares `--x` only (no `--no-x` element); spans from the name token line to the parameter's last token line; the default value 3 never appears.
- `CLI_TYPER_PARAMETER_UNRESOLVED` (call, attribute and nested-call defaults; other parameters survive), `CLI_CUSTOM_CLASS` (`cls=` on the constructor and on a command decorator), `CLI_DYNAMIC_REGISTRATION` (non-literal `Typer(name=)`, command name and `add_typer` name), `CLI_UNBOUND_REGISTRATION` (decorator and `add_typer` on an untracked receiver; receivers and import aliases of other frameworks ignored), `CLI_REGISTRATION_IN_LOOP` (constructor, decorated def, `add_typer`, `typer.run` in a loop), `PYTHON_IDENTIFIER_NON_ASCII` (command function, `typer.run` target and parameter name), each with code, severity `warning`, blocking `$false`, line and survival of the other sites.
- Input non-mutation; `property: Get-DocsTyperCommandSite default names are lower-cased and hyphenated` (seed 102252).

CI: `poshqc / PowerShell QC` (windows-latest shards).
