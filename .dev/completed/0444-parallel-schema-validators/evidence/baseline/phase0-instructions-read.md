# Phase 0 Policy Read Receipt — [P0-T1]

Timestamp: 2026-08-07T18-01

Feature: 2026-08-07-parallel-schema-validators-444 (issue #444)
Plan: `docs/features/active/2026-08-07-parallel-schema-validators-444/plan.2026-08-07T11-11.md`
Task: [P0-T1]
Workspace root: `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a08c400dcb993312e`
Branch: `feature/parallel-schema-validators-444`

Policy Order: The following policy files were read in the exact order specified by [P0-T1], which
matches the repository policy-compliance reading order in `CLAUDE.md` and the
`policy-compliance-order` skill, extended with the language- and domain-specific rules in scope for
this feature (Python and TypeScript, plus the orchestrator-state enforcement precedent and the
module rigor tier system).

## Files Read (in order)

1. `CLAUDE.md`
2. `.claude/rules/general-code-change.md`
3. `.claude/rules/general-unit-test.md`
4. `.claude/rules/python.md`
5. `.claude/rules/python-suppressions.md`
6. `.claude/rules/typescript.md`
7. `.claude/rules/typescript-suppressions.md`
8. `.claude/rules/self-explanatory-code-commenting.md`
9. `.claude/rules/orchestrator-state.md`
10. `.claude/rules/quality-tiers.md`

All ten files were located at the paths listed above, relative to the workspace root. No policy file
was modified.

## Controlling Constraints Extracted

- Toolchain loop order per language: format, lint, type-check, test; restart from step 1 if any stage
  fails or changes files (`.claude/rules/general-code-change.md`, `.claude/rules/python.md`,
  `.claude/rules/typescript.md`).
- File size limit: no production, test, or reusable script file may exceed 500 lines
  (`.claude/rules/general-code-change.md`).
- Coverage thresholds are uniform across tiers T1-T4: line coverage >= 85%, branch coverage >= 75%,
  with no regression on changed lines (`.claude/rules/general-unit-test.md`,
  `.claude/rules/quality-tiers.md`).
- Test file location: tests mirror production structure under a `tests/` tree; colocation with
  production source is prohibited (`.claude/rules/general-unit-test.md`).
- Coverage exclusion policy: no production file under `src/` may be excluded from coverage
  measurement (`.claude/rules/general-unit-test.md`).
- Python commands: `poetry run black .`, `poetry run ruff check .`, `poetry run pyright`,
  `poetry run pytest --cov --cov-branch --cov-report=term-missing` (`.claude/rules/python.md`).
- TypeScript commands: `npm run format`, `npm run lint`, `npm run typecheck`, Jest for tests
  (`.claude/rules/typescript.md`).
- Dependencies may not be added without explicit user instruction (`.claude/rules/python.md`,
  `.claude/rules/typescript.md`). This governs plan task P6-T7 branch (c).
- Suppressions (`# noqa`, `# type: ignore`, `eslint-disable-next-line`, `@ts-expect-error`) require a
  pre-authorized pattern or explicit user approval
  (`.claude/rules/python-suppressions.md`, `.claude/rules/typescript-suppressions.md`).
- Docstrings are mandatory for every class, function, and method; loops, branching, and multi-step
  blocks require intent comments; numbered notes are prohibited
  (`.claude/rules/self-explanatory-code-commenting.md`).
- Foreign Schema Warning and the enforcement doctrine that invariants are expressed as prose plus
  validator logic, never an imported schema file (`.claude/rules/orchestrator-state.md`). This is the
  precedent the parallel validators follow.
- Every project must be classified in `quality-tiers.yml` at the repository root
  (`.claude/rules/quality-tiers.md`). Observed state recorded in [P0-T10].
