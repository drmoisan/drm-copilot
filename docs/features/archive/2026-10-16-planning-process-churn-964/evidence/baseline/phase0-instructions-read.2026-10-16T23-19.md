# Phase 0 Policy Reads — Issue #964

Timestamp: 2026-10-16T23-19
Task: [P0-T1]
Policy Order: CLAUDE.md, then general code change, then general unit test, then language and domain rules (per `.claude/skills/policy-compliance-order/SKILL.md`)

## Files Read (in order)

1. `CLAUDE.md`
2. `.claude/rules/general-code-change.md`
3. `.claude/rules/general-unit-test.md`
4. `.claude/rules/quality-tiers.md` (applies: `quality-tiers.yml` exists at the repository root)
5. `.claude/rules/tonality.md`
6. `.claude/rules/python.md`
7. `.claude/rules/python-suppressions.md`
8. `.claude/rules/typescript.md`
9. `.claude/rules/typescript-suppressions.md`
10. `.claude/rules/powershell.md`
11. `.claude/rules/plan-acceptance-gates.md`

## Constraints Noted

- Toolchain order per language: format, lint, type-check (not PowerShell), test with coverage; restart on any failure or rewrite.
- Coverage: 85% line and 75% branch (Python, TypeScript); 85% line only for PowerShell. The root `CLAUDE.md` states no thresholds, so the defaults govern.
- 500-line limit for non-Markdown files; no temporary files in tests; test files under `tests/` mirroring source.
- Suppressions only per the pre-authorized patterns.
- Tone: professional, factual, no hyperbole.
