# Phase 0 Policy Reads (Remediation Cycle 3)

Timestamp: 2026-10-16T06-16
Task: [P0-T1]
Policy Order: CLAUDE.md -> general-code-change -> general-unit-test -> language-specific (Python, TypeScript) -> quality-tiers -> plan-acceptance-gates

Files read, in order:

1. `CLAUDE.md`
2. `.claude/rules/general-code-change.md`
3. `.claude/rules/general-unit-test.md`
4. `.claude/rules/python.md`
5. `.claude/rules/python-suppressions.md`
6. `.claude/rules/typescript.md`
7. `.claude/rules/typescript-suppressions.md`
8. `.claude/rules/quality-tiers.md`
9. `.claude/rules/plan-acceptance-gates.md`

Key constraints noted:

- Toolchain order: format, lint, type-check, test; restart on any failure or file change.
- 500-line limit for production and test files; no temporary files in tests.
- Coverage defaults 85% line / 75% branch (root `CLAUDE.md` states none); no changed-line regression.
- Suppressions only per the pre-authorized patterns.
- `.claude/rules/plan-acceptance-gates.md` line 153 is the parity paragraph changed in Phase 4 under the operator approval recorded for this item.
