# Final QC: WE-TEST Jest Run (P2-T6, Issue #934, remediation cycle 1)

Timestamp: 2026-10-16T03-06
Command: npx jest --config jest.config.cjs --verbose --runTestsByPath test/lib/subagent-tree/workspace-encoding.test.ts   (working directory: extensions/drm-copilot; output redirected to SCRATCH/issue-934/jest-we-rem-final.log)
EXIT_CODE: 0
Output Summary:
- First run: `Test Suites: 1 passed, 1 total`; `Tests:       9 passed, 9 total`. N = 9 equals the count in the greatest baseline artifact `FEATURE/evidence/remediation-baseline/jest-workspace-encoding.2026-10-16T02-46.md` (9).
- Command: `npx jest --config jest.config.cjs --verbose --runTestsByPath test/lib/subagent-tree/workspace-encoding.test.ts --json --outputFile=../../SCRATCH/issue-934/jest-we-rem-final.json` -> EXIT_CODE: 0; stdout `Tests:       9 passed, 9 total`; JSON file written.
- From the JSON file (Grep tool, content mode, `-o`, pattern `"num(Passed|Total|Failed)Tests":[0-9]+`): `numFailedTests` 0, `numPassedTests` 9, `numTotalTests` 9.
- Title list from the JSON file (Grep tool, content mode, `-o`, pattern `"fullName":"[^"]*"`), 9 entries in execution order:
  1. encodeWorkspacePath replaces backslashes, forward slashes, and colons with hyphens
  2. encodeWorkspacePath encodes a forward-slash workspace path identically to a backslash one
  3. matchEncodedDirectories matches an on-disk directory whose drive-letter segment uses a lowercase letter against an uppercase-encoded workspace name
  4. matchEncodedDirectories includes a per-worktree sibling folder among the matched candidate directories
  5. matchEncodedDirectories includes a nested worktree-of-a-worktree sibling folder
  6. matchEncodedDirectories returns an empty array when no directory name matches
  7. matchEncodedDirectories matches a new-scheme nested worktree sibling encoded name
  8. matchEncodedDirectories matches a new-scheme worktree-of-a-worktree encoded name
  9. matchEncodedDirectories matches by exact equality when the workspace root is the nested leaf
- Comparison: identical, entry for entry and in order, to the JSON-derived baseline title list in `jest-workspace-encoding.2026-10-16T02-46.md`.
- No absolute path from the JSON `name` field or console output is copied here (redaction rule item 1).
- Verdict: PASS.
