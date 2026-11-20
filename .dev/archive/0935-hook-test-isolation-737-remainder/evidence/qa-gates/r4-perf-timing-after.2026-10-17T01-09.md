# R4 PERF-5 After the Perf Edits (P4-T11, issue #935)

Timestamp: 2026-10-17T01-09
Command:
- `stat -c %y artifacts/pester/pester-junit.xml` (pre and post)
- mcp__drm-copilot__run_poshqc_test (workspace_root = worktree root, scan_folders = ["tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1"])
- D-JUNIT-PERF (1), (2) and (3), as stated verbatim in `r4-perf-timing-before.2026-10-17T00-54.md` and under `Measurement Definitions` of the plan
- D-PERF-TIME, verbatim as in `r4-perf-timing-before.2026-10-17T00-54.md`
EXIT_CODE: 0

Output Summary:
- MCP call disposition: returned (`ok: true`).
- `stat -c %y artifacts/pester/pester-junit.xml` pre: `2026-10-16 21:06:34.390556100 -0400`; post: `2026-10-16 21:09:13.719322200 -0400` (differ).
- D-JUNIT-PERF output (local, MCP runner, coverage enabled; relative figure only):
  - `JUNIT_SUITE_TIME_S=78.931`
  - `JUNIT_SUITE_LINES=1`
  - `JUNIT_TOTAL=371 JUNIT_NAMES=365`
  - hash (first field of `sha256sum`): `e79dd6123d5425e215d74092988bf36bd53b88a84c469b0bf6c420009ae71e14`
- D-PERF-TIME (local, Pester run directly, coverage disabled; not comparable with CI): the command did not run (refused before execution). Authorized skip branch; orchestrator note (7) applies.

PERF-TIMING-REFUSED: This agent is isolated in the worktree <worktree root>, but this command runs pwsh in a plain command; what it reads or is handed as shell text cannot be shown not to run git. Refusing to run it — a worktree-isolated agent's git operations must target its own worktree. Run the plain command from <worktree root>.

Comparison with `r4-perf-timing-before.2026-10-17T00-54.md` (the lexicographically greatest `r4-perf-timing-before.*.md`; before values JUNIT_SUITE_TIME_S=222.758, JUNIT_TOTAL=365, JUNIT_NAMES=365, hash e79dd6123d5425e215d74092988bf36bd53b88a84c469b0bf6c420009ae71e14):

PERF-JUNIT-ROW-SET: UNCHANGED (after JUNIT_TOTAL 371 = before 365 + 6; after JUNIT_NAMES 365 = before 365; hashes equal)
PERF-JUNIT-DELTA: before JUNIT_SUITE_TIME_S=222.758 after JUNIT_SUITE_TIME_S=78.931 (relative; coverage enabled; no target applies)
PERF-COMPARISON-UNAVAILABLE
