# Helpers Surface-Parity Suite Result (issue #671)

Timestamp: 2026-09-17T08-15
Task: [P4-T3]
Command: mcp__drm-copilot__run_poshqc_test (workspace_root = worktree root, scan_folders = ["tests/scripts/claude-hooks"]) as the route-compliance step; then `artifacts/pester/pester-junit.xml` (LastWriteTime 2026-09-17T08:15:38) read by a scratchpad parser under pwsh 7.6.6, and `@(Get-Content -LiteralPath <path>).Count` for each helpers copy
EXIT_CODE: 4
ExpectedExitCode: 4

Output Summary:
- MCP call disposition: non-zero (`ok: false`, "Command exited with code 4."). The four failing nodes in the run are the three new L3a/L3b/L8 rows in the Claude command-exemption suite and the baseline `enforce-pr-author-skill` failure. None is in the parity suite.
- The runner collected the new suite: `testsuite` for `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.Parity.Tests.ps1` matches=1, with tests=2, failures=0, errors=0, skipped=0, disabled=0.
- Both asserted nodes: match count 1, status `Passed`.
- Post-change line counts: 433 on each of the four helpers copies (each at most 500).

| It label | Matches | classname | status |
| --- | --- | --- | --- |
| `keeps all four surface copies of the helpers module byte-identical by SHA256 hash` | 1 | `.../tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.Parity.Tests.ps1` | Passed |
| `keeps every surface copy of the helpers module under the 500-line cap` | 1 | same | Passed |

| Helpers copy | Lines |
| --- | --- |
| `.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` | 433 |
| `.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` | 433 |
| `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` | 433 |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` | 433 |

(`...` = `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a6dbf51ad3a3ac686`)
