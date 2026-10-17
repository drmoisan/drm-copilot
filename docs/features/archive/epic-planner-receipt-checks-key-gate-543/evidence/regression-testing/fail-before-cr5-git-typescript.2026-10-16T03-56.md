# Fail-Before CR-5 TypeScript Git Integrity (P1-T8) [expect-fail]

Timestamp: 2026-10-16T03-56
Command: npm --prefix extensions/drm-copilot test -- test/lib/validate/epic-planner-git-integrity-feature-indices.test.ts > SCRATCH/rc1/ts-git-fail-before.txt 2>&1; grep -e 'Tests:' -e 'error TS' -e 'features\[1\].planning_commit' SCRATCH/rc1/ts-git-fail-before.txt
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
- Tests:       2 failed, 4 passed, 6 total (pre-fix production code)
- error TS lines: 0
- Received-value line (compacted index, first failure):
      +   "Epic planner checkpoint features[1].planning_commit must be hexadecimal.",
- Expected-value line of the second failure (received []):
      -   "Epic planner checkpoint features[1].planning_commit must be hexadecimal.",
- Failing cases: "uses the original feature index after a non-object entry" and "uses the original feature index after a plan-less entry"; the four preservation cases pass.
