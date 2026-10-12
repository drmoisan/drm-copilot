# Null-Arm and Target-Role Tests (P1-T33)

Timestamp: 2026-10-12T15-03
Command: cd extensions/drm-copilot && npx jest --config jest.config.cjs test/lib/codex-native-converter/reporting-render.test.ts test/lib/codex-native-converter/reporting-coverage.test.ts test/lib/codex-native-converter/validation.test.ts test/lib/codex-native-converter/engine-pipeline.test.ts -t "889-(null-arm|target-role)"
EXIT_CODE: 0
Output Summary:
- `Test Suites: 4 passed, 4 total`
- `Tests:       13 skipped, 7 passed, 20 total`
- The `Tests:` line contains `7 passed` and no `failed`. PASS.
- Tests run (7): reporting-render.test.ts (2: lines 83 and 189), reporting-coverage.test.ts (2: reporting.ts:151-152 source arm and :157 target arm), validation.test.ts (2: validation.ts:364-365 source arm and :370 target arm), engine-pipeline.test.ts (1: `889-target-role`).
- AC-5 note for validation.ts:364-365: `MappingRecord.sourcePath` and `PlannedEmission.sourcePath` are typed `string`, and the only `sourcePath: null` findings are `missing-required-input` and `lingering-source-runtime-reference`, so no public input yields a null and a non-null source path under an equal code. The test supplies `null` on both operands (two `lingering-source-runtime-reference` findings) and asserts the order decided by the target path (`["a.md", "z.md"]`) in both generated-output insertion orders. No type cast is used.
