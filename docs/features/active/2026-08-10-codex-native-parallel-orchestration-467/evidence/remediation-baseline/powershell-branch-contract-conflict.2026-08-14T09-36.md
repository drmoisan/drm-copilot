# PowerShell Branch-Coverage Contract Conflict

Timestamp: 2026-08-14T23-32
Command: Inspect the repository PoshQC coverage runner, converter, settings, pinned tool manifest, installed Pester 5.6.1 emitter, official Pester 5.7.1 coverage source, and approved dependency manifests; compare all inspected repository surfaces with HEAD.
EXIT_CODE: 0
Output Summary: The configured toolchain measures command and line hits and emits placeholder branch fields. No approved deterministic source-attributable PowerShell control-flow branch collector is present. All inspected repository surfaces remain unchanged.

GENUINE_BRANCH_COLLECTOR_ESTABLISHED: NO

POWERSHELL_BRANCH_POLICY: POWERSHELL_BRANCH_POLICY_UNRESOLVED

## Repository Coverage Pipeline

- `scripts/powershell/PoshQC/PoshQC.Testing.psm1:294` requires Pester; lines 329-389 resolve and enable configured coverage; line 400 delegates measurement to `Invoke-Pester`; lines 402-417 only create a path-relativized Koverage-compatible copy. No branch outcomes are collected or derived.
- `scripts/powershell/PoshQC/convert-poshqc-coverage.ps1:22-34` selects the existing Pester XML and calls `Convert-PoshQCCoverageToRelative`; it rewrites paths only.
- `scripts/powershell/PoshQC/settings/pester.runsettings.psd1:17-23` enables Pester `CoverageGutters` output at `artifacts/pester/powershell-coverage.xml`; line 188 sets `CoveragePercentTarget = 0`. The configured target does not implement the repository's 75% branch threshold.
- `scripts/powershell/PoshQC/PoshQC.psm1:56-57` is the approved PowerShell tool manifest and pins only PSScriptAnalyzer 1.22.0 and Pester 5.6.1. Searches of `pyproject.toml`, `poetry.lock`, root and extension `package.json`/`package-lock.json`, and PoshQC manifests found no approved PowerShell control-flow branch collector dependency.

## Installed Pester 5.6.1

- Module: `C:/Users/DanMoisan/OneDrive/Documents/PowerShell/Modules/Pester/5.6.1/Pester.psm1`
- SHA-256: `A6A160D3F8A70A10BECCA15836841598C821BCB144A4770B176D0C7DE3088DB5`
- Lines 9634-9684 derive instruction and line coverage from command start lines and breakpoint `HitCount` values.
- Lines 9791-9797 emit each JaCoCo line with `mb = 0` and `cb = 0` regardless of source control flow.
- Lines 9813-9816 emit only instruction, line, method, and class counters.
- Line 9843 restricts `Add-JaCoCoCounter` to instruction, line, method, and class. `BRANCH` is not an accepted emitted counter type.

## Official Pester 5.7.1 Source

- Source: `https://raw.githubusercontent.com/pester/Pester/5.7.1/src/functions/Coverage.ps1`
- Retrieved source SHA-256: `FA31AF0CFEC8FAEB79AB74D2AEEE4030192BE3C7EE26166DAF219FE2652B7EFA`
- JaCoCo lines 1011-1012 still emit `mb = 0` and `cb = 0`.
- `Get-CoberturaReportXml` begins at line 1040 and aggregates missed/hit commands into line nodes.
- Cobertura line 1136 assigns class `branch-rate = 1`, line 1159 assigns package `branch-rate = 0`, and lines 1181-1183 assign `branches-valid = 0`, `branches-covered = 0`, and report `branch-rate = 1`. These are fixed zero-denominator placeholders, not measured branch outcomes.
- Line 1287 still restricts JaCoCo counter emission to instruction, line, method, and class.

## Dependency and Mutation Result

Scoped `git diff --name-only` was empty for every inspected repository runner, converter, settings, manifest, and lockfile. Their baseline SHA-256 values were recorded during inspection; no dependency, waiver, policy, suppression, threshold, collector, or coverage configuration was added or changed.

The available metrics cannot satisfy the repository requirement for at least 75% measured branch coverage. Command hits, line hits, AST source positions, and source-position correlation are not control-flow branch outcomes and are not reported as branch coverage.

REMEDIATION_REQUIRED: POWERSHELL_BRANCH_POLICY_UNRESOLVED
