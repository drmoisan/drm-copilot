# Phase 0 — Policy Instructions Read (F2 `ts-validate-orchestration-artifacts`)

Timestamp: 2026-06-25T23-14

Policy Order:
1. CLAUDE.md
2. .claude/rules/general-code-change.md
3. .claude/rules/general-unit-test.md
4. .claude/rules/typescript.md
5. .claude/rules/typescript-suppressions.md
6. .claude/rules/quality-tiers.md
7. .claude/rules/orchestrator-state.md
8. .claude/rules/tonality.md

Files Read:
- CLAUDE.md (loaded via standing instructions) — tone policy, policy-compliance reading order, four-layer architecture.
- .claude/rules/general-code-change.md (loaded via standing instructions) — design principles, 500-line file limit, mandatory toolchain loop, error handling, I/O boundaries.
- .claude/rules/general-unit-test.md (loaded via standing instructions) — five core test properties, coverage (line >= 85%, branch >= 75%), no temp files, test file location mirror, AAA structure.
- .claude/rules/typescript.md (loaded via standing instructions) — toolchain order, strong typing, no `any`, ES modules, kebab-case filenames, coverage thresholds.
- .claude/rules/typescript-suppressions.md (loaded via standing instructions) — pre-authorized single-line suppressions only; prohibited file-level disables and `@ts-ignore`/`@ts-nocheck`.
- .claude/rules/quality-tiers.md (loaded via standing instructions) — T1–T4 tiers; uniform coverage thresholds.
- .claude/rules/orchestrator-state.md (read) — remediation-cycle invariants (3), human_interaction invariants (3), routing-contract receipts, foreign-schema prohibition expressed as prose/logic; must be reproduced verbatim in TS port behavior and message text.
- .claude/rules/tonality.md (loaded via standing instructions) — professional tone; no humor, hyperbole, decorative metaphor; evidence-first wording.

Notes:
- The repository TypeScript policy text references Vitest; the authoritative
  toolchain for `extensions/drm-copilot/` is Jest (`jest.config.cjs`,
  `ts-jest`, `run-jest.cjs`) per the plan toolchain facts and accepted decision
  D1 in spec.md. Tests use Jest conventions (`@jest/globals`, `jest.fn()`,
  `jest.mock`, `jest.spyOn`).
- Coverage thresholds applied: line >= 85%, branch >= 75% (uniform across
  tiers per quality-tiers.md).
- No `any`; prefer `unknown` plus narrowing. Kebab-case filenames. ES modules.
- F1 shared lib reused: `file-system.ts`, `json-config.ts` (`iterGovernedFiles`).
  Not re-ported.
