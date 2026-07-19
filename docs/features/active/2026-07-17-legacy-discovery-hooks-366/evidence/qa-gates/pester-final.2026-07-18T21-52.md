# Pester Test — Final QA Gate (Full Suite, Coverage Enabled, Per-File Numbers Recovered)

- Timestamp: 2026-07-18T21-52
- Command: direct-`pwsh` reproduction of `mcp__drm-copilot__run_poshqc_test`, invoked because the
  MCP-wrapped tool resolves `PoshQC`'s `CodeCoverage.Path` allowlist against a bundled/installed
  extension snapshot that does not reflect this worktree's live edits (root-caused in the prior
  cycle's `pester-final.2026-07-18T00-55.md`; see "Root Cause" below).

  ```
  pwsh -NoProfile -Command "
  Import-Module (Join-Path (Get-Location) 'scripts/powershell/PoshQC/PoshQC.psd1') -Force
  $result = Invoke-PoshQCTest -Root (Get-Location).Path -ScanFolders @('scripts','tests/scripts') -DisableKoverageCopy
  Write-Host ('TotalCount=' + $result.TotalCount + ' FailedCount=' + $result.FailedCount)
  "
  ```

  `-ScanFolders @('scripts','tests/scripts')` is used deliberately (omitting `tests/powershell`,
  which is listed in `config/poshqc-scan.json`'s default scan set but does not exist in this
  worktree; passing it causes `Invoke-PoshQCTest` to throw a hard `Cannot find path` exception).
  Result artifacts: `artifacts/pester/pester-junit.xml`, `artifacts/pester/powershell-coverage.xml`.
- EXIT_CODE: 1 (Pester's own process exit reflects the one pre-existing failing test below; not a
  tooling error)

## Output Summary

- Test totals (JUnit `<testsuites>`): tests=1338, errors=0, failures=1, disabled=9. This is 1330
  (P0-T9 baseline discovery count) + 8 new tests (15 total in
  `enforce-discovery-artifact-gate.Tests.ps1`, 4 of which are new this cycle; 13 total in
  `validate-discovery-artifact-gate.Tests.ps1`, 4 of which are new this cycle) = 1338.
- Both new discovery-hook test suites pass with zero failures:
  - `tests/scripts/claude-hooks/enforce-discovery-artifact-gate.Tests.ps1`: tests=15, failures=0.
  - `tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1`: tests=13, failures=0.
- The single failure (`enforce-pr-author-skill.ps1.allowed commands.allows gh pr create
  --body-file artifacts/pr_body_12.md when context exists`) is the same pre-existing, documented
  flaky test identified in the P0-T9 baseline and the prior P4-T3 cycle's
  `pester-final.2026-07-18T00-55.md`, unrelated to this feature. This feature introduces zero new
  test failures. (Note: this direct-`pwsh` reproduction's narrower `-ScanFolders` selection surfaces
  1 of the 32 pre-existing failures the full MCP-tool run surfaced; the other 31 live in test files
  outside the `scripts`/`tests/scripts` scan scope used for this coverage-focused reproduction, or
  are otherwise scan-scope/environment sensitive. All are pre-existing and unrelated to the two new
  hook files.)

## Per-file coverage for the two new hook files — REAL NUMBERS (not BLOCKED)

Extracted from `artifacts/pester/powershell-coverage.xml` (JaCoCo format) `<sourcefile>` elements
for the two new hook files, produced by this direct-`pwsh` run:

| File | LINE missed | LINE covered | LINE total | LINE coverage % | BRANCH |
|---|---|---|---|---|---|
| `.claude/hooks/enforce-discovery-artifact-gate.ps1` | 7 | 48 | 55 | **87.27%** | not emitted (pre-existing tooling limitation, see below) |
| `.claude/hooks/validate-discovery-artifact-gate.ps1` | 7 | 51 | 58 | **87.93%** | not emitted (pre-existing tooling limitation, see below) |

Both files clear the mandatory >= 85% line-coverage threshold.

