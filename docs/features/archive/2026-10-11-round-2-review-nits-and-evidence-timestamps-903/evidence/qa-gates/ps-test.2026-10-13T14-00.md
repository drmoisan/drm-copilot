# PowerShell Test (P12-T14)

Timestamp: 2026-10-13T14-00
Command: mcp__drm-copilot__run_poshqc_test workspace_root=<worktree> scan_folders=["tests/scripts/claude-hooks", "tests/scripts/codex-hooks", "tests/scripts/claude-lib", "tests/scripts/claude-runtime", "tests/scripts/workflows"]
EXIT_CODE: 0
HEAD: 4e8d9f92d63c686f64f9f97e975448dc126c92f1
Loop-Iteration: 2

EXIT_CODE is the MCP call disposition only. CI (P12-T22 and P12-T23) governs test results.

## MCP result (verbatim, worktree path redacted)

```
{"ok":true,"tool":"run_poshqc_test","workspace_root":"<worktree>","summary":"Ran bundled PoshQC test against '<worktree>' with 5 selected scan folder(s)."}
```

## Supplementary local observation (not an acceptance input)

- Local JUnit (`artifacts/pester/pester-junit.xml`, git-ignored, rewritten by this call at 2026-10-13T14:00 UTC) summary: `tests="9415" failures="0" errors="0" disabled="1"`.
- 0 failing testcases. The `enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1` suite contributed 332 `discovery guard` testcases, none failing. The seven F-2 findings recorded in iteration 1 (`evidence/qa-gates/ps-test.2026-10-13T13-18.md`) are absent after the P12-T27 withhold (commit 4e8d9f92d).
- `git status --porcelain` after the call lists no path outside `<FEATURE>`.

Output Summary: PASS. Call disposition `"ok":true`, matching the P0-T29 disposition. Local JUnit: 9415 tests, 0 failures.
