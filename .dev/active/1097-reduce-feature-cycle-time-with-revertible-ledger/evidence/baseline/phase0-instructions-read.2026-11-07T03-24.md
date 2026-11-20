# Phase 0 Instructions Read

Timestamp: 2026-11-07T03-24
Policy Order: CLAUDE.md; .claude/rules/general-code-change.md; .claude/rules/general-unit-test.md; language rules for the files in scope (PowerShell, then Python test scope), per .claude/skills/policy-compliance-order/SKILL.md

Files read, in order:

1. `CLAUDE.md`
2. `.claude/rules/general-code-change.md`
3. `.claude/rules/general-unit-test.md`
4. `.claude/rules/quality-tiers.md`
5. `.claude/rules/tonality.md`
6. `.claude/rules/powershell.md`
7. `.github/instructions/powershell-code-change.instructions.md`
8. `.github/instructions/powershell-unit-test.instructions.md`
9. `.claude/rules/python.md`
10. `.claude/rules/python-suppressions.md`
11. `.claude/rules/plan-acceptance-gates.md`

Skills read: `policy-compliance-order`, `atomic-plan-contract`, `evidence-and-timestamp-conventions`, `acceptance-criteria-tracking`, and `execution-environment`.

Output Summary: the five `.claude/rules` files named in the skill's baseline order compared byte-identical between the item worktree and the main checkout, so the rules as loaded are the rules on this branch.
