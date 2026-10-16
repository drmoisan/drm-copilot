# P2-T16 Shared Helper Pass (issue #927, after the revision 2.1 scriptblock-invoker rework)

Timestamp: 2026-10-16T03-03
Command: stat -c %Y artifacts/pester/pester-junit.xml (R-JUNIT J0)
EXIT_CODE: 0
MCP_CALL: error Command exited with code 39.
Output Summary: The helper suites pass after the rework: suite A 30/30, suite B 36/36, suite D 32/32 passed with no failure. The JUnit file was rewritten (tests=7166 failures=39 errors=0). The 39 failing rows are exactly the 18 create-side expect-fail rows of Appendix R and the 21 merge-side rows of Appendix R2, as decisions D5 and D9 predict for this phase (create-side hook and merge gates are unchanged until Phases 3 and 4). Both rule 15 (a) guard rows pass (J14 = 1, 1), so the [scriptblock] invoker seams satisfy the no-python-invocation guard that blocked the version 2.0 form. The MCP call returned a non-zero disposition because the 39 expected rows fail; the task acceptance reads counts from the JUnit file only (rule 3).

## R-JUNIT reads

- J0: JUNIT_MTIME_BEFORE: 1792115551
- MCP: `mcp__drm-copilot__run_poshqc_test` workspace_root=<WORKSPACE_ROOT> scan_folders=SCAN_TEST -> ok=false, "Command exited with code 39."
- J1: JUNIT_MTIME_AFTER: 1792119752 (greater than before; rewritten)
- J2: tests=7166 failures=39 errors=0 (FAIL_BASE 0 + 39 = 39)
- J4: 236
- J5: 18
- J6: 34, 15, 8
- J8: 13, 4, 1
- J10: 30, 36, 1, 32, 1 (suites A, B, C, D, E)
- J11: 0, 0, 13, 0, 8 (suites A, B, C, D, E)
- J14: 1, 1 (`reports no Python invocation beyond the allowlist across the guarded tree`, `ships an empty allowlist`)
- B_FAILED lines from [P0-T9]: none.

## J7 and J9

- J9: J3 lists 39 failed rows; each of the 18 Appendix R expect-fail tokens (R1, R4-R11, S1-S4, X1-X4, D1) and each of the 21 Appendix R2 tokens (C1-C13, E1-E8) ends exactly one J3 line, so each J9 count is 1.
- J7: the non-expect-fail Appendix R rows (R2, R3, A1-A4, V1-V3) are not in J3; the expect-fail rows still fail at this phase as planned.
- Every J3 line is an Appendix R or R2 token; no `B_FAILED` line exists, and no other row fails.

## J3 failed lines (test names only, classname omitted)

- Suite C (13): C1-C13 tokens of Appendix R2.
- Suite E (8): E1-E8 tokens of Appendix R2.
- Decision suite (1): `denies a --repo override before the diff (issue #927)`.
- Exemption suite (4): X1-X4 tokens.
- DocsOnly suite (13): R1, R4-R11 (`denies the base or repository override <token>`) and S1-S4 (`Invoke-PrAuthorDocsOnlyGitExe command injection (issue #927)` context; S1-S4 fail on binding `-GitInvoker`, which `Invoke-PrAuthorDocsOnlyGitExe` gains at [P3-T2]).

## Supersedes

This artifact replaces the BLOCKED record `p2-helper-pass.2026-10-16T01-53.md` as the lexicographically greatest `p2-helper-pass.*.md`.
