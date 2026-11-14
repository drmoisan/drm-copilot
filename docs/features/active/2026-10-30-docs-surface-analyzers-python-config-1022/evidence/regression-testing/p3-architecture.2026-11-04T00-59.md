# [P3-T8] Pester gate: DocsAnalyzerArchitecture (issue #1022)

Timestamp: 2026-11-04T00-59
Command: pwsh -NoProfile -File SCRATCH/issue-1022-pester-suite.ps1 -WorktreeRoot <item worktree> -Suite tests/scripts/claude-lib/docs/DocsAnalyzerArchitecture.Tests.ps1 -CoverageFile .claude/lib/docs/DocsAnalyzerArchitecture.psm1 (Invoke-Pester with the configuration of scripts/powershell/PoshQC/settings/pester.runsettings.psd1, Run.PassThru, JUnit to artifacts/pester/pester-junit.xml, coverage over the module; one process)
EXIT_CODE: 0
Output Summary: tests/scripts/claude-lib/docs/DocsAnalyzerArchitecture.Tests.ps1: 9 passed, 0 failed, 0 errored, 0 skipped (JUnit testsuite element; result object Passed=9 Failed=0 Skipped=0). Line execution: .claude/lib/docs/DocsAnalyzerArchitecture.psm1 100 of 100 analyzed lines (100%). The JUnit file is well-formed; counts were read from it. The analyzer output over the corpus inputs equals the `python-architecture` subset of `tests/scripts/claude-lib/docs/fixtures/python-surface-corpus.json` (20 elements, 11 diagnostics) on every element field and every diagnostic.

## Toolchain for the new files

- Formatter: `Already formatted:` for `.claude/lib/docs/DocsAnalyzerArchitecture.psm1` and `tests/scripts/claude-lib/docs/DocsAnalyzerArchitecture.Tests.ps1`; 0 files rewritten on the final pass.
- Analyzer (direct Invoke-ScriptAnalyzer with scripts/powershell/PoshQC/settings/pssa.settings.psd1): 0 findings for the two files on the final pass (one intermittent engine NullReferenceException retried with a module reload).
- Physical line counts: `DocsAnalyzerArchitecture.psm1` 210; `DocsAnalyzerArchitecture.Tests.ps1` 228.
- Defect found and fixed during this task: the package segment list was built through an `if` expression, which unrolls a one-segment package into a scalar string (`.Count` then fails under strict mode); the variable is now typed `[string[]]` and wrapped with `@()`. The `-Statement` parameter accepts `$null` (a module without imports). Two test expectations were corrected (no bare `a` edge from `from a import b`; a second unresolvable relative import in the unit fixture).

## Design facts

- One `architecture-component` per `*.py` input with a valid dotted name: `component_kind` `package` for `__init__.py` (the component text is the `__init__.py` text) and `module` otherwise; a namespace directory without `__init__.py` has no package component (its modules remain components); an external distribution has no component. Each component is a `Select-DocsUniqueElement` candidate with no `LineRange`, so `New-DocsSurfaceElement -SourceText` computes the whole-file declaration digest and `line_range` is `null`; this module computes no digest.
- `Get-DocsPythonImportEdge` resolves `import` and `from` statements at any indentation (the `Statements` list of the import table, including `TYPE_CHECKING` and def-body imports) by longest dotted-prefix match against the known modules and packages; a relative level is resolved against the module's package (the module itself for `__init__.py`), and a level above the top-level package or a relative import in a module outside any package is `ARCHITECTURE_RELATIVE_IMPORT_UNRESOLVED`. Edges are unique, ordinally sorted, without self-edges, stored as `import_count` plus `import-0001`...; above 1000 edges `ARCHITECTURE_EDGE_LIMIT` keeps `import_count` only. `ARCHITECTURE_DYNAMIC_IMPORT` marks `importlib.import_module(`, `__import__(` and `importlib.util.spec_from_file_location(` (through aliases); `ARCHITECTURE_MODULE_NAME_INVALID` a path segment that is not a Python identifier.

## Behavior covered

- Corpus comparison; every component has `line_range` `null`, `source_sha256` equal to `Get-DocsDeclarationSha256 -Text <module text>` with no range, `analysis_method` `scanner` and no parent; captured inputs not mutated; an edit on a non-import line changes the component digest while the element identifier and the other component's digest are unchanged; relative imports (`..`, `..mod`, `.`, beyond the top-level package), `import a.b as x`, `from pkg import name, mod as alias`, an import inside a top-level `if`, ordinal edge order, `import_count`, package and module kinds, no `requests` edge or component, no namespace package component; `ARCHITECTURE_DYNAMIC_IMPORT` (4 occurrences through three callee forms and an alias) and `ARCHITECTURE_MODULE_NAME_INVALID` with the other components kept; `ARCHITECTURE_EDGE_LIMIT` (an `IN_TEST_ROWS` row) proven with 1001 input modules generated in test code: the 1001-edge component keeps `import_count` 1001 and no edge property, the 1000-edge component carries `import-0001` through `import-1000`, and all 1004 components are emitted.
- Property tests: `property: Invoke-DocsAnalyzerPythonArchitecture output is byte-identical under permuted input order` (seed 102300); `property: Get-DocsPythonImportEdge edges equal the longest-prefix resolution of generated imports` (seed 102301).

## Acceptance criteria checked off

- spec S4 (`python-public-api` tests: the literal `__all__` forms, the naming rule, exclusion of `_`-prefixed modules and names, the `PUBLIC_API_DYNAMIC_ALL` fallback with `basis: naming`; `python-architecture` tests: package and module components, internal import edges including relative imports as `import_count` plus ordinally sorted `import-NNNN` properties, no external-dependency component) in `spec.md`, proven by [P3-T7] and this task.

CI: `poshqc / PowerShell QC` (windows-latest shards).
