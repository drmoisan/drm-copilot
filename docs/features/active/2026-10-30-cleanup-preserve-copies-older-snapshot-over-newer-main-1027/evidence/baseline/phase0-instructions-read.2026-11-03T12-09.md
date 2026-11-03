# Phase 0 Instructions Read

Timestamp: 2026-11-03T12-09
Task: [P0-T1]
Policy Order: CLAUDE.md, then the Copilot tone policy, then the general code-change and unit-test policies (GitHub canonical copies and their `.claude/rules/` mirrors), then the tier, shell, and tone rules, then the execution-environment brief.

Files read, in order:

1. `CLAUDE.md`
2. `.github/copilot-instructions.md`
3. `.github/instructions/general-code-change.instructions.md`
4. `.github/instructions/general-unit-test.instructions.md`
5. `.claude/rules/general-code-change.md`
6. `.claude/rules/general-unit-test.md`
7. `.claude/rules/quality-tiers.md`
8. `.claude/rules/shell.md`
9. `.claude/rules/tonality.md`
10. `.claude/skills/execution-environment/SKILL.md`

Applied constraints: bash only (no new Python or PowerShell); no temporary files in tests; line coverage at least 85% for bash with no branch gate (kcov); file-size tiers 500 guidance, 700 advisory, 801 hard block; shfmt then shellcheck then bats loop with restart on failure or rewrite; evidence under `<FEATURE>/evidence/<kind>/` with scratch locations recorded as the token `SCRATCH`.
