# Phase 6 — packages/mcp-server Mirror Parity (manual)

- Timestamp: 2026-06-16T11-00
- Issue: #187
- Task: [P6-T2]

## Command

```
cmp -s .claude/<file> packages/mcp-server/resources/claude-customizations/.claude/<file>
```

The `packages/mcp-server` mirror has no automated contract test (research
Section 2), so parity is confirmed manually per file.

## Output Summary (per file, EXIT_CODE 0 = byte-identical)

- EXIT_CODE: 0  hooks/validate-orchestrator-output.ps1
- EXIT_CODE: 0  hooks/validate-task-researcher-output.ps1
- EXIT_CODE: 0  skills/orchestrate/SKILL.md
- EXIT_CODE: 0  skills/human-exception-runbook/SKILL.md
- EXIT_CODE: 0  skills/human-exception-runbook/example.runbook.md
- EXIT_CODE: 0  rules/orchestrator-state.md
- EXIT_CODE: 0  rules/general-unit-test.md
- EXIT_CODE: 0  skills/remediation-handoff-atomic-planner/SKILL.md

All eight changed/created canonical `.claude/` files are byte-identical to their
`packages/mcp-server/resources/claude-customizations/.claude/...` counterparts.
