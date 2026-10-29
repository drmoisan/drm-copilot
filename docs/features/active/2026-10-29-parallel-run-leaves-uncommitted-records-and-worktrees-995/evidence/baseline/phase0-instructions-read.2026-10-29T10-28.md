# Phase 0 Instructions Read

Timestamp: 2026-10-29T10-28
Task: [P0-T1]
Policy Order: CLAUDE.md -> general-code-change -> general-unit-test -> language rules (PowerShell, Python, Python suppressions) -> domain rules (parallel-orchestration, plan-acceptance-gates) -> execution-environment brief

Files read (in order):

1. `CLAUDE.md`
2. `.claude/rules/general-code-change.md`
3. `.claude/rules/general-unit-test.md`
4. `.claude/rules/powershell.md`
5. `.claude/rules/python.md`
6. `.claude/rules/python-suppressions.md`
7. `.claude/rules/parallel-orchestration.md`
8. `.claude/rules/plan-acceptance-gates.md`
9. `.claude/skills/execution-environment/SKILL.md`

Output Summary: nine policy files read in the stated order. Key constraints noted: 500-line file limit, no temporary files in tests, no mocks of `git` or `gh`, PoshQC MCP results carry no output (counts and coverage read from `artifacts/pester/`), branch-current Pester route via `Invoke-PoshQCTest`, evidence under `FEATURE/evidence/<kind>/`.
