# Phase 0 Policy Read — Remediation Cycle 2 ([P0-T1])

Timestamp: 2026-08-20T16-34

Policy Order: repository standing instructions, then cross-language code-change policy, then
cross-language unit-test policy, then the language-specific rules for the two runtimes in scope
(Python and TypeScript), then the governing rule whose graceful-degradation clause finding R5
restores (read-only this cycle).

Files read, in order:

1. `CLAUDE.md` — standing instructions: tone policy, policy-compliance reading order, four-layer runtime architecture.
2. `.claude/rules/general-code-change.md` — design principles, mandatory seven-stage toolchain loop, 500-line file limit, error-handling and naming rules.
3. `.claude/rules/general-unit-test.md` — five core test properties, uniform coverage thresholds (>= 85% line, >= 75% branch), coverage-exclusion prohibition, test-file location rule, Arrange-Act-Assert structure.
4. `.claude/rules/python.md` — Black, Ruff, Pyright, Pytest toolchain order; typing and error-handling standards; pytest conventions.
5. `.claude/rules/typescript.md` — Prettier, ESLint, tsc, Jest toolchain order; coverage thresholds; determinism rules.
6. `.claude/rules/plan-acceptance-gates.md` — G1 through G6 rule table, the graceful-degradation clause ("A repository seam that raises, or that reports a non-zero exit, causes G2, G3, G5, and G6 to be skipped. No finding is produced and no exception escapes the evaluation entry point."), severity decisions, and the message-formatting prohibition. READ-ONLY this cycle; not modified.

Binding constraints carried forward into execution:

- No finding string, severity constant (`G5_SEVERITY` included), rule ordering, or channel routing changes in either runtime.
- `.claude/rules/plan-acceptance-gates.md`, `.claude/skills/atomic-plan-contract/SKILL.md`, and every file under `.github/instructions/` are read-only.
- No TypeScript production module is modified; the `extensions/drm-copilot/resources/claude-customizations/` mirrors stay byte-identical.
- No committed evidence artifact from a prior cycle is modified or regenerated.
- No jest `coverageThreshold` is weakened and no coverage `exclude` is added for a production path.
- All cycle-2 evidence is written under `docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/evidence/<kind>/`.

EXIT_CODE: 0
