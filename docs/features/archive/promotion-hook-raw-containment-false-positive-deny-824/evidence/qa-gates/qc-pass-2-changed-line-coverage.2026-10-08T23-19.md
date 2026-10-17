# QC Pass 2: Changed-Line Coverage ([P10-T7])

Timestamp: 2026-10-08T23-19
Command: sh <SCRATCHPAD>/s-changedcov.sh
EXIT_CODE: 0
Output Summary:
UNCOVERED_CHANGED_TOTAL: 0

```
CHANGED .claude/hooks/hook-command-scanner.ps1 changed=27 instrumented=10 uncovered=0
CHANGED .claude/hooks/hook-command-heredoc.ps1 changed=119 instrumented=42 uncovered=0
CHANGED .claude/hooks/hook-command-payload.ps1 changed=484 instrumented=186 uncovered=0
CHANGED .claude/hooks/hook-command-payload-powershell.ps1 changed=201 instrumented=71 uncovered=0
CHANGED .claude/hooks/hook-command-invocation.ps1 changed=254 instrumented=117 uncovered=0
CHANGED .claude/hooks/hook-command-invocation-operands.ps1 changed=198 instrumented=40 uncovered=0
CHANGED .claude/hooks/enforce-promotion-mcp-only.ps1 changed=5 instrumented=1 uncovered=0
CHANGED .claude/hooks/enforce-epic-worktree-removal-gate.ps1 changed=41 instrumented=13 uncovered=0
CHANGED .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 changed=41 instrumented=13 uncovered=0
CHANGED .claude/hooks/enforce-pr-author-skill-helpers.ps1 changed=74 instrumented=23 uncovered=0
CHANGED .claude/hooks/enforce-pr-author-command-allowlist.ps1 changed=279 instrumented=75 uncovered=0
CHANGED .codex/hooks/hook-command-scanner.ps1 changed=27 instrumented=10 uncovered=0
CHANGED .codex/hooks/hook-command-heredoc.ps1 changed=119 instrumented=42 uncovered=0
CHANGED .codex/hooks/hook-command-payload.ps1 changed=484 instrumented=186 uncovered=0
CHANGED .codex/hooks/hook-command-payload-powershell.ps1 changed=201 instrumented=71 uncovered=0
CHANGED .codex/hooks/hook-command-invocation.ps1 changed=254 instrumented=117 uncovered=0
CHANGED .codex/hooks/hook-command-invocation-operands.ps1 changed=198 instrumented=40 uncovered=0
CHANGED .codex/hooks/enforce-promotion-mcp-only.ps1 changed=5 instrumented=1 uncovered=0
CHANGED .codex/hooks/enforce-epic-worktree-removal-gate.ps1 changed=46 instrumented=15 uncovered=0
UNCOVERED_CHANGED_TOTAL: 0
```

The 20 lines reported uncovered in pass 1 are now covered by rows PY-25..PY-27 (payload lines 201, 202, 276, 280, 281, 416, 417 on both surfaces), EW-40 (Claude epic gate line 323), PW-40 (Claude parallel gate line 324), CW-40 (Codex epic gate line 100), PA-24 (helpers line 166), PA-23 (helpers line 364), and AL-38 (allowlist line 65).
