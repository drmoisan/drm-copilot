# QC Pass 1: Changed-Line Coverage ([P10-T7]) - FAILED

Timestamp: 2026-10-08T23-02
Command: sh <SCRATCHPAD>/s-changedcov.sh
EXIT_CODE: 1
Output Summary:
UNCOVERED_CHANGED_TOTAL: 20 (acceptance requires 0). Pass 1 fails at this task; the loop restarts at [P10-T1] as pass 2 after the cause is fixed.

```
CHANGED .claude/hooks/hook-command-scanner.ps1 changed=27 instrumented=10 uncovered=0
CHANGED .claude/hooks/hook-command-heredoc.ps1 changed=119 instrumented=42 uncovered=0
CHANGED .claude/hooks/hook-command-payload.ps1 changed=484 instrumented=186 uncovered=7
UNCOVERED_CHANGED .claude/hooks/hook-command-payload.ps1:201
UNCOVERED_CHANGED .claude/hooks/hook-command-payload.ps1:202
UNCOVERED_CHANGED .claude/hooks/hook-command-payload.ps1:276
UNCOVERED_CHANGED .claude/hooks/hook-command-payload.ps1:280
UNCOVERED_CHANGED .claude/hooks/hook-command-payload.ps1:281
UNCOVERED_CHANGED .claude/hooks/hook-command-payload.ps1:416
UNCOVERED_CHANGED .claude/hooks/hook-command-payload.ps1:417
CHANGED .claude/hooks/hook-command-payload-powershell.ps1 changed=201 instrumented=71 uncovered=0
CHANGED .claude/hooks/hook-command-invocation.ps1 changed=254 instrumented=117 uncovered=0
CHANGED .claude/hooks/hook-command-invocation-operands.ps1 changed=198 instrumented=40 uncovered=0
CHANGED .claude/hooks/enforce-promotion-mcp-only.ps1 changed=5 instrumented=1 uncovered=0
CHANGED .claude/hooks/enforce-epic-worktree-removal-gate.ps1 changed=41 instrumented=13 uncovered=1
UNCOVERED_CHANGED .claude/hooks/enforce-epic-worktree-removal-gate.ps1:323
CHANGED .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 changed=41 instrumented=13 uncovered=1
UNCOVERED_CHANGED .claude/hooks/enforce-parallel-worktree-removal-gate.ps1:324
CHANGED .claude/hooks/enforce-pr-author-skill-helpers.ps1 changed=74 instrumented=23 uncovered=2
UNCOVERED_CHANGED .claude/hooks/enforce-pr-author-skill-helpers.ps1:166
UNCOVERED_CHANGED .claude/hooks/enforce-pr-author-skill-helpers.ps1:364
CHANGED .claude/hooks/enforce-pr-author-command-allowlist.ps1 changed=279 instrumented=75 uncovered=1
UNCOVERED_CHANGED .claude/hooks/enforce-pr-author-command-allowlist.ps1:65
CHANGED .codex/hooks/hook-command-scanner.ps1 changed=27 instrumented=10 uncovered=0
CHANGED .codex/hooks/hook-command-heredoc.ps1 changed=119 instrumented=42 uncovered=0
CHANGED .codex/hooks/hook-command-payload.ps1 changed=484 instrumented=186 uncovered=7
UNCOVERED_CHANGED .codex/hooks/hook-command-payload.ps1:201
UNCOVERED_CHANGED .codex/hooks/hook-command-payload.ps1:202
UNCOVERED_CHANGED .codex/hooks/hook-command-payload.ps1:276
UNCOVERED_CHANGED .codex/hooks/hook-command-payload.ps1:280
UNCOVERED_CHANGED .codex/hooks/hook-command-payload.ps1:281
UNCOVERED_CHANGED .codex/hooks/hook-command-payload.ps1:416
UNCOVERED_CHANGED .codex/hooks/hook-command-payload.ps1:417
CHANGED .codex/hooks/hook-command-payload-powershell.ps1 changed=201 instrumented=71 uncovered=0
CHANGED .codex/hooks/hook-command-invocation.ps1 changed=254 instrumented=117 uncovered=0
CHANGED .codex/hooks/hook-command-invocation-operands.ps1 changed=198 instrumented=40 uncovered=0
CHANGED .codex/hooks/enforce-promotion-mcp-only.ps1 changed=5 instrumented=1 uncovered=0
CHANGED .codex/hooks/enforce-epic-worktree-removal-gate.ps1 changed=46 instrumented=15 uncovered=1
UNCOVERED_CHANGED .codex/hooks/enforce-epic-worktree-removal-gate.ps1:100
UNCOVERED_CHANGED_TOTAL: 20
```
