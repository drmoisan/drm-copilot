# Target-Role Mutation Check - Red (P1-T34 steps 1-2) [expect-fail]

Timestamp: 2026-10-12T15-03
Command: (edit) In extensions/drm-copilot/src/lib/codex-native-converter/engine-pipeline.ts, line 241 `    return compareCodePoint(left.targetRole, right.targetRole);` replaced with `    return 0;` using the Edit tool; then: cd extensions/drm-copilot && npx jest --config jest.config.cjs test/lib/codex-native-converter/engine-pipeline.test.ts -t "889-target-role"
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
- `Test Suites: 1 failed, 1 total`
- `Tests:       1 failed, 1 skipped, 2 total`
- Failing test: `coverage: engine-pipeline.ts > 889-target-role: orders traces sharing source path and section id by target role`
- Assertion at engine-pipeline.test.ts:127: expected `["hook", "shared-skill"]`; received `["shared-skill", "hook"]` (the pre-sort insertion order, unchanged because the comparator returned 0).
- PASS (expected failure observed). The mutation was restored in step 3 (see `target-role-mutation-restored.2026-10-12T15-03.md`).
