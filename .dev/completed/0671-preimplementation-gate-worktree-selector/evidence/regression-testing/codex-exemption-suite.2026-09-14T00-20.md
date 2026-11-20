# Codex Command-Exemption Suite Result (issue #671)

Timestamp: 2026-09-17T08-10
Task: [P3-T5]
Command: mcp__drm-copilot__run_poshqc_test (workspace_root = worktree root, scan_folders = ["tests/scripts/codex-hooks"]) as the route-compliance step; then `artifacts/pester/pester-junit.xml` (LastWriteTime 2026-09-17T08:10:03) read by a scratchpad parser under pwsh 7.6.6, per governing paragraph 2
EXIT_CODE: 4
Status: INCOMPLETE — all seven asserted nodes passed, but the suite's `testsuite` element carries `failures="3"`.

Output Summary:
- MCP call disposition: non-zero (`ok: false`, "Command exited with code 4.").
- Run totals (scoped run): tests=897, failures=4, errors=0, disabled=0.
- Asserted suite `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1`: `testsuite` matches=1; tests=83, failures=3, errors=0, skipped=0, disabled=0.
- All seven asserted nodes: match count 1 each, status `Passed`. The classname scoping selected exactly one node per label.
- New Context census: allow cases 7 of 7 Passed; deny cases 14 of 17 Passed.
- Failing nodes in this suite: the same three rows as the Claude suite (L3a, L3b, L8), with the same causes (see `claude-exemption-suite.2026-09-14T00-20.md`).
- The fourth failing node in the run, `Every registered Codex PreToolUse handler accepts every tool name its matcher admits.allows every registered handler for every tool name its own matcher admits` (`codex-pretooluse-integration.Tests.ps1`), is one of the two baseline failures recorded in [P0-T8] and is unrelated.

## Asserted nodes (classname scoped to the suite path)

| It label | Matches | classname | status |
| --- | --- | --- | --- |
| `allows issue #671 LACS allow 1 - drive-letter absolute selector on the add subcommand` | 1 | `.../tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1` | Passed |
| `allows issue #671 LACS allow 5 - chained add and commit segments each carrying the same absolute selector` | 1 | same | Passed |
| `denies issue #671 cd chain into the target worktree` | 1 | same | Passed |
| `denies issue #671 selector with a non-exempt pathspec operand` | 1 | same | Passed |
| `denies issue #671 selector with the tree-wide all flag` | 1 | same | Passed |
| `denies issue #671 selector with an absolute pathspec operand` | 1 | same | Passed |
| `denies issue #671 selector with an output redirection` | 1 | same | Passed |

(`...` = `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a6dbf51ad3a3ac686`)
