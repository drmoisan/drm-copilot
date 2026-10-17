# R4 CR-G3 fail-before (P6-T12, expect-fail)

Timestamp: 2026-10-17T03-46
Command: grep -c -F -e '$script:EpicStateParseCache = @{}' tests/scripts/claude-hooks/EpicStateIsolation.Discovery.Helpers.ps1 (precondition, printed 1); stat -c %y artifacts/pester/pester-junit.xml; mcp__drm-copilot__run_poshqc_test (workspace_root = worktree root, scan_folders = ["tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Memo.Tests.ps1"]); stat -c %y artifacts/pester/pester-junit.xml; D-JUNIT-DIAG awk command over artifacts/pester/pester-junit.xml
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
- MCP disposition: raised (ok false)
- Error text: Command exited with code 1.
- JUnit stat pre: 2026-10-16 23:40:54.581962600 -0400
- JUnit stat post: 2026-10-16 23:46:30.389338900 -0400 (differs)
- The JUnit file holds 10 testcase elements (the ten P_MEMO rows); the D-JUNIT-DIAG output follows verbatim.
FAILED: issue #935 PERF memo.PERF parse memo keeps texts that differ only in letter case apart
