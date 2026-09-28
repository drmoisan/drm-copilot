# Phase 0 — Policy Instructions Read (issue #594)

Timestamp: 2026-09-27T01-09
Task: [P0-T2], [P0-T3]

Policy Order: `.claude/skills/policy-compliance-order/SKILL.md` baseline order (CLAUDE.md, general code-change policy, general unit-test policy, then domain-specific rules), expanded by the plan's P0-T2 list as follows:

1. `CLAUDE.md`
2. `.github/copilot-instructions.md`
3. `.github/instructions/general-code-change.instructions.md`
4. `.github/instructions/general-unit-test.instructions.md`
5. `.claude/rules/general-code-change.md`
6. `.claude/rules/general-unit-test.md`
7. `.claude/rules/quality-tiers.md`
8. `.claude/rules/shell.md`
9. `.claude/rules/self-explanatory-code-commenting.md`
10. `.claude/rules/tonality.md`
11. `.claude/rules/plan-acceptance-gates.md`

Files read (eleven, in the order above):

- `CLAUDE.md`
- `.github/copilot-instructions.md`
- `.github/instructions/general-code-change.instructions.md`
- `.github/instructions/general-unit-test.instructions.md`
- `.claude/rules/general-code-change.md`
- `.claude/rules/general-unit-test.md`
- `.claude/rules/quality-tiers.md`
- `.claude/rules/shell.md`
- `.claude/rules/self-explanatory-code-commenting.md`
- `.claude/rules/tonality.md`
- `.claude/rules/plan-acceptance-gates.md`

Files edited: none.

Key constraints carried into execution:

- Shell toolchain order: shfmt, shellcheck, syntax check (`bash -n` equivalent), bats; restart on any failure or rewrite.
- CI (`.github/workflows/_shell-coverage.yml`, shfmt 3.8.0, kcov v43) is canonical when local and CI results disagree.
- Line coverage >= 85% uniform; no bash branch-coverage gate; no regression on changed lines.
- 500-line limit on production and test shell files; tests use checked-in fixtures only, no temporary files.
- Bugfix workflow: failing regression test first, then minimal fix.
- Professional tone in all evidence and commit text.
