# PoshQC

PoshQC is a lightweight PowerShell quality gate that wraps Invoke-Formatter, PSScriptAnalyzer, and Pester with repo-safe defaults. It targets both Windows PowerShell 5.1 and PowerShell 7.6+.

## What it does

- Formats PowerShell code with consistent indentation and pipeline alignment.
- Lints with PSScriptAnalyzer using a strict, dual-runtime ruleset.
- Runs Pester tests with code coverage (CoverageGutters output), plus an optional Koverage-friendly copy.
- Provides a single suite entry point that can format, analyze, and test a selected workspace scope.
- Provides a one-time dependency installer for PSScriptAnalyzer and Pester.

## Requirements

- PowerShell 5.1 or 7.6+
- Modules: PSScriptAnalyzer 1.22.0, Pester 5.9.0 or later, below 6.0 (installed automatically via the helper if missing)

## Getting started

1) Install dependencies (CurrentUser scope):

   ```powershell
   Import-Module ./PoshQC.psm1
   Install-PoshQCTool  # alias: Install-PoshQCTools
   ```
2) Format everything under the repo root:

   ```powershell
   Import-Module ./PoshQC.psm1
   Invoke-PoshQCFormat -Root .
   ```
3) Lint with PSScriptAnalyzer:

   ```powershell
   Invoke-PoshQCAnalyze -Root .
   ```
4) Test with Pester + coverage:

   ```powershell
   Invoke-PoshQCTest -Root .
   ```

5) Run the full suite against a selected scope:

   ```powershell
   Import-Module ./PoshQC.psm1
   Invoke-PoshQCSuite -Root . -ScanFolders @('scripts', 'tests/powershell')
   ```

   - Writes JUnit XML to `artifacts/pester/pester-junit.xml`.
   - Writes CoverageGutters XML to `artifacts/pester/powershell-coverage.xml`.
   - Also emits `*.koverage.xml` (relative paths) for VS Code Coverage Gutters and Koverage. Disable with `-DisableKoverageCopy` or override the path with `-KoverageOutputPath`.

## Functions

- `Install-PoshQCTool` / `Install-PoshQCTools`: install required modules.
- `Invoke-PoshQCFormat`: run Invoke-Formatter across the repo, honoring exclusions.
- `Invoke-PoshQCAnalyze`: run PSScriptAnalyzer with the bundled settings.
- `Invoke-PoshQCSuite`: run format, analyze, and test in one pass, optionally narrowing the scan scope with `-ScanFolders`.
- `Invoke-PoshQCTest`: run Pester using the bundled runsettings, including coverage and optional Koverage copy.
- `Convert-PoshQCCoverageToRelative`: utility to strip repo-root prefixes and write a `.koverage.xml` copy (used internally by `Invoke-PoshQCTest`).
- `Get-PoshQCShardSlice`: select one shard's test files; with `-Weight` (non-negative values, for example text sizes in bytes) the heaviest files are assigned first to the least-loaded shard, and a negative weight is rejected.
- `New-PoshQCShardManifest`: build the in-memory shard manifest (`shardIndex`, `shardCount`, `all`, `selected`, `selectedFullPath`).
- `Test-PoshQCShardCompleteness`: throw unless a set of shard manifests selects every test file exactly once.
- `Test-PoshQCShardTestCount`: throw unless the shard test counts sum to a discovery-pass test count.
- `Merge-PoshQCCoverageReport`: merge the CoverageGutters XML texts of the shards at LINE granularity (no file I/O, no threshold).
- `Get-PoshQCCoverageLineSummary`: return covered, missed, total, and percent from a report's LINE counter.
- `Invoke-PoshQCParallelTest`: run the Pester suite as concurrent shard processes on one machine and merge the results (see Local concurrent runs below).
- `Get-PoshQCParallelWorkerCount`: return the default worker count, half the logical processors, at least 1 and at most 8.
- `Merge-PoshQCJunitReport`: merge the JUnit XML texts of the shards into one report (no file I/O).
- `ConvertTo-PoshQCShardWeight` / `Export-PoshQCShardWeight`: build the measured shard-weights document from JUnit reports, and write it to a file.

