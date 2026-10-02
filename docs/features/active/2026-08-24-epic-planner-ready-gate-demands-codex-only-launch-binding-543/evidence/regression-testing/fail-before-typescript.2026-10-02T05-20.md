# Fail-before: TypeScript regression test (issue #543)

Timestamp: 2026-10-02T05-20
Task: P1-T4 [expect-fail]
Command: `node run-jest.cjs test/lib/validate/epic-planner-state-launch-binding.test.ts -t "skips launch binding for a feature without launch paths"` (in `extensions/drm-copilot/`)
EXIT_CODE: 1
ExpectedExitCode: 1

Output Summary:
- `Test Suites: 1 failed, 1 total`
- `Tests:       1 failed, 14 skipped, 15 total` (1 failed for the selected title)
- `error TS` lines: 0 (the test compiles against pre-fix `ValidateEpicPlannerStateOptions`; the failure is behavioural).
- Jest failure: `● epic planner child launch binding › skips launch binding for a feature without launch paths`, at the launch-binding assertion `expect(errors.filter((error) => error.includes(" launch binding"))).toEqual([])`; received the five errors:
  - `Epic planner checkpoint features[0] launch binding.branch_name must be a non-empty unique string.`
  - `Epic planner checkpoint features[0] launch binding.worktree_path must be a non-empty canonical absolute path.`
  - `Epic planner checkpoint features[0] launch binding.launch_receipt_path must be under artifacts/orchestration/epic-child-launches/.`
  - `Epic planner checkpoint features[0] launch binding.launch_status_path must be under artifacts/orchestration/epic-child-launches/.`
  - `Epic planner checkpoint features[0] launch binding.delegation_receipt must be an object.`
- D1 note: the test file carried 224 lines before this edit (planning-time 220) because of the merged `isRecord` helper; the new helpers and test were placed by construct.
