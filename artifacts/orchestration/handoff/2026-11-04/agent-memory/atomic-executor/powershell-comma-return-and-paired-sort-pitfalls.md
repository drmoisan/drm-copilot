---
name: powershell-comma-return-and-paired-sort-pitfalls
description: PowerShell 7.6 pitfalls hit while writing docs-lib modules: `@(f)` double-wraps a comma-returned array; `$x = if {...} { @() }` assigns $null (masked by coverage runs); comma binds tighter than + in array literals; missing sibling imports surface only in folder runs; paired `[Array]::Sort` leaves $items unsorted; a registry `Import-Module -Force` drops a suite's own analyzer imports from the test scope; `return & $Member` enumerates byte arrays; worktree Poetry env lacks pytest-cov
metadata:
  type: project
---

Facts (observed 2026-11-03, PowerShell 7.6.9, issue #1033 DocsScannerCommon.psm1):

- A function that ends with `return , $array` (the 1020 docs-lib convention) must be consumed as `$x = f` or `(f).Count`. `@(f)` yields Count 1 for an empty result (the empty array becomes the single element), and `foreach ($row in f)` runs once with `$row` equal to the whole array. Assign first, then wrap or iterate. Confirmed again in Phase 3 (2026-11-03) for NON-empty results too: `foreach ($s in f)`, `@(f)`, a hashtable value `X = @(f)`, and `f | Should -Be @(...)` all see one nested `object[]`; only `[object[]] $x = f` (or `$x = f`) unwraps. Grep new modules and suites for `in Get-Docs`, `@(Get-Docs`, `@(Select-Docs`, `@(ConvertTo-Docs` before the first test run.
- `[Array]::Sort($keys, $items, [System.StringComparer]::Ordinal)` with `[string[]] $keys` and `[object[]] $items` sorted the keys and left `$items` in its original order (the paired-array overload did not bind as expected). Use a `SortedDictionary[string, object]` keyed by `key + "`n" + index.ToString('D9')` (ordinal comparer) and read `.Values` for a stable ordinal sort.
- `Invoke-ScriptAnalyzer -Path <folder> -Recurse` occasionally fails with "Object reference not set to an instance of an object" and then hangs the pwsh process at ~1% CPU; on 2026-11-03 (Phase 3, loaded host) it failed twice in a row. Kill it and run one `Invoke-ScriptAnalyzer -Path <file>` call per file instead (42 files finished in about 15 s with identical findings); keep a per-file runner script under SCRATCH.
- A `[AllowNull()] [string]` parameter turns `$null` into `''`: a `$null` sentinel (dynamic prefix, absent handler) must be typed `[object]` or tested with `[string]::IsNullOrEmpty`, or it silently becomes a real empty value in output.
- Pester `It` names are templates: any `<word>` in a name (for example `<dynamic>`) is expanded as `$($word)` and fails under strict mode.
- Pester test names are templates: `It '... <T,> ...'` is expanded as `$($T,)` and fails with a ParseException; keep angle brackets out of `It` names.
- JUnit `testsuite` elements can be grepped per file (`<name>.Tests.ps1" tests="N" errors="N" failures="N"`) for per-suite counts; the coverage XML is JaCoCo (`class` elements with `counter[@type='LINE']`), not CoverageGutters, despite the settings name.

Added 2026-11-04 (issue #1021 Phases 3 to 6):

- `$x = if (...) { [object[]] $arr } else { ... }` unrolls a one-element array to the bare element (an OrderedDictionary finding became `$x`, so `$x[0]` returned its first value). Assign a default, then reassign inside the `if`.
- Pester `-ForEach` row data is evaluated at discovery, so it cannot call functions defined in `BeforeAll` (the container fails, the tests silently vanish: FAILED_CONTAINERS=1 with no failed test). Variables set in `BeforeDiscovery` are not visible at run time.
- A script that calls `Invoke-PoshQCTest` and then a report step never reaches the report when tests fail: `Run.Exit` ends the process (exit 255). Run the report script separately on `artifacts/pester/*.xml`.

Added 2026-11-04 (issue #1023 Phases 3 to 5):

- `$x = if (...) { @() } else { ... }` (or `{ [byte[]]@() }`) assigns `$null`, not an empty array; `[object[]] @($x)` then becomes `@($null)` and serializes as `[null]`. Coverage-instrumented `Invoke-PoshQCTest` runs masked this (a `DocsLedger.TestSupport.psm1` builder passed every folder run with coverage and failed in a plain `Invoke-Pester` process), so a suite that passes only under coverage is suspect. Assign `$x = [object[]]@()` first and reassign inside the `if`.
- In an array literal the comma binds tighter than `+`: `@('-Limit', 'diagnostic-' + ('0' * 64))` yields three elements (`'-Limit'`, `'diagnostic-'`, `'000…'`). Parenthesize the concatenation.
- A module that calls a sibling's function (`Test-DocsRelativePath` from `DocsSurface.psm1`) without importing that sibling passes alone (the suite's global import resolves it) and fails in the folder run with `CommandNotFoundException`. Every called sibling needs its own literal `Import-Module` line in the module.
- `Invoke-ScriptAnalyzer -Path <file>` fails with the null-reference error on the first file of a fresh process on a loaded host and passes on the second; put a known-clean warm-up file first in the per-file list.

Added 2026-11-04 (issue #1022 Phases 4 to 5):

- `Invoke-DocsAnalyzer` (1020 registry) re-imports the analyzer module with `Import-Module -Force` from inside the registry module: after any command or registry run, a suite's own earlier `Import-Module` of that analyzer loses its exported functions from the test scope (`CommandNotFoundException`). Reach analyzers through `Invoke-DocsAnalyzer` with the registry row in suites that also run the command.
- A context-member helper that does `return & $Member @ArgumentList` enumerates a returned `byte[]` or `string[]` into one pipeline object per element; write `return , (& $Member @ArgumentList)` and assign the result before iterating (`$x = f; foreach ($p in @($x))`).
- PSSA `PSReviewUnusedParameter` does not see a parameter used only inside a `.GetNewClosure()` scriptblock; copy it to a local first (`$target = $Log`) and reference the local in the closure. `$profile`/`$Profile` as a test variable triggers `PSAvoidAssignmentToAutomaticVariable`; test helpers named `New-*` trigger `PSUseShouldProcessForStateChangingFunctions` (use `Get-*`).
- `Sort-Object` and `-clike`/`-like` are culture- or case-sensitive in ways that break ordering assertions under a changed `CurrentCulture`; compare joined ordinal-sorted strings and use `-cmatch '[Aa]pp'` for case-distinct pairs.
- Snapshot diagnostics are sorted by `id` (a hash), so a path-ordered expectation over them fails; sort the collected paths before comparing.
- The worktree Poetry environment lacks `pytest-cov`, so the project `addopts` (`--cov-report=lcov:...`) makes pytest exit 4 before collection; pass `-o addopts=''` for contract tests that need no coverage.

**Why:** each cost a test-iteration round; the 1020 suites did not expose them because their callers use `(f).Count` and single-array sorts.

**How to apply:** when a new module returns arrays with the comma pattern, write callers and tests with assignment-first or `(f).Count`; when a module needs a keyed sort, use the SortedDictionary helper instead of the paired `[Array]::Sort`.
