# Phase 0 — Policy Read Evidence (Issue #194)

Timestamp: 2026-06-17T16-50

Policy Order: The repository-mandated policy reading order was followed for this TypeScript feature.

Files read, in order:

1. `.github/copilot-instructions.md` — repository tone and communication policy (loaded via project instructions / tone policy reference)
2. `.claude/rules/general-code-change.md` — baseline cross-language code change rules
3. `.claude/rules/general-unit-test.md` — baseline cross-language unit test rules
4. `.claude/rules/typescript.md` — TypeScript toolchain and coding standards
5. `.claude/rules/typescript-suppressions.md` — TypeScript suppression authorization policy
6. `.claude/rules/architecture-boundaries.md` — architecture boundary enforcement rules
7. `.claude/rules/quality-tiers.md` — module rigor tiers and coverage thresholds

Notes:
- This feature targets the TypeScript VS Code extension at `extensions/drm-copilot/`, which uses Jest (`run-jest.cjs`) rather than Vitest. The package-local Jest toolchain governs per the plan Toolchain Note.
- Coverage thresholds (uniform across tiers): line >= 85%, branch >= 75%.
- Suppression policy: pre-authorized single-line ESLint/`@ts-expect-error` patterns only, with mandatory `-- <reason>` suffix.
