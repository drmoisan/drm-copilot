# [P3-T4] Pester gate: DocsAnalyzerPythonCli (issue #1022)

Timestamp: 2026-11-04T00-33
Command: pwsh -NoProfile -File SCRATCH/issue-1022-pester-suite.ps1 -WorktreeRoot <item worktree> -Suite tests/scripts/claude-lib/docs/DocsAnalyzerPythonCli.Tests.ps1 -CoverageFile .claude/lib/docs/DocsAnalyzerPythonCli.psm1 (Invoke-Pester with the configuration of scripts/powershell/PoshQC/settings/pester.runsettings.psd1, Run.PassThru, JUnit to artifacts/pester/pester-junit.xml, coverage over the module; one process)
EXIT_CODE: 0
Output Summary: tests/scripts/claude-lib/docs/DocsAnalyzerPythonCli.Tests.ps1: 13 passed, 0 failed, 0 errored, 0 skipped (JUnit testsuite element; result object Passed=13 Failed=0 Skipped=0). Line execution: .claude/lib/docs/DocsAnalyzerPythonCli.psm1 117 of 117 analyzed lines (100%). The JUnit file is well-formed; counts were read from it. The analyzer output over the corpus inputs is 41 elements and 18 diagnostics, equal to the `python-cli` subset of `tests/scripts/claude-lib/docs/fixtures/python-surface-corpus.json` on every element field (kind, path, declaration, `element_id`, name, `parent_id`, `line_range`, `source_sha256`, properties, `analyzer_id`, `analysis_method`) and every diagnostic (code, path, `analyzer_id`).

## Toolchain for the new files

- Formatter: `Already formatted:` for `.claude/lib/docs/DocsAnalyzerPythonCli.psm1` and `tests/scripts/claude-lib/docs/DocsAnalyzerPythonCli.Tests.ps1`; 0 files rewritten.
- Analyzer (direct Invoke-ScriptAnalyzer with scripts/powershell/PoshQC/settings/pssa.settings.psd1): 0 findings for the two files on the final pass (one intermittent engine NullReferenceException retried with a module reload). An earlier pass reported `PSAvoidAssignmentToAutomaticVariable` for a test helper parameter named `$Input`, which also caused an `ArgumentException: index` at run time; the parameter was renamed.
- Physical line counts: `DocsAnalyzerPythonCli.psm1` 252; `DocsAnalyzerPythonCli.Tests.ps1` 202.

## Design facts

- `Invoke-DocsAnalyzerPythonCli` reads `source_roots` from `-Selection` (default `.`), runs the shared front-end of `DocsPythonBindings.psm1` over every `.py` input (front-end diagnostics under `python-cli`; a blocking one removes the file's elements), merges the argparse, Click and Typer site recognizers, reads the console-script tables with `Get-DocsTomlScriptEntry`, and attaches a script to a root site only when the target module resolves through `Get-DocsModuleDottedName` to exactly one input whose root site `Attach` equals the attribute. The `module:attr` target is never exported (asserted: no property value containing `:` and no `nowhere` in the element JSON).
- `Resolve-DocsCliRootName` applies the order console-script, literal, module; `ConvertTo-DocsCliElement` returns the `Select-DocsUniqueElement` candidate whose parameters are the `New-DocsSurfaceElement` argument set with `LineRange` from `ConvertTo-DocsLineRange`; the digest is computed by 1020 inside `New-DocsSurfaceElement`, and this module computes none.
- Inputs are ordered ordinally by path; the output is byte-identical under permuted input order (`property: Invoke-DocsAnalyzerPythonCli output is byte-identical under permuted input order`, seed 102260). Other property tests: `property: Resolve-DocsCliRootName picks the first present name in the fixed order` (seed 102261), `property: ConvertTo-DocsCliElement line range equals the site span and the name is the last declaration segment` (seed 102262).

## Behavior covered

- Corpus comparison; every `cli-option` parent is a `cli-command`; `analysis_method` `scanner` on every element; the console script `tool` is the root of the attached argparse tree (the `argtool` root and the `typ` Typer root are not emitted; `tool run` and `typ-script sub` carry the script element's `parent_id`); `attached: false` for a missing module (`missing`), a non-root attribute (`gui`) and an absent attribute (`poet`); captured inputs are not mutated; a blocking lexer diagnostic removes one file's elements and keeps the others; an unattached root without a literal is named by its module dotted name with `name_source` `module`, and two such roots yield one `DUPLICATE_DECLARATION` under `docs-inventory`; inputs with `text` `$null` and non-Python paths yield nothing.

## Acceptance criteria checked off

- spec S2 (`python-cli` tests: argparse nested subcommands and positional arguments, Click naming with suffix removal, Typer explicit and default names, the three console-script tables with the script name as the root of an attached tree, `attached: false`, a `cli-command` parent for every `cli-option`) in `spec.md`.
- user story U2 (Typer default and explicit names, attached console-script root) in `user-story.md`.

CI: `poshqc / PowerShell QC` (windows-latest shards).
