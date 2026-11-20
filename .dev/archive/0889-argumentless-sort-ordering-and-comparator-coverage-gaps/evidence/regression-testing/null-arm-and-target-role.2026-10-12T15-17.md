# Null-Arm and Target-Role Tests After Formatting (P1-T35 rerun of P1-T33)

Timestamp: 2026-10-12T15-17
Command: cd extensions/drm-copilot && npx jest --config jest.config.cjs test/lib/codex-native-converter/reporting-render.test.ts test/lib/codex-native-converter/reporting-coverage.test.ts test/lib/codex-native-converter/validation.test.ts test/lib/codex-native-converter/engine-pipeline.test.ts -t "889-(null-arm|target-role)"
EXIT_CODE: 0
Output Summary:
- `Test Suites: 4 passed, 4 total`
- `Tests:       13 skipped, 7 passed, 20 total`
- Contains `7 passed`, no `failed`. PASS.
- AC-5 note for validation.ts:364-365: no public input yields a null and a non-null source path under an equal code (`sourcePath` is typed `string` on `MappingRecord` and `PlannedEmission`; only `missing-required-input` and `lingering-source-runtime-reference` findings carry `sourcePath: null`). The test supplies `null` on both operands and asserts the order decided by the target path.
