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
- Modules: PSScriptAnalyzer 1.22.0, Pester 5.6.1 (installed automatically via the helper if missing)

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

## Configuration

- PSScriptAnalyzer settings: `./settings/pssa.settings.psd1`
   - Enforces compatible syntax for 5.1 and 7.6, 4-space indentation, ShouldProcess for state-changing functions, and safety guards (no Invoke-Expression, no global vars, etc.).
- Pester settings: `./settings/pester.runsettings.psd1`
  - Runs tests under `scripts` and `tests/powershell`, outputs JUnit XML and CoverageGutters coverage, and enables coverage. The shipped runsettings carry no `CodeCoverage.Path` list; `Invoke-PoshQCTest` derives the coverage population from the workspace (see Coverage population below).
  - When `-ScanFolders` is supplied to `Invoke-PoshQCSuite` or the lower-level commands, the suite narrows discovery to those workspace-relative or workspace-contained folders.
- Coverage population (issue #527): `Invoke-PoshQCTest` measures the same file set for the same workspace whichever module copy is loaded.
  - Workspace configuration: `config/poshqc-coverage.json` with the schema `{"version": 1, "roots": [...]}`. Each root is a workspace-relative folder. The file is validated fail-fast, and every error names `config/poshqc-coverage.json`: empty content, invalid JSON, a `version` other than 1, a missing or non-array `roots`, and a blank, absolute, or `..`-segment entry are rejected. An empty `roots` array yields an empty population.
  - Precedence, reported as the source name: (1) `settings` - a caller-supplied settings file (`-SettingsPath` other than the module's own `settings/pester.runsettings.psd1`) with a non-empty `CodeCoverage.Path` is honored, and each entry that does not exist is pruned and logged; a `CodeCoverage.Path` list in the module's own settings file is ignored and the ignore is logged. (2) `config` - `config/poshqc-coverage.json` exists. (3) `fallback` - the effective test scan folders: explicit `-ScanFolders`, else `config/poshqc-scan.json`, else the settings `Run.Path`.
  - Built-in exclusions: `.ps1` and `.psm1` files only; files named `*.Tests.ps1` are excluded, as are files whose first root-relative segment is `tests` and files under any root-relative directory named in `DefaultExcludedDirs` (for example `node_modules`, `artifacts`, `.venv`). A nonexistent root is skipped with a warning.
  - An empty population disables coverage for that invocation, logs `Code coverage disabled for this invocation`, and still runs the tests.
  - Each run logs `Code coverage population: source=<source>; files=<count>` before Pester starts.

## Typical workflow

- Day-to-day: run `Invoke-PoshQCFormat`, `Invoke-PoshQCAnalyze`, then `Invoke-PoshQCTest` before committing.
- Bundled / scoped: run `Invoke-PoshQCSuite -Root . -ScanFolders @('scripts', 'tests/powershell')` when you want the suite to focus on selected workspace folders.
- CI: call `Invoke-PoshQCTest` to get tests + coverage and consume JUnit/CoverageGutters artifacts.

## Notes for standalone use

- Place `PoshQC.psm1`, `PoshQC.psd1`, and the `settings/` folder together; import the module from that directory.
- Adjust `settings/pester.runsettings.psd1` and `settings/pssa.settings.psd1` to match your repo paths and policies. Declare coverage roots in `config/poshqc-coverage.json` at the workspace root rather than in the runsettings.
