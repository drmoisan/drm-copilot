# Phase 0 Policy Reads — Remediation Cycle 1 (issue #647)

Timestamp: 2026-10-02T00-34
Policy Order: CLAUDE.md, copilot-instructions, general code change, general unit test, TypeScript code change and unit test, then the `.claude/rules/` mirrors and quality tiers.

Files read (11), in order:

1. `CLAUDE.md` ([P0-T1])
2. `.github/copilot-instructions.md` ([P0-T2])
3. `.github/instructions/general-code-change.instructions.md` ([P0-T3])
4. `.github/instructions/general-unit-test.instructions.md` ([P0-T4])
5. `.github/instructions/typescript-code-change.instructions.md` ([P0-T5])
6. `.github/instructions/typescript-unit-test.instructions.md` ([P0-T6])
7. `.claude/rules/general-code-change.md` ([P0-T7])
8. `.claude/rules/general-unit-test.md` ([P0-T8])
9. `.claude/rules/typescript.md` ([P0-T9])
10. `.claude/rules/typescript-suppressions.md` ([P0-T10])
11. `.claude/rules/quality-tiers.md` ([P0-T11])

Constraints carried into execution: Prettier, ESLint, TSC, and Jest loop in that order with restart on failure or rewrite; no `any`, no `@ts-ignore`/`@ts-nocheck`, no suppression without a pre-authorized pattern (plan rule 7 forbids all suppressions); 500-line file limit; Arrange-Act-Assert; no temporary files in tests; line coverage >= 85% and branch coverage >= 75%; no coverage regression on changed lines.
