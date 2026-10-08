# Coverage Delta: Baseline vs Post-Change vs Changed Lines ([P10-T8])

Timestamp: 2026-10-08T23-20

Sources:
- Baseline: `evidence/baseline/pester-full-coverage.2026-10-08T17-32.md` ([P0-T18]).
- Post-change: `evidence/qa-gates/qc-pass-2-pester-full-coverage.2026-10-08T23-19.md` ([P10-T6], pass 2).
- Changed-line: `evidence/qa-gates/qc-pass-2-changed-line-coverage.2026-10-08T23-19.md` ([P10-T7], pass 2).

Coverage values are PowerShell line coverage (Pester JaCoCo `LINE` counter). Pester does not measure branch coverage, so no branch value is reported (`.claude/rules/general-unit-test.md` exemption).

| Production file | Baseline pct | Post-change pct (covered/missed) | Changed lines | Instrumented changed | Uncovered changed | Delta note |
|---|---|---|---|---|---|---|
| .claude/hooks/hook-command-scanner.ps1 | 100.00 | 100.00 (149/0) | 27 | 10 | 0 | unchanged pct; heredoc functions moved out |
| .claude/hooks/hook-command-heredoc.ps1 | NEW_FILE | 100.00 (42/0) | 119 | 42 | 0 | new |
| .claude/hooks/hook-command-payload.ps1 | NEW_FILE | 100.00 (186/0) | 484 | 186 | 0 | new |
| .claude/hooks/hook-command-payload-powershell.ps1 | NEW_FILE | 100.00 (71/0) | 201 | 71 | 0 | new |
| .claude/hooks/hook-command-invocation.ps1 | 99.19 | 100.00 (147/0) | 254 | 117 | 0 | increase |
| .claude/hooks/hook-command-invocation-operands.ps1 | NEW_FILE | 100.00 (40/0) | 198 | 40 | 0 | new |
| .claude/hooks/enforce-promotion-mcp-only.ps1 | 93.33 | 93.33 (56/4) | 5 | 1 | 0 | unchanged |
| .claude/hooks/enforce-epic-worktree-removal-gate.ps1 | 95.41 | 96.40 (107/4) | 41 | 13 | 0 | increase |
| .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 | 93.46 | 94.50 (103/6) | 41 | 13 | 0 | increase |
| .claude/hooks/enforce-pr-author-skill-helpers.ps1 | 97.00 | 97.39 (112/3) | 74 | 23 | 0 | increase |
| .claude/hooks/enforce-pr-author-command-allowlist.ps1 | NEW_FILE | 100.00 (75/0) | 279 | 75 | 0 | new |
| .codex/hooks/hook-command-scanner.ps1 | 100.00 | 100.00 (149/0) | 27 | 10 | 0 | unchanged pct |
| .codex/hooks/hook-command-heredoc.ps1 | NEW_FILE | 100.00 (42/0) | 119 | 42 | 0 | new |
| .codex/hooks/hook-command-payload.ps1 | NEW_FILE | 100.00 (186/0) | 484 | 186 | 0 | new |
| .codex/hooks/hook-command-payload-powershell.ps1 | NEW_FILE | 100.00 (71/0) | 201 | 71 | 0 | new |
| .codex/hooks/hook-command-invocation.ps1 | 97.58 | 100.00 (147/0) | 254 | 117 | 0 | increase |
| .codex/hooks/hook-command-invocation-operands.ps1 | NEW_FILE | 100.00 (40/0) | 198 | 40 | 0 | new |
| .codex/hooks/enforce-promotion-mcp-only.ps1 | 100.00 | 100.00 (65/0) | 5 | 1 | 0 | unchanged |
| .codex/hooks/enforce-epic-worktree-removal-gate.ps1 | 98.53 | 98.61 (71/1) | 46 | 15 | 0 | increase |

Rows: 19. Every post-change value is numeric and at or above 85.00 (minimum 93.33). No modified file's post-change value is below its baseline value. Changed-line uncovered total: 0.

Result: PASS.
