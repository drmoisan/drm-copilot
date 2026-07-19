# Pester Test Baseline (Coverage Mode)

- Timestamp: 2026-07-18T00-15
- Command: `mcp__drm-copilot__run_poshqc_test` (workspace_root = repo worktree root; full existing Pester suite; coverage enabled via `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`). Result artifacts: `artifacts/pester/pester-junit.xml`, `artifacts/pester/powershell-coverage.xml`.
- EXIT_CODE: 32

## Output Summary

- Test totals (JUnit `<testsuites>`): tests=1310, errors=0, failures=32, disabled=9.
- The 32 failures are pre-existing and confined to test suites unrelated to this feature's scope
  (`.claude/hooks/enforce-discovery-artifact-gate.ps1`, `.claude/hooks/validate-discovery-artifact-gate.ps1`
  do not yet exist at this baseline point):
  - `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1`: 1 failure (of 46).
  - `tests/scripts/powershell/PoshQC/PoshQC.Comprehensive.Tests.ps1`: 26 failures (of 33).
  - `tests/scripts/powershell/PoshQC/PoshQC.EntryPoints.Tests.ps1`: 1 failure (of 5).
  - `tests/scripts/powershell/PoshQC/PoshQC.ScanFolders.Tests.ps1`: 4 failures (of 17).
  - Sum: 1 + 26 + 1 + 4 = 32, matching the process exit code (Pester returns the failed-test
    count as the exit code for this MCP wrapper).
  - No suite under `tests/scripts/claude-hooks/enforce-discovery-artifact-gate.Tests.ps1` or
    `tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1` exists yet, so these
    32 failures are pre-existing baseline state, not introduced by this feature.
- Coverage headline (JaCoCo report totals, `artifacts/pester/powershell-coverage.xml`, root `<report>` counter):
  LINE missed=219, covered=1849, total=2068 -> **89.41% line coverage**.
  BRANCH counters are not emitted at report level for this run (a documented, pre-existing
  limitation of this PoshQC/Pester coverage pipeline; see the same note in
  `docs/features/active/2026-07-17-legacy-discovery-agent-roles-365/evidence/baseline/pester-baseline.md`).
  No BRANCH counter total is available to report numerically at this repository configuration;
  the line-coverage headline above is the numeric value used for the delta comparison in P4-T4.
- This is the pre-change baseline; neither `.claude/hooks/enforce-discovery-artifact-gate.ps1` nor
  `.claude/hooks/validate-discovery-artifact-gate.ps1` nor their mirrored Pester test files exist
  at this point.
