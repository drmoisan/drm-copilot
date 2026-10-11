# QC Pass 1: MCP Test Call ([P10-T4])

Timestamp: 2026-10-08T22-52
Command: mcp__drm-copilot__run_poshqc_test (workspace_root = <WORKSPACE_ROOT>; scan_folders = .claude/hooks, .codex/hooks, tests/scripts/claude-hooks, tests/scripts/codex-hooks)
MCP_CALL: error Command exited with code 2.
EXIT_CODE: 2
Output Summary:
The MCP result was `ok: false` with summary `Command exited with code 2.` The result carries no command output, so no count, failing test, or coverage value is read from it (plan rule 4). The cause of the non-zero exit is not observable from this result. Test pass/fail and coverage for this pass are read from the observation-script runs [P10-T5] (full run, `FULL_RUN_EXIT_CODE`), [P10-T6] (failing-test set against `B_FULL` and per-file coverage), and [P10-T9] (Issue824-tagged rows).

The task acceptance (disposition recorded; no count read) is met.
