# Phase 0 Instructions Read (P0-T8)

Timestamp: 2026-10-08T02-38
Policy Order: CLAUDE.md -> general-code-change -> general-unit-test -> TypeScript language rules (typescript, typescript-suppressions) -> quality-tiers (coverage thresholds referenced by step 3)

Files read in full, in this order (P0-T2 through P0-T7):

1. `CLAUDE.md` (standing instructions; tone reference to `.claude/rules/tonality.md`)
2. `.claude/rules/general-code-change.md`
3. `.claude/rules/general-unit-test.md`
4. `.claude/rules/typescript.md`
5. `.claude/rules/typescript-suppressions.md`
6. `.claude/rules/quality-tiers.md`

Notes:
- The root `CLAUDE.md` states no numeric coverage thresholds, so the 85% line / 75% branch defaults govern.
- `quality-tiers.yml` presence does not affect the uniform coverage defaults applied by this plan.
