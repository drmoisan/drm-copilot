# Targets size and line-length check, remediation cycle 1 (P2-T4)

Timestamp: 2026-10-16T07-06
Command: for each copy: wc -l < <copy>; awk 'length > 120' <copy> | wc -l
EXIT_CODE: 0
Output Summary: Each of the four targets copies has 433 lines (at most 500) and 0 lines over 120 characters.

| Copy | `wc -l` | lines over 120 |
|---|---|---|
| `.claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1` | 433 | 0 |
| `.codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1` | 433 | 0 |
| `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1` | 433 | 0 |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1` | 433 | 0 |

## Acceptance check

- Each line count is 433 (at most 500): met.
- Each long-line count is 0: met.
