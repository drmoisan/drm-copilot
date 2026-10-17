# Phase 0 Instructions Read (P0-T2 to P0-T8)

Timestamp: 2026-10-09T21-08
Policy Order: CLAUDE.md -> general-code-change -> general-unit-test -> quality-tiers -> TypeScript language rules (typescript, typescript-suppressions)

Files read in full, in order (worktree copies):

1. `CLAUDE.md` (P0-T2; includes the tonality reference to `.claude/rules/tonality.md`)
2. `.claude/rules/general-code-change.md` (P0-T3)
3. `.claude/rules/general-unit-test.md` (P0-T4)
4. `.claude/rules/quality-tiers.md` (P0-T5)
5. `.claude/rules/typescript.md` (P0-T6)
6. `.claude/rules/typescript-suppressions.md` (P0-T7)

Notes relevant to this plan:
- 500-line limit per code/test file; no temporary files in tests; tests under `test/` mirroring `src/`.
- Coverage defaults: line >= 85%, branch >= 75%; no regression on changed lines.
- Toolchain order: format, lint, type-check, test; restart from format on failure or file change.
- Suppressions only per the pre-authorized single-line patterns.
