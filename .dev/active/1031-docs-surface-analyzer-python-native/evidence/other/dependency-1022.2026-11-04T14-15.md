# 1022 Upstream Preconditions ([P0-T3])

Timestamp: 2026-11-04T14-15
Command: sh SCRATCH/issue-1031-run.sh issue-1031-dep1022.ps1 issue-1031-dep1022.out (imports DocsJson, DocsSurface, DocsAnalyzerRegistry, DocsSourceText, DocsTomlKeys; reads the registry rows, the `inventory` dispatch row, DocsInventory.psm1, the corpus and core.json; recomputes every corpus element through New-DocsSurfaceElement)
EXIT_CODE: 0
Output Summary: every U-5 and U-6 item PASS; corpus recomputation 110 of 110 elements equal; INVENTORY_SEAM absent; Pester gate over every suite under TESTS 1315 passed, 0 failed, 0 errors (67 suites).

## U-5

- PASS scanner row `python-cli`: `AnalysisMethod` `scanner`, kinds `cli-command`, `cli-option`, `DocsAnalyzerPythonCli.psm1`, `Invoke-DocsAnalyzerPythonCli`.
- PASS scanner row `python-http`: kinds `http-route`, `DocsAnalyzerPythonHttp.psm1`, `Invoke-DocsAnalyzerPythonHttp`.
- PASS scanner row `python-public-api`: kinds `public-symbol`, `DocsAnalyzerPythonApi.psm1`, `Invoke-DocsAnalyzerPythonApi`.
- PASS scanner row `python-architecture`: kinds `architecture-component`, `DocsAnalyzerArchitecture.psm1`, `Invoke-DocsAnalyzerPythonArchitecture`.
- PASS `inventory` row under the 1022 anchor of `LIB/Invoke-DocsCommand.ps1`: `Option = @{ Profile = 'value'; Analyzer = 'multi'; Revision = 'value'; Write = 'switch' }` (no analysis-method option).
- PASS `Invoke-DocsInventoryCommand` flow: profile read, `Select-DocsInventoryRow` (`Select-DocsAnalyzerRegistration` without `-NativeAvailable`), `Context.ListFile`, `Get-DocsInventorySelection`, `Context.ReadBytes`, `New-DocsCapturedInput`, one `Invoke-DocsAnalyzer -Registration $row -CapturedInput -Selection` per row, `New-DocsInventorySnapshot`, self-validation, optional `Context.WriteText`. No native call and no analysis-method option.

## U-6

- PASS corpus `FIXTURES/python-surface-corpus.json` parses with `ConvertFrom-DocsJsonText` (0 findings); top-level keys `description`, `expected_diagnostics`, `expected_elements`, `inputs`, `source_roots`.
- PASS recomputation: 110 expected elements of the four identifiers rebuilt with `New-DocsSurfaceElement -SourceText <corpus input text> [-LineRange start,end] [-ParentId]`; 110 `element_id` and 110 `source_sha256` values equal the corpus values, 0 mismatched (the `architecture-component` rows with `line_range` `null` digest the whole normalized file).
- PASS `Get-DocsTomlScriptEntry -Text` returns `@{ Entries; Diagnostics }`; the corpus `pyproject.toml` yields five entries (tables `project.scripts` x3, `project.gui-scripts`, `tool.poetry.scripts`).
- PASS `New-DocsDiagnosticAggregate` (no parameters) and `Add-DocsDiagnosticOccurrence -Aggregate -AnalyzerId -Code -Path [-Line] [-Severity error|warning]`; two occurrences of one key give one diagnostic with message `2 occurrence(s); first at line 2.`.

## Recorded values

- SELECTION_SHAPE: `-Selection` is the profile `surface_selection` dictionary passed unchanged by `Invoke-DocsInventoryCommand` (keys used by 1022: `source_roots`, `exclusions`, `element_kinds`, optional `analyzers`); `surface_selection.source_roots` is the source of the source roots.
- SCRIPT_ENTRY_SHAPE: `Get-DocsTomlScriptEntry -Text <pyproject text>` returns `@{ Entries = @(@{ Table; Name; Target; Span }); Diagnostics }`, `Table` one of `project.scripts`, `project.gui-scripts`, `tool.poetry.scripts`; `Span` is `@(start, end)`.
- AGGREGATE_API: `$aggregate = New-DocsDiagnosticAggregate`; `Add-DocsDiagnosticOccurrence -Aggregate $aggregate -AnalyzerId <id> -Code <CODE> -Path <path> -Line <n> -Severity error|warning`; result in `$aggregate.Diagnostics` (one per analyzer, code, path).
- CORPUS_SHAPE: `inputs` (map path to text, 26 entries), `source_roots` (`src`), `expected_elements` (fields `analysis_method`, `analyzer_id`, `declaration`, `element_id`, `kind`, `line_range` `{start, end}` or `null`, `name`, `parent_declaration`, `parent_id`, `parent_path`, `path`, `properties` `[{name, value}]`, `source_sha256`; 110 rows: python-cli 41, python-public-api 26, python-http 23, python-architecture 20), `expected_diagnostics` (fields `analyzer_id`, `code`, `path`; 57 rows).
- INVENTORY_SEAM: `absent`
- CORE_TAIL: `last` (the final docs entry `.claude/lib/docs/DocsInventory.psm1` is the last of 334 `CORE` `paths`).

## Pester gate

Command: sh SCRATCH/issue-1031-run.sh issue-1031-poshqc-gate.ps1 issue-1031-gate-p0t3.out -NoCoverage -Paths tests/scripts/claude-lib/docs (branch-current Invoke-PoshQCTest)
EXIT_CODE: 0
Counts from artifacts/pester/pester-junit.xml: tests=1315 failures=0 errors=0 (67 suites under TESTS).
