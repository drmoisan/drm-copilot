# Fail-Before CR-8 TypeScript (P2-T6) [expect-fail]

Timestamp: 2026-10-16T06-26
Command: npm --prefix extensions/drm-copilot test -- test/lib/validate/epic-planner-git-integrity-feature-indices.test.ts > SCRATCH/rc2/ts-cr8-fail-before.txt 2>&1; grep -e 'Tests:' -e 'error TS' -e 'features\[1\].planning_commit' SCRATCH/rc2/ts-cr8-fail-before.txt
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
- Tests:       1 failed, 6 passed, 7 total
- error TS lines: 0
- Failing title: validatePlanningGitIntegrity original feature index > matches a dot-prefixed plan_path to its normalized plan
- Received-value line: +   "Epic planner checkpoint features[1].planning_commit must be hexadecimal.",
  (strict equality finds no entry for the dot-prefixed plan_path, so pairing falls back to positional order and attributes the bad commit to features[1] instead of features[2])
