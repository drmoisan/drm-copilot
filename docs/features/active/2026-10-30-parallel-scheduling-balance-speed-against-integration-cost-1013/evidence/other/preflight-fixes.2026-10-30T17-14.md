# Preflight Fixes

Timestamp: 2026-10-30T17-14
Plan: docs/features/active/2026-10-30-parallel-scheduling-balance-speed-against-integration-cost-1013/plan.2026-10-30T09-15.md
Plan version reviewed: 0.5 (82 tasks)

## Fix 1

- Task: [P0-T1]
- Defect class: citation correction (asserted ref does not match the acceptance criterion)
- Before: the three #1006 observables were checked "at `HEAD`".
- After: the three observables are checked on `origin/main` (spec AC-21) and at `HEAD` after the merge.
- Reason: spec AC-21 and `## Dependency on #1006` state the observables against `origin/main`. Because the branch carries only feature-folder commits beyond the merge base, the intent is the same (prove #1006 is on `main`); the correction aligns the ref with the AC text. No task added, removed, or reordered.

## Fix 2

- Task: [P9-T7]
- Defect class: literal formatting within one task (command order inside the task text)
- Before: "Run ESLint, the TypeScript compiler, Prettier in check mode, and the full Jest suite".
- After: "Run Prettier in check mode, ESLint, the TypeScript compiler, and the full Jest suite".
- Reason: the mandatory toolchain loop orders formatting before linting and type checking. Prettier runs in check mode and changes no file, so the assertion is unchanged; only the stated order now matches the loop.