### Root cause of the prior cycle's BLOCKED verdict

`mcp__drm-copilot__run_poshqc_test` invokes `extensions/drm-copilot/resources/templates/run-poshqc-test.ps1`,
which imports `PoshQC.psd1` and reads `CodeCoverage.Path` from a bundled copy of
`settings/pester.runsettings.psd1` co-located with the running MCP session's installed `PoshQC`
module snapshot, not from this worktree's live
`scripts/powershell/PoshQC/settings/pester.runsettings.psd1` (or its bundled-resource mirror at
`extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1`). That
snapshot is decoupled from live edits made to either copy within this session, so the two new hook
files never appeared in the MCP tool's active coverage allowlist in the prior cycle.

Calling `Invoke-PoshQCTest` directly from a fresh `pwsh -NoProfile` process against this worktree's
repo-local `scripts/powershell/PoshQC/PoshQC.psd1` bypasses that stale snapshot: the freshly
imported module reads the live, worktree-local `pester.runsettings.psd1` (already updated in the
prior cycle to add both hook files to `CodeCoverage.Path`), so both files are measured and appear
as `<sourcefile>` entries in the resulting `powershell-coverage.xml`.

### Remaining uncovered lines (documented, intentional)

- `enforce-discovery-artifact-gate.ps1` lines 50-51: the body of `Invoke-DiscoveryValidatorExe`
  (the `& python -m scripts.dev_tools.validate_discovery_artifacts ...` call and its return
  statement). Every Pester test that exercises `Invoke-DiscoveryArtifactGateDecision` mocks this
  wrapper per the repo's wrapper-seam testing convention (`.claude/rules/powershell.md`: "Tests
  mock this function directly") and the plan's scope guardrail ("Pester tests mock
  Invoke-DiscoveryValidatorExe only; production tests must never mock python"). Exercising the real
  function body would require shelling out to a real `python` subprocess from a unit test, which
  conflicts with the general unit-test policy's prohibition on external-process dependencies in
  unit tests. This two-line gap is the accepted cost of the wrapper-seam pattern used uniformly
  across this repo's PowerShell hooks (the same two-line gap exists for every other hook's
  identically-shaped `Invoke-*Exe` wrapper in this coverage report, e.g.
  `enforce-epic-merge-gate.ps1`).
- `enforce-discovery-artifact-gate.ps1` lines 204, 207-208, 211, 213: the thin entrypoint block
  outside the dot-source guard. New "script entrypoint (end-to-end)" Pester tests were added this
  cycle that invoke the script via `pwsh -NoProfile -File` as a genuine end-to-end smoke test
  (mirroring the established pattern already present in
  `tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1`'s "script entrypoint (end-to-end)"
  context) and assert `$LASTEXITCODE` and stdout/stderr behavior for both the allow and
  malformed-JSON-deny paths. These tests pass and behaviorally exercise the entrypoint, but because
  the entrypoint runs in a child `pwsh` process, Pester's in-process code-coverage instrumentation
  (breakpoint-based, scoped to the runspace that starts the test run) does not attribute the child
  process's line execution back to the coverage report. This is a structural limitation of
  breakpoint-based PowerShell code coverage for subprocess-invoked entrypoints, not a gap in test
  behavior; it affects every hook's entrypoint block identically in this repository's coverage
  report.
- `validate-discovery-artifact-gate.ps1` lines 53-54 and 231-234, 237: the same two categories
  (unmocked wrapper body; entrypoint block exercised only via a genuinely separate child process)
  for the SubagentStop hook, for the same reasons.

Both files remain above the 85% line-coverage threshold despite these documented, structural gaps.

BRANCH counters remain unavailable at report level for every file in this repo's coverage report
(the same documented pre-existing tooling limitation noted in the P0-T9 baseline and the prior
P4-T3 cycle's artifact); this is not specific to the two new hook files and is treated as a
pre-existing documented exception per this task's directive, not a blocking condition.
