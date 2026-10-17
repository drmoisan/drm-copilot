# R1 Baseline PoshQC Pester (Issue #927)

Timestamp: 2026-10-16T07-38
Command: stat -c %Y artifacts/pester/pester-junit.xml
EXIT_CODE: 0
Output Summary: The PoshQC MCP test call over SCAN_TEST returned and rewrote the JUnit file (mtime advanced). Root counters tests=7155 failures=0 errors=0; no failed testcase. Suite passed counts A to E are 30, 36, 14, 32, 9; suite F does not exist yet (0). DocsOnly suites 34, 19, 9 passed. Guard rows J14 and isolation rows J15a/J15b pass; J15c is 0 (suite F absent). Coverage is not read from this run (rule R1-3).

JUNIT_MTIME_BEFORE: 1792125734

Command 2: mcp__drm-copilot__run_poshqc_test workspace_root=<WORKSPACE_ROOT> scan_folders=["tests/scripts/claude-hooks", "tests/scripts/codex-hooks", "tests/scripts/claude-runtime"]
MCP_CALL: returned
EXIT_CODE_2: 0

J1 JUNIT_MTIME_AFTER: 1792136228 (greater than before; rewritten)
J2 R1_BASE_TESTSUITES: tests=7155 failures=0 errors=0
R1_FAIL_BASE: 0
J3 (grep exit 1, no match)
R1_B_FAILED: none
J5 PR_AUTHOR_FAILED: 0
J6 R1_J6_BASE: 34 19 9
J10 R1_J10_BASE: 30 36 14 32 9 0
J11 FAILED_PER_SUITE: 0 0 0 0 0 0
J12 MERGE_FAMILY_FAILED: 0
J13 PASSED enforce-epic-merge-gate.Tests.ps1: 57
J13 PASSED enforce-epic-merge-gate.Authorization.Tests.ps1: 16
J13 PASSED enforce-epic-merge-gate.ItemResolution.Tests.ps1: 20
J13 PASSED enforce-epic-merge-gate.WorktreeResolution.Tests.ps1: 11
J13 PASSED enforce-epic-merge-gate.TriggerScoping.Tests.ps1: 13
J13 PASSED enforce-epic-merge-gate.Coverage.Tests.ps1: 2
J13 PASSED hook-command-parser.AcceptanceCases.Tests.ps1: 11
J13 PASSED hook-command-consumers.Issue824.Tests.ps1: 24
J13 PASSED enforce-epic-merge-gate-authorization.Tests.ps1: 29
J13 PASSED enforce-epic-merge-gate-decision-surface.Tests.ps1: 14
J13 PASSED enforce-epic-merge-gate-trigger-scoping.Tests.ps1: 8
J13 PASSED epic-execution-gates.Tests.ps1: 50
J13 PASSED hook-dependency-failure.SpecialCases.Tests.ps1: 14
J13 PASSED hook-dependency-guard-completeness.Tests.ps1: 598
J13 PASSED hook-import-failure-exemptions.Guard.Tests.ps1: 10
J13 PASSED enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1: 349
J14 NO_PYTHON_GUARD_ROWS: 1 1
J15a: 1
J15b: 1
J15c: 0
