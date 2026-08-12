# TypeScript Semantic-Drift Fail-Before Receipt

- Plan task: `[P1-T5]`
- Baseline HEAD: `fe0413d4aca1e76b2d02d05701fba79a887d5405`
- Command: `npm --prefix extensions/drm-copilot run test:unit -- --runTestsByPath test/lib/validate/parallel-drift-parity.test.ts`
- Exit code: `1` (expected)
- Test suites: `1 failed, 1 total`
- Tests: `4 failed, 4 passed, 8 total`
- Runtime: `0.528 s`

## Expected Missing-Enforcement Failures

Each failure received an empty TypeScript validation-error list where the
Python-authoritative fixture required an error containing `unresolved drift`:

1. `DRIFT_OBSERVED_PATH_ESCAPE`
2. `DRIFT_LATER_STARTED_HALT_REQUIRED`
3. `DRIFT_UNSTARTED_RECOLOR_REQUIRED`
4. `DRIFT_REQUEUE_ITEM_ORDER`

The two accepted semantic cases and both corpus-integrity tests passed. The
non-zero result is therefore caused only by absent TypeScript semantic-drift
enforcement; no fixture-load, JSON-shape, TypeScript compilation, mutation
validation, or unrelated checkpoint-validation failure was present.
