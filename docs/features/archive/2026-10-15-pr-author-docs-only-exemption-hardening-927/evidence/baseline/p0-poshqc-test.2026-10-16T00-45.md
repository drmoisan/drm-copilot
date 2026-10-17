# P0-T9 Baseline Pester (issue #927)

Timestamp: 2026-10-16T00-45
Command: stat -c %Y artifacts/pester/pester-junit.xml (R-JUNIT J0)
EXIT_CODE: 1
MCP_CALL: returned
Output Summary: Baseline Pester over SCAN_TEST (tests/scripts/claude-hooks, tests/scripts/codex-hooks, tests/scripts/claude-runtime) wrote a new JUnit file: tests=7014 failures=0 errors=0. No failed case. pr-author family passed 230, failed 0; DocsOnly suites passed 28/15/8; the five new suites are absent (0 each); merge-family failures 0; all 15 named existing suites have passing rows. Coverage is not read from this run (rule 3).

## R-JUNIT reads

- J0: `stat -c %Y artifacts/pester/pester-junit.xml` -> exit 1 (file absent)
  - JUNIT_MTIME_BEFORE: absent
- MCP: `mcp__drm-copilot__run_poshqc_test` workspace_root=<WORKSPACE_ROOT> scan_folders=["tests/scripts/claude-hooks", "tests/scripts/codex-hooks", "tests/scripts/claude-runtime"] -> ok=true
- J1: `stat -c %Y artifacts/pester/pester-junit.xml` -> exit 0
  - JUNIT_MTIME_AFTER: 1792111467 (file rewritten by this run)
- J2: BASELINE_TESTSUITES: tests=7014 failures=0 errors=0
  - FAIL_BASE: 0
- J3: no output
  - B_FAILED: none
- J4: FAM_BASE: 230
- J5: 0
- J6: 28, 15, 8 (DocsOnly, DocsOnly.Exemption, DocsOnly.Decision)
- J10: 0, 0, 0, 0, 0 (suites A, B, C, D, E do not exist yet)
- J12: 0
  - MERGE_FAM_FAILED_BASE: 0
- J13 (passed count per named existing suite; each greater than 0):
  - enforce-epic-merge-gate.Tests.ps1: 57
  - enforce-epic-merge-gate.Authorization.Tests.ps1: 16
  - enforce-epic-merge-gate.ItemResolution.Tests.ps1: 20
  - enforce-epic-merge-gate.WorktreeResolution.Tests.ps1: 11
  - enforce-epic-merge-gate.TriggerScoping.Tests.ps1: 13
  - enforce-epic-merge-gate.Coverage.Tests.ps1: 2
  - hook-command-parser.AcceptanceCases.Tests.ps1: 11
  - hook-command-consumers.Issue824.Tests.ps1: 24
  - enforce-epic-merge-gate-authorization.Tests.ps1: 29
  - enforce-epic-merge-gate-decision-surface.Tests.ps1: 14
  - enforce-epic-merge-gate-trigger-scoping.Tests.ps1: 8
  - epic-execution-gates.Tests.ps1: 50
  - hook-dependency-failure.SpecialCases.Tests.ps1: 14
  - hook-dependency-guard-completeness.Tests.ps1: 598
  - hook-import-failure-exemptions.Guard.Tests.ps1: 10
  - J13 method: one grep -o over the 15 patterns, counted per suite name with sort | uniq -c.
