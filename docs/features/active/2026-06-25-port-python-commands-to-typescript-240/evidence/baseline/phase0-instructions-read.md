# Phase 0 — Policy Instructions Read (F9 ts-pr-context)

Timestamp: 2026-06-26T10-02

Policy Order:
1. .github/copilot-instructions.md (repository tone and communication policy)
2. .claude/rules/general-code-change.md (cross-language code change policy)
3. .claude/rules/general-unit-test.md (cross-language unit test policy)
4. Language/domain-specific rules (TypeScript in scope):
   - .claude/rules/typescript.md
   - .claude/rules/typescript-suppressions.md
   - .claude/rules/architecture-boundaries.md
   - .claude/rules/quality-tiers.md
   - .claude/rules/tonality.md

Files Read:
- .github/copilot-instructions.md / CLAUDE.md (standing instructions) — tone policy, policy-compliance reading order, four-layer architecture.
- .claude/rules/general-code-change.md — design principles, 500-line file limit, mandatory toolchain loop, error handling, I/O boundaries.
- .claude/rules/general-unit-test.md — five core test properties, coverage (line >= 85%, branch >= 75%), no temp files, test-file mirror location, AAA structure.
- .claude/rules/typescript.md — toolchain order, strong typing, no `any`, ES modules, kebab-case filenames, coverage thresholds, injected Clock for wall-clock reads.
- .claude/rules/typescript-suppressions.md — pre-authorized single-line suppressions only; prohibited file-level disables and `@ts-ignore`/`@ts-nocheck`.
- .claude/rules/architecture-boundaries.md — layer boundary and No-COM assertions; dependency-cruiser is the TS enforcement tool.
- .claude/rules/quality-tiers.md — T1–T4 tiers; uniform coverage thresholds.
- .claude/rules/tonality.md — professional tone; no humor, hyperbole, decorative metaphor; evidence-first wording.

Notes:
- Toolchain deviation recorded: the extensions/drm-copilot package uses Jest (not Vitest, which .claude/rules/typescript.md names). Per the explicit feature directive, Jest is the test framework for this package (@jest/globals, jest.fn(), jest.mock). Coverage thresholds (line >= 85%, branch >= 75%) and all other TypeScript standards apply unchanged.
- Wall-clock reads route through an injected clock (() => Date) per typescript.md determinism rule.
