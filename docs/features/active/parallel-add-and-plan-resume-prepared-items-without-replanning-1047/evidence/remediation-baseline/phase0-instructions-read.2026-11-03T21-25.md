# Phase 0 Instructions Read (remediation cycle 2)

Timestamp: 2026-11-03T21-25
Task: [P0-T1]
Policy Order: policy-compliance-order (CLAUDE.md, then general code change, then general unit test, then PowerShell-specific), followed by the tier rule, the execution-environment brief, and the cycle inputs.

Files read, in order:

1. `CLAUDE.md`
2. `.github/copilot-instructions.md`
3. `.github/instructions/general-code-change.instructions.md`
4. `.github/instructions/general-unit-test.instructions.md`
5. `.github/instructions/powershell-code-change.instructions.md`
6. `.github/instructions/powershell-unit-test.instructions.md`
7. `.claude/rules/quality-tiers.md`
8. `.claude/skills/execution-environment/SKILL.md`
9. `docs/features/active/parallel-add-and-plan-resume-prepared-items-without-replanning-1047/remediation-inputs.2026-11-03T21-16.md`

Notes: `CLAUDE.md`, `.claude/rules/quality-tiers.md`, and `.claude/skills/execution-environment/SKILL.md` in the item worktree are byte-identical to the `main` checkout (cmp). PowerShell execution follows the brief: `sh` launcher scripts under `SCRATCH` invoke PowerShell 7; counts come from the JUnit file and coverage from the coverage XML, not from MCP PoshQC results.
