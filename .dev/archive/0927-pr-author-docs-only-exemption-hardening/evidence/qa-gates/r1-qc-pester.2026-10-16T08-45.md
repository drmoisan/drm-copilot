# R1 QC Step 3: PoshQC Pester (Issue #927, loop pass 2)

Timestamp: 2026-10-16T08-45
Command: stat -c %Y artifacts/pester/pester-junit.xml
EXIT_CODE: 0
Output Summary: Loop pass 2 passes. tests=7183 failures=0 errors=0 (R1_FAIL_BASE 0). Suite passed counts A 30, B 43 (base + 7), C 14, D 38 (base + 6), E 9 (base; CR-5 retained per D-R1-6 fallback), F 13. All 28 Appendix R1-T tokens pass. Guard rows J14, isolation rows J15a/J15b/J15c pass. Coverage is not read from this run (rule R1-3).

JUNIT_MTIME_BEFORE: 1792139381

Command 2: mcp__drm-copilot__run_poshqc_test workspace_root=<WORKSPACE_ROOT> scan_folders=["tests/scripts/claude-hooks", "tests/scripts/codex-hooks", "tests/scripts/claude-runtime"]
MCP_CALL: returned
EXIT_CODE_2: 0

J1 JUNIT_MTIME_AFTER: 1792140254 (greater than before; rewritten)
J2 TESTSUITES: tests=7183 failures=0 errors=0
J3: no failed testcase (grep exit 1); no line outside the R1_B_FAILED set (none)
J5 PR_AUTHOR_FAILED: 0
J6 PASSED_DOCSONLY: 35 19 9 (R1_J6_BASE 34 19 9; docs-only + 1, others unchanged)
J10 PASSED_PER_SUITE: 30 43 14 38 9 13 (E = base because CR5_DECISION: RETAINED)
J11 FAILED_PER_SUITE: 0 0 0 0 0 0 (one alternation grep over the six suite patterns printed 0, exit 1)
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
J13 PASSED enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1: 350
J14 NO_PYTHON_GUARD_ROWS: 1 1
J15a: 1
J15b: 1 (CR-5 retained)
J15c: 1

J16 (each count 1, status Passed): F1 1, F2 1, F3 1, F4 1, F5 1, F6 1, F7 1, F8 1, F9 1, F10 1, F11 1, F12 1, F13 1, D1 1, D2 1, D3 1, D4 1, D5 1, D6 1, B1 1, B2 1, B3 1, B4 1, B5 1, B6 1, B7 1, X0 1, X1 1

CR5_DECISION: RETAINED (fallback applied after loop pass 1; see r1-qc-pester.2026-10-16T08-30.md)
