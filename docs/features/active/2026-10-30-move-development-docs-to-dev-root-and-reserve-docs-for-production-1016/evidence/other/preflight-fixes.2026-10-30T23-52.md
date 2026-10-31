# Preflight Fixes

Timestamp: 2026-10-30T23-52
Plan: docs/features/active/2026-10-30-move-development-docs-to-dev-root-and-reserve-docs-for-production-1016/plan.2026-10-30T18-59.md
Directive: PREFLIGHT VALIDATION ONLY (stage A, pre-decision)

## Fixes

1. [P1-T1] | stale citation | The example helper `collect-commit-context.test-helpers.ts` does not exist; the file under `extensions/drm-copilot/test/` is `collect-commit-context-test-support.ts`. Citation corrected; disposition (unchanged) kept.
2. [P0-T9] | success-case output assertion | ESLint's stylish formatter prints nothing on a clean run, so error and warning counts have no printed source on success. Text now reads the counts from the `problems` summary line, or records 0 and 0 when the output is empty. Assertion meaning unchanged.
3. [P0-T10] | success-case output assertion | `tsc --noEmit` prints nothing on success. The diagnostic count is now defined as the number of `error TS` lines, 0 on empty output. Assertion meaning unchanged.
4. [P4-T2] | success-case output assertion | Same ESLint correction as fix 2 for the final-QA "0 errors" condition. Assertion meaning unchanged.
5. [P4-T9] | literal formatting | Jest prints the seed line as `Seed:` followed by padding spaces and the value (observed in prior evidence, for example the issue 977 isolation artifacts), so the single-space literal `Seed: 1016` would not match. The condition now matches the two tokens. Assertion meaning unchanged.
6. [P3-T1] | task-ordering / ambient state | At [P3-T1], Phases 0 to 2 work is uncommitted, so a bare `git status --porcelain` check cannot attribute changes to the build. Replaced with a before-and-after porcelain capture that must be identical. Assertion meaning (the build adds no tracked change) unchanged.
7. [P3-T2] | task-ordering / ambient state | Same cause as fix 6: a bare porcelain listing would include uncommitted Phase 0 to 2 source and evidence files outside `<FEATURE>/evidence/other/`, making the condition unsatisfiable. Replaced with a before-and-after capture whose difference must lie under `<FEATURE>/evidence/other/`; the command artifact records both captures. Assertion meaning (the dry run changes nothing outside that directory) unchanged.
