# Baseline WE-TEST Jest Run (P0-T15, Issue #934, remediation cycle 1)

Timestamp: 2026-10-16T02-46
Command: npx jest --config jest.config.cjs --verbose --runTestsByPath test/lib/subagent-tree/workspace-encoding.test.ts   (working directory: extensions/drm-copilot; output redirected to SCRATCH/issue-934/jest-we-rem-baseline.log)
EXIT_CODE: 0
Output Summary:
- First run printed only the summary block: `Test Suites: 1 passed, 1 total`; `Tests:       9 passed, 9 total`; `Snapshots:   0 total`; `Ran all test suites within paths "test/lib/subagent-tree/workspace-encoding.test.ts".` No per-test title lines.
- Command: `npx jest --config jest.config.cjs --verbose --runTestsByPath test/lib/subagent-tree/workspace-encoding.test.ts --json --outputFile=../../SCRATCH/issue-934/jest-we-rem-baseline.json` -> EXIT_CODE: 0; stdout `Tests:       9 passed, 9 total`; JSON file written to `SCRATCH/issue-934/jest-we-rem-baseline.json`.
- From the JSON file (Grep tool, content mode, `-o`, pattern `"num(Passed|Total|Failed)Tests":[0-9]+`): `numFailedTests` 0, `numPassedTests` 9, `numTotalTests` 9.
- Baseline title list from the JSON file (Grep tool, content mode, `-o`, pattern `"fullName":"[^"]*"`), 9 entries in execution order (count equals `numTotalTests`):
  1. encodeWorkspacePath replaces backslashes, forward slashes, and colons with hyphens
  2. encodeWorkspacePath encodes a forward-slash workspace path identically to a backslash one
  3. matchEncodedDirectories matches an on-disk directory whose drive-letter segment uses a lowercase letter against an uppercase-encoded workspace name
  4. matchEncodedDirectories includes a per-worktree sibling folder among the matched candidate directories
  5. matchEncodedDirectories includes a nested worktree-of-a-worktree sibling folder
  6. matchEncodedDirectories returns an empty array when no directory name matches
  7. matchEncodedDirectories matches a new-scheme nested worktree sibling encoded name
  8. matchEncodedDirectories matches a new-scheme worktree-of-a-worktree encoded name
  9. matchEncodedDirectories matches by exact equality when the workspace root is the nested leaf
- The JSON `name` field (absolute test-file path) is not copied into this artifact (redaction rule item 1).
