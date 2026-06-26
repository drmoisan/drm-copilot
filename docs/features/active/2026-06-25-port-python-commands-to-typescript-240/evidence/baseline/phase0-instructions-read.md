# Phase 0 — Policy Instructions Read (F1)

Timestamp: 2026-06-25T22-33

Policy Order:
1. CLAUDE.md
2. .claude/rules/general-code-change.md
3. .claude/rules/general-unit-test.md
4. .claude/rules/typescript.md
5. .claude/rules/typescript-suppressions.md
6. .claude/rules/quality-tiers.md
7. .claude/rules/self-explanatory-code-commenting.md

Files Read:
- CLAUDE.md (loaded via standing instructions)
- .claude/rules/general-code-change.md (loaded via standing instructions)
- .claude/rules/general-unit-test.md (loaded via standing instructions)
- .claude/rules/typescript.md (read)
- .claude/rules/typescript-suppressions.md (read)
- .claude/rules/quality-tiers.md (loaded via standing instructions)
- .claude/rules/self-explanatory-code-commenting.md (read)

Notes:
- The repository TypeScript policy text references Vitest; the authoritative
  toolchain for `extensions/drm-copilot/` is Jest (`jest.config.cjs`,
  `ts-jest`, `run-jest.cjs`) per the plan toolchain facts. Tests use Jest
  conventions (`@jest/globals`, `jest.fn()`, `jest.mock`, `jest.spyOn`).
- Coverage thresholds applied: line >= 85%, branch >= 75% (uniform across
  tiers per quality-tiers.md).
- No `any`; prefer `unknown` plus narrowing. Kebab-case filenames. ES modules.
