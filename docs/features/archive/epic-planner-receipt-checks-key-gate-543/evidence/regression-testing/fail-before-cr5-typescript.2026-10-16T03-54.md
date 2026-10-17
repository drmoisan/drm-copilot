# Fail-Before CR-5 TypeScript Validator (P1-T4) [expect-fail]

Timestamp: 2026-10-16T03-54
Command: npm --prefix extensions/drm-copilot test -- test/lib/validate/epic-planner-state-feature-indices.test.ts > SCRATCH/rc1/ts-fail-before.txt 2>&1; grep -e 'Tests:' -e 'error TS' -e 'features\[1\].preparation_status' -e 'features\[1\].feature_folder' SCRATCH/rc1/ts-fail-before.txt
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
- Tests:       7 failed, 1 passed, 8 total (pre-fix production code)
- error TS lines: 0
- Received-value lines (compacted indices):
      +   "Epic planner checkpoint features[1].preparation_status must be 'prepared'.",  (four times, one per $label case)
      +   "Epic planner checkpoint features[1].feature_folder must be unique: 'docs/features/active/feature-101'.",
- The passing case is the preservation test "keeps the feature index unchanged without non-object entries".
