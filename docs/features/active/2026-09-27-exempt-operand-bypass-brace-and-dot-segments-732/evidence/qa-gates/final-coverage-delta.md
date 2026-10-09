# Final coverage delta (issue #732)

Timestamp: 2026-10-09T04-36
Task: [P7-T6]
ROUTE: sh-launcher
Command: sh <SCRATCHPAD>/c1b732/p7-t6.sh (reads evidence/baseline/p0-coverage.md and evidence/qa-gates/final-coverage.md)
EXIT_CODE: 0

## Output

```text
PASS: 3
FILE: .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1
BASELINE: 98.26
POST: 98.11
CHANGED_EXECUTED: 5
CHANGED_MISSED: 0
VERDICT: PASS
FILE: .codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1
BASELINE: 98.26
POST: 98.11
CHANGED_EXECUTED: 5
CHANGED_MISSED: 0
VERDICT: PASS
FILE: .claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1
BASELINE: NEW_FILE
POST: 100.00
CHANGED_EXECUTED: 123
CHANGED_MISSED: 0
VERDICT: PASS
FILE: .codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1
BASELINE: NEW_FILE
POST: 100.00
CHANGED_EXECUTED: 123
CHANGED_MISSED: 0
VERDICT: PASS
FILE: .claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1
BASELINE: 100.00
POST: 98.72
CHANGED_EXECUTED: 18
CHANGED_MISSED: 0
VERDICT: PASS
FILE: .codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1
BASELINE: 100.00
POST: 100.00
CHANGED_EXECUTED: 23
CHANGED_MISSED: 0
VERDICT: PASS
FILE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1
BASELINE: 100.00
POST: 100.00
CHANGED_EXECUTED: 0
CHANGED_MISSED: 0
VERDICT: PASS
FAIL_ROWS: 0
```

Output Summary: pass 3; FAIL rows 0. .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 98.26->98.11 changed-missed 0 PASS; .codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 98.26->98.11 changed-missed 0 PASS; .claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1 NEW_FILE->100.00 changed-missed 0 PASS; .codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1 NEW_FILE->100.00 changed-missed 0 PASS; .claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1 100.00->98.72 changed-missed 0 PASS; .codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1 100.00->100.00 changed-missed 0 PASS; .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 100.00->100.00 changed-missed 0 PASS

