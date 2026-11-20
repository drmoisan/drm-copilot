# Phase 0 Instructions Read

Timestamp: 2026-11-03T12-51
Task: [P0-T1]
Issue: #1047

Policy Order: policy-compliance-order (CLAUDE.md, general code change, general unit test, language-specific, then domain rules and the execution-environment brief)

Files read, in order:

1. `CLAUDE.md`
2. `.github/copilot-instructions.md`
3. `.github/instructions/general-code-change.instructions.md`
4. `.github/instructions/general-unit-test.instructions.md`
5. `.github/instructions/powershell-code-change.instructions.md`
6. `.github/instructions/powershell-unit-test.instructions.md`
7. `.github/instructions/python-code-change.instructions.md`
8. `.github/instructions/python-unit-test.instructions.md`
9. `.claude/rules/quality-tiers.md`
10. `.claude/rules/parallel-orchestration.md`
11. `.claude/skills/execution-environment/SKILL.md`

Notes:

- `quality-tiers.yml` exists at the repository root, so module rigor tiers apply; the new library is classified T3 by the plan.
- Coverage thresholds: line 85% for PowerShell (no branch gate for Pester); no production Python changes in scope.
- Tests create no temporary files; file and git reads go through injected seams.
