# Parser After (P4-T7)

Timestamp: 2026-10-16T11-19
Command: mcp__drm-copilot__run_poshqc_test workspace_root=WORKTREE_ROOT scan_folders=[tests/scripts/claude-lib/ci-gate]
EXIT_CODE: 0
Disposition: RETURNED
Baseline (P0-T10 t-ci-gate): GREEN
Output Summary: the second call returned after a fix to one test assertion; the first call raised. Per-row results for AC-12 and AC-13 come from ORCH-4 (job poshqc / PowerShell QC).

MCP summary string of the returned call (verbatim): Ran bundled PoshQC test against 'WORKTREE_ROOT' with 1 selected scan folder(s).

Fix-and-repeat history (P4-T7 "a raised call fails the task; fix ... and repeat"):
1. First call: RAISED, `Command exited with code 1.` The local PoshQC JUnit output (`artifacts/pester/pester-junit.xml`, gitignored, written by the same run) named one failing testcase: `emits compressed JSON with Status, MergeCommitSha, and MergedAt when -AsJson is set`, message `Expected exactly '2026-10-16T12:34:56Z', but got 2026-10-16T12:34:56.0000000Z.` at test line 112.
2. Cause: the test assertion, not the parser. The parser emitted `"MergedAt":"2026-10-16T12:34:56Z"`, but the test parsed the emitted JSON back with `ConvertFrom-Json`, which converts an ISO-8601 string to `[datetime]`. The assertion then compared the stringified `[datetime]`. The Appendix G.2 expectation for case 12 (compressed JSON carrying Status, MergeCommitSha and MergedAt) is unchanged. Only the assertion mechanism changed: it now compares the emitted text exactly with `{"Status":"merged","MergeCommitSha":"abc123","MergedAt":"2026-10-16T12:34:56Z"}`.
3. Second call: RETURNED. The local JUnit file from that run lists 52 testcases with 0 `status="Failed"` entries (informational, not an acceptance input).

The P4-T1 acceptance was re-checked after the edit: line 1 is `Set-StrictMode -Version Latest`, the file has 121 lines, and the forbidden-token search exits 1.
