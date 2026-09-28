# Phase 0 Policy Read — Issue #440 F7 Remediation Cycle 1

- **Task:** [P0-T1]
- **Plan of record:** `docs/features/active/2026-08-07-parallel-enforcement-hooks-440/remediation-plan.2026-08-08T23-15.md`

Timestamp: 2026-08-09T00-13

Policy Order: The eleven files below were read in the exact order the plan's [P0-T1] task text states. That order is the repository policy-compliance order (`CLAUDE.md`, then the cross-language code-change and unit-test policies, then the language- and domain-specific rules for the files in scope), extended with the TypeScript, Python, commenting, quality-tier, and parallel-surface rules this remediation touches.

## Files Read (in order)

1. `CLAUDE.md`
2. `.claude/rules/general-code-change.md`
3. `.claude/rules/general-unit-test.md`
4. `.claude/rules/typescript.md`
5. `.claude/rules/typescript-suppressions.md`
6. `.claude/rules/architecture-boundaries.md`
7. `.claude/rules/python.md`
8. `.claude/rules/python-suppressions.md`
9. `.claude/rules/self-explanatory-code-commenting.md`
10. `.claude/rules/quality-tiers.md`
11. `.claude/rules/parallel-orchestration.md`

All eleven files were read in this session. Files 1, 2, 3, 10, and 11 are auto-loaded into the session context by the repository's standing-instruction and path-scoped rule mechanism; files 4, 5, 6, 7, 8, and 9 were read explicitly with the Read tool.

## Constraints Extracted That Bind This Cycle

- **No policy document may be modified.** No task in this plan edits any file under `.claude/rules/**` or `.github/instructions/**` (`CLAUDE.md`, policy-compliance-order baseline).
- **TypeScript toolchain order** is format (`npm run format`) → lint (`npm run lint`) → type-check (`npm run typecheck`) → test (`npm run test:coverage`), restarting from step 1 on any failure or file change (`.claude/rules/typescript.md`, `.claude/rules/general-code-change.md`).
- **Python toolchain order** is `poetry run black .` → `poetry run ruff check .` → `poetry run pyright` → `poetry run pytest --cov --cov-branch --cov-report=term-missing`, with the same restart rule (`.claude/rules/python.md`).
- **Coverage thresholds are uniform** across T1–T4: line >= 85%, branch >= 75%, with no regression on changed lines (`.claude/rules/quality-tiers.md`, `.claude/rules/general-unit-test.md`).
- **No suppression may be added.** `// eslint-disable*`, `// @ts-expect-error`, `// @ts-ignore`, `# noqa`, and `# type: ignore` all require pre-authorization or explicit user approval; none is pre-authorized for this work (`.claude/rules/typescript-suppressions.md`, `.claude/rules/python-suppressions.md`).
- **Avoid `any`; prefer `unknown` plus narrowing.** Avoid type assertions (`as X`) unless justified (`.claude/rules/typescript.md`).
- **File size limit** is 500 lines for production, test, and reusable script files (`.claude/rules/general-code-change.md`).
- **Test file location:** TypeScript tests live under `extensions/drm-copilot/test/` mirroring `src/`; Python tests under `tests/scripts/dev_tools/`. Colocation in the production source tree is prohibited (`.claude/rules/general-unit-test.md`).
- **No temporary files in tests.** Read-only access to a committed fixture corpus is not a temporary file (`.claude/rules/general-unit-test.md`, `.claude/rules/general-code-change.md`).
- **Architecture-boundary tool** for TypeScript is `dependency-cruiser` with configuration `.dependency-cruiser.cjs` (`.claude/rules/architecture-boundaries.md`, `.claude/rules/typescript.md`). P4-T11 records the configuration's presence or absence rather than claiming a pass.
- **Python docstring policy:** every function, including private helpers, carries a Google-style docstring; loops, comprehensions, and non-trivial branching carry intent comments; no numbered notes (`.claude/rules/self-explanatory-code-commenting.md`).
- **F7 seam and enum ownership:** the `PARALLEL_COHORT_BARRIER_VIOLATION` invariant is F7's assigned addition to the orchestrator validator; the TypeScript core `parallel-orchestrator-state-core.ts` carries the matching comment-delimited seam. All nine parallel-surface enums are F3-owned: wave-4 features consume and never extend them (`.claude/rules/parallel-orchestration.md`).
- **Parity scope and known divergence classes:** the TypeScript parity port reproduces the same invariants; three divergence classes (`pythonRepr` quote selection, integral floats erased by `JSON.parse`, and boolean/integer equality) are known and are to be avoided rather than fixed by this cycle (`.claude/rules/parallel-orchestration.md`).
