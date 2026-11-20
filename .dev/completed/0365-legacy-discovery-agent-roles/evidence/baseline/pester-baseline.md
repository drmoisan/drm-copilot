# Pester Test Baseline (Coverage Mode) — legacy-discovery-agent-roles (#365)

Timestamp: 2026-07-18T11-16

Command: mcp__drm-copilot__run_poshqc_test (workspace_root = feature worktree root; scan_folders = ["tests/scripts/claude-runtime"]; coverage enabled via repo config scripts/powershell/PoshQC/settings/pester.runsettings.psd1). Result artifacts: artifacts/pester/pester-junit.xml, artifacts/pester/powershell-coverage.xml.

EXIT_CODE: 0

Output Summary:
- Test totals (JUnit `<testsuites>`): tests=20, failures=0, errors=0, disabled=0. All four
  existing `tests/scripts/claude-runtime/` suites pass:
  - claude-architecture-doc.Tests.ps1: 6 passed
  - claude-runtime-structure.Tests.ps1: 6 passed
  - claude-settings.Tests.ps1: 3 passed
  - test-name-uniqueness.Tests.ps1: 5 passed
- Coverage headline (JaCoCo report totals, scoped run): LINE covered=0, missed=2068
  (0.00% line coverage); BRANCH counters are not emitted at report level for this run.
  This 0% figure is inherent to a `.claude/` structural-test scan: the four claude-runtime
  suites read Markdown/JSON runtime assets and do not execute PowerShell production code, so
  the coverage instrument records the measured production files as uncovered. It is not a
  regression and does not reflect changed-file behavior.
- Changed-file coverage gate: N/A for this feature. This feature adds no executable production
  files. The four persona files are Markdown (no line/branch coverage, exempt from the 500-line
  limit) and the new `.Tests.ps1` file is test infrastructure excluded from coverage per
  general-unit-test policy. No changed-file coverage regression is possible.

This is the pre-change baseline; the new structural test `legacy-discovery-agent-roles.Tests.ps1`
does not yet exist at this point.
