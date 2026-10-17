# Phase 0 Policy Reads (issue #532)

Timestamp: 2026-10-02T04-29
Policy Order: CLAUDE.md -> general-code-change -> general-unit-test -> language-specific (Python, TypeScript) -> quality-tiers and plan-acceptance-gates

Files read (P0-T1 through P0-T6):

1. `CLAUDE.md` (P0-T1) - tone policy, policy reading order, four-layer architecture, checkpoint path `artifacts/orchestration/orchestrator-state.json`.
2. `.claude/rules/general-code-change.md` (P0-T2) - 500-line file size limit for production, test, and reusable script files; mandatory seven-stage toolchain loop (format, lint, type-check, architecture-boundary, unit tests, contract checks, integration), restarted from step 1 on any failure or auto-fix.
3. `.claude/rules/general-unit-test.md` (P0-T3) - line coverage >= 85% and branch coverage >= 75% across all tiers; creation and use of temporary files in tests is strictly prohibited; tests live under a mirrored `tests/` tree.
4. `.claude/rules/python.md` and `.claude/rules/python-suppressions.md` (P0-T4) - Black, Ruff, Pyright, Pytest toolchain; full typing; suppressions only by pre-authorized pattern.
4. `.claude/rules/typescript.md` and `.claude/rules/typescript-suppressions.md` (P0-T5) - Prettier, ESLint, TSC, Jest toolchain; no `any`; single-line suppressions with `-- <reason>` only.
5. `.claude/rules/quality-tiers.md` and `.claude/rules/plan-acceptance-gates.md` (P0-T6) - uniform coverage thresholds, tier-dependent property-test density (T1/T2 only); acceptance gates G1 through G9.

Output Summary: nine policy files read in the required order; no policy file was modified.
