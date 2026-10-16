# R2 Expect-Fail Run (Issue #927, CR-R1)

Timestamp: 2026-10-16T10-18
Command: stat -c %Y artifacts/pester/pester-junit.xml
EXIT_CODE: 0
Output Summary: Expect-fail confirmed before the helper edit. The PoshQC MCP test over SCAN_FAIL rewrote the JUnit file (mtime 1792140254 to 1792145895). JUnit root: tests=6473 failures=14 errors=0. All 14 Appendix R rows expected to fail (F1-F9, F11, D1-D4) report status="Failed" exactly once, and all 5 rows expected to pass (F10, F12, F13, D5, D6) report status="Passed" exactly once. The MCP call surfaced the Pester exit code 14 (the failed-test count) as a non-ok result; see the disposition note.

## Commands

- Command 1 (before): `stat -c %Y artifacts/pester/pester-junit.xml`
  - EXIT_CODE_1: 0
  - Output: `1792140254`
- Command 2: `mcp__drm-copilot__run_poshqc_test` with `workspace_root` = `<WORKSPACE_ROOT>` and `scan_folders` = `["tests/scripts/claude-hooks", "tests/scripts/codex-hooks"]` (SCAN_FAIL)
  - MCP_CALL: error Command exited with code 14.
  - Disposition note: the call ran to completion and returned the Pester process exit code. Pester sets its exit code to the failed-test count, and 14 equals the expected failure count of this expect-fail task. The non-ok MCP result is therefore the expected red state, not a failure to execute. The plan text requires `MCP_CALL: returned`; it assumed the MCP reports ok when tests fail, but it reports the failing exit. This interpretation is reported to the caller.
- Command 3 (after): `stat -c %Y artifacts/pester/pester-junit.xml`
  - EXIT_CODE_3: 0
  - Output: `1792145895` (greater than the before value)
- Command 4: `grep -m 1 -o -E '<testsuites [^>]*>' artifacts/pester/pester-junit.xml`
  - EXIT_CODE_4: 0
  - Recorded attributes: `tests="6473"`, `failures="14"`, `errors="0"`

## Appendix R token counts (Commands 5-23)

Each command is `grep -c -F -e '<token>" status="<status>"' artifacts/pester/pester-junit.xml`.

| Row | Expected status | Count |
|---|---|---|
| F1 | Failed | 1 |
| F2 | Failed | 1 |
| F3 | Failed | 1 |
| F4 | Failed | 1 |
| F5 | Failed | 1 |
| F6 | Failed | 1 |
| F7 | Failed | 1 |
| F8 | Failed | 1 |
| F9 | Failed | 1 |
| F10 | Passed | 1 |
| F11 | Failed | 1 |
| F12 | Passed | 1 |
| F13 | Passed | 1 |
| D1 | Failed | 1 |
| D2 | Failed | 1 |
| D3 | Failed | 1 |
| D4 | Failed | 1 |
| D5 | Passed | 1 |
| D6 | Passed | 1 |

EXPECT_FAIL_RESULT: 14 Disposed assertions fail before the helper edit; failures=14 errors=0.
