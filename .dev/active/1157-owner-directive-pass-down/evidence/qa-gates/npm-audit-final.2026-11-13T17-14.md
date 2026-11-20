# npm Audit Final Gate - Remediation Cycle 2 (P2-T5)

Timestamp: 2026-11-13T17-13
Command: sh SCRATCH/issue-1157-c2-finalaudit.sh (per manifest: npm --prefix <worktree root>/<manifest> ci, then npm --prefix <worktree root>/<manifest> audit --audit-level=moderate; no other flag)
EXIT_CODE: 0
Output Summary: all six commands exit 0; root 6 low, extension 6 low, MCP server 0 vulnerabilities; zero moderate, high, or critical in every manifest. Mirrors `.github/workflows/_npm-audit-gate.yml` job `npm-audit`.

## Commands

| Manifest | Command | EXIT_CODE |
|---|---|---|
| `.` | `npm --prefix <worktree root>/. ci` | 0 |
| `.` | `npm --prefix <worktree root>/. audit --audit-level=moderate` | 0 |
| `extensions/drm-copilot` | `npm --prefix <worktree root>/extensions/drm-copilot ci` | 0 |
| `extensions/drm-copilot` | `npm --prefix <worktree root>/extensions/drm-copilot audit --audit-level=moderate` | 0 |
| `packages/mcp-server` | `npm --prefix <worktree root>/packages/mcp-server ci` | 0 |
| `packages/mcp-server` | `npm --prefix <worktree root>/packages/mcp-server audit --audit-level=moderate` | 0 |

## Per-severity counts

| Manifest | Critical | High | Moderate | Low | Summary line |
|---|---|---|---|---|---|
| `.` | 0 | 0 | 0 | 6 | `6 low severity vulnerabilities` |
| `extensions/drm-copilot` | 0 | 0 | 0 | 6 | `6 low severity vulnerabilities` |
| `packages/mcp-server` | 0 | 0 | 0 | 0 | `found 0 vulnerabilities` |

Before this cycle (P0-T2): each manifest carried 2 moderate (`hono <=4.13.15`, `@hono/node-server 2.0.0 - 2.1.5`) and the audit exited 1.
