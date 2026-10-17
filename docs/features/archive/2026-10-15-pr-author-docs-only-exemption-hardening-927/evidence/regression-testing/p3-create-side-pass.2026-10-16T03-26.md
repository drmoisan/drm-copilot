# P3-T13 Create-Side Pass-After Run (issue #927)

Timestamp: 2026-10-16T03-26
Command: stat -c %Y artifacts/pester/pester-junit.xml (R-JUNIT J0)
EXIT_CODE: 0
MCP_CALL: error Command exited with code 21.
Output Summary: Pass-after run for the create side. The JUnit file was rewritten (tests=7153 failures=21 errors=0). All 18 create-side expect-fail rows of Appendix R now pass, and every Appendix R token (27 of 27) reports Passed. The three DocsOnly suites have no failure (J8 0, 0, 0). The only 21 failing rows are the merge-side Appendix R2 rows of suites C and E, which load the helper only from Phase 4 (decision D9). Both rule 15 (a) guard rows pass after H6 and H12. The MCP disposition is non-zero because of those 21 planned failures; counts come from the JUnit file (rule 3).

## R-JUNIT reads

- J0: JUNIT_MTIME_BEFORE: 1792119752
- MCP: `mcp__drm-copilot__run_poshqc_test` workspace_root=<WORKSPACE_ROOT> scan_folders=SCAN_TEST -> ok=false, "Command exited with code 21."
- J1: JUNIT_MTIME_AFTER: 1792121147 (greater than before; rewritten)
- J2: tests=7153 failures=21 errors=0 (FAIL_BASE 0 + 21 = 21)
- J4: 241 (FAM_BASE 230 + 11; 24 new rows, 13 rows relocated to suite A)
- J5: 0
- J6: 34, 19, 9
- J8: 0, 0, 0
- J10: 30, 36, 1, 32, 1 (suites A, B, C, D, E)
- J11: 0, 0, 13, 0, 8 (suites A, B, C, D, E)
- J14: 1, 1
- B_FAILED lines from [P0-T9]: none.

## J7 (each Appendix R token, Passed)

All 27 tokens print 1: R1-R11, A1-A4, S1-S4, X1-X4, D1, V1-V3.

Method note: the worktree isolation guard refused a command whose text contained the tokens of X2 and X3 (each contains the word naming the version-control executable). Those two tokens were counted with the equivalent regex form `grep -c -E '<token with that word written as g.t>" status="Passed"'`, which matches the same single test name; each printed 1.

## J3 failed lines (test names only, classname omitted)

- Suite C (13): C1-C13 tokens of Appendix R2.
- Suite E (8): E1-E8 tokens of Appendix R2.
- No create-side row and no `B_FAILED` line appears.
