# Fail-First: PoshQC.CoverageConfig.Tests.ps1 Against Pre-Fix Code (P2-T5)

Timestamp: 2026-10-02T08-45
Command: CI-evidence deviation DEV-P2-T5 (replaces TR args 'tests/scripts/powershell/PoshQC/PoshQC.CoverageConfig.Tests.ps1', ''). Source: the same run as P2-T4, https://github.com/drmoisan/drm-copilot/actions/runs/36983544629, job https://github.com/drmoisan/drm-copilot/actions/runs/36983544629/job/110763320058 (temporary branch `tmp/527-phase2-failfirst` at PHASE2_SHA bb233fe7). Failing nodes read with the Read and Grep tools from `artifacts/ci/run-36983544629/job.log` lines 1331-1456.
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: PASSED=0 FAILED=17 SKIPPED=0 MISSING_REQUIRED=0 FAILED_CONTAINERS=0 for PoshQC.CoverageConfig.Tests.ps1 (C1, C2, the eight C3 rows, P1-P7). Each failure names a function that does not exist before the fix (`CommandNotFoundException` for `Get-PoshQCCoverageConfigRoot` / `Resolve-PoshQCCoveragePopulation`, or the C3 `Should -Throw` message reporting that term as not recognized). No container or discovery failure line is present in the log.
- Acceptance: `FAILED=` greater than 0 and `PASSED=0`. Met.

## Failed nodes (job log `##[error][-]` lines)

```text
Get-PoshQCCoverageConfigRoot (issue #527).reports the configuration as absent when the file does not exist
Get-PoshQCCoverageConfigRoot (issue #527).returns the validated roots for a version 1 document
Get-PoshQCCoverageConfigRoot (issue #527).fails fast naming config/poshqc-coverage.json for invalid JSON
Get-PoshQCCoverageConfigRoot (issue #527).fails fast naming config/poshqc-coverage.json for empty content
Get-PoshQCCoverageConfigRoot (issue #527).fails fast naming config/poshqc-coverage.json for unsupported version
Get-PoshQCCoverageConfigRoot (issue #527).fails fast naming config/poshqc-coverage.json for missing roots
Get-PoshQCCoverageConfigRoot (issue #527).fails fast naming config/poshqc-coverage.json for non-array roots
Get-PoshQCCoverageConfigRoot (issue #527).fails fast naming config/poshqc-coverage.json for blank entry
Get-PoshQCCoverageConfigRoot (issue #527).fails fast naming config/poshqc-coverage.json for absolute entry
Get-PoshQCCoverageConfigRoot (issue #527).fails fast naming config/poshqc-coverage.json for parent-traversal entry
Resolve-PoshQCCoveragePopulation precedence (issue #527).honors a non-empty CodeCoverage.Path from a caller-supplied settings file over the workspace config
Resolve-PoshQCCoveragePopulation precedence (issue #527).prunes and logs each nonexistent caller-supplied settings path
Resolve-PoshQCCoveragePopulation precedence (issue #527).ignores CodeCoverage.Path in the module-default settings file and logs that it was ignored
Resolve-PoshQCCoveragePopulation precedence (issue #527).uses the workspace config roots over the fallback scan folders
Resolve-PoshQCCoveragePopulation precedence (issue #527).falls back to the scan-folder roots when no workspace config exists
Resolve-PoshQCCoveragePopulation precedence (issue #527).falls back to the settings Run.Path when no scan folders are supplied
Resolve-PoshQCCoveragePopulation precedence (issue #527).returns source config with an empty population when every configured root is missing
```
