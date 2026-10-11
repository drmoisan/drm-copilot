# Phase 0 Policy Reads (remediation cycle 1)

Timestamp: 2026-10-11T01-17
Task: [P0-T1]
Policy Order: CLAUDE.md -> general-code-change -> general-unit-test -> quality-tiers -> language/domain rules (typescript, python, shell) -> plan-acceptance-gates

Files read, in order:

1. `CLAUDE.md`
2. `.claude/rules/general-code-change.md`
3. `.claude/rules/general-unit-test.md`
4. `.claude/rules/quality-tiers.md`
5. `.claude/rules/typescript.md`
6. `.claude/rules/python.md`
7. `.claude/rules/shell.md`
8. `.claude/rules/plan-acceptance-gates.md`

Notes relevant to this cycle:

- Line coverage >= 85% and branch coverage >= 75% apply uniformly (T1-T4); bash (kcov) has no branch gate.
- This cycle is evidence-only; no source file is edited, so no format, lint, or type-check stage runs.
