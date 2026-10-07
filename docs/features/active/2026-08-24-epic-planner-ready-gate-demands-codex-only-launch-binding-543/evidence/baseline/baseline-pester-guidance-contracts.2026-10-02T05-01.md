# Baseline Pester guidance contracts (issue #543)

Timestamp: 2026-10-02T05-01
Task: P0-T17
Command: `mcp__drm-copilot__run_poshqc_test` with `workspace_root` = this worktree and `scan_folders: ["tests/scripts/codex-hooks"]`; then `poetry run python <scratchpad>/read_pester_junit.py`, which reads `artifacts/pester/pester-junit.xml` and selects the `testsuite` element whose name ends in `codex-epic-runtime-contracts.Tests.ps1`
Route: poshqc-mcp (D3)
EXIT_CODE: 0

Output Summary:
- JUnit file freshly written by this run (mtime 6 s before the read); root `testsuites`: `tests="1231" errors="0" failures="0"`.
- Matching `testsuite` elements: 1 (`tests\scripts\codex-hooks\codex-epic-runtime-contracts.Tests.ps1`): `tests="10" failures="0" errors="0" skipped="0"`.
- PassedCount = 10 - 0 - 0 - 0 = 10.
- FailedCount = 0 + 0 = 0 (recorded as `EXIT_CODE:` per the plan's Pester rule).
- Testcase `Codex epic runtime configuration and distribution contracts.keeps root and tracked bundle runtime copies byte-identical`: `status="Passed"` (the D3 equivalent of the `[+]` line).
- The MCP summary string was not used as a count.
