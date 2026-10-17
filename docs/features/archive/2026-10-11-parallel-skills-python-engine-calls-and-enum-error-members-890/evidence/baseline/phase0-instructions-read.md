# Phase 0 Policy Read (Issue #890)

Timestamp: 2026-10-12T20-06
Task: P0-T1
Policy Order: CLAUDE.md, then general code change, general unit test, Python, Python suppressions, shell, quality tiers, plan acceptance gates, parallel orchestration, tonality.

Files read, in order:

1. `CLAUDE.md`
2. `.claude/rules/general-code-change.md`
3. `.claude/rules/general-unit-test.md`
4. `.claude/rules/python.md`
5. `.claude/rules/python-suppressions.md`
6. `.claude/rules/shell.md`
7. `.claude/rules/quality-tiers.md`
8. `.claude/rules/plan-acceptance-gates.md`
9. `.claude/rules/parallel-orchestration.md`
10. `.claude/rules/tonality.md`

Notes:

- No file under `.claude/rules/` or `.github/instructions/` is edited by this plan.
- Shell verification follows the operator constraint: bats and kcov results come only from PR CI; shfmt and shellcheck may run by direct invocation.
