# Phase 0 Instructions Read — Issue #932

Timestamp: 2026-10-16T00-26
Task: [P0-T1]
Policy Order: policy-compliance-order (CLAUDE.md, general code change, general unit test, language-specific rules, then the domain rules named by the plan)

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

Notes:

- The operator approved, for this item only, edits to `.claude/rules/plan-acceptance-gates.md` and its bundle copy, `.claude/skills/atomic-plan-contract/SKILL.md` and its bundle copy, and the 24 `.codex/agents/*.toml` files named in the plan.
- Coverage thresholds: the root `CLAUDE.md` states none, so the defaults apply (85% line, 75% branch).
