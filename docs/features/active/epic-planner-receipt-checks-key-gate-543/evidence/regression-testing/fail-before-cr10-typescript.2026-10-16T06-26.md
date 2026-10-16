# Fail-Before CR-10 TypeScript (P2-T5) [expect-fail]

Timestamp: 2026-10-16T06-26
Command: npm --prefix extensions/drm-copilot test -- test/lib/validate/epic-planner-readiness-relative-paths.test.ts > SCRATCH/rc2/ts-cr10-fail-before.txt 2>&1; grep -e 'Tests:' -e 'error TS' -e 'repository-relative paths' SCRATCH/rc2/ts-cr10-fail-before.txt; grep -e 'plan_path must stay within' -e 'feature folder: docs/features/active//feature-101' SCRATCH/rc2/ts-cr10-fail-before.txt
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
- Tests:       6 failed, 5 passed, 11 total
- error TS lines: 0 (the suite compiled against pre-fix code; failures are assertion failures)
- Failing titles (failure headers):
  - validateEpicReadinessIntegrity repository-relative paths > normalizes a dot-prefix feature_folder like the Python validator
  - validateEpicReadinessIntegrity repository-relative paths > normalizes a dot-segment feature_folder like the Python validator
  - validateEpicReadinessIntegrity repository-relative paths > normalizes a double-slash feature_folder like the Python validator
  - validateEpicReadinessIntegrity repository-relative paths > normalizes a trailing-slash feature_folder like the Python validator
  - validateEpicReadinessIntegrity repository-relative paths > normalizes a dot-only feature_folder like the Python validator
  - validateEpicReadinessIntegrity repository-relative paths > accepts a dot-prefixed plan_path
- Passing: plain, and the four rejections (parent, absolute, backslash, blank).
- Received-value lines (pre-fix behaviour):
  - unnormalized folder: "... Execution readiness requires feature folder: docs/features/active//feature-101"
  - pre-fix rejection: "... Epic planner checkpoint features[0].plan_path must stay within the workspace root."
- Pre-fix relativePath rejects every spelling with a "." segment and returns empty-segment spellings unchanged.
