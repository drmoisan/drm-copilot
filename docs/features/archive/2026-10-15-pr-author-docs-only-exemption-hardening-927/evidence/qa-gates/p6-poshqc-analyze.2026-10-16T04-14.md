# P6-T2 PoshQC Analyze (issue #927, final QC step 2, loop pass 1 - FAILED, restarted)

Timestamp: 2026-10-16T04-14
Command: mcp__drm-copilot__run_poshqc_analyze workspace_root=<WORKSPACE_ROOT> scan_folders=[".claude/hooks", ".codex/hooks", "tests/scripts/claude-hooks", "tests/scripts/codex-hooks"]
EXIT_CODE: 1
MCP_CALL: error Command exited with code 1. (stderr excerpt: PSScriptAnalyzer reported 9 issue(s).)
Output Summary: Loop pass 1 failed at this step: the disposition did not match the [P0-T8] baseline (`returned`). Per-folder MCP runs located all 9 findings under tests/scripts/codex-hooks, the folder holding suites D and E added by this item (.claude/hooks, .codex/hooks, and tests/scripts/claude-hooks each returned ok). The MCP result names no rule, so the causes were identified by inspection and confirmed by re-running the MCP analyzer after each test-text fix: (1) eight parameters of `Set-CodexDocsOnlySeam` in suite D were read only inside `Mock -MockWith` closures, which the unused-parameter rule does not traverse; they are now read into local result objects before the closures (finding count 9 -> 1); (2) the fake `Invoke-CodexDocsOnlyFakeDocs` had a plural noun; it is renamed `Invoke-CodexDocsOnlyFakeDocPath` together with its one row reference (finding count 1 -> 0, MCP ok). No hook file changed. The fix is committed per the Phase 6 restart rule and the loop restarts at [P6-T1].

## Narrowing runs (MCP, scan_folders one at a time)

- .claude/hooks -> ok
- .codex/hooks -> ok
- tests/scripts/claude-hooks -> ok
- tests/scripts/codex-hooks -> error, 9 issues
- tests/scripts/codex-hooks after fix (1) -> error, 1 issue
- tests/scripts/codex-hooks after fix (2) -> ok

## Tree observation

- Command: git status --porcelain -- '*.ps1' '*.psm1' '*.psd1' (before the fix)
- Output: (empty)

FIXED_FILE: tests/scripts/codex-hooks/hook-docs-only-diff.Tests.ps1
LOOP_PASS_1_RESULT: restarted at P6-T1 because P6-T2 reported 9 analyzer findings in suite D
