# R1 Expect-fail Run Against the Unchanged Helper (Issue #927, [P2-T6])

Timestamp: 2026-10-16T08-01
Command: grep -c -E 'status="Failed" classname="[^"]*enforce-pr-author-skill' artifacts/pester/pester-junit.xml
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: Fail-before evidence. The PoshQC MCP test run over SCAN_TEST, before the helper defines Invoke-DocsOnlyBoundedNative, reports tests=7183 failures=19 errors=0. The 19 failures are exactly the 13 suite F rows (F1 to F13) and the 6 new suite D rows (D1 to D6); the new B1 to B7, X0, and X1 rows pass. No pr-author suite failed (J5 = 0).

JUNIT_MTIME_BEFORE: 1792136228

Command 2: mcp__drm-copilot__run_poshqc_test workspace_root=<WORKSPACE_ROOT> scan_folders=["tests/scripts/claude-hooks", "tests/scripts/codex-hooks", "tests/scripts/claude-runtime"]
MCP_CALL: error Command exited with code 19.

J1 JUNIT_MTIME_AFTER: 1792137653 (greater than before; rewritten)
J2 TESTSUITES: tests=7183 failures=19 errors=0 (R1_FAIL_BASE 0 + 19)
J3 FAILED_ROWS (19; classname values omitted per rule R1-2):
FAILED: hook-docs-only-diff bounded runner (issue #927).Invoke-DocsOnlyBoundedNative.starts the executable in the current location with each argument and redirected streams (issue #927)
FAILED: hook-docs-only-diff bounded runner (issue #927).Invoke-DocsOnlyBoundedNative.emits two LF-terminated lines as output lines (issue #927)
FAILED: hook-docs-only-diff bounded runner (issue #927).Invoke-DocsOnlyBoundedNative.emits CRLF-terminated lines as output lines (issue #927)
FAILED: hook-docs-only-diff bounded runner (issue #927).Invoke-DocsOnlyBoundedNative.emits NUL-terminated diff output as output lines (issue #927)
FAILED: hook-docs-only-diff bounded runner (issue #927).Invoke-DocsOnlyBoundedNative.emits empty output as output lines (issue #927)
FAILED: hook-docs-only-diff bounded runner (issue #927).Invoke-DocsOnlyBoundedNative.reports the non-zero exit code of a process that exits in time (issue #927)
FAILED: hook-docs-only-diff bounded runner (issue #927).Invoke-DocsOnlyBoundedNative.stops the process tree, emits nothing, and reports 124 when the exit wait expires (issue #927)
FAILED: hook-docs-only-diff bounded runner (issue #927).Invoke-DocsOnlyBoundedNative.stops the process tree, emits nothing, and reports 124 when the output wait expires (issue #927)
FAILED: hook-docs-only-diff bounded runner (issue #927).Invoke-DocsOnlyBoundedNative.stops the process tree, emits nothing, and reports 124 when stopping the process throws (issue #927)
FAILED: hook-docs-only-diff bounded runner (issue #927).Invoke-DocsOnlyBoundedNative.returns the seam failure object when the process cannot start (issue #927)
FAILED: hook-docs-only-diff bounded runner (issue #927).Invoke-DocsOnlyBoundedNative.returns exit code 124 through the git seam when the bounded call expires (issue #927)
FAILED: hook-docs-only-diff bounded runner (issue #927).Invoke-DocsOnlyBoundedNative.routes the default git invoker through the bounded runner with a 3000 ms limit (issue #927)
FAILED: hook-docs-only-diff bounded runner (issue #927).Invoke-DocsOnlyBoundedNative.routes the default gh invoker through the bounded runner with a 7000 ms limit (issue #927)
FAILED: Codex hook-docs-only-diff copy (issue #927).runs the bounded runner when the process exits in time (codex copy, issue #927)
FAILED: Codex hook-docs-only-diff copy (issue #927).runs the bounded runner when the exit wait expires (codex copy, issue #927)
FAILED: Codex hook-docs-only-diff copy (issue #927).runs the bounded runner when the output wait expires (codex copy, issue #927)
FAILED: Codex hook-docs-only-diff copy (issue #927).runs the bounded runner when stopping the process throws (codex copy, issue #927)
FAILED: Codex hook-docs-only-diff copy (issue #927).routes the default git invoker through the bounded runner (codex copy, issue #927)
FAILED: Codex hook-docs-only-diff copy (issue #927).routes the default gh invoker through the bounded runner (codex copy, issue #927)
R1_B_FAILED lines of [P0-T7]: none, so none can be missing.

J5 PR_AUTHOR_FAILED: 0
J6 PASSED_DOCSONLY: 35 19 9 (R1_J6_BASE 34 19 9; docs-only + 1)
J10 PASSED_PER_SUITE: 30 43 14 32 9 0 (A base, B base + 7, C base, D base, E base, F 0)
J11 FAILED_PER_SUITE: 0 0 0 6 0 13

J16 (each count 1):
F1 Failed: 1
F2 Failed: 1
F3 Failed: 1
F4 Failed: 1
F5 Failed: 1
F6 Failed: 1
F7 Failed: 1
F8 Failed: 1
F9 Failed: 1
F10 Failed: 1
F11 Failed: 1
F12 Failed: 1
F13 Failed: 1
D1 Failed: 1
D2 Failed: 1
D3 Failed: 1
D4 Failed: 1
D5 Failed: 1
D6 Failed: 1
B1 Passed: 1
B2 Passed: 1
B3 Passed: 1
B4 Passed: 1
B5 Passed: 1
B6 Passed: 1
B7 Passed: 1
X0 Passed: 1
X1 Passed: 1