## Configuration

- PSScriptAnalyzer settings: `./settings/pssa.settings.psd1`
   - Enforces compatible syntax for 5.1 and 7.6, 4-space indentation, ShouldProcess for state-changing functions, and safety guards (no Invoke-Expression, no global vars, etc.).
- Pester settings: `./settings/pester.runsettings.psd1`
  - Runs tests under `scripts` and `tests/powershell`, outputs JUnit XML and CoverageGutters coverage, and enables coverage. The shipped runsettings carry no `CodeCoverage.Path` list; `Invoke-PoshQCTest` derives the coverage population from the workspace (see Coverage population below).
  - Coverage uses Pester's profiler-based mode (`CodeCoverage.UseBreakpoints = $false`, issue #953), which needs Pester 5.4 or later and is faster than breakpoint mode on the same coverage population. The PoshQC suites target PowerShell 7; profiler mode under Windows PowerShell 5.1 is not exercised in CI. To use breakpoint mode, pass a settings file with `UseBreakpoints = $true` through `-SettingsPath`.
  - When `-ScanFolders` is supplied to `Invoke-PoshQCSuite` or the lower-level commands, the suite narrows discovery to those workspace-relative or workspace-contained folders.
- Coverage population (issue #527): `Invoke-PoshQCTest` measures the same file set for the same workspace whichever module copy is loaded.
  - Workspace configuration: `config/poshqc-coverage.json` with the schema `{"version": 1, "roots": [...]}`. Each root is a workspace-relative folder. The file is validated fail-fast, and every error names `config/poshqc-coverage.json`: empty content, invalid JSON, a `version` other than 1, a missing or non-array `roots`, and a blank, absolute, or `..`-segment entry are rejected. An empty `roots` array yields an empty population.
  - Precedence, reported as the source name: (1) `settings` - a caller-supplied settings file (`-SettingsPath` other than the module's own `settings/pester.runsettings.psd1`) with a non-empty `CodeCoverage.Path` is honored, and each entry that does not exist is pruned and logged; a `CodeCoverage.Path` list in the module's own settings file is ignored and the ignore is logged. (2) `config` - `config/poshqc-coverage.json` exists. (3) `fallback` - the effective test scan folders: explicit `-ScanFolders`, else `config/poshqc-scan.json`, else the settings `Run.Path`.
  - Built-in exclusions: `.ps1` and `.psm1` files only; files named `*.Tests.ps1` are excluded, as are files whose first root-relative segment is `tests` and files under any root-relative directory named in `DefaultExcludedDirs` (for example `node_modules`, `artifacts`, `.venv`). A nonexistent root is skipped with a warning.
  - An empty population disables coverage for that invocation, logs `Code coverage disabled for this invocation`, and still runs the tests.
  - Each run logs `Code coverage population: source=<source>; files=<count>` before Pester starts.
- Sharded runs (issue #953): `Invoke-PoshQCTest -ShardIndex <n> -ShardCount <N>` runs only shard n of N.
  - Test files are weighted by measured duration first (issue #1048): when `config/poshqc-shard-weights.json` exists at the workspace root, a listed file weighs its milliseconds and a file without an entry weighs the median of all listed values, so bytes and milliseconds are never mixed. Without the weights file, test files are weighted by the UTF-8 size in bytes of their text with CRLF line endings counted as LF, so runners whose checkouts differ only in line-ending conversion compute the same assignment. Files are assigned heaviest first to the shard with the least assigned weight (ties: fewer files, then the lower shard index; equal weights are taken in ordinal path order).
  - Weights file format: `{"version": 1, "unit": "ms", "files": {"<repository-relative forward-slash path>": <non-negative integer milliseconds>}}`. A document with another `version`, another `unit`, an empty `files` map, a non-relative key, or a negative or non-integer value is rejected with an error that names `poshqc-shard-weights.json`. Entries for files that no longer exist are ignored. The file is committed, so every CI shard computes the same assignment; stale or missing entries affect wall-clock time only, because the completeness and test-count checks still guard that every file runs once.
  - Regenerate the weights from the shard JUnit files of a full CI run, not from a local run (local durations differ from the runner's). `Export-PoshQCShardWeight` maps each JUnit `testsuite` name, an absolute path on the runner, to the path from its first `tests` or `scripts` segment, sums seconds per file, and writes integer milliseconds with sorted keys:

    ```powershell
    gh run download <run id> --pattern 'poshqc-test-results-shard-*' --dir <download dir>
    Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1
    Export-PoshQCShardWeight -JunitPath (Get-ChildItem -LiteralPath <download dir> -Recurse -Filter pester-junit.xml).FullName -OutputPath config/poshqc-shard-weights.json
    ```
  - `-ShardFileListPath <path>` writes the shard manifest (`shardIndex`, `shardCount`, `all`, `selected`) as JSON through the `-WriteShardFileList` seam.
  - A shard that selects no test file (more shards than test files) stops with an error before Pester runs.
  - `Merge-PoshQCCoverageReport` merges the shard reports with `ci = max(ci)` per line and recomputes the LINE and INSTRUCTION counters, so the merged LINE figures are exact. It omits `class` and `method` elements and METHOD and CLASS counters, because those cannot be recomputed from line hits.
- Output-path parameters (issue #1048): `Invoke-PoshQCTest -TestResultPath <path> -CoverageOutputPath <path>` replace the JUnit and coverage output paths of the settings file for one invocation; a relative path is resolved against `-Root`. When a parameter is omitted or blank, the settings value is used.
- Local concurrent runs (issue #1048): `Invoke-PoshQCParallelTest -Root . [-WorkerCount <n>]` runs the suite as concurrent shard processes on one machine. Pester 5 has no in-process parallel mode, so each shard is a separate `pwsh` process; the VS Code task `PoshQC: 4 test (Pester, parallel)` runs it.
  - The worker count defaults to half the logical processor count, at least 1 and at most 8 (`Get-PoshQCParallelWorkerCount`); `-WorkerCount` overrides it.
  - Each shard runs `Invoke-PoshQCTest -ShardIndex <i> -ShardCount <N>` with its JUnit, coverage, and manifest files and its console log (`shard.log`, standard error in `shard.log.err`) under `artifacts/pester/parallel/shard-<i>/`.
  - After every shard has exited, the runner checks the manifests with `Test-PoshQCShardCompleteness`, merges the JUnit reports with `Merge-PoshQCJunitReport` and the coverage reports with `Merge-PoshQCCoverageReport`, and writes `artifacts/pester/pester-junit.xml`, `artifacts/pester/powershell-coverage.xml`, and the `powershell-coverage.koverage.xml` copy.
  - The merged JUnit root carries the summed `tests`, `errors`, `failures`, and `disabled` counts, every shard's `testsuite` elements with `id` renumbered from 0, and a root `time` equal to the longest shard's root `time`: the shards run at the same time, so the longest shard is the wall-clock time of the run, not the sum of test time.
  - The runner returns an object with `ExitCode`, `WorkerCount`, `WallClockSeconds`, and per-shard exit codes and log paths. `ExitCode` is 0 only when every shard exited 0, wrote all three outputs, passed the completeness check, and merged; otherwise it is 1 and no merged artifact is written, so a partial result never replaces a full one. The runner never calls `exit`; the VS Code task exits with the returned `ExitCode`.

## Typical workflow

- Day-to-day: run `Invoke-PoshQCFormat`, `Invoke-PoshQCAnalyze`, then `Invoke-PoshQCTest` before committing.
- Bundled / scoped: run `Invoke-PoshQCSuite -Root . -ScanFolders @('scripts', 'tests/powershell')` when you want the suite to focus on selected workspace folders.
- CI: call `Invoke-PoshQCTest` to get tests + coverage and consume JUnit/CoverageGutters artifacts.

## Notes for standalone use

- Place `PoshQC.psm1`, `PoshQC.psd1`, and the `settings/` folder together; import the module from that directory.
- Adjust `settings/pester.runsettings.psd1` and `settings/pssa.settings.psd1` to match your repo paths and policies. Declare coverage roots in `config/poshqc-coverage.json` at the workspace root rather than in the runsettings.
