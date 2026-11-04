# [P3-T7] Pester gate: DocsAnalyzerPythonApi (issue #1022)

Timestamp: 2026-11-04T00-52
Command: pwsh -NoProfile -File SCRATCH/issue-1022-pester-suite.ps1 -WorktreeRoot <item worktree> -Suite tests/scripts/claude-lib/docs/DocsAnalyzerPythonApi.Tests.ps1 -CoverageFile .claude/lib/docs/DocsAnalyzerPythonApi.psm1 (Invoke-Pester with the configuration of scripts/powershell/PoshQC/settings/pester.runsettings.psd1, Run.PassThru, JUnit to artifacts/pester/pester-junit.xml, coverage over the module; one process)
EXIT_CODE: 0
Output Summary: tests/scripts/claude-lib/docs/DocsAnalyzerPythonApi.Tests.ps1: 12 passed, 0 failed, 0 errored, 0 skipped (JUnit testsuite element; result object Passed=12 Failed=0 Skipped=0). Line execution: .claude/lib/docs/DocsAnalyzerPythonApi.psm1 149 of 149 analyzed lines (100%). The JUnit file is well-formed; counts were read from it. The analyzer output over the corpus inputs equals the `python-public-api` subset of `tests/scripts/claude-lib/docs/fixtures/python-surface-corpus.json` (26 elements, 14 diagnostics) on every element field and every diagnostic.

## Toolchain for the new files

- Formatter: `Already formatted:` for `.claude/lib/docs/DocsAnalyzerPythonApi.psm1` and `tests/scripts/claude-lib/docs/DocsAnalyzerPythonApi.Tests.ps1`; 0 files rewritten on the final pass.
- Analyzer (direct Invoke-ScriptAnalyzer with scripts/powershell/PoshQC/settings/pssa.settings.psd1): 0 findings for the two files on the final pass (one intermittent engine NullReferenceException retried with a module reload).
- Physical line counts: `DocsAnalyzerPythonApi.psm1` 277; `DocsAnalyzerPythonApi.Tests.ps1` 217.
- Test defects fixed during this task (no production change): a `"$name:"` interpolation in generated fixtures, a helper returning `, $items` (a nested array through the pipeline), and a dynamic-`__all__` fixture whose helper def was itself a public top-level function.

## Design facts

- `Get-DocsPublicApiAllName` reads the literal forms at indentation 0 in statement order (`=`, annotated `=`, `+=`, `.extend([...])`, `.append("x")`) over plain strings and records the line of each name's first string; any other form (concatenation, comprehension, `list(...)`, star-unpacking, a non-literal element, or any `__all__` statement above indentation 0) marks the list dynamic.
- `Get-DocsPublicApiBinding` binds top-level `def`, `async def`, `class` (header span from the topmost decorator), simple and chained `NAME =`, `NAME: T =`, `NAME: T` and import names (statement span) at indentation 0 and inside top-level `if`, `elif`, `else`, `try`, `except` and `finally` bodies; a tuple or list target is `PUBLIC_API_UNPACKING_TARGET`, a repeated name where either binding sits in a branch is `PUBLIC_API_CONDITIONAL_DEFINITION` (first kept), a non-ASCII def or class name is `PYTHON_IDENTIFIER_NON_ASCII`.
- `Invoke-DocsAnalyzerPythonApi`: front-end diagnostics under `python-public-api`; a module segment that is not a Python identifier is `PUBLIC_API_MODULE_NOT_IMPORTABLE`; a `_`-prefixed segment yields nothing; with a literal `__all__` the elements are its names (`basis: all`, an unbound name kept as `symbol_kind: unresolved` with `PUBLIC_API_NAME_UNRESOLVED`, a top-level star import reported as `PUBLIC_API_STAR_IMPORT`); otherwise the naming rule (`basis: naming`, imports and `_` names excluded) with `PUBLIC_API_DYNAMIC_ALL` when `__all__` is dynamic. Elements through `Select-DocsUniqueElement`; no digest computed here.

## Behavior covered

- Corpus comparison; `analysis_method` `scanner` and no parent; captured inputs not mutated; every literal `__all__` form with `basis: all`, the unresolved name and the star import; the naming rule over branch bodies, chained and annotated targets, decorated async def, class; exclusion of `with` and `for` bodies, class members, imports and `_` names; `PUBLIC_API_CONDITIONAL_DEFINITION` (3 occurrences, first kept with its span); seven dynamic `__all__` forms each falling back to naming with `PUBLIC_API_DYNAMIC_ALL` and no element removed; `PUBLIC_API_UNPACKING_TARGET` and `PYTHON_IDENTIFIER_NON_ASCII` with survival; `PUBLIC_API_MODULE_NOT_IMPORTABLE`, `_` segments, paths outside every source root, and `__init__.py` as the package name.
- Property tests: `property: Invoke-DocsAnalyzerPythonApi output is byte-identical under permuted input order` (seed 102290); `property: Get-DocsPublicApiAllName final list equals the replayed literal operations` (seed 102291); `property: Get-DocsPublicApiBinding binds every generated top-level name once with its kind` (seed 102292).

CI: `poshqc / PowerShell QC` (windows-latest shards).
