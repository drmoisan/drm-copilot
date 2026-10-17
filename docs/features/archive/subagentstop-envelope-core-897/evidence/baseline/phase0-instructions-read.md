# Phase 0 Policy Reads (issue #897, epic child E1)

Timestamp: 2026-10-11T12-30
Task: [P0-T1]
Policy Order: CLAUDE.md -> .github/copilot-instructions.md -> .github/instructions/general-code-change.instructions.md -> .github/instructions/general-unit-test.instructions.md -> .github/instructions/powershell-code-change.instructions.md -> .github/instructions/powershell-unit-test.instructions.md -> .claude/rules/general-code-change.md -> .claude/rules/general-unit-test.md -> .claude/rules/quality-tiers.md -> .claude/rules/powershell.md -> .claude/rules/tonality.md -> .claude/skills/evidence-and-timestamp-conventions/SKILL.md -> .claude/skills/acceptance-criteria-tracking/SKILL.md

## Files read (in order)

1. `CLAUDE.md`
2. `.github/copilot-instructions.md`
3. `.github/instructions/general-code-change.instructions.md`
4. `.github/instructions/general-unit-test.instructions.md`
5. `.github/instructions/powershell-code-change.instructions.md`
6. `.github/instructions/powershell-unit-test.instructions.md`
7. `.claude/rules/general-code-change.md`
8. `.claude/rules/general-unit-test.md`
9. `.claude/rules/quality-tiers.md`
10. `.claude/rules/powershell.md`
11. `.claude/rules/tonality.md`
12. `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`
13. `.claude/skills/acceptance-criteria-tracking/SKILL.md`

## Constraints carried into execution

- PowerShell toolchain order: format -> analyze -> test (no type check). Restart from format on any failure or rewrite.
- 500-line cap on every production and test `.ps1`; line coverage >= 85% for the new helper; no branch gate for PowerShell.
- No temporary files and no child processes in unit tests; Pester 5.x; test files under `tests/` mirroring the source tree.
- Evidence under `docs/features/active/subagentstop-envelope-core-897/evidence/<kind>/` only; every command artifact carries `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`.
- AC check-off in `spec.md` only (work mode `full-bug`), one AC at a time after its named verification passed.
- Tone: professional, factual, no hyperbole.
