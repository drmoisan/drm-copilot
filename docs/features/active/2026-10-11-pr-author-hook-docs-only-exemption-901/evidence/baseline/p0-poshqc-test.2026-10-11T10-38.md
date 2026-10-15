# P0-T8 Baseline Pester (PoshQC MCP test + R-JUNIT)

Timestamp: 2026-10-12T18-23
Command: stat -c %Y artifacts/pester/pester-junit.xml
EXIT_CODE: 0
J0_COMMAND: stat -c %Y artifacts/pester/pester-junit.xml (before the MCP call)
J0_EXIT_CODE: 1
MCP_COMMAND: mcp__drm-copilot__run_poshqc_test workspace_root=<WORKSPACE_ROOT> scan_folders=["tests/scripts/claude-hooks", "tests/scripts/claude-runtime", "tests/scripts/claude-lib/orchestrator-state"]
MCP_CALL: returned
J2_COMMAND: grep -m 1 -o -E '<testsuites [^>]*>' artifacts/pester/pester-junit.xml
J2_EXIT_CODE: 0
J3_COMMAND: grep -o -E 'testcase name="[^"]*" status="Failed"' artifacts/pester/pester-junit.xml
J3_EXIT_CODE: 1
J4_COMMAND: grep -c -E 'status="Passed" classname="[^"]*enforce-pr-author-skill' artifacts/pester/pester-junit.xml
J4_EXIT_CODE: 0
J5_COMMAND: grep -c -E 'status="Failed" classname="[^"]*enforce-pr-author-skill' artifacts/pester/pester-junit.xml
J5_EXIT_CODE: 1
Output Summary:
- J1: JUnit file rewritten by this run (absent before, present after)
- J2: tests=6025 failures=0 errors=0
- J3: no failed test case (grep exit 1 = no match)
- J4: 170 passed pr-author family cases
- J5: 0 failed pr-author family cases
- Coverage is not read locally; the per-file coverage source is the CI poshqc-test-results artifact named in P2-T7.
- Result: PASS

JUNIT_MTIME_BEFORE: absent
JUNIT_MTIME_AFTER: 1791844381
BASELINE_TESTSUITES: tests=6025 failures=0 errors=0
B_FAILED: none
FAM_BASE: 170
J5_COUNT: 0
