# P1-T19 Targeted Pester (PoshQC MCP test + R-JUNIT)

Timestamp: 2026-10-12T18-23
Command: stat -c %Y artifacts/pester/pester-junit.xml
EXIT_CODE: 0
J0_COMMAND: stat -c %Y artifacts/pester/pester-junit.xml (before the MCP call)
J0_EXIT_CODE: 0
MCP_COMMAND: mcp__drm-copilot__run_poshqc_test workspace_root=<WORKSPACE_ROOT> scan_folders=["tests/scripts/claude-hooks", "tests/scripts/claude-runtime", "tests/scripts/claude-lib/orchestrator-state"]
MCP_CALL: returned
J2_EXIT_CODE: 0
J3_EXIT_CODE: 1
J4_EXIT_CODE: 0
J5_EXIT_CODE: 1
J6_EXIT_CODES: 0 0 0 0
Output Summary:
- J1: JUnit rewritten (mtime 1791844381 -> 1791845338)
- J2: tests=6093 failures=0 errors=0
- J3: no failed test case
- J4: 230 = FAM_BASE (170) + 60
- J5: 0
- J6: DocsOnly 28, DocsOnly.Exemption 15, DocsOnly.Decision 8, BodyNumber 9
- R-PARSE-PESTER: the main hook and the four new test files parse (J5 = 0 and every J6 count is non-zero).
- Result: PASS

JUNIT_MTIME_BEFORE: 1791844381
JUNIT_MTIME_AFTER: 1791845338
P1_TESTSUITES: tests=6093 failures=0 errors=0
P1_FAILED: none
J4: 230
J5: 0
J6_DOCSONLY: 28
J6_EXEMPTION: 15
J6_DECISION: 8
J6_BODYNUMBER: 9
