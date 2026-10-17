# PowerShell Pester Route-Compliance Call via MCP (P8-T12)

Timestamp: 2026-09-30T15-06
Task: [P8-T12]
Location: worktree root

Command: mcp__drm-copilot__run_poshqc_test with `workspace_root` = worktree root and `scan_folders` = ["tests/scripts/claude-lib/orchestrator-state", "tests/scripts/claude-hooks", "tests/scripts/claude-runtime", "tests/scripts/codex-hooks"]
EXIT_CODE: 1
MCP-Status: failure (result field `"ok": false`; summary `Command exited with code 2.`; completed 2026-09-30T15:06:46Z)

## Output Summary

- Counts and coverage for the final gate are taken from P8-T13 (the H1 copies in `evidence/qa-gates/poshqc-local/`), because the MCP result carries none. Per the task text, P8-T13's failed-set equality decides the gate.
- `PS_BASELINE_FAILED` is empty, so the task text expects `EXIT_CODE: 0` / `MCP-Status: success`. The observed result is `failure`. This is recorded as a deviation and not rewritten.
- Diagnostic read of the local tool output `artifacts/pester/pester-junit.xml` (written by this run at 2026-09-30 11:06 local time; root `tests="3964" failures="2" errors="0"`). The child exit code 2 equals the failed-test count (Pester `Run.Exit`). The two failed tests:
  1. `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1`: `enforce-pr-author-skill.ps1.allowed commands.allows gh pr create --body-file artifacts/pr_body_12.md when context exists`. Assertion: expected `allow`, got `deny` (test file line 154).
  2. `tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1`: `Every registered Codex PreToolUse handler accepts every tool name its matcher admits.allows every registered handler for every tool name its own matcher admits`. Assertion message begins `enforce-epic-wave-barrier.ps1 x Bash: ... permissionDecision":"deny" ... EPIC_WAVE_BARRIER_BLOCKED: '509' cannot mutate until every depends_on edge is merged or worktree_removed in the epic checkpoint.` (test file line 165).
- Classification: both failures appear to be environment-conditional, not regressions from this change.
  - Neither test file, and neither hook under test, is changed by this branch: `git diff --stat origin/epic/orchestrator-state-contract-correctness-integration...HEAD -- .claude/hooks .codex/hooks tests/scripts/claude-hooks tests/scripts/codex-hooks` printed nothing (exit 0).
  - Test 1 resolves the checkpoint at the session root (the test's `BeforeEach` mock returns `(Get-Location).Path`), and the worktree holds a gitignored local checkpoint `artifacts/orchestration/orchestrator-state.json` (present, 11263 bytes).
  - Test 2's handler `.codex/hooks/enforce-epic-wave-barrier.ps1` reads `artifacts/orchestration/orchestrator-state.json` (line 259) and `artifacts/orchestration/epic-orchestrator-state.json` under the primary checkout (line 278). Those are gitignored local files. The deny reason names issue `509`, which the hook derives from the local branch and checkpoint context.
  - The H1 Source B CI run on the same HEAD (run 36732800820, headSha ca655902a441e6be0d1749f91440d07c38dbe941), whose checkout has no such files, reports `failures="0"` at the junit root. P8-T13 records the per-file counts for these folders.
- No coverage figure is taken from this MCP run.

Result: route-compliance call made; status `failure` recorded verbatim; gate deferred to P8-T13 per the task text.
