# Contract Documents Section Order (P6-T26)

Timestamp: 2026-10-01T23-10
Task: P6-T26
Command: git grep -n -E "^## (Invariants \(per remediation cycle\)|Invariants \(remediation_loop\.review_outcomes\)|Human-Interaction Scope and Backward Compatibility)" -- .claude/rules/orchestrator-state.md .agents/skills/orchestrator-state/SKILL.md
EXIT_CODE: 0

Output:

```
.agents/skills/orchestrator-state/SKILL.md:65:## Invariants (per remediation cycle)
.agents/skills/orchestrator-state/SKILL.md:81:## Invariants (remediation_loop.review_outcomes)
.agents/skills/orchestrator-state/SKILL.md:112:## Human-Interaction Scope and Backward Compatibility
.claude/rules/orchestrator-state.md:39:## Invariants (per remediation cycle)
.claude/rules/orchestrator-state.md:55:## Invariants (remediation_loop.review_outcomes)
.claude/rules/orchestrator-state.md:86:## Human-Interaction Scope and Backward Compatibility
```

Output Summary: three match lines per file with strictly increasing line numbers in the required order (per-cycle invariants, review-outcome invariants, human-interaction scope): 65 < 81 < 112 in the `.agents` skill and 39 < 55 < 86 in the rules document. Result: PASS.
